function UIMolongShopView ()
	local UIMolongShop = {};
	local this = nil;

	local content = nil;
	local Item = nil;
	local BtnNext = nil;
	local BtnPre = nil;
	local Num = nil;
	local sortedTab = nil;
	local curPage = nil;
	local totalPage = nil;
	-- local go = nil;
	local curCount;
	local shopTab = nil;
	-- local formatPage;
	function UIMolongShop.parseDealInfo(info)
		local dealInfo = {}
		dealInfo.dealId = info[1];
		dealInfo.usedCount = info[2];
		return dealInfo;
	end

	-- 初始化shopTab，每一次进行购买时需要，以dealId作key查询table，总次数-使用的次数是否大于购买次数，进行逻辑判断
	-- 每一次购买操作完成之后，在服务端消息回调中，需要进行对shopTab进行更新
	function UIMolongShop.initShopTab(msg)
		local list  = msg["deal_list"];
		shopTab = {};
		if next(list) ~= nil then 
			for i=1, #list do
				local dealInfo = UIMolongShop.parseDealInfo(list[i])
				shopTab[dealInfo.dealId] = dealInfo;
			end
		end
	end

	function UIMolongShop.setPageNum()
		Num.text = curPage..'/'..totalPage;
	end

	-- slot显示
	function UIMolongShop.setItemSlot(item, slotCtrl )
        slotCtrl.setItem(item);
	end

	-- 生成个item给slotctrl使用
	function UIMolongShop.genItem(sid,count)
		local item = {};
		if tb.ItemTable[sid] then
			item.type = const.bagType.item;
			item.quality = tb.ItemTable[sid].quality;
		elseif tb.GemTable[sid] then
			item.type = const.bagType.gem;
			item.quality = tb.GemTable[sid].quality;
		end
		item.sid = sid;
		item.count = count;

		return item;
	end

	-- 购买操作完成后重置兑换次数
	function UIMolongShop.resetCount(param)
		local colorStr;
		local resultVaue = param.curCount;
		if resultVaue == 0 then 
			colorStr  = '#E82424';
		else
			colorStr  = '#E4E4E4';
		end
		param.go:GO('count').text = '兑换次数： '..string.format("<color=%s>%s</color>/%s",colorStr,resultVaue,param.maxCount);
	end

	-- -- 购买操作完成后 物品价格的颜色要重置
	-- function UIMolongShop.resetPriceColor(param)
	-- 	-- 获取玩家拥有的魔龙之心个数
	-- 	local colorStr;
	-- 	if heartCount < param.price then 
	-- 		colorStr  = '#E82424';
	-- 	else
	-- 		colorStr  = '#E4E4E4';
	-- 	end
	-- 	param.go:GO('Price').text = string.format("<color=%s>%s</color>",colorStr,param.price);
	-- end


	-- 确认购买操作
	function UIMolongShop.buy(dealId, dealCount, maxCount ,buyitem,go,callback)
		local msg = { cmd = "molongShop/buy" , deal_id = dealId , deal_count = dealCount };
		Send(msg,function(msg)
			-- 购买成功后重置当前的购买次数,重置shopTab,
			UIMolongShop.initShopTab(msg);
			UIMolongShop.resetCount({ go = go, maxCount = maxCount , curCount = maxCount - shopTab[dealId].usedCount});
			-- resetPriceColor({ go = go, price = msg.price });
			-- 刷新当前界面
			UIMolongShop.formatPage(curPage);
			-- 黄字提示：你购买了<数值>个<物品名>
			local temp = client.tools.formatColor(buyitem.name, const.qualityColor[buyitem.item.quality + 1]);
			local str = "你购买了"..temp.."X"..msg.item_count;
			ui.showMsg(str);
			callback();
		end);
	end

	-- 显示购买物品界面
	function UIMolongShop.showBuyItemPanel(buyItem,maxCount,availCount,heartCount,go)
		-- buyItem = {item = item ,name = shopKVTab.name, price = shopKVTab.price, dealId = dealId};
		this:GO('Buy').gameObject:SetActive(true);
		local item = buyItem.item;
		local slotCtrl  = CreateSlot(this:GO('Buy.Slot').gameObject);
		slotCtrl.reset();
		UIMolongShop.setItemSlot(item, slotCtrl);
		this:GO('Buy.Name').text = buyItem.name;

		--设置
		local count = item.count; 
		this:GO('Buy.Num.Text').text = 1;
		this:GO('Buy.Total.Text').text = buyItem.price;

		-- 点击购买按钮
		this:GO('Buy.BtnBuy'):BindButtonClick(function ()
			local dealCount = tonumber(this:GO('Buy.Num.Text').text);

			if availCount < dealCount then
				ui.showMsg('兑换次数不足');
			elseif heartCount < dealCount* buyItem.price then
				ui.showMsg('魔龙之心数量不足!');
			else
				UIMolongShop.buy(buyItem.dealId, dealCount , maxCount , buyItem,go,function ()
					this:GO('Buy').gameObject:SetActive(false);
				end);
			end
		end);

		-- 购买界面点击+.-或者使用小键盘输入时
		BindNumberChange(this:GO('Buy.Num'), 1, availCount, function ()
			local totalPrice = buyItem.price * tonumber(this:GO('Buy.Num.Text').text);
			-- 获取玩家拥有的魔龙之心个数
			local heartCount = Bag.GetItemCountBysid(const.item.dragon_heart_Sid);
			local colorStr;
			if heartCount < totalPrice then 
				colorStr  = '#E82424';
			else
				colorStr  = '#E4E4E4';
			end
			this:GO('Buy.Total.Text').text = string.format("<color=%s>%s</color>",colorStr,totalPrice);
		end);

		-- 点击关闭按钮
		this:GO('Buy.top.closeBtn'):BindButtonClick(function ()
			this:GO('Buy').gameObject:SetActive(false);
		end);
	end

	-- 设置商店中的每一个条目
	-- shopItem内容:{dealId,priority}, go表示商店中的某一栏
	function UIMolongShop.formatItem(shopItem,go)
		local dealId = shopItem.dealId;

		go.gameObject:SetActive(true);
		-- shopKVTab 包含一个商品的 itemId,amount,price,maxCount,priority,name
		local shopKVTab = tb.MolongShopKVTable[dealId];
		local usedCount;
		if next(shopTab) == nil or shopTab[dealId] == nil then 
			usedCount = 0;
		else
			usedCount = shopTab[dealId].usedCount;
		end
		local availCount = shopKVTab.maxCount - usedCount;
		local item = UIMolongShop.genItem(shopKVTab.itemId,shopKVTab.amount);
		local itemCfg = tb.ItemTable[item.sid] or tb.GemTable[item.sid];
		local slotGo = go:GO('BagItem');
		local slotCtrl  = CreateSlot(slotGo.gameObject);
		slotCtrl.reset();
		UIMolongShop.setItemSlot(item, slotCtrl);
		slotGo:GetComponent("UIWrapper"):BindButtonClick(function ()
			-- 根据物品类型,判断是调用物品悬浮还是宝石悬浮
			if tb.ItemTable[item.sid] then
				local param = {bDisplay = true, sid = item.sid, base = item};		
				PanelManager:CreateConstPanel('ItemFloat',UIExtendType.BLACKCANCELMASK,param);
			elseif tb.GemTable[item.sid] then
				ui.ShowGemFloat(item, true , item.count);
			end
		end);
		go:GO('Name').text = string.format("<color=%s>%s</color>",const.qualityColor[ itemCfg.quality + 1],shopKVTab.name); 
		-- 获取玩家拥有的魔龙之心个数
		local heartCount = Bag.GetItemCountBysid(const.item.dragon_heart_Sid);
		local colorStr;
		if heartCount < shopKVTab.price then 
			colorStr  = '#E82424';
		else
			colorStr  = '#E4E4E4';
		end
		go:GO('Price').text = string.format("<color=%s>%s</color>",colorStr,shopKVTab.price);
		if availCount <= 0 then 
			colorStr  = '#E82424';
		else
			colorStr  = '#E4E4E4';
		end
		go:GO('count').text = '兑换次数： '..string.format("<color=%s>%s</color>/%s",colorStr,availCount,shopKVTab.maxCount);
		go:GetComponent("UIWrapper"):BindButtonClick(function ()
			-- 打开购买界面

			-- 购买一次之后再次点击时，数据需要使用最新的
			local heartCount = Bag.GetItemCountBysid(const.item.dragon_heart_Sid);

			local usedCount;
			if next(shopTab) == nil or shopTab[dealId] == nil then 
				usedCount = 0;
			else
				usedCount = shopTab[dealId].usedCount;
			end
			local availCount = shopKVTab.maxCount - usedCount;

            if availCount <= 0 then
            	ui.showMsg('兑换次数已达当日上限!');
            elseif heartCount < shopKVTab.price then
            	ui.showMsg('魔龙之心数量不足!');
            else
				local buyItem = {item = item ,name = shopKVTab.name, price = shopKVTab.price, dealId = dealId};
				UIMolongShop.showBuyItemPanel(buyItem,shopKVTab.maxCount,availCount,heartCount,go);
            end
		end);

	end

	-- 显示商店中的第N页(一页8栏)
	function UIMolongShop.formatPage(pageNumber)
		local j = 1;
		local wrappr = content:GetComponent("UIWrapper");
		for i = (pageNumber - 1)* 8 + 1, pageNumber* 8 do
			local go = wrappr:GO('Item'..j);
			if sortedTab[i] then
				UIMolongShop.formatItem(sortedTab[i],go);
			else
				go.gameObject:SetActive(false);
			end
			j = j + 1;
		end
	end

	function UIMolongShop.onNextPage()
		if curPage >= totalPage then
			ui.showMsg("已经是最后一页了")
			return;
		end
		curPage = curPage + 1;
		UIMolongShop.formatPage(curPage);
		UIMolongShop.setPageNum();
	end

	function UIMolongShop.onPrePage()
		if curPage == 1 then
			ui.showMsg("已经是第一页了")
			return;
		end
		curPage = curPage - 1;
		UIMolongShop.formatPage(curPage);
		UIMolongShop.setPageNum();
	end

	-- 界面上下滑动，一次翻一页
	function UIMolongShop.dragAction()
		local posY = this:GO('Panel.Container.viewport._content').transform.localPosition.y;
		if posY > 0 then
			UIMolongShop.onNextPage();
			this:GO('Panel.Container.viewport._content').transform.localPosition = Vector3.zero;
		else
			UIMolongShop.onPrePage();
			this:GO('Panel.Container.viewport._content').transform.localPosition = Vector3.zero;
		end
	end

	function UIMolongShop.Start ()
		this = UIMolongShop.this;
		content = this:GO('Panel.Container.viewport._content');
		Item = this:GO('Panel.Container.viewport._Item');
		BtnNext = this:GO('Page._BtnNext');
		BtnPre = this:GO('Page._BtnPre');
		Num = this:GO('Page._Num');
		-- 按照优先级对tb.MolongShoptable排序
		sortedTab = tb.MolongShopTable;
		table.sort( sortedTab , function(a,b) return a.priority < b.priority end );
		totalPage = math.ceil(#sortedTab / 8);

		-- 从服务端获取当前所有shopTab，在回调里进行页面的初始化
		local msg = { cmd = "molongShop/get_cur_count" };

		Send(msg, function (msg)
			UIMolongShop.initShopTab(msg);
			-- 初始时显示第一页
			curPage = 1;
			UIMolongShop.setPageNum();
			UIMolongShop.formatPage(curPage);

			this:GO('Panel.Container'):BindETEndDrag(function() UIMolongShop.dragAction(); end);
			BtnPre:BindButtonClick(function() UIMolongShop.onPrePage(); end );
			BtnNext:BindButtonClick(function() UIMolongShop.onNextPage(); end);
			this:GO('CommonDlg3.Close'):BindButtonClick(function() 
				destroy(this.gameObject);
			 end);
		end);
	end
	return UIMolongShop;
end

ui.ShowMolongShop = function () 
	PanelManager:CreatePanel('UIMolongShop',UIExtendType.BLACKMASK,{});
end

