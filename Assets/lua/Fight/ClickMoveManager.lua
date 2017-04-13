function CreateClickMoveManager()
	local t = {};
	local click_pos = {};
	click_pos.x = 0;
	click_pos.y = 0;
	click_pos.z = 0;
	t.click_pos = click_pos;
	local is_click_moving = false;
	t.IsClickMoving = function ()
		return t.is_click_moving;
	end
	t.GetClickPos = function ()
		return t.click_pos;
	end;
	t.nav_path = {};
	t.ClickPosCanNavigate = function (dst_x, dst_y, dst_z)
		local player = AvatarCache.me;
		if player == nil then
			return false;
		end
		local pos_x = player.pos_x;
		local pos_y = player.pos_y;
		local pos_z = player.pos_z;
		local nav_path = t.nav_path;
		local result = uFacadeUtility.CalcPath(pos_x, pos_y, pos_z, dst_x, dst_y, dst_z, nav_path);
		for i = 1, #nav_path do
			nav_path[i] = nil;
		end
		return result;
	end;
	t.OnClickMove = function (dst_x, dst_y, dst_z)
		if not t.ClickPosCanNavigate(dst_x, dst_y, dst_z) then
			--ui.showMsg("目标无法到达!");
			return;
		end
		local is_click_moving = t.is_click_moving;
		if is_click_moving then
			local click_pos = t.click_pos;
			click_pos["x"] = dst_x;
			click_pos["y"] = dst_y;
			click_pos["z"] = dst_z;
		else
			local click_pos = t.click_pos;
			click_pos["x"] = dst_x;
			click_pos["y"] = dst_y;
			click_pos["z"] = dst_z;
			t.is_click_moving = true;
		end
	end;
	t.Clear = function ()
		-- print("ClickMoveManager.Clear")
		t.is_click_moving = false;
	end;
	t.OnSceneLoaded = function()
		t.Clear()
	end;

	-- 当角色点击移动到达目的地的时候触发这个事件
	t.OnArrived = function (ds)
		local role_type = ds.role_type;
		if role_type == RoleType.Player then
			local is_ghost = ds.is_ghost;
			if is_ghost then
				ds.is_ghost = false;
			end
		end
	end;

	-- 角色终止点击移动
	t.OnCancelClickMoving = function (ds)
		local role_type = ds.role_type;
		if role_type == RoleType.Player then
			local is_ghost = ds.is_ghost;
			if is_ghost then
				ds.is_ghost = false;
			end
		end
	end;

	return t;
end


ClickMoveManager = CreateClickMoveManager();