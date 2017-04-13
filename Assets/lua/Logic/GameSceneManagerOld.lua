------------------------------------------------------- init handler ---------------------------------------------------
client.gcm =  (function ()
    local module = {};

    function module.handleBagChange(msg)
        local IsShowMsg = true;
        local itemType = msg.type
        local item = msg.item;
        local add = msg.add;
        local limitSize = msg.limitSize;

        if itemType == "equipment" then
            Bag.updateWearList(item);
            return;
        end

        for i,v in ipairs(const.NotNeedShowItemMsg) do
            if msg.where == v then
                IsShowMsg = false;
            end
        end
        Bag.updateBag(item, add, IsShowMsg, limitSize);

        if (itemType == "equip") or (itemType == "mid_equip") then
            EventManager.onEvent(Event.ON_EVENT_EQUIP_CHANGE);
        elseif itemType == "item" then
            EventManager.onEvent(Event.ON_EVENT_ITEM_CHANGE);
        elseif itemType == "gem" then
            EventManager.onEvent(Event.ON_EVENT_GEM_CHANGE);
        elseif itemType == "all" then
            EventManager.onEvent(Event.ON_EVENT_EQUIP_CHANGE);
            EventManager.onEvent(Event.ON_EVENT_ITEM_CHANGE);
            EventManager.onEvent(Event.ON_EVENT_GEM_CHANGE);
        end
    end

    --被顶号下线
    function module.beReloginLogout(msg)
        Net.showConnectFailed = true;
        Net.Close();
        ui.showMsgBox(nil, "当前账号在其他设备登录，你已被强制下线", function()
            Net.showConnectFailed = false;
            SceneManager.ReturnToLoginUI();
        end, nil, true);
    end


    function module.UpdateStoneNumber(id,energy_stone)
        if energy_stone ~= nil then
            if id == DataCache.myInfo.id then
                if client.StoneNumberTable[id] == 10 and energy_stone ~= -1 then
                    ui.showMsg("能量石已达最大上限");
                end
            end
            client.StoneNumberTable[id] = energy_stone;
            if energy_stone == -1 then
                client.MolongTask.BIsStart = false;
            end
            --走到这里必然是自己的能量石更新
            local NpdId = client.MolongTask.getNengliangche();
            module.UpdateTitle(NpdId,energy_stone);
        end
    end

    function module.UpdateTitle(NpdId,energy_stone)
        if AvatarCache.HasAvatar(NpdId) == true then
            local HeadTitle = uFacadeUtility.GetAvatarTitle(NpdId);
            -- local HeadTitle = DataCache.sceneAvatar[NpdId]:GetComponent("HeadTitle");
            if HeadTitle ~= nil then
                local esWrapper = HeadTitle:GO("Panel.Other.EnergyStone");
                local esNumberWrapper = HeadTitle:GO("Panel.Other.EnergyStone.Number");
                if energy_stone >= 0 then
                    esWrapper.gameObject:SetActive(true);
                    esNumberWrapper.text = energy_stone;
                    -- HeadTitle:ShowEnergyStone(true);
                    -- HeadTitle:SetStoneNumber(energy_stone);
                elseif energy_stone < 0 then 
                    esWrapper.gameObject:SetActive(false);
                    -- HeadTitle:ShowEnergyStone(false);
                end
            end
        end
    end

    function module.InitStoneNumber(id,energy_stone)
        if energy_stone ~= nil then 
            client.StoneNumberTable[id] = energy_stone;
        end
    end

    return module;
end)()


-------------------------------------------------------  init port ------------------------------------------------------
SetPort("bag_changed", client.gcm.handleBagChange);
SetPort("be_relogin_logout", client.gcm.beReloginLogout);
