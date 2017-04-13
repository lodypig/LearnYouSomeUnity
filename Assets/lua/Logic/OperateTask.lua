--定义操作类任务对应的具体操作

OperateTaskTable = {}

local SendOperateResult = function(taskSid)
	local msg = {cmd = "client_event", type = "client_operate", tasksid = taskSid};
	Send(msg);		
end

local CheckOperateTask = function(key)
	if OperateTaskTable[key] ~= nil then
		for i=1,#OperateTaskTable[key] do
			local taskSid = OperateTaskTable[key][i];
			if client.task.getTaskBySid(taskSid) ~= nil then
				SendOperateResult(taskSid);
			end			
		end
	end
end

--要触发的按钮绑定点击事件需要使用bindGuideButtionClick来绑定点击事件，指定触发的key
--如：bindGuideButtionClick("MainUI_Bag", MainUI.openBag, this:GO('Bag'));
bindGuideButtionClick = function (key, func, wrapper)
	wrapper:BindButtonClick(function () 
		-- trigger key
		CheckOperateTask(key);
		func();	
	end);
end

--这边配置某界面按钮的点击对应的操作任务编号
--Key预计使用UIPrefab的名字和按钮名字用_拼接而成，也可灵活调整，只需和绑定时的key保持一致
OperateTaskTable["MainUI_Bag"] = {10091};