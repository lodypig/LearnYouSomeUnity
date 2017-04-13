
function UIChatView()
	local UIChat = {};
    local this = nil;
    local scale = nil;
    local listenerIndex;
    local inputCharacterLimit = 80;

    --迷你聊天界面
    local showMiniChat = false;
    local miniChatPanel = nil;
    local miniRichText = nil;
    local miniChatContent = nil;
    local delayCallId = 0;

    --详细聊天界面
    local detailChatPanel = nil;
    local detailChatPanelPos = nil;
    local detailChatContainer = nil;	
    local detailChatItem = nil;	--聊天
    local detailScrollView = nil;
    local detailScrollViewHeight = 0;
    local detailChatInput = nil;
    local detailVoiceSend = nil;
    local detailLocationInput = nil;
    local detailBtnSend = nil;
    local detailInputPanel = nil;
    local detailInputTip = nil;
    local joinLegionTip = nil;
    local showVoiceChat = false;
    local isInputVoice = true;
    local isSendVoice = false;
    local lockScroll = false;
    local newChatNumText = nil;
    local newChatTip = nil;
    local newChatNum = 0;
    local channel = "world";
    local inputItemBegin = 0;   --输入框物品起始位置
    local inputItemEnd = 0;     --输入框物品结束位置
    local inputItem = {id = 0};       --输入框物品信息
    local detailChatMoveX = 650;
    local selectEmailWrap = nil;
    local emailPanel = nil;
    local emailItemContent = nil;
    local emailRewardContnet = nil;
    local emailItemList = {};
    local emailPrefab = nil;
    local emailSpScrollArrow = nil;
    local deleteEmailAllBtn = nil;


    --红点新消息数量
    local redTipNum = {0,0,0,0,0,0};
    local redTipIndex = {friend = 1, team = 2, clan = 3, world = 4, system = 5, email = 6};
    local RefreshRedTip = function ()
   		for i,v in pairs(redTipNum) do
			UIChat.controller.SetRedPoint(i, v > 0, v);   			
   		end
    end

    --录音提示
    local speechTip = nil;
    local startSpeechTip = nil;
    local speechVolumeObj = {};
    local cancelSpeechTip = nil;

    --设置
    local settingPanel = nil;
    local mainChatShow = 
    {
        world = true,
        system = true,
        clan = true,
        team = true
    };

    local autoPlaySpeech = 
    {
        world = true,
        clan = true,
        team = true
    };

    local playList = List:New();

	function UIChat.Start()
        this = UIChat.this;
        NativeManager.GetInstance():BindSpeechResult(UIChat.onSpeechResult);
        NativeManager.GetInstance():BindSpeechVolumeChange(UIChat.onSpeechVolume);
        NativeManager.GetInstance():BindSpeechBegin(UIChat.onSpeechBegin);
        NativeManager.GetInstance():BindSpeechEnd(UIChat.onSpeechEnd);
        listenerIndex = client.chat.AddListener(UIChat.receiveChatMsg);

        --聊天界面频道切换按钮
        local commonDlgGO = this:GO('DetailChat.CommonDlg');	--这个是UIWrapper
		UIChat.controller = createCDC(commonDlgGO)
		UIChat.controller.SetButtonNumber(6);
		UIChat.controller.SetButtonText(1,"好友");
		UIChat.controller.bindButtonClick(1, function ()
            UIChat.switchChatChannel(1);
        end);
		UIChat.controller.SetButtonText(2,"队伍");
		UIChat.controller.bindButtonClick(2,function ()
            UIChat.switchChatChannel(2);
        end);
		UIChat.controller.SetButtonText(3,"公会");
		UIChat.controller.bindButtonClick(3,function ()
            UIChat.switchChatChannel(3);
        end);
		UIChat.controller.SetButtonText(4,"世界");
		UIChat.controller.bindButtonClick(4,function ()
            UIChat.switchChatChannel(4);
        end);	
        UIChat.controller.SetButtonText(5,"系统");
        UIChat.controller.bindButtonClick(5,function ()
            UIChat.switchChatChannel(5);
        end);	
		UIChat.controller.SetButtonText(6,"邮箱");
		UIChat.controller.bindButtonClick(6,function ()
            UIChat.switchChatChannel(6);
        end);

        this:GO('DetailChat.Close'):BindButtonClick(UIChat.closeDetailChat)

		--详细聊天界面
		detailChatContainer = this:GO('DetailChat.Chat.ScrollView.Viewport.List').gameObject;
		detailChatPanel = this:GO('DetailChat');
		detailChatPanel.gameObject:SetActive(false);
		detailChatItem = this:GO('DetailChat.Chat.ScrollView.Viewport.List.ChatItem').gameObject;
		detailChatItem:SetActive(false);
		detailScrollView = this:GO('DetailChat.Chat.ScrollView'):GetComponent("ScrollRect");
		this:GO('DetailChat.Chat.ScrollView'):BindScrollRectValueChanged(UIChat.scrollDetailChat);

        --切换
        detailInputPanel = this:GO('DetailChat.Chat.Input');
        detailInputTip = this:GO('DetailChat.Chat.InputTip');
        detailInputTip:Hide();
        joinLegionTip = this:GO('DetailChat.Chat.JoinLegion');
        joinLegionTip:Hide();
        this:GO('DetailChat.Chat.JoinLegion.BtnJoin'):BindButtonClick(ShowLegion);

        --聊天切换按钮
        detailLocationInput = this:GO('DetailChat.Chat.Input.Switch');
        detailLocationInput:BindButtonClick(UIChat.OnInputSwitch);
        UIChat.OnInputSwitch();

        --语音按钮
        detailVoiceSend = this:GO('DetailChat.Chat.Input.Voice.Send');
		detailVoiceSend:BindETButtonDown(UIChat.openVoice);
        detailVoiceSend:BindETButtonUp(UIChat.closeVoice);
        detailVoiceSend:BindETTouchEnter(UIChat.touchVoiceEnter);
        detailVoiceSend:BindETTouchExit(UIChat.touchVoiceExit);
        this:GO('DetailChat.Chat.Input.Voice.Switch'):BindButtonClick(UIChat.OnSendSwitch);
        UIChat.OnSendSwitch();

        --文字输入框
        detailChatInput = this:GO('DetailChat.Chat.Input.Text.InputField');
        detailChatInput:BindButtonClick(UIChat.OpenKeyBoard);
        local editBox = detailChatInput:GetComponent('EditBox');        
        editBox:SetCallBack(UIChat.heightChange, UIChat.enterChatFromKeyBoard);
        detailChatInput:BindInputFiledValueChanged(UIChat.inputValueChanged)
        this:GO('DetailChat.Chat.Input.Text.Enter'):BindButtonClick(UIChat.enterChat);
        this:GO('DetailChat.Chat.Input.Text.Add'):BindButtonClick(UIChat.showEmoteUI);
        
        --新消息数量
       	newChatTip = this:GO('DetailChat.Chat.ScrollView.NewChatNum').gameObject;
       	newChatTip:SetActive(false);
       	this:GO('DetailChat.Chat.ScrollView.NewChatNum'):BindButtonClick(UIChat.showNewChat);
       	newChatNumText = this:GO('DetailChat.Chat.ScrollView.NewChatNum.Text'):GetComponent('Text');

       	--迷你聊天
        miniChatPanel = this:GO('MiniChat');
        miniChatContent = this:GO('MiniChat.Content');
        iTween.FadeTo(miniChatContent.gameObject, 0 ,0.01);
        miniRichText = this:GO('MiniChat.Content.RichText'):GetComponent("LRichText");
        miniChatPanel.gameObject:SetActive(false);

        --录音提示
        speechTip = this:GO('SpeechTip').gameObject;
        speechTip:SetActive(false);
        startSpeechTip = this:GO('SpeechTip.Normal').gameObject;
        for i = 1, 5 do
        	speechVolumeObj[i] = this:GO('SpeechTip.Normal.Volume.' .. i).gameObject;
        end
        cancelSpeechTip = this:GO('SpeechTip.Cancel').gameObject;
        
        --邮件 
        emailPanel = this:GO('Email');
        emailPanel:Hide();
        emailPanel:GO('close'):BindButtonClick(UIChat.CloseEmailPanel);
        emailRewardContnet = this:GO('Email.ScrollView.Viewport.Content');
        emailSpScrollArrow = emailPanel:GO('ScrollView.jiantou')

        emailPrefab = this:GO('DetailChat.Email.emailitem').gameObject
        emailPrefab:SetActive(false);
        emailItemContent = this:GO('DetailChat.Email.Container');
        

        deleteEmailAllBtn = this:GO("DetailChat.Email.DeleteAllEmailBtn");
        deleteEmailAllBtn:BindButtonClick(function() 
            if deleteEmailAllBtn.buttonEnable == true then
                -- client.chat.getEmailAwardAll()
                ui.showMsgBox(nil, "是否删除所有邮件（有附件的将不会删除）？", function()
                    client.chat.deleteEmailAll()
                    UIChat.CloseEmailPanel();
                    end);
            end
            end) 

        if client.role.haveClan() then
            UIChat.controller.activeButton(3);
        else
            UIChat.controller.activeButton(4);
        end

        --设置
        settingPanel = this:GO('Setting').gameObject;
        settingPanel:SetActive(false);
        this:GO('Setting.Close'):BindButtonClick(UIChat.closeSetting);
        UIChat.BindSettingEvent();

        UIChat.LoadSettings();
        this:BindLostFocus(UIChat.LoseFocus);

        --注册事件
        EventManager.bind(this.gameObject,Event.ON_LEVEL_UP,UIChat.handleLevelUp);
        
	end

    function UIChat.CloseEmailPanel()
        emailPanel:Hide()
        if selectEmailWrap ~= nil then
            selectEmailWrap:GO('bk').imageColor = Color.New(1,1,1,0);
            selectEmailWrap:GO('bk.jiantou'):Hide();
        end
    end
    function UIChat.UpdataEmailList()
        if channel == "email" then
            UIChat.switchChatChannel(6);
        end
    end

    function UIChat.OpenEmailPanelList()
        UIChat.switchChatChannel(6);
        UIChat.controller.activeButton(6);
    end

	function UIChat.LoseFocus()
        if detailChatPanel and detailChatPanel.gameObject.activeSelf then
    		UIChat.CloseKeyBoard();
    		UIChat.closeEmoteUI()
        end
	end

	function UIChat.CloseKeyBoard()
		if NativeManager.GetInstance().isKeyboardOpened then
			NativeManager.GetInstance():CloseEditBox();
			UIChat.SetDetailChatPanelHeight(0);
		end
	end

    function UIChat.OpenKeyBoard()
    	UIChat.closeEmoteUI();
        local curText = detailChatInput.inputText;
        local editBox = detailChatInput:GetComponent("EditBox");
        editBox:showEditBox(curText);
    end

	function UIChat.FirstUpdate( )
		scale = this:GetComponent("RectTransform").localScale;
        detailChatPanelPos = this:GO('DetailChat').transform.localPosition;
        local rect = this:GO('DetailChat.Chat.ScrollView'):GetComponent("RectTransform");        
        detailScrollViewHeight = rect.rect.height;
        this:GO('DetailChat').transform.localPosition = Vector3.New(detailChatPanelPos.x - detailChatMoveX, detailChatPanelPos.y, detailChatPanelPos.z);
    end

    function UIChat.Update()

    end

    function UIChat.LoadSettings()
        local settings = DataCache.settings;
        --UIChat.controller.activeButton(settings.chat_channel);
        this:GO('Setting.ChannelSetting.Team').ToggleValue = settings.showChatTeam;
        this:GO('Setting.ChannelSetting.Clan').ToggleValue = settings.showChatClan;
        this:GO('Setting.ChannelSetting.World').ToggleValue = settings.showChatWorld;
        this:GO('Setting.AutoPlay.Team').ToggleValue = settings.playSpeechTeam;
        this:GO('Setting.AutoPlay.Clan').ToggleValue = settings.playSpeechClan;
        this:GO('Setting.AutoPlay.World').ToggleValue = settings.playSpeechWorld;
    end

    function UIChat.BindSettingEvent( )
        
        local wrapper = this:GO('Setting.ChannelSetting.Team');
        wrapper:BindToggleValueChanged(function (toggle)
            mainChatShow["team"] = toggle;
            local settings = DataCache.settings;
            settings.showChatTeam = toggle;
            GameSettings.SaveAndApply();
        end);

        wrapper = this:GO('Setting.ChannelSetting.Clan');
        wrapper:BindToggleValueChanged(function (toggle)
            mainChatShow["clan"] = toggle;
            local settings = DataCache.settings;
            settings.showChatClan = toggle;
            GameSettings.SaveAndApply();
        end);

        wrapper = this:GO('Setting.ChannelSetting.World');
        wrapper:BindToggleValueChanged(function (toggle)
            mainChatShow["world"] = toggle;
            local settings = DataCache.settings;
            settings.showChatWorld = toggle;
            GameSettings.SaveAndApply();
        end);

        wrapper = this:GO('Setting.AutoPlay.Team');
        wrapper:BindToggleValueChanged(function (toggle)
            autoPlaySpeech["team"] = toggle;
            local settings = DataCache.settings;
            settings.playSpeechTeam = toggle;
            GameSettings.SaveAndApply();
        end);

        wrapper = this:GO('Setting.AutoPlay.Clan');
        wrapper:BindToggleValueChanged(function (toggle)
            autoPlaySpeech["clan"] = toggle;
            local settings = DataCache.settings;
            settings.playSpeechClan = toggle;
            GameSettings.SaveAndApply();
        end);

        wrapper = this:GO('Setting.AutoPlay.World');
        wrapper:BindToggleValueChanged(function (toggle)
            autoPlaySpeech["world"] = toggle;
            local settings = DataCache.settings;
            settings.playSpeechWorld = toggle;
            GameSettings.SaveAndApply();
        end);


    end

	local isVoiceTouchEnter = false;
	function UIChat.openVoice()
        if client.chat.canSend(channel) then
            NativeManager.GetInstance():StartSpeech();
            client.speechChannel = channel;
        end
    end

    function UIChat.closeVoice()
        if NativeManager.GetInstance().isStartSpeech then
        	if isVoiceTouchEnter then
            	NativeManager.GetInstance():StopSpeech();
            else
            	NativeManager.GetInstance():CancelSpeech();
            end
        end
    end

    function UIChat.touchVoiceEnter( )
     	isVoiceTouchEnter = true;
     	UIChat.setSpeechTip(true);
    end

    function UIChat.touchVoiceExit( )
     	isVoiceTouchEnter = false;
     	UIChat.setSpeechTip(false);
    end

    function UIChat.sendLocation()
        if SceneManager.IsXiangWeiMap(DataCache.scene_sid) then
            ui.showMsg("该场景不能发送坐标!");
            return
        end
		local curPos = Vector2.New(math.floor(AvatarCache.me.pos_x * 2 + 0.5), math.floor(AvatarCache.me.pos_z * 2 + 0.5));
    	local mapName = DataCache.getSceneTable().name;
        local fenxianID = DataCache.fenxian;
        if tb.SceneTable[DataCache.scene_sid].sceneType == "main_map" or tb.SceneTable[DataCache.scene_sid].sceneType == "xiangwei_map" then
		    UIChat.InputLocation("["..mapName..","..fenxianID..","..curPos.x..","..curPos.y.."]");
        else
            UIChat.InputLocation("["..mapName..","..curPos.x..","..curPos.y.."]");
        end
    end

    function UIChat.setSpeechTip(normal)
     	if startSpeechTip then
     		startSpeechTip:SetActive(normal);
     	end

     	if cancelSpeechTip then
     		cancelSpeechTip:SetActive(not normal);
     	end
     end 

	function UIChat.HideUI()
	   UIChat.closeDetailChat()
       UIChat.closeSetting()
       UIChat.CloseEmailPanel();
	end

	function UIChat.ShowUI()
       
	end

	function UIChat.ShowMiniChat( bShow )
		showMiniChat = bShow;
		miniChatPanel.gameObject:SetActive(bShow);
	end

    local isShowEmoteUI = false;
    function UIChat.showEmoteUI()
        if isShowEmoteUI then
            return;
        end
    	isShowEmoteUI = true;
    	UIChat.CloseKeyBoard();
        ShowChatAssist();
        UIChat.SetDetailChatPanelHeight(351);
    end

    function UIChat.closeEmoteUI()
    	if isShowEmoteUI then
    		isShowEmoteUI = false;
    		HideChatAssist();
    		UIChat.SetDetailChatPanelHeight(0);
    	end
    end

    function UIChat.SetDetailChatPanelHeight(posY)
        local offset = detailChatPanel:GetComponent('RectTransform').offsetMin;
        detailChatPanel:GetComponent('RectTransform').offsetMin = Vector2.New(offset.x, posY);
        offset = detailChatPanel:GO('CommonDlg'):GetComponent('RectTransform').offsetMax;
        detailChatPanel:GO('CommonDlg'):GetComponent('RectTransform').offsetMax = Vector2.New(offset.x, posY);
        detailScrollViewHeight = detailChatPanel:GO('Chat.ScrollView'):GetComponent('RectTransform').rect.height;
        UIChat.showNewChat();
    end

    function UIChat.OnInputSwitch()
        isInputVoice = not isInputVoice;
        detailLocationInput.sprite = isInputVoice and "an_jianpan" or "an_yuying";
        detailInputPanel:GO('Text').gameObject:SetActive(not isInputVoice);
        detailInputPanel:GO('Voice').gameObject:SetActive(isInputVoice);
    end

    function UIChat.OnSendSwitch()
        isSendVoice = not isSendVoice;
        detailInputPanel:GO('Voice.Switch').sprite = isSendVoice and "an_wen" or "an_yu";
        detailInputPanel:GO('Voice.Send.Text').text = isSendVoice and "按住说话，发送语音" or "按住说话，自动转文字发送";
    end

    function UIChat.handleLevelUp( )
        UIChat.showInputPanel(channel);
    end

    function UIChat.switchChatChannel(index)
        channel = const.chatChannelName[index];
        if channel == "email" then
            this:GO('DetailChat.Chat'):Hide()
            this:GO('DetailChat.Email'):Show()
            UIManager.GetInstance():CallLuaMethod('MainUI.ShowTipsEmail', false);
            UIChat.InitEmailItem()
        else
            this:GO('DetailChat.Email'):Hide()
            emailPanel:Hide();
            this:GO('DetailChat.Chat'):Show()
            UIChat.showInputPanel(channel)
            UIChat.removeAllItem();

            UIChat.showNewChat();
            --local settings = DataCache.settings;
            --settings.chat_channel = index;
            --GameSettings.SaveAndApply();
            redTipNum[index] = 0;
        end
        
        RefreshRedTip();
    end

    function UIChat.showInputPanel(channel)
        local isShow = true;
        local myInfo = DataCache.myInfo;
        if channel == "world" and myInfo.level < 19 then
            isShow = false;
            detailInputTip.text = "世界频道发言需要20级";
        elseif channel == "system" or channel == "friend" or channel == "email" then
            isShow = false;
            detailInputTip.text = "请切换至其它频道发言";
        end

        detailInputPanel.gameObject:SetActive(isShow);
        detailInputTip.gameObject:SetActive(not isShow);

        if channel == "clan" and client.role.haveClan() == false then
            joinLegionTip:Show();
        else
            joinLegionTip:Hide();
        end
    end

    function UIChat.enterChatFromKeyBoard()
        UIChat.enterChat();
    end

	function UIChat.enterChat()
		if not client.chat.canSend(channel) then
			return;
		end

        local text = detailChatInput.inputText;

        local bytelength = Util.StringByteLength(text)
        if bytelength > inputCharacterLimit then
            text = Util.CutSubstring(text, inputCharacterLimit);
        end

		if text ~= "" then
            if inputItem.id ~= 0 then
                local head = "";
                if inputItemBegin > 1 then
                    head = Util.Substring(text, 0, inputItemBegin - 1);
                end
                local tail = Util.Substring(text, inputItemEnd, 0);
                --未鉴定装备和橙装碎片处理
                local quality = inputItem.item.quality;
                if quality == const.quality.unidentify then
                    quality = 5;
                end
                if quality == const.quality.orangepiece then
                    quality = 6;
                end
                text = head.."[item:"..inputItem.name..":item:"..quality.."]"..tail;
            end

			if client.chat.send(channel, text, nil, 0, inputItem) then
                inputItem.id = 0;
                detailChatInput.inputText = "";
                if NativeManager.GetInstance().isKeyboardOpened then
                	NativeManager.GetInstance():SetEditBoxString("");
            	end
            end
		end
	end
    
    function UIChat.heightChange(posY)
        --如果表情界面显示，不还原界面高度
        if isShowEmoteUI and posY == 0 then 
            return;
        end
        UIChat.SetDetailChatPanelHeight(posY);
    end

	function UIChat.showNewChat()
		lockScroll = false;
		UIChat.refreshDetailChat();
		newChatNum = 0;
    	newChatTip:SetActive(false);
	end

    local tweener = nil;
	function UIChat.closeDetailChat()
        UIManager.GetInstance():CallLuaMethod('MainUI.closeDetailChat');
        UIChat.CloseKeyBoard();
        UIChat.closeEmoteUI();
		if detailChatPanel then
			tweener = detailChatPanel.transform:DOLocalMove(Vector3.New(detailChatPanelPos.x-detailChatMoveX, detailChatPanelPos.y, detailChatPanelPos.z), 0.3, false):OnComplete(function ()
                detailChatPanel.gameObject:SetActive(false);
            end);
		end

        if channel == "email" then
            UIChat.controller.activeButton(4);
        end
	end

	function UIChat.showDetailChat()
		if detailChatPanel then
            if tweener then
                tweener:Kill(false);
                tweener = nil;
            end
			detailChatPanel.transform:DOLocalMove(detailChatPanelPos, 0.3, false);
            detailChatPanel.gameObject:SetActive(true);
            UIChat.showNewChat();
            UIChat.showInputPanel(channel)
		end
	end

    local chatContainerRT = nil;
	function UIChat.scrollDetailChat(value)
        if chatContainerRT == nil then
            chatContainerRT = detailChatContainer:GetComponent("RectTransform");
        end
		local height = chatContainerRT.sizeDelta.y;
        local localY = chatContainerRT.localPosition.y;
		if height - localY - detailScrollViewHeight > 20 then
			lockScroll = true;
		else
			if lockScroll then 
				UIChat.showNewChat();		
			end
		end

        UIChat.updateChatItem(localY, localY + detailScrollViewHeight);	
	end

	function UIChat.showSetting(  )
		if settingPanel then
			settingPanel:SetActive(true);
		end
	end

	function UIChat.closeSetting(  )
		if settingPanel then
			settingPanel:SetActive(false);
		end
	end

    function UIChat.onSpeechResult(result, speech, length)
        if isSendVoice then
            client.chat.send(client.speechChannel, result, speech, length, nil)
        else
            client.chat.send(client.speechChannel, result, nil, 0, nil)
        end
    end

    --SDK音量范围0-30
    function UIChat.onSpeechVolume(volume)
    	local count = #speechVolumeObj
        for i = 1, count do
        	speechVolumeObj[i]:SetActive(volume > (i-1) * 30 / count);
        end
    end

    function UIChat.onSpeechBegin()
        if speechTip then
        	speechTip:SetActive(true);
        end
    end

    function UIChat.onSpeechEnd()
        if speechTip then
        	speechTip:SetActive(false);
        end
    end 

    function UIChat.receiveChatMsg(msg)
        UIChat.addChatItem(msg)
        --人物头顶气泡显示（系统消息不显示）
        if msg.channel ~= "system" and not msg.isSystemTip and not msg.filter then
            Util.ShowHeadChat(msg.id, msg.text, const.channelColor[msg.channel])
        end
    end

    function UIChat.addChatItem(msg)
	
		if msg.channel == "email" then
            redTipNum[redTipIndex[msg.channel]] = redTipNum[redTipIndex[msg.channel]] + 1;
            RefreshRedTip();
            return
        end

        if not msg.filter and mainChatShow[msg.channel] then
         UIManager.GetInstance():CallLuaMethod('MainUI.addMainChatItem', msg);
	    end

        --聊天界面
        if msg.channel == channel then
            UIChat.addDetailChatItem();
        end

        if msg.channel ~= channel and msg.channel ~= "system" then
        	redTipNum[redTipIndex[msg.channel]] = redTipNum[redTipIndex[msg.channel]] + 1;
        	RefreshRedTip();
            
        end

        --二级界面的聊天区
        if not msg.filter and showMiniChat then
            UIChat.addMiniChat(msg);
        end

        if msg.speech and msg.speech > 0 and autoPlaySpeech[msg.channel] then
            if DataCache.myInfo ~= nil and msg.role_uid ~= DataCache.myInfo.role_uid then
                playList:PushBack(msg);
                UIChat.playSpeech();
            end
        end
    end

    local delayFadeId = 0;
    function UIChat.addMiniChat(msg)
        if msg.isSystemTip then
            return
        end

        local text = msg.text;
        if msg.speech and msg.speech > 0 then
            text = "[#502:speech]"..text;
        end

        miniRichText.normalTextColor = const.channelColor[msg.channel];
        if msg.channel == "system" then
            miniRichText.text = const.richChatChannel[msg.channel]..text;
        else
            local name = string.format("[color:241,241,241, %s：]",msg.name);
            miniRichText.text = const.richChatChannel[msg.channel]..name..text;
        end

        ui.setNodeWidth(miniChatContent, miniRichText.realLineWidth + 30);

        if delayFadeId ~= 0 then
            this:CancelDelay(delayFadeId);
        end

        iTween.FadeTo(miniChatContent.gameObject, 1 ,0.1);
        delayFadeId = this:Delay(5, function() 
            iTween.FadeTo(miniChatContent.gameObject, 0 , 3);
            end);

    end

    function UIChat.addDetailChatItem()
        if lockScroll then
            newChatNum = newChatNum + 1;
            newChatTip:SetActive(true);
            local str = newChatNum;
            if newChatNum > 99 then
                str = "99+";
            end
            newChatNumText.text = "有"..str.."条消息未读，点击阅读";
        else
            UIChat.refreshDetailChat();
        end
    end

    local chatItemList = {};
    local unuseItemList = {};
    local chatList = nil;

    function UIChat.refreshDetailChat( )
        if DataCache.myInfo == nil then
            return;
        end

        if channel == "friend" or channel == "email" then
            return;
        end

        chatList = client.chat.getContentByChannel(channel);
        local totalHeight = 0;
        if #chatList > 0 then
        	totalHeight = chatList[#chatList].posY + chatList[#chatList].data.textHeight;
        end
         
        ui.setNodeHeight(detailChatContainer, totalHeight);

        if detailScrollViewHeight < totalHeight then
            detailScrollView.verticalNormalizedPosition = 0;
        else
            detailScrollView.verticalNormalizedPosition = 1;
        end

        local startY = detailChatContainer.transform.localPosition.y;
        UIChat.updateChatItem(startY, startY + detailScrollViewHeight);	
    end

    --更新可视区域的聊天列表
    function UIChat.updateChatItem(posStart, posEnd)
    	local list = {};
    	for i=1, #chatList do
    		local bottom = chatList[i].posY + chatList[i].data.textHeight
    		local top = chatList[i].posY;
    		if bottom > posStart and top < posEnd then
    			Enqueue(list, chatList[i]);
    		end
    	end

    	for i = #chatItemList, 1, -1 do
    		local wrapper = chatItemList[i]:GetComponent('UIWrapper');
    		local data = wrapper:GetUserData("data");
            local pos = wrapper:GetUserData("pos");
    		if not UIChat.Contains(list, data) or pos ~= data.posY then
    			chatItemList[i].transform.localPosition = Vector3.New(-1000, 0, 0);
    			wrapper:SetUserData("data", nil);
                wrapper:SetUserData("pos", 0);
    			Enqueue(unuseItemList, chatItemList[i]);
    			table.remove(chatItemList, i);
    		end
    	end

    	for i=1, #list do 
    		local data = list[i];
    		if not UIChat.isExistItem(data) then
    			local go = UIChat.getChatItem();
    			local wrapper = go:GetComponent('UIWrapper');
    			wrapper:SetUserData("data", data);
                wrapper:SetUserData("pos", data.posY);            
    			UIChat.refreshDetailChatItem(go, data);
    			Enqueue(chatItemList, go);
    		end
    	end
    end

    function UIChat.Contains(list,item)
        for i=1,#list do
            if list[i] == item then
                return true
            end
        end
        return false
    end

    function UIChat.isExistItem(data)
    	local isExist = false;
    	for i = 1, #chatItemList do
    		local wrapper = chatItemList[i]:GetComponent('UIWrapper');
    		if data == wrapper:GetUserData("data") then
    			isExist = true;
    		end
    	end
    	return isExist;
    end

    function UIChat.removeAllItem( )
        for i = #chatItemList, 1, -1 do
            local wrapper = chatItemList[i]:GetComponent('UIWrapper');
            chatItemList[i].transform.localPosition = Vector3.New(0, 1000, 0);
            wrapper:SetUserData("index", 0);
            Enqueue(unuseItemList, chatItemList[i]);
        end
        chatItemList = {};
    end

    function UIChat.getChatItem()
    	if #unuseItemList > 0 then
    		return Dequeue(unuseItemList);
    	end

        local go = newObject(detailChatItem);
        go:SetActive(true);
        go.transform:SetParent(detailChatContainer.transform);
        go.transform.localScale = Vector3.one;
        go.transform.localPosition = Vector3.zero;

        return go;
    end

    function UIChat.FormatTime(t)
        local now = TimerManager.GetServerNowMillSecond()/1000
        local remaintime = client.chat.EMAIL_TIME_LIMIT - (now - t)
        local str = "小于1分钟"
        if remaintime >= 86400 then
            str = string.format("剩余%d天",math.modf(remaintime/86400))
        elseif remaintime > 3600 then
            str = string.format("剩余%d小时",math.modf(remaintime/86400))
        elseif timetab.hour > 60 then
            str = string.format("剩余%d分钟",math.modf(remaintime/86400))
        end
        return str 
    end

    local emailPanelCallBack = function(id, index)
        local list = client.chat.chatContentList.email;
        local nextIndex = index;
        local email = client.chat.GetMailByIndex(nextIndex)
        if list and next(list) then
            if email then
                UIChat.updateEmailContent(list[nextIndex].data.id);
                local wrapper = emailItemContent:GO('Grid.Content.'..nextIndex-1);
                selectEmailWrap = wrapper;
                wrapper:GO('bk').imageColor = Color.New(1,1,1,1);
                wrapper:GO('bk.jiantou'):Show();
                wrapper:GO('pic').sprite = "tb_youjian_1";
            else
                UIChat.updateEmailContent(list[1].data.id);
                local wrapper = emailItemContent:GO('Grid.Content.0');
                selectEmailWrap = wrapper;
                wrapper:GO('bk').imageColor = Color.New(1,1,1,1);
                wrapper:GO('bk.jiantou'):Show();
                wrapper:GO('pic').sprite = "tb_youjian_1";
            end
        else
            UIChat.CloseEmailPanel();
        end
    end

    function UIChat.updateEmailContent(id)
        emailItemList = {}
        emailPanel:Show()
        emailPanel:SetUserData("id",id);
        local mail = client.chat.GetMailById(id)
        local mailtable = tb.email[mail.sid]
        emailPanel:GO('bk.Title.Text').text = mailtable.title
        local BoardText = emailPanel:GO('description.Viewport.Content.text'):GetComponent("LRichText");
        BoardText.text = mail.description       
        emailPanel:GO('description.Viewport.Content'):GetComponent("RectTransform").sizeDelta = Vector2.New(460,BoardText.realLineHeight)
        emailPanel:GO('sender').text = mailtable.sender
        emailPanel:GO('time').text = os.date("%Y-%m-%d      %H:%M",mail.sendtime)

        local childcount = emailRewardContnet.transform.childCount
        for i = 1,childcount do
            emailRewardContnet.transform:GetChild(i-1).gameObject:SetActive(false);
        end
        local prefab = this:LoadAsset("BagItem");
        for i = 1,#mail.items do
            local item = mail.items[i]
            local itemData  = {}
            local type = ""
    
            if item.type ~= "item" then
                itemData.type = "other"
                itemData.count = item.value                
                itemData.sid = const.numercialNameToId[item.type]
                itemData.quality = tb.ItemTable[itemData.sid].quality
            else
                if tb.ItemTable[item.value[1]] ~= nil then
                    itemData.count = item.value[2][1]
                    itemData.type = "item"
                    itemData.sid = item.value[1]
                    itemData.quality = tb.ItemTable[itemData.sid].quality
                elseif tb.GemTable[item.value[1]] ~= nil then
                    itemData.count = item.value[2][1]
                    itemData.type = "gem"
                    itemData.sid = item.value[1]
                    itemData.quality = tb.GemTable[itemData.sid].quality
                else
                    itemData = client.equip.parseEquip(item.value)
                    itemData.type = "equip"
                end
            end
            emailItemList[#emailItemList + 1] = itemData;  
        end

        for i = 1,#emailItemList do
            local obj = nil;
            if i < childcount then
                obj = emailRewardContnet.transform:GetChild(i-1).gameObject;
                obj:SetActive(true)
            else
                obj = newObject(prefab);
                obj.transform:SetParent(emailRewardContnet.transform);
                obj.transform.localScale = Vector3.one;
                obj.transform.localPosition = Vector3.zero;

            end
            local wrapper = obj:GetComponent("UIWrapper");
            wrapper:BindButtonClick(function ()
                UIChat.onEmailAwardItemClick(i)
            end)
            local slotCtrl = CreateSlot(obj);
            wrapper:SetUserData("ctrl",slotCtrl);
            slotCtrl.reset()
            local item = emailItemList[i]
            if item.type == "equip" then
                slotCtrl.setEquip(item);   
            else
                slotCtrl.setItem(item);
            end
            slotCtrl.setAttr(formatMoney(item.count))
        end

        --没有附件
        local btnstr = "提取附件"
        local itemnum = #emailItemList
        if itemnum == 0 then
            btnstr = "删除邮件"
        end 
        emailPanel:GO('Button.Text').text = btnstr
        emailPanel:GO('Button'):BindButtonClick(function ()
            local id = emailPanel:GetUserData("id")
            local mail = client.chat.GetMailById(id)
            if client.chat.IsMailHaveAward(mail) then
                client.chat.getEmailAward(id, emailPanelCallBack)
            else
                client.chat.deleteEmail(id, emailPanelCallBack)
            end
        end);
  
        emailPanel:GO('itemlisttext').gameObject:SetActive(itemnum > 0)  
        emailSpScrollArrow.gameObject:SetActive(itemnum > 4);
        local showed = false;

        local function EmailScrollRectValueChanged(pos)
            local itemCount = #emailItemList
            if itemCount > 4 then
                if pos.x <= 1  then
                    if not showed then
                        showed = true;
                        emailSpScrollArrow.gameObject:SetActive(true);
                    end
                else
                    if showed then
                        showed = false;
                        emailSpScrollArrow.gameObject:SetActive(false);
                    end
                end
            else
                if showed then
                    showed = false;
                    emailSpScrollArrow.gameObject:SetActive(false);
                end
            end
        end
        emailPanel:GO('ScrollView'):BindScrollRectValueChanged(EmailScrollRectValueChanged);
        emailPanel:GO('description'):GetComponent("ScrollRect").verticalNormalizedPosition = 1;
    end

    function UIChat.onEmailAwardItemClick(index)
        local item = emailItemList[index]
        
        if item.type == "item" then
            local param = {bDisplay = true, sid = item.sid,base = item};        
            PanelManager:CreateConstPanel('ItemFloat',UIExtendType.BLACKCANCELMASK,param);
        elseif item.type =="gem" then
            ui.ShowGemFloat(item, true, item.count)
        elseif item.type == "equip" then
            if item.quality == const.quality.orangepiece then
                PanelManager:CreateConstPanel('FragmentFloat',UIExtendType.BLACKCANCELMASK,{base = item});  
            else
                local param = {showType = "show", subType = "bag", isScreenCenter = true, base = item,enhance = nil}
                PanelManager:CreateConstPanel('EquipFloat',UIExtendType.BLACKCANCELMASK,param);
            end
        else 
             local param = {isCurrency = true, bDisplay = true, sid = item.sid,base = {count = item.count}};        
            PanelManager:CreateConstPanel('ItemFloat',UIExtendType.BLACKCANCELMASK,param);
        end

    end

    function UIChat.onEmailClick(go)
        local bkwrapper = go:GetComponent("UIWrapper")
        local wrapper = bkwrapper:GetUserData("basewarpper");
         if selectEmailWrap ~= nil then
            selectEmailWrap:GO('bk').imageColor = Color.New(1,1,1,0);
            selectEmailWrap:GO('bk.jiantou'):Hide();
        end
        selectEmailWrap = wrapper
        wrapper:GO('bk').imageColor = Color.New(1,1,1,1);
        wrapper:GO('bk.jiantou'):Show();
        wrapper:GO('pic').sprite = "tb_youjian_1";

        local id = bkwrapper:GetUserData("id")
        UIChat.updateEmailContent(id)
        local mail = client.chat.GetMailById(id)
        if mail.readed == 0 then
            client.chat.MarkEmailReaded(id)
            client.chat.readEmail(id)

            UIChat.refreshEmailRedTip()
        end
    end

    function UIChat.refreshEmailRedTip()
        local list = client.chat.getContentByChannel("email")
        local noreadednum = 0
        for i = 1,#list do
            if list[i].data.readed == 0 then
                noreadednum = noreadednum + 1
            end
        end
        redTipNum[redTipIndex["email"]] = noreadednum;
        RefreshRedTip();
        if redTipNum[redTipIndex["email"]] == 0 then
            UIManager.GetInstance():CallLuaMethod('MainUI.HideNewMailIcon');
        end
    end


    function UIChat.InitEmailItem()
        --处理掉已经过期的邮件
        client.chat.handleOverdueMail();
        UIChat.refreshEmailRedTip();
        client.chat.SortMail()
        local mailcount = #client.chat.getContentByChannel("email")
        local warpContent = emailItemContent:GetComponent("UIWarpContent");
        warpContent.goItemPrefab = emailPrefab;
        warpContent:BindInitializeItem(UIChat.FormatEmailItem);
        warpContent:Init(mailcount);
        if client.chat.IsHaveNotAwardMails() then
            deleteEmailAllBtn.buttonEnable = true
        else
            deleteEmailAllBtn.buttonEnable = false
        end
    end

    function UIChat.FormatEmailItem(go, index)
        local wrapper = go:GetComponent("UIWrapper")
        local mail = client.chat.GetMailByIndex(index)
        if mail == nil then return end
        local mailtable = tb.email[mail.sid]
        wrapper:GO('bk'):SetUserData("id",mail.id);
        wrapper:GO('bk'):SetUserData("basewarpper",wrapper);
        wrapper:GO('bk').imageColor = Color.New(1,1,1,0);
        wrapper:GO('bk.jiantou'):Hide();
        wrapper:GO('title').text = mailtable.title
        wrapper:GO('time').text = UIChat.FormatTime(client.chat.GetMailById(mail.id).sendtime)
        wrapper:GO('bk'):BindButtonClick(UIChat.onEmailClick)
        wrapper:GO('pic').sprite = "tb_youjian_"..mail.readed;
        wrapper:GO('pic.pin').gameObject:SetActive(client.chat.IsMailHaveAward(mail))
    end

    function UIChat.refreshDetailChatItem(go, value)
        if value == nil then
            return
        end

    	local msg = value.data;
        local posY = value.posY;

    	local rectTransform = go:GetComponent("RectTransform");
        go.transform.localPosition = Vector3.New(0, -posY, 0);

    	local wrapper = go:GetComponent('UIWrapper');
    	wrapper:GO('other').gameObject:SetActive(false);
    	wrapper:GO('my').gameObject:SetActive(false);
        wrapper:GO('system').gameObject:SetActive(false);
        wrapper:GO('time').gameObject:SetActive(false);

        --获取聊天框类型
        local isSystemMsg = false;
        if msg.isTimeStamp then
            wrapper = wrapper:GO('time');
        elseif msg.channel == "system" or msg.isSystemTip then
            wrapper = wrapper:GO('system');
            isSystemMsg = true;
    	elseif msg.role_uid == DataCache.myInfo.role_uid then
    		wrapper = wrapper:GO('my');
    	else
    		wrapper = wrapper:GO('other');
    	end

    	go = wrapper.gameObject;
        go:SetActive(true);
        msg.go = go;
    
        local titleText = wrapper:GO('Title.Text');
        if titleText then
            titleText.text = UIChat.getChatItemTitle(msg)
        end
        local head = wrapper:GO('Head');
        if head then
            head:GO("Image").sprite = client.tools.ensureString(msg.head_icon);
            head:BindButtonClick(function ()
                if msg.role_uid ~= DataCache.roleID then
                    GetRoleDetail(msg.role_uid, function ()
                        local spSelected = wrapper:GO('spSelected').gameObject;
                        UIChat.ShowOperateFloat(DataCache.otherInfo, spSelected);
                    end);                    
                end
            end)
        end

        local content = wrapper:GO('Content');
        if content then
            content.gameObject:SetActive(false);
        end

        local redPacket = wrapper:GO('RedPacket');
        if redPacket then
            redPacket.gameObject:SetActive(false);
        end

        if msg.isTimeStamp then
            content.gameObject:SetActive(true);
            content:GO('Text').text = UIChat.getTimeStamp(msg.time);
            local textComp = content:GO('Text'):GetComponent("Text");
            content:GetComponent("RectTransform").sizeDelta = Vector2.New(textComp.preferredWidth + 20, 30);
        elseif msg.redpacket ~= nil and msg.redpacket ~= 0 then
            local redpacketDb = tb.legionredpacketsevent[msg.redpacket[2]];
            redPacket:GO('Title').text = redpacketDb.title;
            redPacket.gameObject:SetActive(true);
            redPacket:BindButtonClick(function()
                client.legion.draw_Red_Packets(msg.redpacket[1]);
            end);
        else
            content.gameObject:SetActive(true);
            content:GO('RichText'):SetUserData("msg", msg);
            local richText = UIChat.setDetailChatItemText(go, msg, false);
            richText:BindClickHandler(function (str)
                UIChat.ClickRichText(content:GO('RichText').gameObject, str);
            end)
            if isSystemMsg then
                content:GetComponent("RectTransform").sizeDelta = Vector2.New(471, richText.realLineHeight + 30); --气泡大小
            else
                local width = richText.realLineWidth + 40;
                content:GetComponent("RectTransform").sizeDelta = Vector2.New(math.max(width, 106), richText.realLineHeight + 20); --气泡大小
            end
            content:BindButtonClick(function()
                UIChat.ClickRichText(content:GO('RichText').gameObject, "");
            end);
        end
    end

    function UIChat.getTimeStamp(time)
        local nowTime = TimerManager.GetServerNowSecond();
        if nowTime < time then
            return "错误时间";
        end 

        local date = os.date("*t", time);
        local nowDate = os.date("*t", nowTime);

        if nowDate.year > date.year or nowDate.month > date.month or nowDate.day - date.day > 7 then
            return string.format("%s月%s日 %s:%s", date.month, date.day, date.hour, date.min);
        elseif nowDate.day - date.day > 1 then
            return string.format("%s %s:%s", const.week[date.wday], date.hour, date.min);
        elseif nowDate.day - date.day > 0 then
            return string.format("昨天 %s:%s", date.hour, date.min);
        else
            return string.format("%s:%s", date.hour, date.min);
        end
    end

    function UIChat.getChatItemTitle(msg)
    	local channelText = "";
        if channel == "all" then
            channelText = const.chatChannel[msg.channel];
        end
	    if msg.role_uid == DataCache.myInfo.role_uid then
            return channelText.."<color=#787777>"..msg.name.."</color>";
        else
            return channelText.."<color=#787777>"..msg.name.."</color>";
        end
    end

    function UIChat.setDetailChatItemText(go, msg, speechPlaying)
        local wrapper = go:GetComponent('UIWrapper');

        --当声音播放完回调此接口，如果这个GO已经被另一条消息绑定，就不做处理
        local goMsg = wrapper:GO('Content.RichText'):GetUserData("msg");
        if goMsg ~= msg then
            return;
        end

        local soundImg = "";
        local richText = wrapper:GO('Content.RichText'):GetComponent("LRichText");
        if msg.channel == "system" or msg.isSystemTip then
            richText.normalTextColor = const.channelColor[msg.channel];
            richText.text = const.richChatChannel[msg.channel].." "..msg.text;
        elseif msg.speech == 0 then
            richText.text = msg.text;
        elseif speechPlaying then
            richText.text = "[n]"..msg.text;
            soundImg = "tb_chat_yuyin3";
        elseif msg.isPlay then
            richText.text = "[n]"..msg.text;
            soundImg = "tb_chat_yuyin2";
        else
            richText.text = "[n]"..msg.text;
            soundImg = "tb_chat_yuyin1";
        end

        local sound = wrapper:GO('Content.Sound');
        if sound and msg.speechLen then
            sound.gameObject:SetActive(msg.speech ~= 0);
            sound:GO('Text').text = msg.speechLen.."\"";
            sound:GO('Image').sprite = soundImg;
        end
        
        return richText;
    end

    function UIChat.OnDestroy() 
        client.chat.RemoveListener(listenerIndex);
    end

    local isItemInput = false;
    local lastText = "";
    function UIChat.inputValueChanged(text, inputIndex)
        local bytelength = Util.StringByteLength(text)
        if bytelength > inputCharacterLimit then
            detailChatInput.inputText = Util.CutSubstring(text, inputCharacterLimit);
            return;
        end

        local len1 = Util.StringLength(lastText);
        local len2 = Util.StringLength(text);
        if not isItemInput and inputItem.id ~= 0 then
            if len1 > len2 then
                local len = len1 - len2;
                for i=1, len do
                    local index = inputIndex + i;   --判断删除的位置是否在区间内
                    if index >= inputItemBegin and index <= inputItemEnd then
                        inputItem.id = 0;
                    end
                end
                if inputItem.id ~= 0 then
                    if inputIndex < inputItemBegin then
                        inputItemBegin = inputItemBegin - len;
                        inputItemEnd = inputItemEnd - len;
                    end
                end
            elseif len1 < len2 then
                local len = len2 - len1;
                local index = inputIndex - len;   --判断增加的起始位置是否在区间内

                if index >= inputItemBegin and index < inputItemEnd then
                    inputItem.id = 0;
                end
                if inputItem.id ~= 0 then
                    if index < inputItemBegin then
                        inputItemBegin = inputItemBegin + len;
                        inputItemEnd = inputItemEnd + len;
                    end 
                end
  
            end
        end
        isItemInput = false;
        lastText = text;
        detailChatInput.inputText = text;

    end

    function UIChat.InputItem(item, itemCfg, itemType)
        local name = "["..itemCfg.name.."]";
        local head = ""; 
        local tail = "";
        local inputText = detailChatInput.inputText;

        --原本没有物品时，加上物品的长度后计算有没有超过限制
        if inputItem.id == 0 then
            head = inputText;
            if Util.StringByteLength(head..name) > inputCharacterLimit  then
                return;
            end
            inputItemBegin = Util.StringLength(head) + 1;
        --如果原来已存在物品，就换成新的物品后再计算长度
        else
            if inputItemBegin > 1 then
                head = Util.Substring(inputText, 0, inputItemBegin - 1);
            end
            tail = Util.Substring(inputText, inputItemEnd, 0);
            if Util.StringByteLength(head..name..tail) > inputCharacterLimit then
                return;
            end
        end

        inputItemEnd = inputItemBegin + Util.StringLength(name) - 1;
        inputItem.id = item.sid;
        inputItem.name = itemCfg.name;
        inputItem.type = itemType;
        inputItem.item = item;
        inputItem.itemCfg = itemCfg;

        isItemInput = true;
        detailChatInput.inputText = head..name..tail;
    end

    function UIChat.InputEmote(emote)
        local str = detailChatInput.inputText..emote;
        if Util.StringByteLength(str) > inputCharacterLimit then
            return;
        end
        detailChatInput.inputText = str;

    end 

    function UIChat.InputLocation(location )
         local str = detailChatInput.inputText..location;
         if Util.StringByteLength(str) > inputCharacterLimit then
            return;
        end
        detailChatInput.inputText = str;

    end

    function UIChat.InputBack()
        local str = detailChatInput.inputText;
        local len = string.len(str);
        local pos = string.rfind(str, "%[");
        if pos ~= nil then
            local temp = string.sub(str, pos, -1);
            if LRichText.IsRichElement(temp) then
                detailChatInput.inputText = string.sub(str, 1, pos-1);
            else
                detailChatInput.inputText = string.sub(str, 1, -2);
            end
        else
            detailChatInput.inputText = string.sub(str, 1, -2);
        end
    end

    function UIChat.ClickRichText(go, str)
        local wrapper = go:GetComponent('UIWrapper');
        local msg = wrapper:GetUserData("msg");
        if msg == nil then
            return;
        end

        local Type;
        local subType;
        local params;

        if str == nil or str == "" then
            if msg.item ~= nil and msg.item ~= 0  then
                Type = "item";
            elseif msg.equip ~= nil and msg.equip ~= 0 then
                Type = "item";
            elseif msg.speech ~= nil and msg.speech > 0 then
                Type = "image";
                subType = "speech";
            end
        else
            params = str:split(',');
            Type = #params > 0 and params[1];
            subType = #params > 1 and params[2];
        end

        if Type == "item" then
            if msg.item ~= 0 then
                local item_id = msg.item;
                if tb.ItemTable[item_id] ~= nil then
                    PanelManager:CreateConstPanel('ItemFloat',UIExtendType.BLACKCANCELMASK,{bDisplay = true, sid = item_id});
                elseif tb.GemTable[item_id] ~= nil then
                    local param = { bDisplay = true, gem = {sid = item_id} , count = 1};
                    PanelManager:CreateConstPanel('GemFloat',UIExtendType.BLACKCANCELMASK, param);
                end
            elseif msg.equip ~= 0 then
                --橙装碎片
                if msg.equip.quality == const.quality.orangepiece then
                    PanelManager:CreateConstPanel('FragmentFloat',UIExtendType.BLACKCANCELMASK,{base = msg.equip, showButton = false});  
                else
                    local enhance = nil;
                    if msg.equip.enhance_level then
                        enhance = {level = msg.equip.enhance_level};
                    end
                    local gemList = nil;
                    if msg.equip.gem_list and #msg.equip.gem_list > 0 then
                        gemList = {};
                        for i=1, #msg.equip.gem_list do
                            gemList[i] = {}
                            gemList[i].sid = msg.equip.gem_list[i];
                        end
                    end
                    PanelManager:CreateConstPanel('EquipFloat',UIExtendType.BLACKCANCELMASK,{showType = "show",isScreenCenter = true, base = msg.equip, enhance = enhance, gemList = gemList });
                end
            end
        elseif Type == "location" then
            
            if DataCache.scene_sid == client.MolongTask.sceneSid and DataCache.scene_sid ~= tb.FindSceneId(params[2]) and client.MolongTask.BIsStart == true then
                local tip = "当前正处于护送任务过程中，离开魔龙岛会导致任务失败，是否继续？"
                ui.showMsgBox(nil, tip, function()
                    TransmitScroll.ClickLinkPathing(tb.FindSceneId(params[2]), DataCache.fenxian, Vector2.New(params[3]/2,params[4]/2));
                end)
            else
                TransmitScroll.ClickLinkPathing(tb.FindSceneId(params[2]), DataCache.fenxian, Vector2.New(params[3]/2,params[4]/2));
            end
         elseif Type == "fenxianLocation" then
            
            if DataCache.scene_sid == client.MolongTask.sceneSid and DataCache.scene_sid ~= tb.FindSceneId(params[2]) and client.MolongTask.BIsStart == true then
                local tip = "当前正处于护送任务过程中，离开魔龙岛会导致任务失败，是否继续？"
                ui.showMsgBox(nil, tip, function()
                    TransmitScroll.ClickLinkPathing(tb.FindSceneId(params[2]), params[3], Vector2.New(params[4]/2,params[5]/2));
                end)     
            else          
                TransmitScroll.ClickLinkPathing(tb.FindSceneId(params[2]), params[3], Vector2.New(params[4]/2,params[5]/2));
            end       
        elseif Type == "image" then
            if subType == "speech" then
                playList:Clear();
                UIChat.playWav(msg);
            end
        end
    end

    local isPlaying = false;
    local curPlayMsg = nil;
    function UIChat.playSpeech()
        if isPlaying or playList:Empty() then
            return;
        end
        local msg = playList:PopFront();
        UIChat.playWav(msg);
    end

    function UIChat.playWav(msg)
        isPlaying = true;
        curPlayMsg = msg;
        UIChat.setDetailChatItemText(msg.go, msg, true);

        if msg.speechData then
            Util.PlayWav(msg.speechData);
        else
            client.chat.getSpeechFromServer(
                function (data)
                    msg.speechData = data.speech;
                    Util.PlayWav(data.speech);
                end, msg.speech);
        end
    end

    function UIChat.playFinish()
        isPlaying = false;
        if curPlayMsg ~= nil then
            curPlayMsg.isPlay = true;
            UIChat.setDetailChatItemText(curPlayMsg.go, curPlayMsg, false);
        end

        UIChat.playSpeech();
    end


    function UIChat.ShowSelect(go)
        go:SetActive(true);
    end

    function UIChat.LostSelect(go)
        go:SetActive(false);
    end

    --changeByLiuz
    function UIChat.ShowOperateFloat(data, go)        
        local btnList = {"sendMsg","roleInfo","addFriend","complain"};

        if client.role.haveClan() and math.abs(client.legion.LegionBaseInfo.SelfJur[1]) == 1 and data.offline == false and data.level >= 30 then
            table.insert(btnList,"legionInvitation");
        end 
        
        if client.team.team_uid ~= 0 or data.team_uid == 0 then
            table.insert(btnList, "inviteTeam");
        else
            table.insert(btnList, "applyTeam");
        end
        
        const.operateFloatPos.chat.pos =  const.operateFloatPos.chat.pos or Vector2.New(detailChatPanel.transform.sizeDelta.x, 106);
        UIChat.ShowSelect(go);
        ui.ShowOperateFloat(data, btnList, const.operateFloatPos.chat, this, function() UIChat.LostSelect(go); end, "UIChat");
    end

    return UIChat;
end