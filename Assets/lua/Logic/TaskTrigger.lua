--任务触发事件管理模块
--

CurrentIndex = {};
EventList = {};
DoneList = {};
TaskTrigger = {};

TaskTrigger.HaveCertainEvent = function(taskSid,taskType)
	if tb.TaskTrigger[taskSid] ~= nil and tb.TaskTrigger[taskSid].trigger.type == taskType then
		return true;
	else
		return false;
	end
end

--重置触发器的状态，目前主要是从位面退出时用，以便可以重新触发进入位面
TaskTrigger.ResetState = function(taskSid)
	TaskTrigger.TriggerEvent(taskSid,false);
end

--触发了某个配置事件，按固定顺序执行下去，参数bNext决定了是否马上执行事件
TaskTrigger.TriggerEvent = function(taskSid,bNext)
	local triggerInfo = tb.TaskTrigger[taskSid];
	if triggerInfo == nil then
		return;
	end

	local StartInfo = tb.TaskTrigger[taskSid].trigger;
	--进入区域的起始注册
	if StartInfo.type == "enterArea" then
		AreaManager.AddListener(StartInfo.mapSid, taskSid, StartInfo.pos[1], StartInfo.pos[2], StartInfo.pos[3], StartInfo.radius, function()
			TaskTrigger.DoNextEvent(taskSid);
		end);
	end

	EventList[taskSid] = triggerInfo.event;
	DoneList[taskSid] = triggerInfo.done;
	CurrentIndex[taskSid] = 1;
	if bNext then
		TaskTrigger.DoNextEvent(taskSid);
	end
end

TaskTrigger.HaveEventNow = function(taskSid)
	if EventList[taskSid] ~= nil or DoneList[taskSid] ~= nil then
		return true;
	else
		return false;
	end
end

--顺序执行下一步
TaskTrigger.DoNextEvent = function(taskSid)
	--说明触发事件部分已经全部完成
	if EventList[taskSid][CurrentIndex[taskSid]] == nil then
		CurrentIndex[taskSid] = 1;
		TaskTrigger.DoDoneEvent(taskSid);
		return;
	end

	local CurEvent = EventList[taskSid][CurrentIndex[taskSid]];	
	CurrentIndex[taskSid] = CurrentIndex[taskSid] + 1;
	if CurEvent.type == "talkScreen" then
		PanelManager:CreateFullScreenPanel('TaskTalk',function() end,
			{TaskId = CurEvent.sid, realId = taskSid});
	elseif CurEvent.type == "blackScreen" then
		PanelManager:CreateFullScreenPanel('BlackScreen',function() end,
			{sid = CurEvent.sid, realId = taskSid});
	end
end

--执行下一个结算事件
TaskTrigger.DoDoneEvent = function(taskSid)
	--全部执行完毕
	if DoneList[taskSid][CurrentIndex[taskSid]] == nil then
		CurrentIndex[taskSid] = nil;
		EventList[taskSid] = nil;
		DoneList[taskSid] = nil;
		return;
	end

	local DoneEvent = DoneList[taskSid][CurrentIndex[taskSid]];
	CurrentIndex[taskSid] = CurrentIndex[taskSid] + 1;
	if DoneEvent.type == "completeMsg" then		
		TaskTrigger.TalkCompleteMsg(DoneEvent.npcSid,DoneEvent.taskSid);
	elseif DoneEvent.type == "enterAreaMsg" then
		TaskTrigger.SendEnterArea(DoneEvent.pos,taskSid);
	elseif DoneEvent.type == "showLoading" then
		SceneLoader.GetInstance():ShowLoadingUI();
		TaskTrigger.DoDoneEvent(taskSid);
	elseif DoneEvent.type == "enterXiangwei" then
		TaskTrigger.SendEnterXiangwei(taskSid);
	end
end

TaskTrigger.TalkCompleteMsg = function(npcSid,taskSid)
	--对话完成，发送对话完成消息到服务器
	local msg = {cmd = "client_event", type = "talk_npc", npc = npcSid, tasksid = taskSid};
	Send(msg,function (msgTable)
		client.task.TalkOverTable[taskSid] = true;
		TaskTrigger.DoDoneEvent(taskSid);
	end);
end

TaskTrigger.SendEnterArea = function(position,taskSid)
	local msg = {cmd = "client_event", type = "reach_area", pos = {x = position[1], y = position[2], z = position[3]}};
	Send(msg, function (msgTable)
		TaskTrigger.DoDoneEvent(taskSid);
	end);	
end

TaskTrigger.SendEnterXiangwei = function(taskSid)
	AutoPathfindingManager.Cancel();
	Util.SetRadialBlur(true)
	ui.closeMsgBox();
	if UIManager.GetInstance():FindUI("UIAreaMap") ~= nil then
		UIManager.GetInstance():CallLuaMethod('UIAreaMap.closeSelf')
	end

	XiangWeiFuben.enter(taskSid)
end
