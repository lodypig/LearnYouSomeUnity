function CreateHorseRTT(horseModel, bShowEnhanceEffect, bShowMaxEffect, Carryon_Effect)
	--HorseRTT
	local horse_rtt = CommonRTT:new()

	--HorseRTT overload
	horse_rtt.class = "HorseRTT"
	horse_rtt.width = 1600
	horse_rtt.height = 942
	horse_rtt.camGOPosition = Vector3(0, 0.97, -5.6)
	horse_rtt.camGORotation = Quaternion.Euler(0, 0, 0)
	horse_rtt.camOrthographicSize = 2.6
	horse_rtt.InitialRTTRotation = Vector3(0, 265, 0)

	--UpdateRtt
	horse_rtt.UpdateRtt = function(horseModel, bShowEnhanceEffect, bShowMaxEffect, Carryon_Effect)
		horse_rtt:ComUpdateRtt(horseModel.."_Prefab", nil, false, function(avatar) 
			uFacadeUtility.UpdateHorseEffect(avatar, bShowMaxEffect, bShowEnhanceEffect, Carryon_Effect)
		end)
	end

	--InitRTT
	horse_rtt.InitRtt = function(horseModel, bShowEnhanceEffect, bShowMaxEffect, Carryon_Effect)
		horse_rtt:ComInitRtt(horseModel.."_Prefab", nil, "", function(avatar) 
			uFacadeUtility.UpdateHorseEffect(avatar, bShowMaxEffect, bShowEnhanceEffect, Carryon_Effect)
		end)
	end

	local t =  horse_rtt:new()
	t.InitRtt(horseModel, bShowEnhanceEffect, bShowMaxEffect, Carryon_Effect)
	return t
end

HorseRTT = 0