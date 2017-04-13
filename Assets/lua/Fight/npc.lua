function CreateNpc(ds)

    ds["lua_logic"] = "Npc";

    local t = Fight.CreateAvatarClassData(ds);

    

    -- 销毁
    t.OnDestroy = function (ds)
        t.OnLeaveScope(ds);
        InteractionManager.RemoveNpc(ds);
        CollectManager.OnDestroy(ds);
        TargetSelecter.OnAvatarDestroy(ds);
        AvatarCache.RemoveAvatar(ds);
    end;

    -- 受击
    t.OnHit = function (ds, attacker_ds)
    end;


    t.Killed = function (ds)
        local id = ds["id"];
        uFacadeUtility.ShowAvatarTitle(id, false);
        TargetSelecter.OnAvatarDie(ds);
        uFacadeUtility.PlayState(id, "Die", 0);
    end;

    -- 选中行为，当该角色被选中的时候这个函数会被调用
    t.OnSelect = function (ds)

        
    end;

    -- 初始化选择状态
    t.OnInitSelect = function (ds)
        
    end;

    -- 去选行为，当该角色去选的时候这个函数会被调用
    t.OnUnselect = function (ds)
        
        
    end;


    -- 更新，这个函数对应 AvatarController 里面的 Update 函数
    t.Update = function (ds)
        t.UpdateScopeDetect(ds);
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
                local success = false;
                success = Fight.TryProcessNextCommand(ds);
                if success then
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

    -- 死亡
    t.DieFly = {

        OnEnter = function (ds)
        end,

        OnUpdate = function (ds)
        end,

        OnMove = function (ds)
        end,
    };


    return t;
end