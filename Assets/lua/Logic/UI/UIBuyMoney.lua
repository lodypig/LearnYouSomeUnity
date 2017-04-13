
function UIBuyMoneyView ()
	local UIBuyMoney = {};
	local this = nil;

	local Close = nil;
	local value = nil;
	local BuyBtn = nil;

	local buy_money_max_count = 0;

	function UIBuyMoney.Start ()
		this = UIBuyMoney.this;

		buy_money_max_count = #tb.MoneyTable;

		Close = this:GO('Panel._Close');
		value = this:GO('Panel.remain._value');
		BuyBtn = this:GO('Panel._BuyBtn');

		UIBuyMoney.checkResetCount();
		UIBuyMoney.updateBuyCount();

		Close:BindButtonClick(UIBuyMoney.Close);

		BuyBtn:BindButtonClick(function ()

			-- 购买体力次数不足判断
			local buyCount = client.moneyCtrl.GetMoneyBuyCount();
			local lastTime = client.moneyCtrl.GetLastBuyMoneyTime();
			local currTime = math.floor(TimerManager.GetServerNowMillSecond()/1000);

			if lastTime == 0 or client.tools.IsTheSameDay(lastTime, currTime) then
				local remainingBuyCount = buy_money_max_count - buyCount;
				if remainingBuyCount <= 0 then
					ui.showMsg("购买金币次数不足");
					return;
				end
			end

			local cost = tb.MoneyTable[buyCount + 1];
			local diamond = DataCache.role_diamond;
			if diamond < cost.diamond then
				ui.showCharge();
				return;
			end

			-- 购买金币
			client.moneyCtrl.BuyMoney(function (msgTable)
				local type = msgTable["type"];
				local success = false;
				if type == "ok" then
		  			success = true;
		  		end

		  		if success then
					local value = msgTable["value"];
					local buy_time = msgTable["now"];
					UIBuyMoney.checkResetCount();
					client.moneyCtrl.SetLastBuyMoneyTime(buy_time);
					local buyCount = client.moneyCtrl.GetMoneyBuyCount() + 1;
					client.moneyCtrl.SetMoneyBuyCount(buyCount);
					UIBuyMoney.updateBuyCount();

					UIBuyMoney.Close();
					ui.showMsg(string.format("获得%s金币", value));

				else
					UIBuyMoney.Close();
					ui.showMsg("不能购买金币");
				end

			end);
		end);

	end


	function UIBuyMoney.Close()
		destroy(this.gameObject);
	end

	function UIBuyMoney.checkResetCount( )
		local lastTime = client.moneyCtrl.GetLastBuyMoneyTime();
		local currTime = math.floor(TimerManager.GetServerNowMillSecond()/1000);
		if lastTime ~= 0 then
			if not client.tools.IsTheSameDay(lastTime, currTime) then
				client.moneyCtrl.SetMoneyBuyCount(0);	
			end
		end
	end

	function UIBuyMoney.updateBuyCount()
		local buyCount = client.moneyCtrl.GetMoneyBuyCount();

		local item = tb.MoneyTable[buyCount + 1];
		if item ~= nil then
			this:GO('Panel.diamond.value').text = tostring(tb.MoneyTable[buyCount + 1].diamond);
			this:GO('Panel.money.value').text = tostring(tb.MoneyTable[buyCount + 1].money);
		else
			this:GO('Panel.diamond.value').text = tostring(tb.MoneyTable[buyCount].diamond);
			this:GO('Panel.money.value').text = tostring(tb.MoneyTable[buyCount].money);
		end
		value.text = tostring(buy_money_max_count - buyCount);
	end


	return UIBuyMoney;
end
