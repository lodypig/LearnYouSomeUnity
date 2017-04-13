

createCDC = function(wrapper, disableSetSibling)
	local controller = {};
	controller.buttonNumber = 0;
	controller.wrapper = wrapper;
	--是否禁用按钮顺序调整（默认为不禁止）
	controller.disableSetSibling = disableSetSibling;

	local buttonGroup = controller.wrapper:GO("ButtonGroup");
	if buttonGroup ~= nil then
		controller.maxBtnNum = buttonGroup.transform.childCount;
		controller.current = buttonGroup:GO("btn1");
	end
	
	-- 	设置标题所用资源路径
	controller.SetTitle = function(path)
		controller.wrapper:GO("TitleName").sprite = path;
		controller.wrapper:GO("TitleName"):GetComponent("Image"):SetNativeSize();
	end

	controller.HideButtion = function()
		controller.wrapper:GO("ButtonGroup").gameObject:SetActive(false);
	end

	--	设置面板按钮的个数
	controller.SetButtonNumber = function(number)
		controller.buttonNumber = number;

		for i = 1,controller.maxBtnNum do
			controller.wrapper:GO("ButtonGroup.btn"..i).gameObject:SetActive(i <= number);
			controller.SetRedPoint(i, false);
		end
	end

	--设置第index个按钮的文本
	controller.SetButtonText = function(index,name)
		if controller.maxBtnNum < index then
			return
		end

		local btnName = "btn"..index;
		controller.wrapper:GO("ButtonGroup.".. btnName..".text").text = name;
	end

	--更新按钮红点状态 
	controller.SetRedPoint = function(index, state, num)
		if controller.maxBtnNum < index then
			return
		end

		local flagWrapper = controller.wrapper:GO("ButtonGroup.btn"..index..".flag");
		if flagWrapper == nil then
			return
		end
		flagWrapper.gameObject:SetActive(state)
		
		local numWarrper = controller.wrapper:GO("ButtonGroup.btn"..index..".flag.text");
		if numWarrper == nil then
			return
		end
		numWarrper.gameObject:SetActive(num ~= nil);
		if num ~= nil then
			if num > 99 then
				num = 99;
			end
			numWarrper.text = num;
		end

	end

	-- index = 0 时给关闭按钮绑定函数，1~4为对应按钮
	controller.bindButtonClick = function(index,func,...)
		local arg = {...}
		local checkFunc = nil
		if arg ~= nil then
			checkFunc = arg[1];
		end
		if index == 0 then
			controller.wrapper:GO("Close").isClickSoundEnable = true;
			controller.wrapper:GO("Close").clickSoundOverride = "close_ui";
			controller.wrapper:GO("Close"):BindButtonClick(func);
		elseif index>=1 and index<=controller.maxBtnNum then
			local btnName = "btn"..index;
			local wrapper = controller.wrapper:GO("ButtonGroup.".. btnName);	
			wrapper:BindButtonClick(function () 
				if checkFunc == nil or checkFunc() then
					controller.swapState(wrapper.gameObject,controller.current.gameObject);
					controller.current = wrapper;
					func();
				end
			end);
		end
	end

	--激活按钮
	controller.activeButton = function( index )
		local btnName = "btn"..index;
		local wrapper = controller.wrapper:GO("ButtonGroup.".. btnName);
		if wrapper then
			wrapper:FireButtonClick();
		end
	end

	-- 交换两个按钮的点击状态
	controller.swapState = function (go1 , go2)
		if go1 == go2 then
            return;
        end
        local uw1 = go1:GetComponent("UIWrapper");
        local uw2 = go2:GetComponent("UIWrapper");
        --交换形状信息
        local rt1 = go1:GetComponent("RectTransform");
        local rt2 = go2:GetComponent("RectTransform");

        if not controller.disableSetSibling then
        	rt1:SetAsLastSibling();
    	end
        local tempRect = nil;
        tempRect = rt1.sizeDelta;
        rt1.sizeDelta = rt2.sizeDelta;
        rt2.sizeDelta = tempRect;

        --交换图片
        local tempSprite = uw1.Sprite;
        local tempColor = uw1.imageColor;
        uw1.Sprite = uw2.Sprite;
        uw1.imageColor = uw2.imageColor;
        uw2.Sprite = tempSprite;
        uw2.imageColor = tempColor;
        
        --交换文字颜色,位置
        tempColor = uw1:GO("text").textColor;
        uw1:GO("text").textColor = uw2:GO("text").textColor;
        uw2:GO("text").textColor = tempColor;
        local rect1 = uw1:GO("text").gameObject:GetComponent("RectTransform");
        local rect2 = uw2:GO("text").gameObject:GetComponent("RectTransform");
        local tempPos = rect1.anchoredPosition;
        rect1.anchoredPosition = rect2.anchoredPosition;
        rect2.anchoredPosition = tempPos;
	end

	return controller;

end



createScrollviewCDC = function(wrapper)
	local controller = {};
	controller.buttonNumber = 0;
	controller.wrapper = wrapper;

	local buttonGroup = controller.wrapper:GO("ButtonList.Viewport.Content");
	if buttonGroup ~= nil then
		controller.maxBtnNum = buttonGroup.transform.childCount;
		controller.current = buttonGroup:GO("btn1");
	end
	
	-- 	设置标题所用资源路径
	controller.SetTitle = function(path)
		controller.wrapper:GO("TitleName").sprite = path;
		controller.wrapper:GO("TitleName"):GetComponent("Image"):SetNativeSize();
	end

	controller.HideButtion = function()
		controller.wrapper:GO("ButtonList.Viewport.Content").gameObject:SetActive(false);
	end


	controller.GetItem = function(index)
		if controller.maxBtnNum < index then
			return nil;
		end
		local btnName = "btn" .. index;
		return controller.wrapper:GO("ButtonList.Viewport.Content.".. btnName);
	end

	--	设置面板按钮的个数
	controller.SetButtonNumber = function(number, callback, finish_callback)
		controller.buttonNumber = number;
		local buttonGroup = controller.wrapper:GO("ButtonList.Viewport.Content");

		if controller.buttonNumber > controller.maxBtnNum then

			if callback ~= nil then
				if controller.maxBtnNum > 0 then
					for i = 1, controller.maxBtnNum do
						callback(i, controller.GetItem(i));
					end
				end
			end

			local count = controller.buttonNumber - controller.maxBtnNum;
			for i = 1, count do
				local newItem = newObject(controller.current.gameObject);
				newItem.name = "btn" .. i + controller.maxBtnNum;
				newItem.transform:SetParent(buttonGroup.gameObject.transform);
				newItem.transform.localPosition = controller.current.gameObject.transform.localPosition;
				newItem.transform.localEulerAngles = controller.current.gameObject.transform.localEulerAngles;
				newItem.transform.localScale = controller.current.gameObject.transform.localScale;
				if callback ~= nil then
					callback(controller.maxBtnNum + i, newItem);
				end
			end
			controller.maxBtnNum = controller.buttonNumber;
		end

		for i = 1, controller.maxBtnNum do
			local go = buttonGroup:GO("btn" .. i);
			if go ~= nil then
				go.gameObject:SetActive(i <= number);
			end
			controller.SetRedPoint(i, false);
		end

		if finish_callback ~= nil then
			finish_callback();
		end
	end

	--设置第index个按钮的文本
	controller.SetButtonText = function(index, name)
		local btnName = "btn"..index;
		if controller.wrapper ~= nil then
			local wrapper = controller.wrapper:GO("ButtonList.Viewport.Content.".. btnName..".text");
			if wrapper ~= nil then
				wrapper.text = name;
			end
		end
	end


	


	--更新按钮红点状态 
	controller.SetRedPoint = function(index, state, num)
		if controller.maxBtnNum < index then
			return
		end

		local flagWrapper = controller.wrapper:GO("ButtonList.Viewport.Content.btn"..index..".flag");
		if flagWrapper == nil then
			return
		end
		flagWrapper.gameObject:SetActive(state)
		
		local numWarrper = controller.wrapper:GO("ButtonList.Viewport.Content.btn"..index..".flag.text");
		if numWarrper == nil then
			return
		end
		numWarrper.gameObject:SetActive(num ~= nil);
		if num ~= nil then
			if num > 99 then
				num = 99;
			end
			numWarrper.text = num;
		end

	end

	-- index = 0 时给关闭按钮绑定函数，1~4为对应按钮
	controller.bindButtonClick = function(index,func,...)
		local arg = {...}
		local checkFunc = nil
		if arg ~= nil then
			checkFunc = arg[1];
		end
		if index == 0 then
			controller.wrapper:GO("Close").isClickSoundEnable = true;
			controller.wrapper:GO("Close").clickSoundOverride = "close_ui";
			controller.wrapper:GO("Close"):BindButtonClick(func);
		elseif index>=1 and index<=controller.maxBtnNum then
			local btnName = "btn"..index;
			local wrapper = controller.wrapper:GO("ButtonList.Viewport.Content.".. btnName);	
			wrapper:BindButtonClick(function () 
				if checkFunc == nil or checkFunc() then
					func();
					controller.current = wrapper;
				end
			end);
		end
	end

	--激活按钮
	controller.activeButton = function( index )
		local btnName = "btn"..index;
		local wrapper = controller.wrapper:GO("ButtonList.Viewport.Content.".. btnName);
		if wrapper then
			wrapper:FireButtonClick();
		end
	end

	return controller;

end

