function UIHorseView (param)
	local UIHorse = {};
	local this = nil;

	local svHorse = nil;
	local warpContent;

	local last = {
		clickHorseSlot = nil,
		controller = nil,
		selectIdx = nil,
		model = nil,
		horse = nil
	}

	local ndFigure;
	local ctrlList;

	local horseOffsetCfg = 
	{
		[361001] = Vector3(0, 0.97, -5.6),
		[361002] = Vector3(0, 0.97, -5.6),
		[361003] = Vector3(0, 0.97, -5.6),
		[361004] = Vector3(0, 0.97, -5.6),
		[361005] = Vector3(0, 0.97, -5.6),
		[361006] = Vector3(0, 0.97, -5.6),
	}

	local function fixHorseOffset(sid)
		RTTManager.GetCell("HorseRTT").camGo.transform.localPosition = horseOffsetCfg[sid]
	end

	-- 坐骑列表点击逻辑处理
	local function doHorseClick(clickSlot, i)
		local horseTable = client.horse.horseTableCache[i];
		local horse = client.horse.getHorse(horseTable.sid);
		local newController;
		--显示进阶特效
		local bShowEnhanceEffect = false
		--显示最高特效
		local bShowMaxEffect = false
		if horse == nil then
			newController = ctrlList[1];
		else
			--已经解锁 达到满阶 则播放最高特效
			bShowMaxEffect = client.horse.isMaxEnhance(horse)
			local maxStar = client.horse.isMaxStar(horseTable.sid) 
			if maxStar then
				bShowEnhanceEffect = true
			end
			newController = maxStar and ctrlList[3] or ctrlList[2];
		end
		if last.controller ~= newController then
			if last.controller then
				last.controller.Hide();
			end
			last.controller = newController;
		end
		newController.Show(horseTable, horse);
		-- safe_call(newController.updateFlag);

		if newController.updateRolePos then
			newController.updateRolePos(ndFigure, last.selectIdx, i);
		end
		
		--更新坐骑模型
		if horseTable.model ~= last.model or bShowEnhanceEffect ~= last.showEffect or bShowMaxEffect ~= last.showMaxEffect then
			if HorseRTT == 0 then
				HorseRTT = CreateHorseRTT(horseTable.model, bShowEnhanceEffect, bShowMaxEffect, horseTable.carryon_effect);
			else
				--当前装备的坐骑
				HorseRTT.UpdateRtt(horseTable.model, bShowEnhanceEffect, bShowMaxEffect, horseTable.carryon_effect);
			end
			local RoleFigure = this:GO('content.ndRight._ndFigure.RoleFigure');
			RTTManager.SetRoleFigure(RoleFigure, HorseRTT, false, true);
			
			last.model = horseTable.model;
			last.showEffect = bShowEnhanceEffect;
			last.showMaxEffect = bShowMaxEffect;
		end
		fixHorseOffset(horseTable.sid)
	end

	-- 坐骑列表点击界面处理
	local function onHorseClick(clickSlot, i)
		local horseTable = client.horse.horseTableCache[i];
		local horse = client.horse.getHorse(horseTable.sid);
		if last.clickHorseSlot then
			-- last.clickHorseSlot.SetChoose(false);
			last.clickHorseSlot.SelectItem(last.clickHorseSlot.wrapper, false, last.selectIdx, last.horse)
		end
		doHorseClick(clickSlot, i);
		last.selectIdx = i;
		last.clickHorseSlot = clickSlot;
		last.horse = horse;
		-- clickSlot.SetChoose(true, i);
		clickSlot.SelectItem(clickSlot.wrapper, true, i, horse);
	end

	-- 设置列表条目
	local function formatItem(go, i)
		local wrapper = go:GetComponent("UIWrapper");
		local slotCtrl = wrapper:GetUserData("ctrl");
		if slotCtrl == nil then
			slotCtrl = CreateHorseItem(go);
			wrapper:SetUserData("ctrl", slotCtrl);
		end
		wrapper:UnbindAllButtonClick();
		local horseTable = client.horse.horseTableCache[i];
		local horse = client.horse.getHorse(horseTable.sid);
		if horse then
			slotCtrl.SetHorse(horseTable, false, horse.enhance_lv, client.horse.ride_horse == horseTable.sid, client.horse.checkCouldUp(horse));
		else
			slotCtrl.SetHorse(horseTable, true, nil, nil, client.horse.checkUnlockFunc[horseTable.active_type](horseTable));
		end
		wrapper:BindButtonClick(function() 
			onHorseClick(slotCtrl, i);
		end);

		if last.selectIdx == i or last.selectIdx == nil then
			onHorseClick(slotCtrl, i);
		end
	end

	-- 初始化列表
	local function initHorseList()
		warpContent = svHorse:GetComponent("UIWarpContent");
		warpContent:BindInitializeItem(formatItem);
		warpContent:Init(#client.horse.horseTableCache);
	end

	-- 刷新坐骑列表
	local function updateHorseList()
		warpContent:Refresh(#client.horse.horseTableCache);
	end

	UIHorse.closeSelf = function ()
		-- 坐骑模型rtt
		destroy(UIHorse.this.gameObject);	
		--
		if HorseRTT ~= 0 and HorseRTT ~= nil then
			HorseRTT:SetRttVisible(false)
		end
	end

	local function updateTime()
		safe_call(last.controller.UpdateTime);
	end

	local function onItemChange()
		updateHorseList();
		safe_call(last.controller.onItemChange);
	end

	local function onUnlockHorseChange()
		updateHorseList();
		safe_call(last.controller.onUnlockHorseChange);
	end

	function UIHorse.hide()
		-- this.
	end

	function UIHorse.show()

	end

	function UIHorse.Start()
		this = UIHorse.this;

		this:GO("CommonDlg2.Close"):BindButtonClick(UIHorse.closeSelf);	
		svHorse = this:GO('content._svHorse');

		-- 时间和物品变化事件
		-- 坐骑解锁成功
		EventManager.bind(this.gameObject,Event.ON_TIME_SECOND_CHANGE, updateTime);
		EventManager.bind(this.gameObject, Event.ON_EVENT_ITEM_CHANGE, onItemChange);
		EventManager.bind(this.gameObject, Event.ON_HORSE_UNLOCK_OR_CANUPGRADE, onUnlockHorseChange);
		-- 0.632版本坐骑解锁条件临时改为等级，这里注册等级提升事件，刷新页面
		EventManager.bind(this.gameObject, Event.ON_LEVEL_UP, function ()
			onUnlockHorseChange();
		end);

		-- 3个子界面控制器
		local ndActive = this:GO('content.ndRight._ndActive');
		local ndTrain = this:GO('content.ndRight._ndTrain');
		local ndEnhance = this:GO('content.ndRight._ndEnhance');
		ctrlList = {CreateHorseActive(ndActive, updateHorseList), CreateHorseTrain(ndTrain, updateHorseList, this), CreateHorseEnhance(ndEnhance, updateHorseList, this)}
		
		ndFigure = this:GO('content.ndRight._ndFigure'); -- 用来调整坐骑模型显示位置

		-- 初始化列表
		initHorseList();

		--显示rtt

	end
	return UIHorse;
end

function ui.showHorse()
	if DataCache.myInfo.level < client.horse.OPEN_LEVEL then
		ui.showMsg("坐骑"..client.horse.OPEN_LEVEL .."级开放");
		return;
	end
	if client.newSystemOpen.isSystemOpen("horse") then
        client.newSystemOpen.onGuideComplete("horse");
    end
	if client.horse.horseTableCache then
		PanelManager:CreatePanel('UIHorse', UIExtendType.TRANSMASK, {});
		return;
	end
	client.horse.getServerHorse(function () 
		PanelManager:CreatePanel('UIHorse', UIExtendType.TRANSMASK, {});
	end)

end