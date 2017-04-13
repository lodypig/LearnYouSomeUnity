function CreateDropItemCache()

	local t = {};

	t.drop_items = {};

	-- 添加掉落物品
	function t.AddDropItem(ds)
		local drop_items = t.drop_items;
		local id = ds["id"];
		drop_items[id] = ds;
	end

	-- 删除掉落物品
	function t.RemoveDropItem(id)
		local drop_items = t.drop_items;
		drop_items[id] = nil;
	end

	-- 存在角色
	function t.HasDropItem(id)
		return t.GetDropItem(id) ~= nil;
	end

	-- 获取角色
	function t.GetDropItem(id)
		local drop_items = t.drop_items;
		return drop_items[id];
	end

	-- 删除所有掉落物品
	function t.RemoveAllDropItems()
		local drop_items = t.drop_items;
		for k, v in pairs(drop_items) do
			drop_items[k] = nil;
		end
	end

	-- 删除掉落物品
	function t.DestroyDropItem(id)
		uFacadeUtility.DestroyDropItem(id);
	end

	return t;
end

-- 掉落物品缓存
DropItemCache = CreateDropItemCache();