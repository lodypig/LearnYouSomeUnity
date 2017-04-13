


function CreateInstanceManager()
	local t = {};

	t.add_queue = {};				-- 添加队列
	t.add_list = {};				-- 添加列表

	t.waitting_queue = {};			-- 等待队列
	t.delete_queue = {};				-- 删除队列



	-- 添加列表包含
	t.IsAddQueueContains = function (id)
		local que = t.add_queue;
		return que[id] ~= nil;
	end;

	-- 添加到添加列表
	t.AddItemToAddQueue = function (item)
		if item == nil then
			error("AddItemToAddQueue");
			return;
		end
		local list = t.add_list;
		list[#list + 1] = item;
		local que = t.add_queue;
		que[item.id] = item;
	end;

	-- 从添加列表删除
	t.RemoveItemFromAddQueue = function (id)
		local list = t.add_list;
		local count = #list;
		if count > 0 then
			for i = 1, count do
				local item = list[i];
				if item.id == id then
					local count_minus_one = count - 1;
					for k = i, count_minus_one do
						list[k] = list[k + 1];
					end
					list[count] = nil;
					break;
				end
			end
		end
		local que = t.add_queue;
		que[id] = nil;
	end;


	-- 等待队列包含
	t.IsWaittingQueueContains = function (id)
		local que = t.waitting_queue;
		return que[id] ~= nil;
	end;

	-- 添加到等待列表
	t.AddItemToWaittingQueue = function (item)
		if item == nil then
			error("AddItemToWaittingQueue");
			return;
		end
		local id = item.id;
		local que = t.waitting_queue;
		que[id] = item;
	end;

	-- 从等待队列删除
	t.RemoveItemFromWaittingQueue = function (id)
		local que = t.waitting_queue;
		que[id] = nil;
	end;

	-- 删除所有等待项
	t.ClearWaittingQueue = function ()
		local que = t.waitting_queue;
		for k, v in pairs(que) do
			que[k] = nil;
		end
	end;

	-- 删除队列包含
	t.IsDeleteQueueContains = function (id)
		local que = t.delete_queue;
		return que[id] ~= nil;
	end;

	-- 从删除列表删除
	t.RemoveItemFromDeleteQueue = function (id)
		local que = t.delete_queue;
		que[id] = nil;
	end;

	-- 添加到删除列表
	t.AddItemToDeleteQueue = function (id)
		local que = t.delete_queue;
		que[id] = id;
	end;

	
	-- 添加角色
	-- id 角色 id
	-- type 角色 RoleType
	-- sid 角色 sid(如果有)
	-- style 角色模型（如果有)
 	-- pos 角色位置
 	-- msg 角色消息
 	-- callback(msg, ds, title)
	t.AddAvatar = function (id, type, sid, style, logic, pos, msg, callback)
		if t.IsAddQueueContains(id) then
			return;
		end
		if t.IsWaittingQueueContains(id) then
			local que = t.waitting_queue;
			local item = que[id];
			if item.destroy then
				item.destroy = false;
			end
			return;
		end
		if t.IsDeleteQueueContains(id) then
			t.RemoveItemFromDeleteQueue(id);
			return;
		end
		local ds = AvatarCache.GetAvatar(id);
		if ds ~= nil then
			local is_destroyed = ds["is_destroyed"];
			if not is_destroyed then
				return;
			end
		end
		local new_item = {};
		new_item.id = id;
		new_item.type = type;
		new_item.sid = sid;
		new_item.style = style;
		new_item.logic = logic;
		new_item.pos = pos;
		new_item.msg = msg;
		new_item.callback = callback;
		new_item.destroy = false;
		t.AddItemToAddQueue(new_item);
	end;


	-- 添加离线玩家
	t.AddOfflinePlayer = function (id, pos, msg, callback)
		t.AddAvatar(id, RoleType.OfflinePlayer, nil, nil, nil, pos, msg, callback);
	end;

	-- 添加真实玩家
	t.AddOtherPlayer = function (id, pos, msg, callback)
		t.AddAvatar(id, RoleType.OtherPlayer, nil, nil, nil, pos, msg, callback);
	end;

	-- 添加怪物
	t.AddMonster = function (id, sid, pos, msg, callback)
		t.AddAvatar(id, RoleType.Monster, sid, nil, nil, pos, msg, callback);
	end;

	-- 添加精英怪
	t.AddEliteMonster = function (id, sid, pos, msg, callback)
		t.AddAvatar(id, RoleType.EliteMonster, sid, nil, nil, pos, msg, callback);
	end;

	-- 添加副本精英怪
	t.AddFubenEliteMonster = function (id, sid, pos, msg, callback)
		t.AddAvatar(id, RoleType.FubenEliteMonster, sid, nil, nil, pos, msg, callback);
	end;

	-- 添加世界 Boss
	t.AddWorldBoss = function (id, sid, logic, pos, msg, callback)
		t.AddAvatar(id, RoleType.WorldBoss, sid, nil, logic, pos, msg, callback);
	end;

	-- 添加副本 Boss
	t.AddFubenBoss = function (id, sid, logic, pos, msg, callback)
		t.AddAvatar(id, RoleType.FubenBoss, sid, nil, logic, pos, msg, callback);
	end;


	-- 添加交互 Npc
	t.AddNpc = function (id, sid, style, pos, msg, callback)
		t.AddAvatar(id, RoleType.Npc, sid, style, nil, pos, msg, callback);
	end;

	-- 添加引导掠夺Npc
	t.AddGuideNpc = function (id, sid, style, pos, msg, callback)
		t.AddAvatar(id, RoleType.GuideNpc, sid, style, nil, pos, msg, callback);
	end;

	-- 添加采集物
	t.AddGatherItem = function (id, sid, style, pos, msg, callback)
		t.AddAvatar(id, RoleType.GatherItem, sid, style, nil, pos, msg, callback);
	end;

	-- 添加触发器
	t.AddTransport = function (id, sid, pos, msg, callback)
		t.AddAvatar(id, RoleType.Transport, sid, nil, nil, pos, msg, callback);
	end;

	-- 添加到删除队列
	t.DeleteAvatar = function (id)
		if not AvatarCache.HasAvatar(id) then
			return;
		end
		if t.IsAddQueueContains(id) then
			t.RemoveItemFromAddQueue(id);
			return;
		end
		if t.IsWaittingQueueContains(id) then
			local que = t.waitting_queue;
			local item = que[id];
			item.destroy = true;
			return;
		end
		if t.IsDeleteQueueContains(id) then
			return;
		end
		t.AddItemToDeleteQueue(id);
	end;

	-- 创建结束
	t.OnCreateFinished = function (ds, title)

		local waitting_queue = t.waitting_queue;
		local id = ds["id"];
		local item = waitting_queue[id];
		if item == nil then
			error(string.format("OnCreateFinished: id=%d, role_type=%d, sid=%d", id, ds.role_type, ds.sid));
			return;
		end
		t.RemoveItemFromWaittingQueue(id);

		-- 设置角色属性
		ds["role_type"] = item.type;
		ds["is_destroyed"] = false;
		ds["move_speed"] = 5;
		-- 解析角色数据
		local class = Fight.GetClass(ds);
		class.ParseData(ds, item.msg);
		-- 初始化选中状态
		class.OnInitSelect(ds);
		-- 添加到角色缓存
		AvatarCache.AddAvatar(ds);
		-- 触发回调函数
		local callback = item.callback;
		callback(item.msg, ds, title);
		-- 通知副本添加npc
		FubenManager.OnNotify(FubenHandlerType.OnAddNpc, { ["ds"] = ds });
		-- 如果角色已经销毁, 删除对象
		if item.destroy then
			t.AddItemToDeleteQueue(id);
		end

	end;

	local oldType = type;
	-- 处理创建
	t.ProcessAddQueueItem = function (item)
		local type = item.type;
		if type == RoleType.Monster then
			local id = item.id;
			local sid = item.sid;
			local msg = item.msg;
			local npcInfo = tb.NPCTable[sid];
			local roleName = npcInfo.style .. "_Prefab";
			local smName = npcInfo.style .. "_controller_desc";
			local pos = item.pos;
			local pos_x = pos[1];
			local pos_y = pos[2];
			local pos_z = pos[3];

			local data = tb.NPCTable[sid];
			local chose_area = data.chose_area:split(',');
			local size_y = tonumber(chose_area[2]);
			uFacadeUtility.CreateAvatar(RoleType.Monster, id, pos_x, pos_y, pos_z, roleName, smName, "LittleMonsterTitle", size_y, AvatarTitleLayer.Monster, "Monster");
		

		elseif type == RoleType.EliteMonster or type == RoleType.FubenEliteMonster then

			local id = item.id;
			local sid = item.sid;
			local msg = item.msg;
			local npcInfo = tb.NPCTable[sid];
			local roleName = npcInfo.style .. "_Prefab";
			local smName = npcInfo.style .. "_controller_desc";
			local pos = item.pos;
			local pos_x = pos[1];
			local pos_y = pos[2];
			local pos_z = pos[3];

			local data = tb.NPCTable[sid];
			local chose_area = data.chose_area:split(',');
			local size_y = tonumber(chose_area[2]);
			uFacadeUtility.CreateAvatar(RoleType.Monster, id, pos_x, pos_y, pos_z, roleName, smName, "MonsterTitle", size_y, AvatarTitleLayer.Monster, "Monster");
			
		elseif type == RoleType.OtherPlayer or type == RoleType.OfflinePlayer or type == RoleType.GuideNpc then

			local id = item.id;
			local sid = item.sid;
			local msg = item.msg;
			local pos = msg.pos;
			local pos_x = pos[1];
			local pos_y = pos[2];
			local pos_z = pos[3];
			local career = msg.career;
			local logicName = Fight.GetLuaLogicByCareer(career);
			local roleName, smName
			if type ~= RoleType.GuideNpc then
				roleName = Fight.GetRoleSuitName(career, msg.sex, msg.suitActivateId);
				smName  = string.gsub(roleName, "_Prefab", "_controller_desc");
			else
				local npcInfo = tb.NPCTable[sid];
				roleName = npcInfo.style .. "_Prefab";
				smName = npcInfo.style .. "_controller_desc";
				logicName = "Solider"
			end
			uFacadeUtility.CreateOtherPlayer(type, id, pos_x, pos_y, pos_z, roleName, smName, "OtherPlayerTitle", 2.5, AvatarTitleLayer.OtherPlayer, logicName);

		elseif type == RoleType.WorldBoss or type == RoleType.FubenBoss then

			local id = item.id;
			local sid = item.sid;
			local msg = item.msg;
			local npcInfo = tb.NPCTable[sid];
			local roleName = npcInfo.style .. "_Prefab";
			local smName = npcInfo.style .. "_controller_desc";
			local logic = item.logic;
			local pos = item.pos;
			local pos_x = pos[1];
			local pos_y = pos[2];
			local pos_z = pos[3];
			local data = tb.NPCTable[sid];
			local chose_area = data.chose_area:split(",");
			local size_y = tonumber(chose_area[2]);
			uFacadeUtility.CreateAvatar(RoleType.WorldBoss, id, pos_x, pos_y, pos_z, roleName, smName, "MonsterTitle", size_y, AvatarTitleLayer.Monster, logic);

		elseif type == RoleType.Npc or type == RoleType.GatherItem or type == RoleType.Transport then
			local id = item.id;
			local sid = item.sid;
			local msg = item.msg;
			local style = client.tools.ensureString(msg.style);
			local npcInfo = tb.NPCTable[sid];
			local roleName = "";
			if style == nil then
				roleName = npcInfo.style .. "_Prefab";
			else
				roleName = style .. "_Prefab";
			end
			
			local size_y = 2.5;
			local npc_data = tb.NPCTable[sid];
			if npc_data.chose_area == nil then
				-- error("npc chose_area is nil: " .. sid);
			else
				local chose_area = npc_data.chose_area:split(',');
				size_y = math.max(size_y, tonumber(chose_area[2]));
			end
			local pos = item.pos;
			local pos_x = pos[1];
			local pos_y = pos[2];
			local pos_z = pos[3];
			local npcType = npcInfo.type;
			-- ["NpcType_Interaction"] = 100,
			-- ["NpcType_Trigger"] = 101,
			-- ["NpcType_Gather"] = 102
			local title = "NpcTitle"
			if npcInfo.showname ~= nil and npcInfo.showname == 0 then
				title = ""
			end
			if npcType == commonEnum.NpcType.NpcType_Interaction then
				-- 宝箱是个特殊物品，没有状态机描述文件
				local smName = string.gsub(roleName, "_Prefab", "_controller_desc");
				if roleName == "baoxiang_Prefab" then
					smName = "";
				end
				uFacadeUtility.CreateAvatar(RoleType.Npc, id, pos_x, pos_y, pos_z, roleName, smName, title, size_y, AvatarTitleLayer.Npc, "Npc");
			elseif npcType == commonEnum.NpcType.NpcType_Trigger then
				uFacadeUtility.CreateAvatar(RoleType.Npc, id, pos_x, pos_y, pos_z, roleName, "", title, size_y, AvatarTitleLayer.Npc, "Npc");
			elseif npcType == commonEnum.NpcType.NpcType_Gather then
				uFacadeUtility.CreateAvatar(RoleType.Npc, id, pos_x, pos_y, pos_z, roleName, "", title, size_y, AvatarTitleLayer.Npc, "Npc");
			else
			end
		else

		end
	end;

	-- 清空队列
	t.ClearAddQueue = function ()
		local add_list = t.add_list;
		for i = 1, #add_list do
			add_list[i] = nil;
		end
		local add_queue = t.add_queue;
		for k, v in pairs(add_queue) do
			add_queue[k] = nil;
		end
	end;

	-- 处理延迟创建
	t.ProcessAddQueue = function ()
		local add_list = t.add_list;
		local count = #add_list;
		if count == 0 then
			return;
		end
		local list = {};
		local add_queue = t.add_queue;
		for i = 1, count do
			local item = add_list[i];
			if item ~= nil then
				list[#list + 1] = item;
			end
			add_queue[item.id] = nil;
			add_list[i] = nil;
			-- for k = i, count do
			-- 	add_list[k] = add_list[k + 1];
			-- end
			-- break;
		end
		for i = 1, #list do
			local item = list[i];
			t.AddItemToWaittingQueue(item);
			t.ProcessAddQueueItem(item);
		end
	end;

	-- 清空队列
	t.ClearDeleteQueue = function ()
		local que = t.delete_queue;
		for k, v in pairs(que) do
			que[k] = nil;
		end
	end;


	-- 处理删除对象
	t.ProcessDeleteQueue = function ()
		local list = {};
		local que = t.delete_queue;
		for k, v in pairs(que) do
			list[#list + 1] = k;
			que[k] = nil;
		end
		for i = 1, #list do
			local id = list[i];
			local ds = AvatarCache.GetAvatar(id);
			if ds ~= nil then
				ds["is_destroyed"] = true;
				local class = Fight.GetClass(ds);
				if class.OnDestroy ~= nil then
					class.OnDestroy(ds);
				end
				uFacadeUtility.DestroyAvatar(id);
			end
		end
	end;

	-- 更新
	t.Update = function ()
		t.ProcessDeleteQueue();
		t.ProcessAddQueue();
	end;

	-- 清空
	t.Clear = function ()
		t.ClearAddQueue();
		t.ClearDeleteQueue();
		t.ClearWaittingQueue();
	end;

	return t;
end


InstanceManager = CreateInstanceManager();