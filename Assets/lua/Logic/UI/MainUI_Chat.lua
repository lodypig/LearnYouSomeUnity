function MainUIChatView()
    local MainUIChat = {};

    local this = nil;

    --主界面聊天区
    local clickMainChat = false;
    local panelPos = nil;
    local isMainChatExpand = false;
    local mainChatPanel = nil;
    local mainChatContainer = nil;
    local mainChatItem = nil;
    local btnVoice = nil;
    local channelList = {"team", "clan", "world"};
    local voiceIcon = {"an_liaotian_1", "an_liaotian_2" ,"an_liaotian_3"};
    local voiceChannelIndex = 1;

    --交互提醒区
    local TipsPanel = nil;
    local Tips = nil;
    local ItemPrefab = nil;
    local email = nil;
    local juntuan = nil;
    local zudui = nil;
    local activity = nil;
    local noticeBtn = nil;
    local repairIcon = nil;
    local delayCallId = 0;
    local fromWhere = nil;

    function MainUIChat.Start()      
        this = MainUIChat.this;

        --主界面聊天区域
        mainChatPanel = this:GO('MainChat');
        mainChatPanel.gameObject:SetActive(true);
        panelPos = mainChatPanel.transform.localPosition;
        this:GO('MainChat'):BindETBeginDrag(function () clickMainChat = true; end);
        this:GO('MainChat'):BindETEndDrag(function () clickMainChat = false; end);

        this:GO('MainChat.BoxCollider'):BindButtonClick(MainUI.showDetailChat);
        this:GO('MainChat.BtnSetting'):BindButtonClick(MainUI.showSetting);
        this:GO('MainChat.BtnScale'):BindButtonClick(MainUI.scaleMainChat);
        ItemPrefab = this:GO('MainChat.TipsPanel.Tips.Item');
        mainChatContainer = this:GO('MainChat.Viewport.Content').gameObject;
        mainChatItem = this:GO('MainChat.Viewport.Content.RichText').gameObject;
        mainChatItem:SetActive(false);
        btnVoice = this:GO('MainChat.Voice');
        btnVoice:BindETButtonDown(MainUI.openVoice);
        btnVoice:BindETButtonUp(MainUI.closeVoice);
        btnVoice:BindETTouchEnter(MainUI.touchVoiceEnter);
        btnVoice:BindETTouchExit(MainUI.touchVoiceExit);

        --初始语音按钮状态
        if client.role.haveTeam() then
            voiceChannelIndex = 1;
        elseif client.role.haveClan() then
            voiceChannelIndex = 2;
        else
            voiceChannelIndex = 3;
        end
        MainUI.SetVoiceIcon( );

        --提示区域
        noticeBtn = this:GO('MainChat.TipsPanel.Image1');
        repairIcon = this:GO('MainChat.TipsPanel.repairIcon');
        TipsPanel = this:GO('MainChat.TipsPanel');
        Tips = this:GO('MainChat.TipsPanel.Tips')
        email = TipsPanel:GO('Tips.email');
        juntuan = TipsPanel:GO('Tips.juntuan');
        zudui = TipsPanel:GO('Tips.zudui');
        activity = TipsPanel:GO('Tips.activity');
        email:BindButtonClick(function()
            MainUI.showDetailChat();
            UIManager.GetInstance():CallLuaMethod('UIChat.OpenEmailPanelList');
            --email.gameObject:SetActive(false);
        end);

        juntuan:BindButtonClick(function()
            -- do something
            juntuan.gameObject:SetActive(false);
        end);

        activity:BindButtonClick(function()
                if true then ui.showMsg("暂未开放"); activity.gameObject:SetActive(false) return nil; end --NSY-4793 临时屏蔽
                local param = {page = "findbackAct"};
                PanelManager:CreatePanel('UIActivity' , UIExtendType.TRANSMASK, param);
            --UIManager.GetInstance():CallLuaMethod('UIActivity')
            end)
        MainUI.HideRepairIcon();
        if #Bag.BrokenMap > 0 then
            MainUI.ShowRepairIcon();
        end
        repairIcon:BindButtonClick(MainUI.clickRepairIcon); 
 
        client.chat.getChatRecord();

        EventManager.bind(this.gameObject,Event.ON_MAINUI_HIDE, MainUIChat.Hide);
        EventManager.bind(this.gameObject,Event.ON_MAINUI_SHOW, MainUIChat.Show);
    end

	function MainUIChat.OnDestroy(  )
        
	end

    function MainUIChat.Hide()
        mainChatPanel.transform:DOLocalMoveY(panelPos.y - 300, 0.5, false);
    end

    function MainUIChat.Show()
        if ui.showUIChat == true then
            ui.showUIChat = false;
            MainUI.showDetailChat();
        else
            mainChatPanel.transform:DOLocalMoveY(panelPos.y, 0.3, false);
        end
    end


    -- 交互提醒区
    function MainUI.AddTips(param)
        if param.type == const.TIPS_Type.Email then
            MainUI.AddTips_Email();
        elseif param.type == const.TIPS_Type.Juntuan then
            MainUI.AddTips_Juntuan();
        --组队提示已去除
        -- elseif param.type == const.TIPS_Type.Zudui then
        --     MainUI.AddTips_Zudui();
        elseif param.type == const.TIPS_Type.Activity then
            MainUI.AddTips_Activity();
        else
            MainUI.AddTips_Other(param);
        end
    end

    function MainUI.AddTips_Email()
        email.gameObject:SetActive(true);
        local rt = email:GetComponent("RectTransform");
        rt:SetAsFirstSibling();
    end

    function MainUI.ShowTipsEmail(show)
        if show then
            email.gameObject:SetActive(true);
            local rt = email:GetComponent("RectTransform");
            rt:SetAsFirstSibling();
        else
            email.gameObject:SetActive(false);
        end
    end

    function MainUI.AddTips_Juntuan()
        juntuan.gameObject:SetActive(true);
        local rt = juntuan:GetComponent("RectTransform");
        rt:SetAsFirstSibling();
    end

    -- function MainUI.AddTips_Zudui()
    --     zudui.gameObject:SetActive(true);
    --     local rt = zudui:GetComponent("RectTransform");
    --     rt:SetAsFirstSibling();
    -- end

    function MainUI.AddTips_Activity()
        activity.gameObject:SetActive(true);
        local rt = activity:GetComponent("RectTransform");
        rt:SetAsFirstSibling();
    end

    function MainUI.AddTips_Other(param)
        local go = newObject(ItemPrefab.gameObject);
        go:SetActive(true);
        go.name = 'item'..tostring(#const.AllTips+1);
        go.transform:SetParent(Tips.transform);
        go.transform.localScale = Vector3.one;
        go.transform.localPosition = Vector3.zero;
        go:SetNaiveSize();
        const.AllTips[#const.AllTips+1] = go;

        local wrapper = go:GetComponent("UIWrapper");
        wrapper.sprite = "tb_jiaohu_1";
        wrapper:GO("Image").sprite = const.TIPS_BG[param.type];
        wrapper:BindButtonClick(function ()
            MainUI.ItemClick(param, go, #const.AllTips);
        end);
        local rt = wrapper:GetComponent("RectTransform");
        rt:SetAsFirstSibling();
    end

    function MainUI.DeleteActivityTip()
        activity.gameObject:SetActive(false);
    end

    function MainUI.DeleteTip(go, k)
        local delete = Tips:GO(go.name);
        destroy(delete.gameObject);
        for i = k, #const.AllTips - 1 do
            const.AllTips[k] = const.AllTips[k+1];
        end
        const.AllTips[#const.AllTips] = nil;
    end

    function MainUI.ItemClick(param, go, i)
        if param.type == const.TIPS_Type.Activity then
        end
        if param.type == const.TIPS_Type.Other then

        end
    end

    function MainUI.SetVoiceIcon()
        btnVoice:GO("Voice").sprite = voiceIcon[voiceChannelIndex];
    end

    local isVoiceTouchEnter = false;
    local isShortPress = false;
    function MainUI.openVoice()
        isShortPress = true;

        delayCallId = this:Delay(0.3, function()
                --长按发送语音
                isShortPress = false;
                local channel = channelList[voiceChannelIndex];
                if client.chat.canSend(channel) then
                    NativeManager.GetInstance():StartSpeech();
                    client.speechChannel = channel;
                end
            end);
        
    end

    function MainUI.closeVoice()
        if isShortPress then
            this:CancelDelay(delayCallId);

            --切换语音图标
            voiceChannelIndex = voiceChannelIndex + 1;
            if voiceChannelIndex > #channelList then
                voiceChannelIndex = 1;
            end
            MainUI.SetVoiceIcon( )

            return;
        end

        --发送语音
        if NativeManager.GetInstance().isStartSpeech then
            if isVoiceTouchEnter then
                NativeManager.GetInstance():StopSpeech();
            else
                NativeManager.GetInstance():CancelSpeech();
            end
        end
    end

    function MainUI.touchVoiceEnter( )
        local lua = UIManager.GetInstance():FindUI("UIChat"):GetComponent("LuaBehaviour");
        lua:CallLuaMethod("setSpeechTip", true);
        isVoiceTouchEnter = true;
    end

    function MainUI.touchVoiceExit( )
        local lua = UIManager.GetInstance():FindUI("UIChat"):GetComponent("LuaBehaviour");
        lua:CallLuaMethod("setSpeechTip", false);
        isVoiceTouchEnter = false;
    end


    function MainUI.addChatRecord( )
        local chatList = client.chat.getContentByChannel("world");
        local count = 8;
        if #chatList < count then
            count = #chatList;
        end

        for i=#chatList - count + 1, #chatList do
            MainUI.addMainChatItem(chatList[i].data);
        end
    end
    local mainChatList = List:New();

    function MainUI.addMainChatItem(msg)
        local text = msg.text;
        if msg.speech and msg.speech > 0 then
            text = "[#502:speech]"..text;
        end
        local richText;

        if mainChatList:Size() > 20 then
            richText = mainChatList:PopFront();
        else
            local go = newObject(mainChatItem);
            go:SetActive(true);
            go.transform:SetParent(mainChatContainer.transform);
            go.transform.localScale = Vector3.one;
            go.transform.localPosition = Vector3.zero;
            richText = go:GetComponent("LRichText");
        end

        richText.normalTextColor = const.channelColor[msg.channel];
        richText.linkTextColor = const.systemChannelLink; --超连接颜色设置
        if msg.channel == "system" or msg.isSystemTip then
            richText.text = const.richChatChannel[msg.channel].." "..text;
        else
            local name =  client.tools.formatRichTextColor(msg.name..":", const.mainChat.nameColor);
            richText.text = const.richChatChannel[msg.channel].." "..name..text;
        end

        local wrapper = richText:GetComponent("UIWrapper");
        wrapper:SetUserData("msg", msg);
        richText:BindClickHandler(function (str)
            MainUI.ClickRichText(wrapper.gameObject, str);
        end)

        mainChatList:PushBack(richText);
        MainUI.fixMainChatHeight();
    end

    function MainUI.ClickRichText(go, str)
        local wrapper = go:GetComponent('UIWrapper');
        local msg = wrapper:GetUserData("msg");
        if msg == nil then
            return;
        end

        local params = str:split(',');
        local Type = #params > 0 and params[1];
        local subType = #params > 1 and params[2];
       
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
        else
            MainUI.showDetailChat();
        end
    end

    function MainUI.fixMainChatHeight()
        local totalHeight = 0;
        local start = mainChatList:Begin();
        local richText;
        while start:Valid() do
            richText = start:Value();
            richText:GetComponent("RectTransform").anchoredPosition = Vector2.New(5, -totalHeight);
            totalHeight = totalHeight + richText.realLineHeight;
            start:Next();
        end

        totalHeight = totalHeight + 3;--防止底部被切，多加几个像素

        local limitHeight = isMainChatExpand and 193 or 88;
        ui.setNodeHeight(mainChatContainer, totalHeight);

        --只有在鼠标松开时才跳到新消息位置
        if clickMainChat == false then
            if limitHeight  < totalHeight then
                mainChatContainer.transform.localPosition = Vector3.New(0, totalHeight - limitHeight, 0);
            else
                mainChatContainer.transform.localPosition = Vector3.New(0, 0, 0);
            end
        end
    end

    function MainUI.showDetailChat()
        UIManager.GetInstance():CallLuaMethod('UIChat.showDetailChat');
        if MainUI.isShow then
            MainUI.ShowBottomUI(false)
            MainUIChat.Hide();
        end
    end

    function MainUI.closeDetailChat()
        if MainUI.isShow then
            MainUI.ShowBottomUI(true)
            MainUIChat.Show();
        end
    end
    
    function MainUI.scaleMainChat()
        isMainChatExpand = not isMainChatExpand;
        ui.setNodeHeight(mainChatPanel.gameObject, isMainChatExpand and 199 or 117.5);
        this:GO('MainChat.BtnScale.Image').transform.localEulerAngles = Vector3.New(0,0, isMainChatExpand and 180 or 0);
        MainUI.fixMainChatHeight()
    end

    function MainUI.showSetting()
        UIManager.GetInstance():CallLuaMethod('UIChat.showSetting');
    end

    --提醒区域
    -- function MainUI.CheckLegionInviteTip() -- 
    --     juntuan.gameObject:SetActive(#client.legion.LegionInvitationList > 0);
    --     if #client.legion.LegionInvitationList > 0 then
    --         local param = {type = const.TIPS_Type.Juntuan}
    --         MainUI.AddTips(param);
    --     end
    --     juntuan:BindButtonClick(function ()
    --         local legionInfo = client.legion.LegionInvitationList[#client.legion.LegionInvitationList];
    --         local text = string.format("%s邀请你加入%s",legionInfo.rolename, legionInfo.legionname);
    --         ui.showMsgBox("公会邀请",text,client.legion.Agree_Invited,client.legion.Refuse_Invited,nil,legionInfo.roleid);

    --         table.remove(client.legion.LegionInvitationList,#client.legion.LegionInvitationList); -- 点击之后移除最近一个邀请

    --         MainUI.CheckLegionInviteTip();
    --     end);
    -- end
    
    -- 玩家已公会，而左侧交互信息区公会邀请，此时需要关闭左侧交互提醒区
    function MainUI.CloseQuickOperateBySystem(systemName)
        if fromWhere ~= nil and systemName == fromWhere then
            MainUI.CloseQuickOperate();
        end
    end


    function MainUI.JoinTeam()
        voiceChannelIndex = 1;
        MainUI.SetVoiceIcon( )
    end

    function MainUI.ClearTeam( )
        if client.role.haveClan() then
            voiceChannelIndex = 2;
        else
            voiceChannelIndex = 3;
        end
        MainUI.SetVoiceIcon( )
    end


    function MainUI.ShowRepairIcon()
        repairIcon.gameObject:SetActive(true);
    end

    function MainUI.HideRepairIcon()
        repairIcon.gameObject:SetActive(false);
    end

    function MainUI.clickRepairIcon()
        MainUI.HideRepairIcon();
        PanelManager:CreatePanel('NewUIRole',  UIExtendType.TRANSMASK, {panelType = "Bag"});
        local item = Bag.BrokenMap[1];
        if item ~= nil then
            local equip =  Bag.wearList[item.index];
            local itemCfg = tb.EquipTable[equip.sid];
            local enhanceInfo = Bag.enhanceMap[itemCfg.buwei];
            local gemInfo = client.gem.getEquipGem(itemCfg.buwei);
            PanelManager:CreateConstPanel('EquipFloat',UIExtendType.BLACKCANCELMASK,{showType = "self", subType = "wear", isScreenCenter = true,  index = item.index, base = equip,enhance = enhanceInfo, gemList = gemInfo});
        end
    end

    function MainUI.ActiveNoticeBtn(func)
        noticeBtn.gameObject:SetActive(true);
        noticeBtn:BindButtonClick(func)
    end

    function MainUI.HideNoticeBtn()
        noticeBtn.gameObject:SetActive(false);
    end

    return MainUIChat;
end

