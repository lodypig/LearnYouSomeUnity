function CreateSkillCtrl()
    local SkillCtrl = {};
    SkillCtrl.activeSkillList = {};
    SkillCtrl.talentList = {};
    SkillCtrl.avatarController = nil;

    SkillCtrl.usedSkilPoint = 0;

    SkillCtrl.skillLevelInfo = {
		-- 战士天赋
		[40013001] = {60,1},
		[40013002] = {70,1},
		[40013003] = {30,1},
		[40013004] = {45,1},
		-- 弓手天赋
		[40023001] = {30,1},
		[40023002] = {60,1},
		[40023003] = {70,1},
		[40023004] = {45,1},
		-- 法师天赋
		[40033001] = {30,1},
		[40033002] = {70,1},
		[40033003] = {45,1},
		[40033004] = {60,1},

		-- 法师技能
		[40031001] = {0,99},
		[40031101] = {6,99},
		[40031201] = {10,99},
		[40031301] = {20,1},
		[40031003] = {0,99},



		-- 战士技能
		[40011001] = {0,90},
		[40011101] = {6,90},
		[40011201] = {10,90},
		[40011301] = {20,1},

		[40011003] = {0,90},
		[40011005] = {0,90},

		-- 弓手技能
		[40021001] = {0,90},
		[40021101] = {6,90},
		[40021201] = {10,90},
		[40021301] = {20,1},

		[40021003] = {0,90},
		[40021005] = {0,90},
	}
	SkillCtrl.talentSid2Index = {
		[40013001] = 3,
		[40013002] = 4,
		[40013003] = 1,
		[40013004] = 2,
		[40023001] = 1,
		[40023002] = 3,
		[40023003] = 4,
		[40023004] = 2,
		[40033001] = 1,
		[40033002] = 4,
		[40033003] = 2,
		[40033004] = 3
	}
	SkillCtrl.talentSidByCareerAndIndex = {
		["soldier-1"] = 40013003,
		["soldier-2"] = 40013004,
		["soldier-3"] = 40013001,
		["soldier-4"] = 40013002,

		["bowman-1"] = 40023001,
		["bowman-2"] = 40023004,
		["bowman-3"] = 40023002,
		["bowman-4"] = 40023003,

		["magician-1"] = 40033001,
		["magician-2"] = 40033003,
		["magician-3"] = 40033004,
		["magician-4"] = 40033002
	}
	SkillCtrl.skillSid2Index = {
		[40011001] = 1,
		[40011003] = 1,
		[40011005] = 1,
		[40011201] = 2,
		[40011101] = 3,
		[40011301] = 4,

		[40021001] = 1,
		[40021003] = 1,
		[40021005] = 1,
		[40021201] = 2,
		[40021101] = 3,
		[40021301] = 4,

		[40031001] = 1,
		[40031003] = 1,
		[40031201] = 2,
		[40031101] = 3,
		[40031301] = 4,
	}
	SkillCtrl.NormalSkill = {
		["soldier"] = {40011001,40011003,40011005},
		["bowman"] = {40021001,40021003,40021005},
		["magician"] = {40031001,40031003}
	}

	-- 获取主动技能
	function SkillCtrl.getActiveSkill()		
		SkillCtrl.avatarController = Fight.GetClass(AvatarCache.me);
		for i = 1, 4 do
		  	local skill = SkillCtrl.avatarController.GetSkillByTypeAndIndex(const.skillType[i][1], const.skillType[i][2])
			SkillCtrl.activeSkillList[i] = skill;
		end
	end
	-- 根据职业获取天赋列表
	function SkillCtrl.getTalentInfoDict(career)
		local result = {};
		local t = tb.TalentTable;

		table.sort( t,function (talent1,talent2)
			if talent1.needLevel ~= talent2.needLevel then
				return talent1.needLevel < talent2.needLevel
			else
				return false
			end 
		end )

		for k, v in pairs(t) do
			if v.career == career then
				result[k] = v;
			end
		end
		return result;
	end

	-- 请求获取天赋
	function SkillCtrl.getTalent_S(cb)
		local msg = {cmd = "get_talent", role_id = DataCache.myInfo.role_uid};
		Send(msg, function (reply) SkillCtrl.onGetTalent(cb, reply) end);
	end

	-- 获取天赋回调
	function SkillCtrl.onGetTalent(cb, reply)
		for i = 1, 4 do
			local talentId = tb.GetTableByKey(SkillCtrl.talentSidByCareerAndIndex,{DataCache.myInfo.career,i});
			SkillCtrl.talentList[i] = {id = talentId, level = 0};
		end

		local msg = reply["msg"];
		for i = 1, #msg do
			local msgContent = msg[i];
			local sid = msgContent[1];
			-- local talent = SkillCtrl.avatarController:GetTalentById(sid);
			local talent = SkillCtrl.findTableInfoByValue(SkillCtrl.talentList,sid);

			local level = msgContent[2];
			talent.level = level;		
		end
		safe_call(cb);
	end

	function SkillCtrl.findTableInfoByValue(Tab,value)
		for i=1,#Tab do
			if Tab[i].id == value then
				return Tab[i];
			end
		end
	end

	-- 请求天赋升级
	function SkillCtrl.talentLevelUp_S(sid,selectIndex,callback)
		-- 判断是否已经是最高等级
		-- 原本4个天赋最高等级是20级，
		-- 现在战士{吸血 = 10级，反震 = 10级， 破甲 = 20级， 坚毅 = 20级}
		-- 现在弓手{烈弓 = 20级，狙心 = 10级， 毒箭 = 10级， 灵动 = 20级}
		-- 现在法师{连雷 = 20级，充能 = 10级， 化伤 = 20级， 静电 = 10级}
		-- local talentInfo = SkillCtrl.avatarController:GetTalentById(sid);

		local talentInfo = SkillCtrl.findTableInfoByValue(SkillCtrl.talentList,sid);
		if talentInfo.level == SkillCtrl.skillLevelInfo[sid][2] then
			ui.showMsg("该被动技能已达到等级上限!");
			return;
		end
		-- 判断天赋升级需要消耗的天赋书
		local talentLevelInfo = tb.GetTableByKey(tb.TalentLevelTable, { talentInfo.id, talentInfo.level + 1 });

		if talentLevelInfo.needLevel > DataCache.myInfo.level then
			ui.showMsg("需要角色达到" ..talentLevelInfo.needLevel.."级");
			return;
		end

		if talentLevelInfo ~= nil then
			if DataCache.talentBook < talentLevelInfo.count then
				ui.showMsg("技能点不足，无法升级!");
				return;
			end
		else
			if DataCache.talentBook == 0 then
				ui.showMsg("技能点不足，无法升级!");
				return;
			end
		end

		local msg = {cmd = "up_talent", sid = sid};
		Send(msg, function (reply)
			SkillCtrl.onTalentLevelUp(callback,sid,reply);
		end);
	end

	-- 天赋升级回调
	function SkillCtrl.onTalentLevelUp(callback,sid,reply)
		local type = reply["type"];
		if type == "success" then
			ui.showMsg("升级成功");

			-- local talentInfo = SkillCtrl.avatarController:GetTalentByIndex(selectIndex - 1);
			local talentInfo = SkillCtrl.findTableInfoByValue(SkillCtrl.talentList,sid);

			local new_level = talentInfo.level + 1;
			if new_level > SkillCtrl.skillLevelInfo[talentInfo.id][2] then
				new_level = SkillCtrl.skillLevelInfo[talentInfo.id][2];
			end
			talentInfo.level = new_level;
			-- 刷新界面显示
			SkillCtrl.usedSkilPoint = SkillCtrl.usedSkilPoint + 1; 
			safe_call(callback);
			AudioManager.PlaySoundFromAssetBundle("skill_upgrade");
		else
			--print(type);
			--print(reply["reason"])
			ui.showMsg("XXXXXXX  [错误] 天赋升级失败!!!");
		end
	end

	-- 主动技能 升级接口，使用天赋书升级
	function SkillCtrl.onSkillLevelUp(selectIndex,callback)	
		-- TODO：判断主动技能等级限制，包括天赋书数量和人物等级限制
		-- 改写主动技能升级接口，使用金币升级改为使用天赋书升级，记录技能升级消耗的天赋点，将技能升级表中消耗金币那一列重新利用，改为消耗技能点

		local skillInfo = SkillCtrl.activeSkillList[selectIndex];

		-- if not SkillUpTable[skillInfo.level + 1] then
		-- 	ui.showMsg("技能已满级");
		-- 	return;
		-- end

		if skillInfo.level == SkillCtrl.skillLevelInfo[skillInfo.id][2] then
			ui.showMsg("技能已满级!");
			return;
		end

		local levelUpInfo = SkillUpTable[skillInfo.level][selectIndex];

		if DataCache.myInfo.level < levelUpInfo.level then
			ui.showMsg("需要角色达到" ..levelUpInfo.level.."级");
			return;
		end

		if DataCache.talentBook < levelUpInfo.cost then
			ui.showMsg("技能点不足");
			return;
		end

		local msg = {cmd = "skill_up", skill_tid = skillInfo.id , skill_level = skillInfo.level};

		Send(msg,function (msgTable)
			SkillCtrl.skillUpCallback(callback,selectIndex,skillInfo.id,msgTable);
		end);
	end

	-- 获取技能等级
	function SkillCtrl.GetSkillLevel(index)
		local skillInfo = SkillCtrl.activeSkillList[index];
		return skillInfo.level;
	end

	-- 如果是升级技能，需要修改Cache.myInfo.ability和avatarController中的skill
	-- 如果是升级天赋，需要修改avatarController中talent的level
	function SkillCtrl.skillUpCallback(callback,selectIndex,skillSid,MsgTable)		
		local newLevel = MsgTable.skill_level;
		ui.showMsg("升级成功");
		--改动本地结构
		local skillInfo = SkillCtrl.activeSkillList[selectIndex];
		skillInfo.level = newLevel;

		SkillCtrl.resetSkill(skillSid, newLevel);

		-- 技能经验
		local newSkillExp = MsgTable.skill_exp;
		DataCache.myInfo.skill_exp = newSkillExp;

		AudioManager.PlaySoundFromAssetBundle("skill_upgrade");

		--刷新界面
		SkillCtrl.usedSkilPoint = SkillCtrl.usedSkilPoint + 1; 

		-- safe_call(callback);
		if callback ~= nil then
			callback(MsgTable);
		end
	end

	-- 请求技能重置（主动技能+天赋 置为1级，返还技能点）
	-- 技能重置为1级，天赋重置为1级，返还技能点
	-- 客户端需要重新设置talent和ability

	-- 技能重置回调
	function SkillCtrl.onResetSkill(callback,reply)
		local type = reply["type"];

		if type == "success" then

			local ability = DataCache.myInfo.ability;
			local career = DataCache.myInfo.career;

			-- 改动存到对应的C#结构中
			for i=1,4 do
				-- 重置技能
				if SkillCtrl.activeSkillList[i] then
					-- local index = const.skillIndex[career][i];
					-- local ability_skill = ability:get_Item(index);
					-- ability_skill:set_Item(1, 1);
					-- SkillCtrl.avatarController:SetSkillLevel(const.skillType[i][1], const.skillType[i][2], 1);
					SkillCtrl.activeSkillList[i].level = 1;

					SkillCtrl.resetSkill(SkillCtrl.activeSkillList[i].id,1);
				end

				-- 重置天赋
				-- if SkillCtrl.talentList[i].level > 0 then
				-- 	local talentInfo = SkillCtrl.avatarController:GetTalentByIndex(i - 1);
				-- 	talentInfo.level = 1;
				-- end
			end

			-- 重置天赋
			for k,v in pairs(SkillCtrl.talentList) do
				if v.level > 0 then
					v.level = 1;
				end
			end

			SkillCtrl.usedSkilPoint = 0; 
			safe_call(callback);
		end
	end

	function SkillCtrl.resetAllSkill(callback)
		local msg = {cmd = "skill_reset"};
		Send(msg, function (reply) SkillCtrl.onResetSkill(callback, reply) end);
	end

	-- 创建技能界面UI作为callback传递
	function SkillCtrl.getAllSkill(callback)
		-- 获取主动技能+天赋

		SkillCtrl.getActiveSkill();
		SkillCtrl.getTalent_S(callback)
	end

	

	function SkillCtrl.onTalentUnlock(Msg)
		local talentSid =  Msg.talent_sid
		local talentLevel = Msg.level
		local talentIndex = SkillCtrl.talentSid2Index[talentSid];

		local talentInfo = SkillCtrl.talentList[talentIndex];

		talentInfo.level = talentLevel;
		-- 刷新界面显示
		-- 播放解锁特效

		playSkillTip_Talent(talentSid, "Talent");
		EventManager.onEvent(Event.ON_TALENT_ZHUANJING_UNLOCK);
	end

	SetPort("learn_talent", SkillCtrl.onTalentUnlock);

	function SkillCtrl.canSkillUp(type,index,sid)
		if type == "skill" then
			local skillInfo = SkillCtrl.activeSkillList[index];

			if not SkillUpTable[skillInfo.level] or skillInfo.level == SkillCtrl.skillLevelInfo[skillInfo.id][2] then
				return false;
			end
			local levelUpInfo = SkillUpTable[skillInfo.level][index];
			if DataCache.myInfo.level >= levelUpInfo.level and DataCache.talentBook >= levelUpInfo.cost then
				return true;
			end
			return false;

		elseif type == "talent" then
			local talentInfo = SkillCtrl.talentList[index];
			if talentInfo.level == SkillCtrl.skillLevelInfo[sid][2] then
				return false;
			end
			local talentLevelInfo = tb.GetTableByKey(tb.TalentLevelTable, { talentInfo.id, talentInfo.level + 1 });
			if talentLevelInfo ~= nil and DataCache.talentBook >= talentLevelInfo.count and talentLevelInfo.needLevel <= DataCache.myInfo.level then
				return true;
			end
			return false;
		end
	end

	function SkillCtrl.Test()
		SkillCtrl.talentList = { {id = 40033001,level = 1},{id = 40033002,level = 0},{id = 40033003,level = 0},{id = 40033004,level = 0} };
		SkillCtrl.activeSkillList = { {unlock = true,level = 2, id = 40031001,zhuanjin = {[10000] = 2 }}, {unlock = true,level = 2, id = 40031101,zhuanjin = {[20000] = 1}},{unlock = true,level = 2, id = 40031201 ,zhuanjin = nil},{unlock = true,level = 2, id = 40031301 ,zhuanjin = nil} }
		PanelManager:CreatePanel('UISkillNew', UIExtendType.NONE, {});
	end

	function SkillCtrl.Test2( )
		local talentList = {};
		for i = 1, 4 do
			local talentId = tb.GetTableByKey(SkillCtrl.talentSidByCareerAndIndex,{DataCache.myInfo.career,i});
			talentList[i] = {id = talentId, level = 0};
		end
		for i=1,#talentList do
			--print("id="..talentList[i].id.." level="..talentList[i].level)
		end
	end

	function SkillCtrl.getActiveSkill2()		
        local career = DataCache.myInfo.career;
        local idList = const.ProfessionAbility[career];
        for i = 1,#idList do
            local skillId = idList[i];
            SkillCtrl.activeSkillList[i] = SkillCtrl.GetSkillById(skillId)
		end
	end

	function SkillCtrl.GetSkillById(skillId)
		local ability = DataCache.myInfo.ability;        
        for i= 1, #ability do
            if ability[i][1] == skillId then
                return ability[i];
            end
        end
        return nil;
	end

	-- 将技能信息写回DataCache.myInfo.ability
	function SkillCtrl.resetSkill(skillId,newLevel)
		local ability = DataCache.myInfo.ability;

		if SkillCtrl.skillSid2Index[skillId] == 1 then
			local skillIdTable  = SkillCtrl.NormalSkill[DataCache.myInfo.career];
			for i=1,#skillIdTable do
				for j= 1, #ability do
		            if ability[j][1] == skillIdTable[i] then
		                ability[j][2] = newLevel;
		            end
		        end
			end
		else
			for i= 1, #ability do
	            if ability[i][1] == skillId then
	                ability[i][2] = newLevel;
	            end
	        end
		end
	end

	-- 获取已经使用的技能点
	function SkillCtrl.getUsedSkillPoint()
		local msg = {cmd = "get_used_skill_point"};
		Send(msg, function(MsgTable) 
			SkillCtrl.usedSkilPoint = MsgTable.used_skill_point;
		end);
	end

    return SkillCtrl;
end

client.skillCtrl = CreateSkillCtrl();

-- 服务端单独记录一个技能升级消耗的技能点，返还技能点时从这里读取
-- 提供一个增加天赋书的接口，使用道具来增加天赋书，需要记录该道具使用的次数