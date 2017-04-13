

-- 创建法师行为
function CreateMagician(ds)

    ds["lua_logic"] = "Magician";

    -- 创建角色类数据
    local t = Fight.CreateAvatarClassData(ds);

    -- 创建角色技能数据:
    -- 用于角色释放技能时的 cd 计算，以及角色等级等信息的存储
    Fight.CreateSkillClassDatasForDs(ds);

    -- 角色销毁
    t.OnDestroy = function (ds)
        TargetSelecter.OnAvatarDestroy(ds);
        AvatarCache.RemoveAvatar(ds);
    end;

    -- 更新，这个函数对应 AvatarController 里面的 Update 函数
    t.Update = function (ds)

        --[[
        -- 更新血量
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
        ]]

        local role_type = ds.role_type;
        if role_type == RoleType.Player then
            ControlLogic.Update();
            t.UpdateAvatarsAttackingMe();
        end
        t.UpdateAvatarsAttackedByMe();
    end;

    -- 选中行为，当该角色被选中的时候这个函数会被调用
    t.OnSelect = function (ds)
        local settings = DataCache.settings;
        local role_type = ds.role_type;
        if role_type ~= RoleType.Player then
            local id = ds["id"];
            local title = uFacadeUtility.GetAvatarTitle(id);
            if title ~= nil then
                title:Show();
                local BloodBarWp = title:GO('Panel.BloodBar');
                if BloodBarWp ~= nil then
                    BloodBarWp:Show();
                end
                local OtherTitleWp = title:GO('Panel.Other.Title');
                if OtherTitleWp ~= nil then
                    if settings.system_hideTitle then
                        OtherTitleWp:Hide();
                    else
                        if OtherTitleWp.Sprite == nil then
                            OtherTitleWp:Hide();
                        else
                            OtherTitleWp:Show();
                        end
                    end
                end
            else
                --error(string.format("[select] id=%d, trace=%s", ds["id"], debug.traceback()));
            end
        end
    end;

    -- 初始化选择状态
    t.OnInitSelect = function (ds)
        local settings = DataCache.settings;
        local role_type = ds.role_type;
        if role_type ~= RoleType.Player then
            local id = ds["id"];
            local title = uFacadeUtility.GetAvatarTitle(id);
            if title ~= nil then
                title:Show();
                local BloodBarWp = title:GO('Panel.BloodBar');
                if BloodBarWp ~= nil then
                    if settings.system_hideBlood then
                        BloodBarWp:Hide();
                    else
                        BloodBarWp:Show();
                    end
                end
                local OtherTitleWp = title:GO('Panel.Other.Title');
                if OtherTitleWp ~= nil then
                    if settings.system_hideTitle then
                        OtherTitleWp:Hide();
                    else
                        if OtherTitleWp.Sprite == nil then
                            OtherTitleWp:Hide();
                        else
                            OtherTitleWp:Show();
                        end
                    end
                end
            else
                --error(string.format("[select] id=%d, trace=%s", ds["id"], debug.traceback()));
            end
        end
    end;

    -- 去选行为，当该角色去选的时候这个函数会被调用
    t.OnUnselect = function (ds)
        t.OnInitSelect(ds);
    end;

    -- 当角色被攻击时，这个函数会被调用
    t.OnHit = function (ds)

    end;

    -- 当角色被杀死，这个函数会被调用
    t.Killed = function (ds)
        local id = ds.id;
        ds["hp"] = 0;
        uFacadeUtility.PlayState(id, "Die", 0);
        RebirthManager.OnDie(ds);
    end;

    ---------------------------------------------------------------------------------
    -- 角色状态处理函数
    -- 角色每个状态处理是分离的
    -- 每个状态可以包含如下函数:
    -- OnEnter 进入状态函数，当前状态进入时调用
    -- OnExit 退出状态函数，当前状态退出时调用
    -- OnUpdate 状态更新函数，当进入状态后，每帧都会调用该函数
    -- OnMove 状态移动函数，进入状态后，涉及角色移动的处理都在这个函数
    -- OnFrameEvent 帧事件函数，进入状态后，只要发生了帧事件，这个函数就会被调用
    ---------------------------------------------------------------------------------

    -- 待机
    t.Idle = {

        cross_data = Fight.CreateCrossData(),

        source = SourceType.System,
        
        enter_time = 0,
        wait_minutes = false,

        -- 进入
        OnEnter = function (ds)
            FubenManager.OnNotify(FubenHandlerType.OnEnterIdle, { ["ds"] = ds });
            client.horse.CheckHorseAnimatorPlay(ds, "Idle");
            t.Idle.enter_time = ds.curr_time;
        end,
        
        -- 更新
        OnUpdate = function (ds)

            -- 更新待机和战斗待机
            local cross_data = t.Idle.cross_data;
            cross_data.UpdateValue(ds);

            local role_type = ds.role_type;
            if role_type == RoleType.Player then
                -- 技能跳转
                if Fight.PlayerTryJumpSkill(ds) then
                    if AutoPathfindingManager.IsAutoPathfinding() then
                        AutoPathfindingManager.CancelWithoutJumpIdle();
                    end
                    return;
                end

                -- 跳转摇杆移动
                if Fight.TryJumpJoystickRun(ds) then
                    if AutoPathfindingManager.IsAutoPathfinding() then
                        AutoPathfindingManager.CancelWithoutJumpIdle();
                    end
                    return;
                end

                -- 跳转到点击移动
                if Fight.PlayerTryJumpClickRun(ds) then
                    if AutoPathfindingManager.IsAutoPathfinding() then
                        AutoPathfindingManager.CancelWithoutJumpIdle();
                    end
                    return;
                end

                -- 自动寻路
                if Fight.TryJumpPathfinding(ds) then
                    return;
                end

                -- 自动战斗
                local do_auto_fight = false;
                if not t.Idle.wait_minutes then
                    do_auto_fight = true;
                else
                    local elapsed_time = ds.curr_time - t.Idle.enter_time;
                    if elapsed_time >= const.wait_for_autofight then
                        do_auto_fight = true;
                    end
                end

                if do_auto_fight then
                    if t.AutoFight(ds, 0) then
                        return;
                    end
                end
            else
                if Fight.TryProcessNextCommand(ds) then
                    return;
                end
            end
        end,

        -- 移动
        OnMove = function (ds)
        end,
    };


            -- 摇杆移动
    t.JoystickRun = {

        footstep_data = Fight.CreateFootstepData(),

        start_move_time = 0,
        last_move_time = 0,

        path = {},

        is_exit = false,

        -- 状态进入
        OnEnter = function (ds)
            local curr_time = ds.curr_time;
            t.JoystickRun.start_move_time = curr_time;
            t.JoystickRun.last_move_time = curr_time;
            client.horse.CheckHorseAnimatorPlay(ds, "Run");
            SkillButtons.ClearAllButtonEvents();
            t.JoystickRun.is_exit = false;
        end,

        -- 状态更新
        OnUpdate = function (ds)

            if Fight.TryJumpCanCastSkillWithinScope(ds, SourceType.Player) then
                return;
            end

            -- 如果当前仍然处于摇杆控制
            if JoystickManager.IsJoysticking() then
                -- 什么都不做
                return;
            end

            if ds.is_auto_fighting then
                t.Idle.wait_minutes = true;
            end

            Fight.DoJumpState(ds, SourceType.System, "Idle", 0);
            t.JoystickRun.is_exit = true;
        end,

        -- 状态移动
        OnMove = function (ds)
            if t.JoystickRun.is_exit then
                return;
            end
            local curr_time = ds.curr_time;
            local delta_time = curr_time - t.JoystickRun.last_move_time;
            local pos_x = ds.pos_x;
            local pos_y = ds.pos_y;
            local pos_z = ds.pos_z;
            Fight.DoJoystickMove(ds, delta_time);
            t.JoystickRun.last_move_time = curr_time;
            local new_pos_x = ds.pos_x;
            local new_pos_y = ds.pos_y;
            local new_pos_z = ds.pos_z;
            if new_pos_x ~= pos_x or new_pos_z ~= pos_z then
                local path = t.JoystickRun.path;
                path[1] = pos_x;
                path[2] = pos_y;
                path[3] = pos_z;
                path[4] = new_pos_x;
                path[5] = new_pos_y;
                path[6] = new_pos_z;
                uFacadeUtility.SyncStartMoveDeduce(path, ds.move_speed);
                for i = 1, #path do
                    path[i] = nil;
                end
            end
        end,

        OnExit = function (ds)
            t.JoystickRun.is_exit = true;
            local role_type = ds.role_type;
            if role_type == RoleType.Player then
                local class = Fight.GetClass(ds);
                class.SaveAutoFightPos(ds);
            end
        end,

        -- 帧事件
        OnFrameEvent = function (ds)
            local pos_x = ds["pos_x"];
            local pos_y = ds["pos_y"];
            local pos_z = ds["pos_z"];
            Fight.PlayFootstepSound(ds, t.JoystickRun.footstep_data, pos_x, pos_y, pos_z);
        end,
    };


    -- 移动
    t.Run = {

        source = SourceType.System,

        move_data = Fight.CreateMoveData(),

        idle = true,

        -- 状态进入
        OnEnter = function (ds)
            client.horse.CheckHorseAnimatorPlay(ds, "Run");
            local move_data = t.Run.move_data;
            move_data.RotateToFirstPos(ds);
            move_data.RecaculateTime(ds.curr_time, ds.move_speed);
        end,

        -- 状态更新
        OnUpdate = function (ds)
            -- 移动到了目的地
            local move_data = t.Run.move_data;
            if move_data.arrived then

                if Fight.TryProcessNextCommand(ds) then
                    return;
                end

                if t.Run.idle then
                    Fight.DoJumpState(ds, SourceType.System, "Idle", 0);
                end
            end

        end,

        OnExit = function (ds)
            t.Run.idle = true;
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


    -- 点击移动
    t.ClickRun = {
        
        move_data = Fight.CreateMoveData(),

        footstep_data = Fight.CreateFootstepData(),

        OnEnter = function (ds)
            local pos_x = ds["pos_x"];
            local pos_y = ds["pos_y"];
            local pos_z = ds["pos_z"];
            local dir_x = ds["dir_x"];
            local dir_y = ds["dir_y"];
            local dir_z = ds["dir_z"];
            local click_pos = ClickMoveManager.GetClickPos();
            local dst_x = click_pos.x;
            local dst_y = click_pos.y;
            local dst_z = click_pos.z;
            local move_data = t.ClickRun.move_data;
            local curr_time = ds["curr_time"];
            local move_speed = ds.move_speed;
            local result = move_data.StartMove(curr_time, pos_x, pos_y, pos_z, dir_x, dir_y, dir_z, dst_x, dst_y, dst_z, move_speed);
            if result then
                Fight.DoShowClickEffect(ds, true);
                client.horse.CheckHorseAnimatorPlay(ds, "Run");
                uFacadeUtility.SyncStartMove(move_data.path, move_data.move_speed);
            end
        end,

        OnUpdate = function (ds)

            -- 技能范围内的技能攻击
            if Fight.TryJumpCanCastSkillWithinScope(ds, SourceType.Player) then
                return;
            end

            -- 尝试跳转"摇杆移动"
            if Fight.TryJumpJoystickRun(ds) then
                return;
            end

            -- 跳转到点击移动
            if Fight.PlayerTryJumpClickRun(ds) then
                Fight.DoShowClickEffect(ds, true);
                return;
            end

            -- 自动寻路
            if Fight.TryJumpPathfinding(ds) then
                return;
            end

            -- 移动到了目的地
            local move_data = t.ClickRun.move_data;
            if move_data.arrived then
                if ds.is_auto_fighting then
                    t.Idle.wait_minutes = true;
                end
                Fight.DoJumpState(ds, SourceType.System, "Idle", 0);
                ClickMoveManager.OnArrived(ds);
                return;
            end

        end,

        OnExit = function (ds)

            local move_data = t.ClickRun.move_data;
            local arrived = move_data.arrived;
            -- 取消移动
            ClickMoveManager.Clear();
            Fight.DoShowClickEffect(ds, false);

            local role_type = ds.role_type;
            if role_type == RoleType.Player then
                local class = Fight.GetClass(ds);
                class.SaveAutoFightPos(ds);
            end

            -- 还没到达就终止状态
            if not arrived then
                ClickMoveManager.OnCancelClickMoving(ds);
            end
        end,


        OnMove = function (ds)
            local move_data = t.ClickRun.move_data;
            move_data.DoStateUpdateMove(ds);
        end,


        -- 帧事件
        OnFrameEvent = function (ds)

            local pos_x = ds["pos_x"];
            local pos_y = ds["pos_y"];
            local pos_z = ds["pos_z"];
            Fight.PlayFootstepSound(ds, t.JoystickRun.footstep_data, pos_x, pos_y, pos_z);
        end,
    };



    -- 寻路移动
    t.PathfindingRun = {

        source = SourceType.System,
        move_data = Fight.CreateMoveData(),
        footstep_data = Fight.CreateFootstepData(),
        fly_shoe = false,

        -- 进入
        OnEnter = function (ds)
            local pos_x = ds["pos_x"];
            local pos_y = ds["pos_y"];
            local pos_z = ds["pos_z"];
            local dir_x = ds["dir_x"];
            local dir_y = ds["dir_y"];
            local dir_z = ds["dir_z"];
            local local_path = AutoPathfindingManager.GetLocalPath();
            local dst_x = local_path.dst_x;
            local dst_y = local_path.dst_y;
            local dst_z = local_path.dst_z;
            local move_data = t.PathfindingRun.move_data;
            local curr_time = ds["curr_time"];
            local move_speed = ds.move_speed;
            local result = move_data.StartChaseMove(curr_time, pos_x, pos_y, pos_z, dir_x, dir_y, dir_z, dst_x, dst_y, dst_z, 0.5, move_speed);
            if result then
                AutoPathfindingManager.OnLocalPathStart(ds);
                t.PathfindingRun.canceled = false;
                client.horse.CheckHorseAnimatorPlay(ds, "Run");
                uFacadeUtility.SyncStartMove(move_data.path, move_data.move_speed);
            end
        end,

        -- 更新
        OnUpdate = function (ds)

            -- 技能范围内的技能攻击
            if Fight.TryJumpCanCastSkillWithinScope(ds, SourceType.Player) then
                AutoPathfindingManager.CancelWithoutJumpIdle();
                return;
            end

            -- 尝试跳转"摇杆移动"
            if Fight.TryJumpJoystickRun(ds) then
                AutoPathfindingManager.CancelWithoutJumpIdle();
                return;
            end

            -- 跳转到点击移动
            if Fight.PlayerTryJumpClickRun(ds) then
                AutoPathfindingManager.CancelWithoutJumpIdle();
                return;
            end

            -- 移动到了目的地
            local move_data = t.PathfindingRun.move_data;
            if move_data.arrived then
                if ds.is_auto_fighting then
                    t.Idle.wait_minutes = true;
                end
                -- 待机
                Fight.DoJumpState(ds, SourceType.System, "Idle", 0);
                return;
            end
        end,

        -- 移动
        OnMove = function (ds)
            local move_data = t.PathfindingRun.move_data;
            move_data.DoStateUpdateMove(ds);

            -- 自动寻路更新
            AutoPathfindingManager.OnLocalPathUpdate(ds);

            local is_auto_pathfinding = AutoPathfindingManager.IsAutoPathfinding();
            if is_auto_pathfinding then
                local is_local_path_change = AutoPathfindingManager.IsLocalPathChange();
                if is_local_path_change then
                    AutoPathfindingManager.ResetLocalPathChange();
                    local pos_x = ds["pos_x"];
                    local pos_y = ds["pos_y"];
                    local pos_z = ds["pos_z"];
                    local dir_x = ds["dir_x"];
                    local dir_y = ds["dir_y"];
                    local dir_z = ds["dir_z"];
                    local local_path = AutoPathfindingManager.GetLocalPath();
                    local dst_x = local_path.dst_x;
                    local dst_y = local_path.dst_y;
                    local dst_z = local_path.dst_z;
                    local move_data = t.PathfindingRun.move_data;
                    local curr_time = ds["curr_time"];
                    local move_speed = ds.move_speed;
                   
                    local result = move_data.StartMove(curr_time, pos_x, pos_y, pos_z, dir_x, dir_y, dir_z, dst_x, dst_y, dst_z, move_speed);
                    if result then
                        uFacadeUtility.SyncStartMove(move_data.path, move_data.move_speed);
                        AutoPathfindingManager.OnLocalPathStart(ds);
                    end
                end
            end
            
        end,

        -- 退出
        OnExit = function (ds)

            local role_type = ds.role_type;
            if role_type == RoleType.Player then
                local class = Fight.GetClass(ds);
                class.SaveAutoFightPos(ds);
                -- TargetSelecter.ClearTarget();
            end

            local move_data = t.PathfindingRun.move_data;
            if move_data.arrived then
                -- 局部路径到达
                if AutoPathfindingManager.IsAutoPathfinding() then
                    AutoPathfindingManager.OnLocalPathArrived(ds);
                end
            end
        end,

        -- 帧事件
        OnFrameEvent = function (ds)
           
            local pos_x = ds["pos_x"];
            local pos_y = ds["pos_y"];
            local pos_z = ds["pos_z"];
            Fight.PlayFootstepSound(ds, t.PathfindingRun.footstep_data, pos_x, pos_y, pos_z);
        end,
    };



    
    -- 追击
    t.Chase = {

        move_data = Fight.CreateMoveData(),

        footstep_data = Fight.CreateFootstepData(),

        target_id = 0,

        skill_id = 0,

        OnEnter = function (ds)
            local pos_x = ds["pos_x"];
            local pos_y = ds["pos_y"];
            local pos_z = ds["pos_z"];
            local dir_x = ds["dir_x"];
            local dir_y = ds["dir_y"];
            local dir_z = ds["dir_z"];
            local state = t.Chase;
            local skill_id = state.skill_id;
            local target_id = state.target_id;
            if target_id == 0 then
                error("target_id is 0");
                return;
            end
            local target = AvatarCache.GetAvatar(target_id);
            if target == nil then
                error("target is nil");
                return;
            end
           
            local skill_info = tb.SkillTable[skill_id];
            local dst_x = target["pos_x"];
            local dst_y = target["pos_y"];
            local dst_z = target["pos_z"];
            local move_data = t.Chase.move_data;
            local curr_time = ds["curr_time"];
            local move_speed = ds.move_speed;
            local result = move_data.StartChaseMove(curr_time, pos_x, pos_y, pos_z, dir_x, dir_y, dir_z, dst_x, dst_y, dst_z, skill_info.distance, move_speed);
            TargetSelecter.SetFirstClassTarget(target);
            if result then
                uFacadeUtility.SyncStartMove(move_data.path, move_data.move_speed);
            end
            client.horse.CheckHorseAnimatorPlay(ds, "Run");
            --下马
            if ds.is_riding == true then
                uFacadeUtility.UnRideHorse(ds.id)
            end
        end,

        OnUpdate = function (ds)

            -- 尝试跳转"摇杆移动"
            if Fight.TryJumpJoystickRun(ds) then
                return;
            end

            -- 跳转到点击移动
            if Fight.PlayerTryJumpClickRun(ds) then
                return;
            end

            -- 自动寻路
            if Fight.TryJumpPathfinding(ds) then
                return;
            end

        end,

        OnExit = function (ds)
        end,

        OnMove = function (ds)
            -- 移动到了目的地
            local state = t.Chase;
            local skill_id = state.skill_id;
            local target_id = state.target_id;
            local move_data = state.move_data;
            move_data.DoStateUpdateMove(ds);


            -- 防止玩家切换目标
            local current = TargetSelecter.current;
            if current ~= nil and current.id ~= target_id then
               target_id = current.id;
               state.target_id = current.id; 
            end

            local target = nil;
            if target_id ~= 0 then
                target = AvatarCache.GetAvatar(target_id);
            end
            if Fight.IsSkillCanCast(ds, skill_id, target) then -- or move_data.arrived then
                if move_data.arrived then
                    uFacadeUtility.SendStopMoveMsg();
                end
                Fight.TryJumpCanCastSkill(ds, skill_id, t.Chase.source);
            else
                
                if target_id ~= 0 then
                    local target = AvatarCache.GetAvatar(target_id);
                    if target ~= nil then
                        local target_pos_x = target.pos_x;
                        local target_pos_y = target.pos_y;
                        local target_pos_z = target.pos_z;
                        local last_path = move_data.path;
                        local last_dst_x = move_data.dst_x;
                        local last_dst_y = move_data.dst_y;
                        local last_dst_z = move_data.dst_z;
                        if target_pos_x ~= last_dst_x or target_pos_z ~= last_dst_z then
                            local curr_time = ds["curr_time"];
                            local dst_x = target_pos_x;
                            local dst_y = target_pos_y;
                            local dst_z = target_pos_z;
                            local skill_data = tb.SkillTable[skill_id];
                            local pos_x = ds.pos_x;
                            local pos_y = ds.pos_y;
                            local pos_z = ds.pos_z;
                            local dir_x = ds["dir_x"];
                            local dir_y = ds["dir_y"];
                            local dir_z = ds["dir_z"];
                            local move_speed = ds.move_speed;
                            local result = move_data.StartChaseMove(curr_time, pos_x, pos_y, pos_z, dir_x, dir_y, dir_z, dst_x, dst_y, dst_z, skill_data.distance, move_speed);
                            if result then
                                uFacadeUtility.SyncStartMove(move_data.path, move_data.move_speed);
                            end
                        end
                    end
                end
            end
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


    -- 归位
    t.Return = {

        move_data = Fight.CreateMoveData(ds);

        OnEnter = function (ds)
            local pos_x = ds["pos_x"];
            local pos_y = ds["pos_y"];
            local pos_z = ds["pos_z"];
            local dir_x = ds["dir_x"];
            local dir_y = ds["dir_y"];
            local dir_z = ds["dir_z"];
            local origin_x = ds["origin_x"];
            local origin_y = ds["origin_y"];
            local origin_z = ds["origin_z"];
            local random_move_radius = ds["random_move_radius"];
            local move_data = t.Return.move_data;
            local curr_time = ds["curr_time"];
            local move_speed = ds.move_speed;
            local result = move_data.LoadAutoFightReturnPath(curr_time, pos_x, pos_y, pos_z, dir_x, dir_y, dir_z, origin_x, origin_y, origin_z, random_move_radius, move_speed);
            --print(string.format("回归位置: pos={%f, %f, %f}", origin_x, origin_y, origin_z));
            if result then
                uFacadeUtility.SyncStartMove(move_data.path, move_data.move_speed);
            end
        end,

        OnUpdate = function (ds)

            -- 尝试跳转"摇杆移动"
            if Fight.TryJumpJoystickRun(ds) then
                return;
            end

            -- 跳转到点击移动
            if Fight.PlayerTryJumpClickRun(ds) then
                return;
            end

            -- 自动战斗
            if t.AutoFight(ds, 0) then
                return;
            end

            -- 到达目标点
            local move_data = t.Return.move_data;
            if move_data.arrived then
                Fight.DoJumpState(ds, SourceType.System, "Idle", 0);
            end

        end,

        OnExit = function (ds)
        end,

        OnMove = function (ds)
            local move_data = t.Return.move_data;
            if not move_data.arrived then
                move_data.DoStateUpdateMove(ds);
            end
        end,

        OnFrameEvent = function (ds)
        end,
    };


        -- 普攻1
    t.Attack1 = {

        skill_data = Fight.CreateSkillData();

        -- 进入
        OnEnter = function (ds)
            local role_type = ds.role_type;
            if role_type == nil then
                local rtt = SkillExhibitRTT;
                rtt.ResetModelPos();
            else
                if role_type == RoleType.Player then
                    --下马先
                    client.horse.RideHorse(false)
                    Fight.DoRotateToCurrentTarget(ds)
                    local skill_info = Fight.GetSkillInfoByIndexAndType(ds, 1, SkillType.Normal);
                    local current = TargetSelecter.current;
                    if current ~= nil then
                        local skill_data = t.Attack1.skill_data;
                        skill_data.target_id = current["id"];
                        skill_data.skill_id = skill_info.id;
                        Fight.DoSyncSkill(ds, skill_info.id, current["id"]);
                        TargetSelecter.SetFirstClassTarget(current);
                       
                    else
                        local skill_data = t.Attack1.skill_data;
                        skill_data.target_id = 0;
                        skill_data.skill_id = skill_info.id;
                    end
                else
                    -- 其他玩家逻辑
                    local skill_data = t.Attack1.skill_data;
                    local target_id = skill_data.target_id;
                    local target = AvatarCache.GetAvatar(target_id);
                    if target ~= nil then
                        Fight.DoRotateToTarget(ds, target);
                    end
                end
                --下马
                if ds.is_riding == true then
                    uFacadeUtility.UnRideHorse(ds.id)
                end
            end
        end,
    
        -- 更新
        OnUpdate = function (ds)

            local role_type = ds.role_type;
            if role_type == nil then
                local curr_state_normalized_time = ds["curr_state_normalized_time"];
                if curr_state_normalized_time >= 0.5 then
                    Fight.DoJumpStateForModel(ds, "Attack2", 0);
                end
            else
                if role_type == RoleType.Player then
                    -- 跳转到待机
                    local curr_state_normalized_time = ds["curr_state_normalized_time"];
                    local exit_time = ds["exit_time"];
                    if curr_state_normalized_time >= 1.0 then
                        Fight.DoJumpState(ds, SourceType.System, "Idle", 0);
                    elseif curr_state_normalized_time >= exit_time then

                        -- 尝试跳转"摇杆移动"
                        if Fight.TryJumpJoystickRun(ds) then
                            return;
                        end

                        -- 技能跳转
                        if Fight.PlayerTryJumpSkill(ds)  then
                            return;
                        end

                        -- 跳转到点击移动
                        if Fight.PlayerTryJumpClickRun(ds) then
                            return;
                        end

                        -- 自动寻路
                        if Fight.TryJumpPathfinding(ds) then
                            return;
                        end

                        -- 自动战斗
                        local skill_data = t.Attack1.skill_data;
                        if t.AutoFight(ds, skill_data.target_id) then
                            return;
                        end
                        -- 自动攻击
                        if t.AutoAttack(ds, t.Attack1, skill_data.target_id) then
                            return;
                        end
                    else
                        
                    end
                else
                    local curr_state_normalized_time = ds["curr_state_normalized_time"];
                    local exit_time = ds["exit_time"];
                    if curr_state_normalized_time >= 1.0 then
                        Fight.DoJumpState(ds, SourceType.System, "Idle", 0);
                    elseif curr_state_normalized_time >= exit_time then
                        if Fight.TryProcessNextCommand(ds) then
                            return;
                        end
                    else
                    end
                end
            end
        end,

        -- 移动
        OnMove = function (ds)
        end,

        -- 帧事件
        OnFrameEvent = function (ds)
            local role_type = ds.role_type;
            if role_type == nil then
                local pos_x = ds.pos_x;
                local pos_y = ds.pos_y;
                local pos_z = ds.pos_z;
                local dir_x = ds.dir_x;
                local dir_y = 0;
                local dir_z = ds.dir_z;
                local distance = 4;
                local target_x = pos_x + dir_x * distance;
                local target_y = pos_y + 0.5;
                local target_z = pos_z + dir_z * distance;
                Fight.PlaySound("mage_shandianjian");
                Fight.RttPlayFollowEffect("mage_female_attack_01", 5.0, ds.id, "lhand");
                local cell = SkillExhibitRTT.GetCellRoot();
                local cellY = cell.transform.position.y;
                Fight.RttPlayLighteningEffect("mage_female_attack_02", 5.0, ds.id, "lhand", target_x, cellY + 0.5, target_z);
                Fight.RttPlayPositionEffect(cell, "mage_female_attack_03", 2.0, target_x, pos_y + 0.5, target_z, function () end);
            else
                local skill_data = t.Attack1.skill_data;
                local target_id = skill_data.target_id;
                local current = AvatarCache.GetAvatar(target_id);
                if current == nil then
                    -- error("target is null");
                    return;
                end
                Fight.PlaySound("mage_shandianjian");
                local class = Fight.GetClass(ds);
                local skill = class.GetSkillByTypeAndIndex(SkillType.Normal, 1);
                if const.enable_zhuanjing and skill.zhuanjin ~= nil and skill.zhuanjin[30000] ~= nil then
                    Fight.PlayFollowEffect("mage_female_attack_06", 5.0, ds.id, "lhand");
                    Fight.PlayLighteningEffect("mage_female_attack_04", 5.0, ds.id, "lhand", target_id, "body");
                    Fight.PlayFollowEffect("mage_female_attack_05", 2.0, target_id, "body");
                else   
                    Fight.PlayFollowEffect("mage_female_attack_01", 5.0, ds.id, "lhand");
                    Fight.PlayLighteningEffect("mage_female_attack_02", 5.0, ds.id, "lhand", target_id, "body");
                    Fight.PlayFollowEffect("mage_female_attack_03", 2.0, target_id, "body");
                end
                Fight.DoHitTarget(current, ds);
            end
        end,
    };


    -- 普攻2
    t.Attack2 = {

        skill_data = Fight.CreateSkillData();

        OnEnter = function (ds)
            local role_type = ds.role_type;
            if role_type == nil then
                local curr_state_normalized_time = ds["curr_state_normalized_time"];
                if curr_state_normalized_time >= 1.0 then
                    Fight.DoJumpStateForModel(ds, "Idle", 0);
                end
            else
                if role_type == RoleType.Player then
                    --下马先
                    client.horse.RideHorse(false)
                    Fight.DoRotateToCurrentTarget(ds)
                    local skill_info = Fight.GetSkillInfoByIndexAndType(ds, 2, SkillType.Normal);
                    local current = TargetSelecter.current;
                    if current ~= nil then
                        local skill_data = t.Attack2.skill_data;
                        skill_data.target_id = current["id"];
                        skill_data.skill_id = skill_info.id;
                        Fight.DoSyncSkill(ds, skill_info.id, current["id"]);
                        TargetSelecter.SetFirstClassTarget(current);
                    else
                        local skill_data = t.Attack2.skill_data;
                        skill_data.target_id = 0;
                        skill_data.skill_id = skill_info.id;
                    end
                else
                    -- 其他玩家逻辑
                    local skill_data = t.Attack2.skill_data;
                    local target_id = skill_data.target_id;
                    local target = AvatarCache.GetAvatar(target_id);
                    if target ~= nil then
                        Fight.DoRotateToTarget(ds, target);
                    end
                end
                --下马
                if ds.is_riding == true then
                    uFacadeUtility.UnRideHorse(ds.id)
                end
            end
        end,
    
        OnUpdate = function (ds)

            local role_type = ds.role_type;
            if role_type == nil then
                local curr_state_normalized_time = ds["curr_state_normalized_time"];
                if curr_state_normalized_time >= 1.0 then
                    Fight.DoJumpStateForModel(ds, "Idle", 0);
                end
            else
                if role_type == RoleType.Player then
                    -- 跳转到待机
                    local curr_state_normalized_time = ds["curr_state_normalized_time"];
                    local exit_time = ds["exit_time"];
                    if curr_state_normalized_time >= 1.0 then
                        Fight.DoJumpState(ds, SourceType.System, "Idle", 0);
                    elseif curr_state_normalized_time >= exit_time then

                        -- 尝试跳转"摇杆移动"
                        if Fight.TryJumpJoystickRun(ds) then
                            return;
                        end

                        -- 技能跳转
                        if Fight.PlayerTryJumpSkill(ds)  then
                            return;
                        end

                        -- 跳转到点击移动
                        if Fight.PlayerTryJumpClickRun(ds) then
                            return;
                        end

                        -- 自动寻路
                        if Fight.TryJumpPathfinding(ds) then
                            return;
                        end

                        -- 自动战斗
                        local skill_data = t.Attack2.skill_data;
                        if t.AutoFight(ds, skill_data.target_id) then
                            return;
                        end

                        -- 自动攻击
                        if t.AutoAttack(ds, t.Attack2, skill_data.target_id) then
                            return;
                        end
                    else
                        
                    end
                else
                    local curr_state_normalized_time = ds["curr_state_normalized_time"];
                    local exit_time = ds["exit_time"];
                    if curr_state_normalized_time >= 1.0 then
                        Fight.DoJumpState(ds, SourceType.System, "Idle", 0);
                    elseif curr_state_normalized_time >= exit_time then
                        if Fight.TryProcessNextCommand(ds) then
                            return;
                        end
                    else
                    end
                end
            end
        end,

        OnMove = function (ds)
        end,

        -- 帧事件
        OnFrameEvent = function (ds)
            local role_type = ds.role_type;
            if role_type == nil then
                local pos_x = ds.pos_x;
                local pos_y = ds.pos_y;
                local pos_z = ds.pos_z;
                local dir_x = ds.dir_x;
                local dir_y = 0;
                local dir_z = ds.dir_z;
                local distance = 4;
                local target_x = pos_x + dir_x * distance;
                local target_y = 0.5;
                local target_z = pos_z + dir_z * distance;
                Fight.PlaySound("mage_shandianjian");
                Fight.RttPlayFollowEffect("mage_female_attack_01", 5.0, ds.id, "rhand");
                local cell = SkillExhibitRTT.GetCellRoot();
                local cellY = cell.transform.position.y;
                Fight.RttPlayLighteningEffect("mage_female_attack_02", 5.0, ds.id, "rhand", target_x, cellY + 0.5, target_z);
                Fight.RttPlayPositionEffect(cell, "mage_female_attack_03", 2.0, target_x, pos_y + 0.5, target_z, function () end);
            else
                local skill_data = t.Attack2.skill_data;
                local target_id = skill_data.target_id;
                local current = AvatarCache.GetAvatar(target_id);
                if current == nil then
                    return;
                end
                Fight.PlaySound("mage_shandianjian");
                local class = Fight.GetClass(ds);
                local skill = class.GetSkillByTypeAndIndex(SkillType.Normal, 1);
                if const.enable_zhuanjing and skill.zhuanjin ~= nil and skill.zhuanjin[30000] ~= nil then
                    Fight.PlayFollowEffect("mage_female_attack_06", 5.0, ds.id, "rhand");
                    Fight.PlayLighteningEffect("mage_female_attack_04", 5.0, ds.id, "rhand", target_id, "body");
                    Fight.PlayFollowEffect("mage_female_attack_05", 2.0, target_id, "body");
                else   
                    Fight.PlayFollowEffect("mage_female_attack_01", 5.0, ds.id, "rhand");
                    Fight.PlayLighteningEffect("mage_female_attack_02", 5.0, ds.id, "rhand", target_id, "body");
                    Fight.PlayFollowEffect("mage_female_attack_03", 2.0, target_id, "body");
                end
                Fight.DoHitTarget(current, ds);
            end
        end,
    };


    
    -- AOE
    t.AOE = {

        skill_data = Fight.CreateSkillData();

        OnEnter = function (ds)
            
            local role_type = ds.role_type;
            if role_type == nil then
                local rtt = SkillExhibitRTT;
                rtt.ResetModelPos();
                local dir_x = ds.dir_x;
                local dir_z = ds.dir_z;
                local pos_x = ds.pos_x;
                local pos_y = ds.pos_y;
                local pos_z = ds.pos_z;
                local distance = 4;
                local target_x = pos_x + dir_x * distance;
                local target_z = pos_z + dir_z * distance;
                local cell = SkillExhibitRTT.GetCellRoot();
                Fight.RttPlayStaticEffect(cell, "mage_female_AOE_01", 5.0, ds.id, "");
                Fight.RttPlayPositionEffect(cell, "fashiqungong", 5.0, target_x, pos_y + 0.5, target_z);
            else
                local skill_data = t.AOE.skill_data;
                local class = Fight.GetClass(ds);
                local skill = class.GetSkillByTypeAndIndex(SkillType.Skill, const.AOE_Index)
                if role_type == RoleType.Player then
                    --下马先
                    client.horse.RideHorse(false)
                    Fight.CastSkill(ds, SkillType.Skill, const.AOE_Index);
                    Fight.DoRotateToCurrentTarget(ds);
                    local skill_info = Fight.GetSkillInfoByIndexAndType(ds, const.AOE_Index, SkillType.Skill);
                    local current = TargetSelecter.current;
                    if current ~= nil then
                        skill_data.target_id = current["id"];
                        skill_data.skill_id = skill_info.id;
                        local skill_level = skill.level;
                        local skill_cd = Fight.GetSkillCdTime(skill_info.id, skill_level);
                        Fight.DoStartSkillButtonCD(ds, const.AOE_Index, skill_cd / 1000, ds["is_auto_fighting"]);
                        Fight.DoSyncSkill(ds, skill_info.id, current["id"]);
                        TargetSelecter.SetFirstClassTarget(current);
                    else
                        skill_data.target_id = 0;
                        skill_data.skill_id = skill_info.id;
                    end
                else
                    local target = AvatarCache.GetAvatar(skill_data.target_id);
                    if target ~= nil then
                        Fight.DoRotateToTarget(ds, target);
                    end
                end
                
                if const.enable_zhuanjing and skill.zhuanjin ~= nil and skill.zhuanjin[30002] ~= nil then
                    Fight.PlayStaticEffect("mage_female_AOE_01", 5.0, ds.id, "");
                    Fight.PlayStaticEffect("mage_female_AOE_02", 5.0, skill_data.target_id, "");
                else
                    Fight.PlayStaticEffect("mage_female_AOE_01", 5.0, ds.id, "");
                    Fight.PlayStaticEffect("fashiqungong", 5.0, skill_data.target_id, "");
                end
                --下马
                if ds.is_riding == true then
                    uFacadeUtility.UnRideHorse(ds.id)
                end
            end
        end,
        OnUpdate = function (ds)

            local role_type = ds.role_type;
            if role_type == nil then
                local curr_state_normalized_time = ds["curr_state_normalized_time"];
                if curr_state_normalized_time >= 1.0 then
                    Fight.DoJumpStateForModel(ds, "Idle", 0);
                end
            else
                if role_type == RoleType.Player then
                    -- 跳转到待机
                    local curr_state_normalized_time = ds["curr_state_normalized_time"];
                    local exit_time = ds["exit_time"];
                    if curr_state_normalized_time >= 1.0 then
                        
                        Fight.DoJumpState(ds, SourceType.System, "Idle", 0);

                    elseif curr_state_normalized_time >= exit_time then

                        -- 尝试跳转"摇杆移动"
                        if Fight.TryJumpJoystickRun(ds) then
                            return;
                        end

                        -- 技能跳转
                        if Fight.PlayerTryJumpSkill(ds)  then
                            return;
                        end

                        -- 跳转到点击移动
                        if Fight.PlayerTryJumpClickRun(ds) then
                            return;
                        end

                        -- 自动寻路
                        if Fight.TryJumpPathfinding(ds) then
                            return;
                        end

                        -- 自动战斗
                        local skill_data = t.AOE.skill_data;
                        if t.AutoFight(ds, skill_data.target_id) then
                            return;
                        end

                        -- 自动攻击
                        if t.AutoAttack(ds, t.AOE, skill_data.target_id) then
                            return;
                        end

                    else
                        
                    end
                else
                    local curr_state_normalized_time = ds["curr_state_normalized_time"];
                    local exit_time = ds["exit_time"];
                    if curr_state_normalized_time >= 1.0 then
                        Fight.DoJumpState(ds, SourceType.System, "Idle", 0);
                    elseif curr_state_normalized_time >= exit_time then
                        if Fight.TryProcessNextCommand(ds) then
                            return;
                        end
                    else
                    end
                end
            end
        end,

        OnMove = function (ds)
        end,

        -- 帧事件
        OnFrameEvent = function (ds)
            local role_type = ds.role_type;
            if role_type == nil then
                Fight.PlaySound("mage_nengliangfengbao");
            else
                local skill_data = t.AOE.skill_data;
                local target_id = skill_data.target_id;
                local current = AvatarCache.GetAvatar(target_id);
                Fight.PlaySound("mage_nengliangfengbao");
                if current == nil then
                    return;
                end
                Fight.PlayFollowEffect("warrior_male_attack_hit", 3.0, target_id, "body");
                Fight.DoHitTarget(current, ds);
            end
        end,
    };


    -- EX
    t.EX = {

        skill_data = Fight.CreateSkillData();

        OnEnter = function (ds)
            local role_type = ds.role_type;
            if role_type == nil then
                local rtt = SkillExhibitRTT;
                rtt.ResetModelPos();
                Fight.PlaySound("mage_shenzhishenpan");
                Fight.RttPlayFollowEffect("fashi_jiao", 3.0, ds.id, "");
            else
                Fight.PlaySound("mage_shenzhishenpan");
                Fight.PlayStaticEffect("fashi_jiao", 3.0, ds.id, "");
                if role_type == RoleType.Player then
                    --下马先
                    client.horse.RideHorse(false)
                    Fight.CastSkill(ds, SkillType.Skill, const.EX_Index);
                    Fight.DoRotateToCurrentTarget(ds)
                    local class = Fight.GetClass(ds);
                    local skill = class.GetSkillByTypeAndIndex(SkillType.Skill, const.EX_Index);
                    local skill_info = Fight.GetSkillInfoByIndexAndType(ds, const.EX_Index, SkillType.Skill);
                    local current = TargetSelecter.current;
                    if current ~= nil then
                        local skill_data = t.EX.skill_data;
                        skill_data.target_id = current["id"];
                        skill_data.skill_id = skill_info.id;
                        local skill_level = skill.level;
                        local skill_cd = Fight.GetSkillCdTime(skill_info.id, skill_level);
                        Fight.DoStartSkillButtonCD(ds, const.EX_Index, skill_cd / 1000, ds["is_auto_fighting"]);
                        Fight.DoSyncSkill(ds, skill_info.id, current["id"]);
                        TargetSelecter.SetFirstClassTarget(current);
                    else
                        local skill_data = t.EX.skill_data;
                        skill_data.target_id = 0;
                        skill_data.skill_id = skill_info.id;
                    end
                else
                    -- 其他玩家逻辑
                    local skill_data = t.EX.skill_data;
                    local target_id = skill_data.target_id;
                    local target = AvatarCache.GetAvatar(target_id);
                    if target ~= nil then
                        Fight.DoRotateToTarget(ds, target);
                    end
                end
                --下马
                if ds.is_riding == true then
                    uFacadeUtility.UnRideHorse(ds.id)
                end
            end
        end,
        OnUpdate = function (ds)

            local role_type = ds.role_type;
            if role_type == nil then
                local curr_state_normalized_time = ds["curr_state_normalized_time"];
                if curr_state_normalized_time >= 1.0 then
                    Fight.DoJumpStateForModel(ds, "Idle", 0);
                end
            else
                if role_type == RoleType.Player then
                    -- 跳转到待机
                    local curr_state_normalized_time = ds["curr_state_normalized_time"];
                    local exit_time = ds["exit_time"];
                    if curr_state_normalized_time >= 1.0 then
                        Fight.DoJumpState(ds, SourceType.System, "Idle", 0);
                    elseif curr_state_normalized_time >= exit_time then
                        -- 尝试跳转"摇杆移动"
                        if Fight.TryJumpJoystickRun(ds) then
                            return;
                        end
                        -- 技能跳转
                        if Fight.PlayerTryJumpSkill(ds)  then
                            return;
                        end
                        -- 跳转到点击移动
                        if Fight.PlayerTryJumpClickRun(ds) then
                            return;
                        end

                        -- 自动寻路
                        if Fight.TryJumpPathfinding(ds) then
                            return;
                        end

                        -- 自动战斗
                        local skill_data = t.EX.skill_data;
                        if t.AutoFight(ds, skill_data.target_id) then
                            return;
                        end
                        -- 自动攻击
                        if t.AutoAttack(ds, t.EX, skill_data.target_id) then
                            return;
                        end
                    else
                    end
                else
                    local curr_state_normalized_time = ds["curr_state_normalized_time"];
                    local exit_time = ds["exit_time"];
                    if curr_state_normalized_time >= 1.0 then
                        Fight.DoJumpState(ds, SourceType.System, "Idle", 0);
                    elseif curr_state_normalized_time >= exit_time then
                        if Fight.TryProcessNextCommand(ds) then
                            return;
                        end
                    else
                    end
                end
            end
        end,
        OnExit = function (ds)
            local role_type = ds.role_type;
            if role_type == nil then

            else
                if role_type == RoleType.Player then
                    uFacadeUtility.ShakeMainCamera(ShakeCameraType.FAR_NEAR);
                end
            end
        end,
        OnMove = function (ds)
        end,
        OnFrameEvent = function (ds)

            local role_type = ds.role_type;
            if role_type == nil then
                local frame_event_id = ds["frame_event_id"];
                if frame_event_id == 2020201 or frame_event_id == 2120201 then
                    Fight.RttPlayFollowEffect("fashi_shou", 5.0, ds.id, "lhand");
                end
                if frame_event_id == 2020202 or frame_event_id == 2120202 then
                    local pos_x = ds.pos_x;
                    local pos_y = ds.pos_y;
                    local pos_z = ds.pos_z;
                    local dir_x = ds.dir_x;
                    local dir_z = ds.dir_z;
                    local distance = 4;
                    local target_x = pos_x + dir_x * distance;
                    local target_z = pos_z + dir_z * distance;
                    local cell = SkillExhibitRTT.GetCellRoot();
                    Fight.RttPlayPositionEffect(cell, "fashi_dazhao", 5.0, target_x, pos_y + 0.5, target_z);
                end
            else
                local frame_event_id = ds["frame_event_id"];
                if frame_event_id == 2020201 or frame_event_id == 2120201 then
                    Fight.PlayFollowEffect("fashi_shou", 5.0, ds.id, "lhand");
                    return;
                end
                if frame_event_id == 2020202 or frame_event_id == 2120202 then
                    local skill_data = t.EX.skill_data;
                    local class = Fight.GetClass(ds);
                    local skill = class.GetSkillByTypeAndIndex(SkillType.Skill, const.EX_Index);
                    if const.enable_zhuanjing and skill.zhuanjin ~= nil and skill.zhuanjin[30003] ~= nil then
                        Fight.PlayFollowEffect("fashi_dazhao1", 5.0, skill_data.target_id, "");
                    else
                        Fight.PlayFollowEffect("fashi_dazhao", 5.0, skill_data.target_id, "");
                    end
                    return;
                end
            end
        end,
    };


    -- Special
    t.Special = {

        skill_data = Fight.CreateSkillData(),

        move_data = Fight.CreateMoveData(),

        teleporting = false,

        move_speed = 5.0,

        OnEnter = function (ds)
            t.Special.teleporting = false;
            local role_type = ds.role_type;
            if role_type == nil then
                local rtt = SkillExhibitRTT;
                rtt.ResetModelPos();
                local pos_x = ds["pos_x"];
                local pos_y = ds["pos_y"];
                local pos_z = ds["pos_z"];
                local dir_x = ds.dir_x;
                local dir_y = 0;
                local dir_z = ds.dir_z;
                local dist = dir_x * dir_x + dir_z * dir_z;
                dir_x = dir_x / dist;
                dir_z = dir_z / dist;
                local distance = 4;
                local dst_x = pos_x + dir_x * distance;
                local dst_y = 0;
                local dst_z = pos_z + dir_z * distance;
                t.Special.move_speed = distance; -- / 2.5;
                local move_data = t.Special.move_data;
                local curr_time = ds["curr_time"];
                local move_speed = distance / 0.2;
                ds["move_speed"] = move_speed;
                move_data.LoadModelPath(curr_time, pos_x, 0, pos_z, dir_x, dir_y, dir_z, dst_x, dst_y, dst_z, move_speed);
            else
                if role_type == RoleType.Player then
                    --下马先
                    client.horse.RideHorse(false)
                    Fight.CastSkill(ds, SkillType.Skill, const.Special_Index);
                    local class = Fight.GetClass(ds);
                    local skill = class.GetSkillByTypeAndIndex(SkillType.Skill, const.Special_Index)
                    local skill_info = Fight.GetSkillInfoByIndexAndType(ds, const.Special_Index, SkillType.Skill);
                    local skill_level = skill.level;
                    local skill_cd = Fight.GetSkillCdTime(skill_info.id, skill_level);
                    Fight.DoStartSkillButtonCD(ds, const.Special_Index, skill_cd / 1000, ds["is_auto_fighting"]);
                    Fight.DoSyncSkill(ds, skill_info.id, 0);
                    local pos_x = ds["pos_x"];
                    local pos_y = ds["pos_y"];
                    local pos_z = ds["pos_z"];
                    local dir_x = ds["dir_x"];
                    local dir_y = ds["dir_y"];
                    local dir_z = ds["dir_z"];
                    local move_data = t.Special.move_data;
                    local start_time = ds["curr_time"];
                    local ret = move_data.LoadTeleportPath(start_time, pos_x, pos_y, pos_z, dir_x, dir_y, dir_z, 8.0, 20);
                    local path = t.Special.move_data.path;
                    local from_x = path[1];
                    local from_y = path[2];
                    local from_z = path[3];
                    local to_x = path[4];
                    local to_y = path[5];
                    local to_z = path[6];
                    local dx = to_x - from_x;
                    local dy = to_y - from_y;
                    local dz = to_z - from_z;
                    local distance = math.sqrt(dx * dx + dz * dz);
                    local move_speed = distance / 0.2;
                    ds["move_speed"] = move_speed;
                    t.Special.move_speed = move_speed;
                else
                    local pos_x = ds["pos_x"];
                    local pos_y = ds["pos_y"];
                    local pos_z = ds["pos_z"];
                    local dir_x = ds["dir_x"];
                    local dir_y = ds["dir_y"];
                    local dir_z = ds["dir_z"];
                    local move_data = t.Special.move_data;
                    local start_time = ds["curr_time"];
                    move_data.LoadTeleportPath(start_time, pos_x, pos_y, pos_z, dir_x, dir_y, dir_z, 8.0, 20);
                    local path = t.Special.move_data.path;
                    local from_x = path[1];
                    local from_y = path[2];
                    local from_z = path[3];
                    local to_x = path[4];
                    local to_y = path[5];
                    local to_z = path[6];
                    local dx = to_x - from_x;
                    local dy = to_y - from_y;
                    local dz = to_z - from_z;
                    local distance = math.sqrt(dx * dx + dz * dz);
                    local move_speed = distance / 0.2;
                    ds["move_speed"] = move_speed;
                    t.Special.move_speed = move_speed;
                end
                --下马
                if ds.is_riding == true then
                    uFacadeUtility.UnRideHorse(ds.id)
                end
            end
        end,

        OnUpdate = function (ds)

            local role_type = ds.role_type;
            if role_type == nil then
                local curr_state_normalized_time = ds["curr_state_normalized_time"];
                if curr_state_normalized_time >= 1.5 then
                    local rtt = SkillExhibitRTT;
                    rtt.ResetModelPos();
                    Fight.DoJumpStateForModel(ds, "Idle", 0);
                end
            else
                if role_type == RoleType.Player then
                    -- 跳转到待机
                    local curr_state_normalized_time = ds["curr_state_normalized_time"];
                    local exit_time = ds["exit_time"];
                    if curr_state_normalized_time >= 1.0 then
                        Fight.DoJumpState(ds, SourceType.System, "Idle", 0);
                    elseif curr_state_normalized_time >= exit_time then

                        -- 尝试跳转"摇杆移动"
                        if Fight.TryJumpJoystickRun(ds) then
                            return;
                        end

                        -- 技能跳转
                        if Fight.PlayerTryJumpSkill(ds)  then
                            return;
                        end

                        -- 跳转到点击移动
                        if Fight.PlayerTryJumpClickRun(ds) then
                            return;
                        end

                        -- 自动寻路
                        if Fight.TryJumpPathfinding(ds) then
                            return;
                        end

                        -- 自动战斗
                        local skill_data = t.Special.skill_data;
                        if t.AutoFight(ds, skill_data.target_id) then
                            return;
                        end

                        -- 自动攻击
                        if t.AutoAttack(ds, t.Special, skill_data.target_id) then
                            return;
                        end
                    else

                    end
                else
                    local curr_state_normalized_time = ds["curr_state_normalized_time"];
                    local exit_time = ds["exit_time"];
                    if curr_state_normalized_time >= 1.0 then
                        Fight.DoJumpState(ds, SourceType.System, "Idle", 0);
                    elseif curr_state_normalized_time >= exit_time then
                        if Fight.TryProcessNextCommand(ds) then
                            return;
                        end
                    else
                    end
                end
            end
        end,


        OnExit = function (ds)
            local role_type = ds.role_type;
            if role_type == nil then
                Fight.DoShowMeshForModel(ds);
                ds["move_speed"] = 5;
            else
                Fight.DoShowMesh(ds);
                ds["move_speed"] = 5;
            end
        end,

        OnMove = function (ds)
            local teleporting = t.Special.teleporting;
            if not teleporting then
                return;
            end
            local role_type = ds.role_type;
            if role_type == nil then
                local move_data = t.Special.move_data;
                move_data.DoStateUpdateMoveForModel(ds);
            else
                local move_data = t.Special.move_data;
                move_data.DoStateUpdateMove(ds);
            end
        end,

        OnFrameEvent = function (ds)
            local frame_event_id = ds["frame_event_id"];
            local role_type = ds.role_type;
            if role_type == nil then
                if frame_event_id == 2040101 or frame_event_id == 2140101 then
                    t.Special.teleporting = true;
                    local move_data = t.Special.move_data;
                    local start_time = ds["curr_time"];
                    local move_speed = 40;
                    move_data.RecaculateTime(start_time, move_speed);
                    Fight.DoHideMeshForModel(ds);
                    Fight.PlaySound("mage_shunjianyidong");
                    Fight.RttPlayFollowEffect("mage_female_yidong_qidian", 5.0, ds.id, "");
                    Fight.RttPlayFollowEffect("mage_female_yidong_canying", 5.0, ds.id, "");
                elseif frame_event_id == 2040102 or frame_event_id == 2140102 then
                    t.Special.teleporting = false;
                    Fight.DoShowMeshForModel(ds);
                    Fight.RttPlayFollowEffect("mage_female_yidong_zhongdian", 5.0, ds.id, "");
                    return;
                end
            else
                if frame_event_id == 2040101 or frame_event_id == 2140101 then
                    t.Special.teleporting = true;
                    local move_data = t.Special.move_data;
                    local start_time = ds["curr_time"];
                    local move_speed = 40;
                    move_data.RecaculateTime(start_time, move_speed);
                    Fight.DoHideMesh(ds);
                    Fight.PlaySound("mage_shunjianyidong");
                    Fight.PlayFollowEffect("mage_female_yidong_qidian", 5.0, ds.id, "");
                    Fight.PlayFollowEffect("mage_female_yidong_canying", 5.0, ds.id, "");
                    return;
                elseif frame_event_id == 2040102 or frame_event_id == 2140102 then
                    t.Special.teleporting = false;
                    Fight.DoShowMesh(ds);
                    Fight.PlayFollowEffect("mage_female_yidong_zhongdian", 5.0, ds.id, "");
                    return;
                end
            end
        end,
    };

    return t;
end
