function UITeamMsgView (param)
	local UITeamMsg = {};
	local this = nil;

	local Close = nil;
	local Top = nil;
	local RoleList = nil;
	local Content = nil;
	local Item = nil;
	local Bottom = nil;
	local invite = nil;
	local clear = nil;

	local warpContent = nil;
	local listenerIndex = nil

	UITeamMsg.MsgPlaneType = {
		ApplyMsgList = 1,
		InviteMsgList = 2, 
	}

	UITeamMsg.MsgType = 0

	function UITeamMsg.Start ()
		this = UITeamMsg.this;
		Close = this:GO('Panel._Close');
		Top = this:GO('Panel._Top');
		RoleList = this:GO('Panel._RoleList');
		Content = this:GO('Panel._RoleList.Grid._Content');
		Item = this:GO('Panel._RoleList.Grid._Item');
		Bottom = this:GO('Panel._Bottom');
		invite = this:GO('Panel._Bottom._invite');
		clear = this:GO('Panel._Bottom._clear');

		--窗口消息类型
		--1) 申请  2) 邀请
		UITeamMsg.MsgType = param.page_type

		--UIWrapperContent
		warpContent = RoleList:GetComponent("UIWarpContent");
		warpContent.goItemPrefab = Item.gameObject;
		warpContent:BindInitializeItem(UITeamMsg.FormatListItem);

		clear:BindButtonClick(UITeamMsg.ClearAll)
		Close:BindButtonClick(UITeamMsg.Close)

		UITeamMsg.RefreshMsg()
		listenerIndex = client.team.AddListener(UITeamMsg.RefreshMsg);
		client.UITeamMsg = this;
	end

	function UITeamMsg.RefreshMsg()
		if client.UITeamMsg == nil and listenerIndex ~= nil then
			client.team.RemoveListener(listenerIndex);
			listenerIndex = nil;
		end
		UITeamMsg.itemList = {}
		--申请列表
		if UITeamMsg.MsgType == UITeamMsg.MsgPlaneType.ApplyMsgList then
			UITeamMsg.itemList = client.team.getApplyList()
			--tile处理
			if Top ~= nil then
				Top:GO('Text').text = "申请组队列表"
			end
		--邀请列表
		elseif UITeamMsg.MsgType == UITeamMsg.MsgPlaneType.InviteMsgList then
			UITeamMsg.itemList = client.team.getInviteList()
			--tile处理
			if Top ~= nil then
				Top:GO('Text').text = "邀请组队列表"
			end
		end
		warpContent:Init(#UITeamMsg.itemList)
		--发出红点检查事件信息
		EventManager.onEvent(Event.ON_REDPOINT_TEAMMSG)
	end

	function UITeamMsg.FormatListItem(go, index)
		local info = UITeamMsg.itemList[index];
		if info == nil then
			return
		end
		local wrapper = go:GetComponent("UIWrapper");
		if wrapper ~= nil then
			local icon = wrapper:GO("_icon.img");
			icon.sprite = string.format("tx_%s_%d", info.career, info.sex)
			local name = wrapper:GO("_name");
			name.text = info.name
			local lv = wrapper:GO("_lv");
			lv.text = string.format("Lv.%d", info.level)
			--local title = wrapper:GO("_title");
			local career = wrapper:GO("_career");
			career.sprite = string.format("tb_career_%s", info.career)
		
			local agreeBtn = wrapper:GO('_agreeBtn')
			agreeBtn:BindButtonClick(function()
				if UITeamMsg.MsgType == UITeamMsg.MsgPlaneType.ApplyMsgList then
					--申请列表需要有队伍
					local haveTeam = client.team.haveTeam()
					local isLeader = haveTeam and client.team.isLeader(DataCache.myInfo.role_uid)
					if not isLeader then
						return
					end
				end
				if UITeamMsg.MsgType == UITeamMsg.MsgPlaneType.ApplyMsgList then
					client.team.q_accept_apply(info.role_uid);
				elseif UITeamMsg.MsgType == UITeamMsg.MsgPlaneType.InviteMsgList then
					client.team.q_accept_invite(info.role_uid);
				end
				UITeamMsg.RefreshMsg()
			end)

			local rejuctBtn = wrapper:GO('_rejuctBtn')
			rejuctBtn:BindButtonClick(function()
				if UITeamMsg.MsgType == UITeamMsg.MsgPlaneType.ApplyMsgList then
					--申请列表需要有队伍
					local haveTeam = client.team.haveTeam()
					local isLeader = haveTeam and client.team.isLeader(DataCache.myInfo.role_uid)
					if not isLeader then
						return
					end
				end
				if UITeamMsg.MsgType == UITeamMsg.MsgPlaneType.ApplyMsgList then
					client.team.q_refuse_apply(info.role_uid);
				elseif UITeamMsg.MsgType == UITeamMsg.MsgPlaneType.InviteMsgList then
					client.team.q_refuse_invite(info.role_uid);
				end
				UITeamMsg.RefreshMsg()
			end)
		end
	end

	function UITeamMsg.ClearAll()
		if UITeamMsg.MsgType == UITeamMsg.MsgPlaneType.ApplyMsgList then
			client.team.q_refuse_all_apply()
			-- client.team.clearApplyList()
		elseif UITeamMsg.MsgType == UITeamMsg.MsgPlaneType.InviteMsgList then
			client.team.q_refuse_all_invite()
			-- client.team.clearInviteList()
		end

		UITeamMsg.itemList = {}
		warpContent:Init(#UITeamMsg.itemList)
	end

	function UITeamMsg.Close()
		client.UITeamMsg = nil;
		if listenerIndex ~= nil then
			client.team.RemoveListener(listenerIndex);
			listenerIndex = nil;
		end
		destroy(this.gameObject);
	end

	return UITeamMsg;
end
