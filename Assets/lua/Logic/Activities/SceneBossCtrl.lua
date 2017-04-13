	function CreateSceneBossCtrl()
	local sceneboss = {}
    local awardPanelDelay = 3;
    local belong_you = false;
    local belong_other = true;
	--------------------------监听函数----------------------------
	sceneboss.listen_scene_boss_award = function(msg)
        sceneboss.awardMsg = msg;
        sceneboss.showAwardTimer = Timer.New(sceneboss.createAwardPanel, awardPanelDelay, 0, true);
        sceneboss.showAwardTimer:Start();
	end

    sceneboss.createAwardPanel = function()
    	local hurt_rank = sceneboss.awardMsg["hurt_rank"]
		local my_rank = sceneboss.awardMsg["my_rank"]
		local my_award = sceneboss.awardMsg["my_award"]
        PanelManager:CreateConstPanel('UIBossReward', UIExtendType.NONE, {hurtrank = hurt_rank, myrank = my_rank, myaward = my_award});  
    end

	sceneboss.listen_gain_equip = function(msg)
		local equips = msg["equip"]
		for _,v in pairs(equips) do
			local equipId = v[1]
			local equipPro = tb.EquipTable[equipId]
			--物品链接TODO
			--ui.showMsg(string.format("你获得了%s", equipPro.name))
		end
	end

	sceneboss.itemInTable = function(item, list)
		for i,v in ipairs(list) do
			if v == item then
				return true;
			end
		end
		return false;
	end
	sceneboss.listen_scene_belong_action = function(msg)
		local roleList = msg["belong_list"]; 
		local npcSid = msg["sid"];
		local success = msg["success"];
		local str = nil;
		local name = client.tools.formatRichTextColor(tb.NPCTable[npcSid].name, const.mainChat.specialColor);
		if success then
			if not sceneboss.itemInTable(DataCache.roleID, roleList) then
				if not belong_other then
					local msgstr = ""
					if DataCache.myInfo.team_uid ~= 0 then
						str = "你的队伍失去了"..name.."的归属权";
						msgstr = "你的队伍失去了"..tb.NPCTable[npcSid].name.."的归属权";
					else
						str = "你失去了"..name.."的归属权";
						msgstr = "你失去了"..tb.NPCTable[npcSid].name.."的归属权";
					end
					client.chat.clientSystemMsg(str, nil, nil, "team", true)
					ui.showMsg(msgstr);
				end
				belong_you = false;
				belong_other = true;
				UIManager.GetInstance():CallLuaMethod('MainUI.lostBelong');
			else
				if not belong_you then
					local msgstr = ""
					if DataCache.myInfo.team_uid ~= 0 then
						str = "你的队伍获得了"..name.."的归属权";
						msgstr = "你的队伍获得了"..tb.NPCTable[npcSid].name.."的归属权";
					else
						str = "你获得了"..name.."的归属权";
						msgstr = "你获得了"..tb.NPCTable[npcSid].name.."的归属权";
					end
					client.chat.clientSystemMsg(str, nil, nil, "team", true)
					ui.showMsg(msgstr);
				end
				belong_you = true;
				belong_other = false;
				UIManager.GetInstance():CallLuaMethod('MainUI.getBelong');
			end
		end
	end

	sceneboss.listen_refresh_boss = function(msg)
		local npcsid = msg["sid"];
		local mapid = msg["map"];
		local Pos = msg["pos"];
        local fenxian = msg["fenxian"];
		local bossName = client.tools.formatRichTextColor(tb.NPCTable[npcsid].name, const.mainChat.specialColor);
		local mapname = tb.SceneTable[mapid].name;
		local maplocation = ""
		--解析location
		maplocation = string.format("[%s,%d,%d,%d]", mapname, fenxian, Pos[1]*2, Pos[3]*2);	
		local str = string.format("%s已出现在%s，各位勇士可前往击杀！", bossName, maplocation);
		-- boss刷新后归属清空
		belong_you = false;
    	belong_other = true;
    	if tb.SceneTable[mapid].level <= DataCache.myInfo.level then 
			client.chat.clientSystemMsg(str, nil, nil, "world");
		end
	end

	sceneboss.get_guishu = function()
		local bossName = tb.ActivitiesInfoTable["sceneBoss"..DataCache.scene_sid].bossName; 
		if belong_you then
			if DataCache.myInfo.team_uid ~= 0 then
				ui.showMsg("你的队伍已获得"..bossName.."的归属权");
			else
				ui.showMsg("你已获得"..bossName.."的归属权");
			end
		else
			if DataCache.myInfo.team_uid ~= 0 then
				ui.showMsg("你的队伍未获得"..bossName.."的归属权");
			else
				ui.showMsg("你未获得"..bossName.."的归属权");
			end
		end
	end

	sceneboss.get_boss_info = function(reply)
		local info = reply["hp_list"];
		activity.BossStateList = info;
	end

	SetPort("gain_equip", sceneboss.listen_gain_equip)
	SetPort("scene_boss_award", sceneboss.listen_scene_boss_award)
	SetPort("belong",sceneboss.listen_scene_belong_action);
	SetPort("refresh_boss", sceneboss.listen_refresh_boss);
	--通用活动事件
	SetPort("boss_hp_info", sceneboss.get_boss_info);


	sceneboss.ActivityStart = function()
		-- client.WorldBoard.ShowWorldMsg(str);
		-- client.chat.clientSystemMsg(str);
	end

	return sceneboss

end

client.sceneboss = CreateSceneBossCtrl();
ActivityMap.sceneboss = client.sceneboss;