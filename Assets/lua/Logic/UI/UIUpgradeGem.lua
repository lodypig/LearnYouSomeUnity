function UIUpgradeGemView (param)
	local UIUpgradeGem = {};
	local this = nil;
	local count = 0;
	local upgradeNumber = 1;
	local maxNumber = 0;
	local leftTableInfo = nil;
	local rightTableInfo = nil;

	local leftSlot = nil;
	local rightSlot = nil;
	local leftCell = nil;
	local rightCell = nil;

	local leftText = nil;
	local rightText = nil;

	local spClose = nil;
	local spCancel = nil;
	local btnUpgrade = nil;
	local btnMax = nil;
	local bForbid = false;


	local function  updateUp()
		local needNumber = upgradeNumber * 3;
		if needNumber <= count then
			leftText.text = client.tools.formatColor("X"..needNumber,"#e4e4e4")			
		else
			bForbid = true;
			leftText.text = client.tools.formatColor("X"..needNumber,const.color.red)
		end
		rightText.text = "X"..upgradeNumber;
	end

	local function init()
		this = UIUpgradeGem.this;
		leftCell = this:GO('content.ndMiddle.left.cell');
		rightCell = this:GO('content.ndMiddle.right.cell');
		leftSlot = CreateSlot(leftCell);
		rightSlot = CreateSlot(rightCell);
		leftText = this:GO('content.ndMiddle.left.text');
		rightText = this:GO('content.ndMiddle.right.text');
		spClose = this:GO('Close');
		spCancel = this:GO('content.BtnCancel');
		btnUpgrade = this:GO('content.BtnOk');
		btnUpgrade = this:GO('content.BtnOk');
		btnMax = this:GO('content.ndMiddle.num.Max');
		leftTableInfo = tb.GemTable[param.gem.sid];
		rightTableInfo = tb.GemTable[leftTableInfo.next_gem];

		count = client.gem.getCount(param.gem.sid);
		maxNumber = math.floor(count/3);
		--两个格子初始化
		leftSlot.setGemBySid(param.gem.sid,count);
		rightSlot.setGemBySid(leftTableInfo.next_gem,"");

		BindNumberChange(this:GO('content.ndMiddle.num'), 1, maxNumber, function ()
			upgradeNumber = tonumber(this:GO('content.ndMiddle.num.Text').text);
			updateUp();
		end);
		-- EventBinder.RegisterEvent(this.gameObject,Event.ON_EVENT_GEM_CHANGE, updateCost);
		-- EventBinder.RegisterEvent(this.gameObject,Event.ON_MONEY_CHANGE, updateCost);
		EventManager.onEvent(Event.ON_BAG_FORBIDEN_CHANGE);
	end

	local function close()		
		EventManager.onEvent(Event.ON_BAG_FORBIDEN_CHANGE);
		EventManager.onEvent(Event.ON_EVENT_GEM_CHANGE);		
		destroy(UIUpgradeGem.this.gameObject);
	end

	-- local function updateMiddle()

	-- 	tfLeftName.text = string.format("<color=%s>%s</color>", const.qualityColor[leftTable.quality + 1], leftTable.show_name);
	-- 	tfRightName.text = string.format("<color=%s>%s</color>", const.qualityColor[rightTable.quality + 1], rightTable.show_name);
	-- 	tfLeftAttr.text = string.format("%s  <color=%s>+%s</color>", const.ATTR_NAME[leftTable.add_attr_type], const.color.gold, client.gem.formatAttrValue(param.gem.sid));
	-- 	tfRightAttr.text = string.format("%s  <color=%s>+%s</color>", const.ATTR_NAME[rightTable.add_attr_type], const.color.gold, client.gem.formatAttrValue(leftTable.next_gem));
	-- 	spCostGem.sprite = leftTable.icon;
	-- end

	local function OnUpgradeSuccess()
		leftCell:PlayUIEffect(this.gameObject, "hechengxi1", 0.5);
		this:Delay(0.5, function() 
			leftSlot.setAttr(count-upgradeNumber*3);
			rightCell:PlayUIEffect(this.gameObject, "hechengjieguo", 1.5);
		end);
		if param.cb then
			param.cb();
		end
		
		this:Delay(2, function() 
			local temp = client.tools.formatColor(rightTableInfo.show_name,
				const.qualityColor[rightTableInfo.quality+1]);
			local str = string.format("合成成功，获得%sx%s",temp,upgradeNumber);
			ui.showMsg(str);
			close();			
		end);
	end

	local function OnBtnMax()
		upgradeNumber = math.max(maxNumber, 1);
		this:GO('content.ndMiddle.num.Text').text = upgradeNumber;
		updateUp();
	end

	local function OnBtnClick()
		if bForbid then
			close();
			ui.showMsg("宝石数量不足，无法合成");
		else
			client.gem.upgradeBagGem(OnUpgradeSuccess, param.gem, upgradeNumber*3);
		end
	end

	function UIUpgradeGem.Start()
		init();
		updateUp();
		-- updateMiddle();
		btnMax:BindButtonClick(OnBtnMax);
		btnUpgrade:BindButtonClick(OnBtnClick);
		spCancel:BindButtonClick(close);
		spClose:BindButtonClick(close);
	end
	return UIUpgradeGem;
end

function ui.showUpgredeGem(cb, gem, type, index, buwei)
	local table = tb.GemTable[gem.sid];
	if table.next_gem <= 0 then
		ui.showMsg("宝石已达最高等级");
		return;
	end
	PanelManager:CreateConstPanel('UIUpgradeGem',UIExtendType.BLACKMASK, {cb = cb, gem = gem, type = type, index = index, buwei = buwei});
end
