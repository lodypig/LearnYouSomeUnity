
function CreateMoneyCtrl()
	local Money = {};
	-- 获取今天购买金币的次数
	function Money.GetMoneyBuyCount()
		local buyMoneyInfo = DataCache.myInfo.moneyBuyCount;
		local count = buyMoneyInfo[1];
		return count;
	end

	-- 设置今天购买金币的次数
	function Money.SetMoneyBuyCount(count)
		local buyMoneyInfo = DataCache.myInfo.moneyBuyCount;
		if buyMoneyInfo ~= nil then
			buyMoneyInfo[1] = count;
		end
	end

		-- 获取上一次购买金币的时间
	function Money.GetLastBuyMoneyTime()
		local buyMoneyInfo = DataCache.myInfo.moneyBuyCount;
		local lastTime = buyMoneyInfo[2];
		return lastTime;
	end

	-- 设置上一次购买金币的时间
	function Money.SetLastBuyMoneyTime(time)
		local buyMoneyInfo = DataCache.myInfo.moneyBuyCount;
		if buyMoneyInfo ~= nil then
			buyMoneyInfo[2] = time;
		end
	end

  	-- 购买金币
  	function Money.BuyMoney(callback)
  		local msg = {cmd = "buy_money"}; 		
  		Send(msg, callback);
  	end

  	return Money;
end

client.moneyCtrl = CreateMoneyCtrl();