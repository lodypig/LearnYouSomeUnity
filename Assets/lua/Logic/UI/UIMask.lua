function UIMaskView ()
	local UIMask = {};
	local this = nil;
	function UIMask.Start() 
		UIMask.this.Window:SetShow(false);
		-- UIManager.Instance:SetMaskLayer(UIMask.this.gameObject);
	end
	
	function UIMask.OnDestroy( )
		-- body
	end
	return UIMask;
end
