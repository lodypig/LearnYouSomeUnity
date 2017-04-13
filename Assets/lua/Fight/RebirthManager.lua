
-- 复活管理器，玩家复活或死亡都会触发对应的事件
function CreateRebirthManager()
	local t = {};
	-- 死亡
	t.OnDie = function (ds)
		if ds.role_type == RoleType.Player then
			-- 清空技能队列
			SkillButtons.ClearAllButtonEvents();
			ClickMoveManager.Clear();
			JoystickManager.Clear();
			if not FubenManager.isPlotlineFuben() then
				-- print("t.OnDie")
				-- print(debug.traceback())
				PanelManager:CreateFullScreenPanel("Rebirth");
			end
		end
	end;
	-- 复活
	t.OnRebirth = function (ds)
		if ds.role_type == RoleType.Player then
			-- 清空技能队列
			SkillButtons.ClearAllButtonEvents();
			ClickMoveManager.Clear();
			JoystickManager.Clear();
			local is_auto_fighting = ds.is_auto_fighting;
			if is_auto_fighting then
				ds.is_ghost = true;
				-- local pos_x = ds.origin_x;
				-- local pos_y = ds.origin_y;
				-- local pos_z = ds.origin_z;
				-- Fight.ClickMoveTo(ds, SourceType.AutoFight, pos_x, pos_y, pos_z);
			end
		end
	end;

	return t;
end

RebirthManager = CreateRebirthManager();