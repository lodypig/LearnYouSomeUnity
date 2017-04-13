function CreateUIManager()
	local t = {};
	t.ui_by_id = {};
	t.ui_by_name = {};
	-- 判断是否存在 (by id)
	t.HasUI = function (id)
		local ui = t.GetUI(id);
		return ui ~= nil;
	end;
	-- 判断是否存在 (by name)
	t.HasNamedUI = function (name)
		local ui = t.GetUIByName(name);
		return ui ~= nil;
	end;
	-- 获取 UI (by id)
	t.GetUI = function (id)
		return t.ui_by_id[id];
	end;
	-- 获取 UI (by name)
	t.GetUIByName = function (name)
		return t.ui_by_name[name];
	end;
	-- 创建 UI
	t.CreateUI = function (prefabName, param)
		local list = t.ui_by_id;
		local id = 0;
		local ui = {};
		if list[1] then
			id = list[1];
			list[1] = list[id];
		else
			if #list == 0 then
				id = 2;
			else
				id = #list + 1;
			end
		end
		ui.id = id;
		ui.name = "unnamed_" .. id;
		ui.prefabName = prefabName;
		ui.destroyed = false;
		ui.mask_enable = false;
		ui.SetLayer = function (layer, sortingOrder)
			--uFacadeUtility.SetLayer(layer, sortingOrder);
		end;
		ui.AddMask = function (is_transparent, closed_when_click)
			
		end;
		ui.RemoveMask = function ()

		end;
		ui.Destroy = function ()
			ui.destroyed = true;
			local wrapper = ui.wrapper;
			if wrapper ~= nil then
				ui.wrapper = nil;
				GameObject.Destroy(wrapper.gameObject);
			end
		end;
		ui.Create = function (param)
			uFacadeUtility.CreateUI(prefabName, ui, param);
		end;
		t.ui_by_id[id] = ui;
		ui.Create(param);
		return ui;
	end;
	-- 创建 UI
	t.CreateUIByName = function (name, prefabName)
		local ui = t.GetUIByName(name);
		if ui ~= nil then
			return ui;
		end
		ui = t.CreateUI(prefabName);
		local id = ui.id;
		t.ui_by_name[name] = ui;
		return ui;
	end;
	-- 释放 UI
	t.ReleaseUI = function (id)
		local ui = t.GetUI(id);
		local name = ui.name;
		local list = t.ui_by_id;
		list[id] = nil;
		local ui_by_name = t.ui_by_name;
		ui_by_name[name] = nil;
		if list[1] then
			list[id] = list[1];
			list[1] = id;
		else
			list[id] = nil;
			list[1] = id;
		end
	end;
	-- 销毁 UI (by id)
	t.DestroyUI = function (id)
		local ui = t.GetUI(id);
		if ui == nil then
			return;
		end
		t.ReleaseUI(id);
		ui.Destroy();
	end;
	-- 销毁 UI (by name)
	t.DestroyUIByName = function (name)
		local ui = t.GetUIByName(name);
		if ui == nil then
			return;
		end
		local id = ui.id;
		t.ReleaseUI(id);
		ui.Destroy();
	end;
	-- 销毁所有 UI
	t.DestroyAllUI = function ()
		local ui_by_id = t.ui_by_id;
		for k, v in pairs(ui_by_id) do
			local ui = v;
			ui.Destroy();
			ui_by_id[k] = nil;
		end
		local ui_by_name = t.ui_by_name;
		for k, v in pairs(ui_by_name) do
			ui_by_name[k] = nil;
		end
	end;
	return t;
end

UIManagerNew = CreateUIManager();