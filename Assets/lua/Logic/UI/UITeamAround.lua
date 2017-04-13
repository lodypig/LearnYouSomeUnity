function UITeamAroundView ()
	local UITeamAround = {};
	local this = nil;

	local Close = nil;
	local Top = nil;
	local RoleList = nil;
	local Content = nil;
	local Item = nil;
	local icon = nil;
	local img = nil;
	local name = nil;
	local lv = nil;
	local Button = nil;
	local Y = nil;
	local title = nil;
	local career = nil;
	local team_count = nil;
	local Bottom = nil;
	local apply = nil;

	local warpContent = nil;

	UITeamAround.TeamList = {}
	UITeamAround.ChooseTeamList = {}

	function UITeamAround.Start ()
		this = UITeamAround.this;
		Close = this:GO('Panel._Close');
		Top = this:GO('Panel._Top');
		RoleList = this:GO('Panel._RoleList');
		Content = this:GO('Panel._RoleList.Grid._Content');
		Item = this:GO('Panel._RoleList.Grid._Item');
		team_count = this:GO('Panel._RoleList.Grid._Item._team_count');
		Bottom = this:GO('Panel._Bottom');
		apply = this:GO('Panel._Bottom._apply');

		Close:BindButtonClick(UITeamAround.Close);
		apply:BindButtonClick(UITeamAround.Apply)

		--UIWrapperContent
		warpContent = RoleList:GetComponent("UIWarpContent");
		warpContent.goItemPrefab = Item.gameObject;
		warpContent:BindInitializeItem(UITeamAround.FormatListItem);

		--获取附近队伍列表
		client.team.q_find_teams_around(UITeamAround.RefreshMsg)
		client.UITeamAround = this;
	end

	function UITeamAround.RefreshMsg(msg)
		local TeamInfoList = msg.teams
		UITeamAround.TeamList = {}
		if TeamInfoList == nil or #TeamInfoList == 0 then
			return
		end
		UITeamAround.TeamList = TeamInfoList
		warpContent:Init(#UITeamAround.TeamList)
	end

	function UITeamAround.FormatListItem(go, index)
		local TeamInfo = UITeamAround.TeamList[index];
		if TeamInfo == nil then
			return
		end
		local LeaderId = TeamInfo.leader
		local TeamUid = TeamInfo.uid
		local LeaderInfo = nil
		for k,v in pairs(TeamInfo.members) do
			if v.role_uid == LeaderId then
				LeaderInfo = v
				break
			end
		end
		local wrapper = go:GetComponent("UIWrapper");
		if wrapper ~= nil then
			local icon = wrapper:GO("_icon._img");
			icon.sprite = string.format("tx_%s_%d", LeaderInfo.career, LeaderInfo.sex)
			local name = wrapper:GO("_name");
			name.text = client.tools.ensureString(LeaderInfo.name)
			local lv = wrapper:GO("_lv");
			lv.text = string.format("Lv.%d", LeaderInfo.level)
			--local title = wrapper:GO("_title");
			local career = wrapper:GO("_career");
			career.sprite = string.format("tb_career_%s", LeaderInfo.career)
			local team_count = wrapper:GO('_team_count')
			team_count.text = string.format("队伍人数：%d", #TeamInfo.members)
			local YButton = wrapper:GO("_Button._Y");
			YButton.gameObject:SetActive(false)

			wrapper:BindButtonClick(function(_go)
				local _wrapper = _go:GetComponent("UIWrapper");
				local YButton = _wrapper:GO("_Button._Y");
				if UITeamAround.ChooseTeamList[TeamUid] == nil then
					--未选中
					UITeamAround.ChooseTeamList[TeamUid] = LeaderInfo
					YButton.gameObject:SetActive(true)
				else
					--已经选中
					UITeamAround.ChooseTeamList[TeamUid] = nil
					YButton.gameObject:SetActive(false)
				end
			end)
		end
	end

	--申请！
	function UITeamAround.Apply()
		if UITeamAround.ChooseTeamList == nil then
			return
		end
		for k,v in pairs(UITeamAround.ChooseTeamList) do
			local team_uid = k
			local LeaderInfo = v
			if LeaderInfo ~= nil then
				client.team.q_apply_team(LeaderInfo.role_uid, client.tools.ensureString(LeaderInfo.name), team_uid)
			end
		end
	end

	function UITeamAround.Close()
		client.UITeamAround = nil;
		destroy(this.gameObject);
	end

	return UITeamAround;
end
