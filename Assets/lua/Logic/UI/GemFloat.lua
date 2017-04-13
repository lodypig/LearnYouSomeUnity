function GemFloatView(param)
	local GemFloat = {};
	local this = nil;
	local cdc = nil;


	local function putOn()
		GemFloat.Close();
		ui.showGemWorkShopNew(tb.GemEquipTable[tb.GemTable[param.gem.sid].gem_type]);
		-- ui.showGemWorkShop(tb.GemEquipTable[tb.GemTable[param.gem.sid].gem_type]);
	end

	local function upgrade()
		GemFloat.Close();
		ui.showUpgredeGem(nil, param.gem, 1);
	end

	local sellItemCallback = function(reply)
        local money = reply["money"];
        if money ~= nil and money ~= 0 then
            SysInfoLayer.GetInstance():ShowMsg(string.format("出售成功，获得%s金币",money));
        end
	end

	local sellItem = function()
		local item = param.gem;
		if item ~= nil then
			local itemCfg = tb.GemTable[item.sid];
			local name = itemCfg.show_name;
			local str = "";
			str = string.format("确定要以[color:239,213,88,%s]金币价格出售[color:239,213,88,%s]吗？", itemCfg.price * item.count , name);

			ui.showMsgBox(nil, str, function ()
				local msg = { cmd = "equip/sale", index_list = {item.pos}};
		   	 	Send(msg, sellItemCallback);
		   	 	GemFloat.Close()
	   	 	end);
   		end
	end

	function GemFloat.Start()
		this = GemFloat.this;
		this:BindLostFocus(GemFloat.Close);
		
		local table = tb.GemTable[param.gem.sid];

		--bDisplay为false的时候有使用按钮，传入的是index
		if param.bDisplay == false then
			local buttonData = {Left = {{name = "出  售",fun = sellItem}, 
									{name = "镶  嵌",fun = putOn}},
							Right = {{name = "合  成",fun = upgrade}}
						}
			ui.SetFloatButton(this:GO("content.Button"), buttonData)
		else
			this:GO("content.Button"):Hide();			
		end
		
		local slot = CreateSlot(this:GO('content.ndTop.BagItem'));
		slot.setGem(param.gem);
		
		-- 去除slot数量显示
		slot.setAttr(nil);
		
		if param.count == nil then
			this:GO("content.ndTop.itemCount.value").text = client.gem.getCount(param.gem.sid);
		else
			this:GO("content.ndTop.itemCount.value").text = param.count;
		end

		this:GO('content.ndTop._tfName').text = string.format("<color=%s>%s</color>", const.qualityColor[table.quality + 1], table.show_name);
		-- this:GO("content.ndTop.itemLevel.value").text = "1级";
		this:GO("content.ndMiddle._tfAddAttr").text = const.ATTR_NAME[table.add_attr_type].."+"..client.gem.formatAttrValue(param.gem.sid);
		local buwei = tb.GemEquipTable[table.gem_type];
		this:GO('content.ndMiddle.tfTips').text = string.format("3颗相同宝石可以合成一个同类型的高级宝石，可镶嵌在%s上", const.BuWei[buwei]);

		local rt = this:GO('content'):GetComponent("RectTransform");
		rt.anchoredPosition = Vector2.New(10000, 10000)	
	end

	function GemFloat.FirstUpdate( )
		if param.pos == nil then
			local rt = this:GO('content'):GetComponent("RectTransform");
			rt.pivot = Vector2.New(0.5, 0.5);
			rt.anchoredPosition = Vector2.New(0,0)
		else
			ItemFloat.fixPos();
		end
	end

		--根据点击的坐标
	function GemFloat.fixPos()
		local clickPos = param.pos;
		local UICamera = GameObject.Find("UI Camera"):GetComponent("Camera")
		local w_clickPos = UICamera:ScreenToWorldPoint(clickPos)
		local r_offset = this.transform:InverseTransformPoint(w_clickPos)

		--边界调整
		local canvasSize = this:GetComponent("RectTransform").sizeDelta;
		local panelRect = this:GO("content"):GetComponent("RectTransform");
		local posX = r_offset.x;
		local posY = r_offset.y;

		if posX + panelRect.sizeDelta.x > canvasSize.x/2 then
			posX = canvasSize.x/2 - panelRect.sizeDelta.x;
		end

		if posY + panelRect.sizeDelta.y > canvasSize.y/2 then
			posY = canvasSize.y/2 - panelRect.sizeDelta.y;
		end
		panelRect.anchoredPosition = Vector2.New(posX,posY);
	end

	function GemFloat.Close()
		destroy(this.gameObject)
		GemFloat.this = nil;
	end	

	return GemFloat;
end



function ui.ShowGemFloat(gem, bDisplay , count)
	local param = { bDisplay = bDisplay, gem = gem , count = count};
    PanelManager:CreateConstPanel('GemFloat',UIExtendType.BLACKCANCELMASK, param);
end

function ui.ShowFullGemFloat(gem, bDisplay , count)
	local param = { bDisplay = bDisplay, gem = gem , count = count};
    PanelManager:CreateFullScreenPanel('GemFloat',UIExtendType.BLACKCANCELMASK, function() end, param);
end