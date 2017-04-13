function MainUIMenuView()
    local MainUIMenu = {};
    local this = nil;
    local menuPanel = nil;
    local bagPanel = nil;
    local panelPos = nil;
    local bagPos = nil;
    --背包
    local bagFull = nil;
    local beiBaoMan = nil;
    local bagRePoint = nil;
    -- 菜单折叠展开按钮
    local menuGroup = nil
    local btnMenu = nil;
    local menuRed = nil;
    local btnRole = nil;
    local btnEquip = nil;
    local btnSkill = nil;
    local btnJuntuan = nil;
    local btnSetting = nil;
    local btnShenyou = nil;
    local btnFuwen = nil;
    local menuItem = {};
    local menuOpenLevel = {1, 8, 6, 30, 1, 10, 99};
    local menuItemFun = {"ShowRole", "ShowEquip", "ShowSkill", "ShowLegion", "ShowSetting", "ShowShenyou", "ShowFuwen"};
    local menuItemIcon = {"an_role", "an_zhuangbei", "an_skill", "an_gonghui",  "an_setting", "an_shenyou",  "an_shenyou"};
    local menuId = {["role"] = 1, ["equip"] = 2, ["skill"] = 3, ["gonghui"] = 4, ["setting"] = 5, ["shenyou"] = 6, ["fuwen"] = 7};
	

    function  MainUIMenu.Start()      
		this = MainUIMenu.this;
        bindGuideButtionClick("MainUI_Bag", MainUIMenu.openBag, this:GO('bagPanel.Bag'));
        menuPanel = this:GO('menuPanel');
        panelPos = menuPanel.transform.localPosition;
        bagPanel = this:GO('bagPanel');
        bagPos = bagPanel.transform.localPosition;
        bagFull = this:GO('bagPanel.Bag.fullFlag').gameObject;
        beiBaoMan = this:LoadUIEffect(this.gameObject, "beibaomantishi", true, true);
        beiBaoMan.transform:SetParent(this:GO('bagPanel.Bag').transform)
        beiBaoMan.transform.localScale = Vector3.one;
        beiBaoMan.transform.localPosition = Vector3.zero;

        -- 右侧菜单
        menuGroup = this:GO('menuPanel.menuGroup');
        -- CurMenuPos = menuGroup.transform.localPosition;
        menuPanel.transform.localPosition = Vector3.New(panelPos.x + 300, panelPos.y, panelPos.z);
        btnMenu = this:GO('bagPanel.menu');
        menuRed = this:GO('bagPanel.redPoint');

        EventManager.bind(this.gameObject,Event.ON_MAINUI_HIDE, MainUIMenu.Hide);
        EventManager.bind(this.gameObject,Event.ON_MAINUI_SHOW, MainUIMenu.Show);

        EventManager.bind(this.gameObject,Event.ON_MAIN_MENU_SHOW, MainUIMenu.OpenMenu);
        EventManager.bind(this.gameObject,Event.ON_MAIN_MENU_HIDE, MainUIMenu.CloseMenu);

        EventManager.bind(this.gameObject, Event.ON_EVENT_RED_POINT, function ( )
            MainUIMenu.onRedPoint()
        end );
        EventManager.bind(this.gameObject, Event.ON_LEVEL_UP, function ()
            MainUIMenu.ShowMenu();
            MainUIMenu.onRedPoint();
        end);  -- 升级，刷新头像红点显示(技能/宝石镶嵌)

        EventManager.bind(this.gameObject, Event.ON_TALENTBOOK_CHANGE, function ()
            MainUIMenu.onRedPoint();
        end);   -- 天赋书变化，刷新头像红点显示(技能培养)

        EventManager.bind(this.gameObject, Event.ON_TALENT_ZHUANJING_UNLOCK, function ()
            MainUIMenu.onRedPoint();
        end);   -- 天赋/专精 解锁，刷新头像红点显示(技能)

        EventManager.bind(this.gameObject, Event.ON_ABILITY_UNLOCK, function ()
            MainUIMenu.onRedPoint();
        end);   -- 技能 解锁，刷新头像红点显示(技能)

        EventManager.bind(this.gameObject, Event.ON_MONEY_CHANGE,function ()
            MainUIMenu.onRedPoint();
        end); -- 金钱变化时头像红点显示(很多系统需要金钱来升级)
        EventManager.bind(this.gameObject, Event.ON_EVENT_EQUIP_CHANGE,function ()
            MainUIMenu.onRedPoint();
        end); -- 穿戴装备变化时头像红点显示(替换装备时宝石可能可以镶嵌)
        EventManager.bind(this.gameObject, Event.ON_GEM_PUT_OR_REMOVE,function ()
            MainUIMenu.onRedPoint();
        end); -- 宝石镶嵌/拆卸时头像红点显示

        EventManager.bind(this.gameObject, Event.ON_EVENT_GEM_CHANGE,function ()
            MainUIMenu.onRedPoint();
        end); -- 获得宝石时头像红点显示(宝石镶嵌/合成)
        EventManager.bind(this.gameObject, Event.ON_HORSE_UNLOCK_OR_CANUPGRADE,function ()
            MainUIMenu.onRedPoint();
        end); -- 坐骑解锁成功消除红点显示


        EventManager.bind(this.gameObject,Event.ON_EVENT_EQUIP_CHANGE, function() 
            MainUIMenu.OnBagChange();
            MainUIMenu.showRedPoint();
            end);
        EventManager.bind(this.gameObject,Event.ON_EVENT_ITEM_CHANGE, function()
            MainUIMenu.OnBagChange();
            MainUIMenu.showRedPoint();
            end);
        EventManager.bind(this.gameObject,Event.ON_EVENT_GEM_CHANGE, function() 
            MainUIMenu.OnBagChange();
            MainUIMenu.showRedPoint();
            end);

        this:BindLostFocus(function()
            this:Delay(0.3, MainUIMenu.showRedPoint);
            MainUIMenu.CloseMenu()
            end );
        local btn = this:GO('menuPanel.menuGroup.Btn');
        btn:Hide();
        for i=1, #menuOpenLevel do
            local item = newObject(btn);
            item.transform:SetParent(menuGroup.transform);
            item.gameObject.name = "Btn"..i;
            item:BindButtonClick(MainUIMenu[menuItemFun[i]]);
            item:GO('Icon').sprite = menuItemIcon[i];
            menuItem[i] = item;
        end

        MainUIMenu.ShowMenu();
        btnMenu:BindButtonClick(function()
            if not const.OpenMenuFlag then
                MainUIMenu.OpenMenu()
            else
                MainUIMenu.CloseMenu()
            end;
            MainUIMenu.checkMenuRedPoint();
        end);

        bagRePoint = this:GO('bagPanel.Bag.flag');

        MainUIMenu.OnBagChange();
    end

    function  MainUIMenu.openBag(go)
        const.KeepOpenMenu = true;
        PanelManager:CreatePanel('NewUIRole', UIExtendType.TRANSMASK, {panelType = "Bag"});
        AudioManager.PlaySoundFromAssetBundle("open_bag");
    end

    -- 显示菜单
    function MainUIMenu.ShowMenu()
        local level = DataCache.myInfo.level;
        local countLimit = 5;   --竖排数量限制(默认5)
        local ratio = Screen.width / Screen.height;
        if ratio <= 1.474 then
            countLimit = 7;
        elseif ratio <= 1.667 then
            countLimit = 6;
        end
        local showCount = 0;
        local grid1 = menuGroup:GO('Grid1');
        local grid2 = menuGroup:GO('Grid2');
        for i=1, #menuItem do
            if level >= menuOpenLevel[i] then
                menuItem[i].gameObject:SetActive(true);
                showCount = showCount + 1;
                if showCount <= countLimit then
                    menuItem[i].transform:SetParent(grid1.transform);
                else
                    menuItem[i].transform:SetParent(grid2.transform);
                end

                local rt = menuItem[i]:GetComponent("RectTransform");
                rt:SetAsLastSibling();
            else
                menuItem[i].gameObject:SetActive(false);
            end
        end
    end

    function MainUIMenu.OpenMenu()
        -- 缩进隐藏
        if not const.OpenMenuFlag then
            const.OpenMenuFlag = true;
            const.OpenSkillFlag = false;

            MainUIMenu.ShowMenu()

            btnMenu:GO('image').transform:DOLocalRotate(Vector3.New(0,0,-45), 0.3, DG.Tweening.RotateMode.LocalAxisAdd);
            menuPanel.transform:DOLocalMoveX(panelPos.x , 0.3, false);

            EventManager.onEvent(Event.ON_SKILL_HIDE);
        end
    end

    function MainUIMenu.CloseMenu()
        if const.OpenMenuFlag then
            const.OpenMenuFlag = false;
            const.OpenSkillFlag = true;
            btnMenu:GO('image').transform:DOLocalRotate(Vector3.New(0,0,45), 0.3, DG.Tweening.RotateMode.LocalAxisAdd);
            menuPanel.transform:DOLocalMoveX(panelPos.x + 300, 0.3, false);
            EventManager.onEvent(Event.ON_SKILL_SHOW);
            if const.KeepOpenMenu then
                const.OpenMenuFlag = true;
                const.OpenSkillFlag = false;
                btnMenu:GO('image').transform.rotation = Vector3.New(0,0,315);
                menuPanel.transform:DOLocalMoveX(panelPos.x , 0.3, false);
                EventManager.onEvent(Event.ON_SKILL_HIDE);
            end
            const.KeepOpenMenu = false;
        end
    end

    function MainUIMenu.ShowRole()
        const.KeepOpenMenu = true;
        if client.horse.horseTableCache then
            PanelManager:CreatePanel('NewUIRole', UIExtendType.TRANSMASK, {panelType = "Role"}); 
            return;
        end
        client.horse.getServerHorse(function () 
            PanelManager:CreatePanel('NewUIRole', UIExtendType.TRANSMASK, {panelType = "Role"});
        end)
    end
    function MainUIMenu.ShowEquip()
        const.KeepOpenMenu = true;
        ui.showWorkShopNew(1);
    end
    function MainUIMenu.ShowSkill()
        const.KeepOpenMenu = true;
        ui.ShowSkill();
    end
    function MainUIMenu.ShowLegion()
        const.KeepOpenMenu = true;
        ShowLegion();
    end
    function MainUIMenu.ShowSetting()
        const.KeepOpenMenu = true;
        PanelManager:CreatePanel('UISetting',  UIExtendType.TRANSMASK, {});
    end
    function MainUIMenu.ShowShenyou()
        --const.KeepOpenMenu = true;
        ui.showMsg("暂未开放")
    end
    function MainUIMenu.ShowFuwen()
        --const.KeepOpenMenu = true;
        ui.showMsg("暂未开放")
    end

    function  MainUIMenu.OnBagChange()
        local heavy = Bag.isBagHeavy();
        local full =  Bag.isBagFull();
        bagFull:SetActive(full);
        beiBaoMan:SetActive(false);
    end

    -- 检查菜单按钮上的红点
    function MainUIMenu.checkMenuRedPoint()
        if const.OpenMenuFlag then
            menuRed:Hide();
        else
            if --[[client.redPoint.HorseCanTrainOrEnhance() or client.redPoint.HorseCanUnlock() or -- NSY-4742 临时注释]]client.redPoint.GemCanPutOn() or client.redPoint.Skill() or client.legion.is_legion_have_new_info() then
                menuRed:Show();
            else
                menuRed:Hide();
            end
        end
    end

    -- 检查主界面背包图标红点
    function MainUIMenu.checkBagRedPoint()
        if client.redPoint.CanPutOnBetterEuip() then
            bagRePoint:Show();
        else
            bagRePoint:Hide();
        end
    end

    -- 显示菜单角色按钮红点
    function MainUIMenu.checkRoleRedPoint()
        if --[[client.redPoint.HorseCanTrainOrEnhance() or client.redPoint.HorseCanUnlock()-- NSY-4742 临时注释 并且加了一个 false]] false then
            menuItem[tonumber(menuId["role"])]:GO("redPoint"):Show();
        else
            menuItem[tonumber(menuId["role"])]:GO("redPoint"):Hide();
        end
    end

    -- 显示菜单装备按钮红点
    function MainUIMenu.checkEquipRedPoint()
        if client.redPoint.GemCanPutOn() or client.redPoint.EquipCanEnhance() then
            menuItem[tonumber(menuId["equip"])]:GO("redPoint"):Show();
        else
            menuItem[tonumber(menuId["equip"])]:GO("redPoint"):Hide();
        end
    end

    -- 显示菜单技能按钮红点
    function MainUIMenu.checkSkillRedPoint()
        if client.redPoint.Skill() then
            menuItem[tonumber(menuId["skill"])]:GO("redPoint"):Show();
        else
            menuItem[tonumber(menuId["skill"])]:GO("redPoint"):Hide();
        end 
    end

    -- 显示菜单工会按钮红点
    function MainUIMenu.checkLegionRedPoint()
        if client.legion.is_legion_have_new_info() then
            menuItem[tonumber(menuId["gonghui"])]:GO("redPoint"):Show();
        else
            menuItem[tonumber(menuId["gonghui"])]:GO("redPoint"):Hide();
        end 
    end

    function MainUIMenu.showRedPoint()
        MainUIMenu.onRedPoint();
    end


    function MainUIMenu.onRedPoint()
        MainUIMenu.checkBagRedPoint();
        MainUIMenu.checkRoleRedPoint();
        MainUIMenu.checkEquipRedPoint();
        MainUIMenu.checkSkillRedPoint();
        MainUIMenu.checkLegionRedPoint();
        MainUIMenu.checkMenuRedPoint();
    end

    function MainUIMenu.Hide()
        menuPanel.transform:DOLocalMoveX(panelPos.x + 600, 0.5, false);
        bagPanel.transform:DOLocalMoveX(bagPos.x + 600, 0.5, false);
    end

    function MainUIMenu.Show()
        bagPanel.transform:DOLocalMoveX(bagPos.x, 0.3, false);
        if const.OpenMenuFlag then
            menuPanel.transform:DOLocalMoveX(panelPos.x, 0.3, false);
        end
    end

    return MainUIMenu;
end