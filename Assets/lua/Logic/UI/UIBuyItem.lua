function UIBuyItemView(param)	
	local UIBuyItem = {}; 
	local this = nil;
	local itemId = 0;
	local price = 0;
	local number = 0;
	local totalPrice = 0;
	local itemInfo = nil;

	local BtnMinus = nil;
	local BtnPlus = nil;
	
	function UIBuyItem.Start() 
		this = UIBuyItem.this;
		--text = param.text;
		itemId = param.itemId;
		itemInfo = tb.ItemTable[itemId];
		this:GO("Board.ItemName").text = client.tools.formatColor(itemInfo.name, const.qualityColor[itemInfo.quality + 1]);
		price = param.price;	--记录商品的单价
		number = 1;		--默认购买数量一个，可以调整为配置
		totalPrice = price * number;

		this:GO("Board.BuyNumber.Number").text = number;
		this:GO("Board.PriceNumber.Number").text = totalPrice;

		this:GO('Board.BagItem.icon').sprite = itemInfo.icon;
		this:GO('Board.BagItem.frame').sprite = const.QUALITY_BG[itemInfo.quality+1]; 

		this:GO('Board.BuyNumber.Back'):BindButtonClick(function()
			local param = {textWrapper = this:GO("Board.BuyNumber.Number")};
			PanelManager:CreatePanel('UIKeyBoard',UIExtendType.TRANSMASK,param);
		end	);

		BtnMinus = this:GO('Board.BuyNumber.BtnMinus');
		BtnMinus:BindButtonClick(function()
			number = number - 1;
			if number < 1 then
				number = 1
			end
			this:GO("Board.BuyNumber.Number").text = number;
		end	);

		BtnPlus = this:GO('Board.BuyNumber.BtnPlus');
		BtnPlus:BindButtonClick(function()
			number = number + 1;
			if number > 999 then
				number = 999;
			end
			this:GO("Board.BuyNumber.Number").text = number;
		end	);

		this:GO('Board.Buy'):BindButtonClick(function()
			local msg = {cmd = "shop_buy", shop_id = param.shopId,goods_id = itemId, goods_numb = number};
			Send(msg,UIBuyItem.callback);
		end);

		this:GO('Board.Close'):BindButtonClick(UIBuyItem.Close);
	end

	function UIBuyItem.Update()
		number = tonumber(this:GO("Board.BuyNumber.Number").text);
		if number > 999 then
			number = 999;
		end
		this:GO("Board.BuyNumber.Number").text = number;
		totalPrice = price * number;
		this:GO("Board.PriceNumber.Number").text = totalPrice;
		if number == 1 then
			BtnMinus.buttonEnable = false;
		else
			BtnMinus.buttonEnable = true;
		end
		-- body
	end

	function UIBuyItem.updateNumber()
		-- body
	end

	function UIBuyItem.callback(MsgTable)
		if MsgTable.error == nil then
			ui.showMsg("你购买了"..number.."个"..itemInfo.name);
			UIBuyItem.Close();
		else
			--print("Buy Failed!Error:"..MsgTable.error);
		end
	end

	function UIBuyItem.Close() 
		-- if UIKeyBoard.this ~= nil then
		-- 	UIKeyBoard.Close();
		-- end
		destroy(this.gameObject);
	end
	return UIBuyItem;
end