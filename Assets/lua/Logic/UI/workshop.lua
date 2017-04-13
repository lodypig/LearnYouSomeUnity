function UIWorkShopView(param)
	local workShop = {};	
	local cdc;
	local this;
	local equipList= {};
	local MaxStart = 5;
	local ctrlList = {};
	local curCtrl;
	local ctrlFact = {};
	local m_selectPage;
	local m_selectEquip;

	local tfFightNum;
	local tfPlayerName;

	local function UpdateFightNumber()
		tfFightNum.text =  "战力 "..DataCache.myInfo.fightPoint;	
	end

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
				flag = ctrlList[selectPage] and ctrlList[selectPage].checkHigh(index);
				equipList[index].setHigh(flag);
				if flag then
					if pageFlag == false then
						firstFlag = index
						pageFlag = true;
					end				
					equipList[index].setUp(false);
				else
					if ctrlList[selectPage] and ctrlList[selectPage].checkUp then
						equipList[index].setUp(ctrlList[selectPage].checkUp(index));
						-- 存在宝石可以合成时切页按钮显示红点
						if ctrlList[selectPage].checkUp(index) and pageFlag == false then
							pageFlag = true;
						end
					end			
				end
			end
		end
		cdc.SetRedPoint(selectPage, pageFlag)
		return firstFlag;
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
				equipList[buwei].setBtmGemList(client.gem.getEquipGem(buwei));
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
		ctrlList[1] = CreateQiangHuaUI(this:GO("content.ndQiangHua"), onUpdate)
		ctrlFact[1] = nil;
	end

	ctrlFact[2] = function()		
		ctrlFact[2] = nil;
	end

	local onEquipSelect = function (selectIdx, forceUpdate)		
		m_selectEquip = selectIdx;
		for i = 1, #Bag.enhanceMap do
			equipList[i].setChoose(selectIdx == i);
		end
		m_selectEquip = selectIdx;
		if m_selectEquip ~= 0 and curCtrl then
	 		curCtrl.onEquipSelect(selectIdx, forceUpdate);
	 	end
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

		--这边是新旧切换的临时代码
		if selectPage == 2 then
			workShop.closeSelf()
			ui.showGemWorkShopNew(m_selectEquip);
		end
		
		m_selectPage = selectPage;
		if curCtrl then
		 curCtrl.visible(false);
		end

		for i = 1, #Bag.enhanceMap do			
			equipList[i].reset();
			equipList[i].setBG(true);
		end
		
		ensuerCtrl(selectPage);
		curCtrl = ctrlList[selectPage];
		if curCtrl then
			curCtrl.visible(true);
		end
		local firstFlag = updateHighFlag(selectPage);
		m_selectEquip = m_selectEquip or firstFlag;		
		for i = 1, #Bag.enhanceMap do			
			updateWearEquip(i);
		end
		onEquipSelect(m_selectEquip, true);
	end

	local function initWearEquip()
		local equipSlot;
		local equip;		
		local equipTable;	
		local pageFlag = false;
		for i = 1, #Bag.enhanceMap do
			equipSlot = this:GO("content.ndLeft.equips.equip"..i);
			equipList[i] = CreateSlot(equipSlot);
			equipList[i].reset();
			local equip = Bag.wearList[i];
			if equip then
				equipSlot:BindButtonClick(function () 
					onEquipSelect(i);
				end);
			end
			updateWearEquip(i);
		end
	end

	local initCDC = function ()
		cdc = createCDC(this:GO('CommonDlg'))
		cdc.SetButtonNumber(2);
		cdc.SetButtonText(1,"强化");
		cdc.bindButtonClick(1,workShop.showEnhance);		
		
		cdc.SetButtonText(2,"镶嵌");
		cdc.bindButtonClick(2,workShop.showGem, function () 
			if DataCache.myInfo.level < 40 then
				ui.showMsg("40级开放");
				return false;
			end
			if client.newSystemOpen.isSystemOpen("gem") then
		        client.newSystemOpen.onGuideComplete("gem");
		    end
			return true;
		end);		
		
		cdc.bindButtonClick(0,workShop.closeSelf);
		cdc.SetTitle("wz_gongfang")
	end


	function workShop.checkNewFlag()
		local gemNewFlag = this:GO("CommonDlg.ButtonGroup.btn2.newFlag");
		if client.newSystemOpen.isSystemOpen("gem") then
           	gemNewFlag:Show();
       	else
       		gemNewFlag:Hide();
        end
	end

	function workShop.Start()
		this = workShop.this;		
		initCDC();
		
		initWearEquip();
		tfFightNum = this:GO("content.ndLeft.FightValue");
		tfPlayerName = this:GO("content.ndLeft.Name");
		tfPlayerName.text = DataCache.myInfo.name;	
	 	
		UpdateFightNumber();
		param.selectPage = param.selectPage or 1;
		if param.selectPage == 1 then
			updateHighFlag(2);
		else
			updateHighFlag(1);
		end		

		m_selectEquip = param.selectIdx;
		cdc.activeButton(param.selectPage);
		workShop.checkNewFlag();
		
		EventManager.bind(this.gameObject,Event.ON_FIGHTNUMBER_CHANGE, UpdateFightNumber);
		EventManager.bind(this.gameObject,Event.ON_NEW_SYSTEM_OPEN_FLAG_CHANGE,workShop.checkNewFlag);
		if ctrlList[param.selectPage].Start then
			ctrlList[param.selectPage].Start()
		end
		-- role rtt
		if RoleRTT == 0 then
      		RoleRTT = CreateRoleRTT()
      	else
      		RoleRTT.UpdateRtt()
      	end
		RTTManager.SetRoleFigure(this:GO('content.ndLeft.3DRole.RoleFigure'), RoleRTT, false, true);
	end	

	workShop.showEnhance = function ()		
		onPageSelected(1);
	end

	workShop.showGem = function ()
		onPageSelected(2);
	end

	workShop.closeSelf = function ()
		RoleRTT:SetRttVisible(false);
		destroy(workShop.this.gameObject);
		if curCtrl and curCtrl.recordToggle then
			curCtrl.recordToggle();
		end
	end

	function workShop.OnDestroy( )		
		RoleRTT:SetRttVisible(false);
	end

	return workShop;
end

ui.showGemWorkShop = function (selectIdx)
	if DataCache.myInfo.level < 40 then
		ui.showMsg("40级开放");
		return;
	end
	if client.newSystemOpen.isSystemOpen("gem") then
        client.newSystemOpen.onGuideComplete("gem");
    end
	ui.showWorkShop(2, selectIdx);
end 


ui.showWorkShop = function (selectPage, selectIdx)
	PanelManager:CreatePanel('UIWorkShop',  UIExtendType.BLACKMASK, {selectIdx = selectIdx, selectPage = selectPage});
end 
