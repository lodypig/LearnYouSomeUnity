function CreateRedPointCtrl()
	local RedPoint = {};

	-- 主动技能/天赋 可以提升	
	function RedPoint.Skill()    
        if DataCache.talentBook == nil or DataCache.talentBook == 0 or DataCache.myInfo.level < 10 then
        	return false;
        end

        -- 判断主界面/主菜单技能红点使用 DataCache.myInfo.ability中技能信息，技能UI显示使用AvatarCache.me中的技能信息
        local ability = DataCache.myInfo.ability;  
       	-- DataStruct.DumpTable(ability);      
        for i= 1, #ability do
        	local skillSid = ability[i][1];
        	local skillLevel = ability[i][2];
        	local skillIndex = client.skillCtrl.skillSid2Index[skillSid];
			if SkillUpTable[skillLevel] and client.skillCtrl.skillLevelInfo[skillSid] and client.skillCtrl.skillLevelInfo[skillSid][2] ~= skillLevel then
	        	local levelUpInfo = SkillUpTable[skillLevel][skillIndex];

	        	-- DataStruct.DumpTable(levelUpInfo)

	        	if DataCache.myInfo.level >= levelUpInfo.level and DataCache.talentBook >= levelUpInfo.cost then
	        		-- print(DataCache.myInfo.level.." "..levelUpInfo.level.." "..DataCache.talentBook.." "..levelUpInfo.cost)
	        		-- print("111111111111")
	        		return true;
	        	end
			end
        end

		for i=1,4 do
			-- local activeSkillInfo = client.skillCtrl.activeSkillList[i];

			-- if activeSkillInfo  and activeSkillInfo.unlock and client.skillCtrl.canSkillUp("skill", i) then
			-- 	return true
			-- end
			local talentInfo = client.skillCtrl.talentList[i];
			if talentInfo and talentInfo.level > 0 and client.skillCtrl.canSkillUp("talent", i, talentInfo.id) then
				-- print("2222222222222")
				return true;
			end
		end
        return false;
	end

	-- 宝石是否可以合成
	function RedPoint.GemCanUpGrade()
		local equip;
		for i = 1, #Bag.enhanceMap do					
			equip = Bag.wearList[i];
			if equip then
				local gemList = client.gem.getEquipGem(i);
				for i = 1, #gemList do
					if client.gem.couldUp(gemList[i].sid) then
						return true;
					end
				end
			end
		end
		return false;
	end
	-- 宝石是否可以镶嵌
	function RedPoint.GemCanPutOn()
		for i = 1, #Bag.enhanceMap do					
			local equip = Bag.wearList[i];
			if equip then
				if Bag.getWearEquip(i) ~= nil and client.gem.checkHigh(i) then
					return true
				end
			end
		end
		return false;
	end
	-- 装备是否可以强化
	function RedPoint.EquipCanEnhance()
		for i = 1, #Bag.enhanceMap do					
			local equip = Bag.wearList[i];
			if equip then
				if Bag.getWearEquip(i) ~= nil and client.enhance.canEnhanceByIndex(i) then
					return true;
				end
			end
		end
		return false;
	end
	-- 坐骑是否可以培养/进阶

	function RedPoint.HorseCanTrainOrEnhance()
		for i=1,#client.horse.horseTableCache do
			local horseTable = client.horse.horseTableCache[i];
			local horse = client.horse.getHorse(horseTable.sid);


			if horse ~= nil and not client.horse.isMaxEnhance(horse) then
				local horseCfg = tb.HorseTable[horse.sid];

				if client.horse.isMaxStar(horse.sid) then
					if client.horse.checkCouldEnhance(horse) then
						return true;
					end
				else
					if client.horse.checkCouldTrain(horse) then
						return true;
					end
				end
			end
		end
		return false;
	end
	-- 坐骑是否可以解锁
	function RedPoint.HorseCanUnlock()
		for i=1,#client.horse.horseTableCache do
			local horseTable = client.horse.horseTableCache[i];
			local horse = client.horse.getHorse(horseTable.sid);
			if horse == nil and client.horse.checkUnlockFunc[horseTable.active_type](horseTable) then
				return true;
			end
		end
		return false;
	end

	-- 背包中是否有显示“可穿戴”装备
	function RedPoint.CanPutOnBetterEuip()
		if Bag.isBagFull() then  -- 背包满时不显示红点
			return false;
		end
		local equipList = Bag.GetShowEquip();
		for i=1,#equipList do
			local equip = equipList[i];
			if equip.biaoshi ~= nil and (equip.biaoshi == const.biaoshi.CouldWear or equip.biaoshi == const.biaoshi.CouldXilian or equip.biaoshi == const.biaoshi.CouldZhuanyi) and equip.level <= DataCache.myInfo.level then
				return true;
			end
		end
		return false;
	end

	return RedPoint;
end
client.redPoint = CreateRedPointCtrl();