function UIBossView()
	local UIBoss = {};
	local this = nil
	local leftPanel = nil;
	local top = nil;
	local bottom = nil;
	local dropContent = nil;
	local dropListInfo = {};  -- 掉落列表
	local dropItemList = {}
	local lastselect = 1;
	local lock = {};
	local locked = 1;
	local BagItem = nil;
	local bagItemCount = 1;
	local itemPrefab = nil;
	local length = 0;
	function UIBoss.Start()
		this = UIBoss.this
		BagItem = this:GO('Panel.RightPanel.bottom.dropList.Item1');
		dropItemList[1] = BagItem:GetComponent("UIWrapper");
		local commonDlgGO = this:GO('CommonDlg');
		commonDlgGO:GO('Close'):BindButtonClick(UIBoss.closeSelf);
		leftPanel = this:GO('Panel.LeftList.viewport.content');
		itemPrefab = this:GO('Panel.LeftList.viewport._Item').gameObject;
		top = this:GO('Panel.RightPanel.top');
		bottom = this:GO('Panel.RightPanel.bottom');
		dropContent = bottom:GO('dropList');
		-- 根据玩家当前等级默认选择显示页面
		--Send({cmd = "get_boss"}, UIBoss.FirstCB);
		UIBoss.Init();
		UIBoss.FirstShowUI();
		-- Util.SetGray(leftPanel:GO('0.Item.Bg.icon').gameObject, true);
		-- 服务端首次开启活动则直接解锁35级boss
		-- UIBoss.ShowState();
	end

	function UIBoss.Init()
		local list = tb.ActivitiesInfoTable;
		for k, v in pairs(list) do
			if v ~= nil then
				length = length + 1;  
			end
		end
		local warpContent = this:GO('Panel.LeftList'):GetComponent("UIWarpContent");
		warpContent.goItemPrefab = itemPrefab;
		warpContent:BindInitializeItem(UIBoss.FormatItem);
		warpContent:Init(length);
		itemPrefab.gameObject:SetActive(false)
	end

	function UIBoss.FormatItem(go, index)
		local wrapper = go:GetComponent("UIWrapper");
		local BossStateList = activity.BossStateList;
		local k = const.bossIdToIndex[BossStateList[index][1]];
		wrapper:BindButtonClick(function()
			UIBoss.FormatItemClick(go, index)
			end);
		local name = tb.ActivitiesInfoTable["sceneBoss"..const.SceneBoss_mapId[index]].bossName;
		local level = tb.ActivitiesInfoTable["sceneBoss"..const.SceneBoss_mapId[index]].level;
		wrapper:GO("Item.name").text = name.."（LV"..level.."）";
		if BossStateList[k] and BossStateList[k][2] > 0 then
		-- 当前boss还有血量，即存在
			Util.SetGray(wrapper:GO("Item.Bg.icon").gameObject, false);
			if DataCache.myInfo.level >= tb.SceneTable[const.SceneBoss_mapId[index]].level then
				wrapper:GO("Item.Ison").gameObject:SetActive(true);
				wrapper:GO("Item.Ison").text = tb.SceneTable[const.SceneBoss_mapId[index]].name.."1线";
				wrapper:GO("Item.text").gameObject:SetActive(false);
			else
				wrapper:GO("Item.Ison").gameObject:SetActive(false);
				wrapper:GO("Item.text").gameObject:SetActive(true);
				wrapper:GO("Item.text").text = "等级不足，尚未开启";
			end
		else
		-- 当前boss已经挂了，不存在
			Util.SetGray(wrapper:GO("Item.Bg.icon").gameObject, true);
			wrapper:GO("Item.Ison").gameObject:SetActive(false);
			wrapper:GO("Item.text").gameObject:SetActive(true);
			if DataCache.myInfo.level < tb.SceneTable[const.SceneBoss_mapId[index]].level then
				wrapper:GO("Item.text").text = "等级不足，尚未开启";
			else
				UIBoss.BossStartTime(wrapper);
			end
		end
		-- 前k个boss已经刷新过，可以来显示
		UIBoss.UnLock(index, wrapper);
		-- EventManager.onEvent(Event.ON_EVENT_RED_POINT);
	end

	function UIBoss.closeSelf()
		destroy(this.gameObject);
	end

	--解锁前K个
	function UIBoss.UnLock(k, go)
		lock[k] = 1;
		go:GO("Item.Bg.lock").gameObject:SetActive(false);
	end

	function UIBoss.FirstShowUI()
		local level = DataCache.myInfo.level;
		-- 选择不大于玩家等级的最大等级的boss
		local select = nil;
		local max = 1;
 		for i = 2, #activity.BossStateList do
			if tb.ActivitiesInfoTable["sceneBoss"..const.SceneBoss_mapId[i]].level <= level then
				if lock[i] == 1 then
					--已解锁
					max = i
				end
			end
		end
		select = max
		for i = 1, #activity.BossStateList do
			if i == select then
				leftPanel:GO((i-1)..".Item.bg").gameObject:SetActive(true);
			else
				leftPanel:GO((i-1)..".Item.bg").gameObject:SetActive(false);
			end
		end
		lastselect = select;
		UIBoss.ReFreshShow(select);
	end

	function UIBoss.ReFreshShow(i)
		local SelectMapId = const.SceneBoss_mapId[i];
		top:GO('title.text').text = tb.ActivitiesInfoTable["sceneBoss"..SelectMapId].bossName;
		top:GO('level.value').text = tb.ActivitiesInfoTable["sceneBoss"..SelectMapId].level;
		top:GO('map.value').text = tb.SceneTable[SelectMapId].name;

		-- 初始化显示掉落装备
		local dropEquip = tb.ActivitiesInfoTable["sceneBoss"..SelectMapId].award;
		-- -- 初始化显示掉落物品
		-- local dropItem = tb.ActivitiesInfoTable["sceneBoss"..SelectMapId].awardItem;

		-- dropList = UIBoss.GetDropList(dropEquip, dropItem);
		UIBoss.ShowDropItem(dropEquip);
		bottom:GO('btn'):BindButtonClick(function()
			local nowH = os.date("%H", math.round(TimerManager.GetServerNowMillSecond()/1000));
			local nowM = os.date("%M", math.round(TimerManager.GetServerNowMillSecond()/1000));
			local now = nowH * 60 + nowM;
			if (now <= 750 and now >= 745) or (now <= 1230 and now >= 1225) then
				UIBoss.ClickOk(i);
			else
				if activity.BossIndexStateList[i][2] > 0 then
					UIBoss.ClickOk(i);
				else
					local bossName = tb.ActivitiesInfoTable["sceneBoss"..const.SceneBoss_mapId[i]].bossName;
					local str = string.format("%s尚未出现",bossName);
					ui.showMsg(str);
				end
			end
		end);
	end

	function UIBoss.ShowDropItem(dropList)
		UIBoss.ResetDropList();
		if bagItemCount < #dropList then
			for i = bagItemCount + 1,#dropList do
				local item = newObject(BagItem);
		        item.transform:SetParent(dropContent.transform);
		        item.transform.localScale = Vector3.one;
		        item.transform.localPosition = Vector3.zero;
		        item.name = "Item"..i;
				dropItemList[i] = dropContent:GO('Item'..i):GetComponent("UIWrapper");
			end
			bagItemCount = #dropList;
		end
		for i = 1, #dropList do
			dropItemList[i]:BindButtonClick(function()
				UIBoss.dropClick(i);
			end);
			dropContent:GO("Item"..i..".bg").sprite = const.QUALITY_BG[dropList[i].Quality + 1];
			dropContent:GO("Item"..i..".bg"):GetComponent("Image"):SetNativeSize();
			dropContent:GO("Item"..i..".icon").sprite = dropList[i].Icon;
			dropContent:GO("Item"..i..".icon"):GetComponent("Image"):SetNativeSize();
			dropItemList[i].gameObject:SetActive(true);
			dropListInfo[i] = dropList[i];
		end
	end

	function UIBoss.ResetDropList()
		local count = dropContent.transform.childCount;
		if count > 1 then
			for i = 1, count do
				dropItemList[i].gameObject:SetActive(false);
			end
		end
	end

	function UIBoss.dropClick(i)
		local data = dropListInfo[i];
		PanelManager:CreateConstPanel('ActItemFloat',UIExtendType.BLACKCANCELMASK, {boss = i, data = data});
	end

	function UIBoss.GetDropList(dropEquip, dropItem)
		local career = DataCache.myInfo.career;
		local equipList = dropEquip[career];
		local list = {};
		for i=1, #equipList do
			local equipId = equipList[i][1];
			local equipTable = tb.EquipTable[equipId];
			list[#list + 1] = {icon = equipTable.icon, quality = equipList[i][2], id = equipId, isEquip = true };
		end
		local itemList = dropItem;
		for i=1, #itemList do
			local itemId = itemList[i];
			local itemTable = tb.ItemTable[itemId];
			list[#list + 1] = {icon = itemTable.icon, quality = itemTable.quality, id = itemId, isItem = true};
		end
		return list;
	end

	function UIBoss.FormatItemClick(go, i)
		if i ~= lastselect then
			leftPanel:GO((lastselect-1)..".Item.bg").gameObject:SetActive(false);
			leftPanel:GO((i-1)..".Item.bg").gameObject:SetActive(true);
		end
		UIBoss.ReFreshShow(i);
		lastselect = i;
	end

	function UIBoss.ClickOk(i)
		local end_sceneSid = const.SceneBoss_mapId[i];
		local posX = tb.ActivitiesInfoTable["sceneBoss"..const.SceneBoss_mapId[i]].pos[1];
		local posZ = tb.ActivitiesInfoTable["sceneBoss"..const.SceneBoss_mapId[i]].pos[3];
		TransmitScroll.ClickLinkPathing(end_sceneSid, 1, Vector2.New(posX,posZ));
		local wrapper = UIManager.GetInstance():FindUI("UIActivity");
        	if wrapper then
           	 	destroy(wrapper.gameObject);
            	UIManager.GetInstance():CallLuaMethod('UIMenu.closeSelf');
        	end
        UIBoss.closeSelf();
	end	

	-- function UIBoss.ShowState()
	-- 	for i = 1, 5 do
	-- 		-- if lock[i] == 0 then
	-- 		if DataCache.myInfo.level < tb.ActivitiesInfoTable["sceneBoss"..const.SceneBoss_mapId[i]].level then
	-- 			leftPanel:GO("Item"..i..".text").gameObject:SetActive(true);
	-- 			 leftPanel:GO("Item"..i..".text").text = "等级不足，尚未开启";
	-- 		end
	-- 	end
	-- end

	-- 应该传入参数，参数为哪些boss已经解锁了
	function UIBoss.BossStartTime(go)
		-- 获取服务端的时间
		local server_time_h = os.date("%H", math.round(TimerManager.GetServerNowMillSecond()/1000));
		local server_time_m = os.date("%M", math.round(TimerManager.GetServerNowMillSecond()/1000));
		-- 计算当前时间与12:30开启时间的差值
		local minutes = server_time_h * 60 + server_time_m;
		if minutes < 750 or minutes >= 1230 then
			go:GO("Item.text").gameObject:SetActive(true);
			go:GO("Item.text").text = "刷新时间   12:30"
		else
			go:GO("Item.text").gameObject:SetActive(true);
			go:GO("Item.text").text = "刷新时间   20:30"
		end
	end

	return UIBoss
end
