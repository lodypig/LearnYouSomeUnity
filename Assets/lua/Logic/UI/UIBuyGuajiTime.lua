function UIBuyGuajiTimeView (param)	
	local UIBuyGuajiTime = {};
	local this = nil;
	local cost = nil;

	function UIBuyGuajiTime.Start()
		this = UIBuyGuajiTime.this;

		this:GO('Panel.BtnCancel'):BindButtonClick(UIBuyGuajiTime.Cancel);
		this:GO('Panel.BtnOk'):BindButtonClick(UIBuyGuajiTime.Confirm);

		cost = this:GO('Panel.center.cost.value');
		this:GO('Panel.center.num.Text').text = 1;
		cost.text = const.BuyGuajiTimePrice;
		
		local remain_time = client.tools.formatTime(DataCache.offlineTime*60);
		BindNumberChange(this:GO('Panel.center.num'), 1, const.BuyGuajiTimeMax - remain_time.hour, function ()
			cost.text = const.BuyGuajiTimePrice * tonumber(this:GO('Panel.center.num.Text').text);	
		end);
	end

	function UIBuyGuajiTime.Cancel()
		destroy(this.gameObject);
	end

	function UIBuyGuajiTime.Confirm()
		local buyNum = tonumber(this:GO('Panel.center.num.Text').text);
		client.userCtrl.BuyOfflineTime(buyNum);
		destroy(this.gameObject);
	end

	function UIBuyGuajiTime.OnDestroy()

	end

	return UIBuyGuajiTime;
end