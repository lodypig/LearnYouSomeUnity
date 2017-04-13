function CreateAvatarCache()

	local t = {};

	t.me = nil;

	t.avatars = {};
	t.uid2nid = {};
	t.sid2nid = {};

	function t.PrintAvatars()
		local s = "[Avatars]\n";
		local avatars = t.avatars;
		for k, v in pairs(avatars) do
			s = s .. string.format("id=%d, role_type=%d, judge=%d\n", v["id"], v["role_type"], ControlLogic[ControlLogicType.WildHeping].JudgeCanAttack_TabTarget(v));
		end
		s = s .. "[End Avatars]\n";
		--print(s);
	end


	function t.GetAllAvatars()
		return t.avatars;
	end


	-- 设置玩家
	function t.SetPlayer(ds)
		AvatarCache.me = ds;
	end

	-- 添加角色
	function t.AddAvatar(ds)

		-- 添加角色
		local avatars = t.avatars;
		local id = ds["id"];
		avatars[id] = ds;

		local uid = ds["role_uid"]
		if uid ~= nil then
			t.uid2nid[uid] = id;
		end
		local sid = ds["sid"]
		if sid ~= nil and tb.NPCTable[sid] ~= nil then
			t.sid2nid[sid] = id;
		end

		-- 设置玩家
		local role_type = ds["role_type"];
	    if role_type == RoleType.Player then
	        t.SetPlayer(ds);
	    end
	    if Checker.CheckIsEliteMonster(ds) then
	    	const.CanSeeEliteTab[id] = ds;
	    end
	end

	-- 删除角色
	function t.RemoveAvatar(ds)

		-- 重置玩家
		local role_type = ds["role_type"];
	    if role_type == RoleType.Player then
	        t.SetPlayer(nil);
	    end

	    local uid = ds["role_uid"]
	    if uid ~= nil then
			t.uid2nid[uid] = nil;
		end

		local sid = ds["sid"]
		if sid ~= nil and tb.NPCTable[sid] ~= nil then
			t.sid2nid[sid] = nil;
		end

	    -- 删除角色
		local avatars = t.avatars;
		local id = ds["id"];
		avatars[id] = nil;
		if Checker.CheckIsEliteMonster(ds) then
	    	const.CanSeeEliteTab[id] = nil; 
	    end
	end

	function t.RemoveAllAvatars()
		local avatars = t.avatars;
		for k, v in pairs(avatars) do
			avatars[k] = nil;
		end
	end

	-- 存在角色
	function t.HasAvatar(id)
		return t.GetAvatar(id) ~= nil;
	end

	-- 获取角色
	function t.GetAvatar(id)
		local avatars = t.avatars;
		return avatars[id];
	end

	-- 获取想要的角色信息
	function t.GetAvatarList(filterFunc)
		local avatar_list = {};
		local avatars = t.avatars;
		for k, v in pairs(avatars) do
			if filterFunc(v) then
				avatar_list[#avatar_list + 1] = v;
			end
		end
		return avatar_list;
	end

	-- 获取想要的角色信息并排序
	-- filterFunc 过滤函数，要留下的返回 true, 要剔除的返回 false
	-- sortFunc 排序函数，直接用于 table.sort
	function t.GetAndSortAvatarList(filterFunc, sortFunc)
		local avatar_list = t.GetAvatarList(filterFunc);
		if #avatar_list > 1 then
			table.sort(avatar_list, sortFunc);
		end
		return avatar_list;
	end

	function t.SidToAvatarId(sid)
		return t.sid2nid[sid] or 0
	end

	--uid to nid
	function t.ConvertAvatarId(uid)
		return t.uid2nid[uid] or 0
	end

	return t;
end

-- 角色列表
AvatarCache = CreateAvatarCache();