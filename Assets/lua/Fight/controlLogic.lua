



-- 控制类型： 当增加了新的控制类型的时候，在这里添加对应的类型
ControlLogicType = {};
ControlLogicType.WildHeping = "WildHeping";
ControlLogicType.WildPK = "WildPK";
ControlLogicType.WildAutoFightHeping = "WildAutoFightHeping";
ControlLogicType.WildAutoFightPK = "WildAutoFightPK";
ControlLogicType.SingleFuben = "SingleFuben";


function CreateControlLogic_WildHeping()

	local t = {};

	-- 点击目标，这个目标为非选中状态
	t.ClickTarget = function (ds)
        -- print("DoubleClickTarget");
        local role_type = ds.role_type;
        if role_type == RoleType.Monster then
            if ds.hp > 0 then
                TargetSelecter.SetCurrentTarget(ds);
                TargetSelecter.SetFirstClassTarget(ds);
            end    
        else
            TargetSelecter.SetCurrentTarget(ds);
            TargetSelecter.SetFirstClassTarget(ds);        
        end
	end;

	-- 双击目标，定义为当前已经选中了目标，再点一下
	t.DoubleClickTarget = function (ds)
        local judge = t.JudgeCanAttack_Click(ds);
        if judge ~= AttackJudge.TargetCanAttack then
            if Checker.CheckIsOtherPlayer(ds) then
                if not Checker.CheckIsRedName(ds) then
                    Fight.ClickMoveTo(AvatarCache.me, SourceType.Player, ds.pos_x, ds.pos_y, ds.pos_z);
                    return;
                end
            end
            Utility.ShowWhyCanNotAttack(judge);
            return;
        end
        -- 攻击当前目标
        SkillButtons.EnqueueButtonEvent(SkillType.Normal, 1);
	end;

	-- 攻击目标，定义为按下按钮攻击目标， 如果按下的不是攻击技能，不会走到这里，如按下瞬移
	t.AttackTarget = function (ds)
        --print("AttackTarget");
		t.DoubleClickTarget(ds);
	end;

	-- 按下Tab选择目标
	t.TabTarget = function ()
		local current = TargetSelecter.current;
		local target = TargetSelecter.SelectNext(current, true, t.FilterFunc_TabTarget, t.Compare_TabTarget);
		if target ~= nil then
			TargetSelecter.SetFirstClassTarget(target);
			TargetSelecter.SetCurrentTarget(target);
        else
            ui.showMsg("附近没有可攻击的目标");
		end
	end;

	-- 自动选择目标
	t.AutoSelect = function ()

        -- 如果当前目标，也是第一类目标，放弃自动拾取
        local current = TargetSelecter.current;
        if current ~= nil then
            local firstClass = TargetSelecter.firstClass;
            if firstClass ~= nil  and current["id"] == firstClass["id"] then
                return;
            end
        end

        -- 自动拾取当前最近目标
		local target = TargetSelecter.SelectOne(t.FilterFunc_AutoSelect, t.Compare_AutoSelect);
        if target ~= nil and (current == nil or target["id"] ~= current["id"]) then
			TargetSelecter.SetCurrentTarget(target);
		end
	end;

    
    t.JudgeCanAttack_SelectedTarget = function (ds)
        return t.JudgeCanAttack_DoubleClick(ds);
    end;

	-- 对目标的可攻击判断
	t.JudgeCanAttack_Click = function (ds)


        -- 判断是否是玩家
        if Checker.CheckIsPlayer(ds) then
            return AttackJudge.TargetCanNotAttack;
        end

        -- 判断死亡
        if Checker.CheckIsDead(ds) then
        	return AttackJudge.TargetIsDead;
        end

        -- 判断大 Boss, 可以攻击
        if Checker.CheckIsBigBoss(ds) then
        	return AttackJudge.TargetCanAttack;
        end

        -- 判断小怪，可以攻击
        if Checker.CheckIsMonster(ds) then
            return AttackJudge.TargetCanAttack;
        end

        -- 小 Boss和精英怪
        if Checker.CheckIsSmallBoss(ds) then
            return AttackJudge.TargetCanAttack;
        end

        -- 检查是否精英怪
        if Checker.CheckIsEliteMonster(ds) then
            return AttackJudge.TargetCanAttack;
        end

        -- 检查是否Npc，无法攻击Npc
        if Checker.CheckIsNpc(ds) then
            return AttackJudge.TargetCanNotAttack;
        end


        -- 检查是否是其他玩家
        if Checker.CheckIsOtherPlayer(ds) then

        	-- 检查对象是否是无敌
            if Checker.CheckIsImbaState(ds) then
            	return AttackJudge.TargetIsInvincible;
            end

            -- 玩家小于保护等级不能攻击
            if Checker.CheckIsBelowProtectLevel(AvatarCache.me) then
            	return AttackJudge.SelfLevelBelow30;
            end

            -- 目标小于保护等级不能攻击
            if Checker.CheckIsBelowProtectLevel(ds) then
            	return AttackJudge.TargetLevelBelow30;
           	end

            -- 检查自身是否处于安全区
            if Checker.CheckIsWithinSafeArea(AvatarCache.me) then
                return AttackJudge.SelfWithinSafeZone;
            end

            -- 检查目标是否处于安全区
            if Checker.CheckIsWithinSafeArea(ds) then
                return AttackJudge.TargetWithinSafeZone;
            end

            -- 检查是否是队友
            if Checker.CheckIsSameTeam(ds) then
                return AttackJudge.TargetIsTeamMate;
            end

            -- 检查是否是同公会
            if Checker.CheckIsSameLegion(ds) then
                return AttackJudge.TargetIsArmyMember;
            end

            -- 检查PK
            local judge = Checker.CheckPK(ds);
            if judge ~= AttackJudge.TargetCanAttack then
                return judge;
            end

           	-- 红名可以攻击
            if Checker.CheckIsRedName(ds) then
                return AttackJudge.TargetCanAttack;
            end

                
            -- 检查是否是白名
            if Checker.CheckIsWhiteName(ds) then
                if not AvatarCache.me._t.IsAvatarAttackingMe(ds["id"]) then
                    return AttackJudge.TargetIsWhiteName;
                end
            end

            return AttackJudge.TargetCanAttack;
    	end

    	return AttackJudge.TargetCanNotAttack;
	end;

	-- 对目标的可攻击判断
	t.JudgeCanAttack_DoubleClick = function (ds)
		return t.JudgeCanAttack_Click(ds);
	end;

	-- 对目标的可攻击判断
	t.JudgeCanAttack_AttackTarget = function (ds)
		return t.JudgeCanAttack_Click(ds);
	end;


	t.FilterFunc_TabTarget = function (ds)
		local judge = t.JudgeCanAttack_TabTarget(ds);
		return judge == AttackJudge.TargetCanAttack;
	end;

	t.FilterFunc_AutoSelect = function (ds)
		local judge = t.JudgeCanAttack_AutoSelect(ds);
		return judge == AttackJudge.TargetCanAttack;
	end;

	-- 对目标的可攻击判断
	t.JudgeCanAttack_TabTarget = function (ds)
        local player = AvatarCache.me;
        local lost_target_distance = player.lost_target_distance;
        if not Checker.CheckIsWithinPlayerScope(ds, lost_target_distance) then
            return AttackJudge.TargetCanNotAttack;
        end

		return t.JudgeCanAttack_Click(ds);
	end;

	-- 对目标的可攻击判断
	t.JudgeCanAttack_AutoSelect = function (ds)


        -- 判断是否是玩家
        if Checker.CheckIsPlayer(ds) then
            return AttackJudge.TargetCanNotAttack;
        end

		-- 判断死亡
        if Checker.CheckIsDead(ds) then
        	return AttackJudge.TargetIsDead;
        end

        local player = AvatarCache.me;
        -- 检查是否在玩家半径为 radius 的范围内
        local auto_lock_radius = player["auto_lock_radius"];
        if not Checker.CheckIsWithinPlayerScope(ds, auto_lock_radius) then
            return AttackJudge.TargetNotWithinAutoFightScope;
        end

        -- 判断大 Boss, 可以攻击
        if Checker.CheckIsBigBoss(ds) then
        	return AttackJudge.TargetCanAttack;
        end

        -- 判断小怪，可以攻击
        if Checker.CheckIsMonster(ds) then
            return AttackJudge.TargetCanAttack;
        end

        -- 小 Boss和精英怪
        if Checker.CheckIsSmallBoss(ds) then
            return AttackJudge.TargetCanNotAttack;
        end

        -- 检查是否精英怪
        if Checker.CheckIsEliteMonster(ds) then
            return AttackJudge.TargetCanNotAttack;
        end

        -- 检查是否是其他玩家
        if Checker.CheckIsOtherPlayer(ds) then

        	-- 检查对象是否是无敌
            if Checker.CheckIsImbaState(ds) then
            	return AttackJudge.TargetIsInvincible;
            end

            -- 玩家小于保护等级不能攻击
            if Checker.CheckIsBelowProtectLevel(AvatarCache.me) then
            	return AttackJudge.SelfLevelBelow30;
            end

            -- 目标小于保护等级不能攻击
            if Checker.CheckIsBelowProtectLevel(ds) then
            	return AttackJudge.TargetLevelBelow30;
           	end

           	-- 红名可以攻击
            if Checker.CheckIsRedName(ds) then
                return AttackJudge.TargetCanAttack;
            end
            
            -- 检查PK
            local judge = Checker.CheckPK(ds);
            if judge ~= AttackJudge.TargetCanAttack then
                return judge;
            end

            -- 检查自身是否处于安全区
            if Checker.CheckIsWithinSafeArea(AvatarCache.me) then
                return AttackJudge.SelfWithinSafeZone;
            end

            -- 检查目标是否处于安全区
            if Checker.CheckIsWithinSafeArea(ds) then
                return AttackJudge.TargetWithinSafeZone;
            end

            -- 检查是否是队友
            if Checker.CheckIsSameTeam(ds) then
            	return AttackJudge.TargetIsTeamMate;
            end

            -- 检查是否是同公会
            if Checker.CheckIsSameLegion(ds) then
            	return AttackJudge.TargetIsArmyMember;
            end
                
            -- 检查是否是白名
            if Checker.CheckIsWhiteName(ds) then
                if not AvatarCache.me._t.IsAvatarAttackingMe(ds["id"]) then
                    return AttackJudge.TargetIsWhiteName;
                end
            end

            return AttackJudge.TargetCanAttack;
    	end

    	return AttackJudge.TargetCanNotAttack;

	end;

	-- 优先选择排序函数
	t.Compare_TabTarget = function (a, b)
		local result = Comparer.CompareIsBigBoss(a, b);
		if result ~= 0 then
			if result < 0 then
				return true;
			else
				return false;
			end
		end
		return Comparer.CompareNearerDistance(a, b) < 0;
	end;

	-- 优先选择排序函数
	t.Compare_AutoSelect = function (a, b)
		local result = Comparer.CompareIsBigBoss(a, b);
		if result ~= 0 then
			if result < 0 then
				return true;
			else
				return false;
			end
		end
		return Comparer.CompareNearerDistance(a, b) < 0;
	end;

    t.Update = function ()
        local player = AvatarCache.me;
        local lost_target_distance = player["lost_target_distance"];
        ControlLogic.UpdateTargetLost(lost_target_distance);
    end;

	return t;
end


-- 创建野外 PK 模式
function CreateControlLogic_WildPK()
    local t = {};

    -- 点击目标，这个目标为非选中状态
    t.ClickTarget = function (ds)
        local role_type = ds.role_type;
        if role_type == RoleType.Monster then
            if ds.hp > 0 then
                TargetSelecter.SetCurrentTarget(ds);
                TargetSelecter.SetFirstClassTarget(ds);
            end    
        else
            TargetSelecter.SetCurrentTarget(ds);
            TargetSelecter.SetFirstClassTarget(ds);        
        end
    end;

    -- 双击目标，定义为当前已经选中了目标，再点一下
    t.DoubleClickTarget = function (ds)
        local judge = t.JudgeCanAttack_Click(ds);
        if judge ~= AttackJudge.TargetCanAttack then
            Utility.ShowWhyCanNotAttack(judge);
            return;
        end
        -- 攻击当前目标
        SkillButtons.EnqueueButtonEvent(SkillType.Normal, 1);
    end;


    -- 攻击目标，定义为按下按钮攻击目标， 如果按下的不是攻击技能，不会走到这里，如按下瞬移
    t.AttackTarget = function (ds)
        -- local judge = t.JudgeCanAttack_SelectedTarget(ds);
        -- if judge == AttackJudge.TargetCanAttack then
            t.DoubleClickTarget(ds);
        -- else
            -- Utility.ShowWhyCanNotAttack(judge);
        -- end
    end;

    -- 按下Tab选择目标
    t.TabTarget = function ()
        local current = TargetSelecter.current;
        local target = TargetSelecter.SelectNext(current, true, t.FilterFunc_TabTarget, t.Compare_TabTarget);
        if target ~= nil then
            if current == nil or target.id ~= current.id then
                TargetSelecter.SetCurrentTarget(target);
                TargetSelecter.SetFirstClassTarget(target);
            end
        else
            ui.showMsg("附近没有可攻击的目标");
        end
    end;

    -- 自动选择目标
    t.AutoSelect = function ()

        --print("AutoSelect");

        -- 如果当前目标，也是第一类目标，放弃自动拾取
        local current = TargetSelecter.current;
        if current ~= nil then
            local firstClass = TargetSelecter.firstClass;
            if firstClass ~= nil  and current["id"] == firstClass["id"] then
                return;
            end
        end

        local target = TargetSelecter.SelectOne(t.FilterFunc_AutoSelect, t.Compare_AutoSelect);
        if target ~= nil and (current == nil or target["id"] ~= current["id"]) then
            TargetSelecter.SetCurrentTarget(target);
        end
    end;

    -- 判断当前选中的目标是否可以攻击
    t.JudgeCanAttack_SelectedTarget = function (ds)
        return t.JudgeCanAttack_DoubleClick(ds);
    end;

    -- 对目标的可攻击判断
    t.JudgeCanAttack_Click = function (ds)

        -- 判断是否是玩家
        if Checker.CheckIsPlayer(ds) then
            return AttackJudge.TargetCanNotAttack;
        end

        -- 判断死亡
        if Checker.CheckIsDead(ds) then
            return AttackJudge.TargetIsDead;
        end

        -- 判断大 Boss, 可以攻击
        if Checker.CheckIsBigBoss(ds) then
            return AttackJudge.TargetCanAttack;
        end

        -- 判断小怪，可以攻击
        if Checker.CheckIsMonster(ds) then
            return AttackJudge.TargetCanAttack;
        end

        -- 小 Boss和精英怪
        if Checker.CheckIsSmallBoss(ds) then
            return AttackJudge.TargetCanAttack;
        end

        -- 检查是否精英怪
        if Checker.CheckIsEliteMonster(ds) then
            return AttackJudge.TargetCanAttack;
        end

        -- 检查是否Npc，无法攻击Npc
        if Checker.CheckIsNpc(ds) then
            return AttackJudge.TargetCanNotAttack;
        end

        -- 检查是否是其他玩家
        if Checker.CheckIsOtherPlayer(ds) then

            -- 检查对象是否是无敌
            if Checker.CheckIsImbaState(ds) then
                return AttackJudge.TargetIsInvincible;
            end

            -- 玩家小于保护等级不能攻击
            if Checker.CheckIsBelowProtectLevel(AvatarCache.me) then
                return AttackJudge.SelfLevelBelow30;
            end

            -- 目标小于保护等级不能攻击
            if Checker.CheckIsBelowProtectLevel(ds) then
                return AttackJudge.TargetLevelBelow30;
            end

            -- 检查PK
            local judge = Checker.CheckPK(ds);
            if judge ~= AttackJudge.TargetCanAttack then
                return judge;
            end

            -- 检查自身是否处于安全区
            if Checker.CheckIsWithinSafeArea(AvatarCache.me) then
                return AttackJudge.SelfWithinSafeZone;
            end

            -- 检查目标是否处于安全区
            if Checker.CheckIsWithinSafeArea(ds) then
                return AttackJudge.TargetWithinSafeZone;
            end

            -- 检查是否是队友
            if Checker.CheckIsSameTeam(ds) then
                return AttackJudge.TargetIsTeamMate;
            end

            -- 检查是否是同公会
            if Checker.CheckIsSameLegion(ds) then
                return AttackJudge.TargetIsArmyMember;
            end
                
            return AttackJudge.TargetCanAttack;
        end

        return AttackJudge.TargetCanNotAttack;
    end;

    -- 对目标的可攻击判断
    t.JudgeCanAttack_DoubleClick = function (ds)
        return t.JudgeCanAttack_Click(ds);
    end;

    -- 对目标的可攻击判断
    t.JudgeCanAttack_AttackTarget = function (ds)
        return t.JudgeCanAttack_Click(ds);
    end;


    t.FilterFunc_TabTarget = function (ds)
        local judge = t.JudgeCanAttack_TabTarget(ds);
        return judge == AttackJudge.TargetCanAttack;
    end;

    t.FilterFunc_AutoSelect = function (ds)
        local judge = t.JudgeCanAttack_AutoSelect(ds);
        return judge == AttackJudge.TargetCanAttack;
    end;

    -- 对目标的可攻击判断
    t.JudgeCanAttack_TabTarget = function (ds)
        local player = AvatarCache.me;
        local lost_target_distance = player.lost_target_distance;
        if not Checker.CheckIsWithinPlayerScope(ds, lost_target_distance) then
            return AttackJudge.TargetCanNotAttack;
        end
        return t.JudgeCanAttack_Click(ds);
    end;

    -- 对目标的可攻击判断
    t.JudgeCanAttack_AutoSelect = function (ds)

        -- 判断是否是玩家
        if Checker.CheckIsPlayer(ds) then
            return AttackJudge.TargetCanNotAttack;
        end

        -- 判断死亡
        if Checker.CheckIsDead(ds) then
            return AttackJudge.TargetIsDead;
        end

        local player = AvatarCache.me;
        -- 检查是否在玩家半径为 radius 的范围内
        local auto_lock_radius = player["auto_lock_radius"];
        if not Checker.CheckIsWithinPlayerScope(ds, auto_lock_radius) then
            return AttackJudge.TargetNotWithinAutoFightScope;
        end

        -- 判断大 Boss, 可以攻击
        if Checker.CheckIsBigBoss(ds) then
            return AttackJudge.TargetCanAttack;
        end

        -- 判断小怪，可以攻击
        if Checker.CheckIsMonster(ds) then
            return AttackJudge.TargetCanAttack;
        end

        -- 小 Boss和精英怪
        if Checker.CheckIsSmallBoss(ds) then
            return AttackJudge.TargetCanNotAttack;
        end

        -- 检查是否精英怪
        if Checker.CheckIsEliteMonster(ds) then
            return AttackJudge.TargetCanNotAttack;
        end

        -- 检查是否是其他玩家
        if Checker.CheckIsOtherPlayer(ds) then

            -- 检查对象是否是无敌
            if Checker.CheckIsImbaState(ds) then
                return AttackJudge.TargetIsInvincible;
            end

            -- 玩家小于保护等级不能攻击
            if Checker.CheckIsBelowProtectLevel(AvatarCache.me) then
                return AttackJudge.SelfLevelBelow30;
            end

            -- 目标小于保护等级不能攻击
            if Checker.CheckIsBelowProtectLevel(ds) then
                return AttackJudge.TargetLevelBelow30;
            end

            -- 检查PK
            local judge = Checker.CheckPK(ds);
            if judge ~= AttackJudge.TargetCanAttack then
                return judge;
            end

            -- 检查自身是否处于安全区
            if Checker.CheckIsWithinSafeArea(AvatarCache.me) then
                return AttackJudge.SelfWithinSafeZone;
            end

            -- 检查目标是否处于安全区
            if Checker.CheckIsWithinSafeArea(ds) then
                return AttackJudge.TargetWithinSafeZone;
            end

            -- 检查是否是队友
            if Checker.CheckIsSameTeam(ds) then
                return AttackJudge.TargetIsTeamMate;
            end

            -- 检查是否是同公会
            if Checker.CheckIsSameLegion(ds) then
                return AttackJudge.TargetIsArmyMember;
            end
                
            return AttackJudge.TargetCanAttack;
        end

        return AttackJudge.TargetCanNotAttack;

    end;

    -- 优先选择排序函数
    t.Compare_TabTarget = function (a, b)

        local result = 0;
        result = Comparer.CompareIsOtherPlayer(a, b);
        if result ~= 0 then
            if result < 0 then
                return true;
            else
                return false;
            end
        end
        result = Comparer.CompareIsBigBoss(a, b);
        if result ~= 0 then
            if result < 0 then
                return true;
            else
                return false;
            end
        end
        return Comparer.CompareNearerDistance(a, b) < 0;
    end;

    -- 优先选择排序函数
    t.Compare_AutoSelect = function (a, b)
        local result = 0;
        result = Comparer.CompareIsOtherPlayer(a, b);
        if result ~= 0 then
            if result < 0 then
                return true;
            else
                return false;
            end
        end
        result = Comparer.CompareIsBigBoss(a, b);
        if result ~= 0 then
            if result < 0 then
                return true;
            else
                return false;
            end
        end
        return Comparer.CompareNearerDistance(a, b) < 0;
    end;

    t.Update = function ()
        local player = AvatarCache.me;
        local lost_target_distance = player["lost_target_distance"];
        ControlLogic.UpdateTargetLost(lost_target_distance);
    end;

    return t;
end

-- 创建野外自动战斗和平模式
function CreateControlLogic_WildAutoFightHeping()

    local t = {};

    -- 点击目标，这个目标为非选中状态
    t.ClickTarget = function (ds)
        local role_type = ds.role_type;
        if role_type == RoleType.Monster then
            if ds.hp > 0 then
                TargetSelecter.SetCurrentTarget(ds);
                TargetSelecter.SetFirstClassTarget(ds);
            end    
        else
            TargetSelecter.SetCurrentTarget(ds);
            TargetSelecter.SetFirstClassTarget(ds);        
        end
    end;

    -- 双击目标，定义为当前已经选中了目标，再点一下
    t.DoubleClickTarget = function (ds)
        local judge = t.JudgeCanAttack_Click(ds);
        if judge ~= AttackJudge.TargetCanAttack then
            Utility.ShowWhyCanNotAttack(judge);
            return;
        end
        -- 攻击当前目标
        SkillButtons.EnqueueButtonEvent(SkillType.Normal, 1);
    end;

    -- 攻击目标，定义为按下按钮攻击目标， 如果按下的不是攻击技能，不会走到这里，如按下瞬移
    t.AttackTarget = function (ds)
        t.DoubleClickTarget(ds);
    end;

    -- 按下Tab选择目标
    t.TabTarget = function ()
        local current = TargetSelecter.current;
        local target = TargetSelecter.SelectNext(current, true, t.FilterFunc_TabTarget, t.Compare_TabTarget);
        if target ~= nil then
            TargetSelecter.SetFirstClassTarget(target);
            TargetSelecter.SetCurrentTarget(target);
        else
            ui.showMsg("附近没有可攻击的目标");
        end
    end;

    -- 自动选择目标
    t.AutoSelect = function ()
        
        -- local current_id = 0;
        -- if TargetSelecter.current ~= nil then
        --     current_id = TargetSelecter.current.id;
        -- end
        -- local firstClass_id = 0;
        -- if TargetSelecter.firstClass ~= nil then
        --     firstClass_id = TargetSelecter.firstClass.id;
        -- end

        -- print(string.format("AutoSelect: current=%d, firstClass=%d", current_id, firstClass_id));

        -- 如果当前目标，也是第一类目标，放弃自动拾取
        local current = TargetSelecter.current;
        if current ~= nil then
            local firstClass = TargetSelecter.firstClass;
            if firstClass ~= nil  and current["id"] == firstClass["id"] then
                return;
            end
        end

        local target = TargetSelecter.SelectOne(t.FilterFunc_AutoSelect, t.Compare_AutoSelect);
        if target ~= nil and (current == nil or target["id"] ~= current["id"]) then
            TargetSelecter.SetCurrentTarget(target);
        end
    end;

    -- 判断当前选中的目标是否可以攻击
    t.JudgeCanAttack_SelectedTarget = function (ds)
        return t.JudgeCanAttack_Click(ds);
    end;

    -- 对目标的可攻击判断
    t.JudgeCanAttack_Click = function (ds)

        -- 判断是否是玩家
        if Checker.CheckIsPlayer(ds) then
            return AttackJudge.TargetCanNotAttack;
        end

        -- 判断死亡
        if Checker.CheckIsDead(ds) then
            return AttackJudge.TargetIsDead;
        end

        -- 判断大 Boss, 可以攻击
        if Checker.CheckIsBigBoss(ds) then
            return AttackJudge.TargetCanAttack;
        end

        -- 判断小怪，可以攻击
        if Checker.CheckIsMonster(ds) then
            return AttackJudge.TargetCanAttack;
        end

        -- 小 Boss和精英怪
        if Checker.CheckIsSmallBoss(ds) then
            return AttackJudge.TargetCanAttack;
        end

        -- 检查是否精英怪
        if Checker.CheckIsEliteMonster(ds) then
            return AttackJudge.TargetCanAttack;
        end

        -- 检查是否Npc，无法攻击Npc
        if Checker.CheckIsNpc(ds) then
            return AttackJudge.TargetCanNotAttack;
        end

        -- 检查是否是其他玩家
        if Checker.CheckIsOtherPlayer(ds) then

            -- 检查对象是否是无敌
            if Checker.CheckIsImbaState(ds) then
                return AttackJudge.TargetIsInvincible;
            end

            -- 玩家小于保护等级不能攻击
            if Checker.CheckIsBelowProtectLevel(AvatarCache.me) then
                return AttackJudge.SelfLevelBelow30;
            end

            -- 目标小于保护等级不能攻击
            if Checker.CheckIsBelowProtectLevel(ds) then
                return AttackJudge.TargetLevelBelow30;
            end

            

            -- 检查PK
            local judge = Checker.CheckPK(ds);
            if judge ~= AttackJudge.TargetCanAttack then
                return judge;
            end

            -- 检查自身是否处于安全区
            if Checker.CheckIsWithinSafeArea(AvatarCache.me) then
                return AttackJudge.SelfWithinSafeZone;
            end

            -- 检查目标是否处于安全区
            if Checker.CheckIsWithinSafeArea(ds) then
                return AttackJudge.TargetWithinSafeZone;
            end

            -- 检查是否是队友
            if Checker.CheckIsSameTeam(ds) then
                return AttackJudge.TargetIsTeamMate;
            end

            -- 检查是否是同公会
            if Checker.CheckIsSameLegion(ds) then
                return AttackJudge.TargetIsArmyMember;
            end

            -- 红名可以攻击
            if Checker.CheckIsRedName(ds) then
                return AttackJudge.TargetCanAttack;
            end
            
            -- 检查是否是白名
            if Checker.CheckIsWhiteName(ds) then
                if not AvatarCache.me._t.IsAvatarAttackingMe(ds["id"]) then
                    return AttackJudge.TargetIsWhiteName;
                end
            end

            return AttackJudge.TargetCanAttack;
        end

        return AttackJudge.TargetCanNotAttack;
    end;

    -- 对目标的可攻击判断
    t.JudgeCanAttack_DoubleClick = function (ds)
        return t.JudgeCanAttack_Click(ds);
    end;

    -- 对目标的可攻击判断
    t.JudgeCanAttack_AttackTarget = function (ds)
        return t.JudgeCanAttack_Click(ds);
    end;


    t.FilterFunc_TabTarget = function (ds)
        local judge = t.JudgeCanAttack_TabTarget(ds);
        return judge == AttackJudge.TargetCanAttack;
    end;

    t.FilterFunc_AutoSelect = function (ds)
        local judge = t.JudgeCanAttack_AutoSelect(ds);
        return judge == AttackJudge.TargetCanAttack;
    end;

    -- 对目标的可攻击判断
    t.JudgeCanAttack_TabTarget = function (ds)
        local player = AvatarCache.me;
        local lost_target_distance = player.lost_target_distance;
        if not Checker.CheckIsWithinPlayerScope(ds, lost_target_distance) then
            return AttackJudge.TargetCanNotAttack;
        end
        return t.JudgeCanAttack_Click(ds);
    end;

    -- 对目标的可攻击判断
    t.JudgeCanAttack_AutoSelect = function (ds)


        -- 判断是否是玩家
        if Checker.CheckIsPlayer(ds) then
            return AttackJudge.TargetCanNotAttack;
        end

        -- 判断死亡
        if Checker.CheckIsDead(ds) then
            return AttackJudge.TargetIsDead;
        end

        local player = AvatarCache.me;
        -- 检查是否在玩家自动战斗原点半径为 radius 的范围内
        local search_monster_radius = player["search_monster_radius"];
        if not Checker.CheckIsWithinAutoFightScope(ds, search_monster_radius) then
            return AttackJudge.TargetNotWithinAutoFightScope;
        end

        -- 检查是否在玩家半径为 radius 的范围内
        local auto_lock_radius = player["auto_lock_radius"];
        if not Checker.CheckIsWithinPlayerScope(ds, auto_lock_radius) then
            return AttackJudge.TargetNotWithinAutoFightScope;
        end

        -- 判断大 Boss, 可以攻击
        if Checker.CheckIsBigBoss(ds) then
            return AttackJudge.TargetCanAttack;
        end

        -- 判断小怪，可以攻击
        if Checker.CheckIsMonster(ds) then
            return AttackJudge.TargetCanAttack;
        end

        -- 小 Boss和精英怪
        if Checker.CheckIsSmallBoss(ds) then
            return AttackJudge.TargetCanNotAttack;
        end

        -- 检查是否精英怪
        if Checker.CheckIsEliteMonster(ds) then
            return AttackJudge.TargetCanNotAttack;
        end

        -- 检查是否Npc，无法攻击Npc
        if Checker.CheckIsNpc(ds) then
            return AttackJudge.TargetCanNotAttack;
        end

        -- 检查是否是其他玩家
        if Checker.CheckIsOtherPlayer(ds) then

            -- 检查对象是否是无敌
            if Checker.CheckIsImbaState(ds) then
                return AttackJudge.TargetIsInvincible;
            end

            -- 玩家小于保护等级不能攻击
            if Checker.CheckIsBelowProtectLevel(AvatarCache.me) then
                return AttackJudge.SelfLevelBelow30;
            end

            -- 目标小于保护等级不能攻击
            if Checker.CheckIsBelowProtectLevel(ds) then
                return AttackJudge.TargetLevelBelow30;
            end

            -- 目标没有攻击我
            if not AvatarCache.me._t.IsAvatarAttackingMe(ds["id"]) then
                return AttackJudge.TargetIsWhiteName;
            end

            -- 检查PK
            local judge = Checker.CheckPK(ds);
            if judge ~= AttackJudge.TargetCanAttack then
                return judge;
            end

            -- 检查自身是否处于安全区
            if Checker.CheckIsWithinSafeArea(AvatarCache.me) then
                return AttackJudge.SelfWithinSafeZone;
            end

            -- 检查目标是否处于安全区
            if Checker.CheckIsWithinSafeArea(ds) then
                return AttackJudge.TargetWithinSafeZone;
            end

            -- 检查是否是队友
            if Checker.CheckIsSameTeam(ds) then
                return AttackJudge.TargetIsTeamMate;
            end

            -- 检查是否是同公会
            if Checker.CheckIsSameLegion(ds) then
                return AttackJudge.TargetIsArmyMember;
            end
                
            return AttackJudge.TargetCanAttack;
        end

        return AttackJudge.TargetCanNotAttack;

    end;

    -- 优先选择排序函数
    t.Compare_TabTarget = function (a, b)

        local result = 0;
        result = Comparer.CompareIsBigBoss(a, b);
        if result ~= 0 then
            if result < 0 then
                return true;
            else
                return false;
            end
        end
        return Comparer.CompareNearerDistance(a, b) < 0;
    end;

    -- 优先选择排序函数
    t.Compare_AutoSelect = function (a, b)
        local result = 0;
        result = Comparer.CompareIsAttackingPlayer(a, b);
        if result ~= 0 then
            if result < 0 then
                return true;
            else
                return false;
            end
        end
        if AvatarCache.me._t.IsAvatarAttackingMe(a["id"]) then
            result = Comparer.CompareIsOtherPlayer(a, b);
            if result ~= 0 then
                if result < 0 then
                    return true;
                else
                    return false;
                end
            end
            result = Comparer.CompareIsBigBoss(a, b);
            if result ~= 0 then
                if result < 0 then
                    return true;
                else
                    return false;
                end
            end
            return Comparer.CompareNearerDistance(a, b) < 0;
        else
            result = Comparer.CompareIsBigBoss(a, b);
            if result ~= 0 then
                if result < 0 then
                    return true;
                else
                    return false;
                end
            end
            return Comparer.CompareNearerDistance(a, b) < 0;
        end
    end;

    t.Update = function ()
        local player = AvatarCache.me;
        local lost_target_distance = player["lost_target_distance"];
        ControlLogic.UpdateTargetLost(lost_target_distance);
    end;

    return t;
end


-- 创建野外自动战斗PK
function CreateControlLogic_WildAutoFightPK()

    local t = {};

    -- 点击目标，这个目标为非选中状态
    t.ClickTarget = function (ds)
        local role_type = ds.role_type;
        if role_type == RoleType.Monster then
            if ds.hp > 0 then
                TargetSelecter.SetCurrentTarget(ds);
                TargetSelecter.SetFirstClassTarget(ds);
            end    
        else
            TargetSelecter.SetCurrentTarget(ds);
            TargetSelecter.SetFirstClassTarget(ds);        
        end
    end;

    -- 双击目标，定义为当前已经选中了目标，再点一下
    t.DoubleClickTarget = function (ds)
        local judge = t.JudgeCanAttack_Click(ds);
        if judge ~= AttackJudge.TargetCanAttack then
            Utility.ShowWhyCanNotAttack(judge);
            return;
        end
        -- 攻击当前目标
        SkillButtons.EnqueueButtonEvent(SkillType.Normal, 1);
    end;

    -- 攻击目标，定义为按下按钮攻击目标， 如果按下的不是攻击技能，不会走到这里，如按下瞬移
    t.AttackTarget = function (ds)
        t.DoubleClickTarget(ds);
    end;

    -- 按下Tab选择目标
    t.TabTarget = function ()
        local current = TargetSelecter.current;
        local target = TargetSelecter.SelectNext(current, true, t.FilterFunc_TabTarget, t.Compare_TabTarget);
        if target ~= nil then
            TargetSelecter.SetFirstClassTarget(target);
            TargetSelecter.SetCurrentTarget(target);
        else
            ui.showMsg("附近没有可攻击的目标");
        end
    end;

    -- 自动选择目标
    t.AutoSelect = function ()

        -- 如果当前目标，也是第一类目标，放弃自动拾取
        local current = TargetSelecter.current;
        if current ~= nil then
            local firstClass = TargetSelecter.firstClass;
            if firstClass ~= nil  and current["id"] == firstClass["id"] then
                return;
            end
        end

        local target = TargetSelecter.SelectOne(t.FilterFunc_AutoSelect, t.Compare_AutoSelect);
        if target ~= nil and (current == nil or target["id"] ~= current["id"]) then
            TargetSelecter.SetCurrentTarget(target);
        end
    end;

    -- 判断当前选中的目标是否可以攻击
    t.JudgeCanAttack_SelectedTarget = function (ds)
        return t.JudgeCanAttack_Click(ds);
    end;

    -- 对目标的可攻击判断
    t.JudgeCanAttack_Click = function (ds)

        -- 判断是否是玩家
        if Checker.CheckIsPlayer(ds) then
            return AttackJudge.TargetCanNotAttack;
        end

        -- 判断死亡
        if Checker.CheckIsDead(ds) then
            return AttackJudge.TargetIsDead;
        end

        -- 判断大 Boss, 可以攻击
        if Checker.CheckIsBigBoss(ds) then
            return AttackJudge.TargetCanAttack;
        end

        -- 判断小怪，可以攻击
        if Checker.CheckIsMonster(ds) then
            return AttackJudge.TargetCanAttack;
        end

        -- 小 Boss和精英怪
        if Checker.CheckIsSmallBoss(ds) then
            return AttackJudge.TargetCanAttack;
        end

        -- 检查是否精英怪
        if Checker.CheckIsEliteMonster(ds) then
            return AttackJudge.TargetCanAttack;
        end

        -- 检查是否Npc，无法攻击Npc
        if Checker.CheckIsNpc(ds) then
            return AttackJudge.TargetCanNotAttack;
        end

        -- 检查是否是其他玩家
        if Checker.CheckIsOtherPlayer(ds) then

            -- 检查对象是否是无敌
            if Checker.CheckIsImbaState(ds) then
                return AttackJudge.TargetIsInvincible;
            end

            -- 玩家小于保护等级不能攻击
            if Checker.CheckIsBelowProtectLevel(AvatarCache.me) then
                return AttackJudge.SelfLevelBelow30;
            end

            -- 目标小于保护等级不能攻击
            if Checker.CheckIsBelowProtectLevel(ds) then
                return AttackJudge.TargetLevelBelow30;
            end

            -- 检查PK
            local judge = Checker.CheckPK(ds);
            if judge ~= AttackJudge.TargetCanAttack then
                return judge;
            end

            -- 检查自身是否处于安全区
            if Checker.CheckIsWithinSafeArea(AvatarCache.me) then
                return AttackJudge.SelfWithinSafeZone;
            end

            -- 检查目标是否处于安全区
            if Checker.CheckIsWithinSafeArea(ds) then
                return AttackJudge.TargetWithinSafeZone;
            end

            -- 检查是否是队友
            if Checker.CheckIsSameTeam(ds) then
                return AttackJudge.TargetIsTeamMate;
            end

            -- 检查是否是同公会
            if Checker.CheckIsSameLegion(ds) then
                return AttackJudge.TargetIsArmyMember;
            end
                
            return AttackJudge.TargetCanAttack;
        end

        return AttackJudge.TargetCanNotAttack;
    end;

    -- 对目标的可攻击判断
    t.JudgeCanAttack_DoubleClick = function (ds)
        return t.JudgeCanAttack_Click(ds);
    end;

    -- 对目标的可攻击判断
    t.JudgeCanAttack_AttackTarget = function (ds)
        return t.JudgeCanAttack_Click(ds);
    end;


    t.FilterFunc_TabTarget = function (ds)
        local judge = t.JudgeCanAttack_TabTarget(ds);
        return judge == AttackJudge.TargetCanAttack;
    end;

    t.FilterFunc_AutoSelect = function (ds)
        local judge = t.JudgeCanAttack_AutoSelect(ds);
        return judge == AttackJudge.TargetCanAttack;
    end;

    -- 对目标的可攻击判断
    t.JudgeCanAttack_TabTarget = function (ds)
        local player = AvatarCache.me;
        local lost_target_distance = player.lost_target_distance;
        if not Checker.CheckIsWithinPlayerScope(ds, lost_target_distance) then
            return AttackJudge.TargetCanNotAttack;
        end
        return t.JudgeCanAttack_Click(ds);
    end;

    -- 对目标的可攻击判断
    t.JudgeCanAttack_AutoSelect = function (ds)

        assert(ds);

        -- 判断是否是玩家
        if Checker.CheckIsPlayer(ds) then
            return AttackJudge.TargetCanNotAttack;
        end

        -- 判断死亡
        if Checker.CheckIsDead(ds) then
            return AttackJudge.TargetIsDead;
        end

        -- 判断大 Boss, 可以攻击
        if Checker.CheckIsBigBoss(ds) then
            return AttackJudge.TargetCanAttack;
        end

        -- 判断小怪，可以攻击
        if Checker.CheckIsMonster(ds) then
            return AttackJudge.TargetCanAttack;
        end

        -- 小 Boss和精英怪
        if Checker.CheckIsSmallBoss(ds) then
            return AttackJudge.TargetCanNotAttack;
        end

        -- 检查是否精英怪
        if Checker.CheckIsEliteMonster(ds) then
            return AttackJudge.TargetCanNotAttack;
        end

        -- 检查是否Npc，无法攻击Npc
        if Checker.CheckIsNpc(ds) then
            return AttackJudge.TargetCanNotAttack;
        end

        -- 检查是否是其他玩家
        if Checker.CheckIsOtherPlayer(ds) then

            -- 检查对象是否是无敌
            if Checker.CheckIsImbaState(ds) then
                return AttackJudge.TargetIsInvincible;
            end

            -- 玩家小于保护等级不能攻击
            if Checker.CheckIsBelowProtectLevel(AvatarCache.me) then
                return AttackJudge.SelfLevelBelow30;
            end

            -- 目标小于保护等级不能攻击
            if Checker.CheckIsBelowProtectLevel(ds) then
                return AttackJudge.TargetLevelBelow30;
            end

            -- 检查PK
            local judge = Checker.CheckPK(ds);
            if judge ~= AttackJudge.TargetCanAttack then
                return judge;
            end

            -- 检查自身是否处于安全区
            if Checker.CheckIsWithinSafeArea(AvatarCache.me) then
                return AttackJudge.SelfWithinSafeZone;
            end

            -- 检查目标是否处于安全区
            if Checker.CheckIsWithinSafeArea(ds) then
                return AttackJudge.TargetWithinSafeZone;
            end

            -- 检查是否是队友
            if Checker.CheckIsSameTeam(ds) then
                return AttackJudge.TargetIsTeamMate;
            end

            -- 检查是否是同公会
            if Checker.CheckIsSameLegion(ds) then
                return AttackJudge.TargetIsArmyMember;
            end
                
            return AttackJudge.TargetCanAttack;
        end

        return AttackJudge.TargetCanNotAttack;

    end;

    -- 优先选择排序函数
    t.Compare_TabTarget = function (a, b)

        local result = 0;
        result = Comparer.CompareIsOtherPlayer(a, b);
        if result ~= 0 then
            if result < 0 then
                return true;
            else
                return false;
            end
        end
        result = Comparer.CompareIsBigBoss(a, b);
        if result ~= 0 then
            if result < 0 then
                return true;
            else
                return false;
            end
        end
        return Comparer.CompareNearerDistance(a, b) < 0;
    end;

    -- 优先选择排序函数
    t.Compare_AutoSelect = function (a, b)
        local result = 0;
        result = Comparer.CompareIsAttackingPlayer(a, b);
        if result ~= 0 then
            if result < 0 then
                return true;
            else
                return false;
            end
        end
        result = Comparer.CompareIsOtherPlayer(a, b);
        if result ~= 0 then
            if result < 0 then
                return true;
            else
                return false;
            end
        end
        result = Comparer.CompareIsBigBoss(a, b);
        if result ~= 0 then
            if result < 0 then
                return true;
            else
                return false;
            end
        end
        return Comparer.CompareNearerDistance(a, b) < 0;
    end;

    t.Update = function ()
        local player = AvatarCache.me;
        local lost_target_distance = player["lost_target_distance"];
        ControlLogic.UpdateTargetLost(lost_target_distance);
    end;

    return t;
end

-- 单人副本自动战斗
function CreateControlLogic_SingleFuben()

    local t = {};

    -- 点击目标，这个目标为非选中状态
    t.ClickTarget = function (ds)
        local role_type = ds.role_type;
        if role_type == RoleType.Monster then
            if ds.hp > 0 then
                TargetSelecter.SetCurrentTarget(ds);
                TargetSelecter.SetFirstClassTarget(ds);
            end    
        else
            TargetSelecter.SetCurrentTarget(ds);
            TargetSelecter.SetFirstClassTarget(ds);        
        end
    end;

    -- 双击目标，定义为当前已经选中了目标，再点一下
    t.DoubleClickTarget = function (ds)
        local judge = t.JudgeCanAttack_Click(ds);
        if judge ~= AttackJudge.TargetCanAttack then
            Utility.ShowWhyCanNotAttack(judge);
            return;
        end
        -- 攻击当前目标
        SkillButtons.EnqueueButtonEvent(SkillType.Normal, 1);
    end;

    -- 攻击目标，定义为按下按钮攻击目标， 如果按下的不是攻击技能，不会走到这里，如按下瞬移
    t.AttackTarget = function (ds)
        t.DoubleClickTarget(ds);
    end;

    -- 按下Tab选择目标
    t.TabTarget = function ()
        local current = TargetSelecter.current;
        local target = TargetSelecter.SelectNext(current, true, t.FilterFunc_TabTarget, t.Compare_TabTarget);
        if target ~= nil then
            TargetSelecter.SetFirstClassTarget(target);
            TargetSelecter.SetCurrentTarget(target);
        else
            ui.showMsg("附近没有可攻击的目标");
        end
    end;

    -- 自动选择目标
    t.AutoSelect = function ()

        -- 如果当前目标，也是第一类目标，放弃自动拾取
        local current = TargetSelecter.current;
        if current ~= nil then
            local firstClass = TargetSelecter.firstClass;
            if firstClass ~= nil  and current["id"] == firstClass["id"] then
                return;
            end
        end

        -- 自动拾取当前最近目标
        local target = TargetSelecter.SelectOne(t.FilterFunc_AutoSelect, t.Compare_AutoSelect);
        if target ~= nil and (current == nil or target["id"] ~= current["id"]) then
            TargetSelecter.SetCurrentTarget(target);
        end
    end;

    -- 判断当前选中的目标是否可以攻击
    t.JudgeCanAttack_SelectedTarget = function (ds)
        return t.JudgeCanAttack_Click(ds);
    end;

    -- 对目标的可攻击判断
    t.JudgeCanAttack_Click = function (ds)

        assert(ds);

        -- 判断是否是玩家
        if Checker.CheckIsPlayer(ds) then
            return AttackJudge.TargetCanNotAttack;
        end

        -- 判断死亡
        if Checker.CheckIsDead(ds) then
            return AttackJudge.TargetIsDead;
        end

        -- 判断大 Boss, 可以攻击
        if Checker.CheckIsBigBoss(ds) then
            return AttackJudge.TargetCanAttack;
        end

        -- 判断小怪，可以攻击
        if Checker.CheckIsMonster(ds) then
            return AttackJudge.TargetCanAttack;
        end

        -- 小 Boss和精英怪
        if Checker.CheckIsSmallBoss(ds) then
            return AttackJudge.TargetCanAttack;
        end

        -- 检查是否精英怪
        if Checker.CheckIsEliteMonster(ds) then
            return AttackJudge.TargetCanAttack;
        end

        -- 检查是否Npc，无法攻击Npc
        if Checker.CheckIsNpc(ds) then
            return AttackJudge.TargetCanNotAttack;
        end

        -- 检查是否是其他玩家
        if Checker.CheckIsOtherPlayer(ds) then

            -- 检查对象是否是无敌
            if Checker.CheckIsImbaState(ds) then
                return AttackJudge.TargetIsInvincible;
            end

            -- 玩家小于保护等级不能攻击
            if Checker.CheckIsBelowProtectLevel(AvatarCache.me) then
                return AttackJudge.SelfLevelBelow30;
            end

            -- 目标小于保护等级不能攻击
            if Checker.CheckIsBelowProtectLevel(ds) then
                return AttackJudge.TargetLevelBelow30;
            end

            -- 红名可以攻击
            if Checker.CheckIsRedName(ds) then
                return AttackJudge.TargetCanAttack;
            end
            
            -- 检查PK
            local judge = Checker.CheckPK(ds);
            if judge ~= AttackJudge.TargetCanAttack then
                return judge;
            end

            -- 检查自身是否处于安全区
            if Checker.CheckIsWithinSafeArea(AvatarCache.me) then
                return AttackJudge.SelfWithinSafeZone;
            end

            -- 检查目标是否处于安全区
            if Checker.CheckIsWithinSafeArea(ds) then
                return AttackJudge.TargetWithinSafeZone;
            end

            -- 检查是否是队友
            if Checker.CheckIsSameTeam(ds) then
                return AttackJudge.TargetIsTeamMate;
            end

            -- 检查是否是同公会
            if Checker.CheckIsSameLegion(ds) then
                return AttackJudge.TargetIsArmyMember;
            end
                
            -- 检查是否是白名
            if Checker.CheckIsWhiteName(ds) then
                if not AvatarCache.me._t.IsAvatarAttackingMe(ds["id"]) then
                    return AttackJudge.TargetIsWhiteName;
                end
            end

            return AttackJudge.TargetCanAttack;
        end

        return AttackJudge.TargetCanNotAttack;
    end;

    -- 对目标的可攻击判断
    t.JudgeCanAttack_DoubleClick = function (ds)
        return t.JudgeCanAttack_Click(ds);
    end;

    -- 对目标的可攻击判断
    t.JudgeCanAttack_AttackTarget = function (ds)
        return t.JudgeCanAttack_Click(ds);
    end;


    t.FilterFunc_TabTarget = function (ds)
        local judge = t.JudgeCanAttack_TabTarget(ds);
        return judge == AttackJudge.TargetCanAttack;
    end;

    t.FilterFunc_AutoSelect = function (ds)
        local judge = t.JudgeCanAttack_AutoSelect(ds);
        return judge == AttackJudge.TargetCanAttack;
    end;

    -- 对目标的可攻击判断
    t.JudgeCanAttack_TabTarget = function (ds)
        local player = AvatarCache.me;
        local lost_target_distance = player.lost_target_distance;
        if not Checker.CheckIsWithinPlayerScope(ds, lost_target_distance) then
            return AttackJudge.TargetCanNotAttack;
        end
        return t.JudgeCanAttack_Click(ds);
    end;

    -- 对目标的可攻击判断
    t.JudgeCanAttack_AutoSelect = function (ds)

        assert(ds);


        -- 判断是否是玩家
        if Checker.CheckIsPlayer(ds) then
            return AttackJudge.TargetCanNotAttack;
        end

        -- 判断死亡
        if Checker.CheckIsDead(ds) then
            return AttackJudge.TargetIsDead;
        end

        if Checker.CheckIsOtherPlayer(ds) then
            return AttackJudge.TargetCanNotAttack;
        end

        --目标没有组
        -- if ds.group == nil or ds.group == 0 then
        --   	--print("===== fuben: " .. ds.id);
        --   	--print(ds.group);
        -- end

        --------------------------------------
        --assert(ds.group);
        -- assert(ds.group);
        if ds.group == 0 then
            return AttackJudge.TargetCanNotAttack;
        end

        -- 判断大 Boss, 可以攻击
        if Checker.CheckIsBigBoss(ds) then
            return AttackJudge.TargetCanAttack;
        end

        -- 判断小怪，可以攻击
        if Checker.CheckIsMonster(ds) then
            return AttackJudge.TargetCanAttack;
        end

        -- 小 Boss和精英怪
        if Checker.CheckIsSmallBoss(ds) then
            return AttackJudge.TargetCanNotAttack;
        end

        -- 检查是否精英怪
        if Checker.CheckIsEliteMonster(ds) then
            return AttackJudge.TargetCanNotAttack;
        end

        -- 检查是否是其他玩家
        if Checker.CheckIsOtherPlayer(ds) then

            -- 检查对象是否是无敌
            if Checker.CheckIsImbaState(ds) then
                return AttackJudge.TargetIsInvincible;
            end

            -- 玩家小于保护等级不能攻击
            if Checker.CheckIsBelowProtectLevel(AvatarCache.me) then
                return AttackJudge.SelfLevelBelow30;
            end

            -- 目标小于保护等级不能攻击
            if Checker.CheckIsBelowProtectLevel(ds) then
                return AttackJudge.TargetLevelBelow30;
            end

            -- 红名可以攻击
            if Checker.CheckIsRedName(ds) then
                return AttackJudge.TargetCanAttack;
            end
            
            -- 检查PK
            local judge = Checker.CheckPK(ds);
            if judge ~= AttackJudge.TargetCanAttack then
                return judge;
            end

            -- 检查自身是否处于安全区
            if Checker.CheckIsWithinSafeArea(AvatarCache.me) then
                return AttackJudge.SelfWithinSafeZone;
            end

            -- 检查目标是否处于安全区
            if Checker.CheckIsWithinSafeArea(ds) then
                return AttackJudge.TargetWithinSafeZone;
            end

            -- 检查是否是队友
            if Checker.CheckIsSameTeam(ds) then
                return AttackJudge.TargetIsTeamMate;
            end

            -- 检查是否是同公会
            if Checker.CheckIsSameLegion(ds) then
                return AttackJudge.TargetIsArmyMember;
            end
                
            -- 检查是否是白名
            if Checker.CheckIsWhiteName(ds) then
                if not AvatarCache.me._t.IsAvatarAttackingMe(ds["id"]) then
                    return AttackJudge.TargetIsWhiteName;
                end
            end

            return AttackJudge.TargetCanAttack;
        end

        return AttackJudge.TargetCanNotAttack;

    end;

    -- 优先选择排序函数
    t.Compare_TabTarget = function (a, b)
        local result = Comparer.CompareIsBigBoss(a, b);
        if result ~= 0 then
            if result < 0 then
                return true;
            else
                return false;
            end
        end
        return Comparer.CompareNearerDistance(a, b) < 0;
    end;

    -- 优先选择排序函数
    t.Compare_AutoSelect = function (a, b)

        local result = 0;
        -- 比较组id，组id小优先
        result = Comparer.CompareLessGroupId(a, b);
        if result ~= 0 then
            if result < 0 then
                return true;
            else
                return false;
            end
        end
        -- 比较是否大Boss, 大Boss优先
        result = Comparer.CompareIsBigBoss(a, b);
        if result ~= 0 then
            if result < 0 then
                return true;
            else
                return false;
            end
        end
        -- 比较距离，距离近优先
        return Comparer.CompareNearerDistance(a, b) < 0;
    end;


    t.Update = function ()
        ControlLogic.UpdateTargetHP();
    end;

    return t;
end


-- 创建控制逻辑
function CreateControlLogic()

	local t = {};

	-- 点击目标
	t.ClickTarget = function (ds)

        -- local judge = t.JudgeCanAttack_Click(ds);
        -- if judge == AttackJudge.TargetCanAttack then
            local current = TargetSelecter.current;
            if current ~= nil and current["id"] == ds["id"] then
                t.DoubleClickTarget(ds);
            else
                local player = AvatarCache.me;
                local type = player["control_logic"];
        		local logic = t[type];
        		logic.ClickTarget(ds);

                -- 如果是单击 npc
                local role_type = ds.role_type;
                if role_type == RoleType.Npc then
                    local class = Fight.GetClass(ds);
                    class.OnClick(ds);
                end
            end
        -- else
            -- local player = AvatarCache.me;
        --     local type = player["control_logic"];
        --     local logic = t[type];
        --     logic.ClickTarget(ds);
        --     -- Utility.ShowWhyCanNotAttack(judge);
        -- end
	end

	-- 双击目标
	t.DoubleClickTarget = function (ds)
        local player = AvatarCache.me;
        local type = player["control_logic"];
		local logic = t[type];
		logic.DoubleClickTarget(ds);
	end

	-- 攻击目标
	t.AttackTarget = function (ds)
        local player = AvatarCache.me;
        local type = player["control_logic"];
		local logic = t[type];
		logic.AttackTarget(ds);
	end

	-- 切换目标
	t.TabTarget = function ()
        local player = AvatarCache.me;
        local type = player["control_logic"];
		local logic = t[type];
		logic.TabTarget();
	end

	-- 自动选择
	t.AutoSelect = function ()
        local player = AvatarCache.me;
        if player ~= nil then

            -- 自动更新目标
            local type = player["control_logic"];
            --print("AutoSelect: " .. type);
            local logic = ControlLogic[type];
            logic.AutoSelect();
        end
	end


    -- 判断当前选中的目标是否可以攻击
    t.IsTargetCanAttack_Click = function (ds)
        return t.JudgeCanAttack_Click(ds) == AttackJudge.TargetCanAttack;
    end;

    -- 返回当前选中目标的攻击判断
    t.JudgeCanAttack_Click = function (ds)
        local player = AvatarCache.me;
        if player ~= nil then
            -- 自动更新目标
            local type = player["control_logic"];
            local logic = ControlLogic[type];
            return logic.JudgeCanAttack_Click(ds);
        else
            return AttackJudge.TargetCanNotAttack;
        end
    end;

    -- 判断当前选中的目标是否可以攻击
    t.IsTargetCanAttack_SelectedTarget = function (ds)
        return t.JudgeCanAttack_SelectedTarget(ds) == AttackJudge.TargetCanAttack;
    end;

    -- 返回当前选中目标的攻击判断
    t.JudgeCanAttack_SelectedTarget = function (ds)
        local player = AvatarCache.me;
        if player ~= nil then
            -- 自动更新目标
            local type = player["control_logic"];
            local logic = ControlLogic[type];
            return logic.JudgeCanAttack_SelectedTarget(ds);
        else
            return AttackJudge.TargetCanNotAttack;
        end
    end;


    -- 判断点击攻击按钮时，选中的目标是否可以攻击
    t.IsTargetCanAttack_AttackTarget = function (ds)
        return t.JudgeCanAttack_AttackTarget(ds) == AttackJudge.TargetCanAttack;
    end;


    t.JudgeCanAttack_AttackTarget = function (ds)
        local player = AvatarCache.me;
        if player ~= nil then
            -- 自动更新目标
            local type = player["control_logic"];
            local logic = ControlLogic[type];
            return logic.JudgeCanAttack_AttackTarget(ds);
        else
            return AttackJudge.TargetCanNotAttack;
        end
    end;

    -- 判断目标是否可以攻击
    t.IsTargetCanAttack_AutoSelect = function (ds)
        return t.JudgeCanAttack_AutoSelect(ds) == AttackJudge.TargetCanAttack;
    end;

    -- 是否目标可以攻击
    t.JudgeCanAttack_AutoSelect = function (ds)
        local player = AvatarCache.me;
        if player ~= nil then
            -- 自动更新目标
            local type = player["control_logic"];
            local logic = ControlLogic[type];
            return logic.JudgeCanAttack_AutoSelect(ds);
        else
            return AttackJudge.TargetCanNotAttack;
        end
    end;

    -- 更新目标丢失
    t.UpdateTargetLost = function (lost_target_distance)
        local current = TargetSelecter.current;
        if current ~= nil then
            local player = AvatarCache.me;
            if player ~= nil then
                local pos_x = player["pos_x"];
                local pos_y = player["pos_y"];
                local pos_z = player["pos_z"];
                local current_pos_x = current["pos_x"];
                local current_pos_y = current["pos_y"];
                local current_pos_z = current["pos_z"];
                local dx = current_pos_x - pos_x;
                local dy = current_pos_y - pos_y;
                local dz = current_pos_z - pos_z;
                local dist_sq = dx * dx + dz * dz;
                local dist2 = lost_target_distance * lost_target_distance;
                if dist_sq > dist2 then
                    TargetSelecter.ClearTarget();
                end
            end

            t.UpdateTargetHP();
            -- local level = current["level"];
            -- local hp = current["hp"];
            -- local maxHP = current["maxHP"];
            -- local hp_percent = hp / maxHP;
            -- local info = string.format("%d, %f", level, hp_percent);
            -- EventManager.onEvent(Event.ON_TARGET_UPDATE, info);
        end
    end;

    t.UpdateTargetHP = function()
        local current = TargetSelecter.current;
        if current ~= nil then
            local level = current["level"];
            local hp = current["hp"];
            local maxHP = current["maxHP"];
            local hp_percent = hp / maxHP;            
            EventManager.onEvent(Event.ON_TARGET_UPDATE, level, hp_percent);       
        end    
    end

    -- 控制更新
    t.Update = function ()
        local player = AvatarCache.me;
        if player ~= nil then
            -- 自动更新目标
            local type = player["control_logic"];
            -- print("Update: " .. type);
            local logic = ControlLogic[type];
            logic.Update();
            
            if player.is_auto_fighting then
                logic.AutoSelect();
            end
        end
    end;

	-- 在野外场景的和平模式控制
	t[ControlLogicType.WildHeping] = CreateControlLogic_WildHeping();
	-- 在野外场景的PK模式控制
	t[ControlLogicType.WildPK] = CreateControlLogic_WildPK();
	-- 在野外场景自动战斗的和平模式控制
	t[ControlLogicType.WildAutoFightHeping] = CreateControlLogic_WildAutoFightHeping();
	-- 在野外场景自动战斗的PK模式控制
	t[ControlLogicType.WildAutoFightPK] = CreateControlLogic_WildAutoFightPK();
	-- 在单人副本场景控制
	t[ControlLogicType.SingleFuben] = CreateControlLogic_SingleFuben();

	return t;
end

ControlLogic = CreateControlLogic();

