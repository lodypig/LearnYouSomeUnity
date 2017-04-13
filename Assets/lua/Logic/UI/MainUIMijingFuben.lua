function MainUIMijingFubenView (param)
	local MainUIMijingFuben = {};
	local this = nil;

	local Panel = nil;
	local timeDes = nil;
	local btnExit = nil;
    local btnExitPos = nil;
	local taskItem = nil;
    local timeGonggao = nil;

    local leftsecond = 0;
    local maxNpcCount = 0;
    local leftNpcCount = 0;
    local daojishi = 10;

    MainUIMijingFuben.ExitMijing = function (go)
        ui.showMsgBox("提示", "是否要退出宝库？", MainUIMijingFuben.DoExitMijing, nil);
	end

    MainUIMijingFuben.DoExitMijing = function ()
        local msg = {cmd = "leave_mijing"};
        Send(msg, function(msg) 
            MainUIMijingFuben.closeSelf()
        end); 
    end

	function MainUIMijingFuben.Start ()
		this = MainUIMijingFuben.this;
		Panel = this:GO('_Panel');
        timeDes = this:GO('_Panel._timeDes');
		timeGonggao = this:GO('_Panel._gonggao');
        timeDes:Hide();
        timeGonggao:Hide();
		btnExit = this:GO('_Panel._btnExit');
        btnExitPos = btnExit.transform.localPosition;
		taskItem = this:GO('_Panel._taskItem');
        btnExit:BindButtonClick(MainUIMijingFuben.ExitMijing);


        EventManager.bind(this.gameObject,Event.ON_TIME_SECOND_CHANGE,MainUIMijingFuben.RefreshTimeInfo);
        EventManager.bind(this.gameObject,Event.ON_MIJING_OVER,MainUIMijingFuben.handleOver);
        EventManager.bind(this.gameObject,Event.ON_MIJING_NPC_DEAD,MainUIMijingFuben.handleNpcDead);
        EventManager.bind(this.gameObject,Event.ON_SKILL_HIDE, MainUIMijingFuben.ExitHide);
        EventManager.bind(this.gameObject,Event.ON_SKILL_SHOW, MainUIMijingFuben.ExitShow);

        EventManager.bind(this.gameObject,Event.ON_MAINUI_HIDE, MainUIMijingFuben.Hide);
        EventManager.bind(this.gameObject,Event.ON_MAINUI_SHOW, MainUIMijingFuben.Show);

        -- FubenManager.OnNotify(FubenHandlerType.OnAutoFight, {});

        MainUIMijingFuben.initInfo();
	end

    function MainUIMijingFuben.initInfo ()

        local MJType = param.type;
        local overTime = param.time;
        if "normal" == MJType then
            EventManager.onEvent(Event.ON_CHANGE_SCENENAME, {"宝库",""});
        else
            EventManager.onEvent(Event.ON_CHANGE_SCENENAME, {"高级宝库",""});
        end
        maxNpcCount = param.maxCount;
        leftNpcCount = param.npcCount;
        leftsecond = math.floor((overTime - TimerManager.GetServerNowMillSecond())/1000) + 1;
        MainUIMijingFuben.showTaskItemInfo();
    end

    function MainUIMijingFuben.showTaskItemInfo()
        local conStr;
        if 0 == leftNpcCount then
            conStr = "任务已完成，可退出副本";
        else
            conStr = string.format("击杀宝库中的怪物(%d/%d)", maxNpcCount - leftNpcCount, maxNpcCount);
        end
        taskItem:GO('content').text = conStr;
    end

    function MainUIMijingFuben.RefreshTimeInfo()
        if 0 == leftsecond then 
            return;
        end

        --处理怪物死亡完的倒计时提示
        if 0 == leftNpcCount then
            daojishi = daojishi - 1;
            if daojishi > 0 then
                timeGonggao:GO('time').text = daojishi;
                timeGonggao:Show();
            else
                timeGonggao:Hide();
                MainUIMijingFuben.DoExitMijing();
            end
            return;
        end
        timeDes:Show();

        leftsecond = leftsecond - 1;
        local leftMin = math.floor(leftsecond / 60);
        local tLeftsecond = leftsecond - leftMin * 60;
        local conStr = string.format("%02d:%02d", leftMin, tLeftsecond);
        timeDes.text = conStr;
    end

    function MainUIMijingFuben.handleNpcDead()
        leftNpcCount = leftNpcCount - 1;
        if 0 == leftNpcCount then
            --todo 特效
            MainUIMijingFuben.playEffect();
            timeDes:Hide();
        end
        MainUIMijingFuben.showTaskItemInfo();
    end

    function MainUIMijingFuben.closeSelf()
        destroy(this.gameObject);
	end

    function MainUIMijingFuben.handleOver()
        ui.closeMsgBox();
        MainUIMijingFuben.closeSelf();
	end

    function MainUIMijingFuben.playEffect()
        taskItem:GO('content').gameObject:SetActive(false);      
        taskItem:GO('effectObj'):PlayUIEffect(this.gameObject, "renwuwancheng", 1.5, function(effect)
            local effectController = effect:GetComponent("EffectController");
            effectController:BindDestroyFunction(function()
                taskItem:GO('content').gameObject:SetActive(true);  
            end)                
        end, true);
	end

    function MainUIMijingFuben.Hide()
        this.gameObject:SetActive(false);
    end

    function MainUIMijingFuben.Show()
        this.gameObject:SetActive(true);
    end

    function MainUIMijingFuben.ExitHide()
        btnExit.transform:DOLocalMoveX(btnExitPos.x + 600, 0.5, false);
    end

    function MainUIMijingFuben.ExitShow()
        if not const.OpenMenuFlag then
            btnExit.transform:DOLocalMoveX(btnExitPos.x, 0.3, false);
        end
    end

	return MainUIMijingFuben;
end
