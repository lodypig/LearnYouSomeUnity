function MainUITargetView()
    local MainUITarget = {};
    local this = nil;

    local playSelectTargetEffectFlag = {};

    local last_sectionper = nil
    -- local boss_blood_effect_1 = nil;
    -- local boss_blood_effect_2 = nil;
    local panelPos = nil;

    local Max_Section = 10

    function  MainUITarget.Start()      
        this = MainUITarget.this;

        --选中区域
        MainUI.selectpanel = this:GO('selectpanel'); 
        panelPos = MainUI.selectpanel.transform.localPosition;

        MainUI.select_npc = this:GO('selectpanel.npc');
        MainUI.select_npc:Hide();
        MainUI.select_player = this:GO('selectpanel.player');
        MainUI.select_player:Hide();
        MainUI.select_boss = this:GO('selectpanel.boss');
        MainUI.select_boss:Hide();
        MainUI.select_type = "npc";
        MainUI.select_player_Info = nil;

        -- BOSS血条区域点击盒子响应事件
        MainUI.select_boss:GO('box.guishu_get'):BindButtonClick(function()
            client.sceneboss.get_guishu()
            end);
        MainUI.select_boss:GO('box.guishu_lost'):BindButtonClick(function()
            client.sceneboss.get_guishu()
            end);

        -- boss_blood_effect_1 = MainUI.select_boss:GO('bloodbar.bossxuetiao').gameObject
        -- boss_blood_effect_2 = MainUI.select_boss:GO('bloodbar.bossxuetiao2').gameObject
        EventManager.bind(this.gameObject,Event.ON_ATTACKED, MainUI.onBossAttacked);
        EventManager.bind(this.gameObject,Event.ON_MAINUI_HIDE, MainUITarget.Hide);
        EventManager.bind(this.gameObject,Event.ON_MAINUI_SHOW, MainUITarget.Show);
    end

    function MainUITarget.Hide()
        MainUI.selectpanel.transform:DOLocalMoveY(panelPos.y + 600, 0.5, false);
    end

    function MainUITarget.Show()
        MainUI.selectpanel.transform:DOLocalMoveY(panelPos.y, 0.3, false);
    end

    --选择NPC
    function MainUI.setSelectNPCInfo(id, name, npctype, level, maxbloodbarnum)


        MainUI.SelectNPC_id = id
        MainUI.SelectNPC_name = name
        MainUI.SelectNPC_level = level
        MainUI.SelectNPC_type = npctype
        MainUI.SelectNpc_maxbloodbarnum = maxbloodbarnum

        -- if MainUI.SelectNPC_type == commonEnum.NpcType.NpcType_Boss or 
        --     MainUI.SelectNPC_type == commonEnum.NpcType.NpcType_FBBoss or
        --     MainUI.SelectNPC_type == commonEnum.NpcType.NpcType_Elite then

            MainUI.SelectNPC_section = MainUI.SelectNpc_maxbloodbarnum
        -- else
        --     MainUI.SelectNPC_section = 1
        -- end
        if MainUI.SelectNPC_type == commonEnum.NpcType.NpcType_Boss or 
            MainUI.SelectNPC_type == commonEnum.NpcType.NpcType_FBBoss then

            this:GO('selectpanel.boss.level').text = "Lv"..level
            this:GO('selectpanel.boss.npcName').text = string.format("%s",name)
        else
            this:GO('selectpanel.npc.npcName').text = string.format("Lv%d %s",level,name)
        end

        if MainUI.SelectNPC_section ~= 0 then
            MainUI.SelectNPC_section_per = 1 / MainUI.SelectNPC_section;
        else
            MainUI.SelectNPC_section_per = 1;
        end
    end

    function MainUI.onBossAttacked(info)
        --[[local params = info:split();
        local id = tonumber(params[1])
        local bloodper = tonumber(params[2])
        local cursection, sectionper = math.modf(bloodper / MainUI.SelectNPC_section_per)
        if MainUI.SelectNPC_id == id then

            this:GO('selectpanel.boss.bloodbar.foreblood'):PlayUIEffect(this.gameObject,"bossxuetiao",0.5,
                function(effect)
                    local wrapper = effect:GetComponent("UIWrapper");
                    wrapper:GO('GameObject.xue1').fillAmount = sectionper
                end,true,false,UIWrapper.UIEffectAddType.Overlying)
        end]]
    end

    local function get_blood_bar_str(cur)
        if cur % Max_Section == 0 then
            return Max_Section 
        else
            return cur % Max_Section
        end
    end



    function MainUI.updateSelectNPCBlood(level, bloodper)        
        local cursection, sectionper = math.modf(bloodper / MainUI.SelectNPC_section_per)
        local delt = 0

        if cursection == MainUI.SelectNpc_maxbloodbarnum then sectionper = 1 end
        cursection = math.min(cursection + 1, MainUI.SelectNpc_maxbloodbarnum)
       
        
        local path = "selectpanel.npc";
        -- if MainUI.SelectNPC_type == commonEnum.NpcType.NpcType_Normal then
        if MainUI.SelectNpc_maxbloodbarnum == 1 then

            local forebloodWp = this:GO('selectpanel.npc.bloodbar.foreblood');
            if forebloodWp ~= nil then
                forebloodWp.sprite = "dk_guaiwuxuetiao_1"
                if cursection > 1 then
                    forebloodWp.fillAmount = 1;
                else 
                    forebloodWp.fillAmount = sectionper;
                end
            else
                error("[error] MainUI.updateSelectNPCBlood: forebloodWp");
            end

            local backbloodWp = this:GO('selectpanel.npc.bloodbar.backblood');
            if backbloodWp ~= nil then
                backbloodWp.fillAmount = 0;
            else
                error("[error] MainUI.updateSelectNPCBlood: backbloodWp");
            end

            local bloodSecWp = this:GO('selectpanel.npc.blood_sec');
            if bloodSecWp ~= nil then
                bloodSecWp:Hide();
            else
                error("[error] MainUI.updateSelectNPCBlood: bloodSecWp");
            end



        -- BOSS掉血效果
        elseif MainUI.SelectNPC_type == commonEnum.NpcType.NpcType_Boss
            or MainUI.SelectNPC_type == commonEnum.NpcType.NpcType_FBBoss then
            
            path = "selectpanel.boss"
            MainUI.SpecialBloodExpression(this:GO('selectpanel.boss'), cursection, sectionper, delt)

        -- 血条数量大于1的怪物具有多血条表现，血条底框使用npc的
        else
            MainUI.SpecialBloodExpression(this:GO('selectpanel.npc'), cursection, sectionper, delt)
        end        
        MainUI.updateSelectTargetTarget(path,MainUI.SelectNPC_id)
        
    end

    -- 精英怪/BOSS受击时掉血特殊表现
    function MainUI.SpecialBloodExpression(path, cursection, sectionper, delt)
        local blood_effect_1 = path:GO('bloodbar.xuetiao1').gameObject
        local blood_effect_2 = path:GO('bloodbar.xuetiao2').gameObject

        if cursection > 0 then                 

            path:GO('bloodbar.foreblood').sprite = "dk_boss_"..get_blood_bar_str(cursection)
            path:GO('bloodbar.foreblood').fillAmount = sectionper
            if  last_sectionper == nil then
                last_sectionper = sectionper
            end
            if math.abs(last_sectionper - sectionper) > 0.001 then
                local forebloodWrapper = path:GO('bloodbar.foreblood')

                forebloodWrapper:PlayUIEffect(this.gameObject,blood_effect_1,0.5,
                function(effect)
                    local wrapper = effect:GetComponent("UIWrapper");
                    wrapper:GO('GameObject.xue1').fillAmount = sectionper
                end,true,false,UIWrapper.UIEffectAddType.Replace)


                if last_sectionper > sectionper then
                    delt = last_sectionper - sectionper
                else
                    delt = 1 - sectionper
                end
                last_sectionper = sectionper
                forebloodWrapper:PlayUIEffect(this.gameObject,blood_effect_2,0.5,
                function(effect)                        
                    local wrapper = effect:GetComponent("UIWrapper");
                    local forebloodRTF = forebloodWrapper:GetComponent("RectTransform");
                    wrapper:GetComponent("RectTransform").anchoredPosition = Vector3.New(forebloodRTF.sizeDelta.x * sectionper,0,0)
                    local effectRTF =  wrapper:GO('GameObject.Image'):GetComponent("RectTransform")
                    local size = effectRTF.sizeDelta                            
                    size.x = forebloodRTF.sizeDelta.x * delt
                    effectRTF.sizeDelta = size
                end,true,false,UIWrapper.UIEffectAddType.Replace)
            else
                delt = 0;
            end
        end
        local nxtsection = cursection - 1
        local str_sec = ""
        if cursection > 1 then 
            str_sec = string.format("X%d", cursection)
        end
        if nxtsection > 0 then
            path:GO('bloodbar.backblood').sprite = "dk_boss_"..get_blood_bar_str(nxtsection)
            path:GO('bloodbar.backblood').fillAmount = 1
        else
            path:GO('bloodbar.backblood').fillAmount = 0
        end
        path:GO('blood_sec'):Show();
        path:GO('blood_sec').text = str_sec
    end

    function MainUI.updateSelectTargetTarget(path,id)
        if id == nil then 
            return 
        end
        -- local TargetTargetObj = AvatarUtil.GetSelectedAvatarCurrentAttackingTarget(id);

        local Target = AvatarCache.GetAvatar(id);
        if Target ~= nil then
            local Target_class = Fight.GetClass(Target);
            local TargetTargetInfo = Target_class.GetAvatarAttackedByMe();

            
            if TargetTargetInfo ~= nil then
                local avatar = AvatarCache.GetAvatar(TargetTargetInfo.id)
                if avatar ~= nil then
                    this:GO(path..".targetname").gameObject:SetActive(true)
                    local text = this:GO(path..".targetname.text");
                    text.text = avatar.name
                    local icon = this:GO(path..".targetname.icon");
                    if playSelectTargetEffectFlag[path] == nil then
                        icon:PlayUIEffectForever(this.gameObject, "zhishijiantou");
                        playSelectTargetEffectFlag[path] = true;
                    end
                    local textPos = text.transform.localPosition;
                    icon.transform.localPosition = Vector3.New(textPos.x - text.textWidth - 15, icon.transform.localPosition.y,0);
                    return;
                end
            end
        end    
        this:GO(path..".targetname").gameObject:SetActive(false)


        -- if TargetTargetObj ~= nil then
        --     this:GO(path..".targetname").gameObject:SetActive(true)

        --     local text = this:GO(path..".targetname.text");
        --     text.text = TargetTargetObj:GetComponent("AvatarData").Name;
           
           
        --     local icon = this:GO(path..".targetname.icon");
        --     if playSelectTargetEffectFlag[path] == nil then
        --         icon:PlayUIEffectForever(this.gameObject, "zhishijiantou");
        --         playSelectTargetEffectFlag[path] = true;
        --     end
        --     local textPos = text.transform.localPosition;
        --     icon.transform.localPosition = Vector3.New(textPos.x - text.textWidth - 15, icon.transform.localPosition.y,0);
        -- else
        --    this:GO(path..".targetname").gameObject:SetActive(false)
        -- end  
    end

    function MainUI.updatePlayerNameColor(Uid,color)
        if Uid == MainUI.SelectPlayer_id then
            this:GO('selectpanel.player.name').textColor = color;
        end
    end

    --选择player
    function MainUI.setSelectPlayerInfo(id, name, level,nameColor)
        local info = AvatarCache.GetAvatar(id);
        if info == nil then
            --已经死亡 被移除Cache.sceneInfo 直接return   by linh
            return
        end
        MainUI.SelectPlayer_id = id
        MainUI.SelectPlayer_name = name
        MainUI.SelectPlayer_level = level
        this:GO('selectpanel.player.name').text = name
        this:GO('selectpanel.player.level').text = "Lv"..level
        this:GO('selectpanel.player.name').textColor = nameColor
        --this:GO('selectpanel.player.level').textColor = nameColor
        -- this:GO('selectpanel.player.headbk.head').sprite = string.format("tx_%s_%s",info.career,info.sex);
        if info.career == "soldier" then
            this:GO('selectpanel.player.headbk.head').sprite = "tb_soldier";
        elseif info.career == "magician" then
            this:GO('selectpanel.player.headbk.head').sprite = "tb_magician";
        else
            this:GO('selectpanel.player.headbk.head').sprite = "tb_bowman";
        end
    end

    function MainUI.updateSelectPlayerBlood(level, bloodper)
        
        this:GO('selectpanel.player.bar.blood').fillAmount = bloodper
        MainUI.updateSelectTargetTarget("selectpanel.player",MainUI.SelectPlayer_id)
    end


    function MainUI.InitSelectObject(info)
        local params = info[1]:split(',');
        local selecttype = params[1]
        local id = tonumber(params[2])
        local name = params[3]
        local level = tonumber(params[4])
        local sid = tonumber(params[5])
        local bloodper = tonumber(params[6])
        local nameColor = info[2]
        if selecttype == "npc" then
            local npc = tb.NPCTable[sid]
            local npctype = npc.type;
            local maxbloodbarnum = npc.blood_bar_num;
            if maxbloodbarnum == nil then
                maxbloodbarnum = 1;
            end
            MainUI.SelectNPC_id = id;
            MainUI.SelectNPC_name = name;
            MainUI.SelectNPC_level = level;
            MainUI.SelectNPC_type = npctype;
            MainUI.SelectNpc_maxbloodbarnum = maxbloodbarnum;
            -- if MainUI.SelectNPC_type == commonEnum.NpcType.NpcType_Boss or
            --    MainUI.SelectNPC_type == commonEnum.NpcType.NpcType_FBBoss or
            --    MainUI.SelectNPC_type == commonEnum.NpcType.NpcType_Elite then
                
                MainUI.SelectNPC_section = MainUI.SelectNpc_maxbloodbarnum;
            -- else
            --     MainUI.SelectNPC_section = 1
            -- end
            if MainUI.SelectNPC_section ~= 0 then
                MainUI.SelectNPC_section_per = 1 / MainUI.SelectNPC_section;
            else
                MainUI.SelectNPC_section_per = 1;
            end
        elseif selecttype == "player" then
            MainUI.SelectPlayer_id = id;
            MainUI.SelectPlayer_name = name;
            MainUI.SelectPlayer_level = level;
            MainUI.SelectNPC_section = 1;
            MainUI.SelectNPC_section_per = 1;
            MainUI.SelectNpc_maxbloodbarnum = 1;
        end
    end

    --event
    local selectDelayCallId = -1;
    function MainUI.OnSelectObjDelay(info)
        MainUI.InitSelectObject(info);
        last_sectionper = nil
        selectDelayCallId = this:Delay(0.3, function()
            selectDelayCallId = -1;
            MainUI.OnSelectObj(info);
        end)
    end

    function MainUI.OnSelectObj(info)


        local params = info[1]:split(',');
        local selecttype = params[1]
        local id = tonumber(params[2])
        local name = params[3]
        local level = tonumber(params[4])
        local sid = tonumber(params[5])
        local bloodper = tonumber(params[6])
        local nameColor = info[2]
        this:GO('selectpanel'):Show()
        MainUI.select_type = selecttype


        MainUI.select_boss:Hide()
        MainUI.select_npc:Hide()
        MainUI.select_player:Hide()


        if selecttype == "npc" then
            local npc = tb.NPCTable[sid]
            if npc ~= nil then
                if npc.type >= commonEnum.NpcType.NpcType_Interaction and npc.type <= commonEnum.NpcType.NpcType_Gather then
                    return
                end

                if npc.type == commonEnum.NpcType.NpcType_Boss
                or npc.type == commonEnum.NpcType.NpcType_FBBoss then
                    MainUI.select_boss:Show();
                else
                    MainUI.select_npc:Show()
                end
                MainUI.setSelectNPCInfo(id, name, npc.type, level,npc.blood_bar_num)
                MainUI.updateSelectNPCBlood(level, bloodper)
            end
        elseif selecttype == "player" then
            MainUI.select_player:Show()
            MainUI.setSelectPlayerInfo(id, name, level,nameColor)
            MainUI.updateSelectPlayerBlood(level, bloodper)
            MainUI.select_player_Info = AvatarCache.GetAvatar(id);

            MainUI.select_player:BindButtonClick(function ()
                local btnList = {"sendMsg","roleInfo","addFriend","complain"};
                if client.role.haveClan() and math.abs(client.legion.LegionBaseInfo.SelfJur[1]) == 1 then
                    table.insert(btnList,"legionInvitation");
                end 
                local roleName = client.tools.ensureString(name)
                local legionName = client.tools.ensureString(MainUI.select_player_Info.legion_name)
                local roleSex = MainUI.select_player_Info.sex
                local roleCareer = MainUI.select_player_Info.career


                local data = {role_uid = MainUI.select_player_Info.role_uid, team_uid = MainUI.select_player_Info.team_uid ,name = roleName, legion_name = legionName, sex = roleSex, career = roleCareer};

                --自己有队伍 必定是邀请
                if client.team.team_uid ~= nil and client.team.team_uid ~= 0 then
                    table.insert(btnList, "inviteTeam");
                --对方有队伍 自己没有队伍 则申请
                elseif data.team_uid ~=nil and data.team_uid ~= 0 then
                    table.insert(btnList, "applyTeam");
                --两边都没有队伍 则邀请(自己先组队 然后邀请别人)
                else
                    table.insert(btnList, "inviteTeam");
                end

                --table.insert(btnList, "addFriend");
                --table.insert(btnList, "complain");
                --if data.team_uid then
                --table.insert(btnList, "invite");
                --end

                ui.ShowOperateFloat(data, btnList, const.operateFloatPos.head, this,function() end);
            end);

        end
    end

    function MainUI.OnCancelSelectObj()
        if selectDelayCallId >= 0 then
            this:CancelDelay(selectDelayCallId);
            selectDelayCallId = -1;
        end
        MainUI.select_npc:Hide()
        MainUI.select_player:Hide()
        MainUI.select_boss:Hide()
    end

    function MainUI.OnSelectUpdate(level, bloodper)
        if MainUI.select_type == "npc" then
            MainUI.updateSelectNPCBlood(level, bloodper)
        elseif MainUI.select_type == "player" then
            MainUI.updateSelectPlayerBlood(level, bloodper)
        end
    end
    
    EventManager.register(Event.ON_TARGET_SELECT, MainUI.OnSelectObjDelay);
    EventManager.register(Event.ON_TARGET_CANCEL_SELECT, MainUI.OnCancelSelectObj);
    EventManager.register(Event.ON_TARGET_UPDATE, MainUI.OnSelectUpdate);

    return MainUITarget;
end
    
