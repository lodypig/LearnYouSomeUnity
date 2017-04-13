function UIFubenView(param)
	local UIFuben = {};
	local this = nil;

	local itemPrefab = nil;
	local itemExtend = nil;
	local itemSize = 0;	--基本内容尺寸
	local extendSize = 0;	--扩展内容尺寸
	local itemList = {};

	local content = nil;
	local rtContent = nil;
	local scrollRect = nil;

	local curItemIndex = 0;	--当前选中的副本索引
	local showList = {};	--显示的副本列表

	local dropList = {};	--掉落列表
	local dropContent = nil;
	local dropItemList = {};	

	local challengeNum = 0;

	function UIFuben.Start( )
		this = UIFuben.this;

		this:GO('Panel.Close'):BindButtonClick(UIFuben.closeSelf);

		itemPrefab = this:GO('Panel.List.Viewport.Content.Item');
		itemSize = itemPrefab:GO('Base'):GetComponent('LayoutElement').minWidth;
		itemPrefab.gameObject:SetActive(false);
		
		itemExtend = this:GO('Panel.List.Viewport.Content.Extend');
		extendSize = itemExtend:GetComponent('LayoutElement').minWidth;
		itemExtend.gameObject:SetActive(false)
		dropContent = itemExtend:GO('DropList');
		
		content = this:GO('Panel.List.Viewport.Content');
		rtContent = content:GetComponent('RectTransform');
		scrollRect = this:GO('Panel.List');

		UIFuben.ShowFubenList();
		challengeNum = tb.DailyActTable[const.ActivityId.shiLianMiJing].times;
	end

	function UIFuben.ShowFubenList()
		--隐藏详细框
		itemExtend:GetComponent('LayoutElement').minWidth = 0;
		itemExtend.transform.localScale = Vector3.New(0, 1, 1);
		curItemIndex = 0;

		showList = client.fuben.getFubenList();

		for i=1, #showList do
            if i > #itemList then
                local item = newObject(itemPrefab);
                item.transform:SetParent(content.transform);
                item.transform.localScale = Vector3.one;
                item.transform.localPosition = Vector3.zero;
                itemList[i] = item;
            end
            itemList[i].gameObject.name = i;
            itemList[i].gameObject:SetActive(true);

            UIFuben.FormatItem(showList[i], itemList[i])
        end

        for i=#showList + 1, #itemList do
            itemList[i].gameObject:SetActive(false);
        end

        --显示到列表最后
        local posX = -(#showList - 3) * itemSize;
        rtContent.anchoredPosition = Vector2.New(posX, 0.05);
	end

	function UIFuben.FormatItem(info, item)
		if info.lock then
			item:GO('Base.Name').text = string.format("<color=#ABABAB>LV%s%s</color>", info.minlevel, info.name); 
		else
			item:GO('Base.Name').text = string.format("<color=#E4E4E4>LV%s</color>%s", info.minlevel, info.name); 
		end
		item:GO('Base.Img'):BindButtonClick(function()
			UIFuben.ClickItem(item.gameObject);
		end );

		--是否匹配中
		local isMatch = client.fuben.isMatching(info.sid);
		item:GO('Base.Match').gameObject:SetActive(isMatch);

		--是否解锁
		item:GO('Base.Lock').gameObject:SetActive(info.lock);
		item:GO('Base.Lock.Text').text = string.format("%s级开放", info.minlevel);
		Util.SetGray(item:GO('Base').gameObject, info.lock);
	end

	function UIFuben.FormatDetail(fubenInfo)
		itemExtend:GO('AwardTitle.Text').text = "可能获得";

		--显示掉落物品
		dropList = UIFuben.GetDropList(fubenInfo);
		UIFuben.RefreshDrop(dropList);
	end

	function UIFuben.RefreshUI()
		for i=1, #showList do
            UIFuben.RefreshItem(showList[i], itemList[i])
        end
        UIFuben.RefreshBtnTeam()
	end

	function UIFuben.RefreshItem(info, item)
		local isMatch = client.fuben.isMatching(info.sid);
		item:GO('Base.Match').gameObject:SetActive(isMatch);
	end

	function UIFuben.RefreshBtnTeam()
		if curItemIndex == 0 then
			return
		end

		local fubenInfo = showList[curItemIndex];
		if fubenInfo == nil then
			return;
		end

		local btnTeam = itemExtend:GO('BtnTeam');
		local isMatch = client.fuben.isMatching(fubenInfo.sid);
		btnTeam:GO('Text').text = isMatch and "取消匹配" or "自动匹配";
		if isMatch then
			btnTeam:BindButtonClick(UIFuben.OnCancelChallenge);
		else
			btnTeam:BindButtonClick(UIFuben.OnChallenge);
		end
	end

	function UIFuben.OnChallenge()
		if curItemIndex == 0 then
			return
		end

		local fubenInfo = showList[curItemIndex];
		client.fuben.challenge_fuben(fubenInfo);
	end

	function UIFuben.OnCancelChallenge()
		if curItemIndex == 0 then
			return
		end

		local fubenInfo = showList[curItemIndex];
		if fubenInfo == nil then
			return;
		end

		client.fuben.cancel_challenge(fubenInfo.sid);
	end

	function UIFuben.RefreshDrop()
		--显示掉落物品
		local prefab = this:LoadAsset("BagItem");
		for i=1, #dropList do
            if i > #dropItemList then
                local item = newObject(prefab);
                item.transform:SetParent(dropContent.transform);
                item.transform.localScale = Vector3.one;
                item.transform.localPosition = Vector3.zero;
                dropItemList[i] = item:GetComponent("UIWrapper");
				dropItemList[i]:SetUserData("ctrl",CreateSlot(item));
			end
			dropItemList[i]:BindButtonClick(function( )
				UIFuben.dropItemClick(i);
			end);

			dropItemList[i].gameObject:SetActive(true);
            local data = dropList[i];
            local slotCtrl = dropItemList[i]:GetUserData("ctrl");
            slotCtrl.reset();
            slotCtrl.setData(data);
        end

        for i=#dropList + 1, #dropItemList do
            dropItemList[i].gameObject:SetActive(false);
        end
	end

	function UIFuben.dropItemClick(i)
		local data = dropList[i];
		if data.isEquip then 
			local param = {};
			if data.equip ~= nil then
				param = {showType = "show",isScreenCenter = true ,base = data.equip, enhance = nil};
			else
				param = {showType = "random",isScreenCenter = true ,sid = data.id, quality = data.quality};
			end
			PanelManager:CreateConstPanel('EquipFloat',UIExtendType.BLACKCANCELMASK, param);
		elseif data.isItem then
			local param = {bDisplay = true, sid = data.id};
			PanelManager:CreateConstPanel('ItemFloat',UIExtendType.BLACKCANCELMASK,param);
		end	
	end

	--获取副本可能掉落的物品列表
	function UIFuben.GetDropList(fubenInfo)
		local career = DataCache.myInfo.career;
		local equipList = fubenInfo.dropequip[career];
		local list = {};
		for i=1, #equipList do
			local equipId = equipList[i][1];
			local equipTable = tb.EquipTable[equipId];
			list[#list + 1] = {icon = equipTable.icon, quality = equipList[i][2], id = equipId, isEquip = true };
		end

		local itemList = fubenInfo.dropitem;
		for i=1, #itemList do
			local itemId = itemList[i]
			local itemTable = tb.ItemTable[itemId];
			list[#list + 1] = {icon = itemTable.icon, quality = itemTable.quality, id = itemId, isItem = true};
		end

		return list;
	end

	function UIFuben.ClickItem(go)
		local index = tonumber(go.name);
		local fubenInfo = showList[index];
		if fubenInfo == nil then
			return;
		end

		if fubenInfo.lock then
			ui.showMsg(string.format("需要达到%s级才可进入", fubenInfo.minlevel));
			return;
		end
		local wrapper = go:GetComponent("UIWrapper");
		if curItemIndex ~= index then
			curItemIndex = index;
			UIFuben.FormatDetail(fubenInfo);
			--详细界面展开
			itemExtend.transform:SetParent(wrapper.transform);
			itemExtend.gameObject:SetActive(true);
			local size = Vector2.New(extendSize, itemExtend:GetComponent('LayoutElement').minHeight);
			itemExtend:GetComponent('LayoutElement'):DOMinSize(size, 0.5, false);
			itemExtend.transform.localScale = Vector3.New(0, 1, 1);
			itemExtend.transform:DOScale(Vector3.one, 0.5);
			--移动点击的副本到最左边
			local posX = -(go.name - 1) * itemSize;
			rtContent:DOAnchorPosX(posX, 0.5, false);

			--更新按钮状态
			UIFuben.RefreshBtnTeam();
		else
			curItemIndex = 0;
			--详细界面收起
			local size = Vector2.New(0, itemExtend:GetComponent('LayoutElement').minHeight);
			itemExtend:GetComponent('LayoutElement'):DOMinSize(size, 0.5, false);
			itemExtend.transform:DOScale(Vector3.New(0, 1, 1), 0.5);
			--扩展页收起时判断是否超出显示区域
			local posX = -(#showList - 3) * itemSize;
			posX = math.max(posX, rtContent.anchoredPosition.x);
			rtContent:DOAnchorPosX(posX, 0.5, false);
		end
	end

	function UIFuben.OnDestroy(  )
        
	end

	function UIFuben.closeSelf()
		destroy(this.gameObject);
	end

	return UIFuben;
end
