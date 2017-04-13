function MainUIView()

    --print("4. MainUIView");

	local player = nil;

    --活动区
    local bIsActPanelShrink = true;
    local actPanelTrans = nil;
    local ActPanelPos = nil;
    local ActPaiHang;
    local currentPower = 0;
    local powerChargingTimer = nil;
    local hongbao = nil

    local this = nil;
    --背包
    local bagFull = nil;
    local beiBaoMan = nil;

    -- 队伍任务区
    local IsSelectTask = true;
    local leftPanel = nil;
    local arrow = nil;
    local taskBtn = nil;
    local teamBtn = nil;
    local taskImg = nil;
    local teamImg = nil;
    local leftPanelPosition = nil;
    local scrollbar = nil;
    local leftPos = nil;
    local isPressed = false;

    --用于隐藏的几组控件，区别是隐藏时缩进的方向不同 
    local UIGroup = {{"Joystick","player", "LeftQuickOperate", "leftPanel"}, --左
                      {"ditu", "transmit", "ActPanel","ExitActivity","hongbao"},--右
                      {"btnGroup"},--上
                      {"jingyan", "NetConnectState", "AutoPathfinding", "OpenTreasure", "team"},--下
                      };

    local PosMap = {}
    local HideDistance = 600;
    local HideTime = 0.5;
    local ShowTime = 0.3;
 
    --快速操作面板
    local leftQuickOperate = nil;
    local leftQuick_Panel = nil;
    local leftQuickContent = nil;
    local leftQuick_btnOK = nil;
    local leftQuick_btnCancel = nil;

    --网络连接
    local lastState = nil;
    local netIcon = nil;
    local gsTime = nil;
    local power = nil;

    --local newEmailIcon = nil

    local exitActivityBtn = nil;
    local headTeamLeader = nil;
    local fubenpipei = nil;

    local fubenTask = nil;
    local LeftflyfinalPos = nil;
    local ProtectTaskText = nil;
    local taskEffectObj = nil;

    local actRedPoint = nil;
    local fuliRePoint = nil;
    local bagRePoint = nil;
    local richang = nil;
    -- buff显示区域
    local buffArea = nil;

    local specialExp = nil;
    local openTreasure = nil;
    local btnGroup = nil;

    local sceneW = nil;
    local sceneH = nil;
    local dituBg = nil;
    local dituMe = nil;
    local dituMePos = nil;
    local fubenCompleted = false;
    local UICamera = nil;
    local bossIcon = nil;
    local fubenBoss = nil;
    local eliteIcon = nil
    local teamIcon = nil;
    local teamObj = {}
    local eliteObj = {};
    function  MainUI.Start()      
        player = DataCache.myInfo;
        this = MainUI.this;
        MainUI.isShow = true;

        --记录各模块位置
        for i=1,#UIGroup do
            for j=1,#UIGroup[i] do
                PosMap[UIGroup[i][j]] = this:GO(UIGroup[i][j]).transform.localPosition;
            end
        end

        UICamera = GameObject.Find("UI Camera"):GetComponent("Camera")
        
        this:GO('player.headImage'):BindButtonClick(MainUI.ShowRole);
        this:GO('player.headImage.tx').sprite = const.RoleImgTab[DataCache.myInfo.career][DataCache.myInfo.sex + 1];
        headTeamLeader = this:GO('player.headImage.team');
        headTeamLeader:Hide();

        this:GO('ditu.icon'):BindButtonClick(MainUI.openAreaMap);
        ActPaiHang = this:GO('ActPanel.BasePanel._ActPaiHang');
        --当前地图名称
        dituBg = this:GO('ditu.mask.bg');
        dituMe = this:GO('ditu.mask.bg.Image');
        bossIcon = this:GO('ditu.mask.bg.bossIcon');
        fubenBoss = this:GO('ditu.mask.bg.fubenBoss');
        eliteIcon = this:GO('ditu.mask.bg.eliteIcon');
        teamIcon = this:GO('ditu.mask.bg.teamIcon');

        dituMePos = dituMe.transform.localPosition;
        MainUI.UpdateSceneName();
        this:GO('ditu.Position'):BindButtonClick(MainUI.openAreaMap);
        this:GO('player.pk_model'):BindButtonClick(MainUI.onKill);
        this:GO('team'):BindButtonClick(ui.unOpenFunc)

        this:GO('ActPanel.BtnTreasure'):BindButtonClick(function ()
            PanelManager:CreateConstPanel('UIGoldBox', UIExtendType.BLACKMASK, {});
        end);
        
        -- 顶部按钮
        btnGroup = this:GO('btnGroup');
        this:GO('btnGroup.BtnRank'):BindButtonClick(MainUI.ShowRankingList);
        this:GO('btnGroup.BtnShop'):BindButtonClick(MainUI.ShowShop);
        this:GO('btnGroup.BtnAuction'):BindButtonClick(MainUI.ShowAuction);
        this:GO('btnGroup.BtnFuli'):BindButtonClick(MainUI.ShowFuli);
        this:GO('btnGroup.BtnActivity'):BindButtonClick(MainUI.ShowActivity);

        MainUI.UpdateTreasureBtn();

        actRedPoint = this:GO('btnGroup.BtnActivity.redPoint');
        fuliRePoint = this:GO('btnGroup.BtnFuli.redPoint');

        buffArea = this:GO('player.buffZone');
        buffArea:BindButtonClick(ui.ShowBuffFloat)

        hongbao = this:GO("hongbao.icon")
        hongbao:BindButtonClick(client.legion.draw_candraw_first)

        --活动
        client.activity.GetResourceInfo(function(reply)
            if reply == nil then
                error("为什么会是 nil");
                return;
            end
            local list = reply["list"];
            local flag = client.activity.HandleFindData(list);
            if client.activity.mainTip and flag then
                local param = {type = const.TIPS_Type.Activity}
                UIManager.GetInstance():CallLuaMethod('MainUI.AddTips', param);
            end
        end);

        --副本
        fubenpipei = this:GO('fubenpipei')
        this:GO('fubenpipei.btn'):BindButtonClick(MainUI.FuBenPiPeiClick)
        --提醒区域
        leftQuickOperate = this:GO('LeftQuickOperate');
        leftQuickOperate.gameObject:SetActive(false);
        leftQuick_Panel = leftQuickOperate:GO('Panel')
        leftQuickContent = leftQuickOperate:GO('Panel.Text')
        leftQuick_btnOK       = leftQuickOperate:GO('Panel.btnOK')
        leftQuick_btnCancel   = leftQuickOperate:GO('Panel.btnCancel')

        LeftflyfinalPos = leftQuickContent.transform.localPosition
        exitActivityBtn = this:GO('ExitActivity');

        -- 队伍任务区
        leftPanel = this:GO('leftPanel');
        arrow = leftPanel:GO('Arrow');
        taskBtn = leftPanel:GO('Panel.TaskBtn');
        teamBtn = leftPanel:GO('Panel.TeamBtn'); 
        leftPanelPosition = this:GO('leftPanel.Panel').transform.localPosition;
        arrow:BindButtonClick(MainUI.SwitchLeftPanel);

        --经验
        specialExp = this:GO('jingyan.SpecialExp');
        specialExp:Hide();

        EventManager.bind(this.gameObject,Event.ON_TIME_SECOND_CHANGE,MainUI.UpdateNetConnectState);        
        EventManager.bind(this.gameObject,Event.ON_ENTER_SCENE,MainUI.OnEnterScene);
        EventManager.bind(this.gameObject, Event.ON_EVENT_RED_POINT, function ( )
            MainUI.onRedPoint()
        end );
        EventManager.bind(this.gameObject, Event.ON_LEVEL_UP, function ()
            MainUI.onRedPoint();
        end);  -- 升级，刷新头像红点显示(技能/宝石镶嵌)

        EventManager.bind(this.gameObject, Event.ON_TALENTBOOK_CHANGE, function ()
            MainUI.onRedPoint();
        end);   -- 天赋书变化，刷新头像红点显示(技能培养)

        EventManager.bind(this.gameObject, Event.ON_TALENT_ZHUANJING_UNLOCK, function ()
            MainUI.onRedPoint();
        end);   -- 天赋/专精 解锁，刷新头像红点显示(技能)

        EventManager.bind(this.gameObject, Event.ON_ABILITY_UNLOCK, function ()
            MainUI.onRedPoint();
        end);   -- 技能 解锁，刷新头像红点显示(技能)


        EventManager.bind(this.gameObject, Event.ON_MONEY_CHANGE,function ()
            MainUI.onRedPoint();
        end); -- 金钱变化时头像红点显示(很多系统需要金钱来升级)
        EventManager.bind(this.gameObject, Event.ON_EVENT_EQUIP_CHANGE,function ()
            MainUI.onRedPoint();
        end); -- 穿戴装备变化时头像红点显示(替换装备时宝石可能可以镶嵌)
        EventManager.bind(this.gameObject, Event.ON_GEM_PUT_OR_REMOVE,function ()
            MainUI.onRedPoint();
        end); -- 宝石镶嵌/拆卸时头像红点显示

        EventManager.bind(this.gameObject, Event.ON_EVENT_GEM_CHANGE,function ()
            MainUI.onRedPoint();
        end); -- 获得宝石时头像红点显示(宝石镶嵌/合成)
        EventManager.bind(this.gameObject, Event.ON_HORSE_UNLOCK_OR_CANUPGRADE,function ()
            MainUI.onRedPoint();
        end); -- 坐骑解锁成功消除红点显示

    	EventManager.bind(this.gameObject,Event.ON_EXP_CHANGE,MainUI.showExp);
    	EventManager.bind(this.gameObject,Event.ON_LEVEL_UP,MainUI.handleLevelUp);
    	EventManager.bind(this.gameObject,Event.ON_BLOOD_CHANGE,MainUI.showHp);

        EventManager.bind(this.gameObject,Event.ON_FIGHTNUMBER_CHANGE, MainUI.PlayFightValueEffect);
 
        EventManager.bind(this.gameObject,Event.ON_EVENT_EQUIP_CHANGE, function() 
            MainUI.showRedPoint();
            end);
        EventManager.bind(this.gameObject,Event.ON_EVENT_ITEM_CHANGE, function()
            MainUI.showRedPoint();
            end);
        EventManager.bind(this.gameObject,Event.ON_EVENT_GEM_CHANGE, function() 
            MainUI.showRedPoint();
            end);
        EventManager.bind(this.gameObject,Event.ON_CHANGE_SCENENAME, MainUI.ShowSceneName);
        EventManager.bind(this.gameObject,Event.ON_TIME_DAY_CHANGE,MainUI.handleDayChanged);

        EventManager.bind(this.gameObject,Event.ON_START_AUTO_PATHFINDING,MainUI.onStartAutoPathfinding);
        EventManager.bind(this.gameObject,Event.ON_END_AUTO_PATHFINDING,MainUI.onEndAutoPathfinding);

        EventManager.bind(this.gameObject, Event.ON_RECEIVE_TILI_CHANGE,function ()
            MainUI.checkFuliRedPoint();
        end); -- 福利领取时机变化时检查福利图标红点显示
        EventManager.bind(this.gameObject, Event.ON_TILI_CHANGE,function ()
            MainUI.checkFuliRedPoint();
        end); -- 福利领取之后去除红点显示

        EventManager.bind(this.gameObject, Event.ON_FUBEN_TASK_COMPLETED_EFFECT, MainUI.FubenCompleted);
        EventManager.bind(this.gameObject, Event.ON_REDPOINT_TEAMMSG, MainUI.checkTeamMsgRedPoint);

        MainUI.showName();
        MainUI.showLevel();
        MainUI.showExp();
        MainUI.showHp();
        MainUI.UpdateFightNumber();
        MainUI.InitLeftPanel();

        netIcon = this:GO('NetConnectState.NetIcon');
        gsTime = this:GO('NetConnectState.Time');
        power = this:GO('NetConnectState.PowerIcon.power');

        MainUI.setUIPkMode(player.pk_mode == "quanti");

        MainUI.showAutoPathfindingEffect(false);
        local transmitBtn = this:GO("transmit");
        transmitBtn:BindButtonClick(function (go)
            TransmitScroll.UseIt(go);
        end);

        openTreasure = this:GO('OpenTreasure');
        openTreasure:BindButtonClick(TreasureCtrl.ButtonClick);   
    end

    function MainUI.Update( )
        MainUI.RefreshBuffArea();
        MainUI.UpdateDirection();
        MainUI.UpdateBossPos();
        MainUI.UpdateBestMonster();
        MainUI.UpdateFubenBoss();
        MainUI.UpdateTeamPos();
    end

    local function isNaN(value)
        return value ~= value;
    end

    function MainUI.UpdateDirection()
        local player = AvatarCache.me;
        if player ~= nil then
            local dir_x = player.dir_x;
            local dir_y = player.dir_y;
            local dir_z = player.dir_z;
            if dir_x ~= 0 then
                local angles = math.atan2(dir_z, dir_x);
                local angles_ = math.deg(angles) + 90;
                if not isNaN(angles_) then
                    dituMe.transform.localEulerAngles = Vector3.New(0, 0, angles_);
                else
                    dituMe.transform.localEulerAngles = Vector3.New(0, 0, 0);
                end
            else
                if dir_z > 0 then
                    dituMe.transform.localEulerAngles = Vector3.New(0, 0, 180);
                else
                    dituMe.transform.localEulerAngles = Vector3.New(0, 0, 0);
                end
            end
        end
    end

    -- 世界boss
    function MainUI.UpdateBossPos()
        local pos = nil;
        for i = 1, 5 do
            if DataCache.scene_sid == const.SceneBoss_mapId[i] then
                -- 当前场景中boss的固定三维坐标
                local sid = tb.ActivitiesInfoTable["sceneBoss"..const.SceneBoss_mapId[i]].npcSid;
                local nid = AvatarCache.sid2nid[sid];
                if activity.BossStateList[const.BossIndexTranslate[i]][2] > 0 then
                    bossIcon.gameObject:SetActive(true);
                    if nid then
                        local ds = AvatarCache.GetAvatar(nid);
                        if ds then
                            local boss_x = ds.pos_x
                            local boss_y = ds.pos_y
                            local boss_z = ds.pos_z
                            pos = Vector3.New(boss_x, boss_y, boss_z);
                        end
                    else
                        pos = tb.ActivitiesInfoTable["sceneBoss"..const.SceneBoss_mapId[i]].pos;
                        pos = Vector3.New(pos[1], pos[2], pos[3]);
                    end
                else
                    bossIcon.gameObject:SetActive(false);
                end
                break;
            end
        end
        MainUI.CreateTheMapPos(pos, bossIcon)
    end

    -- 副本boss
    function MainUI.UpdateFubenBoss()
        local pos = nil;
        if tb.SceneTable[DataCache.scene_sid].sceneLua == "PlotlineFuben" then
            -- 是否要判断创建avatar后才显示小BOSS,小boss 被杀后需要消失
            -- 得到当前场景中的副本boss的sid
            -- 判断当前场景副本是否完成
            -- if client.task.mainTaskSid == fubenTask then  -- 判断副本是否进行完毕
            local sid = tb.TaskTable[client.task.mainTaskSid].successCondition[1].v1;
            local nid = AvatarCache.sid2nid[sid];
            if nid then
                local ds = AvatarCache.GetAvatar(nid);
                if ds then 
                    pos = Vector3.New(ds.pos_x, ds.pos_y, ds.pos_z)
                end
            else
                local pos_x = tb.fubenflow[10001][5].pos[1];
                local pos_y = tb.fubenflow[10001][5].pos[2];
                pos = Vector3.New(pos_x, 0, pos_y);
            end
        end
        MainUI.CreateTheMapPos(pos, fubenBoss)
    end

    -- 精英怪
    local function getTab2List(tab)
        local list = {};
        for k, v in pairs(tab) do
            list[#list + 1] = v;
        end
        return list;
    end

    function MainUI.UpdateBestMonster()
        MainUI.ResetTeamPos(eliteObj)
        local eliteList = getTab2List(const.CanSeeEliteTab);
        if #eliteObj == 0 then
            for i = 1, #eliteList do
                local pos = Vector3.New(eliteList[i].pos_x, eliteList[i].pos_y, eliteList[i].pos_z);
                local elite = newObject(eliteIcon)
                elite.gameObject:GetComponent("Image"):SetNativeSize();
                elite.gameObject:SetActive(true);
                elite.transform:SetParent(dituBg.transform);
                elite.transform.localScale = Vector3.one;
                eliteObj[i] = elite;
                MainUI.CreateTheMapPos(pos, elite);
            end
        else
            if #eliteList < #eliteObj then
                for i = 1, #eliteList do
                    local pos = Vector3.New(eliteList[i].pos_x, eliteList[i].pos_y, eliteList[i].pos_z);
                    eliteObj[i].gameObject:SetActive(true);
                    MainUI.CreateTheMapPos(pos, eliteObj[i]);
                end
            else
                for i = 1, #eliteObj do
                    local pos = Vector3.New(eliteList[i].pos_x, eliteList[i].pos_y, eliteList[i].pos_z);
                    eliteObj[i].gameObject:SetActive(true);
                    MainUI.CreateTheMapPos(pos, eliteObj[i]);
                end
                for i = #eliteObj + 1, #eliteList do
                    local pos = Vector3.New(eliteList[i].pos_x, eliteList[i].pos_y, eliteList[i].pos_z);
                    local elite = newObject(eliteIcon);
                    elite.gameObject:GetComponent("Image"):SetNativeSize();
                    elite.gameObject:SetActive(true);
                    elite.transform:SetParent(dituBg.transform);
                    elite.transform.localScale = Vector3.one;
                    eliteObj[i] = elite;
                    MainUI.CreateTheMapPos(pos, elite);
                end
            end
        end
    end

    function MainUI.ResetTeamPos(listObj)
        for i = 1, #listObj do
            listObj[i].gameObject:SetActive(false);
        end
    end

    function MainUI.UpdateTeamPos()
        MainUI.ResetTeamPos(teamObj);
        for k, v in pairs(AvatarCache.avatars) do
            local id = v.id;
            if Checker.CheckIsSameTeam(v) and id ~= AvatarCache.me.id then
                const.CanSeeTeamerTab[id] = v;
            else
                const.CanSeeTeamerTab[id] = nil;  
            end
        end
        local list = getTab2List(const.CanSeeTeamerTab);
        if #teamObj == 0 then
            for i = 1, #list do
                if list[i].state ~= "offline" then
                    local pos = Vector3.New(list[i].pos_x, list[i].pos_y, list[i].pos_z);
                    local teamer = newObject(teamIcon);
                    teamer.gameObject:GetComponent("Image"):SetNativeSize();
                    teamer.gameObject:SetActive(true);
                    teamer.transform:SetParent(dituBg.transform);
                    teamer.transform.localScale = Vector3.one;
                    teamObj[i] = teamer;
                    MainUI.CreateTheMapPos(pos, teamer);
                end
            end
        else
            if #list <= #teamObj then
                for i = 1, #list do
                    if list[i].state ~= "offline" then
                        local pos = Vector3.New(list[i].pos_x, list[i].pos_y, list[i].pos_z);
                        teamObj[i].gameObject:SetActive(true);
                        MainUI.CreateTheMapPos(pos, teamObj[i]);
                    end
                end
            else
                for i = 1, #teamObj do
                    if list[i].state ~= "offline" then
                        local pos = Vector3.New(list[i].pos_x, list[i].pos_y, list[i].pos_z);
                        teamObj[i].gameObject:SetActive(true);
                        MainUI.CreateTheMapPos(pos, teamObj[i]);
                    end
                end
                for i = #teamObj + 1, #list do
                    if list[i].state ~= "offline" then
                        local pos = Vector3.New(list[i].pos_x, list[i].pos_y, list[i].pos_z);
                        local teamer = newObject(teamIcon);
                        teamer.gameObject:GetComponent("Image"):SetNativeSize();
                        teamer.gameObject:SetActive(true);
                        teamer.transform:SetParent(dituBg.transform);
                        teamer.transform.localScale = Vector3.one;
                        teamObj[i] = teamer;
                        MainUI.CreateTheMapPos(pos, teamer);
                    end
                end
            end
        end
    end

    function MainUI.CreateTheMapPos(pos, go)
        if pos then
            go.gameObject:SetActive(true)
            -- playerPos角色的动态变化的三维坐标
            if AvatarCache.me then
                local playerPos_x = AvatarCache.me.pos_x;
                local playerPos_y = AvatarCache.me.pos_y;
                local playerPos_z = AvatarCache.me.pos_z;
                local playerPos = Vector3.New(playerPos_x, playerPos_y, playerPos_z)
                -- player2dPos小地图中人物的三维坐标
                local player2dPos = dituMe.transform.localPosition;
                local AddX = (pos.x - playerPos.x) * 159/64 + player2dPos.x;
                local AddZ = (pos.z - playerPos.z) * 140/64 + player2dPos.z;
                local bossPos = Vector3.New(AddX, AddZ, 0);
                go.transform.localPosition = bossPos;
            end
        else
            go.gameObject:SetActive(false);
        end
    end

    function MainUI.FubenCompleted()
        fubenCompleted = true;
    end

    function MainUI.UpdateTreasureBtn()
        if DataCache.treasureNumber > 0 then
            this:GO('ActPanel.BtnTreasure'):Show();
        else
            this:GO('ActPanel.BtnTreasure'):Hide();
        end
    end

    --初始化左边的组队，任务面板
    function MainUI.InitLeftPanel()
        -- 打开任务隐藏队伍
        taskBtn:BindButtonClick(MainUI.ClickTaskBtn);
        -- 打开队伍隐藏任务
        teamBtn:BindButtonClick(MainUI.ClickTeamBtn);
    end

    function MainUI.ClickTaskBtn()
        taskBtn:GO("text").text = "<color=#000000CC>任 务</color>";
        MainUI.FormatTeamBtnText(false)
        if IsSelectTask then
            local param = {task_module_type = 1};
            PanelManager:CreatePanel('UITask' , UIExtendType.TRANSMASK, param);
        else
            taskBtn.sprite = "tb_selected";
            teamBtn.sprite = "tb_unselected";
            UIManager.GetInstance():CallLuaMethod('MainUITeam.SetActive', false);
            UIManager.GetInstance():CallLuaMethod('MainUITask.SetActive', true);
            -- scrollbar.gameObject:SetActive(true);
        end
        IsSelectTask = true;
    end

    function MainUI.SetIsSelectTask(flag)
        IsSelectTask = flag;
    end

    function MainUI.ClickTeamBtn()
        if DataCache.scene_sid == "20000001" then
            ui.showMsg("11级开启组队系统！");
        else
            MainUI.FormatTeamBtnText(true)
            taskBtn:GO("text").text = "<color=#fed993ff>任 务</color>";
            if not IsSelectTask then
                -- 打开队伍窗口
                MainUI.ShowUITeamActivity()
            else
                teamBtn.sprite = "tb_selected";
                taskBtn.sprite = "tb_unselected";
                UIManager.GetInstance():CallLuaMethod('MainUITask.SetActive', false);
                UIManager.GetInstance():CallLuaMethod('MainUITeam.SetActive', true);
                --scrollbar.gameObject:SetActive(false);
                MainUI.CheckUITeamMsgList()
            end
            client.team.redPoint_Sum = false
            EventManager.onEvent(Event.ON_REDPOINT_TEAMMSG)
            IsSelectTask = false;
            -- UIManager.GetInstance():CallLuaMethod('MainUITeam.OnAwake');
            -- print("over!!")
        end
    end

    function MainUI.FormatTeamBtnText(bChoose)
        local strTeam = "队 伍"
        if client.team.haveTeam() and client.team.team_members ~= nil then
            strTeam = string.format("队 伍  %d", client.team.getTeamMemberCount())
        end
        if bChoose == nil then
            if IsSelectTask then
                teamBtn:GO("text").text = "<color=#fed993ff>"..strTeam.."</color>";
            else
                teamBtn:GO("text").text = "<color=#000000CC>"..strTeam.."</color>";
            end
        else
            if bChoose == true then     --选中是黄字体
                teamBtn:GO("text").text = "<color=#000000CC>"..strTeam.."</color>";
            else                        --未选中是白字
                teamBtn:GO("text").text = "<color=#fed993ff>"..strTeam.."</color>";
            end
        end
    end

    function MainUI.ShowRole()
        if client.horse.horseTableCache then
            PanelManager:CreatePanel('NewUIRole', UIExtendType.TRANSMASK, {panelType = "Role"}); 
            return;
        end
        client.horse.getServerHorse(function () 
            PanelManager:CreatePanel('NewUIRole', UIExtendType.TRANSMASK, {panelType = "Role"});
        end)
    end

    -- 显示buff
    function MainUI.RefreshBuffArea()
        if #client.buffCtrl.buffList > 0 then
            buffArea:Show();
            buffArea:GO('etc'):Hide();
            local buffGO;
            for i=1,#client.buffCtrl.buffList do
                if i <= 4 then
                    buffGO = buffArea:GO('buff'..i);
                    buffGO:Show();
                    local buffCD = buffGO:GO('cd');
                    local buffNumber = buffGO:GO('number');
                    local buffInfo = client.buffCtrl.buffList[i];

                    buffNumber:Hide();
                    buffGO.sprite = buffInfo.icon;
                    if buffInfo.show_cd == true then
                        buffCD:Show();
                        buffCD.fillAmount = 1 - (buffInfo.start_time + buffInfo.useful_time - TimerManager.GetServerNowMillSecond()) / buffInfo.cd;  
                    else
                        buffCD:Hide();
                    end
                else
                    buffArea:GO('etc'):Show();
                    return
                end
            end

            for i=#client.buffCtrl.buffList + 1,5 do
                buffGO = buffArea:GO('buff'..i);
                buffGO:Hide();
            end
        else
            buffArea:Hide();
        end
    end

    -- 检查主界面福利图标红点
    function MainUI.checkFuliRedPoint()
        fuliRePoint:Hide();
    end

    -- 显示活动图标红点
    function MainUI.checkActivityRedPoint()
        if client.activity.getActiveValueRed() or client.activity.CheckBossRed(activity.BossStateList) then
            --actRedPoint:Show(); --(NSY-4793) 屏蔽
        else
            actRedPoint:Hide();
        end
    end

    -- 显示自动寻路特效
    function MainUI.showAutoPathfindingEffect(show)
        local effect = this:GO('AutoPathfinding');
        if show then
            effect:Show();
        else
            effect:Hide();
        end
    end

    -- 开始自动寻路事件处理
    function MainUI.onStartAutoPathfinding()
        local showTransmitBtn = true
        if (SceneManager.IsCurrentXiangWeiMap()) then
            showTransmitBtn = false
        end
        MainUI.DoRefreshTrasmit(showTransmitBtn);
        MainUI.showAutoPathfindingEffect(true);
    end

    -- 结束自动寻路事件处理
    function MainUI.onEndAutoPathfinding()
        MainUI.DoRefreshTrasmit(false);
        MainUI.showAutoPathfindingEffect(false);
    end

    -- 自动寻路按钮刷新
    function MainUI.DoRefreshTrasmit(show)
        if show then
            local transmit = this:GO('transmit');
            if const.use_teleport then
                transmit:Show();
                MainUI.RefreshTransmitScroll();
            else
                transmit:Hide();    
            end
        else
            local transmit = this:GO('transmit');
            transmit:Hide();
        end
    end

    -- 刷新传送卷轴
    function MainUI.RefreshTransmitScrollImpl()
        local transmit = this:GO('transmit');
        local transmit_ticket = transmit:GO('ticket');
        local transmit_diamond = transmit:GO('diamond');
        local item = Bag.FindItemBytid(const.item.chuansong)
        if item == nil or item.count == 0 then
            transmit_ticket:Hide();
            transmit_diamond:Show();
        else
            local numb = transmit_ticket:GO('numb');
            numb.text = string.format("%d/1", item.count);
            transmit_ticket:Show();
            transmit_diamond:Hide();
        end
    end

    -- 刷新传送卷轴
    function MainUI.RefreshTransmitScroll()
        local itemList = Bag.GetItemList();
        if itemList == nil or itemList.list == nil then
            Bag.getItemBag (function ()
                MainUI.RefreshTransmitScrollImpl();
            end);
            return;
        end
        MainUI.RefreshTransmitScrollImpl();
    end

    function MainUI.showRedPoint()
        MainUI.onRedPoint();
    end

    function MainUI.onRedPoint()
        MainUI.checkActivityRedPoint();
        MainUI.checkFuliRedPoint();
        local flag = this:GO('player.flag');
        local newFlag = this:GO('player.newFlag');
        newFlag:Hide();
        flag:Hide();

        -- 新系统开放标识
        local isShow = false;
        for i=1,#client.newSystemOpen.SystemList do
            if client.newSystemOpen.SystemList[i].operateFlag == 0 then
                isShow = true
                break;
            end
        end
    end

    function MainUI.PowerAni()
        if power.fillAmount == 1 then 
            power.fillAmount = currentPower 
        else   
            power.fillAmount = power.fillAmount + 0.1 
        end
    end

    function MainUI.UpdateNetConnectState()
        local state = NativeManager.GetInstance():GetNetState();
        if state ~= lastState then
            lastState = state;
            if netIcon ~= nil then
                if state == UnityEngine.NetworkReachability.NotReachable then --无连接
                    netIcon:Hide();
                elseif state == UnityEngine.NetworkReachability.ReachableViaLocalAreaNetwork then --Wifi
                    netIcon.sprite = "tb_wuxian";
                else  --数据流量
                    netIcon.sprite = "tb_xinhao";
                end
            else
              	--print("Error: netIcon为nil 未初始化成功？!")
            end
        end

        gsTime.text = os.date("%H:%M", math.round(TimerManager.GetServerNowMillSecond()/1000))
        currentPower = NativeManager.GetInstance():GetBattery();

        if NativeManager.GetInstance():GetBatteryCharging() == 1 then
            if powerChargingTimer == nil then
                powerChargingTimer = Timer.New(MainUI.PowerAni, 0.5, -1, false)
                powerChargingTimer:Start()
            end
        else
            if powerChargingTimer ~= nil then
                powerChargingTimer:Stop()
                powerChargingTimer = nil;                
            end
            power.fillAmount = currentPower 
        end

    end


    function MainUI.FirstUpdate()
        MainUI.DoRefreshTrasmit(false);
        
        --MainUI.MoveGroup(UIGroup[5],"Top",true,0.1);
        --记录活动扩展面板的位置并移出屏幕(这样写存了一个引用)
        bIsActPanelShrink = true;
        SRSetting.get_server_role_setting();
        client.requestSE.Start();
    end

    function MainUI.onKill(go)
        if DataCache.myInfo.level < 30 then
            ui.showMsg("等级过低，无法切换模式");
            return;
        end

        if DataCache.bForceRedName == true then
            ui.showMsg("当前地图无法切换模式");
            return;
        end

        if MainUI.IsInMolongdao() == true then
            ui.showMsg("当前地图无法切换模式");
            return;
        else
            if DataCache.myInfo.pk_mode == "quanti" then
                local msg = { cmd = "pk_mode_change",  pk_mode = "heping" };
                Send(msg,  MainUI.onKillCallback);
            else
                local msg = { cmd = "pk_mode_change",  pk_mode = "quanti" };
                Send(msg,  MainUI.onKillCallback);
            end
        end
    end

    function MainUI.onKillCallback(reply)
        -- 切换和平模式
        local player = AvatarCache.me;
        local pk_mode = player.pk_mode;
        if pk_mode == "heping" then
            pk_mode = "quanti";
        else
            pk_mode = "heping";
        end
        -- 保存到 myInfo
        local myInfo = DataCache.myInfo;
        myInfo.pk_mode = pk_mode;
        player.pk_mode = pk_mode;

        -- 设置玩家控制逻辑
        local class = Fight.GetClass(player);
        class.SwitchPKMode(player, pk_mode);
        if pk_mode == "quanti" then
            MainUI.SetKillMode(true);
        else
            MainUI.SetKillMode(false);
        end
        
        -- 重新选择目标
        TargetSelecter.ClearTarget();
        ControlLogic.AutoSelect();
    end

    function MainUI.setUIPkMode(mode)
        local img = this:GO('player.pk_model.icon');
        if MainUI.IsInMolongdao() == false then
            if mode == true then
                img.sprite = "tb_kill_mode"
            else
                img.sprite = "tb_peace_mode"
            end
        else
            img.sprite = "tb_kill_mode"
        end
    end

    function MainUI.IsInMolongdao()
        if DataCache.scene_sid == client.MolongTask.sceneSid then
            return true
        else
            return false
        end
    end

    function MainUI.SetKillMode(mode)
        MainUI.ChangePKMode(mode)
        MainUI.setUIPkMode(mode);                 
    end

    function MainUI.ChangePKMode(mode)
        --mode为true是pk模式，false为和平模式
        -- 设置Cache.myInfo数据   
        if mode == false then
            DataCache.myInfo.pk_mode = "heping";
            ui.showMsg("和平模式无法攻击白名玩家");
        else
            DataCache.myInfo.pk_mode = "quanti";
            ui.showMsg("屠杀模式可以攻击所有玩家");
        end                 
    end
  

    function MainUI.UpdateFightNumber()
        this:GO('player.fightNum.value').text = DataCache.myInfo.fightPoint;
    end

    function MainUI.PlayFightValueEffect(lastFightPoint)
        if lastFightPoint ~= nil and DataCache.myInfo.fightPoint > lastFightPoint then
            playFightValueEffect(lastFightPoint, DataCache.myInfo.fightPoint)
        else
            const.fightValueDelta = 0;
            MainUI.UpdateFightNumber()
        end
    end

    function MainUI.HideUI(name)
        MainUI.MoveGroup(UIGroup[1],"Left",true,HideTime);
        MainUI.MoveGroup(UIGroup[2],"Right",true,HideTime);
        MainUI.MoveGroup(UIGroup[3],"Top",true,HideTime);
        MainUI.MoveGroup(UIGroup[4],"Bottom",true,HideTime);
        EventManager.onEvent(Event.ON_MAINUI_HIDE);
        MainUI.isShow = false;
    end

    function MainUI.ShowUI()
        MainUI.MoveGroup(UIGroup[1],"Left",false,ShowTime);
        MainUI.MoveGroup(UIGroup[2],"Right",false,ShowTime);
        MainUI.MoveGroup(UIGroup[3],"Top",false,ShowTime);
        MainUI.MoveGroup(UIGroup[4],"Bottom",false,ShowTime, function ()
            MainUI.isShow = true; 
        end);
        EventManager.onEvent(Event.ON_MAINUI_SHOW);
    end

    function MainUI.ShowBottomUI(show)
        if show then
            MainUI.MoveGroup(UIGroup[4],"Bottom",false,ShowTime);
        else
            MainUI.MoveGroup(UIGroup[4],"Bottom",true,HideTime);
        end
    end

    function MainUI.ShowRankingList()
        if DataCache.myInfo.level < 30 then
            ui.showMsg("排行榜30级解锁！");
        else
            PanelManager:CreatePanel('UIRankingList',UIExtendType.TRANSMASK,nil);
        end
    end

    function MainUI.ShowShop()
        ui.showMsg("暂未开放")
    end

    function MainUI.ShowAuction()
        if true then ui.showMsg("暂未开放") return false; end
        if DataCache.myInfo.level < 35 then
            ui.showMsg("交易行35级解锁！");
        else
            PanelManager:CreatePanel('UIAuction' , UIExtendType.TRANSMASK, {});
        end 
    end

    function MainUI.ShowFuli()
        ui.showMsg("暂未开放")
    end

    function MainUI.ShowActivity()
        if true then ui.showMsg("暂未开放") return false; end --临时屏蔽
        if DataCache.myInfo.level < 20 then
            ui.showMsg("20级解锁活动");
        else
            PanelManager:CreatePanel('UIActivity' , UIExtendType.TRANSMASK, {});
        end
    end

	function MainUI.showHp( )
		this:GO('player.bloodback.blood').fillAmount = player.hp / player.maxHP;		
	end

	function MainUI.showLevel() 
		this:GO('player.headImage.level').text = player.level;	
	end

    function MainUI.showName()
        this:GO('player.headImage.name').text = player.name;
    end

    local expTween = nil;
	function MainUI.showExp()
		local exp = tb.ExpTable[player.level].levExp;
        local expPercent = player.exp / exp;       
        local image = this:GO('jingyan.value');
        local curPercent = image.fillAmount;

        if expTween ~= nil then
            Util.DotweenKill(expTween);
        end

        if expPercent > curPercent then
            expTween = Util.DOFillAmount(image.gameObject, expPercent, (expPercent - curPercent) * 1.5, function ()
                expTween = nil;
            end);
        else
            expTween = Util.DOFillAmount(image.gameObject, 1, (1 - curPercent) * 1.5, function ()
                expTween = Util.DOFillAmount(image.gameObject, expPercent, expPercent * 1.5, function ()
                    expTween = nil;
                end);
            end);
        end
        this:GO('jingyan.show'):BindButtonDown(function()
            isPressed = true;
            this:GO('jingyan.percent').text = string.format("EXP  <color=#ffe492>%s/%s</color>",player.exp,exp)
            end);
        this:GO('jingyan.show'):BindButtonUp(function()
            isPressed = false;
            this:GO('jingyan.percent').text = string.format("EXP  %.0f%%",expPercent * 100);
            end);
        this:GO('jingyan.Process').SliderValue = expPercent;

        if isPressed then
            this:GO('jingyan.percent').text = string.format("EXP  <color=#ffe492>%s/%s</color>",player.exp,exp) 
        else
            this:GO('jingyan.percent').text = string.format("EXP  %.0f%%",expPercent * 100);
        end
	end

    function MainUI.showSpecialExp(addExp)
        local expObj = newObject(specialExp);
        expObj.transform:SetParent(specialExp.transform.parent);
        expObj.transform.localScale = Vector3.one;
        expObj.transform.localPosition = specialExp.transform.localPosition;
        local expText = expObj:GO("Text");
        expText.text = "+"..1;
        expObj:Show();
        Util.DotweenTo(1, addExp, 0.5, function (x)
            expText.text = "+"..math.floor(x);
        end, function ()
            this:Delay(0.4, function () GameObject.Destroy(expObj.gameObject) end);

            local effect = this:LoadUIEffect(this.gameObject, "huoqujingyan", true, true);
            effect.transform:SetParent(specialExp.transform.parent);
            effect.transform.localScale = Vector3.one;
            effect.transform.localPosition = specialExp.transform.localPosition;
            local flyPos = this:GO('jingyan.Process.Cursor.Pos').transform.position;
            effect.transform:DOMove(flyPos, 1, false):OnComplete(function ()
                GameObject.Destroy(effect);
                EventManager.onEvent(Event.ON_EXP_CHANGE);
                this:GO('jingyan.Process.Cursor.Pos'):PlayUIEffect(this.gameObject, "jingyan_baodian", 1, function (go) 
                    go.transform.position = flyPos;
                end, true);
                
                this:GO('jingyan.Process.FillArea.Fill'):PlayUIEffect(this.gameObject, "jindutiao1-jingyan", 1, function (go)
                    go:GetComponent("RectTransform").sizeDelta = Vector2.zero;
                end, true);
            end);
        end);
    end

    function  MainUI.OnBagChange()
        local heavy = Bag.isBagHeavy();
        local full =  Bag.isBagFull();
        bagFull:SetActive(full);
        beiBaoMan:SetActive(false);
    end

    function MainUI.handleLevelUp()
        MainUI.showLevel();
        Bag.handlelevelUpBetter();
        client.MolongTask.registerProtectStart();
    end  

	function MainUI.openAreaMap()
        if SceneManager.IsCurrentFubenMap() or SceneManager.IsCurrentXiangWeiMap() then
            ui.showMsg("当前地图无法打开");
            return;
        end
		PanelManager:CreatePanel('UIAreaMap',  UIExtendType.TRANSMASK, {page = "curMap"})
	end

    function MainUI.SwitchLeftPanel()
        if const.leftPanelShrink == true then
            this:GO('leftPanel.Panel').transform:DOLocalMoveX(leftPanelPosition.x - 300, 0.3, false):SetEase(DG.Tweening.Ease.InBack);
            this:GO('leftPanel.Arrow').transform.localEulerAngles = Vector3.New(0,0,-180);
            UIManager.GetInstance():CallLuaMethod('MainUITask.MoveOut');
            UIManager.GetInstance():CallLuaMethod('MainUITeam.MoveOut');
            const.leftPanelShrink = false;
        else
            this:GO('leftPanel.Panel').transform:DOLocalMoveX(leftPanelPosition.x, 0.3, false);
            this:GO('leftPanel.Arrow').transform.localEulerAngles = Vector3.New(0,0,0);
            UIManager.GetInstance():CallLuaMethod('MainUITask.MoveIn');
            UIManager.GetInstance():CallLuaMethod('MainUITeam.MoveIn');
            const.leftPanelShrink = true;
        end  
    end

    function MainUI.MoveGroup(groupName,direction,bHide,nTime,callback)
        for i=1, #groupName do
            local name = groupName[i]
            local transform = this:GO(name).transform;
            local position = Vector3.New(PosMap[name].x, PosMap[name].y, PosMap[name].z);

            if direction == "Left" then
                if bHide == true then
                    position.x = position.x - HideDistance;
                end
            elseif direction == "Right" then
                if bHide == true then
                    position.x = position.x + HideDistance;
                end
            elseif direction == "Top" then      
                if bHide == true then
                    position.y = position.y + HideDistance;
                end
            elseif direction == "Bottom" then      
                if bHide == true then
                    position.y = position.y - HideDistance;
                end       
            end

            --菜单的特殊处理 
            if name == "menuGroup" and not const.OpenMenuFlag then
                position = Vector3.New(PosMap[name].x + HideDistance, PosMap[name].y, PosMap[name].z);
            end

            transform:DOLocalMove(position,nTime,false):OnComplete(function()
                if i == #groupName and callback ~= nil then
                    MainUI.FormatTaskList();
                    callback();
                end
            end);
        end
    end

    function MainUI.ShowSceneName(nameTab)
        this:GO('ditu.MapName').text = nameTab[1]
        this:GO('ditu.fenxian').text = nameTab[2]
    end

    function MainUI.UpdateSceneName()
        local scene = tb.SceneTable[DataCache.scene_sid]
        fubenCompleted = false;
        if scene.SceneType == "PlotlineFuben" then
            fubenTask = client.task.mainTaskSid;
        end
        this:GO('ditu.MapName').text = scene.name;
        sceneW = scene.sceneW;
        sceneH = scene.sceneH;
        dituBg.sprite = scene.sceneFile;
        --TODO 回收!  by linh 
        -- uFacadeUtility.ChangeMaterial(dituBg.gameObject, "MW/AreaMap", false)
        if SceneManager.IsCurrentFubenMap() or SceneManager.IsCurrentXiangWeiMap() then
            local fubentable = tb.fuben[client.fuben.curFubenId]
            this:GO('ditu.fenxian').text = "";  --const.fubenDifficulty_text[fubentable.difficulty]
        else
            this:GO('ditu.fenxian').text = string.format("%s线", DataCache.fenxian);
        end
    end

    -- 获得归属，显示为打开的箱子
    function MainUI.getBelong()
        MainUI.select_boss:GO('box').gameObject:SetActive(true);
        MainUI.select_boss:GO('box.guishu_lost').gameObject:SetActive(false);
        MainUI.select_boss:GO('box.guishu_get').gameObject:SetActive(true);
    end
    -- 失去归属，显示为关闭的箱子
    function MainUI.lostBelong()
        MainUI.select_boss:GO('box').gameObject:SetActive(true);
        MainUI.select_boss:GO('box.guishu_get').gameObject:SetActive(false);
        MainUI.select_boss:GO('box.guishu_lost').gameObject:SetActive(true);
    end

    --处理跨天事件
    function MainUI.handleDayChanged()
        client.CBTCtrl.handleDayChanged(); --藏宝图跨天又可以接取
        client.requestSE.OnDaychange()
    end
  
    function MainUI.ShowHongBaoIcon()
        hongbao.gameObject:SetActive(true);
        hongbao:PlayUIEffectForever(this.gameObject, "hongbao");
    end
    function MainUI.HideHongBaoIcon()
        hongbao.gameObject:SetActive(false);
        hongbao:StopAllUIEffects()
    end

    function MainUI.FuBenPiPeiShow(flag)
        fubenpipei:GO('btn').gameObject:SetActive(flag)
    end

    function MainUI.PlayPiPeiEffect(flag)
        local btn = fubenpipei:GO('btn');
        local bk = btn:GO('bk');
        if flag then
            bk.gameObject:SetActive(false)
            btn:PlayUIEffectForever(this.gameObject,"pipei")
        else
            bk.gameObject:SetActive(true)
            btn:StopUIEffect("pipei")
        end
    end

    function MainUI.FuBenPiPeiClick(go)
        if client.fuben.start_prepare_flag == true then
            ui.ShowFuBenZhunBei()
        else
            ui.ShowFuBenAutoTeam()
        end
    end

    function MainUI.ShowTeamLeaderFlag(show )
        headTeamLeader.gameObject:SetActive(show);
    end

    function MainUI.OnEnterScene()
        MainUI.setUIPkMode(player.pk_mode == "quanti")
        if MainUI.showGrowth then
            MainUI.showGrowth(true);
        end
        --隐藏选中条目, 这里直接调用 MainUI.OnCancelSelectObj 可能会出错
        -- 使用发送消息 Event.ON_TARGET_CANCEL_SELECT, zyb
        EventManager.onEvent(Event.ON_TARGET_CANCEL_SELECT);
        -- MainUI.OnCancelSelectObj()
        ui.HideMsg();

        if SceneManager.IsFubenMap(DataCache.scene_sid) or SceneManager.IsXiangWeiMap(DataCache.scene_sid) then
            this:GO('ActPanel').gameObject:SetActive(false);
        else
            this:GO('ActPanel').gameObject:SetActive(true);
        end
    end

    function MainUI.checkTeamMsgRedPoint()
        teamBtn:GO('redPoint').gameObject:SetActive(client.team.redPoint_Sum)
    end

    --打开宝箱
    function MainUI.ShowTreasureBtn()
        openTreasure:Show();
        --如果在掠夺引导场景中，触发引导
        if DataCache.scene_sid == 20040004 then
            GuideManager.yiwuGuide();
        end
    end

    function MainUI.HideTreasureBtn()
        openTreasure:Hide();
    end

    --隐藏touch月牙
    function MainUI.HideJoystickTouchIcon()
        this:GO('Joystick.Touch').gameObject:SetActive(false)
    end

    Util.BindPreLoadingFunc(client.activityMgr.HandleChangeMap)
    client.activityMgr.GetActivityList();

    --创建mianui后开始创建其它界面
    PanelManager:CreateConstPanel('UIChat',UIExtendType.MOVEINOUT,nil);
    PanelManager:CreateConstPanel('ChatAssist',UIExtendType.NONE, nil);
    PanelManager:CreateConstPanel('UISimpleSysMsg',UIExtendType.NONE,nil);
    PanelManager:CreateConstPanel('UIGuide',UIExtendType.NONE,nil);

    return MainUI;
end

function showMainUI()
    PanelManager:CreateUnderPanel('MainUI',UIExtendType.MOVEINOUT,nil);
    PanelManager:CreateUnderPanel('MainUIChat',UIExtendType.MOVEINOUT,nil);
    PanelManager:CreateUnderPanel('MainUITask',UIExtendType.MOVEINOUT,nil);
    PanelManager:CreateUnderPanel('MainUITeam',UIExtendType.MOVEINOUT,nil, 1);
    PanelManager:CreateUnderPanel('MainUITarget',UIExtendType.MOVEINOUT,nil);
    PanelManager:CreateUnderPanel('MainUISkill',UIExtendType.MOVEINOUT,nil);
    PanelManager:CreateUnderPanel('MainUIGrowth',UIExtendType.MOVEINOUT,nil);
    PanelManager:CreateUnderPanel('MainUIMenu',UIExtendType.MOVEINOUT,nil, 10);
end

    
