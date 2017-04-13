function UITeamSearchView ()
	local UITeamSearch = {};
	local this = nil;

	local Close = nil;
	local Top = nil;
	local BtnUnion = nil;
	local BtnFriend = nil;
	local BtnAround = nil;
	local RoleList = nil;
	local Content = nil;
	local Item = nil;
	local Bottom = nil;
	local invite = nil;

	local warpContent = nil;

	UITeamSearch.CurRoleList = {}
	UITeamSearch.ChooseList = {}
	UITeamSearch.CurPage = 0

	function UITeamSearch.Start ()
		this = UITeamSearch.this;
		Close = this:GO('Panel._Close');
		Top = this:GO('Panel._Top');
		BtnUnion = this:GO('Panel._Top._BtnUnion');
		BtnFriend = this:GO('Panel._Top._BtnFriend');
		BtnAround = this:GO('Panel._Top._BtnAround');
		RoleList = this:GO('Panel._RoleList');
		Content = this:GO('Panel._RoleList.Grid._Content');
		Item = this:GO('Panel._RoleList.Grid._Item');
		Bottom = this:GO('Panel._Bottom');
		invite = this:GO('Panel._Bottom._invite');

		Close:BindButtonClick(UITeamSearch.Close)

		invite:BindButtonClick(UITeamSearch.DoInvite)
		BtnUnion:BindButtonClick(function() UITeamSearch.ClickTab(1) end)
		BtnFriend:BindButtonClick(function() UITeamSearch.ClickTab(2) end)
		BtnAround:BindButtonClick(function() UITeamSearch.ClickTab(3) end)

		--UIWrapperContent
		warpContent = RoleList:GetComponent("UIWarpContent");
		warpContent.goItemPrefab = Item.gameObject;
		warpContent:BindInitializeItem(UITeamSearch.FormatListItem);

		UITeamSearch.CurRoleList = {}
		UITeamSearch.BtnList = {BtnUnion, BtnFriend, BtnAround}
		--目前默认选中附近人分页
		UITeamSearch.ClickTab(3)

		client.UITeamSearch = this;
	end

	local colorText_Choose = Color.New(1,1,1)
	local colorText_Normal = Color.New(229/255, 213/255, 183/255)

	function UITeamSearch.ClickTab(tabIndex)
		if tabIndex == 1 then
			--公会页面
			client.legion.get_Legion_Member_List(UITeamSearch.UpdateLegionRoleList)
		elseif tabIndex == 2 then
			--好友页面
			ui.showMsg("功能暂未开放")
			return
		elseif tabIndex == 3 then
			--附近页面
			client.team.q_find_players_around(UITeamSearch.UpdateAroundRoleList);
		end

		--更新UI
		UITeamSearch.CurPage = tabIndex
		for i=1,#UITeamSearch.BtnList do
			local btn = UITeamSearch.BtnList[i]
			btn:GO('Image').gameObject:SetActive(i==tabIndex)
			btn:GO('Text').textColor = ((i==tabIndex) and colorText_Choose or colorText_Normal)
		end
	end

	--更新公会在线玩家
	function UITeamSearch.UpdateLegionRoleList()
		UITeamSearch.CurRoleList = {}
		--只保留在线玩家
		for k,v in pairs(client.legion.MemberList) do
			--构造玩家信息
			if tonumber(v.Id) ~= DataCache.myInfo.role_uid then
				local info = {}
				info.role_uid = tonumber(v.Id)
				info.career = v.Career
				info.level = v.Level
				info.name = v.Name
				info.sex = 1		--TODO
				UITeamSearch.CurRoleList[#UITeamSearch.CurRoleList + 1] = info
			end
		end
		UITeamSearch.ChooseList = {}
		warpContent:Init(#UITeamSearch.CurRoleList)
	end

	--更新附近在线玩家
	function UITeamSearch.UpdateAroundRoleList()
		UITeamSearch.CurRoleList = {}
		for k,v in pairs(client.team.players_around) do
			UITeamSearch.CurRoleList[#UITeamSearch.CurRoleList + 1] = v
		end
		UITeamSearch.ChooseList = {}
		if UITeamSearch.CurRoleList == nil then
			return
		end
		warpContent:Init(#UITeamSearch.CurRoleList)
	end

	function UITeamSearch.FormatListItem(go, index)
		local info = UITeamSearch.CurRoleList[index];
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
			local YButton = wrapper:GO("_Button._Y");
			YButton.gameObject:SetActive(false)
			--local title = wrapper:GO("_title");
			local career = wrapper:GO("_career");
			career.sprite = string.format("tb_career_%s", info.career)
		
			wrapper:BindButtonClick(function(_go)
				local _wrapper = _go:GetComponent("UIWrapper");
				local YButton = _wrapper:GO("_Button._Y");
				if UITeamSearch.ChooseList[index] == nil then
					UITeamSearch.ChooseList[index] = info.role_uid
					YButton.gameObject:SetActive(true)
				else
					UITeamSearch.ChooseList[index] = nil
					YButton.gameObject:SetActive(false)
				end
		    end)
		end	
	end

	function UITeamSearch.DoInvite()
		if UITeamSearch.ChooseList == nil or #UITeamSearch.ChooseList == 0 then
			return
		end
		for k,v in pairs(UITeamSearch.ChooseList) do
			local index = k
			local role_uid = v
			local info = UITeamSearch.CurRoleList[index];
			if info ~= nil then
				client.team.q_invite_team(tonumber(role_uid), info.name)
			end
		end
	end
	
	function UITeamSearch.Close()
		client.UITeamSearch = nil;
		destroy(this.gameObject);
	end

	return UITeamSearch;
end
