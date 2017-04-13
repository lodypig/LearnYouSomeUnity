Bag = 1
function BagCtrl()
	Bag = {};
	local itemBag = {};
	local showItemList = {};
	local showEquipList = {};	

	Bag.itemCountMap = {};
	Bag.wearList = {}
	Bag.cdMap = {};
	Bag.enhanceMap = {};
	Bag.BrokenMap = {};	--管理已经损坏的装备
	local betterEquipList = {};	--记录当前可穿戴的比身上好的最好的装备

    function  Bag.canWear(equip)
		if DataCache.myInfo.career ~= equip.career then
			ui.showMsg("职业不符，无法穿戴");
			return false
		end
		if DataCache.myInfo.level < equip.level then
			ui.showMsg("等级不足，无法穿戴");
			return false
		end
		local onEquip = Bag.wearList[equip.buwei];
		if onEquip ~= nil and onEquip.recoveryTime>0 then
			ui.showMsg("装备修复中，无法更换");
			return false
		end

		return true;
	end

    local function getItemWeight(item)
        local itemTInfo = tb.ItemTable[item.sid];        
        return const.showTypeSortWeight[itemTInfo.show_type] + itemTInfo.priority;
    end
    
    local function caleSortWeight() 
        local caledList = {};
        local weightValue;
        local item;
        for i = 1,itemBag.limitSize do
            weightValue = 0;
            item = itemBag.list[i];
            if nil ~= item then
                if item.type == const.bagType.item then
                    weightValue = getItemWeight(item);
                elseif item.type == const.bagType.equip then
                    weightValue = client.equip.getSortWeight(item);
                elseif item.type == const.bagType.gem then
                    weightValue = client.gem.getSortWeight(item, true);
                end
            end
            caledList[i] = {weight = weightValue, pos = i};
        end
        return caledList
    end
    
    --整理背包  前台整理将整理需要调整的顺序发给后台 后台只做换位置的操作
    local lastClearBagTime = 0;
    local clearBagCDTime = 5;
	function  Bag.clearUpBag(checkFlag)
		if checkFlag then
			local NowTime = TimerManager.GetServerNowMillSecond();
	        if (NowTime - lastClearBagTime) < clearBagCDTime then
	            ui.showMsg("操作过于频繁，请稍后再试");
	            return;
        	end
        	lastClearBagTime = NowTime;
		end
        local caledList = caleSortWeight();
        local msgList = {};
        table.sort(caledList, function(item1, item2) return (item1.weight > item2.weight) or ((item1.weight == item2.weight) and (item1.pos < item2.pos)) end);
        --pos表示它原来的位置，现在的index表示当前的位置，不同表示位置发生变化，msgList的index表示位置，value为0表示没变，有值表示变化并且value为老的位置
        for j= 1, #caledList do           
            if caledList[j].pos ~= j then
                msgList[j] = caledList[j].pos;
            else
                msgList[j] = 0;
            end
        end
        local msg = {cmd = "bag/rerange",rangeInfo = msgList}
		Send(msg, function() 
			if checkFlag then
				ui.showMsg("背包整理成功") 
			end
		end);
	end


    --解锁背包格子
    function  Bag.openCell(count)
		local msg = {cmd = "bag/open_cell", count = count}
		Send(msg);
	end


    function  Bag.wear(equip)
		local msg = {cmd = "equipment/put_on",bag_index = equip.pos}
		Send(msg, Bag.UpdateAppearance);
	end

	function Bag.InitBag()
		Bag.getItemBag(nil);
	end
	function Bag.getItemBag (callback)
		local msg = {cmd = "get_warehouse", bag_type = "bag"};
		Send(msg, function (msgTable)
			Bag.parseBag(msgTable["maxSize"], msgTable["limitSize"], msgTable["itemList"], msgTable["gem"]);
			if callback ~= nil then
				callback();
			end
		end);
	end

	function Bag.InitWearList()
		local msg = {cmd = "equipment/list_all"};
		Send(msg, Bag.parseEquipmentNet);
	end

	--装备清除
    function Bag.clearnBetterEquip(oldEquip)
        if 0 ~= oldEquip and "none" ~= oldEquip and nil ~= oldEquip then
            Bag.deleteBetterEquip(oldEquip)
            UIManager.GetInstance():CallLuaMethod('UpEquipment.clearEquip', oldEquip);
        end

    end

	--获取指定部位可装备的最好的装备
	function Bag.getEquipBetter(buwei)
		local data = itemBag.list;
		local equip = nil;
        for i,v in pairs(data) do
        	if v and v ~= 0 and v ~= "none" and v.type == const.bagType.equip then
        		if v.buwei == buwei then
        			if Bag.isBetterCanPutOn(equip, v) then
                        equip = v;
                    end
        		end
        	end
        end
        return equip;
	end

	function Bag.haveBetterEquip(buwei)
		for i=1, #betterEquipList do
			if betterEquipList[i].buwei == buwei then
				return true;
			end
		end

		return false;
	end

	function Bag.deleteBetterEquip(equip)
		local list = {};
		for i=1, #betterEquipList do
			if betterEquipList[i].id ~= equip.id then
				list[#list + 1] = betterEquipList[i];
			end
		end
		betterEquipList = list;
	end

    function Bag.handleEquipBetter()
    	local temEquip = {};
    	for i=1, #const.BuWei do
    		if not Bag.haveBetterEquip(i) then
	    		local wearEquip = Bag.getWearEquip(i);
	    		local equip = Bag.getEquipBetter(i);

	    		if 0 == wearEquip or nil == wearEquip or "none" == wearEquip or wearEquip.level < 20 then
	    			if equip ~= nil and Bag.isBetterCanPutOn(wearEquip, equip) then	
	    				-- print("ShowUpEquipment:"..i);    	
	    				temEquip[#temEquip + 1] = equip;			
	    				betterEquipList[#betterEquipList + 1] = equip;  			
	    			end
	    		end
	    	end
    	end
    	if #temEquip > 0 then
    		ShowUpEquipment(temEquip);
    	end
    end

	--当升级的时候 重新获取需要提示的装备并都给提示
    function Bag.handlelevelUpBetter()
        Bag.handleEquipBetter();
    end


	function Bag.parseEquipment(equipment)
		local equipSample = equipment[2];	
		local equipList = equipSample[1];
		
		local data = Bag.wearList;
		for i = 1, #equipList do
			local item = equipList[i];
			if 0 == item then
				data[i] = nil;
			else
				data[i] = client.equip.parseEquip(item);
				data[i].pos = i;
				
				if data[i].recoveryTime ~= 0 then
					local item = {type = 1,index = i,time = data[i].recoveryTime};
					table.insert(Bag.BrokenMap,item);
				end
			end
		end
		local temp = equipSample[2];
		temp = temp[1];		
		local enhanceList = temp[2];
		Bag.parseEnhanceSlot(enhanceList);
		--有损坏中的装备，检查是否有装备
		
		-- if #Bag.BrokenMap ~= 0 then
		-- 	--Bag.CheckBrokenEquip();
		-- end
	end

	local function UpdateBorkenMap(msgTable)
		local equip_type = msgTable["equip_type"];
		local equip_index = msgTable["equip_index"];
		local cost_money = msgTable["cost_money"];
		local equiplist = nil;
	
		--恢复对应的装备
		if equip_type == 1 then
			equiplist = Bag.wearList;
		elseif equip_type == 2 then
			equiplist = itemBag.list;
		else
			return;
		end
		local equip = equiplist[equip_index];
		equip.recoveryTime = 0;
		--发出一个事件通知UI更新
		if equip_type == 1 then
			EventManager.onEvent(Event.ON_EVENT_WEAREQUIP_CHANGE);
		else
			EventManager.onEvent(Event.ON_EVENT_EQUIP_CHANGE);
		end

		for i=1,#Bag.BrokenMap do
			if Bag.BrokenMap[i].type ==  equip_type then
				if Bag.BrokenMap[i].index == equip_index then
					table.remove(Bag.BrokenMap,i);
					if #Bag.BrokenMap == 0 then
						MainUI.HideRepairIcon();
					end
					return;
				end
			end
		end
	end

	--local item = {type = 1,index = i,time = data[i].recoveryTime};
	function Bag.CheckBrokenEquip()		
		if #Bag.BrokenMap == 0 then
			return;
		end
		local nowSecond = math.round(TimerManager.GetServerNowMillSecond()/1000);
		for i=#Bag.BrokenMap,1,-1 do
			local item = Bag.BrokenMap[i];
			--装备自动恢复时间到了，给服务端发消息
			if nowSecond >= item.time then
				local msg = {cmd = "equip_recover",equip_type = item.type, index = item.index}
				Send(msg, Bag.UpdateBorkenMap);
			end
		end
	end

	

	function Bag.parseEquipmentNet(msgTable)
		-- 装备的索引是从0 开始的
		Bag.parseEquipment(msgTable["equipment"]);
	end

	Bag.parseEnhanceSlot = function (enhanceList)		
		local info;
		for i = 1, #enhanceList do
			local slot = {};
			info = enhanceList[i];
			slot.buwei = info[1];
			slot.level = info[2];		
			Bag.enhanceMap[slot.buwei] = slot;
		end
	end

	function Bag.getBagGridCount()
		if itemBag == nil then
			return 0;
		end
		if itemBag.limitSize == nil then
			return 0;
		end
		if itemBag.count == nil then
			return 0;
		end
		return itemBag.limitSize - itemBag.count;
	end

	local function rawParseItem(item)		
		local itemData  = {}
		itemData.sid = item[1];
		local tmp = item[2];
		itemData.count = tmp[1];

		itemData.id = tmp[2];		
		itemData.quality = tb.ItemTable[itemData.sid].quality;		
		return itemData;		
	end

	local function addItemCount(sid, count)
		if Bag.itemCountMap[sid] then
			Bag.itemCountMap[sid] = Bag.itemCountMap[sid] + count;
		else
			Bag.itemCountMap[sid] = count;
		end
	end

	local function updateItemCount(new, old)
		local oldCount = Bag.itemCountMap[new.sid] or 0;
		addItemCount(new.sid, new.count);		
		if old and old.type == const.bagType.item then
			addItemCount(old.sid, -old.count);			
		end
		return Bag.itemCountMap[new.sid] - oldCount;
	end

	local function parseItem(item, old)		
		local itemData = rawParseItem(item)
		itemData.type = const.bagType.item;
		local change = updateItemCount(itemData, old);
		return itemData, change;		
	end

	local function removeCount(old)
		if old == nil then
			return;
		end

		if old and old.type == const.bagType.gem then
			client.gem.remove(old)
		end

		if old and old.type == const.bagType.item then
			addItemCount(old.sid, -old.count);
		end
	end

	function Bag.parse(item, old)
		local sid = item[1];
		if tb.ItemTable[sid] then
			if old and old.type ~= const.bagType.item then
				removeCount(old);
			end 
			return parseItem(item, old);
		elseif tb.EquipTable[sid] then
			if old then
				removeCount(old);
			end
			local newEquipInfo, nowCount = client.equip.parseEquip(item)
			local changeCount = nowCount
			if old and newEquipInfo.sid == old.sid and newEquipInfo.quality == old.quality then
				changeCount = changeCount - old.count
			end
 
			return newEquipInfo, changeCount;
		elseif tb.GemTable[sid] then
			if old and old.type ~= const.bagType.gem then
				removeCount(old);
			end 
			return client.gem.parse(item, true, old);		
		end
	end


--判断一个equip2是不是比equip1更好并且可以穿戴
    Bag.isBetterCanPutOn = function (equip1, equip2) 
		if equip2.quality == const.quality.unidentify then
			return false
		end

		if equip2.career == DataCache.myInfo.career and DataCache.myInfo.level >= equip2.level then
            if 0 == equip1 or nil == equip1 then
                return true;
            end

            if equip1.recoveryTime > 0 then
            	return false;
            end

            if equip1.level == equip2.level then
            	return equip1.quality < equip2.quality;
            else
				return equip1.level < equip2.level;
			end
		end
		return false;
	end


	function Bag.isBagFull()
		if itemBag == nil then
			return false;
		end
		if itemBag.count == nil then
			return false;
		end
		if itemBag.limitSize == nil then
			return false;
		end
		return itemBag.count >= itemBag.limitSize;
	end

	--背包是否还能再放下某类或者某种物品
	function Bag.canAddItem(type, sid)
		if type == "gold_icon" or type == "diamond_icon" then
			return true
		end
		-- print("Bag.canAddItem")
		-- print(type)
		-- print(sid)
		--先判断格子够不够
		local lastGridCount = Bag.getBagGridCount()
		-- print("grid count")
		-- print(lastGridCount)
		if lastGridCount <= 0 then
			return false
		end
		--附带sid 且为可叠加装备再判断是否可以与其他格子合并
		if sid ~= nil then
			--在包裹中找到相同sid的格子 比较其数量是否上限
			-- print("judge sid")
			if Bag.GetMergeItemBytid(sid) then
				-- print("true!")
				return true
			end
		end
		-- print("true!")
		return true
	end

	function Bag.isBagHeavy()
		if itemBag == nil then
			return false;
		end
		if itemBag.count == nil then
			return false;
		end
		if itemBag.limitSize == nil then
			return false;
		end	
		return itemBag.count >= 0.9 * itemBag.limitSize;
	end

	function Bag.attrSortFunc(v1, v2)
		return const.ATTR_PRIORTY[v1[1]] > const.ATTR_PRIORTY[v2[1]];
	end

	function Bag.parseBag(maxSize, limitSize, itemlists, gemList)
		local  data  = nil
		local parseFunc;		
		client.gem.onEquipGem(gemList);
	
		itemBag.maxSize = maxSize;
		itemBag.limitSize = limitSize;
		itemBag.list = {};
		itemBag.count = 0;
	
		-- 背包的索引是从1开始的
		for i = 1, #itemlists do
			local item = itemlists[i];
			if type(item) == "number" then
				itemBag.list[i] = nil;
			else
				local sid = item[1];
				itemBag.list[i] = Bag.parse(item);
				if itemBag.list[i] ~= nil then
                    if const.bagType.equip == itemBag.list[i].type then
                        client.equip.AddIdentifyBiaoshi(itemBag.list[i]);
                    end
				    
					if itemBag.list[i].recoveryTime and itemBag.list[i].recoveryTime ~= 0 then
						local item = {type = 2,index = i,time = itemBag.list[i].recoveryTime};
						table.insert(Bag.BrokenMap,item);
					end		
					itemBag.count = itemBag.count + 1;
					-- 在背包中的实际位置 这个物品
					itemBag.list[i].pos = i;
				end
			end
		end
	
		if #Bag.BrokenMap ~= 0 then
			Bag.CheckBrokenEquip();
		end
		if MainUI.OnBagChange then
			MainUI.OnBagChange();
		end
	
		Bag.handleEquipBetter();
	
	end
		
--  物品排序
	local function itemSortFunc(item1, item2)
		if tb.ItemTable[item1.sid].priority == tb.ItemTable[item2.sid].priority then
			return tb.ItemTable[item1.sid].level > tb.ItemTable[item2.sid].level;
		end
		return tb.ItemTable[item1.sid].priority < tb.ItemTable[item2.sid].priority;
	end
	
--  生成显示列表
	local function genShowList(list, sortFunc, type, filterFunc)
		local showList = {};
		if list == nil then
			list = {};
		end
		for i,v in pairs(list) do
			if v and v ~= 0 and v ~= "none" and v.type == type then
				if not filterFunc or filterFunc(v) == true then
					showList[#showList + 1] = v;
				end
			end
		end		
		if #showList == 1 then 
			if type == const.bagType.equip then
				client.equip.AddIdentifyBiaoshi(showList[1]);
			end
		else
			table.sort(showList, sortFunc);
		-- else
		-- 	client.equip.AddIdentifyBiaoshi(showList[1]);
		end
		return showList;
	end

	function Bag.GetAllItem()
		return itemBag.list;
	end

    function Bag.GetShowItem()
		showItemList =  genShowList(itemBag.list, itemSortFunc, const.bagType.item);
		return showItemList;
	end

	function Bag.GetShowEquip(sortFunc)
		if sortFunc == nil then
			sortFunc = client.equip.sortFunc;
		end
		showEquipList = genShowList(itemBag.list, sortFunc, const.bagType.equip);
		return showEquipList;
	end

	function Bag.GetShowGem(buwei)
		local showGemList;
		if buwei then
			local type = tb.EquipGemTable[buwei];
			showGemList = genShowList(itemBag.list, client.gem.sortFunc, const.bagType.gem, function(v) 
				return tb.GemTable[v.sid].gem_type == type;
			end);
		else
			showGemList = genShowList(itemBag.list, client.gem.sortFunc, const.bagType.gem);
		end
		
		return showGemList;
	end

	function Bag.GetShow(Type)
		if Type == const.bagType.item then
			return Bag.GetShowItem();
		elseif Type == const.bagType.equip then
			return Bag.GetShowEquip();
		elseif Type == const.bagType.gem then
			return Bag.GetShowGem();
		end
	end


	function Bag.updateBag(eventData, addIdList, IsShowMsg, limitSize)
		if eventData == nil then
			return;
		end
		local data = itemBag;
        if limitSize then
            data.limitSize = limitSize;
        end
		for i = 1, #eventData do
			local rawData = eventData[i];
			local index  = rawData[1];
			local item   = rawData[2];
			--更新数量
			if 	data.list[index] ~= nil and 0 == item then
				data.count = data.count - 1;
			elseif data.list[index] == nil and 0 ~= item then
				data.count = data.count + 1;
			end
            --位置如果之前有东西，先把对应的物品计数去掉
            local oldCount = 0;
            local oldData = data.list[index];
            if oldData then			    			    
                
                if oldData.type == const.bagType.equip then
            		Bag.clearnBetterEquip(oldData);
                end
            end
			if 0 == item then
				if oldData then
					if oldData.type == const.bagType.item then
	                	Bag.itemCountMap[oldData.sid] = Bag.itemCountMap[oldData.sid] - oldData.count;
	                end
	                if oldData.type == const.bagType.gem then
	                	client.gem.remove(oldData);
	                end
            	end
				data.list[index] = nil;
			else				
				local iteminfo, changeCount = Bag.parse(item, data.list[index]);
                if const.bagType.equip == iteminfo.type then
                        client.equip.AddIdentifyBiaoshi(iteminfo);
                    end
                data.list[index] = iteminfo;
				data.list[index].pos = index;
				--tip
				--addIdList 则做"你获得了..."的提示,如果== all,说明获得了全部
				
					
					if addIdList == "all" or 
						(addIdList ~= nil and #addIdList > 0 and tableContains(addIdList, index)) then	
						local type = "item";
						local table = tb.ItemTable[iteminfo.sid]
						local str = ""
						if table == nil then
	                        table = tb.GemTable[iteminfo.sid]
	                    end
	                    if table == nil then
							table = tb.EquipTable[iteminfo.sid]
							type = "equip";
						end
						if table ~= nil then
							local str = string.format("你获得了[item:%s:item:%d]", table.name or table.show_name, iteminfo.quality);
							local haveTeam = client.role.haveTeam();
							if type == "item" then
								local tempStr = str;
								if changeCount > 1 then
									tempStr = string.format("%sX%d", str, changeCount);
								end
								client.chat.clientSystemMsg(tempStr, iteminfo, nil, "system", true)
								if (haveTeam and iteminfo.quality == 4) then
									client.chat.clientSystemMsg(str, iteminfo, nil, "team", false)
								end
							else
								client.chat.clientSystemMsg(str, nil, iteminfo, "system", true)
								--橙装或者橙色碎片在队伍频道显示
								if (haveTeam and (iteminfo.quality == 4 or iteminfo.quality == 6)) then
									client.chat.clientSystemMsg(str, nil, iteminfo, "team", false)
								end
							end
							if IsShowMsg then
								ui.showItemMsg(iteminfo.sid, changeCount, iteminfo.quality)
							end
						end
					end
				end
		end
		Bag.handleEquipBetter();
	end
	

	function Bag.updateWearList(eventData)
		if eventData==nil then
			return;
		end
		for i = 1, #eventData do
			local rawData = eventData[i];
			local index  = rawData[1];
			local item   = rawData[2];
			if 0 == item then
				Bag.wearList[index] = nil;
				client.suit.updateEquipMap(Bag.wearList[index],nil);
			else
				local equip = client.equip.parseEquip(item);
				client.suit.updateEquipMap(Bag.wearList[index], equip);
				Bag.wearList[index] = equip;
				if Bag.wearList[index].recoveryTime ~= 0 then
					--<装备名称>已损坏，装备在修复期内暂时无效化
					local sid = Bag.wearList[index].sid;
					local equipCfg = tb.EquipTable[sid];
					local str = equipCfg.name.."已损坏，装备在修复期内暂时无效化";
					client.chat.clientSystemMsg(str);
					local item = {type = 1,index = index,time = Bag.wearList[index].recoveryTime};
					table.insert(Bag.BrokenMap,item);
					MainUI.ShowRepairIcon();
				end
			end
		end
		EventManager.onEvent(Event.ON_EVENT_WEAREQUIP_CHANGE);
	end

	function Bag.getWearEquip(buwei)
		local equip = nil;
		local equip_data = nil;

		for i = 1, const.WEAREQUIP_COUNT do
			equip = Bag.wearList[i];
			if equip ~= nil then
				equip_data = tb.EquipTable[equip.sid];
				if equip_data.buwei == buwei then
					return equip;
				end
			end
		end
		return nil;
	end

	
	-- 购买生命药
	function Bag.buyDrug(item, count, callback)
		local msg = {cmd = "shop_buy", shop_id = 10080001, goods_id = item.tid, goods_numb = count};
		Send(msg, function (reply)
			if reply.error ~= nil then
				callback(false);
			else
				callback(true);
			end
		end);
	end

	-- 自动购买生命药
	function Bag.autoBuyItem(callback)
		local settings = DataCache.settings;
		local drugId = settings.fight_drugId;
		local item = tb.ItemTable[drugId];
		local money = DataCache.role_money;
		if money >= item.max_count * item.price then
			Bag.buyDrug(item, item.max_count, callback)
		else
			local count = math.floor(money / item.price);
			Bag.buyDrug(item, count, callback);
		end
	end

	-- 使用生命药
	function Bag.useDrug()
		local settings = DataCache.settings;
		local autoBuy = settings.fight_autoBuy;
		local drugId = settings.fight_drugId;

		local drugs = client.tools.filter(itemBag.list, function (item)
			local itemTable = tb.ItemTable[item.sid];
			return itemTable.tid == drugId;
		end);

		if #drugs > 0 then
			local item = drugs[1];
			Bag.useItem(item, true);
		else
			if autoBuy then
				Bag.autoBuyItem(function (success)
					if success then
						drugs = client.tools.filter(itemBag, function (item) 
							local itemTable = tb.ItemTable[item.sid];
							return itemTable and itemTable.tid == drugId;
						end);
						if #drugs > 0 then
							local item = drugs[1];
							Bag.useItem(item, true);
						end
					end
				end);
			end
		end
	end


	-- 这里应该把一些消息封装成错误代码,
-- 返回值，代表是否在CD时间内，如果是0 ，表示使用成功， 
-- 其他表示 cd的剩余时间
	function Bag.useItem(item, flag, cb)
		if nil == item then
			ui.showMsg("数据错误");
			return 0;
		end
		local cdInfo = Bag.checkCD(item.sid) 
		if nil ~= cdInfo then
			if flag ~= true then 
				ui.showMsg("药品冷却中，请稍后再试！");
			end
			return cdInfo.left;
		end
		local msg = {cmd = "use_prop",bag_index = item.pos,sid = item.sid};
		Send(msg, cb);		
		Bag.cdMap[tb.ItemTable[item.sid].cd_group] = Util.GetCurrentSec();
		return 0;
	end


	function Bag.checkCD(sid)

		local itemCfg = tb.ItemTable[sid];
		if nil == itemCfg then
			--print("数据错误");
			return nil;
		end
		local cd_group = itemCfg.cd_group;

		local lastUseTime = Bag.cdMap[cd_group];

		if nil == lastUseTime then
			return nil;
		end
		
		local now = Util.GetCurrentSec();

		local elapse = now - lastUseTime;
	
	
	

		if elapse > itemCfg.cd then
			Bag.cdMap[cd_group]	= nil;
			return nil;
		end

		return {cd = itemCfg.cd, left = itemCfg.cd - elapse}

	end

	function Bag.checkCDByIdx(idx)
		local result = Bag.checkCD(itemBag.list[idx].sid);		
		if nil == result then 
			return 1;
		end
		return result.cd,result.left;
	end

	function Bag.FindItemBytid(tid)
		local list = itemBag.list;
		for i = 1,#list do 
			local item = list[i]
			if item and item.sid == tid then
				return item;
			end
		end 
		return nil
	end

	function Bag.GetMergeItemBytid(tid)
		-- print("Bag.GetMergeItemBytid")
		-- print(tid)
		local pro = tb.ItemTable[tid]
		if pro == nil then
			return false
		end
		local list = itemBag.list;
		for i = 1,#list do 
			local item = list[i]
			if item and item.sid == tid 
				and item.count < pro.max_count then
				-- print("have space!")
				return true;
			end
		end 
		-- print("no enough space")
		return false
	end

	function Bag.GetItemCountBysid(sid)
		if Bag.itemCountMap[sid] then
			return Bag.itemCountMap[sid];
		end
		return 0;
	end

	function Bag.GetItemList() 
		return itemBag;
	end

	function Bag.GetItemByIndex(index )
		return itemBag.list[index];
	end

	--是否可以上架交易
	function Bag.ItemCanTrade(sid)
		return tb.jiaoyihang[sid] ~= nil and tb.jiaoyihang[sid].cansell == 1;
	end

	function Bag.GetModelAppearanceData()
		--职业
		local careeralias = const.ProfessionAlias[DataCache.myInfo.career]
		local sex = const.sexName[DataCache.myInfo.sex]
		--获取装备外观数据 衣服 + 武器
		local yifu_index = const.BuWeiIndex["衣服"];
		local wuqi_index = const.BuWeiIndex["武器"];
		local yifu = Bag.getWearEquip(yifu_index)
		local yifu_equipTable = tb.EquipTable[yifu.sid];
		local prefablevel = const.model2PrefabLevel[yifu_equipTable.level]
		----模型prefab
		local appearance_body = careeralias.."_"..sex.."_"..prefablevel
		----模型texture
		local appearance_body_tx = careeralias.."_"..sex.."_"..const.material2PrefabLevel[yifu_equipTable.level]
		----武器prefab
		local wuqi = Bag.getWearEquip(wuqi_index)
		local wuqi_equipTable = tb.EquipTable[wuqi.sid];
		local wuqilevel = const.weapon2PrefabLevel[wuqi_equipTable.level]
		local appearance_weapon = careeralias.."_"..wuqilevel.."_w"
		return appearance_body, appearance_body_tx, appearance_weapon
	end

	--更新装备外观
	function Bag.UpdateAppearance(msgTable)
		local newEquip = msgTable["new_equip"]
		local equipTable = tb.EquipTable[newEquip[1]]
		local yifu_index = const.BuWeiIndex["衣服"]
		local wuqi_index = const.BuWeiIndex["武器"]
		local careeralias = const.ProfessionAlias[DataCache.myInfo.career]
		local sex = const.sexName[DataCache.myInfo.sex]

		local class = Fight.GetClass(AvatarCache.me);
		--换衣服
		if equipTable.buwei == yifu_index then
			--print("UpdateAppearance")
			class.PutOnSuit(AvatarCache.me, equipTable.tid, function () end);
		--换武器	
		elseif equipTable.buwei == wuqi_index then
			class.PutOnWeapon(AvatarCache.me, equipTable.tid, function () end);
		end
	end

	EventManager.register(Event.ON_TIME_SECOND_CHANGE,Bag.CheckBrokenEquip);
end
