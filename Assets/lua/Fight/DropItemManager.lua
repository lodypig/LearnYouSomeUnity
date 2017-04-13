function CreateDropItemManager()
	local t = {};

	-- 创建掉落物品有两种方式：
	-- 一种是直接创建一个 Prefab, 对创建出来的 对象 不做任何的操作
	-- 第二种是直接创建 "diaoluowuping" Prefab, 然后设置纹理

	-- 初始化掉落物品数据
	t.InitDropItem = function (ds)
		-- print("init drop item: " .. ds.id);
		ds["src_x"] = ds["pos_x"];
		ds["src_y"] = ds["pos_y"];
		ds["src_z"] = ds["pos_z"];
		ds["landing"] = false;
		ds["picked"] = false;
		ds["picking"] = false;
		ds["land_time"] = 0;
		ds["cold_time"] = 0.7;
		ds["try_pick_times"] = 0;
		ds["animator_move_times"] = 0;
		ds["update_times"] = 0;
		ds["is_my_own"] = false;
		ds["everyone_can_pick"] = false;
		ds["steps"] = {};
		ds["length"] = 0;
		-- print("---- init drop item end: " .. ds.id);
	end;


	-- 掉落金币
	t.DropGold = function (id, count, pos_x, pos_y, pos_z, dst_x, dst_y, dst_z, callback)
		local prefab_name = "paojinbi_duo";
		if count < 20 then
			prefab_name = "paojinbi_sao";
		elseif count < 50 then
			prefab_name = "paojinbi_zong";
		else
		end
		t.CreateDropItemFromPrefab(id, prefab_name, pos_x, pos_y, pos_z, dst_x, dst_y, dst_z, callback);
	end;

	-- 掉落钻石
	t.DropDiamond = function (id, sid, pos_x, pos_y, pos_z, dst_x, dst_y, dst_z, callback)
		local item = tb.ItemTable[sid];
		local icon_name = item.icon;
		t.CreateDropItemFromTexture(id, icon_name, pos_x, pos_y, pos_z, dst_x, dst_y, dst_z, callback);
	end;


	-- 掉落物品
	t.DropItem = function (id, sid, pos_x, pos_y, pos_z, dst_x, dst_y, dst_z, callback)
		local item = tb.ItemTable[sid];
		local icon_name = "";
		if item == nil then
			-- 如果物品表没有，就尝试去宝石表找
			local gem = tb.GemTable[sid];
			if gem == nil then
				--print(string.format("[Error] id=%d, sid=%d", id, sid));
				return;
			end
			icon_name = gem.icon;
		else
			icon_name = item.icon;
		end
		local prefab_name = "baodai"
		-- t.CreateDropItemFromTexture(id, icon_name, pos_x, pos_y, pos_z, dst_x, dst_y, dst_z, callback);
		t.CreateDropItemFromPrefab(id, prefab_name, pos_x, pos_y, pos_z, dst_x, dst_y, dst_z, callback);
	end;

	-- 掉落装备
	t.DropEquip = function (id, sid, quality, pos_x, pos_y, pos_z, dst_x, dst_y, dst_z, callback)
		local equip = tb.EquipTable[sid];
		local icon_name = equip.icon;
		if quality == 6 then
			icon_name = "tb_chengsesuipian";
		end
		local prefab_name = const.EquipModel[equip.buwei];
		t.CreateDropItemFromPrefab(id, prefab_name, pos_x, pos_y, pos_z, dst_x, dst_y, dst_z, callback);
		-- t.CreateDropItemFromTexture(id, icon_name, pos_x, pos_y, pos_z, dst_x, dst_y, dst_z, callback);
	end;

	-- 掉落 Mid 装备
	t.DropMidEquip = function (id, icon_name, pos_x, pos_y, pos_z, dst_x, dst_y, dst_z, callback)
		local prefab_name = "wuqi";
		t.CreateDropItemFromPrefab(id, prefab_name, pos_x, pos_y, pos_z, dst_x, dst_y, dst_z, callback);
		-- t.CreateDropItemFromTexture(id, icon_name, pos_x, pos_y, pos_z, dst_x, dst_y, dst_z, callback);
	end;

	-- 创建掉落 Prefab, 通过名字
	t.CreateDropItemFromPrefab = function (id, prefab_name, pos_x, pos_y, pos_z, dst_x, dst_y, dst_z, callback)
		uFacadeUtility.CreateDropItemFromPrefab(id, prefab_name, "", 1.5, 4, pos_x, pos_y, pos_z, dst_x, dst_y, dst_z, function (ds, title)
			t.InitDropItem(ds);
			DropItemCache.AddDropItem(ds);
			callback(ds, title);
		end);
	end;

	-- 创建 "daioluowuping" Prefab 并设置纹理
	t.CreateDropItemFromTexture = function (id, icon_name, pos_x, pos_y, pos_z, dst_x, dst_y, dst_z, callback)
		uFacadeUtility.CreateDropItemFromTexture(id, icon_name, "", 1.5, 4, pos_x, pos_y, pos_z, dst_x, dst_y, dst_z, function (ds, title)
			t.InitDropItem(ds);
			DropItemCache.AddDropItem(ds);
			callback(ds, title);
		end);
	end;

	-- 销毁掉落物品
	t.DestroyDropItem = function (id)
		DropItemCache.RemoveDropItem(id);
		uFacadeUtility.DestroyDropItem(id);
	end;

	-- 掉落物品飞行
	t.DoItemFly = function (ds, target_id)

		local type = ds.type;
		if type == "gold_coin" then
			local pos_x = ds["pos_x"];
			local pos_y = ds["pos_y"];
			local pos_z = ds["pos_z"];

			local uid = ds["id"];
			uFacadeUtility.DestroyDropItemEffects(uid);

			-- 播放地面反馈特效
			uFacadeUtility.PlayPositionEffect("shiqu_dimianfankui", 5.0, pos_x, pos_y, pos_z, 0, function ()

			end);

			-- 删除掉落物品
			t.DestroyDropItem(uid);

			-- 播放飞行光效
			uFacadeUtility.PlayBulletTraceEffect("shiqu_tuowei_chengse", pos_x, pos_y, pos_z, target_id, "body", -1, -1, function ()

				-- 播放地面反馈特效
				Fight.PlayFollowEffect("shiqu_fankui_chengse", 5.0, target_id, "body");

			end);
		else

			local pos_x = ds["pos_x"];
			local pos_y = ds["pos_y"];
			local pos_z = ds["pos_z"];

			local uid = ds["id"];
			uFacadeUtility.DestroyDropItemEffects(uid);

			local quality = ds["quality"];

			-- 播放地面反馈特效
			local land_ground_effect_name = const.DropItemFlyEffectNames[quality].ground;
			uFacadeUtility.PlayPositionEffect(land_ground_effect_name, 5.0, pos_x, pos_y, pos_z, 0, function ()

			end);

			-- 删除掉落物品
			t.DestroyDropItem(uid);

			-- 播放飞行光效
			local fly_effect_name = const.DropItemFlyEffectNames[quality].fly;
			uFacadeUtility.PlayBulletTraceEffect(fly_effect_name, pos_x, pos_y, pos_z, target_id, "body", -1, -1, function ()

				-- 播放地面反馈特效
				local absorb_effect_name = const.DropItemFlyEffectNames[quality].absorb;
				Fight.PlayFollowEffect(absorb_effect_name, 5.0, target_id, "body");

			end);
		end
	end;

	t.BagFullTipCD = 5
	t.BagFullTipLastTime = 0

	-- 掉落物品尝试拾取
	t.DoTryPick = function (ds)
		local land_time = ds["land_time"];
		-- assert(land_time);
		-- assert(land_time > 0);
		local curr_time = TimerManager.GetUnityTime();
		local elapsed_time = curr_time - land_time;
		-- if elapsed_time < 0 then
			-- error(string.format("curr_time=%f, land_time=%f", curr_time, land_time));
		-- end
		local cold_time = ds["cold_time"];
		-- assert(cold_time);
		-- assert(cold_time > 0);

		-- ds.steps[7] = 1;

		if elapsed_time < cold_time then
			-- print(string.format("id=%d, elapsed_time=%f, cold_time=%f", ds.id, elapsed_time, cold_time));
			return;
		end

		-- ds.steps[8] = 1;

		ds["picking"] = true;
		local try_pick_times = ds.try_pick_times;
		try_pick_times = try_pick_times + 1;
		ds.try_pick_times = try_pick_times;
		local uid = ds["id"];
		local type = ds["type"];
		if type == "gold_coin" then

			-- ds.steps[9] = 1;

			local msg = { cmd = "pickup_award", id = uid };
			Send(msg, function (reply)

				-- ds.steps[10] = 1;

				ds["picking"] = false;
				local success = reply["type"];
				if success == "ok" then
					ds["picked"] = true;
					t.DoItemFly(ds, AvatarCache.me.id);
				else
					-- error("pick fail: " .. uid);
				end				
			end);

		elseif type == "item" or type == "diamond_coin" or type == "equip" or type == "mid_equip" then
			local msg = { cmd = "pickup_award", id = uid };
			Send(msg, function (reply)
				ds["picking"] = false;
				local success = reply["type"];
				if success == "ok" then
					-- print("item fly: " .. uid);
					ds["picked"] = true;
					t.DoItemFly(ds, AvatarCache.me.id);
				else
					-- error("pick fail: " .. uid);
				end				
			end);
		else
			--print("[drop item] do nothing");
		end
	end;


	-- 掉落物品完成掉落
	t.OnFinishDroping = function (ds)

		-- print("OnFinishDroping: " .. ds.id);

		local type = ds["type"];
		ds["land_time"] = TimerManager.GetUnityTime();

		if type == "gold_coin" then
			-- 播放掉落金币音效
			Fight.PlaySound("drop_gold");
			-- 获取掉落物品位置
			local pos_x = ds["pos_x"];
			local pos_y = ds["pos_y"];
			local pos_z = ds["pos_z"];
			-- 计算 prefab 名称
			local count = ds["count"];
			local prefab_name = "dimianjinbi_duo";
			if count < 20 then
				prefab_name = "dimianjinbi_shao";
			elseif count < 50 then
				prefab_name = "dimianjinbi_zhong";
			else
			end
			-- 显示标题
			local id = ds["id"];
			uFacadeUtility.ShowDropItemTitle(id, true);
			-- 播放地面反馈特效
			uFacadeUtility.PlayPositionEffect("shiqu_dimianfankui", 2.0, pos_x, pos_y, pos_z, 0, function ()

			end);
			-- 播放地面常驻特效
			uFacadeUtility.PlayDropItemEffect(id, prefab_name, 0, pos_x, pos_y, pos_z, function ()
				
			end);

		elseif type == "item" or type == "diamond_coin" or type == "equip" or type == "mid_equip" then

			local id = ds["id"];

			Fight.PlaySound("drop_item");
			-- 获取掉落物品位置
			local pos_x = ds["pos_x"];
			local pos_y = ds["pos_y"];
			local pos_z = ds["pos_z"];

			-- 计算 prefab 名称
			local prefab_name = "diaoluowuping";


			-- 显示标题
			local id = ds["id"];
			uFacadeUtility.ShowDropItemTitle(id, true);


			-- 获取物品或装备品质
			local quality = ds["quality"];
			if quality == nil then
				local sid = ds["sid"];
				local item = tb.ItemTable[sid];
				quality = item.quality;
				ds["quality"] = quality;
			end


			-- 播放地面反馈特效
			local land_ground_effect_name = const.DropItemFlyEffectNames[quality].ground;
			uFacadeUtility.PlayPositionEffect(land_ground_effect_name, 2.0, pos_x, pos_y, pos_z, 0, function ()

			end);

			-- 5 代表没有未鉴定的装备
			if quality ~= 5 then
				-- 播放地面常驻特效
				local exhit_effect_name = const.DropItemFlyEffectNames[quality].exhibit;
				uFacadeUtility.PlayDropItemEffect(id, exhit_effect_name, 0, pos_x, pos_y, pos_z, function ()
					
				end);
			end

		else

		end
	end;

	-- 掉落物品掉落移动
	t.OnAnimatorMove = function (ds)

		-- print("OnAnimatorMove: " .. ds.id);

		local animator_move_times = ds.animator_move_times;
		animator_move_times = animator_move_times + 1;
		ds.animator_move_times = animator_move_times;

		local landing = ds["landing"];
		if landing then
			return;
		end

		local has_animator = ds["has_animator"];
		if has_animator then

			local length = ds["length"];
			if length > 1 then
				length = 1;
			end

			local id = ds.id;
			local pos_x = ds["pos_x"];
			local pos_y = ds["pos_y"];
			local pos_z = ds["pos_z"];
			local src_x = ds["src_x"];
			local src_y = ds["src_y"];
			local src_z = ds["src_z"];
			local dst_x = ds["dst_x"];
			local dst_y = ds["dst_y"];
			local dst_z = ds["dst_z"];
			local dx = dst_x - src_x;
			local dy = dst_y - src_y;
			local dz = dst_z - src_z;
			local new_pos_x = src_x + dx * length;
			local new_pos_y = pos_y;
			local new_pos_z = src_z + dz * length;
			ds["pos_x"] = new_pos_x;
			ds["pos_y"] = new_pos_y;
			ds["pos_z"] = new_pos_z;
			uFacadeUtility.SetDropItemPos(id, new_pos_x, new_pos_y, new_pos_z);

			if length >= 1 then
				ds["landing"] = true;
				t.OnFinishDroping(ds);
			end
		else
			
			local start_time = ds["start_time"];
			local curr_time = ds["curr_time"];
			local elapsed_time = 0.5
			local length = (curr_time - start_time) / elapsed_time;
			if length > 1 then
				length = 1;
			end

			-- print(string.format("id=%d, sid=%d, length=%f", ds.id, ds.sid, length));

			local id = ds.id;
			local pos_x = ds["pos_x"];
			local pos_y = ds["pos_y"];
			local pos_z = ds["pos_z"];
			local src_x = ds["src_x"];
			local src_y = ds["src_y"];
			local src_z = ds["src_z"];
			local dst_x = ds["dst_x"];
			local dst_y = ds["dst_y"];
			local dst_z = ds["dst_z"];

			local dx = dst_x - src_x;
			local dy = dst_y - src_y;
			local dz = dst_z - src_z;
			local new_pos_x = src_x + dx * length;
			local new_pos_y = pos_y;
			local new_pos_z = src_z + dz * length;
			ds["pos_x"] = new_pos_x;
			ds["pos_y"] = new_pos_y;
			ds["pos_z"] = new_pos_z;
			uFacadeUtility.SetDropItemPos(id, new_pos_x, new_pos_y, new_pos_z);

			if length >= 1 then
				ds["landing"] = true;
				t.OnFinishDroping(ds);
			end
		end
	end;

	t.OnDestroy = function (ds)

	end;

	-- 物品创建出来后这个函数每帧都会调一次
	-- 调用的时候会把物品的数据集穿过来
	t.OnUpdate = function (ds)

		-- print("lua OnUpdate: " .. ds.id);

		-- assert(type(ds.update_times) == "number");
		local update_times = ds.update_times;
		update_times = update_times + 1;
		ds.update_times = update_times;

		--ds.steps[1] = 1;

		-- 是否已经落地
		local landing = ds["landing"];
		if not landing then
			return;
		end

		--ds.steps[2] = 1;

		-- 是否已经拾取
		local picked = ds["picked"];
		if picked then
			return;
		end

		--ds.steps[3] = 1;

		-- 是否正在拾取
		local picking = ds["picking"]
		if picking then
			return;
		end

		--ds.steps[4] = 1;

		-- 判断是否是我可以拾取的物品
		local can_pick = false;
		local everyone_can_pick = false;
		local is_my_own = false;
		local owner_list = ds.owner_list;

		-- 判断是否是任何人都可以拾取
		if owner_list == nil then
			can_pick = true;
			everyone_can_pick = true;
		else
			-- 判断玩家是否是拥有者
			local owner_count = #owner_list;
			if owner_count == 0 then
				can_pick = true;
				everyone_can_pick = true;
			else
				local player = AvatarCache.me;
				if player ~= nil then
					local player_id = player.id;
					for i = 1, owner_count do
						if player_id == owner_list[i] then
							can_pick = true;
							is_my_own = true;
							break;
						end
					end
				end
			end
		end

		--可以拾取 还要接着判断包裹容量是否ok
		local type = ds["type"];
		if can_pick == true and (type == "item" or type == "equip" or type == "mid_equip") then
			-- print("item!!!")
			if not Bag.canAddItem(type, nil) then
				-- print("no can add !")
				--提示 并有5s的CD	
				local timeNow = math.floor(TimerManager.GetServerNowMillSecond()/1000);
				-- print(timeNow)
				if (t.BagFullTipLastTime == 0) or (timeNow - t.BagFullTipLastTime > t.BagFullTipCD) then
					t.BagFullTipLastTime = timeNow
					ui.showMsg("背包已满，请整理背包")
				end
				can_pick = false
				-- print("cam no pick")
				-- print("false")
			end
		end
		--ds.steps[5] = 1;

		ds.everyone_can_pick = everyone_can_pick;
		ds.is_my_own = is_my_own;

		-- 可以拾取
		if can_pick then

			--ds.steps[6] = 1;
			-- print("can_pick: " .. ds.id);
			t.DoTryPick(ds);
		end

	end;

	return t;
end;


DropItemManager = CreateDropItemManager();