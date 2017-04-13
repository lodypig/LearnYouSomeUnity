--
-- 传送门脚本
-- linh
--

TransmitGate = {}


--初始化传送门
TransmitGate.Start = function(go)
	-- bind callback
	local t = go:GetComponent("CircleTrigger");
	t:BindEnterCallBack(TransmitGate.EnterGate)
	t:BindLeaveCallBack(TransmitGate.LeaveGate)
	t:BindStayCallBack(TransmitGate.StayGate)
end

--进入 
TransmitGate.EnterGate = function(go)
	local player = AvatarCache.me;
	local is_auto_fighting = player.is_auto_fighting;
	if is_auto_fighting then
		--自动战斗 && 自动寻路时候不传送 		
		return
	end

	--直接传送
	TransmitGate.SendTramsitMsg(go)
end

TransmitGate.SendTramsitMsg = function(go)
	--清除JoystickLogic.OnJoystick事件
	JoystickLogic.ResetEvent();

	local player = AvatarCache.me;
    Fight.DoJumpState(player, SourceType.System, "Idle", 0);
    uFacadeUtility.SyncStopMove();

	local portal = go:GetComponent("AvatarController");
	local msg = {cmd = "change_scene", npc_id = portal.ID};
	Send(msg, TransmitGate.callback);
end

TransmitGate.callback = function(msg)
	--暂时无用
end

--离开
TransmitGate.LeaveGate = function(go)
end 

--
TransmitGate.StayGate = function(go)
	--功能一样
	TransmitGate.EnterGate(go)
end