function CreateSingletonManager()
	local t = {};
	t.Update = function ()

		-- local s = DataCache.LuaToJson({ x = 1 });
		InstanceManager.Update();
		ControlLogic.Update();
		FubenManager.Update();
		AreaManager.Update();
		GuideManager.update();


	end;
	return t;
end

SingletonManager = CreateSingletonManager();