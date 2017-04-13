
function CreateAutoPathfindingManager()
	local t = {};
	-- 传送
	t.is_teleporting = false;
	-- 传送
	t.IsTeleporting = function ()
		return t.is_teleporting;
	end;
	-- 设置传送
	t.SetTeleporting = function (is_teleporting)
		t.is_teleporting = is_teleporting;
	end;
	-- 设置类型
	t.type = ArriveTriggerEvent.ATE_None;
	t.flyShoe = true;
	-- 设置飞鞋
	t.SetFlyShoe = function (flyShoe)
		t.flyShoe = flyShoe;
	end;
	-- 获取飞鞋
	t.GetFlyShoe = function ()
		return t.flyShoe;
	end;
	-- 获取 npc sid
	t.GetNpcSid = function ()
		return t.npcSid;
	end;
	-- 传送位置
	t.transmit_scene_sid = 0;
	t.transmit_fenxian = 0;
	t.transmit_pos_x = 0;
	t.transmit_pos_y = 0;
	t.transmit_pos_z = 0;
	-- 设置传送点
	t.SetTransmitPos = function (sceneSid, fenxian, pos_x, pos_y, pos_z)
		t.transmit_scene_sid = sceneSid;
		t.transmit_fenxian = fenxian;
		t.transmit_pos_x = pos_x;
		t.transmit_pos_y = pos_y;
		t.transmit_pos_z = pos_z;
	end;
	-- 获取传送点
	t.GetTransmitPos = function ()
		return t.transmit_scene_sid, t.transmit_fenxian, t.transmit_pos_x, t.transmit_pos_y, t.transmit_pos_z;
	end;
	-- 到达回调
	t.global_arrived_listeners = {};
	-- 添加到达回调
	t.AddGlobalArrivedListener = function (listener)
		local listeners = t.global_arrived_listeners;
		listeners[#listeners + 1] = listener;
	end;
	-- 清除到达回调
	t.ClearGlobalArrivedListeners = function ()
		local listeners = t.global_arrived_listeners;
		for i = 1, #listeners do
			listeners[i] = nil;
		end
	end;
	-- 触发回调
	t.FireGlobalArrived = function ()
		local listeners = t.global_arrived_listeners;
		--print("[pathfinding] fire global arrived: " .. #listeners);
		for i = 1, #listeners do
			local listener = listeners[i];
			listener();
		end
	end;
	-- 局部到达回调
	t.local_arrived_listeners = {};
	-- 添加到达回调
	t.AddLocalArrivedListener = function (listener)
		local listeners = t.local_arrived_listeners;
		listeners[#listeners + 1] = listener;
	end;
	-- 清除到达回调
	t.ClearLocalArrivedListeners = function ()
		local listeners = t.local_arrived_listeners;
		for i = 1, #listeners do
			listeners[i] = nil;
		end
	end;
	-- 触发回调
	t.FireLocalArrived = function ()
		local listeners = t.local_arrived_listeners;
		for i = 1, #listeners do
			local listener = listeners[i];
			listener();
		end
	end;
	-- 添加寻路中回调
	t.update_listeners = {};
	-- 添加寻路回调
	t.AddUpdateListener = function (listener)
		local listeners = t.update_listeners;
		listeners[#listeners + 1] = listener;
	end;
	-- 清空更新回调
	t.ClearUpdateListeners = function ()
		local listeners = t.update_listeners;
		for i = 1, #listeners do
			listeners[i] = nil;
		end
	end;
	-- 触发回调
	t.FireUpdate = function ()
		local listeners = t.update_listeners;
		for i = 1, #listeners do
			local listener = listeners[i];
			listener();
		end
	end;
	-- 到达回调
	t.cancel_listeners = {};
	-- 添加到达回调
	t.AddCancelListener = function (listener)
		local listeners = t.cancel_listeners;
		listeners[#listeners + 1] = listener;
	end;
	-- 清除到达回调
	t.ClearCancelListeners = function ()
		local listeners = t.cancel_listeners;
		for i = 1, #listeners do
			listeners[i] = nil;
		end
	end;
	-- 触发回调
	t.FireCancel = function ()
		local listeners = t.cancel_listeners;
		for i = 1, #listeners do
			local listener = listeners[i];
			listener();
		end
	end;
	-- 自动寻路中
	t.is_auto_pathfinding = false;
	-- 是否自动寻路
	t.IsAutoPathfinding = function ()
		return t.is_auto_pathfinding;
	end;
	-- 是否是改变目标
	t.is_change_goal = false;
	-- 是否改变目标
	t.IsChangeGoal = function ()
		return t.is_change_goal;
	end;
	-- 是否要修改局部路径
	t.is_local_path_change = false;
	-- 是否要修改局部路径
	t.IsLocalPathChange = function ()
		return t.is_local_path_change;
	end;
	-- 重置局部路径修改标志
	t.ResetLocalPathChange = function ()
		t.is_local_path_change = false;
	end;
	-- 全局路径
	t.global_path = {};
	-- 加载路径
	-- src_scene_sid 开始场景 sid
	-- src_pos_x 开始位置 x
	-- src_pos_y 开始位置 y
	-- src_pos_z 开始位置 z
	-- dst_scene_sid 结束场景 sid
	-- dst_pos_x 结束位置 x
	-- dst_pos_y 结束位置 y
	-- dst_pos_z 结束位置 z
	t.LoadGlobalPath = function (src_scene_sid, src_fenxian, src_pos_x, src_pos_y, src_pos_z, dst_scene_sid, dst_fenxian, dst_pos_x, dst_pos_y, dst_pos_z)
		t.ClearGlobalPath();
		local is_auto_pathfinding = t.is_auto_pathfinding;
		if is_auto_pathfinding then
			local path = t.global_path;
			if path.dst_scene_sid == dst_scene_sid and
			   path.dst_pos_x == dst_pos_x and
			   path.dst_pos_z == dst_pos_z then
			   --print("is_auto_pathfinding=false");
			   t.is_auto_pathfinding = false;
			   t.is_change_goal = false;
				return;
			end
			local path = t.global_path;
			path.src_scene_sid = src_scene_sid;
			path.src_fenxian = src_fenxian;
			path.src_pos_x = src_pos_x;
			path.src_pos_y = src_pos_y;
			path.src_pos_z = src_pos_z;
			path.dst_scene_sid = dst_scene_sid;
			path.dst_fenxian = dst_fenxian;
			path.dst_pos_x = dst_pos_x;
			path.dst_pos_y = dst_pos_y;
			path.dst_pos_z = dst_pos_z;
			--print("is_auto_pathfinding=true");
			t.is_auto_pathfinding = true;
			t.is_change_goal = true;
		else
			local path = t.global_path;
			path.src_scene_sid = src_scene_sid;
			path.src_fenxian = src_fenxian;
			path.src_pos_x = src_pos_x;
			path.src_pos_y = src_pos_y;
			path.src_pos_z = src_pos_z;
			path.dst_scene_sid = dst_scene_sid;
			path.dst_fenxian = dst_fenxian;
			path.dst_pos_x = dst_pos_x;
			path.dst_pos_y = dst_pos_y;
			path.dst_pos_z = dst_pos_z;
			--print("is_auto_pathfinding=true");
			t.is_auto_pathfinding = true;
			t.is_change_goal = false;
		end
	end;
	-- 清除全局路径
	t.ClearGlobalPath = function ()
		-- print(debug.traceback());
		local path = t.global_path;
		for k, v in pairs(path) do
			path[k] = nil;
		end
	end;
	-- 清除回调
	t.ClearCallbacks = function ()
		t.ClearCancelListeners();			-- 清除 Cancel 监听
		t.ClearUpdateListeners();			-- 清除 Update 监听
		t.ClearLocalArrivedListeners();		-- 清除局部路径 Arrived 监听
		t.ClearGlobalArrivedListeners();	-- 清除全局路径 Arrvied 监听
	end;
	-- 清理自动寻路
	t.ClearAutoPathfinding = function ()
		t.ClearLocalPath();					-- 清除局部路径
		t.ClearGlobalPath();				-- 清除全局路径
		--print("is_auto_pathfinding=false:" .. debug.traceback());
		t.is_auto_pathfinding = false;		
		t.is_change_goal = false;
		t.is_teleporting = false;
	end;
	-- 清空路径
	t.Clear = function ()
		--print("[pathfinding] Clear");
		t.ClearAutoPathfinding();
		t.ClearCallbacks();
	end;
	-- 获取全局路径
	t.GetGlobalPath = function ()
		return t.global_path;
	end;
	-- 全局场景到达回调
	t.OnGlobalPathArrived = function ()
		--print("[pathfinding] OnGlobalPathArrived: " .. debug.traceback());
		if t.flyShoe then
			EventManager.onEvent(Event.ON_END_AUTO_PATHFINDING);
		end
		t.FireGlobalArrived();
	end;
	-- 是否同图传送
	t.IsSameScene = function ()
		local global_path = t.global_path;
		local dst_scene_sid = global_path.dst_scene_sid;
		return dst_scene_sid == DataCache.scene_sid;
	end;
	-- 是否是目标场景分线
	t.IsDstSceneFenxian = function()
		local global_path = t.global_path;
		local curr_scene_sid = DataCache.scene_sid;
		local curr_scene_fenxian = DataCache.fenxian;
		local dst_scene_sid = global_path.dst_scene_sid;
		local dst_scene_fenxian = global_path.dst_scene_fenxian;
		return (curr_scene_sid == dst_scene_sid) and (curr_scene_fenxian == dst_scene_fenxian)
	end;
	-- 是否已到达终点
	t.IsArrived = function ()
		local global_path = t.global_path;
		local player = AvatarCache.me;
		local curr_scene_sid = DataCache.scene_sid;
		local curr_scene_fenxian = DataCache.fenxian;
		local pos_x = player.pos_x;
		local pos_y = player.pos_y;
		local pos_z = player.pos_z;
		local dst_scene_sid = global_path.dst_scene_sid;
		local dst_scene_fenxian = global_path.dst_fenxian;
		local dst_pos_x = global_path.dst_pos_x;
		local dst_pos_y = global_path.dst_pos_y;
		local dst_pos_z = global_path.dst_pos_z;
		local dx = dst_pos_x - pos_x;
		local dz = dst_pos_z - pos_z;
		local dist2 = dx * dx + dz * dz;
		-- print(string.format("IsArrived: curr_scene_sid=%d, my_pos={%f, %f, %f}", curr_scene_sid, pos_x, pos_y, pos_z))
		-- print(string.format("dst_scene_sid=%d, dst_pos={%f, %f, %f}, dist=%f", dst_scene_sid, dst_pos_x, dst_pos_y, dst_pos_z, math.sqrt(dist2)))
		local Ret = (curr_scene_sid == dst_scene_sid) and (curr_scene_fenxian == dst_scene_fenxian) and (dist2 < 1);
		-- print(Ret)
		return Ret;
	end;
	-- 局部路径
	t.local_path = {};
	-- 清除局部路径
	t.ClearLocalPath = function ()
		local path = t.local_path;
		for k, v in pairs(path) do
			path[k] = nil;
		end
	end;
	-- 获取本地路径
	t.GetLocalPath = function ()
		return t.local_path;
	end;
	-- 加载局部路径
	t.LoadLocalPath = function (src_x, src_y, src_z, dst_x, dst_y, dst_z)
		local path = t.local_path;
		path.src_x = src_x;
		path.src_y = src_y;
		path.src_z = src_z;
		path.dst_x = dst_x;
		path.dst_y = dst_y;
		path.dst_z = dst_z;
	end;
	-- 根据玩家当前位置寻路后修正寻路终点
	t.ModifyDstPos = function(dst_pos)
		local player = AvatarCache.me;
		if player == nil then
			return
		end
		local path = {}
		local result = Fight.CalcChasePath(player.pos_x, player.pos_y, player.pos_z, dst_pos[1], dst_pos[2], dst_pos[3], 0.5, path);
		if result == false then
			return dst_pos
		end
		local final_z = path[#path]
		local final_y = path[#path-1]
		local final_x = path[#path-2]
		return {final_x, final_y, final_z}
	end;
	-- 跳转自动寻路状态, 不需要状态跳转
	-- 如果直接跳转的话，会导致技能在释放的时候僵直时间还没有过的情况下
	-- 进入自动寻路状态，这个时候会导致服务端处于僵直状态，不能移动，前后端
	-- 移动不再同步，导致位置不一致问题。
	t.JumpAutoPathfindingState = function (ds)
		-- local curr_state_name = ds.curr_state_name;
		-- if curr_state_name ~= "PathfindingRun" then
		-- 	Fight.DoJumpState(ds, SourceType.Player, "PathfindingRun", 0);
		-- end
	end;

	-- 当前场景内的自动寻路
	t.StartPathfinding_S = function (dst_x, dst_y, dst_z, flyShoe, arrived_callback)
		-- print("场景内的自动寻路")
		local curr_scene_sid = DataCache.scene_sid;
		local curr_fenxian = DataCache.fenxian;
		t.StartPathfinding(curr_scene_sid, curr_fenxian, dst_x, dst_y, dst_z, flyShoe, arrived_callback);
	end;

	-- 同场景分线自动寻路
	t.StartPathing_F = function(sid, fenxian, pos, flyShoe, cb)
	    if nil == fenxian then
	        fenxian = 0;
	    end
	    fenxian = tonumber(fenxian);
	    local curr_fenxian = DataCache.fenxian;
	    -- 同一分线自动寻路
	    if fenxian == 0 or curr_fenxian == fenxian then
	    	t.StartPathfinding(sid, fenxian, pos.x, 0, pos.y, flyShoe, cb);
	    else
	    	StopPathing();
	    	-- 不同分线自动寻路
	    	local msg = {cmd = "fenxian_transmit", fenxian_id = fenxian}
	        Send(msg, function(msgTable)
	        	t.StartPathfinding(sid, fenxian, pos.x, 0, pos.y, flyShoe, cb);
	        end);
	    end
	end

	-- 开始行走
	t.StartPathfinding = function (dst_scene_sid, dst_fenxian, dst_x, dst_y, dst_z, flyShoe, arrived_callback)
		--print("开始行走 ==>> StartPathfinding")
		t.Clear();
		
		-- print(string.format("---------- StartPathfinding: dst_scene_sid=%d, dst_fenxian=%d", dst_scene_sid, dst_fenxian));
		-- print(string.format("---------- pos %d, %d, %d", dst_x, dst_y, dst_z));
		local player = AvatarCache.me;
		local pos_x = player.pos_x;
		local pos_y = player.pos_y;
		local pos_z = player.pos_z;

		t.SetFlyShoe(flyShoe);
		t.SetTransmitPos(dst_scene_sid, dst_fenxian, dst_x, dst_y, dst_z);

		-- 添加到达
		if arrived_callback ~= nil then
			t.AddGlobalArrivedListener(arrived_callback);
		end

		-- 加载全局路径
		local curr_scene_sid = DataCache.scene_sid;
		local curr_fenxian = DataCache.fenxian;
		t.LoadGlobalPath(curr_scene_sid, curr_fenxian, pos_x, pos_y, pos_z, dst_scene_sid, dst_fenxian, dst_x, dst_y, dst_z);
		if t.IsArrived() then
			t.OnLocalPathArrived();
			return;
		end

		-- 加载局部路径
		local curr_state_name = player.curr_state_name;
		local curr_scene_sid = DataCache.scene_sid;
		local global_path = t.global_path;
		if global_path.dst_scene_sid == curr_scene_sid then

			local player = AvatarCache.me;
			uFacadeUtility.StopAllEffects(player.id, "dutiao");

			--print("同场景寻路!!")
			--同场景寻路
			if curr_state_name == "PathfindingRun" then
				local state = Fight.GetState(player, curr_state_name);
				local move_data = state.move_data;
				local goal_x = move_data.goal_x;
				local goal_y = move_data.goal_y;
				local goal_z = move_data.goal_z;
				local dst_pos = {global_path.dst_pos_x, global_path.dst_pos_y, global_path.dst_pos_z}
				dst_pos = t.ModifyDstPos(dst_pos)
				if goal_x ~= dst_pos[1] or goal_z ~= dst_pos[3] then
					global_path.dst_pos_x = dst_pos[1];
					global_path.dst_pos_y = dst_pos[2];
					global_path.dst_pos_z = dst_pos[3];
					t.LoadLocalPath(pos_x, pos_y, pos_z, dst_pos[1], dst_pos[2], dst_pos[3]);
					t.is_local_path_change = true;
				else
					t.is_local_path_change = false;
				end
			else
				local dst_pos = {global_path.dst_pos_x, global_path.dst_pos_y, global_path.dst_pos_z}
				dst_pos = t.ModifyDstPos(dst_pos)
				global_path.dst_pos_x = dst_pos[1];
				global_path.dst_pos_y = dst_pos[2];
				global_path.dst_pos_z = dst_pos[3];
				t.LoadLocalPath(pos_x, pos_y, pos_z, dst_pos[1], dst_pos[2], dst_pos[3]);
				t.is_local_path_change = false;
				t.JumpAutoPathfindingState(player);
			end

		else
			


			local player = AvatarCache.me;
			local curr_state_name = player.curr_state_name;
			if curr_state_name ~= "Idle" then
				if curr_state_name == "PathfindingRun" then
					local state = Fight.GetState(player, "PathfindingRun");
					state.canceled = true;
				end
				Fight.DoJumpState(player, SourceType.System, "Idle", 0);
			end

			-- 播放过图特效
			uFacadeUtility.StopAllEffects(player.id, "dutiao");
			Fight.PlayFollowEffect("dutiao", 5.0, player.id, "");

			-- print("跨场景寻路!!")
			--跨场景寻路
			--设置走到当前地图的传送水晶
			-- local dst_x = 0;
			-- local dst_y = 0;
			-- local dst_z = 0;
			-- local teleport_data = tb.TeleportTable[curr_scene_sid];
			-- if teleport_data == nil then
			-- 	local scene_data = tb.SceneTable[curr_scene_sid];
			-- 	local bornpos = scene_data.bornpos;
			-- 	dst_x = bornpos[1];
			-- 	dst_z = bornpos[2];
			-- else
			-- 	local teleport_pos = teleport_data.pos;
			-- 	dst_x = teleport_pos[1];
			-- 	dst_z = teleport_pos[2];
			-- end
			-- -- print(string.format("当前场景传送点 %d,%d,%d", dst_x, dst_y, dst_z))
			-- local dst_pos = {dst_x, dst_y, dst_z}
			-- dst_pos = t.ModifyDstPos(dst_pos)
			-- t.LoadLocalPath(pos_x, pos_y, pos_z, dst_pos[1], dst_pos[2], dst_pos[3]);
			-- t.is_local_path_change = false;
			-- if curr_state_name ~= "PathfindingRun" then
			-- 	t.JumpAutoPathfindingState(player);
			-- end
		end
	end;
	-- 局部路径开始回调
	t.OnLocalPathStart = function (ds)
		--print("OnLocalPathStart: " .. debug.traceback());
		if t.flyShoe then
			EventManager.onEvent(Event.ON_START_AUTO_PATHFINDING);
		end
	end;
	-- 局部路径完成回调
	t.OnLocalPathArrived = function (ds)
		--print("============ [pathfinding] OnLocalPathArrived");
		t.FireLocalArrived();
		if t.IsArrived() then
			t.ClearAutoPathfinding();
			-- 全局路径到达回调
			t.OnGlobalPathArrived();
			t.ClearCallbacks();
		else
			--局部路径没有完成就切图？？
			t.ChangeScene();
		end
	end;
	-- 局部路径回调
	t.OnLocalPathUpdate = function (ds)
		t.FireUpdate();
	end;
	-- 局部路径取消回调
	t.OnLocalPathCancelled = function (ds)
		-- print("[pathfinding] OnLocalPathCancelled");
		if t.flyShoe then
			EventManager.onEvent(Event.ON_END_AUTO_PATHFINDING);
		end
		t.ClearAutoPathfinding();
		t.FireCancel();
		t.ClearCallbacks();
	end;
	-- 切图
	t.ChangeScene = function ()
		-- print("ChangeScene")
		-- 取消读条
		t.Abort();
		client.commonProcess.CancelProcess();
		local global_path = t.global_path;
		local dst_scene_sid = global_path.dst_scene_sid;
		local dst_fenxian = global_path.dst_fenxian;
		--已经到达目标场景分线 
		if t.IsDstSceneFenxian() then
			--print("[pathfinding] Same Scene, Same fenxian");
			return;
		end

		--print(string.format("[pathfinding] ChangeScene: dst_scene_sid=%d, dst_fenxian=%d", dst_scene_sid, dst_fenxian));
		PortalCrystal.SendTramsitMsg(dst_scene_sid, dst_fenxian);
	end;
	-- 执行自动寻路
	t.DoPathfinding = function ()
		-- 还没到达，如果当前场景是目的场景
		local player = AvatarCache.me;
		local pos_x = player.pos_x;
		local pos_y = player.pos_y;
		local pos_z = player.pos_z;
		local curr_scene_sid = DataCache.scene_sid;
		local global_path = t.global_path;
		-- 当前在同一个分线，同一个场景中, 直接加载局部路径
		if global_path.dst_scene_sid == curr_scene_sid then
			--print("目标场景段寻路!")
			local dst_pos = {global_path.dst_pos_x, global_path.dst_pos_y, global_path.dst_pos_z}
			dst_pos = t.ModifyDstPos(dst_pos)
			global_path.dst_pos_x = dst_pos[1];
			global_path.dst_pos_y = dst_pos[2];
			global_path.dst_pos_z = dst_pos[3];
			-- print(string.format("dst_pos %d,%d,%d", dst_pos[1], dst_pos[2], dst_pos[3]))
			t.LoadLocalPath(pos_x, pos_y, pos_z, dst_pos[1], dst_pos[2], dst_pos[3]);
			-- 需要跳转状态
			t.JumpAutoPathfindingState(player);
		else
			--print("前一个场景段寻路!")
			-- 判断是否已经到达传送水晶
			local dst_x = 0;
			local dst_y = 0;
			local dst_z = 0;
			local teleport_data = tb.TeleportTable[curr_scene_sid];
			if teleport_data == nil then
				local scene_data = tb.SceneTable[curr_scene_sid];
				local bornpos = scene_data.bornpos;
				dst_x = bornpos[1];
				dst_z = bornpos[2];
			else
				local teleport_pos = teleport_data.pos;
				dst_x = teleport_pos[1];
				dst_z = teleport_pos[2];
			end
			local dx = dst_x - pos_x;
			local dz = dst_z - pos_z;
			local dist2 = dx * dx + dz * dz;
			if dist2 < 0.01 then
				-- 已经到达传送水晶了
				-- print("已经到达传送水晶了!!")
				-- print("changeScene")
				t.ChangeScene();
			else
				-- 移动到传送水晶
				local dst_pos = {dst_x, dst_y, dst_z}
				dst_pos = t.ModifyDstPos(dst_pos)
				t.LoadLocalPath(pos_x, pos_y, pos_z, dst_pos[1], dst_pos[2], dst_pos[3]);
				t.JumpAutoPathfindingState(player);
			end
		end
	end;
	-- 场景加载结束
	t.OnSceneLoaded = function ()
		-- 如果是传送
		if t.IsTeleporting() then
			-- print("Teleporting");
			-- 清除路径
			t.ClearAutoPathfinding();
			-- 全局路径到达回调
			t.OnGlobalPathArrived();
			t.ClearCallbacks();
			return;
		end
		--print("1");
		-- print(string.format("OnSceneLoaded: curr_scene_sid=%d, curr_fenxian=%d", DataCache.scene_sid, DataCache.fenxian));
		local player = AvatarCache.me;
		local pos_x = player.pos_x;
		local pos_y = player.pos_y;
		local pos_z = player.pos_z;
		--print("2");
		-- print(string.format("OnSceneLoaded: player pos={%f, %f, %f}", pos_x, pos_y, pos_z));
		-- 不在自动寻路中
		local is_auto_pathfinding = t.is_auto_pathfinding;
		if not is_auto_pathfinding then
			return;
		end
		--print("3");
		-- 已经到达
		if t.IsArrived() then
			-- print("Arrived");
			-- 清除路径
			t.ClearAutoPathfinding();
			-- 全局路径到达回调
			t.OnGlobalPathArrived();
			t.ClearCallbacks();
			return;
		end
		--print("4");
		--print("DoPathfinding");
		t.DoPathfinding();
	end;
	-- 取消自动寻路但是不跳转状态
	t.CancelWithoutJumpIdle = function ()
		--print("[pathfinding] Cancel");
		--print(debug.traceback())
		local player = AvatarCache.me;
		local curr_state_name = player.curr_state_name;
		if curr_state_name == "PathfindingRun" then
			t.OnLocalPathCancelled();
		else
			t.OnLocalPathCancelled();
			t.Clear();
		end
		--干掉进度条(不变红)
		client.commonProcess.CancelProcess()
	end;
	-- 取消自动寻路
	t.Cancel = function ()
		--print("[pathfinding] Cancel");
		--print(debug.traceback())
		local player = AvatarCache.me;
		if player ~= nil then
			local curr_state_name = player.curr_state_name;
			if curr_state_name == "PathfindingRun" then
				t.OnLocalPathCancelled();
				Fight.DoJumpState(player, SourceType.System, "Idle", 0);
			else
				t.OnLocalPathCancelled();
				t.Clear();
			end
			--干掉进度条(不变红)
			client.commonProcess.CancelProcess()
		end
	end;
	-- 飞鞋
	t.FlyShoe = function ()
		-- 全局路径到达回调
		t.OnGlobalPathArrived();
		t.Clear();
	end;
	-- 角色退出自动寻路状态
	t.Abort = function ()
		--print("[pathfinding] Abort");
		local player = AvatarCache.me;
		if player ~= nil then
			local curr_state_name = player.curr_state_name;
			if curr_state_name ~= "Idle" then
				Fight.DoJumpState(player, SourceType.System, "Idle", 0);
			end
		end
	end;

	return t;
end

AutoPathfindingManager = CreateAutoPathfindingManager();