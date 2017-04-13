function  CreateNewSystemOpenCtrl()
	local NewSystemOpen = {};
	NewSystemOpen.SystemList = {};
	function NewSystemOpen.handleServerMsg(Msg)
		local allSystemList = Msg.args;
		if next(allSystemList) == nil then
			NewSystemOpen.SystemList = {};
		else
			for i = 1,#allSystemList do
				NewSystemOpen.SystemList[i] = {};
				NewSystemOpen.SystemList[i].systemName = allSystemList[i][1];
				NewSystemOpen.SystemList[i].operateFlag = allSystemList[i][2];
			end
			EventManager.onEvent(Event.ON_NEW_SYSTEM_OPEN_FLAG_CHANGE); -- 通知其他所有的新系统标识页面，更新页面新标识显示 
			EventManager.onEvent(Event.ON_EVENT_RED_POINT); -- 主界面
		end
	end
	SetPort("new_system_open",NewSystemOpen.handleServerMsg);

	function NewSystemOpen.onGuideComplete(systemName)
		local msg = {cmd = "complete_system_guide", system_name = systemName};
        Send(msg);
	end

	function NewSystemOpen.getAllNewSystemInfo()
		local msg = {cmd = "get_all_system_info"};
        Send(msg);
	end
	
	function NewSystemOpen.isSystemOpen(systemName)
		for i=1,#NewSystemOpen.SystemList do
			if NewSystemOpen.SystemList[i].systemName == systemName and NewSystemOpen.SystemList[i].operateFlag == 0 then
				return true;
			end
		end
		return false;
	end

	return NewSystemOpen;
end

client.newSystemOpen = CreateNewSystemOpenCtrl()
