function MainUIFubenView (param)
	local MainUIFuben = {};
	local this = nil;

	local Panel = nil;
	local btnExit = nil;
	local taskItem = nil;

    local fubenTask = nil;
    local textTime = nil;
    local passTime = 0;

	function MainUIFuben.Start ()
		this = MainUIFuben.this;
		Panel = this:GO('Panel');
		btnExit = this:GO('Panel.btnExit');
		taskItem = this:GO('Panel.task');
        taskItem:Hide();
        
        textTime = this:GO('Panel.Time');
        textTime:Hide();

        btnExit:BindButtonClick(MainUIFuben.ExitFuben);
        taskItem:BindButtonClick(MainUIFuben.ClickFubenTask);

        EventManager.bind(this.gameObject,Event.ON_FUBEN_TASK_CHANGE,MainUIFuben.showFubenNextTask);
        EventManager.bind(this.gameObject,Event.ON_FUBEN_TASK_COMPLETED,MainUIFuben.showFubenTaskCompleted);
        EventManager.bind(this.gameObject,Event.ON_FUBEN_TASK_COMPLETED_EFFECT,MainUIFuben.onFubenPlayEffect);
        EventManager.bind(this.gameObject,Event.ON_LEAVE_FUBEN,MainUIFuben.closeSelf);

        EventManager.bind(this.gameObject,Event.ON_MAINUI_HIDE, MainUIFuben.Hide);
        EventManager.bind(this.gameObject,Event.ON_MAINUI_SHOW, MainUIFuben.Show);
        EventManager.bind(this.gameObject, Event.ON_TIME_SECOND_CHANGE, MainUIFuben.onRefresh1Sec);

        local fubenCfg = tb.fuben[param.fubenSid];
        passTime = fubenCfg.passtime;
        MainUIFuben.showFubenNextTask(param.firstGroup)
        -- FubenManager.OnNotify(FubenHandlerType.OnAutoFight, {});

        EventManager.onEvent(Event.ON_CHANGE_SCENENAME, {fubenCfg.name,""});

        -- print("MainUi Fuben")
        --MainUi左侧Team与Task的处理
        MainUI.SetIsSelectTask(true)
        MainUI.ClickTeamBtn()
	end

    function MainUIFuben.closeSelf()
        destroy(this.gameObject);
	end

    function MainUIFuben.Hide()
        this.gameObject:SetActive(false);
    end

    function MainUIFuben.Show()
        this.gameObject:SetActive(true);
    end

    function MainUIFuben.ExitFuben( )
        local tip = "中途退出将无法获得奖励，确定离开吗？"

        ui.showMsgBox(nil, tip, function ()
                    client.fuben.q_leave_fuben();
                end, nil);
    end

    function MainUIFuben.ClickFubenTask()
        FubenManager.OnNotify(FubenHandlerType.OnAutoFight, {});
    end

    -- 设置下一个目标
    function MainUIFuben.showFubenNextTask(groupId)
        taskItem:Show();
        
        local fuben_id = client.fuben.curFubenId;
        local task_data = MainUIFuben.getFubenTaskData(fuben_id, groupId);
        local fuben_data = tb.fuben[fuben_id];
 
        if task_data ~= nil then
            taskItem:GO('content').text = task_data.desc;
        end

        if fuben_data ~= nil then
            taskItem:GO('title').text = fuben_data.name;
        end

    end

    function MainUIFuben.getFubenTaskData(fuben_id, groupId)
        if groupId == 0 then
            return nil;
        end
        local fuben_data = tb.fuben[fuben_id];
        local flow_id = fuben_data.flowcfg;
        local task_data_list = tb.fubenflow[flow_id];
        local task_data = task_data_list[groupId];
        return task_data;
    end

    function MainUIFuben.showFubenTaskCompleted(groupId)
        MainUIFuben.addCompletedFubenTask(groupId);
    end

    function MainUIFuben.addCompletedFubenTask(groupId)
        local newTask = {};
        newTask.groupId = groupId;
        newTask.nextTask = nil;
        if fubenTask == nil then
            fubenTask = newTask;
        else
            local task = fubenTask;
            while task.nextTask ~= nil do
                task = task.nextTask;
            end
            task.nextTask = newTask;
        end
    end

    -- 获取特效数量
    function MainUIFuben.getEffectCount()
        if fubenTask == nil then
            return 0;
        end
        local count = 0;
        local task = fubenTask;
        while task ~= nil do
            count = count + 1;
            task = task.nextTask;
        end
        return count;
    end


    function MainUIFuben.onFubenPlayEffect(count)
        local effectCount = MainUIFuben.getEffectCount();
        if effectCount > count then
            return;
        end
        MainUIFuben.playEffectForCompletedFubenTask();
    end

    function MainUIFuben.playEffectForCompletedFubenTask()

        if fubenTask == nil then
            return;
        end

        local groupId = fubenTask.groupId;
        MainUIFuben.removeTopFubenTask();
        taskItem:GO('content').gameObject:SetActive(false);
        
        taskItem:GO('effectObj'):PlayUIEffect(this.gameObject, "renwuwancheng", 1.5, function(effect)
            local effectController = effect:GetComponent("EffectController");
            effectController:BindDestroyFunction(function()


                --FubenManager.SetInt("groupId", groupId + 1);
                local nextGroupId = groupId + 1;
                MainUIFuben.refreshFubenTask(nextGroupId);
                taskItem:GO('content').gameObject:SetActive(true);

                if fubenTask ~= nil then
                    this:Delay(0.3, function ()
                        MainUIFuben.playEffectForCompletedFubenTask();
                    end);
                end
            end)                
        end, true);
    end

    function MainUIFuben.removeTopFubenTask()
        if fubenTask == nil then
            return;
        end
        fubenTask = fubenTask.nextTask;
    end

    function MainUIFuben.refreshFubenTask(groupId)
        local fuben_id = client.fuben.curFubenId;
        local task_data = MainUIFuben.getFubenTaskData(fuben_id, groupId);
        if task_data == nil then
            return;
        end
        local fubenTaskContent = taskItem:GO('content');
        fubenTaskContent.text = task_data.desc;
    end

    function MainUIFuben.RefreshTime()
        textTime:Show();
        local usedTime = math.round((TimerManager.GetServerNowMillSecond() - param.startTime)/1000);
        local time = client.tools.formatTime(math.max(passTime - usedTime, 0));
        textTime.text = string.format("%02s:%02s", time.minute, time.second);
    end

    function MainUIFuben.onRefresh1Sec()
        MainUIFuben.RefreshTime()
    end

	return MainUIFuben;
end
