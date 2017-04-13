--缓存魔龙岛任务相关的信息，与RewardTaskCtrl相仿

function CreateMolongTaskCtrl()
	local ResCollectPosTable = {
		[21000] = {{78.7,134.9},{124.5,85.9}},
		[21001] = {{195.0,84.4},{232.2,126.7}},
		[21002] = {{80.7,195.0},{126.5,235.8}},

		[21004] = {{78.7,134.9},{124.5,85.9}},
		[21005] = {{195.0,84.4},{232.2,126.7}},
		[21006] = {{80.7,195.0},{126.5,235.8}}
	}

	local MolongTask = {};
	MolongTask.TaskList = nil;--任务列表  任务id,状态（Tracking、completed、free）
	MolongTask.RefreshTime = 0;

	MolongTask.OnEqueueEvent = nil;
	MolongTask.DoNumOneDay = 5;

	MolongTask.sceneSid = 20000003;
	MolongTask.ProtectTaskSid = 21003;
	MolongTask.EnergyStoneSid = 80010008;
	MolongTask.StartNpcSid = 90010020;
	MolongTask.ProtectStartTime = 0;
	MolongTask.ProtectTotalTime = 1800;--1800
	MolongTask.NengliangcheSid = 90010021;
	MolongTask.NengliangcheId = 0;

	MolongTask.AutoGoNpc = 0;
	MolongTask.filterFunc = function(ds)
		return ds.sid == MolongTask.AutoGoNpc;
	end	
	MolongTask.sortFunc = function(a, b)
		return Comparer.CompareNearerDistance(a, b) < 0;
	end
	MolongTask.GetCollectPosition = function(taskSid,npcSid)
		local posList = ResCollectPosTable[taskSid];
		if posList == nil then
			--print("任务id未找到")
			return Vector2.New(0,0);
		else
			MolongTask.AutoGoNpc = npcSid;
			local AvatarList = AvatarCache.GetAndSortAvatarList(MolongTask.filterFunc, MolongTask.sortFunc);
			-- local npc = InteractionManager.GetSingleNpc(npcSid);
			if #AvatarList > 0 then
				return Vector2.New(AvatarList[1].pos_x,AvatarList[1].pos_z);
			else
				local index = math.random(2);
				InteractionManager.SetAutoGoNpc(npcSid);
				return Vector2.New(posList[index][1],posList[index][2]);				
			end
		end
	end

	local DoNext;
	local Check_1;
	local Check_2;
	local Check_3;
	local CreatEnumTable = nil;
	local CompletedToState = nil;
	local HaveCompletedToState = nil;
	local TracingToState = nil;

	MolongTask.ReachNumber = -1;
	MolongTask.TotalNumber = 4;
	MolongTask.ProtectState = {false,false,false,false};
	
	MolongTask.BIsStart = false;
	MolongTask.StoneNumber = 0;
	MolongTask.HeadTitle = nil;
	MolongTask.StateEnum = nil;
	MolongTask.RreshCostDiamond = 50;

	MolongTask.AddListener = function (listener)
		MolongTask.OnEqueueEvent = listener;
		-- MolongTask.UpdateUIInfo()
	end

	MolongTask.Clear = function()
		MolongTask.OnEqueueEvent = nil;
	end
	--状态变化，通知UI更新状态
	function MolongTask.UpdateUIInfo()
		if(MolongTask.OnEqueueEvent ~= nil) then
			MolongTask.OnEqueueEvent(MolongTask.TaskList);
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

	MolongTask.StateEnum = 
	{
		"Free",             --空闲
		"Tracing",			--追踪中
		"Completed",		--完成未提交
		"HaveCompleted"		--已完成
	};

	MolongTask.StateEnum = CreatEnumTable(MolongTask.StateEnum, 0);

	--任务完成未提交通知
	function MolongTask.TaskCompleted(sid)
		local table = tb.TaskTable[sid];


		if table == nil or MolongTask.TaskList == nil or table.task_module_type ~= commonEnum.taskModuleType.QuYu then  --悬赏任务
			return;
		end


		local task = nil;
		for i = 1,#MolongTask.TaskList do
			--if MolongTask.TaskList[i] == nil then
			--	--print("item " .. i .. " is null");
			--end
			if MolongTask.TaskList[i].sid == sid and MolongTask.TaskList[i].state < MolongTask.StateEnum.HaveCompleted then
				task = MolongTask.TaskList[i]
				break;
			end				
		end



		if task ~= nil then
			CompletedToState(task,true);
			MolongTask.UpdateUIInfo();
		end



		if sid == MolongTask.ProtectTaskSid then
			MolongTask.EndProtectTask();
		end

	end

	--完成未提交
	function CompletedToState(task,flag)
		if task.state < MolongTask.StateEnum.Completed and flag == true then 
			task.state = MolongTask.StateEnum.Completed;
		end
	end
	--已完成
	function HaveCompletedToState(task,flag)
		if task.state < MolongTask.StateEnum.HaveCompleted and flag == 1 then
			task.state = MolongTask.StateEnum.HaveCompleted;
		end
	end
	--追踪中
	function TracingToState(task,state)
		if task.state <= MolongTask.StateEnum.Tracing then
			task.state = state;
		end
	end

	--解析任务
	function MolongTask.parseMolongTask(info)
		local task = {};
		task.sid = info[1];
		task.state = info[2];
		return task;
	end

	function MolongTask.UpdateTaskState(msg)
		local commitIndex = msg["commit_index"];
		local traceIndex = msg["trace_index"];
		if traceIndex ~= nil then
			local task = MolongTask.TaskList[traceIndex];
			task.state = MolongTask.StateEnum.Tracing;
			MolongTask.TaskList[traceIndex] = task;
		end
		if commitIndex ~= nil then
			local task = MolongTask.TaskList[commitIndex];
			task.state = MolongTask.StateEnum.HaveCompleted;
			MolongTask.TaskList[commitIndex] = task;
		end
		MolongTask.UpdateUIInfo();
	end

	--请求任务列表回调
	function MolongTask.OnReceiveTaskList(cb, msg)
		SetPort("update_task_state", MolongTask.UpdateTaskState);
	 	local content = msg["molong_task_info"]
	 	if content == nil then 
	 		return 
	 	end;
	 	local oldTime = MolongTask.ProtectStartTime;
	 	MolongTask.RefreshTime = content[1];
	 	local traceIndex = content[2];
	 	local taskListInfo = content[3];
	 	MolongTask.ProtectStartTime = content[4];
	 	
	 	local stone_number = content[5];
	 	client.StoneNumberTable[DataCache.nodeID] = stone_number;

	 	MolongTask.TaskList = {};
	 	for i = 1, #taskListInfo do
	 		local tempInfo = MolongTask.parseMolongTask(taskListInfo[i])
	 		MolongTask.TaskList[i]  = tempInfo;
	 	end
	 	TracingToState(MolongTask.TaskList[traceIndex],MolongTask.StateEnum.Tracing)
	 	if cb ~= nil then
			cb(MolongTask.TaskList);
		end

		if MolongTask.ProtectStartTime ~= oldTime then
			MainUI.FormatTaskList();
		end
		activity.AddReturnNumber();
	end

	--已完成个数
	function MolongTask.GetHaveCompletedNum()
		local num = 0;
		if MolongTask.TaskList ~= nil then
			for k,v in pairs(MolongTask.TaskList) do
				if v.state == MolongTask.StateEnum.HaveCompleted then
					num = num + 1;
				end
			end
			return num
		else
			return 0;
		end
	end
	--请求任务列表
	function MolongTask.GetMolongTasks(callback)
		local msg = {};
		msg.cmd = "get_molong_tasks";
	 	Send(msg, function (msg) MolongTask.OnReceiveTaskList(callback, msg); end);
	end

	function MolongTask.OnCommitTaskCallBack(msg)
		if msg.type == "ok" then
			if msg.trace_index ~= nil then	
				TracingToState(MolongTask.TaskList[msg.trace_index],MolongTask.StateEnum.Tracing)			
			end
			MolongTask.TaskList[msg.commit_index].state = MolongTask.StateEnum.HaveCompleted;
			MolongTask.UpdateUIInfo();
			EventManager.onEvent(Event.ON_EVENT_RED_POINT);
		end
	end

	function MolongTask.ChangeTracingCallBack(msg)
		if msg.type == "ok" then
			local OldTracingTask = MolongTask.TaskList[msg.oldIndex];
			local NewTracingTask = MolongTask.TaskList[msg.newIndex];
			TracingToState(OldTracingTask,MolongTask.StateEnum.Free)
			NewTracingTask.state = MolongTask.StateEnum.Tracing;
			MolongTask.UpdateUIInfo()
			client.task.TaskAutoGo(NewTracingTask.sid);
		end
	end

	function MolongTask.OnTaskBtnClick(index)
		local msg = {};
		local msgType = {};
		local task = MolongTask.TaskList[index]
		if task.state == MolongTask.StateEnum.Free then  --空闲态 -> 追踪
			msg.cmd = "trace_molong_task";
			msg.index = index;
			Send(msg, MolongTask.ChangeTracingCallBack);
		end
	end

	function MolongTask.UpdateProtectTask(taskInfo)
		MolongTask.ProtectState = taskInfo.success_data;
		MolongTask.RefreshProtectTask(true);
	end

	function MolongTask.RefreshProtectTask(autoGo)
		if client.task.getTaskBySid(MolongTask.ProtectTaskSid) == nil then
			return;
		end
		-- local oldReachNumber = MolongTask.ReachNumber;
		local taskTableInfo = tb.TaskTable[MolongTask.ProtectTaskSid];
		local oldNumber = MolongTask.ReachNumber;
		MolongTask.ReachNumber = 0;
		-- MolongTask.BIsStart = false;
		--这里需要有一个变量BIsStart控制护送任务是否已经开始，未开始的时候在安全区注册一个点通知
		--服务端开启任务，给予初始能量石，同时更新客户端表现，并激活能量石采集和下一个目标点
		for i = 1,#MolongTask.ProtectState do
			if MolongTask.ProtectState[i] == "true" then
				MolongTask.ReachNumber = MolongTask.ReachNumber + 1;
			end
		end
		if client.StoneNumberTable[DataCache.nodeID] ~= -1 then
			MolongTask.BIsStart = true;
		end
		if client.task.getTaskBySid(MolongTask.ProtectTaskSid) ~= nil then
			if MolongTask.BIsStart == false and MolongTask.ReachNumber == 0 then
				if DataCache.myInfo.level >= const.ProtectTaskLevel then

					InteractionManager.BindEnterCallBack(MolongTask.StartNpcSid, MolongTask.ShowStartConfirm);
					InteractionManager.BindLeaveCallBack(MolongTask.StartNpcSid, MolongTask.HideStartConfirm);
				end
			elseif MolongTask.ReachNumber < 4 then
				--这里向服务器请求添加能量车
				local msg = {cmd = "check_nengliangche"};				
			 	Send(msg);			
				InteractionManager.RemoveEnterCallBack(MolongTask.StartNpcSid);
				InteractionManager.RemoveLeaveCallBack(MolongTask.StartNpcSid);

				client.task.addResGroup(MolongTask.EnergyStoneSid,MolongTask.ProtectTaskSid);
				InteractionManager.SetTaskState(MolongTask.EnergyStoneSid,TaskNoticeType.Resource);
				--激活对应的触发地点
				local areaInfo = taskTableInfo.successCondition[MolongTask.ReachNumber+1];				
				client.task.TaskUpdatetable[MolongTask.ProtectTaskSid] = true,
				AreaManager.AddListener(areaInfo.v1, MolongTask.ProtectTaskSid, areaInfo.v2[1], 0, areaInfo.v2[2], areaInfo.v3, function()
					local pos = {x = areaInfo.v2[1], y = 0, z = areaInfo.v2[2]};
					client.task.enterArea(pos)
				end);
			end
		end
	end

	MolongTask.ShowStartConfirm = function()
		client.rightUpConfirm.Show("是否进行补给能量任务？", MolongTask.StartProtectTask, MolongTask.CancelProtectTask);
	end

	MolongTask.HideStartConfirm = function()
		client.rightUpConfirm.Hide();
	end

	function MolongTask.StartProtectTask()
		--通知服务端开启护送任务
		local msg = {cmd = "start_protect_task"};
	 	Send(msg, MolongTask.InitProtectTask);
	end

	--服务端返回了初始能量石数量，可以正式开始，能量石的数量显示由场景广播统一处理
	function MolongTask.InitProtectTask(msg)
		client.StoneNumberTable[DataCache.nodeID]  = msg["stone_number"];
		
		if client.StoneNumberTable[DataCache.nodeID] >= 0 then
			MolongTask.BIsStart = true;
			MolongTask.RefreshProtectTask();
			client.task.addResGroup(MolongTask.EnergyStoneSid,MolongTask.ProtectTaskSid);
			InteractionManager.SetTaskState(MolongTask.EnergyStoneSid,TaskNoticeType.Resource);
		end

		--如果当前追踪的不是护送任务，切换到护送任务
		local task = MolongTask.TaskList[4];
		if task.state == MolongTask.StateEnum.Free then
			MolongTask.OnTaskBtnClick(4);
		end
	end

	function MolongTask.CancelProtectTask()
		-- local taskTableInfo = tb.TaskTable[MolongTask.ProtectTaskSid];
		-- local areaInfo = taskTableInfo.successCondition[MolongTask.TotalNumber];
		-- local pos = Vector3.New(areaInfo.v2[1],0,areaInfo.v2[2]);
	end

	--taskComplete之后调用过来
	function MolongTask.EndProtectTask()
		MolongTask.BIsStart = false;
		MolongTask.StoneNumber = -1;
		InteractionManager.SetTaskState(MolongTask.EnergyStoneSid,TaskNoticeType.None);
	end

	function MolongTask.ProtectAutoGo(taskTableInfo)
		local TargetIndex = 0;
		local sceneSid = nil;
		local scenePos = nil;
		local Type = -1;
		if MolongTask.BIsStart == false then
			TargetIndex = 4;
			local npcInfo = tb.MapOnlyNPCTable[MolongTask.StartNpcSid];
			local pos = Vector3.New(npcInfo.pos[1],0,npcInfo.pos[2]);
			sceneSid = npcInfo.scene_id;
			scenePos = Vector2.New(npcInfo.pos[1],npcInfo.pos[2]);
			Type = 1;
		else
			TargetIndex = MolongTask.ReachNumber + 1;
			local areaInfo = taskTableInfo.successCondition[TargetIndex];
			sceneSid = areaInfo.v1;
			scenePos = Vector2.New(areaInfo.v2[1],areaInfo.v2[2]);
			Type = 2;
		end	
		if AvatarCache.me ~= nil then
			if Type == 1 then
				TransmitScroll.ClickLinkPathing(sceneSid, DataCache.fenxian, scenePos);
			else
				StartPathing(scenePos, false);
			end
		end
	end

-----------------------刷新判断 Begin--------------------------
	function MolongTask.IsHaveCompleted()
		for k,v in pairs(MolongTask.TaskList) do
			if v.state == MolongTask.StateEnum.Completed then
				return true
			end
		end
		return false;
	end

	-- function MolongTask.UpdateStoneNumber(title,npcId)
	-- 	local StoneNumber = client.StoneNumberTable[AvatarCache.myInfo.role_uid];
	-- 	if StoneNumber == nil or npcId ~= MolongTask.NengliangcheId then
	-- 		return
	-- 	end
 --        if StoneNumber >= 0 then
 --            title:ShowEnergyStone(true);
 --            title:SetStoneNumber(StoneNumber);
 --        elseif StoneNumber < 0 then 
 --            title:ShowEnergyStone(false);
 --        end
	-- end

	function MolongTask.warningChange(msg)
    	local count = msg["count"];
    	local iteminfo = {};
    	iteminfo.sid = const.item.dragon_heart_Sid;
    	iteminfo.quality = 3;
    	local table = tb.ItemTable[iteminfo.sid]
		local str = nil;
    	if count > 0 then
    		str = string.format("你夺取了[item:%s:item:%d]x%d", table.name, iteminfo.quality,count)
    		client.chat.clientSystemMsg(str, iteminfo, nil, "system", false)
    	else
    		str = string.format("你失去了[item:%s:item:%d]x%d", table.name, iteminfo.quality,-count)
    		client.chat.clientSystemMsg(str, iteminfo, nil, "system", false)
    	end
    end

    function MolongTask.createNengliangche(msg)
    	local id = msg["id"];
    	MolongTask.NengliangcheId = id;
    end

    function MolongTask.getNengliangche()
    	return MolongTask.NengliangcheId;
    end

    function MolongTask.registerProtectStart()
    	if MolongTask.TaskList ~= nil then
			local ProtectTask = MolongTask.TaskList[4];
	    	if ProtectTask.state == MolongTask.StateEnum.Free and DataCache.myInfo.level >= const.ProtectTaskLevel then
				InteractionManager.BindEnterCallBack(MolongTask.StartNpcSid, MolongTask.ShowStartConfirm);
				InteractionManager.BindLeaveCallBack(MolongTask.StartNpcSid, MolongTask.HideStartConfirm);
			end
		end
    end

    function MolongTask.GetProtectStr()
    	local str = nil; 
    	if MolongTask.BIsStart == false then
    		str = "领取能量车后，在30分钟内给魔龙岛中的能量塔充能";
    	else
    		local passTime = TimerManager.GetServerNowSecond() - MolongTask.ProtectStartTime;
    		local leftTime = MolongTask.ProtectTotalTime - passTime;
    		if leftTime < 0 then
    			leftTime = 0;
    		end
    		if MolongTask.ProtectStartTime ~= 0 and leftTime == 0 then
		    	local msg = {cmd = "protect_task_timeout"};
			 	Send(msg);
    		end
    		local minute = math.floor(leftTime/60);
    		if minute < 10 then
    			minute = "0"..minute;
    		end
    		local second = leftTime - 60 * minute;
    		if second < 10 then
    			second = "0"..second;
    		end
    		local timeStr = "<color=#fd8000>["..minute..":"..second.."]</color>";
    		str = "采集能量石，前往各个能量塔充能"..timeStr;
    	end
    	return str;
    end

    function MolongTask.startProtect(msg)
    	local startTime = msg["time"];
    	MolongTask.BIsStart = true;
    	MolongTask.ProtectStartTime = startTime;
    	MainUI.FormatTaskList();
    end

    SetPort("start_protect",MolongTask.startProtect);
	SetPort("heart_change",MolongTask.warningChange);
	SetPort("create_nengliangche",MolongTask.createNengliangche);

	return MolongTask;
end

--记录添加的角色能量石的数量，在GameObject创建完后的回调中来读取
client.StoneNumberTable = {};
client.MolongTask = CreateMolongTaskCtrl()