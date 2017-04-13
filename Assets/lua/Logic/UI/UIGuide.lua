function UIGuideView(param)
	local UIGuide = {};
	local this = nil;
	local text = "";
	local guideMask = nil;
	local styleCircle = nil;
	local styleRect = nil;

	local targetPath = nil;
	local realScreenWidth;
	local realScreenHeight;

	function UIGuide.Start( )
		this = UIGuide.this;
		realScreenWidth = this:GetComponent("RectTransform").sizeDelta.x;
		realScreenHeight = this:GetComponent("RectTransform").sizeDelta.y;
		this:GO('Guide').gameObject:SetActive(false);
		this:GO('ClickMask').gameObject:SetActive(false);

		guideMask = this:GO('Guide.Mask'):GetComponent("GuideMask");
		guideMask:BindTouchDown(UIGuide.OnTouchDown);
		guideMask:BindTouchUp(UIGuide.OnTouchUp);

		styleCircle = this:GO('Guide.Center.StyleCircle');
		styleCircle:GO('BlackBg.Right'):GetComponent("RectTransform").sizeDelta = Vector2.New(realScreenWidth, 0);
		styleCircle:GO('BlackBg.Left'):GetComponent("RectTransform").sizeDelta = Vector2.New(realScreenWidth, 0);
		styleCircle:GO('BlackBg.Top'):GetComponent("RectTransform").sizeDelta = Vector2.New(realScreenWidth*2, realScreenHeight);
		styleCircle:GO('BlackBg.Bottom'):GetComponent("RectTransform").sizeDelta = Vector2.New(realScreenWidth*2, realScreenHeight);
		styleRect = this:GO('Guide.Center.StyleRect');
		styleRect:GO('BlackBg.Right'):GetComponent("RectTransform").sizeDelta = Vector2.New(realScreenWidth, 0);
		styleRect:GO('BlackBg.Left'):GetComponent("RectTransform").sizeDelta = Vector2.New(realScreenWidth, 0);
		styleRect:GO('BlackBg.Top'):GetComponent("RectTransform").sizeDelta = Vector2.New(realScreenWidth*2, realScreenHeight);
		styleRect:GO('BlackBg.Bottom'):GetComponent("RectTransform").sizeDelta = Vector2.New(realScreenWidth*2, realScreenHeight);

		this:Delay(0.2,function ()
			this:GO('Guide.Center.StyleCircle'):PlayUIEffectForever(this.gameObject, "xinshouzhiying");
			this:GO('Guide.Center.StyleRect.TopLeft'):PlayUIEffectForever(this.gameObject, "xinshouzhiying_fang");
			this:GO('Guide.Center.StyleRect.TopRight'):PlayUIEffectForever(this.gameObject, "xinshouzhiying_fang");
			this:GO('Guide.Center.StyleRect.BottomLeft'):PlayUIEffectForever(this.gameObject, "xinshouzhiying_fang");
			this:GO('Guide.Center.StyleRect.BottomRight'):PlayUIEffectForever(this.gameObject, "xinshouzhiying_fang");
		end)
		
	end

	function UIGuide.OnTouchDown(touchInTarget)
		if touchInTarget then
			UIGuide.isTouchDown = true;
			local finishGuide = false;

			--特殊情况(移动摇杆时按下鼠标直接完成引导)
			if string.find(targetPath, "Joystick") then
				finishGuide = true
			end

			if finishGuide then
				UIGuide.isTouchDown = false;
				this:GO('Guide').gameObject:SetActive(false);
				GuideManager.run();
			end
		end
	end

	function UIGuide.OnTouchUp(touchInTarget)
		--完成引导
		if UIGuide.isTouchDown and touchInTarget then
			UIGuide.isTouchDown = false;
			this:GO('Guide').gameObject:SetActive(false);
			GuideManager.run();
		end
	end

	function UIGuide.Show(target, text, style, showBlackBg, path)
		this:GO('Guide').gameObject:SetActive(true);
		targetPath = path;

		local targetRT = target:GetComponent("RectTransform");
		local targetCenter = UIGuide.getTargetCenter(targetRT)
		local targetSize = targetRT.sizeDelta;

		local screenPos = ui.WorldToScreenPoint(targetCenter);
		local localPos = this:GO('Guide').transform:InverseTransformPoint(targetCenter);
		localPos.z = 0;

		if guideMask ~= nil then
			guideMask.target = targetRT;
		end

		--根据目标中心调整位置
		this:GO('Guide.Center').transform.localPosition = localPos;

		--文字内容
		local textComp = this:GO('Guide.Content.Text'):GetComponent("Text");
		textComp.text = text;
		local textHeight = textComp.preferredHeight;
		local textWidth = textComp.preferredWidth;
		local textSize = Vector2.New(textWidth + 50, textHeight + 50);
		this:GO('Guide.Content'):GetComponent("RectTransform").sizeDelta = textSize;

		--计算文字和箭头在屏幕位置
		local isLeft = screenPos.x > Screen.width * 0.5;
		local arrowPos = Vector3.New(localPos.x, localPos.y, localPos.z);
		local textPos = Vector3.New(localPos.x, localPos.y, localPos.z);
		local arrowSize = this:GO('Guide.Arrow'):GetComponent("RectTransform").sizeDelta;
		if isLeft then
			arrowPos.x = arrowPos.x - targetSize.x * 0.5 - arrowSize.x * 0.5;
			textPos.x = arrowPos.x - arrowSize.x * 0.5 - textSize.x * 0.5;
		else
			arrowPos.x = arrowPos.x + targetSize.x * 0.5 + arrowSize.x * 0.5;
			textPos.x = arrowPos.x + arrowSize.x * 0.5 + textSize.x * 0.5;
		end
		this:GO('Guide.Arrow').transform.localPosition = arrowPos;
		this:GO('Guide.Arrow').transform.localEulerAngles = Vector3.New(0, 0, isLeft and 0 or -180);
		this:GO('Guide.Content').transform.localPosition = textPos;

		UIGuide.setStyle(style or "circle", showBlackBg or "showMask", targetSize);
	end

	function UIGuide.setStyle(style, showBlackBg, targetSize)
		styleCircle.gameObject:SetActive(style == "circle");
		styleRect.gameObject:SetActive(style == "rect");
		this:GO('Guide.Arrow').gameObject:SetActive(style == "rect")

		if style == "circle" then
			styleCircle:GO('BlackBg').gameObject:SetActive(showBlackBg == "showMask");
		elseif style == "rect" then
			styleRect:GetComponent("RectTransform").sizeDelta = targetSize;
			styleRect:GO('BlackBg'):GetComponent("RectTransform").sizeDelta = targetSize;
			styleRect:GO('BlackBg').gameObject:SetActive(showBlackBg == "showMask");
		end
	end

	--获取目标中心点,转为世界坐标
	function UIGuide.getTargetCenter(target)
		local pos = target.localPosition;
		local pivot = target.pivot;
		local size = target.sizeDelta;
		pos.x = pos.x + (0.5 - pivot.x) * size.x;
		pos.y = pos.y + (0.5 - pivot.y) * size.y;
		return target.parent:TransformPoint(pos);
	end

	function UIGuide.showClickMask()
		this:GO('ClickMask').gameObject:SetActive(true);
	end

	function UIGuide.hideClickMask()
		this:GO('ClickMask').gameObject:SetActive(false);
	end

	function UIGuide.OnDestroy(  )
        
	end

	function UIGuide.closeSelf()
		destroy(this.gameObject);
	end

	client.uiGuide = UIGuide;
	return UIGuide;
end
