const.TeamMemberType = 
{
	MEMBER_TRUE = 0;
	MEMBER_ROBOT = 1;
	MEMBER_OFFLINEPLAYER = 2;
}

function CreateTeamCtrl()
	local team = {}

	--队伍信息
	team.team_uid = 0
	team.team_leader_uid = 0
	team.team_members = {}
	team.invite_lst = {};
	team.apply_lst = {};
	team.old_team_members = {};

	team.redPoint_Sum = false;
	--周围玩家信息
	team.players_around = {}

	--注册组队发生变化的回调
	local onTeamChange = {};
	local count = 0;
	team.AddListener = function (listener)
		for i = 1, count do
			if onTeamChange[i] == nil  then
				onTeamChange[i] = listener;
				return i;
			end
		end
		count = count + 1;
		onTeamChange[count] = listener;
		return count;
	end

	team.RemoveListener = function (index)
		if onTeamChange ~= nil then
			onTeamChange[index] = nil;
		end
	end

	team.OnEvent = function ()
		for i = 1, count do
			if (onTeamChange[i]) then
				onTeamChange[i]();
			end
		end
	end

	
	----------------------------------------------------------------
	--function: 
	--    q 		--> 请求server的消息函数
	--    cb 		--> server返回的callback函数
	--	  listen 	--> server主动发送消息的监听函数
	----------------------------------------------------------------
    team.normalsend = function(cmd)
		local msg = {cmd = cmd}
        Send(msg, function() end); 
	end

	---------获取队伍信息---------
	team.cb_get_team = function(msg)
		local team_info = msg["team"]
		if team_info == nil then
			return
		end
		team.team_uid = team_info["uid"]
		team.team_leader_uid = team_info["leader"]
		team.team_members = {}
		if team_info["members"] == nil then
			return
		end
		for _,v in pairs(team_info["members"]) do
			local uid = v["role_uid"]
			--role_uid, name, sid, level, scene, pos, time, fight_point, state, career, hp, maxhp, isnpc
			local name = client.tools.ensureString(v["name"])
			team.team_members[uid] = v
			team.team_members[uid].name = name
			team.team_members[uid].sceneId = v.scene[1];
			team.team_members[uid].line = v.scene[3];
			team.team_members[uid].team_uid = team.team_uid;
			if v.membertype ~= const.TeamMemberType.MEMBER_TRUE then
				--如果队友是npc 则一定是在线的
				team.team_members[uid].state = "online"
			end
		end
		team.OnEvent();
	end

	team.q_get_team = function()
		local msg = {cmd = "get_team"}
        Send(msg, team.cb_get_team); 
	end

	--获取附近队伍列表
	team.q_find_teams_around = function(callback)
		local msg = {cmd = "find_teams_around"}
        Send(msg, function(msg)
        	callback(msg)
    	end);
        --team.cb_get_around_team); 
	end

	---------------------------------
	------------申请组队-------------
	---------------------------------
	team.q_apply_team = function(target_roleid, targetName, target_teamUid)
		if team.team_uid ~= 0 then
			ui.showMsg("你已有队伍");
			return;
		end

		if team.forbidTeam() then
			ui.showMsg("当前地图无法组队");
			return;
		end

		local msg = {cmd = "apply", target_uid = target_roleid}
		Send(msg, function(msg) 
			if msg.ret ~= "notip" then
				ui.showMsg(string.format("已向%s发出组队申请，请等待", targetName));
			end
		end)
	end

	team.cb_team_apply_success = function()
		--ui.showMsg("申请组队成功");
	end

	------------同意请求------------
	team.q_accept_apply = function(role_uid)
		if team.forbidTeam() then
			ui.showMsg("当前地图无法组队");
			return;
		end

		local msg = {cmd = "accept_apply", target_uid = role_uid}
  		Send(msg); 
  		team.removeApplyList(role_uid);
	end

	------------拒绝请求------------
	team.q_refuse_apply = function(role_uid)
		local msg = {cmd = "refuse_apply", target_uid = role_uid}
        Send(msg); 
  		team.removeApplyList(role_uid);
    end

    team.q_remove_apply = function(role_uid, notify_target)
		local msg = {cmd = "remove_apply", target_uid = role_uid, is_notify = notify_target}
        Send(msg); 
  		team.removeApplyList(role_uid);
    end

    ------------获取申请列表------------
    team.q_get_apply_list = function()
    	local msg = {cmd = "get_apply_list"}
        Send(msg, team.cb_prase_apply_list); 
	end

	team.cb_prase_apply_list = function(msg)
		local apply = msg["apply"]
		team.apply_lst = {}
		if #apply ~= 0 then
			for k,v in pairs(apply) do
				local role_uid = v["role_uid"]
				team.apply_lst[role_uid] = v
				team.apply_lst[role_uid].name = client.tools.ensureString(v.name)
				team.apply_lst[role_uid].referral = client.tools.ensureString(v.referral)
			end
		end

	end

    ------------获取邀请请列表------------
    team.q_get_invite_list = function()
    	local msg = {cmd = "get_invite_list"}
        Send(msg, team.cb_prase_invite_list); 
	end

	team.cb_prase_invite_list = function(msg)
		local invite = msg["invite"]
		team.invite_lst = {}
		if #invite ~= 0 then
			for k,v in pairs(invite) do
				local role_uid = v["role_uid"]
				team.invite_lst[role_uid] = v
				team.invite_lst[role_uid].name = client.tools.ensureString(v.name)
			end
		end

	end
	------------拒绝所有申请-------------
    team.q_refuse_all_apply = function()
    	team.normalsend("refuse_all_apply")
    	team.clearApplyList();
	end
	------------拒绝所有邀请-------------
    team.q_refuse_all_invite = function()
    	team.normalsend("refuse_all_invite")
    	team.clearInviteList();
	end

	team.q_remove_invite = function(role_uid)
		local msg = {cmd = "remove_invite", target_uid = role_uid}
        Send(msg); 
  		team.removeInviteList(role_uid);
    end
    ---------------------------------

	---------------------------------
    ------------邀请组队-------------
    ---------------------------------
	team.q_invite_team = function(target_roleid, targetName, target_teamUid)
		if target_teamUid ~= nil and target_teamUid ~= 0 then
			if target_teamUid == team.team_uid then
				ui.showMsg("对方已在队伍中");
			else
				ui.showMsg("对方已有队伍");
			end
			return;
		end

		if #client.team.getTeamList(true) == const.team_max_member then
			ui.showMsg("队伍已满员");
			return;
		end

		if team.forbidTeam() then
			ui.showMsg("当前地图无法组队");
			return;
		end

		local msg = {cmd = "invite", target_uid = target_roleid}

		Send(msg, function(msg)
			if msg.ret ~= "notip" then
				if not team.haveTeam() or team.isLeader(DataCache.myInfo.role_uid) then
					ui.showMsg(string.format("已向%s提出组队邀请，请等待", targetName));
				else
					ui.showMsg(string.format("已提出组队邀请，请等待", targetName));
				end
			end
		 end)
	end

	team.cb_team_invite_success = function()
		ui.showMsg("申请组队成功");
	end

	------------接受邀请------------
	team.q_accept_invite = function(target_uid)
		if team.forbidTeam() then
			ui.showMsg("当前地图无法组队");
			return;
		end

		local msg = {cmd = "accept_invite", invite_uid = target_uid}
  		Send(msg);
  		team.removeInviteList(target_uid);
	end

	------------拒绝邀请------------
	team.q_refuse_invite = function(target_uid)
		local msg = {cmd = "refuse_invite", invite_uid = target_uid}
        Send(msg); 
        team.removeInviteList(target_uid);
    end

	-------------------------------------

    ------------队伍操作-------------
    ---------------------------------
    team.q_create = function(cb)
		local msg = {cmd = "create_team"}
		if cb ~= nil then
			Send(msg, cb);
		else
			Send(msg);
		end
	end

    team.q_kick = function(role_uid)
    	if team.forbidTeam() then
			ui.showMsg("当前地图无法踢出队员");
			return;
		end
        local msg = {cmd = "kick", target_uid = role_uid}
		Send(msg); 
	end

	team.q_dismiss = function()
		team.normalsend("dismiss")
	end

	team.q_leave = function()
		if team.forbidTeam() then
			ui.showMsg("当前地图无法离开队伍");
			return;
		end
		--ui.showMsgBox("确定要离开队伍吗？", function ()
		team.normalsend("leave");	
		--end)
	end

	team.q_change_leader = function(role_uid)
		if team.forbidTeam() then
			ui.showMsg("当前地图无法改变队长");
			return;
		end
		local info = team.team_members[role_uid]
		if info.state ~= "online" then
			ui.showMsg("对方处于离线状态")
		elseif info.membertype ~= const.TeamMemberType.MEMBER_TRUE then
			return
		end
		local msg = {cmd = "change_leader", target_uid = role_uid}
        Send(msg); 
	end

	---------------------------------
    -----------逻辑操作--------------
    ---------------------------------
	--获取申请状态
    team.q_check_application = function()
    	team.normalsend("check_application")
	end

	--获取附近玩家列表
	team.q_find_players_around = function(callback)
		local msg = {cmd = "find_players_around"}
        Send(msg, team.cb_prase_players_around); 
	end

	team.cb_prase_players_around = function(msg)
		local players = msg["players"]
		team.players_around = {}
		for _, v in pairs(players) do
			local player = v;
			local info = {}
			info.role_uid = player[1] 
			info.name = client.tools.ensureString(player[2])
			info.level = player[3]
			info.career = player[4]
			info.sex = player[5]
			info.isGuaJi = player[6] == "true"
			local teamInfo = player[7]
			info.team_uid = teamInfo[1]
			info.team_pos = teamInfo[2] --member,leader, free
			info.team_member_num = teamInfo[3]
			if info.role_uid ~= DataCache.myInfo.role_uid then
				table.insert(team.players_around, info)
			end
		end

		UIManager.GetInstance():CallLuaMethod('UITeamSearch.UpdateAroundRoleList');
	end

    --------------------------------
	------------监听函数------------
	--------------------------------
	team.listen_team_apply2Leader = function(msg)
		local apply = msg["apply"]
		--role_uid, name, sid, level, time, FP, career
		local role_uid = apply["role_uid"]
		local name = client.tools.ensureString(apply.name)
		local referral = client.tools.ensureString(apply.referral)
		team.apply_lst[role_uid] = apply
		team.apply_lst[role_uid].name = name
		team.apply_lst[role_uid].referral = referral

		--设置红点标记事件
		team.redPoint_Sum = true
		EventManager.onEvent(Event.ON_REDPOINT_TEAMMSG);
		team.OnEvent()
    end

	team.listen_team_join_succeed = function(msg)
		ui.showMsg("你加入了队伍！")
		team.cb_get_team(msg)
		team.JoinTeam();
		team.clearInviteList();
	end

	team.listen_team_info = function(msg)
		team.cb_get_team(msg)
	end

	team.listen_team_add_member = function(msg)
		local newMember = msg["member"]
		local uid = newMember["role_uid"]  
		local name = client.tools.ensureString(newMember["name"])
		client.chat.clientSystemMsg(string.format("%s加入了队伍", client.tools.formatRichTextColor(name, const.mainChat.nameColor)), nil, nil, "team");

		team.team_members[uid] = newMember
		team.team_members[uid].name = name
		team.team_members[uid].sceneId = newMember.scene[1];
		team.team_members[uid].line = newMember.scene[3];
		team.team_members[uid].team_uid = team.team_uid;
		team.OnEvent();

		team.hideOperateFloat();
	end

	team.listen_team_message = function(msg)
		local msg = msg["msg"]
		local msgType = msg[1];
		local name = msg[2];
		local tip = ""

		if name ~= nil then
			name = client.tools.ensureString(name);
		end

		if msgType == "team_refuse_invite" then
			tip = string.format("%s拒绝了你的组队邀请", name)
		elseif msgType == "team_refuse_apply" then
			tip = string.format("%s拒绝了你的组队申请", name)
		elseif msgType == "team_not_response" then
			tip = "对方长时间未响应"
		end

		if tip ~= "" then
			ui.showMsg(tip)
		end
	end

	team.listen_team_create = function(msg)
		ui.showMsg("队伍创建成功")
		team.cb_get_team(msg)
		team.JoinTeam();
		team.clearInviteList();
	end

	team.listen_team_invite_2member = function(msg)
		local invite = msg["invite"]
		local role_uid = invite["role_uid"]
		local name = client.tools.ensureString(invite.name)
		team.invite_lst[role_uid] = invite
		team.invite_lst[role_uid].name = name

		team.redPoint_Sum = true
		EventManager.onEvent(Event.ON_REDPOINT_TEAMMSG);

		team.OnEvent()
	end

	team.do_team_leave = function(role_uid) 
		--离开队伍的人是不是自己
		if role_uid == DataCache.myInfo.role_uid then
			ui.showMsg("你离开队伍了！") 
			team.clearTeam()
		else
			local member = team.team_members[role_uid]
			if member == nil then
				return
			end	
			local showName = client.tools.formatRichTextColor(member.name, const.mainChat.nameColor);
			client.chat.clientSystemMsg(string.format("%s离开了队伍",showName), nil, nil, "team");
			team.team_members[role_uid] = nil
			if client.areamap ~= nil then
				client.areamap.ClearTeamMemberNail(role_uid)
			end

			team.hideOperateFloat();
		end
		team.OnEvent();
	end

	team.listen_team_leave = function(msg)
		local role_uid = msg["role_uid"]
		team.do_team_leave(role_uid)
	end

	team.listen_team_offline = function(msg)
		local id = msg["role_uid"]
		local member = team.team_members[id]
		if member == nil then
			return
		end
		local name = member["name"]
		ui.showMsg("你的队友"..name.."下线啦!")
		member.state = "offline"
		team.OnEvent();
	end

	team.listen_team_online = function(msg)
		local id = msg["role_uid"]
		local member = team.team_members[id]
		if member == nil then
			return
		end
		local name = member["name"]
		ui.showMsg("你的队友"..name.."上线啦!")
		--确保此时队伍的membertype标志一定是真人玩家
		member.membertype = const.TeamMemberType.MEMBER_TRUE
		member.state = "online"
		team.OnEvent();
	end

	team.JoinTeam = function()
		MainUI.JoinTeam();

		team.hideOperateFloat();
	end

	team.clearTeam = function()
		team.team_uid = 0
		team.team_leader_uid = 0
		team.team_members = {}
		MainUI.ClearTeam();
		if client.areamap ~= nil then
			client.areamap.ClearTeamNail()
		end

		team.hideOperateFloat();
	end

	team.hideOperateFloat = function ( )
		--回收队伍交互菜单
        if ui.teamOperateFloat ~= nil then
    		local lua = ui.teamOperateFloat:GetComponent("LuaBehaviour");
    		lua:CallLuaMethod("Hide")
        end
	end

	team.listen_team_dismiss = function(msg)
		--特殊 如果当前队伍内有npc 则清除非npc非队长的所有玩家
		if team.haveRobotMember() then
			team.ClearTrueMember(false)
			return
		end
		ui.showMsg("队伍已解散")
		team.clearTeam()
		team.OnEvent()
	end

	team.listen_team_kick = function(msg)
		local role_uid = msg["role_uid"]
		--是否是自己被踢出队伍
		if role_uid == DataCache.myInfo.role_uid then
			ui.showMsg("你被踢出了队伍")
			team.clearTeam()
		else
			local member = team.team_members[role_uid]
			local showName = client.tools.formatRichTextColor(member.name, const.mainChat.nameColor);

			if member ~= nil then
				client.chat.clientSystemMsg(string.format("%s被踢出了队伍",showName), nil, nil, "team");
			end
			--table.remove(team.team_members, role_uid)
			team.team_members[role_uid] = nil
			-- if team.team_members == 1 then
			-- 	team.clearTeam()
			-- end
		end
		team.OnEvent()
	end

	team.listen_team_change_leader = function(msg)
		local role_uid = msg["role_uid"]

		local member = team.team_members[role_uid]
		if member == nil then
			return
		end
		local showName = client.tools.formatRichTextColor(member.name, const.mainChat.nameColor);

		client.chat.clientSystemMsg(string.format("%s被提升为队长",showName), nil, nil, "team");
		ui.showMsg(string.format("%s被提升为队长",member.name))
		team.team_leader_uid = role_uid
		team.OnEvent()
	end

	team.listen_team_member_attr = function(msg)
		local id = msg["role_uid"]
		local type = msg["attr_type"]
		local newLevel = msg["attr_value"]
		local member = team.team_members[id]
		if member == nil then
			return
		end
		local name = member["name"]
		if type == "level" then
			--等级变动
			ui.showMsg("你的队友"..name.."升到"..newLevel.."级啦!")
			member.level = newLevel
		end
		team.OnEvent()
	end

	team.listen_team_member_change_scene = function (msg )
		local id = msg["role_uid"]
		local scene = msg["scene"]
		local pos = msg["pos"]
		local member = team.team_members[id]
		if member == nil then
			return
		end
		member.pos = pos;
		member.scene = scene;
		member.sceneId = scene[1];
		member.line = scene[2][2];

		team.OnEvent()

		if client.areamap ~= nil then
			client.areamap.ClearTeamMemberNail(id)
		end
	end

	team.listen_team_merge_team = function(msg)
		team.cb_get_team(msg)
	end

	team.OnSecondAction = function()
		if team.team_uid ~= nil and team.team_uid ~= 0 then
			team.q_get_member_status();
		end

		local nowSecond = TimerManager.GetServerNowSecond();
		for _,v in pairs(team.apply_lst) do
			if v and nowSecond - v.time > 30 then
				team.q_remove_apply(v.role_uid, "notify");
			end
		end

		for _,v in pairs(team.invite_lst) do
			if v and nowSecond - v.time > 30 then
				team.q_remove_invite(v.role_uid);
			end
		end
	end

	--请求队员状态变化
	team.q_get_member_status = function()
		local msg = {cmd = "get_member_status"}
        Send(msg, team.cb_team_member_status); 
	end

	team.cb_team_member_status = function(msg)
		local status = msg["status"]
		if status == nil then
			return
		end
		for _,v in pairs(status) do
			local role_uid = tonumber(v[1])
			local hp = v[2]
			local maxhp = v[3]
			local disstate = v[4]
			local state = v[5]
			local pos = v[6]			--位置
			if team.team_members ~= nil and team.team_members[role_uid] ~= nil then
				team.team_members[role_uid].hp = hp;
				team.team_members[role_uid].maxhp = maxhp;
				team.team_members[role_uid].disstate = disstate;		--faraway close
				team.team_members[role_uid].state = state;
				team.team_members[role_uid].targetName = team.getAttackTargetName(role_uid);
				team.team_members[role_uid].pos = pos;
				if client.areamap ~= nil then
					client.areamap.UpdateTeamMemberNail(role_uid, pos, state, team.team_members[role_uid].scene)
				end
			end
		end
		MainUI.RefreshTeamList();
		--team.OnEvent();
	end

	team.getAttackTargetName = function(attacker_id)
		local avatarid = AvatarCache.ConvertAvatarId(attacker_id);
		local avatar = AvatarCache.GetAvatar(avatarid);
        if avatar ~= nil then
            local avatar_class = Fight.GetClass(avatar);
            local TargetInfo = avatar_class.GetAvatarAttackedByMe();

            if TargetInfo ~= nil then
            	local Target = AvatarCache.GetAvatar(TargetInfo.id);
            	if Target ~= nil then
	                return Target.name
	            end
            end
        end

        return nil
	 end

    team.listen_team_member_get_item = function(msg)
    	local role_uid = msg.role_uid
		local member = team.team_members[role_uid]
		if member == nil then
			return
		end	
    	local item = msg.item
    	local iteminfo = Bag.parse(item)
    	--tip
		local type = "item";
		local table = tb.ItemTable[iteminfo.sid]
		local str = ""
		if table == nil then
			type = "equip"
			table = tb.EquipTable[iteminfo.sid]
		end
		-----
		if table ~= nil then
			local showName = client.tools.formatRichTextColor(member.name, const.mainChat.nameColor);
			local str = string.format("%s获得了[item:%s:item:%d]", showName, table.name, iteminfo.quality)
			if type == "item" then
				client.chat.clientSystemMsg(str, iteminfo, nil, "team")
			else
				client.chat.clientSystemMsg(str, nil, iteminfo, "team")
			end
		end
	end

	team.listen_remove_npc_member = function(msg)
		local dismiss = (tonumber(msg.isdismiss) == 1)
		client.team.clearRobotInfo(dismiss)
	end

	team.listen_member_offline_guaji = function(msg)
		local id = msg["role_uid"]
		local mapid = msg["role_map"]
		local member = team.team_members[id]
		if member == nil then
			return
		end
		--修改该玩家标志位离线挂机 并且是在线玩家
		member.membertype = const.TeamMemberType.MEMBER_OFFLINEPLAYER
		member.state = "online"
		member.sceneId = mapid
		team.OnEvent();
	end
	----------------------------------------------------

	--setport
	SetPort("team_create",team.listen_team_create)
	SetPort("team_apply_success",team.cb_team_apply_success)
	SetPort("team_apply_2leader",team.listen_team_apply2Leader)
	SetPort("team_invite_2member",team.listen_team_invite_2member)
	SetPort("team_join", team.listen_team_join_succeed)
	SetPort("team_add_member", team.listen_team_add_member)
	SetPort("team_message", team.listen_team_message)
	SetPort("team_leave", team.listen_team_leave)
	SetPort("team_online", team.listen_team_online)
	SetPort("team_offline", team.listen_team_offline)
	SetPort("dismiss", team.listen_team_dismiss)
	SetPort("team_kick", team.listen_team_kick)
	SetPort("team_change_leader", team.listen_team_change_leader)
	SetPort("team_member_attr", team.listen_team_member_attr)
	SetPort("team_member_change_scene", team.listen_team_member_change_scene)
	SetPort("team_merge_team", team.listen_team_merge_team)
	SetPort("team_team_info", team.listen_team_info)
	SetPort("team_member_get_item", team.listen_team_member_get_item)
	SetPort("remove_npc_member", team.listen_remove_npc_member)
	SetPort("member_offline_guaji", team.listen_member_offline_guaji)

	--
	team.getTeamList = function(includeSelf)
		local list = {};
		for _,v in pairs(team.team_members) do
			if v then
				if includeSelf then
					list[#list + 1] = v;
				elseif v.role_uid ~= DataCache.myInfo.role_uid then
					list[#list + 1] = v;
				end
			end
		end
		return list;
	end

	team.sortTeamList = function(TeamList)
		if TeamList == nil or #TeamList == 0 then
			return TeamList
		end
		table.sort(TeamList, function(a, b)
			if a.role_uid == DataCache.myInfo.role_uid then
				return true
			end
			if b.role_uid == DataCache.myInfo.role_uid then
				return false
			end
			return a.role_uid < b.role_uid
		end)
		return TeamList
	end

	team.getOldTeamList = function()
		local list = {};
		for _,v in pairs(team.old_team_members) do
			if v then
				list[#list + 1] = v;
			end
		end
		return list;
	end

	team.haveTeam = function()
		return #team.getTeamList(true) > 0; 
	end

	team.forbidTeam = function()
		local scene = tb.SceneTable[DataCache.scene_sid]
		return scene.teamMode == 1;
	end

	team.getApplyList = function()
		local list = {};
		for _,v in pairs(team.apply_lst) do
			if v then
				list[#list + 1] = v;
			end
		end
		table.sort(list, function (a, b) 
			return a.time > b.time; 
			end);
		return list;
	end

	team.getInviteList = function ()
		local list = {};
		for _,v in pairs(team.invite_lst) do
			if v then
				list[#list + 1] = v;
			end
		end
		table.sort(list, function (a, b) 
			return a.time > b.time; 
			end);
		return list;
	end

	team.clearApplyList = function ( )
		team.apply_lst = {};
		UIManager.GetInstance():CallLuaMethod('UITeamMsg.RefreshMsg');
	end

	team.clearInviteList = function ( )
		team.invite_lst = {};
		UIManager.GetInstance():CallLuaMethod('UITeamMsg.RefreshMsg');
	end

	team.removeApplyList = function (role_uid)
		team.apply_lst[role_uid] = nil
		UIManager.GetInstance():CallLuaMethod('UITeamMsg.RefreshMsg');
	end

	team.removeInviteList = function (role_uid)
		team.invite_lst[role_uid] = nil
		UIManager.GetInstance():CallLuaMethod('UITeamMsg.RefreshMsg');
	end

	team.isRoleInMyTeam = function(role_uid)
		return team.team_members ~=nil and team.team_members[role_uid] ~= nil 
	end

	team.isLeader = function( uid )
		return uid == team.team_leader_uid;
	end

	team.updateMemberHp = function(info)
		local params = info:split();
		local role_uid = tonumber(params[1]);
		local hp = tonumber(params[2]);
		local maxhp = tonumber(params[3]);
		if team.team_members[role_uid] then
			team.team_members[role_uid].hp = hp;
			team.team_members[role_uid].maxhp = maxhp;
			team.team_members[role_uid].targetName = team.getAttackTargetName(role_uid);
			team.OnEvent();
		end
	end

	team.getTeamInfo = function ()
		team.q_get_team();
        team.q_get_apply_list();
        team.q_get_invite_list();
	end

	team.clearRobotInfo = function(dismiss)
		if team == nil then
			return
		end
		if team.team_members == nil then
			return
		end
		local robotList = {}
		for k,v in pairs(team.team_members) do
			local memberInfo = v
			if memberInfo.membertype == const.TeamMemberType.MEMBER_ROBOT then
				--是npc 目前是机器人
				robotList[#robotList+1] = memberInfo.role_uid
			end
		end
		for k,v in pairs(robotList) do
			client.team.do_team_leave(v)
		end


		--若队伍中只有自己是真人，则需要清除掉假的队伍标记
        if dismiss == true then
            client.team.clearTeam()
            client.team.OnEvent()
        end
	end

	team.haveRobotMember = function()
		if team == nil then
			return false
		end
		if team.team_members == nil then
			return false
		end
		for k,v in pairs(team.team_members) do
			local memberInfo = v
			if memberInfo.membertype == const.TeamMemberType.MEMBER_ROBOT then
				return true
			end
		end
		return false
	end

	team.ClearTrueMember = function()
		if team == nil then
			return 
		end
		if team.team_members == nil then
			return 
		end
		local trueMemberList = {}
		for k,v in pairs(team.team_members) do
			local memberInfo = v
			if memberInfo.membertype ~= const.TeamMemberType.MEMBER_ROBOT and memberInfo.role_uid ~= DataCache.myInfo.role_uid then
				trueMemberList[#trueMemberList + 1] = memberInfo.role_uid
			end
		end

		for k,v in pairs(trueMemberList) do
			client.team.do_team_leave(v)
		end
	end

	team.getMemberInfo = function(role_uid)
		return team.team_members[role_uid]
	end

	team.updateMemberFlag = function()
		local teamList = team.getTeamList(true);
		local oldTeamList = team.getOldTeamList();
		for i=1,#oldTeamList do
			local member = oldTeamList[i];
			local uid = member.role_uid;
			--现在不在队中的，将队伍图标隐藏
			if team.isRoleInMyTeam(uid) == false then
				team.HideTeamFlag(uid, member.membertype);
			end
		end
		--记录下当前的队伍状态
		team.old_team_members = {}
		for k,v in pairs(team.team_members) do
			team.old_team_members[k] = v
		end

		for i=1,#teamList do
			local member = teamList[i];
			local uid = member.role_uid;
			team.ShowTeamFlag(uid)
		end
	end

	team.HideTeamFlag = function(uid, membertype)
		local nodeId = uid * 10 + 1;
		if membertype ~= const.TeamMemberType.MEMBER_TRUE then
			--特殊处理 离线玩家id
			nodeId = uid * 10 + 7;
		end
		--现在不在队中的，将队伍图标隐藏
		if AvatarCache.HasAvatar(nodeId) then
			local HeadTitle = uFacadeUtility.GetAvatarTitle(nodeId);
			local name = HeadTitle:GO("Panel.Other.Name");
			local teamFlag = HeadTitle:GO("Panel.Other.TeamFlag");
			teamFlag.gameObject:SetActive(false);
		else
		end
	end

	team.ShowTeamFlag = function(uid)
		if not team.isRoleInMyTeam(uid) then
			return
		end
		local team_data = team.team_members[uid]
		local nodeId = uid * 10 + 1;
		if team_data.membertype ~= const.TeamMemberType.MEMBER_TRUE then
			--特殊处理 离线玩家id
			nodeId = uid * 10 + 7;
		end
		if AvatarCache.HasAvatar(nodeId) then
			local HeadTitle = uFacadeUtility.GetAvatarTitle(nodeId);
			local name = HeadTitle:GO("Panel.Other.Name");
			local teamFlag = HeadTitle:GO("Panel.Other.TeamFlag");
			teamFlag.gameObject:SetActive(true);
			local bIsLeader = team.isLeader(uid);
			if bIsLeader == true then
				teamFlag.sprite = "tb_duizhang";
			else
				teamFlag.sprite = "tb_duiyou";
			end
			local teamTransform = teamFlag:GetComponent("RectTransform");
			local nameTransform = name:GetComponent("RectTransform");	
			local nameWidth = name.textWidth;
			local anchoredPositionY = teamTransform.anchoredPosition.y;
			if teamTransform ~= nil and nameTransform ~= nil then
				MainUI.this:Delay(0.1,function()
					if not AvatarCache.HasAvatar(nodeId) then
						return;
					end
					if HeadTitle ~= nil then
						local teamFlag = HeadTitle:GO("Panel.Other.TeamFlag");
						if teamFlag ~= nil then
							local teamTransform = teamFlag:GetComponent("RectTransform");
							if teamTransform ~= nil then
								teamTransform.anchoredPosition = Vector2.New(nameWidth/2 + 5, anchoredPositionY);
							end
						end
					end
				end)
			end
		end
	end

	team.haveTeamMsgLeft = function()
		local count_apply = 0
		local count_invite = 0
        --遍历？
        for k,v in pairs(team.apply_lst) do
        	count_apply = count_apply + 1
            -- return true
        end
        for k,v in pairs(team.invite_lst) do
        	count_invite = count_invite + 1
            -- return true
        end
        return count_apply, count_invite
	end

	team.getTeamMemberCount = function()
		local count = 0
		for k,v in pairs(team.team_members) do
			count = count + 1
		end
		return count
	end

	team.AddListener(team.updateMemberFlag);

	--注册事件
	EventManager.register(Event.ON_TEAM_MEMBER_HP_CHANGE, team.updateMemberHp);
	EventManager.register(Event.ON_TIME_SECOND_CHANGE, team.OnSecondAction);

	return team
end

client.team = CreateTeamCtrl();