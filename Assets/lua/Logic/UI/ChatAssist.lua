function ChatAssistView ()
	local ChatAssist = {};
	local this = nil;
	local ImageSize = 1.5;	--调节面板显示表情的倍率
	--导出的wrapper
	local SendLocation = nil;
	local EmotePanel = nil;
	local EmoteGrid = nil;
	local ItemPanel = nil;
	local ItemGrid = nil;
	--local Mask = nil;
	--缓存的数据
	local player = nil;
	local mapName = nil;
    local fenxianID = nil;
	local curPos = nil;
	local mapId = 0;

	local wearEquipList = nil;--穿戴装备列表（有空格）
	local wearEquipTable = nil;--收集的穿戴装备（没有空格）
	local wearEquipIndex = nil;--穿戴装备的实际index
	local equipList = nil;--包里装备列表
	local itemList = nil;--包里物品列表
	local itemNameMap = {};--下方列表物品内容缓存
	local itemTypeMap = {};--列表物品种类缓存
	local itemContainer = nil;
	local longPressed = false;
	local clickItemGo = nil;

	local bHaveLoadEmote = false;
	local emoteNameMap = {};--表情内容缓存
	local emoteContainer = nil;
	local emoteTable = {};

	local itemCount = 0; 
	local curPage = 0;	--0 表情，1 物品，2 坐标 

	function ChatAssist.Start ()
		this = ChatAssist.this;
		
		local commonDlgGO = this:GO('CommonDlg');
		ChatAssist.controller = createCDC(commonDlgGO)
		ChatAssist.controller.SetButtonNumber(2);
		ChatAssist.controller.bindButtonClick(1,ChatAssist.OpenEmotePage);		
		ChatAssist.controller.bindButtonClick(2,ChatAssist.OpenItemPage);
		--ChatAssist.controller.bindButtonClick(3,ChatAssist.OpenLocationPage);		

		SendLocation = this:GO('_SendLocation');
		EmotePanel = this:GO('_EmotePanel');
		EmoteGrid = this:GO('_EmotePanel.Container.Grid.Content');
		ItemPanel = this:GO('_ItemPanel');
		ItemGrid = this:GO('_ItemPanel.Container.Grid.Content');
		itemContainer = this:GO('_ItemPanel.Container');
		--Mask = this:GO('Mask');
		emoteContainer = this:GO('_EmotePanel.Container');

		SendLocation:BindButtonClick(ChatAssist.SendLocation);
		--Mask:BindButtonClick(ChatAssist.Hide);

		local count;
		for i = 1 , #tb.EmoteTable do
			local emote = tb.EmoteTable[i];
			if emote.type == 0 then
				emoteTable[#emoteTable+1] = emote;
			end

			count = #emoteTable + 1;
			if count % 30 == 0 then
				emoteTable[count] = "back";	--退格键
			end
		end

		if #emoteTable % 30 ~= 0 then
			emoteTable[#emoteTable + 1] = "back";	--退格键
		end

		ChatAssist.OpenEmotePage();
		this:BindLostFocus(ChatAssist.LoseFocus);
	end

	function ChatAssist.Update()
		--如果处在处在坐标界面，每帧更新位置
		if curPage == 2 then
			curPos = Vector2.New(math.floor(player.transform.position.x * 2 + 0.5), math.floor(player.transform.position.z * 2 + 0.5));
			local locationText = mapName.."["..curPos.x..","..curPos.y.."]";
			LocationText.text = locationText;
		end
	end

	function ChatAssist.LoseFocus()
		UIManager.GetInstance():CallLuaMethod('UIChat.closeEmoteUI');
	end

	--注意：表情和装备列表的区别是表情只需要加载一次，中途不会发生变化，切回来也不需要进行刷新
	function ChatAssist.OpenEmotePage()
		curPage = 0;
		ChatAssist.DisableAllPanel();
		ChatAssist.ShowEmotePage(true);
		local rtTrans = EmoteGrid:GetComponent("RectTransform");
		rtTrans.anchoredPosition = Vector2.zero;
		local warpContent = emoteContainer:GetComponent("UIWarpContent");
		
		--第一次加载
		if bHaveLoadEmote == false then
			emoteNameMap = {};
			--这里开始读入表情表，根据表情表的数据填入表情GameObject
			local count = #emoteTable			
			warpContent:BindInitializeItem(function (go, index)
				ChatAssist.FormatEmote(go, emoteTable[index])
			end)
			warpContent:Init(count);
			bHaveLoadEmote = true;
		else
			warpContent:ResetPosition();
		end
	end

	function ChatAssist.FormatEmote(go, emote)
		emoteNameMap[go.name] = emote;
		local wrapper = go:GetComponent("UIWrapper");
		wrapper:GO('Image').gameObject:SetActive(emote ~= "back");
		wrapper:GO('Back').gameObject:SetActive(emote == "back");

		if emote == "back" then
			wrapper:BindButtonClick(ChatAssist.emoteBack);
		else
			wrapper:BindButtonClick(ChatAssist.emoteClick);
			local image = wrapper:GO("Image");
			local clip = image.gameObject:GetComponent("LMovieClip");
			clip.path = emote.path;
			clip.fps = emote.fps;
			clip.frameLength = emote.frameCount;
			clip:loadTexture();
			clip:play();
			local rect = image:GetComponent("RectTransform");
			rect.sizeDelta = Vector2.New(emote.width * ImageSize,emote.height * ImageSize);
		end
	end	

	function ChatAssist.emoteClick(go)
		local emote = emoteNameMap[go.name];
		UIManager.GetInstance():CallLuaMethod('UIChat.InputEmote', "["..emote.name.."]");
	end

	function ChatAssist.emoteBack(go)
		UIManager.GetInstance():CallLuaMethod('UIChat.InputBack');
	end

	function ChatAssist.OpenItemPage()
		curPage = 1;
		ChatAssist.DisableAllPanel();
		ChatAssist.ShowItemPage(true);
		wearEquipList = Bag.wearList;--穿戴装备
		equipList = Bag.GetShowEquip();--包里装备
		itemList = Bag.GetShowItem();--包里物品
		itemCount = 0; 
		wearEquipTable = {};
		wearEquipIndex = {};
		--统计一下展示物品的总数
		for i = 1, const.WEAREQUIP_COUNT do
			local equip = wearEquipList[i];
			if equip ~= nil then
				itemCount = itemCount + 1;
				wearEquipTable[itemCount] = equip;
				wearEquipIndex[itemCount] = i;
			end
		end

		itemCount = itemCount + #equipList;
		itemCount = itemCount + #itemList;

		--重置位置
		local grid = ItemGrid;
		local rtTrans = grid:GetComponent("RectTransform");
		rtTrans.anchoredPosition = Vector2.zero;
		itemNameMap = {};

		--开始载资源进入下一步
		ChatAssist.LoadItem();
	end

	function ChatAssist.LoadItem()
		local wrapper = this:GetComponent("UIWrapper");
		local prefab = wrapper:LoadAsset("BagItem");
		local warpContent = itemContainer:GetComponent("UIWarpContent");
		warpContent.goItemPrefab = prefab;
		warpContent:BindInitializeItem(ChatAssist.FormatItem);
		warpContent:Init(itemCount);
	end

	function ChatAssist.FormatItem(go, i)
		local item = nil;

		local wrapper = go:GetComponent("UIWrapper");
		local slotCtrl = wrapper:GetUserData("ctrl");
		if slotCtrl == nil then
			slotCtrl = CreateSlot(go);
			wrapper:SetUserData("ctrl",slotCtrl);
		end
		slotCtrl.reset();
		ChatAssist.genItemArrow(wrapper, slotCtrl);
		wrapper:BindButtonClick(ChatAssist.itemClick)
		wrapper:BindButtonDown(ChatAssist.itemClickDown)
		wrapper:BindButtonLongPressed(ChatAssist.itemLongPressed)

		--1、身上穿戴装备
		if i <= #wearEquipTable then
			item = wearEquipTable[i];
            slotCtrl.setWareEquip(item);
            slotCtrl.setWear(commonEnum.EquipFlagSprite[commonEnum.EquipFlag.Wear]) 
			itemTypeMap[go.name] = 1;
			itemNameMap[go.name] = wearEquipIndex[i];
		--2、背包里的装备
		elseif i<= #wearEquipTable + #equipList then
			local index = i - #wearEquipTable;
			item = equipList[index];
			itemTypeMap[go.name] = 2;
			itemNameMap[go.name] = index;
			slotCtrl.setBagEquip(item);

		--3、背包里的物品
		else
			local index = i - #wearEquipTable - #equipList;
			item = itemList[index];
			itemTypeMap[go.name] = 3;
			itemNameMap[go.name] = index;
			slotCtrl.setItem(item);

		end

	end

	--动态生成箭头
	function ChatAssist.genItemArrow(wrapper, slot)
		local arrow = wrapper:GO('arrow');
		if arrow == nil then
			arrow = newObject(slot.icon);
			arrow.transform:SetParent(wrapper.transform);
			arrow.transform.localPosition = Vector3.New(5, -17, 0);
			arrow.transform.localScale = Vector3.one;
			arrow.sprite = "jiantou";
			arrow.imageType = 3;
			arrow.fillMethod = 1;
			arrow.gameObject.name = "arrow";

			local image = arrow:GetComponent("Image");
			image:SetNativeSize();
		end
	end

	function ChatAssist.itemClick(go)
		if longPressed or itemNameMap[go.name] == nil  then 
			local wrapper = go:GetComponent("UIWrapper");
			wrapper:GO('arrow'):Hide();
			return;
		end	

		local itemType =  itemTypeMap[go.name];
		local index = itemNameMap[go.name];


		--根据类型到不同的位置去取
		local item = nil;
		if itemType == 1 then
			item = wearEquipList[index];
		elseif itemType == 2 then
			item = equipList[index];
		else
			item = itemList[index];
		end

		local itemCfg = tb.EquipTable[item.sid];
		if itemCfg == nil then
			itemCfg = tb.ItemTable[item.sid];
		end

		UIManager.GetInstance():CallLuaMethod('UIChat.InputItem',item, itemCfg, itemType );
	end

	local showFloat = false;

	function ChatAssist.itemClickDown(go)
		longPressed = false;
		showFloat = false;
		clickItemGo = go;
	end

	function ChatAssist.itemLongPressed(time)
		longPressed = true;

		if showFloat then
			return;
		end

		local wrapper = clickItemGo:GetComponent("UIWrapper");
		local arrow = wrapper:GO('arrow');
		arrow:Show();
		arrow.fillAmount = math.min((time - 0.5) / 1.5, 1);

		if time > 2  then
			showFloat = true;
			arrow:Hide();
			ChatAssist.showItemFloat(clickItemGo);
		end
	end

	function ChatAssist.showItemFloat(go)
		if itemNameMap[go.name] == nil  then 
			return;
		end	
		local itemType = itemTypeMap[go.name];
		local index = itemNameMap[go.name];


		--根据类型到不同的位置去取
		local item = nil;
		if itemType == 1 then
			item = wearEquipList[index];
		elseif itemType == 2 then
			item = equipList[index];
		else
			item = itemList[index];
		end

		local itemCfg = tb.EquipTable[item.sid];
		if itemCfg == nil then
			itemCfg = tb.ItemTable[item.sid];
		end

		local click_pos = go:GetComponent("UIWrapper").pointer_position;
		--需要打开装备悬浮或物品悬浮，这里还需要区分是身上穿戴的还是背包中的物品
		if itemType == 1 then 
			--身上的装备会多带一个强化属性
			local enhanceInfo = Bag.enhanceMap[itemCfg.buwei];
			local gemInfo = client.gem.getEquipGem(itemCfg.buwei);
			PanelManager:CreateConstPanel('EquipFloat',UIExtendType.BLACKCANCELMASK, {pos = click_pos, showType = "show",base = item, enhance = enhanceInfo, gemList = gemInfo});
		elseif itemType == 2 then 
			if itemCfg.career == "suipian" then
				PanelManager:CreateConstPanel('FragmentFloat',UIExtendType.BLACKCANCELMASK,{base = item, showButton = false});	
			else
				PanelManager:CreateConstPanel('EquipFloat',UIExtendType.BLACKCANCELMASK, {pos = click_pos, showType = "show",base = item,enhance = nil});
			end
		elseif itemType == 3 then 
			PanelManager:CreateConstPanel('ItemFloat',UIExtendType.BLACKCANCELMASK, {pos = click_pos, bDisplay = true, sid = item.sid , base = item});
		end	
	end

	function ChatAssist.SendLocation()		
		UIManager.GetInstance():CallLuaMethod('UIChat.sendLocation');
	end

	function ChatAssist.ShowEmotePage(bShow)
		EmotePanel.gameObject:SetActive(bShow);
	end

	function ChatAssist.ShowItemPage(bShow)
		ItemPanel.gameObject:SetActive(bShow);
	end

	function ChatAssist.DisableAllPanel()
		ChatAssist.ShowEmotePage(false);
		ChatAssist.ShowItemPage(false);
	end

	function ChatAssist.Show()
		this.gameObject:SetActive(true);
		ChatAssist.DisableAllPanel();
		if curPage == 0 then
			ChatAssist.OpenEmotePage();
		elseif curPage == 1 then
			ChatAssist.OpenItemPage();
		end
	end

	function ChatAssist.Hide()
		this.gameObject:SetActive(false);
	end

	return ChatAssist;
end

function CreateChatAssist()
	
end

function ShowChatAssist()
	if client.chatAssist == nil then
		client.chatAssist = PanelManager.UIRoot:Find("ChatAssist").gameObject;
	end

	if client.chatAssist ~= nil then
		client.chatAssist:SetActive(true);
	end
	--UIManager.GetInstance():CallLuaMethod('ChatAssist.Show');
end

function HideChatAssist()
	if client.chatAssist ~= nil then
		client.chatAssist:SetActive(false);
	end
	--UIManager.GetInstance():CallLuaMethod('ChatAssist.Hide');
end