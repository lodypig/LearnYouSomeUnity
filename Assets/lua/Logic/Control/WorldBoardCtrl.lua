function  CreateWorldBoardCtrl()
	local WorldBoard = {};

	WorldBoard.list = {};

	WorldBoard.OnEqueueEvent = nil;

	local NormalColor = "#D8FA3CFF";  --一般文字颜色
	local KeywordColor = "#479FE7FF"; --关键字颜色


	WorldBoard.AddListener = function (listener)
		WorldBoard.OnEqueueEvent = listener;
		WorldBoard.OnEqueueEvent();
	end

	function WorldBoard.IsListEmpty()
		return #WorldBoard.list == 0;
	end
	
	function WorldBoard.Enqueue(msg)
		local format_type = msg["format_type"]
		local content = msg["content"]
		local info = client.MsgFormatCtrl.GetString(format_type, content)
		content[#content+1] = 0
		local info2 = client.MsgFormatCtrl.GetString(format_type, content)
		if info == nil or info2 == nil then
			return
		end

		--公告面板
		if UIManager.GetInstance():FindUI('UIWorldBoard') == nil then
			PanelManager:CreateConstPanel('UIWorldBoard',UIExtendType.NONE,nil);
		end
		WorldBoard.list[#WorldBoard.list + 1] = info2;

		if  WorldBoard.OnEqueueEvent ~= nil then  
			WorldBoard.OnEqueueEvent()
		end
	end

	function WorldBoard.Dequeue()
		if WorldBoard.IsListEmpty() then
			return nil;
		end
		local info = WorldBoard.list[1];
		table.remove(WorldBoard.list,1);
		return info;
	end

	function  WorldBoard.Clear()
		WorldBoard.list = {};
		WorldBoard.OnEqueueEvent = nil;
	end

	function WorldBoard.ShowWorldMsg(info)
		if UIManager.GetInstance():FindUI('UIWorldBoard') == nil then
			PanelManager:CreateConstPanel('UIWorldBoard',UIExtendType.NONE,nil);
		end
		WorldBoard.list[#WorldBoard.list + 1] = info;

		if  WorldBoard.OnEqueueEvent ~= nil then  
			WorldBoard.OnEqueueEvent()
		end	
	end

	function WorldBoard.Test()
		local str = "[color:71,159,231,不朽君王][color:160,22,19,已出现在][炽炎山谷,180,166][color:160,22,19,，各位勇士可前往击杀！]"
		WorldBoard.ShowWorldMsg(str)
		client.chat.clientSystemMsg(str)
		client.SystemBoard.ShowSysMsg(str)
	end
	
	SetPort("worldboard",WorldBoard.Enqueue);

	return WorldBoard;
end

client.WorldBoard = CreateWorldBoardCtrl()