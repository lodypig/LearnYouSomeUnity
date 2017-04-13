clear_tire_value_cost = 10;
no_tire_color = "31EE3A";
low_tire_color = "BF7900";
high_tire_color = "BB2424";

function NewUIRoleView(param)
	local UIRole = {};
	local this = nil;
	local gameObject = nil;
	local player = nil;
	local wearSlotList = {};
	local ndActive = nil;
	local ndTrain = nil;
	local ndEnhance = nil;

	function UIRole.Start( )
		this = UIRole.this;

		player = DataCache.myInfo;
		--打开包裹先帮忙整理	
		Bag.clearUpBag(false);
		local commonDlgGO = this:GO('CommonDlg');	
		UIRole.controller = createCDC(commonDlgGO)
		if param.panelType == "Bag" then
			UIRole.controller.SetButtonNumber(1);
			UIRole.controller.SetButtonText(1,"背包");
			UIRole.controller.bindButtonClick(1, UIRole.showBagPanel);
		end
		if param.panelType == "Role" then
			UIRole.controller.SetButtonNumber(3);
			UIRole.controller.SetButtonText(1,"角色");
			UIRole.controller.bindButtonClick(1, UIRole.showAttrPanel);		
			UIRole.controller.SetButtonText(2,"坐骑");
			--UIRole.controller.bindButtonClick(2, UIRole.showHorsePanel); --NSY-4742 临时
			UIRole.controller.bindButtonClick(2, nil, UIRole.showHorsePanel); --NSY-4742 临时
	        UIRole.controller.SetButtonText(3,"翅膀");
			UIRole.controller.bindButtonClick(3, nil, ui.unOpenFunc);
		end
		UIRole.controller.bindButtonClick(0,UIRole.closeSelf);
		-- UIManager.GetInstance():CallLuaMethod('Horse.Start');
		-- UIManager.GetInstance():CallLuaMethod('Horse.hide');

		
        UIRole.openCell = UIRole.createOpenCellPanel(this:GO('OpenCellPanel'));
		UIRole.panelAttr = CreatePanelAttr(this:GO('AttrPanel'));
		-- EventManager.bind(this.gameObject,Event.ON_EXP_CHANGE,UIRole.panelAttr.showExp);
		EventManager.bind(this.gameObject,Event.ON_LEVEL_UP,UIRole.handleLevelUp);
		EventManager.bind(this.gameObject,Event.ON_BLOOD_CHANGE,UIRole.panelAttr.showHp);
		EventManager.bind(this.gameObject,Event.ON_KILL_VALUE_CHANGE,UIRole.panelAttr.showKillValue);
		EventManager.bind(this.gameObject,Event.ON_ATTR_CHANGE, UIRole.panelAttr.UpdateAttr);
	
		UIRole.showHorse = CreatePanelHorse(this, this:GO('HorsePanel'));
		UIRole.panelBag = CreatePanelBag(UIRole, this:GO('BagPanel'));
		EventManager.bind(this.gameObject,Event.ON_EVENT_ITEM_CHANGE,function() 
			UIRole.panelBag.refreshBagItem()
			UIRole.showRedPoint()
			end);
		EventManager.bind(this.gameObject,Event.ON_EVENT_EQUIP_CHANGE,UIRole.panelBag.refreshBagEquip);
		EventManager.bind(this.gameObject,Event.ON_EVENT_GEM_CHANGE,UIRole.panelBag.refreshBagGem);

		EventManager.bind(this.gameObject,Event.ON_LEVEL_UP,UIRole.panelBag.refreshBag);
		EventManager.bind(this.gameObject,Event.ON_TREASURE_BOX_CHANGE,UIRole.panelBag.RefreshBoxFlag);
		
		EventManager.bind(this.gameObject,Event.ON_EVENT_WEAREQUIP_CHANGE,UIRole.showWearEquip);
		EventManager.bind(this.gameObject,Event.ON_FIGHTNUMBER_CHANGE, UIRole.UpdateFightNumber);
        EventManager.bind(this.gameObject,Event.ON_MONEY_CHANGE,UIRole.UpdateMoney);
        EventManager.bind(this.gameObject,Event.ON_DIAMOND_CHANGE,UIRole.UpdateDiamond);
        EventManager.bind(this.gameObject,Event.ON_HORSE_UNLOCK_OR_CANUPGRADE, UIRole.showRedPoint);
        -- 时间和物品变化事件
		-- 坐骑解锁成功
		EventManager.bind(this.gameObject,Event.ON_TIME_SECOND_CHANGE, UIRole.showHorse.updateTime);
		EventManager.bind(this.gameObject, Event.ON_EVENT_ITEM_CHANGE, UIRole.showHorse.onItemChange);
		EventManager.bind(this.gameObject, Event.ON_HORSE_UNLOCK_OR_CANUPGRADE, UIRole.showHorse.onUnlockHorseChange);
		-- 0.632版本坐骑解锁条件临时改为等级，这里注册等级提升事件，刷新页面
		EventManager.bind(this.gameObject, Event.ON_LEVEL_UP, function ()
			UIRole.showHorse.onUnlockHorseChange();
		end);

		local wearEquipContainer = this:GO('EquipPanel');

		local  equipname, equipSlot;
		for i = 1, const.WEAREQUIP_COUNT do
			equipname =  "equip"..i;
			equipSlot = wearEquipContainer:GO(equipname);
			wearSlotList[i] = CreateSlot(equipSlot);
		end

		-- role rtt
		if RoleRTT == 0 then
      		RoleRTT = CreateRoleRTT()
      	else
      		-- print("UpdateRtt")
      		RoleRTT.UpdateRtt()
      	end
		RTTManager.SetRoleFigure(this:GO('3DRole.RoleFigure'), RoleRTT, false, true);
		RTTManager.SetRoleFigure(this:GO('3DRole.MirrorFigure'), RoleRTT, true, true);
        -- UIRole.controller.activeButton(2);
		UIRole.showWearEquip()
		UIRole.showRoleInfo()
		UIRole.showRedPoint();		
		UIRole.controller.activeButton(1);
	end

	function UIRole.ShowRoleFigure()
		this:GO('3DRole').gameObject:SetActive(true);
	end
	function UIRole.HideRoleFigure()
		this:GO('3DRole').gameObject:SetActive(false);
	end

	function UIRole.showRedPoint()
		--NSY-4742 屏蔽
		--UIRole.controller.SetRedPoint(2, client.redPoint.HorseCanTrainOrEnhance() or client.redPoint.HorseCanUnlock());
	end

	function UIRole.wearEquipClick(index)
		local wearEquipList = Bag.wearList;
		local equip =  wearEquipList[index];
		if equip ~= nil then
			local itemCfg = tb.EquipTable[equip.sid];
			local enhanceInfo = Bag.enhanceMap[itemCfg.buwei];
			local gemInfo = client.gem.getEquipGem(itemCfg.buwei);
			if nil ~= equip then 
				local param = {showType = "self", subType = "wear", isScreenCenter = true,  index = index, base = equip, enhance = enhanceInfo, gemList = gemInfo}
				PanelManager:CreateConstPanel('EquipFloat',UIExtendType.BLACKCANCELMASK, param);
			end
		end
	end

	function UIRole.showWearEquip()
		local equip;
		for i = 1, const.WEAREQUIP_COUNT do
			equip =  Bag.wearList[i];
			wearSlotList[i].reset();
			if nil ~= equip then 
				wearSlotList[i].setWareEquip(equip);
				wearSlotList[i].wrapper:BindButtonClick(function () 
					UIRole.wearEquipClick(i);
				end);
			else
				wearSlotList[i].setIcon(const.EQUIP_ICON[i]);
                wearSlotList[i].setFrame(const.QUALITY_BG_Equip[1])
			end
		end
	end

    --创建解锁格子界面
    function UIRole.createOpenCellPanel(wrapper)
        local openCell = {};
        local needDimaond = 0;
        local openCellCount = 0;
        local limitSize;
        local INIT_SIZE = 100;
        --计算解锁需要的道具数量 
        local getOpenConsume = function(count)
            local num = 0;
            local temLsize = limitSize + 1;
            for i =1, count do
                num = num + math.ceil((temLsize - INIT_SIZE) / 20);
                temLsize = temLsize + 1;
            end
            return num;
        end

        local onValueChange = function()
            openCellCount = tonumber(wrapper:GO('Setting.Num.Text').text);
            local consumeCount = getOpenConsume(openCellCount);
            local haveCount = Bag.GetItemCountBysid(const.item.open_bagCell_item);
            if haveCount < consumeCount then
                wrapper:GO('Setting.Total.Text').text = string.format("<color=#CF1010>%d</color>/%d", haveCount, consumeCount);
                --钻石消耗配置 richText 图片
                needDimaond = (consumeCount - haveCount)*10;
                openCell.lackDes:GO("Text").text = string.format("%d补足", needDimaond);
                openCell.lackDes.gameObject:SetActive(true);
            else
                openCell.lackDes.gameObject:SetActive(false);
                wrapper:GO('Setting.Total.Text').text = string.format("<color=#8DDD10>%d</color>/%d", haveCount, consumeCount);
            end
        end

        function openCell.init()
            wrapper:GO('btnOK'):BindButtonClick(function()
                if needDimaond > DataCache.role_diamond then
                    ui.showCharge();
                else
                    Bag.openCell(openCellCount);
                end
                openCell.hide();
			end);
           wrapper:GO('btnCancel'):BindButtonClick(openCell.hide);
           openCell.lackDes = wrapper:GO('Setting.lackDes');
        end

        function openCell.show(count)
            local bagInfo = Bag.GetItemList();	
            wrapper:GO('Setting.Num.Text').text = count;
            limitSize = bagInfo.limitSize;
            BindNumberChange(wrapper:GO('Setting.Num'), 1, bagInfo.maxSize - bagInfo.limitSize, onValueChange);
            onValueChange();
            wrapper.gameObject:SetActive(true);
        end

        function openCell.hide()
            wrapper.gameObject:SetActive(false);
        end

        openCell.init();
        return openCell;
	end



	function UIRole.showRoleInfo()	
        --todo
		this:GO("RoleInfo.FightPoint.value").text = player.fightPoint;	
        this:GO("RoleInfo.money.value").text = formatMoney(DataCache.role_money);
        this:GO("RoleInfo.diamond.value").text = DataCache.role_diamond;
        this:GO("RoleInfo.diamond"):BindButtonClick(ui.unOpenFunc);
        this:GO("RoleInfo.money"):BindButtonClick(function() PanelManager:CreateConstPanel('UIBuyMoney', UIExtendType.BLACKMASK, nil); end);
	end

	function UIRole.UpdateFightNumber()
		this:GO("RoleInfo.FightPoint.value").text = player.fightPoint;	
		this:GO("AttrPanel.FightPoint.value").text = player.fightPoint;	
	end

    function UIRole.UpdateMoney()
		this:GO("RoleInfo.money.value").text = formatMoney(DataCache.role_money);	
	end

    function UIRole.UpdateDiamond()
		this:GO("RoleInfo.diamond.value").text = DataCache.role_diamond;
	end

	function UIRole.showAttrPanel( )
		UIRole.panelBag.hide();
		UIRole.panelAttr.show();
		UIRole.hideEquipAndDiamond();
		UIRole.showHorse.hide();
		UIRole.ShowRoleFigure()
	end

	function UIRole.showBagPanel()
		UIRole.panelBag.show();
		UIRole.panelAttr.hide();
		UIRole.showEquipAndDiamond();
		UIRole.showHorse.hide();

	end

	function UIRole.showHorsePanel()
		if true then ui.showMsg("敬请期待") return nil; end --NSY-4742
		UIRole.panelBag.hide();
		UIRole.panelAttr.hide();
		UIRole.hideEquipAndDiamond();
		UIRole.showHorse.show();
		UIRole.HideRoleFigure()
	end

	function UIRole.showEquipAndDiamond()
		this:GO('RoleInfo'):Show();
		this:GO('EquipPanel'):Show();
	end

	function UIRole.hideEquipAndDiamond()
		this:GO('RoleInfo'):Hide();
		this:GO('EquipPanel'):Hide();
	end

	function UIRole.refreshBag( )
		UIRole.panelBag.refreshBag();
	end

    function UIRole.handleLevelUp()
		UIRole.panelAttr.showLevel();
	end

	function UIRole.closeSelf()
		RoleRTT:SetRttVisible(false);
		destroy(this.gameObject);
	end

	function UIRole.OnDestroy( )

	end

	return UIRole;
end


--背包界面
function CreatePanelBag(parant, wrapper)
	local UIBag = {};
	--local spScrollArrow = wrapper:GO('bagCon.Container.spScrollArrow');
	local prefab = wrapper:LoadAsset("BagItem");
	local itemContainer = wrapper:GO('bagCon.Container');
	local warpContent = itemContainer:GetComponent("UIWarpContent");
	local forbidenRefrsh = false;
	local itemList = nil;
    local limitSize;
	local showed;
    local UN_OPEN_ICON = "tb_suo_beibao1";
	local bagCellNumber; --背包中显示的格子数量

	EventManager.bind(wrapper.gameObject,Event.ON_BAG_FORBIDEN_CHANGE, function () 
		forbidenRefrsh = not forbidenRefrsh;
	end);

	local function GetItemCount(itemBag)
		local count = (math.ceil(itemBag.limitSize/4)+2) * 4;
		if count > itemBag.maxSize then
			count = itemBag.maxSize;
        end
		return count;
	end


	function UIBag.Init()
		warpContent.goItemPrefab = prefab;
		warpContent:BindInitializeItem(UIBag.FormatItem);

		--wrapper:GO('Volume.icon'):BindButtonClick(UIBag.addVolume);
		if DataCache.myInfo.level < 30 then
			wrapper:GO('baBottem.BtnBox'):Hide();
		end
		wrapper:GO('baBottem.BtnBox'):BindButtonClick(UIBag.openGoldBox);
		wrapper:GO('baBottem.BtnSale'):BindButtonClick(UIBag.oneKeySale);
        wrapper:GO('baBottem.BtnClear'):BindButtonClick(UIBag.bagClear);
		--wrapper:GO('BtnSmelt'):BindButtonClick(UIBag.showSmelt)
		UIBag.RefreshBoxFlag();
	end

	function UIBag.RefreshBoxFlag()
		if DataCache.treasureNumber > 0 then
			wrapper:GO('baBottem.BtnBox.flag'):Show();
		else
			wrapper:GO('baBottem.BtnBox.flag'):Hide();
		end
	end

	function UIBag.openGoldBox()
		PanelManager:CreateConstPanel('UIGoldBox', UIExtendType.BLACKMASK, {});
	end
	
	function UIBag.addVolume(index)
        parant.openCell.show(index-limitSize);
	end

	function UIBag.show()
		wrapper.gameObject:SetActive(true);
		UIBag.refreshBag();
	end

	function UIBag.hide()
		wrapper.gameObject:SetActive(false);
	end

	--	显示包裹的容量信息
	function UIBag.showVolume(count, limitSize)
        if count < limitSize then
            wrapper:GO('baBottem.Volume.value').text = count .."/".. limitSize;
        else
            wrapper:GO('baBottem.Volume.value').text = string.format("<color=%s>%s</color>/%s" , const.color.red , count , limitSize);
        end
	end

	--刷新背包
	function UIBag.refreshBag()
		local bagInfo = Bag.GetItemList();	
        itemList = bagInfo.list;
        limitSize = bagInfo.limitSize;
        local count = GetItemCount(bagInfo);
        if nil == bagCellNumber then
            bagCellNumber = count
            --itemContainer:BindScrollRectValueChanged(ScrollRectValueChanged);
            warpContent:Init(bagCellNumber);
        else
            bagCellNumber = count;
            warpContent:Refresh(bagCellNumber);
        end
		--装备页显示容量，物品页刷新cd
		UIBag.showVolume(bagInfo.count, bagInfo.limitSize);
	end

	function UIBag.FormatItem(go, i)
		local wrapper = go:GetComponent("UIWrapper");
		local slotCtrl = wrapper:GetUserData("ctrl");
		if slotCtrl == nil then
			slotCtrl = CreateSlot(go);
			slotCtrl.reset();
			wrapper:SetUserData("ctrl",slotCtrl);
		end
		slotCtrl.reset();
		wrapper:UnbindAllButtonClick();
		
        if i > limitSize then  --未解锁
            slotCtrl.setIcon(UN_OPEN_ICON);
			slotCtrl.setBG(true);
			wrapper:BindButtonClick(function( )
				UIBag.addVolume(i);
			end);
            return;
        end
		local item = itemList[i];			
		if item ~= 0 and item ~= nil then
			wrapper:BindButtonClick(function( )
				UIBag.itemClick(i);
			end);
			if item.type == const.bagType.equip then
                slotCtrl.setBagEquip(item);
				UIBag.showCD(go, false);
			elseif item.type == const.bagType.item then
				slotCtrl.setNormalItem(item);
				UIBag.showCD(go, true);
				UIBag.refreshCD(go);
			elseif item.type == const.bagType.gem then
				slotCtrl.setGem(item);
			end
		else
			slotCtrl.setBG(true);
		end
	end



	function UIBag.refresh(type) 
		if not forbidenRefrsh then
			UIBag.refreshBag()
		end
	end

	function UIBag.refreshBagGem()
		UIBag.refresh(const.bagType.gem)
	end	

	function UIBag.refreshBagItem()
		UIBag.refresh(const.bagType.item)
	end	

	function UIBag.refreshBagEquip()
		UIBag.refresh(const.bagType.equip)
	end	


	function UIBag.isHighScore(equip)
		return equip.isHighScore;
	end


	function UIBag.showCD(go,flag)
		local trans = go.transform:Find("_cd");
		trans.gameObject:SetActive(flag);
	 end 

	 function UIBag.refreshCD(go)
	 	local trans = go.transform:Find("_cd");
	 	local cdCtrl = trans:GetComponent("ItemCDCtrl");
		cdCtrl:CheckCD();
	 end

	function UIBag.itemClick(i)
		local item = itemList[i];
		if item.type == const.bagType.equip then
			local equipInfo = tb.EquipTable[item.sid];
			if item.quality == 6 then
				PanelManager:CreateConstPanel('FragmentFloat',UIExtendType.BLACKCANCELMASK,{base = item});	
			else
				local wear = Bag.wearList[equipInfo.buwei];
				local param = {showType = "self", subType = "bag", isScreenCenter = true,  index = i,base = item, compEquip = wear, enhance = nil}
				PanelManager:CreateConstPanel('EquipFloat',UIExtendType.BLACKCANCELMASK,param);
			end
		elseif item.type == const.bagType.item then
			local param = {bDisplay = false, index = i,base = item};		
			PanelManager:CreateConstPanel('ItemFloat',UIExtendType.BLACKCANCELMASK,param);
		elseif item.type == const.bagType.gem then
			ui.ShowGemFloat(item, false ,nil);
		end	
		--ui.FixFloatPosition(this,go,BAGTYPE);
	end
    
    --一键出售
	function UIBag.oneKeySale()
		client.quickSaleCtrl.getSaleState(function(reply)
			local list = reply["sale_state"];
			client.quickSaleCtrl.StateList = list;
			for i = 1, #client.quickSaleCtrl.StateList do
				if client.quickSaleCtrl.StateList[i] == 1 then
					client.quickSaleCtrl.SelectedList[i] = true; 
				else
					client.quickSaleCtrl.SelectedList[i] = false;
				end
			end
			PanelManager:CreateConstPanel('UISale', UIExtendType.BLACKMASK, {});
		  end);
	end

    --整理
    function UIBag.bagClear()
		Bag.clearUpBag(true);
	end
	-- function UIBag.showSmelt()
	-- 	PanelManager:CreatePanel('UISmelt',  UIExtendType.BLACKMASK, {});
	-- end
	UIBag.Init();
	return UIBag;
end

--坐骑界面
function CreatePanelHorse(parent, wrapper)
	local UIHorse = {};
	local svHorse = nil;
	local warpContent;
	local ctrlList = nil;
	local ndActive = wrapper:GO('ndRight._ndActive');
	local ndTrain = wrapper:GO('ndRight._ndTrain');
	local ndEnhance = wrapper:GO('ndRight._ndEnhance');
	
	local last = {
		clickHorseSlot = nil,
		controller = nil,
		selectIdx = nil,
		model = nil,
		horse = nil
	}

	local ndFigure;

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
			local RoleFigure = wrapper:GO('ndRight._ndFigure.RoleFigure');
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
	function UIHorse.formatItem(go, i)
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
	function UIHorse.initHorseList()
		warpContent = svHorse:GetComponent("UIWarpContent");
		warpContent:BindInitializeItem(UIHorse.formatItem);
		warpContent:Init(#client.horse.horseTableCache);
	end

	-- 刷新坐骑列表
	local function updateHorseList()
		warpContent:Refresh(#client.horse.horseTableCache);
	end

	function UIHorse.closeSelf()
		-- 坐骑模型rtt
		destroy(wrapper.gameObject);	
		--
		if HorseRTT ~= 0 and HorseRTT ~= nil then
			HorseRTT:SetRttVisible(false)
		end
	end

	function UIHorse.updateTime()
		safe_call(last.controller.UpdateTime);
	end

	function UIHorse.onItemChange()
		updateHorseList();
		safe_call(last.controller.onItemChange);
	end

	function UIHorse.onUnlockHorseChange()
		updateHorseList();
		safe_call(last.controller.onUnlockHorseChange);
	end

	function UIHorse.hide()
		wrapper.gameObject:SetActive(false)
	end

	function UIHorse.show()
		wrapper.gameObject:SetActive(true);
	end

	function UIHorse.Init()
		-- this:GO("CommonDlg2.Close"):BindButtonClick(UIHorse.closeSelf);	
		svHorse = wrapper:GO('_svHorse');

		-- 3个子界面控制器
		ctrlList = {CreateHorseActive(ndActive, updateHorseList), CreateHorseTrain(ndTrain, updateHorseList, parent ,wrapper), CreateHorseEnhance(ndEnhance, updateHorseList, parent, wrapper)}
		ndFigure = wrapper:GO('ndRight._ndFigure'); -- 用来调整坐骑模型显示位置

		-- 初始化列表
		UIHorse.initHorseList();

		--显示rtt

	end
	UIHorse.Init();
	return UIHorse;
end

--属性界面
function CreatePanelAttr(wrapper)
	local PanelAttr = {};
	local player = DataCache.myInfo;

	wrapper:GO('BaseInfo.changeName'):BindButtonClick(ui.unOpenFunc);
	wrapper:GO('BaseInfo.head.img').sprite = const.RoleImgTab[DataCache.myInfo.career][DataCache.myInfo.sex + 1];
	-- 点击PK值栏 弹出悬浮提示
	local PKTip = wrapper:GO('PKTip');
	local PKGo = wrapper:GO('BaseInfo.KillValue.bg');
	local ClearPKValue = wrapper:GO('ClearPKValue');

	PKGo:BindButtonClick(function ()
		PKTip:Show();
		local string;
		if DataCache.myInfo.level >= const.PKOpenLevel then
			string = "在野外杀死白名玩家将增加恶名值，在线每5分钟降低1点";
		else
			string = "30级以下角色处于新手保护期，无法进行PK，也不会有死亡惩罚";
		end
		PKTip:GO('bg.text').text = string;
	end);
	
	PKTip:GO('close'):BindButtonClick(function ()
		PKTip:Hide();
	end);

	wrapper:GO('BaseInfo.ClearButton'):BindButtonClick(function ()
		-- 显示清除杀戮值弹窗
		if math.ceil(player.kill_value) <= 0 then
			ui.showMsg("恶名值为0，无需清除");
			return;
		end
		local needDiamondNum = const.PKValueDiamond * math.ceil(player.kill_value);
		ClearPKValue:GO('text').text = "是否立即花费" .. needDiamondNum .. "钻石清除恶名值?"; 
		ClearPKValue:Show();
	end);
	ClearPKValue:GO('close'):BindButtonClick(function ()
		ClearPKValue:Hide();
	end);
	ClearPKValue:GO('btn'):BindButtonClick(function ()
		local killValue = math.ceil(player.kill_value)
		-- 界面打开期间杀戮值可能变化
		if killValue == 0 then
			ui.showMsg("恶名值为0，无需清除");
			ClearPKValue:Hide();	
			return;
		end
		local needDiamondNum = const.PKValueDiamond * math.ceil(player.kill_value);
		if needDiamondNum > DataCache.role_diamond then
			ClearPKValue:Hide();
			ui.showCharge();
		else
			-- 钻石充足，可以进行杀戮值清除
			client.killValueCtrl.ClearKillValue('diamond', needDiamondNum , function ()
				ClearPKValue:Hide();
			end);
		end
	end);

	function PanelAttr.Init()
		PanelAttr.UpdateAttr();
		PanelAttr.showInfo();
		PanelAttr.initBtnGroup();
	end
	function PanelAttr.initBtnGroup()
		wrapper:GO("BtnGroup.headTitle"):BindButtonClick(ui.unOpenFunc)
		wrapper:GO("BtnGroup.fashionSuit"):BindButtonClick(ui.unOpenFunc)
		wrapper:GO("BtnGroup.rankTitle"):BindButtonClick(ui.unOpenFunc)
	end

	function PanelAttr.showInfo()
		PanelAttr.showName();
		PanelAttr.showKillValue();
		PanelAttr.showLegionName();
		PanelAttr.showLevel();
		PanelAttr.showFightPoint();
	end

	function PanelAttr.showName()
		wrapper:GO('BaseInfo.Name.value').text = player.name;
	end

	function PanelAttr.showLevel()
		wrapper:GO('BaseInfo.Level.value').text = player.level;
	end

	function PanelAttr.showKillValue()
		local killValue = math.ceil(player.kill_value);
		local colorStr;
		if killValue == 0 then
			colorStr = "#e4e4e4"
		else
			colorStr = "#CE2041"
		end
		wrapper:GO('BaseInfo.KillValue.value').text = string.format("<color=%s>%s</color>", colorStr, killValue);
	end

	-- 公会发生变化时数据要更新
	function PanelAttr.showLegionName()
		local legionName = wrapper:GO('BaseInfo.Clan.value');
		if client.role.haveClan() then
			legionName.text = client.legion.LegionBaseInfo.Name;
		else
			legionName.text = "未加入";
		end
	end

	function PanelAttr.showFightPoint()
		wrapper:GO('FightPoint.value').text = player.fightPoint
	end

	function PanelAttr.show()
		wrapper.gameObject:SetActive(true);
	end

	function PanelAttr.hide()
		wrapper.gameObject:SetActive(false);
	end

	function PanelAttr.UpdateAttr()
		local FightAttrPanel = wrapper:GO('FightAttr');

		FightAttrPanel:GO('maxhp.value').text = player.maxHP;
		FightAttrPanel:GO('wenzi_atk.value').text = (player.phyAttackMin+player.phyAttack).."~"..(player.phyAttackMax+player.phyAttack);
		FightAttrPanel:GO('wenzi_defend.value').text = player.phyDefense;
		FightAttrPanel:GO('wenzi_hit.value').text = player.hit;
		FightAttrPanel:GO('wenzi_dodge.value').text = player.dodge;
		FightAttrPanel:GO('wenzi_crit.value').text = player.critical;
		FightAttrPanel:GO('wenzi_toughness.value').text = player.tenacity;
		FightAttrPanel:GO('wenzi_poji.value').text = player.brokenBlock;
		FightAttrPanel:GO('wenzi_gedang.value').text = player.block;	

		FightAttrPanel:GO('wenzi_addAttack.value').text = math.round(player.damageAmplifyP*100).."%";
		FightAttrPanel:GO('wenzi_reduceAttack.value').text = math.round(player.damageResistP*100).."%";	
		FightAttrPanel:GO('wenzi_ignoreDefend.value').text = math.round(player.defenseReduceP*100).."%";
		FightAttrPanel:GO('wenzi_resistAttack.value').text = math.round(player.attackReduceP*100).."%";
		FightAttrPanel:GO('wenzi_hpRecover1.value').text = player.fightHPRecover;
		FightAttrPanel:GO('wenzi_hpRecover2.value').text = player.freeHPRecover;
	end
	
	PanelAttr.Init();
	return PanelAttr;
end
