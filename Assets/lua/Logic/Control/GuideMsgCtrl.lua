function  CreateGuideMsgCtrl()
	
	local GuideMsg = {};
	GuideMsg.listener = nil;
	local msgQue = {};

	GuideMsg.AddListener = function (listener)
		GuideMsg.listener = listener;
		GuideMsg.listener();
	end

	function GuideMsg.deque()
		if #msgQue == 0 then
			return nil;
		end
		local msg = msgQue[1];
		for i = 2, #msgQue do
			msgQue[i - 1] = msgQue[i];
		end
		msgQue[#msgQue] = nil;
		return msg;
	end

	function GuideMsg.enque(msg)
		msgQue[#msgQue + 1] = msg;
	end

	function GuideMsg.ShowMsg(msg)
		if UIManager.GetInstance():FindUI('UIGuideMsg') == nil then
			PanelManager:CreateConstPanel('UIGuideMsg', UIExtendType.NONE, nil);
		end
		local isShow = false;
		if #msgQue == 0 then
			isShow = true;
		end
		GuideMsg.enque(msg);
		if isShow then
			GuideMsg.DoShow();
		end
	end

	function GuideMsg.DoShow()
		if #msgQue == 0 then
			return;
		end
		local listener = GuideMsg.listener;
		if listener == nil then
			return;
		end
		listener();
	end


	function GuideMsg.TestShowMsg()
		client.GuideMsg.ShowMsg("复活的亡灵要聚在一起向安琳献祭，利用群攻消灭他们！1");
		client.GuideMsg.ShowMsg("复活的亡灵要聚在一起向安琳献祭，利用群攻消灭他们！2");
		client.GuideMsg.ShowMsg("复活的亡灵要聚在一起向安琳献祭，利用群攻消灭他们！3");
		
	end

	return GuideMsg;
end

client.GuideMsg = CreateGuideMsgCtrl()