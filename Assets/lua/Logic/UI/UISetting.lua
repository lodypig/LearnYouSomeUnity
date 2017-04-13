function UISettingView ()
	local UISetting = {};
	local this = nil;

	local btnSetting = nil;
	local btnPush = nil;
	local showSystemSetting;

	--系统设置界面
	local systemPanel = nil;
	local guajiSetting = nil;
	local displaySetting = nil;
	local audioSetting = nil;

	--推送界面
	local pushPanel = nil;
	--活动推送
	local actPushContent = nil;
	local actPushItem = nil;
	--挂机推送
	local guajiPushContent = nil;
	local guajiPushItem = nil;

	local actPush = {
						{name = "灵魂试炼场", period = "周一、二、三", time = "20:00"},
						{name = "安哥拉魔谷", period = "周日", time = "11:00"},
						{name = "战盟联赛", period = "周二、四、五、六", time = "21:30"},
						{name = "安哥拉魔谷", period = "周日", time = "11:00"},
						{name = "战盟联赛", period = "周二、四、五、六", time = "21:30"}
					}

	local guajiPush = {
						"好友私聊消息提醒","开始离线挂机提醒", "离线挂机死亡提醒",
						 "离线挂机时间不足提醒", "升级提醒", "背包空间不足提醒"
						}

	function UISetting.Start()
		this = UISetting.this;

		this:GO('Panel.Close'):BindButtonClick(UISetting.onClose);

		systemPanel = this:GO('Panel.Content.SystemPanel');
		guajiSetting = systemPanel:GO('GuaJiSetting');
		displaySetting = systemPanel:GO('DisplaySetting');
		audioSetting = systemPanel:GO('AudioSetting');

		pushPanel = this:GO('Panel.Content.PushPanel');
		actPushContent = this:GO('Panel.Content.PushPanel.Left.Container.Grid.Content');
		actPushItem = this:GO('Panel.Content.PushPanel.Left.Container.Grid.Item');
		actPushItem:Hide();
		guajiPushContent = this:GO('Panel.Content.PushPanel.Right.Container.Grid.Content');
		guajiPushItem = this:GO('Panel.Content.PushPanel.Right.Container.Grid.Item');
		guajiPushItem:Hide();

		--挂机时间
		this:GO('Panel.Bottom.Left.Add'):BindButtonClick(ui.buyGuajiTime);
		this:GO('Panel.Bottom.Left'):BindButtonClick(ui.GuajiTips);
		UISetting.refreshGuaji()
		UISetting.refreshGuajiTime()

		-- 绑定账号按钮事件
		UISetting.bindButtonEvents();
		-- 设置默认值
		-- UISetting.loadSettings();
		-- 加载设置值界面
		UISetting.loadSettingsUI();
		-- 绑定系统Panel事件
		UISetting.bindSystemPanelEvents();

		--默认显示系统界面
		showSystemSetting = true;
		UISetting.switchPanel();

		--初始推送界面
		UISetting.initPushPanel();

		EventManager.bind(this.gameObject,Event.ON_BUY_OFFLINE_TIME, UISetting.refreshGuajiTime);
		EventManager.bind(this.gameObject, Event.ON_LEVEL_UP, UISetting.refreshGuaji);

	end

	function UISetting.refreshGuaji()
		-- local openGuaji = client.userCtrl.IsOpenGuaji();
		-- this:GO('Panel.Bottom.Left.Add').gameObject:SetActive(openGuaji);
		-- this:GO('Panel.Bottom.Left.Lock').gameObject:SetActive(not openGuaji);
		-- this:GO('Panel.Bottom.Left.Time').gameObject:SetActive(openGuaji);
	end

	function UISetting.refreshGuajiTime()
		-- local remain_time = client.tools.formatTime(DataCache.offlineTime*60);
		-- if remain_time.hour == 0 then
		-- 	this:GO('Panel.Bottom.Left.Time').text = string.format("%s分钟", remain_time.minute);
		-- else
		-- 	this:GO('Panel.Bottom.Left.Time').text = string.format("%s小时%s分钟", remain_time.hour, remain_time.minute);
		-- end
	end

	function UISetting.initPushPanel( )
		for i=1, #NoticeManager.activityText do
			local go = newObject(actPushItem.gameObject);
            go:SetActive(true);	
            go.transform:SetParent(actPushContent.transform);
            go.transform.localScale = Vector3.one;
            go.transform.localPosition = Vector3.zero;

            local act = NoticeManager.activityText[i];
            local wrapper = go:GetComponent("UIWrapper");  
            wrapper:GO("Name").text = act.name;
            wrapper:GO("Period").text = act.period;
            wrapper:GO("Time").text = act.time;

            wrapper:GO("Toggle").ToggleValue = (NoticeManager.bActive[i] == 1);
            wrapper:GO("Toggle"):BindToggleValueChanged(function (toggle)
            	local activityId = NoticeManager.activityText[i].activityId;
            	if toggle == true then
            		NoticeManager.bActive[i] = 1;
            		NoticeManager.RegisterNoticeByActivity(activityId);
            	else
            		NoticeManager.bActive[i] = 0;
            		NoticeManager.CancelNoticeByActivity(activityId);
            	end
				NoticeManager.SaveSettings();
			end);
		end

		for i=1, #guajiPush do
			local go = newObject(guajiPushItem.gameObject);
            go:SetActive(true);	
            go.transform:SetParent(guajiPushContent.transform);
            go.transform.localScale = Vector3.one;
            go.transform.localPosition = Vector3.zero;
            local wrapper = go:GetComponent("UIWrapper");  
            wrapper:GO("Name").text = guajiPush[i];       
            wrapper:GO("Toggle").ToggleValue = SRSetting.get_setting_value(i+1);
            wrapper:GO("Toggle"):BindToggleValueChanged(function (toggle)
            	SRSetting.set_server_role_setting(i+1,toggle);
			end);    
		end
	end

	function UISetting.switchPanel()
		systemPanel.gameObject:SetActive(showSystemSetting);
		btnSetting:GO('Image').gameObject:SetActive(showSystemSetting);
		btnSetting:GO('Text').textColor = showSystemSetting and Color.New(1, 1, 1) or Color.New(162/255, 139/255, 83/255);

		pushPanel.gameObject:SetActive(not showSystemSetting);
		btnPush:GO('Image').gameObject:SetActive(not showSystemSetting);
		btnPush:GO('Text').textColor = showSystemSetting and Color.New(162/255, 139/255, 83/255) or Color.New(1, 1, 1);

	end

	function UISetting.bindButtonEvents()
		--切换系统设置界面
		btnSetting = this:GO('Panel.Top.BtnSetting');
		btnSetting:BindButtonClick(function (go)
			showSystemSetting = true;
			UISetting.switchPanel();
		end);

		--切换推送界面
		btnPush = this:GO('Panel.Top.BtnPush');
		btnPush:BindButtonClick(function (go)
			showSystemSetting = false;
			UISetting.switchPanel();
		end);

		-- 选择角色
		local selectRoleBtn = this:GO('Panel.Bottom.Right.BtnSelectRole');
		selectRoleBtn:BindButtonClick(function (go)
			ui.showMsgBox("切换角色", "要返回到选择角色界面吗？",
				function ()
					Send({cmd = "logout_scene"}, function ()
						SceneManager.ReturnToSelectRoleUI();
					end);
				end, nil);
		end);

		-- 重新登录
		local reloginBtn = this:GO('Panel.Bottom.Right.BtnRelogin');
		reloginBtn:BindButtonClick(function (go)
			ui.showMsgBox("重新登录", "要返回到登录界面吗？",	
				function ()
					SceneManager.ReturnToLoginUI();
				end, nil);
		end);
	end


	function UISetting.onClose()
		destroy(this.gameObject);
	end
 	
	-- 保存设置到客户端本地
	function UISetting.saveSettings()
		GameSettings.SaveAndApply();
	end

	-- 从客户端本地加载配置
	function UISetting.loadSettings()
		-- local myInfo = DataCache.myInfo;
		-- GameSettings.Load(myInfo.role_uid);
	end

	function UISetting.loadSettingsUI()
		UISetting.loadSystemSettings();
	end

	-- 加载系统面板设置
	function UISetting.loadSystemSettings()
		local settings = DataCache.settings;
		local useAOE = guajiSetting:GO('UseAOE');
		useAOE.ToggleValue = settings.fight_useAOE;
		local useEX = guajiSetting:GO('UseEX');
		useEX.ToggleValue = settings.fight_useEX;
		local useSpecial = guajiSetting:GO('UseSpecial');
		useSpecial.ToggleValue = settings.fight_useSpecial;
		local autoTeam = guajiSetting:GO('AutoTeam');
		autoTeam.ToggleValue = SRSetting.get_setting_value(SRSetting.SettingIndex.AutoTeam);

		local hideBlood = displaySetting:GO('HideOtherPlayerBlood');
		hideBlood.ToggleValue = settings.system_hideBlood;
		local hideTitle = displaySetting:GO('HideOtherPlayerTitle');
		hideTitle.ToggleValue = settings.system_hideTitle;
		local fluencyMode = displaySetting:GO('UseFluencyMode');
		fluencyMode.ToggleValue = settings.system_fluencyMode;

		local bgmMute = audioSetting:GO('BGMMute');
		bgmMute.ToggleValue = settings.system_bgmMute;
		local soundMute = audioSetting:GO('SoundMute');
		soundMute.ToggleValue = settings.system_soundMute;
	end

	-- 绑定系统设置事件
	function UISetting.bindSystemPanelEvents()

		--------------------------- 挂机设置 ---------------------------
		-- 自动战斗时施放群攻技能
		local useAOE = guajiSetting:GO('UseAOE');
		useAOE:BindToggleValueChanged(function (toggle)
			-- body
			local settings = DataCache.settings;
			settings.fight_useAOE = toggle;
			GameSettings.SaveAndApply();
		end);

		-- 自动战斗时施放必杀技
		local useEX = guajiSetting:GO('UseEX');
		useEX:BindToggleValueChanged(function (toggle)
			-- body
			local settings = DataCache.settings;
			settings.fight_useEX = toggle;
			GameSettings.SaveAndApply();
		end);

		-- 自动战斗时施放特殊技能
		local useSpecial = guajiSetting:GO('UseSpecial');
		useSpecial:BindToggleValueChanged(function (toggle)
			local settings = DataCache.settings;
			settings.fight_useSpecial = toggle;
			GameSettings.SaveAndApply();

		end);

		-- 自动组队
		local autoTeam = guajiSetting:GO('AutoTeam');
		autoTeam:BindToggleValueChanged(function (toggle)
			SRSetting.set_server_role_setting(SRSetting.SettingIndex.AutoTeam,toggle);
		end);

		local autoTeam = guajiSetting:GO('AutoTeam');
		autoTeam:BindToggleValueChanged(function (toggle)
			SRSetting.set_server_role_setting(SRSetting.SettingIndex.AutoTeam,toggle);
		end);

		--------------------------- 显示设置 ---------------------------
		local hideBlood = displaySetting:GO('HideOtherPlayerBlood');
		hideBlood:BindToggleValueChanged(function (toggle)
			-- body
			local value = 0;
			if toggle then
				value = 1;
			end
			--print("system_hideBlood = " .. value);
			local settings = DataCache.settings;
			settings.system_hideBlood = toggle;
			GameSettings.SaveAndApply();
		end);
		-- 隐藏其他玩家称号
		local hideTitle = displaySetting:GO('HideOtherPlayerTitle');
		hideTitle:BindToggleValueChanged(function (toggle)
			-- body
			local settings = DataCache.settings;
			settings.system_hideTitle = toggle;
			GameSettings.SaveAndApply();
		end);
		-- 使用流畅模式（建议低配置设备使用）
		local fluencyMode = displaySetting:GO('UseFluencyMode');
		fluencyMode:BindToggleValueChanged(function (toggle)
			-- body
			local settings = DataCache.settings;
			settings.system_fluencyMode = toggle;
			GameSettings.SaveAndApply();
		end);

		--------------------------- 声音设置 ---------------------------
		-- 关闭背景音乐
		local bgmMute = audioSetting:GO('BGMMute');
		bgmMute:BindToggleValueChanged(function (toggle)
			-- body
			local settings = DataCache.settings;
			settings.system_bgmMute = toggle;
			GameSettings.SaveAndApply();
		end);
		-- 关闭系统音效
		local soundMute = audioSetting:GO('SoundMute');
		soundMute:BindToggleValueChanged(function (toggle)

			-- print("关闭系统音效");
			-- body
			local settings = DataCache.settings;
			settings.system_soundMute = toggle;
			GameSettings.SaveAndApply();
		end);
	end


	return UISetting;

end

