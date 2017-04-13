SkillButtons = {};
SkillButtons.Events = {};

--------------------------------------------
-- 技能类型 type: 1 普攻; 2 技能 ; 3 回血
--------------------------------------------

SkillType = {};
SkillType.Normal = 1;
SkillType.Skill = 2;
SkillType.Recovery = 3;

-----------------------------------------------------------------
-- 技能索引 index: type 普攻: 1 普攻按钮; 技能: 1 群攻; 2 必杀 3 特殊技能
-----------------------------------------------------------------


-- 读取首个技能
function SkillButtons.PeekButtonEvents()
	local events = SkillButtons.Events;
	if #events == 0 then
		return nil;
	end
	return events[1];
end


-- 技能队列, 最多缓存一个
function SkillButtons.EnqueueButtonEvent(type, index)
	-- 判断玩家技能 cd 过了没有
	local player = AvatarCache.me;
	if player == nil then
		return;
	end

	local player_class = Fight.GetClass(player);
	-- 角色死亡
	if player_class.IsDead() then
		return;
	end

	local skill_index = Fight.MapSkillButtonToSkillIndex(player, type, index);
	local skill_info = player_class.GetSkillByIndex(skill_index);
	if not skill_info.IsUnlock() then
		ui.showMsg("技能未解锁");
		return;
	end

	if skill_info.id == 40001001 then
		-- 回血技能要特殊处理，血量充足时不能使用
		if player.maxHP == player.hp then
			ui.showMsg("当前生命值已满");
			return;
		end
		if skill_info.IsColdTime() then
			ui.showMsg("药品冷却中，请稍后再试！");
			return;
		end
	end

	if skill_info.IsColdTime() then
		--local skill_data = Fight.GetSkillInfoByIndex(player, skill_index);
		ui.showMsg("技能冷却中");
		return;
	end

	-- 当前没有目标
	-- print("没有目标");
	local skill_data = tb.SkillTable[skill_info.id];
	-- print(skill_info.id);
	-- print(skill_info.info.no_action);
	-- print(skill_data.target_needless);
	if not skill_info.info.no_action and skill_data.target_needless == 0 then
		local target = TargetSelecter.current;
		if target == nil then
			-- 0.662 点击技能时如果没有目标，重新索敌
        	ControlLogic.AutoSelect();
        	target = TargetSelecter.current;
	        if target == nil then
				ui.showMsg("附近没有可攻击的目标");
	            return;
	        end
	        --print(string.format("select: id=%d, frame=%d", target.id, Time.frameCount));
		end
		--print("check");
		local judge = ControlLogic.JudgeCanAttack_AttackTarget(target);
		if judge ~= AttackJudge.TargetCanAttack then
			Utility.ShowWhyCanNotAttack(judge);
			return;
		end
		--print(judge);
	end

	local events = SkillButtons.Events;
	if #events == 0 then
		local event = {};
		event.index = index;
		event.type = type;
		events[1] = event;
	else
		if type == SkillType.Normal then
			return;
		end
		local event = events[1];
		event.index = index;
		event.type = type;
	end
end

-- 判断是否存在按钮事件
function SkillButtons.HasButtonEvent()
	local events = SkillButtons.Events;
	return #events > 0;
end


-- 按钮事件出队列
function SkillButtons.DequeueButtonEvent()
	local events = SkillButtons.Events;
	if #events == 0 then
		return nil;
	end
	local event = events[1];
	for i = 1, #events - 1 do
		events[i] = events[i + 1];
	end
	events[#events] = nil;
	return event;
end


-- 清除所有按钮事件
function SkillButtons.ClearAllButtonEvents()
	local events = SkillButtons.Events;
	for i = 1, #events do
		events[i] = nil;
	end
end