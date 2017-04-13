function MsgBoxView(param)
	local MsgBox = {};
	local this = nil;
	local text;
	local title;

	function MsgBox.Start() 
		this = MsgBox.this;
		text = param.text;
		title = param.title;

		if title == nil then
			title = "提    示"
		end

		this:GO("Image.top.Title").text = title;
		this:GO("Image.Text"):GetComponent("LRichText").text = text;
		this:GO('Image.btnOK'):BindButtonClick(function ()
			if (param.callBackOK ~= nil) then
				param.callBackOK(param.arguments)
			end
			MsgBox.Close()
		end);

		if param.hideCancel then
			local trans = this:GO('Image.btnOK').transform;
			trans.localPosition = Vector3.New(0, trans.localPosition.y, 0);
		end

		this:GO('Image.btnCancel').gameObject:SetActive(not param.hideCancel)
		this:GO('Image.btnCancel'):BindButtonClick(function ()
			if (param.callbackCancel ~= nil) then
				param.callbackCancel(param.arguments)
			end
			MsgBox.Close()
		end)

		this:GO('Image.top.closeBtn'):BindButtonClick(function ()
			if (param.callbackCancel ~= nil) then
				param.callbackCancel(param.arguments)
			end
			MsgBox.Close()
		end);

	end

	function MsgBox.Close() 
		if this == nil then
			return
		end
		destroy(this.gameObject)
		this = nil
	end
	return MsgBox;
end

function ui.showMsgBox(title, text, callBackOK, callbackCancel, hideCancel, arguments)
	local param = {title = title, text = text, callBackOK = callBackOK, callbackCancel = callbackCancel, hideCancel = hideCancel, arguments = arguments};
	AudioManager.PlaySoundFromAssetBundle("popup_prompt");
	PanelManager:CreateConstPanel("MsgBox", UIExtendType.BLACKMASK, param);
end

function ui.closeMsgBox()
	local msgBoxWrap = UIManager.GetInstance():FindUI('MsgBox');
    if msgBoxWrap ~= nil then
        destroy(msgBoxWrap.gameObject);
    end
end
