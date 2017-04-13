function UIFubenAutoTeamView ()
	local UIFubenAutoTeam = {};
	local this = nil;

	local List = nil;
	local tip = nil;
	local item = nil;
	local itemArray = {};

	function UIFubenAutoTeam.Start ()
		this = UIFubenAutoTeam.this;
		List = this:GO('Panel.ScrollView.Viewport._List');
		tip = this:GO('Panel._Bottom.Tip')
		item = this:GO('Panel.ScrollView.Viewport.item');

		this:GO('Panel._Close'):BindButtonClick(UIFubenAutoTeam.OnClose);
		this:GO('Panel._Bottom.baomingbtn'):BindButtonClick(UIFubenAutoTeam.OnBaoMingAll);
		client.FuBenAutoTeam.AddFuBen = UIFubenAutoTeam.AddFuBen;
		client.FuBenAutoTeam.DeleteFuBen = UIFubenAutoTeam.DeleteFuBen;
		UIFubenAutoTeam.Init(client.FuBenAutoTeam.FubenArray)

	end

	function UIFubenAutoTeam.Update()
		local count = math.min(#client.FuBenAutoTeam.FubenArray,#itemArray)
		for i = 1 ,count do
			UIFubenAutoTeam.UpdateItem(client.FuBenAutoTeam.FubenArray[i])
		end
	end

	function UIFubenAutoTeam.OnClose()
		client.FuBenAutoTeam.AddFuBen = nil;
		client.FuBenAutoTeam.DeleteFuBen = nil;
		destroy(this.gameObject);
	end

	function UIFubenAutoTeam.CanOperate()
		if client.role.haveTeam() then
			return client.team.isLeader(DataCache.roleID)
		end
		return true
	end

	function UIFubenAutoTeam.OnBaoMingAll(go)
		if client.role.haveTeam() and client.team.isLeader(DataCache.roleID) == false then
			ui.showMsg("只有队长可以操作");
            return;
		end

		for i = 1,#itemArray do
			local sid = itemArray[i]:GO('btn'):GetUserData("sid")
			local fuben = client.FuBenAutoTeam.GetFuBen(sid)
			if fuben.state == client.FuBenAutoTeam.StateEnum.Pause then
				UIFubenAutoTeam.OnItemBtnClick(itemArray[i]:GO('btn').gameObject)
			end
		end
	end

	function UIFubenAutoTeam.OnAllPause()
		for i = 1,#itemArray do
			local sid = itemArray[i]:GO('btn'):GetUserData("sid")
			local fuben = client.FuBenAutoTeam.GetFuBen(sid)
			if fuben.state == client.FuBenAutoTeam.StateEnum.Waiting then
				UIFubenAutoTeam.OnItemBtnClick(itemArray[i]:GO('btn').gameObject)
			end
		end
	end

	function UIFubenAutoTeam.AddFuBen(info)
		local go = newObject(item.gameObject);
        go:SetActive(true);
        go.name = 'item'..tostring(#itemArray);
        go.transform:SetParent(List.transform);
        go.transform.localScale = Vector3.one;
        go.transform.localPosition = Vector3.zero;
        local wrapper = go:GetComponent("UIWrapper");  

        local btn = wrapper:GO('btn')
        btn:BindButtonClick(UIFubenAutoTeam.OnItemBtnClick)
        btn:SetUserData("sid", info.sid);

        wrapper:GO('delete'):BindButtonClick(UIFubenAutoTeam.OnDelete)
        wrapper:GO('delete'):SetUserData("sid", info.sid);

        itemArray[#itemArray + 1] = wrapper

		UIFubenAutoTeam.UpdateItem(info)        	
	end

	function UIFubenAutoTeam.GetIndex(sid)
		for i = 1,#itemArray do 
			if itemArray[i]:GO('btn'):GetUserData("sid") == sid then
				return i
			end
		end
		return -1
	end

	function UIFubenAutoTeam.DeleteFuBen(sid)
		local count = List.transform.childCount
		for i = 1,count do
			local id = List.transform:GetChild(i-1).gameObject:GetComponent("UIWrapper"):GO('btn'):GetUserData("sid")
			if  id == sid then
				destroy(List.transform:GetChild(i-1).gameObject)
				local index = UIFubenAutoTeam.GetIndex(sid)
				if index ~= -1 then
					table.remove(itemArray,index);
				end		
			end
		end		
	end

	function UIFubenAutoTeam.Init(Array)
		for i = 1,#Array do
			local info = Array[i];
			UIFubenAutoTeam.AddFuBen(info)
        end
	end

	function UIFubenAutoTeam.UpdateItem(fuben)
		local wrapper = UIFubenAutoTeam.GetWrapperBySid(fuben.sid)
		if wrapper == nil then return end

        local cfg = tb.fuben[fuben.sid]
        if cfg ~= nil then
	        --wrapper:GO('name').text = string.format("<color=%s>%s</color>(%s)",const.fubenDifficultyColor[cfg.difficulty], cfg.name, const.fubenDifficulty[cfg.difficulty]);
	        wrapper:GO('name').text = string.format("<color=%s>%s</color>",const.fubenDifficultyColor[cfg.difficulty], cfg.name);
	        wrapper:GO('namebk').sprite = const.fubenDifficultyBg2[cfg.difficulty]
	    else
	        wrapper:GO('name').text = string.format("<color=%s>随机副本</color>",const.fubenDifficultyColor[1]);
	        wrapper:GO('namebk').sprite = const.fubenDifficultyBg2[1]	    	
	    end

        local IsWaiting = fuben.state == client.FuBenAutoTeam.StateEnum.Waiting

        wrapper:GO('state').text = string.format("已等待：%s",os.date("%M:%S",TimerManager.GetServerNowMillSecond()/1000 - fuben.startTime))

        wrapper:GO('state').gameObject:SetActive(IsWaiting)
        wrapper:GO('btn').gameObject:SetActive(not IsWaiting)
        
	end

	function UIFubenAutoTeam.GetWrapperBySid(sid)
		for i = 1,#itemArray do
			if itemArray[i] and itemArray[i]:GO('btn'):GetUserData("sid") == sid then
				return itemArray[i]
			end
		end
		return nil;
	end


	function UIFubenAutoTeam.OnItemBtnClick(go)
		if not UIFubenAutoTeam.CanOperate() then
			ui.showMsg("只有队长可以操作");
            return;
		end
		local wrapper = go:GetComponent("UIWrapper");
		local sid = wrapper:GetUserData("sid")

		local fuben = client.FuBenAutoTeam.GetFuBen(sid)

		if fuben == nil then 
			return
		end
		if fuben.state == client.FuBenAutoTeam.StateEnum.Pause then
			client.fuben.q_challenge_fuben(fuben.sid, "team");
		end

		client.FuBenAutoTeam.SetState(fuben,client.FuBenAutoTeam.StateEnum.Max - fuben.state)

		UIFubenAutoTeam.UpdateItem(fuben)

	end

	function UIFubenAutoTeam.OnDelete(go)
		if not UIFubenAutoTeam.CanOperate() then
			ui.showMsg("只有队长可以操作");
            return;
		end
		local wrapper = go:GetComponent("UIWrapper");
		local sid = wrapper:GetUserData("sid")

		client.fuben.q_quit_fuben_queue(sid, function() end)
	end


	return UIFubenAutoTeam;
end

function ui.ShowFuBenAutoTeam()
	PanelManager:CreatePanel('UIFubenAutoTeam',UIExtendType.BLACKMASK);
end
