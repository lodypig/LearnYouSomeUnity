function CreateLoginManager()

    local t = {};
    t.bShow = false;


    t.ReloginScene = function ()

        local player = AvatarCache.me;
        if player == nil then
            return;
        end
        local myInfo = DataCache.myInfo;

        local msg = {}
        msg.cmd = "relogin_scene";
        msg.roleID = myInfo.role_uid;
        msg.pos={};
        msg.pos[1] = player.pos_x;
        msg.pos[2] = player.pos_y;
        msg.pos[3] = player.pos_z;
        msg.useID = DataCache.userID;

        -- print("send relogin_scene");
        -- print(string.format("useID=%d", DataCache.userID));

        Send(msg, function(loginSceneMsg)
            local rError = loginSceneMsg["error"];
            if nil == rError then

                local need_change_scene = false;

                local myInfo = DataCache.myInfo;
                myInfo.id = loginSceneMsg["node_id"];           -- 玩家节点id
                local map_info = loginSceneMsg["scene_name"];   -- 场景信息
                local map_scene_id = map_info[1];   -- 场景 sid
                local mapName = map_info[2];        
                local map_fen_xian = tonumber(mapName[2]);    -- 场景分线
                if DataCache.scene_sid ~= map_scene_id or
                   DataCache.fenxian ~= map_fen_xian then
                   need_change_scene = true;
                end

                DataCache.scene_sid = map_scene_id;
                DataCache.fenxian = map_fen_xian;
                DataCache.fenxianFlag = tb.SceneTable[map_scene_id].fenxianFlag;

                local attr = loginSceneMsg.attr;
                DataCache.ParseAttr(attr, myInfo);
                DataCache.role_money = loginSceneMsg.role_money;
                DataCache.role_diamond = loginSceneMsg.role_diamond;
                DataCache.role_goumaili = loginSceneMsg.role_goumaili;
                DataCache.role_jingtie = loginSceneMsg.role_jingtie;
                DataCache.talentBook = loginSceneMsg.talentBook;
                DataCache.guideList = client.tools.parseArrayList(loginSceneMsg["guide"])      
                Bag.InitWearList();
                EventManager.onEvent(Event.ON_RELOGIN);

                -- 清除当前目标
                TargetSelecter.ClearTarget();

                if need_change_scene then
                    SceneManager.LoadScene(map_scene_id);   -- 加载场景
                else
                    local msg = { cmd = "confirm_login" };
                    Send(msg);
                end
            else
              	--print(rError);
                t.ReloginScene();
            end
        end)
    end;

    t.OnRelogin = function ()

        uFacadeUtility.DestroyAllDropItems();

        local player = AvatarCache.me;
        if player == nil then
            return;
        end

        --现在重连不用删除旧的怪物
        local temp = AvatarCache.GetAllAvatars();
        local avatars = {};
        for k, v in pairs(temp) do
            avatars[k] = v;
        end
        for k, v in pairs(avatars) do
            local avatar = v;
            if avatar.id ~= AvatarCache.me.id then
                uFacadeUtility.DestroyAvatarImmediate(avatar.id);
                AvatarCache.RemoveAvatar(avatar);
            end
        end

        t.ReloginScene();
    end;

    t.ShowReconnectFailed = function()
        Net.showConnectFailed = true;
        ui.showMsgBox(nil, "重新连接失败，是否重试？", 
            function()
                Util.NetReconnect();
                Net.showConnectFailed = false;
            end,
            function ()
                SceneLoader.GetInstance():ReturnToLoginUI();
                Net.showConnectFailed = false;
            end);
    end

    t.ShowConnectFailed = function()    
        ui.showMsgBox(nil, "连接失败，详情请咨询官方客服", nil, nil, true);
    end

    -- 连接丢失
    t.ConnectLost = function()
        if DataCache.myInfo == nil then
            ShowConnectFailed();
        else
            Util.NetReconnect();
        end
    end

    t.ShowConnectUI = function (bShow)
        t.bShow = bShow == true;
        if t.connectUI == nil then
            if bShow then
                PanelManager:CreateConstPanel("ConnectUI", UIExtendType.TRANSMASK, function (go)
                    if ui.connectUI ~= nil then
                        destroy(ui.connectUI)
                    end
                    t.connectUI = go;
                    go:SetActive(t.bShow);
                end, nil, true);
            end
        else
            t.connectUI:SetActive(bShow);
        end
    end

    return t;
end

LoginManager = CreateLoginManager();

