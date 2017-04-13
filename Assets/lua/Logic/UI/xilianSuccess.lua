function xilianSuccessView (param)
	local xilianSuccess = {};
	local this = nil;

	local oldAttr = nil;
	local btnOK = nil;
	local btnOK1 = nil;
	local btnCancel = nil;
	local newAttr = nil;
	local index = nil;
	local addAttr;
	local tempAttr;
	local equip;
	local cost;

	local function sendMsg(command,callback)
		local msg = { cmd = command , index = equip.buwei};
		Send(msg,function(msg)
			EventManager.onEvent(Event.ON_EVENT_EQUIP_CHANGE);
			safe_call(callback);
			destroy(this.gameObject);
		end);
	end

	function xilianSuccess.Start ()
		this = xilianSuccess.this;
		oldAttr = this:GO('Image._oldAttr.attr');
		btnOK = this:GO('Image._btnOK');
		btnOK1 = this:GO('Image._btnOK1');
		btnCancel = this:GO('Image._btnCancel');
		newAttr = this:GO('Image._newAttr.attr');
		cost = this:GO('Image.cost');
		cost:GO('text').text = const.PurifyRevertDiamond;
		equip = param.equip;
		index = param.index;
		-- 装备的tempAttr是{selectedIndex,attr}结构，selectedIndex表示选择的洗炼属性索引，attr表示服务器抽中的一条附加属性
		tempAttr = equip.tempAttr[2];
		addAttr = equip.addAttr[index];
		if next(tempAttr) == nil then
			oldAttr.text = "空属性";
			-- btnOK.gameObject:SetActive(true);
			-- btnCancel.gameObject:SetActive(true);
			-- btnOK1.gameObject:SetActive(true);
			-- cost:Hide();

			-- btnOK1:GetComponent('UIWrapper'):BindButtonClick(function ()
			-- 	ui.showMsg("成功保存洗炼结果");
			-- 	sendMsg("equip/confirm_purify");
			-- end);
			
			Util.SetGray(btnCancel.gameObject, true);
			btnCancel.buttonEnable = false;
		else
			oldAttr.text = string.format("<color=%s>%s</color>",const.qualityColor[tempAttr[3] + 1],const.ATTR_NAME[tempAttr[1]].."   +"..tempAttr[2]);
			btnCancel.buttonEnable = true;
		end
		btnOK.gameObject:SetActive(true);
		btnCancel.gameObject:SetActive(true);
		-- btnOK1.gameObject:SetActive(false);

		btnOK:GetComponent('UIWrapper'):BindButtonClick(function ()
			ui.showMsg("成功保存洗炼结果");
			sendMsg("equip/confirm_purify");
		end);
		btnCancel:GetComponent('UIWrapper'):BindButtonClick(function ()
			if btnCancel.buttonEnable then
				if (DataCache.role_diamond < const.PurifyRevertDiamond) then
					ui.showCharge();
					return;
				end
				sendMsg("equip/quit_purify",function ()
					ui.showMsg("恢复成功");
				end);
			end
		end);
		newAttr.text = string.format("<color=%s>%s</color>",const.qualityColor[addAttr[3] + 1],const.ATTR_NAME[addAttr[1]].."   +"..addAttr[2]);
	end
	return xilianSuccess;
end

ui.ShowXiLianSuccess = function (param) 
	PanelManager:CreateConstPanel('xilianSuccess',UIExtendType.BLACKMASK,param);
	-- PanelManager:CreatePanel("ui", "xilian", param);
end