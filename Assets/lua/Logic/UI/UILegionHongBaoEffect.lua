function UILegionHongBaoEffectView (param)
	local UILegionHongBaoEffect = {};
	local this = nil;

	local effect = nil;

	function UILegionHongBaoEffect.Start ()
		this = UILegionHongBaoEffect.this;
	end

	function UILegionHongBaoEffect.FirstUpdate()
		effect = this:GO('panel.hongBao._effect');
		effect:PlayUIEffect(this.gameObject, "kaihongbao", 1,function ()end,true );
		this:Delay(0.2,function ()
			if param.callback then
				param.callback()
			end
		end)
		this:Delay(1,function ()
			destroy(this.gameObject);
		end)
	end

	return UILegionHongBaoEffect;
end
