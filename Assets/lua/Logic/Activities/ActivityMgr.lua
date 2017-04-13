--每个活动模块初始化的时候自己插入
ActivityMap = {} 

function CreateActivityMgr()
	local ActivityMgr = {};
	local curActivityName = "";
	--在每次切换场景时调用
	ActivityMgr.HandleChangeMap = function()
		--从某个活动场景中退出
		if curActivityName ~= "" then
			ActivityMgr.ExitActivity(curActivityName);
		end 
		--新进入的是活动场景
		if DataCache.mapType == "active_map" then
			ActivityMgr.EnterActivity(DataCache.activityName);
			curActivityName = DataCache.activityName;
		else
			--进入普通场景将当前所在活动清零
			curActivityName = "";
		end
	end

	--处理活动地图进入和退出的相关操作
	ActivityMgr.EnterActivity = function(activityName)
		local Module = ActivityMap[activityName];
		if Module and Module.EnterActivity ~= nil then
			Module.EnterActivity();
		end
	end

	ActivityMgr.ExitActivity = function(activityName)
		local Module = ActivityMap[activityName];
		if Module and Module.ExitActivity ~= nil then
			Module.ExitActivity();
		end
	end

	ActivityMgr.GetActivityList = function()
		local msg = { cmd = "get_all_active"};
        Send(msg,function(msgTable)
        	local replyList = msgTable["reply_list"];
        	for i=1,#replyList do
         		local Module = ActivityMap[replyList[i].name];
         		if Module ~= nil then
         			Module.ActivityStart();
         		end
        	end
        end);
	end	

	return ActivityMgr;
end

client.activityMgr = CreateActivityMgr();