function ActivityCtrl()
	local Activity = {};
	-- 主界面消息区提示
	Activity.mainTip = true;
	-- Activity.haveActFind = false;
	Activity.recordResourceState = true;
	Activity.nowServerDay = nil;
	Activity.dailyActList = nil;
	Activity.limitedActList = nil;
	Activity.findBackActList = nil;
	Activity.TimesList = nil;
	Activity.activeValue = nil;
	Activity.activelist = nil;
	Activity.five_clock_level = nil;
	Activity.showlist = nil;
	Activity.nowServerDay = nil;
	Activity.RedPoint = {
		[100001] = activity.HaveRewardTaskFree,
		[100002] = activity.HaveCBTFree,
		[100004] = activity.HaveMolongTaskFree,
	};
	Activity.resource_Info_times = {};
	Activity.resource_Info_doneFind = {};

	function Activity.CheckRed(id)
		local flag = false;
		if id ~= 100009 then
			if DataCache.myInfo.level >= tb.DailyActTable[id].level then
				if client.activity.RedPoint[id] then
					if client.activity.RedPoint[id]() then
						flag = true;
						return flag;
					end
				end
			end
		end
		return flag;
	end 

	function Activity.CheckBossRed(list)
		local minLevel = 1000;
		for i = 1, #list do
			if list[i][2] > 0 then
				if minLevel > const.BossLevel[list[i][1]] then
					minLevel = const.BossLevel[list[i][1]];
				end
			end
		end
		return DataCache.myInfo.level + 5 >= minLevel;
	end

	function Activity.CheckPageRed1() 
		local flag = false;
		local idList = {100001,100002,100004};
		for i = 1, #idList do
			if client.activity.CheckRed(idList[i]) then
				flag = true;
				return flag;
			end
		end
		return flag;
	end

	local daily_sortfunction = function(data1, data2) 
		if data1.done ~= data2.done then
			return data1.done < data2.done;
		else
			if data1.done == const.ActShowStart.showButNotStart then
				if data1.level ~= data2.level then
					return data1.level < data2.level;
				else
					return data1.priority < data2.priority;
				end
			else
				return data1.priority < data2.priority;
			end
		end
	end

	local limited_sortfunction = function(data1, data2)
		if data1.done ~= data2.done then
			return data1.done < data2.done;
		else
			if data1.done ~= const.ActShowStart.showButNotStart then
				return data1.priority < data2.priority;
			else
				return data1.level < data2.level;
			end
		end
	end

	local findback_sortfunction = function(data1, data2)
		if data1.IsFindDone ~= data2.IsFindDone then
			return data1.IsFindDone < data2.IsFindDone;
		else
			if data1.type ~= data2.type then 
				return data1.type < data2.type;
			else
				return data1.priority < data2.priority;
			end
		end
	end

	--刷新活跃值的显示
	function Activity.handleActiveValueChange(msg)
		if msg ~= nil then
			Activity.activeValue = msg["active_value"];
			EventManager.onEvent(Event.ON_ACTIVE_VALUE_CHANGE);
		end
	end

	function Activity.RequestXuanShang(cb)
		client.RewardTask.GetRewardTasks(cb);
	end

	function Activity.handleFindBackChange(msg)
		if msg ~= nil then
			Activity.GetResourceInfo(function (reply)
				local list = reply["list"];
				client.activity.HandleFindData(list);
				EventManager.onEvent(Event.ON_FINDBACKTIMES_CHANGE);
			end)
		end
	end

	function Activity.handleFirstLoginLevel(msg)
		local level = msg["level"];
		if level ~= nil then
			client.activity.five_clock_level = level;
		end
		if Activity.nowServerDay == nil then
			Activity.nowServerDay = getServerDayIndex(5, 0, 0);
		end
	end

	function Activity.Daily_addExtraFlag(showlist)
		local timeslist = client.activity.TimesList;
		local list = Activity.AddShowStartFlag(showlist);
		for k, v in pairs(list) do
			--k 在{次数购买,设置的id}
			if k == const.ActivityId.outLine then
				list[k].done = const.ActShowStart.cando;
			end
			-- 已显示未开启的活动
			if v.show_start == 2 then
				list[k].done = const.ActShowStart.showButNotStart;
			else
				-- 已开启的活动
				if v.times then
					if v.times > timeslist[k] then
					--可以前往的活动 
						list[k].done = const.ActShowStart.cando;
					else
						-- 已完成活动
						list[k].done = const.ActShowStart.done;
					end
				else
					--没有次数的活动
					list[k].done = const.ActShowStart.cando;
				end
			end
		end
		return list;
	end

	function Activity.Limited_addExtraFlag(showlist)
		local list = showlist;
		for k, v in pairs(list) do
			if k == const.ActivityId.SceneBoss then
				list[k].done = const.ActShowStart.cando;				
			end
		end
		return list;
	end
	--增加显示开启标志，已显示未开启为2，已开启为1
	function Activity.AddShowStartFlag(showlist)
		local list = showlist;
		for k, v in pairs(list) do
			-- 已显示，未开启的活动
			if v.condition then
				if DataCache.myInfo.level >= v.condition and DataCache.myInfo.level < v.level then
					list[k].show_start = 2;
				else
					-- 已开启的活动
					list[k].show_start = 1;
				end
			else
				list[k].show_start = 1;
			end
		end
		return list;
	end	

	-- 活动获取次数
	function Activity.GetTimesList()
		local showlist = tb.DailyActTable;
		Activity.TimesList = {};
		for k ,v in pairs(showlist) do
			Activity.TimesList[k] = 0;
			if k == const.ActivityId.xuanShang then
				Activity.TimesList[k] = Activity.getXuanshangTimes();
			end
			if k == const.ActivityId.cangBaoTu then
				Activity.TimesList[k] = Activity.getCangbaotuTimes();
			end
			if k == const.ActivityId.moLongDao then
				Activity.TimesList[k] = Activity.getMolongdaoTimes();
			end
			if k == const.ActivityId.shiLianMiJing then
				Activity.TimesList[k] = client.fuben.getChallengeNum();
			end
			if k == const.ActivityId.Legion then
				-- 得到工会宴会次数
				Activity.TimesList[k] = 0;
			end
		end
	end

	-- 资源找回


	--封装日常活动所需要数据
	function Activity.getDailyAct()
		local showlist = {};
		local sortlist = {};
		local list = nil;
		for k, v in pairs(tb.DailyActTable) do
			showlist[k] = v;
		end
		for k, v in pairs(showlist) do
			if v.condition then
				if DataCache.myInfo.level < v.condition then
					showlist[k] = nil;
				end
			end
		end
		sortlist = Activity.Daily_addExtraFlag(showlist);
		list = Activity.dailyActShowList(sortlist);
		Activity.dailyActList = {};
		Activity.dailyActList = list;
		return list;
	end

	--封装限时活动所需的数据
	function Activity.getLimitedAct()
		local showlist = {};
		local sortlist = {};
		local list = nil;
		for k, v in pairs(tb.LimitedActTable) do
			showlist[k] = v;
		end
		for k, v in pairs(showlist) do
			if v.condition then
				if DataCache.myInfo.level < v.condition then
					showlist[k] = nil;
				end
			end
		end
		sortlist = Activity.Limited_addExtraFlag(showlist);
		list = Activity.limitedActShowList(sortlist);
		Activity.limitedActList = {};
		Activity.limitedActList = list;
		return list;
	end

	--封装资源找回所需的数据
	function Activity.getBackAct()
		local list = tb.FindBackTab;
		local showlist = {};
		for k,v in pairs(list) do
			if client.activity.five_clock_level < v.level then
				list[k] = nil;
			end
		end
		if next(Activity.resource_Info_times) == nil then
			showlist = {};
		else
			for k, v in pairs(list) do
				if v.times then
					list[k].canFind = v.times - Activity.resource_Info_times[const.SidToIndex[k]];
				else
					list[k].canFind = 1 - Activity.resource_Info_times[const.SidToIndex[k]];
				end
				if list[k].canFind == 0 then
					--可召回次数为0，不显示
					list[k] = nil;
				else
					if list[k].canFind > Activity.resource_Info_doneFind[const.SidToIndex[k]] then
						-- 未找回完
						list[k].IsFindDone = 0;
					else
						--已完全找回
						list[k].IsFindDone = 1;
					end
				end
			end
			showlist = Activity.findBackActShowList(list);
			Activity.findBackActList = showlist;
		end
		return showlist;
	end

	function Activity.getCangbaotuTimes()
		return client.CBTCtrl.get_cbt_count();
	end

	function Activity.getXuanshangTimes()
		return client.RewardTask.GetHaveCompletedNum();
	end

	function Activity.getMolongdaoTimes()
		return client.MolongTask.GetHaveCompletedNum();
	end

	-- 日常活动数据排序
	function Activity.dailyActShowList(showlist)
		return Activity.ActShowList(showlist, daily_sortfunction);
	end

	-- 限时活动数据排序
	function Activity.limitedActShowList(showlist)
		return Activity.ActShowList(showlist, limited_sortfunction);
	end

	-- 资源找回数据排序
	function Activity.findBackActShowList(showlist)
		return Activity.ActShowList(showlist, findback_sortfunction);
	end

	function Activity.ActShowList(showlist, sortFunc)
		local list = {};
		for k,v in pairs(showlist) do
			list[#list+1] = v;
		end
		table.sort(list, sortFunc);
		return list;
	end

	-- 活跃值的读取
	function Activity.getActiveValue(cb)
		local msg = {cmd = "get_active_value"};
		Send(msg, cb);
	end

	function Activity.GetActiveReward(k, cb)
		local msg = {cmd = "get_active_reward", data = k};
		Send(msg, cb);
	end
	--离线挂机时间的请求
	function Activity.RequestOutLineGuaJiTime(cb)
		local msg = {cmd = "get_outline_guaji_time"};
		Send(msg, cb)
	end	

	-- 请求服务端得到昨天的做活动状态
	function Activity.GetResourceInfo(cb)
		local msg = {cmd = "get_resource_info"};
		Send(msg, cb)
		-- body
	end

	function Activity.HandleFindData(list)
		-- 该活动已完成的次数，剩余的即为可找回的
		local flag = false;
		Activity.resource_Info_times = {};
		-- 该活动已经找回的次数
		Activity.resource_Info_doneFind = {};
		if next(list) == nil then
			Activity.resource_Info_times = {};
		else
			for i = 1, #list do
				if tb.FindBackTab[const.IndexToSid[i]] then
					if client.activity.five_clock_level >= tb.FindBackTab[const.IndexToSid[i]].level then
						Activity.resource_Info_times[i] = list[i][2]; -- 该活动做的次数
						Activity.resource_Info_doneFind[i] = list[i][3]; -- 该活动找回的次数
						if tb.FindBackTab[const.IndexToSid[i]].times - (list[i][3] + list[i][2]) > 0 then
							flag = true;
						end
					end
				end
			end
		end
		return flag;
	end

	-- 获取玩家当天首次登陆等级等级
	function Activity.RequestLevel(cb)
		local msg = {cmd = "get_first_login_level"};
		Send(msg, function(reply)
			local success = reply["success"];
			if success == 1 then
				local level = reply["level"];
				if level ~= nil then
					Activity.five_clock_level = level;
				end
				if cb ~= nil then
					cb();
				end
			end
		end);
	end

	-- diamond为1即为钻石找回，为0即为金币找回
	function Activity.ResourceFindBack(id, n, diamond, lev)
		local msg = {cmd = "get_find_back_reward", sid = id, times = n, type = diamond, level = lev};
		Send(msg, function(reply)
			local money = tonumber(reply["money"]);
			local exp = tonumber(reply["exp"]);
			
		end);
	end

	function Activity.getActiveValueRed()
		local flag = false;
		if client.activity.activelist == nil then
			return flag
		end
		for i = 1, #client.activity.activelist do 
			if client.activity.activelist[i][2] == 0 and client.activity.activeValue >= client.activity.activelist[i][1] then
				flag = true;
				return flag;
			end
		end
		return flag;
	end

	function Activity.handeleLoginActive(reply)
		local value = reply["value"];
		local list = reply["list"];
		Activity.activeValue = value;
		Activity.activelist = list;
	end
	return Activity;
end

client.activity = ActivityCtrl();
----------------------------------Port-------------------------------
SetPort("active_base_info", client.activity.handeleLoginActive);
SetPort("active_value_changed", client.activity.handleActiveValueChange);
SetPort("findback_changed", client.activity.handleFindBackChange);
SetPort("first_login_level" , client.activity.handleFirstLoginLevel);