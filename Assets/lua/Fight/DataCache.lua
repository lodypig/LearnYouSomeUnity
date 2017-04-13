Gender = {};
Gender.Female = 0;
Gender.Male = 1;

-- 数据缓存
function CreateDataCache()
	local t = {};

	t.scene_sid = 0;			-- 当前场景的 sid
	t.fenxian = 0;				-- 当前分线
	t.molong_pk_mode = "fangwei";
	t.myInfo = {};
	t.contribution = 0;
	t.settings = {};			-- 系统设置

	t.getSceneTable = function ()
		return tb.SceneTable[t.scene_sid];
	end

	-- 解析玩家信息
	t.CachePlayerInfo = function (info, attr)
		t.ParseInfo(info);
		t.ParseAttr(attr, t.myInfo);
	end;

	-- 解析信息
	t.ParseInfo = function (info)
		--local myInfo = t.myInfo;
		--myInfo.id = info.id;
	end;


	t.CopyAttrs = function (cache, attrs)
		for k, v in pairs(attrs) do
			cache[k] = v;
		end
	end;

	-- 解析更新属性
	t.ParseUpdateAttrs = function (cache, attrs)
		for i = 1, #attrs do
			local attr = attrs[i];
			local name = attr[1];
			local value;
			if name == "equipment" then
				value = t.ParseEquipment(attr[2]);
			elseif name == "fightPoint" then
				value = math.floor(attr[2]);
			else
				value = attr[2];
			end
			if value ~= nil then
				cache[name] = value;
			end
		end
	end;

	t.ParseEquipment = function (equipment)
		if equipment == nil then
			return
		end
		local equip_list = {};
		local equipment_info = equipment;
		for i = 1, #equipment_info do

			local equip_info = equipment_info[i];
			if type(equip_info) == "table" then

				local equip = {};
				equip.sid = equip_info[1];
				local table = tb.EquipTable[equip.sid];
				local equip_attr_info = equip_info[2];

		        equip.addAttr = equip_attr_info[1];	
				equip.baseAttr = equip_attr_info[2];	
				equip.count = equip_attr_info[3]
				equip.forgeAttr = equip_attr_info[4];
				equip.id = equip_attr_info[5];
				equip.maxcount = equip_attr_info[6]	
				equip.quality = equip_attr_info[7];
				equip.recoveryTime = equip_attr_info[8];
				equip.tempAttr = equip_attr_info[9];
				
				equip.level = table.level;	
				equip.career = table.career;	
				equip.buwei = table.buwei;
				equip.name = table.name;

				equip_list[i] = equip;
			else
				equip_list[i] = nil;
			end
		end
		return equip_list;
	end;

	t.parseGemList = function(gemList)
		local list = {};
		local i;
		for i = 1, #gemList do
			list[i] = client.gem.parse(gemList[i]);
		end
		return list;
	end

	t.ParseGem = function(gemList)
		local i;
		local equipGemMap = {};
		for i = 1, #gemList do
			equipGemMap[gemList[i][1][2]] = t.parseGemList(gemList[i][2]);
		end
		return equipGemMap;
	end


	-- 解析属性
	t.ParseAttr = function (attr, Info)
		Info.sid = attr.sid

		-- 方向
		if attr.dir ~= nil then
			Info.dir = {};
			Info.dir.x = attr.dir[1];
			Info.dir.y = attr.dir[2];
			Info.dir.z = attr.dir[3];
		end

		-- 能量
		Info.energy = attr.energy

		-- 职业
		Info.career = client.tools.ensureString(attr.career)

		-- hp
		Info.hp = attr.hp

		-- 性别
		Info.sex = attr.sex
		
		-- 速度
		Info.speed = attr.speed
		Info.level = attr.level

		if attr.team_uid == nil then
			Info.team_uid = 0
		else
			Info.team_uid = attr.team_uid
		end

        Info.legion_uid = attr.legion_uid or 0
        Info.legion_position = attr.legion_position or 0
        Info.legion_name = client.tools.ensureString(attr.legion_name or "")
        t.contribution = attr.contribution or 0
        Info.exp = attr.exp
        Info.skill_exp = attr.skill_exp;
        
   		Info.money = attr.money
  		Info.kill_value = attr.kill_value
		Info.maxHP = attr.maxHP
		Info.phyAttackMin = attr.phyAttackMin or 0
		Info.phyAttackMax = attr.phyAttackMax or 0
        Info.phyAttack = attr.phyAttack
		Info.phyDefense = attr.phyDefense
		Info.hit = attr.hit
		Info.dodge = attr.dodge
		Info.critical = attr.critical
		Info.tenacity = attr.tenacity;
		Info.fight_state_time = (attr.fight_state_time == nil) and 0 or attr.fight_state_time;
		Info.role_uid = attr.role_uid

		-- 位置信息
		if attr.loc ~= nil then
			Info.pos = {};
			Info.pos.x = attr.loc[1];
			Info.pos.y = attr.loc[2];
			Info.pos.z = attr.loc[3];
		end

		-- 名字
		Info.name = client.tools.ensureString(attr.name)
		-- 灰名
		Info.grey_name_time = attr.grey_name_time
		Info.pk_mode = client.tools.ensureString(attr.pk_mode)
		Info.imba_state = attr.imba_state
		Info.brokenBlock = attr.brokenBlock

		Info.block = attr.block
		Info.damageAmplifyP = attr.damageAmplifyP
		Info.damageResistP = attr.damageResistP
		Info.defenseReduceP = attr.defenseReduceP
		Info.attackReduceP = attr.attackReduceP
		if attr.fightPoint ~= nil then
			Info.fightPoint = math.floor(attr.fightPoint);
		end
		Info.offline = attr.offline == 1

		--arraylist
		Info.ability = attr.ability; -- client.tools.parseArrayList(attr.ability)
		Info.equipment = t.ParseEquipment(attr.equipment);
		Info.enhance = attr.enhance;
		if attr.gemlist ~= nil then
			Info.gemMap = t.ParseGem(attr.gemlist);
		end
		-- Info.sceneName = client.tools.parseArrayList(attr.sceneName)
		-- Info.buffer_lis = client.tools.parseArrayList(attr.buffer_list)
		Info.fightHPRecover = attr.fightHPRecover
		Info.freeHPRecover = attr.freeHPRecover

		-- 体力值
		Info.muscleValue = attr.muscleValue;
		Info.maxMuscleValue = attr.maxMuscleValue;
		Info.lastMuscleRTime = attr.lastMuscleRTime;

		-- 疲劳值
		Info.tiredValue = attr.tiredValue;
		Info.lastLiemoRTime = attr.lastLiemoRTime;
		
		if attr.moneyBuyCount == nil then
			attr.moneyBuyCount = {};
		end
		if #attr.moneyBuyCount == 0 then
			attr.moneyBuyCount[1] = 0;
		end
		Info.moneyBuyCount = attr.moneyBuyCount;

		if attr.tiredClearCount == nil then
			attr.tiredClearCount = {};
		end
		if #attr.tiredClearCount == 0 then
			attr.tiredClearCount[1] = 0;
		end
		Info.tiredClearCount = client.tools.parseArrayList(attr.tiredClearCount);

		if attr.rebornCount ~= nil then
		    Info.siteRebirthCount = attr.rebornCount[1];
		    Info.lastSiteRebirthTime = attr.rebornCount[2];
		end

		if attr.roleMultiDeathInfo ~= nil then
	        Info.multiDeathCount = attr.roleMultiDeathInfo[1];
	        Info.multiDeathTime = attr.roleMultiDeathInfo[2];
	    end
        if attr.suitActivateId == nil then
        	Info.suitActivateId = FashionSuit.getNewerSuitId();
        else
			Info.suitActivateId = attr.suitActivateId;
		end
		Info.horse = attr.horse			
	end;

	-- --解析其他玩家强化属性
	-- t.ParseEnhanceInfo = function(equipment)
	-- 	local enhanceMap = {};
	-- 	local equipSample = equipment[2];	
	-- 	local temp = equipSample[2];
	-- 	temp = temp[1];		
	-- 	local enhanceList = temp[2];

	-- 	local info;
	-- 	for i = 1, #enhanceList do
	-- 		local slot = {};
	-- 		info = enhanceList[i];
	-- 		slot.buwei = info[1];
	-- 		slot.level = info[2];		
	-- 		enhanceMap[slot.buwei] = slot;
	-- 	end
	-- 	return enhanceMap;
	-- end



	return t;
end

DataCache = CreateDataCache();