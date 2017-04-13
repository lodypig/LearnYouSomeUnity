ui.setNodeHeight = function(go, height)
	local rt = go:GetComponent("RectTransform");
	local size = rt.sizeDelta;
	size.y = height;
	rt.sizeDelta = size;
end

ui.setNodeWidth = function(go, width)
	local rt = go:GetComponent("RectTransform");
	local size = rt.sizeDelta;
	size.x = width;
	rt.sizeDelta = size;
end

--根据点击的位置设置悬浮框的位置
--panel:点击的界面LuaBehavior
--go: 点击到的具体控件
--floatType：0物品，1装备
ui.FixFloatPosition = function(panel,go,floatType)
	--调整悬浮的位置在点击格子的右上角
	local rect = go:GetComponent("RectTransform");
	local panelRect = nil;
	if floatType == 1 then			
		panelRect = UIManager.GetInstance():FindUI("EquipFloat"):GO("content"):GetComponent("RectTransform");
	else
		panelRect = UIManager.GetInstance():FindUI("ItemFloat"):GO("panel"):GetComponent("RectTransform");
	end

	--设置悬浮框相对于点击的位置，边界处理由悬浮框自己做
	local clickPos = go:GetComponent("UIWrapper").pointer_position;
	local UICamera = GameObject.Find("UI Camera"):GetComponent("Camera")
	local w_clickPos = UICamera:ScreenToWorldPoint(clickPos)
	local r_offset = panel.transform:InverseTransformPoint(w_clickPos)
	--local canvasSize = panel:GetComponent("RectTransform").sizeDelta;
	local posX = r_offset.x;-- + canvasSize.x/2;
	local posY = r_offset.y;-- + canvasSize.y/2;
	panelRect.anchoredPosition = Vector2.New(posX ,posY);
end

ui.WorldToScreenPoint = function (world)
	local UICamera = GameObject.Find("UI Camera"):GetComponent("Camera")
	return UICamera:WorldToScreenPoint(world)
end

ui.ScreenToWorldPoint = function (screen)
	local UICamera = GameObject.Find("UI Camera"):GetComponent("Camera")
	return UICamera:ScreenToWorldPoint(screen)
end

local longPressed = false;
local getChangeNum = function(time)
	if time < 2 then
		return 1;
	elseif time < 5 then
		return 2;
	elseif time < 8 then
		return 10;
	else
		return 50;
	end
end

function BindNumberChange(wrapper, minValue, maxValue, onValueChange, onMin, onMax)
	local textWrapper = wrapper:GO('Text');

	--减少数字
	local minusNum = function(num)
		local value = tonumber(textWrapper.text);
		if value > minValue then
			textWrapper.text = math.max(value - num, minValue);
			if onValueChange ~= nil then
				onValueChange();
			end
		else
			if onMin ~= nil then
				onMin();
			end
		end
	end

	wrapper:GO('-'):BindButtonClick(function ( )
		if longPressed then
			longPressed = false;
		else
			minusNum(1);
		end
	end)

	wrapper:GO('-'):BindButtonLongPressed(function (time)
		longPressed = true;
		local num = getChangeNum(time);
		minusNum(num);
	end)

	--增加数字
	local addNum = function (num)
		local value = tonumber(textWrapper.text);
		if value < maxValue then
			textWrapper.text = math.min(value + num, maxValue);
			if onValueChange ~= nil then
				onValueChange();
			end
		else
			if onMax ~= nil then
				onMax();
			end
		end
	end

	wrapper:GO('+'):BindButtonClick(function ( )
		if longPressed then
			longPressed = false;
		else
			addNum(1);
		end
	end)

	wrapper:GO('+'):BindButtonLongPressed(function (time)
		longPressed = true;
		local num = getChangeNum(time);
		addNum(num);
	end)

	--数字键盘输入
	wrapper:GO('bg'):BindButtonClick(function ( )
		local param = {};
		param.textWrapper = textWrapper;
		param.min = minValue;
		param.max = maxValue;
		param.callback = onValueChange;
		PanelManager:CreateConstPanel('UIKeyBoard',UIExtendType.NONE,param);
	end)
end

function ui.SetFloatButton(buttonGroup, param)
	if buttonGroup == nil or param == nil then
		return;
	end

	buttonGroup:Show();
	ui.SetFloatButtonGroup(buttonGroup:GO('Left'), param.Left);
	ui.SetFloatButtonGroup(buttonGroup:GO('Right'), param.Right);
end

function ui.SetFloatButtonGroup(buttonGroup, list)
	if list and #list > 0 then
		buttonGroup.gameObject:SetActive(true);
		local max = buttonGroup.transform.childCount;
		--隐藏多余按钮
		for i = 1, max do
			buttonGroup:GO("btn"..i):Hide();
		end
		--设置按钮内容
		if #list == 1 then
			buttonGroup:GO("btn1.text").text = list[1].name;
			buttonGroup:GO("btn1.arrow").gameObject:SetActive(false);
			buttonGroup:GO("btn1"):BindButtonClick(list[1].fun);
			buttonGroup:GO("btn1"):Show();
		else
			local function setState()
				buttonGroup:GO("btn1.arrow").transform.localEulerAngles = Vector3.New(0, 0, list.expand and 0 or 180);
				for i=1, #list do
					buttonGroup:GO("btn"..i+1).gameObject:SetActive(list.expand);
				end
			end
			list.expand = false;
			buttonGroup:GO("btn1.text").text = "更  多";
			buttonGroup:GO("btn1.arrow").gameObject:SetActive(true);
			buttonGroup:GO("btn1"):Show();
			buttonGroup:GO("btn1"):BindButtonClick(function ()
				list.expand = not list.expand;
				setState();
			end);

			for i=1, #list do
				buttonGroup:GO("btn"..(i+1)..".text").text = list[i].name;
				buttonGroup:GO("btn"..i+1):BindButtonClick(list[i].fun);
			end
		end
	else
		buttonGroup.gameObject:SetActive(false);
	end
end