function CreateOtherRoleRTT()
	local otherrole_rtt = CommonRTT:new()

	--OtherRoleRTT overload
	otherrole_rtt.class = "OtherRoleRTT"
	otherrole_rtt.bMirror = true

	otherrole_rtt.lastmodelName = ""
	otherrole_rtt.lastmodelMaterialName = ""
	otherrole_rtt.lastweaponName = ""

	otherrole_rtt.InitRtt = function()
		local role_info = DataCache.otherInfo
		local modelName, modelMaterialName, weaponmodelName = uAvatarUtil.GetPlayerModelName(role_info, false)
		local weaponbindName = uAvatarUtil.GetWeaponBindName(role_info.career)

		otherrole_rtt:ComInitRtt(modelName, modelMaterialName, "", function(avatar)
			otherrole_rtt.lastmodelName = modelName
			otherrole_rtt.lastmodelMaterialName = modelMaterialName
			otherrole_rtt.lastweaponName = weaponmodelName
			--装备武器
			uFacadeUtility.PutonWeapon(weaponmodelName, weaponbindName, avatar)
		end)
	end

	otherrole_rtt.UpdateRtt = function(role_info)
		local modelName, modelMaterialName, weaponmodelName = uAvatarUtil.GetPlayerModelName(role_info, false)
		if otherrole_rtt.lastmodelName == modelName and otherrole_rtt.lastmodelMaterialName == modelMaterialName and otherrole_rtt.lastweaponName == weaponmodelName then
			otherrole_rtt:SetRttVisible(true)
			return
		end
		local weaponbindName = uAvatarUtil.GetWeaponBindName(role_info.career)

		otherrole_rtt:ComUpdateRtt(modelName, modelMaterialName, true, function(avatar)
			--装备武器
			otherrole_rtt.lastmodelName = modelName
			otherrole_rtt.lastmodelMaterialName = modelMaterialName
			otherrole_rtt.lastweaponName = weaponmodelName
			uFacadeUtility.PutonWeapon(weaponmodelName, weaponbindName, avatar)
		end)
	end

	local t = otherrole_rtt:new()
	t.InitRtt()
	return t
end

OtherRoleRTT = 0 