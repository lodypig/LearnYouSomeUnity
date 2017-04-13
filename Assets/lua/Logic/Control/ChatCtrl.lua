
function CreateChatCtrl()
	local chat = {};
	local onChatChange = {};
	local count = 0;
	local richText = nil;
	local chatItem = nil;
	chat.chatCD = -1;
	chat.EMAIL_TIME_LIMIT = 2592000 --30天
	chat.haveNewEmail = false;

	chat.lastTimeStamp = {};	--记录上一次的时间戳

	chat.AddListener = function (listener)
		for i = 1, count do
			if onChatChange[i] == nil  then
				onChatChange[i] = listener;
				return i;
			end
		end
		count = count + 1;
		onChatChange[count] = listener;
		return count;
	end

	chat.RemoveListener = function (index)
		onChatChange[index] = nil;
	end

	chat.OnEvent = function (param)
		for i = 1, 1 do
			if (onChatChange[i]) then
				onChatChange[i](param);
			end
		end
	end

	chat.getSpeechFromServer = function (callBack, speechID)
		local msg = {};
		msg.cmd = "get_speech_chat"
		msg.speech_id = speechID;
		Send(msg, callBack);
	end

    chat.chatContentList = 
	{
		world = {},
		current = {},
		system = {},
		clan = {},
		team = {},
		email = {},
	};

	function chat.mail()
		local data = {channel = "email",id = 1,title = "邮件1"}
		data.items = {}

		chat.InsertToList("email", data)
		chat.OnEvent(data);
	end

	chat.ChatListMaxSize = {
		world = 100,
		system = 100,
		clan = 50,
		team = 20,
		email = 100
	}; --聊天记录上限

	function chat.onRefresh1Sec()
		if chat.chatCD >= 0 then
    		chat.chatCD = chat.chatCD - 1;
    	end
	end

	function chat.InsertToList(channel, data)
		data.textHeight = chat.GetChatTextHeight(data);
		local list = chat.chatContentList[channel];

		if list ~= nil then
			if #list >= chat.ChatListMaxSize[channel] then
				chat.Dequeue(list);
			end
			--插入时间戳
			chat.CheckInsertTime(channel, list, data)
			chat.Enqueue(list, data);
		end
	end

	function chat.CheckInsertTime(channel, list, data)
		if channel ~= "clan" then
			return
		end

		if #list == 0 then
			--第一条消息直接加入时间戳
			chat.InsertTimeStamp(channel, list, data.time);
		else
			local lastMsg = list[#list].data;

			--与上条消息时间间隔大于2分钟，加入时间戳
			if data.time - lastMsg.time > 2*60 then 
				chat.InsertTimeStamp(channel, list, data.time);
			else
				--否则判断与上次的时间戳间隔，大于5分钟则加时间戳
				if data.time - chat.lastTimeStamp[channel] > 5*60 then
					chat.InsertTimeStamp(channel, list, data.time);
				end
			end
		end
	end

	function chat.InsertTimeStamp(channel, list, time)
		local data = {};
		data.time = time;
		data.isTimeStamp = true;
		data.textHeight = 50;
		chat.lastTimeStamp[channel] = time;
		chat.Enqueue(list, data);
	end

	-- 进队列
	function chat.Enqueue(queue, data)
	    if queue == nil then
	        return;
	    end

	    local value = {};
	    value.posY = 0;
	    value.data = data;
	    local count = #queue;
	    if count > 0 then
	    	value.posY = queue[count].posY + queue[count].data.textHeight;
	    end

	    queue[count + 1] = value;
	end

	-- 出队列
	function chat.Dequeue(queue)
	    if queue == nil or #queue == 0 then
	        return nil;
	    end

	    local count = #queue;
	    local value = queue[1];
	    local posY = 0;
	    for i = 1, count - 1 do
	        queue[i] = queue[i + 1];
	        queue[i].posY = posY;
	        posY = queue[i].posY + queue[i].data.textHeight;
	    end
	    queue[count] = nil;
	    return value;
	end

	function chat.GetChatTextHeight(data)
		if data.channel == "email" then
			return 103
		end

		if data.redpacket ~= nil and data.redpacket ~= 0 then
			return 190;
		end

		--聊天相关
		if richText == nil then
			richText = UIManager.GetInstance():FindUI("SysLayer"):GO("richText"):GetComponent("LRichText");
		end

		local offset = 0; 
        if data.channel == "system" or data.isSystemTip then
        	offset = 45;	--系统消息没有头像，偏移较小
        	richText.maxLineWidth = 420;
        	richText.text = const.richChatChannel[data.channel]..data.text;
        else
        	offset = 70; --人物聊天气泡以及头像等其它元素的额外高度
        	richText.maxLineWidth = 264;
        	if data.speech == nil or data.speech == 0 then
            	richText.text = data.text;
        	else
           		richText.text = "[n]"..data.text;
        	end
        end

		return richText.realLineHeight + offset;
	end

	function chat.ReceiveChatMsg(msg)
		local content = msg["content"];
		
		-- 只有私聊才添加消息推送音效，目前没有私聊，先注释掉
		--AudioManager.PlaySoundFromAssetBundle("push_message");

		--将每一条聊天数据搞成一个table，塞到相应list中
		local data = {};
		data.channel = content[1];
		data.id = content[2];
		data.role_uid = content[3];
		data.name = client.tools.ensureString(content[4]);
		data.level = content[5];
		data.head_icon = content[6];
		data.speech = content[8];
		data.speechLen = content[9];
		data.title = content[10];
		data.equip = content[11];
		data.item = content[12];
		data.redpacket = content[13];
		data.time = content[14];
		data.isSystemTip = content[15] == 1;
		if data.isSystemTip then
			data.text = client.GetChatString(data.title, content[7]);
		else
			data.text = client.tools.ensureString(content[7]);
		end
		data.filter = data.redpacket ~= nil and data.redpacket ~= 0;
		data.isPlay = false;
		chat.InsertToList(data.channel, data);
		chat.OnEvent(data);
	end

	--for client
	function chat.clientSystemMsg(text, item, equip, channel, filter,redpacket)
		local data = {};
		data.channel = channel == nil and "system" or channel;
		data.text = text;
		data.speech = 0;
		--是否系统提示
		data.isSystemTip = true;
		--主界面聊天区是否过滤
		data.filter = filter;
		if equip ~= nil then
			data.equip = equip;--client.equip.toSend(equip, nil);
		else
			data.equip = 0;
		end
		if item ~= nil then
			data.item = item.sid;
		else
			data.item = 0;
		end
		if redpacket ~= nil then
			data.redpacket = redpacket
		else 
			data.redpacket = 0
		end
		data.time = TimerManager.GetServerNowSecond();
		chat.InsertToList(data.channel, data);
		chat.OnEvent(data);
	end

	function chat.canSend(channel)
		if channel == "world" then
			if DataCache.myInfo.level < 20 then
				ui.showMsg("达到20级方可在世界频道发言")
				return false;
			end

			if chat.chatCD > 0 then
				ui.showMsg(string.format("您的发言过于频繁，请%s秒后再试", chat.chatCD));
				return false;
			end
		end

		if channel == "team" and client.role.haveTeam() == false then
			client.chat.clientSystemMsg("未处于队伍中", nil, nil, "team", false)
			return false;
		end

		if channel == "clan" and client.role.haveClan() == false then
			ui.showMsg("未处于公会中")
			return false;
		end

		return true;
	end

	SetPort("chat",chat.ReceiveChatMsg);
	
	
	function chat.send(channel, text, speech, speechLen, inputItem)
		if channel == "all" or channel == "system" then
			return false;
		end

		--屏幕敏感字
		text = StrFiltermanger.Instance:Replace(text);

		local msg = {};
		msg.cmd = "chat";
		msg.channel = channel;
		msg.id = DataCache.nodeID;
		msg.role_uid = DataCache.myInfo.role_uid;
		msg.name = DataCache.myInfo.name;
		msg.level = DataCache.myInfo.level;
		msg.head_icon = const.RoleImgTab[DataCache.myInfo.career][DataCache.myInfo.sex + 1];
		msg.text = text;
		msg.speech = speech;
		msg.speechLen = speechLen;
		msg.title = 0;

		if inputItem ~= nil and inputItem.id ~= 0 then
		    msg.item = 0;
		    if inputItem.type == 3 then
		    	msg.item = inputItem.id;
		    else
		    	msg.equip = client.equip.toSend(inputItem.item, Bag.enhanceMap[inputItem.itemCfg.buwei], client.gem.getEquipGem(inputItem.itemCfg.buwei));
		    end
		end

        Send(msg);

        if channel == "world" then
        	chat.chatCD = 5;
        end
        return true;
	end

	function chat.ChatRecordCallback(msg)
		local chat_list = msg["chat_list"];
		if (chat_list == nil) then
			return;
		end

		local content = nil;
		local channel;
		for i = 1, #chat_list do
			content = chat_list[i];

			local data = {};
			data.channel = content[1];
			channel = data.channel;
			data.id = content[2];
			data.role_uid = content[3];
			data.name = client.tools.ensureString(content[4]);
			data.level = content[5];
			data.head_icon = content[6];
			data.speech = content[8];
			data.speechLen = content[9];
			data.title = content[10];
			data.equip = content[11];
			data.item = content[12];
			data.redpacket = content[13];
			data.time = content[14];
			data.isSystemTip = content[15] == 1;
			if data.isSystemTip then
				data.text = client.GetChatString(data.title, content[7]); 
			else
				data.text = client.tools.ensureString(content[7]);
			end
			data.filter = data.redpacket ~= nil and data.redpacket ~= 0;
			data.isPlay = true;
			chat.InsertToList(data.channel, data);
		end		

		if channel == "world" then
			UIManager.GetInstance():CallLuaMethod('MainUI.addChatRecord');
		end
	end


	function chat.getChatRecord()
		chat.getChatRecordList("system");
		chat.getChatRecordList("clan");
		chat.getChatRecordList("team");
		chat.getChatRecordList("world");
		chat.getEmailList()
	end


-------------------------------邮件-----------------------------------

	function chat.parseEmail(content)
		local data = {}
		data.channel = "email"
		data.id = content[1] --数据库中id
		data.sid = content[2] --配表中id
		data.sendtime = content[3]	
		data.readed = content[4]
		data.items = {}
		for i = 1,#content[5] do
			local obj = content[5][i];
			
			if	obj[1] == "item" then
				for j = 1,#obj[2] do
					data.items[#data.items + 1] = {type = "item",value = obj[2][j]}
				end
			else--数值类奖励
				data.items[#data.items + 1] = {type = obj[1],value = obj[2]}	
			end
		end
		data.description = tb.email[data.sid].description
		local args = content["args"]
		if args ~= nil then
			for i = 1,#args do
				data.description = string.gsub(data.description,'%$',client.tools.ensureString(args[i]),1)
			end
		end

		return data
	end

	function chat.InsertToEmailList(data)
		if chat.GetMailById(data.id) == nil then
			chat.InsertToList(data.channel, data);
			if data.readed == 0 then
				chat.OnEvent(data);
			end
			return
		end
	end

	function chat.ReceiveEmailMsg(msg)
		--print("chat.ReceiveEmailMsg")
		local content = msg["content"];
		local data = chat.parseEmail(content);
		chat.SortMail()
		chat.chatContentList.email = ReverseTable(chat.chatContentList.email)
		
		chat.InsertToEmailList(data)
		UIManager.GetInstance():CallLuaMethod('UIChat.UpdataEmailList');

		AudioManager.PlaySoundFromAssetBundle("receive_mail");

		chat.checkEmailTip();
		--登录时发送邮件奖励，主界面还没有生成，延迟1s执行
		-- local t = Timer.New(function ()
		-- 	UIManager.GetInstance():CallLuaMethod('MainUI.ShowNewMailIcon');
		-- end,3,1,false)
		-- t:Start()
	end
	SetPort("email",chat.ReceiveEmailMsg);

	local loginfirstcheck = true;
	function chat.EmailRecordCallback(msg)
		local list = msg["email_list"];
		if (list == nil) then
			return;
		end
		chat.chatContentList.email = {}

		for k,v in pairs(list) do
			local data = chat.parseEmail(v);
			chat.InsertToEmailList(data)
		end

		chat.checkEmailTip();
	end
	

	function chat.GetMailById(id)
		local list = chat.getContentByChannel("email")
		for i = 1,#list do
			if list[i].data.id == id then
				return list[i].data
			end			
		end
		return nil
	end
	function chat.GetMailByIndex(index)
		local list = chat.getContentByChannel("email")
		if index > 0 and index <= #list then
			return list[index].data
		end
		return nil
	end

	function chat.handleOverdueMail()
		local list = chat.getContentByChannel("email")
		chat.chatContentList.email = {}
		for i = 1,#list do		
			if not chat.IsEmailOverdue(list[i].data) then
				chat.InsertToEmailList(list[i].data)
			end
		end
	end

	function chat.IsEmailOverdue(mail)
		return TimerManager.GetServerNowMillSecond()/1000 - mail.sendtime > chat.EMAIL_TIME_LIMIT
	end
	
	function chat.GetMailIndexById(id)
		local list = chat.getContentByChannel("email")
		for i = 1,#list do
			if list[i].data.id == id then
				return i
			end			
		end
		return -1
	end

	function chat.SortMail()
		local function mailSortFunc(a, b)
			if a.data.readed ~= b.data.readed then
				return a.data.readed == 0;
			end
			--if client.chat.IsMailHaveAward(a.data) ~= client.chat.IsMailHaveAward(b.data) then
			--	return client.chat.IsMailHaveAward(a.data)
			--end
			if a.data.sendtime ~= b.data.sendtime then
				return a.data.sendtime > b.data.sendtime
			end
			return a.data.id > b.data.id;
		end
		table.sort(chat.chatContentList.email, mailSortFunc);
	end

	function chat.IsMailHaveAward(mail)
		return #mail.items > 0 
	end
	function chat.IsMailHaveNotAward(mail)
		return #mail.items == 0;
	end

	function chat.IsHaveAwardMails()
		local list = chat.getContentByChannel("email")
		for k,v in pairs(list) do
			if chat.IsMailHaveAward(v.data) then
				return true
			end
		end
		return false
	end
	function chat.IsHaveNotReadMails()
		local list = chat.getContentByChannel("email")
		for k,v in pairs(list) do
			if v.data.readed == 0 then
				return true
			end
		end
		return false
	end
	function chat.IsHaveNotAwardMails()
		local list = chat.getContentByChannel("email")
		for k,v in pairs(list) do
			if chat.IsMailHaveNotAward(v.data) then
				return true;
			end
		end
		return false;
	end

	function chat.checkEmailTip()
		local show = chat.IsHaveAwardMails() or chat.IsHaveNotReadMails();
		UIManager.GetInstance():CallLuaMethod('MainUI.ShowTipsEmail', show);
		-- body
	end

	function chat.DeleteMailById(id)
		local list = chat.getContentByChannel("email")
		local index = chat.GetMailIndexById(id);
		if index ~= -1 then
			table.remove(list,index);
		end

		chat.chatContentList.email = list
		--chat.checkEmailTip();
		UIManager.GetInstance():CallLuaMethod('UIChat.UpdataEmailList');
	end
	--标记为已读
	function chat.MarkEmailReaded(id)
		local mail = chat.GetMailById(id);
		mail.readed = 1
		--chat.checkEmailTip();
	end
	--读邮件
	function chat.readEmail(id)
		local msg = {};
		msg.cmd = "read_email"
		msg.mailid = id
        Send(msg);
	end
	--提取附件
	function chat.getEmailAward(id, callback)
		local msg = {};
		local index = chat.GetMailIndexById(id);
		msg.cmd = "get_email_award"
		msg.mailid = id
        Send(msg,  function (msg)
        	if msg.type == "ok" or msg.type == "overdue" then
        		chat.DeleteMailById(msg.mailid)
        		callback(id, index);
        	end
        end);
	end

	function chat.deleteEmailAll()
		local msg = {};
		msg.cmd = "delate_email_all_no_award";
		Send(msg, function (msg)
			if msg.email_list ~= nil then
               	chat.getEmailAwardAllCallBack(msg)
            end
		end)
	end

	--提取全部附件
	function chat.getEmailAwardAllCallBack(msg)
		client.chat.EmailRecordCallback(msg) 
        UIManager.GetInstance():CallLuaMethod('UIChat.UpdataEmailList');
	end

	SetPort("email_list",chat.getEmailAwardAllCallBack);

	function chat.getEmailAwardAll()
		if not chat.IsHaveAwardMails() then
			ui.showMsg("没有可提取的附件")
			return
		end
		local msg = {};
		msg.cmd = "get_email_award_all"
        Send(msg,function(msg) 
        	if msg.email_list ~= nil then
        		--ui.showMsg("领取成功")
        		chat.getEmailAwardAllCallBack(msg)
        	end
        	end);
	end
	--删除邮件
	function chat.deleteEmail(id, callback)
		local msg = {};
		local index = chat.GetMailIndexById(id);
		msg.cmd = "delete_mail"
		msg.mailid = id
        Send(msg);
        chat.DeleteMailById(id)
        callback(id, index);
	end
	--获取邮件列表
	function chat.getEmailList()
		local msg = {};
		msg.cmd = "get_email_list"
        Send(msg,  chat.EmailRecordCallback);
	end

	function chat.getChatRecordList(channel)
		local msg = {};
		msg.cmd = "get_world_chat";
		msg.channel = channel;
		msg.count = chat.ChatListMaxSize[channel];
		
        Send(msg,  chat.ChatRecordCallback);
	end

	function chat.getContentByChannel(channel)
		if chat.chatContentList[channel] == nil then 
			return nil;
		end
		return chat.chatContentList[channel];
	end

	EventManager.bind(PanelManager.UIRoot.gameObject, Event.ON_TIME_SECOND_CHANGE, chat.onRefresh1Sec);

	return chat;
end

client.chat = CreateChatCtrl();