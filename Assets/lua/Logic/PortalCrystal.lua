--
-- 传送水晶脚本
-- linh
--

PortalCrystal = {}

PortalCrystal.bActiveCheck = false
PortalCrystal.bTime2StarAction = 0
PortalCrystal.OneTimeNotCheck = false
PortalCrystal.LockTransmit = false


PortalCrystal.OnDestroy = function(ds)
	-- 销毁
	PortalCrystal.Leave();
end

--进入 
PortalCrystal.Enter = function(ds)
	--进入传送水晶范围 激活检查功能
	if PortalCrystal.OneTimeNotCheck then
		PortalCrystal.OneTimeNotCheck = false
		return
	end
	PortalCrystal.bActiveCheck = true
	-- --直接传送
	-- PortalCrystal.SendTramsitMsg(go)
end

--离开
PortalCrystal.Leave = function(ds)
	--取消检查功能
	PortalCrystal.bActiveCheck = false
	PortalCrystal.bTime2StarAction = 0
	client.rightUpConfirm.Hide()
	--hide messagebox
end 

PortalCrystal.Stay = function()
end

PortalCrystal.CheckMove = function()
	local player = AvatarCache.me;
	local is_auto_fighting = player.is_auto_fighting;
	if is_auto_fighting then
		--自动战斗 && 自动寻路时候不传送 		
	 	return true
	end
	-- if controller:IsMoving() or controller:IsRouting() then
	-- 	return true
	-- end
	return false
end

PortalCrystal.SendTramsitMsg = function(scenesid, fenxian, callback)
	--清除JoystickLogic.OnJoystick事件
    if nil == fenxian then
        fenxian = 0;
    end

    local player = AvatarCache.me;
    Fight.DoJumpStateDontSendStopMoveMsg(player, SourceType.System, "Idle", 0);
    
    if PortalCrystal.LockTransmit == true 
    	or (SceneManager ~= nil and SceneManager.LoadingScene == true) then
    	return
    end
    -- print(debug.traceback())
	local msg = {cmd = "transmit", scene_sid = scenesid, fenxianID = fenxian};
	Send(msg, function (msgTable)
		PortalCrystal.Callback();
		if callback ~= nil then
			callback();
		end
		PortalCrystal.LockTransmit = false
	end);
	PortalCrystal.LockTransmit = true
end

PortalCrystal.Callback = function(msg)
	PortalCrystal.bTime2StarAction = 0
end

--设置一次不检查
PortalCrystal.SetOneTimeNotCheck = function()
	if PortalCrystal.IsNearby() then
		PortalCrystal.OneTimeNotCheck = true
	end
end

--判断是否在传送水晶周围
PortalCrystal.IsNearby = function()
	local SceneSid = DataCache.scene_sid;
	local bornpos = tb.SceneTable[SceneSid].bornpos
	if AvatarCache.me == nil then
		return false
	end
	local player = AvatarCache.me;
	-- print("IsNearBy")
	-- print(bornpos[1])
	-- print(bornpos[2])
	local distance = Vector2.Distance({x=bornpos[1], y=bornpos[2]}, {x = player.pos_x, y = player.pos_z})
	if distance <= 4 then
		return true
	end
	return false
end