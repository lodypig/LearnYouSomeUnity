function CreateRewardTaskCtrl()
	local RewardTask = {};
	RewardTask.TaskList = nil;--任务列表  任务id,品质,状态（Tracking、completed、free）
	RewardTask.RefreshTime = 0;

	RewardTask.OnEqueueEvent = nil;
	RewardTask.DoNumOneDay = 5;


	local DoNext;
	local Check_1;
	local Check_2;
	local Check_3;
	local CreatEnumTable = nil;
	local CompletedToState = nil;
	local HaveCompletedToState = nil;
	local TracingToState = nil;
	
	RewardTask.StateEnum = nil;

	RewardTask.AddListener = function (listener)
		RewardTask.OnEqueueEvent = listener;
		RewardTask.UpdateUIInfo()
	end

	function RewardTask.UpdateUIInfo()
		if(RewardTask.OnEqueueEvent ~= nil) then
			RewardTask.OnEqueueEvent(RewardTask.TaskList);
		end
	end

	function CreatEnumTable(tbl, index) 
    	local enumtbl = {} 
    	local enumindex = index or 0 
   		for i, v in ipairs(tbl) do 
        	enumtbl[v] = enumindex + i 
    	end 
    	return enumtbl 
	end

	RewardTask.StateEnum = 
	{
		"Free",             --空闲
		"Tracing",			--追踪中
		"Completed",		--完成未提交
		"HaveCompleted"		--已完成
	};

	RewardTask.StateEnum = CreatEnumTable(RewardTask.StateEnum, 0);

	--任务完成未提交通知
	function RewardTask.TaskCompleted(sid)
		local table = tb.TaskTable[sid];
		if table == nil or RewardTask.TaskList == nil or table.task_module_type ~= commonEnum.taskModuleType.XuanShang then  --悬赏任务
			return;
		end

		local task = nil;
		for i = 1,#RewardTask.TaskList do
			if RewardTask.TaskList[i].sid == sid and RewardTask.TaskList[i].state < RewardTask.StateEnum.HaveCompleted then
				task = RewardTask.TaskList[i]
				break;
			end				
		end
		if task ~= nil then
			CompletedToState(task,true);
			RewardTask.UpdateUIInfo();
		end
		
		RewardTask.RefreshOtherPage();
	end

	--完成未提交
	function CompletedToState(task,flag)
		if task.state < RewardTask.StateEnum.Completed and flag == true then 
			task.state = RewardTask.StateEnum.Completed;
		end
	end
	--已完成
	function HaveCompletedToState(task,flag)
		if task.state < RewardTask.StateEnum.HaveCompleted and flag == 1 then
			task.state = RewardTask.StateEnum.HaveCompleted;
		end
	end
	--追踪中
	function TracingToState(task,state)
		if task.state <= RewardTask.StateEnum.Tracing then
			task.state = state;
		end
	end

	--解析任务
	function RewardTask.parseRewardTask(info)
		local task = {};
		task.sid = info[1];
		task.state = RewardTask.StateEnum.Free; --初始
		--是否已完成
		HaveCompletedToState(task,info[2]);  
		--是否完成未提交
		CompletedToState(task,client.task.isTaskComplete(task.sid));

		task.quality = info[3];

		return task;
	end

	--请求任务列表回调
	function RewardTask.OnReceiveTaskList(cb, msg)
	 	local content = msg["reward_task_info"]
	 	if content == nil then 
	 		return 
	 	end;
	 	RewardTask.RefreshTime = content[1];
	 	local traceIndex = content[3];
	 	local taskListInfo = content[4];
	 	RewardTask.TaskList = {};
	 	for i = 1, #taskListInfo do
	 		local tempInfo = RewardTask.parseRewardTask(taskListInfo[i])
	 		RewardTask.TaskList[i]  = tempInfo;
	 	end
	 	TracingToState(RewardTask.TaskList[traceIndex],RewardTask.StateEnum.Tracing)
	 	if cb ~= nil then
			cb(RewardTask.TaskList);
		end

		RewardTask.RefreshOtherPage();
		activity.AddReturnNumber();
	end

	--已完成个数
	function RewardTask.GetHaveCompletedNum()
		local num = 0;
		if RewardTask.TaskList ~= nil then
			for k,v in pairs(RewardTask.TaskList) do
				if v.state == RewardTask.StateEnum.HaveCompleted then
					num = num + 1;
				end
			end
			return num;
		else
			return 0;
		end
	end
	--请求任务列表
	function RewardTask.GetRewardTasks(callback)
		local msg = {};
		msg.cmd = "get_reward_tasks";
	 	Send(msg, function (msg) RewardTask.OnReceiveTaskList(callback, msg); end);
	end

	SetPort("rewardtasklist",function (msg) RewardTask.OnReceiveTaskList(nil, msg); end);

	function RewardTask.OnCommitTaskCallBack(msg)
		if msg.type == "ok" then
			if msg.trace_index ~= nil then	
				TracingToState(RewardTask.TaskList[msg.trace_index],RewardTask.StateEnum.Tracing)			
			end
			RewardTask.TaskList[msg.commit_index].state = RewardTask.StateEnum.HaveCompleted;
			RewardTask.UpdateUIInfo();

			RewardTask.RefreshOtherPage();
			EventManager.onEvent(Event.ON_EVENT_RED_POINT);
		end
	end

	function RewardTask.ChangeTracingCallBack(msg)
		if msg.type == "ok" then
			local OldTracingTask = RewardTask.TaskList[msg.oldIndex];
			local NewTracingTask = RewardTask.TaskList[msg.newIndex];

			TracingToState(OldTracingTask,RewardTask.StateEnum.Free)
			NewTracingTask.state = RewardTask.StateEnum.Tracing;
			RewardTask.UpdateUIInfo()
			client.task.TaskAutoGo(NewTracingTask.sid);
			-- MainUI.RefreshTaskListLater(0.5);
		end
	end

	function RewardTask.OnRewardTaskComplete()
		local msg = {};
		msg.cmd = "complete_reward_task";
		for i = 1,#RewardTask.TaskList do
			local task = RewardTask.TaskList[i]
			if client.task.isTaskComplete(task.sid) then
				msg.index = i;
				Send(msg,RewardTask.OnCommitTaskCallBack);
			end
		end
	end


	function RewardTask.OnTaskBtnClick(index)
		local msg = {};
		local task = RewardTask.TaskList[index]
		if task.state == RewardTask.StateEnum.Free then  --空闲态 -> 追踪
			msg.cmd = "trace_task";
			msg.index = index;
			Send(msg, RewardTask.ChangeTracingCallBack);
		elseif task.state == RewardTask.StateEnum.Completed then --完成态 -> 提交
			msg.cmd = "complete_reward_task";
			msg.index = index;
			Send(msg, RewardTask.OnCommitTaskCallBack);
		end
	end

-----------------------刷新判断 Begin--------------------------
	function RewardTask.IsHaveCompleted()
		if not RewardTask.TaskList then
			return false;
		end
		for k,v in pairs(RewardTask.TaskList) do
			if v.state == RewardTask.StateEnum.Completed then
				return true
			end
		end
		return false;
	end

	function RewardTask.IsAllQualityOfS()
		for k,v in pairs(RewardTask.TaskList) do
			if v.state < RewardTask.StateEnum.HaveCompleted and v.quality < 4 then
				return false;
			end
		end
		return true;
	end

	function DoNext()
		RewardTask.DoSequentialCheck.iter = RewardTask.DoSequentialCheck.iter + 1
		if RewardTask.DoSequentialCheck.iter <= #RewardTask.DoSequentialCheck.funlist then
			RewardTask.DoSequentialCheck.funlist[RewardTask.DoSequentialCheck.iter]();
		end
	end

	function Check_1()
		if RewardTask.IsHaveCompleted() then
			ui.showMsgBox(nil, "当前有任务可以交付，是否刷新？",DoNext)	
		elseif RewardTask.IsAllQualityOfS() then
			ui.showMsgBox(nil, "当前任务都为S级，是否刷新？", DoNext)	
		else
			DoNext()
		end
	end

	function Check_2()
		if Bag.GetItemCountBysid(const.item.reward_task_refresh) <= 0 and DataCache.role_diamond < const.reward_task_refresh_diamond_cost then
			ui.showCharge()
		else
			DoNext()
		end
	end

	function RewardTask.DoRefresh(cb)
		local msg = {};
		msg.cmd = "diamond_refresh_reward_task";
	 	Send(msg, function (msg) RewardTask.OnReceiveTaskList(cb, msg); end);
	end
	
	RewardTask.DoSequentialCheck = {};
	
	RewardTask.DoSequentialCheck.iter = 1;
	RewardTask.DoSequentialCheck.StartCheck = function(cb)
		RewardTask.DoSequentialCheck.funlist = 
		{
			Check_1,
			Check_2,
			function () RewardTask.DoRefresh(cb) end
		};
		RewardTask.DoSequentialCheck.iter = 1;
		RewardTask.DoSequentialCheck.funlist[1]();
	end
		
	function RewardTask.RefreshTasks(cb)
		local flag = false;
		for k,v in pairs(RewardTask.TaskList) do
			if v.state ~= RewardTask.StateEnum.HaveCompleted then
				flag = true;
			end
		end
		
		if flag then
			RewardTask.DoSequentialCheck.StartCheck(cb);
		else
			ui.showMsg("没有可刷新任务");
		end
	end
-----------------------刷新判断 End--------------------------

	
	function RewardTask.Clear()
		RewardTask.OnEqueueEvent = nil;
	end

-----------------------悬赏任务状态变化，刷新活动页面和主菜单红点显示--------------------------
	function RewardTask.RefreshOtherPage()
		if UIManager.GetInstance():FindUI("UIMenu") ~= nil then
			UIManager.GetInstance():CallLuaMethod("UIMenu.onRedPoint")
		end
		if UIManager.GetInstance():FindUI("UIActivity") ~= nil then
			UIManager.GetInstance():CallLuaMethod("UIActivity.ReStart")
		end
	end

	return RewardTask;
end

client.RewardTask = CreateRewardTaskCtrl()