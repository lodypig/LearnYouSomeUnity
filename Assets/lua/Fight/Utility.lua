
--[[
AttackJudge = {};
AttackJudge.TargetCanAttack = 0;				-- 目标可以攻击
AttackJudge.NoTargetFound = 1;					-- 没有目标
AttackJudge.TargetIsWhiteName = 2;				-- 目标是白名
AttackJudge.SelfLevelBelow30 = 3;				-- 自身等级未达到30级
AttackJudge.TargetLevelBelow30 = 4;				-- 目标等级未达到30级
AttackJudge.TargetWithinSafeZone = 5;			-- 目标处于安全区
AttackJudge.SelfWithinSafeZone = 6;				-- 自身处于安全区
AttackJudge.TargetIsTeamMate = 7;				-- 目标是队友
AttackJudge.TargetIsArmyMember = 8;				-- 目标是公会成员
AttackJudge.TargetIsDead = 9;					-- 目标已经死亡
AttackJudge.TargetIsInvincible = 10;			-- 目标无敌
AttackJudge.TargetIsInactiveEliteMonster = 11;	-- 目标是未激活精英怪
AttackJudge.TargetCanNotAttack = 12;			-- 不能攻击该目标
AttackJudge.ThisAreaPkForbidden = 13;			-- 此区域禁止PK
AttackJudge.Unknown = 99;						-- 未知情况
]]


function CreateUtility()
	
	local t = {};

	t.judges = {};
	t.judges[AttackJudge.NoTargetFound] = "没有目标";
	t.judges[AttackJudge.TargetIsWhiteName] = "目标是白名";
	t.judges[AttackJudge.SelfLevelBelow30] = "30级前无法参与PK";
	t.judges[AttackJudge.TargetLevelBelow30] = "请不要欺负新手";
	t.judges[AttackJudge.TargetWithinSafeZone] = "目标处于安全区内，无法攻击";
	t.judges[AttackJudge.SelfWithinSafeZone] = "安全区内无法攻击其他角色";
	t.judges[AttackJudge.TargetIsTeamMate] = "不能攻击你的队友";
	t.judges[AttackJudge.TargetIsArmyMember] = "不能攻击同公会成员";
	t.judges[AttackJudge.TargetIsDead] = "目标已经死亡";
	t.judges[AttackJudge.TargetIsInvincible] = "目标无敌";
	t.judges[AttackJudge.TargetIsInactiveEliteMonster] = "目标是未激活精英怪";
	t.judges[AttackJudge.TargetCanNotAttack] = "不能攻击该目标";
	t.judges[AttackJudge.ThisAreaPkForbidden] = "此区域禁止PK";
	t.judges[AttackJudge.Unknown] = "未知情况";

	t.ShowWhyCanNotAttack = function (type)
		local msg = t.judges[type];
		if msg == nil then
			--print("msg type not found: " .. type);
			return;
		end
		ui.showMsg(t.judges[type]);
	end

	t.AddFollowEffect = function(ds)
		--根据table上的随身Effect
	    --api  create
	    --read lua tbale
	  	--print("sid:"..ds.sid)
	    local NpcTableInfo = tb.NPCTable[ds.sid];
	    local effect = NpcTableInfo.effect;
	    local modelName = NpcTableInfo.style;
	    -- print("effect:"..effect)
	    -- print("modelName:"..modelName)
	    --c# api
	    if effect ~= nil then
	    	uFacadeUtility.AddFollowEffect(ds.id, effect, modelName)    
	    end	
	end

	return t;
end

Utility = CreateUtility();