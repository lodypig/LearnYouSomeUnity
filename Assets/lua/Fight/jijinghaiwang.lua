function CreateJijinghaiwang(ds)
    -- print("CreateJijinghaiwang")
    ds["lua_logic"] = "Jijinghaiwang";

    local t = Fight.CreateAvatarClassData(ds);

    -- 创建角色技能数据:
    -- 用于角色释放技能时的 cd 计算，以及角色等级等信息的存储
    Fight.CreateSkillClassDatasForDs(ds);

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
            local success = false;
            success = Fight.TryProcessNextCommand(ds);
            if success then
                return;
            end
        end,

        -- 移动
        OnMove = function (ds)
        end,
    };

    
    -- 移动
    t.Run = {

        move_data = Fight.CreateMoveData(),

        -- 状态进入
        OnEnter = function (ds)
        end,

        -- 状态更新
        OnUpdate = function (ds)
            -- 移动到了目的地
            local move_data = t.Run.move_data;
            if move_data.arrived then
                local id = ds.id;
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


    -- 寂静海王普攻1
    t.Attack1 = {

        -- 技能数据
        skill_data = Fight.CreateSkillData(),

        OnEnter = function (ds)
          	--print("t.Attack1")
            local skill_data = t.Attack1.skill_data;
            local target_id = skill_data.target_id;
            local target_ds = AvatarCache.GetAvatar(target_id);
            if target_ds ~= nil then
                Fight.DoRotateToTarget(ds, target_ds);
            end
            Fight.PlayFollowEffect("jijinghaiwang_attack1", 5.0, ds.id, "");
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
        end,
    };

    -- 寂静海王普攻2
    t.Attack2 = {

        -- 技能数据
        skill_data = Fight.CreateSkillData(),

        OnEnter = function (ds)
          	--print("t.Attack2")
            local skill_data = t.Attack2.skill_data;
            local target_id = skill_data.target_id;
            local target_ds = AvatarCache.GetAvatar(target_id);
            if target_ds ~= nil then
                Fight.DoRotateToTarget(ds, target_ds);
            end
            Fight.PlayFollowEffect("jijinghaiwang_attack2", 5.0, ds.id, "");
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
        end,
    };

    -- 寂静海王技能1
    t.Skill1 = {
        -- 技能数据
        skill_data = Fight.CreateSkillData(),

        OnEnter = function (ds)
          	--print("t.Skill1！")
            local skill_data = t.Skill1.skill_data;
            local target_id = skill_data.target_id;
            -- local target_ds = AvatarCache.GetAvatar(target_id);
            -- if target_ds ~= nil then
            --     Fight.DoRotateToTarget(ds, target_ds);
            -- end
            Fight.PlayFollowEffect("jijinghaiwang_skill1", 5.0, ds.id, "");
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
        end,
    };

    -- 寂静海王技能2
    t.Skill2 = {
        -- 技能数据
        skill_data = Fight.CreateSkillData(),

        OnEnter = function (ds)
          	--print("t.Skill2！")
            local skill_data = t.Skill2.skill_data;
            local target_id = skill_data.target_id;
            local target_ds = AvatarCache.GetAvatar(target_id);
            if target_ds ~= nil then
                Fight.DoRotateToTarget(ds, target_ds);
            end
            Fight.PlayFollowEffect("jijinghaiwang_skill2", 5.0, ds.id, "");
            -- Fight.PlayFollowEffect("kulouwang_attack4_weapon", 5.0, ds.id, "weapon1");
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
        end,
    };
    
    return t;
end