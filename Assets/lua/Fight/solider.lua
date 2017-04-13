

-- 创建战士行为
function CreateSolider(ds)


    ds["lua_logic"] = "Solider";

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

                -- 尝试跳转"摇杆移动"
                local success = false;

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
            t.JoystickRun.is_exit = false;
            local curr_time = ds.curr_time;
            t.JoystickRun.start_move_time = curr_time;
            t.JoystickRun.last_move_time = curr_time;
            client.horse.CheckHorseAnimatorPlay(ds, "Run");
            SkillButtons.ClearAllButtonEvents();
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
            -- local path = move_data.path;
            -- move_data.RotateToFirstPos(ds);
            -- local count = #path / 3;
            -- if count == 1 then
            --     local p1_x, p1_y, p1_z = move_data.GetPos(1);
            --   	--print(string.format("[run] single: {%f, %f}", p1_x, p1_z));
            -- else
            --     local p1_x, p1_y, p1_z = move_data.GetPos(1);
            --     local p2_x, p2_y, p2_z = move_data.GetPos(count);
            --   	--print(string.format("[run] multiple: from={%f, %f}, to={%f, %f}", p1_x, p1_z, p2_x, p2_z));
            -- end
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

        source = SourceType.System,
        
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
        canceled = false,

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
            t.PathfindingRun.canceled = false;
            local result = move_data.StartChaseMove(curr_time, pos_x, pos_y, pos_z, dir_x, dir_y, dir_z, dst_x, dst_y, dst_z, 0.5, move_speed);
            if result then
                AutoPathfindingManager.OnLocalPathStart(ds);
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

        source = SourceType.System,

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
                -- 技能跳转
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

        source = SourceType.System,

        OnEnter = function (ds)
        end,

        OnUpdate = function (ds)
        end,

        OnMove = function (ds)
        end,
    };


    -- 归位
    t.Return = {

        source = SourceType.System,

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

            -- 自动寻路
            if Fight.TryJumpPathfinding(ds) then
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

        source = SourceType.System,

        skill_data = Fight.CreateSkillData();

        -- 进入
        OnEnter = function (ds)
            local role_type = ds.role_type;
            if role_type == nil then
                local rtt = SkillExhibitRTT;
                rtt.ResetModelPos();
                Fight.RttPlayFollowEffect("warrior_male_attack01", 5.0, ds.id, "");
            else
                local class = Fight.GetClass(ds);
                local skill = class.GetSkillByTypeAndIndex(SkillType.Normal, 1);
                if const.enable_zhuanjing and skill.zhuanjin ~= nil and skill.zhuanjin[10000] ~= nil then
                    Fight.PlayFollowEffect("warrior_male_attack04", 5.0, ds.id, "");
                else
                    Fight.PlayFollowEffect("warrior_male_attack01", 5.0, ds.id, "");
                end     
                if role_type == RoleType.Player then
                    --下马先
                    client.horse.RideHorse(false)
                    -- 玩家逻辑
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

            else
                local skill_data = t.Attack1.skill_data;
                local target_id = skill_data.target_id;
                local current = AvatarCache.GetAvatar(target_id);
                Fight.PlaySound("warrior_liekongzhan");              
                if current == nil then
                    return;
                end
                Fight.PlayFollowEffect("warrior_male_attack_hit", 5.0, current.id, "body");
                Fight.DoHitTarget(current, ds);
            end
        end,
    };


    -- 普攻2
    t.Attack2 = {

        source = SourceType.System,

        skill_data = Fight.CreateSkillData();

        OnEnter = function (ds)
            local role_type = ds.role_type;
            if role_type == nil then
                Fight.RttPlayFollowEffect("warrior_male_attack02", 5.0, ds.id, "");
            else
                local class = Fight.GetClass(ds);
                local skill = class.GetSkillByTypeAndIndex(SkillType.Normal, 2);
                if const.enable_zhuanjing and skill.zhuanjin ~= nil and skill.zhuanjin[10000] then
                    Fight.PlayFollowEffect("warrior_male_attack05", 5.0, ds.id, "");
                else
                    Fight.PlayFollowEffect("warrior_male_attack02", 5.0, ds.id, "");
                end
                if role_type == RoleType.Player then
                    --下马先
                    client.horse.RideHorse(false)
                    Fight.DoRotateToCurrentTarget(ds);
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
                if curr_state_normalized_time >= 0.5 then
                    Fight.DoJumpStateForModel(ds, "Attack3", 0);
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

            else
                local skill_data = t.Attack2.skill_data;
                local target_id = skill_data.target_id;
                local current = AvatarCache.GetAvatar(target_id);
                Fight.PlaySound("warrior_liekongzhan");
                if current == nil then
                    return;
                end
                Fight.PlayFollowEffect("warrior_male_attack_hit", 5.0, target_id, "body");
                Fight.DoHitTarget(current, ds);
            end
        end,
    };


    -- 普攻3
    t.Attack3 = {

        source = SourceType.System,

        skill_data = Fight.CreateSkillData();

        OnEnter = function (ds)
            local role_type = ds.role_type;
            if role_type == nil then
                Fight.RttPlayFollowEffect("warrior_male_attack03", 5.0, ds.id, "");
            else
                local class = Fight.GetClass(ds);
                local skill = class.GetSkillByTypeAndIndex(SkillType.Normal, 3);
                if const.enable_zhuanjing and skill.zhuanjin ~= nil and skill.zhuanjin[10000] then
                    Fight.PlayFollowEffect("warrior_male_attack06", 5.0, ds.id, "");
                else
                    Fight.PlayFollowEffect("warrior_male_attack03", 5.0, ds.id, "");
                end
                if role_type == RoleType.Player then
                    --下马先
                    client.horse.RideHorse(false)
                    Fight.DoRotateToCurrentTarget(ds);
                    local skill_info = Fight.GetSkillInfoByIndexAndType(ds, 3, SkillType.Normal);
                    local current = TargetSelecter.current;
                    if current ~= nil then
                        local skill_data = t.Attack3.skill_data;
                        skill_data.target_id = current["id"];
                        skill_data.skill_id = skill_info.id;
                        Fight.DoSyncSkill(ds, skill_info.id, current["id"]);
                        TargetSelecter.SetFirstClassTarget(current);
                    else
                        local skill_data = t.Attack3.skill_data;
                        skill_data.target_id = 0;
                        skill_data.skill_id = skill_info.id;
                    end
                else
                    -- 其他玩家逻辑
                    local skill_data = t.Attack3.skill_data;
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
                        local skill_data = t.Attack3.skill_data;
                        if t.AutoFight(ds, skill_data.target_id) then
                            return;
                        end

                        -- 自动攻击
                        if t.AutoAttack(ds, t.Attack3, skill_data.target_id) then
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

            else
                local skill_data = t.Attack3.skill_data;
                local target_id = skill_data.target_id;
                local current = AvatarCache.GetAvatar(target_id);
                Fight.PlaySound("warrior_liekongzhan");
                if current == nil then
                    return;
                end
                Fight.PlayFollowEffect("warrior_male_attack_hit", 5.0, target_id, "body");
                Fight.DoHitTarget(current, ds);
            end
        end,
    };



    -- AOE
    t.AOE = {

        source = SourceType.System,

        skill_data = Fight.CreateSkillData();

        OnEnter = function (ds)
            local role_type = ds.role_type;
            if role_type == nil then
                local rtt = SkillExhibitRTT;
                rtt.ResetModelPos();
                local cell = SkillExhibitRTT.GetCellRoot();
                Fight.RttPlayStaticEffect(cell, "zhanshi_qungong", 5.0, ds.id, "");
            else
                local class = Fight.GetClass(ds);
                local skill_info = Fight.GetSkillInfoByIndexAndType(ds, const.AOE_Index, SkillType.Skill);
                local skill = class.GetSkillById(skill_info.id);
                if const.enable_zhuanjing and skill.zhuanjin ~= nil and skill.zhuanjin[10002] ~= nil then
                    Fight.PlayStaticEffect("zhanshi_qungong1", 5.0, ds.id, "");    
                else
                    Fight.PlayStaticEffect("zhanshi_qungong", 5.0, ds.id, "");
                end

                if role_type == RoleType.Player then
                    --下马先
                    client.horse.RideHorse(false)
                    Fight.CastSkill(ds, SkillType.Skill, const.AOE_Index);
                    Fight.DoRotateToCurrentTarget(ds);

                    local current = TargetSelecter.current;
                    if current ~= nil then
                        local skill_data = t.AOE.skill_data;
                        skill_data.target_id = current["id"];
                        skill_data.skill_id = skill_info.id;
                        local skill_level = skill.level;
                        local skill_cd = Fight.GetSkillCdTime(skill_info.id, skill_level);
                        Fight.DoStartSkillButtonCD(ds, const.AOE_Index, skill_cd / 1000, ds["is_auto_fighting"]);                    
                        Fight.DoSyncSkill(ds, skill_info.id, current["id"]);
                        TargetSelecter.SetFirstClassTarget(current);
                    else
                        local skill_data = t.AOE.skill_data;
                        skill_data.target_id = 0;
                        skill_data.skill_id = skill_info.id;
                    end

                else
                    -- 其他玩家逻辑
                    local skill_data = t.AOE.skill_data;
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
                local curr_state_normalized_time = ds.curr_state_normalized_time;
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
                Fight.PlaySound("warrior_leitingzhenji");
                local pos_x = ds.pos_x;
                local pos_y = ds.pos_y;
                local pos_z = ds.pos_z;
                local dir_x = ds.dir_x;
                local dir_y = 0;
                local dir_z = ds.dir_z;
                local distance = 3;
                local target_x = pos_x + dir_x * distance;
                local target_y = pos_y;
                local target_z = pos_z + dir_z * distance;
                local cell = SkillExhibitRTT.GetCellRoot();
                Fight.RttPlayPositionEffect(cell, "warrior_male_attack_hit", 5.0, 0, pos_y, 0, function () end);
            else
                local skill_data = t.AOE.skill_data;
                local target_id = skill_data.target_id;
                local current = AvatarCache.GetAvatar(target_id);
                if current == nil then
                    return;
                end
                Fight.PlaySound("warrior_leitingzhenji");
                Fight.PlayFollowEffect("warrior_male_attack_hit", 5.0, target_id, "body");
                Fight.DoHitTarget(current, ds);
            end
        end,
    };


    -- EX
    t.EX = {

        source = SourceType.System,

        skill_data = Fight.CreateSkillData(),

        OnEnter = function (ds)
            local role_type = ds.role_type;
            if role_type == nil then
                local rtt = SkillExhibitRTT;
                rtt.ResetModelPos();
            else
                local class = Fight.GetClass(ds);
                local skill_info = Fight.GetSkillInfoByIndexAndType(ds, const.EX_Index, SkillType.Skill);
                local skill = class.GetSkillById(skill_info.id);
                if role_type == RoleType.Player then
                    --下马先
                    client.horse.RideHorse(false)
                    Fight.CastSkill(ds, SkillType.Skill, const.EX_Index);
                    Fight.DoRotateToCurrentTarget(ds)
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
            if role_type == RoleType.Player then
                uFacadeUtility.ShakeMainCamera(ShakeCameraType.FAR_NEAR);
            end
        end,
        OnMove = function (ds)
        end,
        OnFrameEvent = function (ds)
            local role_type = ds.role_type;
            if role_type == nil then
                local frame_event_id = ds.frame_event_id;
                if frame_event_id == 1040101 or frame_event_id == 1140101 then
                    Fight.PlaySound("warrior_longhunzhinu");
                    local cell = SkillExhibitRTT.GetCellRoot();
                    Fight.RttPlayStaticEffect(cell, "warrior_male_EX", 5.0, ds.id, "");
                    return;
                end
                if frame_event_id == 1040102 or frame_event_id == 1140102 then
                    local cell = SkillExhibitRTT.GetCellRoot();
                    local pos_x = ds.pos_x;
                    local pos_y = ds.pos_y;
                    local pos_z = ds.pos_z;
                    local dist = 2.5;
                    local dir_x = ds.dir_x;
                    local dir_y = 0;
                    local dir_z = ds.dir_z;
                    local target_x = pos_x + dir_x * dist;
                    local target_y = 0;
                    local target_z = pos_z + dir_z * dist;
                    Fight.RttPlayPositionEffect(cell, "zhanshi_dazhao", 5.0, target_x, pos_y, target_z, function () end);
                    return;
                end
            else
                local frame_event_id = ds["frame_event_id"];
                if frame_event_id == 1040101 or frame_event_id == 1140101 then
                    Fight.PlaySound("warrior_longhunzhinu");
                    Fight.PlayStaticEffect("warrior_male_EX", 5.0, ds.id, "");
                    return;
                end
                if frame_event_id == 1040102 or frame_event_id == 1140102 then
                    local class = Fight.GetClass(ds);
                    local skill_info = Fight.GetSkillInfoByIndexAndType(ds, const.EX_Index, SkillType.Skill);
                    local skill = class.GetSkillById(skill_info.id);
                    local skill_data = t.EX.skill_data;
                    if const.enable_zhuanjing and skill ~= nil and skill.zhuanjin[10003] ~= nil then
                        Fight.PlayStaticEffect("zhanshi_dazhao1", 5.0, skill_data.target_id, "");
                    else
                        Fight.PlayStaticEffect("zhanshi_dazhao", 5.0, skill_data.target_id, "");
                    end
                    -- Fight.PlayStaticEffect("chiyanzhishenzadi", 3.0, ds.id, "");
                    -- MainUI.this:Delay(1.3, function()
                    --     Fight.PlayStaticEffect("chiyanzhishen_hit", 3.0, skill_data.target_id, "");
                    -- end)
                    -- return;
                end
            end
        end,
    };


    -- Special
    t.Special = {

        source = SourceType.System,

        skill_data = Fight.CreateSkillData(),

        move_data = Fight.CreateMoveData(),

        charging = false,

        move_speed = 5.0,

        speed_ratio = 3,

        OnEnter = function (ds)
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
                local move_speed = distance / 0.2 / t.Special.speed_ratio;
                ds["move_speed"] = move_speed;
                move_data.LoadModelPath(curr_time, pos_x, 0, pos_z, dir_x, dir_y, dir_z, dst_x, dst_y, dst_z, move_speed);
            else
                if role_type == RoleType.Player then
                    --下马先
                    client.horse.RideHorse(false)
                    Fight.CastSkill(ds, SkillType.Skill, const.Special_Index);
                    Fight.DoRotateToCurrentTarget(ds)
                    local class = Fight.GetClass(ds);
                    local skill_info = Fight.GetSkillInfoByIndexAndType(ds, const.Special_Index, SkillType.Skill);
                    local skill = class.GetSkillById(skill_info.id);
                    local current = TargetSelecter.current;
                    if current ~= nil then
                        local skill_data = t.Special.skill_data;
                        skill_data.target_id = current["id"];
                        skill_data.skill_id = skill_info.id;
                        local skill_level = skill.level;
                        local skill_cd = Fight.GetSkillCdTime(skill_info.id, skill_level)
                        Fight.DoStartSkillButtonCD(ds, const.Special_Index, skill_cd / 1000, ds["is_auto_fighting"]);
                        -- Fight.DoSyncSkill(ds, skill_info.id, current["id"]);
                        TargetSelecter.SetFirstClassTarget(current);
                    else
                        local skill_data = t.Special.skill_data;
                        skill_data.target_id = 0;
                        skill_data.skill_id = skill_info.id;
                    end
                    local pos_x = ds["pos_x"];
                    local pos_y = ds["pos_y"];
                    local pos_z = ds["pos_z"];
                    local dst_x = current["pos_x"];
                    local dst_y = current["pos_y"];
                    local dst_z = current["pos_z"];
                    local dx = dst_x - pos_x;
                    local dy = dst_y - pos_y;
                    local dz = dst_z - pos_z;
                    local distance = math.sqrt(dx * dx + dz * dz);
                    local dir_x = dx / distance;
                    local dir_y = 0;
                    local dir_z = dz / distance;
                    t.Special.move_speed = distance; -- / 2.5;
                    local move_data = t.Special.move_data;
                    local curr_time = ds["curr_time"];
                    local move_speed = distance / 0.2 / t.Special.speed_ratio;
                    ds["move_speed"] = move_speed;
                    local result = move_data.LoadChargePath(curr_time, pos_x, pos_y, pos_z, dir_x, dir_y, dir_z, dst_x, dst_y, dst_z, 0.5, move_speed);
                    if result then
                        local goal_x = move_data.goal_x;
                        local goal_y = move_data.goal_y;
                        local goal_z = move_data.goal_z;
                        uFacadeUtility.SyncCastSkill(skill_info.id, current.id, goal_x, goal_y, goal_z);
                    end
                  
                else
                    -- 其他玩家逻辑
                    local skill_data = t.EX.skill_data;
                    local target_id = skill_data.target_id;
                    local target = AvatarCache.GetAvatar(target_id);
                    if target ~= nil then
                        Fight.DoRotateToTarget(ds, target);
                    end
                    local pos_x = ds["pos_x"];
                    local pos_y = ds["pos_y"];
                    local pos_z = ds["pos_z"];
                    local dst_x = target["pos_x"];
                    local dst_y = target["pos_y"];
                    local dst_z = target["pos_z"];
                    local dx = dst_x - pos_x;
                    local dy = dst_y - pos_y;
                    local dz = dst_z - pos_z;
                    local distance = math.sqrt(dx * dx + dz * dz);
                    local move_data = t.Special.move_data;
                    local curr_time = ds["curr_time"];
                    local move_speed = distance / 0.2 / t.Special.speed_ratio;
                    ds["move_speed"] = move_speed;
                    local result = move_data.LoadChargePath(curr_time, pos_x, pos_y, pos_z, dir_x, dir_y, dir_z, dst_x, dst_y, dst_z, 0.5, move_speed);
                    if result then
                        local goal_x = move_data.goal_x;
                        local goal_y = move_data.goal_y;
                        local goal_z = move_data.goal_z;
                        uFacadeUtility.SyncCastSkill(skill_data.skill_id, target_id, goal_x, goal_y, goal_z);
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
                    local move_data = t.Special.move_data;
                    local src_x = move_data.src_x;
                    local src_y = move_data.src_y;
                    local src_z = move_data.src_z;
                    uFacadeUtility.SetAvatarPosForModel(ds.id, src_x, src_y, src_z);
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

                        -- 技能跳转
                        if Fight.PlayerTryJumpSkill(ds) then
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

        OnMove = function (ds)
            local role_type = ds.role_type;
            if role_type == nil then
                local charging = t.Special.charging;
                if not charging then
                    return;
                end
                local move_data = t.Special.move_data;
                move_data.DoStateUpdateMoveForModel(ds);
            else
                local charging = t.Special.charging;
                if not charging then
                    return;
                end
                local move_data = t.Special.move_data;
                move_data.DoStateUpdateMove(ds);
            end
        end,

        OnExit = function (ds)
            local role_type = ds.role_type;
            if role_type == nil then
                ds["move_speed"] = 5;
                uFacadeUtility.SetStateSpeedForModel(ds.id, 1);
            else
                ds["move_speed"] = 5;
                uFacadeUtility.SetStateSpeed(ds.id, 1);
            end
        end,

        OnFrameEvent = function (ds)
            local role_type = ds.role_type;
            if role_type == nil then
                local frame_event_id = ds["frame_event_id"];
                if frame_event_id == 1030101 or frame_event_id == 1130101 then
                    local state = t.Special;
                    local move_data = state.move_data;
                    t.Special.charging = true;
                    local curr_time = ds["curr_time"];
                    move_data.start_time = curr_time;
                    move_data.last_time = curr_time;
                    uFacadeUtility.SetStateSpeedForModel(ds.id, 1 / t.Special.speed_ratio);
                    Fight.PlaySound("warrior_tujin");
                    Fight.RttPlayFollowEffect("warrior_male_yidong", 5.0, ds.id, "");
                elseif frame_event_id == 1030102 or frame_event_id == 1130102 then
                    t.Special.charging = false;
                    uFacadeUtility.SetStateSpeedForModel(ds.id, 1 / t.Special.speed_ratio);
                    -- local class = Fight.GetClass(ds);
                    -- local skill = class.GetSkillByTypeAndIndex(SkillType.Skill, const.Special_Index);
                    -- if const.enable_zhuanjing and skill.zhuanjin ~= nil and skill.zhuanjin[10004] ~= nil then
                    --     Fight.PlayFollowEffect("warrior_male_attack_hit", 2.0, skill_data.target_id, "body");
                    --     Fight.PlayFollowEffect("zhanshi_chongjibo", 2.0, skill_data.target_id, "");
                    -- end
                end
            else
                local frame_event_id = ds["frame_event_id"];
                local skill_data = t.Special.skill_data;
                if frame_event_id == 1030101 or frame_event_id == 1130101 then
                    local state = t.Special;
                    local move_data = state.move_data;
                    t.Special.charging = true;
                    local curr_time = ds["curr_time"];
                    move_data.start_time = curr_time;
                    move_data.last_time = curr_time;
                    uFacadeUtility.SetStateSpeed(ds.id, 1 / t.Special.speed_ratio);
                    Fight.PlaySound("warrior_tujin");
                    Fight.PlayFollowEffect("warrior_male_yidong", 5.0, ds.id, "");
                    return;
                elseif frame_event_id == 1030102 or frame_event_id == 1130102 then
                    t.Special.charging = false;
                    uFacadeUtility.SetStateSpeed(ds.id, 2);
                    local class = Fight.GetClass(ds);
                    local skill = class.GetSkillByTypeAndIndex(SkillType.Skill, const.Special_Index);
                    if const.enable_zhuanjing and skill.zhuanjin ~= nil and skill.zhuanjin[10004] ~= nil then
                        Fight.PlayFollowEffect("warrior_male_attack_hit", 2.0, skill_data.target_id, "body");
                        Fight.PlayFollowEffect("zhanshi_chongjibo", 2.0, skill_data.target_id, "");
                    end
                end
            end
        end,
    };



    return t;
end
