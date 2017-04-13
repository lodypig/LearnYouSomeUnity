
function CreateAuctionCtrl()
	local auction = {};

	local shelveList = {};	--自己的上架列表
	local goodsList = {};
	local pageNum = 0;

	--交易行是否只显示有货的标签页
	auction.showSubTypeFlag = false;

    --商品显示排序
	local goodsSortFunc = function (item1, item2)
        if item1.price == item2.price then
           	return item1.time < item2.time; 
        end
        return item1.price < item2.price;
	end

	--获取商品列表
	function auction.getGoodsList()
		local list = {};
		for _,v in pairs(goodsList) do
			if v then
				list[#list + 1] = v;
			end
		end 
        table.sort(list,goodsSortFunc)
		return list;
	end


	--商品页数
	function auction.GetGoodsPage()
		return pageNum;
	end

	local shelveSortFunc = function (item1, item2)
		return item1.time < item2.time;
	end

	--获取自己的上架列表
	function auction.getShelveList()
		local list = {};
		for _,v in pairs(shelveList) do
			if v then
				list[#list + 1] = v;
			end
		end 
		table.sort(list, shelveSortFunc);
		return list;
	end

	--获取重新上架的列表
	function auction.getReShelveList()
		local list = {};
		for _,v in pairs(shelveList) do
			if v and v.cash == 0 then
				list[#list + 1] = v;
			end
		end 
		table.sort(list, shelveSortFunc);
		return list;
	end

	local equipSortFunc = function (equip1, equip2)
		if equip1.quality ~= equip2.quality then
			return equip1.quality > equip2.quality;
		else
			if equip1.level ~= equip2.level then
				return equip1.level > equip2.level;
			else
				if equip1.buwei ~= equip2.buwei then
					return const.BuWeiChangedIndex[equip1.buwei] < const.BuWeiChangedIndex[equip2.buwei];
				else
					return equip1.id < equip2.id;
				end
			end
		end
	end

	--获取背包可出售的物品列表
	function auction.getBagList()
		local list = {};

		--装备
		local bagList = Bag.GetShowEquip(equipSortFunc);
		for i=1,#bagList do
			local equip = bagList[i];
			--未鉴定和橙装碎片才能交易
			if equip.quality == const.quality.unidentify or equip.quality == const.quality.orangepiece then
				if tb.jiaoyihang[equip.sid] ~= nil and tb.jiaoyihang[equip.sid].cansell == 1 then
					list[#list+1] = bagList[i];
				end
			end
		end

		--物品
		local bagList = Bag.GetShowItem();
		for i=1,#bagList do
			local item = bagList[i];
			if tb.jiaoyihang[item.sid] ~= nil and tb.jiaoyihang[item.sid].cansell == 1 then
				list[#list+1] = bagList[i];
			end
		end

		--宝石
		bagList = Bag.GetShowGem();
		for i=1,#bagList do
			local gem = bagList[i];
			if tb.jiaoyihang[gem.sid] ~= nil and tb.jiaoyihang[gem.sid].cansell == 1 then
				list[#list+1] = bagList[i];
			end
		end

		return list;
	end

	--交易信息解析
	function parseSellInfo(Info)
		local sellinfo = {}
		sellinfo.jiaoyiid = Info[1]
		sellinfo.rolename = client.tools.ensureString(Info[2]);
		sellinfo.time = Info[3]
		sellinfo.cash = Info[4]
		sellinfo.price = Info[5]
		sellinfo.item = {}

		local item = Info[6] 
		local sid = item[1];
		if tb.ItemTable[sid] then
			sellinfo.item.sid = sid
			local tmp = item[2];
			sellinfo.item.count = tmp[1];
			sellinfo.item.id = tmp[2];		
			sellinfo.item.quality = tb.ItemTable[sid].quality;
			sellinfo.item.type = const.bagType.item;
		elseif tb.EquipTable[sid] then
			sellinfo.item = client.equip.parseEquip(item);
			sellinfo.item.type = const.bagType.equip;
		end
		return sellinfo
	end

	--成功被他人购买
	function auction.sellsuccess(msg)
		local sid = msg.sid
		local num = msg.number
		local cash = msg.cash
		local name = ""
		if tb.ItemTable[sid] ~= nil then
			name = tb.ItemTable[sid].name
		elseif tb.EquipTable[sid] ~= nil then
			name = tb.EquipTable[sid].name
		end

		local str = string.format("恭喜！成功出售%s*%d，获得%d钻石",name,num,cash)
		ui.showMsg(str);
	end

	SetPort("sellsuccess",auction.sellsuccess);

	--上架
	function auction.shelveItem(bagindex, price, number)
		local msg = {};
		msg.cmd = "sell_item"
		msg.bagindex = bagindex
		msg.price = price
		msg.number = number

        Send(msg, function(msg)
        	ui.showMsg("物品上架成功");
         end);
	end
	--重新上架
	function auction.reShelveItem(jiaoyiid,price,number)
		local msg = {};
		msg.cmd = "resell_item"
		msg.jiaoyiid = jiaoyiid
		msg.price = price
		msg.number = number
        Send(msg, function(msg)
        	ui.showMsg("物品上架成功");
         end);
	end
	--下架
	function auction.offShelveItem(jiaoyiid)
		local msg = {cmd = "off_shelf_item", jiaoyiid = jiaoyiid};
        Send(msg);
	end
	--提现
	function auction.withDrawCash(jiaoyiid)
		local msg = {cmd = "withdraw_cash", jiaoyiid = jiaoyiid};
        Send(msg, function(msg)
        	ui.showMsg(string.format("你获得了%d钻石",msg.cash)) 
    	end);
	end
	--全部提现
	function auction.withDrawCashAll()
		local msg = {cmd = "withdraw_cash_all"};
        Send(msg, function(msg) 
        	ui.showMsg(string.format("你获得了%d钻石",msg.cash))
    	end);
	end
	--获取自己上架物品信息
	function auction.getSelfShelveItemCallBack(msg)

		local list = msg["selfsellinfo"]
		shelveList = {};
		for i = 1,#list do
			local sell = parseSellInfo(list[i])
			shelveList[sell.jiaoyiid] = sell;
		end

		UIManager.GetInstance():CallLuaMethod('UIAuction.refreshStall');
		UIManager.GetInstance():CallLuaMethod('UIRole.refreshBag');
	end

	SetPort("selfsellinfo",auction.getSelfShelveItemCallBack);

	function auction.getSelfShelveItem()
		local msg = {cmd = "get_self_sellinfo"};
        Send(msg);
	end

	--获取指定类型的物品信息
	function auction.getgoodsItemCallBack(msg)
		local list = msg["sell_info_list"]
		pageNum = msg["pagenum"]
		goodsList = {}
		for i = 1,#list do
			local data = parseSellInfo(list[i])
			goodsList[data.jiaoyiid] = data;
		end

		UIManager.GetInstance():CallLuaMethod('UIAuction.refreshBuyList');
	end
	
	SetPort("sell_info_list",auction.getgoodsItemCallBack);
	function auction.getgoodsItem(type,buwei,level,page)
		local msg = {};
		msg.cmd = "get_sell_info_list"
		msg.type = type
		msg.buwei = buwei
		msg.level = level
		msg.page = page
        Send(msg);
	end


	function auction.getGoodsPageList(type, level)
		local msg = {};
		msg.cmd = "get_sell_info_pagecount"
		msg.type = type
		msg.level = level
        Send(msg, function(msg)
        	auction.pageList = msg.list;
        	UIManager.GetInstance():CallLuaMethod('UIAuction.ShowBuySubType');
        end);
	end
	--购买物品
	function auction.buyItem(jiaoyiid,number, callback)
		local msg = {};
		msg.cmd = "buy_item"
		msg.jiaoyiid = jiaoyiid
		msg.number = number

        Send(msg, function(msg) 
		    local data = parseSellInfo(msg.sellinfo)
			if goodsList[data.jiaoyiid] ~= nil then
				goodsList[data.jiaoyiid] = data;
			end

			callback(data);
			if msg.type == "addemail" then
	        	ui.showMsg("背包已满，物品以邮件形式发送");
	        else
				local temp = client.tools.formatColor(data.item.name, const.qualityColor[data.item.quality + 1]);
	            local str = "你购买了"..temp.."X"..number;
				ui.showMsg(str);
			end
        end);
	end

	--获得推荐价格
	function auction.getRecommendPrice(sid, callback)
		local msg = {cmd = "get_recommendprice", sid = sid};
        Send(msg, function(msg)
        	callback(msg.price);
        end);
	end

	return auction;
end

client.auction = CreateAuctionCtrl();