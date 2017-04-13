function CreateGameSceneManager()

	local t = {};

	t.handlers = {};


	------------------------------------------------------------------
	-- node_added
	------------------------------------------------------------------

	t.node_added_handlers = {};

	-- 添加其他玩家
	t.AddOtherPlayer = function (value)
		
		local msg = Parser.ParseKVMessage(value);
		-- 当前角色是否存在
		if AvatarCache.HasAvatar(msg.id) then
			return;
		end
		local energy_stone_info = msg.energy_stone;
		if energy_stone_info ~= nil then
			local energy_stone = energy_stone_info;
			client.gcm.InitStoneNumber(msg.id, energy_stone);
		end

		InstanceManager.AddOtherPlayer(msg.id, msg.pos, msg, function (msg, ds, title)
			ds["role_type"] = RoleType.OtherPlayer;
			ds["is_destroyed"] = false;
			ds["move_speed"] = 5;
			local size_x = 1;
			local size_y = 2;
			local size_z = 1;
			local id = msg.id;
			local class = Fight.GetClass(ds);
			class.ParseData(ds, msg);
			Fight.BuildOtherPlayerTitle(ds, title);
			class.UpdateTitleRedName(ds, title);
			uFacadeUtility.AddBoxCollider(id, 0, 0.5 * size_y, 0, size_x, size_y, size_z);
			uFacadeUtility.SetAvatarLayer(id, "Player");
			class.PutOnEquips(ds, ds.equipment, function () end);
		end);
	end;

	-- 添加真实玩家
	t.node_added_handlers["player"] = function (msg)
		t.AddOtherPlayer(msg);
	end;

	-- 添加离线玩家
	t.AddOfflinePlayer = function (value)
		local msg = Parser.ParseKVMessage(value);
		if AvatarCache.HasAvatar(msg.id) then
			return;
		end
		local energy_stone_info = msg.energy_stone;
		if energy_stone_info ~= nil then
			local energy_stone = energy_stone_info;
			client.gcm.InitStoneNumber(msg.id, energy_stone);
		end
		InstanceManager.AddOfflinePlayer(msg.id, msg.pos, msg, function (msg, ds, title)
			ds["role_type"] = RoleType.OfflinePlayer;
			ds["is_destroyed"] = false;
			ds["move_speed"] = 5;
			local size_x = 1;
			local size_y = 2;
			local size_z = 1;
			local id = msg.id;
			--print("[offline_player] 1");
			local class = Fight.GetClass(ds);
			class.ParseData(ds, msg);
			-- print(msg)
			Fight.BuildOfflinePlayerTitle(ds, title);
			class.UpdateTitleRedName(ds, title);
			uFacadeUtility.AddBoxCollider(id, 0, 0.5 * size_y, 0, size_x, size_y, size_z);
			--print("[offline_player] 3");
			uFacadeUtility.SetAvatarLayer(id, "Player");
			--print("[offline_player] 4");
			--DataStruct.DumpTable(msg);
			--DataStruct.DumpTable(ds.equipment);
			class.PutOnEquips(ds, ds.equipment, function () end);
			--print("[offline_player] 5");
		end);
	end;

	-- 添加离线玩家
	t.node_added_handlers["offline_player"] = function (msg)
		t.AddOfflinePlayer(msg);
	end;

	-- 添加 npc
	t.node_added_handlers["npc"] = function (value)
		
		local msg = Parser.ParseKVMessage(value);

		local id = msg.id;
		local sid = msg.sid;
		local pos = msg.pos;
		local dir = msg.dir;
		local style = msg.style;

		-- print("add npc: " .. id);

		if id ~= 0 and sid ~= 0 then
			local npcInfo = tb.NPCTable[sid];
			local npcType = npcInfo.type;
			if npcType < 100 then
				-- 创建世界 Boss
				if npcType == commonEnum.NpcType.NpcType_Boss then
					local rawLogicStr = npcInfo.style;
					local head = string.upper(string.sub(rawLogicStr,1,1));
					local tail = string.sub(rawLogicStr,2,string.len(rawLogicStr))
					local Logic = head..tail;
					--print("Logic:"..Logic);
					-- 世界Boss
					InstanceManager.AddWorldBoss(id, sid, Logic, pos, msg, function (msg, ds, title)
						ds["role_type"] = RoleType.WorldBoss;
						ds["is_destroyed"] = false;
						ds["move_speed"] = 5;
						local class = Fight.GetClass(ds);
						class.ParseData(ds, msg);
						Fight.BuildMonsterTitle(ds, title);
						class.SetSpecialMonsterTitle("WorldBoss", title)
						class.AdjustTitleHeight(ds);
						class.AddBoxCollider(ds);
						class.AdjustScale(ds);
						uFacadeUtility.SetAvatarLayer(id, "NPC");
						-- print("Create Kuangnuqishi!!!!!")
						-- print(ds.id)
						-- print(ds.sid)
						Utility.AddFollowEffect(ds);
					end);

				-- 创建副本 Boss
				elseif npcType == commonEnum.NpcType.NpcType_FBBoss then

					-- 副本Boss
					InstanceManager.AddFubenBoss(id, sid, "Jiangongdifeiya", pos, msg, function (msg, ds, title)
						ds["role_type"] = RoleType.FubenBoss;
						ds["is_destroyed"] = false;
						ds["move_speed"] = 5;
						local class = Fight.GetClass(ds);
						Fight.BuildMonsterTitle(ds, title);
						class.SetSpecialMonsterTitle("FubenBoss", title)
						class.AdjustTitleHeight(ds);
						class.AddBoxCollider(ds);
						class.AdjustScale(ds);
						uFacadeUtility.SetAvatarLayer(id, "NPC");
						Utility.AddFollowEffect(ds);
					end);

				elseif npcType == commonEnum.NpcType.NpcType_Guide then
					-- 引导Npc
					InstanceManager.AddGuideNpc(id, sid, npcInfo.style, pos, msg, function (msg, ds, title)
						ds["role_type"] = RoleType.GuideNpc;
						ds["is_destroyed"] = false;
						ds["move_speed"] = 5;

						--掠夺NPC的一些属性设置
						ds["treasure_number"] = 15;
						ds["kill_value"] = 0;
						ds["grey_name_time"] = 0;
						msg.sex = 1;
						msg.career = "soldier"

						local class = Fight.GetClass(ds);
						class.ParseData(ds, msg);
						Fight.BuildOtherPlayerTitle(ds, title);
						class.OnInitSelect(ds);
						class.AdjustTitleHeight(ds);
						class.AddBoxCollider(ds);
						class.AdjustScale(ds);
						uFacadeUtility.SetAvatarLayer(id, "NPC");
						Utility.AddFollowEffect(ds);
					end);
				else
					if msg.activeFlag == nil then
						-- 创建怪物
						InstanceManager.AddMonster(id, sid, pos, msg, function (msg, ds, title)
							ds["role_type"] = RoleType.Monster;
							ds["is_destroyed"] = false;
							ds["move_speed"] = 5;

							local class = Fight.GetClass(ds);
							class.ParseData(ds, msg);
							Fight.BuildMonsterTitle(ds, title);
							class.OnInitSelect(ds);

							if ds.sid ~= nil and tb.NPCTable[ds.sid] ~= nil then
								if tb.NPCTable[ds.sid].showtitle == commonEnum.TitleType["HeadTitle_CBTMonster"] then
									class.SetSpecialMonsterTitle("CBTMonster",title)
								end
					    	end

							class.AdjustTitleHeight(ds);
							class.AddBoxCollider(ds);
							class.AdjustScale(ds);
							uFacadeUtility.SetAvatarLayer(id, "NPC");
							Utility.AddFollowEffect(ds);
						end);

					else

						-- 创建怪物
						InstanceManager.AddEliteMonster(id, sid, pos, msg, function (msg, ds, title)
							ds["role_type"] = RoleType.EliteMonster;
							ds["is_destroyed"] = false;
							ds["move_speed"] = 5;

							local class = Fight.GetClass(ds);
							class.ParseData(ds, msg);
							Fight.BuildMonsterTitle(ds, title);
							class.OnInitSelect(ds);
							class.SetSpecialMonsterTitle("EliteMonster", title)
							class.AdjustTitleHeight(ds);
							class.AddBoxCollider(ds);
							class.AdjustScale(ds);
							uFacadeUtility.SetAvatarLayer(id, "NPC");

							local activeFlag = ds.activeFlag;
							if activeFlag == true then
								uFacadeUtility.ActiveShader(id, 0);
							else
								uFacadeUtility.ActiveShader(id, 1);
							end
							Utility.AddFollowEffect(ds);
						end);

					end
				end

			elseif npcType == commonEnum.NpcType.NpcType_Interaction then
				-- 采集 NPC
				InstanceManager.AddNpc(id, sid, style, pos, msg, function (msg, ds, title)
					
					ds["role_type"] = RoleType.Npc;
					ds["is_destroyed"] = false;
					ds["move_speed"] = 5;
					
					local class = Fight.GetClass(ds);
					class.ParseData(ds, msg);
					Fight.BuildNpcTitle(ds, title);

					class.OnInitSelect(ds);
					class.AdjustTitleHeight(ds);
					class.AddBoxCollider(ds);
					class.AdjustScale(ds);
					uFacadeUtility.SetAvatarLayer(id, "NPC");

					-- 交互 npc 有任务状态
					local npcSid = ds.sid;
					if InteractionManager.HasTaskState(npcSid) then
						local taskState = InteractionManager.GetTaskState(npcSid);
						class.ShowTaskState(ds, taskState);
					else
						class.HideAllTaskStates(ds);
					end

					InteractionManager.AddNpc(ds);

					class.AddClickListener(function (ds)
						local npcSid = ds.sid;
						InteractionManager.OnClick(npcSid,id);
					end);

					class.SetDetectScopeEnable(ds, true);
					class.AddEnterScopeListener(function (ds)
						local npcSid = ds.sid;
						InteractionManager.FireEnterCallBack(npcSid)
				    end);
				    class.AddLeaveScopeListener(function (ds)
				    	local npcSid = ds.sid;
				    	InteractionManager.FireLeaveCallBack(npcSid)
				    end);
				    --update dir
				    ds["dir_x"] = dir[1]
					ds["dir_y"] = dir[2]
					ds["dir_z"] = dir[3]
					local direction = Vector3.ProjectOnPlane(Vector3.New(dir[1], dir[2], dir[3]), Vector3.up):Normalize()
					if direction ~= Vector3.zero then
						uFacadeUtility.RotateToPos(id, ds["pos_x"] + direction.x, ds["pos_y"] + direction.y, ds["pos_z"] + direction.z);
					end

					t.HandleShowAvatar(sid)
				end);

			elseif npcType == commonEnum.NpcType.NpcType_Trigger then
				--这里判断一下有没有同名的脚本，是否要自定义状态机行为			
				-- 触发器
				InstanceManager.AddTransport(id, sid, pos, msg, function (msg, ds, title)
					local npcSid = ds.sid;
					local script = tb.NPCTable[npcSid].script;
					local class = Fight.GetClass(ds);
					-- print("InstanceManager.AddTransport:"..id)
					class.ParseData(ds, msg);
					Fight.BuildNpcTitle(ds, title);
					-- DataStruct.DumpTable(msg)
					--class.OnInitSelect(ds);
					--class.AdjustTitleHeight(ds);
					--class.AddBoxCollider(ds);
					ds["role_type"] = RoleType.Npc;
					class.AdjustScale(ds);
					uFacadeUtility.SetAvatarLayer(id, "NPC");

					-- 特殊处理过图点，只有两米的范围
					if npcSid == 10010054 then
						ds.scope_detect_radius = 2.0;
					end

					if tb.NPCTable[npcSid].canclick == true then
						class.AddBoxCollider(ds);
					end
					-- if script == "PortalCrystal" then
					-- 	script = PortalCrystal;
					-- elseif script == "cbtMJCtrl" then
					-- 	script = cbtMJCtrl;
					-- else
					-- 	script = nil
					-- end
					script = _G[script];
					if script == nil then
						return;
					end

					if script.Start ~= nil then
						script.Start(ds);
					end

					class.SetDetectScopeEnable(ds, true);

					class.AddClickListener(function (ds)
						if script.OnClick ~= nil then
							script.OnClick(ds)
						end
					end);

					class.AddEnterScopeListener(function (ds)
						if script.Enter ~= nil then
							script.Enter(ds)
						end
				    end);

				    class.AddLeaveScopeListener(function (ds)
				    	script.Leave(ds)
				    end);

				    class.AddStayScopeListener(function (ds)
				    	script.Stay(ds)
				    end);
				end);

			elseif npcType == commonEnum.NpcType.NpcType_Gather then

				-- 交互npc, visible_character
				-- 1: 所有玩家可见
				-- 2: 有任务玩家可见
				-- 3: 指定奖励归属玩家可见
				if npcInfo.visible_character == 1 or
				   npcInfo.visible_character == 2 or
				   npcInfo.visible_character == 3 then
					
					InstanceManager.AddNpc(id, sid, style, pos, msg, function (msg, ds, title)
						
						ds["role_type"] = RoleType.Npc;
						ds["is_destroyed"] = false;
						ds["move_speed"] = 5;

						local class = Fight.GetClass(ds);
						class.ParseData(ds, msg);
						Fight.BuildNpcTitle(ds, title);
						
						class.OnInitSelect(ds);
						class.AdjustTitleHeight(ds);
						class.AddBoxCollider(ds);
						class.AdjustScale(ds);
						uFacadeUtility.SetAvatarLayer(id, "NPC");

						InteractionManager.AddNpc(ds);

						if InteractionManager.GetTaskState(sid) == TaskNoticeType.Resource then
							class.SetDetectScopeEnable(ds, true);
						else
							class.SetDetectScopeEnable(ds, false);
						end
					    class.AddEnterScopeListener(function (ds)
					        CollectManager.OnEnter(ds);
					    end);
					    class.AddLeaveScopeListener(function (ds)
					        CollectManager.OnLeave(ds);
					    end);
					    class.AddStayScopeListener(function (ds)
					        CollectManager.OnStay(ds);
					    end);

					end);
				end
			else
				--print("[Error] Unknown Npc Type !!");
			end
		end
	end;

	-- 掉落金币
	t.DropGold = function (info)
		local id = info["id"];
		local throw_pos = info["throw_pos"];
		local pos = info["pos"];
		local award = info["award"];
		local drop_item = award[2];
		local sid = drop_item[1];
		local attrs = drop_item[2];
		local count = attrs[1];
		local drop_item_id = attrs[3];
		local type = award[3];
		local npc = info.npc;
		local owner_list = info.owner_list;
		local create_time = TimerManager.GetUnityTime();

		DropItemManager.DropGold(id, count, throw_pos[1], throw_pos[2], throw_pos[3], pos[1], pos[2], pos[3], function (ds, title)
			ds["type"] = type;
			ds["count"] = count;
			ds["sid"] = sid;
			ds["pos_x"] = throw_pos[1];
			ds["pos_y"] = throw_pos[2];
			ds["pos_z"] = throw_pos[3];
			ds["src_x"] = ds.pos_x;
			ds["src_y"] = ds.pos_y;
			ds["src_z"] = ds.pos_z;
			ds["dst_x"] = pos[1];
			ds["dst_y"] = pos[2];
			ds["dst_z"] = pos[3];
			ds["npc"] = npc;
			ds["owner_list"] = owner_list;
			ds["create_time"] = create_time;
			local item = tb.ItemTable[sid];
			ds["name"] = item.show_name;
			ds.info = info;
			Fight.BuildItemTitle(ds, title);
		end);

	end;

	-- 掉落钻石
	t.DropDiamond = function (info)

		local id = info["id"];
		local throw_pos = info["throw_pos"];
		local pos = info["pos"];
		local award = info["award"];
		local drop_item = award[2];
		local sid = drop_item[1];
		local attrs = drop_item[2];
		local count = attrs[1];
		local drop_item_id = attrs[3];
		local type = award[3];
		local npc = info.npc;
		local owner_list = info.owner_list;
		local create_time = TimerManager.GetUnityTime();

		DropItemManager.DropDiamond(id, sid, throw_pos[1], throw_pos[2], throw_pos[3], pos[1], pos[2], pos[3], function (ds, title)
			ds["type"] = type;
			ds["sid"] = sid;
			ds["count"] = count;
			ds["pos_x"] = throw_pos[1];
			ds["pos_y"] = throw_pos[2];
			ds["pos_z"] = throw_pos[3];
			ds["src_x"] = ds.pos_x;
			ds["src_y"] = ds.pos_y;
			ds["src_z"] = ds.pos_z;
			ds["dst_x"] = pos[1];
			ds["dst_y"] = pos[2];
			ds["dst_z"] = pos[3];
			ds["npc"] = npc;
			ds["owner_list"] = owner_list;
			ds["create_time"] = create_time;
			local item = tb.ItemTable[sid];
			ds["name"] = item.show_name;
			ds.quality = item.quality;
			ds.info = info;
			Fight.BuildItemTitle(ds, title);
		end);
	end;

	-- 掉落物品
	t.DropItem = function (info)
		local id = info["id"];
		local throw_pos = info["throw_pos"];
		local pos = info["pos"];
		local award = info["award"];
		local drop_item = award[2];
		local sid = drop_item[1];
		local attrs = drop_item[2];
		local count = attrs[1];
		local drop_item_id = attrs[3];
		local type = award[3];
		local npc = info.npc;
		local owner_list = info.owner_list;
		local create_time = TimerManager.GetUnityTime();

		DropItemManager.DropItem(id, sid, throw_pos[1], throw_pos[2], throw_pos[3], pos[1], pos[2], pos[3], function (ds, title)
			ds["type"] = type;
			ds["sid"] = sid;
			ds["count"] = count;
			ds["pos_x"] = throw_pos[1];
			ds["pos_y"] = throw_pos[2];
			ds["pos_z"] = throw_pos[3];
			ds["src_x"] = ds.pos_x;
			ds["src_y"] = ds.pos_y;
			ds["src_z"] = ds.pos_z;
			ds["dst_x"] = pos[1];
			ds["dst_y"] = pos[2];
			ds["dst_z"] = pos[3];
			local item = tb.ItemTable[sid];
			if item == nil then
				local gem = tb.GemTable[sid];
				ds["name"] = gem.show_name;
				ds.quality = gem.quality;
			else
				ds["name"] = item.show_name;
				ds.quality = item.quality;
			end
			ds["npc"] = npc;
			ds["owner_list"] = owner_list;
			ds["create_time"] = create_time;
			ds.info = info;
			Fight.BuildItemTitle(ds, title);
		end);
	end;

	-- 掉落装备
	t.DropEquip = function (info)

		local id = info["id"];
		local throw_pos = info["throw_pos"];
		local pos = info["pos"];
		local award = info["award"];
		local drop_item = award[2];
		local sid = drop_item[1];
		local attrs = drop_item[2];
		local count = attrs[1];
		local drop_item_id = attrs[3];
		local type = award[3];
		local npc = info.npc;
		local owner_list = info.owner_list;
		local quality = attrs[7];
		local create_time = TimerManager.GetUnityTime();

		DropItemManager.DropEquip(id, sid, quality, throw_pos[1], throw_pos[2], throw_pos[3], pos[1], pos[2], pos[3], function (ds, title)
			ds["type"] = type;
			ds["sid"] = sid;
			ds["quality"] = quality;
			ds["pos_x"] = throw_pos[1];
			ds["pos_y"] = throw_pos[2];
			ds["pos_z"] = throw_pos[3];
			ds["src_x"] = ds.pos_x;
			ds["src_y"] = ds.pos_y;
			ds["src_z"] = ds.pos_z;
			ds["dst_x"] = pos[1];
			ds["dst_y"] = pos[2];
			ds["dst_z"] = pos[3];
			local item = tb.EquipTable[sid];
			ds["name"] = item.show_name;
			ds["npc"] = npc;
			ds["owner_list"] = owner_list;
			ds["create_time"] = create_time;
			ds.info = info;
			Fight.BuildItemTitle(ds, title);
		end);
	end;

	-- 掉落Mid装备
	t.DropMidEquip = function (info)
		local id = info["id"];
		local throw_pos = info["throw_pos"];
		local pos = info["pos"];
		local award = info["award"];
		local drop_item = award[2];
		local sid = drop_item[1];
		local quality = drop_item[2];
		local player = AvatarCache.me;
		local career = player.career;
		local midEquip = tb.MidEquipTable[sid];
		local name = "Mid Equip ???";
		local equip_sid = 0;
		if career == "soldier" then
			equip_sid = midEquip.soldierSid;
		elseif career == "magician" then
			equip_sid = midEquip.magicianSid;
		elseif career == "bowman" then
			equip_sid = midEquip.bowmanSid;
		end
		local create_time = TimerManager.GetUnityTime();
		local equip_data = tb.EquipTable[equip_sid];
		local equip_name = equip_data.show_name; -- const.MidEquip[drop_item[3]];
		local type = award[3];
		local npc = info.npc;
		local owner_list = info.owner_list;
		DropItemManager.DropEquip(id, equip_sid, quality, throw_pos[1], throw_pos[2], throw_pos[3], pos[1], pos[2], pos[3], function (ds, title)
			ds["type"] = type;
			ds["quality"] = quality;
			ds["sid"] = equip_sid;
			ds["name"] = equip_name;
			ds["pos_x"] = throw_pos[1];
			ds["pos_y"] = throw_pos[2];
			ds["pos_z"] = throw_pos[3];
			ds["src_x"] = ds.pos_x;
			ds["src_y"] = ds.pos_y;
			ds["src_z"] = ds.pos_z;
			ds["dst_x"] = pos[1];
			ds["dst_y"] = pos[2];
			ds["dst_z"] = pos[3];
			ds["npc"] = npc;
			ds["owner_list"] = owner_list;
			ds["create_time"] = create_time;
			ds.info = info;
			Fight.BuildItemTitle(ds, title);
		end);
	end;

	-- 物品掉落
	t.AddDrop = function (info)
		
		local npc = info["npc"];					-- npc
		local target = AvatarCache.GetAvatar(npc);
		if target == nil then
			return;
		end
		local id = info["id"];						-- id
		local pos = info["pos"];				 	-- pos
		local throw_pos = info["throw_pos"];		-- throw_pos
		local owner_list = info["owner_list"];		-- owner_list
		local award = info["award"];				-- award
		local type = award[3];						-- 奖励类型
		if type == "gold_coin" then
			t.DropGold(info);
		elseif type == "diamond_coin" then
			t.DropDiamond(info);
		elseif type == "item" then
			t.DropItem(info);
		elseif type == "equip" then
			t.DropEquip(info);
		elseif type == "mid_equip" then
			t.DropMidEquip(info);
		else
			--print("[Error] 未知物品掉落类型: " .. type);
		end
	end;


	t.node_added_handlers["prop"] = function (msg)
		local info = Parser.ParseKVMessage(msg);
		local player = AvatarCache.me;
		local myId = player.id;
		local can_pick = false;
		local owner_list = info.owner_list;
		if owner_list == nil or #owner_list == 0 then
			can_pick = true;
		else
			for i = 1, #owner_list do
				if owner_list[i] == myId then
					can_pick = true;
					break;
				end
			end
		end
		local award_type = info.award_type;
		-- DataStruct.DumpTable(info);
		if award_type == "public_award" or can_pick then
			t.AddDrop(info);
		end
	end;

	t.node_added_handlers["summon"] = function (msg)
		
	end

	------------------------------------------------------------------
	-- node_added end
	------------------------------------------------------------------
	
	-- 添加节点
	t.handlers["node_added"] = function (msg)
		--print(os.time());
		local type = msg["class"];
		local handler = t.node_added_handlers[type];
		if handler ~= nil then
			local info = msg["info"];
			handler(info);
		end
	end;

	-- 停止移动
	t.handlers["stop_move"] = function (msg)
		
		--print(msg);

		-- print("stop_move: " .. msg.id);
		local id = msg.id;
		local ds = AvatarCache.GetAvatar(id);
		if ds ~= nil then
			if ds.role_type == RoleType.OtherPlayer then
				--print(msg);
				local class = Fight.GetClass(ds);
				local queue = class.command_queue;
    			local count = #queue;
    			if count == 0 then
					local curr_state_name = ds.curr_state_name;
					if curr_state_name == "Run" then
						local state = Fight.GetState(ds, "Run");
						state.idle = true;
					end
				else
					local last_command = queue[count];
					if last_command.type == CommandType.Run then
						last_command.idle = true;
					end
				end
			elseif ds.role_type ~= RoleType.Player then
				Fight.DoJumpState(ds, SourceType.System, "Idle", 0);
			end
		end
	end;

	-- 提取服务端路径点和时间
	-- pos_x, pos_y, pos_z 角色当前位置
	-- pos_list 保存路径点, 结构 [[[x1, y1, z1], t1], [[x2, y2, z2], t2], ..., [[xn, yn, zn], tn]]
	-- server_start_time 路径开始移动的服务端时间
	-- server_move_speed 移动的速度
	-- out_path 生成的路径点数组, 结构 [x1, y1, z1, x2, y2, z2, ..., xn, yn, zn]
	-- out_time 生成的时刻数组, 结构 [t1, t2, ..., tn]
	t.ExtractPathAndTime = function (pos_x, pos_y, pos_z, pos_list, server_start_time, server_move_speed, out_path, out_time)

		-- 提取路径位置点数量
		local pos_list_count = #pos_list;

		-- 路径是空路径
		if pos_list_count == 0 then
			error("pos_list is empty!!");
			return false;
		end

		-- 路径只包含一个点
		if pos_list_count == 1 then
			--error("pos_list contains only one pos !!!");
			out_time[1] = server_start_time + pos_list[1][2];
			local curr_pos = pos_list[1][1];
			local curr_pos_x = curr_pos[1];
			local curr_pos_y = curr_pos[2];
			local curr_pos_z = curr_pos[3];
			out_path[1] = curr_pos_x;
			out_path[2] = curr_pos_y;
			out_path[3] = curr_pos_z;
			return true;
		end

		-- 正常路径，包含至少两个点
		for i = 1, pos_list_count do
			local curr_pos = pos_list[i][1];
			local curr_time = pos_list[i][2];
			local curr_pos_x = curr_pos[1];
			local curr_pos_y = curr_pos[2];
			local curr_pos_z = curr_pos[3];
			out_path[#out_path + 1] = curr_pos_x;
			out_path[#out_path + 1] = curr_pos_y;
			out_path[#out_path + 1] = curr_pos_z;
			if i == 1 then
				out_time[i] = server_start_time + curr_time;
			else
				local prev_pos = pos_list[i - 1][1];
				local prev_pos_x = prev_pos[1];
				local prev_pos_y = prev_pos[2];
				local prev_pos_z = prev_pos[3];
				out_time[i] = out_time[i - 1] + curr_time;
			end
		end
		return true;
	end;

	-- 打印路径和时刻点
	t.PrintPathAndTime = function (prefix, path, time)
		-- local s = "";
		-- local s = s .. string.format("[path] count=%d\n", #time);
		-- for i = 1, #time do
		-- 	local index = 3 * (i - 1);
		-- 	local x = path[index + 1];
		-- 	local y = path[index + 2];
		-- 	local z = path[index + 3];
		-- 	local t = time[i];
		-- 	s = s .. string.format("t=%d, pos={%f, %f, %f}\n", t, x, y, z);
		-- end
		-- s = s .. "[path end] ------------------------------------------\n";

		local dist = 0;
		local count = #path / 3;
		for i = 1, count - 1 do
			local index = 3 * i;
			local x1 = path[index - 2];
			local y1 = path[index - 1];
			local z1 = path[index];
			local x2 = path[index + 1];
			local y2 = path[index + 2];
			local z2 = path[index + 3];
			local dtx = x2 - x1;
			local dty = y2 - y1;
			local dtz = z2 - z1;
			dist = dist + math.sqrt(dtx * dtx + dtz * dtz);
		end
		local sT = time[1];
		local sP_x = path[1];
		local sP_y = path[2];
		local sP_z = path[3];
		local eT = time[#time];
		local eP_x = path[#path - 2];
		local eP_y = path[#path - 1];
		local eP_z = path[#path];
		local dx = eP_x - sP_x;
		local dz = eP_z - sP_z;
		local dT = eT - sT;
		local speed = dist * 1000 / dT;
		local s = string.format("[path] %s, from={%f, %f}, t1=%f, to={%f, %f}, t2=%f, dist=%f, dt=%f, speed=%f", prefix, sP_x, sP_z, sT, eP_x, eP_z, eT, dist, dT, speed);
		-- print(s);
	end;

	t.handlers["start_move"] = function (msg)
		-- print("start_move: " .. msg.id);
		--print(msg);
		local id = msg["id"];
		local player = AvatarCache.me;
		if player ~= nil then
			if player.id == id then
				--print("start_move: player");
				return;
			end
		end
		local client_trace = msg["client_trace"];
		local pos_list = client_trace[1];			-- 位置点, 里面包含的时间没有意义
		local server_arrive_time = client_trace[2];		-- 到达服务端的服务端时间
		local server_start_time = client_trace[3];			-- 开始移动的服务端时间
		local ds = AvatarCache.GetAvatar(id);
		if ds == nil then
			return;
		end

		local type = msg.type;
		
		local curr_state_name = ds["curr_state_name"];

		local class = Fight.GetClass(ds);
		local queue = class.command_queue;
    	local count = #queue;

    	-- 当前没有移动指令，而且当前状态正在移动同步状态
		if curr_state_name == "Run" and count == 0 then

			-- 路径
			local path = {};
			-- 时间
			local time = {};
			-- 计算移动速度
			local move_speed = ds.move_speed;
			-- 获取状态
			local state = class.Run;
			-- 获取移动信息
			local move_data = state.move_data;
			-- 计算当前移动的服务端时间
			local current_server_time = move_data.GetServerTimeOfCurrPos();
			-- 提取服务端路径
			t.ExtractPathAndTime(ds.pos_x, ds.pos_y, ds.pos_z, pos_list, server_start_time, move_speed, path, time);
			-- 是否摇杆，0 代表不是摇杆，如果不是摇杆，移动结束后跳转到待机
			if type == 0 then
				state.idle = true;
			end
			
			-- 获取当前客户端时间
			local client_start_time = ds.curr_time;
			-- 获取角色位置和方向
			local pos_x = ds.pos_x;
			local pos_y = ds.pos_y;
			local pos_z = ds.pos_z;
			local dir_x = ds.dir_x;
			local dir_y = ds.dir_y;
			local dir_z = ds.dir_z;
			-- 转换服务端路径到客户端路径
			local client_path, client_time = Fight.ConvertServerPathToClient(pos_x, pos_y, pos_z, path, time, client_start_time, current_server_time);
			-- 设置客户端路径
			move_data.SetPath(client_start_time, current_server_time, dir_x, dir_y, dir_z, client_path, client_time, move_speed);
		else
			-- 客户端路径
			local path = {};
			local time = {};
			-- 提取路径和时刻
			local move_speed = ds.move_speed;
			-- 获取状态
			local state = class.Run;
			-- 获取移动信息
			local move_data = state.move_data;
			-- 提取服务端路径
			t.ExtractPathAndTime(ds.pos_x, ds.pos_y, ds.pos_z, pos_list, server_start_time, move_speed, path, time);
			-- 添加移动命令
			class.AddRunCommand(ds, server_start_time, path, time, type);
		end
	end;

	-- 同步位置
	t.HandleSetPos = function (msg)
		local type = msg.type;
		-- print("set_pos: " .. type);
		if type == "reborn" then
			-- 设置 myInfo 位置
			local id = msg.id;
			local pos = msg.pos;
			local pos_x = pos[1];
			local pos_y = pos[2];
			local pos_z = pos[3];
			local myInfo = DataCache.myInfo;
			myInfo.pos.x = pos_x;
			myInfo.pos.y = pos_y;
			myInfo.pos.z = pos_z;

			-- 设置模型位置
			local ds = AvatarCache.GetAvatar(id);
			if ds == nil then
				return;
			end
			ds.pos_x = pos_x;
			ds.pos_y = pos_y;
			ds.pos_z = pos_z;
			uFacadeUtility.SetAvatarPos(id, pos_x, pos_y, pos_z);

			-- 复活玩家
			local class = Fight.GetClass(ds);
			class.Rebirth(ds);
			if ds.role_type == RoleType.Player and ds.is_auto_fighting == true then
				-- print("ReturnOriginPos");
				local class = Fight.GetClass(ds);
				class.ReturnOriginPos(ds);
			end
			-- 隐藏复活界面
			--uFacadeUtility.HideRebirthUI();
			-- 重置同步
			uFacadeUtility.ResetSync();

		elseif type == "chuansong" then

			-- 只有玩家才有 chuansong 消息
			-- 设置 myInfo 位置
			local id = msg.id;
			local pos = msg.pos;
			local pos_x = pos[1];
			local pos_y = pos[2];
			local pos_z = pos[3];
			--print(string.format("chuansong: id=%d, pos={%f, %f, %f}", id, pos_x, pos_y, pos_z));
			local myInfo = DataCache.myInfo;
			myInfo.pos.x = pos_x;
			myInfo.pos.y = pos_y;
			myInfo.pos.z = pos_z;

			-- 设置模型位置
			local ds = AvatarCache.GetAvatar(id);
			if ds == nil then
				return;
			end
			ds.pos_x = pos_x;
			ds.pos_y = pos_y;
			ds.pos_z = pos_z;
			uFacadeUtility.SetAvatarPos(id, pos_x, pos_y, pos_z);

			-- cost_transmit, 同图传送，服务端才会发送 chuansong 消息
			-- 这里特殊处理，如果有切场景走，AutoPathfindingManager.OnSceneLoaded();
			-- 如果当前玩家正在自动寻路
			--print("1");
			if AutoPathfindingManager.IsAutoPathfinding() then
				--print("2");
				AutoPathfindingManager.Abort();
				AutoPathfindingManager.OnGlobalPathArrived();
				AutoPathfindingManager.Clear();
				--print("3");
			end
			
		elseif type == "pengzhuang" or type == "npc_flyback" then

			local id = msg.id;
			local pos = msg.pos;
			local pos_x = pos[1];
			local pos_y = pos[2];
			local pos_z = pos[3];
			--print(string.format("chuansong: pos={%f, %f, %f}", pos_x, pos_y, pos_z));
			
			-- 设置模型位置
			local ds = AvatarCache.GetAvatar(id);
			if ds == nil then
				return;
			end
			ds.pos_x = pos_x;
			ds.pos_y = pos_y;
			ds.pos_z = pos_z;
			uFacadeUtility.SetAvatarPos(id, pos_x, pos_y, pos_z);

		end
		
	end;

	t.handlers["set_pos"] = function (msg)
		t.HandleSetPos(msg);
	end;

	t.handlers["set_direction"] = function (msg)
		local id = msg.id
		local dir = msg.direction
		local dir_x = dir[1]
		local dir_y = dir[2]
		local dir_z = dir[3]
		local ds = AvatarCache.GetAvatar(id);
		if ds == nil then
			return;
		end
		local direction = Vector3.ProjectOnPlane(Vector3.New(dir_x, dir_y, dir_z), Vector3.up):Normalize()
		if direction == Vector3.zero then
			return
		end
		uFacadeUtility.RotateToPos(id, ds["pos_x"] + direction.x, ds["pos_y"] + direction.y, ds["pos_z"] + direction.z);
	end;

	t.handlers["node_removed"] = function (msg)
		local id_list = msg["id"];
		--local player = AvatarCache.me;
		--local player_x = player.pos_x;
		--local player_y = player.pos_y;
		--local player_z = player.pos_z;
		for i = 1, #id_list do
			local id = id_list[i];
			if DropItemCache.HasDropItem(id) then
				--local ds = DropItemCache.GetDropItem(id);
				--local l = 0;
				--if ds.landing then
				--	l = 1;
				--end
				--local pkd = 0;
				--if ds.picked then
				--	pkd = 1;
				--end
				--local pking = 0;
				--if ds.picking then
				--	pking = 1;
				--end
				--local everyone_can_pick = 0;
				--if ds.everyone_can_pick then
				--	everyone_can_pick = 1;
				--end
				--local is_my_own = 0;
				--if ds.is_my_own then
				--	is_my_own = 1;
				--end
				--local fmt = "node_removed: id=%d, sid=%d, try_times=%d, landing=%d, picked=%d, picking=%d, create_time=%f, land_time=%f, destroy_time=%f, animator_move_times=%d, update_times=%d, everyone_can_pick=%d, is_my_own=%d, steps=%d";
				--if not ds.picked then
				--	error(string.format(fmt, id, ds.sid, ds.try_pick_times, l, pkd, pking, ds.create_time, ds.land_time, TimerManager.GetUnityTime(), ds.animator_move_times, ds.update_times, everyone_can_pick, is_my_own, #ds.steps));
				--	DataStruct.DumpTable(ds.info);
				--end
				DropItemCache.DestroyDropItem(id);
			elseif AvatarCache.HasAvatar(id) then
				--local avatar = AvatarCache.GetAvatar(id);
				--local pos_x = avatar.pos_x;
				--local pos_y = avatar.pos_y;
				--local pos_z = avatar.pos_z;
				--local dx = pos_x - player_x;
				--local dy = pos_y - player_y;
				--local dz = pos_z - player_z;
				--if dx * dx + dz * dz < 100 then
				--	error("[异常删除角色]: " .. id);
				--end
				InstanceManager.DeleteAvatar(id);
			end
		end
	end;

	-- 显示召唤特效
	t.ShowSummonEffect = function (target_uid, skill_id)
		local attacker_ds = AvatarCache.GetAvatar(target_uid);
		if attacker_ds == nil then
			return;
		end
		local cb = SummonSkillCallback[skill_id]
		if cb ~= nil then
			cb(target_uid)
		end
	end;

	-- HandleUseAbility: 处理使用技能
	t.HandleUseAbility = function (source_uid, target_uid, action)
		-- print("HandleUseAbility!")
		-- 判断攻击者存在
		local attacker_ds = AvatarCache.GetAvatar(source_uid);
		if attacker_ds == nil then
			return;
		end

		-- 显示技能警告
		local skill_id = action["value"];
		if skill_id == 0 then
			return;
		end

		local attacker_class = Fight.GetClass(attacker_ds);
		if attacker_class ~= nil then
			attacker_class.AddAvatarAttackedByMe(target_uid);
		end

		-- 通知副本使用技能
		local target_ds = AvatarCache.GetAvatar(target_uid);
		if target_ds ~= nil and target_ds.role_type == RoleType.Player then
			local target_class = Fight.GetClass(target_ds);
			target_class.AddAvatarAttackingMe(source_uid);
		end

		FubenManager.OnNotify(FubenHandlerType.OnUseAbility, { ["attacker"] = attacker_ds, ["target"] = target_ds, ["skill_id"] = skill_id });
		
		-- 播放召唤特效
		local skill_data = tb.SkillTable[skill_id];
		if skill_data == nil then
			error(string.format("skill(%d) not found in tb.SkillTable", skill_id));
			return;
		end

		if target_uid ~= 0 then
			--AbilityWarn
			if skill_data.warn_ani ~= nil and skill_data.warn_ani.timing == "use_ability" then
				t.PlayWarnEffect(source_uid, target_uid, skill_data, nil)
			end
		end

		--过滤召唤技能
		if skill_data.sub_type == "SummonSkill" then
			t.ShowSummonEffect(target_uid, skill_id);
			return;
		end

		local attacker_role_type = attacker_ds["role_type"];
		if attacker_role_type == RoleType.Monster or
		   attacker_role_type == RoleType.FubenMonster or
		   attacker_role_type == RoleType.EliteMonster or
		   attacker_role_type == RoleType.FubenElitMonster or
		   attacker_role_type == RoleType.FubenBoss or
		   attacker_role_type == RoleType.WorldBoss then

		    local class = Fight.GetClass(attacker_ds);
		    class.AddSkillCommand(attacker_ds, skill_id, target_uid);

		 	-- --NPC shout 暂时不启用
			-- local npc_sid = tonumber(attacker_ds["sid"])
			-- if npc_sid ~= nil then
			-- 	-- print(npc_sid)
			-- 	local pro = tb.ShoutTable[npc_sid]
			-- 	-- print(pro)
			-- 	if pro ~= nil then
			-- 		-- print("t.CheckNPCShout")
			-- 		if not t.CheckNPCShout(source_uid, pro, "skill", skill_id) then
			-- 			t.CheckNPCShout(source_uid, pro, "fight", nil)
			-- 		end
			-- 	end
			-- end

		elseif attacker_role_type == RoleType.OtherPlayer or
		   	   attacker_role_type == RoleType.OfflinePlayer or
		   	   attacker_role_type == RoleType.GuideNpc then
			
			local class = Fight.GetClass(attacker_ds);
			local skill = class.GetSkillById(skill_id);
			if skill ~= nil then

				if skill.info.no_action then
					Fight.DoNoActionSkill(attacker_ds, skill_id);
				else
					class.AddSkillCommand(attacker_ds, skill_id, target_uid);
				end
			end
		elseif attacker_role_type == RoleType.Player then
		else
			error(string.format("有RoleType没有处理相应逻辑！%d", attacker_role_type))
		end
		
	end;

	t.PlayWarnEffect = function(source_uid, target_uid, skill_data, pos)
		local warn_type = skill_data.warn_ani.type
		local warn_center = skill_data.warn_ani.center
		local warn_time = skill_data.warn_time
		local effectName = warn_type.."Projector"
		local sizeX, sizeY 
		local OffsetZ
		if warn_type == "circle" then
			local radius = skill_data.warn_ani.radius
			sizeX = radius; sizeY = radius
			OffsetZ = 0
		elseif warn_type == "deskcube" then
			sizeX = skill_data.warn_ani.rectx
			sizeY = skill_data.warn_ani.recty
			OffsetZ = sizeY
		elseif warn_type == "sector" then
			local radius = skill_data.warn_ani.radius
			sizeX = radius; sizeY = radius
			OffsetZ = radius
		end
		local bOnTarget = (warn_center == "target")
		if pos == nil then
			uFacadeUtility.PlayWarnEffect(source_uid, target_uid, effectName, bOnTarget, warn_time, sizeX, sizeY, OffsetZ, 0, 0, 0)
		else
			uFacadeUtility.PlayWarnEffect(source_uid, target_uid, effectName, bOnTarget, warn_time, sizeX, sizeY, OffsetZ, pos[1], pos[2], pos[3])
		end
	end

	-- HandleSpreadAbility: 处理技能溅射
	t.HandleSpreadAbility = function (source_uid, target_uid, action)
		local avatar = AvatarCache.GetAvatar(target_uid)
		if avatar == nil then
			return
		end
		local role_type = avatar.role_type;
		if role_type == RoleType.Player then
			local class = Fight.GetClass(avatar);
			if class ~= nil then
				class.AddAvatarAttackingMe(source_uid);
			end
		end
	end;

	-- HandleUseProp: 处理使用物品
	t.HandleUseProp = function (source_uid, target_uid, action)

	end;

	-- HandleSingAbility: 处理吟唱技能
	t.HandleSingAbility = function (source_uid, action)
		-- print("HandleSingAbility")
		local skill_sid = action.value
		local skill_data = tb.SkillTable[skill_sid];
		local pos = action.pos
		--AbilityWarn
		if skill_data.warn_ani ~= nil and skill_data.warn_ani.timing == "sing_ability" then
			t.PlayWarnEffect(source_uid, -1, skill_data, pos)
			--有预警光效 则此刻转向目标点 在吟唱期间服务端将控制其僵直 不会转向
			local attacker_ds = AvatarCache.GetAvatar(source_uid);
			if attacker_ds ~= nil then
				Fight.DoRotateToPos(attacker_ds, pos[1], pos[2], pos[3])
			end;
		end
	end;

	-- HandleFailAbility: 处理失败技能
	t.HandleFailAbility = function (source_uid, target_uid, action)

	end;

	-- Handle Action
	t.HandleAction = function (source_uid, target_uid, action)

		local type = action["type"];
		if type == nil then
			return;
		end
		if type == "use_ability" then
			t.HandleUseAbility(source_uid, target_uid, action);
		elseif type == "spread_ability" then
			t.HandleSpreadAbility(source_uid, target_uid, action);
		elseif type == "use_prop" then
			t.HandleUseProp(source_uid);
		elseif type == "sing_ability" then
			t.HandleSingAbility(source_uid, action);
		elseif type == "fail_ability" then
			t.HandleFailAbility(source_uid, target_uid, action);
		else
			--print(string.format("[Error] Unknown action type: %s !!!", type));
		end
	end;


	t.GetHurtType = function (value)
		local hurt_type_list = value["hurt_type"];
		local att_talent_list = {};
		local def_talent_list = {};
		if hurt_type_list == nil then
			return false, false, att_talent_list, def_talent_list;
		end

		local critical = false;
		local parry = false;
		for i = 1, #hurt_type_list do
			local hurt_type = hurt_type_list[i];
			if hurt_type == "critical" then
				critical = true;
			elseif hurt_type == "block" then
				parry = true;
			else
				local talent_id = tonumber(hurt_type);
				if talent_id ~= 0 then
					local talent_info = tb.TalentTable[talent_id];
					if talent_info ~= nil then
						local talent_type = talent_info.type;
						if talent_type == "Attack" then
							att_talent_list[#att_talent_list + 1] = talent_id;
						elseif talent_type == "Defence" then
							def_talent_list[#def_talent_list + 1] = talent_id;
						else
						end
					end
				end
			end
		end
		return critical, parry, att_talent_list, def_talent_list;
	end;

	-- Handle Hurt
	t.HandleHurt = function (source_uid, target_uid, value)
		local target_ds = AvatarCache.GetAvatar(target_uid);
		if target_ds == nil then
			return;
		end;
		local target_class = Fight.GetClass(target_ds);
		local old_hp = target_ds["hp"];
		local hp = value["hp"];
		target_ds["hp"] = hp;
		local title = uFacadeUtility.GetAvatarTitle(target_uid);
		target_class.UpdateTitleHp(target_ds, title);
		local hurt = value["hurt_value"];
		local skill_id = value["id"];
		local attacker = AvatarCache.GetAvatar(source_uid);
		local target = AvatarCache.GetAvatar(target_uid);
		if target_uid == DataCache.nodeID then
			DataCache.myInfo.hp = hp;
			EventManager.onEvent(Event.ON_BLOOD_CHANGE);
		end
		-- 伤害飘字
		local critical, parry, att_talent_list, def_talent_list = t.GetHurtType(value);
		FloatManager.CommonFloat(source_uid, target_uid, hurt, critical, parry, att_talent_list, def_talent_list);

		-- 处理死亡
		if hp <= 0 and old_hp > 0 then
			target_class.Killed(target_ds);
		end
	end;

	-- Handle Not Hit
	t.HandleNotHit = function (source_uid, target_uid, value)
		local target_ds = AvatarCache.GetAvatar(target_uid);
		if target_ds == nil then
			return;
		end
		local target_role_type = target_ds["role_type"];
		if target_role_type == RoleType.Player then
			FloatManager.FloatEvade(target_uid, 2.0, 1, 1, 1, 1);
			--如果是自己闪避了 有可能是灵动的天赋 需要表现
			local critical, parry, att_talent_list, def_talent_list = t.GetHurtType(value);
			FloatManager.FloatTalent(target_uid, source_uid, def_talent_list);
		else
			FloatManager.FloatMiss(target_uid, 2.0, 1, 1, 1, 1);
		end
	end;

	-- Handle Died
	t.HandleDied = function (source_uid, target_uid, value)
		-- print("t.HandleDied:"..target_uid)
		-- print("source_uid:"..source_uid)
		-- print("DataCache.nodeID:"..DataCache.nodeID)
		local target_ds = AvatarCache.GetAvatar(target_uid);
		if target_ds == nil then
			return;
		end
		if target_ds.role_type == RoleType.Player then
			-- DataStruct.DumpTable(value);
			DataCache.myInfo.multiDeathCount = value["multiDeathCount"];
			DataCache.myInfo.multiDeathTime = value["multiDeathTime"];
			DataCache.myInfo.siteRebirthCount = value["siteCount"];
			DataCache.myInfo.multiDeathKiller = client.tools.ensureString(value["multiDeathKiller"]);
		end
		local target_class = Fight.GetClass(target_ds);
		local target_hp = target_ds["hp"];
		-- print("target_hp:"..target_hp)
		-- if target_hp > 0 then
		target_ds["hp"] = 0;
		local str = "";
		if target_uid == DataCache.nodeID then
			DataCache.myInfo.hp = 0;
			-- EventManager.onEvent(Event.ON_BLOOD_CHANGE);
			local attacker = AvatarCache.GetAvatar(source_uid);
			if attacker.role_type == RoleType.OtherPlayer or attacker.role_type == RoleType.OfflinePlayer then
				str = string.format("你被%s杀死了！",attacker.name);
			else
				str = string.format("你被怪物%s杀死了！",attacker.name);
			end
			-- print(str)
			client.chat.clientSystemMsg(str);
		elseif source_uid == DataCache.nodeID and 
			(target_ds.role_type == RoleType.OtherPlayer or target_ds.role_type == RoleType.OfflinePlayer) then
			str = string.format("你杀死了%s",target_ds.name);
			client.chat.clientSystemMsg(str);
		end
		local title = uFacadeUtility.GetAvatarTitle(target_uid);
		target_class.UpdateTitleHp(target_ds, title);
		--hurt的时候已经调用过一次
		-- target_class.Killed(target_ds);
		-- end
	end;

	-- Handle Reborn
	t.HandleReborn = function (source_uid, target_uid, value)
		--print("HandleReborn");
		-- 复活玩家
		local ds = AvatarCache.GetAvatar(target_uid);
		local class = Fight.GetClass(ds);
		class.Rebirth(ds);
	end;

	-- Handle Recovery
	t.HandleRecovery = function (source_uid, target_uid, value)
		local target_ds = AvatarCache.GetAvatar(target_uid);
		if target_ds == nil then
			return;
		end;


		local hp = value["hp"];
		target_ds["hp"] = hp;
		local target_class = Fight.GetClass(target_ds);
		local title = uFacadeUtility.GetAvatarTitle(target_uid);
		target_class.UpdateTitleHp(target_ds, title);

		if target_uid == DataCache.nodeID then
			DataCache.myInfo.hp = hp;
			EventManager.onEvent(Event.ON_BLOOD_CHANGE);
		end
	end;

	-- HandleAddBuffer
	t.HandleAddBuffer = function (source_uid, target_uid, value)
		local sid = value["sid"];
		local over_time = value["over_time"];
		local useful_time = value["useful_time"];
		local nowSecond = TimerManager.GetServerNowSecond();
		local buff_time = over_time - nowSecond;

		if target_uid == AvatarCache.me.id then
			client.buffCtrl.AddBuff(sid, useful_time, TimerManager.GetServerNowMillSecond())
		end

		if buff_time <= 0 then
			return;
		end
		local ds = AvatarCache.GetAvatar(target_uid);
		if ds == nil then
			return;
		end

		-- print("target_uid:")
		-- print(target_uid)
		-- print("source_uid:")
		-- print(source_uid)
		-- print("sid:"..sid)
		BuffManager.OnAddBuff(target_uid, source_uid, sid);
	end;

	-- HandleRemoveBuffer
	t.HandleRemoveBuffer = function (source_uid, target_uid, value)
		local sid = value["sid"];

		if target_uid == AvatarCache.me.id then 
			client.buffCtrl.RemoveBuff(sid)
		end

		BuffManager.OnRemoveBuff(target_uid, source_uid, sid);
	end;

	-- Handle Effect
	t.HandleEffect = function (source_uid, target_uid, value)
		local target_id = value["target"];
		local type = value["type"];
		if type == "hurt" then
			t.HandleHurt(source_uid, target_id, value);
		elseif type == "not_hit" then
			t.HandleNotHit(source_uid, target_id, value);
		elseif type == "died" then
			t.HandleDied(source_uid, target_id, value);
		elseif type == "reborn" then
			t.HandleReborn(source_uid, target_id);
		elseif type == "recover" then
			t.HandleRecovery(source_uid, target_id, value);
		elseif type == "add_buffer" then
			t.HandleAddBuffer(source_uid, target_id, value);
		elseif type == "remove_buffer" then
			t.HandleRemoveBuffer(source_uid, target_id, value);
		else
			--print("No Handler: " .. type);
		end
	end;

	-- Handle Fight Log
	t.handlers["fight_log"] = function (msg)
		local source_uid = msg["sourceUid"];
		local target_uid = msg["targetUid"];
		local uid = msg["uid"];
		local action = msg["action"];
		local effect = msg["effect"];

		-- 处理 action
		if action ~= nil then
			t.HandleAction(source_uid, target_uid, action);
		else
			-- if effect == nil then
			-- 	--print("[Error] action is empty list and no effect !!!!");
			-- else
			-- 	--print("[Error] action is empty list !!!!");
			-- end
		end

		-- 处理 effect
		if effect ~= nil then
			for i = 1, #effect do
				t.HandleEffect(source_uid, target_uid, effect[i]);
			end
		else
			-- if action ~= nil then
			-- 	local type = action["type"];
			-- 	if type == "spread_ability" then
			-- 		--print("[Error] spread_ability does not contain float blood info !!!");
			-- 	end
			-- end
		end
	end;

	-- HandleUpdateAttr
	t.handlers["update_attr"] = function (msg)
		--DataStruct.DumpTable(msg.attrs);
		--print("===================================");

		local id = msg["id"];
		local attrs = {};
		DataCache.ParseUpdateAttrs(attrs, msg["attrs"]);
		local me = AvatarCache.me;
		local my_id = me["id"];
		local my_level = me["level"];
		local myInfo = DataCache.myInfo;
		local target = AvatarCache.GetAvatar(id);
		if target ~= nil then

			-- 更新能量石
			local energy_stone = attrs["energy_stone"];
			if energy_stone ~= nil then				
				if my_id == id then
					client.gcm.UpdateStoneNumber(id, energy_stone);
				end
			end
			
			-- 旧的属性
			local target_last_level = target["level"];
			local oldKillValue = target.kill_value;
			-- 更新属性
			local target_class = Fight.GetClass(target);
			DataCache.CopyAttrs(target, attrs);

			if my_id == id then
				

				-- 更新属性
				local lastFightPoint = myInfo.fightPoint;

				local my_last_hp = me["hp"];
				local my_class = Fight.GetClass(me);
				DataCache.CopyAttrs(me, attrs);
				DataCache.CopyAttrs(myInfo, attrs);

				EventManager.onEvent(Event.ON_ATTR_CHANGE);

				local fightPoint = attrs["fightPoint"];
				if fightPoint ~= nil then
					EventManager.onEvent(Event.ON_FIGHTNUMBER_CHANGE, lastFightPoint);
				end

				local tiredValue = attrs["tiredValue"];
				if myInfo.tiredValue < 0 then
					myInfo.tiredValue = 0;
				end

				EventManager.onEvent(Event.ON_TIRED_VALUE_CHANGE);

			end


			if attrs["treasure_number"] ~= nil then
				local nowSecond = TimerManager.GetServerNowSecond();
				if my_id == id then
					DataCache.treasureNumber = attrs["treasure_number"];
					MainUI.UpdateTreasureBtn();
					local title = uFacadeUtility.GetAvatarTitle(id);
					if target.dead_protect_time == nil then
						Fight.SetBoxIcon(title,DataCache.treasureNumber);
					elseif target.dead_protect_time == 0 or nowSecond > target.dead_protect_time then
						Fight.SetBoxIcon(title,DataCache.treasureNumber);
					end
					EventManager.onEvent(Event.ON_TREASURE_BOX_CHANGE);
				else
					target.treasure_number = attrs["treasure_number"];
					local title = uFacadeUtility.GetAvatarTitle(id);
					if target.dead_protect_time == nil then
						Fight.SetBoxIcon(title,target.treasure_number);
					elseif target.dead_protect_time == 0 or nowSecond > target.dead_protect_time then
						Fight.SetBoxIcon(title,target.treasure_number);
					end
				end
			end

			local maxHP = attrs["maxHP"];
			if maxHP ~= nil then
				if id == DataCache.nodeID then
					DataCache.myInfo.maxHP = maxHP;
					EventManager.onEvent(Event.ON_BLOOD_CHANGE);
				end			
				target["maxHP"] = maxHP;
			end

			-- 时装
			-- 暂时已经停止使用了 现在穿不同等级的衣服 即更换装备 by linh
			local suitActivateId = attrs["suitActivateId"];
			if suitActivateId ~= nil then
				local role_type = target["role_type"];
				if role_type == RoleType.Player then
					--update RoleRTT
					if RoleRTT ~= 0 then
						RoleRTT.UpdateRtt()
					end
				elseif role_type == RoleType.OtherPlayer or role_type == RoleType.OfflinePlayer then
					--put on weapon

				end
			end

			local need_update_title_color = false;

			-- 杀戮值
			local kill_value = attrs["kill_value"];
			if kill_value ~= nil then
				-- print("kill_value:"..oldKillValue)
				-- print("oldValue:"..oldValue)
				target.kill_value = kill_value;
				need_update_title_color = true;
				if my_id == id then
					local addValue = kill_value - oldKillValue;
					-- print("addValue:"..addValue)
					if addValue == 5 then
						-- print("addValue == 5")
						ui.showMsg("杀死白名角色，恶名值+5");
					elseif addValue == 15 then	
						-- print("addValue == 15")
						ui.showMsg("由于你比对方等级领先过多，恶名值额外+10");
					end
					myInfo.kill_value = kill_value;
					EventManager.onEvent(Event.ON_KILL_VALUE_CHANGE);
				end
				--print(string.format("id=%d, kill_value=%d", id, kill_value));
			end

			-- 黄名
			local grey_name_time = attrs["grey_name_time"];
			if grey_name_time ~= nil then
				target.grey_name_time = grey_name_time;
				need_update_title_color = true;
				if my_id == id then
					myInfo.grey_name_time = grey_name_time;
				end
				--print(string.format("id=%d, grey_name_time=%d", id, grey_name_time));
			end

			--print(attrs);

			-- 更新标题名字颜色
			if need_update_title_color then
				local title = uFacadeUtility.GetAvatarTitle(id);
				target_class.UpdateTitleRedName(target, title);
			end

			-- 队伍
			local team_uid = attrs["team_uid"];
			if team_uid ~= nil then
				target.team_uid = team_uid;
			end

			-- 公会
			local legion_uid = attrs["legion_uid"];
			if legion_uid ~= nil then
				target.legion_uid = legion_uid;
				if id == DataCache.nodeID then
					DataCache.myInfo.legion_uid = legion_uid
				end
			end

			-- 公会名字和公会位置
			local legion_name = client.tools.ensureString(attrs["legion_name"]);
			local legion_position = attrs["legion_position"];

			if legion_name ~= nil  then
				target.legion_name = legion_name;
				if id == DataCache.nodeID then
					DataCache.myInfo.legion_name = client.tools.ensureString(legion_name)
				end
			end
			if legion_position ~= nil then
				target.legion_position = legion_position;
			end

			if legion_position ~= nil then
				target.legion_position = legion_position;
				if id == DataCache.nodeID then
					DataCache.myInfo.legion_position = legion_position
				end
			end

			-- 公会信息有变动
			if legion_uid ~= nil or legion_name ~= nil or legion_position ~= nil then 
				local title = uFacadeUtility.GetAvatarTitle(id);
				if target.legion_uid == 0 then
					-- 隐藏名称
					title:GO('Panel.Other.ArmyName'):Hide()
				else
					-- 设置公会名称和职位
					if  target.legion_name ~= nil and target.legion_position ~= nil and target.legion_position > 0  then
						title:GO('Panel.Other.ArmyName'):Show()
						title:GO('Panel.Other.ArmyName').text = client.tools.ensureString(target.legion_name).."·"..const.legionPos[target.legion_position]
					end
				end
			end

			-- 骑乘
			local horse = attrs["horse"];
			if horse ~= nil then
				local ds = AvatarCache.GetAvatar(id)
				local horseid = horse[1]
				local pro = tb.HorseTable[horseid]
				local bShowMaxEffect = horse[3] == 1
				-- print("Horse Update ")
				-- print("MaxEffect     ")
				-- print(bShowMaxEffect)
				if ds.horse ~= nil then
					local isRiding = (horse[2] == 1)
					if ds.horseName ~= pro.model or bShowMaxEffect == true then
						uFacadeUtility.LoadHorse(ds.role_type, id, pro.model, function() 
							if bShowMaxEffect then
								local Carryon_Effect = pro.carryon_effect
								uFacadeUtility.UpdateHorseEffectById(id, bShowMaxEffect, false, Carryon_Effect)
							end
							--检查是否需要重新上马
							if isRiding then
								uFacadeUtility.RideHorse(id)
							else
								uFacadeUtility.UnRideHorse(id)
							end
						end)
					end
					if ds.is_riding ~= isRiding then
						if isRiding then
							uFacadeUtility.RideHorse(id)
						else
							uFacadeUtility.UnRideHorse(id)
						end
					end
				end	
			end

			-- 速度
			local speed = attrs["speed"];
			if speed ~= nil then
				target.move_speed = speed * 1000;
				--print(string.format("id=%d, speed=%f", target.id, target.move_speed));
				local target_class = Fight.GetClass(target);
				target_class.SetMoveSpeed(target, target.move_speed);
			end

			-- 战斗状态时间
			local fight_state_time = attrs["fight_state_time"];
			if fight_state_time ~= nil then
				AvatarCache.me.fight_state_time = fight_state_time;
				EventManager.onEvent(Event.ON_FIGHT_STATE_TIME);
				-- 脱战切换待机动作
				if id ~= my_id then
					if target ~= nil then
						if target.role_type == RoleType.OtherPlayer or
						   target.role_type == RoleType.OfflinePlayer then
							if fight_state_time > 0 then
								uFacadeUtility.SetAnimatorFloat(id, "SwitchFight", 1.0);
							else
								if target ~= nil then
									Fight.CrossFightIdle(target, "SwitchFight", 1.0, 0.0, 2);
								end
							end
						end
					end
				end
			end

			-- 装备
			local equipments = attrs["equipment"];
			if equipments ~= nil then
				for i=1,#equipments do
					local equipment = equipments[i]
					if equipment ~= nil then
						local pro = tb.EquipTable[equipment.sid] 
						if pro ~= nil and 
							(pro.buwei == const.BuWeiIndex["武器"] or pro.buwei == const.BuWeiIndex["衣服"]) then
							local role_type = target["role_type"];
							if role_type == RoleType.Player then
								--update RoleRTT
								if RoleRTT ~= 0 then
									RoleRTT.UpdateRtt()
								end
								--put on weapon
								local class = Fight.GetClass(AvatarCache.me);
								if pro.buwei == const.BuWeiIndex["武器"] then
									class.PutOnWeapon(AvatarCache.me, equipment.sid, function () end);	
								elseif pro.buwei == const.BuWeiIndex["衣服"] then
									class.PutOnSuit(AvatarCache.me, equipment.sid, function () end);	
								end
							elseif role_type == RoleType.OtherPlayer or role_type == RoleType.OfflinePlayer then
								--put on weapon
								local ds = AvatarCache.GetAvatar(id)
								local class = Fight.GetClass(ds);
								if pro.buwei == const.BuWeiIndex["武器"] then
									class.PutOnWeapon(ds, equipment.sid, function () end);	
								elseif pro.buwei == const.BuWeiIndex["衣服"] then
									class.PutOnSuit(ds, equipment.sid, function () end);	
								end
							end
						end
					end
				end
			end
			
			-- 等级升级
			local new_level = target["level"];
			if new_level > target_last_level then
				Fight.PlaySound("level_up");
				Fight.PlayFollowEffect("shengjizong", 10.0, target["id"], "", 0, 0.3, 0);
				if target.role_type == RoleType.Player then
					showLevelUp(new_level, 3);
					EventManager.onEvent(Event.ON_LEVEL_UP);
				end
			end
		end
	end;

	-- Handle Pick Prop
	t.handlers["pick_prop"] = function (msg)
		
		local id = msg.id;
		local ds = DropItemCache.GetDropItem(id);
        if ds == nil then
        	return;
        end
        
        -- 不存在拾取人，直接返回
        local sourceId = msg.source;
        if not AvatarCache.HasAvatar(sourceId) then
            return;
        end
        
        DropItemManager.DoItemFly(ds, sourceId);
	end;

	-- Handle Talent Trigger
	t.handlers["talent_trigger"] = function (msg)
		local talentId = tonumber(msg["type"]);
		local sourceUid = msg["source"];
		local targetUid = msg["target"];
		local talent_list = {};
		talent_list[#talent_list + 1] = talentId;
		FloatManager.FloatTalent(sourceUid, targetUid, talent_list);
	end;


	-- Handle learn_zhuanjin
	t.handlers["learn_zhuanjin"] = function (msg)
		local id = msg.id;
		local ds = AvatarCache.GetAvatar(id);
		ds.ability = msg.ability;
		local class = Fight.GetClass(ds);
		local sidList = msg.sid;
		local zhuanjin = msg.zhuanjin;
		for i = 1, #sidList do
			local skillSid = sidList[i];
			local skill = class.GetSkillById(skillSid);
			skill.Setzhuanjin(zhuanjin);
		end

		if AvatarCache.me.id == id then
			if const.enable_zhuanjing then
				if zhuanjin ~= nil then
					for i = 1, #zhuanjin do
						playSkillTip_Talent(zhuanjin[1][1], "ZhuanJing");
						EventManager.onEvent(Event.ON_TALENT_ZHUANJING_UNLOCK);
					end
				end
			end
		end
	end;

	t.message_cache = {};


	t.ProcessCachedMessages = function ()
		local cache = t.message_cache;
		local cache_count = #cache;
		if cache_count > 0 then
			for i = 1, cache_count do
				local cache_msg = cache[i];
				for k = 1, #cache_msg do
					t.HandleMapKeyValue(cache_msg[k][1], cache_msg[k][2]);
				end
				cache[i] = nil;
			end
		end
	end;

	-- Handle Map(没有使用)
	-- key 有可能重复，所以 msg 不能转换成 lua 表
	t.HandleMap = function (msg)
		if SceneManager.IsSceneLoaded() then
			for i = 1, #msg do
				t.HandleMapKeyValue(msg[i][1], msg[i][2]);
			end
		else
			local cache = t.message_cache;
			cache[#cache + 1] = msg;
		end
	end;

	-- Handle Map Key/Value
	t.HandleMapKeyValue = function (key, info)
		
		

		local handler = t.handlers[key];
		for i = 1, #info do
			info[info[i][1]] = info[i][2];
			info[i] = nil;
		end

		if handler ~= nil then
			handler(info);
		else
			--print(string.format("[Error] No Handler: %s !!!", key));
		end
	end;


	t.HandleChangeScene = function (msg)

		-- print("change_scene");

		-- 场景 id
		local id = msg["id"];
		local pos = msg["pos"];
		
		local map_info = msg["name"];
		local map_scene_id = map_info[1];
		local mapName = map_info[2];
		local map_fen_xian = mapName[2];

		local myInfo = DataCache.myInfo;

		myInfo.id = id;
		DataCache.mapType = mapName[1];
		
		DataCache.activityName = DataCache.mapType;

		if myInfo.pos == nil then
			myInfo.pos = {};
		end

		myInfo.pos.x = pos[1];
		myInfo.pos.y = pos[2];
		myInfo.pos.z = pos[3];

		--print(string.format("HandleChangeScene: curr_scene_sid=%d, curr_fenxian=%d, pos={%f, %f, %f}", map_scene_id, map_fen_xian, pos[1], pos[2], pos[3]));
		local pre_scene_sid = DataCache.scene_sid
		if DataCache.scene_sid ~= map_scene_id or DataCache.fenxian ~= map_fen_xian then
			DataCache.scene_sid = map_scene_id;
			DataCache.fenxian = tonumber(map_fen_xian);
			DataCache.fenxianFlag = tb.SceneTable[map_scene_id].fenxianFlag;
			DropItemCache.RemoveAllDropItems();
			AvatarCache.RemoveAllAvatars();
			TargetSelecter.ClearTarget();
			-- print("load scene: " .. map_scene_id);
			SceneManager.LoadScene(pre_scene_sid,map_scene_id);
		end

		TreasureCtrl.Clean();
	end;


	-----------------------------------------------------------------
	-- 处理奖励
	-----------------------------------------------------------------

	-- 处理经验奖励
	t.HandleExp = function  (msg)
		local exp = msg[1];
		local addExp = msg[2];
		local expType = msg[3] or 0;
		local me = AvatarCache.me;
		me["exp"] = exp;
		local myInfo = DataCache.myInfo;
		myInfo["exp"] = exp;

		if addExp > 0 then
			if expType == 1 then
				MainUI.showSpecialExp(addExp)
			else
				client.SimpleSysMsg.ShowMsg("经验+" .. addExp);
				EventManager.onEvent(Event.ON_EXP_CHANGE);
			end
		end
	end;



	-- 处理金钱奖励
	t.HandleMoney = function (msg)
		local money = msg[1];		
		DataCache.role_money = money;
		local add_money = msg[2];
		if add_money > 0 then
				ui.showMoneyMsg(add_money);
		end
		EventManager.onEvent(Event.ON_MONEY_CHANGE, money);
	end;

	-- 处理钻石
	t.HandleDiamond = function (msg)
		local role_diamond = msg[1];
		DataCache.role_diamond = role_diamond;
		local add_diamond = msg[2];
		if add_diamond > 0 then
			local bKillNpcAwardFlag = false;
			if #msg > 2 then
				if add_diamond == 1 then
					bKillNpcAwardFlag = true;
				end
			end
			if #msg == 2 or not bKillNpcAwardFlag then
				ui.showDiamondMsg(add_diamond);
			end
		end
		EventManager.onEvent(Event.ON_DIAMOND_CHANGE, role_diamond);
	end;

	-- 处理购买力
	t.HandleGoumaili = function (msg)
		local role_goumaili = msg[1];		
		DataCache.role_goumaili = role_goumaili;
		EventManager.onEvent(Event.ON_GOUMAILI_CHANGE, role_goumaili);
	end;

	-- 处理天赋书
	t.HandleTalentBook = function (msg)
		local talentBook = msg[1];
		-- local myInfo = DataCache.myInfo;
		
		DataCache.talentBook = talentBook;
		EventManager.onEvent(Event.ON_TALENTBOOK_CHANGE, talentBook);
	end;

	-- 处理贡献
	t.HandleContribution = function (msg)
		local contribution = msg[1];
		local myInfo = DataCache.myInfo;
		myInfo.contribution = contribution;
		EventManager.onEvent(Event.ON_MONEY_CHANGE, contribution);
	end;

	-- SetPort("award")
	t.HandleAward = function (msg)
		local exp = msg["exp"];
		if exp ~= nil then
			t.HandleExp(exp);
		end

		local money = msg["money"];
		if money ~= nil then
			t.HandleMoney(money);
		end

		local diamond = msg["diamond"];
		if diamond ~= nil then
			t.HandleDiamond(diamond);
		end

		local goumaili = msg["goumaili"];
		if goumaili ~= nil then
			t.HandleGoumaili(goumaili);
		end

		local talentBook = msg["talentBook"];
		if talentBook ~= nil then
			t.HandleTalentBook(talentBook);
		end

		local contribution = msg["contribution"];
		if contribution ~= nil then
			t.HandleContribution(contribution);
		end

	end;

	-- 解锁技能
	t.HandleAbility = function (value)
		local player = AvatarCache.me;
		local class = Fight.GetClass(player);
		local idList = value.sid;
		local myInfo = DataCache.myInfo;
		local abilities = myInfo.ability;
		for i = 1, #idList do
			local skill_id = idList[i];
			local skill = class.GetSkillById(skill_id);
			skill.unlock = true;
			local found = false;
			for k = 1, #abilities do
				local ability = abilities[k];
				if ability[1] == skill_id then
					found = true;
					break;
				end
			end
			if not found then
				local ability = {};
				ability[1] = skill_id;
				ability[2] = 1;
				ability[3] = 0;
				abilities[#abilities + 1] = ability;
			end
			playNewSkillTip(skill_id);
		end
		EventManager.onEvent(Event.ON_ABILITY_UNLOCK);
	end;

	

	--检查喊话
	t.CheckNPCShout = function(uid, pro, state, param)
		-- print("CheckNPCShout")
		local data = pro[state]
		if data == nil then
			return
		end
		-- print(data.param1)
		-- print(data.param2)
		local bShout = false
		if (param ~= nil and data.param1 ~= nil and data.param1 == param)
			or (param ~= nil and data.param2 ~= nil and data.param2 == param) then
			bShout = true
		end
		if bShout then
			local info = data.shout
			local sum = 0
			for i=1,#info do
				sum = sum + info[i][1]
			end
			local weight = math.random(sum)
			for i=1,#info do
				if weight <= info[i][1] then
					content = info[i][2]
					if content ~= "" then
						--shout it!
						Util.ShowHeadChat(uid, content, Color.white)
					end
				else
					weight = weight - info[i][1]
				end
			end
		end
	end

	function t.HandleShowAvatar(sid)
		--print(sid)
		local NT = tb.NPCTable[sid]
		if NT == nil or NT.task_sid == nil then
			return;
		end
		local show_type = NT.show_type
		if show_type == commonEnum.NpcShowType.const then
			return
		elseif show_type == commonEnum.NpcShowType.before_task_complete then
			local flag =  not client.task.isDoneTask(NT.task_sid)
			uFacadeUtility.ShowAvatar(AvatarCache.SidToAvatarId(sid),flag)
		elseif show_type == commonEnum.NpcShowType.after_task_complete then
			local flag =  client.task.isDoneTask(NT.task_sid)
			uFacadeUtility.ShowAvatar(AvatarCache.SidToAvatarId(sid),flag)
		end
	end

	function t.HandleNpcShow_WhenTaskChange()
		local task_id = client.task.mainTaskSid
		if task_id == nil then
			return
		end

		for sid,nid in pairs(AvatarCache.sid2nid) do			
			t.HandleShowAvatar(sid)
		end
	end

	EventManager.register(Event.ON_ADD_TASK, t.HandleNpcShow_WhenTaskChange);
	EventManager.register(Event.ON_TASK_COMPLETED, t.HandleNpcShow_WhenTaskChange);

	return t;

end


GameSceneManager = CreateGameSceneManager();

SetPort("award", GameSceneManager.HandleAward);
SetPort("map", GameSceneManager.HandleMap, false);
SetPort("change_scene", GameSceneManager.HandleChangeScene);
SetPort("update_attr", GameSceneManager.handlers.update_attr);
SetPort("ability", GameSceneManager.HandleAbility);
