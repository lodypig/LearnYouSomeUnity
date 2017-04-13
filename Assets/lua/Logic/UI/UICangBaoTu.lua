function UICangBaoTuView ()
	local UICangBaoTu = {};
	local this = nil;

	local BackGroud = nil;
	local Panel = nil;
	local AwardArea = nil;
	local InfoDes1 = nil;
	local InfoDes2 = nil;
	local GoButton = nil;
	local LeftInfo = nil;

    local dropList = {};
    local dropItemList = {};

    --次数上限
    local MAXCBTCount = 5;

    --装备奖励
    local dropequip = {soldier={},
                        bowman={},
                        magician={},};
	--物品奖励（可能有宝石）
    local dropitem = {const.item.reward_task_refresh, const.item.fuben_sweep_ticket, const.item.chuansong, 11150001, const.item.money};

    --获取可能掉落的物品列表
	function UICangBaoTu.GetDropList()
		local career = DataCache.myInfo.career;
		local equipList = dropequip[career];
		local list = {};
		for i=1, #equipList do
			local equipId = equipList[i][1];
			local equipTable = tb.EquipTable[equipId];
			list[i] = {icon = equipTable.icon, quality = equipList[i][2], sid = equipId, type = "equip"};
		end

		for i=1, #dropitem do
			local itemId = dropitem[i]
			local itemTable = tb.ItemTable[itemId];
            if nil == itemTable then
                itemTable = tb.GemTable[itemId]
                list[#list + 1] = {icon = itemTable.icon, quality = itemTable.quality, type = "gem", sid = itemId};
            else
                list[#list + 1] = {icon = itemTable.icon, quality = itemTable.quality, sid = itemId, type = "item"}; 
            end
		end

		return list;
	end

    function UICangBaoTu.RefreshDrop()
		--显示掉落物品
		local prefab = this:LoadAsset("BagItem");
		for i=1, #dropList do
            if i > #dropItemList then
                local item = newObject(prefab);
                item.transform:SetParent(AwardArea.transform);
                item.transform.localScale = Vector3.one;
                item.transform.localPosition = Vector3.zero;
                dropItemList[i] = item:GetComponent("UIWrapper");
				dropItemList[i]:SetUserData("ctrl",CreateSlot(item));
			end

			dropItemList[i]:BindButtonClick(function()
				UICangBaoTu.dropClick(i);
			end);

			dropItemList[i].gameObject:SetActive(true);
            local data = dropList[i];
            local slotCtrl = dropItemList[i]:GetUserData("ctrl");
            slotCtrl.reset();
            slotCtrl.setData(data);
        end
	end

    function UICangBaoTu.dropClick(index)
    	local item = dropList[index];
        
        if item.type == "item" then
            local param = {bDisplay = true, sid = item.sid};        
            PanelManager:CreateConstPanel('ItemFloat',UIExtendType.BLACKCANCELMASK, param);
        elseif item.type =="gem" then
            ui.ShowGemFloat(item, true, 1)
        else
            local param = {showType = "show", subType = "bag", isScreenCenter = true, base = item, enhance = nil}
            PanelManager:CreateConstPanel('EquipFloat',UIExtendType.BLACKCANCELMASK,param);
        end
    
    end

	function UICangBaoTu.Start ()
		this = UICangBaoTu.this;
		BackGroud = this:GO('_BackGroud');
		Panel = this:GO('_Panel');
		AwardArea = this:GO('_Panel._AwardArea');
		InfoDes1 = this:GO('_Panel._InfoDes1');
		InfoDes2 = this:GO('_Panel._InfoDes2');
		GoButton = this:GO('_Panel._GoButton');
		LeftInfo = this:GO('_Panel._LeftInfo');

        local commonDlgGO = this:GO('CommonDlg3');
        UICangBaoTu.controller = createCDC(commonDlgGO);
        UICangBaoTu.controller.SetTitle("wz_cangbaotu");
        UICangBaoTu.controller.bindButtonClick(0,UICangBaoTu.closeSelf);
        --todo 配置 描述相关

        UICangBaoTu.ShowCount(); 
        dropList = UICangBaoTu.GetDropList();
        UICangBaoTu.RefreshDrop();

        --todo 移动backgroud 到 frame之上
        -- BackGroud.transform:SetParent(commonDlgGO.transform);
        local pos = this:GO('CommonDlg3.Frame'):GetComponent('RectTransform'):GetSiblingIndex();
        local rt = BackGroud:GetComponent('RectTransform');
        rt:SetParent(commonDlgGO:GetComponent('RectTransform'));
        rt.localScale = Vector3.one;
        rt:SetSiblingIndex(pos);


        GoButton:BindButtonClick(UICangBaoTu.BeginCBT);

        EventManager.bind(this.gameObject, Event.ON_CBT_Changed, UICangBaoTu.OnCBTChanged);
	end

    function UICangBaoTu.BeginCBT ()
        if client.CBTCtrl.get_cbt_count() < MAXCBTCount then
            client.CBTCtrl.begin_cbt(true);
            UICangBaoTu.closeAll();
        else
           ui.showMsg("没有剩余次数");
        end

	end


    function UICangBaoTu.ShowCount() 
        LeftInfo.text = "今日完成次数"..client.CBTCtrl.get_cbt_count().."/"..MAXCBTCount;
	end

    function UICangBaoTu.OnCBTChanged()
        UICangBaoTu.ShowCount();
    end

    function UICangBaoTu.closeSelf()
		destroy(this.gameObject);
	end

    function UICangBaoTu.closeAll()
        local wrapper = UIManager.GetInstance():FindUI("UIActivity");
        UICangBaoTu.closeSelf();
        if wrapper then
            destroy(wrapper.gameObject);
        end
        UIManager.GetInstance():CallLuaMethod('UIMenu.closeSelf');
    end
	return UICangBaoTu;
end
