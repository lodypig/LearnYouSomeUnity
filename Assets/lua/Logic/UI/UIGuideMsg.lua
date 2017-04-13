function UIGuideMsgView ()

	local UIGuideMsg = {};
	local this = nil;

	local Text = nil;
	local Line = nil;
	local Panel = nil;
	

	function UIGuideMsg.Start ()
		this = UIGuideMsg.this;
		Panel = this:GO('Panel');
		Text = this:GO('Panel._Text');
		Line = this:GO('Panel._Line');
		UIGuideMsg.Reset("");
		client.GuideMsg.AddListener(UIGuideMsg.ShowSingle);
	end


	function UIGuideMsg.Reset(msg)
		Line.alpha = 1;
		Line.fillAmount = 0;
		Text.text = msg;
		Text.alpha = 1;
		Text.scale = Vector3.New(1, 0, 1);
	end


	function UIGuideMsg.DoEffect()
		if Panel:IsDoingCrack() then
			return;
		end
		local msg = client.GuideMsg.deque();
		if msg == nil then
			return;
		end
		Panel:DoCrack(msg, 0.3, 0.3, 5.0, 1.0, client.GuideMsg.DoShow);

	end

	function UIGuideMsg.ShowSingle()
		UIGuideMsg.DoEffect();
	end

	return UIGuideMsg;
end
