function CreateEnhanceCtrl()
	local ctrl = {};
	local lastEnhanceBuwei;
	local lastEnhanceCB;
	local getEnhanceCB;
	local allenhance;
	ctrl.enhanceFlag = true;
	ctrl.enhanceAllFlag = true;
	ctrl.valueList = nil;
	local getEnhanceTable = function (index, level) 
		return  tb.GetTableByKey(tb.EnhanceTable, {DataCache.myInfo.career, index, level});		
	end

	function ctrl.canEnhance()
		for i = 1, #Bag.enhanceMap do
			return ctrl.canEnhanceByIndex(i);
		end
		return false;
	end
	
	function ctrl.canEnhanceByIndex(index)
	 	local enhanceInfo = Bag.enhanceMap[index];		
		local enhanceTable = getEnhanceTable(index, enhanceInfo.level);
		local value = DataCache.myInfo.level >= 8 and DataCache.myInfo.level >= enhanceTable.need_level;
		return value and ctrl.CanEnhanceLevelUp(index, enhanceInfo.level);
	end

	ctrl.getValueList = function(cb)
		local msg = {cmd = "get_value_list"};
		Send(msg, function(reply)
			if reply["type"] == "success" then
				ctrl.valueList = reply["valueList"];
				cb();
			end
		end);
	end

	local onEnhance = function(msgTable)
		if msgTable.type == "success" then
			Bag.enhanceMap[lastEnhanceBuwei].level = msgTable.level;
			AudioManager.PlaySoundFromAssetBundle("enhance_equip");
			local total = msgTable["total"];
			local this = msgTable["this"];
			local newlist = msgTable["newList"];
			local value = msgTable["value"];
			ctrl.valueList = newlist;
			if this >= total then
				local image = "dk_zhongyaoxinxiqu_2";
				local color = Color.New(255/255, 255/255, 143/255);
				ui.showMsg("强化等级提高", image, color)
			end
			lastEnhanceCB();
		else 
			ui.showMsg("强化失败!");
		end
		ctrl.enhanceFlag = true;
	end

	local onEnhanceAll = function(msgTable)
		if msgTable.type == "success" then
			local lastLevelList = msgTable["oldlist"];
			local newLevelList = msgTable["newlist"];
			local lastValueList = msgTable["oldValue"];
			local newValueList = msgTable["newValue"];
			for i = 1, #newLevelList do
				local showIndex = newLevelList[i][2];
				Bag.enhanceMap[const.TranslateIndex[showIndex]].level = newLevelList[i][1];
			end
			local image = "dk_zhongyaoxinxiqu_2";
			local color = Color.New(255/255, 255/255, 143/255);
			ctrl.valueList = newValueList;
			ui.showMsg("强化成功", image, color);
			allenhance(lastLevelList, lastValueList, newValueList);
		else
			ui.showBuyMoney();		
		end
		ctrl.enhanceAllFlag = true;
	end

	-- ctrl.enhance = function(buwei)
	-- 	return true;
	-- end
	local onGetEhanceProgress = function(reply)
		if reply.type == "success" then
			local value = reply["value"];
			local totalValue = reply["total"];
			getEnhanceCB(value, totalValue);
		end
	end

	ctrl.enhance = function(cb, buwei)
		local enhanceInfo = Bag.enhanceMap[buwei];
		local enhanceTable = getEnhanceTable(buwei, enhanceInfo.level);		
		if enhanceInfo.level >= 99 then
			ui.showMsg("强化已达上限");
			return;
		end
		if DataCache.myInfo.level < enhanceTable.need_level then
			ui.showMsg("当前已强化至上限");
			return;
		else
			if DataCache.role_money < enhanceTable.need_money then
				ui.showBuyMoney()
				return;
			else
				ctrl.enhanceFlag = false;
				--消耗相应的强化物品,实现强化效果, 充当强化石强化装备
				local msg = {cmd = "slot/enhance", buwei = buwei};
				lastEnhanceBuwei = buwei;
				lastEnhanceCB = cb;
				Send(msg, onEnhance);
			end
		end
	end

 	ctrl.enhanceAll = function(cb, firstBuwei, enhanceLevel)
 		local miniNeedLevel = 100;
 		local enhanceMinLevel = 100;
 		for i = 1, #Bag.enhanceMap do
 			local equip = Bag.wearList[i];
 			if equip then
				local enhanceInfo = Bag.enhanceMap[i];
				local enhanceTable = getEnhanceTable(i, enhanceInfo.level);	
				if enhanceMinLevel > enhanceInfo.level then
					enhanceMinLevel = enhanceInfo.level;
				end
				if miniNeedLevel > enhanceTable.need_level then
					miniNeedLevel = enhanceTable.need_level;
				end
			end
		end
		if DataCache.myInfo.level < miniNeedLevel then
			ui.showMsg("当前已强化至上限");
			return;
		end
		if enhanceMinLevel >= 99 then
			ui.showMsg("强化已达上限");
			return;
		end
		if DataCache.role_money < getEnhanceTable(firstBuwei, enhanceLevel).need_money then
			ui.showBuyMoney();
			return;
		end

		if client.enhance.CanEnhanceLevelUp(firstBuwei, enhanceLevel) then
			client.enhance.enhanceAllFlag = false;
			local msg = {cmd = "all/enhance", continue_enhance = 0};
			allenhance = cb;
			Send(msg, onEnhanceAll);
		else
			ui.showMsgBox(nil, "当前金币数量不足以提升强化等级，是否继续强化？",function()
				client.enhance.enhanceAllFlag = false;
			    local msg = {cmd = "all/enhance", continue_enhance = 1};
				allenhance = cb;
				Send(msg, onEnhanceAll);
			end, nil);
		end
	end

	ctrl.getEnhanceTable = function (index, level) 
		return tb.GetTableByKey(tb.EnhanceTable, {DataCache.myInfo.career, index, level});		
	end

	ctrl.getEnhancePoint = function (cb, index)
		local msg = {cmd = "get_enhance_value", buwei = index};
		getEnhanceCB = cb;
		Send(msg, onGetEhanceProgress);
	end

	ctrl.getValue = function (buwei, enhanceLevel, value, total)
		local allValue = 0;
		local money = DataCache.role_money;
		local enhanceTable = client.enhance.getEnhanceTable(buwei, enhanceLevel)
		local enhanceAdd = enhanceTable.enhance_add;
		local needMoney = enhanceTable.need_money;
		local needLevel = enhanceTable.need_level;
		local totalValue = enhanceTable.enhance_total;
		local newValue = value;
		while true do
			if newValue >= total then
				return true;
			else
				if money < needMoney then
					break;
				else
					newValue = newValue + enhanceAdd;
					money = money - needMoney;
				end
			end
		end
		return false;
	end

	ctrl.getTotalValue = function (buwei, enhanceLevel)
		local totalValue = 0;
		for i = 0, enhanceLevel do
			local enhanceTable = client.enhance.getEnhanceTable(buwei, i)
			totalValue = totalValue + enhanceTable.enhance_total;
		end
		return totalValue;
	end

	ctrl.CanEnhanceLevelUp = function(buwei, enhanceLevel)
		local flag = false;
		if ctrl.valueList ~= nil then
			local value = ctrl.valueList[buwei][2];
			local totalValue = ctrl.getTotalValue(buwei, enhanceLevel);
			flag = ctrl.getValue(buwei, enhanceLevel, value, totalValue);
		end
		return flag;
	end

	return ctrl;
end
client.enhance = CreateEnhanceCtrl();



