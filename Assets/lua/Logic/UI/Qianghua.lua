function CreateQiangHuaUI(node, onUpdate, selectEquip, root)
	local controller = {};
	local buwei;
	local tfCostMoney = node:GO("_MoneyCell._count");
	local tfEquipName = node:GO("_EquipCell._name");
	local tfEquipLevel = node:GO("_EquipCell._level");
	local spEquip = node:GO("_EquipCell.icon");
	local spQuality = node:GO("_EquipCell.frame");

	local spEnhancedEquip = node:GO("Equip.frame.icon");
	local spEnhancedQuality = node:GO("Equip.frame");
	local tfEnhancedEquipLevel = node:GO("Equip.level");
	local tfNextShow = node:GO("Equip._text");

 	local tfCurAttrType = node:GO("AttrFrame.attr");
	local tfCurAttr = node:GO("AttrFrame.value");
	local tfCurAttrAdd = node:GO("AttrFrame.add");

	local spProgress = node:GO("Progress.background.value");
	local spShowProgress = node:GO("Progress.value");

	local BtnEnhance = node:GO("BtnEnhance");
	local BtnAllEnhance = node:GO("BtnAll");

	local EquipGrid = root:GO("content.LeftContent._EquipGrid");

	local grid1 = root:GO("content.LeftContent._EquipGrid.equip1.grid");
	local grid2 = root:GO("content.LeftContent._EquipGrid.equip2.grid");
	local grid3 = root:GO("content.LeftContent._EquipGrid.equip3.grid");
	local grid4 = root:GO("content.LeftContent._EquipGrid.equip4.grid");
	local grid5 = root:GO("content.LeftContent._EquipGrid.equip5.grid");
	local grid6 = root:GO("content.LeftContent._EquipGrid.equip6.grid");
	local grid7 = root:GO("content.LeftContent._EquipGrid.equip7.grid");
	local grid8 = root:GO("content.LeftContent._EquipGrid.equip8.grid");
	local grid9 = root:GO("content.LeftContent._EquipGrid.equip9.grid");
	local grid10 = root:GO("content.LeftContent._EquipGrid.equip10.grid");
	local gridTab = {grid1, grid2, grid3, grid4, grid5, grid6, grid7, grid8, grid9, grid10};

	local EnhanceLevelPos1 = grid1.transform.localPosition;
	local EnhanceLevelPos2 = grid2.transform.localPosition;
	local EnhanceLevelPos3 = grid3.transform.localPosition;
	local EnhanceLevelPos4 = grid4.transform.localPosition;
	local EnhanceLevelPos5 = grid5.transform.localPosition;
	local EnhanceLevelPos6 = grid6.transform.localPosition;
	local EnhanceLevelPos7 = grid7.transform.localPosition;
	local EnhanceLevelPos8 = grid8.transform.localPosition;
	local EnhanceLevelPos9 = grid9.transform.localPosition;
	local EnhanceLevelPos10 = grid10.transform.localPosition;
	local EnhanceLevelPosTab = {EnhanceLevelPos1, EnhanceLevelPos2, EnhanceLevelPos3, EnhanceLevelPos4, EnhanceLevelPos5, EnhanceLevelPos6, EnhanceLevelPos7, EnhanceLevelPos8, EnhanceLevelPos9, EnhanceLevelPos10};


	local sequence1 = DG.Tweening.DOTween.Sequence();
	local sequence2 = DG.Tweening.DOTween.Sequence();
	local sequence3 = DG.Tweening.DOTween.Sequence();
	local sequence4 = DG.Tweening.DOTween.Sequence();
	local sequence5 = DG.Tweening.DOTween.Sequence();
	local sequence6 = DG.Tweening.DOTween.Sequence();
	local sequence7 = DG.Tweening.DOTween.Sequence();
	local sequence8 = DG.Tweening.DOTween.Sequence();
	local sequence9 = DG.Tweening.DOTween.Sequence();
	local sequence10 = DG.Tweening.DOTween.Sequence();
	local sequenceTab = {sequence1, sequence2, sequence3, sequence4, sequence5, sequence6, sequence7, sequence8, sequence9, sequence10};

	for i = 1, 10 do
		gridTab[i].transform.localPosition = Vector2.New(EnhanceLevelPosTab[i].x, EnhanceLevelPosTab[i].y);
		sequenceTab[i]:Append(gridTab[i]:GetComponent("CanvasGroup"):DOFade(0, 2));
		sequenceTab[i]:Join(gridTab[i].transform:DOLocalMoveY(EnhanceLevelPosTab[i].y + 50, 2, false));
		sequenceTab[i]:SetAutoKill(false);
	end

	local function copyTab(st)  
        local tab = {}  
        for k, v in pairs(st or {}) do  
            if type(v) ~= "table" then  
                tab[k] = v  
            else  
                tab[k] = copyTab(v)  
            end  
        end
        return tab  
    end

	local updateEquip = function (selectIdx, enhanceInfo)		
		local equip = Bag.wearList[selectIdx];
		local enhanceInfo = Bag.enhanceMap[selectIdx];
		if equip then
			if equip.enhanceInfo ~= 99 then
				tfEquipName.gameObject:SetActive(true);
				tfEquipLevel.gameObject:SetActive(true);
				spEquip.gameObject:SetActive(true);
				local equipTable = tb.EquipTable[equip.sid];
				spEquip.sprite = equipTable.icon;
				spQuality.sprite = const.QUALITY_BG[equip.quality + 1];
				tfEquipName.text = const.BuWei[selectIdx];
				tfEquipLevel.text = enhanceInfo.level.."级";

				tfNextShow.gameObject:SetActive(true);
				spEnhancedEquip.sprite = equipTable.icon;
				spEnhancedQuality.sprite = const.QUALITY_BG[equip.quality + 1];
				tfEnhancedEquipLevel.text = (enhanceInfo.level + 1).."级";
			else
				-- 达到强化等级物理上限,显示空格子,感觉看着很难受啊~~~
				tfEquipName.gameObject:SetActive(false);
				tfEquipLevel.gameObject:SetActive(false);
				spEquip.gameObject:SetActive(false);
				tfNextShow.gameObject:SetActive(false);
				spQuality.sprite = "dk_kong_1";
				spEnhancedEquip.sprite = equipTable.icon;
				spEnhancedQuality.sprite = const.QUALITY_BG[equip.quality + 1];
				tfEnhancedEquipLevel.text = (enhanceInfo.level).."级";
			end
		else
			spEquip.sprite = const.EQUIP_ICON[selectIdx];
		end
	end

	local updateCost = function (enhanceTable)	
		local sid = enhanceTable.material_sid;
		local count = Bag.GetItemCountBysid(sid);
		tfCostMoney.text = client.tools.formatColor(enhanceTable.need_money, const.color.red, DataCache.role_money, enhanceTable.need_money);
	end

	local updateContent = function (selectIdx)
		local enhanceInfo = Bag.enhanceMap[selectIdx];
		local enhanceTable = client.enhance.getEnhanceTable(selectIdx, enhanceInfo.level);			
		local equip = Bag.wearList[selectIdx];
		if enhanceTable.attr_type == "phyAttack" then
			tfCurAttrType.text = "攻击力"
		else
			tfCurAttrType.text = "防御"
		end
		tfCurAttr.text = enhanceTable.attr_value;
		tfCurAttrAdd.text = "+ "..enhanceTable.add_value;

		enhanceTable = client.enhance.getEnhanceTable(selectIdx, enhanceInfo.level + 1);
	end

	local ShowProgressFunc = function(value, total)
		local selectIdx = buwei;
		local enhanceInfo = Bag.enhanceMap[selectIdx];
		local enhanceTable = client.enhance.getEnhanceTable(selectIdx, enhanceInfo.level);	
		spProgress.fillAmount = (value - total) / enhanceTable.enhance_total;
		spShowProgress.text = (value - total) .. "/" .. enhanceTable.enhance_total;
	end

	local updateProgress = function(selectIdx)
		client.enhance.getEnhancePoint(ShowProgressFunc, selectIdx);
	end

	local handelLeftEffect = function(lastLevelList, lastValueList, newValueList)
		local index = -1;
		local index1 = -1;
		for i = 1, 10 do
			local buwei = const.TranslateIndex[i]
			local last = lastValueList[buwei][2];
			local new = newValueList[buwei][2];
			if new - last > 0 then
				index1 = index1 + 1;
				root:Delay(0.1 * index1, function()
					root:GO("content.LeftContent._EquipGrid.equip"..buwei..".effectObj"):PlayUIEffect(root.gameObject, "qianghuachenggong", 2, function() end, true,false,UIWrapper.UIEffectAddType.Replace);
				end);
			end
			if lastLevelList[i] ~= nil then
				index = index + 1;
				root:Delay(0.7 + 0.1 * index, function()
					local ShowIndex = lastLevelList[i][2];
					local LastLevel = lastLevelList[i][1];
					local buwei = const.TranslateIndex[ShowIndex]
					local enhanceInfo = Bag.enhanceMap[buwei];
					local addLevel = 0;
					if enhanceInfo.level > LastLevel then
						addLevel = 1;
					end
					local grid = gridTab[buwei];
					local image1 = grid:GO("Image1");
					local image2 = grid:GO("Image2");
					local image3 = grid:GO("Image3");

					image1.sprite = "wz_+_qianghua";
					if addLevel > 0 then
						image1.gameObject:SetActive(true);
						image2.gameObject:SetActive(true);
						image3.gameObject:SetActive(true);
						grid:GetComponent("CanvasGroup"):DOFade(1, 0);
						if addLevel < 10 then
							image3.gameObject:SetActive(false);
							image2.sprite = const.QiangHuaLevel[addLevel];
						else
							image2.sprite = const.QiangHuaLevel[math.modf(addLevel/10)];
							image3.sprite = const.QiangHuaLevel[addLevel % 10];
						end
						if sequenceTab[buwei] ~= nil then
							sequenceTab[buwei]:Restart(true);
						end
					end
				end);
			end
		end
	end

	controller.onEquipSelect = function (selectIdx)		
		buwei = selectIdx;		
		local enhanceInfo = Bag.enhanceMap[selectIdx];
		local enhanceTable = client.enhance.getEnhanceTable(selectIdx, enhanceInfo.level);
		updateEquip(selectIdx, enhanceInfo);		
		updateContent(selectIdx);		
		updateCost(enhanceTable);
		updateProgress(selectIdx);
	end

	controller.checkHigh = function(buwei)
		return Bag.getWearEquip(buwei) ~= nil and client.enhance.canEnhanceByIndex(buwei);
	end

	controller.visible = function(visible)
		node.gameObject:SetActive(visible);
		if visible then
			node:GO('EffectObj'):StopAllUIEffects();
			node:GO('Equip'):StopAllUIEffects();
		end
	end

	controller.onUpdate_slow = function()
		for k = 1, #Bag.enhanceMap do
			local equip = Bag.wearList[k];
			local enhanceInfo = Bag.enhanceMap[k];
			local index = -1;
			if equip and enhanceInfo.level > 0 then
				index = index + 1;
				root:Delay(0.7 + 0.1 * index, function() 
					EquipGrid:GO("equip"..k..".cell.enhance").gameObject:SetActive(true);
					EquipGrid:GO("equip"..k..".cell.enhance").text = "强化 +"..enhanceInfo.level; end);
			end
			local flag = controller.checkHigh(k);
			if flag then
				EquipGrid:GO('equip'..k..'.cell._spHigh').gameObject:SetActive(true);
			else
				EquipGrid:GO('equip'..k..'.cell._spHigh').gameObject:SetActive(false);
			end
		end
	end

	BtnEnhance:BindButtonClick(function()
		if client.enhance.enhanceFlag then
			client.enhance.enhance(function()
				controller.onEquipSelect(buwei); 
				onUpdate();
				node:GO('EffectObj'):PlayUIEffect(root.gameObject, "zhuangbeiqianghua1", 3, function() end, true,false,UIWrapper.UIEffectAddType.Replace)
				node:GO('Equip'):PlayUIEffect(root.gameObject, "zhuangbeiqianghua2", 3, function() end, true,false,UIWrapper.UIEffectAddType.Replace)
				EventManager.onEvent(Event.ON_EVENT_EQUIP_CHANGE);
				end,  buwei);
		end
	end);
	BtnAllEnhance:BindButtonClick(function()
		if client.enhance.enhanceAllFlag then
			local enhanceInfoTab = copyTab(Bag.enhanceMap);
			table.sort(enhanceInfoTab, function(equip1, equip2)
				if equip1.level ~= equip2.level then
					return equip1.level < equip2.level;
				else
					return const.BuweiToIndex[equip1.buwei] < const.BuweiToIndex[equip2.buwei];
				end
			  end);
			local firstBuwei = nil;
			local enhanceLevel = nil;

			for i = 1, 10 do
				firstBuwei = enhanceInfoTab[i].buwei;
				enhanceLevel = enhanceInfoTab[i].level;
				local equip = Bag.wearList[firstBuwei];
				if equip ~= nil then
					break;
				end
			end

			client.enhance.enhanceAll(function(lastLevelList, lastValueList, newValueList)
				controller.onEquipSelect(buwei);
				controller.onUpdate_slow();
				handelLeftEffect(lastLevelList, lastValueList, newValueList);
				EventManager.onEvent(Event.ON_EVENT_EQUIP_CHANGE);
				end, firstBuwei, enhanceLevel);
		end
	end);

	return controller;
end


