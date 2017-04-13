--author:wugj 2016/6/16
--success_data的内容: 1-进度数量(1,2,3,4) 2-完成与否(true or false) 
TaskCompleteType = {
	[1] = 1, --击杀npc
	[2] = 1, --击杀npc收集物品
	[3] = 1, --击杀满足条件npc
	[4] = 1, --击杀满足条件npc收集物品
	[5] = 2, --对话npc
	[6] = 1, --采集有物品
	[7] = 1, --采集无物品	
	[8] = 2, --探索区域
	[9] = 2, --传递物品得到
	[10] = 2, --传递物品失去
	[11] = 1, --使用物品
	[12] = 2, --到达等级
	[13] = 2, --护送车辆
    [14] = 2, --完成挖宝
    [15] = 2, --引导任务
    [16] = 2, --操作任务
}


TaskAutoGoType = {};
TaskAutoGoType.KillNpc = 1;
TaskAutoGoType.Dialog = 2;
TaskAutoGoType.Collect = 3;
TaskAutoGoType.SearchArea = 4;
TaskAutoGoType.Item = 5;
TaskAutoGoType.Level = 6;



isFirstHolyShow = false;
--任务管理器
function CreateTaskManager()
	local taskMgr = {};
	-- 任务清单
	local taskList = {};

	local Sid2IndexMap = {};
	local overList = {};
	local Sid2IndexOverMap = {};

	local npcID2TaskID = {};
	local npcID2OverTaskID = {};
	local npcID2ResTaskID = {};
	local inDistance = 4;

	local updateTask = nil;
	local addTask = nil;
	local completeTask = nil;
	local deleteTask = nil;

	local removeTaskList;
	local resHelpTable = {};

	taskMgr.IsResAutoGo = false;
	taskMgr.ResAutoGoSid = 0;
	--已经完成并对话过的任务
	--在任务相应提交对话结束后加入，用来显示任务完成和领取奖励的光效
	taskMgr.TalkOverTable ={};	
	--刚刚更新过进度的任务
	taskMgr.TaskUpdatetable = {};
	taskMgr.HavePlayedTable = {};

	taskMgr.CurTraceTaskSid = 0;
	taskMgr.mainTaskSid = 0; 

	--需要隐藏的npc
	
	taskMgr.getWholeTaskList = function() 
		return taskList;
	end

	-- 
	removeTaskList = function (list, index, indexMap)
		local listCount = #list;
		indexMap[list[index].sid] = nil;
		for i = index,listCount-1 do
			list[i] = list[i+1];
			indexMap[list[i].sid] = i;
		end
		list[listCount] = nil;
	end

	local parseOverTask = function(overTaskInfo)
		local task = {};
		task.sid = overTaskInfo[1];
		task.accept_time = overTaskInfo[2];
		task.complete_time = overTaskInfo[3];
		return task;
	end

	local parseTask = function(taskInfo)
		local task = {};
		task.sid = taskInfo[1];
		task.accept_time = taskInfo[2][1];
		task.add_award = taskInfo[2][2];
		task.fail_data = taskInfo[2][3];
		task.is_fail = taskInfo[2][4];
		task.quality = taskInfo[2][5];
		task.retained = taskInfo[2][6];
		task.son_sid = taskInfo[2][7];
		task.success_data = taskInfo[2][8];

		task.visible = taskInfo[2][9];
        task.otherInfo = taskInfo[2][10];
		local taskTableInfo = tb.TaskTable[task.sid]; 
		task.sorting = taskTableInfo.sorting;
		if taskTableInfo.task_module_type == commonEnum.taskModuleType.ZhuXian and taskTableInfo.task_type ~= 14 then
			taskMgr.mainTaskSid = task.sid;
		end
		return task;
	end

	local dump = function ()
		--print("--------- count : " .. #taskList .. " -----------")
		for i = 1, #taskList do
			--print("sid : " .. taskList[i].sid);
		end
		--print("------------------------------------------------");
	end

	-- 初始化任务列表
	taskMgr.InitTaskList = function()
		local msg = {cmd = "get_tasks"};
		Send(msg, taskMgr.parseTaskList);	
	end

	local function compare(a,b)
		return a.sorting < b.sorting;
	end

	-- 
	taskMgr.refreshSorting = function ()
		table.sort(taskList,compare);
		for i=1,#taskList do
			Sid2IndexMap[taskList[i].sid] = i;
		end
	end

	taskMgr.parseTaskList = function(msgTable)
		local AcceptTask = msgTable.msg;
		local OverTask = msgTable.over;
		for i=1,#AcceptTask do
			local taskInfo = parseTask(AcceptTask[i]);
			taskList[i] = taskInfo;
			--为区域探索任务注册地图事件
			taskMgr.ProcessAreaTask(taskInfo);
			--已经完成的任务优先级为1
			if taskMgr.isTaskComplete(taskList[i].sid) then
				taskList[i].sorting = 101;
			end
			local taskTableInfo = tb.TaskTable[taskList[i].sid]; 
			--这里对于等级任务来说，接到的时候可能已经是可以完成的状态，这时直接提交
			if taskTableInfo.task_module_type == commonEnum.taskModuleType.ZhuXian then
				if taskTableInfo.task_type == 12 and DataCache.myInfo.level >= taskTableInfo.successCondition[1].v1 then
			        local msg = {cmd = "complete_task", sid = taskList[i].sid};
			        Send(msg)
			    end
		    end
		end
		--根据sorting对任务进行排序
		taskMgr.refreshSorting();

		for j=1,#OverTask do
			local taskInfo = parseOverTask(OverTask[j]);
			overList[j] = taskInfo;
			Sid2IndexOverMap[taskInfo.sid] = j;
		end

		if MainUI and MainUI.FormatTaskList then
			MainUI.FormatTaskList();
		end
		if MainUI and MainUI.initGrowth then
			MainUI.initGrowth();
		end

		taskMgr.GenNpcShowList();
	end

	taskMgr.ProcessAreaTask = function(taskInfo)
		local taskTableInfo = tb.TaskTable[taskInfo.sid]; 
		--有配置到达某区域的触发，并不要求一定是到达区域任务
		if TaskTrigger.HaveCertainEvent(taskInfo.sid,"enterArea") then
			TaskTrigger.TriggerEvent(taskInfo.sid,false);
		--是区域探索任务且当前未完成才会注册
		elseif taskTableInfo.task_type == 8 then
			if taskMgr.isTaskComplete(taskInfo.sid) == false then
				local sc = taskTableInfo.successCondition[1];
				AreaManager.AddListener(sc.v1, taskInfo.sid, sc.v2[1], 0, sc.v2[2], sc.v3, taskMgr.enterArea);
			end
		elseif taskTableInfo.task_type == 13 then
			if taskInfo.sid == client.MolongTask.ProtectTaskSid then
				client.MolongTask.UpdateProtectTask(taskInfo);
			end
		end
	end

	taskMgr.enterArea = function(position)
		local msg = {cmd = "client_event", type = "reach_area", pos = {x = position.x, y = position.y, z = position.z}};
		Send(msg);	
	end

	taskMgr.getTaskList = function()
		return client.tools.filter(taskList, function (task) return task.visible == 1 end);	
	end

	taskMgr.getTracingRewardTask = function()
		local list = taskMgr.getTaskList()
		for k,v in pairs(list) do
			local Info = tb.TaskTable[v.sid];
			if Info.task_module_type == commonEnum.taskModuleType.XuanShang then
				return v;
			end
		end
		return nil;
	end

	--根据一个sid获取当前的任务结构
	taskMgr.getTaskBySid = function(sid)
		local index = Sid2IndexMap[sid];
		if index == nil then
			return nil;
		else 
			return taskList[index];
		end
	end
	taskMgr.getOverTaskBySid = function(sid)
		local index = Sid2IndexOverMap[sid];
		if index == nil then
			return nil;
		else 
			return overList[index];
		end
	end

	taskMgr.isDoneTask = function(sid)
		return taskMgr.getOverTaskBySid(sid) ~= nil;
	end

	taskMgr.getTaskBySidEx = function (sid)
		local task = taskMgr.getTaskBySid(sid)
		if task == nil then
			task = taskMgr.getOverTaskBySid(sid)
		end
		return task;
	end

	--任务现在会自动接取，不需要从npc处接取
	--收集可接取任务
-- 	local GatherAcceptList = function()
-- --		--print("GatherAcceptList!")
-- 		local acceptList = {};


-- 		for key,value in pairs(tb.TaskTable) do
-- --			--print("level_min:"..value.level_min..",level_max"..value.level_max);
-- 			--玩家等级符合要求
-- 			if DataCache.myInfo.level >= value.level_min and DataCache.myInfo.level <= value.level_max then
-- --				--print("需要完成："..value.task_completed);
-- 				--前置任务已经完成
-- 				if Sid2IndexOverMap[value.task_completed] ~= nil then
-- 					--不在已经接取和已经完成的任务中
-- 					if Sid2IndexMap[value.sid] == nil and Sid2IndexOverMap[value.sid] == nil then
-- 						acceptList[#acceptList+1] = value.get_npc;
-- 						npcID2TaskID[value.get_npc] = value.sid;
-- 					end
-- 				end
-- 			end
-- 		end
-- --		--print("acceptListSize:"..#acceptList)
-- 		return acceptList;
-- 	end

	-- --收集可完成任务
	-- local GatherCompleteList = function()
	-- 	local completeList = {};
	-- 	local taskTableInfo = nil;
	-- 	for i=1,#taskList do
	-- 		if taskMgr.isTaskComplete(taskList[i].sid) or taskMgr.isTalkTask(taskList[i].sid) then
	-- 			taskTableInfo = tb.TaskTable[taskList[i].sid];
	-- 			completeList[#completeList+1] = taskTableInfo.complete_npc;
	-- 			npcID2OverTaskID[taskTableInfo.complete_npc] = taskList[i].sid;
	-- 		end
	-- 	end
	-- 	return completeList;
	-- end


	-- --收集可对话
	local GatherTalkTaskList = function()
		local talkTaskList = {};
		local taskTableInfo = nil;
		for i=1,#taskList do
			if taskMgr.isTalkTask(taskList[i].sid) then --taskMgr.isTaskComplete(taskList[i].sid) or
				taskTableInfo = tb.TaskTable[taskList[i].sid];
				local completeNpc = taskTableInfo.successCondition[1].v1;
				talkTaskList[#talkTaskList+1] = completeNpc;
				npcID2OverTaskID[completeNpc] = taskList[i].sid;
			end
		end
		return talkTaskList;
	end	

	--收集采集任务
	local GatherResourceList = function()
		local resourceNpcList = {};
		local taskTableInfo = nil;
		for i=1,#taskList do
			-- 如果是需要采集的任务
			taskTableInfo = tb.TaskTable[taskList[i].sid];
			if taskTableInfo.task_type == 6 or taskTableInfo.task_type == 7 then
				if taskList[i].success_data[1] ~= nil and taskTableInfo.successCondition[1] ~= nil then
					--没有采集完
					if taskList[i].success_data[1] < taskTableInfo.successCondition[1].v2 then
						resourceNpcList[#resourceNpcList + 1] = taskTableInfo.successCondition[1].v1;
						npcID2ResTaskID[taskTableInfo.successCondition[1].v1] = taskList[i].sid;
					end
				end
			end
		end
		return resourceNpcList;
	end
	
	taskMgr.GenNpcShowList = function()
		--清空这两个npcID到任务ID的对应关系
		npcID2ResTaskID = {};
		local CanTalkList = GatherTalkTaskList();
		if #CanTalkList > 0 then
			for i=1,#CanTalkList do
				InteractionManager.SetTaskState(CanTalkList[i], TaskNoticeType.Complete);
				--注册可能的触发事件，在走到对应位置后才激活下一步
	        	if TaskTrigger.HaveCertainEvent(npcID2OverTaskID[CanTalkList[i]],"npcInteract") ~= false then
	        		TaskTrigger.TriggerEvent(npcID2OverTaskID[CanTalkList[i]],false);
	        	end
			end
		end
		--生成可以采集的npc
		local ResourceNpcList = GatherResourceList();
		if #ResourceNpcList > 0 then
			for i=1,#ResourceNpcList do
				InteractionManager.SetTaskState(ResourceNpcList[i],TaskNoticeType.Resource);
			end
		end	

		client.MolongTask.RefreshProtectTask(false);
	end

	taskMgr.openTaskAccept = function(npcSid)
		-- TODO AvatarData结构变动 需要修改		 linh
		-- --TODO:根据go找到相应的任务sid

		taskMgr.forceOpenTaskAccept(npcSid);
		-- if Vector3.PlaneDistance(AvatarData.transform.position, AvatarCache.me.transform.position) < inDistance * inDistance then
		-- 	taskMgr.forceOpenTaskAccept(NpcSid);
		-- else
		-- 	if npcID2OverTaskID[NpcSid] ~= nil then
		-- 		local taskId = npcID2OverTaskID[NpcSid];
		-- 		taskMgr.TaskAutoGo(taskId);
		-- 	end			
		-- end
	end

	taskMgr.forceOpenTaskAccept = function(sid)
		local npcSid = sid;
		local taskId = 0;
		if npcID2TaskID[npcSid] ~= nil then
			taskId = npcID2TaskID[npcSid];
		end
		if npcID2OverTaskID[npcSid] ~= nil then
			taskId = npcID2OverTaskID[npcSid];
		end
		if taskId == 0 then
			return;
		end
		if TaskTrigger.HaveCertainEvent(taskId,"npcInteract") ~= false then
        	TaskTrigger.DoNextEvent(taskId);
        	return;
        end

		PanelManager:CreateFullScreenPanel('TaskTalk',function() end,{TaskId = taskId , NpcSid = npcSid});
	end

	local lastTime = nil;
	taskMgr.finishCollect = function(npcId,taskId)
		local msg = {cmd = "finish_collect", npc = npcId, taskSid = taskId};
		Send(msg, function (msgTable)
			lastTime = math.floor(TimerManager.GetServerNowMillSecond());
			local result = msgTable["result"];
		end)
	end

	
	taskMgr.getResTaskID = function (npcSid)
		return npcID2ResTaskID[npcSid];
	end


	taskMgr.breakCollectResBySid = function(npcSid, npcId)
		if npcID2ResTaskID[npcSid] ~= nil then
			local taskId = npcID2ResTaskID[npcSid];
			local msg = {cmd = "stop_collect", npc = npcId, taskSid = taskId};
			Send(msg, function (msgTable)
				local result = msgTable["result"];
				if result == "ok" then
					client.collectProcess.BreakCollect();
				end
			end);
		end
	end


	taskMgr.breakCollectRes = function(go)
		local avatarData = go:GetComponent("AvatarData");
		local npcSid = avatarData.sID;
		local npcId = avatarData.ID;
		taskMgr.breakCollectResBySid(npcSid, npcId);
	end

	taskMgr.addResGroup = function(npcSid,taskId)
		npcID2ResTaskID[npcSid] = taskId;
	end

	taskMgr.collectRes = function(go)
		if client.collectProcess.isCollect() == true then
			return;
		end

		if lastTime ~= nil and TimerManager.GetServerNowMillSecond() - lastTime < 200 then
			return;
		end
		
		local AvatarData = go:GetComponent("AvatarData");
		local npcSid = AvatarData.sID;
		local npcId = AvatarData.ID;
		if npcID2ResTaskID[npcSid] ~= nil then
			local taskId = npcID2ResTaskID[npcSid];
			local taskTableInfo = tb.TaskTable[taskId];
			local npcTableInfo = tb.NPCTable[npcSid];
			if resHelpTable[npcId] == nil then
				resHelpTable[npcId] = true;
			end
			if client.collectProcess.CheckCoolDown() == true then
				local msg = {cmd = "start_collect", npc = npcId, taskSid = taskId};
				Send(msg,function (msgTable)
					local result = msgTable["result"];
					if result == "ok" then


						client.collectProcess.StartCollect(npcSid, npcId, npcTableInfo.collect_time/1000, npcTableInfo.collect_msg,
							function() taskMgr.finishCollect(npcId,taskId); end);
					elseif result == "target_in_use" then 
						if resHelpTable[npcId] == true then
							resHelpTable[npcId] = false;
							ui.showMsg("采集目标已被其他玩家锁住");
						end
					else
						-- ui.showMsg("采集失败");
					end
				end);
			end
		end
	end

	taskMgr.isTaskComplete = function(sid)
		local index = Sid2IndexMap[sid];
		if index == nil then
			return false
		end
		local taskInfo = taskList[index];
		local taskTableInfo = tb.TaskTable[taskInfo.sid];
		--TODO:魔龙岛任务这里待处理
		if taskTableInfo.successCondition[1] == nil or taskTableInfo.successCondition[1].type == nil then
			return true;
		end
		if taskInfo.success_data == nil then
			return false;
		end
		local taskType = taskTableInfo.successCondition[1].type;
        local completeType = TaskCompleteType[taskType];
		if completeType == 1 then
			for i=1,#taskTableInfo.successCondition do
			    if taskInfo.success_data[i] ~= taskTableInfo.successCondition[i].v2 then
	                return false;
	            end
	        end
	        return true;
		elseif completeType == 2 then
			if taskTableInfo.task_type == 13 or taskTableInfo.task_type == 15 then
				for i=1,#taskInfo.success_data do
					if taskInfo.success_data[i] == "false" then
						return false;
					end
				end
				--所有点都为true才算完成
				return true;
            elseif taskInfo.success_data[1] == "true" then
                return true;
            else
                return false;
            end
		end
	end

	taskMgr.isTalkTask = function(sid)
		local taskTableInfo = tb.TaskTable[sid];
		if taskTableInfo == nil then
			return false;
		end
		if taskTableInfo.successCondition[1] == nil then
			return false;
		end
		local taskType = taskTableInfo.successCondition[1].type;
		if taskType == 5 then
			return true;
		else
			return false;
		end
	end

	taskMgr.handleTask = function(msgTable)
		if msgTable["refresh_task"] ~= nil then
			updateTask(msgTable);
		elseif  msgTable["add_task"] ~= nil then
			addTask(msgTable);
		elseif msgTable["complete_task"] ~= nil then
			completeTask(msgTable);
		elseif msgTable["delete_task"] ~= nil then
			deleteTask(msgTable);
		end
	end
	
	--更新现有的任务
	updateTask = function(msgTable)
		--更新任务状态
		local modifyList = msgTable["refresh_task"];

		local updateTaskList = {};
		for i=1,#modifyList do
			local taskInfo = parseTask(modifyList[i])
			updateTaskList[i] = taskInfo;
		end


		for i=1,#updateTaskList do
			--如果任务列表中已经有这条任务
			if Sid2IndexMap[updateTaskList[i].sid] ~= nil then
				local index = Sid2IndexMap[updateTaskList[i].sid];
				taskList[index] = updateTaskList[i];
				taskMgr.TaskUpdatetable[taskList[index].sid] = true;
				local taskTableInfo = tb.TaskTable[taskList[index].sid];
				if taskMgr.isTaskComplete(taskList[index].sid) then									
					if taskTableInfo ~= nil then
						--如果是采集任务，移除采集物的可采集状态
						if taskTableInfo.task_type == 6 or taskTableInfo.task_type == 7 then
							if taskTableInfo.successCondition[1] ~= nil then
								local resourceSid =  taskTableInfo.successCondition[1].v1;
								if npcID2ResTaskID[resourceSid] ~= nil then
									InteractionManager.SetTaskState(resourceSid,TaskNoticeType.None);
									npcID2ResTaskID[resourceSid] = nil;
								end
							end
						end
						--如果是主线任务，任务目标完成直接自动提交
						-- print("updateTaskList[i].sid:"..updateTaskList[i].sid)
						-- print("taskTableInfo.task_module_type:"..taskTableInfo.task_module_type)
						if taskTableInfo.task_module_type == commonEnum.taskModuleType.ZhuXian then
							-- print("发送任务完成:"..taskList[index].sid)
                            local msg = {cmd = "complete_task", sid = taskList[index].sid};
                            Send(msg,function(reMsg)
                                --藏宝图完成了  再次触发   
                                if taskTableInfo.task_type == 14 then
                                    client.CBTCtrl.begin_cbt(false);
                                end
                            end)		
                        else 
							--如果配置了自动寻路提交，则直接寻路到npc
							-- if taskTableInfo.task_type ~= 5 then
							-- 	if taskTableInfo.auto_submit == 1 then
							-- 		taskMgr.TaskAutoGo(taskList[index].sid);
							-- 	end
							-- end
							client.RewardTask.TaskCompleted(taskList[index].sid)
							client.MolongTask.TaskCompleted(taskList[index].sid)                       				
						end

						if taskTableInfo.task_module_type ~= commonEnum.taskModuleType.ZhuXian then
							--重设任务的优先级，并重新进行排序
							taskList[index].sorting = 101;
							taskMgr.refreshSorting();
						end
					end
				end
				--处理护送任务的进度
				if taskTableInfo ~= nil and taskTableInfo.task_type == 13 then
					taskMgr.ProcessAreaTask(taskList[index]);
				end
				taskMgr.GenNpcShowList();
			end  
		end

		-- for i = 1, #taskList do
		-- 	local task = taskList[i];
		-- 	--print("sid: " .. task.sid .. ", visible: " .. task.visible);
		-- end

		--TODO:wugj 改成事件机制
		-- UIManager.GetInstance():CallLuaMethod('TaskAccept.RefreshTask');
		UIManager.GetInstance():CallLuaMethod('MainUI.FormatTaskList');
	end

	
	--添加新的任务
	addTask = function(msgTable)
		--更新任务状态
		local addList = msgTable["add_task"];
		local addTaskList = {};
		for i=1,#addList do
			local taskInfo = parseTask(addList[i])
			--新添加的任务给予一个标记，来显示一个接受任务的光效			
			taskInfo.bIsNew = true;
			addTaskList[i] = taskInfo;
		end

		for i=1,#addTaskList do
			--如果任务列表中已经有这条任务
			if Sid2IndexMap[addTaskList[i].sid] ~= nil then
				return;
			else
				local index = Sid2IndexMap[addTaskList[i].sid];
				taskList[#taskList+1] = addTaskList[i];
				--已经完成的任务优先级为1
				if taskMgr.isTaskComplete(addTaskList[i].sid) then
					taskList[#taskList].sorting = 101;
				end
				local taskTableInfo = tb.TaskTable[addTaskList[i].sid];
				if taskTableInfo.task_module_type == commonEnum.taskModuleType.ZhuXian and taskTableInfo.task_type ~= 14 then
					taskMgr.mainTaskSid = addTaskList[i].sid;
					if taskTableInfo.progress  == 100 then
						isFirstHolyShow = true;
					end
				end
				--Sid2IndexMap[addTaskList[i].sid] = #taskList;
				taskMgr.refreshSorting();

				--这里需要移出接取任务的npc状态和点击回调
				local sid = addTaskList[i].sid;
				local npcSid = taskTableInfo.get_npc;
				if npcID2TaskID[npcSid] ~= nil then
					InteractionManager.SetTaskState(npcSid, TaskNoticeType.None);
					npcID2TaskID[npcSid] = nil;
				end

				--这里对于等级任务来说，接到的时候可能已经是可以完成的状态，这时直接提交
				if taskTableInfo.task_module_type == commonEnum.taskModuleType.ZhuXian then
					if taskTableInfo.task_type == 12 and DataCache.myInfo.level >= taskTableInfo.successCondition[1].v1 then
				        local msg = {cmd = "complete_task", sid = addTaskList[i].sid};
				        Send(msg)
				    end
			    end
				--处理可能添加的区域探索任务
				taskMgr.ProcessAreaTask(addTaskList[i]);			
			end  
		end
		if tb.TaskTable[addTaskList[1].sid].accept_autogo == 1 and not SceneManager.IsXiangWeiMap(DataCache.scene_sid) then
			taskMgr.TaskAutoGo(addTaskList[1].sid)
		end


		--TODO:wugj 改成事件机制
		-- UIManager.GetInstance():CallLuaMethod('TaskAccept.Close');
		-- UIManager.GetInstance():CallLuaMethod('MainUI.FormatTaskList');
		--接取了新的任务，更新npc状态
		taskMgr.GenNpcShowList();
		--自动寻路到目标点
		MainUI.FormatTaskList();
		MainUI.RefreshTaskListLater(0.5);

		EventManager.onEvent(Event.ON_ADD_TASK, taskMgr.mainTaskSid);
	end

	deleteTask = function (msgTable)
		local taskSid = msgTable.delete_task;
		local index;
		client.MolongTask.TaskCompleted(taskSid)

		if Sid2IndexMap[taskSid] ~= nil then
			index = Sid2IndexMap[taskSid];
			removeTaskList(taskList, index, Sid2IndexMap);
		end

		if Sid2IndexOverMap[taskSid] ~= nil then
			index = Sid2IndexOverMap[taskSid];
			removeTaskList(overList, index, Sid2IndexOverMap);
		end
		
		UIManager.GetInstance():CallLuaMethod('MainUI.FormatTaskList');
	end


	--完成现有的任务
	completeTask = function(msgTable)


		

		--更新任务状态
		local taskSid = msgTable["complete_task"];
		if Sid2IndexMap[taskSid] == nil then
			return;
		end



		local listCount = #taskList;
		local index = Sid2IndexMap[taskSid];
		--将任务加入到已完成任务列表中
		overList[#overList+1] = taskList[index];
		Sid2IndexOverMap[taskList[index].sid] = #overList;

		removeTaskList(taskList, index, Sid2IndexMap);

		-- 不是悬赏任务不能停止自动战斗，悬赏任务不能停止自动战斗
		local taskTableInfo = tb.TaskTable[taskSid];
		if taskTableInfo.task_module_type ~= commonEnum.taskModuleType.XuanShang then
			local player = AvatarCache.me;
			local class = Fight.GetClass(player);
			class.HandUp(player, false);
		end

		--任务完成时移除问号的状态和点击回调，目前只有对话任务使用
		if taskMgr.isTalkTask(taskSid) then		
			local npcSid = taskTableInfo.successCondition[1].v1;
			if npcID2OverTaskID[npcSid] ~= nil then
				InteractionManager.SetTaskState(npcSid,TaskNoticeType.None);
				npcID2OverTaskID[npcSid] = nil;
			end
		end
		--移除这个对话过的标志
		taskMgr.TalkOverTable[taskSid] = nil;

		--NSY-2740:播放任务完成的光效及奖励飘字，现在和追踪区无关
		MainUI.CompleteTaskEffect(taskSid);

		--如果配置了寻路接取下一个任务的sid，则开始寻路
		-- if taskTableInfo.auto_accept ~= 0 then
		-- 	taskMgr.TaskAutoGo(taskTableInfo.auto_accept);
		-- end		
		--刷新主界面追踪区
		MainUI.FormatTaskList();
		client.MolongTask.TaskCompleted(taskSid);

		UIManager.GetInstance():CallLuaMethod('MainUIGrowth.CompleteTask', taskSid);
    	if TaskTrigger.HaveCertainEvent(taskSid,"taskDone") ~= false then
    		TaskTrigger.TriggerEvent(taskSid,true);
    	end
		--完成了已有的任务，更新npc状态
		taskMgr.GenNpcShowList();	


		EventManager.onEvent(Event.ON_GUIDE_COMPLETE_TASK, taskSid);
		EventManager.onEvent(Event.ON_TASK_COMPLETED, taskSid);
	end


	

	-- 判断玩家是否在目标点附近
	taskMgr.TaskAutoGo_IsPlayerNearby = function (dst_scene_sid, dst_x, dst_y, dst_z)
		local player = AvatarCache.me;
		local player_pos_x = player.pos_x;
		local player_pos_y = player.pos_y;
		local player_pos_z = player.pos_z;
		local dx = player_pos_x - dst_x;
		local dy = player_pos_y - dst_y;
		local dz = player_pos_z - dst_z;
		local dist2 = dx * dx + dz * dz;
        if DataCache.scene_sid == dst_scene_sid and dist2 < 4  then
        	return true;
        end
        return false;
	end;

	-- 开启玩家自动战斗
	taskMgr.TaskAutoGo_OpenAutoFighting = function ()
		local player = AvatarCache.me;
		local class = Fight.GetClass(player);
		class.HandUp(player, true);
	end;

	-- 开启和npc交互
	taskMgr.TaskAutoGo_InteractNpc = function (npcSid)
    	taskMgr.forceOpenTaskAccept(npcSid);
	end;

	-- 任务 AutoGo 寻路
	taskMgr.TaskAutoGo_Pathfinding = function (dst_scene_sid, dst_pos_x, dst_pos_y, dst_pos_z, callback)
         --开始进行寻路操作
         -- print("开始进行寻路操作")
         -- print(dst_scene_sid)
        local scenePos = { x = dst_pos_x, y = dst_pos_z };
    	if taskMgr.TaskUpdatetable[const.lastSid] ~= nil then
    		taskMgr.TaskUpdatetable[const.lastSid] = nil;
    		--直接传送，不用寻路操作
    		local msg = {cmd = "transmit", scene_sid = dst_scene_sid}
			Send(msg, function ()
				-- 从水晶自动寻路到NPC不需要读条操作
				TransmitScroll.ClickLinkPathing(dst_scene_sid, DataCache.fenxian, scenePos, callback);
			end);
    	else
    		--print("7.2")
    		TransmitScroll.ClickLinkPathing(dst_scene_sid, DataCache.fenxian, scenePos, callback);
    	end
	end;

	--------------------------------------------------
	-- 任务自动移动
	--------------------------------------------------

	taskMgr.autogo_handlers = {};

	-- 杀死怪物
	taskMgr.autogo_handlers[TaskAutoGoType.KillNpc] = function (taskSid)
		--print("Kill Npc")
		local taskTableInfo = tb.TaskTable[taskSid];
        if taskTableInfo == nil then
        	--print("没有找到指定任务id的任务信息:" .. taskSid);
        	return;
        end
        local sc = taskTableInfo.successCondition[1];
        local monsterSid = sc.v1;
        local monsterMapInfo = tb.MapOnlyNPCTable[monsterSid];
        if monsterMapInfo == nil then
        	return;
        end

        local dst_scene_sid = monsterMapInfo.scene_id;
        local dst_x = monsterMapInfo.pos[1];
        local dst_z = monsterMapInfo.pos[2];
        -- print(string.format("自动寻路: dst_scene_sid=%d, pos={%f, %f, %f}, taskSid=%d", dst_scene_sid, dst_x, 0, dst_z, taskSid));
    	taskMgr.TaskAutoGo_Pathfinding(dst_scene_sid, dst_x, 0, dst_z, function ()
    		-- print("open auto fight");
    		taskMgr.TaskAutoGo_OpenAutoFighting();
    		-- if AvatarCache.me.is_auto_fighting then
    		-- 	--print("open: auto fighting");
    		-- else
    		-- 	--print("close: auto fighting");
    		-- end
    	end);
	end;

	-- 与 npc 对话
	taskMgr.autogo_handlers[TaskAutoGoType.Dialog] = function (taskSid)
		local taskTableInfo = tb.TaskTable[taskSid];
        if taskTableInfo == nil then
        	--print("没有找到指定任务id的任务信息:" .. taskSid);
        	return;
        end
        local sc = taskTableInfo.successCondition[1];
        local npcSid = sc.v1;
        local npcMapInfo = tb.MapOnlyNPCTable[npcSid];
        local dst_scene_sid = npcMapInfo.scene_id;
        local dst_x = npcMapInfo.pos[1];
        local dst_z = npcMapInfo.pos[2];
        -- print(string.format("自动寻路: dst_scene_sid=%d, pos={%f, %f, %f}, taskSid=%d", dst_scene_sid, dst_x, 0, dst_z, taskSid));
    	taskMgr.TaskAutoGo_Pathfinding(dst_scene_sid, dst_x, 0, dst_z, function ()
    		-- print("interact npc: " .. npcSid);
    		taskMgr.TaskAutoGo_InteractNpc(npcSid);
    	end);
	end;

	-- 采集的任务自动移动
	taskMgr.autogo_handlers[TaskAutoGoType.Collect] = function (taskSid)

		local taskTableInfo = tb.TaskTable[taskSid];
        if taskTableInfo == nil then
        	--print("没有找到指定任务id的任务信息:" .. taskSid);
        	return;
        end
        local sc = taskTableInfo.successCondition[1];
		local npcSid = sc.v1;
        local npcMapInfo = tb.MapOnlyNPCTable[npcSid];
        local obj = InteractionManager.GetSingleNpc(npcSid);
        if obj ~= nil then
        	local player = AvatarCache.me;
        	if player ~= nil then
        		local player_class = Fight.GetClass(player);
        		player_class.HandUp(player, false);
        	end
        	local obj_pos_x = obj.pos_x;
        	local obj_pos_y = obj.pos_y;
        	local obj_pos_z = obj.pos_z;
        	local dst_scene_sid = npcMapInfo.scene_id;
        	local dst_x = obj_pos_x;
        	local dst_y = obj_pos_y;
        	local dst_z = obj_pos_z;
        	taskMgr.IsResAutoGo = false;
        	-- print(string.format("自动寻路: dst_scene_sid=%d, pos={%f, %f, %f}, taskSid=%d", dst_scene_sid, dst_x, 0, dst_z, taskSid));
	        taskMgr.TaskAutoGo_Pathfinding(dst_scene_sid, dst_x, 0, dst_z);
        else
        	if npcMapInfo ~= nil then
        		local player = AvatarCache.me;
	        	if player ~= nil then
	        		local player_class = Fight.GetClass(player);
	        		player_class.HandUp(player, false);
	        	end		
        		local dst_scene_sid = npcMapInfo.scene_id;
        		local dst_x = 0;
        		local dst_z = 0;
        		--魔龙岛任务读取单独的配置
        		if dst_scene_sid == client.MolongTask.sceneSid then
        			local scenePos = client.MolongTask.GetCollectPosition(taskSid,npcSid);
        			dst_x = scenePos.x;
        			dst_z = scenePos.y;
        		else
        			dst_x = npcMapInfo.pos[1];
        			dst_z = npcMapInfo.pos[2];
        		end
        		taskMgr.IsResAutoGo = true;
				taskMgr.ResAutoGoSid = npcSid;
				-- print(string.format("自动寻路: dst_scene_sid=%d, pos={%f, %f, %f}, taskSid=%d", dst_scene_sid, dst_x, 0, dst_z, taskSid));
		        taskMgr.TaskAutoGo_Pathfinding(dst_scene_sid, dst_x, 0, dst_z);
        	end
            --这个记录一个状态，在后该npc出现在视野中的时候，直接寻路到对应npc的位置
		end
	end;

	-- 探索区域
	taskMgr.autogo_handlers[TaskAutoGoType.SearchArea] = function (taskSid)
		local taskTableInfo = tb.TaskTable[taskSid];
        if taskTableInfo == nil then
        	--print("没有找到指定任务id的任务信息:" .. taskSid);
        	return;
        end
        local player = AvatarCache.me;
    	if player ~= nil then
    		local player_class = Fight.GetClass(player);
    		player_class.HandUp(player, false);
    	end		
        local sc = taskTableInfo.successCondition[1];
		local dst_scene_sid = sc.v1;
		local dst_x = sc.v2[1];
		local dst_z = sc.v2[2];
        taskMgr.TaskAutoGo_Pathfinding(dst_scene_sid, dst_x, 0, dst_z);
	end;

	

	-- 执行自动移动
	taskMgr.DoTaskAutoGo = function (type, taskSid)
	    -- print("type = "..type)
		local handler = taskMgr.autogo_handlers[type];
		InteractionManager.ClearAutoGoNpc();
		if handler ~= nil then
			handler(taskSid);
		end
	end;

	-- 任务自动移动
	taskMgr.TaskAutoGo = function(taskSid)

		taskMgr.CurTraceTaskSid = taskSid;
		--local index = Sid2IndexMap[taskSid];
		--任务列表中未找到要寻路的任务
		-- if index == nil then
		-- 	return;
		-- end		
		--local taskInfo = taskList[index];

		--这里目前要支持寻路接取下一个任务
        local taskTableInfo = tb.TaskTable[taskSid];
        if taskTableInfo == nil then
        	--print("没有找到指定任务id的任务信息:"..taskSid);
        	return;
        end
    	if TaskTrigger.HaveCertainEvent(taskSid,"enterArea") == true then
    		local StartInfo = tb.TaskTrigger[taskSid].trigger;
    		if  not SceneManager.IsXiangWeiMap(DataCache.scene_sid) then
    			taskMgr.TaskAutoGo_Pathfinding(StartInfo.mapSid, StartInfo.pos[1], 0, StartInfo.pos[3]);
    			return
    		end	
    	end
        local index = Sid2IndexMap[taskSid];
        local sc = taskTableInfo.successCondition[1];
        local sceneSid = 0;     --要寻路的地图sid
        local scenePos = nil;   --要寻路的地图坐标
        local arriveEvent = ArriveTriggerEvent.ATE_None;	--到达任务点后的回调


        --没有在身上找到该任务，直接返回
        if index == nil or sc == nil then
        	return;
        end

        --这类是击杀npc的任务，寻路到所在npc处
        if taskTableInfo.task_type == 1 or
        	taskTableInfo.task_type == 2 or
        	taskTableInfo.task_type == 3 or
            taskTableInfo.task_type == 4 then
            -- print("悬赏任务");
            taskMgr.DoTaskAutoGo(TaskAutoGoType.KillNpc, taskSid);
            MainUI.RefreshTaskListLater(0.5);
            return;

        end

        if taskTableInfo.task_type == 5 then
            taskMgr.DoTaskAutoGo(TaskAutoGoType.Dialog, taskSid);
            MainUI.RefreshTaskListLater(0.5);
            return;
        end

        --到指定npc处采集物品
        if taskTableInfo.task_type == 6 or taskTableInfo.task_type == 7 then
			taskMgr.DoTaskAutoGo(TaskAutoGoType.Collect, taskSid);
			MainUI.RefreshTaskListLater(0.5);
			return;
		end

        --探索区域
        if taskTableInfo.task_type == 8 then
            -- sceneSid = sc.v1;
            -- scenePos = Vector2.New(sc.v2[1],sc.v2[2]);

            taskMgr.DoTaskAutoGo(TaskAutoGoType.SearchArea, taskSid);
            MainUI.RefreshTaskListLater(0.5);
            return;
        end

        if taskTableInfo.task_type == 13 then
        	if taskSid == client.MolongTask.ProtectTaskSid then
                client.MolongTask.ProtectAutoGo(taskTableInfo);
            end
            MainUI.RefreshTaskListLater(0.5);
            return;

        end

        --藏宝图   
        if taskTableInfo.task_type == 14 then
            client.CBTCtrl.begin_cbt_action();
            -- MainUI.FormatTaskList();
            return;
        end
        	
        -- 任务类型 9, 10, 11, 12，不处理
        
	end

	taskMgr.getTaskExp = function (task)
	 	if task == nil then
	 		return 0;
	 	end
		local exp = tb.TaskTable[task.sid].exp_award;
		--完成任务列表中是没有add_award的，但有需求要显示，这个可能要改进
		if task.add_award ~= nil then
			for i = 1, #task.add_award do				
				if task.add_award[i][1] == "exp" then
					exp = exp + task.add_award[i][2];
				end
			end
		end
		return exp;
	end

	SetPort("task",taskMgr.handleTask);

	taskMgr.taskClickZhuXian = function (task)
		
	end
	taskMgr.taskClickXuanShang = function (task)
		ui.ShowRewardTask()
	end

	taskMgr.taskClickEvent = 
	{
		taskMgr.taskClickZhuXian,
		taskMgr.taskClickXuanShang,
	}

	taskMgr.HandleNpcRemove = function(npcId)
		if resHelpTable[npcId] ~= nil then
			resHelpTable[npcId] = nil;
		end
	end
	EventManager.register(Event.ON_NPC_REMOVE,taskMgr.HandleNpcRemove);
	return taskMgr;	
end
client.task = CreateTaskManager();
--所有所接任务所在的列表
 