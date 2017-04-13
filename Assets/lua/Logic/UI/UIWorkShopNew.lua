function UIWorkShopNewView (param)
	local UIWorkShopNew = {};
	local this = nil;
	local cdc = nil;
	local equipList= {};
	local MaxStart = 5;
	local ctrlList = {};
	local curCtrl;
	local ctrlFact = {};
	local EquipGrid = nil;
	local equipCell = nil;
	local level = nil;
	-- local baoshi1 = nil;
	-- local baoshi2 = nil;
	-- local baoshi3 = nil;
	-- local baoshi4 = nil;

	local m_selectPage;
	local m_selectEquip;

	local ensuerCtrl = function(selectPage)
		if ctrlFact[selectPage] then
			ctrlFact[selectPage]();
		end
	end

	local updateHighFlag = function(selectPage)
		local firstFlag = 0;
		local pageFlag = false;
		local flag;
		local equip;
		-- 创建选中的页面
		ensuerCtrl(selectPage);
		for i = 1, #Bag.enhanceMap do
			local index = const.TranslateIndex[i]				
			equip = Bag.wearList[index];
			if equip then
				if firstFlag == 0 then
					firstFlag = index;
				end
				flag = ctrlList[selectPage].checkHigh(index);
				equipList[index].setHigh(flag);
				if flag then
					if pageFlag == false then
						firstFlag = index
						pageFlag = true;
					end				
					equipList[index].setUp(false);
				else
					if ctrlList[selectPage].checkUp then
						equipList[index].setUp(ctrlList[selectPage].checkUp(index));
						-- 存在宝石可以合成时切页按钮显示红点
						-- if ctrlList[selectPage].checkUp(index) and pageFlag == false then
						-- 	pageFlag = true;
						-- end
					end			
				end
			end
		end
		cdc.SetRedPoint(selectPage, pageFlag)
		return firstFlag;
	end

	local initCDC = function ()
		cdc = createCDC(this:GO('CommonDlg'))
		cdc.SetButtonNumber(2);
		cdc.SetButtonText(1,"强化");
		cdc.bindButtonClick(1,UIWorkShopNew.showEnhance);		
		
		cdc.SetButtonText(2,"宝石");
		cdc.bindButtonClick(2,UIWorkShopNew.showGem, function () 
			if DataCache.myInfo.level < 35 then
				ui.showMsg("35级开放");
				return false;
			end
			if client.newSystemOpen.isSystemOpen("gem") then
		        client.newSystemOpen.onGuideComplete("gem");
		    end
			return true;
		end);
		
		cdc.bindButtonClick(0,UIWorkShopNew.closeSelf);
	end

	local SetEquipEnhanceShow = function(IsShow, k)
			local equip = Bag.wearList[k];
			local enhanceInfo = Bag.enhanceMap[k];
			if equip and  enhanceInfo.level > 0 then
				EquipGrid:GO("equip"..k..".cell.enhance").gameObject:SetActive(IsShow);
				EquipGrid:GO("equip"..k..".cell.enhance").text = "强化 +"..enhanceInfo.level;
			end
	end

	local updateWearEquip = function (buwei)	
		local equip = Bag.wearList[buwei];
		if equip then	
			equipList[buwei].setEquip(equip, "");
			if buwei == m_selectEquip then
				equipList[buwei].setChoose(true);
			end
			local enhanceInfo = Bag.enhanceMap[buwei];		
			if enhanceInfo.level > 0 and m_selectPage == 1 then
				equipList[buwei].setAttr("+"..enhanceInfo.level);
			end
			if m_selectPage == 2 then
				SetEquipEnhanceShow(false, buwei);
				equipList[buwei].setBtmGemList(client.gem.getEquipGem(buwei));
			end
			if m_selectPage == 1 then
				SetEquipEnhanceShow(true, buwei);
				--client.setEnhanceLevel(client.enhance.enhanceLevelList);
			end
		else			
			equipList[buwei].setIcon(const.EQUIP_ICON[buwei]);
		end
	end

	local onUpdate = function()
		for i = 1, #Bag.enhanceMap do			
			updateWearEquip(i);
		end
		updateHighFlag(m_selectPage);
		if m_selectEquip ~= 0 then
	 		curCtrl.onEquipSelect(m_selectEquip);
		end
	end

	ctrlFact[1] = function()		
		ctrlList[1] = CreateQiangHuaUI(this:GO("content.EnhancePanel"), onUpdate, m_selectEquip, this);
		ctrlFact[1] = nil;
	end

	ctrlFact[2] = function()
		ctrlList[2] = CreateGemCtrl(this:GO('content.BaoshiPanel'), onUpdate, m_selectEquip, this);
		ctrlFact[2] = nil;
	end

	local onEquipSelect = function (selectIdx, forceUpdate)		
		m_selectEquip = selectIdx;
		for i = 1, #Bag.enhanceMap do
			equipList[i].setChoose(selectIdx == i);
		end
		m_selectEquip = selectIdx;
		if m_selectEquip ~= 0 then
	 		curCtrl.onEquipSelect(selectIdx, forceUpdate);
	 	end
	end	

	local initWearEquip = function()
		local equipItem;
		local equipSlot;
		local equip;		
		local equipTable;	
		local pageFlag = false;
		for i = 1, #Bag.enhanceMap do
			equipItem = EquipGrid:GO("equip"..i);
			equipSlot = equipItem:GO("cell");
			equipList[i] = CreateSlot(equipSlot);
			equipList[i].reset();

			local equip = Bag.wearList[i];
			if equip then
				equipItem:BindButtonClick(function () 
					onEquipSelect(i);
				end);
			end
			updateWearEquip(i);
		end
	end

	function UIWorkShopNew.Start ()
		this = UIWorkShopNew.this;
		m_selectEquip = param.selectIdx;
		-- param.selectPage  = param.selectPage or 2;
		EquipGrid = this:GO('content.LeftContent._EquipGrid');
		equipCell = this:GO('content.BaoshiPanel.RightContent._equipCell');
		initCDC();
		initWearEquip();
		updateHighFlag(1);
		updateHighFlag(2);
		cdc.activeButton(param.selectPage);
		EventManager.bind(this.gameObject, Event.ON_EVENT_EQUIP_CHANGE,function ()
            updateHighFlag(m_selectPage);
        end);
	end

	local onPageSelected = function (selectPage)
		if curCtrl then
			if curCtrl.recordToggle then
				curCtrl.recordToggle();
			end
		end

		if m_selectPage == selectPage then
			return;
		end
		m_selectPage = selectPage;
		if curCtrl then
		 	curCtrl.visible(false);
		end

		for i = 1, #Bag.enhanceMap do			
			equipList[i].reset();
		end
		ensuerCtrl(selectPage);
		curCtrl = ctrlList[selectPage];
		curCtrl.visible(true);
		local firstFlag = updateHighFlag(selectPage);
		m_selectEquip = m_selectEquip or firstFlag;		
		for i = 1, #Bag.enhanceMap do			
			updateWearEquip(i);
		end
		onEquipSelect(m_selectEquip, true);
	end

	--初始化强化界面
	UIWorkShopNew.showEnhance = function ()
		--这边是新旧切换的临时代码
		--UIWorkShopNew.closeSelf();
		--ui.showWorkShop(m_selectEquip);
		onPageSelected(1);
	end

	--初始化宝石界面
	UIWorkShopNew.showGem = function ()
		onPageSelected(2);
	end

	UIWorkShopNew.closeSelf = function ()
		destroy(this.gameObject);
	end

	return UIWorkShopNew;
end

ui.showGemWorkShopNew = function (selectIdx)
	if DataCache.myInfo.level < 35 then
		ui.showMsg("35级开放");
		return;
	end
	if client.newSystemOpen.isSystemOpen("gem") then
        client.newSystemOpen.onGuideComplete("gem");
    end
	ui.showWorkShopNew(2, selectIdx);
end 

ui.showWorkShopNew = function (selectPage, selectIdx)
	PanelManager:CreatePanel('UIWorkShopNew',  UIExtendType.TRANSMASK, {selectIdx = selectIdx, selectPage = selectPage});
end 
