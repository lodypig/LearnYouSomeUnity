function UIMenuView ()
	local UIMenu = {};
	local this = nil;
    local suijifubenopenlevel = 40

	local juese = nil;
    local gongfang = nil;
    local jineng = nil;
    
    local moling = nil;
    local zuoqi = nil;
    local fuwen = nil;

    -- local juewei = nil;
    -- local richang = nil;
    -- local fuben = nil;
    -- local huodong = nil;
    -- local jingji = nil;
    local beibao = nil;
	local juntuan = nil;
    local yuliu = nil;
    local jiaoyihang = nil;
	local paihangbang = nil;
    local chengjiu = nil;
    local shezhi = nil;
    
    -- local lock1 = nil;
    -- local lock2 = nil;
    -- local lock3 = nil;
    local BackGround = nil;

    -- local fuli = nil;
    local leftPanelPos = nil;
    local rightPanelPos = nil;
    local bottomPanelPos = nil;
    local leftPanel = nil;
    local rightPanel = nil;
    local bottomPanel = nil;

    local HideTime = 0.5;
    local ShowTime = 0.3;
    local HideDistance = 300;

    local scale = nil;
    local suijifuben = nil;


	function UIMenu.Start ()
		this = UIMenu.this;
		BackGround = this:GO('_BackGround');
		juese = this:GO('LeftPanel._juese');
        jineng = this:GO('LeftPanel._jineng');
        gongfang = this:GO('LeftPanel._gongfang');
        -- zuoqi = this:GO('LeftPanel._zuoqi');
        -- moling = this:GO('LeftPanel._moling');
        -- juewei = this:GO('LeftPanel._juewei');
        moling = this:GO('RightPanel._moling');
        zuoqi = this:GO('RightPanel._zuoqi');
        fuwen = this:GO('RightPanel._fuwen');
        -- richang = this:GO('RightPanel._richang');
        -- fuben = this:GO('RightPanel._fuben');
        -- huodong = this:GO('RightPanel._huodong');
        -- jingji = this:GO('RightPanel._jingji');
        beibao = this:GO('BottomPanel._beibao');
		juntuan = this:GO('BottomPanel._juntuan');
        yuliu = this:GO('BottomPanel._yuliu');
        jiaoyihang = this:GO('BottomPanel._jiaoyihang');
		paihangbang = this:GO('BottomPanel._paihangbang');
        chengjiu = this:GO('BottomPanel._chengjiu');
        shezhi = this:GO('BottomPanel._shezhi');
        -- lock1 = this:GO('BottomPanel._lock1');
        -- lock2 = this:GO('BottomPanel._lock2');
        -- lock3 = this:GO('BottomPanel._lock3');
        -- fuli = this:GO('BottomPanel.fuli');
        --suijifuben = this:GO('RightPanel._suijifuben');
        --suijifuben.gameObject:SetActive(DataCache.myInfo.level >= suijifubenopenlevel)


        leftPanel = this:GO('LeftPanel').gameObject;
        rightPanel = this:GO('RightPanel').gameObject;
        bottomPanel = this:GO('BottomPanel').gameObject;

        BackGround:BindButtonClick(UIMenu.closeSelf);

        juese:BindButtonClick(UIMenu.ShowRole);
        gongfang:BindButtonClick(UIMenu.ShowQiangHua);
        jineng:BindButtonClick(UIMenu.ShowSkill);

        moling:BindButtonClick(UIMenu.ShowMoLing);

        zuoqi:BindButtonClick(UIMenu.ShowZuoqi);
        fuwen:BindButtonClick(UIMenu.showMsg);
        --juewei:BindButtonClick(UIMenu.ShowMsg);
        --richang:BindButtonClick(UIMenu.ShowMsg);
        --fuben:BindButtonClick(UIMenu.ShowFuben);
        --huodong:BindButtonClick(UIMenu.ShowActivity);
        --jingji:BindButtonClick(UIMenu.ShowMsg);
        beibao:BindButtonClick(UIMenu.ShowBag);
        juntuan:BindButtonClick(ShowLegion);
        yuliu:BindButtonClick(UIMenu.ShowMsg);
        jiaoyihang:BindButtonClick(UIMenu.openJiaoYiHang);
        paihangbang:BindButtonClick(UIMenu.ShowRankingList);
        chengjiu:BindButtonClick(UIMenu.ShowChengjiu);
        shezhi:BindButtonClick(UIMenu.openSetting);
        -- lock1:BindButtonClick(ui.unOpenFunc);
        -- lock2:BindButtonClick(UIMenu.ShowMsg2);
        -- lock3:BindButtonClick(UIMenu.ShowMsg2);
        -- fuli:BindButtonClick(UIMenu.ShowFuli);
        --suijifuben:BindButtonClick(UIMenu.SuiJiFuBen);

        SetPort("start_prepare",UIMenu.test2);

        EventManager.bind(this.gameObject, Event.ON_EVENT_RED_POINT, UIMenu.onRedPoint);
        EventManager.bind(this.gameObject, Event.ON_LEVEL_UP, UIMenu.showRedPoint);  -- 技能升级，刷新红点显示

        

        EventManager.bind(this.gameObject, Event.ON_TALENT_ZHUANJING_UNLOCK,function ()
            UIMenu.onRedPoint();
        end); -- 天赋解锁/专精解锁检查技能红点

        EventManager.bind(this.gameObject, Event.ON_TALENTBOOK_CHANGE,function ()
            UIMenu.onRedPoint();
        end); -- 天赋书变化检查技能红点

        EventManager.bind(this.gameObject, Event.ON_HORSE_UNLOCK_OR_CANUPGRADE,function ()
            UIMenu.onRedPoint();
        end); -- 坐骑解锁/培养至可进阶时检查坐骑红点提示
        EventManager.bind(this.gameObject, Event.ON_GEM_PUT_OR_REMOVE,function ()
            UIMenu.onRedPoint();
        end); -- 宝石拆卸/镶嵌时检查工坊红点提示
        EventManager.bind(this.gameObject, Event.ON_EVENT_ITEM_CHANGE,function ()
            UIMenu.onRedPoint();
        end); -- 物品变化时检查坐骑红点提示
        EventManager.bind(this.gameObject, Event.ON_EVENT_EQUIP_CHANGE,function ()
            UIMenu.onRedPoint();
        end); -- 穿的装备变化时检查工坊红点提示
        EventManager.bind(this.gameObject, Event.ON_EVENT_GEM_CHANGE,function ()
            UIMenu.onRedPoint();
        end); -- 宝石变化时检查工坊红点提示
        EventManager.bind(this.gameObject, Event.ON_MONEY_CHANGE,function ()
            UIMenu.onRedPoint();
        end); -- 金钱变化时检查 技能/坐骑/工坊 红点显示
        EventManager.bind(this.gameObject, Event.ON_RECEIVE_TILI_CHANGE,function ()
            UIMenu.onRedPoint();
        end); -- 福利领取时机变化时检查红点显示
        EventManager.bind(this.gameObject, Event.ON_TILI_CHANGE,function ()
            UIMenu.onRedPoint();
        end); -- 福利领取之后去除红点显示
        EventManager.bind(this.gameObject, Event.ON_CBT_Changed,function ()
            UIMenu.onRedPoint();
        end); -- 挖宝次数变化时检查红点提示

        EventManager.bind(this.gameObject,Event.ON_NEW_SYSTEM_OPEN_FLAG_CHANGE,UIMenu.onNewPoint); -- 新系统开放标识变化时检查“新”标识显示

        EventManager.bind(this.gameObject,Event.ON_LEVEL_UP,function ()
            UIMenu.CheckIcon( )
        end);

        UIMenu.CheckIcon( );

        UIMenu.showRedPoint();
        UIMenu.showNewPoint();

        AudioManager.PlaySoundFromAssetBundle("open_menu");
        juese:GO('flag'):Hide();

	end

    function UIMenu.CheckIcon( )
        if DataCache.myInfo.level >= 10 then
            jineng:GO('Image'):Show();
            jineng:GO('lock'):Hide();
        else
            jineng:GO('Image'):Hide();
            jineng:GO('lock'):Show();
        end

        if DataCache.myInfo.level >= 30 then
            paihangbang:GO('Image'):Show();
            paihangbang:GO('lock'):Hide();
        else
            paihangbang:GO('Image'):Hide();
            paihangbang:GO('lock'):Show();
        end

        if DataCache.myInfo.level >= 35 then
            jiaoyihang:GO('Image'):Show();
            jiaoyihang:GO('lock'):Hide();
        else
            jiaoyihang:GO('Image'):Hide();
            jiaoyihang:GO('lock'):Show();
        end
    end

    function UIMenu.showRedPoint()
        UIMenu.onRedPoint();
    end

    function UIMenu.onRedPoint()
        -- local fashionSuitRedPoint = juese:GO('flag');
        -- if FashionSuit.hasFashionSuitRedPoint then
        --     fashionSuitRedPoint:Show();
        -- else
        --     fashionSuitRedPoint:Hide();
        -- end

        local legionRedPoint = juntuan:GO('flag')
        local legionNewFlag = juntuan:GO('newFlag')

        legionNewFlag:Hide();
        legionRedPoint:Hide();
        if client.legion.is_have_apply_flag() or client.newSystemOpen.isSystemOpen("legion") then
            legionNewFlag:Show();
        else
            if client.legion.is_legion_have_new_info() then                
                legionRedPoint:Show();
            end
        end
------------------------技能红点---------------------------------
        local skillFlag = jineng:GO('flag');
        if client.redPoint.Skill() then
            skillFlag:Show();
        else
            skillFlag:Hide();
        end  
------------------------坐骑红点---------------------------------
        local horseFlag = zuoqi:GO('flag');
        if --[[client.redPoint.HorseCanTrainOrEnhance() or client.redPoint.HorseCanUnlock()--NSY-4742 临时注释 并且加了false]] false then
            horseFlag:Show();
        else
            horseFlag:Hide();
        end   
------------------------工坊红点---------------------------------
        local workShopFlag = gongfang:GO('flag');--or client.redPoint.EquipCanEnhance() or client.redPoint.GemCanUpGrade()
        if client.redPoint.GemCanPutOn() or client.redPoint.EquipCanEnhance() then
            workShopFlag:Show();
        else
            workShopFlag:Hide();
        end
    end

    function UIMenu.showNewPoint()
        UIMenu.onNewPoint();
    end



    function UIMenu.onNewPoint()
        local workShopFlag = gongfang:GO('newFlag');
        if client.newSystemOpen.isSystemOpen("gem") then
            workShopFlag:Show();
        else
            workShopFlag:Hide();
        end

        local horseFlag = zuoqi:GO('newFlag');
        if client.newSystemOpen.isSystemOpen("horse") then
            horseFlag:Show();
        else
            horseFlag:Hide();
        end

        -- local fashionSuitFlag = juese:GO('newFlag');
        -- if client.newSystemOpen.isSystemOpen("fashionSuit") then
        --     fashionSuitFlag:Show();
        -- else
        --     fashionSuitFlag:Hide();
        -- end

        local legionFlag = juntuan:GO('newFlag');
        if client.newSystemOpen.isSystemOpen("legion") then
            legionFlag:Show();
        else
            legionFlag:Hide();
        end

        -- local fubenFlag = fuben:GO('newFlag');
        -- if client.newSystemOpen.isSystemOpen("fuben") then
        --     fubenFlag:Show();
        -- else
        --     fubenFlag:Hide();
        -- end
    end

    
	function UIMenu.OnDestroy( )
		-- body
        AudioManager.PlaySoundFromAssetBundle("close_menu");
	end

    function UIMenu.closeSelf()
        destroy(this.gameObject);
	end
    

    function UIMenu.ShowMsg()
        ui.unOpenFunc();
    end

    function UIMenu.ShowMsg2()
        ui.unOpenFunc();
    end

    function UIMenu.ShowZuoqi()
        ui.showHorse();
    end

    function UIMenu.ShowMoLing( )
        ui.unOpenFunc();
    end

    function UIMenu.ShowTask()
        PanelManager:CreatePanel('UITask' , UIExtendType.BLACKMASK, {});
    end

    function UIMenu.ShowRole()
        --UIManagerNew.CreateUI('NewUIRole', {panelType = "Role"});
        PanelManager:CreatePanel('NewUIRole',  UIExtendType.NONE, {panelType = "Role"});
    end

    function UIMenu.ShowSkill()
        -- PanelManager:CreatePanel('UINewSkill' , UIExtendType.BLACKMASK, {});
        if DataCache.myInfo.level < 10 then
            ui.showMsg("10级开启");
            return
        end
        ui.ShowSkill();
    end

    function UIMenu.ShowQiangHua()
        if DataCache.myInfo.level < 8 then
            ui.showMsg("8级解锁强化系统");
        else
            ui.showWorkShopNew(1);
        end
    end

    function UIMenu.ShowActivity()
        if DataCache.myInfo.level < 20 then
            ui.showMsg("20级解锁活动");
        else
            -- print("create ui");
            PanelManager:CreatePanel('UIActivity' , UIExtendType.NONE, {});
        end
    end

    function UIMenu.ShowChengjiu()
        UIMenu.ShowMsg();
    end

    function UIMenu.ShowBag()
        PanelManager:CreatePanel('NewUIRole',  UIExtendType.NONE,{panelType = "Bag"});
    end

    function UIMenu.openSetting()
    	PanelManager:CreatePanel('UISetting',  UIExtendType.NONE, {});
    end

    function UIMenu.openSmelt()
        PanelManager:CreatePanel('UISmelt' , UIExtendType.NONE, {});
    end

    function UIMenu.ShowRankingList()
        if DataCache.myInfo.level < 30 then
            ui.showMsg("排行榜30级解锁！");
        else
            PanelManager:CreatePanel('UIRankingList',UIExtendType.NONE,nil);
        end
    end

    function UIMenu.ShowFuli()
       ui.unOpenFunc();
    end

    function UIMenu.openJiaoYiHang()
        if DataCache.myInfo.level < 35 then
            ui.showMsg("交易行35级解锁！");
        else
            PanelManager:CreatePanel('UIAuction' , UIExtendType.NONE, {});
        end 
    end

    function UIMenu.test1()
        local msg = {cmd = "quit_fuben", fubenId = 0} --10001
        Send(msg)       
    end

    function UIMenu.test2(msg)
        local leaderId = msg["leaderId"];
        local fubenId = msg["fubenId"] 
    end

    function UIMenu.ShowFuben()
        if DataCache.myInfo.level < 27 then
            ui.showMsg("27级解锁副本");
        else
            local scene = tb.SceneTable[DataCache.scene_sid];
            if not scene.transfer then
                ui.showMsg("当前地图无法查看副本界面");
                return;
            end
            PanelManager:CreatePanel('UIFuben',  UIExtendType.BLACKMASK, {});
        end
    end

    function UIMenu.FirstUpdate()
        scale = this:GetComponent("RectTransform").localScale;
        local temp = leftPanel:GetComponent("RectTransform").localPosition;
        leftPanelPos = this:GetComponent("RectTransform"):TransformPoint(temp);
        temp = rightPanel:GetComponent("RectTransform").localPosition;
        rightPanelPos = this:GetComponent("RectTransform"):TransformPoint(temp);
        temp = bottomPanel:GetComponent("RectTransform").localPosition;
        bottomPanelPos = this:GetComponent("RectTransform"):TransformPoint(temp);
    end

    function UIMenu.SuiJiFuBen(go)
        local scene = tb.SceneTable[DataCache.scene_sid];
        if not scene.transfer then
            ui.showMsg("特殊区域，无法执行该操作");
            return;
        end
        client.fuben.q_auto_challenge_fuben()
    end

    function UIMenu.HideUI()
        local position = leftPanel.transform.position;
        position.x = position.x - HideDistance * scale.x;
        iTween.MoveTo(leftPanel,position,HideTime);
        position = rightPanel.transform.position;
        position.x = position.x + HideDistance * scale.x;
        iTween.MoveTo(rightPanel,position,HideTime);
        position = bottomPanel.transform.position;
        position.y = position.y - HideDistance * scale.x;
        iTween.MoveTo(bottomPanel,position,HideTime);
        BackGround.gameObject:SetActive(false);
    end

    function UIMenu.ShowUI()
        iTween.MoveTo(leftPanel,leftPanelPos,ShowTime);
        iTween.MoveTo(rightPanel,rightPanelPos,ShowTime);
        iTween.MoveTo(bottomPanel,bottomPanelPos,ShowTime);
        BackGround.gameObject:SetActive(true);
    end

-----------------------------技能红点判断-----------------------
    function UIMenu.IsHaveTalentBook()
        return DataCache.talentBook > 0;
    end
    function UIMenu.IsHaveSkillCanUpGrade()
        return true;
        --[[
        local flag = false;
        local avatarCtrl = DataCache.me:GetComponent("AvatarController");
        for i=1,4 do
            local activeSkillInfo = avatarCtrl:GetSkillByTypeAndIndex(const.skillType[i][1], const.skillType[i][2]);

            if activeSkillInfo ~= nil then
                local nextLevelSkillInfo = SkillUpTable[activeSkillInfo.Level][i];
                if not( nextLevelSkillInfo == nil or (nextLevelSkillInfo.cost == 0 and nextLevelSkillInfo.level == 0) 
                    or (nextLevelSkillInfo.level > DataCache.myInfo.level or nextLevelSkillInfo.cost > DataCache.role_money) ) then

                        flag = true;
                        break;
                end
            end
        end
        return flag;
        --]]
    end
-----------------------------技能红点判断-----------------------

	return UIMenu;
end
