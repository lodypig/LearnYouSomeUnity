--这个文件用来统计各个活动模块的完成情况，方便穿透显示
activity = {};

-----------------悬赏任务相关---------------------
--已有UIRewardtaskCtrl中定义的client.RewardTask相关接口,拉取接口加入到requestFunc中
activity.GetRewardTasks = function()
	client.RewardTask.GetRewardTasks();
end


activity.HaveRewardTaskFree = function()
	local count = client.RewardTask.GetHaveCompletedNum();	
	local activityTable = tb.DailyActTable;
	local totalTimes = activityTable[const.ActivityId.xuanShang].times;
	if totalTimes - count > 0 then
		return true;
	else
		return false;
	end
end

-----------------魔龙岛相关---------------------
--已有UIMolongTaskCtrl中定义的client.MolongTask相关接口,拉取接口加入到requestFunc中
activity.GetMolongTasks = function()
	client.MolongTask.GetMolongTasks(nil);
end

activity.HaveMolongTaskFree = function()
	local count = client.MolongTask.GetHaveCompletedNum();	
	local activityTable = tb.DailyActTable;
	local totalTimes = activityTable[const.ActivityId.moLongDao].times;
	if totalTimes - count > 0 then
		if DataCache.myInfo.level < 45 and totalTimes - count == 1 then
			return false;
		else
			return true;
		end
	else
		return false;
	end
end
-----------------世界boss相关---------------------
--世界boss存活情况表
activity.BossStateList = {};
activity.BossIndexStateList = {};
activity.RequestBossState = function(cb)
	Send({cmd = "get_boss"}, function(reply)
		activity.BossStateList = reply["npclist"];
		for i = 1, #activity.BossStateList do
			activity.BossIndexStateList[const.bossIdToIndex[activity.BossStateList[i][1]]] = activity.BossStateList[i];
		end

		if cb ~= nil then
			cb(activity.BossIndexStateList);
		end
		activity.AddReturnNumber();
	end);
end

activity.HaveBossAlive = function()
	if #activity.BossStateList == 0 then
		return false
	end
	for i = 1,#activity.BossStateList do
		if activity.BossStateList[i][2] > 0 then
			return true;
		end
	end
	return false;
end

-----------------藏宝图相关---------------------
activity.GetCBTTask = function()
	client.CBTCtrl.get_cbt_info()
end

activity.HaveCBTFree = function()
	local count = client.CBTCtrl.get_cbt_count();--完成数量	
	local activityTable = tb.DailyActTable;
	local totalTimes = activityTable[const.ActivityId.cangBaoTu].times;
	if totalTimes - count > 0 then
		return true;
	else
		return false;
	end
end

----------------------------------------------------

local requestFunc = {
	activity.GetRewardTasks,
	activity.GetMolongTasks,
	activity.RequestBossState,
	activity.GetCBTTask,
}
--Boss不算在所有统计里
local checkRedFunc = {
	activity.HaveRewardTaskFree,
	activity.HaveMolongTaskFree,
	--activity.HaveBossAlive,
	activity.HaveCBTFree,
}

local checkLevel = {
	30,--activity.HaveRewardTaskFree,
	40,--activity.HaveMolongTaskFree,
	-- activity.HaveBossAlive,
	35,--activity.HaveCBTFree,
}

--获取所有活动的数据
activity.RequestAllActivities = function()
	for i=1,#requestFunc do
		if requestFunc[i] ~= nil then
			requestFunc[i]();
		end
	end
end

local returnNumber = 0;
activity.AddReturnNumber = function()
	if returnNumber < #requestFunc then
		returnNumber = returnNumber + 1;
	end
	if returnNumber == #requestFunc then
		EventManager.onEvent(Event.ON_EVENT_RED_POINT);
	end
end
activity.HaveAllReturn = function()
	return returnNumber == #requestFunc;
end

--判断是否有任意活动模块需要加红点，给主界面和菜单界面调用
activity.IsAnyActivityRed = function()
	for i=1,#checkRedFunc do
		if checkRedFunc[i] ~= nil and DataCache.myInfo.level >= checkLevel[i] then
			if checkRedFunc[i]() == true then
				return true;
			else
			end
		end
	end	

	return false;
end
