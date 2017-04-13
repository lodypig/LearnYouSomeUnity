const.auction_type_name = {
	"装备",
	"橙装碎片",
	"坐骑",
	"魔灵",
	"其他",
}

const.auction_type = {
	"equipment",
	"equipsuipian",
	"zuoqi",
	"moling",
	"other",
}

const.auction_buy_level = 
{
	equipment = {20,40,50,60,70},
	equipsuipian = {40,50,60,70},
}

const.auction_subtype_icon = {
			[1] = {magician = "tb_fazhang_diaoluo", bowman = "tb_gongjian_diaoluo", soldier = "tb_wuqi_diaoluo"},
			[2] = "tb_erhuan_diaoluo",
			[3] = "tb_yifu_diaoluo",
			[4] = "tb_kuzi_diaoluo",
			[5] = "tb_xianglian_diaoluo",
			[6] = "tb_jiezhi_diaoluo",
			[7] = "tb_toukui_diaoluo",
			[8] = "tb_hujian_diaoluo",
			[9] = "tb_shoutao_diaoluo",
			[10] = "tb_xiezi_diaoluo",
			}


function UIAuctionView(param)
	local UIAuction = {};
	local this = nil;

	--二级类型
	local subTypeList = {};
	--购买物品列表
	local buyItemList = {};
	local curBuyItem = nil;
	local curBuyLevel = 0;
	local curBuyType = "";
	local curBuySubType = 0;
	local curBuyPage = 1;
	local showSubTypePanel = false;

	local lastRefreshTime = 0;--记录刷新商品的时间,30秒重新向服务端请求列表
	local refreshTime = 30;

	--自己的摊位列表
	local sell_time = 48 * 60 * 60;
	local stall_count = 10;
	local stallList = {}

	--出售界面
	local goodsList = nil;	--要上架的物品列表
	local curSelectedGoods = nil;	--当前选中的物品
	local curGoodsIndex = 0;	--当前选中物品的索引
	local curSelectedGoodsId = 0;
	local isReShelve = false;--是否重新上架
	local btnShelvePos = nil;
	local shelveCostPos = nil;
	local costGold = 0;--上架花费的金币

	function UIAuction.Start( )
		this = UIAuction.this;

		local commonDlgGO = this:GO('CommonDlg');
		UIAuction.controller = createCDC(commonDlgGO)
		UIAuction.controller.SetButtonNumber(2);
		UIAuction.controller.SetButtonText(1,"购买");		
		UIAuction.controller.bindButtonClick(1,UIAuction.showBuyPanel);
		UIAuction.controller.SetButtonText(2,"出售");
		UIAuction.controller.bindButtonClick(2,UIAuction.showSalePanel);	
		UIAuction.controller.bindButtonClick(0,UIAuction.closeSelf);		
		
		UIAuction.initBuyPanel();--购买界面
		UIAuction.initSalePanel();--出售界面

		EventManager.bind(this.gameObject,Event.ON_TIME_SECOND_CHANGE, UIAuction.UpdateOneSecond);
        EventManager.bind(this.gameObject,Event.ON_GOUMAILI_CHANGE,UIAuction.updateGoumali);
        EventManager.bind(this.gameObject,Event.ON_DIAMOND_CHANGE,UIAuction.UpdateDiamond);


        --从物品悬浮跳转，直接显示上架界面
        if param.isShelve then
			UIAuction.controller.activeButton(2);
		else
			client.auction.getSelfShelveItem();
			UIAuction.controller.activeButton(1);		
        end
	end

	--初始购买界面
	function UIAuction.initBuyPanel(  )
		this:GO('BuyPanel.SubType.Viewport.Content.Item').gameObject:SetActive(false);
		this:GO('BuyPanel.List.Viewport.Content.Item').gameObject:SetActive(false);
        this:GO('BuyPanel.List'):BindETEndDrag(UIAuction.clickBuyList)
		this:GO('BuyPanel.Buy.BtnBuy'):BindButtonClick(UIAuction.buyGoods);
		this:GO('BuyPanel.Buy.top.closeBtn'):BindButtonClick(UIAuction.hideBuyItemPanel);
		this:GO('BuyPanel.LevelSwitch.Switch'):BindButtonClick(UIAuction.closeLevelSwitch);
		this:GO('BuyPanel.LevelSwitch.Level'):BindButtonClick(UIAuction.showLevelSwitch);
		this:GO('BuyPanel.Page.BtnPre'):BindButtonClick(UIAuction.onPrePage);
		this:GO('BuyPanel.Page.BtnNext'):BindButtonClick(UIAuction.onNextPage);

		this:GO('BuyPanel.Currency.Diamond.BtnAdd'):BindButtonClick(ui.showChargePage);
		this:GO('BuyPanel.Currency.Goumaili.BtnAdd'):BindButtonClick(ui.showChargePage);
		this:GO('BuyPanel.Currency.Tips').gameObject:SetActive(false);
		this:GO('BuyPanel.Currency.BtnTip'):BindButtonDown(function ()
			this:GO('BuyPanel.Currency.Tips').gameObject:SetActive(true);
		end)
		this:GO('BuyPanel.Currency.BtnTip'):BindButtonUp(function ()
			this:GO('BuyPanel.Currency.Tips').gameObject:SetActive(false);
		end)

		local check = this:GO('BuyPanel.SubType.Check');
		check.ToggleValue = client.auction.showSubTypeFlag;
		check:BindToggleValueChanged(function (toggle)
			client.auction.showSubTypeFlag = toggle;
			UIAuction.ShowBuySubType();
		end);

		local cdc = createCDC(this:GO('BuyPanel'));
		cdc.SetButtonNumber(#const.auction_type_name);
		for i=1, #const.auction_type_name do
			cdc.SetButtonText(i, const.auction_type_name[i]);
			cdc.bindButtonClick(i, function ()
				UIAuction.selectBuyType(const.auction_type[i]);
			end)
		end
		cdc.activeButton(1);
		UIAuction.buyCdc = cdc;
	end

	--初始出售界面
	function UIAuction.initSalePanel( )
		UIAuction.initStall( );		
		this:GO('SalePanel.Sale.closeBtn'):BindButtonClick(UIAuction.hideShelvePanel);
		this:GO('SalePanel.Sale.Button.BtnShelve'):BindButtonClick(UIAuction.shelveGoods);
		this:GO('SalePanel.Sale.Button.BtnOffShelve'):BindButtonClick(UIAuction.offShelveGoods);
		this:GO('SalePanel.BtnGetMoney'):BindButtonClick(UIAuction.withdrawCashAll);
		btnShelvePos = this:GO('SalePanel.Sale.Button.BtnShelve').transform.localPosition;
		shelveCostPos = this:GO('SalePanel.Sale.Button.Cost').transform.localPosition;
	end

	function UIAuction.GetItemCfg( item )
		local itemCfg = nil;
		if item.type == const.bagType.item then
			itemCfg = tb.ItemTable[item.sid];
		elseif item.type == const.bagType.equip then
			itemCfg = tb.EquipTable[item.sid];
			itemCfg.showtype = item.quality == const.quality.orangepiece and "碎片" or "装备";
		elseif item.type == const.bagType.gem then
			itemCfg = tb.GemTable[item.sid];
		end

		return itemCfg;
	end

	--显示购买界面
	function UIAuction.showBuyPanel( )
		this:GO('SalePanel').gameObject:SetActive(false);
		this:GO('BuyPanel').gameObject:SetActive(true);
		this:GO('BuyPanel.Currency').gameObject:SetActive(true);
		this:GO('BuyPanel.Currency.Goumaili.Text').text = DataCache.role_goumaili;
		this:GO("BuyPanel.Currency.Diamond.Text").text = DataCache.role_diamond;
		
		UIAuction.buyCdc.activeButton(1);
	end

	function UIAuction.updateGoumali()
		this:GO('BuyPanel.Currency.Goumaili.Text').text = DataCache.role_goumaili;
	end

	function UIAuction.UpdateDiamond()
		this:GO("BuyPanel.Currency.Diamond.Text").text = DataCache.role_diamond;
	end

	--选择购买类型
	function UIAuction.selectBuyType(type)
		this:GO('BuyPanel.Buy').gameObject:SetActive(false);
		this:GO('BuyPanel.SubType').gameObject:SetActive(false);
		this:GO('BuyPanel.LevelSwitch').gameObject:SetActive(false);
        this:GO('BuyPanel.List').gameObject:SetActive(false)
        this:GO('BuyPanel.Tips').gameObject:SetActive(false)
		this:GO('BuyPanel.Page').gameObject:SetActive(false);
		showSubTypePanel = false;
		curBuyType = type;

		if type == "equipment" or type == "equipsuipian" then
			curBuyLevel = UIAuction.getBuyDefaultLevel(type);
			client.auction.getGoodsPageList(type, curBuyLevel);
			UIAuction.setLevelSwitch();
		else
        	this:GO('BuyPanel.Tips').gameObject:SetActive(true)
		end
	end

	function UIAuction.getBuyDefaultLevel( type )
		local level = DataCache.myInfo.level;
		if type == "equipment" then
			if level < 40 then
				return 20;
			else
				return math.floor(level / 10) * 10;
			end
		elseif type == "equipsuipian" then
			return math.max(40, math.floor(level / 10) * 10);
		else
			return 0;
		end
	end

	function UIAuction.ShowBuySubType()
		local list = client.auction.pageList;
		this:GO('BuyPanel.SubType').gameObject:SetActive(true);
		showSubTypePanel = true;
		--子类型列表
		local itemPrefab = this:GO('BuyPanel.SubType.Viewport.Content.Item');
		local content = this:GO('BuyPanel.SubType.Viewport.Content');

		local typeList = {};
		for i=1, #const.BuWei do
			if client.auction.showSubTypeFlag == false or list[i] > 0 then
				typeList[#typeList + 1] = i;
			end
		end

		for i=1, #typeList do
            if i > #subTypeList then
                local item = newObject(itemPrefab);
                item.transform:SetParent(content.transform);
                item.transform.localScale = Vector3.one;
                item.transform.localPosition = Vector3.zero;
                subTypeList[i] = item;
            end

            subTypeList[i].gameObject:SetActive(true);
            local buwei = typeList[i];

            if buwei == 1 then
            	local career = DataCache.myInfo.career;
            	subTypeList[i]:GO('Slot.icon').sprite = const.auction_subtype_icon[1][career];
            else
            	subTypeList[i]:GO('Slot.icon').sprite = const.auction_subtype_icon[buwei];
            end

            subTypeList[i]:GO('Name').text = const.BuWei[buwei];
            subTypeList[i]:GO('SellOut').gameObject:SetActive(list[buwei] == 0);

            subTypeList[i]:BindButtonClick(function ()
            	UIAuction.selectBuySubType(buwei);
            end)
        end

        for i=#typeList + 1, #subTypeList do
            subTypeList[i].gameObject:SetActive(false);
        end
	end

	--选择购买子类型，
	function UIAuction.selectBuySubType(subType)
		curBuySubType = subType;
		curBuyPage = 1;

		this:GO('BuyPanel.SubType').gameObject:SetActive(false);
		showSubTypePanel = false;

		UIAuction.refreshGoods()
	end

	local levelItemList = {};
	function UIAuction.showLevelSwitch()
		this:GO('BuyPanel.LevelSwitch.Switch').gameObject:SetActive(true);
		local itemPrefab = this:GO('BuyPanel.LevelSwitch.Switch.List.Button');
		local content = this:GO('BuyPanel.LevelSwitch.Switch.List');
		itemPrefab.gameObject:SetActive(false);

		local levelList = const.auction_buy_level[curBuyType];
		for i=1, #levelList do
            if i > #levelItemList then
                local item = newObject(itemPrefab);
                item.transform:SetParent(content.transform);
                item.transform.localScale = Vector3.one;
                item.transform.localPosition = Vector3.zero;
                levelItemList[i] = item;
            end

            levelItemList[i]:GO('Text').text = levelList[i].."级";
            levelItemList[i].gameObject.name = i;
            levelItemList[i].gameObject:SetActive(true);
            levelItemList[i]:BindButtonClick(function ()
            	curBuyLevel = levelList[i];
				UIAuction.switchLevel();
            end)
        end

        for i=#levelList + 1, #levelItemList do
            levelItemList[i].gameObject:SetActive(false);
        end
	end

	function UIAuction.setLevelSwitch()
		this:GO('BuyPanel.LevelSwitch').gameObject:SetActive(true);
		this:GO('BuyPanel.LevelSwitch.Level.Text').text = curBuyLevel.."级";
		this:GO('BuyPanel.LevelSwitch.Switch').gameObject:SetActive(false);
	end

	function UIAuction.switchLevel()
		this:GO('BuyPanel.LevelSwitch.Level.Text').text = curBuyLevel.."级";
		UIAuction.closeLevelSwitch( );
		curBuyPage = 1;

		if showSubTypePanel then
			client.auction.getGoodsPageList(curBuyType, curBuyLevel);
		else
			UIAuction.refreshGoods()
		end
	end

	function UIAuction.closeLevelSwitch( )
		this:GO('BuyPanel.LevelSwitch.Switch').gameObject:SetActive(false);
	end

	function UIAuction.onNextPage()
		local pageMax = client.auction.GetGoodsPage();
		if curBuyPage >= pageMax then
			ui.showMsg("已经是最后一页了")
			return;
		end

		curBuyPage = curBuyPage + 1
		UIAuction.refreshGoods()
	end

	function UIAuction.onPrePage()
		if curBuyPage == 1 then
			ui.showMsg("已经是第一页了")
			return;
		end
		curBuyPage = curBuyPage - 1;
		UIAuction.refreshGoods()
	end

	function UIAuction.clickBuyList()
		local posY = this:GO('BuyPanel.List.Viewport.Content').transform.localPosition.y;
		if posY > 0 then
			UIAuction.onNextPage()
			this:GO('BuyPanel.List.Viewport.Content').transform.localPosition = Vector3.zero;
		else
			UIAuction.onPrePage()
			this:GO('BuyPanel.List.Viewport.Content').transform.localPosition = Vector3.zero;
		end
	end

	--刷新商品列表
	function UIAuction.refreshGoods()
		lastRefreshTime = math.round(TimerManager.GetServerNowMillSecond()/1000);
		client.auction.getgoodsItem(curBuyType,curBuySubType,curBuyLevel,curBuyPage);
	end

	function UIAuction.refreshBuyList()
		local buyList = client.auction.getGoodsList();

		this:GO('BuyPanel.Tips').gameObject:SetActive(#buyList == 0)
        this:GO('BuyPanel.List').gameObject:SetActive(#buyList > 0)
        this:GO('BuyPanel.Page').gameObject:SetActive(#buyList > 0)
        this:GO('BuyPanel.Page.Num').text = string.format("%s/%s", curBuyPage, client.auction.GetGoodsPage());

		local itemPrefab = this:GO('BuyPanel.List.Viewport.Content.Item');
		local content = this:GO('BuyPanel.List.Viewport.Content');

		for i=1, #buyList do
            if i > #buyItemList then
                local item = newObject(itemPrefab);
                item.transform:SetParent(content.transform);
                item.transform.localScale = Vector3.one;
                item.transform.localPosition = Vector3.zero;
                buyItemList[i] = item;
            end

            buyItemList[i].gameObject.name = i;
            buyItemList[i].gameObject:SetActive(true);
            buyItemList[i]:BindButtonClick(function ()
            	UIAuction.showBuyItemPanel(buyList[i])
            end)

            --物品信息
        	local item = buyList[i].item;
			local slotCtrl  = CreateSlot(buyItemList[i]:GO('Slot').gameObject);
			slotCtrl.reset();
			UIAuction.SetGoodsItemSlot(item, slotCtrl);
			local itemCfg = UIAuction.GetItemCfg(item);
			buyItemList[i]:GO('Slot'):BindButtonClick(function ()
				UIAuction.clickItemSlot(item);
			end)
			buyItemList[i]:GO('Name').text = client.tools.formatColor(itemCfg.show_name, const.qualityColor[item.quality + 1]);
			buyItemList[i]:GO('Price').text = buyList[i].price;
			buyItemList[i]:GO('Seller').text = buyList[i].rolename;
        end

        for i=#buyList + 1, #buyItemList do
            buyItemList[i].gameObject:SetActive(false);
        end
	end

	function UIAuction.clickItemSlot(item)
		if item.type == const.bagType.item then
            PanelManager:CreateConstPanel('ItemFloat',UIExtendType.BLACKCANCELMASK,{bDisplay = true, sid = item.sid});
		elseif item.type == const.bagType.equip then
			if item.quality == const.quality.orangepiece then
                PanelManager:CreateConstPanel('FragmentFloat',UIExtendType.BLACKCANCELMASK,{base = item, showButton = false});  
			else
                PanelManager:CreateConstPanel('EquipFloat',UIExtendType.BLACKCANCELMASK,{showType = "show",isScreenCenter = true, base = item});
			end
		elseif item.type == const.bagType.gem then
			local param = { bDisplay = true, gem = {sid = item.sid} , count = 1};
            PanelManager:CreateConstPanel('GemFloat',UIExtendType.BLACKCANCELMASK, param);
		end
	end

	--显示购买物品界面
	function UIAuction.showBuyItemPanel(buyItem)
		if buyItem.rolename == DataCache.myInfo.name then
			ui.showMsg("不可以购买自己的物品")
			return;
		end

		curBuyItem = buyItem;
		this:GO('BuyPanel.Buy').gameObject:SetActive(true);
		local item = buyItem.item;
		local slotCtrl  = CreateSlot(this:GO('BuyPanel.Buy.Slot').gameObject);
		slotCtrl.reset();
		UIAuction.SetGoodsItemSlot(item, slotCtrl);
		slotCtrl.setAttr();

		local itemCfg = UIAuction.GetItemCfg(item);
		this:GO('BuyPanel.Buy.Name').text = client.tools.formatColor(itemCfg.show_name, const.qualityColor[item.quality + 1]);

		--设置
		local count = item.count; 
		this:GO('BuyPanel.Buy.Num.Text').text = 1;
		this:GO('BuyPanel.Buy.Total.Text').text = buyItem.price;
		
		BindNumberChange(this:GO('BuyPanel.Buy.Num'), 1, count, function ()
			this:GO('BuyPanel.Buy.Total.Text').text = buyItem.price * tonumber(this:GO('BuyPanel.Buy.Num.Text').text);	
		end);
	end

	--关闭物品上架
	function UIAuction.hideBuyItemPanel( )
		this:GO('BuyPanel.Buy').gameObject:SetActive(false);
	end

	function UIAuction.buyGoods()
		if curBuyItem ~= nil then
			local count = tonumber(this:GO('BuyPanel.Buy.Num.Text').text);
			local cost = count*curBuyItem.price;

			if DataCache.role_diamond < cost then
				ui.showMsgBox(nil, "钻石不足，确定进入充值？", ui.showChargePage);
				return;
			elseif DataCache.role_goumaili < cost then
				ui.showMsgBox(nil, "购买力不足，确定进入充值？", ui.showChargePage);
				return;
			end

			client.auction.buyItem(curBuyItem.jiaoyiid, count, UIAuction.buyGoodsCallBack);
			UIAuction.hideBuyItemPanel( );
		end
	end

	function UIAuction.buyGoodsCallBack(goods)
		local nowTime = math.round(TimerManager.GetServerNowMillSecond()/1000);
		if nowTime - lastRefreshTime > refreshTime then
			UIAuction.refreshGoods();
		else
			local remainTime = UIAuction.getRemainTime(goods.time);
			if remainTime <= 0 or goods.item.count == 0 then
				UIAuction.refreshGoods();
			else
				UIAuction.refreshBuyList()
			end
		end
	end

	--显示出售界面
	function UIAuction.showSalePanel( )
		this:GO('BuyPanel').gameObject:SetActive(false);
		this:GO('SalePanel').gameObject:SetActive(true);
		this:GO('SalePanel.Sale').gameObject:SetActive(false);
		this:GO('SalePanel.Title.Count').text = string.format("我的摊位(%s/%s)",0, stall_count);

		for i=1, #stallList do
			stallList[i].gameObject:SetActive(false);
		end
		client.auction.getSelfShelveItem();
	end

	--摊位列表
	function UIAuction.initStall( )
		local itemPrefab = this:GO('SalePanel.List.Viewport.Content.Item');
		itemPrefab.gameObject:SetActive(false);

		local content = this:GO('SalePanel.List.Viewport.Content');

		for i=1, stall_count do
	        local item = newObject(itemPrefab);
	        item.transform:SetParent(content.transform);
	        item.transform.localScale = Vector3.one;
	        item.transform.localPosition = Vector3.zero;
	        item.gameObject:SetActive(true)
	        stallList[i] = item;
        end
	end

	function UIAuction.getRemainTime(shelveTime)
		local nowSecond = math.round(TimerManager.GetServerNowMillSecond()/1000);
		return sell_time + shelveTime - nowSecond;
	end

	function UIAuction.setReaminTime(remainTime, wrapper)
		wrapper.gameObject:SetActive(true);

		if remainTime >= 3600 then
			local hour = math.floor(remainTime / 3600);
			wrapper.text = "剩余"..hour.."小时";
		elseif remainTime >= 60 then
			local minite = math.floor(remainTime / 60);
			wrapper.text = "剩余"..minite.."分钟";
		elseif remainTime > 0 then
			wrapper.text = "小于1分钟";
		else
			wrapper.gameObject:SetActive(false);
		end
	end

	--刷新摊位
	function UIAuction.refreshStall( )
		local shelveList = client.auction.getShelveList();
		UIAuction.shelveList = shelveList;
		this:GO('SalePanel.Title.Count').text = string.format("我的摊位(%s/%s)",#shelveList, stall_count);

		local flag = false; --能提现或者有过期的标识
		for i=1, #stallList do
			stallList[i].gameObject:SetActive(true);
            if i <= #shelveList then
            	stallList[i]:GO('Goods').gameObject:SetActive(true);
            	stallList[i]:GO('Goods'):BindButtonClick(function ( )
            		if shelveList[i].cash > 0 then
            			UIAuction.withdrawCash(shelveList[i].jiaoyiid)
            		else
            			UIAuction.showShelvePanel(true, shelveList[i].jiaoyiid);
            		end
            	end);
            	stallList[i]:GO('Add').gameObject:SetActive(false);

            	--摊位出售的物品信息
            	local item = shelveList[i].item;
				local slotCtrl  = CreateSlot(stallList[i]:GO('Goods.Slot').gameObject);
				slotCtrl.reset();
				
				UIAuction.SetGoodsItemSlot(item, slotCtrl);
				local itemCfg = UIAuction.GetItemCfg(item);
				stallList[i]:GO('Goods.Name').text = client.tools.formatColor(itemCfg.show_name, const.qualityColor[item.quality + 1]);
				stallList[i]:GO('Goods.Price').text = shelveList[i].price;

				stallList[i]:GO('Goods.Slot._spWear').gameObject:SetActive(false);
				local remainTime = UIAuction.getRemainTime(shelveList[i].time);
				if shelveList[i].cash > 0 then
					stallList[i]:GO('Goods.Slot._spWear').gameObject:SetActive(true);
					stallList[i]:GO('Goods.Slot._spWear').sprite = "tb_tixian";
					flag = true;
				elseif remainTime <= 0 then
					stallList[i]:GO('Goods.Slot._spWear').gameObject:SetActive(true);
					stallList[i]:GO('Goods.Slot._spWear').sprite = "tb_guoqi";
					flag = true;
				end
				UIAuction.setReaminTime(remainTime, stallList[i]:GO('Goods.Time'))
				
            else
            	stallList[i]:GO('Goods').gameObject:SetActive(false);
            	stallList[i]:GO('Add').gameObject:SetActive(true);
            	stallList[i]:GO('Add'):BindButtonClick(function ()
            		UIAuction.showShelvePanel(false);
            	end);
            end
        end

        UIAuction.controller.SetRedPoint(2, flag);

        --如果重新上架的界面没关闭，则刷新
        if this:GO('SalePanel.Sale').gameObject.activeSelf then
        	UIAuction.refreshShelvePanel()
        end

        if param.isShelve then
        	UIAuction.showShelvePanel(false, param.itemId);
        end
	end

	--提现
	function UIAuction.withdrawCash(jiaoyiid)
		client.auction.withDrawCash(jiaoyiid);
	end

	function UIAuction.withdrawCashAll()
		client.auction.withDrawCashAll();
	end

	--显示物品上架
	function UIAuction.showShelvePanel(reShelve, goodsId)
		isReShelve = reShelve;

		if reShelve then
			goodsList = client.auction.getReShelveList();
		else
			goodsList = client.auction.getBagList();
		end

		if #goodsList == 0 then
			UIAuction.hideShelvePanel( );
			if not reShelve then
				ui.showMsg("背包中没有可出售的物品");
			end
			return;
		end

		this:GO('SalePanel.Sale').gameObject:SetActive(true);
		this:GO('SalePanel.Sale.Button.BtnShelve').transform.localPosition = reShelve and btnShelvePos or Vector3.New(0,btnShelvePos.y, btnShelvePos.z);
		this:GO('SalePanel.Sale.Button.Cost').transform.localPosition = reShelve and shelveCostPos or Vector3.New(0,shelveCostPos.y, shelveCostPos.z);
		this:GO('SalePanel.Sale.Button.BtnShelve.Text').text = reShelve and "重新上架" or "上架";
		this:GO('SalePanel.Sale.Button.BtnOffShelve').gameObject:SetActive(reShelve);

		curSelectedGoods = nil;--清除当前选择的物品
		curSelectedGoodsId = goodsId;

		local prefab = this:LoadAsset("BagItem");
		local itemContainer = this:GO('SalePanel.Sale.List.Container');
		local warpContent = itemContainer:GetComponent("UIWarpContent");
		
		warpContent.goItemPrefab = prefab;
		warpContent:BindInitializeItem(UIAuction.FormatGoodsItem);
		warpContent:Init(#goodsList);

	end

	--关闭物品上架
	function UIAuction.hideShelvePanel( )
		this:GO('SalePanel.Sale').gameObject:SetActive(false);
		param.isShelve = false;
	end

	function UIAuction.refreshShelvePanel()
		UIAuction.showShelvePanel(true);
	end

	function UIAuction.FormatGoodsItem(go, i)
		local wrapper = go:GetComponent("UIWrapper");
		local slotCtrl  = CreateSlot(go);
		slotCtrl.reset();
		wrapper:UnbindAllButtonClick();
		
		local item = goodsList[i];
		if isReShelve then
			item = goodsList[i].item;

			local remainTime = UIAuction.getRemainTime(goodsList[i].time);
			wrapper:GO('_weijianding').gameObject:SetActive(remainTime <= 0);
			wrapper:GO('_weijianding').sprite = "tb_guoqi";
		end		
		if item ~= nil then
			wrapper:BindButtonClick(function( )
				UIAuction.ClickGoodsItem(slotCtrl, i);
			end);
		
			UIAuction.SetGoodsItemSlot(item, slotCtrl);
			
			--默认选中第一个
			if curSelectedGoodsId ~= nil and curSelectedGoodsId ~= 0 then
				if (param.isShelve and goodsList[i].id == curSelectedGoodsId) or
				 goodsList[i].jiaoyiid == curSelectedGoodsId then
					UIAuction.ClickGoodsItem(slotCtrl, i);
				end
			else
				if i == 1 then
					UIAuction.ClickGoodsItem(slotCtrl, i);
				end
			end
		end
	end

	function UIAuction.SetGoodsItemSlot(item, slotCtrl )
		if item.type == const.bagType.equip then
            slotCtrl.setBagEquip(item);
		else
			slotCtrl.setItem(item);
		end
	end

	function UIAuction.ClickGoodsItem(slot, index)
		if curSelectedGoods ~= nil then
			curSelectedGoods.setChoose(false);
		end

		curSelectedGoods = slot;
		curGoodsIndex = index;
		slot.setChoose(true);
		this:GO('SalePanel.Sale.Info.Time').gameObject:SetActive(false);

		local item = goodsList[index];
		--交易价格
		local price = 0;
		if isReShelve then
			item = goodsList[index].item;
			price = goodsList[index].price or 0;
			--重新上架物品的时间状态
			local remainTime = UIAuction.getRemainTime(goodsList[index].time);
			if remainTime > 0 then
				this:GO('SalePanel.Sale.Info.Time').gameObject:SetActive(true);
				UIAuction.setReaminTime(remainTime, this:GO('SalePanel.Sale.Info.Time'))
			end
		end	

		local slotCtrl  = CreateSlot(this:GO('SalePanel.Sale.Info.Slot').gameObject);
		slotCtrl.reset();
		UIAuction.SetGoodsItemSlot(item, slotCtrl);
		slotCtrl.setAttr(nil);

		local itemCfg = UIAuction.GetItemCfg(item);
		this:GO('SalePanel.Sale.Info.Name').text = client.tools.formatColor(itemCfg.show_name, const.qualityColor[item.quality + 1]);
		this:GO('SalePanel.Sale.Info.Desc').text = "类型："..itemCfg.showtype;

		--设置
		local count = item.count;
		local table = tb.jiaoyihang[item.sid] 
		local priceMin = table.minprice;
		local priceMax = table.maxprice;
		this:GO('SalePanel.Sale.Setting.Num.Text').text = count;
		this:GO('SalePanel.Sale.Setting.Price.Text').text = 0;
		UIAuction.refreshShelveTotal();

		--请求服务器推荐价格，此时不让点击
		this:GO('SalePanel.Sale.boxcollider').gameObject:SetActive(true);

		local callback = function (recommendPrice)
			this:GO('SalePanel.Sale.boxcollider').gameObject:SetActive(false);
			this:GO('SalePanel.Sale.Setting.Price.Text').text = recommendPrice;
			UIAuction.refreshShelveTotal();

			BindNumberChange(this:GO('SalePanel.Sale.Setting.Num'), 1, count, UIAuction.refreshShelveTotal);
			BindNumberChange(this:GO('SalePanel.Sale.Setting.Price'), priceMin, priceMax, 
				function ()
					local price = this:GO('SalePanel.Sale.Setting.Price.Text').text;
					this:GO('SalePanel.Sale.Setting.Slider').SliderValue = (price - priceMin) / (priceMax - priceMin);
				end, 
				function ()
					ui.showMsg("已经是最低价了");
				end,
				function ()
					ui.showMsg("已经是最高价了");
				end);

			this:GO('SalePanel.Sale.Setting.Slider'):BindSliderValueChanged(function (value)
				local price = math.round(value * (priceMax - priceMin)) + priceMin;
				this:GO('SalePanel.Sale.Setting.Price.Text').text = price;
				UIAuction.refreshShelveTotal();
			end);
			this:GO('SalePanel.Sale.Setting.Slider').SliderValue = (recommendPrice - priceMin) / (priceMax - priceMin);
			this:GO('SalePanel.Sale.Setting.Min'):BindButtonClick(function ()
				if this:GO('SalePanel.Sale.Setting.Slider').SliderValue == 0 then
					ui.showMsg("已经是最低价了");
				end
				this:GO('SalePanel.Sale.Setting.Slider').SliderValue = 0;
			end);
			this:GO('SalePanel.Sale.Setting.Max'):BindButtonClick(function ()
				if this:GO('SalePanel.Sale.Setting.Slider').SliderValue == 1 then
					ui.showMsg("已经是最高价了");
				end
				this:GO('SalePanel.Sale.Setting.Slider').SliderValue = 1;
			end);
		end

		if price > 0 then
			callback(price);
		else
			client.auction.getRecommendPrice(item.sid, callback);
		end
	end

	--刷新上架物品总价
	function UIAuction.refreshShelveTotal( )
		local count = this:GO('SalePanel.Sale.Setting.Num.Text').text;
		local price = this:GO('SalePanel.Sale.Setting.Price.Text').text;

		local total = count * price;
		this:GO('SalePanel.Sale.Setting.Total.Text').text = total;
		costGold = total * 12;
		local color = DataCache.role_money < costGold and Color.New(1, 0, 0) or Color.New(116/255,116/255,116/255);
		this:GO('SalePanel.Sale.Button.Cost').text = string.format("上架费:%s金币", costGold);
		this:GO('SalePanel.Sale.Button.Cost').textColor =  color;
	end

	function UIAuction.shelveGoods()
		local item = goodsList[curGoodsIndex];
		local count = tonumber(this:GO('SalePanel.Sale.Setting.Num.Text').text);
		local price = tonumber(this:GO('SalePanel.Sale.Setting.Price.Text').text);

		if DataCache.role_money < costGold then
			ui.showBuyMoney()
			return;
		end

		if isReShelve then
			client.auction.reShelveItem(item.jiaoyiid, price, count)
		else
			UIAuction.hideShelvePanel()
			if #UIAuction.shelveList >= stall_count then
				ui.showMsg(string.format("最多只能同时上架%s件道具",stall_count));
			else
				client.auction.shelveItem(item.pos, price, count)
			end
			
		end
	end

	function UIAuction.offShelveGoods()
		local item = goodsList[curGoodsIndex];
		client.auction.offShelveItem(item.jiaoyiid)
	end

	function UIAuction.closeSelf()
		destroy(this.gameObject);
	end

	function UIAuction.OnDestroy(  )
        
	end


	function UIAuction.UpdateOneSecond()
		-- body
	end

	return UIAuction;
end

function ui.shelveItem(id)
	 PanelManager:CreatePanel('UIAuction' , UIExtendType.NONE, {isShelve = true, itemId = id});
end

