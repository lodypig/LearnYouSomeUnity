
AvatarTitleLayer = {};
AvatarTitleLayer.Monster = 1;
AvatarTitleLayer.OtherPlayer = 2;
AvatarTitleLayer.Npc = 3;
AvatarTitleLayer.Item = 4;
AvatarTitleLayer.AutoPathfinding = 5;
AvatarTitleLayer.AutoFight = 6;
AvatarTitleLayer.Player = 7;


SceneType = {};
SceneType.MainScene = 0;
SceneType.Fuben = 1;

function CreateSceneManager()
	local t = {};

	t.first_load = true;

	t.SetFirstLoad = function (first_load)
		t.first_load = first_load;
	end;

	t.is_loaded = false;

	t.npc_id_list = {};

	t.creatingRole = false;
	t.LoadingScene = false

	t.ClearNpcIdList = function ()
		local npc_id_list = t.npc_id_list;
		for i = 1, #npc_id_list do
			npc_id_list[i] = nil;
		end
	end

	t.LoadNpcIdList = function (scene_sid)
		t.ClearNpcIdList();
		local npc_id_list = t.npc_id_list;
		local scene_npc_list = tb.MapNpcTable[scene_sid]
		if scene_npc_list == nil then
			return
		end
		for k, v in pairs(scene_npc_list) do
			local info = v;
			if info.npc_type == MapNPCType.MapNPC_monster then
				npc_id_list[#npc_id_list + 1] = info.npc_id;
			end
		end
	end


	t.LoadScene = function (pre_scene_sid,scene_sid)
		t.is_loaded = false;
		local pre_or_curr_scene_isxiangwei = (SceneManager.IsXiangWeiMap(pre_scene_sid) or SceneManager.IsXiangWeiMap(scene_sid))
		-- 停止自动战斗光效
		local player = AvatarCache.me;
		if player ~= nil then
			local class = Fight.GetClass(player);
			class.HandUp(player, false);
		end
		InstanceManager.Clear();
		InteractionManager.Clear();
		CollectManager.ClearWaitQueue();
		DataCache.scene_sid = scene_sid;
		if not pre_or_curr_scene_isxiangwei then
			uFacadeUtility.CreateLoadingUI();
		end
		t.LoadNpcIdList(scene_sid);
		local myInfo = DataCache.myInfo
		local pos = myInfo.pos;
		local pos_x = pos.x;
		local pos_y = pos.y;
		local pos_z = pos.z;
		
		-- 重置副本状态
		FubenManager.Reset();
		-- 设置副本控制 ai
		local scene_info = tb.SceneTable[scene_sid];
		local sceneLua = scene_info.sceneLua;
		if sceneLua ~= "0" then
			
			FubenManager.SetFubenAI(FubenAI[sceneLua]);
			FubenManager.OnNotify(FubenHandlerType.OnInit);
		else
			FubenManager.SetFubenAI(0);
		end

		-- 播放场景音乐
		local scene_info = tb.SceneTable[DataCache.scene_sid];
		uFacadeUtility.PlayMusic(scene_info.bgMusic);

		if pre_or_curr_scene_isxiangwei then
			SceneLoader.GetInstance():onXiangWeiMapChange(pre_scene_sid,scene_sid)
			Util.SetRadialBlur(true)
		else
			uFacadeUtility.LoadScene(scene_sid, scene_info.sceneFile, pos_x, pos_y, pos_z, t.npc_id_list);
		end
		t.ClearNpcIdList();
	end;

	t.OnTerrainLoaded = function ()
		--print("1.OnTerrainLoaded");
		if t.first_load then
        	showMainScene();
        end
	end

	t.OnStartLoad = function ()
		t.LoadingScene = true
	end;

	t.OnLoading = function (progress)

	end;

	t.OnPreFinishLoad = function ()

	end;

	-- 获取角色套装名称
	t.GetRoleSuitName = function ()
		local myInfo = DataCache.myInfo;
		return Fight.GetRoleSuitName(myInfo.career, myInfo.sex, myInfo.suitActivateId);
	end;

	-- -- 登录场景加载成功
	-- t.OnLoadLoginSceneFinishLoad = function ()
	-- 	-- 删除 Loading 界面
	-- 	uFacadeUtility.DestroyLoadingUI();
	-- end;

	-- 获取随机移动半径
	t.GetRandomMoveRadius = function (career)
		return const.RandomMoveRadius[career];
	end;

	-- 获取攻击距离
	t.GetAttackRange = function (career)
		return const.AttackRange[career];
	end;

	-- 获取寻怪半径
	t.GetSearchMonsterRadius = function (career)
		return t.GetRandomMoveRadius(career) + t.GetAttackRange(career);
	end;

	t.OnFinishLoad = function ()
		--print("5. OnFinishLoad");
		OnLoadScene();
		uFacadeUtility.SetSyncWindow(0.2);
		-- 解锁传送点
		TransmitPoint.lock = false;

		local myInfo = DataCache.myInfo;
		local id = myInfo.id;
		local pos = myInfo.pos;
		local pos_x = pos.x;
		local pos_y = pos.y;
		local pos_z = pos.z;
		local career = myInfo.career;
		--local roleName = t.GetRoleSuitName();
		-- print(string.format("[load role] career=%s, sex=%d, level=%d", myInfo.career, myInfo.sex, myInfo.level));
		local modelName, _modelMaterialName, _weaponmodelName = uAvatarUtil.GetPlayerModelName(myInfo, false)
		-- print(modelName)
		local smName = string.gsub(modelName, "_Prefab", "_controller_desc");
		local logicName = Fight.GetLuaLogicByCareer(career);
		if t.creatingRole == true then
			return
		end
		local bFirstLoad = t.first_load
		uFacadeUtility.CreatePlayer(RoleType.Player, id, pos_x, pos_y, pos_z, modelName, smName, "PlayerTitle", 2.2, AvatarTitleLayer.Player, logicName, function (ds, title)
			local myInfo = DataCache.myInfo;
			ds["career"] = myInfo.career;
			ds["lua_logic"] = logicName;
			ds["lost_target_distance"] = 18;
			ds["id"] = myInfo.id;
			ds["role_type"] = RoleType.Player;
			ds["name"] = tostring(myInfo.id);
			ds["hp"] = myInfo.hp;
			ds["maxHP"] = myInfo.maxHP;
			ds["move_speed"] = myInfo.speed * 1000;
			--print(myInfo.speed);
			ds["pos_x"] = myInfo.pos.x;
			ds["pos_y"] = myInfo.pos.y;
			ds["pos_z"] = myInfo.pos.z;
			ds["dir_x"] = myInfo.dir.x;
			ds["dir_y"] = myInfo.dir.y;
			ds["dir_z"] = myInfo.dir.z;
			ds["control_logic"] = ControlLogicType.WildHeping;
			ds["auto_lock_radius"] = 16;
			ds["random_move_radius"] = t.GetRandomMoveRadius(myInfo.career);
			ds["search_monster_radius"] = t.GetSearchMonsterRadius(myInfo.career);
			ds["is_auto_fighting"] = false;
			ds["origin_x"] = myInfo.pos.x;
			ds["origin_y"] = myInfo.pos.y;
			ds["origin_z"] = myInfo.pos.z;
			ds["is_ghost"] = false;

			AvatarCache.AddAvatar(ds);

			--[[
			// 角色属性
        cs2lua.SetInt("id", 0);                             // 基础id
        cs2lua.SetInt("sid", 0);                            // sid
        cs2lua.SetInt("role_type", 0);                      // 角色类型
        cs2lua.SetInt("hp", 100);                        // 角色血量
        cs2lua.SetInt("maxHP", 100);                    // 最大血量
        cs2lua.SetInt("imba_state", 0);                     // 角色无敌
        cs2lua.SetInt("level", 0);                          // 角色等级
        cs2lua.SetInt("team_uid", 0);                       // 队伍uid
        cs2lua.SetInt("legion_uid", 0);                     // 公会uid
        cs2lua.SetInt("kill_value", 0);                     // 杀戮值
        cs2lua.SetLong("grey_name_time", 0);                // 黄名状态
        cs2lua.SetString("pk_mode", "heping");              // pk模式
        cs2lua.SetBool("is_riding", false);                 // 是否骑乘
        cs2lua.SetFloat("horse_curr_state_normalized_time", 0);
        cs2lua.SetBool("is_destroyed", false);              // 是否已销毁
        ]]
			local class = Fight.GetClass(ds);
			class.ParseRoleInfo(ds, myInfo);
			Fight.BuildPlayerTitle(ds, title);
			class.UpdateTitleRedName(ds, title);
			client.team.ShowTeamFlag(ds.role_uid);
			class.UpdateTitleHp(ds, title);
			class.LoadSkillStates(ds);
			-- DataStruct.DumpTable(myInfo.equipment)
			class.PutOnEquips(ds, myInfo.equipment, function () end);


			-- 如果玩家已经死亡，直接死亡
			if ds.hp <= 0 then
				class.Killed(ds);
			end
			Main.OnPlayerInitOK();
			
			-- 加载坐骑相关
			if myInfo.horse ~= nil and myInfo.horse[1] ~= 0 then
				local horseid = myInfo.horse[1]
				local pro = tb.HorseTable[horseid]
				local bShowMaxEffect = myInfo.horse[3] == 1
				uFacadeUtility.LoadHorse(1, myInfo.id, pro.model, function() 
					if bShowMaxEffect then
						local Carryon_Effect = pro.carryon_effect
						uFacadeUtility.UpdateHorseEffectById(myInfo.id, bShowMaxEffect, false, Carryon_Effect)
					end
					--当前该骑马的要骑马(但第一次上线进入场景的时候要下马)
					local _myInfo = DataCache.myInfo;
					if _myInfo.horse[2] == 1 then
						if bFirstLoad then
							client.horse.RideHorse(false)
						else
							client.horse.RideHorse(true)
						end
					end
				end)
			end

			t.OnCreatePlayerFinished();
			t.is_loaded = true;
			
			-- 处理缓存的消息
			GameSceneManager.ProcessCachedMessages();

			AutoPathfindingManager.OnSceneLoaded();
			JoystickManager.OnSceneLoaded();
			ClickMoveManager.OnSceneLoaded();
			EventManager.onEvent(Event.ON_GUIDE_CHANGE_SCENE, DataCache.scene_sid);

			-- 确定玩家控制逻辑
			class.SwitchPKMode(ds, ds.pk_mode);
			if client.rightUpConfirm then
				client.rightUpConfirm.Hide();
			end
			t.creatingRole = false
			--
			--print("CreateRoleFinished")
		end);
		t.LoadingScene = false
		Util.SetRadialBlur(false)
	end;

	t.IsSceneLoaded = function ()
		return t.is_loaded;
	end;

	t.OnCreatePlayerFinished = function ()
		--print("6. OnCreatePlayerFinished");
		OnRoleCreateFinished(t.first_load);
		t.first_load = false;
		uFacadeUtility.ShowScene();
		uFacadeUtility.DestroyLoadingUI();
	end;

	-- 判断 scene_sid 是否是相位地图
	t.IsXiangWeiMap = function (scene_sid)
		if scene_sid == 0 then
			return false;
		end
		local scene = tb.SceneTable[scene_sid];
        return scene.sceneType == "xiangwei_map";
	end;

	-- 判断 scene_sid 是否是副本
	t.IsFubenMap = function (scene_sid)
		local scene = tb.SceneTable[scene_sid];
        return scene.sceneType == "fuben_map" or scene.sceneType == "active_map";
	end;

	-- 判断当前场景是否是副本
	t.IsCurrentFubenMap = function ()
		return t.IsFubenMap(DataCache.scene_sid);
	end;

	t.IsCurrentXiangWeiMap = function ()
		return t.IsXiangWeiMap(DataCache.scene_sid);
	end;

	t.ReturnToSelectRoleUI = function ()
		--Reinit
		RTTManager.DestroyAllCells()
		--
		t.SetFirstLoad(true);
		uFacadeUtility.SetShowLogin(false);
		uFacadeUtility.CreateLoadingUI();
		uFacadeUtility.ReturnToSelectRoleUI();
	end;

	t.ReturnToLoginUI = function ()
		--Reinit
		RTTManager.DestroyAllCells()
		--
		t.SetFirstLoad(true);
		uFacadeUtility.SetShowLogin(true);
		uFacadeUtility.CreateLoadingUI();
		uFacadeUtility.ReturnToSelectRoleUI();
	end;

	t.HandleOtherOper = function(from_scene_sid, to_scene_sid)

	end

	return t;
end

SceneManager = CreateSceneManager();