function UISaleView ()	
	local UISale = {};
	local this = nil;

	local selected = {};
	local position = {};
	local _white = nil;
	local _green = nil;
	local _blue = nil;
	local _purple = nil;
	local _purpleTip = nil;

	function UISale.Start()
		this = UISale.this;

    	this:GO('Image.title.close'):BindButtonClick(UISale.onCancelClick);
    	this:GO('Image.btnOk'):BindButtonClick(UISale.onOkClick);
    	_white = this:GO('Image._white');
    	_green = this:GO('Image._green');
		_blue = this:GO('Image._blue');
		_purple = this:GO('Image._purple');
		_purpleTip = this:GO('Image._purpleTip');

		_white.ToggleValue = client.quickSaleCtrl.SelectedList[1];
		_green.ToggleValue = client.quickSaleCtrl.SelectedList[2];
		_blue.ToggleValue = client.quickSaleCtrl.SelectedList[3];
		_purple.ToggleValue = client.quickSaleCtrl.SelectedList[4];
		EventManager.bind(this.gameObject, Event.ON_LEVEL_UP, UISale.InitButton);
		UISale.InitButton();

		_white:BindButtonClick(function() 
			if _white.ToggleValue then
				_white.sprite = "dk_xuanzong"
			else
				_white.sprite = "dk_liebiao_gongfang"
			end
		end);

		_green:BindButtonClick(function() 
			if _green.ToggleValue then
				_green.sprite = "dk_xuanzong"
			else
				_green.sprite = "dk_liebiao_gongfang"
			end
		end);

		_blue:BindButtonClick(function() 
			if _blue.ToggleValue then
				_blue.sprite = "dk_xuanzong"
			else
				_blue.sprite = "dk_liebiao_gongfang"
			end
		end);

		_purple:BindButtonClick(function() 
			if _purple.ToggleValue then
				_purple.sprite = "dk_xuanzong"
			else
				_purple.sprite = "dk_liebiao_gongfang"
			end
		end);

	end

	function UISale.InitButton()
		if _white.ToggleValue then
			_white.sprite = "dk_xuanzong"
		else
			_white.sprite = "dk_liebiao_gongfang"
		end

		if _green.ToggleValue then
			_green.sprite = "dk_xuanzong"
		else
			_green.sprite = "dk_liebiao_gongfang"
		end

		if _blue.ToggleValue then
			_blue.sprite = "dk_xuanzong"
		else
			_blue.sprite = "dk_liebiao_gongfang"
		end

		if _purple.ToggleValue then
			_purple.sprite = "dk_xuanzong"
		else
			_purple.sprite = "dk_liebiao_gongfang"
		end

		if DataCache.myInfo.level < 40 then
			_purple:GO("Label").text = "紫  色";
			_purple.gameObject:SetActive(true);
			_purpleTip.gameObject:SetActive(false);
		else
			_purple:GO("Label").text = "紫  色（40级以下）";
			local havePurple = UISale.havePurpleEquipLess40();
			_purple.gameObject:SetActive(havePurple);
			_purpleTip.gameObject:SetActive(not havePurple);
		end
	end

	function UISale.onCancelClick()
		destroy(this.gameObject);
	end

	function UISale.onOkClick()
		selected[1] = _white.ToggleValue;
		selected[2] = _green.ToggleValue;
		selected[3] = _blue.ToggleValue;
		selected[4] = _purple.ToggleValue;

		client.quickSaleCtrl.SelectedList[1] = _white.ToggleValue;
		client.quickSaleCtrl.SelectedList[2] = _green.ToggleValue;
		client.quickSaleCtrl.SelectedList[3] = _blue.ToggleValue;
		client.quickSaleCtrl.SelectedList[4] = _purple.ToggleValue;

		client.quickSaleCtrl.writeSaleState();

		--selected不为空则继续执行，为空直接跳出
		if not selected[1] and not selected[2] and not selected[3] and not selected[4] then
			ui.showMsg("请选择出售品质");
		else
			UISale.getColorEquip(selected);
		end
	end

	function UISale.havePurpleEquipLess40()
		--是否有紫色装备40级以下的
		local bag = Bag.GetItemList();
		local list = bag.list;
		for k,item in pairs(list) do
			if item and item.type == const.bagType.equip and item.quality == const.quality.purple and item.level < 40 then
				return true;
			end
		end	

		return false;
	end

	function UISale.getColorEquip(selected)
		local bag = Bag.GetItemList();
		--list为bag里面所有的装备物品
		local list = bag.list;
		for k,item in pairs(list) do
			if item and item.type == const.bagType.equip then
				--判断颜色为选中的
				if selected[item.quality + 1] then
					--判断品质不是紫色，或者小于40级的紫色
					if item.quality ~= const.quality.purple or item.level < 40 then
						position[#position + 1] =item.pos;
					end
				end
			end
		end		
		if position and next(position) then
			--发送pos给服务器
			local msg = { cmd = "equip/sale", index_list = position};
       	 	Send(msg,  UISale.onSaleCallback);
        else
			ui.showMsg("没有可以一键出售的装备");
			destroy(this.gameObject);
		end	
	end
	--回调接受服务端返回结果
	function UISale.onSaleCallback(reply)
        local count = table.getn(position);
        local money = reply["money"];
        if money ~= nil and money ~= 0 then
            ui.showMsg(string.format("成功出售%s件装备，获得%s金币",count,money));
        end
        destroy(this.gameObject);
	end

	return UISale;
end