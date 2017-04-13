function CreateChatPlayerRTT()
	--ChatPlayerRTT
	local chatplayer_rtt = CommonRTT:new()

	--ChatPlayerRTT overload
	chatplayer_rtt.class = "ChatPlayerRTT"
	chatplayer_rtt.camGOPosition = Vector3(0.351, 1.735, -1.552)
	chatplayer_rtt.camGORotation = Quaternion.Euler(0.3, -5, 0)
	chatplayer_rtt.camOrthographic = false
	chatplayer_rtt.camFieldOfView = 60
	chatplayer_rtt.bShadow = true

	--UpdateRtt
	chatplayer_rtt.UpdateRtt = function()
		local modelName, modelMaterialName, weaponmodelName = uAvatarUtil.GetPlayerModelName(DataCache.myInfo, false)
		modelMaterialName = modelMaterialName.."_display"
		chatplayer_rtt:ComUpdateRtt(modelName, modelMaterialName, true, function(avatar)
			--装备武器
			local weaponbindName = uAvatarUtil.GetWeaponBindName(DataCache.myInfo.career)
			uFacadeUtility.PutonWeapon(weaponmodelName, weaponbindName, avatar)
		end)
	end

	--InitRTT
	chatplayer_rtt.InitRtt = function()
		local modelName, modelMaterialName, weaponmodelName = uAvatarUtil.GetPlayerModelName(DataCache.myInfo, false)
		modelMaterialName = modelMaterialName.."_display"
		chatplayer_rtt:ComInitRtt(modelName, modelMaterialName, "", function(avatar)
			local role_info = DataCache.myInfo
			--装备武器
			local weaponbindName = uAvatarUtil.GetWeaponBindName(role_info.career)
			uFacadeUtility.PutonWeapon(weaponmodelName, weaponbindName, avatar)
		end)
	end

	local t =  chatplayer_rtt:new()
	t.InitRtt()
	return t
end

ChatPlayerRTT = 0