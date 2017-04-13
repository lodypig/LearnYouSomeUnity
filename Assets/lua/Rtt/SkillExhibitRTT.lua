function CreateSkillExhibitRTT()


	local role_rtt = CommonRTT:new()

	--RoleRTT overload
	role_rtt.class = "SkillExhibitRTT"
	role_rtt.bMirror = true
	role_rtt.bShadow = true

	role_rtt.lastmodelName = ""
	role_rtt.lastmodelMaterialName = ""
	role_rtt.lastweaponName = ""
	role_rtt.model_id = 0;
	role_rtt.cell_root = nil;
	role_rtt.luaName = "";
	role_rtt.pos_x = 0;
	role_rtt.pos_y = 0;
	role_rtt.pos_z = 0;
	role_rtt.rot_x = 0;
	role_rtt.rot_y = 0;
	role_rtt.rot_z = 0;

	-- 设置模型方向并保存方向信息
	role_rtt.SetModelDirAndSave = function (rot_x, rot_y, rot_z)
		role_rtt.SetModelDir(rot_x, rot_y, rot_z);
		role_rtt.rot_x = rot_x;
		role_rtt.rot_y = rot_y;
		role_rtt.rot_z = rot_z;
	end

	-- 设置模型方向
	role_rtt.SetModelDir = function (rot_x, rot_y, rot_z)
		local id = role_rtt.model_id;
		uFacadeUtility.SetLocalEulerAnglesForModel(id, rot_x, rot_y, rot_z);
	end

	-- 重置方向
	role_rtt.ResetModelDir = function ()
		local pos_x = role_rtt.pos_x;
		local pos_y = role_rtt.pos_y;
		local pos_z = role_rtt.pos_z;
		role_rtt.SetModelDir(pos_x, pos_y, pos_z);
	end

	-- 设置模型位置并保存位置
	role_rtt.SetModelPosAndSave = function (pos_x, pos_y, pos_z)
		role_rtt.SetModelPos(pos_x, pos_y, pos_z);
		role_rtt.pos_x = pos_x;
		role_rtt.pos_y = pos_y;
		role_rtt.pos_z = pos_z;
	end

	-- 设置模型位置
	role_rtt.SetModelPos = function (pos_x, pos_y, pos_z)
		local id = role_rtt.model_id;
		uFacadeUtility.SetAvatarPosForModel(id, pos_x, pos_y, pos_z);
	end

	-- 重置模型位置
	role_rtt.ResetModelPos = function ()
		-- body
		local pos_x = role_rtt.pos_x;
		local pos_y = role_rtt.pos_y;
		local pos_z = role_rtt.pos_z;
		role_rtt.SetModelPos(pos_x, pos_y, pos_z);
	end

	role_rtt.GetCellRoot = function ()
		return role_rtt.cell_root;
	end

	-- 播放技能
	role_rtt.PlaySkill = function (skill_id)
		local model_id = role_rtt.model_id;
		local luaName = role_rtt.luaName;
		local skill_info = Fight.GetSkillInfoByLuaNameAndSkillId(luaName, skill_id);
   		local state_name = skill_info.state;
		local name_hash = const.AnimatorStateNameToId[state_name];
		uFacadeUtility.JumpStateForModel(model_id, name_hash, 0);
	end

	role_rtt.InitRtt = function()
		local role_info = DataCache.myInfo
		local modelName, modelMaterialName, weaponmodelName = uAvatarUtil.GetPlayerModelName(role_info, false)
		local weaponbindName = uAvatarUtil.GetWeaponBindName(role_info.career)
		--人物展示shader(目前只有1级女弓有)
		--if modelMaterialName == "archer_female_1" then
			modelMaterialName = modelMaterialName.."_display"
		--end
		local career = role_info.career;
		local luaName = Fight.GetLuaLogicByCareer(career);
		role_rtt.camOrthographicSize = 5;
		role_rtt.width = 6 * 180; -- 1080
		role_rtt.height = 7 * 180; -- 1260
		role_rtt:ComInitRtt(modelName, modelMaterialName, luaName, function(avatar)
			role_rtt.luaName = luaName;
			role_rtt.lastmodelName = modelName
			role_rtt.lastmodelMaterialName = modelMaterialName
			role_rtt.lastweaponName = weaponmodelName
			--装备武器
			uFacadeUtility.PutonWeapon(weaponmodelName, weaponbindName, avatar)
			-- 保存模型 id
			role_rtt.model_id = uFacadeUtility.GetModelId(avatar);
			role_rtt.cell_root = avatar.transform.parent.gameObject;
		end)
	end

	role_rtt.UpdateRtt = function()
		local role_info = DataCache.myInfo
		local modelName, modelMaterialName, weaponmodelName = uAvatarUtil.GetPlayerModelName(role_info, false)
		if role_rtt.lastmodelName == modelName and role_rtt.lastmodelMaterialName == modelMaterialName and role_rtt.lastweaponName == weaponmodelName then
			role_rtt:SetRttVisible(true)
			return
		end
		--人物展示shader(目前只有1级女弓有)
		--if modelMaterialName == "archer_female_1" then
			modelMaterialName = modelMaterialName.."_display"
		--end
		local weaponbindName = uAvatarUtil.GetWeaponBindName(role_info.career)

		role_rtt:ComUpdateRtt(modelName, modelMaterialName, true, function(avatar)
			--装备武器
			-- print("puton weapon")
			role_rtt.lastmodelName = modelName
			role_rtt.lastmodelMaterialName = modelMaterialName
			role_rtt.lastweaponName = weaponmodelName
			uFacadeUtility.PutonWeapon(weaponmodelName, weaponbindName, avatar)
		end)
	end

	local t = role_rtt:new()
	t.InitRtt()

	return t
end

SkillExhibitRTT = 0

function GetSkillExhibitRTT()
	return SkillExhibitRTT;
end