function GemMenuView (param)
	local GemMenu = {};
	local this = nil;
	local buwei = -1;
	local curGem = nil;
	local bagGemList = nil;
	local itemPrefab = nil;
	local grid = nil;
	local slotList = {};

	--获取升级需要的钻石以及宝石列表
	local GetUpgradeGemCost = function(cost,needLevel)
		local leftValue = cost;
		local gemSidList = {};
		local gemCountList = {};
		for i=1,#bagGemList do
			local count = 0;
			local gem = bagGemList[i];
			local tableInfo = tb.GemTable[gem.sid];
			if leftValue > 0 then
				for j=1,gem.count do
					if leftValue > 0 and tableInfo.level <= needLevel then
						leftValue = leftValue - tableInfo.diamond_value;
						count = count + 1;
					else
						break;
					end
				end
			else
				break;
			end
			table.insert(gemSidList,gem.sid)
			table.insert(gemCountList,count)
		end
		local result = {left = leftValue,sidList = gemSidList, countList = gemCountList};
		return result;
	end

	local FormatEmptyList = function(count)
	    for i = 1,count do
	        local go = newObject(itemPrefab);
	        go:SetActive(true);
	        go.name = 'item'..tostring(i);
	        go.transform:SetParent(grid.transform);
	        go.transform.localScale = Vector3.one;
	        go.transform.localPosition = Vector3.zero;
	        slotList[i] = CreateSlot(grid:GO("item"..i..".cell"));
	        slotList[i].setUp(false);
	    end
    end

 --    local upgradeEquipGemWithNum = function(cb, buwei, gemIndex, num, need_diamond)
	-- 	if DataCache.role_diamond < need_diamond then
	-- 		ui.showCharge();
	-- 		return;
	-- 	end
	-- 	local msg = {cmd = "upgrade_equip_gem", num = num, buwei = buwei, gem_index = gemIndex};
	-- 	Send(msg, cb);
	-- end

    local SetBuyBtn = function(index)
    	--先设置购买的对应显示
    	local item = grid:GO("item"..index);
    	item:GO("text").text = "购买宝石";
    	local slot = slotList[index];
    	local gemSid = client.gem.firstGemList[buwei];
    	slot.setGemBySid(gemSid);
    	local gem = tb.GemTable[gemSid];
		item:BindButtonClick(function() 
			GemMenu.closeSelf();
			ui.showMsgBox(nil, string.format("是否花费%s钻石购买一个%s？", gem.diamond_value,gem.show_name), 
			function()
				--判断钻石是否足够
				local DiamondCount = DataCache.role_diamond;
				if DiamondCount < gem.diamond_value then
					ui.showCharge();
					return;
				else
					local msg = {cmd = "buy_gem" , sid = gemSid};
					Send(msg,function(msg)
						if msg.index then
							local bagIndex = msg.index
							local newGem = {sid = gemSid,pos = bagIndex};
							param.father.onPutOnClick(newGem,param.index);
							ui.showMsg("购买并镶嵌成功");
						end						
					end);					
				end				
			end, nil);
		end);	
	end

	local SetPutOnBtn = function(cellIndex,gemIndex)
		local gem = bagGemList[gemIndex];
    	local slot = slotList[gemIndex];
    	slot.setGemBySid(gem.sid,gem.count);
    	local item = grid:GO("item"..gemIndex);
    	local table = tb.GemTable[gem.sid];
    	local str = const.ATTR_NAME[table.add_attr_type].." +"..client.gem.formatAttrValue(gem.sid);
    	item:GO("text").text = client.tools.formatColor(str, const.qualityColor[gem.quality + 1]);    	
 		item:BindButtonClick(function()
			GemMenu.closeSelf();	
			param.father.onPutOnClick(gem,cellIndex);
		end);	   	
	end

	--设置升级宝石按钮，需要参数:cellIndex-原先是第几个格子中的宝石
	local SetUpgradeBtn = function(cellIndex)
		local gem = curGem;
    	local slot = slotList[1];
    	slot.setGemBySid(gem.sid,"");
    	local item = grid:GO("item"..1);
    	item:GO("text").text = "升级宝石";
		slot.setUp(true);
		--计算是否需要钻石
		local table = tb.GemTable[gem.sid];
		local cost = (table.to_next_count - 1) * table.diamond_value;
		local result = GetUpgradeGemCost(cost,table.level);
		local DiamondCount = DataCache.role_diamond;
		item:BindButtonClick(function() 		
			if result.left > 0 then
				ui.showMsgBox(nil, string.format("是否花费%s钻石代替不足的宝石？", result.left), 
					function()
						local DiamondCount = DataCache.role_diamond;
						if DiamondCount < result.left then
							ui.showCharge();
							return;
						end
						-- if DataCache.role_money < table.cost_money then
						-- 	ui.showMsg("金币不足"..table.cost_money);
						-- 	return;
						-- end
						--判断钻石是否足够
						param.father.upgradeEquipGem(result,cellIndex);
						GemMenu.closeSelf();			
					end, nil);
			else
				param.father.upgradeEquipGem(result,cellIndex);
				GemMenu.closeSelf();					
			end
		end);
		--点击事件绑定
	end

	--设置更换宝石按钮
	local SetChangeBtn = function(cellIndex,gemIndex)
		local gem = bagGemList[gemIndex];
    	local slot = slotList[gemIndex+1];
    	slot.setGemBySid(gem.sid,gem.count);
    	local item = grid:GO("item"..gemIndex+1);
    	local table = tb.GemTable[gem.sid];
    	local str = const.ATTR_NAME[table.add_attr_type].." +"..client.gem.formatAttrValue(gem.sid);
    	item:GO("text").text = client.tools.formatColor(str, const.qualityColor[gem.quality + 1]);    	
 		item:BindButtonClick(function()
			GemMenu.closeSelf();	
			param.father.onPutOnClick(gem,cellIndex);
		end);		
	end

	--设置卸下按钮，需要参数:cellIndex-原先是第几个格子中的宝石
	local SetRemoveBtn = function(cellIndex)
		local gem = curGem;
    	local slot = slotList[#bagGemList+2];
    	slot.setGemBySid(gem.sid,"");
    	local item = grid:GO("item"..#bagGemList+2);
    	item:GO("text").text = "卸下宝石";
		--点击事件绑定
		item:BindButtonClick(function() 		
			param.father.onRemoveClick(cellIndex);
			GemMenu.closeSelf();
		end);
	end

	local FormatAllItem = function()
		--确定项数，没有镶嵌时
		local itemCount = 0;
		--如果没有插宝石，检查背包中是否有同类型宝石
		if curGem == nil then
			if #bagGemList == 0 then
				--显示购买按钮
				FormatEmptyList(1);
				SetBuyBtn(1);
			else
				--显示对应的宝石列表
				FormatEmptyList(#bagGemList);
				for i=1,#bagGemList do
					SetPutOnBtn(param.index,i)
				end
			end
		--插了宝石显示升级宝石、包内宝石、卸下宝石三部分
		else
			FormatEmptyList(#bagGemList+2);
			SetUpgradeBtn(param.index)
			for i=1,#bagGemList do
				SetChangeBtn(param.index,i);
			end
			SetRemoveBtn(param.index);
		end
	end


	function GemMenu.Start ()
		this = GemMenu.this;
		buwei = param.buwei;
		bagGemList = param.bagGemList;
		curGem = param.curGem;		
		itemPrefab = this:GO("ScrollView.Viewport.item").gameObject;
		grid = this:GO("ScrollView.Viewport.ButtonGroup");
		FormatAllItem();
	end

	GemMenu.closeSelf = function ()
		destroy(this.gameObject);
	end

	return GemMenu;
end
