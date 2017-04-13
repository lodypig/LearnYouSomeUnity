function LoginView(param)
	local Login = {}
	local this = nil
	--UI
	local login_panel = nil
	local selectRole_panel = nil
	local createRole_panel = nil

	local l_bk = nil
	local l_loginScene = nil
	local l_ls_btnSelectServer = nil
	local l_ls_btnStart = nil
	local l_ls_selectServer = nil
	local l_ls_selectServer_btnBack = nil
	--local l_ls_selectServer_tfServer = nil
	local l_ls_selectServer_btnServer = nil
	local l_ls_selectServer_serverList = nil
	local l_ls_curSelectServer = nil
	local l_ls_tfDevelopMode = nil
	local l_ls_inputAccountBK = nil
	local l_ls_inputAccount = nil
	local l_ls_AccountEditbox = nil
	local l_ls_AccountBox = nil

	local l_us_bar = nil
	local l_us_tfProgress = nil

	local sr_selectIndex = 0
	local sr_btnStart = nil
	local sr_btnBack = nil
	local sr_roleCount = 4

	local AccountCharacterLimit = 12
	local ls_editbox_oldPos = nil


	----const
	local MainCameraMode = {
		MCM_INGAME = 0,
        MCM_CreateRole = 1,
        MCM_ChooseRole = 2,
        MCM_ServerSelect = 3,
	}


	local l_ls_mapBtnServer2Index = {}

	function Login.Start()
		this = Login.this
		------大面板------
		login_panel = this:GO('login')
		selectRole_panel = this:GO('select-role')
		createRole_panel = this:GO('create-role')

		Login.L_Start()	
		Login.SR_Start()
		Login.CR_Start()

		local uiManager = UIManager.GetInstance();
		local ui = uiManager:FindUI('UpdateScene');
		if ui ~= nil then
    		destroy(ui.gameObject);
    	end
		Login.L_ShowLogin()

		uFacadeUtility.PlayMusic("login");

		local show_login = uFacadeUtility.GetShowLogin();
		if show_login then
			uFacadeUtility.DestroyLoadingUI();
		end
	end

	------------------------------------------
	----------------- common -----------------
	------------------------------------------
	function Login.ShowSelectRole()
		login_panel:Hide()
		selectRole_panel:Show()
		Login.SR_Refresh()
	end

	function Login.BackLogin()
		login_panel:Show()
		selectRole_panel:Hide()
		createRole_panel:Hide()
		Login.L_LS_HideAccountBox()
		SetMainCameraInfo(Vector3.New(9999, 9999, 9999), Vector3.New(9,0,0), Vector3.one, 45, false)
		Util.SwitchMainCameraMode(MainCameraMode.MCM_ServerSelect, "")
	end

	function Login.ShowCreateRole()
		selectRole_panel:Hide()
		createRole_panel:Show()
		Login.CR_RandomCareerSex()
		Login.CR_Init3DCreateRole()
	end

	function Login.BackSelectRole()
		selectRole_panel:Show()
		createRole_panel:Hide()
		Login.SR_Refresh()
	end

	function Login.HideSelectRole()
		selectRole_panel:Hide()
	end

	------------------------------------------
	----------------login面板-----------------
	------------------------------------------	
	function Login.L_Start()
		l_loginScene = this:GO('login.loginScene')
		l_ls_selectServer = this:GO('login.select-server')
		l_bk = this:GO('login.loginScene.bg')
		Login.L_LS_Start()
	end

	function Login.L_ShowLogin()
		l_loginScene:Show()
		SetMainCameraInfo(Vector3.New(9999, 9999, 9999), Vector3.New(9,0,0), Vector3.one, 45, false)
		Util.SwitchMainCameraMode(MainCameraMode.MCM_ServerSelect, "")
	end

	----->>>>>>>> loginScene面板 <<<<<<<<<----
	function Login.L_LS_Start()
		l_ls_mapBtnServer2Index = {}

		l_ls_btnSelectServer = l_loginScene:GO('btn-selectServer')
		l_ls_btnStart = l_loginScene:GO('btn-start')
		l_ls_selectServer_btnBack = l_ls_selectServer:GO('btnBack')
		--l_ls_selectServer_tfServer = l_ls_selectServer:GO('tfServer')
		l_ls_selectServer_btnServer = l_ls_selectServer:GO('bk.right.ServerList.viewport.prefab')
		l_ls_selectServer_serverList = l_ls_selectServer:GO('bk.right.ServerList.viewport.servercontent')
		l_ls_curSelectServer = l_ls_btnSelectServer:GO('curserver')
		l_ls_tfDevelopMode = l_loginScene:GO('tfDevelopMode')
		l_ls_inputAccountBK = l_loginScene:GO('accountbox')
		l_ls_inputAccount = l_loginScene:GO('accountbox.input-account')
		l_ls_inputAccount:BindButtonClick(Login.L_LS_OpenKeyBoard)
		l_ls_inputAccount:BindInputFiledValueChanged(Login.L_LS_InputChanged);

		l_ls_AccountBox = this:GO('login.loginScene.accountbox')
		ls_editbox_oldPos = l_ls_AccountBox:GetComponent('Transform').localPosition;

		l_ls_AccountEditbox = l_ls_inputAccount:GetComponent('EditBox');
		l_ls_AccountEditbox.characterLimit = AccountCharacterLimit
		--l_ls_AccountEditbox.iscenter = true
		l_ls_AccountEditbox:SetCallBack(Login.L_LS_OnHeightChange, Login.L_LS_EditResult);

		l_ls_btnSelectServer:BindButtonClick(Login.L_LS_ShowServerList)
		l_ls_btnStart:BindButtonClick(Login.L_LS_ShowAccountBox)
		l_loginScene:GO('accountbox.L'):BindButtonClick(Login.L_LS_HideAccountBox)
		l_loginScene:GO('accountbox.X'):BindButtonClick(Login.L_LS_HideAccountBox)
		l_ls_inputAccountBK:BindButtonClick(Login.L_LS_HideAccountBox)
		------------------------------------------------------------------
		--EditBox
		-- local editBox = l_ls_inputAccount:GetComponent('EditBox')
		-- l_ls_inputAccount:BindButtonClick(Login.L_LS_OpenKeyBoard);
  --       editBox:SetCallBack(Login.L_LS_SetDetailChatPanelHeight, Login.L_LS_EnterChat)
		-- l_ls_inputAccount:BindInputFiledValueChanged(Login.L_LS_InputNameChanged)
		------------------------------------------------------------------
		l_loginScene:GO('accountbox.btn_login'):BindButtonClick(Login.L_LS_DoLoginButtonClick)
		l_loginScene:GO('btn_gonggao'):BindButtonClick(Login.TempNoOpen)
		l_loginScene:GO('btn_bofang'):BindButtonClick(Login.TempNoOpen)
		l_ls_selectServer_btnBack:BindButtonClick(Login.L_LS_OnServerListClose)
		local lastServerIndex = UnityEngine.PlayerPrefs.GetInt("serverIndex")
		if lastServerIndex ~= 0 then
			ServerListCtrl.SetNetServerInfo(lastServerIndex)
		else
			if AppConst.DevelopMode then
				--开发模式 默认选择本地服
				ServerListCtrl.SetNetServerInfo(3)	
			else
				--非开发模式 默认选择外网
				ServerListCtrl.SetNetServerInfo(2)
			end
		end
		--l_ls_selectServer_tfServer.text = "当前选择："..Net.serverName
		l_ls_curSelectServer.text = Net.serverName
		if AppConst.DevelopMode then
			l_ls_tfDevelopMode.text = "当前模式：开发模式"
			l_ls_tfDevelopMode.gameObject:SetActive(true);
		end
		local account = UnityEngine.PlayerPrefs.GetString("account")
		if account ~= nil then
			l_ls_inputAccount.inputText = account
		end

		local btnServer = l_ls_selectServer_btnServer
		local curServerIndex = UnityEngine.PlayerPrefs.GetInt("serverIndex")
		if curServerIndex <= 0 then
			curServerIndex = 2
		end
		for i=1,#ServerListCtrl.serverList do
			local go = newObject(btnServer)
			go.gameObject:SetActive(true)
			go.transform:SetParent(l_ls_selectServer_serverList.transform)
			go.transform.localScale = Vector3.New(1, 1, 1)
			local info = ServerListCtrl.serverList[i]
			go:GO('name').text = info.name
			go.gameObject.name = i
			l_ls_mapBtnServer2Index[info.name] = i
			go:BindButtonClick(Login.L_LS_ClickServerBtn)
			--for test "龙神创世"显示推荐/火爆
			if info.name == "龙神创世" then
				go:GO('mark'):SetShow(true)
				go:GO('state').sprite = "tb_huobao"
			else
				go:GO('mark'):SetShow(false)
				go:GO('state').sprite = "tb_liuchang"
			end
			if i == curServerIndex then
				go:GO('selected'):SetShow(true)
			else
				go:GO('selected'):SetShow(false)
			end
		end

		Login.L_LS_SetServerContentOffset(curServerIndex)

		
		local show_login = uFacadeUtility.GetShowLogin();
		if not show_login then
			uFacadeUtility.SetShowLogin(true);
			Login.L_LS_DoLoginButtonClick();
		end

		
        uFacadeUtility.DisablePlayerAudioListener();
        uFacadeUtility.EnableMainCameraAudioListener();
	end

	function Login.TempNoOpen()
		ui.unOpenFunc();
	end
	-- ------------------------------
	-- -----EditBox

	function Login.L_LS_OpenKeyBoard()
        local curText = l_ls_inputAccount.inputText;
        l_ls_AccountEditbox:showEditBox(curText);
    end

    function Login.L_LS_CloseKeyBoard()
		if NativeManager.GetInstance().isKeyboardOpened then
			NativeManager.GetInstance():CloseEditBox()
			l_ls_AccountBox:GetComponent('Transform').localPosition = ls_editbox_oldPos
		end
		l_ls_inputAccount.gameObject:SetActive(true);
    end

    function Login.L_LS_InputChanged(text, _inputIndex)
		local newText = Util.CutSubstring(text, AccountCharacterLimit);
		l_ls_inputAccount.inputText = newText;
	end

	function Login.L_LS_OnHeightChange(posY)		
		l_ls_AccountBox:GetComponent('Transform').localPosition = Vector3.New(ls_editbox_oldPos.x, ls_editbox_oldPos.y + posY, ls_editbox_oldPos.z);
	end

	function Login.L_LS_EditResult(text)
    	local newText = Util.CutSubstring(text, AccountCharacterLimit);
    	l_ls_inputAccount.inputText = newText;	
    	l_ls_inputAccount.gameObject:SetActive(true);
    	l_ls_AccountBox:GetComponent('Transform').localPosition = ls_editbox_oldPos;
    end

	 
     ------------------------------

	--设置当前服务器列表的偏移 保证当前选中的服务器在第一行
	function Login.L_LS_SetServerContentOffset(curServerIndex)
		local rowindex = math.floor((curServerIndex-1)/2)
		local viewSize = l_ls_selectServer:GO('bk.right.ServerList'):GetComponent("RectTransform").sizeDelta.y
		local contentSumSize = l_ls_selectServer_serverList:GetComponent("RectTransform").sizeDelta.y
		local maxOffset = math.max(contentSumSize - viewSize, 0)
		l_ls_selectServer_serverList:GetComponent("RectTransform").anchoredPosition = Vector2.New(0, math.min(rowindex * (90 + 9.3), maxOffset))
	end

	function Login.L_LS_ShowServerList()
		l_ls_selectServer:Show()
		l_loginScene:Hide()
		l_bk:Hide()
		local curServerIndex = UnityEngine.PlayerPrefs.GetInt("serverIndex")
		if curServerIndex <= 0 then
			curServerIndex = 2
		end
		Login.L_LS_SetServerContentOffset(curServerIndex)
	end

	function Login.L_LS_OnServerListClose()
		l_ls_selectServer:Hide()
		l_loginScene:Show()
		l_bk:Show()
	end

	function Login.L_LS_ShowAccountBox()
		l_loginScene:GO('accountbox'):Show()
	end

	function Login.L_LS_HideAccountBox()
		l_loginScene:GO('accountbox'):Hide()
		Login.L_LS_CloseKeyBoard()
	end

	function Login.L_LS_DoLoginButtonClick()
		local accountInfo = l_ls_inputAccount:GO("Text").text
		UnityEngine.PlayerPrefs.SetString("account", accountInfo)
		local msg = {cmd = "user_login", account = accountInfo, server = 1}
		Send(msg, function(loginMsg)
			DataCache.userID = loginMsg["user_id"]
            --DataCache.serverID = loginMsg["serverID"]
			local role_list = loginMsg["role_list"]
			client.cacheService.SetRoleInfo(role_list)
			sr_selectIndex = 0
			Login.ShowSelectRole()
		end)
	end

	function Login.L_LS_ClickServerBtn(go)
		local lstServerIndex = UnityEngine.PlayerPrefs.GetInt("serverIndex")
		if lstServerIndex <= 0 then
			lstServerIndex = 2
		end
		l_ls_selectServer_serverList:GO(tostring(lstServerIndex)):GO('selected'):SetShow(false)
		Net.Close()
		local name = go:GetComponent("UIWrapper"):GO('name').text
		local curSelectIndex = l_ls_mapBtnServer2Index[name]
		ServerListCtrl.SetNetServerInfo(curSelectIndex)
		go:GetComponent("UIWrapper"):GO('selected'):SetShow(true)
		UnityEngine.PlayerPrefs.SetInt("serverIndex", curSelectIndex)
		l_ls_curSelectServer.text = Net.serverName
		--点击立即返回登录界面
		Login.L_LS_OnServerListClose()
	end

	------------------------------------------
	-------------select_role面板--------------
	------------------------------------------	
	function Login.SR_Start()
		sr_selectIndex = 0
		sr_btnStart = selectRole_panel:GO('btnStart')
		sr_btnStart.isClickSoundEnable = false;
		--sr_btnStart.isSoundDontDestroyOnLoad = true;
		--sr_btnStart.clickSoundOverride = "enter_game";
		sr_btnStart:BindButtonClick(Login.SR_OnStartClick)
		sr_btnBack = selectRole_panel:GO('btnBack')
		sr_btnBack:BindButtonClick(Login.SR_OnBackClick)
		for i=1,sr_roleCount do
			selectRole_panel:GO('Role.Role'..i..".btnCreateRole"):BindButtonClick(Login.SR_OnCreateClick)
			selectRole_panel:GO('Role.Role'..i..".SelectRole"):BindButtonClick(Login.SR_OnChooseClick)
		end
	end

	function Login.SR_OnBackClick()
		Login.HideAllExistRoleModels(false)
		Login.BackLogin()
		DataCache.userID = 0
		DataCache.roleID = 0
		client.cacheService.RoleInfoList = nil
	end

    function Login.handleLoginOK(info, loginSceneMsg)
    	--记录登陆的角色
    	local userID = DataCache.userID;
    	uFacadeUtility.SavePlayerPrefs("lastRole_" .. userID, tostring(info.id));
		SetMainCameraInfo(Vector3.one, Vector3.one, Vector3.one, 45, false)
    	Util.SwitchMainCameraMode(MainCameraMode.MCM_INGAME, "")
        local attr = loginSceneMsg["attr"]
        DataCache.CachePlayerInfo(info, attr);
        DataCache.guaji_award = loginSceneMsg["guaji_award"]
        local equipment = loginSceneMsg["equipment"]

        if equipment ~= nil then
            Bag.parseEquipment(equipment);
        end

        DataCache.roleID = loginSceneMsg["role_id"]
        DataCache.nodeID = loginSceneMsg["node_id"]
        DataCache.role_money = loginSceneMsg["role_money"]
        DataCache.role_diamond = loginSceneMsg["role_diamond"]
        DataCache.role_goumaili = loginSceneMsg["role_goumaili"]
        DataCache.role_jingtie = loginSceneMsg["role_jingtie"]
        DataCache.talentBook = loginSceneMsg["talentBook"]
        DataCache.contribution = loginSceneMsg["contribution"]
        DataCache.guideList = client.tools.parseArrayList(loginSceneMsg["guide"])
        DataCache.offlineTime = loginSceneMsg["offline_time"]
        DataCache.treasureList = loginSceneMsg["treasure_list"]
        DataCache.treasureNumber = attr.treasure_number;
        DataCache.boxEfficiency = loginSceneMsg["get_box_time"]   
        --print("DataCache.treasureNumber:");
        --print(DataCache.treasureNumber);
        client.horse.onLoginMsg(loginSceneMsg.ride_horse);

        local bagInfo = loginSceneMsg["bag_info"];
        Bag.parseBag(bagInfo[1], bagInfo[2], bagInfo[3], bagInfo[4]);
        
        client.StoneNumberTable[DataCache.nodeID] = attr.energy_stone;

        client.CBTCtrl.get_cbt_info();
        FashionSuit.init();
        client.newSystemOpen.getAllNewSystemInfo();
        activity.RequestAllActivities();

        client.skillCtrl.getTalent_S();
        client.skillCtrl.getUsedSkillPoint();

	end

    --确定顶号  其实就是重登陆
    function Login.confirmRelogin(info, loginSceneMsg)
		local msg = {cmd = "confirm_relogin_scene", role_uid = info.id}
		Send(msg, function(loginSceneMsg)
			Login.LoginGame(info, loginSceneMsg);
		end)
	end

	function Login.LoginGame(info, loginSceneMsg)
		-- 隐藏所有角色模型
    	Login.HideAllExistRoleModels(true);
    	-- 加载登录信息
        Login.handleLoginOK(info, loginSceneMsg);
        -- 播放音效 enter_game
        uFacadeUtility.PlaySoundDontDestroyOnLoad("enter_game");
        -- 加载场景
        local myInfo = DataCache.myInfo;
        myInfo.id = loginSceneMsg["node_id"];			-- 玩家节点id
        local map_info = loginSceneMsg["scene_name"];	-- 场景信息
		local map_scene_id = map_info[1];	-- 场景 sid
		local mapName = map_info[2];		
		local map_fen_xian = mapName[2];	-- 场景分线
		DataCache.scene_sid = map_scene_id;
		DataCache.fenxian = tonumber(map_fen_xian);
		DataCache.fenxianFlag = tb.SceneTable[map_scene_id].fenxianFlag;
		SceneManager.LoadScene(map_scene_id,map_scene_id);	-- 加载场景
	end

	function Login.SR_OnStartClick()
		if not Login.CommonCheck() then
			return
		end
		if sr_selectIndex <= 0 then
			SysInfoLayer.GetInstance():ShowMsg("请先选择角色！")
			return
		end
		local info = client.cacheService.RoleInfoList[sr_selectIndex];
		local myInfo = DataCache.myInfo;
		myInfo.role_uid = info.id;
		GameSettings.Load(info.id);
		-- print(string.format("load settings with role_uid: role_uid=%d, stack=%s", info.id, debug.traceback()));
		--print("login_scene");
		local msg = {cmd = "login_scene", role_uid = info.id}
        Send(msg, function(loginSceneMsg)
            local rError = loginSceneMsg["error"];
            if nil == rError then
            	--print("login_scene ok");
            	Login.LoginGame(info, loginSceneMsg);
            elseif "relogin" == rError then --重复登录 relogin_scene
            	--print("confirm relogin ok");
                ui.showMsgBox(nil, "该账号已登录到游戏中，确认将其挤下线吗？", function()
                    Login.confirmRelogin(info, loginSceneMsg);
                end, nil);
            else
              	--print("login_Error:"..rError)
            end
		end)
	end

	function Login.SR_OnCreateClick()
		Login.HideAllExistRoleModels(false)
		Login.ShowCreateRole()
	end

	function Login.SR_OnChooseClick(go)
		local roleInfoList = client.cacheService.RoleInfoList
		local count = #roleInfoList
		if count > 0 then
			local chooseName = go:GetComponent("UIWrapper"):GO('tfName').text
			for i=1,count do
				local temp = selectRole_panel:GO('Role.Role'..i..'.SelectRole')
				local selectRole_Name = temp:GO('tfName').text
				local spcareer = temp:GO("spCareer")
				local choose = chooseName == selectRole_Name
				local role = roleInfoList[i]
				spcareer.sprite = "tp_"..role.role.career.."_icon"..(choose and 2 or 1)
				spcareer:GetComponent("RectTransform").anchoredPosition = choose and Vector2.New(-68.26, 5.8) or Vector2.New(-51.5, 0.4)
				spcareer:GetComponent("RectTransform").sizeDelta = choose and Vector2.New(109, 109) or Vector2.New(80, 80)
				temp:GetComponent("UIWrapper"):GO('selected'):SetShow(choose)
				temp:GetComponent("UIWrapper"):GO('normal'):SetShow(not choose)
				if choose then
					sr_selectIndex = i
				end
			end
		end
		Login.SR_SetCurRoleInfo()
	end

	local ExistRoleModels = {}

	function Login.HideAllExistRoleModels(bDestroy)
		if ExistRoleModels == nil then
			return
		end
		for k,v in pairs(ExistRoleModels) do
			if v ~= nil and v ~= 1 then
				v:SetActive(false)
				if bDestroy then
					Util.DestroyWithMaterialCheck(v)
				end
			end
		end
		if bDestroy then
			ExistRoleModels = {}
		end
	end

	function Login.SR_Refresh()
		--读取上次登陆的角色ID
		local userID = DataCache.userID;
		local lastRoleId = uFacadeUtility.GetPlayerPrefs("lastRole_"..userID);

		local roleInfoList = client.cacheService.RoleInfoList
		local count = #roleInfoList
		if count > 0 then
			for i=1,count do
				local role = roleInfoList[i]
				if sr_selectIndex == 0 and tostring(role.id) == lastRoleId then
					sr_selectIndex = i;
				end
			end

			for i=1,count do
				local prefix = 'Role.Role'..i
				local role = roleInfoList[i]
				Login.SR_SetRoleBox(prefix, role)
				if sr_selectIndex == 0 then
					sr_selectIndex = i
				end
				local go = selectRole_panel:GO('Role.Role'..i..'.SelectRole')
				go:GO('selected'):SetShow(sr_selectIndex == i)
				go:GO('normal'):SetShow(sr_selectIndex ~= i)
				local spcareer = selectRole_panel:GO(prefix..".SelectRole.spCareer")
				spcareer.sprite = "tp_"..role.role.career.."_icon"..(sr_selectIndex == i and 2 or 1)
				spcareer:GetComponent("RectTransform").anchoredPosition = (sr_selectIndex == i) and Vector2.New(-68.26, 5.8) or Vector2.New(-51.5, 0.4)
				spcareer:GetComponent("RectTransform").sizeDelta = (sr_selectIndex == i )and Vector2.New(109, 109) or Vector2.New(80, 80)
			end

			if count < sr_roleCount then
				for i=count+1, sr_roleCount do
					Login.SR_SetRoleBox('Role.Role'..i, nil)
				end
			end
		end
		Login.SR_SetCurRoleInfo()
		if count == 0 then
			--没有角色 进入创建角色分页
			Login.SR_OnCreateClick()
		else
			--初始化摄像机
			SetMainCameraInfo(Vector3.New(0.14, 3.231, -13.51), Vector3.New(9.69, 0, 0), Vector3.one, 45, true, 1.5)
			Util.SwitchMainCameraMode(MainCameraMode.MCM_ChooseRole, "")
		end
	end 

	function Login.SR_SetRoleBox(prefix, role)
		if role == nil then
			selectRole_panel:GO(prefix..".btnCreateRole"):Show()
			selectRole_panel:GO(prefix..".SelectRole"):Hide()
			return
		end
		selectRole_panel:GO(prefix..".btnCreateRole"):Hide()
		selectRole_panel:GO(prefix..".SelectRole"):Show()
		selectRole_panel:GO(prefix..".SelectRole.tfName").text = role.nickname
		selectRole_panel:GO(prefix..".SelectRole.tfLevel").text = role.level.."级"
		selectRole_panel:GO(prefix..".SelectRole.tfCareer").text = const.ProfessionName[role.role.career]
	end

	Login.SelectRoleFigure = nil

	function Login.SR_SetCurRoleInfo()
		local roleInfoList = client.cacheService.RoleInfoList
		if sr_selectIndex > 0 and #roleInfoList >= sr_selectIndex then
			local info = roleInfoList[sr_selectIndex]
			local career = info.role.career
			local sex = info.role.sex
			--selectRole_panel:GO('SelectRole').sprite = career.."_"..sex
			selectRole_panel:GO('Career.Name').text = const.ProfessionName[career]
			--处理3d模型显示
			Login.HideAllExistRoleModels(false)
			local RoleFigure = selectRole_panel:GO('RoleRotation')
			Login.SelectRoleFigure = CreateRoleFigure(RoleFigure)
			Login.SelectRoleFigure.Init(RoleFigure)
			if ExistRoleModels[info.nickname] == nil then
				--异步保护 先占个坑
				ExistRoleModels[info.nickname] = 1
				--
				local modelName, modelMaterialName, weaponmodelName = uAvatarUtil.GetPlayerModelName_Action(const.ProfessionName2Alias[career], tonumber(sex), nil, info.suitID, false)
				local weaponbindName = uAvatarUtil.GetWeaponBindName(career)
				local yifupro = tb.EquipTable[info.yifuID]
				if yifupro ~= nil then
					modelName = uAvatarUtil.GetPlayerModelNameByLevel(const.ProfessionName2Alias[career], tonumber(sex), yifupro.level)
	        		modelMaterialName = uAvatarUtil.GetModelMaterialNameByLevel(const.ProfessionName2Alias[career], tonumber(sex), yifupro.level);
				end
				local pro = tb.EquipTable[info.mainWeaponID]
				if pro ~= nil then
					weaponmodelName = uAvatarUtil.GetWeaponNameByLevel(const.ProfessionName2Alias[career], pro.level)
				end
				--人物展示shader(目前只有1级女弓有)
				--if modelMaterialName == "archer_female_1" then
					modelMaterialName = modelMaterialName.."_display"
				--end
				-- print(modelName)
				-- print(modelMaterialName) 
				-- print(weaponmodelName)

				uFacadeUtility.CreateModel(Vector3.zero, modelName, modelMaterialName, "", function(avatar)
					avatar.transform.localPosition = Vector3.zero
					avatar.transform.localEulerAngles = Vector3.New(0,180,0)
					avatar.transform.localScale = Vector3.one
					--weapon
					uFacadeUtility.PutonWeapon(weaponmodelName, weaponbindName, avatar)

					ExistRoleModels[info.nickname] = avatar
					Login.SelectRoleFigure.OneObj = avatar			
				end)
			else
				if ExistRoleModels[info.nickname] == 1 then
					return
				end
				ExistRoleModels[info.nickname]:SetActive(true)

				Login.SelectRoleFigure.OneObj = ExistRoleModels[info.nickname]
			end
		end
	end

	------------------------------------------
	------------create_role面板---------------
	------------------------------------------	
	local cr_careerCount = 3
	local cr_selectIndex = 0
	local cr_sex = 0

	local sr_editbox_oldPos

	function Login.CR_Start()
		--createRole_panel:GO('bg'):BindButtonClick(Login.CR_LostFocus)
		createRole_panel:GO('btnBack'):BindButtonClick(Login.CR_OnBackClick)
		createRole_panel:GO('btnCreate'):BindButtonClick(Login.CR_DoCreateButtonClick)
		createRole_panel:GO('btnCreate').isClickSoundEnable = false;
		--createRole_panel:GO('btnCreate').isSoundDontDestroyOnLoad = true;
		--createRole_panel:GO('btnCreate').clickSoundOverride = "enter_game"
		createRole_panel:GO('btnRandom'):BindButtonClick(Login.CR_OnRandomClick)
		createRole_panel:GO('select_sex.btnMale'):BindButtonClick(function()  Login.CR_OnClickMale() Login.CR_Init3DCreateRole()  end)
		createRole_panel:GO('select_sex.btnFemale'):BindButtonClick(function() Login.CR_OnClickFemale() Login.CR_Init3DCreateRole()  end)
		--Login.CR_OnRandomClick(nil)
		local inputPanel = createRole_panel:GO('iptName')
		inputPanel.inputText = ""

		sr_editbox_oldPos = createRole_panel:GetComponent('Transform').localPosition

		local editBox = inputPanel:GetComponent('EditBox')
		inputPanel:BindButtonClick(Login.CR_OpenKeyBoard);
        editBox:SetCallBack(Login.CR_SetDetailChatPanelHeight, Login.CR_EnterChat)
		inputPanel:BindInputFiledValueChanged(Login.CR_InputNameChanged)

		for i=0,cr_careerCount-1 do
			Login.CR_BindClick("role-section.role_"..i, i)
		end
		--createRole_panel:GO('role-section.role_0'):FireButtonClick()

		local show_login = uFacadeUtility.GetShowLogin();
		if not show_login then
			uFacadeUtility.SetShowLogin(true);
			uFacadeUtility.DestroyLoadingUI();
		end
	end

	function Login.CR_RandomCareerSex()
		--随机职业与性别
		cr_selectIndex = math.random(cr_careerCount)-1
		for i=0,cr_careerCount-1 do
			local career = const.Index2Career[i]
			local selected = (i==cr_selectIndex)
			createRole_panel:GO('role-section.role_'..i..'.Selected'):SetShow(selected)
			createRole_panel:GO('role-section.role_'..i..'.Normal'):SetShow(not selected)
			local Icon = createRole_panel:GO('role-section.role_'..i..'.Icon')
			local Name = createRole_panel:GO('role-section.role_'..i..'.Name')
			if selected then
				--Icon
				Icon.sprite = "tp_"..career.."_icon2"
				Icon:GetComponent("RectTransform").anchoredPosition = Vector2.New(-62, 12.3)
				Icon:GetComponent("RectTransform").sizeDelta = Vector2.New(109, 109)
				--Name
				Name.sprite = "wz_"..career.."_name"
				Name:GetComponent("RectTransform").anchoredPosition = Vector2.New(64.1, 7.5)
				Name:GetComponent("RectTransform").sizeDelta = Vector2.New(137, 55)
			else
				--Icon
				Icon.sprite = "tp_"..career.."_icon1"
				Icon:GetComponent("RectTransform").anchoredPosition = Vector2.New(0.8, 5.6)
				Icon:GetComponent("RectTransform").sizeDelta = Vector2.New(80, 80)
				--Name
				Name.sprite = "wz_"..career.."_name"
				Name:GetComponent("RectTransform").anchoredPosition = Vector2.New(102, 3.9)
				Name:GetComponent("RectTransform").sizeDelta = Vector2.New(122, 51)
			end
			Login.CR_SetCurRoleInfo()
		end
		if math.random(2) == 1 then
			Login.CR_OnClickFemale()
		else
			Login.CR_OnClickMale()
		end
	end

	function Login.CR_BindClick(name, index)
		createRole_panel:GO(name):BindButtonClick(function(go)
			cr_selectIndex = index
			for i=0,cr_careerCount-1 do
				local career = const.Index2Career[i]
				local selected = (i==cr_selectIndex)
				createRole_panel:GO('role-section.role_'..i..'.Selected'):SetShow(selected)
				createRole_panel:GO('role-section.role_'..i..'.Normal'):SetShow(not selected)
				local Icon = createRole_panel:GO('role-section.role_'..i..'.Icon')
				local Name = createRole_panel:GO('role-section.role_'..i..'.Name')
				if selected then
					--Icon
					Icon.sprite = "tp_"..career.."_icon2"
					Icon:GetComponent("RectTransform").anchoredPosition = Vector2.New(-62, 12.3)
					Icon:GetComponent("RectTransform").sizeDelta = Vector2.New(109, 109)
					--Name
					Name.sprite = "wz_"..career.."_name"
					Name:GetComponent("RectTransform").anchoredPosition = Vector2.New(64.1, 7.5)
					Name:GetComponent("RectTransform").sizeDelta = Vector2.New(137, 55)
				else
					--_icon1
					Icon.sprite = "tp_"..career.."_icon1"
					Icon:GetComponent("RectTransform").anchoredPosition = Vector2.New(0.8, 5.6)
					Icon:GetComponent("RectTransform").sizeDelta = Vector2.New(80, 80)
					--Name
					Name.sprite = "wz_"..career.."_name"
					Name:GetComponent("RectTransform").anchoredPosition = Vector2.New(102, 3.9)
					Name:GetComponent("RectTransform").sizeDelta = Vector2.New(122, 51)
				end
				Login.CR_SetCurRoleInfo()
			end
			Login.CR_Init3DCreateRole()
		end)
	end

	function Login.CR_OnClickMale()
		cr_sex = 1
		Login.CR_SetCurRoleInfo()
		createRole_panel:GO('select_sex.btnMale').buttonEnable = false
		createRole_panel:GO('select_sex.btnFemale').buttonEnable = true
	end

	function Login.CR_OnClickFemale()
		cr_sex = 0
		Login.CR_SetCurRoleInfo()
		createRole_panel:GO('select_sex.btnFemale').buttonEnable = false
		createRole_panel:GO('select_sex.btnMale').buttonEnable = true
	end

	local exampleRoleModel = {}

	function Login.HideExampleRoleModel()
		if exampleRoleModel == nil then
			return
		end
		--隐藏其他模型
		for k,v in pairs(exampleRoleModel) do
			if v ~= nil and v ~= 1 then
				v:SetActive(false)
			end
		end
	end

	function Login.InitSelectModel(go, name)
		if go == nil then
			return
		end
		if exampleRoleModel[name] == nil or exampleRoleModel[name] == 1 then
			exampleRoleModel[name] = go
		end
		--pos
		go.transform.localPosition = Vector3.zero
		go.transform.localEulerAngles = Vector3.zero
		go.transform.localScale = Vector3.one
		Login.HideExampleRoleModel()
		go:SetActive(true)
		SetMainCameraInfo(Vector3.one, Vector3.one, Vector3.one, 45, false)
		Util.SwitchMainCameraMode(MainCameraMode.MCM_CreateRole, name.."_SelectRoleCamera")
	end

	function Login.CR_Init3DCreateRole()
		local career = const.Index2Career[cr_selectIndex]
		local SelectModelName = career.."_"..cr_sex
		--加载3D模型 准备摄像机移动参数
		if exampleRoleModel[SelectModelName] == nil then
			--异步加载 占个坑
			exampleRoleModel[SelectModelName] = 1
			Util.GenerateNewCreateRoleModel(SelectModelName, function(go) 
				Login.InitSelectModel(go, SelectModelName)
			end)
		else
			if exampleRoleModel[SelectModelName] == 1 then
				return
			end
			Login.InitSelectModel(exampleRoleModel[SelectModelName], SelectModelName)
		end
	end

	local CareerSpecialty = {
		soldier = {"shengcun","baofa", "yicao"},	
		bowman = "shecheng",
		magician = "jidong",
	}
	local stress_tcolor = Color.New(1,1,1)
	local normal_tcolor = Color.New(0.68, 0.68, 0.68)

	function Login.CR_SetCurRoleInfo()
		local career = const.Index2Career[cr_selectIndex]
		createRole_panel:GO('left.Desc').text = const.desc2Career[career]
		createRole_panel:GO('left.Specialty').sprite = "wz_"..career.."_name"
		createRole_panel:GO('left.graph.graph').sprite = "tp_"..career.."_graph"
		--设置特性文字颜色
		for k,v in pairs(CareerSpecialty) do
			local Specialty = v
			
			if type(Specialty) == "table" then
				for i=1,#Specialty do
					createRole_panel:GO('left.graph.'..Specialty[i]).textColor = k==career and stress_tcolor or normal_tcolor
				end
			else
				createRole_panel:GO('left.graph.'..Specialty).textColor = k==career and stress_tcolor or normal_tcolor
			end
		end
	end

	function Login.CR_OnRandomClick()
		local name = NameRandom.randomName(cr_sex)
		createRole_panel:GO('iptName').inputText = Util.CutSubstring(name, 12)
	end

	function Login.CR_OnBackClick()
		Login.HideExampleRoleModel()
		if client.cacheService.RoleInfoList == nil or #client.cacheService.RoleInfoList == 0 then
			Login.BackLogin()
			DataCache.userID = 0
			DataCache.roleID = 0
			client.cacheService.RoleInfoList = nil
		else
			Login.HideExampleRoleModel()
			SetMainCameraInfo(Vector3.New(0.14, 3.231, -13.51), Vector3.New(9.69, 0, 0), Vector3.one, 45, true, 1.5)
			Util.SwitchMainCameraMode(MainCameraMode.MCM_ChooseRole, "")
			Login.BackSelectRole()
		end
	end

	local maxNameCharNum = 12
	local minNameCharNum = 1

	function Login.CR_InputNameChanged(text, _inputIndex)
		local newText = Util.CutSubstring(text, maxNameCharNum)
		createRole_panel:GO("iptName").inputText = newText
	end

	function Login.CommonCheck()
		--网络状态
		local netstate = NativeManager.GetInstance():GetNetState()
		if netstate == UnityEngine.NetworkReachability.NotReachable then --无连接
			SysInfoLayer.GetInstance():ShowMsg("无网络连接，请检查设置")
			return false
		end  
		--服务器状态
		if not Net.isOpen then
			SysInfoLayer.GetInstance():ShowMsg("连接失败，详情请咨询官方客服")
			return false
		end
		return true
	end

	local err2Msg = {
		illagel_char = "角色名中含有空格或非法字符，请重新输入！",
		too_long = "角色名字过长，请重新输入！",
		too_short = "角色名称不能少于2个字符，请重新输入！",
		rename = "角色名重复，请重新输入！",
		role_full = "该账号可创建角色数量已达上限",
	}

	function Login.CR_DoCreateButtonClick()
		local rolename = createRole_panel:GO("iptName").inputText
		if rolename == "" then
			SysInfoLayer.GetInstance():ShowMsg("请输入角色名！")
			return
		end
		if StrFiltermanger.Instance:IsFileter(rolename) then
			SysInfoLayer.GetInstance():ShowMsg(err2Msg.illagel_char)
			return
		end
		if cr_selectIndex == nil then
			SysInfoLayer.GetInstance():ShowMsg("请选择一个职业！")
			return
		end	
		if not Login.CommonCheck() then
			return
		end
		local roletype = const.Index2Career[cr_selectIndex]
		local msg = {cmd = "create_role", role_name = rolename, role_type = roletype, sex = cr_sex}
		Send(msg, function(createMsg)
			local err = createMsg["error"]
			if err ~= nil then
				if err2Msg[err] ~= nil then
					SysInfoLayer.GetInstance():ShowMsg(err2Msg[err])
				end
				return
			end
			local role_list = createMsg["role_list"]
			client.cacheService.SetRoleInfo(role_list)
			sr_selectIndex = 1;
			local info = client.cacheService.RoleInfoList[sr_selectIndex];
			local myInfo = DataCache.myInfo;
			myInfo.role_uid = info.id;
			--创建完角色立即进入游戏
			Login.SR_OnStartClick()
			--恢复相机设置
			SetMainCameraInfo(Vector3.one, Vector3.one, Vector3.one, 45, false)
			Util.SwitchMainCameraMode(MainCameraMode.MCM_INGAME, "")
		end)	
	end

	-----EditBox
	function Login.CR_SetDetailChatPanelHeight(posY)	
	print("CR_SetDetailChatPanelHeight")	
		createRole_panel:GetComponent('Transform').localPosition = Vector3.New(sr_editbox_oldPos.x, sr_editbox_oldPos.y + posY, sr_editbox_oldPos.z)
	end

	function Login.CR_OpenKeyBoard()
        local curText = createRole_panel:GO('iptName').inputText
        local editBox = createRole_panel:GO('iptName'):GetComponent('EditBox')
        editBox:showEditBox(curText)
    end

    function Login.CR_LostFocus()
    	Login.CR_CloseKeyBoard()
    end

    function Login.CR_CloseKeyBoard()
		if NativeManager.GetInstance().isKeyboardOpened then
			NativeManager.GetInstance():CloseEditBox()
			print("CR_CloseKeyBoard")
			createRole_panel:GetComponent('Transform').localPosition = sr_editbox_oldPos
		end
    end

    function Login.CR_EnterChat(text)
    	print("CR_EnterChat")
    	createRole_panel:GO('iptName').inputText = text
    	createRole_panel:GO('iptName').gameObject:SetActive(true)
    	createRole_panel:GetComponent('Transform').localPosition = sr_editbox_oldPos
    end

	------------------------------------------
	------------------- end ------------------
	------------------------------------------
	return Login
end
