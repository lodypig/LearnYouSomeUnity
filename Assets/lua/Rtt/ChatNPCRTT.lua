function CreateChatNPCRTT(npcmodel)
	--ChatNPCRTT
	local chatnpc_rtt = CommonRTT:new()

	--ChatNPCRTT overload
	chatnpc_rtt.class = "ChatNPCRTT"
	chatnpc_rtt.camGOPosition = Vector3(0.351, 1.735, -1.552)
	chatnpc_rtt.camGORotation = Quaternion.Euler(0.3, -5, 0)
	chatnpc_rtt.camOrthographic = false
	chatnpc_rtt.camFieldOfView = 60
	chatnpc_rtt.bShadow = true

	--UpdateRtt
	chatnpc_rtt.UpdateRtt = function(modelName)
		chatnpc_rtt:ComUpdateRtt(modelName, nil, false, function(avatar) 
			--change shader material
			uFacadeUtility.ChangeMaterial(avatar, "MW/Display", true)
		end)
	end

	--InitRTT
	chatnpc_rtt.InitRtt = function(modelName)
		chatnpc_rtt:ComInitRtt(modelName, nil, "", function(avatar) 
			--change shader material
			uFacadeUtility.ChangeMaterial(avatar, "MW/Display", true)
		end)
	end

	local t =  chatnpc_rtt:new()
	t.InitRtt(npcmodel)
	return t
end

ChatNPCRTT = 0