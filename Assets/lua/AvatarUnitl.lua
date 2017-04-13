--
uAvatarUtil = {

	GetOtherPlayerModelNameByLevel = function(strCareer, gender, level)
		local suitPrefixName = string.format("%s_%s_%d", strCareer, const.sexName[gender], const.model2PrefabLevel[level])
		return string.format("%s_otherplayer_prefab", suitPrefixName)
	end,

	GetPlayerModelNameByLevel = function(strCareer, gender, level)
        local suitPrefixName = string.format("%s_%s_%d", strCareer, const.sexName[gender], const.model2PrefabLevel[level])
        return string.format("%s_Prefab", suitPrefixName);
	end,

	GetModelMaterialNameByLevel = function(strCareer, gender, level)
        return string.format("%s_%s_%d", strCareer, const.sexName[gender], const.material2PrefabLevel[level])
	end,

	GetWeaponNameByLevel = function(strCareer, level)
		return string.format("%s_%s_w", strCareer, const.weapon2PrefabLevel[level])
	end,

	GetPlayerWeaponModelName = function(equiplist)
		local weaponmodelName = ""
		if equiplist ~= nil and #equiplist > 0 then
			for k,v in pairs(equiplist) do
				local i = k
	            local avatarEquip = v
	            if avatarEquip == nil then
	            	--print("Error  Equip nil  "..i)
	            	--print(equiplist)
	            else
		            if tb.EquipTable[avatarEquip.sid] ~= nil then
			            local equipInfo = tb.EquipTable[avatarEquip.sid]
			            if equipInfo.buwei == const.BuWeiIndex["武器"] then
			            	weaponmodelName = uAvatarUtil.GetWeaponNameByLevel(const.ProfessionName2Alias[equipInfo.career], equipInfo.level)
			            end
			        end
			    end
	        end
	    end
	    return weaponmodelName
	end,

	GetWeaponBindName = function(career)
		if career == "soldier" or career == "magician" then
			return "rhand"
		else
			return "lhand"
		end
	end,

	GetPlayerModelName = function(role_info, isOtherPlayer)
		local career = const.ProfessionName2Alias[role_info.career]
		local gender = role_info.sex
		local equiplist = role_info.equipment
		local suitActivateId = role_info.suitActivateId
		-- print(career)
		-- print(gender)
		-- print(equiplist)
		return uAvatarUtil.GetPlayerModelName_Action(career, gender, equiplist, suitActivateId, isOtherPlayer)
	end,

	GetPlayerModelName_Action = function(career, gender, equiplist, suitActivateId, isOtherPlayer)
		local modelLevel = 1
		local modelName = ""
		local modelMaterialName = ""

		--获取武器模型
		local weaponmodelName = uAvatarUtil.GetPlayerWeaponModelName(equiplist)
    	--1 默认装备
        -- if isOtherPlayer == true then
        --     modelName = uAvatarUtil.GetOtherPlayerModelNameByLevel(career, gender, modelLevel)
        -- else
            modelName = uAvatarUtil.GetPlayerModelNameByLevel(career, gender, modelLevel)
        --end
        modelMaterialName = uAvatarUtil.GetModelMaterialNameByLevel(career, gender, modelLevel);
		if equiplist == nil or #equiplist <= 0 then
			return modelName, modelMaterialName, weaponmodelName
		end
		--2 从装备列表中获取
		for k,v in pairs(equiplist) do
            local avatarEquip = v
            if tb.EquipTable[avatarEquip.sid] ~= nil then
	            local equipInfo = tb.EquipTable[avatarEquip.sid]
	            if equipInfo.buwei == const.BuWeiIndex["衣服"] then
	                local level = equipInfo.level;
	                modelLevel = level;
	                -- if isOtherPlayer then
	                --     modelName = uAvatarUtil.GetOtherPlayerModelNameByLevel(career, gender, modelLevel);
	                -- else
	                    modelName = uAvatarUtil.GetPlayerModelNameByLevel(career, gender, modelLevel);
	                -- end
	                modelMaterialName = uAvatarUtil.GetModelMaterialNameByLevel(career, gender, modelLevel);
	            elseif equipInfo.buwei == const.BuWeiIndex["武器"] then
	            	weaponmodelName = uAvatarUtil.GetWeaponNameByLevel(const.ProfessionName2Alias[equipInfo.career], equipInfo.level)
	            end
	        end
        end
        
        return modelName, modelMaterialName, weaponmodelName
	end
}