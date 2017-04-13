
function CreateFubenCtrl()
	local fuben = {};
	fuben.startTime = 0;	--开始挑战副本时间
	fuben.parpareTime = 0;  --开始匹配时间
	fuben.curFubenId = 10001;	--正在挑战的副本ID
	fuben.deathblow = 0;		--致命攻击次数

	local fubenRecord = {}			--通关的副本记录

	fuben.matchFuben = {}

	--正在匹配过程数据
	fuben.cur_leader_id = 0;
	fuben.cur_fuben_sid = 0;

	--默认是显示副本队列界面
	fuben.start_prepare_flag = false;

	local Fuben_Tip={
		fuben_forbid_transfer = "处于特殊区域，匹配失败",
		fuben_role_offline = "已离线，匹配失败",
		fuben_highlevel_norandom = "地狱副本无法随机",
		fuben_challenge_countlimit = "秘境次数不足，匹配失败",
		fuben_level_limit = "等级不足，匹配失败",
		fuben_front_notcomplete = "未完成前置副本%s，匹配失败",
		fuben_musle_notenough = "体力值不足，匹配失败",
		fuben_tick_notenough = "缺少地狱副本门票，匹配失败",
	}

	--获取副本界面的显示列表
	function fuben.getFubenList()
		local list = tb.fubendif2id[1];
		local showList = {};
		for i=1, #list do
			local id = list[i];
			local item = tb.fuben[id];
			if item.minlevel <= DataCache.myInfo.level then
				showList[i] = tb.fuben[id];
				showList[i].lock = false;
			end
		end

		--加一个未解锁的（如增加后不足3个则加满3个）
		local count = math.max(#showList + 1, 3);
		count = math.min(count, #list);
		for i = #showList + 1, count do
			showList[i] = tb.fuben[list[i]];
			showList[i].lock = true;
		end

		return showList;
	end

	-------------------------------------------------
	--获取挑战记录
	function fuben.q_get_fuben_record()

		local msg = {cmd = "get_fuben_record"}
        Send(msg, function(msg) fuben.cb_getFubenRecord(msg) end); 
	end

	function fuben.cb_getFubenRecord(msg)
		local fuben_records = msg.record
		if fuben_records == nil then
			return
		end
		for k,v in pairs(fuben_records) do
			local record = {}
			local sid = v[2]
			record.max_star = v[3]
			record.challenge_num = v[4]
			fubenRecord[sid] = record;
		end

	end

	function fuben.getChallengeNum()
		local num = 0;
		for k,v in pairs(fubenRecord) do
			num = num + v.challenge_num
		end

		return num;
	end

	-------------------------------------------------
	--发起挑战
	function fuben.challenge_fuben(fubenInfo)
		local dofunc = function(fubenInfo_)
			--如果已经报名，则取消报名
			local isMatch = client.fuben.isMatching(fubenInfo_.sid);
			if isMatch then
				client.fuben.cancel_challenge(fubenInfo_.sid);
				return false;
			end
			if client.fuben.check_challenge(fubenInfo_) == false then
				return false;
			end

			if client.role.haveTeam() and not client.role.isTeamLeader() then
				ui.showMsg("只有队长可以进行此操作");
				return false;
			end

			--已经在准备
			if client.fuben.start_prepare_flag then
				ui.showMsg("准备阶段无法进行报名");
				return false;
			end

			local list = client.team.getTeamList(false);
			for i=1,#list do
				if list[i].state == "offline" then
					ui.showMsg(string.format("%s已离线，匹配失败",list[i].name));
					return false;
				end
			end

			client.fuben.q_challenge_fuben(fubenInfo_.sid, "team");
			return true
		end
		
		local fromSceneSid = DataCache.scene_sid;
        if fromSceneSid == 1020 and client.MolongTask.BIsStart == true then
            local tip = "当前正处于护送任务过程中，离开魔龙岛会导致任务失败，是否继续？"
            ui.showMsgBox(nil, tip, function()
                dofunc(fubenInfo)
            end)
            return false  
        else  
        	return dofunc(fubenInfo)
        end
	end

	--取消挑战
	function fuben.cancel_challenge(sid)
		if client.role.haveTeam() and not client.role.isTeamLeader() then
			ui.showMsg("只有队长可以操作");
			return false;
		end

		client.fuben.q_quit_fuben_queue(sid, function() end)
		return true
	end

	--挑战检查
	function fuben.check_challenge(fubenInfo)
		--等级判断
		if DataCache.myInfo.level < fubenInfo.minlevel then
			ui.showMsg(string.format("需要达到%s级才可进入", fubenInfo.minlevel));
			return false;
		end

		local id = fubenInfo.sid;
		local num = client.fuben.getChallengeNum();

		if num >= tb.DailyActTable[const.ActivityId.shiLianMiJing].times then
			ui.showMsg("副本挑战次数达到上限");
			return false;
		end

		return true;
	end

	--请求挑战副本
	function fuben.q_challenge_fuben(fubensid, mode)
		local msg = {cmd = "challenge_fuben", fuben_sid = fubensid, challenge_mode = mode}
        Send(msg, fuben.listen_fuben_tip)
	end

	--随机副本挑战
	function fuben.q_auto_challenge_fuben()
		fuben.q_challenge_fuben(999999, "team")
	end

	--离开副本
	function fuben.q_leave_fuben()
        EventManager.onEvent(Event.ON_LEAVE_FUBEN);
		local msg = {cmd = "leave_fuben"}
        Send(msg, fuben.cb_leave_fuben); 
	end

	function fuben.cb_leave_fuben()
	end

		--进入副本成功
	function fuben.listen_enter_succeed(msg)
		--增加角色副本挑战次数
		local fuben_sid = msg.fuben_sid
		fuben.curFubenId = fuben_sid
		DataCache.curFubenId = fuben_sid;
		local record = fubenRecord[fuben_sid]
		if record ~= nil then
			record.challenge_num = record.challenge_num + 1
		end

		fuben.Set_start_prepare_flag(false)

		--如果是组队状态 则自动组队删除该副本
		if client.FuBenAutoTeam.HaveFuBen(999999) then
			client.FuBenAutoTeam.Dequeue(999999)
		else
			client.FuBenAutoTeam.Dequeue(fuben_sid)
		end
		client.FuBenAutoTeam.PauseAll()
		--进入副本就不显示组队头顶按钮
		MainUI.FuBenPiPeiShow(false)
		MainUI.PlayPiPeiEffect(false)

		UIManager.GetInstance():DestoryAllUI();
	end

	--进入副本失败
	function fuben.listen_enter_fail(msg)
		--返回给玩家失败原因(最后状态突变照成失败的原因 暂时木有做)
		fuben.Set_start_prepare_flag(false)
		client.FuBenAutoTeam.PauseAll()
		UIManager.GetInstance():CallLuaMethod('UIFubenZhunBei.Close');
	end

	function fuben.list_fuben_broadcast(msg)
		local msgType = msg.type;
		if msgType == "fuben_success" then
			FubenManager.OnNotify(FubenHandlerType.OnResult, { success = true , ["data"] = msg});
		elseif msgType == "fuben_fail" then
			FubenManager.OnNotify(FubenHandlerType.OnResult, { success = false });
		elseif msgType == "fuben_login" then
			--受到致命攻击次数
			fuben.deathblow = tonumber(fuben.get_roleEvent_value("dying", msg["roleEvent"]));
			--副本开始时间
			fuben.startTime = tonumber(msg["init_time"]);
			fuben.parpareTime = tonumber(msg["init_time"]);
			--副本ID
			if msg.sid ~= nil then
				fuben.curFubenId = msg.sid;
				DataCache.curFubenId = msg.sid;
			end

			-- 通知副本开启
			FubenManager.OnNotify(FubenHandlerType.OnStart, msg);
			
		elseif msgType == "fuben_role_update" then
			fuben.deathblow = tonumber(fuben.get_roleEvent_value("dying", msg["event"]));
		end

		--有机器人列表 清空在队伍上的机器人数据
		local robot_list = msg.robot_list
		if robot_list~= nil and #robot_list ~= 0 then
			--delete robot team
			for k,v in pairs(robot_list) do
				client.team.do_team_leave(v)
			end
            --若队伍中只有自己是真人，则需要清除掉假的队伍标记
            if #robot_list == 4 then
                client.team.clearTeam();
                client.team.OnEvent();
            end
		end
	end

	function fuben.get_roleEvent_value(eventType, roleEvents)
		for i=1, #roleEvents do
			if roleEvents[i][1] == eventType then
				return roleEvents[i][2];
			end
		end

		return 0;
	end

	--------------------------匹配相关-----------------------
	--是否匹配中
	function fuben.isMatching(fubenId )
		return fuben.matchFuben[fubenId] ~= nil and fuben.matchFuben[fubenId];
	end

	function fuben.isPrepare(fubenId)
		return fuben.start_prepare_flag and fuben.cur_fuben_sid == fubenId;
	end

	--退出副本匹配队伍
	function fuben.q_quit_fuben_queue(fubensid, callback)
		local msg = {cmd = "quit_fuben_queue", fubenId = fubensid}
        Send(msg, callback); 
	end

	-------------------------------------------------
	--准备确认
	function fuben.q_confirm_prepare(leader_id, fubensid, answer, callback)
		local msg = {cmd = "confirm_prepare", leaderId = leader_id, fubenId = fubensid, result = answer}
        Send(msg, callback); 
	end

	-------------------------------------------------
	--准备失败再次请求匹配
	function fuben.fuben_prepare_info(fubensid, callback)
		local msg = {cmd = "enter_queue_spec", fubenId = fubensid}
        Send(msg, callback); 
	end

	-------------------------------------------------
	--匹配超时请求匹配机器人
	function fuben.fuben_robot_match(fubensid)
		local msg = {cmd = "fill_robot", fubenId = fubensid}
        Send(msg, function() end); 
	end

	-------------------------------------------------

	--匹配成功 开始准备
	function fuben.listen_fuben_start_prepare(msg)
		fuben.cur_leader_id = msg.leaderId
		fuben.cur_fuben_sid = msg.fubenId
		--msg.list 所有人5个人
		fuben.cur_member_list = msg.list
		fuben.Set_start_prepare_flag(true)

		--测试用
		-- fuben.q_confirm_prepare(fuben.cur_leader_id, fuben.cur_fuben_sid, 1, function() 
		-- 	--print("send confirm prepare   callback !!!!")
		-- end)

		client.FubenZhunBei.StartPrepare()
		client.FuBenAutoTeam.PauseAll()
		-- client.FuBenAutoTeam.Enqueue(fuben.cur_fuben_sid)

		for k,v in pairs(msg.list) do
			--机器人 自动准备
			if v == "robot" then
				local t = Timer.New(function() client.FubenZhunBei.Enqueue("robot") end, math.random(3), 1, false)
				t:Start()
			end
		end
	end

	--准备后收到消息
	function fuben.listen_fuben_prepare_info(msg)
		local role_id = msg.roleId
		local result = msg.result

		if result == 1 then
			client.FubenZhunBei.Enqueue(role_id)
			--同意
			--UI 打勾de
		elseif result == 0 then
			--拒绝者是自己或者队伍成员
			if client.team.isRoleInMyTeam(role_id) then
				--系统提示 --队长专属
				if client.team.haveTeam() and client.team.isLeader(DataCache.roleID) then
					local str = string.format("%s取消准备，匹配失败",client.team.team_members[role_id].name)
					ui.showMsg(str)
				end
				--队伍频道提示
				local name = client.tools.formatRichTextColor(client.team.team_members[role_id].name, const.mainChat.nameColor);
				local str2 = string.format("%s取消准备，匹配失败", name)
				client.chat.clientSystemMsg(str2, nil, nil, "team")
			elseif role_id == DataCache.roleID then
			--跟拒绝者不在同一队伍 --> 立即自动上发重新匹配请求
			else
				fuben.fuben_prepare_info(fuben.cur_fuben_sid, function () end)
			end

			--直接关闭改为先打叉再关闭
			UIManager.GetInstance():CallLuaMethod('UIFubenZhunBei.ShowCross');
			fuben.Set_start_prepare_flag(false)			
			--有随机副本先将随机副本出队列
			-- if client.FuBenAutoTeam.HaveFuBen(999999) then
			-- 	client.FuBenAutoTeam.Dequeue(999999)
			-- else
			-- 	client.FuBenAutoTeam.Dequeue(fuben.cur_fuben_sid)
			-- end
			client.FuBenAutoTeam.PauseAll();
			fuben.check_show_fubenpipei();
			if fuben.cur_fuben_sid ~= 0 then
			-- fuben.q_enter_fuben_spec(fuben.cur_fuben_sid)
				fuben.cur_fuben_sid = 0
				fuben.cur_leader_id = 0
			end
			-- MainUI.FuBenPiPeiShow(false)
		--现在如果服务器发现时间到了有人未响应，则默认此人同意准备
		elseif result == "timeout" then
			--没有同意的角色列表
			local rolelist = msg.rolelist 
			for i = 1,#rolelist do
				client.FubenZhunBei.Enqueue(rolelist[i]);
				-- if client.team.isRoleInMyTeam(rolelist[i]) == false then
				-- 	fuben.fuben_prepare_info(fuben.cur_fuben_sid, function () end)
				-- end
			end
		else
			local reason = result.reason;
			if result ~= nil and reason ~= nil then
				if client.team.isRoleInMyTeam(role_id) then
					--系统提示 --队长专属
					if client.team.haveTeam() and client.team.isLeader(DataCache.roleID) then
						local str = string.format("%s%s",client.team.team_members[role_id].name, Fuben_Tip[reason])
						ui.showMsg(str)
					end
					--队伍频道提示
					local name = client.tools.formatRichTextColor(client.team.team_members[role_id].name, const.mainChat.nameColor);
					local str2 = string.format("%s%s",name,Fuben_Tip[reason])
					client.chat.clientSystemMsg(str2, nil, nil, "team")
				elseif role_id == DataCache.roleID then
					local str = string.format("%s%s",DataCache.myInfo.name, Fuben_Tip[reason])
					ui.showMsg(str)
				else
					fuben.fuben_prepare_info(fuben.cur_fuben_sid, function () end)
				end
			end

			UIManager.GetInstance():CallLuaMethod('UIFubenZhunBei.ShowCross');
			client.FuBenAutoTeam.PauseAll();
			fuben.Set_start_prepare_flag(false)
			fuben.check_show_fubenpipei();
			if fuben.cur_fuben_sid ~= 0 then
				-- fuben.q_enter_fuben_spec(fuben.cur_fuben_sid)
				fuben.cur_fuben_sid = 0
				fuben.cur_leader_id = 0
			end
		end
	end

	--副本相关提示
	function fuben.listen_fuben_tip(msg)
		local reason = msg.reason
		local role_id = tonumber(msg.role_id)
		local fuben_id = tonumber(msg.fuben_id)
		local mode = msg.mode 
		if mode == "random" then
			ui.showMsg("已报名随机副本")
			return
		end

		if reason == nil then
			local pro = tb.fuben[fuben_id]
			if pro ~= nil and mode == "team" then
				-- local fubenDiff = const.fubenDifficulty_text[pro.difficulty]
				local fubenName = pro.name
				ui.showMsg(string.format("成功报名%s",fubenName))
			end
			return 
		end
		local format = Fuben_Tip[reason]
		if format == nil then
			return
		end
		local tip = ""
		local role_name = ""
		if role_id ~= nil then
			if role_id ~= DataCache.myInfo.sid then
				--查找队友名字
				local info = client.team.getMemberInfo(role_id)
				if info ~= nil then
					role_name = info.name 
				else 
					role_name = ""
				end
			else
				role_name = "你"
			end
		end
		if reason == "fuben_front_notcomplete" then
			local frontfuben = ""
			local pro = tb.fuben[fuben_id]
			if pro ~= nil then
				local frontpro = tb.fuben[pro.frontsid]
				if frontpro ~= nil then
					frontfuben = frontpro.name
				end
			end
			tip = string.format(format, frontfuben)
		else
			tip = format
		end
		--系统提示 --队长专属
		if client.team.haveTeam() then
			if client.team.isLeader(DataCache.roleID) then
				local str = string.format("%s%s", role_name, tip)
				ui.showMsg(str)
			end
		else
			--没有队伍 给自己提示
			local str = string.format("%s%s", role_name, tip)
			ui.showMsg(str)
		end
		--队伍频道提示
		local str2 = ""
		if role_name ~= "" then
			local name = client.tools.formatRichTextColor(role_name, const.mainChat.nameColor);
			str2 = string.format("%s%s", name, tip)
		else
			str2 = tip
		end
		client.chat.clientSystemMsg(str2, nil, nil, "team")
	end

	function fuben.Set_start_prepare_flag(flag)
		MainUI.PlayPiPeiEffect(flag)
		if flag then
			UIManager.GetInstance():CallLuaMethod('UIFubenAutoTeam.OnClose');
			ui.ShowFuBenZhunBei()
		end
		fuben.start_prepare_flag = flag
	end

	--检查是否显示头顶匹配按钮
	function fuben.check_show_fubenpipei()
		--如果队列中有列表 就显示
		if client.FuBenAutoTeam.FubenArray ~= nil and #client.FuBenAutoTeam.FubenArray > 0 then
			MainUI.FuBenPiPeiShow(true)
			MainUI.PlayPiPeiEffect(false)
		else
			MainUI.FuBenPiPeiShow(false)
			MainUI.PlayPiPeiEffect(false)			
		end
	end

	--队长操作匹配列表 成功了下发给所有队员
	function fuben.team_enter_queue(msg)
		local sid = msg.fubenId;
		client.FuBenAutoTeam.Enqueue(sid)
		EventManager.onEvent(Event.ON_FUBEN_MATCH_CHANGE);
	end

	--队长删除了某个匹配列表 通知所有队员
	function fuben.team_leave_queue(msg)
		local sid = msg.fubenId;
		client.FuBenAutoTeam.Dequeue(sid)
		EventManager.onEvent(Event.ON_FUBEN_MATCH_CHANGE);
	end

	--队伍发生变化
	function fuben.team_changed(msg)
		ui.showMsg("队伍发生变化，匹配失败") 
		fuben.Set_start_prepare_flag(false)
		client.FuBenAutoTeam.PauseAll()
	end

	function fuben.prepare_team_change(msg)
		fuben.Set_start_prepare_flag(false)
		UIManager.GetInstance():CallLuaMethod('UIFubenZhunBei.Close');
		client.FuBenAutoTeam.PauseAll()
	end

	function fuben.listen_leave_fuben()
        EventManager.onEvent(Event.ON_LEAVE_FUBEN);
		fuben.check_show_fubenpipei()
		--清除队伍中机器人数据
		client.team.clearRobotInfo()
	end

	function fuben.listen_match_passfail(msg)
		--暂停自动组队
		local role_id = tonumber(msg.role_id)
		local fuben_id = tonumber(msg.fuben_id)

		--未通过是自己或者队伍成员 暂停所有队列
		if client.team.isRoleInMyTeam(role_id) then
			--系统提示 --队长专属
			client.FuBenAutoTeam.PauseAll()
			MainUI.PlayPiPeiEffect(false)
		elseif role_id == DataCache.roleID then
			client.FuBenAutoTeam.PauseAll()
			MainUI.PlayPiPeiEffect(false)
		else
			--非自己队伍或自己未通过 重新发送
			fuben.fuben_prepare_info(fuben_id, function () end)
		end

		fuben.listen_fuben_tip(msg)
	end

	SetPort("fuben_enter_succeed",fuben.listen_enter_succeed)
	SetPort("fuben_enter_failed",fuben.listen_enter_fail)
	SetPort('fuben_broadcast', fuben.list_fuben_broadcast)
	SetPort('fuben_start_prepare', fuben.listen_fuben_start_prepare)
	SetPort('fuben_prepare_info', fuben.listen_fuben_prepare_info)
	SetPort('enter_queue',fuben.team_enter_queue)		--进入匹配队列
	SetPort('quit_queue',fuben.team_leave_queue)		--退出匹配队列
	SetPort('team_change',fuben.team_changed)
	SetPort('prepare_team_change',fuben.prepare_team_change)
	SetPort('fuben_tip',fuben.listen_fuben_tip)
	SetPort('fuben_leave_fuben', fuben.listen_leave_fuben)
	SetPort('fuben_match_passfail', fuben.listen_match_passfail)
	

	-------------------------------------------------
	-------------------------------------------------
	return fuben;
end

client.fuben = CreateFubenCtrl();