function ActItemFloatView(param)
	local ActItemFloat = {};
	local this = nil;
	local icon = nil;
	local bg = nil;
	local type = nil;
	local name = nil;
	local text = nil;

	function ActItemFloat.Start()
		this = ActItemFloat.this;
		
		bg = ActItemFloat.bg;
		icon = ActItemFloat.icon;
		type = ActItemFloat.value;
		text = ActItemFloat.text;
		name = ActItemFloat.name;
		
		local sid = param.sid;
		if tb.ItemTable[sid] then
			bg.sprite = const.QUALITY_BG[tb.ItemTable[sid].quality+1];
		end
		if tb.GemTable[sid] then
			bg.sprite = const.QUALITY_BG[tb.GemTable[sid].quality+1];
		end
		if param.index then
			icon.sprite = tb.ActiveTab[param.index].icon;
			icon:GetComponent("Image"):SetNativeSize();
			type.text = tb.ActiveTab[param.index].type;
			text.text = tb.ActiveTab[param.index].text;
			local sid = tb.ActiveTab[param.index].sid;
			local str = string.format("<color=%s>%s</color>",const.qualityColor[tb.ItemTable[sid].quality + 1], tb.ActiveTab[param.index].name);
			name.text = str;
		elseif param.boss then
			bg.sprite = const.QUALITY_BG[param.data.Quality + 1];
			bg:GetComponent("Image"):SetNativeSize();
			icon.sprite = param.data.Icon;
			icon:GetComponent("Image"):SetNativeSize();
			type.text = param.data.Type;
			text.text = param.data.Describe;
			local str = string.format("<color=%s>%s</color>", const.qualityColor[param.data.Quality + 1], param.data.Name);
			name.text = str;
		else
			if tb.ItemTable[sid] then
				icon.sprite = tb.ItemTable[sid].icon;
				icon:GetComponent("Image"):SetNativeSize();
				type.text = tb.ItemTable[sid].showtype ;
				text.text = tb.ItemTable[sid].use_effect;
				name.text = tb.ItemTable[sid].name;
			end
			if tb.GemTable[sid] then
				icon.sprite = tb.GemTable[sid].icon;
				icon:GetComponent("Image"):SetNativeSize();
				type.text = "宝石";
				local buwei = tb.GemEquipTable[tb.GemTable[sid].gem_type];
				text.text = string.format("3颗相同宝石可以合成一个同类型的高级宝石，可镶嵌在%s上", const.BuWei[buwei]);
				name.text = tb.GemTable[sid].show_name;
			end 
		end
	end

	return ActItemFloat;
end
