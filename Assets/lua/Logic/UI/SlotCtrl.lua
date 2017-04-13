function CreateSlot(go)
	local wrapper = go:GetComponent("UIWrapper");
	local slot = {};
	slot.icon = wrapper:GO("_icon");
    slot.bg = wrapper:GO("_bg");
	slot.frame = wrapper:GO("_frame");
	slot.attr = wrapper:GO("_attr");	
	slot.disable = wrapper:GO("_disable");
	slot.up = wrapper:GO("_up");
	slot.spHigh = wrapper:GO("_spHigh");
	slot.choosen = wrapper:GO("_choosen");
	slot.spWear = wrapper:GO("_spWear");
	slot.weijianding = wrapper:GO("_weijianding");
	slot.spLock = wrapper:GO("_spLock");
	slot.tfLock = wrapper:GO("_tfLock");
	slot.spPlus = wrapper:GO("_spPlus");
	slot.spCover = wrapper:GO("_spCover");
	slot.btmGemGrid = wrapper:GO("_btmGemGrid");
	return CreateSlotCtrl(slot, wrapper);
end

function SlotView(param, go)	
	local slot = {};
	local wrapper = go:GetComponent("UIWrapper");
	return CreateSlotCtrl(slot, wrapper);
end

------------------------------------------------------ tools ------------------------------------------------------
local function setSprite(spriteUI, icon)	
	if spriteUI and icon then
		spriteUI.gameObject:SetActive(true);
		spriteUI.sprite = icon;
		spriteUI:GetComponent("Image"):SetNativeSize();
	elseif spriteUI then 
		spriteUI.gameObject:SetActive(false);
	end
end

local function setText(textUI, text)	
	if textUI and text then
		textUI.gameObject:SetActive(true);
		textUI.text = text;
	elseif textUI then 
		textUI.gameObject:SetActive(false);
	end
end

CreateSlotCtrl = function (slot, wrapper)
	-- slot代表wrapper table
	
	slot.wrapper = wrapper;	
	
	------------------------------------------------------ base ui widget ------------------------------------------------------
	--背景图
    slot.setBG = function (flag)
        if slot.bg then
           slot.bg.gameObject:SetActive(flag)
        end
	end

	--- 品质底图 ---
	slot.setFrame = function (icon)  
        setSprite(slot.frame, icon)
	end

    slot.setQuality = function (quality)
        setSprite(slot.frame, const.QUALITY_BG[quality + 1])
	end

	--- 图标 ---
	slot.setIcon = function (iconName)
		setSprite(slot.icon, iconName)
	end

    --- 右下角（一般为数量） ---
	slot.setAttr = function (attr)
		setText(slot.attr, attr)
	end

	--- 禁用 ---
	slot.setDisable = function (disable)
		if slot.disable then
			slot.disable.gameObject:SetActive(disable == true);
		end
	end
    
    --右上角可提升图标--
	slot.setUp = function (up)
		if slot.up then
			slot.up.gameObject:SetActive(up == true);
		end
	end

	--- 红点 ---
	slot.setHigh = function (high)
		if slot.spHigh then
			slot.spHigh.gameObject:SetActive(high == true);
		end
	end;

	--- 选中 ---
	slot.setChoose = function (choose)
		if slot.choosen then
			slot.choosen.gameObject:SetActive(choose == true);
		end
	end;
		
	---右下角斜图标 已装备，可洗炼，可转移等等 ---
	slot.setWear = function (icon)
        setSprite(slot.spWear, icon);
	end;

    --- 格子中间的位置的图标 未鉴定---
	slot.setWeiJianDing = function (icon)
        setSprite(slot.weijianding, icon);
	end

    --- 锁图标 一般用于显示没有解锁的空格子---
	slot.setLock = function(lock, level)
		if slot.spLock then
			slot.spLock.gameObject:SetActive(lock == true);
		end
		if slot.tfLock then
			if lock and level then
				slot.tfLock.gameObject:SetActive(lock == true);
				slot.tfLock.text = level.."级解锁";
			else
				slot.tfLock.gameObject:SetActive(false);
			end
		end
	end

	--==========================下面不知道还有没有用===================================

	--- 碎片图标 ---
	slot.setCover = function(bCover)
		if slot.spCover then
			slot.spCover.gameObject:SetActive(bCover == true);
		end
	end

	--- 加号 ---
	slot.setPlus = function(plus)
		if slot.spPlus then
			slot.spPlus.gameObject:SetActive(plus == true);
		end
	end
		
	------------------------------------------------------ equip ------------------------------------------------------
	--  TODO:这个函数不应在这里
	local function isDisable(itemCfg, isEquip)
		if itemCfg.level_limit and itemCfg.level_limit > DataCache.myInfo.level then
			return true;
		elseif isEquip == true and itemCfg.career ~= DataCache.myInfo.career then
			return true;
		else
			return false;
		end
	end

    --icon需要额外找到具体的本职业对应的装备
    local function setSuiPianIcon(bagEquip)
        local fragEquipInfo = tb.FragTable[bagEquip.sid];
        local equipId = fragEquipInfo[DataCache.myInfo.career];
        local equipInfo = tb.EquipTable[equipId];
        slot.setIcon(equipInfo.icon);
    end

	-- TODO:isDisable应由外部判断,
    --奖励类似的装备显示
	slot.setEquip = function (equip)
		local equipTable = tb.EquipTable[equip.sid];        
        slot.setFrame(const.QUALITY_BG[equip.quality + 1]);
        if equipTable.career == "suipian" then
            slot.setWeiJianDing(commonEnum.EquipFlagSprite[commonEnum.EquipFlag.OrangePiece])
            setSuiPianIcon(equip)
        else
            slot.setIcon(equipTable.icon);  
        end	
	end


    --穿在身上的装备的显示 等级 品质背景 icon
    slot.setWareEquip = function (wareEquip)
		local equipTable = tb.EquipTable[wareEquip.sid];        
        slot.setIcon(equipTable.icon);
        slot.setFrame(const.QUALITY_BG[wareEquip.quality + 1]);	
        if wareEquip.recoveryTime ~= nil and wareEquip.recoveryTime > 0 then
            slot.setDisable(true)
        end
	end

	slot.setTreasure = function (sid)
		local itemTable = tb.ItemTable[sid];        
        slot.setIcon(itemTable.icon);
        slot.setFrame(const.QUALITY_BG[itemTable.quality + 1]);			
	end

    --可装备 洗炼 转移 
    local function handleBiaoShi(bagEquip)
        if bagEquip.biaoshi == const.biaoshi.CouldWear then
            slot.setWear(commonEnum.EquipFlagSprite[commonEnum.EquipFlag.CouldWear])
        elseif bagEquip.biaoshi == const.biaoshi.CouldXilian then
            slot.setWear(commonEnum.EquipFlagSprite[commonEnum.EquipFlag.CouldXilian])
        elseif bagEquip.biaoshi == const.biaoshi.CouldZhuanyi then
            slot.setWear(commonEnum.EquipFlagSprite[commonEnum.EquipFlag.CouldZhuanyi])
        end
    end


    slot.setBagEquip = function (bagEquip)
		local equipTable = tb.EquipTable[bagEquip.sid];
        slot.setFrame(const.QUALITY_BG[bagEquip.quality + 1]);        
        --slot.setDisable(DataCache.myInfo.level < equipTable.level);
        if bagEquip.quality == const.quality.orangepiece then --橙装碎片
            slot.setWeiJianDing(commonEnum.EquipFlagSprite[commonEnum.EquipFlag.OrangePiece])
            slot.setAttr(bagEquip.count)
            setSuiPianIcon(bagEquip)
        elseif bagEquip.quality == const.quality.unidentify then --未鉴定
            slot.setIcon(equipTable.icon);
            slot.setWeiJianDing(commonEnum.EquipFlagSprite[commonEnum.EquipFlag.identify])
            slot.setAttr(bagEquip.count)
        else --其他
            slot.setIcon(equipTable.icon);
            handleBiaoShi(bagEquip)
        end
	end;


	------------------------------------------------------ gem ------------------------------------------------------

	
	local spGemList;
	local spBgList;

	local ensuerbtmGemSpList = function ()
	 	if spBgList then
	 		return;
	 	end
	 	local name = "spBtmGem";
	 	spBgList = {slot.btmGemGrid:GO("spGemBg1"), slot.btmGemGrid:GO("spGemBg2"), slot.btmGemGrid:GO("spGemBg3"), slot.btmGemGrid:GO("spGemBg4")}; 
 		spGemList = {};
	 	for i = 1, 4 do	
	 		spGemList[i] = spBgList[i]:GO(name);
	 	end
	end

	local setBtmGemList = function (gemList)
		ensuerbtmGemSpList();
		local table;
		local myLevel = DataCache.myInfo.level;		
		if gemList then
			slot.btmGemGrid.gameObject:SetActive(true);
			for i = 1, 4 do
				local level = tb.GemLevelTable[i];
				if myLevel < level then
					spBgList[i].gameObject:SetActive(false);
				elseif gemList[i] then
					spGemList[i].gameObject:SetActive(true);
					table = tb.GemTable[gemList[i].sid];
					spGemList[i].sprite = table.icon;
					spGemList[i]:SetNaiveSize();
				else
					spBgList[i].gameObject:SetActive(true);
					spGemList[i].gameObject:SetActive(false);
				end

				-- if gemList[i] then
				-- 	spGemList[i].gameObject:SetActive(true);
				-- 	table = tb.GemTable[gemList[i].sid];
				-- 	spGemList[i].sprite = table.icon;
				-- 	spGemList[i]:SetNaiveSize();
				-- end
			end
		else
			slot.btmGemGrid.gameObject:SetActive(false);
		end
		

	end

	slot.setBtmGemList = function (gemList)
		if slot.btmGemGrid then
			if gemList then
				slot.btmGemGrid.gameObject:SetActive(true);
				setBtmGemList(gemList);
			else
				slot.btmGemGrid.gameObject:SetActive(false);
			end
		end
	end

	slot.setGem = function (gem)	
		slot.setGemBySid(gem.sid, gem.count);
	end

	slot.setGemBySid = function (sid, count)	
		local gemTable = tb.GemTable[sid];
        slot.setFrame(const.QUALITY_BG[gemTable.quality + 1]);        
        slot.setIcon(gemTable.icon);
        slot.setAttr(count);
	end

	------------------------------------------------------ item ------------------------------------------------------
	--通用物品
    slot.setItem = function (item)
        if tb.GemTable[item.sid] then
            slot.setGem(item)
        else
            slot.setNormalItem(item)
        end
	end

    --通用物品sid --todo看是否需要显示数量
    slot.setItemFromSid = function (sid)
        local item = {sid= sid, count = 1};
        slot.setItem(item);
	end

    slot.setNormalItem = function (item)
		local itemTable = tb.ItemTable[item.sid];		
        slot.setFrame(const.QUALITY_BG[itemTable.quality + 1]);
        slot.setAttr(item.count);
        slot.setIcon(itemTable.icon);
	end

    --不关心具体类型，data包含所需信息，不需要配置表了
    slot.setData = function (data)	
        slot.setAttr(data.count);	
        slot.setIcon(data.icon);
        slot.setFrame(const.QUALITY_BG[data.quality + 1]);
	end;

	------------------------------------------------------ reset ------------------------------------------------------
	slot.reset = function () 
		slot.setIcon();   
		slot.setFrame();
		slot.setWeiJianDing();
		slot.setChoose();
		slot.setHigh();
		slot.setDisable();
		slot.setUp();
		slot.setAttr();
		slot.setLock();
		slot.setCover();	
        slot.setWear();
		slot.setBtmGemList();
        slot.setBG(false);
		slot.setPlus();
	end;

	return slot;
end