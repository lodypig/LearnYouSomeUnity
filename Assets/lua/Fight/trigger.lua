function CreateTriggerBehaviours(ds)


    local t = Fight.CreateAvatarClassData(ds);


    -- 销毁
    t.OnDestroy = function (ds)
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


    -- 更新，这个函数对应 AvatarController 里面的 Update 函数
    t.Update = function (ds)
        local title = t.title;
        if title ~= nil then
            local hp = ds["hp"];
            local maxHP = ds["maxHP"];
            local percent = hp / maxHP;
            if percent > 1 then
                percent = 1;
            end
            local progress = title:GO('Panel.BloodBar.foreground');
            progress.fillAmount = percent;
        end
    end;


    -- 待机
    t.Idle = {

        -- 进入
        OnEnter = function (ds)
            return nil;
        end,
        
        -- 更新
        OnUpdate = function (ds)
            local success = false;
            local result = nil;

            
            success, result = Fight.TryProcessNextCommand(ds);
            if success then
                return nil;
            end
            

            return nil;
        end,

        -- 移动
        OnMove = function (ds)
            return nil;
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

    -- 死亡
    t.DieFly = {

        OnEnter = function (ds)
            return nil;
        end,

        OnUpdate = function (ds)
            return nil;
        end,

        OnMove = function (ds)
            return nil;
        end,
    };


    return t;
    
end