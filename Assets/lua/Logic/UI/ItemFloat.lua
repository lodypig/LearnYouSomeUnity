--物品item_type的翻译
--[[  ""生命药水": 1,
  "传送物品": 2,
  "强化材料": 3,
  "数值":4,
  "悬赏令":5,
  "BOSS宝箱": 6,
  "功能道具": 7,
  "装备碎片": 8,
  "兑换代币": 9,
  "藏宝钥匙": 10,]]

function ItemFloatView(param)
	local ItemFloat = {};

	local this = nil;
	local cdc = nil;
	local Icon1 = nil;
	local Icon2 = nil;
	
	local function useItem()
		local item = Bag.GetAllItem()[param.index];
		if nil == item then 
			--print("数据错误 ItemFloat");
			return;
		end

		local itemInfo = tb.ItemTable[item.sid];
		if itemInfo.item_type == 31 then
			ItemFloat.Close()
			ui.showWorkShop(1);
		elseif itemInfo.item_type == 32 then
			ItemFloat.Close()
			ui.showHorse()
		else
			Bag.useItem(item, false, ItemFloat.closeSelf);
		end
	end

	local sellItemCallback = function(reply)
        local money = reply["money"];
        if money ~= nil and money ~= 0 then
            SysInfoLayer.GetInstance():ShowMsg(string.format("出售成功，获得%s金币",money));
        end
	end

	local sellItem = function()
		local item = Bag.GetAllItem()[param.index];
		if item ~= nil then
			local itemCfg = tb.ItemTable[item.sid];
			local name = itemCfg.show_name;
			local str = "";
			str = string.format("确定要以[color:239,213,88,%s]金币价格出售[color:239,213,88,%s]吗？", itemCfg.price * item.count , name);

			ui.showMsgBox(nil, str, function ()
				local msg = { cmd = "equip/sale", index_list = {item.pos}};
		   	 	Send(msg, sellItemCallback);
		   	 	ItemFloat.Close()
	   	 	end);
   		end
	end

	local function tradeItem(  )
		local item = Bag.GetAllItem()[param.index];
		ItemFloat.Close()
		ui.shelveItem(item.id)
	end

	local function openItem(  )
		if ui.UIGoldBoxG then
			ui.UIGoldBoxG.SendOpenTreasure(param.treasureIndex);
		end
		ItemFloat.Close();
	end

    --藏宝钥匙合成
    local function cbtYaoshiHeCheng()
        local item = Bag.GetAllItem()[param.index];
	    local msg = {cmd = "merge_cbt_key", sid = item.sid, index = item.pos};
        Send(msg, function(msg) 
                local rType = msg["type"];
                if rType ~= "ok" then
                    ui.showMsg("钥匙碎片不足");
                    ItemFloat.closeSelf();
                else
                    --只能这么判断是否钥匙碎片被消耗完了，如果以后不是消耗一个碎片，就得改这个 DT
                    if item.count == 1 then
                        ItemFloat.closeSelf();
                    end
                    local targetTab = msg["target"];
                    for i = 1, #targetTab do
                        local tem = tb.ItemTable[targetTab[i][1]];
                        local str = "获得"..client.tools.formatColor(tem.name, const.qualityColor[tem.quality+1]);
                        ui.showMsg(str);
                    end
                end
            end);
	end

	function ItemFloat.Start()
		this = ItemFloat.this;
		this:BindLostFocus(ItemFloat.closeSelf);
		local itemInfo = {};
		--bDisplay为false的时候有使用按钮，传入的是index

		local slot = CreateSlot(this:GO('content.ndTop.BagItem'));
		slot.reset();
		if param.bDisplay == false then
			--cdc = createCDC(this:GO("panel.commonFlt"));
			if param.index ~= nil then
				local sid = Bag.GetAllItem()[param.index].sid
				itemInfo = tb.ItemTable[sid];

				local buttonData = {Left = {}, Right = {}};
				if itemInfo.item_type == 10 then
					Enqueue(buttonData.Right, {name = "合  成",fun = cbtYaoshiHeCheng});
				end

				if itemInfo.could_use then
					Enqueue(buttonData.Right, {name = "使  用",fun = useItem});
				end

				if itemInfo.could_sell then
					Enqueue(buttonData.Left, {name = "出  售",fun = sellItem});
				end

				if Bag.ItemCanTrade(sid) then
					Enqueue(buttonData.Left, {--[[name = "上  架",fun = tradeItem--NSY-4740 屏蔽]]});
				end

				ui.SetFloatButton(this:GO("content.Button"), buttonData);

				slot.setItem(param.base);
				slot.setAttr(param.base.count);
			else
				itemInfo = tb.ItemTable[param.sid];
				if itemInfo.item_type == 11 then	
					local buttonData = {Left = {}, Right = {}};		
					Enqueue(buttonData.Right, {name = "开  启",fun = openItem});
					ui.SetFloatButton(this:GO("content.Button"), buttonData);
				end					
				slot.setItemFromSid(param.sid);				
			end
		else
			this:GO("content.Button"):Hide();
			itemInfo = tb.ItemTable[param.sid];
			slot.setItemFromSid(param.sid);

			if param.base ~= nil then 
				slot.setAttr(param.base.count);
			end
		end

		-- 去除悬浮图标右下角数量显示
		slot.setAttr(nil)
		-- this:GO("content.ndTop.itemLevel.value").text = client.tools.formatColor(itemInfo.level.."级", const.color.red, DataCache.myInfo.level, itemInfo.level);
		local count;
		if param.base ~= nil then
			this:GO("content.ndTop.itemCount.value").text = param.base.count
		else
			this:GO("content.ndTop.itemCount"):Hide();
		end

		this:GO('content.ndTop.itemname').text = client.tools.formatColor(itemInfo.show_name, const.qualityColor[itemInfo.quality + 1]);
		this:GO('content.ndTop.useeffect').text = itemInfo.use_effect;		

		
		--初始时先把界面移出屏幕外，防止界面在设置坐标时突然闪一下
		local rt = this:GO('content'):GetComponent("RectTransform");
		rt.anchoredPosition = Vector2.New(10000, 10000)	
	end

	function ItemFloat.FirstUpdate( )
		if param.pos == nil then
			local rt = this:GO('content'):GetComponent("RectTransform");
			rt.pivot = Vector2.New(0.5, 0.5);
			rt.anchoredPosition = Vector2.New(0,0)
		else
			ItemFloat.fixPos();
		end
	end

	--根据点击的坐标
	function ItemFloat.fixPos()
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
		
		if posY - panelRect.sizeDelta.y < 0 then
			posY = 0;
		end

		panelRect.anchoredPosition = Vector2.New(posX,posY);
	end

	function ItemFloat.ShowMsg()
		ui.showMsg("功能暂未开放")
	end

	function ItemFloat.Close()
		ItemFloat.closeSelf()
	end	

	function ItemFloat.closeSelf()
		destroy(this.gameObject)
		ItemFloat.this = nil;
	end

	return ItemFloat;
end