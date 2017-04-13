function CreateHorseEnhance(ndEnhance, onUpdate, this, wrapper)
	local controller = {};
	local horseTable = nil;
	local horse = nil;
	local Count = 0;
	local effect = wrapper:GO('_svHorse.effect');
	local tfCostMaterial = ndEnhance:GO('ndCost.costinfo.material._tfCostMaterial');
	local spCostMaterial = ndEnhance:GO('ndCost.costinfo.material');
	local btnEnhance = ndEnhance:GO('ndCost._btnEnhance');
	local spFlag = ndEnhance:GO('ndCost._btnEnhance._spFlag');
	local spProgress = ndEnhance:GO('spProgressBg._spProgress');
	local rctProgress = spProgress:GetComponent("RectTransform");
	local tfProgress = ndEnhance:GO('spProgressBg._tfProgress');
	local tfAddProgress1 = ndEnhance:GO('spProgressBg._tfAddProgress1');
	local tfAddProgress2 = ndEnhance:GO('spProgressBg._tfAddProgress2');
	local tfAddProgress3 = ndEnhance:GO('spProgressBg._tfAddProgress3');
	local rt1 = tfAddProgress1:GetComponent("RectTransform");
	local rt2 = tfAddProgress2:GetComponent("RectTransform");
	local rt3 = tfAddProgress3:GetComponent("RectTransform");
	local rtList = {rt3, rt1, rt2};
	local effectAnimation = ndEnhance:GO('spProgressBg._spProgressEffect'):GetComponent("Image");
	local addProgressAnimation = tfAddProgress1.gameObject;
	
	local tfTime = ndEnhance:GO('ndTimer._tfTime');

	local tfCost = ndEnhance:GO('ndCost.costinfo');
	local tfCostPos = tfCost.transform.localPosition;
	local CostDiamond = ndEnhance:GO('ndCost.autoSupplyMaterial');
	local tfCostDiamond = ndEnhance:GO('ndCost.autoSupplyMaterial._tfCostDiamond');
	local spKuang = ndEnhance:GO('ndCost.autoSupplyMaterial._spKuang');
	local spGou = ndEnhance:GO('ndCost.autoSupplyMaterial._spKuang._spGou');
	local spRide = ndEnhance:GO('_spRide');
	local btnRide = ndEnhance:GO('_btnRide');

	local spAdd_1 = tfAddProgress1:GO("_spAdd");
	local spNum1_1 = tfAddProgress1:GO("_spNum1");
	local spNum2_1 = tfAddProgress1:GO("_spNum2");
	local spCheng_1 = tfAddProgress1:GO("_spCheng");
	local spBaoji_1 = tfAddProgress1:GO("_spBaoji");
	local spValue_1 = tfAddProgress1:GO("_spValue")
	local spValue1_1 = tfAddProgress1:GO("_spValue1");
	local spValue2_1 = tfAddProgress1:GO("_spValue2");
	local spAdd__1 = tfAddProgress1:GO("_spAdd_");
	local spNum3_1 = tfAddProgress1:GO("_spNum3");
	local spNum4_1 = tfAddProgress1:GO("_spNum4");

	local spAdd_2 = tfAddProgress2:GO("_spAdd");
	local spNum1_2 = tfAddProgress2:GO("_spNum1");
	local spNum2_2 = tfAddProgress2:GO("_spNum2");
	local spCheng_2 = tfAddProgress2:GO("_spCheng");
	local spBaoji_2 = tfAddProgress2:GO("_spBaoji");
	local spValue_2 = tfAddProgress2:GO("_spValue")
	local spValue1_2 = tfAddProgress2:GO("_spValue1");
	local spValue2_2 = tfAddProgress2:GO("_spValue2");
	local spAdd__2 = tfAddProgress2:GO("_spAdd_");
	local spNum3_2 = tfAddProgress2:GO("_spNum3");
	local spNum4_2 = tfAddProgress2:GO("_spNum4");

	local spAdd_3 = tfAddProgress3:GO("_spAdd");
	local spNum1_3 = tfAddProgress3:GO("_spNum1");
	local spNum2_3 = tfAddProgress3:GO("_spNum2");
	local spCheng_3 = tfAddProgress3:GO("_spCheng");
	local spBaoji_3 = tfAddProgress3:GO("_spBaoji");
	local spValue_3 = tfAddProgress3:GO("_spValue")
	local spValue1_3 = tfAddProgress3:GO("_spValue1");
	local spValue2_3 = tfAddProgress3:GO("_spValue2");
	local spAdd__3 = tfAddProgress3:GO("_spAdd_");
	local spNum3_3 = tfAddProgress3:GO("_spNum3");
	local spNum4_3 = tfAddProgress3:GO("_spNum4");

	local spAddTab = {spAdd_1, spAdd_2, spAdd_3};
	local spNum1Tab = {spNum1_1, spNum1_2, spNum1_3};
	local spNum2Tab = {spNum2_1, spNum2_2, spNum2_3};
	local spChengTab = {spCheng_1, spCheng_2, spCheng_3};
	local spBaojiTab = {spBaoji_1, spBaoji_2, spBaoji_3};
	local spValueTab = {spValue_1, spValue_2, spValue_3};
	local spValue1Tab = {spValue1_1, spValue1_2, spValue1_3};
	local spValue2Tab = {spValue2_1, spValue2_2, spValue2_3};
	local spAdd_Tab = {spAdd__1, spAdd__2, spAdd__3};
	local spNum3Tab = {spNum3_1, spNum3_2, spNum3_3};
	local spNum4Tab = {spNum4_1, spNum4_2, spNum4_3};

	local tfAddProgressPos = tfAddProgress1.transform.localPosition;
	local tfAddProgressTab = {tfAddProgress1, tfAddProgress2, tfAddProgress3}
	local delayID;

	local sequence1 = DG.Tweening.DOTween.Sequence();
	local sequence2 = DG.Tweening.DOTween.Sequence();
	local sequence3 = DG.Tweening.DOTween.Sequence();

	local sequenceList = {sequence3, sequence1, sequence2};

	for i = 1, 3 do
		sequenceList[i]:Append(tfAddProgressTab[i].transform:DOLocalMoveY(tfAddProgressPos.y + 50, 1, false));
		sequenceList[i]:AppendInterval(0.5);
		sequenceList[i]:Join(tfAddProgressTab[i]:GetComponent("CanvasGroup"):DOFade(0, 0.5));
		-- sequenceList[i]:Join(tfAddProgressTab[i].transform:DOLocalMoveY(tfAddProgressPos.y + 25, 0.5, false));
		sequenceList[i]:SetAutoKill(false);
	end
	local fadeFunc = function (mul)
		if sequenceList[Count%3+1] ~= nil then
			sequenceList[Count%3+1]:Restart(true);
		end
	end

	local function updateAddProgress(critical)
		local mul = critical[1];
		local add = critical[2];
		spNum1Tab[Count%3+1].gameObject:SetActive(false);
		spNum2Tab[Count%3+1].gameObject:SetActive(false);
		spAddTab[Count%3+1].gameObject:SetActive(false);
		spBaojiTab[Count%3+1].gameObject:SetActive(false);
		spChengTab[Count%3+1].gameObject:SetActive(false);
		spValue1Tab[Count%3+1].gameObject:SetActive(false);
		spValue2Tab[Count%3+1].gameObject:SetActive(false);
		spAdd_Tab[Count%3+1].gameObject:SetActive(false);
		spNum3Tab[Count%3+1].gameObject:SetActive(false);
		spNum4Tab[Count%3+1].gameObject:SetActive(false);
		tfAddProgressTab[Count%3+1].transform.localPosition = tfAddProgressPos;
		if mul > 1 then

			if math.modf(add/10) == 0 then
				spNum1Tab[Count%3+1].sprite = const.baoji_icon[add%10];
				-- spNum2Tab[Count%3+1].gameObject:SetActive(false);
				spValueTab[Count%3+1].sprite = const.baoji_icon[mul];
			else
				spNum2Tab[Count%3+1].gameObject:SetActive(true);
				spNum1Tab[Count%3+1].sprite = const.baoji_icon[math.modf(add/10)];
				spNum2Tab[Count%3+1].sprite = const.baoji_icon[add%10];
			end
			if math.modf(mul/10) == 0 then
				-- spValue2Tab[Count%3+1].gameObject:SetActive(false);
				spValue1Tab[Count%3+1].sprite = const.baoji_icon[mul];
			else
				spValue2Tab[Count%3+1].gameObject:SetActive(true);
				spValue1Tab[Count%3+1].sprite = const.baoji_icon[math.modf(mul/10)];
				spValue2Tab[Count%3+1].sprite = const.baoji_icon[mul%10];
			end
			spNum1Tab[Count%3+1].gameObject:SetActive(true);
			spAddTab[Count%3+1].gameObject:SetActive(true);
			spBaojiTab[Count%3+1].gameObject:SetActive(true);
			spChengTab[Count%3+1].gameObject:SetActive(true);
			spValue1Tab[Count%3+1].gameObject:SetActive(true);

			spAddTab[Count%3+1]:GetComponent("Image"):DOFade(1, 0);
			spNum1Tab[Count%3+1]:GetComponent("Image"):DOFade(1, 0);
			spNum2Tab[Count%3+1]:GetComponent("Image"):DOFade(1, 0);
			spBaojiTab[Count%3+1]:GetComponent("Image"):DOFade(1, 0);
			spChengTab[Count%3+1]:GetComponent("Image"):DOFade(1, 0);
			spValue1Tab[Count%3+1]:GetComponent("Image"):DOFade(1, 0);
			spValue2Tab[Count%3+1]:GetComponent("Image"):DOFade(1, 0);
		else
			if math.modf(add/10) == 0 then
				-- spNum4Tab[Count%3+1].gameObject:SetActive(false);
				spNum3Tab[Count%3+1].sprite = const.baoji_icon[add%10];
			else
				spNum4Tab[Count%3+1].gameObject:SetActive(true);
				spNum3Tab[Count%3+1].sprite = const.baoji_icon[math.modf(add/10)];
				spNum4Tab[Count%3+1].sprite = const.baoji_icon[add%10];
			end
			spNum3Tab[Count%3+1].gameObject:SetActive(true);
			spAdd_Tab[Count%3+1].gameObject:SetActive(true);

			spAdd_Tab[Count%3+1]:GetComponent("Image"):DOFade(1, 0);
			spNum3Tab[Count%3+1]:GetComponent("Image"):DOFade(1, 0);
			spNum4Tab[Count%3+1]:GetComponent("Image"):DOFade(1, 0);
		end
		fadeFunc(mul);
		-- if delayID then
		-- 	this:CancelDelay(delayID);
		-- end
		-- delayID = this:Delay(1, fadeFunc);
		
	end

	local function updateProgress(progressObj, first)		
		local progress = (getServerDayIndex(5, 0, 0) > progressObj[1]) and 0 or progressObj[2];
		tfProgress.text = "祝福值"..progress .."/100";
		local size = rctProgress.sizeDelta;
		size.x = progress *8.32;
		rctProgress.sizeDelta =size;
		if first then
			return
		end
		effectAnimation:DOFade(1, 0.15)
		this:Delay(0.25, function ()
			effectAnimation:DOFade(0, 0.3)
		end)
		spProgress:PlayUIEffect(ndEnhance.gameObject, "jindutiao", 0.3, function (go)	
			go.transform.localPosition = Vector2.New((progress / 100 * 832), 0);
			-- go.transform.anchoredPosition = Vector2.New((progress / 100 - 0.5) * 737, 0);			
		end, true);
	end

	function controller.UpdateTime()
		local dayTime = (TimerManager.GetServerNowMillSecond()/1000 + 3600 * 8) % 86400;
		local diff = 5 * 3600 - dayTime;
		if diff < 0 then
			diff = diff + 86400;
		end
		local hour = math.floor(diff / 3600);
		local minite = math.floor((diff % 3600) / 60);
		local second = math.floor(diff % 60);
		
		if minite < 10 then
			minite = "0" ..minite;
		end

		if second < 10 then
			second = "0" ..second;
		end
		
		tfTime.text = string.format("%s:%s:%s", hour, minite, second);
		if diff == 0 then			
			updateProgress(horse.progress, true);
		end
	end

	local function updateAuto(horseTable, horse)		
		spGou.gameObject:SetActive(client.horse.ui_auto_enhance);
		if client.horse.ui_auto_enhance then
			local trainTable = tb.horseTrainTable[horse.enhance_lv];			
			local count = Bag.GetItemCountBysid(trainTable.enhance_cost_material);
			local cost = trainTable.enhance_cost_count;
			tfCostDiamond.gameObject:SetActive(true);
			tfCostDiamond.text = (cost - count) * trainTable.enhance_material_diamond;
		else
			tfCostDiamond.gameObject:SetActive(false);
		end
	end

	spKuang:BindButtonClick(function ()
		client.horse.ui_auto_enhance = not client.horse.ui_auto_enhance;
		spGou.gameObject:SetActive(client.horse.ui_auto_enhance);
		updateAuto(horseTable, horse);
	end)

	local function updateCost()
		local trainTable = tb.horseTrainTable[horse.enhance_lv];
		local count = Bag.GetItemCountBysid(trainTable.enhance_cost_material);
		if count < trainTable.enhance_cost_count then
			tfCost.transform.localPosition = tfCostPos;
			CostDiamond.gameObject:SetActive(true);
		else
			tfCost.transform.localPosition = Vector3.New(tfCostPos.x + 260 , tfCostPos.y, tfCostPos.z);
			CostDiamond.gameObject:SetActive(false);
		end
		tfCostMaterial.text = client.tools.formatColor(count, const.color.red, count, trainTable.enhance_cost_count).. "/" .. trainTable.enhance_cost_count;
		updateAuto(horseTable, horse);
	end


	function controller.Show(_horseTable, _horse)
		horseTable = _horseTable;
		horse = _horse;
		ndEnhance.gameObject:SetActive(true);
		updateCost(horseTable, horse);
		updateProgress(horse.progress, true);
		controller.UpdateTime();
		initRide(spRide, btnRide, horseTable.sid, horse.enhance_lv >= horseTable.ride_enhance, onUpdate);
		spCostMaterial:UnbindAllButtonClick();
		spCostMaterial:BindButtonClick(function () 
			local param = {bDisplay = true, index = i, sid = tb.horseTrainTable[horse.enhance_lv].enhance_cost_material};
			PanelManager:CreateConstPanel('ItemFloat',UIExtendType.BLACKCANCELMASK,param);
		end);
	end

	local function onEnhanceClick()
		local trainTable = tb.horseTrainTable[horse.enhance_lv];
		local count = Bag.GetItemCountBysid(trainTable.enhance_cost_material);
		local cost = trainTable.enhance_cost_count;
		local enhanceCb = function (success, critical)
			if success then
				-- 坐骑进阶成功,等级提升,检查菜单界面红点
				EventManager.onEvent(Event.ON_HORSE_UNLOCK_OR_CANUPGRADE);
				updateProgress({horse.progress[1], 100});
				effect:PlayUIEffect(wrapper.gameObject, "jinjiechenggong", 3.5);	
				this:Delay(1, onUpdate);
				--进阶达到最高阶级 更新坐骑 显示坐骑特效
				local player = DataCache.me;
				if player ~= nil then
					local ac = player:GetComponent('AvatarController');
					local bShowMaxEffect = client.horse.isMaxEnhance(horse)
					if bShowMaxEffect == true then
						ac:LuaLoadHorse(horse.sid, true);
					end
				end
			else
				updateProgress(horse.progress);
				Count = Count + 1;
				updateAddProgress(critical);
			end
		end

		if count >= cost then
			client.horse.enhance(enhanceCb, horse.sid, cost);
		else
			if client.horse.ui_auto_enhance then
				local diamond = (cost - count) * trainTable.enhance_material_diamond;			
				if DataCache.role_diamond < diamond then
					ui.showCharge();
					return;
				else
					client.horse.enhance(enhanceCb, horse.sid, count);
				end
			else				
				ui.showMsg("兽魂不足");
			end
		end
	end

	-- function controller.updateFlag()
	-- 	local flag = client.horse.checkCouldEnhance(horse);
	-- 	spFlag.gameObject:SetActive(flag);
	-- 	return flag;
	-- end

	function controller.onItemChange()
		updateCost();
		-- controller.updateFlag();
	end

	function controller.updateRolePos(node, last ,now)
		if last == now then
			node.transform:DOLocalMove(Vector3.New(50, 0, 0), 1, false);
		else
			node.transform:DOLocalMove(Vector3.New(50, 0, 0), 0, false);
		end
	end

	btnEnhance:BindButtonClick(onEnhanceClick);

	function controller.Hide()
		ndEnhance.gameObject:SetActive(false);
	end

	return controller;
end
