
-- 创建目标选择器
function CreateTargetSelecter()

	local t = {};

	-- 当前目标
	t.current = nil;

	-- 第一类目标
	t.firstClass = nil;


	-- 选择一个优先级最高的目标
	function t.SelectOne(filterFunc, sortFunc)
		local target_list = AvatarCache.GetAndSortAvatarList(filterFunc, sortFunc);
		if #target_list == 0 then
			return nil;
		end
		return target_list[1];
	end

	-- 选择当前目标的下一个目标
	-- current 是当前目标
	-- wrap 代表要不要轮转
	function t.SelectNext(current, wrap, filterFunc, sortFunc)
		local player = AvatarCache.me;
		-- 获取目标列表
		local target_list = AvatarCache.GetAndSortAvatarList(filterFunc, sortFunc);
		-- 提取目标数量
		local target_count = #target_list;
		-- 没有目标，直接返回 nil
		if target_count == 0 then
			return nil;
		end

		-- 如果列表中只有一个目标，直接返回第一个目标
		-- 如果没有当前目标，也直接返回第一个目标
		if target_count == 1 or current == nil then
			return target_list[1];
		end

		-- 获取当前目标在列表中的索引
		local index = 0;
		for i = 1, #target_list do
			if target_list[i].id == current.id then
				index = i;
				break;
			end
		end
		-- 列表中没有当前目标, 直接返回第一个目标
		if index == 0 then
			return target_list[1];
		end
		-- 计算下一个目标索引
		local next_index = index + 1;
		if wrap then
			-- 循环方式
			if next_index > target_count then
				next_index = 1;
			end
		else
			-- 钳制方式
			if next_index > target_count then
				next_index = target_count;
			end
		end
		-- 返回目标
		return target_list[next_index];
	end

	-- 清空当前目标
	function t.ClearTarget()
		--print("ClearTarget: " .. debug.traceback());
		local current = t.current;
		if current == nil then
			return;
		end
		t.ClearTargetRaw();
		t.OnClearTarget(current);

		-- 0.662 清空目标死亡之后不自动选择下一个，放到Controllogic.Update()中每一帧来处理 
		-- t.AutoSelect();
	end

	-- 清空当前目标
	function t.ClearTargetRaw()
		local current = t.current;
		if current == nil then
			return;
		end
		local firstClass = t.firstClass;
		if firstClass ~= nil and firstClass["id"] == current["id"] then
			t.firstClass = nil;
		end
		--print(string.format("clear: id=%d, trace=%s, frame=%d", current.id, debug.traceback(), Time.frameCount));
		t.current = nil;
	end

	-- 存在攻击目标
	function t.HasTarget()
		return t.current ~= nil;
	end

	-- 存在第一类目标
	function t.HasFirstClassTarget()
		return t.firstClass ~= nil;
	end


	-- 自动拾取目标
	function t.AutoSelectTarget()
		local player = AvatarCache.me;
		local control_logic = ds["control_logic"];
		ControlLogic.AutoSelect(control_logic);
	end

	-- 设置第一类目标
	function t.SetFirstClassTarget(target)
		t.firstClass = target;
	end


	function t.ShowTarget(target)
		local isOtherPlayer = Checker.CheckIsOtherPlayer(target);
		local type = "player";
		if not isOtherPlayer then
			type = "npc";
		end
		local id = target["id"];
		local name = target["name"];
		local level = target["level"];
		local sid = target["sid"];
		local hp = target["hp"];
		local maxHP = target["maxHP"];
		local hp_percent = hp / maxHP;
		local info = string.format("%s, %d, %s, %d, %d, %f", type, id, name, level, sid, hp_percent);
		local table = {};
		table[1] = info;
		table[2] = Color.white;
		EventManager.onEvent(Event.ON_TARGET_SELECT, table);
	end

	-- 显示/隐藏选中光效
	function t.ShowSelectedEffect(show, target)
		if target == nil then
			show = false;
		end
		if show then
			if ControlLogic.JudgeCanAttack_SelectedTarget(target) == AttackJudge.TargetCanAttack then
				uFacadeUtility.ShowCanAttackSelectEffect(true, target.id);
			else
				uFacadeUtility.ShowCanNotAttackSelectEffect(true, target.id);
			end
		else
			uFacadeUtility.HideSelectedEffect();
		end
	end

	-- 设置对象事件，在当前没有目标，选中的新目标的时候触发
	function t.OnSetTarget(target)
		if target ~= nil then
			target.selected = true;
			local class = Fight.GetClass(target);
			if class ~= nil then
				local onSelectFunc = class.OnSelect;
				if onSelectFunc ~= nil then
					t.ShowSelectedEffect(true, target)
					onSelectFunc(target);
				end
			end
			t.ShowTarget(target);
		end

		--TargetSelecter.PrintTarget();
	end

	-- 改变目标事件，在当前有目标，选中了新的目标的时候触发
	function t.OnChangeTarget(current, target)


		-- 当前
		if current ~= nil then
			current.selected = false;
			local class = Fight.GetClass(current);
			if class ~= nil then
				local onUnselectFunc = class.OnUnselect;
				if onUnselectFunc ~= nil then
					t.ShowSelectedEffect(false, nil);
					onUnselectFunc(current);
				end
			end
		end

		-- 当前目标选中事件
		if target ~= nil then
			target.selected = true;
			local class = Fight.GetClass(target);
			if class ~= nil then
				local onSelectFunc = class.OnSelect;
				if onSelectFunc ~= nil then
					t.ShowSelectedEffect(true, target);
					onSelectFunc(target);
				end
			end
			t.ShowTarget(target);
		end
		
		--TargetSelecter.PrintTarget();
	end

	-- 自动拾取
	function t.AutoSelect()


		-- 如果当前目标，也是第一类目标，放弃自动拾取
		local current = t.current;
        
        if current ~= nil then
            local firstClass = t.firstClass;
            if firstClass ~= nil  and current["id"] == firstClass["id"] then
                return;
            end
        end


		local player = AvatarCache.me;


		if player ~= nil then


			-- local old_current = TargetSelecter.current;

			-- 自动更新目标
	        local type = player["control_logic"];
	        local logic = ControlLogic[type];
	        logic.AutoSelect();

	        -- local new_current = TargetSelecter.current;

	        -- if (old_current == nil and new_current ~= nil) or
	        --    (old_current ~= nil and new_current == nil) or
	        --    (old_current ~= nil and new_current ~= nil and old_current["id"] ~= new_current["id"]) then
	        -- 	TargetSelecter.PrintTarget();
	        -- end
		end


	end

	-- 清空目标事件，当前有目标，清除目标的时候触发
	function t.OnClearTarget(current)


		if current ~= nil then
			current.selected = false;
			local class = Fight.GetClass(current);
			if class ~= nil then
				local onUnselectFunc = class.OnUnselect;
				if onUnselectFunc ~= nil then
					t.ShowSelectedEffect(false, nil);
					onUnselectFunc(current);
				end
			end
		end

		EventManager.onEvent(Event.ON_TARGET_CANCEL_SELECT);
	end

	-- 设置当前目标
	function t.SetCurrentTarget(target)
		if target ~= nil then
			local current = t.current;
			if current == nil then
				t.SetCurrentTargetRaw(target);
				t.OnSetTarget(target);
			else
				if current["id"] == target["id"] then
					return;
				end
				t.SetCurrentTargetRaw(target);
				t.OnChangeTarget(current, target);
			end
		else
			t.ClearTarget();
		end
	end

	-- 打印目标
	function t.PrintTarget()
        local current = t.current;
        local current_id = 0;
        local current_hp = 0;
        if current ~= nil then
            current_id = current["id"];
            current_hp = current["hp"];
        end
        local firstClass_id = 0;
        local firstClass = t.firstClass;
        if firstClass ~= nil then
            firstClass_id = firstClass["id"];
        end
      	--print(string.format("[target] current_id=%d, current_hp=%d, firstClass=%d, trace=%s", current_id, current_hp, firstClass_id, debug.traceback()));
    end;

	-- 设置当前目标
	function t.SetCurrentTargetRaw(target)
		if target ~= nil then
			t.current = target;
		else
			local current = t.current;
			if current ~= nil then
				local firstClass = t.firstClass;
				if firstClass ~= nil and firstClass["id"] == current["id"] then
					t.firstClass = nil;
				end
				t.current = nil;
			end
		end
	end

	-- 目标销毁
	function t.OnAvatarDestroy(ds)
		local current = t.current;
		if current ~= nil and current["id"] == ds["id"] then
			t.ClearTarget();
		end
	end

	-- 目标死亡
	function t.OnAvatarDie(ds)
		local current = t.current;
		if current ~= nil and current["id"] == ds["id"] then
			t.ClearTarget();
		end
	end

	-- 更新
	function t.Update()
		local current = t.current;
		if current ~= nil then
			if ControlLogic.JudgeCanAttack_SelectedTarget(current) == AttackJudge.TargetCanAttack then
				uFacadeUtility.ShowCanNotAttackSelectEffect(false, 0);
				uFacadeUtility.ShowCanAttackSelectEffect(true, current.id);
			else
				uFacadeUtility.ShowCanAttackSelectEffect(false, 0);
				uFacadeUtility.ShowCanNotAttackSelectEffect(true, current.id);
			end
		end
	end

	return t;

end

TargetSelecter = CreateTargetSelecter();