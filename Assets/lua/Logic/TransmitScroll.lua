--
-- 传送卷轴
-- linh
--

TransmitScroll = {}

local Btn = nil
local bk = nil


--初始化传送卷轴
TransmitScroll.Start = function(go, FlyShoes)
	--bind callback 
	--Btn = go:GO('Panel.chuansongBtn')
	--bk = go:GO('Panel.bk')
	--Btn:BindButtonClick(TransmitScroll.UseIt)
	TransmitScroll.SetFlyShoes(FlyShoes)
end

TransmitScroll.SetFlyShoes = function(FlyShoes)
	
	--[[
	if FlyShoes == true then
		--显示飞鞋
		bk:GetComponent("RectTransform").anchoredPosition = Vector2.New(-18.1, -0.7)
		Btn:Show()
	else
		--隐藏飞鞋
		bk:GetComponent("RectTransform").anchoredPosition = Vector2.New(0, -0.7)
		Btn:Hide()
	end
	]]

	EventManager.onEvent(Event.ON_START_AUTO_PATHFINDING, FlyShoes);
end

TransmitScroll.UseIt = function(go)
	--print("Use Transmit Scroll!!!")
	local scene_sid, fenxian, dst_x, dst_y, dst_z = AutoPathfindingManager.GetTransmitPos();
	local scenepos = { x = dst_x, y = dst_z };
	if fenxian == nil then
		fenxian = DataCache.fenxian;
	end

	--print("use it ----------------------");
	-- print("scene_sid: " .. scene_sid);
	-- print("fenxian: " .. fenxian);
	-- print(string.format("pos={%f, %f, %f}", dst_x, dst_y, dst_z));

	--同图内，目标点与距离要超过1.5屏
	if scene_sid == DataCache.scene_sid then
		local player = AvatarCache.me;
		local screenWidth = 7
		local distance = math.sqrt(math.pow(math.abs(player.pos_x - scenepos.x), 2) + math.pow(math.abs(player.pos_z - scenepos.y), 2))
		if distance <= screenWidth then
			ui.showMsg("距离较近，无需传送");
			return
		end
	end

	TransmitScroll.Process(scene_sid, fenxian, scenepos);
	TransmitScroll.OnHide();
	
	--飞鞋传送之后 清楚过图上马标记
	-- print("Set Flag_SceneLoadRide false On Flyshoes")
	client.horse.Flag_SceneLoadRide = false
end

TransmitScroll.Process = function(sceneid, fenxianID, scenepos)
	--地图是否开放
	--是否处于禁飞状态
	--查找包裹中的传送卷轴

	--print("1");
	local item = Bag.FindItemBytid(const.item.chuansong)
	if item == nil then
		if not const.IsNotShow then
			PanelManager:CreatePanel('UICostTransmit',  UIExtendType.BLACKMASK, nil);
		else
			if DataCache.role_diamond < 10 then
				ui.showMsgBox(nil, "您的钻石不足，是否前往充值？", function() ui.showMsg("暂未开放"); end, nil);
			else
				TransmitScroll.SendMsg(item, sceneid, fenxianID, scenepos);
				TransmitScroll.OnHide();
			end
		end
		return;
	else
		TransmitScroll.SendMsg(item, sceneid, fenxianID, scenepos);
		TransmitScroll.OnHide();
	end
end


TransmitScroll.SendMsg = function(item, sceneid, fenxianID, scenepos)

	-- print(sceneid.."  "..scenepos.x.."  "..scenepos.y)
	local index;
	if item == nil then
		index = 0;
	else
		index = item.pos;
	end

	local curr_scene_sid = DataCache.scene_sid;
	--print("pos"..item.pos);
	-- print(string.format("transmit target pos: scene_sid=%d, fenxian=%d, pos={%f, %f, %f}", sceneid, fenxianID, scenepos.x, 0, scenepos.y));
	-- 取消读条
	-- 停止自动战斗
	local player = AvatarCache.me;
    Fight.DoJumpStateDontSendStopMoveMsg(player, SourceType.System, "Idle", 0);
	local class = Fight.GetClass(player);
	class.HandUp(player, false);
	client.commonProcess.CancelProcess();
	AutoPathfindingManager.SetTeleporting(true);

	--print("send cost_transmit");
	local msg = {cmd = "cost_transmit", bag_index = index, sid = const.item.chuansong, scene_id = sceneid, fenxianID = fenxianID, pos = { scenepos.x, 0, scenepos.y}};
	Send(msg, function (reply)
		if reply == nil then
			error("为什么会是 nil");
			return;
		end
		if reply["type"] == "success" then
	    	ui.showMsg("传送成功");
	    end
	end);

end

--点击链接寻路的一系列逻辑
TransmitScroll.ClickLinkPathing = function(dst_sceneSid, dst_fenxian, toPos, arriveCB)
	-- print("TransmitScroll.ClickLinkPathing!!")
	--当前场景id
	local cur_sceneSid = DataCache.scene_sid
	dst_fenxian = tonumber(dst_fenxian);
	if cur_sceneSid == tb.SceneAlias2Id["linfengpingyuan"] and dst_sceneSid ~= tb.SceneAlias2Id["linfengpingyuan"] then 
		-- 判断当前新手村任务是否已完成，没完成的话不能传送成功
		ui.showMsg("外面的世界很危险");
		return
	end

	if cur_sceneSid ~= tb.SceneAlias2Id["linfengpingyuan"] and dst_sceneSid == tb.SceneAlias2Id["linfengpingyuan"] then
	-- 除了新手村其他地图的玩家无法靠传送链接回到新手村
		ui.showMsg("您无法返回新手村");
		return
	end

	--传送判断
	if not client.tools.transmitCheck(DataCache.scene_sid, dst_sceneSid) then
		-- print("return herer")
		return
	end

	--同图不同的分线
	if cur_sceneSid == dst_sceneSid and dst_fenxian ~= nil and dst_fenxian ~= DataCache.fenxian then
		-- print("[同图不同分线] fenxian_transmit");
        local msg = {cmd = "fenxian_transmit", fenxian_id = dst_fenxian}
        Send(msg, function(msgTable) 
        	TransmitScroll.ClickLinkPathing(dst_sceneSid, dst_fenxian, toPos, arriveCB)
        end)
        return
	end 

	--先取消正在的自动寻路
	AutoPathfindingManager.CancelWithoutJumpIdle();

	--现在已经没有这个逻辑了
	--1) 已经在本图(非目标图)传送水晶范围 直接传送 不要跑步与读条 
	-- if cur_sceneSid ~= dst_sceneSid and PortalCrystal.IsNearby() then
	-- 	local dst_x = toPos.x;
	-- 	local dst_z = toPos.y;
	-- 	AutoPathfindingManager.StartPathfinding(dst_sceneSid, dst_fenxian, toPos.x, 0, toPos.y, false, function ()
	-- 		--设置传图之后上马
	-- 		if DataCache.myInfo.fight_state_time > 0 then
	-- 			--战斗 --> 脱战3s上马
	-- 			client.horse.Flag_FightLeaveRide = true
	-- 		else
	-- 			--非战 --> 过图上马
	-- 			--print("Set Flag_SceneLoadRide true!!! 11111")
	-- 			client.horse.Flag_SceneLoadRide = true
	-- 		end
	-- 	end);
	-- 	return
	-- end
	-- print("3333333333333333333333")
	--2) 跑步前往(飞鞋 点击立即传送到目的地)
	local dst_x = toPos.x;
	local dst_z = toPos.y;
	AutoPathfindingManager.StartPathfinding(dst_sceneSid, dst_fenxian, toPos.x, 0, toPos.y, true, arriveCB);
	--3) 跨图 读条传送往新图
	-- print("4444444444444444444")
	if DataCache.scene_sid ~= dst_sceneSid then
		-- print("555555555555555")
		local pro = tb.SceneTable[dst_sceneSid]
		--local str = string.format("正在前往%s(%d级)", pro.name, pro.level)
		local str = "传送中"
		--设置传图之后上马(中断传送时 也需要清除该标记)
		if DataCache.myInfo.fight_state_time > 0 then
			--战斗 --> 脱战3s上马
			client.horse.Flag_FightLeaveRide = true
		else
			--非战 --> 过图上马
			--print("Set Flag_SceneLoadRide true!!! 22222")
			client.horse.Flag_SceneLoadRide = true
		end

		local player = AvatarCache.me;
		local pos_x = player.pos_x;
		local pos_y = player.pos_y;
		local pos_z = player.pos_z;
		-- print(string.format("[pathfinding] 读条: scene_sid=%d, pos={%f, %f, %f}", DataCache.scene_sid, pos_x, pos_y, pos_z));
		-- 自动寻路读条
		client.commonProcess.StartProcess(ProcessType.TransmitProcess, 3, str, function() 
			--print(string.format("[pathfinding] 读条结束, 过图: dst_scene_sid=%d, dst_fenxian=%d", dst_sceneSid, dst_fenxian));
			AutoPathfindingManager.Abort();
			--并设置一个传图后的寻路动作
			PortalCrystal.SendTramsitMsg(dst_sceneSid, dst_fenxian);
		end)
	else
		--3.1) 同图链接
		if DataCache.myInfo.fight_state_time > 0 then
			--战斗 ---> 设置脱战3s后上马 
			client.horse.Flag_FightLeaveRide = true
		else
			--非战 ---> 3s后上马
			client.horse.Delay3sRide()
			--if AutoPathfindingManager.IsAutoPathfinding() then
			--	client.horse.RideHorse(true)
			--end
		end
	end
end

TransmitScroll.OnHide = function()
	--打断正在进行的传送读条
	local pro = client.commonProcess
	if pro.isProcess() and pro.GetProcessType() == ProcessType.TransmitProcess then
		pro.CancelProcess()
	end

	EventManager.onEvent(Event.ON_END_AUTO_PATHFINDING);
end