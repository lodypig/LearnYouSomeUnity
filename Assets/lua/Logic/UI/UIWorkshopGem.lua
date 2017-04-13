function CreateGemCtrl(node, onUpdate, selectIdx, root)
	local controller = {};
	local gemList = {};
	local i;
	-- local _tfName = node:GO("ndTop._tfName");
	-- local _tfGemName = node:GO("ndBottom._tfGemName");
	-- local _tfAddAttr = node:GO("ndBottom._tfAddAttr");
	-- local _btnUpgrade = node:GO("ndBottom._btnUpgrade");
	-- local _btnPutOn = node:GO("ndBottom._btnPutOn");
	-- local _btnText = node:GO("ndBottom._btnPutOn._tfBtnText");
	local nodeContent = node:GO('RightContent');
	local forbidenRefrsh = false;

	local lastSelectIndex;
	local lastSelectSlot;
	local lastSelectBuWei;
	local lastSelectType;	
	local TEXT = {"35级解锁", "40级解锁", "45级解锁", "50级解锁"};

	-- local warpContent = node:GO('ndMiddle'):GetComponent("UIWarpContent");

	local bagGemList = Bag.GetShowGem(selectIdx);
	local equipGemList;

	local effectObj = nodeContent:GO("RightObj");
	effectObj:PlayUIEffectForever(root.gameObject, "baoshiditudongtai");

	local equipItem = nodeContent:GO("_equipCell");
	local equipSlot = CreateSlot(equipItem);
	equipSlot.reset();
	--获取对应部位的宝石信息到gemList中
	local function getEquipGemList(buwei)
		local list = client.gem.getEquipGem(buwei);
		local gemListTemp = {};
		if list then
			for i = 1, 4 do
				gemListTemp[i] = list[i];
			end
		end
		return gemListTemp;
	end

	--收集slotCtrl的列表
	local itemCount = 0;
	for i = 1, 4 do
		gemList[i] = CreateSlot(nodeContent:GO("_baoshi"..i..".cell"));
	end

	local function GetItemCount()
		local count = 0;
		if bagGemList ~= nil then
			count = #bagGemList;
		end
		return count;
	end

	--更新界面上宝石的文字说明
	local function updateAttr(gem)
		-- if gem then
		-- 	 local table = tb.GemTable[gem.sid];
		-- 	_tfGemName.text = table.show_name;
		-- 	_tfAddAttr.text = const.ATTR_NAME[table.add_attr_type].." +"..client.gem.formatAttrValue(gem.sid);
		-- else
		-- 	_tfGemName.text = "";
		-- 	_tfAddAttr.text = "";
		-- end	
	end

	local function getGem(type, i)
		if type == 0 then
			return equipGemList and equipGemList[i]
		elseif type == 1 then
			return bagGemList[i];
		end
		return nil;
	end

	local function onGemClick(slot, i, type)
		--这里如果该槽没有宝石，则判断背包中是否
		PanelManager:CreatePanel('GemMenu',  UIExtendType.TRANSCANCELMASK, 
			{buwei = lastSelectBuWei, curGem = equipGemList[i], bagGemList = bagGemList, index = i, father = controller});
		-- local gem = getGem(type, i);
		-- if gem == nil then
		-- 	return
		-- end


		-- if lastSelectType ~= type then
		-- 	lastSelectType = type;
		-- 	if gem then
		-- 		_btnText.text = TEXT[type + 1];
		-- 	end
		-- end
		-- if lastSelectSlot and slot ~= lastSelectSlot then			
		-- 	lastSelectSlot.setChoose(false);
		-- end
		
		-- if gem then
		-- 	 lastSelectIndex = i;
		-- 	 updateAttr(gem);
		-- 	 lastSelectSlot = slot;
		-- 	 slot.setChoose(true);			
		-- end	
	end

	local ShowGemName = function(index,bShow)
		local name = nodeContent:GO("_baoshi"..index..".name");
		name.gameObject:SetActive(bShow);
	end

	local SetGemName = function (index,text)
		local name = nodeContent:GO("_baoshi"..index..".name");
		name.gameObject:SetActive(true);
		name.text = text;
	end

	local ShowGemAttr = function(index,bShow)
		local attr = nodeContent:GO("_baoshi"..index..".desc");
		attr.gameObject:SetActive(bShow);
		local back = nodeContent:GO("_baoshi"..index..".back");
		back.gameObject:SetActive(bShow);
	end

	local SetGemAttr = function (index,text)
		local attr = nodeContent:GO("_baoshi"..index..".desc");
		attr.gameObject:SetActive(true);
		local back = nodeContent:GO("_baoshi"..index..".back");
		back.gameObject:SetActive(true);
		attr.text = text;
	end

	local resetText = function (index)
		ShowGemName(index,false);
		ShowGemAttr(index,false);
	end

	local updateEquip = function ()	
		local equip = Bag.wearList[lastSelectBuWei];
		if equip then	
			equipSlot.setEquip(equip, "");
			local enhanceInfo = Bag.enhanceMap[lastSelectBuWei];		
			if enhanceInfo.level > 0 then
				equipSlot.setAttr("+"..enhanceInfo.level);
			end
		else			
			equipSlot.setIcon(const.EQUIP_ICON[lastSelectBuWei]);
		end
	end

	--初始化右边4个宝石格子以及中间装备格
	local function updateCell()
		local level;
		local myLevel = DataCache.myInfo.level;
		local gemSlot;
		local hasGem = client.gem.hasGem(lastSelectBuWei);		
		for i = 1, 4 do	
			gemSlot = gemList[i];			
			gemSlot.wrapper:UnbindAllButtonClick();
			level = tb.GemLevelTable[i];
			gemSlot.reset();
			--先显示一个白底
			gemSlot.setFrame(const.QUALITY_BG[1]);	
			resetText(i);
			--等级未到，显示锁的图标
			if myLevel < level then
				SetGemName(i,TEXT[i]);
				gemSlot.setLock(true, level);
				gemSlot.wrapper:GO("spPlus"):StopAllUIEffects();
			else
				--绑定宝石点击事件
				gemSlot.wrapper:BindButtonClick(function() 
					onGemClick(gemList[i], i, 0);
				end);		
				--如果有宝石，显示宝石
				if equipGemList[i] then
					local gem = equipGemList[i];
					local table = tb.GemTable[gem.sid];
					local text = const.ATTR_NAME[table.add_attr_type].." +"..client.gem.formatAttrValue(gem.sid);
					SetGemName(i,table.show_name);
					SetGemAttr(i,text);
					gemSlot.setGem(gem);
					gemSlot.wrapper:GO("spPlus"):StopAllUIEffects();
					gemSlot.setUp(client.gem.couldUp(gem.sid))
				--没有宝石显示+号
				else	
					gemSlot.wrapper:GO("spPlus"):PlayUIEffectForever(root.gameObject, "baoshijiahao");
					-- gemSlot.setPlus(true);
					gemSlot.setHigh(hasGem);
				end

				-- if i == lastSelectIndex and lastSelectType == 0 then
				-- 	onGemClick(gemList[i], i, 0);				
				-- end
			end
		end
		updateEquip();
	end

	local function onGemChange()
		if forbidenRefrsh then
			return;
		end
		onUpdate();		
	end

	EventManager.bind(root.gameObject,Event.ON_BAG_FORBIDEN_CHANGE, function () 
			forbidenRefrsh = not forbidenRefrsh;
		end);
	EventManager.bind(root.gameObject,Event.ON_EVENT_GEM_CHANGE, onGemChange);
	EventManager.bind(root.gameObject,Event.ON_LEVEL_UP, onUpdate);

	

	controller.onRemoveClick = function(index)
		client.gem.removeEquipGem(function () 
			ui.showMsg("拆卸成功");
			lastSelectType = nil;
			equipGemList[index] = nil;
			onUpdate();
			EventManager.onEvent(Event.ON_GEM_PUT_OR_REMOVE);
		end, lastSelectBuWei, index);
	end

	controller.onPutOnClick = function(gem,index)
		client.gem.putOn(function () 
			AudioManager.PlaySoundFromAssetBundle("setting_gems");
			gemList[index].wrapper:PlayUIEffect(root.gameObject, "xiangqianbaoshi", 1);			
			equipGemList = getEquipGemList(lastSelectBuWei);
			onUpdate();
			EventManager.onEvent(Event.ON_GEM_PUT_OR_REMOVE);
		end, lastSelectBuWei, gem, index);
	end

	controller.upgradeEquipGem = function(result,index)
		client.gem.upgradeEquipGem(function () 
			ui.showMsg("宝石升级成功");
			AudioManager.PlaySoundFromAssetBundle("setting_gems");
			gemList[index].wrapper:PlayUIEffect(root.gameObject, "baoshishengji", 1);			
			equipGemList = getEquipGemList(lastSelectBuWei);
			onUpdate();
			EventManager.onEvent(Event.ON_GEM_PUT_OR_REMOVE);
		end, lastSelectBuWei, result, index);
	end

	-- local function onRightBtnClick()
	-- 	local gem;
	-- 	if lastSelectType and lastSelectIndex then
	-- 		gem =  getGem(lastSelectType, lastSelectIndex)
	-- 	end
	-- 	if gem then
	-- 		if lastSelectType == 0 then
	-- 			onRemoveClick(gem);
	-- 		else
	-- 			onPutOnClick(gem);
	-- 		end
	-- 	else
	-- 		ui.showMsg("请选择一个宝石");
	-- 	end
	-- end

	-- local function onUpgradeClick()
	-- 	local gem = getGem(lastSelectType, lastSelectIndex);
	-- 	if gem then
	-- 		ui.showUpgredeGem(function () 
	-- 			equipGemList = getEquipGemList(lastSelectBuWei);
	-- 			if lastSelectType == 0 then
	-- 				onUpdate();
	-- 			end
	-- 		end, gem, lastSelectType, lastSelectIndex, lastSelectBuWei);
	-- 	else
	-- 		ui.showMsg("请选择一个宝石");
	-- 	end
	-- end

	-- local function formatItem(go, i)
	-- 	local wrapper = go:GetComponent("UIWrapper");
	-- 	local slotCtrl = wrapper:GetUserData("ctrl");
	-- 	if slotCtrl == nil then
	-- 		slotCtrl = CreateSlot(go);
	-- 		wrapper:SetUserData("ctrl",slotCtrl);
	-- 	end
		
	-- 	wrapper:UnbindAllButtonClick();
	-- 	local item = bagGemList[i];
	-- 	wrapper:BindButtonClick(function() 
	-- 		onGemClick(slotCtrl, i, 1);
			
	-- 	end);
	-- 	if item ~= 0 and item ~= nil then
	-- 		local gemTable = tb.GemTable[item.sid];
	-- 		slotCtrl.setGem(item);
	-- 		slotCtrl.setAttr(item.count);					
	-- 	else
	-- 		slotCtrl.reset();
	-- 	end

	-- 	if i == lastSelectIndex and lastSelectType == 1 then
	-- 		if item ~= 0 and item ~= nil then
	-- 			onGemClick(slotCtrl, i, 1);				
	-- 		else
	-- 			lastSelectType = nil;
	-- 			lastSelectIndex = 0;
	-- 		end
	-- 	end
	-- end

	function controller.onEquipSelect(selectIdx, forceUpdate)
		if lastSelectBuWei ~= selectIdx then
			equipGemList = getEquipGemList(selectIdx);
			lastSelectIndex = 1;
			lastSelectType = 1;
		elseif forceUpdate then
			equipGemList = getEquipGemList(selectIdx);
			lastSelectIndex = 1;
			lastSelectType = 1;
		end
		lastSelectBuWei = selectIdx;
		--取得背包中该类型宝石的列表
		bagGemList = Bag.GetShowGem(lastSelectBuWei);
		-- warpContent:Refresh(GetItemCount());		
		-- _tfName.text = const.BuWei[selectIdx];
		updateCell();		
	end

	controller.checkHigh = function(buwei)
		return client.gem.checkHigh(buwei);
	end

	controller.checkUp = function (buwei)
		local gemList = client.gem.getEquipGem(buwei);
		for i = 1, #gemList do
			if gemList[i] and client.gem.couldUp(gemList[i].sid) then
				return true;
			end
		end
		return false;
	end

	controller.visible = function(visible)
		node.gameObject:SetActive(visible);
	end

	-- warpContent.goItemPrefab = node:LoadAsset("BagItem");
	-- warpContent:BindInitializeItem(formatItem);
	-- warpContent:Init(GetItemCount());
	-- _btnUpgrade:BindButtonClick(onUpgradeClick);
	-- _btnPutOn:BindButtonClick(onRightBtnClick);

	return controller;
end