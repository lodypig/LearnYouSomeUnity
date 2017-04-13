function MainUIPlotlineFubenView (param)
	local MainUIPlotlineFuben = {};
	local this = nil;

	local Panel = nil;
	local btnExit = nil;
	local taskItem = nil;
    local textTime = nil;
    local fubenTask = nil;

    local passTime = 300;
    local CurExitPos = nil;

	function MainUIPlotlineFuben.Start ()
		this = MainUIPlotlineFuben.this;
		Panel = this:GO('Panel');
        btnExit = this:GO('Panel.btnExit');
        CurExitPos = btnExit.transform.localPosition;
        textTime = this:GO('Panel.Time');
        textTime:Hide();
        taskItem = this:GO('Panel.task');
		taskItem:Hide();

        btnExit:BindButtonClick(MainUIPlotlineFuben.ExitFuben);
        taskItem:BindButtonClick(MainUIPlotlineFuben.ClickFubenTask);

        -- EventManager.bind(this.gameObject,Event.ON_FUBEN_TASK_CHANGE,MainUIPlotlineFuben.showFubenNextTask);
        EventManager.bind(this.gameObject,Event.ON_FUBEN_TASK_COMPLETED,MainUIPlotlineFuben.showFubenTaskCompleted);
        EventManager.bind(this.gameObject,Event.ON_FUBEN_TASK_COMPLETED_EFFECT,MainUIPlotlineFuben.onFubenPlayEffect);
        
        EventManager.bind(this.gameObject,Event.ON_LEAVE_FUBEN,MainUIPlotlineFuben.closeSelf);

        EventManager.bind(this.gameObject,Event.ON_SKILL_HIDE, MainUIPlotlineFuben.ExitHide);
        EventManager.bind(this.gameObject,Event.ON_SKILL_SHOW, MainUIPlotlineFuben.ExitShow);

        EventManager.bind(this.gameObject,Event.ON_MAINUI_HIDE, MainUIPlotlineFuben.Hide);
        EventManager.bind(this.gameObject,Event.ON_MAINUI_SHOW, MainUIPlotlineFuben.Show);

		EventManager.bind(this.gameObject, Event.ON_TIME_SECOND_CHANGE, MainUIPlotlineFuben.onRefresh1Sec);

        -- MainUIPlotlineFuben.showFubenNextTask(param.firstGroup);

        -- 此设置没有效果，因为事件发出时才完成角色创建
        -- FubenManager.OnNotify(FubenHandlerType.OnAutoFight, {});

        EventManager.onEvent(Event.ON_CHANGE_SCENENAME, {"水晶矿洞",""});
        if const.OpenMenuFlag then
            btnExit.transform.localPosition = Vector3.New(CurExitPos.x + 600, CurExitPos.y, CurExitPos.z);
        end
	end

    function MainUIPlotlineFuben.closeSelf()
        destroy(this.gameObject);
	end

    function MainUIPlotlineFuben.Hide()
        this.gameObject:SetActive(false);
    end

    function MainUIPlotlineFuben.Show()
        this.gameObject:SetActive(true);
    end

    function MainUIPlotlineFuben.ExitHide()
        btnExit.transform:DOLocalMoveX(CurExitPos.x + 600, 0.5, false);
    end

    function MainUIPlotlineFuben.ExitShow()
        if not const.OpenMenuFlag then
            btnExit.transform:DOLocalMoveX(CurExitPos.x, 0.3, false);
        end
    end

    function MainUIPlotlineFuben.RefreshTime()
        textTime:Show();
    	local usedTime = math.round((TimerManager.GetServerNowMillSecond() - param.startTime)/1000);
    	local time = client.tools.formatTime(math.max(passTime - usedTime, 0));
	    textTime.text = string.format("%02s:%02s", time.minute, time.second);
    end

    function MainUIPlotlineFuben.ExitFuben( )
        local tip = "是否离开副本？";
        ui.showMsgBox(nil, tip, PlotlineFuben.LeaveFuben, nil);
    end

    function MainUIPlotlineFuben.ClickFubenTask()
        FubenManager.OnNotify(FubenHandlerType.OnAutoFight, {});
    end

    -- 设置下一个目标
    function MainUIPlotlineFuben.showFubenNextTask(groupId)
		taskItem:Show();
        -- local fuben_id = client.fuben.curFubenId;
        local task_data = MainUIPlotlineFuben.getFubenTaskData(10001, groupId);
        --local task_data = tb.fuben[10001];
 
        if task_data ~= nil then
            taskItem:GO('content').text = task_data.desc;
        end

        -- if fuben_data ~= nil then
        --     local tip = string.format("%s %s",fuben_data.name, const.fubenDifficulty[fuben_data.difficulty]);
        --     taskItem:GO('title').text = tip
        -- end

    end

    function MainUIPlotlineFuben.getFubenTaskData(flow_id, groupId)
        if groupId == 0 then
            return nil;
        end
        local task_data_list = tb.fubenflow[flow_id];
        local task_data = task_data_list[groupId];
        return task_data;
    end

    function MainUIPlotlineFuben.showFubenTaskCompleted(groupId)
        MainUIPlotlineFuben.addCompletedFubenTask(groupId);
    end

    function MainUIPlotlineFuben.addCompletedFubenTask(groupId)
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
    function MainUIPlotlineFuben.getEffectCount()
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


    function MainUIPlotlineFuben.onFubenPlayEffect(count)
        local effectCount = MainUIPlotlineFuben.getEffectCount();
        if effectCount > count then
            return;
        end
        MainUIPlotlineFuben.playEffectForCompletedFubenTask();
    end

    function MainUIPlotlineFuben.playEffectForCompletedFubenTask()

        if fubenTask == nil then
            return;
        end

        local groupId = fubenTask.groupId;
        MainUIPlotlineFuben.removeTopFubenTask();
        taskItem:GO('content').gameObject:SetActive(false);



        --fubenTaskContent:StopAllUIEffects();
        
        taskItem:GO('effectObj'):PlayUIEffect(this.gameObject, "renwuwancheng", 1.5, function(effect)
            local effectController = effect:GetComponent("EffectController");
            effectController:BindDestroyFunction(function()


                --FubenManager.SetInt("groupId", groupId + 1);
                local nextGroupId = groupId + 1;
                MainUIPlotlineFuben.refreshFubenTask(nextGroupId);
                taskItem:GO('content').gameObject:SetActive(true);

                if fubenTask ~= nil then
                    this:Delay(0.3, function ()
                        MainUIPlotlineFuben.playEffectForCompletedFubenTask();
                    end);
                end
            end)                
        end, true);
    end

    function MainUIPlotlineFuben.removeTopFubenTask()
        if fubenTask == nil then
            return;
        end
        fubenTask = fubenTask.nextTask;
    end

    function MainUIPlotlineFuben.refreshFubenTask(groupId)
        local task_data = MainUIPlotlineFuben.getFubenTaskData(10001, groupId);
        if task_data == nil then
            return;
        end
        local fubenTaskContent = taskItem:GO('content');
        fubenTaskContent.text = task_data.desc;
    end

    function MainUIPlotlineFuben.onRefresh1Sec()
    	MainUIPlotlineFuben.RefreshTime()
    end

	return MainUIPlotlineFuben;
end
