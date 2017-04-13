function CreateAreaManager()
	local t = {};
	t.listeners = {};
	-- 添加回调
	t.AddListener = function (scene_sid, task_sid, pos_x, pos_y, pos_z, radius, listener)
		if listener == nil then
			return;
		end
		local listeners = t.listeners;
		if listeners[scene_sid] == nil then
			listeners[scene_sid] = {};
		end
		local item = {};
		item.pos_x = pos_x;
		item.pos_y = pos_y;
		item.pos_z = pos_z;
		item.radius = radius;
		item.callback = listener;
		listeners[scene_sid][task_sid] = item;
	end;
	-- 删除回调
	t.RemoveListener = function (scene_sid, task_sid)
		local listeners = t.listeners;
		if listeners[scene_sid] == nil then
			return;
		end
		listeners[scene_sid][task_sid] = nil;
	end;
	-- 清空
	t.Clear = function ()
		local listeners = t.listeners;
		for k, v in pairs(listeners) do
			listeners[k] = nil;
		end
	end;
	-- 更新
	t.Update = function ()
		local player = AvatarCache.me;
		if player == nil then
			return;
		end
		local pos_x = player.pos_x;
		local pos_y = player.pos_y;
		local pos_z = player.pos_z;
		local curr_scene_id = DataCache.scene_sid;
		local listeners = t.listeners;
		if listeners[curr_scene_id] ~= nil then
			local items = listeners[curr_scene_id];
			for k, v in pairs(items) do
				local item = v;
				local radius = item.radius;
				local cx = item.pos_x;
				local cy = item.pos_y;
				local cz = item.pos_z;
				local dx = pos_x - cx;
				local dy = pos_y - cy;
				local dz = pos_z - cz;
				local dist2 = dx * dx + dz * dz;
				if dist2 < radius * radius then
					item.callback();
					items[k] = nil;
				end
			end
		end
	end;
	return t;
end

AreaManager = CreateAreaManager();