function CreateFubenZhunBeiCtrl()
	local FubenZhunBei = {};
		
	FubenZhunBei.OkList = {};
	FubenZhunBei.UpdatePanel = nil;
	FubenZhunBei.StartTime = 0;
	FubenZhunBei.LimitTime = 60;
	
	function FubenZhunBei.Haverole(roleid)
		return FubenZhunBei.GetRoleidIndex(roleid) ~= -1
	end

	function FubenZhunBei.GetRoleidIndex(roleid)
		for i = 1,#FubenZhunBei.OkList do
			if roleid == FubenZhunBei.OkList[i] then
				return i
			end
		end
		return -1;
	end

	function FubenZhunBei.Enqueue(roleid)
		--有可能是机器人
		if roleid ~= "robot" and FubenZhunBei.Haverole(roleid) then
			return
		end
		FubenZhunBei.OkList[#FubenZhunBei.OkList+1] = roleid	
		FubenZhunBei.UpdateZhunBeiPanel()
	end

	function FubenZhunBei.UpdateZhunBeiPanel()
		if FubenZhunBei.UpdatePanel == nil then
			return;
		end
		FubenZhunBei.UpdatePanel(FubenZhunBei.OkList)
	end

	function FubenZhunBei.StartPrepare()
		FubenZhunBei.StartTime = TimerManager.GetServerNowMillSecond()/1000
		FubenZhunBei.OkList = {};
		client.FuBenAutoTeam.PauseAll()
	end

	return FubenZhunBei;
end
client.FubenZhunBei = CreateFubenZhunBeiCtrl();