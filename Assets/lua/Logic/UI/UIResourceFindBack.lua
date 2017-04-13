function UIResourceFindBackView (param)	
	local UIResourceFindBack = {};
	local this = nil;
	local btn_cancel = nil;
	local btn_confirm = nil;
	local num = nil;
	local cost = nil;
	local title = nil;
	local text = nil;
	local image = nil;
	local close = nil;
	function UIResourceFindBack.Start()
		this = UIResourceFindBack.this;
		btn_cancel = this:GO('Panel.btn1');
		btn_confirm = this:GO('Panel.btn2');
		btn_cancel:BindButtonClick(UIResourceFindBack.Cancel);
		btn_confirm:BindButtonClick(UIResourceFindBack.Confirm);
		num = this:GO('Panel.center.one.Text');
		cost = this:GO('Panel.center.two.value');
		image = this:GO('Panel.center.two.image');
		title = this:GO('Panel.center.sfTitle');
		text = this:GO('Panel.center.text');
		close = this:GO('Panel.top.close');
		local diamond = tb.FindBackTab[param.item.id].cost_diamond[client.activity.five_clock_level - param.item.level + 1][2];
		local money = tb.FindBackTab[param.item.id].cost_money[client.activity.five_clock_level - param.item.level + 1][2];
		local max = param.item.canFind - client.activity.resource_Info_doneFind[const.SidToIndex[param.item.id]];
		local str = string.format("%s（可找回<color=#8ddd10>%s</color>次）", param.item.name, max)
		title.text = str;
		num.text = max;
		if param.diamond then
			image:GetComponent("UIWrapper").sprite = "tb_zuanshi";
			cost.text = max * diamond;
		else
			image:GetComponent("UIWrapper").sprite = "tb_jinbi";
			cost.text = max * money;
		end
		if param.diamond then
			text.text = "单价"..diamond.."钻石";
			BindNumberChange(this:GO('Panel.center.one'), 1, max, function()
				cost.text = diamond * tonumber(num.text);
			end);

		else
			text.text = "单价"..money.."金币";
			BindNumberChange(this:GO('Panel.center.one'), 1, max, function ()
				cost.text = money * tonumber(num.text);
			end);
		end
		close:BindButtonClick(UIResourceFindBack.Cancel);
	end

	function UIResourceFindBack.Cancel()
		destroy(this.gameObject);
	end

	function UIResourceFindBack.Confirm()
		if param.diamond then
			if DataCache.role_diamond >= tonumber(cost.text) then
				client.activity.ResourceFindBack(param.item.id, tonumber(num.text), 1, client.activity.five_clock_level);
			else
				ui.showMsgBox(nil, "钻石不足，请充值！", ui.showChargePage);
			end
		else
			if DataCache.role_money >= tonumber(cost.text) then
				client.activity.ResourceFindBack(param.item.id, tonumber(num.text), 0, client.activity.five_clock_level);
			else
				ui.showMsg("金币不足");
			end
		end
		destroy(this.gameObject);
	end

	return UIResourceFindBack;
end