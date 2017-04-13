function CreateSystemBoardCtrl()
	local SystemBoard = {};
	SystemBoard.list = {};
	SystemBoard.OnEqueueEvent = nil;
	local NormalColor = "#A01613FF";  --一般文字颜色
	local KeywordColor = "#479FE7FF"; --关键字颜色


	SystemBoard.AddListener = function (listener)
		SystemBoard.OnEqueueEvent = listener;
		SystemBoard.OnEqueueEvent();
	end

	function SystemBoard.IsListEmpty()
		return #SystemBoard.list == 0;
	end

	function SystemBoard.Enqueue(msg)

		local info = client.tools.ensureString(msg["content"])
		if info == nil then
			return;
		end

		if UIManager.GetInstance():FindUI('UISystemBoard') == nil then
			PanelManager:CreateConstPanel('UISystemBoard',UIExtendType.NONE,nil);
		end

		SystemBoard.list[#SystemBoard.list + 1] = info;

		if  SystemBoard.OnEqueueEvent ~= nil then  
			SystemBoard.OnEqueueEvent()
		end		
	end

	function SystemBoard.Dequeue()
		if #SystemBoard.list <= 0 then
			return nil;
		end
		local info = SystemBoard.list[1];
		table.remove(SystemBoard.list,1);
		return info;
	end

	function  SystemBoard.Clear()
		SystemBoard.list = {};
		SystemBoard.OnEqueueEvent = nil;
	end

	function SystemBoard.ShowSysMsg(info)
		if UIManager.GetInstance():FindUI('UISystemBoard') == nil then
			PanelManager:CreateConstPanel('UISystemBoard',UIExtendType.NONE,nil);
		end
		SystemBoard.list[#SystemBoard.list + 1] = info;
		if  SystemBoard.OnEqueueEvent ~= nil then  
			SystemBoard.OnEqueueEvent()
		end	
	end

	SetPort("systemboard",SystemBoard.Enqueue);

	return SystemBoard;
end
client.SystemBoard = CreateSystemBoardCtrl();