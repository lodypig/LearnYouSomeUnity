function CreateMonster(ds)

    ds["lua_logic"] = "Monster";

    local t = Fight.CreateAvatarClassData(ds);


    -- 销毁
    t.OnDestroy = function (ds)

        TargetSelecter.OnAvatarDestroy(ds);
        AvatarCache.RemoveAvatar(ds);

        -- 通知副本添加npc
        FubenManager.OnNotify(FubenHandlerType.OnRemoveNpc, { ["ds"] = ds });
    end;


    -- 受击
    t.OnHit = function (ds, attacker_ds)
        t.Tremble(ds, attacker_ds);
        t.FlashWhite(ds);
    end;


    t.Killed = function (ds)
        local id = ds["id"];
        ds["hp"] = 0;
        local class = Fight.GetClass(ds);
        class.ClearCommandQueue();
        uFacadeUtility.ShowAvatarTitle(id, false);
        TargetSelecter.OnAvatarDie(ds);
        uFacadeUtility.PlayState(id, "Die", 0);
        -- 通知副本死亡
        FubenManager.OnNotify(FubenHandlerType.OnDie, { ["ds"] = ds });
    end;



    -- 选中行为，当该角色被选中的时候这个函数会被调用
    t.OnSelect = function (ds)

        local role_type = ds.role_type;
        if role_type == RoleType.EliteMonster or role_type == RoleType.FubenEliteMonster then
            return;
        end
        local id = ds["id"];
        local title = uFacadeUtility.GetAvatarTitle(id);
        if title ~= nil then
            title:Show();
        else
            --error(string.format("[select] id=%d, trace=%s", ds["id"], debug.traceback()));
        end
    end;

    -- 初始化选择状态
    t.OnInitSelect = function (ds)
        local role_type = ds.role_type;
        if role_type == RoleType.EliteMonster or role_type == RoleType.FubenEliteMonster then
            return;
        end
        local id = ds["id"];
        local title = uFacadeUtility.GetAvatarTitle(id);
        if title ~= nil then
            title:Hide();
        else
            --error(string.format("--- [unselect] id=%d, trace=%s", ds["id"], debug.traceback()));
        end
    end;

    -- 去选行为，当该角色去选的时候这个函数会被调用
    t.OnUnselect = function (ds)
        local role_type = ds.role_type;
        if role_type == RoleType.EliteMonster or role_type == RoleType.FubenEliteMonster then
            return;
        end
        t.OnInitSelect(ds);
    end;


    -- 更新，这个函数对应 AvatarController 里面的 Update 函数
    t.Update = function (ds)
        t.UpdateAvatarsAttackedByMe();
    end;


    -- 待机
    t.Idle = {

        -- 进入
        OnEnter = function (ds)
        end,
        
        -- 更新
        OnUpdate = function (ds)
            if Fight.TryProcessNextCommand(ds) then
                return;
            end
        end,

        -- 移动
        OnMove = function (ds)
        end,
    };

    
    -- 移动
    t.Run = {

        source = SourceType.System,

        move_data = Fight.CreateMoveData(),

        -- 状态进入
        OnEnter = function (ds)
        end,

        -- 状态更新
        OnUpdate = function (ds)
            -- 移动到了目的地
            local move_data = t.Run.move_data;
            if move_data.arrived then

                if Fight.TryProcessNextCommand(ds) then
                    return;
                end

                Fight.DoJumpState(ds, SourceType.System, "Idle", 0);
                return;
            end

        end,

        -- 状态移动
        OnMove = function (ds)
            local move_data = t.Run.move_data;
            move_data.DoStateUpdateMove(ds);
        end,

        -- 帧事件
        OnFrameEvent = function (ds)
        end,
    };


    -- 死亡
    t.Die = {

        OnEnter = function (ds)
        end,

        OnUpdate = function (ds)
        end,

        OnMove = function (ds)
        end,
    };


    -- 普攻1
    t.Attack1 = {

        -- 技能数据
        skill_data = Fight.CreateSkillData(),

        OnEnter = function (ds)
            local skill_data = t.Attack1.skill_data;
            local target_id = skill_data.target_id;
            local target_ds = AvatarCache.GetAvatar(target_id);
            if target_ds ~= nil then
                Fight.DoRotateToTarget(ds, target_ds);
            end
            local npc = tb.NPCTable[ds.sid];
            local skill = tb.SkillTable[skill_data.skill_id];
            if skill.has_effect ~= nil and skill.has_effect == true and skill.start_effect1 ~= nil then
                -- print("play npc Skill ==>  "..npc.style)
                --local skill_name = string.format("%s_attack1", npc.style);
                local skill_name = skill.start_effect1;
                Fight.PlayFollowEffect(skill_name, 5.0, ds.id, "");
            end

            -- 判断弹道攻击的类型
            if skill.start_effect2 ~= nil then
                -- 如果是连线型技能
                if skill.start_effect2.type == 1 then
                    Fight.PlayLighteningEffect(skill.start_effect2.name, 5.0, ds["id"], skill.start_effect2.bindpos, target_id, "body");
                end

                -- 如果是直线弹道型
                if skill.start_effect2.type == 2 then
                    Fight.PlayLineBulletEffect(skill.start_effect2.name, ds["id"], skill.start_effect2.bindpos, target_id, "body", skill.start_effect2.speed, function ()
                        if skill.start_effect3 ~= nil then
                            Fight.PlayFollowEffect(skill.start_effect3, 5.0, target_id, "body");
                        end
                    end);
                end
                -- 如果是跟随弹道技能
                if skill.start_effect2.type == 3 then
                    Fight.PlayBulletTraceEffect(skill.start_effect2.name, ds["id"], target_id, "body", skill.start_effect2.speed, skill.start_effect2.accel, function ()
                        if skill.start_effect3 ~= nil then
                            Fight.PlayFollowEffect(skill.start_effect3, 5.0, target_id, "body");
                        end
                    end);
                end
            end
        end,
    
        OnUpdate = function (ds)
            -- 跳转到待机
            local curr_state_normalized_time = ds["curr_state_normalized_time"];
            local exit_time = ds["exit_time"];
            exit_time = 1.0;
            if curr_state_normalized_time >= exit_time then
                Fight.DoJumpState(ds, SourceType.System, "Idle", 0);
                return;
            end
        end,

        OnMove = function (ds)
        end,

        -- 帧事件
        OnFrameEvent = function (ds)
            print("Monster:OnFrameEvent");
            local skill_data = t.Attack1.skill_data;
            local target_id = skill_data.target_id;
            local target_ds = AvatarCache.GetAvatar(target_id);
            local npc = tb.NPCTable[ds.sid];
            local skill = tb.SkillTable[skill_data.skill_id];
            -- 判断弹道攻击的类型
            if skill.frame_effect1 ~= nil then
                -- 如果是连线型技能
                if skill.frame_effect1.type == 1 then
                    Fight.PlayLighteningEffect(skill.frame_effect1.name, 5.0, ds["id"], skill.frame_effect1.bindpos, target_id, "body");
                end

                -- 如果是直线弹道型
                if skill.frame_effect1.type == 2 then
                    Fight.PlayLineBulletEffect(skill.frame_effect1.name, ds["id"], skill.frame_effect1.bindpos, target_id, "body", skill.frame_effect1.speed, function ()
                        if skill.start_effect3 ~= nil then
                            Fight.PlayFollowEffect(skill.start_effect3, 5.0, target_id, "body");
                        end
                    end);
                end
                -- 如果是跟随弹道技能
                if skill.frame_effect1.type == 3 then
                    Fight.PlayBulletTraceEffect(skill.frame_effect1.name, ds["id"], target_id, "body", function ()
                        if skill.start_effect3 ~= nil then
                            Fight.PlayFollowEffect(skill.start_effect3, 5.0, target_id, "body");
                        end
                    end);
                end
            end
        end,
    };
    
    return ;
    
end