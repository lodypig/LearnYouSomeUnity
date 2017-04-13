local function GemCtrl() 
	local gem = {}
	local gemCountMap = {};
	local gemBuWeiMap = {};
	local equipGemMap = {};

	-- 初始化各部位1级宝石
	do
		gem.firstGemList = {};
		local firstTypeList = {};		
		for k,v in pairs(tb.GemTable) do
			if v.level == 1 then
				firstTypeList[v.gem_type] = k;
			end
		end
		for i = 1, #tb.EquipGemTable do
			gem.firstGemList[i] = firstTypeList[tb.EquipGemTable[i]];
		end
		firstTypeList = nil;
	end


	local addGem = function (addGem, old)
		local type = tb.GemTable[addGem.sid].gem_type;
		local oldCount = gemCountMap[addGem.sid] or 0;

		if gemCountMap[addGem.sid] then
			gemCountMap[addGem.sid] = gemCountMap[addGem.sid] + addGem.count;
		else
			gemCountMap[addGem.sid] = addGem.count;
		end


		if gemBuWeiMap[type] then
			gemBuWeiMap[type] = gemBuWeiMap[type] + addGem.count;
		else
			gemBuWeiMap[type] = addGem.count;
		end

		if old and old.type == const.bagType.gem then
			gem.remove(old);
		end

		return gemCountMap[addGem.sid] - oldCount;
	end

	local upgradeBagGemWithNum = function(cb, gem, num, need_diamond)
		if DataCache.role_diamond < need_diamond then
			ui.showCharge();
			return;
		end
		local msg = {cmd = "upgrade_bag_gem", num = num, gem_sid = gem.sid};
		Send(msg, cb);
	end

	gem.upgradeBagGem = function (cb, selectGem, costCount)
		upgradeBagGemWithNum(cb, selectGem, costCount, 0);
	end
	
	--这边需要检查这个位置是否需要显示红点
	gem.checkHigh = function(buwei)
		--收集开了几个宝石孔
		local count = 0;
		for i=1,4 do
			if tb.GemLevelTable[i] <= DataCache.myInfo.level then
				count = i;
			end
		end
		--判断已开的孔是否有未镶嵌的
		local bFree = false;
		local GemInfo = gem.getEquipGem(buwei);
		for i=1,count do
			if GemInfo[i] == nil then
				bFree = true;
				break;
			end
		end

		if bFree == false then
			return false
		else
			return gem.hasGem(buwei);
		end
	end

	gem.putOn = function(cb, buwei, selectGem, index)
		local need_type = tb.EquipGemTable[buwei];
		local gemTable = tb.GemTable[selectGem.sid];

		if gemTable.gem_type ~= need_type then
			ui.showMsg("宝石类型不符");
			return;
		end

		local msg = {cmd = "put_on_gem", buwei = buwei, bag_index = selectGem.pos, gem_index = index};
		Send(msg, function(msg) 
			if not equipGemMap[buwei] then
				equipGemMap[buwei] = {};
			end
			local equipGem = equipGemMap[buwei];
			equipGem[index] = gem.parse(msg.gem);
			cb();
		end);

	end

	gem.remove = function(oldData)
		local type = tb.GemTable[oldData.sid].gem_type;
		gemCountMap[oldData.sid] = gemCountMap[oldData.sid] - oldData.count;
		gemBuWeiMap[type] = gemBuWeiMap[type] - oldData.count;
	end

	gem.removeEquipGem = function(cb, buwei, index)
		if not index then
			ui.showMsg("未知错误，请刷新页面重试");
			return;
		end
		local msg = {cmd = "remove_equip_gem", buwei = buwei, gem_index = index};
		Send(msg, function(msg) 
			local gemList = equipGemMap[buwei];
			gemList[index] = nil;
			cb();
		end);
	end

	gem.upgradeEquipGem = function(cb, buwei, result, index)
		local msg = {cmd = "upgrade_gem_new" , diamond = result.left, sidList = result.sidList, 
			countList = result.countList, buwei = buwei, cellIndex = index};
		Send(msg, function(msg) 
			local equipGem = equipGemMap[buwei];
			equipGem[index] = gem.parse(msg.gem);
			cb();
		end);
	end

	local function parseGemList(gemList)
		local list = {};
		local i;
		for i = 1, #gemList do
			list[i] = gem.parse(gemList[i]);
		end
		return list;
	end

	function gem.onEquipGem(gemList)
		local i;

		for i = 1, #gemList do
			equipGemMap[gemList[i][1][2]] = parseGemList(gemList[i][2]);
		end
	end

	function gem.hasGem(buwei) 
		local gemType = tb.EquipGemTable[buwei];
		if gemBuWeiMap[gemType] then
			return gemBuWeiMap[gemType] > 0;
		else	
		    return false;
		end
	end

	function gem.getEquipGem(buwei)
		return equipGemMap[buwei] or {};
	end

	gem.parse = function(sample, add, old) 
		local gem = {};
		local changeCount;
		if sample == 0 then
			return nil;
		end

		gem.sid = sample[1];
		gem.count = sample[2][1];
		gem.id = sample[2][2];
		if add then
			changeCount = addGem(gem, old);
		end
		gem.quality = tb.GemTable[gem.sid].quality;
		
		gem.type = const.bagType.gem;

		return gem, changeCount;
	end

	gem.sortFunc = function (gem1, gem2)
		return gem1.sid > gem2.sid;
	end

    --排序权重  类型 等级
    gem.getSortWeight = function(gem)
        local table = tb.GemTable[gem.sid];
        return const.showTypeSortWeight.gem + table.gem_type * 100 + table.level;
    end

	gem.couldUp = function (gemSid)
		local table = tb.GemTable[gemSid];
		local to_next_count = table.to_next_count - 1;
		local costMoney = table.cost_money;

		if table.next_gem == 0 then
			return false;
		end

		return gem.canGetUp(gemSid, to_next_count); 
	end

	gem.formatAttrValue = function(gemSid)
		local table = tb.GemTable[gemSid];
		if const.ATTR_PERCENT[table.add_attr_type] then
			return table.add_attr_value * 100 .. "%";
		end
		return table.add_attr_value;		
	end

	

	gem.getCount = function(sid)
		return gemCountMap[sid] or 0;
	end

	gem.canGetUp = function(gemsid, to_next_count)
		local level = tb.GemTable[gemsid].level;
		local sid = gemsid;
		for i = 1, level do
			sid = string.sub(sid, 1,-2)..((level+1)-i);
			if gem.getCount(tonumber(sid)) >= to_next_count then
				return true;
			end
			to_next_count = 3 * (to_next_count - gem.getCount(tonumber(sid)));
		end
		return false;
	end

	return gem;
end

client.gem = GemCtrl();