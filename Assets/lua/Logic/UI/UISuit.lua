
function UISuitView ()
	local UISuit = {};
	local this = nil;
	local selectedIndex = -1;
	local SuitName = nil;
	local Count = nil;
	local ActivedIcn = nil;
	local UnlockBtn = nil;
	local ActivateBtn = nil;
	local SuitDetailTitle = nil;

	function UISuit.Start ()
		this = UISuit.this;
		SuitName = this:GO('Panel.CenterPanel._SuitName');
		Count = this:GO('Panel.RightPanel._Count');
		ActivedIcn = this:GO('Panel.RightPanel.Status._ActivedIcn');
		UnlockBtn = this:GO('Panel.RightPanel.Status._UnlockBtn');
		ActivateBtn = this:GO('Panel.RightPanel.Status._ActivateBtn');
		SuitDetailTitle = this:GO('Panel.RightPanel.Label');

		local roleFigure = this:GO('Panel.3DRole.RoleFigure');
		if SuitRTT == 0 then
			SuitRTT = CreateSuitRTT()
		else
			local modelName, modelMaterialName, _ = uAvatarUtil.GetPlayerModelName(DataCache.myInfo, false)
			SuitRTT.UpdateRtt(modelName, modelMaterialName)
		end
		RTTManager.SetRoleFigure(roleFigure, SuitRTT, false, true);

		EventManager.bind(this.gameObject, Event.ON_EVENT_GET_NEW_EQUIP, UISuit.onGetNewEquip);

		for i = 1, 6 do
			local itemWrapper = this:GO("Panel.RightPanel.Item" .. i .. ".icon");
			itemWrapper:SetUserData("index", i);
			itemWrapper:BindButtonClick(function (go)
				local wrapper = go:GetComponent('UIWrapper');
				local index = wrapper:GetUserData("index");
				local itemData = FashionSuit.suits[selectedIndex];
				local itemSid = itemData["part" .. index];
				local itemQuality = itemData["part" .. index .. "_quality"];
				local param = {showType = "random", isScreenCenter = true, sid = itemSid, quality = itemQuality};
				PanelManager:CreateConstPanel('EquipFloat', UIExtendType.BLACKCANCELMASK, param);
			end);
		end

		UnlockBtn:BindButtonClick(function (go)
			local wrapper = go:GetComponent('UIWrapper');
			if not wrapper.buttonEnable then
				return;
			end
			local index = wrapper:GetUserData("index");
			local itemData = FashionSuit.suits[index];
			FashionSuit.unlockFashionSuit(itemData.id, function (success)
				if success then
					UISuit.setNormalItem(index);
					UISuit.showSelectedSuitDesc(index);
				end
			end);
		end);

		ActivateBtn:BindButtonClick(function (go)
			local wrapper = go:GetComponent('UIWrapper');
			if not wrapper.buttonEnable then
				return;
			end
			local index = wrapper:GetUserData("index");
			local itemData = FashionSuit.suits[index];
			FashionSuit.activateFashionSuit(itemData.id, function (success)

				if success then
					
					for i = 1, #FashionSuit.suits do
					
						local itemData = FashionSuit.suits[i];
						if FashionSuit.isActivateSuit(itemData.id) then
							UISuit.setActivedItem(i);
						elseif FashionSuit.isUnlockSuit(itemData.id) then
							UISuit.setNormalItem(i);
						else
							UISuit.setLockedItem(i);
						end
					end

					UISuit.showSelectedSuitDesc(index);
				end

			end);
		end);


		selectedIndex = UISuit.getSelectedSuitIndex();

		--切页按钮
		local commonDlgGO = this:GO('CommonDlg5');
		local controller = createScrollviewCDC(commonDlgGO)
		UISuit.controller = controller;
		controller.bindButtonClick(0, UISuit.Close);
		FashionSuit.addFashionSuits();
		controller.SetButtonNumber(#FashionSuit.suits, function (index, item)

			local itemData = FashionSuit.suits[index];
			local wrapper = item:GetComponent("UIWrapper");
			wrapper:SetUserData("index", index);
			controller.SetButtonText(index, itemData.name);
			wrapper:BindButtonClick(UISuit.onButtonClicked);

		end, function ()

			FashionSuit.getFashionSuits(function ()
				
				for i = 1, #FashionSuit.suits do
					local itemData = FashionSuit.suits[i];

					if FashionSuit.isActivateSuit(itemData.id) then
						UISuit.setActivedItem(i);
					elseif FashionSuit.isUnlockSuit(itemData.id) then
						UISuit.setNormalItem(i);
					else
						UISuit.setLockedItem(i);
					end
				end

				local firstItem = controller.GetItem(selectedIndex);
				if firstItem ~= nil then
					firstItem:FireButtonClick();
				end

			end);

		end);

		
	end


	function UISuit.getSelectedSuitIndex()
		local activateSuitId = DataCache.myInfo.suitActivateId;
		if activateSuitId == 0 then
			activateSuitId = FashionSuit.getNewerSuitId(FashionSuit.suits);
		end
		for i = 1, #FashionSuit.suits do
			local itemData = FashionSuit.suits[i];
			if itemData.id == activateSuitId then
				return i;
			end
		end
		return 1;
	end


	function UISuit.onGetNewEquip(msg)

	

		local equips = msg["equips"];
	
	
		FashionSuit.refreshHistoryEquips(equips);

		local controller = UISuit.controller;
		for i = 1, #FashionSuit.suits do
			local itemData = FashionSuit.suits[i];
			if not FashionSuit.isUnlockSuit(itemData.id) and not FashionSuit.isActivateSuit(itemData.id) then
				local item = controller.GetItem(i);
				local flag = item:GO('flag');
				if FashionSuit.isAllSuitEquipOn(itemData) then
					flag:Show();
				else	
					flag:Hide();
				end
			end
		end

		
		local item = controller.GetItem(selectedIndex);
		if item ~= nil then
			item:FireButtonClick();
		end

		
	end

	function UISuit.onButtonClicked(go)
		-- body
		local wrapper = go:GetComponent('UIWrapper');
		local index = wrapper:GetUserData('index');
		selectedIndex = index;
		FashionSuit.getFashionSuitInfo(function ()
			UISuit.setSelected(index, true);
		end);
	end

	function UISuit.isAllSuitEquipOnByIndex(index)
		local itemData = FashionSuit.suits[index];
		return FashionSuit.isAllSuitEquipOn(itemData);
	end


	function UISuit.showSelectedSuitDesc(index)

		UnlockBtn:SetUserData("index", index);
		ActivateBtn:SetUserData("index", index);

		local itemData = FashionSuit.suits[index];
		SuitName.text = itemData.name;
		local Status = this:GO("Panel.RightPanel.Status");

		local onCount = 0;
		local partCount = 0;

		if FashionSuit.isNewerSuit(itemData.id) then
			SuitDetailTitle:Hide();
			Count:Hide();
			for i = 1, 6 do
				local itemWrapper = this:GO("Panel.RightPanel.Item" .. i);
				itemWrapper:Hide();
			end
			Status:Show();
		else
			Status:Show();
			SuitDetailTitle:Show();
			
			for i = 1, 6 do
				local part = itemData["part" .. i];
				local part_quality = itemData["part"..i.."_quality"];
				local itemWrapper = this:GO("Panel.RightPanel.Item" .. i);
				if part ~= 0 then
					partCount = partCount + 1;
					itemWrapper:Show();
					local isOn = false;
					local equipData = tb.EquipTable[part];
					if equipData == nil then
						isOn = false;
					else
						isOn = FashionSuit.isSuitEquipOn(part, part_quality);
					end
					local frameWrapper = itemWrapper:GO("frame");
					local iconWrapper = itemWrapper:GO("icon");
					iconWrapper.sprite = equipData.icon;
					if isOn then
						onCount = onCount + 1;
						frameWrapper.sprite = const.QUALITY_BG[part_quality + 1];
						frameWrapper:SetBlackWhiteMode(false);
						iconWrapper:SetBlackWhiteMode(false);
					else
						frameWrapper.sprite = const.QUALITY_BG[1];
						frameWrapper:SetBlackWhiteMode(true);
						iconWrapper:SetBlackWhiteMode(true);
					end
				else
					itemWrapper:Hide();
				end
			end

			-- 装备点亮数量
			Count:Show();
			Count.text = string.format("%d/%d", onCount, partCount);

		end

		if FashionSuit.isNewerSuit(itemData.id) then

			if FashionSuit.isActivateSuit(itemData.id) then
				ActivedIcn:Show();
				UnlockBtn:Hide();
				ActivateBtn:Hide();
			else
				ActivedIcn:Hide();
				UnlockBtn:Hide();
				ActivateBtn:Show();
			end

		else

			-- 显示/隐藏时装状态
			if FashionSuit.isActivateSuit(itemData.id) then
				ActivedIcn:Show();
				UnlockBtn:Hide();
				ActivateBtn:Hide();

			elseif FashionSuit.isUnlockSuit(itemData.id) then
				ActivedIcn:Hide();
				UnlockBtn:Hide();
				ActivateBtn:Show();
			else
				UnlockBtn:Show();

				local flagWrapper = UnlockBtn:GO('flag');
				if FashionSuit.isAllSuitEquipOn(itemData) then
					flagWrapper:Show();
				else
					flagWrapper:Hide();
				end

				ActivedIcn:Hide();
				ActivateBtn:Hide();
				if onCount == partCount then
					UnlockBtn.buttonEnable = true;
				else
					UnlockBtn.buttonEnable = false;
				end
			end
		end

		-- 穿上时装
		local suitName = itemData.male_model;
		local suitTxName = itemData.male_model_tex;
		if DataCache.myInfo.sex == 0 then
			suitName = itemData.female_model;
			suitTxName = itemData.female_model_tex;
		end
		SuitRTT.UpdateRtt(suitName, suitTxName);
	end


	function UISuit.setSelected(index, selected)
		if selected then
			local controller = UISuit.controller;
			for i = 1, controller.maxBtnNum do
				local item = controller.GetItem(i);
				UISuit.setSelected(i, false);
			end
			local controller = UISuit.controller;
			local item = controller.GetItem(index);
			local selectedWrapper = item:GO('Selected');
			selectedWrapper:Show();

			UISuit.showSelectedSuitDesc(index);


		else
			local controller = UISuit.controller;
			local item = controller.GetItem(index);
			local selectedWrapper = item:GO('Selected');
			selectedWrapper:Hide();
		end
	end

	-- 设置已经被激活的时装项
	function UISuit.setActivedItem(index)
		local controller = UISuit.controller;
		local item = controller.GetItem(index);
		local actived = item:GO('Status.Actived');
		local lock = item:GO('Status.Lock');
		local flag = item:GO('flag');
		local text = item:GO('text');
		text:SetTextColor(241, 241, 241, 255);
		actived:Show();
		lock:Hide();
		flag:Hide();
	end

	-- 设置锁定的时装项
	function UISuit.setLockedItem(index)
		
		local controller = UISuit.controller;
		local item = controller.GetItem(index);
		local actived = item:GO('Status.Actived');
		local lock = item:GO('Status.Lock');
	
		local flag = item:GO('flag');
		if UISuit.isAllSuitEquipOnByIndex(index) then
			flag:Show();
		else
			flag:Hide();
		end
		
		local text = item:GO('text');
		text:SetTextColor(108, 108, 109, 255);
		actived:Hide();
		lock:Show();
		
	end

	-- 设置一般的时装项
	function UISuit.setNormalItem(index)
		local controller = UISuit.controller;
		local item = controller.GetItem(index);
		local actived = item:GO('Status.Actived');
		local lock = item:GO('Status.Lock');
		local flag = item:GO('flag');
		local text = item:GO('text');
		text:SetTextColor(241, 241, 241, 255);
		actived:Hide();
		lock:Hide();
		flag:Hide();
	end


	function UISuit.Close()
		SuitRTT:SetRttVisible(false);
		destroy(this.gameObject);
	end

	function UISuit.OnDestroy()
		-- body
	end


	return UISuit;
end
