
-- 副本 AI ID 类型
FubenAI = {};
FubenAI.PlotlineFuben = 1;
FubenAI.BaokuFuben = 2;
FubenAI.MijingFuben = 3;
FubenAI.XiangWeiFuben = 4;

-- 副本处理函数
FubenHandlerType = {}
FubenHandlerType.OnStart = 1;			-- 副本开始事件
FubenHandlerType.OnResult = 2;			-- 未使用
FubenHandlerType.OnAddNpc = 3;			-- 副本添加 Npc 事件
FubenHandlerType.OnRemoveNpc = 4;		-- 副本删除 Npc 事件
FubenHandlerType.OnDie = 5;				-- 死亡事件, 所有死亡都会触发这个事件，包括玩家死亡，怪物死亡，Boss死亡
FubenHandlerType.OnUseAbility = 6;		-- 使用技能事件，所有技能都会触发这个事件, 包括玩家、怪物、Boss
FubenHandlerType.OnRevive = 7;			-- 玩家复活
FubenHandlerType.OnUpdate = 8;			-- 更新事件，每帧一次
FubenHandlerType.OnEnterIdle = 9;		-- 玩家进入待机
FubenHandlerType.OnAutoFight = 10;		-- 自动战斗按钮点击
FubenHandlerType.OnInit = 11;		-- 副本数据初始化

-- 副本管理器
function CreateFubenManager()

	local t = {};

	-- 副本 AI id
	t.current_fuben_ai_id = 0;

	-- 设置副本 AI
	t.SetFubenAI = function (fuben_ai_id)
		t.current_fuben_ai_id = fuben_ai_id;
	end;

	t.GetFubenAiId = function ()
		return t.current_fuben_ai_id;
	end;

	t.isPlotlineFuben = function ()
		return t.current_fuben_ai_id == FubenAI.PlotlineFuben;
	end;

	t.fuben_ais = {};

	-- 创建副本
	t.CreateFubenAI = function (fuben_ai_id)
		local fuben_ai = {};
		fuben_ai.is_running = false;
		fuben_ai.id = fuben_ai_id;
		fuben_ai.InvokeHandler = function (handler_type, msg)
			local handler = fuben_ai[handler_type];
			if handler ~= nil then
				handler(msg);
			end
		end;
		fuben_ai.IsRunning = function ()
			return fuben_ai.is_running;
		end;
		fuben_ai.Start = function ()
			fuben_ai.is_running = true;
		end;
		fuben_ai.Reset = function ()
			fuben_ai.is_running = false;
		end
		fuben_ai.SetHandler = function (handler_type, handler)
			fuben_ai[handler_type] = handler;
		end;
		t.fuben_ais[fuben_ai_id] = fuben_ai;
		return fuben_ai;
	end;

	-- 删除副本
	t.DestroyFubenAI = function (fuben_ai_id)
		local fuben_ai = t.fuben_ais[fuben_ai_id];
		if fuben_ai ~= nil then
			t.fuben_ais[fuben_ai_id] = nil;
		end
	end;

	-- 获取副本
	t.GetFubenAI = function (fuben_ai_id)
		return t.fuben_ais[fuben_ai_id];
	end

	-- 删除所有副本
	t.DestroyAllFubenAIs = function ()
		local fuben_ais = t.fuben_ais;
		for i = 1, #fuben_ais do
			fuben_ais[i] = nil;
		end
	end;

	-- 激活副本处理函数
	t.InvokeFubenAIHandler = function (fuben_ai_id, handler_type, msg)
		
		local fuben_ai = t.GetFubenAI(fuben_ai_id);
		if fuben_ai ~= nil then
			fuben_ai.InvokeHandler(handler_type, msg);
		end
	end;

	-- 触发当前副本处理函数
	t.InvokeCurrentFubenAIHandler = function (handler_type, msg)
		t.InvokeFubenAIHandler(t.current_fuben_ai_id, handler_type, msg);
	end;

	-- 通知副本
	t.OnNotify = function (handler_type, msg)
		local is_fuben = SceneManager.IsCurrentFubenMap() or SceneManager.IsCurrentXiangWeiMap;
		if not is_fuben then
			return;
		end
		t.InvokeCurrentFubenAIHandler(handler_type, msg);
	end;

	-- 副本更新入口
	t.Update = function ()
		local fuben_ai = t.GetFubenAI(t.current_fuben_ai_id);
		if fuben_ai ~= nil then
			if fuben_ai.IsRunning() then
				fuben_ai.InvokeHandler(FubenHandlerType.OnUpdate, nil);
			end
		end
	end;

	-- 重置所有副本状态
	t.Reset = function ()
		local fuben_ais = t.fuben_ais;
		for i = 1, #fuben_ais do
			local fuben_ai = fuben_ais[i];
			fuben_ai.Reset();
		end
	end;

	return t;
end

function CreateCommon(fuben)
	----------------------------------------------
	-- 工具函数
	----------------------------------------------

	-- 获取组 Id 索引
	-- 遍历 fuben.groups 组，每一项和 groupId 比对
	-- 如果相等返回索引号，若果不存在这样的项，则返回 0
	function fuben.GetGroupIndex(groupId)
		local groups = fuben.groups;
		for i = 1, #groups do
			if groups[i] == groupId then
				return i;
			end
		end
		return 0;
	end

	-- 根据副本时间获取当前第一波怪是哪一波怪
	function fuben.GetFubenFirstGroupIdByEvents(events)
		local fuben_flow_data = fuben.GetFlowData();
		local count = #fuben_flow_data;
		for i = 1, count do
			local event = "fight" .. i;
			local found = false;
			for k = 1, #events do
				if events[k] == event then
					found = true;
					break;
				end
			end
			if not found then
				return i;
			end
		end
		return 1;
	end

	-- 判断是否所有的 Boss 都已经死亡
	function fuben.IsAllBossDead()
		local bosses = fuben.bosses;
		for i = 1, #bosses do
			local bossId = bosses[i];
			if AvatarCache.HasAvatar(bossId) then
				local avatar = AvatarCache.GetAvatar(bossId);
				if avatar["hp"] > 0 then
					return false;
				end
			end
		end
		return true;
	end

	-- 是否所有的怪物都已经死亡
	function fuben.IsAllMonsterDead()
		local groups = fuben.groups;
		for i = 1, #groups do
			local groupId = groups[i];
			if not fuben.IsAllMonsterDeadOfGroup(groupId) then
				return false;
			end
		end
		return true;
	end

	-- 是否 goupId 里面的怪物都死亡
	function fuben.IsAllMonsterDeadOfGroup(groupId)
		-- code here
		local monsters = fuben.monsters;
		local idList = monsters[groupId];
		if idList == nil then
			return true;
		end
		for i = 1, #idList do
			local id = idList[i];
			if AvatarCache.HasAvatar(id) then
				local avatar = AvatarCache.GetAvatar(id);
				if avatar["hp"] > 0 then
					return false;
				end
			end
		end
		return true;
	end


	-- 获取第一个有活怪的组 ID
	function fuben.GetFirstGroupIdOwnAliveMonsterAfterGroupId(startGroupId)
		local groups = fuben.groups;
		local index = fuben.GetGroupIndex(startGroupId);
		local found = false;
		local groupId = 0;
		for i = index + 1, #groups do
			if not fuben.IsAllMonsterDeadOfGroup(groups[i]) then
				found = true;
				groupId = groups[i];
				break;
			end
		end
		if found then
			return groupId;
		end
		return 0;
	end

	-- 副本结束
	function fuben.IsFubenFinished()
		local groupId = fuben.groupId;
		local fuben_flow_data = fuben.GetFlowData();
		local flow_numb = #fuben_flow_data;
		if groupId == flow_numb and fuben.IsAllMonsterDeadOfGroup(groupId) then
			return true;
		end
		return false;
	end

	-- 获取组中心位置
	function fuben.GetGroupCenterPos(groupId)
		-- code here
		local monsters = fuben.monsters;
		local idList = monsters[groupId];
		if idList == nil then
			return false, 0, 0, 0;
		end
		local player = AvatarCache.me;
		local pos_x = player.pos_x;
		local pos_y = player.pos_y;
		local pos_z = player.pos_z;
		local dst_x = 0;
		local dst_y = 0;
		local dst_z = 0;
		local min_dist_sq = 0;
		local found = false;
		for i = 1, #idList do
			local id = idList[i];
			if AvatarCache.HasAvatar(id) then
				local avatar = AvatarCache.GetAvatar(id);
				if avatar["hp"] > 0 then
					if found then
						local target_pos_x = avatar.pos_x;
						local target_pos_y = avatar.pos_y;
						local target_pos_z = avatar.pos_z;
						local dx = target_pos_x - pos_x;
						local dy = target_pos_y - pos_y;
						local dz = target_pos_z - pos_z;
						local dist_sq = dx * dx + dz * dz;
						if dist_sq < min_dist_sq then
							min_dist_sq = dist_sq;
							dst_x = target_pos_x;
							dst_y = target_pos_y;
							dst_z = target_pos_z;
						end
					else
						local target_pos_x = avatar.pos_x;
						local target_pos_y = avatar.pos_y;
						local target_pos_z = avatar.pos_z;
						found = true;
						local dx = target_pos_x - pos_x;
						local dy = target_pos_y - pos_y;
						local dz = target_pos_z - pos_z;
						min_dist_sq = dx * dx + dz * dz;
						dst_x = target_pos_x;
						dst_y = target_pos_y;
						dst_z = target_pos_z;
					end
				end
			end
		end
		return found, dst_x, dst_y, dst_z;
	end

	-- 角色状态
	function fuben.DoStartAutoFighting()
		local player = AvatarCache.me;
		local is_auto_fighting = player["is_auto_fighting"];
		if not is_auto_fighting then
			fuben.SetAutoFighting(true);
			--fuben.AutoSelectNextTarget();
		end
	end


	-- 设置自动战斗
	function fuben.SetAutoFighting(enable)
		local player = AvatarCache.me;
		local class = Fight.GetClass(player);
		class.HandUp(player, enable);
	end

	-- 更新是否开启自动战斗
	function fuben.UpdateIfStartAutoFighting()
		local player = AvatarCache.me;
		local is_auto_fighting = player["is_auto_fighting"];
		if not is_auto_fighting then
			local enter_idle_time = fuben.enter_idle_time;
			local curr_time = TimerManager.GetServerNowSecond();
			local idle_elapsed_time = curr_time - enter_idle_time;
			if idle_elapsed_time >= 5 then
				fuben.DoStartAutoFighting();
			end
		end
	end


	-- 自动选择下一个目标
	function fuben.AutoSelectNextTarget()
		local target = fuben.GetNextTarget();
		if target == nil then
			TargetSelecter.ClearTarget();
		else
			TargetSelecter.SetCurrentTarget(target);
		end
	end

	-- 获取下一个怪物 id
	function fuben.GetNextTarget()
		local monsters = fuben.monsters;
		for i = 1, #monsters do
			local idList = monsters[i];
			if idList ~= nil then
				for k = 1, #idList do
					local target = AvatarCache.GetAvatar(idList[k]);
					if target ~= nil and not target._t.IsDead() then
						return target;
					end
				end
			end
		end
		return nil;
	end

	-- 添加怪物
	fuben[FubenHandlerType.OnAddNpc] = function (msg)



		-- 提取 ds
		local ds = msg.ds;
		-- print("add npc: " .. ds.id);
		-- 提取 role_type
		local role_type = ds["role_type"];
		-- 对于副本怪物
		if role_type == RoleType.Monster then
			-- 提取怪物信息列表
			local monsters = fuben.monsters;
			-- 提取组 id 列表
			local groupId = ds.group or 1;
			-- 提取怪物列表
			local idList = monsters[groupId];
			-- 没有怪物列表则创建并添加怪物
			if idList == nil then
				idList = {};
				monsters[groupId] = idList;
				idList[1] = ds.id;
			else
				-- 添加怪物
				idList[#idList + 1] = ds.id;
			end

			-- 查询组id索引
			local index = fuben.GetGroupIndex(groupId);
			if index == 0 then
				local groups = fuben.groups;
				groups[#groups + 1] = groupId;
				if #groups > 1 then
					table.sort(groups);
				end
			end
		elseif role_type == RoleType.FubenBoss then

			local bosses = fuben.bosses;
			local bossGroupId = ds.group;
			local fuben_flow_data = fuben.GetFlowData();
			local fubenflow_group_data = fuben_flow_data[bossGroupId];
			local boss_pos = fubenflow_group_data.pos;
			fuben.groupId = bossGroupId;
			EventManager.onEvent(Event.ON_FUBEN_TASK_CHANGE, bossGroupId);
		end
	end;

	-- 删除怪物
	fuben[FubenHandlerType.OnRemoveNpc] = function (msg)

		local ds = msg.ds;

	end;

	-- 怪物死亡
	fuben[FubenHandlerType.OnDie] = function (msg)

		local ds = msg.ds;
		local currentGroupId = fuben.groupId;
		local groupId = ds.group;
		if currentGroupId ~= groupId then
			return;
		end

		-- 当前组所有怪物已死亡
		if fuben.IsAllMonsterDeadOfGroup(currentGroupId) then
			local count = 0;
			EventManager.onEvent(Event.ON_FUBEN_TASK_COMPLETED, currentGroupId);
			count = count + 1;

			if fuben.IsFubenFinished() then
				EventManager.onEvent(Event.ON_FUBEN_TASK_COMPLETED_EFFECT, count);
			else
				-- 副本组
				local groups = fuben.groups;
				local index = fuben.GetGroupIndex(currentGroupId);
				for i = index + 1, #groups do
					local nextCompletedGroupId = groups[i];
					if not fuben.IsAllMonsterDeadOfGroup(nextCompletedGroupId) then
						fuben.groupId = nextCompletedGroupId;
						EventManager.onEvent(Event.ON_FUBEN_TASK_CHANGE, nextCompletedGroupId);
						break;
					end

					EventManager.onEvent(Event.ON_FUBEN_TASK_COMPLETED, nextCompletedGroupId);
					count = count + 1;
				end
				if count > 0 then
					EventManager.onEvent(Event.ON_FUBEN_TASK_COMPLETED_EFFECT, count);
				end
				-- print("next target: " .. AvatarCache.me.control_logic);
				fuben.AutoSelectNextTarget();
			end
		else
			-- print("next target: " .. AvatarCache.me.control_logic);
			fuben.AutoSelectNextTarget();
		end
	end;

	-- 怪物使用技能
	fuben[FubenHandlerType.OnUseAbility] = function (msg)

		local attacker = msg.attacker;
		local target = msg.target;
		local skill_id = msg.skill_id;

	end;
	
	-- 复活
	fuben[FubenHandlerType.OnRevive] = function (msg)

	end;

	-- 更新
	fuben[FubenHandlerType.OnUpdate] = function (msg)

		-- 更新副本持续时间
		local curr_time = TimerManager.GetServerNowSecond();
		fuben.elapsed_time = curr_time - fuben.start_time;

		-- 副本还未结束，继续自动战斗
		if not fuben.isOver then
			fuben.UpdateIfStartAutoFighting();
		end
	end;

	-- 进入待机
	fuben[FubenHandlerType.OnEnterIdle] = function (msg)

		local ds = msg.ds;
		local role_type = ds.role_type;
		if role_type == RoleType.Player then
			local curr_time = TimerManager.GetServerNowSecond();
			fuben.enter_idle_time = curr_time;
		end
	end;

	-- 自动战斗按钮
	fuben[FubenHandlerType.OnAutoFight] = function (msg)
		local player = AvatarCache.me;
		local is_auto_fighting = player.is_auto_fighting;
		is_auto_fighting = not is_auto_fighting;
		fuben.SetAutoFighting(is_auto_fighting);
	end;
end

--创建主线副本
function CreatePlotlineFuben()
	local fuben = FubenManager.CreateFubenAI(FubenAI.PlotlineFuben);
	CreateCommon(fuben);
	fuben[FubenHandlerType.OnInit] = function ()
		fuben.groups = {};
		fuben.monsters = {};
		fuben.bosses = {};
		fuben.isOver = false
	end
	-- 副本开始
	fuben[FubenHandlerType.OnStart] = function (msg)
		-- 保存副本开始时间
		local chapter_id = msg.charpter;
		local curr_time = TimerManager.GetServerNowSecond();
		fuben.start_time = curr_time;
		fuben.elapsed_time = 0;
		fuben.enter_idle_time = curr_time;
		fuben.chapter_id = chapter_id;

		-- 初始化副本数据
		local events = msg.event;
		local firstGroupId = fuben.GetFubenFirstGroupIdByEvents(events);
		fuben.firstGroupId = firstGroupId
		--FubenPanelUI中的Start也有相同的逻辑， 都不能去掉，目前因为资源加载时序的问题，两段代码分别在PC跟手机端生效
		fuben.groupId = firstGroupId;
		-- 通知界面加载
		EventManager.onEvent(Event.ON_FUBEN_TASK_CHANGE, firstGroupId);
		-- 创建副本UI
		PanelManager:CreateConstPanel('MainUIPlotlineFuben', UIExtendType.NONE, {startTime = msg.init_time, firstGroup = firstGroupId});
		-- 开始副本
		fuben.Start();
		-- 设置玩家攻击逻辑是单人副本逻辑
		local player = AvatarCache.me;
		player["control_logic"] = ControlLogicType.SingleFuben;
		TargetSelecter.ClearTarget();
		fuben.AutoSelectNextTarget();

	end;

	-- 副本结束
	fuben[FubenHandlerType.OnResult] = function (msg)

		fuben.isOver = true
		fuben.SetAutoFighting(false);

		local success = msg.success;
		if success then
			local chapterCfg = tb.plotlineFuben[fuben.chapter_id];
			if chapterCfg == nil then
				ui.showMsg("主线副本数据出错!");
				return;
			end

			local param = {};
			param.result = "win";
			param.fubenType = "plotline";
			param.passtime = msg.passtime;

			param.baseAward = {};
			if chapterCfg.money > 0 then
				param.baseAward["money"] = chapterCfg.money;
			end
			if chapterCfg.exp > 0 then
				param.baseAward["exp"] = chapterCfg.exp;
			end
			if chapterCfg.diamond > 0 then
				param.baseAward["diamond"] = chapterCfg.diamond;
			end

			--奖励物品
			local list = {};
			local itemList = chapterCfg.awardItem;
			for i=1, #itemList do
				local itemId = itemList[i][1]
				local itemTable = tb.ItemTable[itemId];
				list[#list + 1] = {icon = itemTable.icon, count = itemList[i][2], quality = itemTable.quality, id = itemId, isItem = true};
			end

			param.itemList = list;
			PanelManager:CreateFullScreenPanel('UIFubenResult', function () end, param)

		else
			local param = {};
			param.result = "lose";
			param.fubenType = "plotline";
			PanelManager:CreateFullScreenPanel('UIFubenResult', function () end, param);
		end
	end;

	function fuben.GetFlowData()
		return tb.fubenflow[10001];
	end

	return fuben;
end

-- 创建试炼秘境副本
function CreateMijingFuben()

	local fuben = FubenManager.CreateFubenAI(FubenAI.MijingFuben);
	CreateCommon(fuben);

	------------------------------------------------------------------------
	-- 事件处理
	------------------------------------------------------------------------
	fuben[FubenHandlerType.OnInit] = function ()
		fuben.groups = {};
		fuben.monsters = {};
		fuben.bosses = {};
		fuben.isOver = false
	end
	-- 副本开始
	fuben[FubenHandlerType.OnStart] = function (msg)
		-- 保存副本开始时间
		local fuben_sid = msg.sid;
		local curr_time = TimerManager.GetServerNowSecond();
		fuben.start_time = curr_time;
		fuben.elapsed_time = 0;
		fuben.enter_idle_time = curr_time;
		fuben.groups = {};
		fuben.monsters = {};
		fuben.bosses = {};
		fuben.fuben_sid = fuben_sid;

		-- 初始化副本数据
		local events = msg.event;
		local firstGroupId = fuben.GetFubenFirstGroupIdByEvents(events);
		fuben.firstGroupId = firstGroupId
		--FubenPanelUI中的Start也有相同的逻辑， 都不能去掉，目前因为资源加载时序的问题，两段代码分别在PC跟手机端生效
		fuben.groupId = firstGroupId;
		-- 通知界面加载
		EventManager.onEvent(Event.ON_FUBEN_TASK_CHANGE, firstGroupId);
		-- 创建副本UI
		local param = {fubenSid = msg.sid, startTime = msg.init_time, firstGroup = firstGroupId};
		PanelManager:CreateConstPanel('MainUIFuben', UIExtendType.NONE, param);
		-- 开始副本
		fuben.Start();
		-- 设置玩家攻击逻辑是单人副本逻辑
		local player = AvatarCache.me;
		player["control_logic"] = ControlLogicType.SingleFuben;
		fuben.AutoSelectNextTarget();
	end;

	-- 副本结束
	fuben[FubenHandlerType.OnResult] = function (msg)
		fuben.isOver = true
		local player = AvatarCache.me;
		player["is_auto_fighting"] = false;

		local success = msg.success;
		if success then
			local data = msg.data;
			local fuben_sid = fuben.fuben_sid
			local fubenCfg = tb.fuben[fuben_sid];
			local param = {};
			param.result = "win";
			param.passtime = data.time;
			param.appraise = data.star[1][2];

			param.baseAward = {};
			if fubenCfg.money > 0 then
				param.baseAward["money"] = fubenCfg.money;
			end
			if fubenCfg.exp > 0 then
				param.baseAward["exp"] = fubenCfg.exp;
			end
			if fubenCfg.diamond > 0 then
				param.baseAward["diamond"] = fubenCfg.diamond;
			end

			--评价奖励
			param.appraiseAward = {};
			for i=1, #data.award do
				local award = data.award[i];
				param.appraiseAward[award[1]] = award[2];
			end

			--奖励物品
			local list = {};
			local itemList = fubenCfg.awardItem;
			for i=1, #itemList do
				local itemId = itemList[i][1]
				local itemTable = tb.ItemTable[itemId];
				list[#list + 1] = {icon = itemTable.icon, count = itemList[i][2], quality = itemTable.quality, id = itemId, isItem = true};
			end
			param.itemList = list;

			PanelManager:CreateFullScreenPanel('UIFubenResult', function () end, param)

		else
			local param = {};
			param.result = "lose";
			PanelManager:CreateFullScreenPanel('UIFubenResult', function ()	end, param);
		end
	end;

	function fuben.GetFlowData()
		local fuben_sid = fuben.fuben_sid;
		local fuben_data = tb.fuben[fuben_sid];
		return tb.fubenflow[fuben_data.flowcfg];
	end

	return fuben;
end


-- 创建宝库副本
function CreateBaokuFuben()

	local fuben = FubenManager.CreateFubenAI(FubenAI.BaokuFuben);
	CreateCommon(fuben);

	fuben[FubenHandlerType.OnInit] = function ()
		fuben.groups = {};
		fuben.monsters = {};
		fuben.bosses = {};
		fuben.isOver = false
	end
	-- 副本开始
	fuben[FubenHandlerType.OnStart] = function (msg)
		local curr_time = TimerManager.GetServerNowSecond();
		fuben.elapsed_time = 0;
		fuben.enter_idle_time = curr_time;
		fuben.groups = {};
		fuben.monsters = {};
		fuben.bosses = {};

		local param =  {time = msg.overTime, type = msg.mijingType, maxCount = msg.maxCount, npcCount = msg.npcCount};
    	PanelManager:CreateConstPanel('MainUIMijingFuben', UIExtendType.NONE,param);
	end;
	-- 副本结束
	fuben[FubenHandlerType.OnResult] = function (msg)
		fuben.isOver = true
	end;
	-- 怪物死亡
	fuben[FubenHandlerType.OnDie] = function (msg)
    	EventManager.onEvent(Event.ON_MIJING_NPC_DEAD);
	end;
	
	return fuben;
end

--创建宝库副本
function CreateXiangWeiFuben()

	local fuben = FubenManager.CreateFubenAI(FubenAI.XiangWeiFuben);
	CreateCommon(fuben);

	fuben[FubenHandlerType.OnInit] = function ()
		fuben.groups = {};
		fuben.monsters = {};
		fuben.bosses = {};
		fuben.isOver = false
		PanelManager:CreateConstPanel('MainUIXiangWeiFuben', UIExtendType.NONE,nil);
	end
	-- 副本开始
	fuben[FubenHandlerType.OnStart] = function ()

	end;
	-- 副本结束
	fuben[FubenHandlerType.OnResult] = function (msg)
		fuben.isOver = true
	end;
	-- 怪物死亡
	fuben[FubenHandlerType.OnDie] = function (msg)
    	
	end;
	
	return fuben;
end


-- 创建所有的副本 AI
function CreateFubenAIs()
	-- 秘境副本
	CreateMijingFuben();
	-- 宝库副本
	CreateBaokuFuben();
	--主线副本
	CreatePlotlineFuben();
	--相位副本
	CreateXiangWeiFuben();
end

FubenManager = CreateFubenManager();
CreateFubenAIs();