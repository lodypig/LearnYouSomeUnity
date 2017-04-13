function SysLayerView()
	local this = nil;
	local SysLayer = {};
	local msg = nil;
	local list = {};
	local msgData = {};
	local intervalTime = 0.5;
	local wrapper = nil;
	local lastDataMsg = {};
	local count = 0;
	local msg1 = nil;
	local msg2 = nil;
	local msg3 = nil;
	local go = nil;
	local rt1 = nil;
	local rt2 = nil;
	local rt3 = nil;
	local rtList = {};
	local lastTime = nil;
	local sequence1 = nil;
	local sequence2 = nil;
	local sequence3 = nil;
	local sequenceList = {nil,nil,nil};
	local msgList = {};
	local Text1 = nil;
	local Text2 = nil;
	local Text3 = nil;
	local TextList = {};
	local CanvasGroup1= nil;
	local CanvasGroup2= nil;
	local CanvasGroup3= nil;
	local CanvasGroupList = {};
	local Icon1 = nil;
	local Icon2 = nil;
	local Icon3 = nil;
	local IconList = {};

	--钻石特效对象
	local diamondObj = nil;
	local diamondEffect = nil;
	local diamondParam = {};

	function SysLayer.Start()
		this = SysLayer.this;
		wrapper = this:GetComponent("UIWrapper");
		lastDataMsg.msg = nil;
		lastDataMsg.type = nil;

		msg1 = wrapper:GO('msg1');
		msg2 = wrapper:GO('msg2');
		msg3 = wrapper:GO('msg3');
		msgList = {msg3,msg1,msg2};

		CanvasGroup1 = msg1:GO("canvasgroup");
		CanvasGroup2 = msg2:GO("canvasgroup");
		CanvasGroup3 = msg3:GO("canvasgroup");
		CanvasGroupList = {CanvasGroup3, CanvasGroup1, CanvasGroup2};

		Text1 = msg1:GO("canvasgroup.Text");
		Text2 = msg2:GO("canvasgroup.Text");
		Text3 = msg3:GO("canvasgroup.Text");
		TextList = {Text3,Text1,Text2};

		rt1 = msg1:GetComponent("RectTransform");
	    rt2 = msg2:GetComponent("RectTransform");
		rt3 = msg3:GetComponent("RectTransform");
		rtList = {rt3,rt1,rt2};

		Icon1 = msg1:GO("Icon");
		Icon2 = msg2:GO("Icon");
		Icon3 = msg3:GO("Icon");
		IconList = {Icon3, Icon1, Icon2};

		sequence1 = DG.Tweening.DOTween.Sequence();
		sequence2 = DG.Tweening.DOTween.Sequence();
		sequence3 = DG.Tweening.DOTween.Sequence();
		sequenceList = {sequence3, sequence1, sequence2};

		for i = 1, 3 do
			msgList[i].transform.localScale = Vector3.New(1, 0, 1);
			sequenceList[i]:Append(msgList[i].transform:DOScale(Vector3.New(1,1,1), 0.3));      -- 0.3s拉伸效果
			sequenceList[i]:AppendInterval(2);
			sequenceList[i]:Append(msgList[i]:GetComponent("Image"):DOFade(0, 0.5));                    -- 0.5s 渐出效果
			sequenceList[i]:Join(CanvasGroupList[i]:GetComponent("CanvasGroup"):DOFade(0, 0.5));
			sequenceList[i]:Join(IconList[i]:GetComponent("Image"):DOFade(0, 0.5)); 
			sequenceList[i]:SetAutoKill(false);
		end


		--获得钻石特效
		diamondObj = this:GO('Diamond');
		diamondObj:GetComponent("CanvasGroup").alpha = 0;
	end

	function SysLayer.Update()
		if #list ~= 0 then
			local msg_Data = list[1];
			if msg_Data == nil then
				return;
			end
			if lastDataMsg.msg == msg_Data.msg and lastDataMsg.type == msg_Data.type then
				-- 上一个prefab重放
				SysLayer.doInfoMsg(msgList[count%3+1], msg_Data);
			else
				local timeUntilLastMsg = SysLayer.GetTimeOfLastMsgShowUtilNow();
				if timeUntilLastMsg < intervalTime then
					return;
				end
				count = count + 1;
				go = msgList[count%3+1];
				SysLayer.doInfoMsg(go, msg_Data);
			end
			Dequeue(list);
		end
	end

	function SysLayer.ShowMsg(Msg, Type, image, color)
		local msgdata = {};
		msgdata.msg = Msg;
		msgdata.type = Type;
		msgdata.image = image;
		msgdata.color = color;
		-- 将队列中队尾的出队列,并位移
		Enqueue(list, msgdata);
	end

	function SysLayer.ShowItemMsg(Sid, Count, Quality, type)
		local msgdata = {};
		msgdata.msg = Sid;
		msgdata.type = 4;
		msgdata.sid = Sid;
		msgdata.count = Count;
		msgdata.quality = Quality;
		Enqueue(list, msgdata);
	end

	function SysLayer.doInfoMsg(go, msgdata)
		-- 三个消息显示区的动画都相互不影响，是否要三个sequence分别表示三个动画
		SysLayer.Init(go, msgdata);
		if sequenceList[count%3+1] ~= nil then
			sequenceList[count%3+1]:Restart(true);
		end
		if msgdata.image == nil then
			SysLayer.ChangeWidth(go, msgdata);
		end
		SysLayer.lastTime = TimerManager.GetServerNowMillSecond()/1000;

		if lastDataMsg.msg ~= msgdata.msg or lastDataMsg.type ~= msgdata.type then
			SysLayer.MoveUpGo(count);
		end
		lastDataMsg = msgdata;
	end

	function SysLayer.HideMsg()
		for i = 1, 3 do
			msgList[i].gameObject:SetActive(false);
		end
	end
    
	function SysLayer.DoTween(go)
		local hashtable = iTween.Hash("alpha",0,"time", 0.5, "oncomplete", "OnTweenComplete",
			"oncompleteparams",go.gameObject);
		Util.FadeToEx(go.gameObject, hashtable, function () end);
	end

	function SysLayer.ChangeWidth(go, msgdata)
		local Text = TextList[count%3+1].text;
		local str = SysLayer.GetText(Text);
        local length = string.len(str) * 7;
		local rt = rtList[count%3+1]
		if msgdata.type == nil or msgdata.type == const.Message.item then
			rt.sizeDelta = Vector2.New(length + 80, 40);
		else
			rt.sizeDelta = Vector2.New(40 + 28 + 10 + length + 40, 40);
		end
	end

	function SysLayer.GetText(str)
		local text1 = (string.gsub(str, "<color.->", ","));
		local text2 = (string.gsub(text1, "</color.->", ","));
		local temp = Split(text2, ",");
		str = "";
		for i = 1, #temp do
			str = str..temp[i];
		end
		return str;
	end

	function SysLayer.MoveUpGo(Count)
		-- Count的前两个上移
		local rt = nil;
		if Count == 1 then
			return;
		end
		if Count == 2 then
			rt = rt1;
			local position_y = rt.anchoredPosition.y + 45;
        	rt.anchoredPosition = Vector2.New(rt.anchoredPosition.x, position_y);
		end
		if Count > 2 then
			for i = 1, 2 do 
	            rt = rtList[(count-i)%3+1]
		        local position_y = rt.anchoredPosition.y + 45;
        		rt.anchoredPosition = Vector2.New(rt.anchoredPosition.x, position_y);
		    end
		end
	end

	function SysLayer.Init(go, msgdata)
		-- 初始化状态
		if msgdata.image ~= nil then
			go.sprite = msgdata.image;
			go.imageType = 0;
			go:GetComponent("Image"):SetNativeSize();
			TextList[count%3+1].textColor = msgdata.color;
		else
			TextList[count%3+1].textColor = Color.New(228/255, 228/255, 228/255);
			go.imageType = 1;
			go.sprite = "dk_zhongyaoxinxiqu";
		end
		go.imageColor = Color.New(1,1,1,1);
		CanvasGroupList[count%3+1].gameObject:SetActive(true);
		IconList[count%3+1].gameObject:SetActive(false);
		go.gameObject:SetActive(true);
		go.transform.localScale = Vector3.New(1, 0, 1);
		go.transform.localPosition = Vector3.New(0, 200, 0);
		CanvasGroupList[count%3+1]:GetComponent("RectTransform").anchoredPosition = Vector2.New(0, 0);
		-- 当有icon的时候，将文字右移，显得更好看
		if msgdata.type ~= nil and msgdata.type ~= const.Message.item then
			CanvasGroupList[count%3+1]:GetComponent("RectTransform").anchoredPosition = Vector2.New(15, 0);
		end
		-- 初始化数据
		if msgdata.type == nil then
			TextList[count%3+1].text = msgdata.msg;
			IconList[count%3+1].gameObject:SetActive(false);
		end
		if msgdata.type == const.Message.diamond then
			TextList[count%3+1].text = "+"..msgdata.msg;
			IconList[count%3+1].gameObject:SetActive(true);
			IconList[count%3+1].sprite = "tb_zuanshi";
		end
		if msgdata.type == const.Message.money then
			TextList[count%3+1].text = "+"..msgdata.msg;
			IconList[count%3+1].gameObject:SetActive(true);
			IconList[count%3+1].sprite = "tb_jinbi";
		end
		if msgdata.type == const.Message.experience then
			TextList[count%3+1].text = "+"..msgdata.msg;
			IconList[count%3+1].gameObject:SetActive(true);
			IconList[count%3+1].sprite = "tb_exp";
		end
		if msgdata.type == const.Message.item then
			IconList[count%3+1].gameObject:SetActive(false);
			if tb.ItemTable[msgdata.sid] ~= nil then
				if msgdata.count > 1 then
					TextList[count%3+1].text = string.format("<color=%s>[%s]</color>X%s",const.qualityColor[msgdata.quality+1], tb.ItemTable[msgdata.sid].show_name, msgdata.count);
				else
					TextList[count%3+1].text = string.format("<color=%s>[%s]</color>",const.qualityColor[msgdata.quality+1], tb.ItemTable[msgdata.sid].show_name);
				end
				-- IconList[count%3+1].sprite = tb.ItemTable[msgdata.sid].icon;
			elseif tb.EquipTable[msgdata.sid] ~= nil then
				if msgdata.count > 1 then
					TextList[count%3+1].text = string.format("<color=%s>[%s]</color>X%s",const.qualityColor[msgdata.quality+1], tb.EquipTable[msgdata.sid].show_name, msgdata.count);
				else
					TextList[count%3+1].text = string.format("<color=%s>[%s]</color>",const.qualityColor[msgdata.quality+1], tb.EquipTable[msgdata.sid].show_name);
				end
				-- IconList[count%3+1].sprite = tb.EquipTable[msgdata.sid].icon;
			else
				-- 掉落的为宝石
				if msgdata.count > 1 then
					TextList[count%3+1].text = string.format("<color=%s>[%s]</color>X%s",const.qualityColor[msgdata.quality+1], tb.GemTable[msgdata.sid].show_name, msgdata.count);
				else
					TextList[count%3+1].text = string.format("<color=%s>[%s]</color>",const.qualityColor[msgdata.quality+1], tb.GemTable[msgdata.sid].show_name);
				end
				IconList[count%3+1].gameObject:SetActive(true);
				IconList[count%3+1].sprite = tb.GemTable[msgdata.sid].icon;
				CanvasGroupList[count%3+1]:GetComponent("RectTransform").anchoredPosition = Vector2.New(15, 0);
			end
		end
	end

	function SysLayer.GetTimeOfLastMsgShowUtilNow()
		if SysLayer.lastTime == nil then
			ui.InitSysLastTime();
		end
		return TimerManager.GetServerNowMillSecond()/1000 - SysLayer.lastTime;
	end

	function SysLayer.ShowDiamond(value)
		local canvasGroup = diamondObj:GetComponent("CanvasGroup");
		canvasGroup.alpha = 1;

		--特效
		if diamondEffect == nil then
			diamondEffect = this:LoadUIEffect(this.gameObject, "zhuanshihuode", true, true);
			diamondEffect.transform:SetParent(diamondObj.transform)
			diamondEffect.transform.localScale = Vector3.one;
			diamondEffect.transform.localPosition = Vector3.zero;
		end

		--参数
		local param = diamondParam;
		if param.playNumber == true then
			param.totalValue = param.totalValue + value;
		else
			--local num = math.max(string.len(value) - 1, 0);
			param.curValue = 1; --10 ^ num;
			param.totalValue = value;
			diamondObj:GO("Text").text = "+1";
		end
		param.playNumber = true;
		if param.tweener ~= nil then
			Util.DotweenKill(param.tweener);
		end

		param.tweener =  Util.DotweenTo(param.curValue, param.totalValue, 1.5, function (x)
			param.curValue = x;
			diamondObj:GO("Text").text = "+"..math.floor(x);
		end, function ()
			param.tweener = Util.DotweenFade(diamondObj.gameObject, 0, 1, function ()
					if diamondEffect ~= nil then
						GameObject.Destroy(diamondEffect);
						diamondEffect = nil;
					end
				end);
			param.playNumber = false;
		end);
	end
    ------------------------ui.showMsg等接口--------------------------------------

    ui.InitSysLastTime = function()
		SysLayer.lastTime = TimerManager.GetServerNowMillSecond()/1000;
	end	

    ui.HideMsg = function()
    	SysLayer.HideMsg();
	end

	ui.showMsg = function(msg, image, color)
        SysLayer.ShowMsg(msg, nil, image, color);
    end

    ui.showDiamondMsg = function(msg)
    	--SysLayer.ShowMsg(msg, const.Message.diamond, nil, nil);
    	SysLayer.ShowDiamond(msg)
	end

	ui.showMoneyMsg = function(msg)
    	SysLayer.ShowMsg(msg, const.Message.money, nil, nil);
	end

	ui.showExpMsg = function(msg)
    	SysLayer.ShowMsg(msg, const.Message.experience, nil, nil);
	end

    ui.showItemMsg = function(sid, count, quality)
		SysLayer.ShowItemMsg(sid, count, quality, const.Message.item);
	end

	return SysLayer;
end

ui.ShowSysLayer = function()
    PanelManager:CreateConstPanel('SysLayer', UIExtendType.NONE, {});
end