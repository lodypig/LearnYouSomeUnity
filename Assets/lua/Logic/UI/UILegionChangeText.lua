function UILegionChangeTextView (param)
	local UILegionChangeText = {};
	local this = nil;

    local oldPos;
    local editBox;

	function UILegionChangeText.Start ()
		this = UILegionChangeText.this;

       	UILegionChangeText.InitContent();
       	UILegionChangeText.close:BindButtonClick(UILegionChangeText.Close);
       	UILegionChangeText.operateBtn:BindButtonClick(UILegionChangeText.OnButtonClick);
	end

	function UILegionChangeText.InitContent()
		oldPos = UILegionChangeText.panel:GetComponent('Transform').localPosition;

		--  param  = {titleText, descText, maxCount, initText, callback}
		UILegionChangeText.title.text = param.titleText;
		UILegionChangeText.desc.text = param.descText;
		UILegionChangeText.inputText.inputText = param.initText;
		UILegionChangeText.textCount.text = math.ceil(Util.StringByteLength(param.initText)/2).."/"..param.maxCount/2;

		-- 点击输入框以外的位置，关闭输入框
		UILegionChangeText.panel:BindButtonClick(UILegionChangeText.CloseKeyBoard);

		editBox = UILegionChangeText.inputText:GetComponent('EditBox');
		editBox.characterLimit = param.maxCount
		editBox.iscenter = true
		editBox.multiline = true
		UILegionChangeText.inputText:BindButtonClick(UILegionChangeText.OpenKeyBoard);
		
        editBox:SetCallBack(UILegionChangeText.OnHeightChange, UILegionChangeText.EditResult);
		UILegionChangeText.inputText:BindInputFiledValueChanged(UILegionChangeText.InputChanged);
	end 

	function UILegionChangeText.OnHeightChange(posY)		
		UILegionChangeText.panel:GetComponent('Transform').localPosition = Vector3.New(oldPos.x, oldPos.y + posY, oldPos.z);
	end

	-- 打开键盘，获取已输入的文字
	function UILegionChangeText.OpenKeyBoard()
        local curText = UILegionChangeText.inputText.inputText;
        editBox:showEditBox(curText);
    end

    -- editbox 点击发送时的回调
    function UILegionChangeText.EditResult(text)
    	local newText = Util.CutSubstring(text, param.maxCount);
    	UILegionChangeText.inputText.inputText = newText;
    	UILegionChangeText.inputText.gameObject:SetActive(true);
    	UILegionChangeText.panel:GetComponent('Transform').localPosition = oldPos;
    end

    -- inputField发生变化时，更新文本框显示
	function UILegionChangeText.InputChanged(text, _inputIndex)
		local newText = Util.CutSubstring(text, param.maxCount);
		UILegionChangeText.inputText.inputText = newText;
		UILegionChangeText.textCount.text = math.ceil(Util.StringByteLength(newText)/2).."/"..param.maxCount/2;
	end

	-- 关闭键盘
    function UILegionChangeText.CloseKeyBoard()
		if NativeManager.GetInstance().isKeyboardOpened then
			NativeManager.GetInstance():CloseEditBox();
			UILegionChangeText.panel:GetComponent('Transform').localPosition = oldPos;
		end
    end

	function UILegionChangeText.Close()
		UILegionChangeText.CloseKeyBoard();
		destroy(this.gameObject);
	end

	-- 点击操作按钮后的回调
	-- 具体点击之后的操作全部由外部传入控制
	function UILegionChangeText.OnButtonClick()
		local textContent = UILegionChangeText.inputText.inputText;
		if textContent == "" then
			ui.showMsg("输入内容不能为空")
			return
		end
		if StrFiltermanger.Instance:IsFileter(textContent) then
			ui.showMsg("输入含有非法字符")
			return
		end
		if param.callback then
			param.callback(textContent);
		end
		UILegionChangeText.Close();
	end

	return UILegionChangeText;
end

ui.ShowLegionChangeText = function (titleText, descText, maxCount, initText, callback)
	local param = { titleText = titleText, descText = descText, maxCount = maxCount, initText = initText, callback = callback};
	PanelManager:CreateConstPanel('UILegionChangeText',UIExtendType.NONE, param);
end