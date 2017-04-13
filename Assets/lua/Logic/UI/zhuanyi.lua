--[[
0.63版本去掉金币消耗功能
--]]

function zhuanyiView (param)
	local zhuanyi = {};
	local this = nil;

	local middle = nil;
	local btn = nil;
	local cost = nil;

	local srcEquip;
	local dstEquip;
	local srcEquipTab;
	local dstEquipTab;
	local srcBaseAttrTab;
	local dstBaseAttrTab;
	local leftObj;
	local rightObj;

	local newRightEquip;
	-- 当点击确认之后向服务端发送消息，接受到消息之后，重新设置左右装备的附加属性，隐藏界面中的转移图标，隐藏转移消耗，将按钮文字改为确定
	local signal = false;

	-- 装备的基本属性包括三种，有两种显示方式，分别是"攻击 +数值"和"生命  +数值    防御  +数值"
	local handleText = function (tab)
		local text = "";
		if(tab.phyAttackMin ~= 0) then
			text = text..'攻击  +'..tab.phyAttackMax;
		end
		if(tab.maxHP ~= 0) then
			text = text..'生命  +'..tab.maxHP..'\n';
		end
		if(tab.phyDefense ~= 0) then
			text = text..'防御  +'..tab.phyDefense;
		end
		return text;
	end
	-- 计算右侧装备附加属性 在左侧装备中的品质
	local getAttrQuality = function(sid, attr, value)
		local quality = 4;
		local range;
		while quality >= 1 do
			range = tb.GetTableByKey(tb.AttrQualityTable, {sid, quality})[attr];
			if value >= range[1] then
				return quality;
			end
			quality = quality - 1;
		end
		return quality;
	end

	-- 设置附加属性显示，srcEquip中的属性的品质色为，换算到dstEquip中的品质
	local setAddAttr = function (equipObj,srcEquip,dstEquip)
		local wrapper = equipObj:GetComponent('UIWrapper');
		local tempObj;   
		local addAttr;
		for i = 1,6 do
			tempObj = wrapper:GO("addAttr.attr"..i);
			local tempWrapper = tempObj:GetComponent("UIWrapper");
			local text = tempWrapper:GO('text');
			if (i <= #srcEquip.addAttr)  then
				addAttr = srcEquip.addAttr[i];
				tempWrapper.gameObject:SetActive(true);
				local quality = addAttr[3] + 1; --getAttrQuality(dstEquip.sid,addAttr[1],addAttr[2]) + 1;
				text.text = string.format("<color=%s>%s</color>",const.qualityColor[quality],const.ATTR_NAME[addAttr[1]].."  +"..addAttr[2]); 
			else
				tempWrapper.gameObject:SetActive(false);
			end
		end
	end

	local sendZhuanyi = function ()
		local msg = { cmd = "equip/transfer" , bag_index = srcEquip.pos};
		Send(msg,function(msg)
			this:GO('content._middle.effect'):PlayUIEffect( this.gameObject, "shuxingzhuanyi", 1.3 );  
			this:Delay(1.3,function ()
				local left_equip = client.equip.parseEquip(msg.left_equip);
				local right_equip = client.equip.parseEquip(msg.right_equip);
				setAddAttr(leftObj,right_equip,right_equip);
				setAddAttr(rightObj,left_equip,left_equip);
				newRightEquip = client.equip.parseEquip(msg.right_equip);
				newRightEquip.pos = msg.index;

				middle.gameObject:SetActive(false);
				cost.gameObject:SetActive(false);
				btn:GetComponent('UIWrapper'):GO('text').text = "换   装";
				this:GO('content._leftEquip.addAttr.quanxuan').gameObject:SetActive(false);
				this:GO('content._rightEquip.addAttr.quanxuan').gameObject:SetActive(false);

				signal = true;
				btn.buttonEnable = true;
				ui.showMsg("转移成功");
			end);
		end);
	end

	local init = function ()
		this:GO('content._leftEquip.top.tubiao.frame').sprite = const.QUALITY_BG_Equip[dstEquip.quality + 1];
		this:GO('content._leftEquip.top.tubiao.icon').sprite = dstEquipTab.icon;	
		this:GO('content._leftEquip.top.tubiao.level').text = dstEquipTab.level;			

		this:GO('content._leftEquip.top.title').text = string.format("<color=%s>%s</color>",const.qualityColor[dstEquip.quality + 1],dstEquipTab.show_name);
		this:GO('content._leftEquip.top.level').text = "等级  "..dstEquipTab.level.."级";
		this:GO('content._leftEquip.top.baseAttr').text = handleText(dstBaseAttrTab);
		this:GO('content._leftEquip.top.tubiao.putIcon').gameObject:SetActive(true);

		this:GO('content._rightEquip.top.tubiao.frame').sprite = const.QUALITY_BG_Equip[srcEquip.quality + 1];
		this:GO('content._rightEquip.top.tubiao.icon').sprite = srcEquipTab.icon;
		this:GO('content._rightEquip.top.tubiao.level').text = srcEquipTab.level;			


		this:GO('content._rightEquip.top.title').text = string.format("<color=%s>%s</color>",const.qualityColor[srcEquip.quality + 1],srcEquipTab.show_name);
		this:GO('content._rightEquip.top.level').text = "等级  "..srcEquipTab.level.."级";
		this:GO('content._rightEquip.top.baseAttr').text = handleText(srcBaseAttrTab);
		this:GO('content._rightEquip.top.tubiao.putIcon').gameObject:SetActive(false);
		setAddAttr(leftObj,dstEquip,dstEquip);
		setAddAttr(rightObj,srcEquip,srcEquip);
		cost:GO('value').text = tb.TransferCostTable[srcEquipTab.level];
		cost.gameObject:SetActive(true);
	end

	function zhuanyi.Start()
		this = zhuanyi.this;
		middle = this:GO('content._middle');
		btn = this:GO('content._btn');
		cost = this:GO('content._cost');

		srcEquip = param;
		dstEquip = Bag.getWearEquip(srcEquip.buwei);

		srcEquipTab = tb.EquipTable[srcEquip.sid];
		dstEquipTab = tb.EquipTable[dstEquip.sid];
		srcBaseAttrTab = tb.GetTableByKey(tb.baseAttrTable, {srcEquip.sid, srcEquip.quality});
		dstBaseAttrTab = tb.GetTableByKey(tb.baseAttrTable, {dstEquip.sid, dstEquip.quality});


		leftObj = this:GO('content._leftEquip');	
		rightObj = this:GO('content._rightEquip');
		init();

		btn:GetComponent('UIWrapper'):BindButtonClick(function ()
			if btn.buttonEnable then
				if(signal == false) then
					if tb.TransferCostTable[srcEquipTab.level] > DataCache.role_money then
						ui.showMsg("金币不足");
						return;
					end
					
					btn.buttonEnable = false;				
					sendZhuanyi();
				else
					ui.showMsg("换装成功");
					btn.buttonEnable = false;
					Bag.wear(newRightEquip);
					destroy(this.gameObject);
				end
			end
		end);

		this:GO('blank'):GetComponent('UIWrapper'):BindButtonClick(function ()
			-- if(signal == false ) then  
				--Bag.wear(srcEquip);
				destroy(this.gameObject);
			-- end
		end);
	end
	return zhuanyi;
end
ui.ShowZhuanyi = function (param) 
-- 没有绑定BindLostFocus事件，但是点击界面外时还是会关闭界面
	PanelManager:CreateConstPanel('zhuanyi',UIExtendType.BLACKMASK,param);
end