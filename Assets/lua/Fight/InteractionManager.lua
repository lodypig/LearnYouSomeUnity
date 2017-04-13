
TaskNoticeType = {}
TaskNoticeType.None = 0;
TaskNoticeType.Accept = 1;
TaskNoticeType.Complete = 2;
TaskNoticeType.Resource = 3;

function CreateInteractionManager()

	local t = {};

	----------------------------------
	--
	----------------------------------

	t.npcs = {};

	-- 获取 npc id
	t.GetSingleNpcId = function (npcSid)
		local npcs = t.npcs;
		if npcs[npcSid] then
			return npcs[npcSid][1];
		else
			return nil
		end
	end;

	-- 获取 npc ds
	t.GetSingleNpc = function (npcSid)
		local npcs = t.npcs;
		local npcId = t.GetSingleNpcId(npcSid);
		if npcId == nil then
			return nil;
		end
		return AvatarCache.GetAvatar(npcId);
	end;

	t.GetNpcIdList = function (npcSid)
		return t.npcs[npcSid];
	end

	-- 注册交互 npc
	t.AddNpc = function(ds)
		local role_type = ds.role_type;
		if role_type ~= RoleType.Npc then
			return;
		end
		local id = ds.id;
		local npcSid = ds.sid;
		local npcInfo = tb.NPCTable[npcSid];
		local npcType = npcInfo.type;

		local npcs = t.npcs;
		npcs[npcSid] = npcs[npcSid] or {};
		table.insert(npcs[npcSid], id);

		t.ProcessCollectNpc(ds)
		t.CheckProcessTitle(ds)
		t.CheckCollectAutoGo(ds)
	end;

	-- 删除交互 npc
	t.RemoveNpc = function (ds)
		local role_type = ds.role_type;
		if role_type ~= RoleType.Npc then
			return;
		end
		local npcSid = ds.sid;
		if npcSid == nil then
			return;
		end
		local npcInfo = tb.NPCTable[npcSid];
		local npcType = npcInfo.type;

		local id = ds.id;
		local npcs = t.npcs;
		if npcs[npcSid] ~= nil then
			local list = npcs[npcSid];
			if #list == 1 then
				list[1] = nil;
			else
				for i = 1, #list do
					if list[i] == id then
						list[i] = list[#list];
						list[#list] = nil;
						break;
					end
				end
			end
			if #list == 0 then
				npcs[npcSid] = nil;
			end
		end
		-- npcs[npcSid] = nil;
	end;

	-- 清空所有注册
	t.ClearNpcs = function ()
		local npcs = t.npcs;
		for k, v in pairs(npcs) do
			npcs[k] = nil;
		end
	end;

	t.CheckProcessTitle = function(ds)
		local npcSid = ds.sid;
		if npcSid == client.MolongTask.NengliangcheSid then
			client.MolongTask.NengliangcheId = ds.id;
			local energy_stone = client.StoneNumberTable[DataCache.nodeID];
			client.gcm.UpdateTitle(ds.id, energy_stone);
		end
	end
	-----------------------------------
	-- NPC 任务状态
	-----------------------------------

	-- 任务状态表
	t.npc_task_states = {};
	-- 获取任务状态
	t.GetTaskState = function (npcSid)
		local states = t.npc_task_states;
		return states[npcSid];
	end;
	-- 拥有任务状态
	t.HasTaskState = function (npcSid)
		local states = t.npc_task_states;
		return states[npcSid] ~= nil;
	end;
	-- 设置任务状态
	t.SetTaskState = function (npcSid, taskState)
		local states = t.npc_task_states;
		local oldState = states[npcSid];
		states[npcSid] = taskState;
		local list = t.GetNpcIdList(npcSid);
		if list ~= nil and #list ~= 0 then
			for i=1,#list do				
				local ds =  AvatarCache.GetAvatar(list[i]);
				if ds ~= nil then
					local class = Fight.GetClass(ds);
					class.ShowTaskState(ds, taskState);
				end
			end
		end
		t.HandleChangeState(npcSid,oldState,taskState);
	end;
	-- 删除任务状态
	t.RemoveTaskState = function (npcSid)
		local list = t.GetNpcIdList(npcSid);
		if list ~= nil and #list ~= 0 then
			for i=1,#list do				
				local ds =  AvatarCache.GetAvatar(list[i]);
				if ds ~= nil then
					local class = Fight.GetClass(ds);
					class.HideAllTaskStates(ds);
				end
			end
		end
		local states = t.npc_task_states;
		states[npcSid] = nil;
	end;
	-- 清空所有任务状态
	t.ClearAllTaskStates = function ()
		local states = t.npc_task_states;
		for i = 1, #states do
			states[i] = nil;
		end
	end;

	t.TrunCollect = function(npcSid,bCan)
		local list = t.GetNpcIdList(npcSid);
		if list ~= nil and #list ~= 0 then
			for i=1,#list do				
				local ds =  AvatarCache.GetAvatar(list[i]);
				if ds ~= nil then
					local class = Fight.GetClass(ds);
					class.SetDetectScopeEnable(ds, bCan);
					--改变采集物的显示状态
					uFacadeUtility.SetAvatarVisible(ds.id, bCan);
				end
			end
		end	
	end

	t.ProcessCollectNpc = function(ds)
		local npcInfo = tb.NPCTable[ds.sid];
		local npcType = npcInfo.type;
		if npcType and npcType == commonEnum.NpcType.NpcType_Gather then
			local class = Fight.GetClass(ds);
			if t.HasTaskState(ds.sid) == false or t.GetTaskState(ds.sid) ~= TaskNoticeType.Resource then
				class.SetDetectScopeEnable(ds, false);
				uFacadeUtility.SetAvatarVisible(ds.id, false);
			else
				class.SetDetectScopeEnable(ds, true);
				uFacadeUtility.SetAvatarVisible(ds.id, true);
			end
		end
	end

	--处理状态切换可能的一些操作
	t.HandleChangeState = function(npcSid,oldState,newState)
		--设置采集状态时，开启采集检测
		if newState == TaskNoticeType.Resource then
			t.TrunCollect(npcSid,true);
		elseif oldState == TaskNoticeType.Resource and newState == TaskNoticeType.None then
			t.TrunCollect(npcSid,false);			
		end
	end

	----------------------------------------
	-- NPC 交互回调
	----------------------------------------
	t.ClickCallBack = {}
	t.BindClickCallBack = function(npcId,callBack)
		t.ClickCallBack[npcId] = callBack;
	end

	t.RemoveClickCallBack = function(npcId)
		t.ClickCallBack[npcId] = nil;
	end

	t.OnClick = function (npcSid,npcId)
		if t.ClickCallBack[npcSid] ~= nil then
			t.ClickCallBack[npcSid](npcId)
		else
			client.task.openTaskAccept(npcSid);
		end
	end;

	--设定交互的回调
	t.EnterCallBack = {}
	t.LeaveCallBack = {}
	t.BindEnterCallBack = function(npcSid,callBack)
		t.EnterCallBack[npcSid] = callBack;
	end
	t.BindLeaveCallBack = function(npcSid,callBack)
		t.LeaveCallBack[npcSid] = callBack;
	end

	t.RemoveEnterCallBack = function(npcSid)
		t.EnterCallBack[npcSid] = nil;
	end
	t.RemoveLeaveCallBack = function(npcSid)
		t.LeaveCallBack[npcSid] = nil;
	end

	t.FireEnterCallBack = function(npcSid)
		if t.EnterCallBack[npcSid] then
			t.EnterCallBack[npcSid]();
		end
	end
	t.FireLeaveCallBack = function(npcSid)
		if t.LeaveCallBack[npcSid] then
			t.LeaveCallBack[npcSid]();
		end
	end

	----------------------------------------
	-- NPC 采集任务寻路重定向
	----------------------------------------
	local CollectNpcSid = 0;
	t.SetAutoGoNpc = function(sid)
		CollectNpcSid = sid;
	end

	t.ClearAutoGoNpc = function()
		CollectNpcSid = 0;
	end

	t.CheckCollectAutoGo = function(ds)
		if CollectNpcSid ~= 0 then
			if ds.sid == CollectNpcSid then				
				client.task.TaskAutoGo_Pathfinding(DataCache.scene_sid, ds.pos_x, 0, ds.pos_z);
				CollectNpcSid = 0;
			end
		end
	end


	----------------------------------------
	-- 清空状态
	----------------------------------------

	t.Clear = function ()
		t.ClearNpcs();
		t.ClearAllTaskStates();
	end;

	return t;
end

InteractionManager = CreateInteractionManager()