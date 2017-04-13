function CreateCBTCtrl()
	local cbtCtrl = {}

    cbtCtrl.CBTTaskSid = 90000;
    cbtCtrl.targetMap = nil;
    cbtCtrl.targetPos = nil;
    cbtCtrl.serverDoCount = nil;
    cbtCtrl.serverDoTime = nil;

    --执行挖宝
    function action_cbt()
        local msg = {cmd = "do_cangbao"}
        Send(msg, function(msg) 
            local rtype = msg["type"];
            if rtype == "ok" then
                cbtCtrl.serverDoCount = msg["count_info"][1];
                cbtCtrl.serverDoTime = msg["count_info"][2];
                cbtCtrl.targetMap = nil;
                cbtCtrl.targetPos = nil;
            end
            --更改界面次数
            EventManager.onEvent(Event.ON_CBT_Changed);
            EventManager.onEvent(Event.ON_EVENT_RED_POINT);
        end);
    end

    function cbtCtrl.begin_cbt_action()
        -- print("begin_cbt_action");
        client.task.CurTraceTaskSid = cbtCtrl.CBTTaskSid;
        MainUI.RefreshTaskListLater(0.5);
        local toPos = {x = cbtCtrl.targetPos[1], y = cbtCtrl.targetPos[3]};
        -- print(string.format("toPos: {%f, %f}", toPos.x, toPos.y));
        TransmitScroll.ClickLinkPathing(cbtCtrl.targetMap, DataCache.fenxian, toPos,
        function()
            local str = "挖宝中";
            client.commonProcess.StartProcess(ProcessType.CBTProcess, 3, str, action_cbt);
        end)
    end

    --获取藏宝图相关信息
    function cbtCtrl.get_cbt_info()
		local msg = {cmd = "get_cangbaotu_info"}
        Send(msg, function(msg)
            local countInfo = msg["count_info"];
            local cbtInfo = msg["info"];
            cbtCtrl.serverDoCount = countInfo[1];
            cbtCtrl.serverDoTime = countInfo[2];
            -- print(cbtInfo);
            if type(cbtInfo) == "table" then
                cbtCtrl.targetMap = cbtInfo[1];
                cbtCtrl.targetPos = cbtInfo[3];
                -- local pos = cbtInfo[3];
                -- print("--------- cbt");
                -- DataStruct.DumpTable(pos);
            else
                cbtCtrl.begin_cbt(false);
            end
            activity.AddReturnNumber();
        end); 
	end

    --点击“立即前往”
    function cbtCtrl.begin_cbt(actionFlag)
        if cbtCtrl.targetMap == nil then
            local msg = {cmd = "begin_cangbao"}
            Send(msg, function(msg) 
                local rtype = msg["type"];
                if rtype == "ok" then
                    cbtCtrl.targetMap = msg["map"];
                    cbtCtrl.targetPos = msg["pos"];
                end
                if actionFlag then
                    cbtCtrl.begin_cbt_action()
                end
            end);
        else
            if actionFlag then
                cbtCtrl.begin_cbt_action()
            end
        end
	end

    
    function cbtCtrl.handleDayChanged()
        cbtCtrl.begin_cbt(false);
    end

    --获取藏宝图已完成次数
    function cbtCtrl.get_cbt_count()
        if cbtCtrl.serverDoCount == 0 then
            return 0;
        end
        local currentTime = math.floor(TimerManager.GetServerNowMillSecond()/1000);
        if client.tools.IsTheSameDay(cbtCtrl.serverDoTime, currentTime) then
            return cbtCtrl.serverDoCount;
        end
        return 0;
	end

    function cbtCtrl.handleCBTMsg(msgTable)
        local mType = msgTable["type"];
        local mapName = client.tools.ensureString(msgTable["mapName"]);
        local playerName = client.tools.ensureString(msgTable["playerName"]);
        playerName = client.tools.formatRichTextColor(playerName, const.mainChat.nameColor);
        local fenxian = msgTable["fenxian"];
        if mType == "flauntAward" then
            local money = msgTable["money"];
            local str = string.format("天降横财！%s挖宝时获得[color:111,216,255,%s]金币", playerName, money);
            client.WorldBoard.ShowWorldMsg(str);
        elseif mType == "create_mowu" then
            local str = string.format("%s不慎挖开了魔物洞窟的封印，魔物正在[color:111,216,255,%s]作乱，各路英雄快前往平乱吧！", playerName, mapName);
            local pro = tb.SceneTable[msgTable["mapSid"]];
            client.WorldBoard.ShowWorldMsg(str);
        elseif mType == "create_shouhu" then
            local str = "挖宝时惊动了守护兽，击败它吧！";
            ui.showMsg(str);
            client.chat.clientSystemMsg(str);
        elseif mType == "create_normal_mijing" then
            local pro = tb.SceneTable[msgTable["mapSid"]];
            local str = string.format("%s在挖宝时触动了封印，一个持续5分钟的宝库出现在了[color:111,216,255,%s]，各路英雄快前往一探究竟！", playerName, mapName);
            client.WorldBoard.ShowWorldMsg(str);
        elseif mType == "create_super_mijing" then
            local pro = tb.SceneTable[msgTable["mapSid"]];
            local str = string.format("%s在挖宝时触动了封印，一个持续15分钟的高级宝库出现在了[color:111,216,255,%s]，各路英雄快前往一探究竟！", playerName, mapName);
            client.WorldBoard.ShowWorldMsg(str);
        elseif mType == "levelup_first_get" then
            cbtCtrl.begin_cbt(false);
        end

    end

    SetPort("cangbaotu",cbtCtrl.handleCBTMsg);
	
	return cbtCtrl;
end


client.CBTCtrl = CreateCBTCtrl();