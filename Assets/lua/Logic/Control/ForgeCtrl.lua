
function CreateForgeCtrl()
	local Forge = {};
	local buweiSortWeight = {
		[1] = 1,
		[2] = 4,
		[3] = 2,
		[4] = 6,
		[5] = 3,
		[6] = 5,
		[7] = 7,
		[8] = 8,
		[9] = 9,
		[10] = 10
	}

	Forge.IsAllPurpleOn = 0;

	-- 计算装备可提供的锻造度
	function Forge.CalcEquipForgeValue(equip)
		local v1 = tb.GetTableByKey(tb.EquipForgeValueTable, {equip.level, equip.quality});
		if type(equip.forgeAttr) ~= "table" then
			return v1;
		else
			local v2 = tb.GetTableByKey(tb.EquipForgeAttrTable, {equip.level, equip.forgeAttr[1], equip.buwei}).total_forge_value + equip.forgeAttr[2]; 
			return v1 + v2;
		end
	end

	-- 获取背包中比穿戴装备等级低的紫装或橙装list
	function Forge.GetForgeEquipList(wearEquip)
		Forge.forgeEquipList = {};
		Forge.chooseList = {};
		local bag = Bag.GetItemList();
		local list = bag.list;
		for k,item in pairs(list) do
			-- 选择等级低于穿戴装备,40级以上，且品质为橙色或紫色的装备
			if item and item.type == const.bagType.equip and item.level >= 40 and item.level <= wearEquip.level and (item.quality == 3 or item.quality == 4)  then
				Forge.forgeEquipList[#Forge.forgeEquipList + 1] = item;
				Forge.chooseList[#Forge.chooseList + 1] = 0;
			end
		end

		if #Forge.forgeEquipList > 1 then
    		table.sort(Forge.forgeEquipList, Forge.Sort)
		end 
	end
	-- 对选择的装备进行一次排序
    -- 先按装备品质排，品质高的排在前面；
    -- 同品质下按等级排，等级高的排在前面；
    -- 同品质同等级下按部位排，从前到后： 武器>衣服>项链>耳环>戒指>裤子>头盔>护肩>手套>鞋子；
    										-- 1  3    5    2   6     4    7   8    9    10
    -- 同品质同等级同部位，按获得先后顺序排，先获得的在前；
    function Forge.Sort(equip1,equip2)
    	if equip1.quality ~= equip2.quality then
    		return equip1.quality > equip2.quality
		elseif equip1.level ~= equip2.level then
    		return equip1.level > equip2.level
    	elseif equip1.buwei ~= equip2.buwei then
    		return buweiSortWeight[equip1.buwei] < buweiSortWeight[equip2.buwei];
    	else
    		-- 根据装备的获取时间来排序，暂时没有
    		return false
    	end
    end

    -- 全身紫装
    -- 同时提供快捷功能“全选紫装”；
    -- 该功能前有勾选框，每次进入该界面，选项都不会勾上；
    -- 玩家点击勾选框，勾选框变为勾选状态，同时选中列表中的条目，选中规则为：
    --     勾选的装备一定都是紫色品质；
    --     按照列表从上往下的顺序逐个勾选，直到勾选装备提供的进度足够使当前进度提升到下一级为止，从表现上应该是同时全部选中的；
    --     若将所有可以勾选的装备勾选后依然不足以升级，则还是将所有可以勾选的装备都勾上；
    -- 若当前没有可以勾选的装备，依然可以将“全选紫装”选项勾上；
    function Forge.AllPurple(equip)
    	if Forge.IsAllPurpleOn == 1 then
    		-- 没有材料装备 或 穿戴装备已满级
    		local upGradeValue = Forge.calcUpgradeValue(equip)
	    	if #client.forge.forgeEquipList == 0 or upGradeValue == 0 then
	    		return
	    	else
	    		-- 将选中列表全部重置为0，同时按装备顺序由上至下选择紫色装备，直到锻造值满足升下级需求，然后刷新右侧装备选中效果 和 左侧预览效果
	    		for i=1, #Forge.chooseList do
	    			Forge.chooseList[i] = 0;
	    		end

	    		local totalValue = 0;
	    		for i=1, #Forge.forgeEquipList do
	    			if Forge.forgeEquipList[i].quality == 3 then
	    				totalValue = totalValue + Forge.CalcEquipForgeValue(Forge.forgeEquipList[i]);
    					Forge.chooseList[i] = 1;
	    				-- 如果装备累计的锻造值大于升下级所需锻造度，返回
	    				if totalValue >= upGradeValue then
	    					return;
	    				end
	    			end
	    		end
	    	end
    	end
    end

	-- 计算装备升下级所需的锻造值
    function Forge.calcUpgradeValue(equip)
    	-- 装备未经过锻造
		if type(equip.forgeAttr) ~= "table" then
			local equipCfg = tb.GetTableByKey(tb.EquipForgeAttrTable,{equip.level, 0, equip.buwei});
			return equipCfg.next_level_value;
		else
			-- 装备经过锻造，需要考虑穿戴的装备是否达到满级
			-- 装备已锻造至满级，无需再锻造
			if equip.level == tb.MaxForgeLevelTable[equip.level] then
				return 0;
			end
			local equipCfg = tb.GetTableByKey(tb.EquipForgeAttrTable,{equip.level,equip.forgeAttr[1], equip.buwei});
			return equipCfg.next_level_value - equip.forgeAttr[2];
		end
    end

    -- 装备在给定的forgeValue下可以升到多少级
    function Forge.CalcNextForgeLevel(equip,deltaForgeValue)
		local tempEquip = {}
		tempEquip.level = equip.level
		tempEquip.buwei = equip.buwei
		tempEquip.forgeAttr = {}

    	if type(equip.forgeAttr) == "table" then
    		-- 锻造过
			tempEquip.forgeAttr[1] = equip.forgeAttr[1]  			    		
			tempEquip.forgeAttr[2] = equip.forgeAttr[2]
    	else
    		-- 未锻造过
    		tempEquip.forgeAttr[1] = 0
    		tempEquip.forgeAttr[2] = 0
    	end
		local level = Forge.LoopCalcForgeLV(tempEquip, deltaForgeValue, tempEquip.forgeAttr[1])
		return level
    end

    -- 如果equip没有锻造过，传入的equip.forgeAttr = {0,0}
    function Forge.LoopCalcForgeLV(equip,deltaForgeValue,forgeLV)
		local curLVCfg = tb.GetTableByKey(tb.EquipForgeAttrTable, {equip.level, forgeLV, equip.buwei}); 

		-- 已满级
		if forgeLV == tb.MaxForgeLevelTable[equip.level] then
			return forgeLV
		end

		if curLVCfg.next_level_value <= equip.forgeAttr[2] + deltaForgeValue then
			equip.forgeAttr = {};
			equip.forgeAttr[1] = forgeLV + 1
			equip.forgeAttr[2] = 0

			deltaForgeValue = deltaForgeValue + equip.forgeAttr[2] - curLVCfg.next_level_value;
			return Forge.LoopCalcForgeLV(equip, deltaForgeValue, forgeLV + 1)
		else
			return forgeLV
		end    	
    end

	-- 处理装备锻造
	function Forge.HandleForge(posList,buwei,callback)
		local msg = { cmd = "forge_port/forge", bag_index_list = posList, buwei = buwei}
		Send(msg, callback);
	end

  	return Forge;
end

client.forge = CreateForgeCtrl();