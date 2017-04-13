TransmitPoint = {}

-- 暂时定为 1.5 秒, 只要在传送点范围内停留超过这个时间马上传送
TransmitPoint.time_to_transmit = 1.5;
TransmitPoint.start_time = 0;
TransmitPoint.lock = false;

-- 进入传送点
TransmitPoint.Enter = function (ds)
	-- print("Enter TransmitPoint: " .. ds.transmit_sid);
	TransmitPoint.start_time = TimerManager.GetUnityTime();

	-- -- 播放过图特效
	-- local player = AvatarCache.me;
	-- uFacadeUtility.StopAllEffects(player.id, "dutiao");
	-- Fight.PlayFollowEffect("dutiao", 5.0, player.id, "");
end

TransmitPoint.Transmit = function (transmitSid, dst_fenxian)
	if TransmitPoint.lock then
		return;
	end
	-- 是否存在跳转信息
	local transmit_info = tb.MapNpcTransmitTable[transmitSid];
	if transmit_info == nil then
		return;
	end
	-- 判断当前场景是否是目标场景
	local dst_scene_sid = transmit_info.dst_scene_sid;
	if dst_scene_sid == DataCache.scene_sid then
		return;
	end
	-- 判断玩家是否可以进入目标地图
	local player = AvatarCache.me;
	local scene_info = tb.SceneTable[dst_scene_sid];
	if scene_info.level > player.level then
		ui.showMsg("暂时无法进入目标地图");
		return;
	end
	-- 玩家死亡不传送
	if Checker.CheckIsDead(player) then
		return
	end
	-- 角色跳到待机状态
	local curr_state_name = player.curr_state_name;
	if curr_state_name ~= "Idle" then
		Fight.DoJumpStateDontSendStopMoveMsg(player, SourceType.System, "Idle", 0);
	end
	-- 跳转到目标地图
	local dst_fenxian = DataCache.fenxian;
	local msg = {cmd = "transmit_pos", transmit_sid = transmitSid, fenxianID = dst_fenxian};
	Send(msg, function (msgTable)
	end);
end

-- 离开传送点
TransmitPoint.Leave = function (ds)
	-- print("Leave TransmitPoint: " .. ds.transmit_sid);
	TransmitPoint.lock = false;
	-- local player = AvatarCache.me;
	-- uFacadeUtility.StopAllEffects(player.id, "dutiao");
end

-- 待在传送点
TransmitPoint.Stay = function (ds)
	local curr_time = TimerManager.GetUnityTime();
	local elapsed_time = curr_time - TransmitPoint.start_time;
	if elapsed_time >= TransmitPoint.time_to_transmit then
		local transmitSid = ds.transmit_sid;
		TransmitPoint.Transmit(transmitSid, DataCache.fenxian);
		TransmitPoint.lock = true;
	end
end