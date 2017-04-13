function UISmeltEquipListView()
	local UISmeltEquipList = {};
	local this = nil;
	local equiplist = nil;
	local equipContainer = nil;

	function UISmeltEquipList.Start() 
        this = UISmeltEquipList.this;
    	this:GO('Panel.close'):BindButtonClick(UISmeltEquipList.closeSelfAndCancelReturnFromSelect);
    	this:GO('Panel.ok'):BindButtonClick(UISmeltEquipList.onOK);

    	if LuaCache.Ronglian == nil then
			LuaCache.Ronglian = {}
			LuaCache.Ronglian.MaxCount = 5;
		end
		if LuaCache.Ronglian.Items == nil then
			LuaCache.Ronglian.Items = {}
		end
		
    	equipContainer = this:GO('Panel.equiplist');
    	equiplist = Smelt.getEquipList();

    	--PanelManager:LoadUIAsset("UI","EquipItem", UISmeltEquipList.loadEquipItem);

    	local prefab = equipContainer:LoadAsset("EquipItem");
    	UISmeltEquipList.loadEquipItem(prefab);
    	
	end

	function UISmeltEquipList.loadEquipItem(prefab)
		
		if equiplist == nil then
			return;
		end
		
		local warpContent = equipContainer:GetComponent("UIWarpContent");
		warpContent.goItemPrefab = prefab;
		warpContent:BindInitializeItem(UISmeltEquipList.FormatItem);
		warpContent:Init(#equiplist);
	end

	function UISmeltEquipList.FormatItem(go, index)
		local equip = equiplist[index];
		local equipItem = tb.EquipTable[equip.sid];

		local wrapper = go:GetComponent('UIWrapper');
		local slotCtrl = wrapper:GetUserData("ctrl");
		if slotCtrl == nil then
			local slotGo = wrapper:GO('Slot').gameObject;
			slotCtrl = CreateSlot(slotGo);
			wrapper:SetUserData("ctrl", slotCtrl);
		end
		slotCtrl.reset();
		slotCtrl.setEquip(equip);
		slotCtrl.setHigh(DataCache.myInfo.level >= equipItem.level and client.equip.isHighScore(equip));
		slotCtrl.setChoose(Smelt.isSelectedItem(equip.pos));

		wrapper:SetUserData('bagindex', equip.pos);
		wrapper:GO('Slot'):BindButtonClick(UISmeltEquipList.onClick);
	end

	function UISmeltEquipList.onOK(wrapper)
		UISmeltEquipList.closeSelfAndCancelReturnFromSelect()
	end

	function UISmeltEquipList.unselectItem(bagindex, go)
		Smelt.unselectItem(bagindex);
		local wrapper = go:GetComponent('UIWrapper');
		wrapper:GO("choosen"):Hide();
	end

	function UISmeltEquipList.selectItem(bagindex, go)
		Smelt.selectItem(bagindex);
		local wrapper = go:GetComponent('UIWrapper');
		wrapper:GO("choosen"):Show();
	end

	function UISmeltEquipList.onClick(go)
		local wrapper = go:GetComponent('UIWrapper');
		local bagindex = wrapper.Parent:GetUserData('bagindex');
		if Smelt.isSelectedItem(bagindex) then
			UISmeltEquipList.unselectItem(bagindex, go);
		else
			local items = LuaCache.Ronglian.Items;
			if #items == 5 then
				ui.showMsg("最多只能选择5个装备!");
				return;
			end
			UISmeltEquipList.selectItem(bagindex, go);
		end
	end

	function UISmeltEquipList.OnDestroy()
		-- body
	end

	function UISmeltEquipList.closeSelfAndCancelReturnFromSelect()
        UIManager.GetInstance():CallLuaMethod('UISmelt.refreshSmeltUI');
        UISmeltEquipList.closeSelf();

	end

    function UISmeltEquipList.closeSelf()
        destroy(this.gameObject);
	end
    return UISmeltEquipList;
end

