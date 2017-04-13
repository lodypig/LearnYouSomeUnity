function CreateRoleRTT()
	local role_rtt = CommonRTT:new()

	--RoleRTT overload
	role_rtt.class = "RoleRTT"
	role_rtt.bMirror = true
	role_rtt.bShadow = true

	role_rtt.lastmodelName = ""
	role_rtt.lastmodelMaterialName = ""
	role_rtt.lastweaponName = ""

	role_rtt.InitRtt = function()
		local role_info = DataCache.myInfo
		local modelName, modelMaterialName, weaponmodelName = uAvatarUtil.GetPlayerModelName(role_info, false)
		local weaponbindName = uAvatarUtil.GetWeaponBindName(role_info.career)
		--人物展示shader(目前只有1级女弓有)
		--if modelMaterialName == "archer_female_1" then
			modelMaterialName = modelMaterialName.."_display"
		--end

		role_rtt:ComInitRtt(modelName, modelMaterialName, "", function(avatar)
			role_rtt.lastmodelName = modelName
			role_rtt.lastmodelMaterialName = modelMaterialName
			role_rtt.lastweaponName = weaponmodelName
			--装备武器
			uFacadeUtility.PutonWeapon(weaponmodelName, weaponbindName, avatar)
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

RoleRTT = 0 