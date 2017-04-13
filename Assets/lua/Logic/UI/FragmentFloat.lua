function FragmentFloatView (param)
	local FragmentFloat = {};
	local this = nil;
	local cdc = nil;
	local slot = nil;
	local itemTableInfo = nil;
	local itemName = nil;

	local useEffect = nil;
	local Icon1 = nil;
	local Icon2 = nil;

	--发送合成消息，根据返回信息决定关不关闭悬浮
	local startCombine = function()
		if DataCache.myInfo.level < itemTableInfo.level then
			ui.showMsg(itemTableInfo.level.."级可以使用");
			return;
		end
		if param.base.count < 5 then
			ui.showMsg("碎片数量不足")
			return;
		end

        local msg = {cmd = "fragment_combine", itemSid = param.base.sid} --10001
        Send(msg, function(msgTable)
        	local equipSid = msgTable["equipSid"];
        	if equipSid ~= nil then
        		local equipTableInfo = tb.EquipTable[equipSid];
        		local temp = client.tools.formatColor(equipTableInfo.show_name, const.qualityColor[5]);
        		local str = "获得"..temp;
        		ui.showMsg(str)
	        	if param.base.count < 10 then
	        		FragmentFloat.Close();
	        	else
	        		param.base.count = param.base.count - 5;
	        		slot.setAttr(param.base.count);
	        	end
        	else
        		local reason = msgTable["reason"];
        		if reason == "not_enough_space" then
        			ui.showMsg("背包空间不足")
				elseif reason == "not_enough_fragment" then
					ui.showMsg("碎片数量不足")
				elseif reason == "can_not_find_info" then
					ui.showMsg("碎片信息未找到")
				end
        	end
        end)  
	end

	local function tradeItem(  )
		if param.base ~= nil then
			FragmentFloat.Close()
			ui.shelveItem(param.base.id)
		end
	end

	local sellItemCallback = function(reply)
        local money = reply["money"];
        if money ~= nil and money ~= 0 then
            SysInfoLayer.GetInstance():ShowMsg(string.format("出售成功，获得%s金币",money));
        end
	end

	local sellItem = function()
		local item = param.base;
		if item ~= nil then
			local itemCfg = tb.EquipTable[item.sid];
			local name = itemCfg.show_name;
			local str = "";
			local single_price = _equip_kit.get_equip_price(item, itemCfg);
			str = string.format("确定要以[color:239,213,88,%s]金币价格出售[color:239,213,88,%s]吗？", single_price * item.count , name);

			ui.showMsgBox(nil, str, function ()
				local msg = { cmd = "equip/sale", index_list = {item.pos}};
		   	 	Send(msg, sellItemCallback);
		   	 	FragmentFloat.Close()
	   	 	end);
   		end
	end

	function FragmentFloat.Start ()
		this = FragmentFloat.this;
		
		if param.showButton ~= false then
			local buttonData = {Left = {{name = "出  售",fun = sellItem}, 
										--[[{name = "上  架",fun = tradeItem}--NSY-4740 屏蔽]]},
								Right = {{name = "合  成",fun = startCombine}}
							}
			ui.SetFloatButton(this:GO("content.Button"), buttonData)
		else
			this:GO("content.Button"):Hide();
		end

		itemTableInfo = tb.EquipTable[param.base.sid];

		slot = CreateSlot(this:GO('content.ndTop.BagItem'));
		slot.setEquip(param.base);
		slot.setDisable(DataCache.myInfo.level < itemTableInfo.level)
		-- slot.setAttr(param.base.count);

		itemName = this:GO('content.ndTop._itemName');
		useEffect = this:GO('content.ndTop._useEffect');

		itemName.text = itemTableInfo.show_name;
		local count = 1;
		if param.base.count ~= nil then
			count = param.base.count;
		end
		-- slot.setAttr(count);
		-- 去除slot上数量的显示
		slot.setAttr(nil)

		useEffect.text =  itemTableInfo.describe;
		this:GO("content.ndTop.itemCount.value").text = count;

		local rt = this:GO('content'):GetComponent("RectTransform");
		rt.anchoredPosition = Vector2.New(10000, 10000)
	end

	function FragmentFloat.FirstUpdate( )
		if param.pos == nil then
			local rt = this:GO('content'):GetComponent("RectTransform");
			rt.pivot = Vector2.New(0.5, 0.5);
			rt.anchoredPosition = Vector2.New(0,0)
		else
			ItemFloat.fixPos();
		end
	end

		--根据点击的坐标
	function FragmentFloat.fixPos()
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

	function FragmentFloat.ShowMsg()
		ui.showMsg("功能暂未开放")
	end

	function FragmentFloat.Close()
		destroy(this.gameObject)
	end	

	return FragmentFloat;
end
