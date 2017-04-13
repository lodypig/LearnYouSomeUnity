function EquipCtrl()
	local  Equip = {};

	Equip.createTempEquip = function (sid, addAttr, quality)
		local equip = {};
		equip.sid = sid;
		equip.addAttr = addAttr;
		equip.quality = quality;

		local table = tb.EquipTable[equip.sid];
		equip.level = table.level;	
		equip.career = table.career;	
		equip.score = runTable.getEquipScore(equip);
		equip.fight_power = runTable.getEquipFightPower(equip);
		equip.buwei = table.buwei;

		return equip;
	end

	Equip.parseEquip = function (equipSample)
		local equip  = {};

		equip.sid = equipSample[1];
		local tmp = equipSample[2];	
		equip.baseAttr = tmp[2];	
        equip.addAttr = tmp[1];	
		equip.count = tmp[3]
		-- table.sort(equip.addAttr, Bag.attrSortFunc);

		equip.forgeAttr = tmp[4];
		equip.id = tmp[5];	
		equip.maxcount = tmp[6]	
		equip.quality = tmp[7];
		
		equip.recoveryTime = tmp[8];
		equip.tempAttr = tmp[9];
		local table = tb.EquipTable[equip.sid];
		equip.level = table.level;	
		equip.career = table.career;	
		equip.buwei = table.buwei;
		equip.name = table.name;

		equip.type = const.bagType.equip;
		return equip, equip.count;
	end

	Equip.toSend = function (equip, enhance, gemList)
		local msg = {
			sid = equip.sid,
			quality = equip.quality,
			addAttr = equip.addAttr
		};
		if enhance and enhance.level then
			msg.enhance_level = enhance.level;			
		end		

		if gemList and #gemList > 0 then
			local list = {};
			for i = 1, #gemList do
				list[i] = gemList[i].sid;
			end
			msg.gem_list = list;
		end

		return msg;
	end

	--获取装备附加属性战力总和
	Equip.getAddAttrFightPoint = function (equip)
		local list = tb.GetFightPoint(equip.career, equip.addAttr);

		local fightPoint = 0;
		for i=1, #list do
			fightPoint = fightPoint + list[i];
		end

		return fightPoint;
	end

	Equip.isHighScore = function (equip) 
		if equip.career == DataCache.myInfo.career then
			local wearEquip = Bag.getWearEquip(equip.buwei);
			return wearEquip == nil or wearEquip.score < equip.score;
		end
		return false;
	end

	Equip.AddIdentifyBiaoshi = function(equip)
		if equip.quality == const.quality.unidentify then
			equip.isIdentify = const.IsIdentify.Unidentify;
		else
			--橙装碎片，且个数 < 5
			if equip.quality == const.quality.orangepiece and equip.count < 5 then
			--判断为不能合成的橙装碎片
				equip.isIdentify = const.IsIdentify.Orangepiece;
			else
				--橙装碎片，且个数 > = 5 ，为可以合成的橙装碎片
				if equip.quality == const.quality.orangepiece and equip.count >= 5 then
					equip.isIdentify = const.IsIdentify.Orangesuccess;

				else
					equip.isIdentify = const.IsIdentify.Identified;
					local Signal_Wear = Equip.showWearFlag(equip);
					local Signal_Zhuanyi = Equip.CouldZhuanyi(equip);
					local Signal_Xilian = Equip.CouldXilian(equip);
					if Signal_Wear then
						equip.biaoshi = const.biaoshi.CouldWear;
					elseif Signal_Zhuanyi then
						equip.biaoshi = const.biaoshi.CouldZhuanyi;
					elseif Signal_Xilian then
						equip.biaoshi = const.biaoshi.CouldXilian;
					else
						equip.biaoshi = const.biaoshi.NoAttr;
					end
				end
			end
		end	
	end

	Equip.showWearFlag = function (equip)
		-- 基础属性大于等于同部位穿戴的装备，且附加属性战力总和高于同部位穿戴的装备
		local wearEquip = Bag.getWearEquip(equip.buwei);
		if wearEquip == nil then
			return DataCache.myInfo.level >= equip.level;
		end

		if wearEquip.level > equip.level then
			return false;
		end

		if DataCache.myInfo.level < equip.level then
			return false;
		end

		local srcEquipCfg = tb.GetTableByKey(tb.baseAttrTable, {equip.sid, equip.quality});
		local wearEquipCfg = tb.GetTableByKey(tb.baseAttrTable, {wearEquip.sid, wearEquip.quality});

		-- 大于等于用and
		if srcEquipCfg.phyDefense >= wearEquipCfg.phyDefense and srcEquipCfg.phyAttackMin >= wearEquipCfg.phyAttackMin then
			local wearFightPoint = Equip.getAddAttrFightPoint(wearEquip);
			local srcFightPoint = Equip.getAddAttrFightPoint(equip);
			return srcFightPoint > wearFightPoint;
		end
		return false;
	end

	Equip.CouldZhuanyi = function(equip)
		-- 基础属性大于同部位穿戴的装备，且附加属性战力总和小于等于同部位穿戴的装备
		local wearEquip = Bag.getWearEquip(equip.buwei);
		if wearEquip == nil or wearEquip.level <= 1 or equip.level <= 1 or equip.quality <=1 or wearEquip.quality <= 1  then
			return false;
		end

		if wearEquip.level > equip.level then
			return false;
		end

		if DataCache.myInfo.level < equip.level then
			return false;
		end

		local srcEquipCfg = tb.GetTableByKey(tb.baseAttrTable, {equip.sid, equip.quality});
		local wearEquipCfg = tb.GetTableByKey(tb.baseAttrTable, {wearEquip.sid, wearEquip.quality});

		local wearFightPoint = Equip.getAddAttrFightPoint(wearEquip);
		local srcFightPoint = Equip.getAddAttrFightPoint(equip);

		-- 大于时用or
		if srcEquipCfg.phyDefense > wearEquipCfg.phyDefense or srcEquipCfg.phyAttackMin > wearEquipCfg.phyAttackMin then
			local wearFightPoint = Equip.getAddAttrFightPoint(wearEquip);
			local srcFightPoint = Equip.getAddAttrFightPoint(equip);

			return srcFightPoint <= wearFightPoint;
		end
		return false;
	end

	Equip.CouldXilian = function(equip, tblOutParam)
		-- 基础属性小于等于同部位穿戴的装备,且附加属性中最高战力属性的显示品质比同部位穿戴的装备中最低战力属性的显示品质高至少一个品质时
		local wearEquip = Bag.getWearEquip(equip.buwei);

		if wearEquip == nil then
			return false;
		end

		if equip.quality <=1 or wearEquip.quality <= 1 then
			if tblOutParam ~= nil then
				tblOutParam.err = 1; --装备品质
			end
			return false;
		end

		if wearEquip.level <= 1 or equip.level <= 1  then
			return false;
		end

		--if wearEquip.level > equip.level then
		--	return false;
		--end

		if DataCache.myInfo.level < equip.level then
			return false;
		end

		local srcEquipCfg = tb.GetTableByKey(tb.baseAttrTable, {equip.sid, equip.quality});
		local wearEquipCfg = tb.GetTableByKey(tb.baseAttrTable, {wearEquip.sid, wearEquip.quality});
		
		

		if #wearEquip.addAttr >= 6 then
			-- 基础属性小于等于身上所穿装备
			if srcEquipCfg.phyDefense <= wearEquipCfg.phyDefense and srcEquipCfg.phyAttackMin <= wearEquipCfg.phyAttackMin then
				if Equip.GetMaxFightQuality(equip) >=  Equip.GetMinFightQuality(wearEquip) + 1  then
					return true;
				end
			end
			return false;
		else
			return true;
		end
	end

	Equip.GetMaxFightQuality = function (equip)
		local fightPointList = tb.GetFightPoint(equip.career,equip.addAttr);
		local maxFP = fightPointList[1];
		local maxIndex = 1;
		for i = 1, #fightPointList do
			if maxFP < fightPointList[i] then 
				maxFP = fightPointList[i];
				maxIndex = i;
			end
		end	

		return equip.addAttr[maxIndex][3];
	end

	Equip.GetMinFightQuality = function (equip)
		local fightPointList = tb.GetFightPoint(equip.career,equip.addAttr);
		local minFP = fightPointList[1];
		local minIndex = 1;
		for i = 1, #fightPointList do
			if minFP > fightPointList[i] then 
				minFP = fightPointList[i];
				minIndex = i;
			end
		end	

		return equip.addAttr[minIndex][3];
	end

	Equip.MaxFight = function(fight)
	local max = fight[1];
		for i = 1, #fight do
			if max < fight[i] then 
				max = fight[i];
			end
		end
		return max;
	end

	Equip.MinFight = function(fight)
	local min = fight[1];
		for i = 1, #fight do
			if min > fight[i] then 
				min = fight[i];
			end
		end
		return min;
	end

    --装备排序权重 
    -- 首先类型  足够合成的橙装碎片（7）>未鉴定（6）>已鉴定（品质+1）>不足以合成的橙装碎片（0）
    --  等级  部位        状态（可装备标识（4）>可转移标识（3）>可洗炼标识（2））>普通（1） （和碎片区分开）
    Equip.getSortWeight = function(equip)
        local weightValue = const.showTypeSortWeight.equipment;
        if equip.isIdentify == const.IsIdentify.Orangesuccess then 
            weightValue = weightValue + 7 * 10000;
            weightValue = weightValue + equip.level *100;
            weightValue = weightValue + const.BuWeiChangedIndex[equip.buwei] *10;
        elseif  equip.isIdentify == const.IsIdentify.Unidentify then 
            weightValue = weightValue + 6 * 10000;
            weightValue = weightValue + equip.level *100;
            weightValue = weightValue + const.BuWeiChangedIndex[equip.buwei] *10;
        elseif  equip.isIdentify == const.IsIdentify.Orangepiece then 
            weightValue = weightValue + equip.level *100;
            weightValue = weightValue + const.BuWeiChangedIndex[equip.buwei] *10;
        else
            weightValue = weightValue + (equip.quality + 1) * 10000;
            weightValue = weightValue + equip.level *100;
            weightValue = weightValue + const.BuWeiChangedIndex[equip.buwei] *10;
            weightValue = weightValue + equip.biaoshi;
        end
        return weightValue;
    end

	Equip.sortFunc = function (equip1, equip2) 
		-- if Equip.isHighScore(equip1) then
		-- 	if Equip.isHighScore(equip2) then
		-- 		if equip1.buwei == equip2.buwei then
		-- 			if equip1.score == equip2.score then
		-- 				return equip1.id < equip2.id;
		-- 			else
		-- 				return equip1.score > equip2.score;
		-- 			end
		-- 		else
		-- 			return equip1.buwei < equip2.buwei;
		-- 		end
		-- 	else
		-- 		return true;
		-- 	end
		-- else 
		-- 	if Equip.isHighScore(equip2) then
		-- 		return false;
		-- 	end
		-- ends

		Equip.AddIdentifyBiaoshi(equip1);
		Equip.AddIdentifyBiaoshi(equip2);


		if equip1.isIdentify == equip2.isIdentify then
			--可合成的橙装碎片
			if equip1.isIdentify == const.IsIdentify.Orangesuccess then 
				if equip1.level == equip2.level then 
					if equip1.buwei == equip2.buwei then
						return equip1.id < equip2.id;

					else
						return const.BuWeiChangedIndex[equip1.buwei] < const.BuWeiChangedIndex[equip2.buwei];
					end
				else
					return  equip1.level > equip2.level;
				end
			else
				--未鉴定
				if equip1.isIdentify == const.IsIdentify.Unidentify then
					if equip1.level == equip2.level then
						if equip1.buwei == equip2.buwei then
							return equip1.id < equip2.id;

						else
							return const.BuWeiChangedIndex[equip1.buwei] < const.BuWeiChangedIndex[equip2.buwei];
						end
					else
						return equip1.level > equip2.level;
					end
				else --已鉴定
					if equip1.isIdentify == const.IsIdentify.Identified then
						--可穿戴标识>可洗炼标识>无标识
						if equip1.biaoshi == equip2.biaoshi then 
							if equip1.quality == equip2.quality then
								if equip1.level == equip2.level then
									if equip1.buwei == equip2.buwei then
										--按照获得时间的先后顺序排列
										if equip1.biaoshi == const.biaoshi.CouldWear then
											return equip1.id < equip2.id;
										end

										if equip1.biaoshi == const.biaoshi.CouldXilian then
											return Equip.MaxFight(tb.GetFightPoint(equip1.career,equip1.addAttr)) > Equip.MaxFight(tb.GetFightPoint(equip2.career,equip2.addAttr));
										end

										if equip1.biaoshi == const.biaoshi.NoAttr then
											return equip1.id < equip2.id;
										end
									else
										return const.BuWeiChangedIndex[equip1.buwei] < const.BuWeiChangedIndex[equip2.buwei];
									end 
								else
									return equip1.level > equip2.level;
								end
							else
								return equip1.quality > equip2.quality;
							end
						else
							return equip1.biaoshi < equip2.biaoshi;
						end
					else
						--橙装碎片
						if equip1.level == equip2.level then 
							if equip1.buwei == equip2.buwei then
								return equip1.id < equip2.id;

							else
								return const.BuWeiChangedIndex[equip1.buwei] < const.BuWeiChangedIndex[equip2.buwei];
							end
						else
							return  equip1.level > equip2.level;
						end
					end
				end
			end
		else
			return equip1.isIdentify < equip2.isIdentify;
		end 
	end	
	return Equip;
end

client.equip = EquipCtrl();
