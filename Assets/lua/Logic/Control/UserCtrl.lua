local function CreateUserCtrl()
	local UserCtrl = {};

	function UserCtrl.BuyOfflineTime(buyNumber)
		local cost = buyNumber * const.BuyGuajiTimePrice;
		local diamond = DataCache.role_diamond;
		if diamond < cost then
			ui.showCharge();
			return;
		end

		local msg = {cmd = "buy_offline_time", number = buyNumber};
		Send(msg, function(msg)
			DataCache.offlineTime = msg.result;
        	EventManager.onEvent(Event.ON_BUY_OFFLINE_TIME);
        	ui.showMsg("购买成功")
		 end)
	end

	function UserCtrl.IsOpenGuaji()
		return DataCache.myInfo.level >= const.GuajiLevel;
	end

	return UserCtrl;
end 

client.userCtrl = CreateUserCtrl();