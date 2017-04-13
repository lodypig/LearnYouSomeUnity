function CreateFuBenAutoTeamCtrl()
	local FuBenAutoTeam = {}

	FuBenAutoTeam.AddFuBen = nil;
	FuBenAutoTeam.DeleteFuBen = nil;
	FuBenAutoTeam.FubenArray = {};

	FuBenAutoTeam.StateEnum = 
	{
		"Waiting",
		"Pause",
		"Max"
	};

	FuBenAutoTeam.StateEnum = commonEnum.CreatEnumTable(FuBenAutoTeam.StateEnum,0);

	function FuBenAutoTeam.HaveFuBen(sid)
		return FuBenAutoTeam.GetFuBenIndex(sid) ~= -1;
	end

	function FuBenAutoTeam.GetFuBenIndex(sid)
		for i = 1,#FuBenAutoTeam.FubenArray do
			if sid == FuBenAutoTeam.FubenArray[i].sid then
				return i
			end
		end
		return -1;
	end

	function FuBenAutoTeam.GetFuBen(sid)
		for i = 1,#FuBenAutoTeam.FubenArray do
			if sid == FuBenAutoTeam.FubenArray[i].sid then
				return FuBenAutoTeam.FubenArray[i]
			end
		end
		return nil;
	end

	function FuBenAutoTeam.Add(fuben)
		if FuBenAutoTeam.AddFuBen ~= nil then
			FuBenAutoTeam.AddFuBen(fuben)
		end
	end

	function FuBenAutoTeam.Delete(sid)
		if FuBenAutoTeam.DeleteFuBen ~= nil then
			FuBenAutoTeam.DeleteFuBen(sid)
		end
	end


	function FuBenAutoTeam.Enqueue(sid)
		local atom = {}
		atom.sid = sid;
		atom.state = FuBenAutoTeam.StateEnum.Waiting;
		atom.startTime = TimerManager.GetServerNowMillSecond()/1000;
		atom.parpareTime = TimerManager.GetServerNowMillSecond()/1000;
		if FuBenAutoTeam.HaveFuBen(sid) then
			FuBenAutoTeam.Dequeue(sid)
		end
		if client.fuben.start_prepare_flag then
			FuBenAutoTeam.SetState(atom,FuBenAutoTeam.StateEnum.Pause)
		else
			FuBenAutoTeam.SetState(atom,FuBenAutoTeam.StateEnum.Waiting)
		end
		
		FuBenAutoTeam.FubenArray[#FuBenAutoTeam.FubenArray+1] = atom;
		FuBenAutoTeam.Add(atom)
		MainUI.FuBenPiPeiShow(true)
		MainUI.PlayPiPeiEffect(true)
	end

	function FuBenAutoTeam.Dequeue(sid)
		if FuBenAutoTeam.HaveFuBen(sid) then	
			local fuben = FuBenAutoTeam.GetFuBen(sid)
			FuBenAutoTeam.SetState(fuben,FuBenAutoTeam.StateEnum.Pause)		
			FuBenAutoTeam.Delete(sid)
			table.remove(FuBenAutoTeam.FubenArray,FuBenAutoTeam.GetFuBenIndex(sid));
			if #FuBenAutoTeam.FubenArray == 0 then
				UIManager.GetInstance():CallLuaMethod('UIFubenAutoTeam.OnClose');
				MainUI.FuBenPiPeiShow(false)
				MainUI.PlayPiPeiEffect(false)
			end
		end
	end

	function FuBenAutoTeam.SetState(fuben,state)
		if state == FuBenAutoTeam.StateEnum.Waiting then
			fuben.startTime = TimerManager.GetServerNowMillSecond()/1000;
			fuben.parpareTime = TimerManager.GetServerNowMillSecond()/1000;
		end
		fuben.state = state
		client.fuben.matchFuben[fuben.sid] = state == FuBenAutoTeam.StateEnum.Waiting;
		UIManager.GetInstance():CallLuaMethod('UIFuben.RefreshUI');
	end

	function FuBenAutoTeam.PauseAll()
		for i = 1,#FuBenAutoTeam.FubenArray do
			FuBenAutoTeam.SetState(FuBenAutoTeam.FubenArray[i],FuBenAutoTeam.StateEnum.Pause)
		end
	end

	local time_to_robot_match = 30		--4*60

	function FuBenAutoTeam.check_4min_robot_match()
		if FuBenAutoTeam == nil then
			return
		end
		--检查超过4分钟的组队请求
		--自动请求机器人组队
		local nowTime = TimerManager.GetServerNowMillSecond()/1000
		for i=1,#FuBenAutoTeam.FubenArray do
			local atom = FuBenAutoTeam.FubenArray[i]
			if nowTime - atom.parpareTime >= time_to_robot_match 
				and atom.state == FuBenAutoTeam.StateEnum.Waiting then
				--有队伍 但不是队长 也不用发
				if client.team.haveTeam() and not client.team.isLeader(DataCache.roleID) then
					return
				end
				client.fuben.fuben_robot_match(atom.sid)
				 atom.parpareTime = nowTime
			end
		end
	end

	EventManager.register(Event.ON_TIME_SECOND_CHANGE, FuBenAutoTeam.check_4min_robot_match);

	return FuBenAutoTeam;
end

client.FuBenAutoTeam = CreateFuBenAutoTeamCtrl();