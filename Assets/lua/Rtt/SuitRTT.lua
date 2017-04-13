function CreateSuitRTT()
	--SuitRTT
	local suit_rtt = CommonRTT:new()

	--SuitRTT overload
	suit_rtt.class = "SuitRTT"

	--UpdateRtt
	suit_rtt.UpdateRtt = function(modelName, modelMaterialName)
		local role_info = DataCache.myInfo
		local weaponmodelName = uAvatarUtil.GetPlayerWeaponModelName(role_info.equipment)
		suit_rtt:ComUpdateRtt(modelName, modelMaterialName, false, function(avatar)
			--装备武器
			local weaponbindName = uAvatarUtil.GetWeaponBindName(role_info.career)
			uFacadeUtility.PutonWeapon(weaponmodelName, weaponbindName, avatar)
		end)
	end

	--InitRTT
	suit_rtt.InitRtt = function()
		local modelName, modelMaterialName, weaponmodelName = uAvatarUtil.GetPlayerModelName(DataCache.myInfo, false)
		suit_rtt:ComInitRtt(modelName, modelMaterialName, "", function(avatar)
			local role_info = DataCache.myInfo
			--装备武器
			local weaponbindName = uAvatarUtil.GetWeaponBindName(role_info.career)
			uFacadeUtility.PutonWeapon(weaponmodelName, weaponbindName, avatar)
		end)
	end

	local t =  suit_rtt:new()
	t.InitRtt()
	return t
end

SuitRTT = 0