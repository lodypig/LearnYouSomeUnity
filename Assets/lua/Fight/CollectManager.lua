function CreateCollectManager()
	local t = {};
	t.current = nil;
	t.wait_queue = {};
	
	-- 等待队列包含
	t.WaitQueueContains = function (id)
		local que = t.wait_queue;
		for i = 1, #que do
			if que[i] == id then
				return true;
			end
		end
		return false;
	end;

	-- 添加到等待队列
	t.AddToWaitQueue = function (id)
		local que = t.wait_queue;
		que[#que + 1] = id;
	end;

	-- 从等待队列删除
	t.RemoveFromWaitQueue = function (id)
		local index = 0;
		local que = t.wait_queue;
		for i = 1, #que do
			if que[i] == id then
				for k = index, #que - 1 do
					que[k] = que[k + 1];
				end
				que[#que] = nil;
				break;
			end
		end
	end;

	-- 清空等待队列
	t.ClearWaitQueue = function ()
		t.current = nil;
		local que = t.wait_queue;
		for i = 1, #que do
			que[i] = nil;
		end
	end;

	-- 进入范围
	t.OnEnter = function (ds)
		local id = ds.id;
		-- 正在采集中
		if t.current ~= nil and t.current == id then
			return;
		end
		-- 还没开始采集，但是已经在采集队列中了
		if t.WaitQueueContains(id) then
			return;
		end
		-- 添加到采集队列
		t.AddToWaitQueue(id);
		t.OnEnterCollectScope(ds);
	end;

	-- 退出范围
	t.OnLeave = function (ds)
		local id = ds.id;
		t.RemoveFromWaitQueue(id);
		if t.current ~= nil and t.current == id then
			t.current = nil;
			t.OnStopCollect(ds);
		else
			t.OnLeaveCollectScope(ds);
		end
	end;

	t.coolDown = 2;
	t.lastBreakTime = 0;
	t.CheckCoolDown = function()
		local now = TimerManager.GetUnityTime();
		-- print("检查冷却=========================")
		-- print(now..","..t.lastBreakTime)
		if now - t.lastBreakTime >= t.coolDown then
			return true;
		else
			return false;
		end
	end

	--开始采集的时间
	t.start_time = 0;
	-- 响应时间
	t.respond_time = 3;
	-- 完成时间
	t.finish_time = 10;

	-- 停留在范围中
	t.OnStay = function (ds)

		local sid = ds.sid;
		local npcData = tb.NPCTable[sid];
		local respond_time = npcData.respond_time * 0.001;
		local curr_time = TimerManager.GetUnityTime();
		local enter_scope_time = ds.enter_scope_time;
		local elapsed_time = curr_time - enter_scope_time;

		if t.current == nil then
			-- print("检查触发=========================")
			-- print(elapsed_time..","..respond_time)
			if elapsed_time < respond_time then
				return;
			end
			if t.CheckCoolDown() == false then
				return;
			end
			local id = ds.id;
			t.current = id;
			t.RemoveFromWaitQueue(id);
			t.finish_time = npcData.collect_time * 0.001;
			t.start_time = curr_time;
			t.OnStartCollect(ds);
		else
			local current = t.current;
			if current ~= ds.id then
				return;
			end

			elapsed_time = curr_time - t.start_time;
			if elapsed_time >= t.finish_time then
				t.current = nil;
				local class = Fight.GetClass(ds);
				class.ForseLeaveScope(ds); 
				t.OnContinueCollect(ds);
				t.OnFinishCollect(ds);
			else
				t.OnContinueCollect(ds);
			end			
		end
	end;

	-- 进入采集范围
	t.OnEnterCollectScope = function (ds)
	end;

	-- 退出采集范围
	t.OnLeaveCollectScope = function (ds)
	end

	-- 开始采集
	t.OnStartCollect = function (ds)
		local npcId = ds.id;
		local npcSid = ds.sid;
		local npcTableInfo = tb.NPCTable[npcSid];
		local taskSid = client.task.getResTaskID(npcSid);
		-- npcTableInfo.collect_time/1000
		local msg = {cmd = "start_collect", npc = npcId, taskSid = taskSid};
		Send(msg, function (msgTable)
			local result = msgTable["result"];
			if result == "ok" then
				local collect_time = t.finish_time;
				t.start_time = TimerManager.GetUnityTime();
				client.collectProcess.StartCollect(npcSid, npcId, collect_time, npcTableInfo.collect_msg, function ()
					client.task.finishCollect(npcId, taskSid);
				end);
			elseif result == "target_in_use" then 
				ui.showMsg("采集目标已被其他玩家锁住");
			else
				ui.showMsg("采集失败: ".. result);
			end
		end);
	end;

	-- 完成采集
	t.OnFinishCollect = function (ds)
		-- print("t.OnFinishCollect")
		t.lastBreakTime = TimerManager.GetUnityTime();
		local npcId = ds.id;
		local npcSid = ds.sid;
		local taskSid = client.task.getResTaskID(npcSid);
		local msg = {cmd = "finish_collect", npc = npcId, taskSid = taskSid};
		Send(msg, function (msgTable)			
			client.collectProcess.StopCollect();
		end);
	end;

	-- 停止采集
	t.OnStopCollect = function (ds)
		-- print("t.OnStopCollect")
		t.lastBreakTime = TimerManager.GetUnityTime();
		local npcId = ds.id;
		local npcSid = ds.sid;
		local taskSid = client.task.getResTaskID(npcSid);
		local msg = {cmd = "stop_collect", npc = npcId, taskSid = taskSid};
		Send(msg, function (msgTable)
			local result = msgTable["result"];
			if result == "ok" then
				t.lastBreakTime = TimerManager.GetUnityTime();
				client.collectProcess.BreakCollect();
			end
		end);
	end;

	-- 持续采集中
	t.OnContinueCollect = function (ds)
		local curr_time = TimerManager.GetUnityTime();
		local fProgress = (curr_time - t.start_time) / t.finish_time;
		if fProgress > 1 then
			fProgress = 1;
		end
		client.collectProcess.ManualUpdate(fProgress);
	end;

	-- 对象销毁
	t.OnDestroy = function (ds)
		local scope_detect_enable = ds.scope_detect_enable;
		if scope_detect_enable then 
			t.OnLeave(ds);
		end
	end;

	return t;
end

CollectManager = CreateCollectManager();