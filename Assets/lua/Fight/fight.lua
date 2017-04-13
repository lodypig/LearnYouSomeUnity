
Fight = {};


RoleType = {};
RoleType.None = 0;
RoleType.Player = 1;				-- 玩家
RoleType.OtherPlayer = 2;			-- 其他玩家（真实玩家）
RoleType.OfflinePlayer = 3;			-- 离线玩家（服务器控制）
RoleType.Monster = 4;				-- 小怪
RoleType.EliteMonster = 5;			-- 精英怪
RoleType.WorldBoss = 6;				-- 世界Boss
RoleType.FubenMonster = 7;			-- 副本小怪
RoleType.SmallBoss = 8;				-- 小Boss
RoleType.FubenEliteMonster = 9;		-- 副本精英怪
RoleType.FubenBoss = 10;			-- 副本Boss
RoleType.Npc = 11;					-- Npc(对话 npc)
RoleType.GatherItem = 12;			-- 采集物(采集物品)
RoleType.Transport = 13;			-- 传送装置
RoleType.GuideNpc = 14;				-- 引导NPC


SceneType = {};
SceneType.MainScene = 0;
SceneType.FubenScene = 1;

-----------------------------------------
-- 指令类型
-----------------------------------------

CommandType = {};
CommandType.Run = 1;
CommandType.Skill = 2;

-- 显示 Mesh
function Fight.DoShowMesh(ds)
	uFacadeUtility.ShowMesh(ds.id, true);
end

-- 隐藏 Mesh
function Fight.DoHideMesh(ds)
	uFacadeUtility.ShowMesh(ds.id, false);
end

-- 显示 Mesh(模型)
function Fight.DoShowMeshForModel(ds)
	uFacadeUtility.ShowMeshForModel(ds.id, true);
end

-- 隐藏 Mesh(模型)
function Fight.DoHideMeshForModel(ds)
	uFacadeUtility.ShowMeshForModel(ds.id, false);
end


-----------------------------------------------------------------------------------
-- 特效播放
--
-- effect_name: 播放特效名
-- effect_elapsed_time: 特效持续时间
-- effect_sound_name: 特效音效
-- effect_play_type: 1： 放置特效；2：弹道特效
-- 
-- 1. 放置特效
-- =============================================================
-- effect_bind_target: 1: 放置在攻击者身上； 2：放置在受击者身上
-- effect_bind_pos: 特效绑定的节点位置，如果为 ""，则绑定在角色根节点上
-- effect_bind_type：1：跟随特效；2：静止特效

-- 2. 弹道特效
-- =============================================================
-- effect_bullet_curve_type: 弹道轨迹类型: 1: 代表直线，目前只有直线
-- effect_target_bind_pos: 轨迹终结位置的绑点位置
-- 弹道特效起始位置为 (attacker, effect_bind_pos)
-- 弹道特效终止位置为 (target, effect_target_bind_pos)


-- 特效播放类型
EffectPlayType = {};
EffectPlayType.None = 0;
EffectPlayType.Place = 1;
EffectPlayType.Bullet = 2;
EffectPlayType.Lightening = 3;

-- 特效绑定目标
EffectBindTarget = {};
EffectBindTarget.None = 0;
EffectBindTarget.Attacker = 1;
EffectBindTarget.Target = 2;

-- 特效绑定类型
EffectBindType = {};
EffectBindType.None = 0;
EffectBindType.Follow = 1;
EffectBindType.Static = 2;

-- 特效弹道轨迹类型
EffectBulletCurveType = {};
EffectBulletCurveType.None = 0;
EffectBulletCurveType.Line = 1;


-- 播放音效
function Fight.PlaySound(name)
	local hash = ResNameMap[name];
	if hash == nil then
		return;
	end
	uFacadeUtility.PlaySound(hash);
end

-- 播放跟随特效
function Fight.PlayFollowEffect(name, elapsed_time, id, bind_pos)
	local bind_pos_id = BindPosNameToId[bind_pos];
	if bind_pos_id == nil then
		bind_pos_id = 0;
	end
	local hash = ResNameMap[name];
	if hash == nil then
		return;
	end
	uFacadeUtility.PlayFollowEffect(hash, elapsed_time, id, bind_pos_id);
end


function Fight.RttPlayFollowEffect(name, elapsed_time, id, bind_pos)
	local bind_pos_id = BindPosNameToId[bind_pos];
	if bind_pos_id == nil then
		bind_pos_id = 0;
	end
	local hash = ResNameMap[name];
	if hash == nil then
		return;
	end
	uFacadeUtility.RttPlayFollowEffect(hash, elapsed_time, id, bind_pos_id);
end




-- Rtt 播放静态特效
function Fight.RttPlayStaticEffect(root, name, elapsed_time, id, bind_pos)
	local bind_pos_id = BindPosNameToId[bind_pos];
	if bind_pos_id == nil then
		bind_pos_id = 0;
	end
	local hash = ResNameMap[name];
	if hash == nil then
		return;
	end
	uFacadeUtility.RttPlayStaticEffect(root, hash, elapsed_time, id, bind_pos_id);
end

-- 播放静态特效
function Fight.PlayStaticEffect(name, elapsed_time, id, bind_pos)
	local bind_pos_id = BindPosNameToId[bind_pos];
	if bind_pos_id == nil then
		bind_pos_id = 0;
	end
	local hash = ResNameMap[name];
	if hash == nil then
		return;
	end
	uFacadeUtility.PlayStaticEffect(hash, elapsed_time, id, bind_pos_id);
end


-- 播放闪电特效(RTT)
function Fight.RttPlayLighteningEffect(name, elapsed_time, id, bind_pos, target_x, target_y, target_z)
	local bind_pos_id = BindPosNameToId[bind_pos];
	if bind_pos_id == nil then
		bind_pos_id = 0;
	end
	local hash = ResNameMap[name];
	if hash == nil then
		return;
	end
	uFacadeUtility.RttPlayLighteningEffect(hash, elapsed_time, id, bind_pos_id, target_x, target_y, target_z);
end

-- RTT 播放位置特效
function Fight.RttPlayPositionEffect(cell, name, elapsed_time, target_x, target_y, target_z, callback)
	uFacadeUtility.RttPlayPositionEffect(cell, name, elapsed_time, target_x, target_y, target_z, callback);
end

-- 播放闪电特效
function Fight.PlayLighteningEffect(name, elapsed_time, id, bind_pos, target_id, target_bind_pos)
	local bind_pos_id = BindPosNameToId[bind_pos];
	if bind_pos_id == nil then
		bind_pos_id = 0;
	end
	local target_bind_pos_id = BindPosNameToId[target_bind_pos];
	if target_bind_pos_id == nil then
		target_bind_pos_id = 0;
	end
	local hash = ResNameMap[name];
	if hash == nil then
		return;
	end
	uFacadeUtility.PlayLighteningEffect(hash, elapsed_time, id, bind_pos_id, target_id, target_bind_pos_id);
end


-- 播放飞弹特效(模型)
function Fight.RttPlayLineBulletEffect(name, id, bind_pos, target_x, target_y, target_z, speed, callback)
	local bind_pos_id = BindPosNameToId[bind_pos];
	if bind_pos_id == nil then
		bind_pos_id = 0;
	end
	local hash = ResNameMap[name];
	if hash == nil then
		return;
	end
	uFacadeUtility.RttPlayLineBulletEffect(hash, id, bind_pos_id, target_x, target_y, target_z, speed, callback);
end


-- 播放飞弹特效
function Fight.PlayLineBulletEffect(name, id, bind_pos, target_id, target_bind_pos, speed, callback)
	local bind_pos_id = BindPosNameToId[bind_pos];
	if bind_pos_id == nil then
		bind_pos_id = 0;
	end
	local target_bind_pos_id = BindPosNameToId[target_bind_pos];
	if target_bind_pos_id == nil then
		target_bind_pos_id = 0;
	end
	local hash = ResNameMap[name];
	if hash == nil then
		return;
	end
	uFacadeUtility.PlayLineBulletEffect(hash, id, bind_pos_id, target_id, target_bind_pos_id, speed, callback);
end

-- 播放射线子弹特效
function Fight.PlayRayBulletEffect(name, id, bind_pos, target_id, target_bind_pos, range, speed, callback)
	local bind_pos_id = BindPosNameToId[bind_pos];
	if bind_pos_id == nil then
		bind_pos_id = 0;
	end
	local target_bind_pos_id = BindPosNameToId[target_bind_pos];
	if target_bind_pos_id == nil then
		target_bind_pos_id = 0;
	end
	local hash = ResNameMap[name];
	if hash == nil then
		return;
	end
	uFacadeUtility.PlayLineBulletEffect(hash, id, bind_pos_id, target_id, target_bind_pos_id, speed, callback);
end

-- 播放跟随子弹特效
function Fight.PlayBulletTraceEffect(name, id, target_id, target_bind_pos, speed, accel, callback)
	local target_bind_pos_id = BindPosNameToId[target_bind_pos];
	if target_bind_pos_id == nil then
		target_bind_pos_id = 0;
	end
	local hash = ResNameMap[name];
	if hash == nil then
		return;
	end
	local ds = AvatarCache.GetAvatar(id);
	local pos_x = ds["pos_x"];
	local pos_y = ds["pos_y"];
	local pos_z = ds["pos_z"];
	uFacadeUtility.PlayBulletTraceEffect(hash, pos_x, pos_y, pos_z, target_id, target_bind_pos_id, speed, accel, callback);
end

-- 状态跳转（对于模型）
function Fight.DoJumpStateForModel(ds, next_state_name, normalized_time)
	local hash = const.AnimatorStateNameToId[next_state_name];
	uFacadeUtility.JumpStateForModel(ds.id, hash, normalized_time);
end


function Fight.DoJumpStateDontSendStopMoveMsg(ds, source, next_state_name, normalized_time)
	local state = Fight.GetState(ds, next_state_name);
	state.source = source;
	local hash = const.AnimatorStateNameToId[next_state_name];
	uFacadeUtility.JumpState(ds.id, hash, normalized_time);
	-- uFacadeUtility.JumpState(ds.id, next_state_name, normalized_time);
end


-- 跳转到一般状态
function Fight.DoJumpState(ds, source, next_state_name, normalized_time)

	-- 跳转状态
	Fight.DoJumpStateDontSendStopMoveMsg(ds, source, next_state_name, normalized_time);
	
	-- 处理 stop_move 消息发送
	local will_send = false;
	local curr_state_name = ds.curr_state_name;
	if curr_state_name == "JoystickRun" then
		will_send = true;
	elseif curr_state_name == "Chase" or
		curr_state_name == "PathfindingRun" or 
		curr_state_name == "ClickRun" or
		curr_state_name == "Return" then
	    local state = Fight.GetState(ds, curr_state_name);
	    if state ~= nil then
	    	local move_data = state.move_data;
	    	if move_data ~= nil then
	    		if not move_data.arrived then
					will_send = true;
	   			end
	    	end
	    end
	end
	-- 发送 stop_move
	if will_send then
	    --print(string.format("[stop_move] id=%d, time=%f", ds.id, TimerManager.GetUnityTime()));
	   	uFacadeUtility.SendStopMoveMsg();
	end
end


-- 跳转到追击状态
function Fight.DoJumpChaseState(ds, source, next_state_name, normalized_time, horse_normalized_time, skill_id, target_id)
	local state = ds._t.Chase;
	state.source = source;
	state.skill_id = skill_id;
	state.target_id = target_id;
	Fight.DoJumpState(ds, source, next_state_name, normalized_time);
end


-- 转向目标
function Fight.DoRotateToTarget(ds, target)
	local pos_x = target["pos_x"];
	local pos_y = target["pos_y"];
	local pos_z = target["pos_z"];
	return Fight.DoRotateToPos(ds, pos_x, pos_y, pos_z);
end

-- 旋转朝向当前目标位置
function Fight.DoRotateToCurrentTarget(ds)
	local target = TargetSelecter.current;
	if target == nil then
		return;
	end
	Fight.DoRotateToTarget(ds, target);
end


-- 旋转朝向目标点
function Fight.DoRotateToPos(ds, target_pos_x, target_pos_y, target_pos_z)
	uFacadeUtility.RotateToPos(ds["id"], target_pos_x, target_pos_y, target_pos_z);
end


function Fight.DoPlaySound(ds, sound_name)
	Fight.PlaySound(sound_name);
end

function Fight.DoJoystickMove(ds, delta_time)
	local move_speed = ds.move_speed;
	uFacadeUtility.UpdateJoystickRun(delta_time, move_speed);
end

-- 设置角色位置和方向（对于模型）
function Fight.SetAvatarPosAndDirForModel(ds)
	local pos_x = ds["pos_x"];
	local pos_y = ds["pos_y"];
	local pos_z = ds["pos_z"];
	local dir_x = ds["dir_x"];
	local dir_y = ds["dir_y"];
	local dir_z = ds["dir_z"];
	uFacadeUtility.SetAvatarPosAndDirForModel(ds["id"], pos_x, pos_y, pos_z, dir_x, dir_y, dir_z);
end

-- 同步位置信息
function Fight.SetAvatarPosAndDir(ds)
	local pos_x = ds["pos_x"];
	local pos_y = ds["pos_y"];
	local pos_z = ds["pos_z"];
	local dir_x = ds["dir_x"];
	local dir_y = ds["dir_y"];
	local dir_z = ds["dir_z"];
	uFacadeUtility.SetAvatarPosAndDir(ds["id"], pos_x, pos_y, pos_z, dir_x, dir_y, dir_z);
end


-- 和服务器同步技能
function Fight.DoSyncSkill(ds, sync_skill_id, sync_target_id)
	local pos_x = ds.pos_x;
	local pos_y = ds.pos_y;
	local pos_z = ds.pos_z;
	--print(string.format("id=%d, skill_id=%d, time=%f", ds.id, sync_skill_id, TimerManager.GetUnityTime()));
	uFacadeUtility.SyncCastSkill(sync_skill_id, sync_target_id, pos_x, pos_y, pos_z);
end


-- 获取技能 cd 时间
function Fight.GetSkillCdTime(skill_id, skill_level)
	local cd = tb.GetTableByKey(tb.SkillCDTable, {skill_id, skill_level});
	if cd ~= nil then
		return cd * 1000;
	end
	local skill_table_item = tb.SkillTable[skill_id];
	cd = skill_table_item.cd;
	return cd;
end

-- 技能按钮走cd
function Fight.DoStartSkillButtonCD(ds, skill_button_index, skill_button_cd, skill_button_press_simulate)
	uFacadeUtility.StartSkillButtonCd(skill_button_index, skill_button_cd, skill_button_press_simulate);
end

-- 显示点击地面光效
function Fight.DoShowClickEffect(ds, show)
	if show then
		local click_pos = ClickMoveManager.GetClickPos();
		uFacadeUtility.ShowClickMoveEffect(true, click_pos.x, click_pos.y, click_pos.z);
	else
		uFacadeUtility.ShowClickMoveEffect(false, 0, 0, 0);
	end
end


--------------------------------------------------------------------
-- 角色头顶文字装配函数
--------------------------------------------------------------------
local BoxIcon = {"tb_headbaoxiang1","tb_headbaoxiang2","tb_headbaoxiang3"};
function Fight.SetBoxIcon(title,number)
	title:GO('Panel.Other.BoxIcon'):Show();
	title:GO('Panel.Other.BoxIcon'):StopAllUIEffects();
	if number < 10 then
		title:GO('Panel.Other.BoxIcon'):Hide();
	elseif number < 12 then
		title:GO('Panel.Other.BoxIcon'):PlayUIEffectForever(title.gameObject, "luoduojintiao_shao")
	elseif number < 14 then
		title:GO('Panel.Other.BoxIcon'):PlayUIEffectForever(title.gameObject, "luoduojintiao_zhong")
	else
		title:GO('Panel.Other.BoxIcon'):PlayUIEffectForever(title.gameObject, "luoduojintiao_duo")
	end
end
-- 玩家头顶文字装配函数
function Fight.BuildPlayerTitle(ds, title)
	if title == nil then
		return;
	end
	Fight.FormatTitle(ds, title)
	local legion_uid = ds.legion_uid;
	if legion_uid ~= 0 then
		local legion_position = ds.legion_position;
		local legion_name = client.tools.ensureString(ds.legion_name);
		local armyNameWp = title:GO('Panel.Other.ArmyName');
		if legion_position == 0 then
			armyNameWp.text = "";
		elseif legion_position >= 1 and legion_position <= 5 then
			armyNameWp.text = string.format("%s·%s", legion_name, const.LegionPosName[legion_position]);
		else
			armyNameWp.text = "";
			error("错误的公会职位: " .. legion_position);
		end
		armyNameWp:Show();
	else
		local armyNameWp = title:GO('Panel.Other.ArmyName');
		armyNameWp:Hide();
	end
	-- print(DataCache.treasureNumber)
	if DataCache.treasureNumber ~= nil then
		Fight.SetBoxIcon(title,DataCache.treasureNumber);
	end
end

-- 其他玩家头顶文字装配函数
function Fight.BuildOtherPlayerTitle(ds, title)
	if title == nil then
		return;
	end
	Fight.FormatTitle(ds, title)
	local legion_uid = ds.legion_uid;
	if legion_uid ~= nil and legion_uid ~= 0 then
		local legion_position = ds.legion_position;
		local legion_name = client.tools.ensureString(ds.legion_name);
		local armyNameWp = title:GO('Panel.Other.ArmyName');
		if legion_position == 0 then
			armyNameWp.text = "";
		elseif legion_position >= 1 and legion_position <= 5 then
			armyNameWp.text = string.format("%s·%s", legion_name, const.LegionPosName[legion_position]);
		else
			armyNameWp.text = "";
			error("错误的公会职位: " .. legion_position);
		end
		armyNameWp:Show();
	else
		local armyNameWp = title:GO('Panel.Other.ArmyName');
		armyNameWp:Hide();
	end
	-- print("ds.dead_protect_time")
	-- print(ds.treasure_number)
	-- print(ds.dead_protect_time)
	if ds.treasure_number ~= nil and ds.treasure_number ~= 0 then
		local nowSecond = TimerManager.GetServerNowSecond();
		if ds.dead_protect_time == nil then
			Fight.SetBoxIcon(title,ds.treasure_number);
		elseif ds.dead_protect_time == 0 or nowSecond > ds.dead_protect_time then
			Fight.SetBoxIcon(title,ds.treasure_number);
		else
			local lastTime = ds.dead_protect_time - nowSecond;
			print("有保护Buff时间:"..lastTime)
			local TitleTimer = Timer.New(function()
					Fight.SetBoxIcon(title,ds.treasure_number);
				end,lastTime,0,true);
			TitleTimer:Start();
		end
	end
	-- print(ds.buffer_list)
	if ds.buffer_list ~= nil then
		for i=1,#ds.buffer_list do
			BuffManager.OnAddBuff(ds.id, 0, ds.buffer_list[i][2]);
		end
	end
end

-- 给头顶文字赋值
function Fight.FormatTitle(ds, title)
	if title == nil then
		return;
	end
	local name = ds["name"];
	if const.debug then
		name = string.format("%s(%d)", ds["name"], ds["id"]);
	end
	local nameWp = title:GO('Panel.Other.Name');
	if nameWp ~= nil then
		nameWp.text = name;
		nameWp:Show();
	end
end

-- 离线玩家头顶文字装配函数
function Fight.BuildOfflinePlayerTitle(ds, title)
	Fight.BuildOtherPlayerTitle(ds, title);
end

-- 怪物头顶文字装配函数
function Fight.BuildMonsterTitle(ds, title)
	Fight.BuildCommonTitle(ds, title);
end

-- 世界Boss头顶文字装配函数
function Fight.BuildWorldBossTitle(ds, title)
	Fight.BuildCommonTitle(ds, title);
end

-- 副本Boss头顶文字装配函数
function Fight.BuildFubenBossTitle(ds, title)
	Fight.BuildCommonTitle(ds, title);
end

-- Npc 头顶文字装配函数
function Fight.BuildNpcTitle(ds, title)
	Fight.FormatTitle(ds, title);
end

-- 触发器头顶文字装配函数
function Fight.BuildTriggerTitle(ds, title)
	Fight.BuildCommonTitle(ds, title);
end

function Fight.BuildCommonTitle(ds, title)
	Fight.FormatTitle(ds, title)
end

-- 装配玩家文字
function Fight.BuildItemTitle(ds, title)
	Fight.FormatTitle(ds, title)
end

-----------------------------------------------------------------------
-- 工具函数
-----------------------------------------------------------------------

-- 通过职业名获取 Lua 逻辑
function Fight.GetLuaLogicByCareer(career)
	local logicName = "Solider";
	if career == "solider" then
		logicName = "Solider";
	elseif career == "bowman" then
		logicName = "Bowman";
	elseif career == "magician" then
		logicName = "Magician";
	else
	end
	return logicName;
end



-- 通过时装获取当前模型
function Fight.GetRoleSuitName(career, sex, suitActivateId)
	if suitActivateId == nil or suitActivateId == 0 then
		suitActivateId = FashionSuit.getNewerSuitIdByCareer(career);
	end
	local suit_info = FashionSuit.getFashionSuitTableInfoById(suitActivateId);
	if sex == Gender.Male then
		return suit_info.male_model;
	else
		return suit_info.female_model;
	end
end


-- 判断目标是否丢失
function Fight.IsTargetLost(target_id)
	-- 目标id == 0
	if target_id == 0 then
		return true;
	end
	-- 攻击目标已经丢失
    local target = AvatarCache.GetAvatar(target_id);
    if target == nil then
        return true;
    end
    return false;
end

-- 判断目标是否死亡
function Fight.IsTargetDead(target_id)
	-- 目标id == 0
	if target_id == 0 then
		return true;
	end
	-- 攻击目标已经死亡
	local target = AvatarCache.GetAvatar(target_id);
	if target == nil then
		return true;
	end
    local target_class = Fight.GetClass(target);
    return target_class.IsDead();
end


-- 当前没有目标
function Fight.HasCurrentTarget()
	-- 没有当前目标
    local current = TargetSelecter.current;
    if current ~= nil then
        return true;
    end
    return false;
end


-- 获取角色类
function Fight.GetClass(ds)
	local t = ds._t;
	return t;
end

-- 打印客户端路径
function Fight.PrintClientTracePath(id, path)
	local count = #path;
	if count > 0 then
		--print(string.format("[%d] path begin:", id));
		for i = 1, count do
			local ptInfo = path[i];
			local pos = ptInfo[1];
			local pos_x = pos[1];
			local pos_y = pos[2];
			local pos_z = pos[3];
			local time = ptInfo[2];
			--print(string.format("pos: x=%f, y=%f, z=%f; time=%d", pos_x, pos_y, pos_z, time));
		end
		--print(string.format("[%d] path end ---------------", id));
	else
		--print(string.format("[%d] path: no pos!!!", id));
	end
end


-- 把当前服务端路径时间提升到新的服务器时间
-- 把服务器时间提升到新的开始时间
function Fight.PromoteServerPathTime(inout_server_time, new_start_server_time)
	local length = #inout_server_time;
	if length == 0 then
		return;
	end
	local old_start_server_time = inout_server_time[1];
	for i = 1, length do
		inout_server_time[i] = inout_server_time[i] - old_start_server_time + new_start_server_time;
	end
end

-- 转换服务器路径到客户端
-- pos_x, pos_y, pos_z 当前角色位置
-- server_path 服务端路径点
-- server_time 服务器时刻点(ms)
-- client_current_time 当前客户端时间(unity时间)
-- server_current_time 当前服务端时间
-- 返回:
-- client_path 客户端路径
-- client_time 客户端时刻点（s）
function Fight.ConvertServerPathToClient(pos_x, pos_y, pos_z, server_path, server_time, client_current_time, server_current_time)
	local client_path = {};
	local client_time = {};
	-- 加入当前点
	if server_current_time < server_time[1] then
		client_path[1] = pos_x;
		client_path[2] = pos_y;
		client_path[3] = pos_z;
		client_time[1] = client_current_time;
	end
	for i = 1, #server_path do
		client_path[#client_path + 1] = server_path[i];
	end
	for i = 1, #server_time do
		client_time[#client_time + 1] = (server_time[i] - server_current_time) / 1000 + client_current_time;
	end
	return client_path, client_time;
end

-- 计算服务端路径时刻点
-- path 路径点集合, 结构 [p1.x, p1.y, p1.z, p2.x, p2.y, p2.z, ..., pn.x, pn.y, pn.z]
-- server_start_time 开始移动的服务器时间(单位毫秒)
-- move_speed 路径移动的速度
-- out_server_time 输出路径点时刻(服务器时间, 单位毫秒)
function Fight.CalcServerPosTime(path, server_start_time, move_speed, out_server_time)
	local length = #path / 3;
	if length == 0 then
		return;
	end
	if length == 1 then
		out_server_time[1] = server_start_time;
	end
	local length_minus_one = length - 1;
	out_server_time[1] = server_start_time;
	for i = 1, length_minus_one do
		local index = 3 * i;
		local x1 = path[index + 1];
		local y1 = path[index + 2];
		local z1 = path[index + 3];
		local x2 = path[index + 4];
		local y2 = path[index + 5];
		local z2 = path[index + 6];
		local dx = x2 - x1;
		local dy = y2 - y1;
		local dz = z2 - z1;
		local dist = math.sqrt(dx * dx + dz * dz);
		local dt = math.floor(1000 * dist / move_speed + 0.1);
		out_server_time[i + 1] = out_server_time[i] + dt;
	end
end


-- 创建技能类数据
function Fight.CreateSkillClassData(ds, id, type, index, level, last_cast_time)
	local t = {};
	t.id = id;
	t.level = level;
	t.type = type;
	t.index = index;
	t.last_cast_time = last_cast_time;
	t.info = Fight.GetSkillInfoById(ds, id);
	t.zhuanjin = {};
	if type == SkillType.Normal or type == SkillType.Recovery then
		t.unlock = true;
	else
		t.unlock = false;
	end
	t.SetLevel = function (level)
		t.level = level;
	end;
	--设置技能专精，没有的话是nil，有的话是一个Table key是专精id, value是等级（后面可以改为专精信息）
	t.Setzhuanjin = function (zhuanjin)
		if zhuanjin ~= nil then
			for i = 1, #zhuanjin do
				t.zhuanjin[zhuanjin[i][1]] = zhuanjin[i][2];
			end
		end
	end;
	t.IsUnlock = function ()
		return t.unlock;
	end;
	t.IsColdTime = function ()
		if t.last_cast_time == 0 then
			return false;
		end
		local time = TimerManager.GetServerNowMillSecond();
		local cd = Fight.GetSkillCdTime(t.id, t.level);
		-- print(string.format("cd=%d", cd));
		if (time - t.last_cast_time) < cd then
			return true;
		end
		return false;
	end;
	t.Cast = function ()
		--print("cast: " .. t.id);
		t.last_cast_time = TimerManager.GetServerNowMillSecond();
		-- 释放技能的信息保存到 myInfo 中
		local myInfo = DataCache.myInfo;
		if myInfo ~= nil then
			local abilities = myInfo.ability;
			--print(abilities);
			if abilities ~= nil then
				for i = 1, #abilities do
					local ability = abilities[i];
					if ability[1] == t.id then
						ability[3] = t.last_cast_time;
						--print(ability);
					end
				end
			end
		end
	end;
	t.GetMaskPercent = function ()
		if t.last_cast_time == 0 then
			return 1;
		end;
		local time = TimerManager.GetServerNowMillSecond();
		local t = (time - t.last_cast_time) * 0.001 / cd;
		if t > 1 then
			t = 1;
		end
		return t;
	end
	return t;
end


-- 释放技能，修改技能信息
function Fight.CastSkill(ds, type, index)
	local class = Fight.GetClass(ds);
	local skill_info = class.GetSkillByTypeAndIndex(type, index);
	skill_info.Cast();
end


-- 检查技能是否还在冷却
function Fight.IsSkillColdTime(ds, type, index)
	local class = Fight.GetClass(ds);
	local skill_info = class.GetSkillByTypeAndIndex(type, index);
	return skill_info.IsColdTime();
end


-- 检查技能是否还在冷却
function Fight.IsSkillColdTimeById(ds, id)
	local class = Fight.GetClass(ds);
	local skill_info = class.GetSkillById(id);
	if skill_info == nil then
		--print("[Error] skill " .. id .. " is null");
	end
	return skill_info.IsColdTime();
end


-- 创建技能信息
function Fight.CreateSkillClassDatasForDs(ds)

	local lua_logic = ds["lua_logic"];
	local ability = const.CareerAbility[lua_logic];
	local attack_count = ability["attack_count"];
	local skills = ability.skills;
	local t = {};
	t.skills = {};
	
	for i=1, #skills do
		local skill_info = skills[i];
		local skill_data = tb.SkillTable[skill_info.id];
		t.skills[i] = Fight.CreateSkillClassData(ds, skill_info.id, skills[i].skill_type, i, 1, 0);
	end

	t.attack_count = attack_count;
	local class = Fight.GetClass(ds);
	class["skills"] = t;
	return t;
end


-- 创建角色类数据
function Fight.CreateAvatarClassData(ds)

	local t = {};

	t.ds = ds;

    ds._t = t;

    ------------------------------
    -- 开启自动战斗
    ------------------------------

    -- 切换策略模式
    t.SwitchPKMode = function (ds, pk_mode)
    	ds.pk_mode = pk_mode;
    	if SceneManager.IsCurrentFubenMap() then
			ds.control_logic = ControlLogicType.SingleFuben;
		else
			local scene_data = tb.AreaTable[DataCache.scene_sid];
			local scene_pk_mode = scene_data.pk_mode;
			if scene_pk_mode == "free" then
				local is_auto_fighting = ds.is_auto_fighting;
				if is_auto_fighting then
					ds.control_logic = ControlLogicType.WildAutoFightPK;
				else
					ds.control_logic = ControlLogicType.WildPK;
				end
			elseif scene_pk_mode == "normal" then
		    	local is_auto_fighting = ds.is_auto_fighting;
		    	if is_auto_fighting then
		    		if pk_mode == "heping" then
		    			ds.control_logic = ControlLogicType.WildAutoFightHeping;
		    		else
		    			ds.control_logic = ControlLogicType.WildAutoFightPK;
		    		end
		    	else
		    		if pk_mode == "heping" then
		    			ds.control_logic = ControlLogicType.WildHeping;
		    		else
		    			ds.control_logic = ControlLogicType.WildPK;
		    		end
		    	end
		    end
	    end
    end;

    -- 设置自动战斗
    t.SetAutoFighting = function (ds, enable)
    	ds.is_auto_fighting = enable;
    	if enable then
    		t.SaveAutoFightPos(ds);
    	end
    	local pk_mode = ds.pk_mode;
    	t.SwitchPKMode(ds, pk_mode);
    end;

    -- 挂机
    t.HandUp = function (ds, enable)
    	t.SetAutoFighting(ds, enable);
    	EventManager.onEvent(Event.ON_AUTO_FIGHT_CHANGE);
    end;

    -- 挂机(并提示)
    t.HandUpAndShowMsg = function (ds, enable)
    	t.HandUp(ds, enable);
    	if enable then
    		ui.showMsg("开始自动战斗");
    	else
    		ui.showMsg("停止自动战斗");
    	end
    end;

    -- 变速
    t.SetMoveSpeed = function (ds, move_speed)
    	local curr_state_name = ds.curr_state_name;
    	if curr_state_name == "ClickRun" or
    	   curr_state_name == "PathfindingRun" or
    	   curr_state_name == "Return" or
    	   curr_state_name == "Chase" then
    		ds.move_speed = move_speed;
    		local state = Fight.GetState(ds, curr_state_name);
    		local move_data = state.move_data;
    		move_data.SetMoveSpeed(move_speed);
    	end
    end;

    -----------------------------
    -- npc 任务状态
    -----------------------------

    -- 隐藏交互 npc 所有任务状态
    t.HideAllTaskStates = function (ds)
    	local id = ds.id;
    	local title = uFacadeUtility.GetAvatarTitle(id);
    	if title == nil then
    		return;
    	end
    	local ExclamationMark = title:GO('Panel.exclamationMark');
        local QuestionMark = title:GO('Panel.questionMark');
        local CollectMark= title:GO('Panel.collectMark');
        if ExclamationMark ~= nil then
        	ExclamationMark:Hide();
    	end
    	if QuestionMark ~= nil then
    		QuestionMark:Hide();
    	end
    	if CollectMark ~= nil then
    		CollectMark:Hide();
    	end
    end;

    -- 显示交互 npc 任务状态
    t.ShowTaskState = function (ds, type)
    	local id = ds.id;
    	local title = uFacadeUtility.GetAvatarTitle(id);
    	if title == nil then
    		return;
    	end
    	local ExclamationMark = title:GO('Panel.exclamationMark');
        local QuestionMark = title:GO('Panel.questionMark');
        local CollectMark= title:GO('Panel.collectMark');
		ExclamationMark:PlayUIEffectForever(title.gameObject, "gantanhao_effect")
		QuestionMark:PlayUIEffectForever(title.gameObject, "wenhao_effect")

        if ExclamationMark ~= nil then
        	ExclamationMark:Hide();
    	end
    	if QuestionMark ~= nil then
    		QuestionMark:Hide();
    	end
    	if CollectMark ~= nil then
    		CollectMark:Hide();
    	end
        if type == TaskNoticeType.None then
        	return;
        end
        if type == TaskNoticeType.Accept then
        	if ExclamationMark ~= nil then
        		ExclamationMark:Show();
    		end
    		return;
        end
        if type == TaskNoticeType.Complete then
        	if QuestionMark ~= nil then
	    		QuestionMark:Show();
	    	end
        	return;
        end
        if type == TaskNoticeType.Resource then
        	if CollectMark ~= nil then
	    		CollectMark:Show();
	    	end
        	return;
        end
    end;

    --------------------------------
    -- 设置缩放比例
    --------------------------------

    -- 设置特殊怪物头顶称号
    t.SetSpecialMonsterTitle = function (type,title)
    	local monsterTitle = title:GO('Panel.Title');
    	monsterTitle:Show();
    	if type == "WorldBoss" then
			monsterTitle.text = "<color=#e3250c>世界BOSS</color>"
		elseif type == "FubenBoss" then
			monsterTitle.text = "<color=#e3250c>副本BOSS</color>"
		elseif type == "EliteMonster" then
			monsterTitle.text = "<color=#ffb54b>精英</color>"
		elseif type == "CBTMonster" then
			monsterTitle.text = "<color=#ffd34b>宝藏魔物</color>"
		else
			monsterTitle:Hide();
		end
    end

    -- 获取标题高度
   	t.GetTitleHeight = function (ds)
   		local defaultHeight = 2.5;
   		local sid = ds.sid;
    	if sid == nil then
    		return defaultHeight;
    	end
    	local npcData = tb.NPCTable[sid];
    	if npcData == nil then
    		return defaultHeight;
    	end
    	local id = ds.id;
    	local style_scale = npcData.style_scale;
    	local chose_area_str = npcData.chose_area;
    	local chose_area = {};
    	if chose_area_str == nil then
    		chose_area = {"0.5","0.5","0.5"}
    	else
    		chose_area = chose_area_str:split(',');
    	end
		local size_y = tonumber(chose_area[2]);
    	local height = math.max(defaultHeight, size_y);
    	return height;
   	end;

    -- 调整标题高度
    t.AdjustTitleHeight = function (ds)
    	local sid = ds.sid;
    	if sid == nil then
    		return;
    	end
    	local npcData = tb.NPCTable[sid];
    	if npcData == nil then
    		return;
    	end
    	local id = ds.id;
    	local style_scale = npcData.style_scale;
    	local chose_area_str = npcData.chose_area;
    	local chose_area = {};
    	if chose_area_str == nil then
    		chose_area = {"0.5","0.5","0.5"}
    	else
    		chose_area = chose_area_str:split(',');
    	end
		local size_y = tonumber(chose_area[2]);
    	local height = math.max(2.5, size_y);
    	uFacadeUtility.AdjustTitleHeight(id, height);
    end;

    -- 添加碰撞体
    t.AddBoxCollider = function (ds)
    	local sid = ds.sid;
    	if sid == nil then
    		return;
    	end
    	local npcData = tb.NPCTable[sid];
    	if npcData == nil then
    		return;
    	end
    	local id = ds.id;
    	local style_scale = npcData.style_scale;
    	local chose_area_str = npcData.chose_area;
    	local chose_area = {};
    	if chose_area_str == nil then
    		chose_area = {"0.5","0.5","0.5"}
    	else
    		chose_area = chose_area_str:split(',');
    	end
		local size_x = tonumber(chose_area[1]);
		local size_y = tonumber(chose_area[2]);
		local size_z = tonumber(chose_area[3]);
    	uFacadeUtility.AddBoxCollider(id, 0, 0.5 * size_y * style_scale, 0, size_x * style_scale, size_y * style_scale, size_z * style_scale);
    end;

    -- 调整缩放比例
    t.AdjustScale = function (ds)
    	local sid = ds.sid;
    	if sid == nil then
    		return;
    	end
    	local npcData = tb.NPCTable[sid];
    	if npcData == nil then
    		return;
    	end
    	local id = ds.id;
    	local style_scale = npcData.style_scale;
    	local chose_area_str = npcData.chose_area;
    	local chose_area = {};
    	if chose_area_str == nil then
    		chose_area = {"0.5","0.5","0.5"}
    	else
    		chose_area = chose_area_str:split(',');
    	end
		local size_x = tonumber(chose_area[1]);
		local size_y = tonumber(chose_area[2]);
		local size_z = tonumber(chose_area[3]);
    	if style_scale ~= 1 then
    		uFacadeUtility.SetAvatarScale(id, style_scale, style_scale, style_scale);
    	end
    end;

    -----------------------------
    -- 加载技能状态
    -----------------------------

    -- 加载技能状态
    t.LoadSkillStates = function (ds)
    	
    	local abilities = ds.ability;
    	local skills = t.skills.skills;
    	--print("LoadSkillStates: " .. #skills);
    	for i = 1, #skills do
    		local skill = skills[i];
    		for k = 1, #abilities do
    			local ability = abilities[k];
    			if ability[1] == skill.id then
    				--print(ability);
    				skill.unlock = true;
					skill.SetLevel(ability[2]);
					skill.Setzhuanjin(ability[4]);
					skill.last_cast_time = ability[3];
    			end
    		end
    	end
    	--print("------------ LoadSkillStates end");
    end;

    -----------------------------------------------------
    -- 复活
    -----------------------------------------------------

    t.Rebirth = function (ds)
    	if ds.hp > 0 then
    		return;
    	end
    	ds.hp = ds.maxHP;
    	local id = ds.id;
    	if id == DataCache.nodeID then
			DataCache.myInfo.hp = ds.hp;
			EventManager.onEvent(Event.ON_BLOOD_CHANGE);
		end
    	local title = uFacadeUtility.GetAvatarTitle(id);
    	t.UpdateTitleHp(ds, title);
    	Fight.DoJumpState(ds, SourceType.System, "Idle", 0);
    end;

    ----------------------------------------------------------
    -- 受击效果
    ----------------------------------------------------------

    -- 抖动
    t.Tremble = function (ds, attacker_ds)
    	local pos_x = ds.pos_x;
        local pos_y = ds.pos_y;
        local pos_z = ds.pos_z;
        local attacker_pos_x = attacker_ds.pos_x;
        local attacker_pos_y = attacker_ds.pos_y;
        local attacker_pos_z = attacker_ds.pos_z;
        local dx = pos_x - attacker_pos_x;
        local dy = pos_y - attacker_pos_y;
        local dz = pos_z - attacker_pos_z;
        local dist = math.sqrt(dx * dx + dz * dz);
        local dir_x = dx / dist;
        local dir_y = 0;
        local dir_z = dz / dist;
        uFacadeUtility.Tremble(ds.id, dir_x, dir_y, dir_z);
    end;

    -- 闪白
    t.FlashWhite = function (ds)
    	uFacadeUtility.FlashWhite(ds.id);
    end;

    -----------------------------------------------------------
    -- 武器穿戴
    -----------------------------------------------------------

    -- 穿戴装备
	t.PutOnWeapon = function (ds, sid, callback)
		local career = ds.career;
		local bind_pos = "rhand";
		if career == "bowman" then
			bind_pos = "lhand";
		end
		local equip = tb.EquipTable[sid];
		if equip == nil then
			-- print("nil equip  ===>>  "..sid)
			return
		end
		local level = equip.level;
		local alias = const.ProfessionAlias[career];
		local weapon_name = string.format("%s_%d_w", alias, level);
		uFacadeUtility.PutOnWeapon(ds.id, weapon_name, bind_pos, (ds.role_type == RoleType.Player), function ()
			callback();
		end);
	end;


	-- 穿戴武器递归
	t.PutOnEquipsInternal = function (ds, equipment, index, callback)
		if equipment == nil then
			return
		end
		local count = #equipment;
		if count == 0 then
			callback();
			return;
		end
		local equip = equipment[index];
		if type(equip) ~= "table" then
			t.PutOnEquipsInternal(ds, equipment, index + 1, callback);
			return;
		end
		local sid = tonumber(equip.sid);
		local equip_data = tb.EquipTable[sid];
		if equip_data == nil then
			t.PutOnEquipsInternal(ds, equipment, index + 1, callback);
			return
		end
		if index == count then
			if equip_data.buwei == const.BuWeiIndex["武器"] then
				t.PutOnWeapon(ds, sid, callback);
			elseif equip_data.buwei == const.BuWeiIndex["衣服"] then
				t.PutOnSuit(ds, sid, callback);
			else
				callback();
				return;
			end
		else
			if equip_data.buwei == const.BuWeiIndex["武器"] then
				t.PutOnWeapon(ds, sid, function ()
					t.PutOnEquipsInternal(ds, equipment, index + 1, callback);
				end);
			elseif equip_data.buwei == const.BuWeiIndex["衣服"] then
				t.PutOnSuit(ds, sid, function ()
					t.PutOnEquipsInternal(ds, equipment, index + 1, callback);
				end);
			else 
				t.PutOnEquipsInternal(ds, equipment, index + 1, callback);
			end
		end
	end

	-- 穿戴所有装备
	t.PutOnEquips = function (ds, equipment, callback)
		t.PutOnEquipsInternal(ds, equipment, 1, callback);
	end;

	--穿戴衣服
	t.PutOnSuit = function(ds, sid, callback)
		local career = ds.career;
		local equip = tb.EquipTable[sid];
		if equip == nil then
			return
		end
		local level = equip.level;
		local alias = const.ProfessionAlias[career];
		local sex = const.sexName[ds.sex]
		local modelMaterialName = string.format("%s_%s_%d", alias, sex, level);
		-- if ds.role_uid ~= DataCache.myInfo.role_uid then
		-- 	modelMaterialName = modelMaterialName.."_otherplayer"
		-- end
		local modelName = string.format("%s_Prefab", modelMaterialName);
		local smName = string.gsub(modelName, "_Prefab", "_controller_desc");
		-- print(modelName)
		uFacadeUtility.PutOnSuit(ds.id, modelName, smName, (ds.role_type == RoleType.Player), function() end);
	end

    ------------------------------------------------------------
    -- 标题更新
    ------------------------------------------------------------

    -- 更新标题 Hp
    t.UpdateTitleHp = function (ds, title)
        if title ~= nil then
            local hp = ds["hp"];
            local maxHP = ds["maxHP"];
            local percent = hp / maxHP;
            if percent > 1 then
                percent = 1;
            end
            local progress = title:GO('Panel.BloodBar.foreground');
            if progress ~= nil then
            	progress.fillAmount = percent;
            end
        end
    end;

    -- 更新标题红名
    t.UpdateTitleRedName = function (ds, title)
    	if title ~= nil then
    		local kill_value = ds.kill_value;
    		local grey_name_time = ds.grey_name_time;
    		local nameWp = title:GO('Panel.Other.Name');
    		if nameWp ~= nil then
	    		if kill_value > 100 then	    				    			
	    			nameWp.color = Color.New(255/255, 0/255, 0/255, 255/255);
	    		elseif grey_name_time > 0 then
	    			nameWp.color = Color.New(255/255, 255/255, 0/255, 255/255);
	    		else
	    			nameWp.color = Color.New(198/255, 246/255, 198/255, 255/255);
	    		end
	    	end
    	end
    end;


    -----------------------------------------------------------------
    -- 自动战斗
    -----------------------------------------------------------------

    -- 保存自动战斗位置
    t.SaveAutoFightPos = function (ds)
    	local pos_x = ds["pos_x"];
        local pos_y = ds["pos_y"];
        local pos_z = ds["pos_z"];
        ds["origin_x"] = pos_x;
        ds["origin_y"] = pos_y;
        ds["origin_z"] = pos_z;
        --print(string.format("保存自动战斗位置: pos={%f, %f, %f}", pos_x, pos_y, pos_z));
    end;


    -- 自动战斗返回
    t.AutoFight_Return = function (ds)
    	local return_start_wait_time = ds.return_start_wait_time;
    	if return_start_wait_time == nil then
    		ds.return_start_wait_time = ds.curr_time;
    	end
    	local elapsed_time = ds.curr_time - ds.return_start_wait_time;
    	if elapsed_time < const.wait_for_autofight_return then
    		return false;
    	end
    	local pos_x = ds.pos_x;
    	local pos_y = ds.pos_y;
    	local pos_z = ds.pos_z;
    	local origin_x = ds.origin_x;
    	local origin_y = ds.origin_y;
    	local origin_z = ds.origin_z;
    	local random_move_radius = ds.random_move_radius;
    	local path = {};
    	local result = uFacadeUtility.CalcAutoFightReturnPath(pos_x, pos_y, pos_z, origin_x, origin_y, origin_z, random_move_radius, path);
    	if result then
    		ds.return_start_wait_time = nil;
    		-- 没有目标进入归位逻辑
            Fight.DoJumpState(ds, SourceType.AutoFight, "Return", 0);
            return true;
        end
        return false;
    end;

    --返回挂机点
    t.ReturnOriginPos = function (ds)
    	local origin_x = ds.origin_x;
    	local origin_y = ds.origin_y;
    	local origin_z = ds.origin_z;
    	t.HandUp(ds, false);
    	AutoPathfindingManager.StartPathfinding_S(origin_x, origin_y, origin_z, false, function ()
    		t.HandUp(ds, true);
    	end);
    end

    -- 自动战斗函数，当玩家进入自动战斗此函数会调用
    -- 自动战斗分野外自动战斗和副本自动战斗
    t.AutoFight = function (ds, last_target_id)
        local is_auto_fighting = ds["is_auto_fighting"];
        if is_auto_fighting then
            if SceneManager.IsCurrentFubenMap() then
                return t.AutoFight_Fuben(ds, last_target_id);
            else
                return t.AutoFight_Wild(ds, last_target_id);
            end
        end
        return false;
    end;

    -- 野外自动战斗
    t.AutoFight_Wild = function (ds, last_target_id)

        -- 目标已经丢失
        local target_is_lost = Fight.IsTargetLost(last_target_id);
        -- 目标已经死亡
        local target_is_dead = Fight.IsTargetDead(last_target_id);
        -- 没有当前目标
        local has_current_target = Fight.HasCurrentTarget();
        -- 当前要攻击的目标
        local target = nil;
        -- 当前目标作为攻击目标
        if target_is_lost or target_is_dead then
            if has_current_target then
                target = TargetSelecter.current;
            end
        else
            target = AvatarCache.GetAvatar(last_target_id);
        end

       	-- 血量低于40%，释放回血技能
       	if ds.hp < ds.maxHP * 0.4 then
            local class = Fight.GetClass(ds);
       		local special_skill_data = class.GetSkillByTypeAndIndex(SkillType.Recovery, 1);
            if special_skill_data.IsUnlock() and not special_skill_data.IsColdTime() then
       			return Fight.TryJumpSkillById(ds, special_skill_data.id, SourceType.AutoFight);
       		end
       	end

        -- 没有当前目标
        if target == nil then
        	local curr_state_name = ds.curr_state_name;
        	if curr_state_name ~= "Return" then
        		return t.AutoFight_Return(ds);
            end
            return false;
        else



        	-- 当前目标无法攻击
        	if not ControlLogic.IsTargetCanAttack_SelectedTarget(target) then

        		TargetSelecter.ClearTarget();
        		-- 尝试重新拾取
	        	ControlLogic.AutoSelect();
	        	-- 提取当前目标
	        	target = TargetSelecter.current;
	        	-- 如果还是没有目标
		        if target == nil then
		        	local curr_state_name = ds.curr_state_name;
		        	if curr_state_name ~= "Return" then
		        		return t.AutoFight_Return(ds);
		            end
		            return false;
		        end
        	end


            local current_target_id = target["id"];

            -- 获取当前类
            local class = Fight.GetClass(ds);

            -- local settings = DataCache.settings;
            
            -- 使用必杀技能
        	-- if settings.fight_useEX then
	            -- 必杀技能
	            local ex_skill_data = class.GetSkillByTypeAndIndex(SkillType.Skill, const.EX_Index);
	            if ex_skill_data.IsUnlock() and not ex_skill_data.IsColdTime() then
	                return Fight.TryJumpSkillById(ds, ex_skill_data.id, SourceType.AutoFight);
	            end
	        -- end

	        -- 使用群攻技能
	        -- if settings.fight_useAOE then
	            -- 群攻技能
	            local aoe_skill_data = class.GetSkillByTypeAndIndex(SkillType.Skill, const.AOE_Index);
	            if aoe_skill_data.IsUnlock() and not aoe_skill_data.IsColdTime() then
	                return Fight.TryJumpSkillById(ds, aoe_skill_data.id, SourceType.AutoFight);
	            end
	        -- end

	        -- 使用特殊技能
	        -- if settings.fight_useSpecial then
	            -- 计算玩家和目标距离
	            -- local target_pos_x = target["pos_x"];
	            -- local target_pos_y = target["pos_y"];
	            -- local target_pos_z = target["pos_z"];
	            -- local pos_x = ds["pos_x"];
	            -- local pos_y = ds["pos_y"];
	            -- local pos_z = ds["pos_z"];
	            -- local dx = target_pos_x - pos_x;
	            -- local dy = target_pos_y - pos_y;
	            -- local dz = target_pos_z - pos_z;
	            -- local dist_sq = dx * dx + dz * dz;
	            -- local max_skill_distance = class.GetMaxSkillDistance();
	            -- local dist2 = max_skill_distance * max_skill_distance;
	            -- if dist_sq > dist2 then
	                local special_skill_data = class.GetSkillByTypeAndIndex(SkillType.Skill, const.Special_Index);
	                if special_skill_data.IsUnlock() and not special_skill_data.IsColdTime() then
	                	--print("11111111");
	                	--print(special_skill_data.info.no_action);
	                	-- 转向目标
	                	if not special_skill_data.info.no_action then
	                		--print("not no_action");
		            		if target ~= nil then
		            			--print("rotate to");
		            			Fight.DoRotateToTarget(ds, target);
		            		end
		            	end
	                    return Fight.TryJumpSkillById(ds, special_skill_data.id, SourceType.AutoFight);
	                end
	            -- end
	        -- end


            -- 使用普攻
            local attack_skill_data = Fight.GetAutoFightAttackSkillData(ds, last_target_id, current_target_id);
            if attack_skill_data ~= nil then
                return Fight.TryJumpSkillById(ds, attack_skill_data.id, SourceType.AutoFight);
            end


            return false;
        end

    end;

    -- 副本自动战斗
    t.AutoFight_Fuben = function (ds, last_target_id)

    	-- 目标已经丢失
        local target_is_lost = Fight.IsTargetLost(last_target_id);
        -- 目标已经死亡
        local target_is_dead = Fight.IsTargetDead(last_target_id);
        -- 没有当前目标
        local has_current_target = Fight.HasCurrentTarget();
        -- 当前要攻击的目标
        local target = nil;
        -- 当前目标作为攻击目标
        if target_is_lost or target_is_dead then
            if has_current_target then
                target = TargetSelecter.current;
            end
        else
            target = AvatarCache.GetAvatar(last_target_id);
        end

       	-- 血量低于40%，释放回血技能
       	if ds.hp < ds.maxHP * 0.4 then
            local class = Fight.GetClass(ds);
       		local special_skill_data = class.GetSkillByTypeAndIndex(SkillType.Recovery, 1);
            if special_skill_data.IsUnlock() and not special_skill_data.IsColdTime() then
       			return Fight.TryJumpSkillById(ds, special_skill_data.id, SourceType.AutoFight);
       		end
       	end

        -- 没有当前目标
        if target == nil then
            return true;
        else
        	-- 当前目标无法攻击
        	if not ControlLogic.IsTargetCanAttack_AutoSelect(target) then
        		-- 清除当前目标
        		TargetSelecter.ClearTarget();
        		-- 尝试重新拾取
	        	ControlLogic.AutoSelect();
	        	-- 提取当前目标
	        	target = TargetSelecter.current;
	        	-- 如果还是没有目标
		        if target == nil then
		            return true;
		        end
        	end


            local current_target_id = target["id"];

            -- 获取当前类
            local class = Fight.GetClass(ds);

            -- 计算玩家和目标距离
            -- local target_pos_x = target["pos_x"];
            -- local target_pos_y = target["pos_y"];
            -- local target_pos_z = target["pos_z"];
            -- local pos_x = ds["pos_x"];
            -- local pos_y = ds["pos_y"];
            -- local pos_z = ds["pos_z"];
            -- local dx = target_pos_x - pos_x;
            -- local dy = target_pos_y - pos_y;
            -- local dz = target_pos_z - pos_z;
            -- local dist_sq = dx * dx + dz * dz;
            -- local max_skill_distance = class.GetMaxSkillDistance();
            -- local dist2 = max_skill_distance * max_skill_distance;
            -- if dist_sq > dist2 then
            --     local special_skill_data = class.GetSkillByTypeAndIndex(SkillType.Skill, const.Special_Index);
            --     if not special_skill_data.IsColdTime() then
            --         return Fight.TryJumpSkillById(ds, special_skill_data.id, SourceType.AutoFight);
            --     end
            -- end

            local settings = DataCache.settings;
            if settings.fight_useEX then
	            -- 必杀技能
	            local ex_skill_data = class.GetSkillByTypeAndIndex(SkillType.Skill, const.EX_Index);
	            if ex_skill_data.IsUnlock() and not ex_skill_data.IsColdTime() then
	                return Fight.TryJumpSkillById(ds, ex_skill_data.id, SourceType.AutoFight);
	            end
	        end

	        if settings.fight_useAOE then
	            -- 群攻技能
	            local aoe_skill_data = class.GetSkillByTypeAndIndex(SkillType.Skill, const.AOE_Index);
	            if aoe_skill_data.IsUnlock() and not aoe_skill_data.IsColdTime() then
	                return Fight.TryJumpSkillById(ds, aoe_skill_data.id, SourceType.AutoFight);
	            end
           	end

            -- 普攻
            local attack_skill_data = Fight.GetAutoFightAttackSkillData(ds, last_target_id, current_target_id);
            if attack_skill_data ~= nil then
                return Fight.TryJumpSkillById(ds, attack_skill_data.id, SourceType.AutoFight);
            end


            return false;
        end
    end;

    -------------------------------------------------------------
    -- 玩家进入范围检测
    -------------------------------------------------------------

    t.click_listeners = {};

    -- 添加点击处理
    t.AddClickListener = function (listener)
    	local listeners = t.click_listeners;
    	listeners[#listeners + 1] = listener;
    end;

    -- 触发点击事件
    t.OnClick = function (ds)
		local listeners = t.click_listeners;
		--print("t.OnClick:"..#listeners)
		--print(debug.traceback())
    	for i = 1, #listeners do
    		local listener = listeners[i];
    		listener(ds);
    	end
    end;

    t.enter_listeners = {};
    t.leave_listeners = {};
    t.stay_listeners = {};


    t.InitScopeDetect = function (ds)
    	ds["scope_detect_enable"] = false;
    	ds["scope_detect_shape"] = "circle";
    	ds["scope_detect_radius"] = 5.0;
    	ds["is_within_scope"] = false;
    end;


    t.InitScopeDetect(ds);

    -- 添加进入范围监听器
    t.AddEnterScopeListener = function (listener)
    	local listeners = t.enter_listeners;
    	listeners[#listeners + 1] = listener;
    end;

    -- 进入范围
    t.OnEnterScope = function (ds)
    	local listeners = t.enter_listeners;
    	for i = 1, #listeners do
    		local listener = listeners[i];
    		listener(ds);
    	end
    end;

    -- 添加离开范围监听器
    t.AddLeaveScopeListener = function (listener)
    	local listeners = t.leave_listeners;
    	listeners[#listeners + 1] = listener;
    end;

    -- 退出范围
    t.OnLeaveScope = function (ds)
		local listeners = t.leave_listeners;
    	for i = 1, #listeners do
    		local listener = listeners[i];
    		listener(ds);
    	end
    end;

    -- 添加离开范围监听器
    t.AddStayScopeListener = function (listener)
    	local listeners = t.stay_listeners;
    	listeners[#listeners + 1] = listener;
    end;

    -- 停留在范围
    t.OnStayScope = function (ds)
    	local listeners = t.stay_listeners;
    	for i = 1, #listeners do
    		local listener = listeners[i];
    		listener(ds);
    	end
    end;

    -- 强制离开范围
    t.ForseLeaveScope = function (ds)
		ds["is_within_scope"] = false;
		ds["enter_scope_time"] = 0;
    end;

    -- 设置范围检测开启/关闭
    t.SetDetectScopeEnable = function (ds, enable)
    	if enable then
    		local last_enable = ds["scope_detect_enable"];
    		if not last_enable then
    			ds["scope_detect_enable"] = true;
    			ds["is_within_scope"] = false;
    			ds["enter_scope_time"] = 0;
    		end
    	else
    		ds["scope_detect_enable"] = false;
    		ds["is_within_scope"] = false;
    		ds["enter_scope_time"] = 0;
    	end
    end;

    -- 圆形范围检测
    t.CircleScopeDetect = function (ds)
    	local pos_x = ds["pos_x"];
    	local pos_y = ds["pos_y"];
    	local pos_z = ds["pos_z"];
    	local player = AvatarCache.me;
    	local my_pos_x = player["pos_x"];
    	local my_pos_y = player["pos_y"];
    	local my_pos_z = player["pos_z"];
    	local dx = my_pos_x - pos_x;
    	local dy = my_pos_y - pos_y;
    	local dz = my_pos_z - pos_z;
    	local distSq = dx * dx + dz * dz;
    	local distance = ds["scope_detect_radius"];
    	local dist2 = distance * distance;
    	if distSq <= dist2 then
    		return true;
    	end
    	return false; 
    end;

    -- 检查范围(ds 是自身数据)
    t.UpdateScopeDetect = function (ds)
    	local scope_detect_enable = ds["scope_detect_enable"];
    	if not scope_detect_enable then
    		return;
    	end
    	
    	local player = AvatarCache.me;
    	if player ~= nil then
    		if player["id"] == ds["id"] then
    			return;
    		end
    	end
    	
    	local type = ds["scope_detect_shape"];
    	local is_within_scope = false;
    	if type == "circle" then
    		is_within_scope = t.CircleScopeDetect(ds);
    	else
    	end
    	local last_is_within_scope = ds["is_within_scope"];
    	ds["is_within_scope"] = is_within_scope;
    	if last_is_within_scope then
    		if is_within_scope then
    			t.OnStayScope(ds);
    		else
    			t.OnLeaveScope(ds);
    		end
    	else
    		if is_within_scope then
    			ds["enter_scope_time"] = TimerManager.GetUnityTime();
    			t.OnEnterScope(ds);
    		else
    			-- 上次检测不在范围内，这次检测也不在范围内
    			-- do nothing
    		end
    	end
    end;

    ---------------------------------------------------------------
    -- 技能
    ---------------------------------------------------------------

    t.GetMaxSkillDistance = function ()
    	local skills = t.skills.skills;
    	local max_distance = 0;
    	for i = 1, #skills do
    		local skill = skills[i];
    		local skill_data = tb.SkillTable[skill.id];
    		if skill_data.distance > max_distance then
    			max_distance = skill_data.distance;
    		end
    	end
    	return max_distance;
    end;


    -- 获取技能
    t.GetSkillByIndex = function (index)
    	local skills = t.skills.skills;
    	return skills[index];
    end;

    -- 获取普通攻击数量
    t.GetNormalAttackCount = function ()
    	local skills = t.skills;
    	return skills.attack_count;
    end;

    -- 获取技能类型索引
    t.GetSkillTypeIndex = function (skill_id)
    	local skill = t.GetSkillById(skill_id);
    	if skill.type == SkillType.Normal then
    		return skill.index;
    	end
    	local attack_count = t.GetNormalAttackCount();
    	return skill.index - attack_count;
    end;

    -- 通过类型和索引获取技能
    t.GetSkillByTypeAndIndex = function (type, index)
    	local skills = t.skills.skills;
    	local skill_index = 1;
    	for i = 1, #skills do
    		if skills[i].type == type then
    			if skill_index == index then
    				return skills[i];
    			else
    				skill_index = skill_index + 1;
    			end
    		end
    	end
    	return nil;
    end;

    -- 通过技能id获取技能
    t.GetSkillById = function (id)
    	local skills = t.skills.skills;
    	for i = 1, #skills do
    		if skills[i].id == id then
    			return skills[i];
    		end
    	end
    	return nil;
    end;


    ----------------------------------------------------------------
    -- 命令队列: 用于网络控制的角色
    ----------------------------------------------------------------

    t.command_queue = {};

    t.PeekCommand = function ()
    	local queue = t.command_queue;
    	local count = #queue;
    	if count == 0 then
    		return nil;
    	end
    	return queue[1];
    end;

    t.ClearCommandQueue = function ()
    	local queue = t.command_queue;
    	for i = 1, #queue do
    		queue[i] = nil;
    	end
    end;

    t.EnqueueCommand = function (command)
    	local queue = t.command_queue;
    	queue[#queue + 1] = command;
    end;

    t.DequeueCommand = function ()
    	local queue = t.command_queue;
    	local count = #queue;
    	if count == 0 then
    		return nil;
    	end
    	local command = queue[1];
    	for i = 1, count - 1 do
    		queue[i] = queue[i + 1];
    	end
    	queue[count] = nil;
    	return command;
    end;


    t.AddSkillCommand = function (ds, skill_id, target_id)
    	local id = ds.id;    	
    	local command = {};
    	command.type = CommandType.Skill;
    	command.skill_id = skill_id;
    	command.target_id = target_id;
    	t.EnqueueCommand(command);
    end;
    
    -- 添加移动指令
    -- server_path 服务端传过来的路径点，结构 [x1, y1, z1, x2, y2, z2, ..., xn, yn, zn]
    -- server_time 服务端传过来的时刻点, 结构 [t1, t2, ..., tn]
    -- type 0: 非摇杆移动，1 代表摇杆移动
    t.AddRunCommand = function (ds, server_start_time, server_path, server_time, type)
    	local id = ds.id;
    	local queue = t.command_queue;
    	local count = #queue;
    	if count == 0 then
    		local curr_state_name = ds["curr_state_name"];
    		if curr_state_name == "Run" then
    			local class = Fight.GetClass(ds);
    			local state = class.Run;
    			if type == 0 then
					state.idle = true;
				end
    			local move_data = class.Run.move_data;
    			local move_speed = ds.move_speed;
    			local pos_x = ds.pos_x;
    			local pos_y = ds.pos_y;
    			local pos_z = ds.pos_z;
    			local dir_x = ds.dir_x;
    			local dir_y = ds.dir_y;
    			local dir_z = ds.dir_z;
    			local client_start_time = TimerManager.GetUnityTime();
    			local server_current_time = move_data.GetServerTimeOfCurrPos();
    			local client_path, client_time = Fight.ConvertServerPathToClient(pos_x, pos_y, pos_z, server_path, server_time, client_start_time, server_current_time);
    			move_data.SetPath(client_start_time, server_current_time, dir_x, dir_y, dir_z, client_path, client_time, move_speed);
    		else
				local command = {};
				command.type = CommandType.Run;
				command.path = server_path;							
				command.time = server_time;
				command.server_start_time = server_start_time;
				if ds.role_type == RoleType.OtherPlayer then
					if type == 0 then
						command.idle = true;
					else
						command.idle = false;
					end
				else
					command.idle = true;
				end
				t.EnqueueCommand(command);
			end
		else
			local last_command = queue[count];
			if last_command.type == CommandType.Run then
				last_command.path = server_path;
				last_command.time = server_time;
				last_command.server_start_time = server_start_time;
				if ds.role_type == RoleType.OtherPlayer then
					if type == 0 then
						last_command.idle = true;
					else
						last_command.idle = false;
					end
				else
					last_command.idle = true;
				end
			else
				local command = {};
				command.type = CommandType.Run;
				command.path = server_path;								-- 路径点
				command.time = server_time;
				command.server_start_time = server_start_time;
				if ds.role_type == RoleType.OtherPlayer then
					if type == 0 then
						command.idle = true;
					else
						command.idle = false;
					end
				else
					command.idle = true;
				end								-- 路径点时刻
				t.EnqueueCommand(command);
			end
		end
	end;

	-- 是否命令队列为空
	t.IsCommandQueueEmpty = function ()
		local queue = t.command_queue;
		local count = #queue;
		return count == 0;
	end;

	-- 处理命令队列
	t.ProcessCommandQueue = function ()
		local queue = t.command_queue;
		local count = #queue;
		if count == 0 then
			return false;
		end
		local command = t.PeekCommand();
		local success = t.ProcessCommand(command);
		if success then
			t.DequeueCommand();
			return true;
		end
		return false;
	end;

	-- 处理指令
	t.ProcessCommand = function (command)
		local type = command.type;
		if type == CommandType.Run then
			return t.ProcessRunCommand(command);
		elseif type == CommandType.Skill then
			return t.ProcessSkillCommand(command);
		end
		return false;
	end;

	-- 处理
	t.ProcessRunCommand = function (command)
		local state = t.Run;
		if state == nil then
			return false;
		end
		local move_data = state.move_data;
		local start_time = TimerManager.GetUnityTime();
		local path = command.path;
		local time = command.time;
		local server_start_time = command.server_start_time;
		local server_current_time = TimerManager.GetServerNowMillSecond();
		if server_current_time > server_start_time then
			server_current_time = server_start_time;
		end
		local ds = t.ds;
		local pos_x = ds.pos_x;
		local pos_y = ds.pos_y;
		local pos_z = ds.pos_z;
		local dir_x = ds.dir_x;
		local dir_y = ds.dir_y;
		local dir_z = ds.dir_z;
		local move_speed = ds.move_speed;
		local class = Fight.GetClass(ds);
		local move_data = class.Run.move_data;
		local start_time = TimerManager.GetUnityTime();
		local client_path, client_time = Fight.ConvertServerPathToClient(pos_x, pos_y, pos_z, path, time, start_time, server_start_time);
		move_data.SetPath(start_time, server_current_time, dir_x, dir_y, dir_z, client_path, client_time, move_speed);
		local state = class.Run;
		state.idle = command.idle;
		Fight.DoJumpState(ds, SourceType.Network, "Run", 0);
		return true 
	end;

	-- 处理技能指令
	t.ProcessSkillCommand = function (command)
		local role_type = ds["role_type"];
		-- print(role_type)
		-- 普通小怪
		if role_type == RoleType.Monster or role_type == RoleType.EliteMonster or role_type == RoleType.FubenMonster or role_type == RoleType.FubenEliteMonster then
			local skill_id = command.skill_id;
			local target_id = command.target_id;
			local state = t.Attack1;
			local skill_data = state.skill_data;
			skill_data.skill_id = skill_id;
			skill_data.target_id = target_id;
			Fight.DoJumpState(ds, SourceType.Network, "Attack1", 0);
			return true;
		elseif role_type == RoleType.OtherPlayer or role_type == RoleType.OfflinePlayer 
			or role_type == RoleType.WorldBoss 
			or role_type == RoleType.FubenBoss 
			or role_type == RoleType.GuideNpc then
			local skill_id = command.skill_id;
			local target_id = command.target_id;
			local id = ds.id;
			local class = Fight.GetClass(ds);
			local skill = class.GetSkillById(skill_id);
			if skill == nil then
				error(string.format("[%s] skill not found: id=%d, skill_id=%d, target_id=%d", ds.career, id, skill_id, target_id));
				return;
			end
			local skill_info = skill.info;
			local state = t[skill_info.state];
			local skill_data = state.skill_data;
			if skill_data == nil then
				error(string.format("role_type=%d does not has state(%s) !!!", role_type, skill_info.state));
			else
				skill_data.skill_id = skill_id;
				skill_data.target_id = target_id;
			end
			Fight.DoJumpState(ds, SourceType.Network, skill_info.state, 0);
			return true;
		else
		end
		return true;
	end;


	--------------------------------------------------------------------
	-- 解析数据
	-- msg 从网络过来的玩家数据
	-- 通过解析保存到角色的数据集中
	--------------------------------------------------------------------


	-- 解析玩家信息, 用于从 myInfo 中读取玩家数据
	t.ParseRoleInfo = function (ds, info)
		for k, v in pairs(info) do
			ds[k] = v;
		end
	end;

	-- 解析角色信息(用于创建怪物， NPC， 其他玩家等除玩家外的角色)
    t.ParseData = function (ds, msg)
    	for k, v in pairs(msg) do
    		local name = k;
    		local value = v;

    		if name == "pos" then
    			ds["pos_x"] = value[1];
    			ds["pos_y"] = value[2];
    			ds["pos_z"] = value[3];
    		elseif name == "dir" then
    			ds["dir_x"] = value[1];
    			ds["dir_y"] = value[2];
    			ds["dir_z"] = value[3];
    		elseif name == "name" or name == "style" or name == "legion_name" then
    			ds[name] = client.tools.ensureString(value);
    		elseif name == "equipment" then
    			ds[name] = DataCache.ParseEquipment(value);
    		elseif name == "ability" then
    			local abilities = {};
    			-- 其他玩家技能，value 结构 [[id1, level1, cast_time1], [id2, level2, cast_time2], ..., [idn, leveln, cast_timen]]
    			-- 怪物技能, value 结构 [id1, id2, ..., idn]
    			for j = 1, #value do
    				local item = value[j];
    				if type(item) == "table" then
	    				local ability = {};
	    				ability.id = item[1];
	    				ability.level = item[2];
	    				ability.cast_time = item[3];
	    				abilities[#abilities + 1] = ability;
	    			else
	    				local ability = {};
	    				ability.id = item;
	    				ability.level = 1;
	    				ability.cast_time = 0;
	    				abilities[#abilities + 1] = ability;
	    			end
    			end
    			ds[name] = abilities;
    		else
    			-- 如下名字走这里
    			-- "fightHPRecover"
    			-- "attackReduceP"
    			-- "fightPoint"
    			-- "energy_stone"
    			-- "grey_name_time"
    			-- "kill_value"
    			-- "freeHPRecover"
    			-- "imba_state"
    			-- "exp"
    			-- "energy"
    			-- "id"
    			-- "sid"
    			-- "camp"
    			-- "style_scale"
    			-- "level"
    			-- "hp"
    			-- "maxHP"
    			-- "sleep_time"
    			-- "obstacle_mask"
    			-- "career"
    			-- "sex"
    			-- "curr_area_PKMode"
    			-- "defenseReduceP"
    			-- "maxEnergy"
    			-- "tiredValue"
    			-- "damageAmplifyP"
    			-- "damageResistP"
    			-- "role_uid"
    			ds[name] = value;
    		end
    	end
    end;




    -- 销毁
    t.OnDestroy = function (ds)
        AvatarCache.RemoveAvatar(ds);
    end;


    ------------------------------------------------------------------
    -- 角色攻击判断
    ------------------------------------------------------------------

    -------------------------
    -- 攻击我的 
    -------------------------

    t.avatars_attacking_me = {};

    -- 获取攻击我的角色ID列表
    t.GetAvatarsAttackingMe = function ()
    	return t.avatars_attacking_me;
    end;

    -- 判断角色是否正在攻击我
    t.IsAvatarAttackingMe = function (id)
    	local list = t.avatars_attacking_me;
    	for i = 1, #list do
    		if list[i].id == id then
    			return true;
    		end
    	end
    	return false;
    end;

    -- 存在攻击我的角色
    t.HasAvatarAttackingMe = function ()
    	local list = t.avatars_attacking_me;
    	return #list > 0;
    end

    -- 获取攻击我的角色
    t.GetAvatarAttackingMe = function (id)
    	local list = t.avatars_attacking_me;
    	for i = 1, #list do
    		if list[i].id == id then
    			return list[i];
    		end
    	end
    	return nil;
    end;

    -- 添加攻击我的角色
    t.AddAvatarAttackingMe = function (id)
    	local info = t.GetAvatarAttackingMe(id);
    	if info ~= nil then
    		info.time = TimerManager.GetUnityTime();
    		return;
    	end
    	local list = t.avatars_attacking_me;
    	local info = {};
    	info.id = id;
    	info.time = TimerManager.GetUnityTime();
    	list[#list + 1] = info;
	end;

	-- 删除攻击我的角色
	t.RemoveAvatarAttackingMe = function (id)
		local list = t.avatars_attacking_me;
    	for i = 1, #list do
    		if list[i].id == id then
    			for k = i, #list - 1 do
    				list[k] = list[k + 1];
    			end
    			list[#list] = nil;
    			break;
    		end
    	end
	end;

	-- 清空所有攻击我的角色
	t.RemoveAllAvatarsAttackingMe = function ()
		local list = t.avatars_attacking_me;
		local count = #list;
		for i = 1, count do
			list[i] = nil;
		end
	end;

	-- 更新删除攻击我的角色
	t.UpdateAvatarsAttackingMe = function ()
        
        local now = TimerManager.GetUnityTime();
		local del_list = {};
        local list = t.GetAvatarsAttackingMe();
        for i = 1, #list do
            local info = list[i];
            local deltaTime = now - info.time;
            if deltaTime > 2.0 then
                del_list[#del_list + 1] = info.id;
            end
        end
        for i = 1, #del_list do
        	t.RemoveAvatarAttackingMe(del_list[i]);
        end

	end

    -------------------------
    -- 被我攻击的 
    -------------------------

    t.avatars_attacked_by_me = {};

    -- 获取我攻击的角色ID列表
    t.GetAvatarAttackedByMe = function ()
    	local list = t.avatars_attacked_by_me;
    	if #list == 0 then
    		return nil;
    	end
    	return list[1];
    end;

    -- 判断角色是否正被我攻击
    t.IsAvatarAttackedByMe = function (id)
    	local list = t.avatars_attacked_by_me;
    	for i = 1, #list do
    		if list[i].id == id then
    			return true;
    		end
    	end
    	return false;
    end;

    -- 存在被我攻击的角色
    t.HasAvatarAttackedByMe = function ()
    	local list = t.avatars_attacked_by_me;
    	return #list > 0;
    end;

    -- 添加被我攻击的角色
    t.AddAvatarAttackedByMe = function (id)
    	local info = t.GetAvatarAttackedByMe();
    	if info ~= nil then
    		info.time = TimerManager.GetUnityTime();
    		return;
    	end
    	t.RemoveAllAvatarsAttackedByMe();
    	local list = t.avatars_attacked_by_me;
    	info = {};
    	info.id = id;
    	info.time = TimerManager.GetUnityTime();
    	list[#list + 1] = info;
	end;

	-- 删除被我攻击的角色
	t.RemoveAvatarAttackedByMe = function (id)
		local list = t.avatars_attacked_by_me;
    	for i = 1, #list do
    		if list[i].id == id then
    			for k = i, #list - 1 do
    				list[k] = list[k + 1];
    			end
    			list[#list] = nil;
    			break;
    		end
    	end
	end;

	-- 清空所有被我攻击的角色
	t.RemoveAllAvatarsAttackedByMe = function ()
		local list = t.avatars_attacked_by_me;
		local count = #list;
		for i = 1, count do
			list[i] = nil;
		end
	end;

	-- 更新删除被我攻击的角色
	t.UpdateAvatarsAttackedByMe = function ()
		
        local info = t.GetAvatarAttackedByMe();
        if info == nil then
        	return;
        end
        local now = TimerManager.GetUnityTime();
        local deltaTime = now - info.time;
        if deltaTime > 2.0 then
            t.RemoveAvatarAttackedByMe(info.id);
        end
	end;
	

	---------------------------------------------------------------------------
	-- 自动攻击
	---------------------------------------------------------------------------

    t.AutoAttack = function (ds, state, last_target_id)

    	-- 如果当前状态发起源不是玩家或者自动攻击，则不发动自动攻击
    	if state.source ~= SourceType.Player and state.source ~= SourceType.AutoAttack then
    		return false;
    	end

        -- 目标已经丢失
        local target_is_lost = Fight.IsTargetLost(last_target_id);
        -- 目标已经死亡
        local target_is_dead = Fight.IsTargetDead(last_target_id);
        -- 当前要攻击的目标
        local target = nil;
        -- 当前目标作为攻击目标
        if target_is_lost or target_is_dead then
            return false;
        else
            target = AvatarCache.GetAvatar(last_target_id);
        end

        -- 没有当前目标
        if target == nil then
            return false;
        else

        	local current = TargetSelecter.current;

        	if current == nil or current.id ~= target.id then
        		return false;
        	end

            -- 普攻
            local attack_skill_data = Fight.GetAutoFightAttackSkillData(ds, last_target_id, last_target_id);
            if attack_skill_data ~= nil then
                return Fight.TryJumpSkillById(ds, attack_skill_data.id, SourceType.AutoAttack);
            end
            return false;
        end
    end;


	----------------------------------------------------------------------------
	-- 玩家属性判断
	----------------------------------------------------------------------------


    -- 是否已经死亡
    t.IsDead = function ()
        local hp = ds["hp"];
        if hp <= 0 then
            return true;
        end
        return false;
    end

    -- 是否处于野外PK模式
    t.IsWildPkState = function ()
    	local ds = t.ds;
		local pk_mode = ds["pk_mode"];
		if pk_mode == "quanti" then
			return true;
		else
			return false;
		end
	end

	-- 是否处于魔龙岛PK模式
	t.IsMolongdaoPkState = function ()
		if DataCache.scene_sid == 20000003 then
    		if DataCache.pk_mode == "fangwei" then
    			return false;
    		else
    			return true;
    		end
    	else
    		return false;
    	end
	end

    -- 是否处于PK模式
    t.IsPkState = function ()
    	return t.IsWildPkState() or t.IsMolongdaoPkState();
	end

    -- 是否处于行凶状态
    t.IsKillState = function ()
    	local ds = t.ds;
    	local grey_name_time = ds["grey_name_time"];
    	return grey_name_time > 0;
    end

    -- 是否是红名
    t.IsRedName = function ()
    	local ds = t.ds;
		local kill_value = ds.kill_value;
		local grey_name_time = ds.grey_name_time;
		return kill_value > 100 or grey_name_time > 0;
	end

	-- 是否白名
	t.IsWhiteName = function ()
    	return not t.IsRedName() and not t.IsKillState();
	end

    -- 是否是无敌
    t.IsImbaState = function ()
        local ds = t.ds;
        local imba_state = ds["imba_state"];
        if imba_state ~= nil then
        	return imba_state > 0;
        end
        return false;
    end

    -- 是否等级小于保护等级
    t.IsBelowProtectLevel = function ()
        local ds = t.ds;
        local level = ds["level"];
        return level < 30;
    end

    -- 是否处于安全区域
    t.IsWithinSafeArea = function ()
    	return false;
	end

    -- 判断是否属于某个队伍
    t.IsTeamOf = function (team_uid)
    	if team_uid == 0 then
    		return false;
    	end
    	local ds = t.ds;
    	local my_team_uid = ds["team_uid"];
    	return my_team_uid == team_uid;
	end

	-- 判断是否是同一公会
	t.IsLegionOf = function (legion_uid)
		if legion_uid == 0 then
			return false;
		end
		local ds = t.ds;
		local my_legion_uid = ds["legion_uid"];
		return my_legion_uid == legion_uid;
	end

	-- 判断目标当前是否处于某个圆形区域
	t.IsWithinCircle = function (center_x, center_y, center_z, radius)
		local ds = t.ds;
		local pos_x = ds["pos_x"];
		local pos_y = ds["pos_y"];
		local pos_z = ds["pos_z"];
		local dx = pos_x - center_x;
		local dy = pos_y - center_y;
		local dz = pos_z - center_z;
		return dx * dx + dz * dz <= radius * radius;
	end

	-- 判断是否属于某一类角色
	t.IsRoleTypeOf = function (role_type)
		local ds = t.ds;
		local my_role_type = ds["role_type"];
		return my_role_type == role_type;
	end

    return t;
end


-- 计算瞬移路径
function Fight.CalcTeleportPath(pos_x, pos_y, pos_z, dst_x, dst_y, dst_z, path)
	return uFacadeUtility.CalcTeleportPath(pos_x, pos_y, pos_z, dst_x, dst_y, dst_z, 0.1, path);
end


-- 计算冲锋路径
function Fight.CalcChargePath(pos_x, pos_y, pos_z, dst_x, dst_y, dst_z, min_distance, path)
	Fight.ClearPath(path);
	return uFacadeUtility.CalcChasePath(pos_x, pos_y, pos_z, dst_x, dst_y, dst_z, min_distance, path);
end


-- 计算追击路径
function Fight.CalcChasePath(pos_x, pos_y, pos_z, dst_x, dst_y, dst_z, min_distance, path)
	Fight.ClearPath(path);
	return uFacadeUtility.CalcChasePath(pos_x, pos_y, pos_z, dst_x, dst_y, dst_z, min_distance, path);
end

-- 计算从当前位置到挂机随机半径内随机一点间的移动路径
function Fight.CalcAutoFightReturnPath(pos_x, pos_y, pos_z, origin_x, origin_y, origin_z, random_move_radius, path)
	Fight.ClearPath(path);
	return uFacadeUtility.CalcAutoFightReturnPath(pos_x, pos_y, pos_z, origin_x, origin_y, origin_z, random_move_radius, path);
end


-- 计算路径
function Fight.CalcPath(pos_x, pos_y, pos_z, dst_x, dst_y, dst_z, path)
	Fight.ClearPath(path);
	return uFacadeUtility.CalcPath(pos_x, pos_y, pos_z, dst_x, dst_y, dst_z, path);
end

-- 清空路径
function Fight.ClearPath(path)
	for i = 1, #path do
		path[i] = nil;
	end
end

-- 清空时刻
function Fight.ClearTime(time)
	for i = 1, #time do
		time[i] = nil;
	end
end


function Fight.PrintPos(ds)
	local pos_x = ds.pos_x;
	local pos_y = ds.pos_y;
	local pos_z = ds.pos_z;
	--print(string.format("pos: {%f, %f, %f}", pos_x, pos_y, pos_z));
end

-- 打印路径
function Fight.PrintPath(path)
	local s = "";
	local length = #path / 3;
	for i = 1, length do
		if i > 1 then
			s = s .. ">";
		end
		local x = path[3 * i - 2];
		local y = path[3 * i - 1];
		local z = path[3 * i];
		s = s .. string.format("{%f, %f}", x, z);
	end
	--print(s);
end



-- 计算路径位置
-- pos_x, pos_y, pos_z 是当前位置
-- dir_x, dir_y, dir_z 是当前方向
-- path 是当前路径
-- index 是当前路径线段的索引，从 1 开始
-- move_speed 是移动速度
-- delta_time 是距离上一次调用 CalcMovePos 的时刻经过的时间
function Fight.CalcMovePos(pos_x, pos_y, pos_z, dir_x, dir_y, dir_z, path, index, move_speed, delta_time)
	local length = #path / 3;
	if length == 0 then
		return pos_x, pos_y, pos_z, dir_x, dir_y, dir_z, 1, true;
	end
	if length == 1 then
		return path[1], path[2], path[3], dir_x, dir_y, dir_z, 1, true;
	end
	local proceed = move_speed * delta_time;
	while proceed > 0 do
		-- 已经到达最后一个线段的终点了
		if index >= length then
			return path[3 * length - 2], path[3 * length - 1], path[3 * length], dir_x, dir_y, dir_z, length, true;
		end
		local st_x = path[3 * index - 2];
		local st_y = path[3 * index - 1];
		local st_z = path[3 * index];
		local en_x = path[3 * index + 1];
		local en_y = path[3 * index + 2];
		local en_z = path[3 * index + 3];
		local dx = en_x - st_x;
		local dy = en_y - st_y;
		local dz = en_z - st_z;
		-- 如果这个线段退化成了点，则跳过
		if dx == 0 and dz == 0 then
			index = index + 1;
		else
			-- 计算距离
			local dist = math.sqrt(dx * dx + dz * dz);
			-- 前进的距离大于两点间的距离
			if proceed > dist then
				-- 计算方向
				dir_x = dx / dist;
				dir_y = 0;
				dir_z = dz / dist;
				-- 前进 dist
				proceed = proceed - dist;
				-- 开始走下一个线段
				index = index + 1;
			else
				-- 在本线段的某个点就停止, 计算停止的位置
				local t = math.min(proceed / dist, 1);
				-- 如果刚好停在线段的终点, 下一次走下一个线段
				if t >= 1 then
					index = index + 1;
				end
				-- 前进距离清零
				proceed = 0;
				-- 计算方向
				dir_x = dx / dist;
				dir_y = 0;
				dir_z = dz / dist;
				-- 计算位置
				return st_x + dx * t, pos_y, st_z + dz * t, dir_x, dir_y, dir_z, index, false;
			end
		end
	end
	return pos_x, pos_y, pos_z, dir_x, dir_y, dir_z, index, true;
end

-- 发起类型
SourceType = {};
SourceType.Player = 1;
SourceType.AutoFight = 2;
SourceType.AutoAttack = 3;
SourceType.Network = 4;
SourceType.System = 5;

function Fight.CrossFightIdle(ds, var_name, start_value, value, speed)
	local curr_state_name = ds.curr_state_name;
	if curr_state_name == "Idle" then
		local state = Fight.GetState(ds, "Idle");
		local cross_data = state.cross_data;
		local start_time = ds.curr_time;
		cross_data.Load(ds, start_time, var_name, start_value, value, speed);
	else
		uFacadeUtility.SetAnimatorFloat(ds.id, "SwitchFight", 0.0);
	end
end


-- 创建动作过渡数据
function Fight.CreateCrossData()
	local cross_data = {
		start_time = 0.0,			-- 开始变化的时间
		last_time = 0.0,			-- 上次更新的时间
		finished = true,			-- 变化是否已经完成
		var_name = "SwitchFight",	-- Float 变量名
		start_value = 0.0,			-- 开始时的变量值
		value = 1.0,				-- 目标值
		speed = 1.0,				-- 从当前值变化到目标值的速度，每秒变化多少
	};
	cross_data.Load = function (ds, start_time, var_name, start_value, value, speed)
		cross_data.start_time = start_time;
		cross_data.last_time = start_time;
		cross_data.finished = false;
		cross_data.var_name = var_name;
		local id = ds.id;
		cross_data.start_value = start_value; -- uFacadeUtility.GetAnimatorFloat(id, var_name);
		cross_data.value = value;
		cross_data.speed = speed;
	end;
	-- 更新值
	cross_data.UpdateValue = function (ds)
		-- 已经完成
		if cross_data.finished then
			return;
		end
		-- 上次更新时间
		local last_time = cross_data.last_time;
		-- 当前时间
		local curr_time = ds.curr_time;
		-- 记录修改值的时间
		cross_data.last_time = curr_time;
		-- 计算经过的时间
		local delta_time = curr_time - last_time;
		-- 获取 id
		local id = ds.id;
		-- 获取当前值
		local value = uFacadeUtility.GetAnimatorFloat(id, cross_data.var_name);
		-- 如果已经变化到目标值
		if value == cross_data.value then
			cross_data.finished = true;
		elseif value < cross_data.value then
			-- 值要变大
			local delta_value = cross_data.speed * delta_time;
			local new_value = value + delta_value;
			if new_value > cross_data.value then
				new_value = cross_data.value;
			end
			uFacadeUtility.SetAnimatorFloat(id, cross_data.var_name, new_value);
			if new_value == cross_data.value then
				cross_data.finished = true;
			end
		else
			-- 值要变小
			local delta_value = cross_data.speed * delta_time;
			local new_value = value - delta_value;
			if new_value < cross_data.value then
				new_value = cross_data.value;
			end
			uFacadeUtility.SetAnimatorFloat(id, cross_data.var_name, new_value);
			if new_value == cross_data.value then
				cross_data.finished = true;
			end
		end
	end;
	return cross_data;
end

-- 创建攻击数据
function Fight.CreateSkillData()
	local skill_data = {
		skill_id = 0;
		target_id = 0;
		target_x = 0;
		target_y = 0;
		target_z = 0;
	};
	return skill_data;
end

-- 创建移动数据
function Fight.CreateMoveData()

	-- 移动数据
    local move_data = {
        path = {},			-- 路径点, 结构 [x1, y1, z1, x2, y2, z2, ..., xn, yn, zn]
        time = {},			-- 路径点时间, 结构 [t1, t2, ..., tn]
        server_start_time = 0,	-- 路径开始的服务端时间
        start_time = 0,		-- 路径开始走的时间，这个时间不一定等于第一个位置点 time 的时间, 单位秒
        last_time = 0,		-- 上次更新时间, 每次修改路径状态，都要记录时间, 单位秒
        arrived = false,	-- 路径是否已经走完
        pos_x = 0,			-- 当前位置
        pos_y = 0,			
        pos_z = 0,
        dir_x = 0,			-- 当前方向
        dir_y = 0,
        dir_z = 1,
        src_x = 0,			-- 起点位置
        src_y = 0,
        src_z = 0,
        dst_x = 0,			-- 寻路位置
        dst_y = 0,
        dst_z = 0,
        goal_x = 0,			-- 真实终点位置
        goal_y = 0,
        goal_z = 0,
        move_speed = 0,		-- 移动速度
    };


    function move_data.RotateToFirstPos(ds)
    	local pos_x = ds.pos_x;
    	local pos_y = ds.pos_y;
    	local pos_z = ds.pos_z;
    	local path = move_data.path;
    	local count = #path / 3;
    	for i = 1, count do
    		local x, y, z = move_data.GetPos(i);
    		if x ~= pos_x or z ~= pos_z then
    			Fight.DoRotateToPos(ds, x, y, z);
    			break;
    		end
    	end
    end


    -- 从另一个 move_data 复制
    function move_data.CopyFrom(other)
    	move_data.ClearPath();
    	move_data.ClearTime();
    	local path = move_data.path;
    	local other_path = other.path;
    	for i = 1, #other_path do
    		path[i] = other_path[i];
    	end
    	local time = move_data.time;
    	local other_time = other.time;
    	for i = 1, #other_time do
    		time[i] = other_time[i];
    	end
    	move_data.server_start_time = other_time.server_start_time;
    	move_data.start_time = other_time.start_time;	-- 路径开始走的时间，这个时间不一定等于第一个位置点 time 的时间, 单位秒
        move_data.last_time = other_time.last_time;		-- 上次更新时间, 每次修改路径状态，都要记录时间, 单位秒
        move_data.arrived = false;						-- 路径是否已经走完
        move_data.pos_x = other_time.pos_x;				-- 当前位置
        move_data.pos_y = other_time.pos_y;			
        move_data.pos_z = other_time.pos_z;
        move_data.dir_x = other_time.dir_x;				-- 当前方向
        move_data.dir_y = other_time.dir_y;
        move_data.dir_z = other_time.dir_z;
        move_data.src_x = other_time.src_x;				-- 起点位置
        move_data.src_y = other_time.src_y;
        move_data.src_z = other_time.src_z;
        move_data.dst_x = other_time.dst_x;				-- 寻路位置
        move_data.dst_y = other_time.dst_y;
        move_data.dst_z = other_time.dst_z;
        move_data.goal_x = other_time.goal_x;			-- 真实终点位置
        move_data.goal_y = other_time.goal_y;
        move_data.goal_z = other_time.goal_z;
        move_data.move_speed = other_time.move_speed;	-- 移动速度
    end


    function move_data.ClearTime()
    	local time_arr = move_data.time;
    	for i = 1, #time_arr do
    		time_arr[i] = nil;
    	end
    end

    function move_data.GetPathLength()
    	local path = move_data.path;
    	local length = #path;
    	return length / 3;
    end


    -- 合并路径
    function move_data.MergePath(curr_time, append_path, append_time, move_speed)
    	-- 获取时间
    	local last_pos_x = move_data.goal_x;
    	local last_pos_y = move_data.goal_y;
    	local last_pos_z = move_data.goal_z;
    	local dir_x = move_data.dir_x;
    	local dir_y = move_data.dir_y;
    	local dir_z = move_data.dir_z;
		local first_pos_x = append_path[1];
		local first_pos_y = append_path[2];
		local first_pos_z = append_path[3];

		local new_time = {};
		local new_path = {};
		-- 获取前面的路径
		local i, j = move_data.BinarySearch(curr_time);

		if i < j then
			local pos_x = move_data.pos_x;
			local pos_y = move_data.pos_y;
			local pos_z = move_data.pos_z;
			local ix, iy, iz = move_data.GetPos(i);
			local jx, jy, jz = move_data.GetPos(j);
			local kx = jx - ix;
			local ky = jy - iy;
			local kz = jz - iz;
			local px = pos_x - ix;
			local py = pos_y - iy;
			local pz = pos_z - iz;
			local sq1 = px * px + pz * pz;
			local sq2 = kx * kx + kz * kz;
			local t = math.sqrt(sq1 / sq2);
			if t > 1 then
				t = 1;
			end
			if t < 1 then
				local fx = ix + kx * t;
				local fy = iy;
				local fz = iz + kz * t;
				local time = move_data.time;
				for k = j, #time do
					local path_x, path_y, path_z = move_data.GetPos(k);
					new_path[#new_path + 1] = path_x;
					new_path[#new_path + 1] = path_y;
					new_path[#new_path + 1] = path_z;
					new_time[#new_time + 1] = time[k];
				end
			else
				local time = move_data.time;
				for k = j, #time do
					local path_x, path_y, path_z = move_data.GetPos(k);
					new_path[#new_path + 1] = path_x;
					new_path[#new_path + 1] = path_y;
					new_path[#new_path + 1] = path_z;
					new_time[#new_time + 1] = time[k];
				end
			end
		else
			if j ~= 0 then
				local time = move_data.time;
				for k = j, #time do
					local path_x, path_y, path_z = move_data.GetPos(k);
					new_path[#new_path + 1] = path_x;
					new_path[#new_path + 1] = path_y;
					new_path[#new_path + 1] = path_z;
					new_time[#new_time + 1] = time[k];
				end
			end
		end

		-- 添加后续路径
		local startIndex = #new_path / 3;
		local pathIndex = #new_path;   -- 9
		for i = 2, #append_time do
			local index = 3 * i;      -- 6
			local curr_pos_x = append_path[index - 2];  -- 4
			local curr_pos_y = append_path[index - 1];  -- 5
			local curr_pos_z = append_path[index];      -- 6
			new_path[pathIndex + index - 5] = curr_pos_x;  -- 10
			new_path[pathIndex + index - 4] = curr_pos_y;  -- 11
			new_path[pathIndex + index - 3] = curr_pos_z;  -- 12
			local server_delta_time = append_time[i] - append_time[i - 1];
			local client_delta_time = server_delta_time * 0.001;
			new_time[startIndex + i - 1] = new_time[startIndex + i - 2] + client_delta_time;
		end

		move_data.ClearPath();
		move_data.ClearTime()
		move_data.arrived = false;
		move_data.start_time = curr_time;
		for i = 1, #new_time do
			move_data.time[i] = new_time[i];
		end
		for i = 1, #new_path do
			move_data.path[i] = new_path[i];
		end
		move_data.start_time = curr_time;
		move_data.last_time = curr_time;
		move_data.arrived = false;
		first_pos_x = move_data.path[1];
		first_pos_y = move_data.path[2];
		first_pos_z = move_data.path[3];
		last_pos_x = move_data.path[#move_data.path - 2];
		last_pos_y = move_data.path[#move_data.path - 1];
		last_pos_z = move_data.path[#move_data.path];
		move_data.src_x = first_pos_x;
		move_data.src_y = first_pos_y;
		move_data.src_z = first_pos_z;
		move_data.dst_x = last_pos_x;
		move_data.dst_y = last_pos_y;
		move_data.dst_z = last_pos_z;
		move_data.goal_x = last_pos_x;
		move_data.goal_y = last_pos_y;
		move_data.goal_z = last_pos_z;
		move_data.move_speed = move_speed;

		-- move_data.Print();
    end

    -- 移动路径开始时间
    function move_data.PromoteStartTime(new_start_time)
    	local start_time = move_data.start_time;
    	local time = move_data.time;
    	local length = #time;
    	local length_plus_one = length + 1;
    	for i = 1, length do
    		time[i] = time[i] - start_time + new_start_time;
    	end
    	move_data.last_time = move_data.last_time - start_time + new_start_time;
    	move_data.start_time = new_start_time;
    end

    -- 根据速度计算时间
    function move_data.RecaculateTime(start_time, move_speed)
    	move_data.ClearTime();
    	local time = move_data.time;
    	local length = move_data.GetPathLength();
    	local length_minus_one = length - 1;
    	time[1] = start_time;
    	for i = 1, length_minus_one do
    		local p1_x, p1_y, p1_z = move_data.GetPos(i);
    		local p2_x, p2_y, p2_z = move_data.GetPos(i + 1);
    		local dx = p2_x - p1_x;
    		local dy = p2_y - p1_y;
    		local dz = p2_z - p1_z;
    		local dist = math.sqrt(dx * dx + dz * dz);
    		time[i + 1] = time[i] + dist / move_speed;
    	end
    	move_data.move_speed = move_speed;
    end

    -- 更新位置
    function move_data.UpdatePosByTime(ds, curr_time)
    	local goal_x = move_data.goal_x;
    	local goal_y = move_data.goal_y;
    	local goal_z = move_data.goal_z;
		local pos_x, pos_y, pos_z, dir_x, dir_y, dir_z = move_data.CalcPosByTime(ds, curr_time);
		move_data.pos_x = pos_x;
		move_data.pos_y = pos_y;
		move_data.pos_z = pos_z;
		move_data.dir_x = dir_x;
		move_data.dir_y = dir_y;
		move_data.dir_z = dir_z;
		move_data.last_time = curr_time;
		if pos_x == goal_x and pos_z == goal_z then
			move_data.arrived = true;
		end
	end


    -- index 从 1 开始编号
    function move_data.GetTime(index)
    	local time = move_data.time;
    	return time[index];
    end

    -- index 从 1 开始编号
    function move_data.GetPos(index)
    	local path = move_data.path;
    	local i = 3 * (index - 1);
    	local pos_x = path[i + 1];
    	local pos_y = path[i + 2];
    	local pos_z = path[i + 3];
    	return pos_x, pos_y, pos_z;
    end


    -- 二分查找
    function move_data.BinarySearch(curr_time)
    	-- 获取时间
    	local time_arr = move_data.time;
    	local time_arr_count = #time_arr;
    	if time_arr_count == 0 then
    		return 0, 0;
    	end
    	if time_arr_count == 1 then
    		return 1, 1;
    	end
    	if curr_time >= time_arr[time_arr_count] then
    		return time_arr_count, time_arr_count;
    	end
    	-- i == 1
    	local i = 1;
    	-- j == n
    	local j = time_arr_count;
    	-- 二分查找
    	while i + 1 < j do
    		local m = math.floor((i + j) * 0.5 + 0.1);  -- +0.1 为了防止 math.floor 错误计算
    		local tm = time_arr[m];
    		-- 时间等于中间位置时间
    		if tm == curr_time then
    			i = m;
    			j = m;
    			break;
    		else
    			-- 如果时间大于中间位置时间，改变查找区间为 [m, j]
	    		if curr_time > tm then
	    			i = m;
	    		-- 如果时间小于中间位置时间，改变查找区间为 [i, m]
	    		else
	    			j = m;
	    		end	
    		end
    	end
    	return i, j;
    end

    -- path 和 time 至少要有两个点, 而且 path 和 time 的个数必须一致
    -- path 结构 [p1.x, p1.y, p1.z, p2.x, p2.y, p2.z, ..., pn.x, pn.y, pn.z ]
    -- time 结构 [t1, t2, ..., tn]
    -- 如果 path 点的数量是 0，则返回 false, 0, 0, 0
    -- 如果 path 点的数量是 1, 则返回 true, p1.x, p1.y, p1.z
    function move_data.CalcPosByTime(ds, curr_time)
    	local time_arr = move_data.time;
    	local time_arr_count = #time_arr;
    	if time_arr_count == 0 then
    		return move_data.pos_x, move_data.pos_y, move_data.pos_z, ds.dir_x, ds.dir_y, ds.dir_z;
    	end
    	if curr_time >= time_arr[time_arr_count] then
    		if time_arr_count == 1 then
				local p1_x, p1_y, p1_z = move_data.GetPos(time_arr_count);
				return p1_x, p1_y, p1_z, ds.dir_x, ds.dir_y, ds.dir_z;
			else
				local p1_x, p1_y, p1_z = move_data.GetPos(time_arr_count - 1);
				local p2_x, p2_y, p2_z = move_data.GetPos(time_arr_count);
				local dir_x = p2_x - p1_x;
				local dir_y = 0;
				local dir_z = p2_z - p1_z;
				local dist = math.sqrt(dir_x * dir_x + dir_z * dir_z);
				dir_x = dir_x / dist;
				dir_z = dir_z / dist;
				return p2_x, p2_y, p2_z, dir_x, dir_y, dir_z;
			end
    	end
    	-- 二分查找出时间点位置
    	local i, j = move_data.BinarySearch(curr_time);
    	if i == j then
    		if i == 1 then

    			if time_arr_count == 1 then
    				local p1_x, p1_y, p1_z = move_data.GetPos(1);
    				return p1_x, p1_y, p1_z, ds.dir_x, ds.dir_y, ds.dir_z;
    			else
    				local p1_x, p1_y, p1_z = move_data.GetPos(1);
    				local p2_x, p2_y, p2_z = move_data.GetPos(2);
    				local dir_x = p2_x - p1_x;
    				local dir_y = 0;
    				local dir_z = p2_z - p1_z;
    				local dist = math.sqrt(dir_x * dir_x + dir_z * dir_z);
    				dir_x = dir_x / dist;
    				dir_z = dir_z / dist;
    				return p1_x, p1_y, p1_z, dir_x, dir_y, dir_z;
    			end
    		end
    		i = i - 1;
    	end
    	local time = move_data.time;
		local t1 = move_data.GetTime(i);
    	local t2 = move_data.GetTime(j);
    	local p1_x, p1_y, p1_z = move_data.GetPos(i);
    	local p2_x, p2_y, p2_z = move_data.GetPos(j);
    	local t = (curr_time - t1) / (t2 - t1);
    	if t > 1 then
    		t = 1;
    	end
		local dx = p2_x - p1_x;
    	local dy = 0;
    	local dz = p2_z - p1_z;
    	local dist = math.sqrt(dx * dx + dz * dz);
    	local pos_x = p1_x + dx * t;
    	local pos_y = p1_y;
    	local pos_z = p1_z + dz * t;
		local dir_x = dx / dist;
		local dir_y = 0;
		local dir_z = dz / dist;
    	return pos_x, pos_y, pos_z, dir_x, dir_y, dir_z;
    end

    -- 加载模型路径
    -- 用于角色模型的路径加载，加载后的路径不会进行路径的导航
    function move_data.LoadModelPath(start_time, pos_x, pos_y, pos_z, dir_x, dir_y, dir_z, dst_x, dst_y, dst_z, move_speed)
		move_data.Clear();
		local path = move_data.path;
		path[1] = pos_x;
		path[2] = pos_y;
		path[3] = pos_z;
		path[4] = dst_x;
		path[5] = dst_y;
		path[6] = dst_z;
	    move_data.index = 1;
	    move_data.arrived = false;
	    move_data.server_start_time = TimerManager.GetServerNowMillSecond();
	    move_data.start_time = start_time;
	    move_data.last_time = start_time;
	    move_data.pos_x = pos_x;	-- 位置
	    move_data.pos_y = pos_y;
	    move_data.pos_z = pos_z;
	    move_data.dir_x = dir_x;	-- 方向
	    move_data.dir_y = dir_y;
	    move_data.dir_z = dir_z;
	    move_data.src_x = pos_x;
	    move_data.src_y = pos_y;
	    move_data.src_z = pos_z;
	    move_data.dst_x = dst_x;
	    move_data.dst_y = dst_y;
	    move_data.dst_z = dst_z;
	    move_data.goal_x = dst_x;	-- 目标位置
    	move_data.goal_y = dst_y;
    	move_data.goal_z = dst_z;
	    -- 重新计算时间
	    move_data.RecaculateTime(start_time, move_speed);
	    move_data.move_speed = move_speed;
	    return true;
    end

    -- 加载冲锋路径
	function move_data.LoadChargePath(start_time, pos_x, pos_y, pos_z, dir_x, dir_y, dir_z, dst_x, dst_y, dst_z, min_distance, move_speed)
		move_data.Clear();
		local path = move_data.path;
	    local result = Fight.CalcChargePath(pos_x, pos_y, pos_z, dst_x, dst_y, dst_z, min_distance, path);
	    if not result then
	    	return false;
	    end
	    move_data.index = 1;
	    move_data.arrived = false;
	    move_data.server_start_time = TimerManager.GetServerNowMillSecond();
	    move_data.start_time = start_time;
	    move_data.last_time = start_time;
	    move_data.pos_x = pos_x;	-- 位置
	    move_data.pos_y = pos_y;
	    move_data.pos_z = pos_z;
	    move_data.dir_x = dir_x;	-- 方向
	    move_data.dir_y = dir_y;
	    move_data.dir_z = dir_z;
	    move_data.src_x = pos_x;
	    move_data.src_y = pos_y;
	    move_data.src_z = pos_z;
	    move_data.dst_x = dst_x;
	    move_data.dst_y = dst_y;
	    move_data.dst_z = dst_z;
	    
	    local length = move_data.GetPathLength();
	    if length > 0 then
	    	local goal_x, goal_y, goal_z = move_data.GetPos(length);
	    	move_data.goal_x = goal_x;	-- 目标位置
	    	move_data.goal_y = goal_y;
	    	move_data.goal_z = goal_z;
	    else
	    	move_data.goal_x = dst_x;	-- 目标位置
	    	move_data.goal_y = dst_y;
	    	move_data.goal_z = dst_z;
	    end
	    -- 重新计算时间
	    move_data.RecaculateTime(start_time, move_speed);
	    move_data.move_speed = move_speed;
	    return true;
	end

	-- 加载从当前点到挂机随机移动半径内随机选中的点之间寻路路径
	function move_data.LoadAutoFightReturnPath(start_time, pos_x, pos_y, pos_z, dir_x, dir_y, dir_z, origin_x, origin_y, origin_z, random_move_radius, move_speed)
		move_data.Clear();
		local path = move_data.path;
	    local result = Fight.CalcAutoFightReturnPath(pos_x, pos_y, pos_z, origin_x, origin_y, origin_z, random_move_radius, path);
	    if not result then
	    	return false;
	    end
	    move_data.index = 1;
	    move_data.arrived = false;
	    move_data.server_start_time = TimerManager.GetServerNowMillSecond();
	    move_data.start_time = start_time;
	    move_data.last_time = start_time;
	    move_data.pos_x = pos_x;	-- 位置
	    move_data.pos_y = pos_y;
	    move_data.pos_z = pos_z;
	    move_data.dir_x = dir_x;	-- 方向
	    move_data.dir_y = dir_y;
	    move_data.dir_z = dir_z;
	    move_data.src_x = pos_x;
	    move_data.src_y = pos_y;
	    move_data.src_z = pos_z;
	    move_data.dst_x = origin_x;
	    move_data.dst_y = origin_y;
	    move_data.dst_z = origin_z;
	    local length = move_data.GetPathLength();
	    if length > 0 then
	    	local goal_x, goal_y, goal_z = move_data.GetPos(length);
	    	move_data.goal_x = goal_x;	-- 目标位置
	    	move_data.goal_y = goal_y;
	    	move_data.goal_z = goal_z;
	    else
	    	move_data.goal_x = origin_x;	-- 目标位置
	    	move_data.goal_y = origin_y;
	    	move_data.goal_z = origin_z;
	    end
	    -- 重新计算时间
	    move_data.RecaculateTime(start_time, move_speed);
	    move_data.move_speed = move_speed;
	    return true;
	end


	-- 加载瞬移路径
	function move_data.LoadTeleportPath(start_time, pos_x, pos_y, pos_z, dir_x, dir_y, dir_z, distance, move_speed)
		move_data.Clear();
		move_data.arrived = false;
		move_data.server_start_time = TimerManager.GetServerNowMillSecond();
		move_data.start_time = start_time;
		move_data.last_time = start_time;
		move_data.pos_x = pos_x;	-- 位置
	    move_data.pos_y = pos_y;
	    move_data.pos_z = pos_z;
	    move_data.dir_x = dir_x;	-- 方向
	    move_data.dir_y = dir_y;
	    move_data.dir_z = dir_z;
	    move_data.src_x = pos_x;	-- 起始位置
	    move_data.src_y = pos_y;
	    move_data.src_z = pos_z;
		local dist = math.sqrt(dir_x * dir_x + dir_z * dir_z);
		local dx = dir_x / dist;
		local dz = dir_z / dist;
		local dst_x = pos_x + dx * distance;
		local dst_y = pos_y;
		local dst_z = pos_z + dz * distance;
		move_data.dst_x = dst_x;	-- 起始位置
	    move_data.dst_y = dst_y;
	    move_data.dst_z = dst_z;
		local path = move_data.path;
		local ret = Fight.CalcTeleportPath(pos_x, pos_y, pos_z, dst_x, dst_y, dst_z, path);
		--计算瞬移路径有可能会失败，原地瞬移就好了(比如：当遇到边缘障碍的时候)
		if ret == false then
		    path[1] = pos_x;
            path[2] = pos_y;
            path[3] = pos_z;
            path[4] = pos_x;
            path[5] = pos_y;
            path[6] = pos_z;
		end
		local length = move_data.GetPathLength();
	    if length > 0 then
	    	local goal_x, goal_y, goal_z = move_data.GetPos(length);
	    	move_data.goal_x = goal_x;	-- 目标位置
	    	move_data.goal_y = goal_y;
	    	move_data.goal_z = goal_z;
	    else
	    	move_data.goal_x = dst_x;	-- 目标位置
	    	move_data.goal_y = dst_y;
	    	move_data.goal_z = dst_z;
	    end
	    -- 重新计算时间
	    move_data.RecaculateTime(start_time, move_speed);
	    move_data.move_speed = move_speed;
	end

	-- 开始追击移动
	function move_data.StartChaseMove(start_time, pos_x, pos_y, pos_z, dir_x, dir_y, dir_z, dst_x, dst_y, dst_z, min_distance, move_speed)
		move_data.Clear();
	    local path = move_data.path;
	    local result = Fight.CalcChasePath(pos_x, pos_y, pos_z, dst_x, dst_y, dst_z, min_distance, path);
	    if not result then
	    	return false;
	    end
	    move_data.arrived = false;
	    move_data.server_start_time = TimerManager.GetServerNowMillSecond();
	    move_data.start_time = start_time;
	    move_data.last_time = start_time;
	    move_data.pos_x = pos_x;	-- 位置
	    move_data.pos_y = pos_y;
	    move_data.pos_z = pos_z;
	    move_data.dir_x = dir_x;	-- 方向
	    move_data.dir_y = dir_y;
	    move_data.dir_z = dir_z;
	    move_data.src_x = pos_x;	-- 起始位置
	    move_data.src_y = pos_y;
	    move_data.src_z = pos_z;
	    move_data.dst_x = dst_x;	-- 寻路位置
	    move_data.dst_y = dst_y;
	    move_data.dst_z = dst_z;
	    local length = move_data.GetPathLength();
	    if length > 0 then
	    	local goal_x, goal_y, goal_z = move_data.GetPos(length);
	    	move_data.goal_x = goal_x;	-- 目标位置
	    	move_data.goal_y = goal_y;
	    	move_data.goal_z = goal_z;
	    else
	    	move_data.goal_x = pos_x;	-- 目标位置
	    	move_data.goal_y = pos_y;
	    	move_data.goal_z = pos_z;
	    end
	    -- 重新计算时间
	    move_data.RecaculateTime(start_time, move_speed);
	    move_data.move_speed = move_speed;
	    return true;
	end

	function move_data.Print()
		local s = "";
		s = s .. "move_data:\n";
		s = s .. "\tarrived=" .. tostring(move_data.arrived) .. "\n";
		s = s .. "\tstart_time=" .. move_data.start_time .. "\n";
		s = s .. "\tlast_time=" .. move_data.last_time .. "\n";
		s = s .. "\tpos_x=" .. move_data.pos_x .. "\n";
		s = s .. "\tpos_y=" .. move_data.pos_y .. "\n";
		s = s .. "\tpos_z=" .. move_data.pos_z .. "\n";
		s = s .. "\tdir_x=" .. move_data.dir_x .. "\n";
		s = s .. "\tdir_y=" .. move_data.dir_y .. "\n";
		s = s .. "\tdir_z=" .. move_data.dir_z .. "\n";
		s = s .. "\tsrc_x=" .. move_data.src_x .. "\n";
		s = s .. "\tsrc_y=" .. move_data.src_y .. "\n";
		s = s .. "\tsrc_z=" .. move_data.src_z .. "\n";
		s = s .. "\tdst_x=" .. move_data.dst_x .. "\n";
		s = s .. "\tdst_y=" .. move_data.dst_y .. "\n";
		s = s .. "\tdst_z=" .. move_data.dst_z .. "\n";
		s = s .. "\tgoal_x=" .. move_data.goal_x .. "\n";
		s = s .. "\tgoal_y=" .. move_data.goal_y .. "\n";
		s = s .. "\tgoal_z=" .. move_data.goal_z .. "\n";
		s = s .. "\tmove_speed=" .. move_data.move_speed .. "\n";
		local time = move_data.time;
		local time_length = #time;
		s = s .. "\tpath=[" .. time_length .. "] {\n";
		for i = 1, time_length do
			local x, y, z = move_data.GetPos(i);
			local t = move_data.GetTime(i);
			s = s .. string.format("\t\tpos={%f, %f, %f}, time=%f\n", x, y, z, t);
		end
		s = s .. "\t}\n";
		s = s .. "end move_data\n";
		--print(s);
	end

	function move_data.ClearPath()
		Fight.ClearPath(move_data.path);
	end

	function move_data.ClearTime()
		Fight.ClearTime(move_data.time);
	end

	function move_data.Clear()
		Fight.ClearPath(move_data.path);
		Fight.ClearTime(move_data.time);
	end

	function move_data.SetMoveSpeed(move_speed)
		local start_time = TimerManager.GetUnityTime();
		local pos_x = move_data.pos_x;
		local pos_y = move_data.pos_y;
		local pos_z = move_data.pos_z;
		local dir_x = move_data.dir_x;
		local dir_y = move_data.dir_y;
		local dir_z = move_data.dir_z;
		local dst_x = move_data.dst_x;
		local dst_y = move_data.dst_y;
		local dst_z = move_data.dst_z;
		local i, j = move_data.BinarySearch(start_time);
		local first_x, first_y, first_z = move_data.GetPos(j);
		local length = move_data.GetPathLength();
		local path = move_data.path;
		local b = 1;
		if first_x ~= pos_x or first_z ~= pos_z then
			path[b] = pos_x;
			path[b + 1] = pos_y;
			path[b + 2] = pos_z;
			b = b + 3;
		end
		for k = j, length do
			local p_x, p_y, p_z = move_data.GetPos(k);
			path[b] = p_x;
			path[b + 1] = p_y;
			path[b + 2] = p_z;
			b = b + 3;
		end
		for k = b, #path do
			path[k] = nil;
		end
		move_data.arrived = false;
	    move_data.server_start_time = TimerManager.GetServerNowMillSecond();
	    move_data.start_time = start_time;
	    move_data.last_time = start_time;
	    move_data.pos_x = pos_x;	-- 位置
	    move_data.pos_y = pos_y;
	    move_data.pos_z = pos_z;
	    move_data.dir_x = dir_x;	-- 方向
	    move_data.dir_y = dir_y;
	    move_data.dir_z = dir_z;
	    move_data.src_x = pos_x;	-- 起始位置
	    move_data.src_y = pos_y;
	    move_data.src_z = pos_z;
	    move_data.dst_x = dst_x;	-- 寻路位置
	    move_data.dst_y = dst_y;
	    move_data.dst_z = dst_z;
	    local length = move_data.GetPathLength();
	    if length > 0 then
	    	local goal_x, goal_y, goal_z = move_data.GetPos(length);
	    	move_data.goal_x = goal_x;	-- 目标位置
	    	move_data.goal_y = goal_y;
	    	move_data.goal_z = goal_z;
	    else
	    	move_data.goal_x = pos_x;	-- 目标位置
	    	move_data.goal_y = pos_y;
	    	move_data.goal_z = pos_z;
	    end
	    -- 重新计算时间
	    move_data.RecaculateTime(start_time, move_speed);
	    move_data.move_speed = move_speed;
	end

		-- 开始移动
	function move_data.StartMove(start_time, pos_x, pos_y, pos_z, dir_x, dir_y, dir_z, dst_x, dst_y, dst_z, move_speed)
		move_data.Clear();
		local path = move_data.path;
		local result = Fight.CalcPath(pos_x, pos_y, pos_z, dst_x, dst_y, dst_z, path);
		if not result then
			return false;
		end
	    move_data.arrived = false;
	    move_data.server_start_time = TimerManager.GetServerNowMillSecond();
	    move_data.start_time = start_time;
	    move_data.last_time = start_time;
	    move_data.pos_x = pos_x;	-- 位置
	    move_data.pos_y = pos_y;
	    move_data.pos_z = pos_z;
	    move_data.dir_x = dir_x;	-- 方向
	    move_data.dir_y = dir_y;
	    move_data.dir_z = dir_z;
	    move_data.src_x = pos_x;	-- 起始位置
	    move_data.src_y = pos_y;
	    move_data.src_z = pos_z;
	    move_data.dst_x = dst_x;	-- 寻路位置
	    move_data.dst_y = dst_y;
	    move_data.dst_z = dst_z;
	    local length = move_data.GetPathLength();
	    if length > 0 then
	    	local goal_x, goal_y, goal_z = move_data.GetPos(length);
	    	move_data.goal_x = goal_x;	-- 目标位置
	    	move_data.goal_y = goal_y;
	    	move_data.goal_z = goal_z;
	    else
	    	move_data.goal_x = pos_x;	-- 目标位置
	    	move_data.goal_y = pos_y;
	    	move_data.goal_z = pos_z;
	    end
	    -- 重新计算时间
	    move_data.RecaculateTime(start_time, move_speed);
	    move_data.move_speed = move_speed;
	    return true;
	end

	-- 设置路径
	--move_speed 不对，但是好像也没用
	function move_data.SetPath(start_time, server_start_time, dir_x, dir_y, dir_z, new_path, new_time, move_speed)
		move_data.Clear();
		move_data.arrived = false;
		move_data.server_start_time = server_start_time;
		move_data.start_time = start_time;
		move_data.last_time = start_time;
		local count = #new_path;
		move_data.src_x = new_path[1];
	    move_data.src_y = new_path[2];
	    move_data.src_z = new_path[3];
	    move_data.pos_x = new_path[1];
	    move_data.pos_y = new_path[2];
	    move_data.pos_z = new_path[3];
	    move_data.dir_x = dir_x;
	    move_data.dir_y = dir_y;
	    move_data.dir_z = dir_z;
	    move_data.dst_x = new_path[count - 2];
	    move_data.dst_y = new_path[count - 1];
	    move_data.dst_z = new_path[count];
	    move_data.goal_x = move_data.dst_x;
	    move_data.goal_y = move_data.dst_y;
	    move_data.goal_z = move_data.dst_z;
	    move_data.move_speed = move_speed;
	    -- 设置路径
	    local path = move_data.path;
	    for i = 1, #new_path do
	    	path[i] = new_path[i];
	    end
	    -- 设置时间
	    local time = move_data.time;
	    for i = 1, #new_time do
	    	time[i] = new_time[i];
	    end
	end


	-- 添加路径
	function move_data.AddPath(append_path)
		local path = move_data.path;
		move_data.arrived = false;
		local count = #append_path;
		local dst_x = append_path[count - 2];
		local dst_y = append_path[count - 1];
		local dst_z = append_path[count];
		move_data.dst_x = dst_x;
		move_data.dst_y = dst_y;
		move_data.dst_z = dst_z;
		for i = 1, #append_path do
			path[i] = append_path[i];
		end
	end


	-- 更新移动
	function move_data.UpdateMove(ds, curr_time)
	    move_data.UpdatePosByTime(ds, curr_time);
	end

	-- 获取当前服务器时间
	function move_data.GetServerTimeOfCurrPos()
		local pos_x = move_data.pos_x;
		local pos_y = move_data.pos_y;
		local pos_z = move_data.pos_z;
		local server_start_time = move_data.server_start_time;
		local start_time = move_data.start_time;
		local curr_time = move_data.last_time;
		local i, j = move_data.BinarySearch(curr_time);
		if i == j and i == 0 then
			return server_start_time;
		end
		local time = move_data.time;
		local count = #time;
		if count == 1 then
			return server_start_time;
		end
		local xi, yi, zi = move_data.GetPos(i);
		local xj, yj, zj = move_data.GetPos(j);
		local ti = move_data.GetTime(i);
		local tj = move_data.GetTime(j);
		if i == j then
			return server_start_time + (ti - start_time) * 1000;
		end
		local dti = ti - start_time;
		local dtj = tj - start_time;
		local server_ti = server_start_time + dti * 1000;
		local server_tj = server_start_time + dtj * 1000;
		local dx_ix = pos_x - xi;
		local dz_iz = pos_z - zi;
		local dist_sq_ix = dx_ix * dx_ix + dz_iz * dz_iz;
		local dx_ij = xj - xi;
		local dz_ij = zj - zi;
		local dist_sq_ij = dx_ij * dx_ij + dz_ij * dz_ij;
		if dist_sq_ij == 0 then
			return server_ti;
		end
		local t = math.sqrt(dist_sq_ix / dist_sq_ij);
		if t > 1 then
			t = 1;
		end
		local server_time = server_ti + (server_tj - server_ti) * t;
		return server_time;
	end

	-- 移动状态更新（对于模型）
	function move_data.DoStateUpdateMoveForModel(ds)
		local time = move_data.time;
		if #time == 0 then
			return;
		end
		local curr_time = ds.curr_time;
	    move_data.UpdateMove(ds, curr_time)
	    local pos_x = move_data.pos_x;
	    local pos_y = move_data.pos_y;
	    local pos_z = move_data.pos_z;
	    local dir_x = move_data.dir_x;
	    local dir_y = move_data.dir_y;
	    local dir_z = move_data.dir_z;
	    local start_time = move_data.start_time;
	    local last_time = move_data.last_time;
	    local move_speed = move_data.move_speed;
	    ds["pos_x"] = pos_x;
	    ds["pos_y"] = pos_y;
	    ds["pos_z"] = pos_z;
	    ds["dir_x"] = dir_x;
	    ds["dir_y"] = dir_y;
	    ds["dir_z"] = dir_z;
	    -- print(string.format("dir={%f, %f, %f}", dir_x, dir_y, dir_z));
	    Fight.SetAvatarPosAndDirForModel(ds);
	end

	-- 状态更新移动
	-- 在 OnMove 中直接调用这个函数就可以进行路径移动的位置更新
	function move_data.DoStateUpdateMove(ds)
		local time = move_data.time;
		if #time == 0 then
			return;
		end
		local curr_time = ds.curr_time;
	    move_data.UpdateMove(ds, curr_time)
	    local pos_x = move_data.pos_x;
	    local pos_y = move_data.pos_y;
	    local pos_z = move_data.pos_z;
	    local dir_x = move_data.dir_x;
	    local dir_y = move_data.dir_y;
	    local dir_z = move_data.dir_z;
	    local start_time = move_data.start_time;
	    local last_time = move_data.last_time;
	    local move_speed = move_data.move_speed;
	    ds["pos_x"] = pos_x;
	    ds["pos_y"] = pos_y;
	    ds["pos_z"] = pos_z;
	    ds["dir_x"] = dir_x;
	    ds["dir_y"] = dir_y;
	    ds["dir_z"] = dir_z;
	    -- print(string.format("dir={%f, %f, %f}", dir_x, dir_y, dir_z));
	    Fight.SetAvatarPosAndDir(ds);
	end

    return move_data;
end




-- 命中敌人
function Fight.DoHitTarget(target, attacker)
	local _t = target._t;
	_t.OnHit(target, attacker);
end


-- 获取当前普攻索引值
function Fight.GetCurrentAttackIndex(ds)
	local curr_state_name = ds["curr_state_name"];
	if curr_state_name == "Attack1" then
		return 1;
	elseif curr_state_name == "Attack2" then
		return 2;
	elseif curr_state_name == "Attack3" then
		return 3;
	elseif curr_state_name == "Attack4" then
		return 4;
	elseif curr_state_name == "Attack5" then
		return 5;
	elseif curr_state_name == "Attack6" then
		return 6;
	end
	return 0;
end



-- 获取技能信息，从 1 开始编号
function Fight.GetSkillInfoByIndex(ds, index)
	local lua_logic = ds["lua_logic"];
	local ability = const.CareerAbility[lua_logic];
	local skills = ability.skills;
	return skills[index];
end


function Fight.GetSkillInfoByLuaNameAndSkillId(luaName, skill_id)
	local ability = const.CareerAbility[luaName];
	local skills = ability.skills;
	for i = 1, #skills do
		local skill = skills[i];
		if skill.id == skill_id then
			return skill;
		end
	end
	return nil;
end

-- 获取技能信息（通过 id)
function Fight.GetSkillInfoById(ds, skill_id)
	local lua_logic = ds["lua_logic"];
	return Fight.GetSkillInfoByLuaNameAndSkillId(lua_logic, skill_id);
end

-- 根据索引和类型获取技能信息
-- index 从 1 开始编号, 类型为 SkillType.Normal 和 SkillType.Skill
function Fight.GetSkillInfoByIndexAndType(ds, index, type)
	if type == SkillType.Normal then
		local skillIndex = Fight.GetCurrentAttackIndex(ds);
		local lua_logic = ds["lua_logic"];
		local ability = const.CareerAbility[lua_logic];
		local skills = ability.skills;
		return skills[skillIndex];
	elseif type == SkillType.Skill then
		local lua_logic = ds["lua_logic"];
		local ability = const.CareerAbility[lua_logic];
		local skills = ability.skills;
		local attack_count = ability["attack_count"];
		return skills[index + attack_count];
	end
end


-- 获取当前自动战斗
function Fight.GetAutoFightAttackSkillData(ds, last_target_id, current_target_id)
	if current_target_id == 0 then
		return nil;
	end
	local lua_logic = ds["lua_logic"];
	local ability = const.CareerAbility[lua_logic];
	local attack_count = ability["attack_count"];
	if attack_count == 0 then
		return nil;
	end

	local skills = ability.skills;

	-- 上一次攻击没有目标
	if last_target_id == 0 then
		return skills[1];
	end

	-- 上次攻击目标和本次目标不一致
	if last_target_id ~= current_target_id then
		return skills[1];
	end

	-- 当前状态
	local curr_state_name = ds["curr_state_name"];

	-- 获取当前攻击的技能索引
	local attack_skill_index = 0;
	for i = 1, #skills do
		if skills[i].state == curr_state_name then
			attack_skill_index = i;
			break;
		end
	end

	-- 如果有普通攻击，则返回第一个普通攻击
	-- 否则返回 nil
	if attack_skill_index == 0 then
		return skills[1];
	end

	attack_skill_index = attack_skill_index + 1;
	if attack_skill_index > attack_count then
		attack_skill_index = 1;
	end

	return skills[attack_skill_index];

end



-- 从技能按钮映射到技能索引, 映射后是技能在所有技能中的索引值
-- 
function Fight.MapSkillButtonToSkillIndex(ds, type, index)
	if type == SkillType.Normal then
		local skillIndex = Fight.GetCurrentAttackIndex(ds);
		local nextSkillIndex = 1;
		local lua_logic = ds["lua_logic"];
		local ability = const.CareerAbility[lua_logic];
		local skills = ability.skills;
		local attack_count = ability["attack_count"];
		if skillIndex ~= 0 then
			nextSkillIndex = skillIndex + 1;
			if nextSkillIndex > attack_count then
				nextSkillIndex = 1;
			end
		end
		return skills[nextSkillIndex].index;
	elseif type == SkillType.Skill then
		local lua_logic = ds["lua_logic"];
		local ability = const.CareerAbility[lua_logic];
		local skills = ability.skills;
		local attack_count = ability["attack_count"];
		local skillIndex = index;
		return skills[skillIndex + attack_count].index;
	end
end



-- 获取技能信息
function Fight.GetSkillInfo(ds, skill_id)
	local lua_logic = ds["lua_logic"];
	local ability = const.CareerAbility[lua_logic];
	local skills = ability.skills;
	for i = 1, #skills do
		local skill = skills[i];
		if skill.id == skill_id then
			return skill;
		end
	end
	return nil;
end

-- 从技能按钮映射到技能信息
function Fight.MapSkillButtonToInfo(ds, type, index)
	local lua_logic = ds["lua_logic"];
	local ability = const.CareerAbility[lua_logic];
	local index = Fight.MapSkillButtonToSkillIndex(ds, type, index);
	return ability.skills[index];
end



-- 获取脚步声索引
function Fight.GetFootstepIndexByName(name)
	local t = const.FootstepName;
	for i = 1, #t do
		if t[i] == name then
			return i;
		end
	end
	return 0;
end

-- 创建脚步声数据
function Fight.CreateFootstepData()
	local t = {};
	t.footstep = 0;
	t.index = 0;
	return t;
end

-- 播放脚步声
function Fight.PlayFootstepSound(ds, footstep_data, pos_x, pos_y, pos_z)
	local sound_name = "";
	local footstep = footstep_data.footstep;
	local index = footstep_data.index;
	sound_name, footstep, index = Fight.GetFootstepSoundName(pos_x, pos_y, pos_z, footstep, index);
	footstep_data.footstep = footstep;
	footstep_data.index = index;
	Fight.DoPlaySound(ds, sound_name);
end

-- 获取脚步声
function Fight.GetFootstepSoundName(pos_x, pos_y, pos_z, footstep, index)
	local area_footstep = uFacadeUtility.GetAreaFootstep(pos_x, pos_y, pos_z);
    if area_footstep == 0 then
    	local footstep_name = tb.SceneTable[DataCache.scene_sid].footstep;
    	local footstep_index = Fight.GetFootstepIndexByName(footstep_name);
    	if footstep_index ~= footstep then
    		index = 1;
    	end
    	local nextIndex = index + 1;
    	if nextIndex > 5 then
    		nextIndex = 1;
    	end
	    local prefixName = const.FootstepName[footstep_index];
    	return prefixName .. "_" .. index, footstep_index, nextIndex;
    else
    	if area_footstep ~= footstep then
	    	index = 1;
	    end
	    local nextIndex = index + 1;
    	if nextIndex > 5 then
    		nextIndex = 1;
    	end
    	local prefixName = const.FootstepName[area_footstep];
    	return prefixName .. "_" .. index, area_footstep, nextIndex;
    end
end


-----------------------------------------------------------------------
-- 尝试状态跳转函数
-- ds: c# to lua 数据集
-- return: true: 成功跳转; false: 不会跳转
-----------------------------------------------------------------------


-- 尝试跳转到下一个指令
function Fight.TryProcessNextCommand(ds)
	local class = Fight.GetClass(ds);
	if class.IsCommandQueueEmpty() then
		return false;
	end
	return class.ProcessCommandQueue();
end


-- 尝试跳转到摇杆移动（非骑乘）
function Fight.TryJumpJoystickRun(ds)
	local is_joysticking = JoystickManager.IsJoysticking();
    if is_joysticking then
    	local curr_state_name = ds["curr_state_name"];
    	if curr_state_name == "JoystickRun" then
    		Fight.DoJumpState(ds, SourceType.Player, "JoystickRun", 0);
    		return true;
    	else
    		local normalized_time = ds["curr_state_normalized_time"];
        	Fight.DoJumpState(ds, SourceType.Player, "JoystickRun", normalized_time);
        	return true;	
    	end
    end
    return false;
end


-- 点击移动到某个位置
function Fight.ClickMoveTo(ds, source, click_move_x, click_move_y, click_move_z)
	ClickMoveManager.OnClickMove(click_move_x, click_move_y, click_move_z);
	Fight.TryJumpClickRun(ds, source);
end


-- 玩家尝试跳转 ClickRun
function Fight.PlayerTryJumpClickRun(ds)
	return Fight.TryJumpClickRun(ds, SourceType.Player);
end


-- 尝试跳转到点击移动（非骑乘）
function Fight.TryJumpClickRun(ds, source)
	local is_click_moving = ClickMoveManager.IsClickMoving();
    if is_click_moving then
    	local curr_state_name = ds["curr_state_name"];
    	if curr_state_name == "ClickRun" then
    		local click_pos = ClickMoveManager.GetClickPos();
            local click_move_x = click_pos.x;
            local click_move_y = click_pos.y;
            local click_move_z = click_pos.z;
    		local class = Fight.GetClass(ds);
    		local state = class.ClickRun;
    		local move_data = state.move_data;
    		state.source = source;
    		if move_data.dst_x == click_move_x and move_data.dst_z == click_move_z then
    			return false;
    		end
    		local pos_x = ds["pos_x"];
    		local pos_y = ds["pos_y"];
    		local pos_z = ds["pos_z"];
    		local dir_x = ds["dir_x"];
            local dir_y = ds["dir_y"];
            local dir_z = ds["dir_z"];
    		--local curr_time = ds["curr_time"];
    		local move_speed = ds["move_speed"];
    		local state = Fight.GetState(ds, "ClickRun");
    		local move_data = state.move_data;
    		local last_time = move_data.last_time;
    		local result = move_data.StartMove(last_time, pos_x, pos_y, pos_z, dir_x, dir_y, dir_z, click_move_x, click_move_y, click_move_z, move_speed);
    		if result then
    			uFacadeUtility.SyncStartMove(move_data.path, move_data.move_speed);
    			Fight.DoShowClickEffect(ds, true);
    			return true;
    		end
    		return false;
    	else
        	Fight.DoJumpState(ds, source, "ClickRun", 0);
        	return true;
        end
    end
    return false;
end



-- 技能是否可以释放
function Fight.IsSkillCanCast(ds, skill_id, target)
	if Fight.IsSkillColdTimeById(ds, skill_id) then
		return false;
	end
	local info = Fight.GetSkillInfo(ds, skill_id);
	if info == nil then
		return false;
	end
	local skill_info = tb.SkillTable[info.id];
	if skill_info.target_needless == 1 then
		return true;
	end
	if Fight.IsTargetWithinSkillScopeBySkillInfo(ds, skill_info, target) then
		return true;
	end
	return false;
end


-- 当前目标是否在攻击者的技能范围内
function Fight.IsTargetWithinSkillScope(ds, skill_id, target)
	local skill_info = Fight.GetSkillInfo(ds, skill_id);
	if skill_info == nil then
		return false;
	end
	return Fight.IsTargetWithinSkillScopeBySkillInfo(ds, skill_info, target);
end


-- 目标在技能范围内
function Fight.IsTargetWithinSkillScopeBySkillInfo(ds, skill_info, target)
    if target == nil then
    	return false;
    end
    if skill_info.target_needless == 1 then
    	return false;
    end
    local pos_x = ds["pos_x"];
	local pos_y = ds["pos_y"];
	local pos_z = ds["pos_z"];
	local target_pos_x = target["pos_x"];
	local target_pos_y = target["pos_y"];
	local target_pos_z = target["pos_z"];
	local dx = target_pos_x - pos_x;
	local dy = target_pos_y - pos_y;
	local dz = target_pos_z - pos_z;
	local dist_sq = dx * dx + dz * dz;
	local dist = skill_info.distance;
	local dist2 = dist * dist;
	if dist_sq <= dist2 then
		return true;
	end
	return false;
end


function Fight.TryJumpCanCastSkillWithinScope(ds, source)
	local event = SkillButtons.PeekButtonEvents();
	if event == nil then
		return false;
	end
	local info = Fight.MapSkillButtonToInfo(ds, event.type, event.index);
	return Fight.TryJumpCanCastSkill(ds, info.id, source);
end


-- 尝试跳转技能（当距离在范围内）
function Fight.TryJumpCanCastSkill(ds, skill_id, source)
	if Fight.IsSkillCanCast(ds, skill_id, TargetSelecter.current) then
		local info = Fight.GetSkillInfo(ds, skill_id);
		if info == nil then
			return false;
		end
		if not info.no_action then
			Fight.DoJumpState(ds, source, info.state, 0);
			SkillButtons.DequeueButtonEvent();
    		return true;
    	else
    		Fight.DoNoActionSkill(ds, skill_id);
    		return true;
    	end
   	end
	return false;
end


-- 释放没有动作技能
function Fight.DoNoActionSkill(ds, skill_id)
	if skill_id == 40021301 then
		local role_type = ds.role_type;
		if role_type == nil then
			Fight.PlaySound("archer_xunjie");
			Fight.RttPlayFollowEffect("archer_female_special", 5.0, ds["id"], "");
		else
			if ds.role_type == RoleType.Player then
				local class = Fight.GetClass(ds);
				local skill = class.GetSkillById(skill_id);
				skill.Cast();
				uFacadeUtility.SyncCastSkill(skill_id, 0);
				local skill_cd = Fight.GetSkillCdTime(skill_id, skill.level);
				local skill_index = class.GetSkillTypeIndex(skill_id);
				Fight.DoStartSkillButtonCD(ds, skill_index, skill_cd / 1000, ds["is_auto_fighting"]);
				SkillButtons.DequeueButtonEvent();
			end
			Fight.PlaySound("archer_xunjie");
			Fight.PlayFollowEffect("archer_female_special", 5.0, ds["id"], "");
		end
		
	end
	if skill_id == 40001001 then
		if ds.role_type == RoleType.Player then
			local class = Fight.GetClass(ds);
			local skill = class.GetSkillById(skill_id);
			skill.Cast();
			uFacadeUtility.SyncCastSkill(skill_id, DataCache.myInfo.id);
			local skill_cd = Fight.GetSkillCdTime(skill_id, skill.level);
			local skill_index = class.GetSkillTypeIndex(skill_id);
			Fight.DoStartSkillButtonCD(ds, skill_index, skill_cd / 1000, ds["is_auto_fighting"]);
			SkillButtons.DequeueButtonEvent();
		end
		Fight.PlayFollowEffect("buxue", 2.5, ds["id"], "");
	end
end

-- 获取状态
function Fight.GetState(ds, state_name)
	local class = Fight.GetClass(ds);
	return class[state_name];
end

-- 尝试跳转技能（攻击目标可能在范围内，也可能不在攻击范围内，当攻击目标不在范围内会触发追击）
function Fight.TryJumpSkillById(ds, skill_id, source)
	local info = Fight.GetSkillInfo(ds, skill_id);
	local skill_info = tb.SkillTable[skill_id];
	if skill_info.target_needless == 1 then
		if not info.no_action then
			Fight.DoJumpState(ds, source, info.state, 0);
    		return true;
    	else
    		Fight.DoNoActionSkill(ds, skill_id);
    		return true;
    	end
    end
    local target = TargetSelecter.current;
    if target == nil then
    	return false;
    end
    local pos_x = ds["pos_x"];
	local pos_y = ds["pos_y"];
	local pos_z = ds["pos_z"];
    local target_pos_x = target["pos_x"];
	local target_pos_y = target["pos_y"];
	local target_pos_z = target["pos_z"];
	local dx = target_pos_x - pos_x;
	local dy = target_pos_y - pos_y;
	local dz = target_pos_z - pos_z;
	local dist_sq = dx * dx + dz * dz;
	local dist = skill_info.distance;
	local dist2 = dist * dist;
	local skill_id = info.id;
	if dist_sq <= dist2 then
		Fight.DoJumpState(ds, source, info.state, 0);
    	return true;
	end
	Fight.DoJumpChaseState(ds, source, "Chase", 0, 0, skill_id, target["id"]);
	return true;
end


-- 玩家尝试释放技能
function Fight.PlayerTryJumpSkill(ds)
	return Fight.TryJumpSkill(ds, SourceType.Player);
end


-- 尝试跳转技能
function Fight.TryJumpSkill(ds, source)
	
	local is_skill_button_pressed = SkillButtons.HasButtonEvent();
	if not is_skill_button_pressed then
		return false;
	end
	local event = SkillButtons.PeekButtonEvents();
	local info = Fight.MapSkillButtonToInfo(ds, event.type, event.index);
	local skill_info = tb.SkillTable[info.id];
	
	if skill_info.target_needless == 1 then
		if not info.no_action then
			Fight.DoJumpState(ds, source, info.state, 0);
			SkillButtons.DequeueButtonEvent();
    		return true;
    	else
    		Fight.DoNoActionSkill(ds, info.id);
    		SkillButtons.DequeueButtonEvent();
			return false;
		end
    end
    local target = TargetSelecter.current;
    if target == nil then
    	return false;
    end
    local pos_x = ds["pos_x"];
	local pos_y = ds["pos_y"];
	local pos_z = ds["pos_z"];
    local target_pos_x = target["pos_x"];
	local target_pos_y = target["pos_y"];
	local target_pos_z = target["pos_z"];
	local dx = target_pos_x - pos_x;
	local dy = target_pos_y - pos_y;
	local dz = target_pos_z - pos_z;
	local dist_sq = dx * dx + dz * dz;
	local dist = skill_info.distance;
	local dist2 = dist * dist;
	local skill_id = info.id;
	if dist_sq <= dist2 then
		Fight.DoJumpState(ds, source, info.state, 0);
		SkillButtons.DequeueButtonEvent();
    	return true;
	end
	Fight.DoJumpChaseState(ds, source, "Chase", 0, 0, skill_id, target["id"]);
	SkillButtons.DequeueButtonEvent();
	return true;
end

-- 尝试跳转自动寻路
function Fight.TryJumpPathfinding(ds)
	local is_auto_pathfinding = AutoPathfindingManager.IsAutoPathfinding();
	local is_teleporting = AutoPathfindingManager.IsTeleporting();
	if is_auto_pathfinding and not is_teleporting then
		local curr_state_name = ds.curr_state_name;
		if curr_state_name == "PathfindingRun" then
			local is_change_goal = AutoPathfindingManager.IsChangeGoal();
			if not is_change_goal then
				return false;
			end
			if AutoPathfindingManager.IsSameScene() then
				local curr_state_normalized_time = ds.curr_state_normalized_time;
				--print("jump pathfinding state");
				Fight.DoJumpState(ds, SourceType.Player, "PathfindingRun", curr_state_normalized_time);
				return true;
			else
				local player = AvatarCache.me;
				local state = Fight.GetState(player, "PathfindingRun");
				state.canceled = true;
				Fight.DoJumpState(player, SourceType.System, "Idle", 0);
				return true;
			end
		else
			if not AutoPathfindingManager.IsSameScene() then
				local player = AvatarCache.me;
				local curr_state_name = player.curr_state_name;
				if curr_state_name ~= "Idle" then
					Fight.DoJumpState(player, SourceType.System, "Idle", 0);
				end
				return true;
			else
				--print("jump pathfinding state");
				Fight.DoJumpState(ds, SourceType.Player, "PathfindingRun", 0);
				return true;
			end
		end
	end
	return false;
end