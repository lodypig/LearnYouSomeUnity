function UITeamActivityView (param)
	local UITeamActivity = {};
	local this = nil;

	local Close = nil;
	local ActivityButtonGroup = nil;
	local btn = nil;
	local SubButton = nil;
	local btn = nil;
	local Right = nil;
	local TeamButtonGroup = nil;
	local btn = nil;
	local role = nil;
	local choose = nil;
	local rolename = nil;
	local career = nil;
	local lv = nil;
	local Tip = nil;
	local createTeamBtn = nil;
	local leaveTeamBtn = nil;
	local applyListBtn = nil;
	local inviteListBtn = nil;
	local cancelMatchBtn = nil;
	local autoMatchBtn = nil;
	local ActBtnPrefab = nil;
	local SubActBtnPrefab = nil;

	local listenerIndex = nil

	local curMainIndex = 0
	local curSubIndex = 0

	UITeamActivity.curChooseMemberIndex = 0
	UITeamActivity.MemberIDList = {}

	function UITeamActivity.Start ()
		this = UITeamActivity.this;

		Close = this:GO('CommonDlg2._Close');
		ActivityButtonGroup = this:GO('CommonDlg2._ButtonGroup');
		ActBtnPrefab = this:GO('CommonDlg2._btn');
		SubButton = this:GO('_SubButton');
		SubActBtnPrefab = this:GO('_SubButton._btn');
		Right = this:GO('_Right');
		TeamButtonGroup = this:GO('_Right._ButtonGroup');
		btn = this:GO('_Right._ButtonGroup._btn');
		role = this:GO('_Right._ButtonGroup._btn._role');
		choose = this:GO('_Right._ButtonGroup._btn._choose');
		rolename = this:GO('_Right._ButtonGroup._btn._rolename');
		career = this:GO('_Right._ButtonGroup._btn._career');
		lv = this:GO('_Right._ButtonGroup._btn._lv');
		Tip = this:GO('_Right._Tip');
		createTeamBtn = this:GO('_createTeamBtn');
		leaveTeamBtn = this:GO('_leaveTeamBtn');
		applyListBtn = this:GO('_applyListBtn');
		inviteListBtn = this:GO('_inviteListBtn');
		cancelMatchBtn = this:GO('_cancelMatchBtn');
		autoMatchBtn = this:GO('_autoMatchBtn');

		--bind bottom button
		createTeamBtn:BindButtonClick(function() client.team.q_create(UITeamActivity.Refresh) end)
		leaveTeamBtn:BindButtonClick(function() 
			local haveTeam = client.team.haveTeam()			
			if not haveTeam then
				return
			end
			client.team.q_leave()
		end)
		applyListBtn:BindButtonClick(UITeamActivity.applyList)
		inviteListBtn:BindButtonClick(UITeamActivity.inviteList)
		cancelMatchBtn.gameObject:SetActive(false)
		autoMatchBtn.gameObject:SetActive(false)
		cancelMatchBtn:BindButtonClick(UITeamActivity.cancelMatch)
		autoMatchBtn:BindButtonClick(UITeamActivity.autoMatch)
		Close:BindButtonClick(UITeamActivity.Close)

		--bind Team button
		for i=1,4 do
			local index = i;
			local btn = TeamButtonGroup:GO(tostring(index))
			btn:BindButtonClick(UITeamActivity.ClickMember)
		end

		curMainIndex = 0
		curSubIndex = 0

		--刷新试炼秘境信息
		client.teamAct.RefreshFubenInfo()
		--过滤活动信息
		UITeamActivity.InitActBtn()
		UITeamActivity.Refresh()
		--bind
		listenerIndex = client.team.AddListener(UITeamActivity.Refresh);
		EventManager.bind(this.gameObject, Event.ON_REDPOINT_TEAMMSG, UITeamActivity.RefreshRedPoint);
		EventManager.bind(this.gameObject, Event.ON_FUBEN_MATCH_CHANGE, UITeamActivity.Refresh)
		client.UITeamActivity = this
	end

	function UITeamActivity.InitActBtn()
		--过滤一发组队活动信息
		client.teamAct.filterActCfg(DataCache.myInfo.level)
		--create ActClass Btn
		for i=1,#client.teamAct.ActivityList do
			--创建主Btn
			local ActClass = client.teamAct.ActivityList[i]
			local ActBtn = newObject(ActBtnPrefab)
			ActBtn.gameObject:SetActive(true)
			ActBtn:GO('text').text = ActClass.name			
			ActBtn.transform:SetParent(ActivityButtonGroup.transform)
			ActBtn.transform.localScale = Vector3.one
			--完成进度 TODO
			ActBtn:BindButtonClick(function()
				-- NSY-4756 临时添加 start
				if ActClass.name == "试炼秘境" then
					ui.showMsg("暂未开放，敬请期待！");
					return 
				end
				-- NSY-4756 临时添加 end
				UITeamActivity.ClickMainActBtn(i)
			end)
			ActClass.MainBtn = ActBtn
			ActClass.IsExpand = false
			--创建子Btn
			local SubBtnGroupPrefab = newObject(SubButton)
			SubBtnGroupPrefab.transform:SetParent(ActivityButtonGroup.transform)
			SubBtnGroupPrefab.transform.localScale = Vector3.one
			local SubBtnPreafb = SubBtnGroupPrefab:GO('_btn')
			for j=1,#ActClass.subActList do
				local SubActInfo = ActClass.subActList[j]
				local SubBtn = newObject(SubBtnPreafb)
				SubBtn:GO('text').text = SubActInfo.name
				if SubActInfo.isActive == true then
					SubBtn.gameObject:SetActive(true)
				end
				SubBtn.transform:SetParent(SubBtnGroupPrefab.transform)
				SubBtn.transform.localScale = Vector3.one
				--完成进度 TODO
				--子Btn事件绑定
				SubBtn:BindButtonClick(function() 
					UITeamActivity.ClickSubActBtn(i, j)
				end)
				SubBtn.gameObject:SetActive(true)
				SubActInfo.Btn = SubBtn
			end
			SubBtnGroupPrefab.gameObject:SetActive(false)
			ActClass.SubBtnList = SubBtnGroupPrefab
		end
	end

	local textColor_Expand = Color.New(1,1,1)
	local textColor_Combine = Color.New(175/255, 172/255, 141/255)

	function UITeamActivity.ClickMainActBtn(MainActIndex)
		if client.teamAct.ActivityList == nil or client.teamAct.ActivityList[MainActIndex] == nil then
			return
		end
		local ActClassInfo = client.teamAct.ActivityList[MainActIndex]
		ActClassInfo.SubBtnList.gameObject:SetActive(not ActClassInfo.IsExpand)
		ActClassInfo.IsExpand = not ActClassInfo.IsExpand
		--箭头指向
		ActClassInfo.MainBtn:GO('arrow').sprite = string.format("an_jiantou_%d", ActClassInfo.IsExpand and 3 or 2)
		--文字颜色
		ActClassInfo.MainBtn:GO('text').textColor = ActClassInfo.IsExpand and textColor_Expand or textColor_Combine
		if ActClassInfo.subActList[ActClassInfo.choose] ~= nil then
			local info = ActClassInfo.subActList[ActClassInfo.choose]
			info.Btn.sprite = "an_xuanze_2"
			ActClassInfo.choose = 0
		end
		--记录当前选中
		curMainIndex = MainActIndex 
		curSubIndex = 0
	end

	function UITeamActivity.ClickSubActBtn(MainActIndex, SubActIndex)
		if client.teamAct.ActivityList == nil or client.teamAct.ActivityList[MainActIndex] == nil then
			return
		end
		local ActClassInfo = client.teamAct.ActivityList[MainActIndex]
		if ActClassInfo.subActList == nil or ActClassInfo.subActList[SubActIndex] == nil then
			return
		end
		local SubActInfo = ActClassInfo.subActList[SubActIndex] 
		local SubBtn = SubActInfo.Btn
		if ActClassInfo.choose == 0 then
			--还未选中
			SubBtn.sprite = "an_xuanze_1"
			ActClassInfo.choose = SubActIndex
		elseif ActClassInfo.choose ~= SubActIndex then
			--已经选中
			local oldSubActInfo = ActClassInfo.subActList[ActClassInfo.choose] 
			local oldSubBtn = oldSubActInfo.Btn
			if oldSubBtn ~= nil then
				oldSubBtn.sprite = "an_xuanze_2"
			end
			SubBtn.sprite = "an_xuanze_1"
			ActClassInfo.choose = SubActIndex
		end
		local haveTeam = client.team.haveTeam()
		local isLeader = haveTeam and client.team.isLeader(DataCache.myInfo.role_uid)
		--处理自动匹配按钮
		local isMatch = client.fuben.isMatching(SubActInfo.fubenSid)
		if not isLeader then
			cancelMatchBtn.gameObject:SetActive(false)
			autoMatchBtn.gameObject:SetActive(false)
		else
			cancelMatchBtn.gameObject:SetActive(isMatch)
			autoMatchBtn.gameObject:SetActive(not isMatch)	
		end
		--刷新队员列表UI
		UITeamActivity.RefreshTeamList(isMatch)
		--记录当前选中的
		curMainIndex = MainActIndex 
		curSubIndex = SubActIndex
	end

	function UITeamActivity.Close()
		if listenerIndex ~= nil then
			client.team.RemoveListener(listenerIndex);
			listenerIndex = nil;
		end
		client.UITeamActivity = nil;
		EventManager.removeGO(this.gameObject);
		destroy(this.gameObject);
	end

	function UITeamActivity.Refresh()
		-- print("UITeamActivity.Refresh!!!")
		if listenerIndex ~= nil and client.UITeamActivity == nil then
			client.team.RemoveListener(listenerIndex);
			listenerIndex = nil;
		end
		local match = false
		if curMainIndex ~= 0 and curSubIndex ~= 0 then
			if not(client.teamAct.ActivityList == nil or client.teamAct.ActivityList[curMainIndex] == nil) then
				local ActClassInfo = client.teamAct.ActivityList[curMainIndex]
				if not(ActClassInfo.subActList == nil or ActClassInfo.subActList[curSubIndex] == nil) then
					local SubActInfo = ActClassInfo.subActList[curSubIndex] 
					if SubActInfo ~= nil then
						match = client.fuben.isMatching(SubActInfo.fubenSid)
					end
				end
			end
		end
		--刷新队伍队员缓存
		UITeamActivity.RefreshTeamList(match)
		--刷新下方按钮
		UITeamActivity.RefreshBtns()
		--刷新Right面板
		UITeamActivity.RefreshRight(match)
		--刷新活动按钮面板
		UITeamActivity.RefreshActBtnList()
	end

	function UITeamActivity.RefreshActBtnList()
		--刷新活动完成情况
		--刷新当前活动匹配情况
		for i=1,#client.teamAct.ActivityList do
			local ActInfo = client.teamAct.ActivityList[i]
			if ActInfo ~= nil then
				for j=1,#ActInfo.subActList do
					local fubenSid = ActInfo.subActList[j].fubenSid
					if client.fuben.isMatching(fubenSid) then
						ActInfo.subActList[j].Btn:GO('match').gameObject:SetActive(true)
					else
						ActInfo.subActList[j].Btn:GO('match').gameObject:SetActive(false)
					end
				end
			end
		end
	end

	function UITeamActivity.RefreshBtns()
		local haveTeam = client.team.haveTeam()
		local isLeader = haveTeam and client.team.isLeader(DataCache.myInfo.role_uid)

		createTeamBtn.gameObject:SetActive(not haveTeam)
		leaveTeamBtn.gameObject:SetActive(haveTeam)
		inviteListBtn.gameObject:SetActive(not haveTeam)
		applyListBtn.gameObject:SetActive(isLeader)
		autoMatchBtn.gameObject:SetActive(isLeader)

		UITeamActivity.RefreshRedPoint()
	end

	function UITeamActivity.RefreshRight(bMatch)
		local haveTeam = client.team.haveTeam()
		local isLeader = haveTeam and client.team.isLeader(DataCache.myInfo.role_uid)
		TeamButtonGroup.gameObject:SetActive(haveTeam)
		Tip.gameObject:SetActive(not haveTeam)

		if haveTeam then
			UITeamActivity.RefreshTeamList(bMatch)
		end
	end


	function UITeamActivity.ClickMember(button)
		local index = tonumber(button.name)
		local wrapper = button:GetComponent("UIWrapper");
		--根据当前状态处理 1) exist 2) match 3) add
		if UITeamActivity.MemberIDList == nil then
			return
		end 
		--
		if UITeamActivity.MemberIDList[index] == nil then
			--match or add
			if wrapper:GO('match'):IsShow() then
				return
			end
			if wrapper:GO('+'):IsShow() then
				--可添加成员 弹出 UITeamSearch
				UITeamActivity.ShowUITeamSearch()
			end
		else
			--exist
			-- if UITeamActivity.curChooseMemberIndex == index then
			-- 	return
			-- end
			local lastid = UITeamActivity.MemberIDList[UITeamActivity.curChooseMemberIndex]
			local lastBtn = TeamButtonGroup:GO(tostring(UITeamActivity.curChooseMemberIndex))
			if lastBtn ~= nil then
				lastBtn:GO('_choose').gameObject:SetActive(false)
			end
			wrapper:GO('_choose').gameObject:SetActive(true)
			local id = UITeamActivity.MemberIDList[index]
			UITeamActivity.curChooseMemberIndex = index
			--如果点击的不是自己
			if id ~= DataCache.myInfo.role_uid then
				--弹出opertor菜单
				local MemberInfo = client.team.team_members[id]
				if MemberInfo == nil then
					return
				end
				--重新打开
				UITeamActivity.ShowOperateFloat(MemberInfo, index)
			else
				
			end
		end
	end

	function UITeamActivity.RefreshTeamList(matching)
		-- print("UITeamActivity.RefreshTeamList")
		local count = 0
		--收集并排序队伍成员列表
		local list = client.team.getTeamList(true);
        --排序一下(自己放在最前面)
        list = client.team.sortTeamList(list)
        UITeamActivity.MemberIDList = {}
        for i=1,#list do
        	count = count +1
        	local btn = TeamButtonGroup:GO(tostring(i))
        	local data = list[i]
			UITeamActivity.ShowTeamBtn(btn, UITeamActivity.TeamBtnType.exist, data)
			UITeamActivity.MemberIDList[i] = data.role_uid
        end
		--剩余btn隐藏(或者显示匹配)
		if count < const.team_max_member then
			for j=count+1,const.team_max_member do
				local btn = TeamButtonGroup:GO(tostring(j))
				if matching then
					UITeamActivity.ShowTeamBtn(btn, UITeamActivity.TeamBtnType.match, nil)
				else
					UITeamActivity.ShowTeamBtn(btn, UITeamActivity.TeamBtnType.add, nil)
				end
			end
		end
	end

	UITeamActivity.TeamBtnType = {
		exist = 1,
		match = 2,
		add = 3,
		hide = 4,
	}

	function UITeamActivity.ShowTeamBtn(btn, showType, info)
		if showType == UITeamActivity.TeamBtnType.exist then
			if info == nil then
				return
			end
			btn.gameObject:SetActive(true)
			btn:GO('_role').gameObject:SetActive(true)
			local filename = string.format("dk_role_%s", info.career)
			btn:GO('_role').sprite = filename
			btn:GO('_rolename').text = info.name
			btn:GO('_lv').text = string.format("lv.%d", info.level)
			local curId = UITeamActivity.MemberIDList[UITeamActivity.curChooseMemberIndex]
			btn:GO('_choose').gameObject:SetActive(curId == info.role_uid)
			btn:GO('match').gameObject:SetActive(false)
			btn:GO('+').gameObject:SetActive(false)
		elseif showType == UITeamActivity.TeamBtnType.match then
			-- print("show match btn!!")
			btn.gameObject:SetActive(true)
			btn:GO('_role').gameObject:SetActive(false)
			btn:GO('_rolename').text = ""
			btn:GO('_lv').text = ""
			btn:GO('_choose').gameObject:SetActive(false)
			btn:GO('match').gameObject:SetActive(true)
			btn:GO('+').gameObject:SetActive(false)
		elseif showType == UITeamActivity.TeamBtnType.add then
			btn.gameObject:SetActive(true)
			btn:GO('_role').gameObject:SetActive(false)
			btn:GO('_rolename').text = ""
			btn:GO('_lv').text = ""
			btn:GO('_choose').gameObject:SetActive(false)
			btn:GO('match').gameObject:SetActive(false)
			btn:GO('+').gameObject:SetActive(true)
		elseif showType == UITeamActivity.TeamBtnType.hide then
			btn.gameObject:SetActive(false)
		end
	end

	function UITeamActivity.autoMatch()
		client.teamAct.MatchAct(curMainIndex, curSubIndex, function(Btn)
			--显示正在匹配
			Btn:GO('match').gameObject:SetActive(true)
			--匹配按钮更新
			cancelMatchBtn.gameObject:SetActive(true)
			autoMatchBtn.gameObject:SetActive(false)
			--成员面板的match图标显示 add图标隐藏
			UITeamActivity.RefreshTeamList(true)
			UITeamActivity.RefreshActBtnList()
		end)
	end

	function UITeamActivity.cancelMatch()
		client.teamAct.CancelMatchAct(curMainIndex, curSubIndex, function(Btn)
			--显示取消匹配
			Btn:GO('match').gameObject:SetActive(false)
			--匹配按钮更新
			cancelMatchBtn.gameObject:SetActive(false)
			autoMatchBtn.gameObject:SetActive(true)
			--
			UITeamActivity.RefreshTeamList(false)
			UITeamActivity.RefreshActBtnList()
		end)
	end

	function UITeamActivity.ShowOperateFloat(MemberInfo, index)
        local btnList = nil
        if MemberInfo.role_uid == DataCache.myInfo.role_uid then
        	--自己只有这两个
        	btnList = {"sendPos", "leaveTeam"}
        else
        	btnList = {"goTo", "sendPos", "roleInfo", "addFriend"};
        	local haveTeam = client.team.haveTeam()
	        local isLeader = haveTeam and client.team.isLeader(DataCache.myInfo.role_uid)
	        if isLeader then
	        	table.insert(btnList, "changeLeader");
	        	table.insert(btnList, "removeTeam");
	        end
        end
        local posInfo = const.operateFloatPos.team
        posInfo.pos = Vector3.New(198 + 222 * (index - 1), -72.3)
        ui.ShowOperateFloat(MemberInfo, btnList, posInfo, this, function()  end)
	end

	function UITeamActivity.ShowUITeamSearch()
       PanelManager:CreateConstPanel('UITeamSearch', UIExtendType.NONE, {}); 
    end

    
	function UITeamActivity.applyList()
		--打开队伍申请列表
		UITeamActivity.ShowUITeamMsg(1)
	end

	function UITeamActivity.inviteList()
		--打开邀请列表
		UITeamActivity.ShowUITeamMsg(2)
	end

    function UITeamActivity.ShowUITeamMsg(type)
       	PanelManager:CreateConstPanel('UITeamMsg', UIExtendType.NONE, {page_type = type}); 
       	--clear redpoint
       	client.team.redPoint_Sum = false
		MainUI.checkTeamMsgRedPoint()
    end

    function UITeamActivity.RefreshRedPoint()
    	--红点显示
		inviteListBtn:GO('redpoint').gameObject:SetActive(client.team.redPoint_Sum)
		applyListBtn:GO('redpoint').gameObject:SetActive(client.team.redPoint_Sum)
    end

	return UITeamActivity;
end