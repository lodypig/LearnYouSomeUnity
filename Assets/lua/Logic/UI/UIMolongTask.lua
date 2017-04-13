function UIMolongTaskView (param)
	local UIMolongTask = {};
	local this = nil;

	local Close = nil;
	local TaskInfo = nil;
	local taskDes = {
		"在魔龙岛中破坏<color=#58d421>10个龙蛋</color>获得经验奖励",
		"在魔龙岛中采集<color=#58d421>10份金矿</color>获得金币奖励",
		"在魔龙岛中采集<color=#58d421>10份钻石矿</color>获得钻石奖励",
		"在安全区领取能量车，沿途<color=#58d421>收集能量石</color>，补充能量塔"
	}

	-- 1 空闲 2 追踪 3 完成 4 已完成
	local BtnStateCfg = 
	{
		{ "an_zhuizong",""},
		{ "an_lanse_1","<color=#4caff0>追踪中…</color>"},
		{ "an_lingjiang",""},
		{ "an_lanse_1","<color=#e4e4e4>已完成！</color>"},
	}

	function UIMolongTask.Start ()
		this = UIMolongTask.this;
		Close = this:GO('CommonDlg3._Close');
		TaskInfo = this:GO('Panel._TaskInfo');
		--param.taskList
		Close:BindButtonClick(UIMolongTask.Close);
		UIMolongTask.FormatTaskContent();
		client.MolongTask.AddListener(UIMolongTask.FormatTaskContent);
	end

	function UIMolongTask.ProcessBtnState(Btn,taskState,index)
		local Text = Btn:GO('Text');
		local StateEnum = client.MolongTask.StateEnum;
		local stateCfg = BtnStateCfg[taskState];
		--空闲状态，显示追踪按钮
		if taskState == StateEnum.Free then
			if index == 4 and DataCache.myInfo.level < const.ProtectTaskLevel then
				Text.text =  "45级开放";
				Btn.buttonImageEnable = false;				
			else
				Text.text =  stateCfg[2];
				Btn.buttonImageEnable = true;
			end
		elseif taskState == StateEnum.Tracing then
			Text.text =  stateCfg[2];
			Btn.buttonImageEnable = false
		elseif taskState == StateEnum.Completed or taskState == StateEnum.HaveCompleted then
			Text.text =  stateCfg[2];
			Btn.buttonImageEnable = false
		end
	end

	function UIMolongTask.FormatTaskContent()
		local taskList = client.MolongTask.TaskList;
	 	for i = 1, #taskList do
	 		local taskTableInfo = tb.TaskTable[taskList[i].sid];	
	 		if taskTableInfo ~= nil then
	 			local taskItem = TaskInfo:GO("Task"..i);
	 			local title = taskItem:GO("TaskName");
	 			local level = taskItem:GO("LevelPart.Number");
				local Content = taskItem:GO("Content.Text");
				local Btn = taskItem:GO("Btn");
				Btn:SetUserData("index", i);
				Btn:BindButtonClick(UIMolongTask.OnTaskBtnClick);
				UIMolongTask.ProcessBtnState(Btn,taskList[i].state,i);
				title.text = taskTableInfo.name;
				level.text = taskTableInfo.level_min;
				Content.text = taskDes[i];
		 	end
	 	end		
	end

	function UIMolongTask.OnTaskBtnClick(go)
		local UIWrapper = go:GetComponent('UIWrapper')
		if UIWrapper.buttonEnable == false then
			return
		end
		local index = UIWrapper:GetUserData("index");
		client.MolongTask.OnTaskBtnClick(index);
		
		-- 寻路到目标
		UIMolongTask.Close();
		UIManager.GetInstance():CloseUI("UIActivity");
		UIManager.GetInstance():CallLuaMethod('UIMenu.closeSelf');
		-- local taskList = client.MolongTask.TaskList;
		-- local taskInfo = taskList[index];
		-- client.task.TaskAutoGo(taskInfo.sid);

		-- local task = client.MolongTask.TaskList[index]
		-- if task.state == client.MolongTask.StateEnum.Free then
		-- 	UIMolongTask.Close();
		-- end
	end

	function UIMolongTask.Close()
		-- if DelayRefreshID ~= nil then
		-- 	this:CancelDelay(DelayRefreshID)
		-- end
		client.MolongTask.Clear();
		destroy(this.gameObject);
	end

	return UIMolongTask;
end

function ui.ShowMolongTask()
	client.MolongTask.GetMolongTasks(function (taskList)
		PanelManager:CreatePanel('UIMolongTask',UIExtendType.BLACKMASK, {taskList = taskList});
	end);
end