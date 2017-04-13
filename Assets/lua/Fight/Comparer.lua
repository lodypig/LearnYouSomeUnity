


function CreateComparer()
	local t = {};

	-- 比较组id小
	t.CompareLessGroupId = function (a, b)
		local group_a = a.group;
		local group_b = b.group;
		if group_a == nil and group_b == nil then
			return 0
		elseif group_a < group_b then
			return -1;
		elseif group_a > group_b then
			return 1;
		else
			return 0;
		end
	end

	-- 比较血量低
	t.CompareLowerBlood = function (a, b)
		local hp_a = a["hp"];
		local hp_b = b["hp"];
        if hp_a < hp_b then
            return -1;
        elseif hp_a > hp_b then
        	return 1;
        else
        	return 0;
        end
	end

	-- 比较是否攻击玩家
	t.CompareIsAttackingPlayer = function (a, b)
		local player = AvatarCache.me;
		local _t = player._t;
		local is_attacking_a = _t.IsAvatarAttackingMe(a["id"]);
		local is_attacking_b = _t.IsAvatarAttackingMe(b["id"]);
		if is_attacking_a and not is_attacking_b then
			return -1;
		elseif not is_attacking_a and is_attacking_b then
			return 1;
		else
			return 0;
		end
	end

	-- 比较是否是大Boss
	t.CompareIsBigBoss = function (a, b)
		local is_big_boss_a = Checker.CheckIsBigBoss(a);
		local is_big_boss_b = Checker.CheckIsBigBoss(b);
		if is_big_boss_a and not is_big_boss_b then
			return -1;
		elseif not is_big_boss_a and is_big_boss_b then
			return 1;
		else
			return 0;
		end
	end

	-- 比较是否其他玩家
	t.CompareIsOtherPlayer = function (a, b)
		local is_other_player_a = Checker.CheckIsOtherPlayer(a);
		local is_other_player_b = Checker.CheckIsOtherPlayer(b);
		if is_other_player_a and not is_other_player_b then
			return -1;
		elseif not is_other_player_a and is_other_player_b then
			return 1;
		else
			return 0;
		end
	end

	-- 比较距离
	t.CompareNearerDistance = function (a, b)


		local player = AvatarCache.me;
		local pos_x = player["pos_x"];
		local pos_y = player["pos_y"];
		local pos_z = player["pos_z"];

		local pos_x_a = a["pos_x"];
		local pos_y_a = a["pos_y"];
		local pos_z_a = a["pos_z"];

		local pos_x_b = b["pos_x"];
		local pos_y_b = b["pos_y"];
		local pos_z_b = b["pos_z"];

		local dx_a = pos_x_a - pos_x;
		local dy_a = pos_y_a - pos_y;
		local dz_a = pos_z_a - pos_z;

		local dx_b = pos_x_b - pos_x;
		local dy_b = pos_y_b - pos_y;
		local dz_b = pos_z_b - pos_z;

		local dist_sq_a = dx_a * dx_a + dz_a * dz_a;
		local dist_sq_b = dx_b * dx_b + dz_b * dz_b;

		if dist_sq_a < dist_sq_b then
			return -1;
		elseif dist_sq_a > dist_sq_b then
			return 1;
		else
			return 0;
		end
	end

	return t;
end

Comparer = CreateComparer();