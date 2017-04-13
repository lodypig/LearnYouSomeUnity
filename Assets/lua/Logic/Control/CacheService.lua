
function CacheService()
	local cacheService = {}
	cacheService.RoleInfoList = nil 		--从1开始

	local RoleSample = {
		"career",
		"dir",
		"energy",
		"hp",
		"loc",
		"logout_time",
		"offline",
		"sceneName",
		"sex",
		"tiredValue",
	}

	cacheService.SetRoleInfo = function(roleInfoList)
		local newList = {}
		if roleInfoList ~= nil and #roleInfoList ~= 0 then
			for i=1,#roleInfoList do
				local roleInfo = roleInfoList[i]
				local role = {}
				role.id = tonumber(roleInfo[1])
				local roleSample = roleInfo[2]
				role.role = {}
				local sample = roleSample[2]
				--sample
				for i=1,#RoleSample do
					if sample[i] ~= nil then
						role.role[RoleSample[i]] = sample[i]
					else
						--挫
						if i == 10 then
							role.role[RoleSample[i]] = sample.main_map
						end
					end
				end
				role.nickname = client.tools.ensureString(roleInfo[3])
				role.level = tonumber(roleInfo[4])
				role.suitID = tonumber(roleInfo[5])
				if role.suitID == nil then
					role.suitID = 0
				end
				role.yifuID = tonumber(roleInfo[6])
				role.mainWeaponID = tonumber(roleInfo[7])
				newList[#newList + 1] = role
			end
		end
		cacheService.RoleInfoList = newList
		EventManager.onEvent(Event.ON_ROLE_INFO_CHANGE)
	end

	--真是太挫了 要想办法把Cache全部移到lua中
	cacheService.SetMyInfo = function(attr)
	
		DataCache.myInfo.sid = attr.sid
		DataCache.myInfo.dir = Vector3.New(attr.dir[1], attr.dir[2], attr.dir[3])
		DataCache.myInfo.energy = attr.energy
		DataCache.myInfo.career = client.tools.ensureString(attr.career)
		DataCache.myInfo.hp = attr.hp
		DataCache.myInfo.sex = attr.sex

		--速度处理
		DataCache.myInfo.speed = attr.speed
		DataCache.myInfo.level = attr.level
		if attr.team_uid == nil then
			DataCache.myInfo.team_uid = 0
		else
			DataCache.myInfo.team_uid = attr.team_uid
		end

        DataCache.myInfo.legion_uid = attr.legion_uid or 0
        DataCache.myInfo.legion_position = attr.legion_position or 0
        DataCache.myInfo.legion_name = client.tools.ensureString(attr.legion_name or "")
        DataCache.contribution = attr.contribution or 0
        DataCache.myInfo.exp = attr.exp
   		DataCache.myInfo.money = attr.money
  		DataCache.myInfo.kill_value = attr.kill_value
		DataCache.myInfo.maxHP = attr.maxHP
		--DataCache.myInfo.max_energy = attr.max_energy
		--DataCache.myInfo.agility = attr.agility
		--DataCache.myInfo.physique = attr.physique
		DataCache.myInfo.phyAttackMin = attr.phyAttackMin or 0
		DataCache.myInfo.phyAttackMax = attr.phyAttackMax or 0
        DataCache.myInfo.phyAttack = attr.phyAttack
		DataCache.myInfo.phyDefense = attr.phyDefense
		--DataCache.myInfo.power = attr.power
		--DataCache.myInfo.endurance = attr.endurance
		DataCache.myInfo.hit = attr.hit
		DataCache.myInfo.dodge = attr.dodge
		DataCache.myInfo.critical = attr.critical
		DataCache.myInfo.tenacity = attr.tenacity

		--DataCache.myInfo.fight_state_time = attr.fight_state_time
		--DataCache.myInfo.id = attr.id
		DataCache.myInfo.role_uid = attr.role_uid
		--DataCache.myInfo.pos = Vector3.New(attr.pos[1], attr.pos[2], attr.pos[3])
		DataCache.myInfo.name = client.tools.ensureString(attr.name)
		DataCache.myInfo.grey_name_time = attr.grey_name_time


		--DataCache.myInfo.camp = attr.camp
		--DataCache.myInfo.style = attr.style
		-- DataCache.myInfo.style_scale = attr.style_scale
		-- DataCache.myInfo.sleep_time = attr.sleep_time
		-- DataCache.myInfo.obstacle_mask = attr.obstacle_mask
		-- DataCache.myInfo.display_type = attr.display_type
		DataCache.myInfo.pk_mode = client.tools.ensureString(attr.pk_mode)
		DataCache.myInfo.imba_state = attr.imba_state
		DataCache.myInfo.brokenBlock = attr.brokenBlock
		DataCache.myInfo.block = attr.block
		DataCache.myInfo.damageAmplifyP = attr.damageAmplifyP
		DataCache.myInfo.damageResistP = attr.damageResistP
		DataCache.myInfo.defenseReduceP = attr.defenseReduceP
		DataCache.myInfo.attackReduceP = attr.attackReduceP
		DataCache.myInfo.fightPoint = attr.fightPoint
		DataCache.myInfo.offline = attr.offline == 1

		--arraylist
		-- DataCache.myInfo.ability = client.tools.parseArrayList(attr.ability)
		DataCache.myInfo.equipment = client.tools.parseArrayList(attr.equipment)
		DataCache.myInfo.sceneName = client.tools.parseArrayList(attr.sceneName)
		DataCache.myInfo.buffer_lis = client.tools.parseArrayList(attr.buffer_list)
		DataCache.myInfo.fightHPRecover = attr.fightHPRecover
		DataCache.myInfo.freeHPRecover = attr.freeHPRecover
		-- 疲劳值
		DataCache.myInfo.tiredValue = attr.tiredValue;

		-- client.StoneNumberTable[attr.sid] = attr.energy_stone;

		if attr.moneyBuyCount == nil then
			attr.moneyBuyCount = {};
		end
		if #attr.moneyBuyCount == 0 then
			attr.moneyBuyCount[1] = 0;
		end
		client.userCtrl.buyMoneyInfo = attr.moneyBuyCount;

		if attr.tiredClearCount == nil then
			attr.tiredClearCount = {};
		end
		if #attr.tiredClearCount == 0 then
			attr.tiredClearCount[1] = 0;
		end
		DataCache.myInfo.tiredClearCount = client.tools.parseArrayList(attr.tiredClearCount);
		

        DataCache.myInfo.siteRebirthCount = attr.rebornCount[1];
        DataCache.myInfo.lastSiteRebirthTime = attr.rebornCount[2];

        DataCache.myInfo.multiDeathCount = attr.roleMultiDeathInfo[1];
        DataCache.myInfo.multiDeathTime = attr.roleMultiDeathInfo[2];

        -- 时装
        if attr.suitActivateId == nil then

        	DataCache.myInfo.suitActivateId = FashionSuit.getNewerSuitId();
        else
			DataCache.myInfo.suitActivateId = attr.suitActivateId;
		end


		DataCache.myInfo.horse = attr.horse		

	end

	return cacheService
end

client.cacheService = CacheService();