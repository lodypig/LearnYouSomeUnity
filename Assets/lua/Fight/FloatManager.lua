function CreateFloatManager()
	local t = {};

	-- 数字转文字
	t.ConvertNumberToText = function (number)
		if number < 0 then
			return string.format("-%d", - number);
		end

		return string.format("+%d", number);
	end;

	-- 数字转格挡文字
	t.ConvertNumberToParryText = function (number)
		return string.format("P %s", t.ConvertNumberToText(number));
	end;

	-- 飘字通用函数
	t.FloatText = function (id, height, font_name, float_text_res_name, text, r, g, b, a)
		uFacadeUtility.FloatText(id, height, font_name, float_text_res_name, text, r, g, b, a);
	end;

	---------------------------------------------------------------
	-- 其他人对玩家的攻击伤害皮飘字
	---------------------------------------------------------------

	-- 玩家被暴击，伤害飘字
	t.FloatCritPlayer_Normal = function (height, number, r, g, b, a)
		local text = t.ConvertNumberToText(number);
		t.FloatText(AvatarCache.me["id"], height, "Font_Injured", "CritMe_Prefab", text, r, g, b, a);
	end;

	-- 玩家被暴击，玩家格挡伤害飘字
	t.FloatCritPlayer_Parry = function (height, number, r, g, b, a)
		local text = t.ConvertNumberToParryText(number);
		t.FloatText(AvatarCache.me["id"], height, "Font_Injured", "CritMe_Prefab", text, r, g, b, a);
	end;

	-- 玩家被普通攻击，伤害飘字
	t.FloatDamagePlayer_Normal = function (height, number, r, g, b, a)
		local text = t.ConvertNumberToText(number);
		local index = math.random(1, 3);
        local res_name = string.format("FloatBlood%d_Prefab", index);
		t.FloatText(AvatarCache.me["id"], height, "Font_Injured", res_name, text, r, g, b, a);
	end;

	-- 玩家被普通攻击, 格挡飘字
	t.FloatDamagePlayer_Parry = function (height, number, r, g, b, a)
		local text = t.ConvertNumberToParryText(number);
		local index = math.random(1, 3);
        local res_name = string.format("FloatBlood%d_Prefab", index);
		t.FloatText(AvatarCache.me["id"], height, "Font_Injured", res_name, text, r, g, b, a);
	end;

	-- 玩家伤害飘字
	t.FloatPlayer = function (height, number, r, g, b, a, critical, parry)
		if critical then
			if parry then
				t.FloatCritPlayer_Parry(height, number, r, g, b, a);
			else
				t.FloatCritPlayer_Normal(height, number, r, g, b, a);
			end
		else
			if parry then
				t.FloatDamagePlayer_Parry(height, number, r, g, b, a);
			else
				t.FloatDamagePlayer_Normal(height, number, r, g, b, a);
			end
		end
	end;

	----------------------------------------------------------------
	-- 玩家对其他人的攻击伤害飘字
	----------------------------------------------------------------

	-- 玩家对敌人造成暴击伤害，伤害飘字
	t.FloatCrit_Normal = function (id, height, number, r, g, b, a)
		local text = t.ConvertNumberToText(number);
		t.FloatText(id, height, "Font_Crit", "CritOther_Prefab", text, r, g, b, a);
	end;

	-- 玩家对敌人造成暴击伤害，格挡伤害飘字
	t.FloatCrit_Parry = function (id, height, number, r, g, b, a)
		local text = t.ConvertNumberToParryText(number);
		t.FloatText(id, height, "Font_Crit", "CritOther_Prefab", text, r, g, b, a);
	end;

	-- 玩家对敌人造成普通攻击，伤害飘字
	t.FloatDamage_Normal = function (id, height, number, r, g, b, a)
		local text = t.ConvertNumberToText(number);
		local index = math.random(1, 3);
        local res_name = string.format("FloatBlood%d_Prefab", index);
        t.FloatText(id, height, "Font_Damage", res_name, text, r, g, b, a);
	end;

	-- 玩家对敌人造成普通攻击，格挡伤害飘字
	t.FloatDamage_Parry = function (id, height, number, r, g, b, a)
		local text = t.ConvertNumberToParryText(number);
		local index = math.random(1, 3);
        local res_name = string.format("FloatBlood%d_Prefab", index);
        t.FloatText(id, height, "Font_Damage", res_name, text, r, g, b, a);
	end;

	t.FloatOther = function (id, height, number, r, g, b, a, critical, parry)
		if critical then
			if parry then
				t.FloatCrit_Parry(id, height, number, r, g, b, a);
			else
				t.FloatCrit_Normal(id, height, number, r, g, b, a);
			end
		else
			if parry then
				t.FloatDamage_Parry(id, height, number, r, g, b, a);
			else
				t.FloatDamage_Normal(id, height, number, r, g, b, a);
			end
		end
	end;

	-------------------------------------------------------------------
	-- 未命中飘字
	-------------------------------------------------------------------

	t.FloatMiss = function (id, height, r, g, b, a)
		t.FloatText(id, height, "Font_Missing", "shanb_Prefab", "M", r, g, b, a);
	end;

	-------------------------------------------------------------------
	-- 闪避飘字
	-------------------------------------------------------------------

	t.FloatEvade = function (id, height, r, g, b, a)
		t.FloatText(id, height, "Font_Missing", "shanb_Prefab", "E", r, g, b, a);
	end;

	------------------------------------------------------------------
	-- 天赋飘字
	------------------------------------------------------------------

	-- 左侧天赋飘字
	t.FloatTalentLeft = function (id, height, talent_id, r, g, b, a)
		local talent_info = tb.TalentTable[talent_id];
		t.FloatText(id, height, "Font_Talent", "talent_text_left", talent_info.float_text, r, g, b, a);
	end;

	-- 右侧天赋飘字
	t.FloatTalentRight = function (id, height, talent_id, r, g, b, a)
		local talent_info = tb.TalentTable[talent_id];
		t.FloatText(id, height, "Font_Talent", "talent_text_right", talent_info.float_text, r, g, b, a);
	end


	t.FloatTalent = function (sourceId, targetId, talentIdTable)
		local ds = AvatarCache.GetAvatar(sourceId);
		local talentId;
		local talent_info;
		if ds == nil then
			return;
		end
		if ds["talentFloatFlag"] == nil then
			ds["talentFloatFlag"] = true;
		end
		for i = 1, #talentIdTable do
			talentId = talentIdTable[i];
			talent_info = tb.TalentTable[talentId];
			if talent_info.sub_type ~= "Negative" then
				if ds["talentFloatFlag"] then
					t.FloatTalentLeft(sourceId, 2.0, talentId, 1, 1, 1, 1);
				else
					t.FloatTalentRight(sourceId, 2.0, talentId, 1, 1, 1, 1);
				end
				ds["talentFloatFlag"] = not ds["talentFloatFlag"];
			end
			t.FloatTalentEffect(sourceId, targetId, talentId);
		end
	end


	t.FloatTalentEffect = function (sourceId, targetId, talentId)
		if talentId == 40033001 then
			Fight.PlayStaticEffect("fashilianlei", 5.0, targetId, "");
		elseif talentId == 40033003 then
			Fight.PlayFollowEffect("huashangtianfu", 1.0, sourceId, "");
		elseif talentId == 40033004 then
			Fight.PlayStaticEffect("jingdianlichang", 4.5, targetId, "");
		end
	end

	-- 通用飘字函数
	t.CommonFloat = function (attacker_id, target_id, hurt_value, critical, parry, att_talent_list, def_talent_list)
		local attacker_ds = AvatarCache.GetAvatar(attacker_id);
		if attacker_ds == nil then
			return;
		end
		local attacker_role_type = attacker_ds["role_type"];
		local target_ds = AvatarCache.GetAvatar(target_id);
		local target_role_type = target_ds["role_type"];
		if target_role_type == RoleType.Player then
			t.FloatPlayer(2.0, hurt_value, 1, 1, 1, 1, critical, parry);
		else
			if attacker_role_type == RoleType.Player then
				t.FloatOther(target_id, 2.0, hurt_value, 1, 1, 1, 1, critical, parry);
			end
		end
		t.FloatTalent(attacker_id, target_id, att_talent_list);
		t.FloatTalent(target_id, attacker_id, def_talent_list);
	end;

	return t;

end


FloatManager = CreateFloatManager();