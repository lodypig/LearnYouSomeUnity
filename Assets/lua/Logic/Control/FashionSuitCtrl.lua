FashionSuit = {};
FashionSuit.suits = {};
FashionSuit.suitEquips = {};
FashionSuit.unlockSuits = {};
FashionSuit.hasFashionSuitRedPoint = false;

function FashionSuitCtrl()
	
	-- 时装初始化
	function FashionSuit.init()
		
		local career = DataCache.myInfo.career;
		FashionSuit.clearFashionSuits();
		FashionSuit.getSuitDatas(FashionSuit.suits, career);
		EventManager.register(Event.ON_EVENT_GET_NEW_EQUIP, FashionSuit.onGetNewEquip);
		FashionSuit.getFashionSuits(function ()
            
        end);
	end

	function FashionSuit.clearFashionSuits()
		for i = 1, #FashionSuit.suits do
			FashionSuit.suits[i] = nil;
		end
	end

	-- 获取表信息
	function FashionSuit.getFashionSuitTableInfoById(id)
		for k, v in pairs(tb.ItemFashionSuitTable) do
			if v.id == id then
				return v;
			end
		end
		return nil;
	end

	-- 获取新手装信息
	function FashionSuit.getNewerFashionSuitTableInfo(career)
		for k, v in pairs(tb.ItemFashionSuitTable) do
			if string.sub(k, 1, string.len(career)) == career then
				if FashionSuit.isNewerSuit_TableItem(v) then
					return v;
				end
			end
		end
		return nil;
	end


	function FashionSuit.getNewerSuitId()
		local career = DataCache.myInfo.career;
		FashionSuit.getSuitDatas(FashionSuit.suits, career);
		local itemData = FashionSuit.getNewerSuit(FashionSuit.suits);
		if itemData == nil then
			return 0;
		end
		return itemData.id;
	end

	function FashionSuit.getNewerSuitIdByCareer(career)
		local suits = {};
		FashionSuit.getSuitDatas(suits, career);
		local itemData = FashionSuit.getNewerSuit(suits);
		if itemData == nil then
			return 0;
		end
		return itemData.id;
	end


	function FashionSuit.getNewerSuit(suits)
		for i = 1, #suits do
			local itemData = suits[i];
			if FashionSuit.isNewerSuit_TableItem(itemData) then
				return itemData;
			end
		end
		return nil;
	end

	-- 获取时装数据
	function FashionSuit.addFashionSuits()
		FashionSuit.clearFashionSuits();	
		local career = DataCache.myInfo.career;
		FashionSuit.getSuitDatas(FashionSuit.suits, career);
	end

	-- 添加时装
	function FashionSuit.addFashionSuit(level, quality)
		local career = DataCache.myInfo.career;
		local item = tb.GetTableByKey(tb.ItemFashionSuitTable, {career, level, quality});
		FashionSuit.suits[#FashionSuit.suits + 1] = item;
	end

	-- 获取职业时装数据
	function FashionSuit.getSuitDatas(datas, career)

		if datas == nil then
			return;
		end

		if #datas > 0 then
			return;
		end

		local suitTable = tb.ItemFashionSuitTable;
		for k, v in pairs(suitTable) do
			if string.sub(k, 1, string.len(career)) == career then
				datas[#datas + 1] = v;
			end
		end
		if #datas > 1 then
			table.sort(datas, function(a, b)
				return a.id < b.id;
			end);
		end
	end


	-- 存在可以解锁的时装
	function FashionSuit.hasCanUnlockSuit()
		local career = DataCache.myInfo.career;
		FashionSuit.getSuitDatas(FashionSuit.suits, career);
		for i = 1, #FashionSuit.suits do
			local itemData = FashionSuit.suits[i];
			if FashionSuit.isLockedSuit(itemData) then
				if FashionSuit.isAllSuitEquipOn(itemData) then
					return true;
				end
			end
		end
		return false;
	end


	function FashionSuit.isNewerSuit_TableItem(itemData)
		return itemData.level == 1;
	end


	-- 是否是新手装
	function FashionSuit.isNewerSuit(id)
		local suits = FashionSuit.suits;
		for i = 1, #suits do
			local itemData = suits[i];
			if itemData.id == id and FashionSuit.isNewerSuit_TableItem(itemData) then
				return true;
			end
		end
		return false;
	end

	-- 是否是能解锁的时装
	function FashionSuit.isCanUnlockSuit(id)
		if FashionSuit.isNewerSuit(id) then
			return false;
		end
		local career = DataCache.myInfo.career;
		local table = tb.ItemFashionSuitTable;
		
		for k, v in pairs(table) do
			if string.sub(k, 1, string.len(career)) == career then
				local itemData = v;
				if itemData.id == id then

					return false;
				end
			end
		end
		return false;
	end

	-- 是否是锁定的时装
	function FashionSuit.isLockedSuit(itemData)
		if FashionSuit.isNewerSuit(itemData.id) then
			return false;
		end
		if FashionSuit.isActivateSuit(itemData.id) then
			return false;
		end
		if FashionSuit.isUnlockSuit(itemData.id) then
			return false;
		end
		return true;
	end

	-- 是否是已经解锁的时装
	function FashionSuit.isUnlockSuit(id)

		if FashionSuit.isNewerSuit(id) then
			return true;
		end

		for i = 1, #FashionSuit.unlockSuits do
			if FashionSuit.unlockSuits[i] == id then
				return true;
			end
		end

		return false;
	end

	-- 是否是已经激活的时装
	function FashionSuit.isActivateSuit(id)
		if DataCache.myInfo.suitActivateId == 0 then
			return FashionSuit.isNewerSuit(id);
		end
		return DataCache.myInfo.suitActivateId == id;
	end


	-- 套装装备全部获得
	function FashionSuit.isSuitEquipOn(sid, quality)
		for i = 1, #FashionSuit.suitEquips do
			local history_equip = FashionSuit.suitEquips[i];
			if sid == history_equip[1] and quality == history_equip[2] then
				return true;
			end
		end
		return false;
	end

	-- 时装所有装备都获得过
	function FashionSuit.isAllSuitEquipOn(itemData)
		if FashionSuit.isNewerSuit(itemData.id) then
			return false;
		end
		for i = 1, 6 do
			local p = "part" .. i;
			local q = "part" .. i .. "_quality";
			local part = itemData[p];
			local quality = itemData[q];
			if not FashionSuit.isSuitEquipOn(part, quality) then
				return false;
			end
		end
		return true;
	end


	-- 获取时装数据
	function FashionSuit.getSuitDataByIndex(index)
		return FashionSuit.suits[index];
	end


	-- 刷新历史获得装备
	function FashionSuit.onGetNewEquip(msg)
		local history_equips = msg["equips"];
		FashionSuit.refreshHistoryEquips(history_equips);
		FashionSuit.hasFashionSuitRedPoint = FashionSuit.hasCanUnlockSuit();
		EventManager.onEvent(Event.ON_EVENT_RED_POINT);
	end


	-- 添加历史获得装备
	function FashionSuit.refreshHistoryEquips(equips)
		for i = 1, #FashionSuit.suitEquips do
			FashionSuit.suitEquips[i] = nil;
		end
		if equips ~= nil then
			for i = 1, #equips do
				FashionSuit.suitEquips[#FashionSuit.suitEquips + 1] = equips[i];
			end
		end
		-- DataStruct.DumpTable(FashionSuit.suitEquips)
	end


	-- 获取时装表数据
	function FashionSuit.getSuitData(career, level, quality)
		return tb.GetTableByKey(tb.ItemFashionSuitTable, {career, level, quality});
	end


	-- 获取时装状态
	function FashionSuit.getFashionSuits(callback)
		FashionSuit.addFashionSuits();
		local msg = { cmd = "get_fashion_suits" };
		Send(msg, function(msg)
			local history_equips = msg["history_equips"];
			FashionSuit.refreshHistoryEquips(history_equips);
			if msg["activate"] == nil then
				DataCache.myInfo.suitActivateId = FashionSuit.getNewerSuitId();
			else
				DataCache.myInfo.suitActivateId = msg["activate"];
				if DataCache.myInfo.suitActivateId == 0 then
					DataCache.myInfo.suitActivateId = FashionSuit.getNewerSuitId();
				end
			end

			for i = 1, #FashionSuit.unlockSuits do
				FashionSuit.unlockSuits[i] = nil;
			end
			local unlockList = msg["unlock"];
			for i = 1, #unlockList do
				FashionSuit.unlockSuits[#FashionSuit.unlockSuits + 1] = unlockList[i];
 			end

 			FashionSuit.hasFashionSuitRedPoint = FashionSuit.hasCanUnlockSuit();
 			EventManager.onEvent(Event.ON_EVENT_RED_POINT);
			callback();
		end);
	end

	-- 获取套装信息
	function FashionSuit.getFashionSuitInfo(callback)
		local msg = { cmd = "get_fashion_suit_history_equips" };
		Send(msg, function(msg)
			local history_equips = msg["history_equips"];
			for i = 1, #FashionSuit.suitEquips do
				FashionSuit.suitEquips[i] = nil;
			end
			if history_equips ~= nil then
				for i = 1, #history_equips do
					FashionSuit.suitEquips[#FashionSuit.suitEquips + 1] = history_equips[i];
				end
			end
			if callback ~= nil then
				callback();
			end
		end);
	end

	-- 解锁套装
	function FashionSuit.unlockFashionSuit(id, callback)
		local msg = { cmd = "unlock_fashion_suit", suit_sid = id };
		Send(msg, function(msg)
			local type = msg["type"];
			if type == "success" then
				FashionSuit.unlockSuits[#FashionSuit.unlockSuits + 1] = id;
				FashionSuit.hasFashionSuitRedPoint = FashionSuit.hasCanUnlockSuit();
 				EventManager.onEvent(Event.ON_EVENT_RED_POINT);
				callback(true);
			else
				callback(false);
			end
		end);
	end

	-- 激活时装
	function FashionSuit.activateFashionSuit(id, callback)
		local msg = { cmd = "activate_fashion_suit", suit_sid = id };
		Send(msg, function(msg)
			local type = msg["type"];
			if type == "success" then
				DataCache.myInfo.suitActivateId = id;
				callback(true);
			else
				callback(false);
			end
		end);
	end
end