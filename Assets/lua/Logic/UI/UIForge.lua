function UIForgeView (param)
	local UIForge = {};
	local this = nil;
	local wearEquip = nil;
	local curForgeValue = nil;
	local upNeedForgeValue = nil;

	local selectIconList = {};
	UIForge.clickEnable = true;

	function UIForge.Start()
		this = UIForge.this;
		wearEquip = Bag.getWearEquip(param.buwei);
		UIForge.SetLeftInfo(wearEquip);

		-- 获取可以用来锻造的装备列表
		client.forge.GetForgeEquipList(wearEquip);

		-- 显示右侧材料装备基本信息
		UIForge.SetRightInfo();

		client.forge.IsAllPurpleOn = 0;
		-- 全选紫装按钮事件
		UIForge.quickChoose:BindButtonClick(function (go)
			client.forge.IsAllPurpleOn = 1 - client.forge.IsAllPurpleOn;
			UIForge.queding.gameObject:SetActive(client.forge.IsAllPurpleOn == 1)
			if client.forge.IsAllPurpleOn == 1 and UIForge.IsEquipMaxForge(wearEquip) == false then
				client.forge.AllPurple(wearEquip);
				UIForge.SetRightInfo();
				UIForge.RefreshLeftInfo()
			end
		end) 


		-- 打开规则面板
		UIForge.ruleBtn:BindButtonClick(function (go)
			UIForge.rulePanel.gameObject:SetActive(true)
		end)

		-- 点击面板外框或关闭按钮关闭规则面板
		UIForge.blank:BindButtonClick(function (go)
			UIForge.rulePanel.gameObject:SetActive(false)
		end)
		UIForge.closeBtn[2]:BindButtonClick(function (go)
			UIForge.rulePanel.gameObject:SetActive(false)
		end)

		-- 关闭锻造界面UI
		UIForge.closeBtn[1]:BindButtonClick(function (go)
			destroy(this.gameObject);
		end)

		-- 点击装备锻造
		UIForge.btnForge:BindButtonClick(function ()
			if UIForge.clickEnable then
				if #client.forge.forgeEquipList == 0 then
					ui.showMsg("当前没有可使用的材料装备");
					return
				elseif UIForge.HaveChooseForgeEquip() == false then
					ui.showMsg("请先选择材料装备");
					return
				else
					local posList = UIForge.ChooseEquipPosList();
					UIForge.clickEnable = false;
					client.forge.HandleForge(posList,param.buwei,function (Msg)
						-- 刷新界面显示，去除全身紫装打钩、右侧材料装备刷新，左侧装备信息重新设置（不显示下级预览等信息）
						-- 指定选中装备播放消失特效，进度条变化，进度条上方数值变化，
						-- 如果锻造等级提升，左侧装备图标播放升级特效，提示锻造成功，同时播放进度条变化
						-- 重新获取右侧装备列表信息，左侧装备信息也需要刷新

						local warpContent = UIForge.container:GetComponent("UIWarpContent");
						warpContent:ForEach(function (go, i) 
						 	if client.forge.chooseList[i] == 1 then
						 		local wrapper = go:GetComponent("UIWrapper");
				 				wrapper:GO("_rightEquipItem"):PlayUIEffect(this.gameObject, "zbdz", 1.5);
						 	end
					 	end)



						this:Delay(0.4, function ()
							UIForge.leftEquipItem.wrapper:PlayUIEffect(this.gameObject, "zbdz1", 2);
							wearEquip = Bag.getWearEquip(param.buwei);
							
							-- 装备等级提升
							local forgeLevelUp = Msg["level_up"];
							if forgeLevelUp == 1 then
								this:Delay(1, function ()
									UIForge.levelUpObj:PlayUIEffect(this.gameObject, "zbdz2", 1);
								end);
							end

							this:Delay(0.2, function ()
								UIForge.SetLeftInfo(wearEquip);
								-- 获取可以用来锻造的装备列表
								client.forge.GetForgeEquipList(wearEquip);
								-- 显示右侧材料装备基本信息
								UIForge.SetRightInfo();

								-- 去勾选全选紫装
								client.forge.IsAllPurpleOn = 0;
								UIForge.queding.gameObject:SetActive(false)

								UIForge.clickEnable = true;
							end);	
						end);
					end)
				end
			end
		end)
	end

	-- 判断装备是否已经锻造至满级
	function UIForge.IsEquipMaxForge(equip)
		if type(equip.forgeAttr) == "table" and equip.forgeAttr[1] == tb.MaxForgeLevelTable[equip.level] then
			return true
		else
			return false
		end
	end

	-- 返回选中装备在背包中的位置列表
	function UIForge.ChooseEquipPosList()
		local posList = {}
		for i=1, #client.forge.forgeEquipList do

			if client.forge.chooseList[i] == 1 then
				posList[#posList + 1] = client.forge.forgeEquipList[i].pos;
			end
		end
		return posList;
	end

	-- 可锻造装备列表不为空时，是否选择了装备用来锻造
	function UIForge.HaveChooseForgeEquip()
		for i=1, #client.forge.forgeEquipList do
			if client.forge.chooseList[i] == 1 then
				return true
			end
		end
		return false
	end

	-- 初始化左侧装备信息（名称、图标、锻造等级、当前基础属性、下一级基础属性、锻造进度）
	function UIForge.SetLeftInfo(equip)
		UIForge.zbdz4.gameObject:SetActive(false)
		UIForge.equipName.text = equip.name;
		UIForge.leftEquipItem.reset();
		UIForge.leftEquipItem.setEquip(equip);
		-- local slotCtrl  = CreateSlot(UIForge.leftEquipItem.gameObject);
		-- slotCtrl.reset();
		-- slotCtrl.setEquip(equip);

		local equipCfg = tb.GetTableByKey(tb.baseAttrTable, {equip.sid, equip.quality});


		UIForge.jiantou.gameObject:SetActive(false)
		UIForge.nextLevel.gameObject:SetActive(false)
		-- 装备未经过锻造
		if type(equip.forgeAttr) ~= "table" then
			-- 显示锻造等级
			UIForge.curLevel.text = 0;
			local nextLVCfg = tb.GetTableByKey(tb.EquipForgeAttrTable, {equip.level, 1, equip.buwei});
			if equipCfg.phyAttackMin ~= 0 then

				UIForge.baseAttr.text = "攻击： "..equipCfg.phyAttackMax;
				UIForge.nextLevelAttr.text = "下一级：<color=#8ddd10>攻击+"..nextLVCfg.hit_value.."</color>";
			else
				UIForge.baseAttr.text = "防御： "..equipCfg.phyDefense.."        生命： "..equipCfg.maxHP;
				UIForge.nextLevelAttr.text = "下一级：<color=#8ddd10>防御+"..nextLVCfg.defense_value.."      生命+"..nextLVCfg.hp_value.."</color>";
			end

			UIForge.foreground.fillAmount = 0;
			UIForge.processText.text = "0/"..nextLVCfg.total_forge_value;
			curForgeValue = 0;
			upNeedForgeValue = nextLVCfg.total_forge_value; 
		else
			-- 装备锻造过
			-- 显示锻造进度条/锻造进度数值
			local curLevelCfg = tb.GetTableByKey(tb.EquipForgeAttrTable, {equip.level, equip.forgeAttr[1], equip.buwei});
			UIForge.curLevel.text = equip.forgeAttr[1]; 
			-- 装备未锻造至满级
			if equip.forgeAttr[1] ~= tb.MaxForgeLevelTable[equip.level] then
				local nextLVCfg = tb.GetTableByKey(tb.EquipForgeAttrTable, {equip.level, equip.forgeAttr[1] + 1, equip.buwei});
				-- 攻击型装备
				if equipCfg.phyAttackMin ~= 0 then
					local text = "攻击： "..equipCfg.phyAttackMax;
					if equip.forgeAttr[1] ~= 0 then
						text = text.." <color=#8ddd10>+"..tb.GetTableByKey(tb.EquipForgeAttrTable, {equip.level, equip.forgeAttr[1], equip.buwei}).hit_value.."</color>"
					end
					UIForge.baseAttr.text = text;
					UIForge.nextLevelAttr.text = "下一级：<color=#8ddd10>攻击+"..nextLVCfg.hit_value.."</color>";
				else
					-- 防御型装备
					local text = "防御： "..equipCfg.phyDefense.."        生命： "..equipCfg.maxHP
					if equip.forgeAttr[1] ~= 0 then
						text = "防御： "..equipCfg.phyDefense.." <color=#8ddd10>+"..curLevelCfg.defense_value.."</color>".."        生命： "..equipCfg.maxHP.." <color=#8ddd10>+"..curLevelCfg.hp_value.."</color>"
					end
					UIForge.baseAttr.text = text;
					UIForge.nextLevelAttr.text = "下一级：<color=#8ddd10>防御+"..nextLVCfg.defense_value.."      生命+"..nextLVCfg.hp_value.."</color>";
				end
				UIForge.foreground.fillAmount = equip.forgeAttr[2] / curLevelCfg.next_level_value;
				UIForge.processText.text = equip.forgeAttr[2].."/"..curLevelCfg.next_level_value;

				curForgeValue = equip.forgeAttr[2];
				upNeedForgeValue = curLevelCfg.next_level_value; 
			else
				-- 锻造至满级后，当前属性和下级属性如何显示需要核对
				local nextLVCfg = tb.GetTableByKey(tb.EquipForgeAttrTable, {equip.level, equip.forgeAttr[1] + 1, equip.buwei});
				-- 攻击型装备
				if equipCfg.phyAttackMin ~= 0 then
					local text = "攻击： "..equipCfg.phyAttackMax;
						text = text.." <color=#8ddd10>+"..tb.GetTableByKey(tb.EquipForgeAttrTable, {equip.level, equip.forgeAttr[1], equip.buwei}).hit_value.."</color>"
					UIForge.baseAttr.text = text;
					UIForge.nextLevelAttr.text = "下一级：<color=#8ddd10>已满级</color>";
				else
					-- 防御型装备
					text = "防御： "..equipCfg.phyDefense.." <color=#8ddd10>+"..curLevelCfg.defense_value.."</color>".."    生命： "..equipCfg.maxHP.." <color=#8ddd10>+"..curLevelCfg.hp_value.."</color>"
					UIForge.baseAttr.text = text;
					UIForge.nextLevelAttr.text = "下一级：<color=#8ddd10>已满级</color>";
				end
				local level9Cfg = tb.GetTableByKey(tb.EquipForgeAttrTable, {equip.level, equip.forgeAttr[1] - 1, equip.buwei});

				UIForge.foreground.fillAmount = (equip.forgeAttr[2] + level9Cfg.next_level_value)/ level9Cfg.next_level_value;
				UIForge.processText.text = (equip.forgeAttr[2] + level9Cfg.next_level_value).."/"..level9Cfg.next_level_value;

				curForgeValue = equip.forgeAttr[2] + level9Cfg.next_level_value;
				upNeedForgeValue = level9Cfg.next_level_value;
			end
		end
	end

	-- 每一次勾选右侧装备后需要刷新左侧的锻造进度信息预览，包括锻造下一等级（箭头和数字上需要添加特效）、进度条增长显示（未满级时需要显示）、进度数值预览
	-- 如果选中装备list不为空，需要显示进度数值预览，如果装备提供的锻造度足够升下一级，需要显示锻造下一等级，如果装备未满级，需要显示装备的锻造进度
	function UIForge.SetRightInfo()
        local equipCount = #client.forge.forgeEquipList;
        local container = UIForge.container;
        local itemPrefab = UIForge.item.gameObject;
        local warpContent = container:GetComponent("UIWarpContent");
        warpContent.goItemPrefab = itemPrefab;
        warpContent:BindInitializeItem(UIForge.FormatItem);
        warpContent:Init(equipCount);
	end

	function UIForge.FormatItem(go,index)
		local wrapper = go:GetComponent("UIWrapper");
        local equipInfo = client.forge.forgeEquipList[index];

   --      if Slot[index] == nil then
   --      	local slotGo = wrapper:GO('_rightEquipItem');
			-- Slot[index] = CreateSlot(slotGo.gameObject);	
   --      end
        -- 装备图标
		local slotGo = wrapper:GO('_rightEquipItem');
		local slotCtrl  = CreateSlot(slotGo.gameObject);
		slotCtrl.reset();
		slotCtrl.setEquip(equipInfo);

        wrapper:GO('_name').text = string.format("<color=%s>%s</color>",const.qualityColor[equipInfo.quality + 1], tb.EquipTable[equipInfo.sid].name);
        wrapper:GO('_value').text = "进度+"..client.forge.CalcEquipForgeValue(equipInfo);
        wrapper:GO('_xuanzhong').gameObject:SetActive(client.forge.chooseList[index] ~= nil and client.forge.chooseList[index] == 1)
        wrapper:GO('_dikuang._dagou').gameObject:SetActive(client.forge.chooseList[index] ~= nil and client.forge.chooseList[index] == 1)

        wrapper:BindButtonClick(function (go)
        	-- 将选中列表的值取反
        	client.forge.chooseList[index] = 1 - client.forge.chooseList[index];
        	-- 需要勾选中选中的item（打钩和选中图片点亮），同时需要刷新左侧的进度条效果、进度条上方数值显示，如果足够升下一级，需要显示箭头和下一级等级数字（以及播放特效）
        	local tempWrapper = go:GetComponent("UIWrapper");
	        tempWrapper:GO('_xuanzhong').gameObject:SetActive(client.forge.chooseList[index] ~= nil and client.forge.chooseList[index] == 1)
	        tempWrapper:GO('_dikuang._dagou').gameObject:SetActive(client.forge.chooseList[index] ~= nil and client.forge.chooseList[index] == 1)

	        UIForge.RefreshLeftInfo();
        end);
	end

	-- 根据选中的材料装备来 预览穿戴装备的信息
	function UIForge.RefreshLeftInfo()
		-- 已经没有可以锻造的装备
		if #client.forge.forgeEquipList == 0 then
			UIForge.jiantou.gameObject:SetActive(false)
			UIForge.nextLevel.gameObject:SetActive(false)
		else
			-- 如果当前选中材料装备锻造值为0
			if UIForge.CalcTotalForgeValue() == 0 then
				UIForge.SetLeftInfo(wearEquip);
				return
			else
				-- 显示进度条上方锻造数值，显示锻造进度条变化
				UIForge.processText.text = curForgeValue.."<color=#8ddd10>(+"..UIForge.CalcTotalForgeValue()..")</color>".."/"..upNeedForgeValue
				
				if curForgeValue < upNeedForgeValue then
					UIForge.zbdz4.gameObject:SetActive(true)
					UIForge.zbdz4:GetComponent("RectTransform").anchoredPosition = Vector3.New(UIForge.foreground:GetComponent("RectTransform").sizeDelta.x * (curForgeValue/ upNeedForgeValue),0,0)
					local totalJindu = (curForgeValue + UIForge.CalcTotalForgeValue()) / upNeedForgeValue;
					if totalJindu > 1 then
						totalJindu = 1
					end
					UIForge.zbdz4:GO("Image").fillAmount = totalJindu - (curForgeValue/ upNeedForgeValue)
				end
			end

			-- 当前选中装备是否可以升下级
			if UIForge.IsEquipCanUpGrade(wearEquip,UIForge.CalcTotalForgeValue()) then
				UIForge.jiantou.gameObject:SetActive(true);
				UIForge.nextLevel.gameObject:SetActive(true);
				UIForge.jiantou:GO("zbdz3.shuzi").text = client.forge.CalcNextForgeLevel(wearEquip,UIForge.CalcTotalForgeValue()); 
			else
				UIForge.jiantou.gameObject:SetActive(false);
				UIForge.nextLevel.gameObject:SetActive(false);
			end
		end
	end

	-- 计算选中装备可以提供的锻造值
	function UIForge.CalcTotalForgeValue()
		local totalForgeValue = 0;
		for i=1,#client.forge.forgeEquipList do
			if client.forge.chooseList[i] == 1 then
				totalForgeValue = totalForgeValue + client.forge.CalcEquipForgeValue(client.forge.forgeEquipList[i]);
			end
		end
		return totalForgeValue;
	end

	-- 计算锻造值是否可以给装备带来锻造等级提升
	function UIForge.IsEquipCanUpGrade(equip,deltaValue)
		-- 装备未经过锻造
		if type(equip.forgeAttr) ~= "table" then
			local equipCfg = tb.GetTableByKey(tb.EquipForgeAttrTable,{equip.level,0,equip.buwei});
			if equipCfg.next_level_value <= deltaValue then
				return true
			else
				return false
			end
		else
			-- 装备经过锻造，需要考虑穿戴的装备是否达到满级
			local equipCfg = tb.GetTableByKey(tb.EquipForgeAttrTable,{equip.level,equip.forgeAttr[1], equip.buwei});
			if equip.forgeAttr[1] == tb.MaxForgeLevelTable[equip.level] then
				return false 
			elseif equipCfg.next_level_value <= equip.forgeAttr[2] + deltaValue then
				return true
			else
				return false
			end
		end
	end

	return UIForge;
end

ui.ShowForge = function (param) 
	PanelManager:CreateConstPanel('UIForge',UIExtendType.BLACKMASK,param);
end