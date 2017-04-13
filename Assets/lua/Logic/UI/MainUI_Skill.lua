function MainUISkillView()
    local MainUISkill = {};
    local this = nil;

    local skillicon_clickeffect = {}
    local skillPanel = nil;
    local panelPos = nil;
    local autofight = nil;
    local function isLockSkill(skillId)
        local ability = DataCache.myInfo.ability;        
        for i= 1, #ability do
            if ability[i][1] == skillId then
                return false;
            end
        end
        return true;
    end

	function  MainUISkill.Start()      
		this = MainUISkill.this;
        
        EventManager.bind(this.gameObject,Event.ON_FIGHT_STATE_TIME,MainUI.onFightStateChanged);
        EventManager.bind(this.gameObject,Event.ON_ATTR_CHANGE, MainUI.UpdateEnergy);
        EventManager.bind(this.gameObject,Event.ON_MAINUI_HIDE, MainUISkill.Hide);
        EventManager.bind(this.gameObject,Event.ON_SKILL_HIDE, MainUISkill.Hide);

        EventManager.bind(this.gameObject,Event.ON_MAINUI_SHOW, MainUISkill.Show)
        EventManager.bind(this.gameObject,Event.ON_SKILL_SHOW, MainUISkill.Show)
        EventManager.bind(this.gameObject,Event.ON_LEVEL_UP, MainUISkill.ShowHorseIcon)
        -- 自动战斗
        EventManager.bind(this.gameObject,Event.ON_AUTO_FIGHT_CHANGE, MainUISkill.onSetAutoFight);
        --设置技能图标
        MainUI.formatSkillIcon();

        skillPanel = this:GO('SkillPanel');
        panelPos = skillPanel.transform.localPosition;
        MainUISkill.ShowHorseIcon();
        this:GO('SkillPanel.autofight'):BindButtonClick(MainUISkill.onAutoFightBtnClick);
        this:GO('SkillPanel.HorseBtn.Image'):BindButtonClick(MainUI.switchRide);
	end

    function MainUISkill.onSetAutoFight()
        local player = AvatarCache.me;
        local is_auto_fighting = player.is_auto_fighting;
        MainUISkill.showAutoFightEffect(is_auto_fighting);
    end

    function MainUISkill.onAutoFightBtnClick()
        if SceneManager.IsCurrentFubenMap() then
            FubenManager.OnNotify(FubenHandlerType.OnAutoFight, {});
        else
            local player = AvatarCache.me;
            local is_auto_fighting = player.is_auto_fighting;
            is_auto_fighting = not is_auto_fighting;
            -- 开启角色挂机
            local class = Fight.GetClass(player);
            class.HandUpAndShowMsg(player, is_auto_fighting);
            MainUISkill.showAutoFightEffect(is_auto_fighting);
        end
    end

    function MainUISkill.showAutoFightEffect(enable)
        local btn = this:GO('SkillPanel.autofight');
        if enable then
            btn:PlayUIEffectForever(this.gameObject, "zidongzhandou");
            --强制下马
            client.horse.RideHorse(false)
        else
            btn:StopAllUIEffects();
        end
    end

    function MainUISkill.ShowHorseIcon()
        if DataCache.myInfo.level < 18 then
            this:GO('SkillPanel.HorseBtn').gameObject:SetActive(false);
        else
            this:GO('SkillPanel.HorseBtn').gameObject:SetActive(true);
        end
    end

    function MainUISkill.Hide()
        skillPanel.transform:DOLocalMoveX(panelPos.x + 600, 0.5, false);
    end

    function MainUISkill.Show()
        if const.OpenSkillFlag then
            skillPanel.transform:DOLocalMoveX(panelPos.x, 0.3, false);
        end
    end

    function MainUISkill.FirstUpdate()
        local career = DataCache.myInfo.career;
        local idList = const.ProfessionAbility[career];
        for i = 1,#idList do
            local skillID = idList[i];
            local skillInfo = tb.SkillTable[skillID];
            local str = 'SkillPanel.btn'..i..".Image.Icon";
            this:GO(str).sprite = skillInfo.icon;
  
            local effectname = ""
            if i ~= 1 then
                this:GO('SkillPanel.btn'..i..'.lock').gameObject:SetActive(isLockSkill(skillID));
                effectname = "quanquan_xiao_"..career
            else
                if career == "bowman" or career == "magician" then
                    this:GO(str):PlayUIEffectForever(this.gameObject, "jinengdongtai_"..career);
                end
                effectname = "quanquan_"..career
            end

            --修改为Async加载 不然如果是同步加载会跟上面的PlayUIEffectForever(异步加载)出现加载AB冲突的warning  by linh
            this:LoadUIEffectAsync(this.gameObject, effectname, true, true, function(effect)
                skillicon_clickeffect[i] = effect
                skillicon_clickeffect[i].transform:SetParent(this:GO(str).transform)
                skillicon_clickeffect[i].transform.localScale = Vector3.one;
                skillicon_clickeffect[i].transform.localPosition = Vector3.zero;
                skillicon_clickeffect[i].gameObject:SetActive(false)
            end);
        end
        MainUI.UpdateEnergy();
    end

    function MainUI.switchRide( )
        --尝试准备坐骑数据
        if DataCache.myInfo.level < client.horse.OPEN_LEVEL then
            ui.showMsg("坐骑"..client.horse.OPEN_LEVEL .."级开放");
            return;
        end
        local ac = AvatarCache.me;
        --是否处于战斗状态
        if DataCache.myInfo.fight_state_time > 0 or (ac ~= nil and ac.is_auto_fighting) then
            ui.showMsg("战斗中无法骑乘")
            return;
        end
        --当前地图是否可以骑乘
        local mapsid = DataCache.scene_sid
        if tb.AreaTable[mapsid] ~= nil and tb.AreaTable[mapsid].default.rider == false then
            ui.showMsg("该地图无法骑乘")
            return;
        end
        
        if not client.horse.checkCanRide() then
            ui.showMsg("坐骑升阶后方可骑乘");
        else
            --点击当即设置状态机骑乘动作
            local param = uFacadeUtility.GetAnimatorFloat(AvatarCache.me.id, "IsRiding");
            if param == 1.0 then
                uFacadeUtility.SetAnimatorFloat(AvatarCache.me.id, "IsRiding", 0);
            else
                uFacadeUtility.SetAnimatorFloat(AvatarCache.me.id, "IsRiding", 1.0);
            end
            --并立即切换限制
            client.horse.SwitchRideHorse()
        end
    end

    function MainUI.formatSkillIcon()
        local career = DataCache.myInfo.career;
        local idList = const.ProfessionAbility[career];
        for i = 1,#idList do
            local skillID = idList[i];
            local skillInfo = tb.SkillTable[skillID];
            local str = 'SkillPanel.btn'..i..".Image.Icon";
            this:GO(str).sprite = skillInfo.icon;
            
            local skillBtn = this:GO('SkillPanel.btn'..i..".Image");
            skillBtn:SetUserData("index", i);
            skillBtn:BindButtonMultipleClick(function(go)
                if go ~= nil then
                    local wrapper = go:GetComponent("UIWrapper");
                    if wrapper ~= nil then
                        local index = wrapper:GetUserData("index");
                        if skillicon_clickeffect[index] ~= nil then
                            local effect = skillicon_clickeffect[index].gameObject;
                            effect:SetActive(false);
                            effect:SetActive(true);
                        end

                        --print("skill button down");

                        --前台判断是否进入开战状态
                        MainUI.setClientFightState();
                        -------------------------------
                        --此时要强制下马
                        --client.horse.RideHorse(false)
                    end
                end
            end);

        end
    end

    local expandSkillDelayCallId = 0;
    local newSkillUnLock = false;           -- 标志新技能正在解锁
    function MainUI.setClientFightState(  )
        --只有后台为非战状态时，前台才会进入一个假的开战状态(展开技能)
        if expandSkillDelayCallId ~= 0 then
            this:CancelDelay(expandSkillDelayCallId);
            expandSkillDelayCallId = 0;
        end

        if DataCache.myInfo.fight_state_time == 0 then
            -- print("expand skill: open");
            MainUI.expandSkillPanel(true)
            expandSkillDelayCallId = this:Delay(5, function()
                    expandSkillDelayCallId = 0;
                    if DataCache.myInfo.fight_state_time == 0 then
                        MainUI.expandSkillPanel(false)
                        -- print("expand skill: close");
                    end
                end);
        end
    end

    function MainUI.onFightStateChanged( )

        if expandSkillDelayCallId ~= 0 then
            this:CancelDelay(expandSkillDelayCallId);
            expandSkillDelayCallId = 0;
        end

        local show = (DataCache.myInfo.fight_state_time > 0) or newSkillUnLock;
        
        
        MainUI.expandSkillPanel(show);
        --骑乘相关控制
        if DataCache.myInfo.fight_state_time > 0 then
            --入战
            --立即下马
            client.horse.RideHorse(false)
        else
            --脱战
            --检查是否骑乘
            client.horse.FightLeaveRideCheck()
        end
    end

    function MainUI.expandSkillPanel(bExpand)
        local skillPanelWp = this:GO('SkillPanel');
        if skillPanelWp == nil then
          	--print("Skill Panel Wp");
            return;
        end
        local animator = skillPanelWp:GetComponent("Animator");
        if animator == nil then
          	--print("animator is nil");
        end
        if bExpand then
            -- Fight.CrossFightIdle(AvatarCache.me, "SwitchFight", 0.0, 1.0, 1);
            uFacadeUtility.SetAnimatorFloat(AvatarCache.me.id, "SwitchFight", 1.0);
            if not uFacadeUtility.IsCurrentStateOf(animator, "open") then
                animator:Play("open");
            end
        else
            Fight.CrossFightIdle(AvatarCache.me, "SwitchFight", 1.0, 0.0, 2);
            if not uFacadeUtility.IsCurrentStateOf(animator, "close") then
                animator:Play("close");
            end
        end
    end

    local function GetSkillIndex(id)
        local career = DataCache.myInfo.career;
        local idList = const.ProfessionAbility[career];
        for i = 1,#idList do
            local skillID = idList[i];
            if skillID == id then
                return i;
            end
        end
        return 0;
    end

    function MainUI.OpenSkillPanel()
        -- 存在新技能解锁时，将正在解锁标志置为true、cacel掉 技能面板缩回、强制展开技能面板
        newSkillUnLock = true;
        if expandSkillDelayCallId ~= 0 then
            this:CancelDelay(expandSkillDelayCallId);
            expandSkillDelayCallId = 0;
        end
        MainUI.expandSkillPanel(true);
    end

    function MainUI.UnlockSkill(skillID)
        local index = GetSkillIndex(skillID);
        local skillBtn = this:GO('SkillPanel.btn'..index);
        local skillInfo = tb.SkillTable[skillID];
        skillBtn:PlayUIEffect(this.gameObject, "jinengjiesuo", 1);
        skillBtn:GO('lock').gameObject:SetActive(isLockSkill(skillID));
        -- 技能解锁所有的特效播完之后，若此时不处于战斗状态，5秒后将技能面板收回，同时将技能解锁标志置为false
        newSkillUnLock = false;
        MainUI.setClientFightState();

    end

    function MainUI.UpdateEnergy()
        local percent = DataCache.myInfo.energy * 0.01
        local career = DataCache.myInfo.career;
        this:GO("SkillPanel.btn4.Image.energy").fillAmount = percent;
        local skillID = const.ProfessionAbility[career][4];
        local skillInfo = tb.SkillTable[skillID];
        if DataCache.myInfo.energy < skillInfo.energy then
            this:GO("SkillPanel.btn4.Image.mengban").gameObject:SetActive(true);
        else
            this:GO("SkillPanel.btn4.Image.mengban").gameObject:SetActive(false);
        end
    end

    return MainUISkill;
end

    
