function UICostTransmitView (param)	
	local UICostTransmit = {};
	local this = nil;

	local selected = {};
	local position = {};
	local sptoggle = nil;
	local spGou = nil;
	function UICostTransmit.Start()
		this = UICostTransmit.this;

    	this:GO('panel.btnCancel'):BindButtonClick(UICostTransmit.onCancelClick);
    	this:GO('panel.top.closeBtn'):BindButtonClick(UICostTransmit.onCancelClick);
    	this:GO('panel.btnOk'):BindButtonClick(UICostTransmit.onOkClick);

    	sptoggle = this:GO('panel.toggle'):GetComponent('UIWrapper');
    	spGou = this:GO('panel.toggle.spKuang.spGou');

    	sptoggle:BindButtonClick(UICostTransmit.onToggleClick);
	end

	function UICostTransmit.onToggleClick()
		if spGou:IsShow() then
			spGou.gameObject:SetActive(false);
		else
			spGou.gameObject:SetActive(true);
		end
	end

	function UICostTransmit.CostDiamondCallBack()

	end

	function UICostTransmit.onCancelClick()
		destroy(this.gameObject);
	end

	function UICostTransmit.onOkClick()
		const.IsNotShow = spGou:IsShow();
		--
		local sceneid, sceneFenxian, dst_x, dst_y, dst_z = AutoPathfindingManager.GetTransmitPos();
		local scenepos = { x = dst_x, y = dst_z };
		if sceneFenxian == nil then
			sceneFenxian = DataCache.fenxian;
		end

		-- print("----------------------")
		-- print("sceneid "..sceneid)
		-- print("scenepos "..scenepos.x.." "..scenepos.y)
		--同图内，目标点与距离要超过1.5屏
		if sceneid == DataCache.scene_sid then
			local player = AvatarCache.me;
			local pos_x = player.pos_x;
			local pos_y = player.pos_y;
			local pos_z = player.pos_z;
			local screenWidth = 7
			local distance = math.sqrt(math.pow(math.abs(pos_x - scenepos.x), 2) + math.pow(math.abs(pos_z - scenepos.y), 2))
			if distance == 0 or distance <= screenWidth then
				ui.showMsg("距离较近，无需传送")
				destroy(this.gameObject);
				return
			end
		end
		if sceneid == 0 then
			ui.showMsg("已到达目的地，无需传送")
			destroy(this.gameObject);
			return 
		end
		-- --到达后传送 直接传入终点场景与坐标
		-- -- print("到达事件 ")
		-- -- print(arriveEvent)
		-- if arriveEvent == ArriveTriggerEvent.ATE_AutoTransmit then
		-- 	sceneid = WayFinding.autoTransmit_sceneid
		-- 	scenepos = WayFinding.autoTransmit_pos
		-- 	-- print("到达后传送")
		-- 	-- print("sceneid "..sceneid)
		-- 	-- print("scenepos "..scenepos.x.." "..scenepos.y)
		-- end

		if DataCache.role_diamond < 10 then
			ui.showMsgBox(nil, "您的钻石不足，是否前往充值？", function() ui.showMsg("暂未开放"); end, nil);
		else

			local player = AvatarCache.me;
    		Fight.DoJumpStateDontSendStopMoveMsg(player, SourceType.System, "Idle", 0);
			local item = Bag.FindItemBytid(const.item.chuansong);
			TransmitScroll.OnHide();
			TransmitScroll.SendMsg(item, sceneid, sceneFenxian, scenepos);
		end
		destroy(this.gameObject);
	end

	return UICostTransmit;
end