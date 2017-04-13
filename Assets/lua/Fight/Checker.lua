
AttackJudge = {};
AttackJudge.TargetCanAttack = 0;				-- 目标可以攻击
AttackJudge.NoTargetFound = 1;					-- 没有目标
AttackJudge.TargetIsWhiteName = 2;				-- 目标是白名
AttackJudge.SelfLevelBelow30 = 3;				-- 自身等级未达到30级
AttackJudge.TargetLevelBelow30 = 4;				-- 目标等级未达到30级
AttackJudge.TargetWithinSafeZone = 5;			-- 目标处于安全区
AttackJudge.SelfWithinSafeZone = 6;				-- 自身处于安全区
AttackJudge.TargetIsTeamMate = 7;				-- 目标是队友
AttackJudge.TargetIsArmyMember = 8;				-- 目标是公会成员
AttackJudge.TargetIsDead = 9;					-- 目标已经死亡
AttackJudge.TargetIsInvincible = 10;			-- 目标无敌
AttackJudge.TargetIsInactiveEliteMonster = 11;	-- 目标是未激活精英怪
AttackJudge.TargetCanNotAttack = 12;			-- 不能攻击该目标
AttackJudge.ThisAreaPkForbidden = 13;			-- 此区域禁止PK
AttackJudge.TargetNotWithinAutoFightScope = 14;		-- 角色不在自动战斗范围内
AttackJudge.Unknown = 99;

function CreateChecker()
	local t = {};

	-- 检查是否是玩家
	t.CheckIsPlayer = function (ds)
		local role_type = ds.role_type;
		if role_type == RoleType.Player then
			return true;
		end
		return false;
	end

	-- 目标是否死亡
	t.CheckIsDead = function (ds)
		assert(ds);
		local class = Fight.GetClass(ds);
		assert(class);
		return class.IsDead();
	end

	-- 检查是否在圆圈半径内
	t.CheckIsWithinCircle = function (ds, cx, cy, cz, radius)
		local pos_x = ds["pos_x"];
		local pos_y = ds["pos_y"];
		local pos_z = ds["pos_z"];
		local dx = pos_x - cx;
		local dy = pos_y - cy;
		local dz = pos_z - cz;
		local dist_sq = dx * dx + dz * dz;
		local radius2 = radius * radius;
		return dist_sq <= radius2;
	end

	-- 检查是否在玩家自动战斗原点半径为 radius 的范围内
	t.CheckIsWithinAutoFightScope = function (ds, radius)
		assert(ds);
		local player = AvatarCache.me;
		local cx = player["origin_x"];
		local cy = player["origin_y"];
		local cz = player["origin_z"];
		return t.CheckIsWithinCircle(ds, cx, cy, cz, radius);
	end

	-- 检查是否在玩家半径为 radius 的范围内
	t.CheckIsWithinPlayerScope = function (ds, radius)
		assert(ds);
		local player = AvatarCache.me;
		local cx = player["pos_x"];
		local cy = player["pos_y"];
		local cz = player["pos_z"];
		return t.CheckIsWithinCircle(ds, cx, cy, cz, radius);
	end

	-- 检查是否是野外PK模式
	t.CheckIsWildPkState = function (ds)
		local _t = ds._t;
		return _t.IsWildPkState();
	end

	-- 检查 PK
	t.CheckPK = function (ds)
		local areas = tb.AreaTable[DataCache.scene_sid];
		local default_area = areas["default"];
		if default_area == nil then
			return AttackJudge.TargetCanAttack;
		end
		local pk_mode = default_area.pk_mode;
		if pk_mode == "forbidden" then
			return AttackJudge.ThisAreaPkForbidden;
		end
		if pk_mode == "free" then
			return AttackJudge.TargetCanAttack;
		end
		if pk_mode == "camp" then
			return AttackJudge.TargetCanAttack;
		end
		local my_ds = AvatarCache.me;
		if pk_mode == "normal" then
			if not t.CheckIsWildPkState(my_ds) then
				if t.CheckIsWhiteName(ds) then
					return AttackJudge.TargetIsWhiteName;
				else
					return AttackJudge.TargetCanAttack; 
				end
			else
				return AttackJudge.TargetCanAttack;
			end
		end
		return AttackJudge.TargetCanAttack;
	end

	-- 检查是否红名
	t.CheckIsRedName = function (ds)
		local _t = ds._t;
		return _t.IsRedName();
	end

	-- 检查是否白名
	t.CheckIsWhiteName = function (ds)
		local _t = ds._t;
		return _t.IsWhiteName();
	end

	-- 检查是否无敌
	t.CheckIsImbaState = function (ds)
		local _t = ds._t;
		return _t.IsImbaState();
	end

	-- 检查是否处于安全区
	t.CheckIsWithinSafeArea = function (ds)
		local _t = ds._t;
		return _t.IsWithinSafeArea();
	end

	-- 检查低于保护等级
	t.CheckIsBelowProtectLevel = function (ds)
		local _t = ds._t;
		return _t.IsBelowProtectLevel();
	end

	-- 检查是否是小Boss
	t.CheckIsSmallBoss = function (ds)
		local _t = ds._t;
		return _t.IsRoleTypeOf(RoleType.SmallBoss);
	end

	-- 检查是否是大Boss
	t.CheckIsBigBoss = function (ds)
		local _t = ds._t;
		return _t.IsRoleTypeOf(RoleType.WorldBoss) or
			   _t.IsRoleTypeOf(RoleType.FubenBoss);
	end

	-- 检查是否是Boss
	t.CheckIsBoss = function (ds)
		local _t = ds._t;
		return _t.IsRoleTypeOf(RoleType.SmallBoss) or
			   _t.IsRoleTypeOf(RoleType.WorldBoss) or
			   _t.IsRoleTypeOf(RoleType.FubenBoss);
	end

	-- 检查是否是精英怪
	t.CheckIsEliteMonster = function (ds)
		local _t = ds._t;
		return _t.IsRoleTypeOf(RoleType.EliteMonster) or
			   _t.IsRoleTypeOf(RoleType.FubenEliteMonster);
	end


	-- 检查是否是小怪
	t.CheckIsMonster = function (ds)
		local _t = ds._t;
		return _t.IsRoleTypeOf(RoleType.Monster) or
			   _t.IsRoleTypeOf(RoleType.FubenMonster);
	end

	-- 检查是否Npc
	t.CheckIsNpc = function (ds)
		local _t = ds._t;
		return _t.IsRoleTypeOf(RoleType.Npc);
	end


	-- 检查是否和玩家是同一队
	t.CheckIsSameTeam = function (ds)
		local _t = ds._t;
		local team_uid = AvatarCache.me["team_uid"];
		return _t.IsTeamOf(team_uid);
	end

	-- 检查是否是同公会
	t.CheckIsSameLegion = function (ds)
		local _t = ds._t;
		local legion_uid = AvatarCache.me["legion_uid"];
		return _t.IsLegionOf(legion_uid);
	end


	-- 检查是否是在线其他玩家
	t.CheckIsOnlineOtherPlayer = function (ds)
		local _t = ds._t;
		return _t.IsRoleTypeOf(RoleType.OtherPlayer);
	end

	-- 检查是否是离线玩家
	t.CheckIsOfflineOtherPlayer = function (ds)
		local _t = ds._t;
		return _t.IsRoleTypeOf(RoleType.OfflinePlayer);
	end

	-- 检查是否是其他玩家
	t.CheckIsOtherPlayer = function (ds)
		local _t = ds._t;
		return _t.IsRoleTypeOf(RoleType.OtherPlayer) or
			   _t.IsRoleTypeOf(RoleType.OfflinePlayer) or
			   _t.IsRoleTypeOf(RoleType.GuideNpc);
	end

	-- 检查是否非其他玩家
	t.CheckIsNotOtherPlayer = function (ds)
		return not t.CheckIsOtherPlayer(ds);
	end

	return t;
end


Checker = CreateChecker();

