--
-- 玩家掉落遗物宝箱控制
--

TreasureCtrl = {}

TreasureCtrl.Start = function(ds)
	-- bind callback
	ds.scope_detect_radius = 5.0;
	if DataCache.myInfo.id == ds.killer or DataCache.myInfo.id == ds.owner then
		uFacadeUtility.SetAlpha(ds.id,1.0);
	else
		uFacadeUtility.SetAlpha(ds.id,0.5);
	end
end

--进入的
TreasureCtrl.TreasureList = {};
TreasureCtrl.NearestTreasureId = 0;
--进入 
TreasureCtrl.Enter = function(ds)
	--判断宝箱的归属者，玩家不是归属者不处理
	-- print("DataCache.myInfo.id:"..DataCache.myInfo.id)
	-- print("ds.killer:")
	-- print(ds.killer)
	-- print("ds.owner:")
	-- print(ds.owner)
	-- print("ds.box_time:")
	-- print(ds.box_time);
	-- if ds.killer == nil then
	-- 	return;
	-- end
	if DataCache.myInfo.id == ds.killer or DataCache.myInfo.id == ds.owner then
		-- print("TreasureCtrl.Enter:"..ds.id)
		--记录最近进入的宝箱id
		if #TreasureCtrl.TreasureList == 0 then
			MainUI.ShowTreasureBtn();
		end
		TreasureCtrl.TreasureList[ds.id] = ds.id;
		table.insert(TreasureCtrl.TreasureList,ds.id);
		-- print(#TreasureCtrl.TreasureList)
	end
end

--离开
TreasureCtrl.Leave = function(ds)
	if DataCache.myInfo.id == ds.killer or DataCache.myInfo.id == ds.owner then
		-- print("TreasureCtrl.Leave:"..ds.id)
		--记录最近进入的宝箱id
		local index = -1;
		for i=1,#TreasureCtrl.TreasureList do
			if TreasureCtrl.TreasureList[i] == ds.id then
				index = i;
				break;
			end
		end
		if index ~= -1 then
			table.remove(TreasureCtrl.TreasureList,index);
			if #TreasureCtrl.TreasureList == 0 then
				MainUI.HideTreasureBtn();
			end		
			-- print(#TreasureCtrl.TreasureList)
		end
	end
end 

TreasureCtrl.Stay = function()
	--判断宝箱的归属者，不是归属者不处理
end 

TreasureCtrl.Clean = function()
	TreasureCtrl.TreasureList = {};
	MainUI.HideTreasureBtn();
end

TreasureCtrl.OnClick = function(ds)
	-- print("TreasureCtrl.OnClick!")
	-- print("ds.killer:")
	-- print(ds.killer)
	-- print("ds.owner:")
	-- print(ds.owner)
	--判断宝箱的归属者，不是归属者不处理
	if DataCache.myInfo.id == ds.killer or DataCache.myInfo.id == ds.owner then
		TreasureCtrl.DoOpenBox(ds.id);
	end
end 

TreasureCtrl.OnDestroy = function()
	TreasureCtrl.Leave();
end 

TreasureCtrl.ButtonClick = function()
	local boxId = TreasureCtrl.GetNearestBoxId();
	if boxId ~= 0 then
		TreasureCtrl.DoOpenBox(boxId);
	end
end

TreasureCtrl.GetNearestBoxId = function()
	local tempId = 0;
	local minDistance = 100;
	if #TreasureCtrl.TreasureList ~= 0 then
		-- local myPosition = AvatarCache.me.transform.position
		local myPos = {x = AvatarCache.me.pos_x, y = AvatarCache.me.pos_z};
		for i=1,#TreasureCtrl.TreasureList do
			local ds = AvatarCache.GetAvatar(TreasureCtrl.TreasureList[i]);
			local boxPos = { x = ds.pos_x, y = ds.pos_z};
			-- print(Vector2)
			local distance = Vector2.Distance(myPos,boxPos);
			if distance < minDistance then
				tempId = TreasureCtrl.TreasureList[i];
				minDistance = distance;
			end
		end
	end
	return tempId;
end 



TreasureCtrl.DoOpenBox = function(id)
	local ds = AvatarCache.GetAvatar(id);
	if ds ~= nil then
		if DataCache.myInfo.id == ds.killer or DataCache.myInfo.id == ds.owner then
			local dst_scene_sid = DataCache.scene_sid;
			local scenePos = { x = ds.pos_x + 1, y = ds.pos_z + 1};
			local callback = function()		
				PanelManager:CreateConstPanel('UIGetYiWu', UIExtendType.BLACKMASK, {killer = ds.killer, boxId = id ,name = ds.name, time = 300});
				-- ui.showMsgBox(ds.name, "是否拾取"..ds.name.."？", function()
				-- 	local str = "拾取遗物中";
				-- 	MainUI.HideTreasureBtn();
				-- 	client.commonProcess.StartProcess(ProcessType.CBTProcess, 3, str, function() 
				-- 		if #TreasureCtrl.TreasureList > 0 then
				-- 			MainUI.ShowTreasureBtn();
				-- 		end
				-- 		local msg = {cmd = "open_yiwu",boxId = id};
    --     				Send(msg);
				-- 		Fight.DoJumpState(ds, SourceType.System, "Die", 0);
				-- 	end)					
				-- end, nil);
			end
			TransmitScroll.ClickLinkPathing(dst_scene_sid, DataCache.fenxian, scenePos, callback);
		end
	end	
end

TreasureCtrl.GetFreeCell = function()
	return 15 - #DataCache.treasureList;
end

TreasureCtrl.HandleUpdateTreasure = function(msg)
	local newList = msg["new_list"];
	if newList ~= nil then
		local oldNumber = #DataCache.treasureList;
		DataCache.treasureList = newList;
		local newNumber = #DataCache.treasureList;
		local changeNumber = newNumber - oldNumber;
		if changeNumber > 0 then
			ui.showMsg("你获得了"..changeNumber.."个巫师宝藏")
		elseif changeNumber == 0 then
			-- ui.showMsg("黄金圣匣的空间不足以容纳，请先整理")
		else
			changeNumber = -changeNumber;				
			ui.showMsg("你失去了"..changeNumber.."个巫师宝藏")
		end
		if UIManager.GetInstance():FindUI("UIGoldBox") ~= nil then
			UIManager.GetInstance():CallLuaMethod('UIGoldBox.Refresh')
		end
	end
end
-- TreasureCtrl.StartOpenAction = function(ds)
-- 	Fight.DoJumpState(ds, SourceType.System, "Die", 0);

SetPort("update_treasure",TreasureCtrl.HandleUpdateTreasure);
-- end
