function MainUITeamView()
    local MainUITeam = {};
    local this = nil;

    --队伍面板
    local teamPanel = nil;    --队伍列表
    local panelPos = nil;

    local btnAddMember = nil;     --队伍列表里的增加队员按钮
    local btnTeam = nil;     --队伍列表里的增加队员按钮

    local teamItem = nil;
    local teamGrid = nil;
    local teamList = {};
    local listenerIndex;

    local chooseTeamMemberIndex = 0

	function  MainUITeam.Start()      
		this = MainUITeam.this;

        --队伍区域
        teamPanel = this:GO('TeamPanel');
        panelPos = teamPanel.transform.localPosition;
        teamItem = this:GO('TeamPanel.teamList.teamItem');
        teamItem.gameObject:SetActive(false);
        teamGrid = this:GO('TeamPanel.teamList');
        btnAddMember = this:GO('TeamPanel.btnAddTeam');
        btnAddMember:BindButtonClick(MainUI.ShowUITeamSearch);
        btnTeam = this:GO('TeamPanel.btnTeam');
        btnTeam:GO('createTeam'):BindButtonClick(function() client.team.q_create(MainUI.ShowUITeamActivity) end);
        btnTeam:GO('aroundTeam'):BindButtonClick(MainUI.ShowUITeamAround);

        listenerIndex = client.team.AddListener(MainUI.RefreshTeamList);
        
        MainUI.RefreshTeamList();
        EventManager.bind(this.gameObject,Event.ON_MAINUI_HIDE, MainUITeam.Hide);
        EventManager.bind(this.gameObject,Event.ON_MAINUI_SHOW, MainUITeam.Show);
        MainUITeam.SetActive(false);
	end

    function MainUITeam.FirstUpdate()
        client.team.getTeamInfo();
    end

    function MainUITeam.OnDestroy(  )
        if listenerIndex ~= nil then
            client.team.RemoveListener(listenerIndex);
            listenerIndex = nil;
        end
    end

   function MainUITeam.Hide()
        teamPanel.transform:DOLocalMoveX(panelPos.x - 600, 0.5, false);
    end
    -- 点击按钮飘出
    function MainUITeam.MoveOut()
        teamPanel.transform:DOLocalMoveX(panelPos.x - 300, 0.3, false):SetEase(DG.Tweening.Ease.InBack);
    end 

    function MainUITeam.Show()
        if const.leftPanelShrink then
            teamPanel.transform:DOLocalMoveX(panelPos.x, 0.3, false);
        end
    end

    function MainUITeam.MoveIn()
        teamPanel.transform:DOLocalMoveX(panelPos.x, 0.3, false);
    end

    function MainUITeam.SetActive(isShow)
        teamPanel.gameObject:SetActive(isShow);
    end

    function MainUI.ShowTeamPanel(show )
        teamPanel.gameObject:SetActive(show);
    end

    function MainUITeam.OnAwake()
        if chooseTeamMemberIndex ~= 0 then
            local lstChoose = teamList[chooseTeamMemberIndex]:GO('Item.choose')
            lstChoose.gameObject:SetActive(false)
        end
        chooseTeamMemberIndex = 0
    end


    --显示新队伍界面
    function MainUI.ShowUITeamActivity()
        if MainUI.CheckUITeamMsgList() then
            return
        end
        PanelManager:CreatePanel('UITeamActivity', UIExtendType.TRANSMASK, nil); 
    end

    function MainUI.CheckUITeamMsgList()
        if not client.team.redPoint_Sum then
            return
        end
        local applyCount, inviteCount = client.team.haveTeamMsgLeft() 
        if client.team.haveTeam() then
            if applyCount ~= 0 then
                MainUI.applyList()
                return true
            end
        else
            if inviteCount ~= 0 then
                MainUI.inviteList()
                return true
            end
        end
        return false
    end

    --显示附近队伍
    function MainUI.ShowUITeamAround()
        if client.UITeamAround ~= nil then
            return
        end
        PanelManager:CreateConstPanel('UITeamAround', UIExtendType.NONE, nil);  
    end

    --刷新队伍信息
    function MainUI.RefreshTeamList()
        local list = client.team.getTeamList(true);
        --排序一下(自己放在最前面)
        list = client.team.sortTeamList(list)
        -- list[#list + 1] = list[1]
        -- list[#list + 1] = list[1]
        -- list[#list + 1] = list[1]
        --头像区队长标识
        local isLeader = client.role.isTeamLeader()
        if MainUI.ShowTeamLeaderFlag == nil then
            return;
        end
        
        MainUI.ShowTeamLeaderFlag(client.role.isTeamLeader());
        MainUI.FormatTeamBtnText();
        
        for i=1, #list do
            if i > #teamList then
                local go = newObject(teamItem.gameObject);
                go.transform:SetParent(teamGrid.transform);
                go.transform.localScale = Vector3.one;
                go.transform.localPosition = Vector3.zero;
                -- print("new teamList")
                teamList[i] = go:GetComponent("UIWrapper");
                teamList[i]:GO('Item.State.Image'):PlayUIEffectForever(this.gameObject, "zhishijiantou");

                --teamList[i]:GO('Item.spSelected').gameObject:SetActive(false);
            end
            local data = list[i];
            -- if teamList == nil then
            --   	--print("teamList error")
            -- end
            -- if teamList[i] == nil then
            --   	--print("teamList[i] error")
            -- end
            teamList[i].gameObject:SetActive(true);
            teamList[i]:BindButtonClick(function(btn)
                local param = {};
                param.data = data;
                param.posY = teamList[i].transform.position.y;
                param.teamObj = teamList[i]:GO('Item');

                --显示choose黄色框框
                -- local choose = teamList[i]:GO('Item.choose')
                -- if i ~= chooseTeamMemberIndex and chooseTeamMemberIndex ~= 0 then
                --     local lstChoose = teamList[chooseTeamMemberIndex]:GO('Item.choose')
                --     lstChoose.gameObject:SetActive(false)
                -- end
                -- chooseTeamMemberIndex = i
                -- choose.gameObject:SetActive(true)
                --显示OperatorFloat
                MainUI.ShowOperateFloat(data,nil)
            end)
            
            MainUI.FormatTeamMemberUI(teamList[i], data)
        end

        for i=#list + 1, #teamList do
            teamList[i].gameObject:SetActive(false);
        end

        --有队伍的时候隐藏
        local haveTeam = client.team.haveTeam()
        if haveTeam == true then
            --满员时隐藏
            btnAddMember.gameObject:SetActive(#list ~= 4);    
            --设置其位置 在最后一个玩家条目下面
            if #list ~= 4 then
                btnAddMember.transform.localPosition = Vector3.New(0, -72.2 * #list, 0)
            end
        else 
            --没有队伍时隐藏
            btnAddMember.gameObject:SetActive(false);    
        end
        if btnTeam:IsShow() ~= not haveTeam then
            btnTeam.gameObject:SetActive(not haveTeam)
        end
    end

    function MainUI.FormatTeamMemberUI(TeamUI, data)
        TeamUI:GO('Item.Name').text = data.name;
        local hp = tonumber(data.hp)
        local maxhp = tonumber(data.maxhp)
        if maxhp ~= 0 and maxhp ~= nil and hp ~= nil then
            TeamUI:GO('Item.Hp.Value').fillAmount = hp / maxhp;
        end
        if data.career == "soldier" then
            TeamUI:GO('Item.icon').sprite = "tb_soldier";
        elseif data.career == "magician" then
            TeamUI:GO('Item.icon').sprite = "tb_magician";
        else
            TeamUI:GO('Item.icon').sprite = "tb_bowman";
        end 

        TeamUI:GO('Item.Slot.Level').text = data.level;
        TeamUI:GO('Item.Slot.Leader').gameObject:SetActive(client.team.team_leader_uid == data.role_uid);
        TeamUI:GO('Item.Slot.Icon').sprite = string.format("tx_%s_%s",data.career,data.sex);
        TeamUI:GO('Item.Slot.mask').gameObject:SetActive(data.disstate == "faraway" and data.role_uid ~= DataCache.myInfo.role_uid);
        if (data.state == "offline" or hp == nil or hp <= 0 or (data.sceneId ~= DataCache.scene_sid or data.line ~= DataCache.fenxian) ) and data.role_uid ~= DataCache.myInfo.role_uid then
            Util.SetGray(TeamUI.gameObject, true);
        else
            Util.SetGray(TeamUI.gameObject, false);
        end

        --显示队员状态
        -- print("-----------------------")
        -- print(data.targetName)
        -- print(data.sceneId)
        -- print(DataCache.scene_sid)
        -- print(data.line)
        -- print(DataCache.fenxian)
        local stateText = TeamUI:GO("Item.State");
        if data.state == "offline" then
            stateText.text = "<color=#b5b5b5>         离线</color>";
            TeamUI:GO('Item.Slot.Level').text = string.format("<color=#b5b5b5>%s</color>", data.level);
            TeamUI:GO('Item.Name').text = string.format("<color=#b5b5b5>%s</color>", data.name);
        -- elseif data.sceneId ~= DataCache.scene_sid or data.line ~= DataCache.fenxian then
        --     if SceneManager.IsFubenMap(data.sceneId) then
        --         stateText.text = "<color=#ffd967>副本中</color>";
        --     else
        --         --当前玩家的场景信息没有同步 直接取本地信息
        --         if data.role_uid == DataCache.myInfo.role_uid then
        --             stateText.text = string.format("<color=#ffd967>%s·%s线</color>", tb.SceneTable[DataCache.scene_sid].name, data.line);
        --         else
        --             stateText.text = string.format("<color=#ffd967>%s·%s线</color>", tb.SceneTable[data.sceneId].name, data.line);    
        --         end
        --     end
        -- elseif data.disstate == "faraway" then
        --     stateText.text = "  距离过远";
        -- elseif data.targetName ~= nil then
        --     stateText.text = data.targetName;
        else
            stateText.text = "";
        end
        --设置打怪箭头
        stateText:GO("Image").gameObject:SetActive(data.targetName ~= nil);
    end

    function MainUI.applyList()
        --打开队伍申请列表
        MainUI.ShowUITeamMsg(1)
    end

    function MainUI.inviteList()
        --打开邀请列表
        MainUI.ShowUITeamMsg(2)
    end

    function MainUI.ShowUITeamMsg(type)
        if client.UITeamMsg ~= nil then
            return
        end
        PanelManager:CreateConstPanel('UITeamMsg', UIExtendType.NONE, {page_type = type}); 
    end

    function MainUI.ShowUITeamSearch()
        if client.UITeamSearch ~= nil then
            return
        end
        --直接打开
        PanelManager:CreateConstPanel('UITeamSearch', UIExtendType.NONE, {}); 
    end

    function MainUI.ShowOperateFloat(MemberInfo,callback)
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
        -- posInfo.pos = Vector3.New(265.9, -207.9)
        ui.ShowOperateFloat(MemberInfo, btnList, posInfo, this, callback)
    end

    return MainUITeam;
end

