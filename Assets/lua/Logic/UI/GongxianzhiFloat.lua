function GongxianzhiFloatView(param)
	local GongxianzhiFloat = {};

	local this = nil;
	local selfContribution;

	function GongxianzhiFloat.Start()
		this = GongxianzhiFloat.this;
		this:BindLostFocus(GongxianzhiFloat.Close);
		selfContribution = this:GO('content.ndTop.itemCount.value');
		selfContribution.text = DataCache.contribution
		for i=1,4 do
			this:GO('content.ndBottom._Icon'..i):BindButtonClick(function ()
				GongxianzhiFloat.Close();
				if UIManager.GetInstance():FindUI('UILegion') ~= nil then
					client.legion.OnClickGetContribution();
				end
			end);
		end
	end

	function GongxianzhiFloat.Close()
		destroy(this.gameObject)
	end

	return GongxianzhiFloat;
end