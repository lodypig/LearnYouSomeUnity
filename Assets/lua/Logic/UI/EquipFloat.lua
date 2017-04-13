function EquipFloatView(param)
	local EquipFloat = {};
	local this = nil;
	local dayTime = 3600 * 24;
	local hourTime = 3600;
	local minuteTime = 60;
	local needTime = 0;
	local minHeight = 440

	--装备数据
	local equip = param.base;
	local enhance = param.enhance;
	local gemList = param.gemList;
	local bagIndex = param.index;
	local equip2 = param.compEquip;	--对比的装备

	--显示类型
	--self, 自己的装备 
	--show,只作显示, 没有操作按钮
	--random, 随机属性，掉落预览
	local showType = param.showType;
	--子类型，根据显示类型再做区分
	local subType = param.subType;

	local closeSelf = function ()
		destroy(this.gameObject)
	end

	local unwear = function ()
		local equip = Bag.wearList[param.index];
		if nil == equip then
			error("can't find the equip  ".. param.index);
			return
		end
		local msg = {cmd = "take_off",equipment_index = param.index}
		Send(msg);
	end

	local doRepair = function ()
		local money = equip.level * math.ceil(needTime/minuteTime);
		local str = "立即修复该装备需要花费"..money.."金币,确定要这么做吗?";
		ui.showMsgBox(nil, str, function ()
			if DataCache.role_money < money then
				ui.showBuyMoney()
			else
				local msg = {cmd = "equip_fix",equip_type = 1, index = param.index}
				Send(msg, function(msgTable)
					equip.recoveryTime = 0;		
					this:GO("content.equip1.Broken").gameObject:SetActive(false);
					Bag.UpdateBorkenMap(msgTable);
					ui.showMsg("装备已修复")
				end);
			end
		end)
	end

	local processWear = function ()
		local equip = param.base;
		if Bag.canWear(equip) then




			-- if client.equip.CouldZhuanyi(equip) then
			-- 	local okFun = function ()
			-- 		ui.ShowZhuanyi(equip);
			-- 	end




			-- 	local cancelFun = function ()
			-- 		Bag.wear(equip);
			-- 	end
				


			-- 	ui.showMsgBox(nil, "是否将换下装备的附加属性转移到新的装备？", okFun, cancelFun);
			-- else
				Bag.wear(equip);

			--end
		end
		closeSelf();
	end

	local processForge = function ()
		if Bag.wearList[param.base.buwei] ~= nil and Bag.wearList[param.base.buwei].level >= 40 or Bag.wearList[param.base.buwei].quality == 4 then
			ui.ShowForge({buwei = param.base.buwei})
		else
			ui.showMsg("装备未满足条件，无法锻造");
		end
		closeSelf();
	end

	local processXiLian = function ()
		if DataCache.myInfo.level < param.base.level then
			ui.showMsg("等级不足，无法洗炼");
		elseif DataCache.myInfo.career ~= equip.career then
			ui.showMsg("职业不符，无法洗炼");
		elseif Bag.wearList[param.base.buwei] == nil then
			ui.showMsg("当前部位未穿戴装备，无法洗炼");
		else
			ui.ShowXiLian(param.base);
		end
		closeSelf();
	end

	local processZhuanyi = function ()
		if DataCache.myInfo.level < param.base.level then
			ui.showMsg("等级不足，无法转移");
		elseif DataCache.myInfo.career ~= equip.career then
			ui.showMsg("职业不符，无法转移");
		elseif Bag.wearList[param.base.buwei] == nil then
			ui.showMsg("当前部位未穿戴装备，无法转移");
		else
			ui.ShowZhuanyi(param.base);
		end
		closeSelf();
	end

	local IdentifyEquipCallBack = function(msg)
		if msg.type == "ok" then 
            local equipInfo = client.equip.parseEquip(msg.equip);
            local temp = client.tools.formatColor(equipInfo.name, const.qualityColor[equipInfo.quality + 1]);
            local str = "获得"..temp;
			ui.showMsg(str);
			str = string.format("鉴定成功！获得[item:%s:item:%d]", equipInfo.name, equipInfo.quality);
			client.chat.clientSystemMsg(str, nil, equipInfo, "system", true)
			equip.count = math.max(equip.count - 1,1)
			EquipFloat.SetUnidentify()
			if equip.count <= 1 then		
				closeSelf();
			end
		end
	end

	local IdentifyEquip = function()
		local equip = param.base

		if DataCache.myInfo.career ~= equip.career then
			ui.showMsg("职业不符，无法鉴定");
			return
		end
		if DataCache.myInfo.level < equip.level then
			ui.showMsg("等级不足，无法鉴定");
			return
		end

		if DataCache.role_money < tb.equip_identify[equip.sid].identify_cost then
			ui.showBuyMoney()
			return
		end

		if equip.count > 1 and Bag.getBagGridCount() == 0 then
			ui.showMsg("包裹空间不足，无法鉴定");
			return
		end

		local msg = {cmd = "identify_equip",index = equip.pos}
		Send(msg, IdentifyEquipCallBack);
		
	end

	local SaleEquipCallback = function(reply)
        local money = reply["money"];
        if money ~= nil and money ~= 0 then
            SysInfoLayer.GetInstance():ShowMsg(string.format("出售成功，获得%s金币",money));
        end
	end

	local SaleEquip = function()
		if equip ~= nil then
			local equipCfg = tb.EquipTable[equip.sid];
			local name = equipCfg.show_name;
			local str = "";
			local single_price = _equip_kit.get_equip_price(equip, equipCfg);
			if equip.count > 1 then
				
				str = string.format("确定要以[color:239,213,88,%s]金币价格出售[color:239,213,88,%s]个[color:239,213,88,%s]吗？", single_price * equip.count, equip.count, name);
			else
				str = string.format("确定要以[color:239,213,88,%s]金币价格出售[color:239,213,88,%s]吗？", single_price , name);
			end
			ui.showMsgBox(nil, str, function ()
				local msg = { cmd = "equip/sale", index_list = {equip.pos}};
		   	 	Send(msg, SaleEquipCallback);
		   	 	closeSelf();
	   	 	end);
   		end
	end

	local function tradeEquip(  )
		if equip ~= nil then
			closeSelf()
			ui.shelveItem(equip.id)
		end
	end

	local function OnQiangHuaClick()
		ui.showWorkShop(1, param.index);
		closeSelf();
	end

	local function OnGemClick()
		ui.showGemWorkShop(param.index)
		closeSelf();
	end

	-- 设置套装属性颜色 
	local function setColor(wrapper,signal)
		-- 选中按钮变黄，字体颜色为黄色
		if signal == true then 
			wrapper:GO('light').gameObject:SetActive(true);
			wrapper:GO('gary').gameObject:SetActive(false);
			wrapper:GO('Value').textColor = Color.New(255/255, 219/255, 156/255);
		else
			wrapper:GO('light').gameObject:SetActive(false);
			wrapper:GO('gary').gameObject:SetActive(true);
			wrapper:GO('Value').textColor = Color.New(144/255, 144/255, 144/255);
		end
	end

	--装备修复时间
	local processTime = function(time)
		local str = "";
		local dayCount = math.floor(time/dayTime);
		local hourCount = math.floor((time - dayTime * dayCount)/hourTime);
		local minuteCount = math.floor((time - dayTime * dayCount - hourTime * hourCount)/minuteTime);
		local secondCount =  time - dayTime * dayCount - hourTime * hourCount - minuteTime * minuteCount;
		if dayCount > 0 then --超过24小时			
			str = dayCount.."天"..hourCount.."小时"..minuteCount.."分钟";
		elseif hourCount > 1 then --超过1个小时
			str = hourCount.."小时"..minuteCount.."分钟"..secondCount.."秒";
		else
			str = minuteCount.."分钟"..secondCount.."秒";
		end
		return str;
	end

	function EquipFloat.SetBrokenText(equip, wrapper)
		wrapper.gameObject:SetActive(true);
		local nowSecond = math.round(TimerManager.GetServerNowMillSecond()/1000);
		needTime = math.max(equip.recoveryTime - nowSecond, 0);
		wrapper.gameObject:SetActive(needTime ~= 0);
		if needTime == 0 then
			equip.recoveryTime = 0;
		else
			local str = "正在修复中:"..processTime(needTime);
			wrapper:GO('fixText').text = client.tools.formatColor(str,const.brokenColor);
		end

	end

	function EquipFloat.UpdateRecoveryTime( )
		--只有自己的装备才显示修复时间
		if showType == "self" and equip ~= nil and equip.recoveryTime ~= 0 then
			EquipFloat.SetBrokenText(equip, this:GO("content.equip1.Broken"));
		end

		if showType == "self" and equip2 ~= nil and equip2.recoveryTime ~= 0 then
			EquipFloat.SetBrokenText(equip2, this:GO("content.equip2.Broken"));
		end
	end

	function EquipFloat.SetBaseInfo(sid, quality, enhance, flag, wrapper)
		wrapper.gameObject:SetActive(true);
		--装备名字(+强化等级)
		local equipCfg = tb.EquipTable[sid];
		local name = equipCfg.show_name;
		if enhance ~= nil and enhance.level > 0 then
			name = name .. "+" ..enhance.level;
		end
		local nameStr = client.tools.formatColor(name, const.qualityColor[quality + 1]);
		wrapper:GO('Name').text = nameStr;

		--部位
		wrapper:GO('Part.Value').text = const.BuWei[equipCfg.buwei];
		--等级
		wrapper:GO('Level').text = "等级：";
		if DataCache.myInfo.level < equipCfg.level then

			wrapper:GO('Level.Value').text = string.format("<color=#ee3131>%s级</color>", equipCfg.level);
		else

			wrapper:GO('Level.Value').text = equipCfg.level.."级";
		end

		--slot

		local slot = CreateSlot(wrapper:GO("BagItem").gameObject);
		slot.reset();



		slot.setIcon(equipCfg.icon);
        slot.setQuality(quality);
		-- slot.setLevel(equipCfg.level);
        if flag ~= commonEnum.EquipFlag.none then
           	slot.setWear(commonEnum.EquipFlagSprite[flag]) 
        end
	end

	function EquipFloat.SetBaseAttr(sid, quality, wrapper, equip)
		wrapper.gameObject:SetActive(true);
		--装备基础属性
		local equipCfg = tb.GetTableByKey(tb.baseAttrTable, {sid, quality});

        --local color = const.qualityColor[quality + 1];

        -- 先隐藏锻造进度
		wrapper:GO('Attr3').gameObject:SetActive(false);
		if equipCfg.phyAttackMin ~= 0 and equipCfg.phyAttackMax ~= 0 then 
			wrapper:GO('Attr1').text = "攻击";
			wrapper:GO('Attr1.Value').text = string.format("+%s~%s", equipCfg.phyAttackMin, equipCfg.phyAttackMax);
			wrapper:GO('Attr2').gameObject:SetActive(false);
		end

		if equipCfg.phyDefense ~= 0 then
			wrapper:GO('Attr1').text = "防御";
			wrapper:GO('Attr1.Value').text = string.format("+%s",equipCfg.phyDefense);
		end

		if equipCfg.maxHP ~= 0 then 
			wrapper:GO('Attr2').text = "生命";
			wrapper:GO('Attr2.Value').text = string.format("+%s", equipCfg.maxHP);
		end

		-- 40级以上橙装显示锻造进度及锻造增加属性
		if equip ~= nil and equip.level >= 40 and equip.quality == 4 then
			if type(equip.forgeAttr) == "table" then
				local forgeAttrCfg = tb.GetTableByKey(tb.EquipForgeAttrTable,{equip.level,equip.forgeAttr[1], equip.buwei})
				if equip.forgeAttr[1] > 0 then
					if equipCfg.phyAttackMin ~= 0 then
						wrapper:GO('Attr1.Value').text = string.format("+%s~%s<color=#2be42f>(+%s)</color>", equipCfg.phyAttackMin, equipCfg.phyAttackMax, forgeAttrCfg.hit_value);
					else
						wrapper:GO('Attr1.Value').text = string.format("+%s<color=#2be42f>(+%s)</color>",equipCfg.phyDefense, forgeAttrCfg.defense_value);
					end
					wrapper:GO('Attr2.Value').text = string.format("+%s<color=#2be42f>(+%s)</color>", equipCfg.maxHP, forgeAttrCfg.hp_value);
				end
				wrapper:GO('Attr3').gameObject:SetActive(true);
				if equip.forgeAttr[1] == tb.MaxForgeLevelTable[equip.level] then
					wrapper:GO('Attr3').text = "锻造等级"..equip.forgeAttr[1].."  已满级";
				else
					wrapper:GO('Attr3').text = "锻造等级"..equip.forgeAttr[1].."  进度"..equip.forgeAttr[2].."/"..forgeAttrCfg.next_level_value;
				end
			end
		end
	end


	function EquipFloat.SetAddAttr(equip, wrapper)
		wrapper.gameObject:SetActive(true);
		--装备附加属性
		local addAttr;
		--[[table.sort(equip.addAttr,
			function (a,b)
				if a[3] ~= b[3] then
					return a[3] > b[3]
				end
				return false
			end)]]
		for i = 1, #equip.addAttr do
			addAttr = equip.addAttr[i];
			if type(addAttr[1]) ~= "string" then
				addAttr[1] = client.tools.ensureString(addAttr[1]);
			end
			local attrName = addAttr[1];
			local attrValue = addAttr[2];
			local quality = addAttr[3];
			if quality == nil then
				quality = 0;
			end
			local color = const.qualityColor[quality + 1];
			local isPercent = const.ATTR_PERCENT[attrName];
			local attr_value = isPercent and (attrValue * 100).."%" or attrValue;
			wrapper:GO('Attr' .. i .. ".Value").text = string.format("<color=%s>%s</color>", color, const.ATTR_NAME[attrName].."   +"..attr_value);
		end	
		for i = #equip.addAttr + 1, 6 do
			wrapper:GO('Attr' .. i).gameObject:SetActive(false);
		end
	end

	--部位属性
	function EquipFloat.SetPartAttr(enhance, gemList, wrapper)
		--设置强化属性
		local equipCfg = tb.EquipTable[equip.sid];
		local enhanceTable = nil;
		if equipCfg ~= nil and enhance ~= nil and enhance.level > 0 then
			enhanceTable = tb.GetTableByKey(tb.EnhanceTable, {equipCfg.career, equipCfg.buwei, enhance.level});
		end

		if enhanceTable ~= nil and enhanceTable.attr_value > 0 then
			local attr_name = const.ATTR_NAME[enhanceTable.attr_type];
			wrapper:GO("QiangHuaAttr.Value").text = attr_name.."   +"..enhanceTable.attr_value;
			wrapper:GO("QiangHuaAttr").gameObject:SetActive(true);
		else
			wrapper:GO("QiangHuaAttr").gameObject:SetActive(false);
		end


		--设置宝石属性
		wrapper:GO("GemAttr").gameObject:SetActive(gemList ~= nil and #gemList > 0);
		if gemList ~= nil then
			for i=1, #gemList do
				local gem = gemList[i];
				if gem then
					local table = tb.GemTable[gem.sid]; 
					wrapper:GO("GemAttr.Attr"..i..".Gem").sprite = table.icon;
					local attr_name = const.ATTR_NAME[table.add_attr_type];
					local isPercent = const.ATTR_PERCENT[table.add_attr_type];
					local attr_value = isPercent and (table.add_attr_value * 100).."%" or table.add_attr_value;
					wrapper:GO("GemAttr.Attr"..i..".Value").text = string.format("<color=%s>%s</color>", const.qualityColor[table.quality + 1], attr_name.."   +"..attr_value);
				else
					wrapper:GO("GemAttr.Attr" .. i).gameObject:SetActive(false);
				end
			end

			for i = #gemList + 1, 4 do
				wrapper:GO("GemAttr.Attr" .. i).gameObject:SetActive(false);
			end
		end
		
		local show = wrapper:GO("QiangHuaAttr").gameObject.activeSelf or wrapper:GO("GemAttr").gameObject.activeSelf;
		wrapper.gameObject:SetActive(show);
	end

	function EquipFloat.SetUnidentify()
		local equipCfg = tb.EquipTable[equip.sid];
		local wrapper = this:GO('content.equip1.Unidentify');
		wrapper.gameObject:SetActive(true);
		--鉴定花费
		wrapper:GO("cost.value").text = tb.equip_identify[equip.sid].identify_cost;
		wrapper:GO("title").text = "鉴定后可获得一个本职业随机品质\n"..const.BuWei[equipCfg.buwei]

		--鉴定等级
		if DataCache.myInfo.level < equipCfg.level then
			wrapper:GO('level.value').text = string.format("<color=#ee3131>%s</color>", equipCfg.level);
		else
			wrapper:GO('level.value').text = equipCfg.level;
		end

		wrapper = this:GO('content.equip1.Info');
		wrapper.gameObject:SetActive(true);
		--装备名字
		wrapper:GO('Name').text = client.tools.formatColor(equipCfg.show_name, const.qualityColor[equip.quality + 1]);
		--部位
		-- wrapper:GO('Part.Value').text = const.BuWei[equipCfg.buwei];
		wrapper:GO('Part'):Hide();

		--数量
		wrapper:GO('Level').text = "拥有：";
		local count = 1;
		if equip.count ~= nil then
			count = equip.count;
		end
		wrapper:GO('Level.Value').text = string.format("<color=#5d7af7>%s</color>",count);

		this:GO('content.equip1.Button.line').gameObject:SetActive(false);
		--slot
		local slot = CreateSlot(wrapper:GO("BagItem").gameObject);
		slot.reset();



		slot.setQuality(0);
        slot.setIcon(equipCfg.icon);
		-- slot.setLevel(equipCfg.level);
		slot.setWeiJianDing(commonEnum.EquipFlagSprite[commonEnum.EquipFlag.identify]);
	end 

	function EquipFloat.SetSuit(equip,equipMap,wrapper,top)
		-- suitId ~= 0 在外部判断
		wrapper.gameObject:SetActive(true);




		-- 点击身上穿戴的装备，若有套装属性，套装属性位于equip2上，置顶，要隐藏line,显示空行
		wrapper:GO('line').gameObject:SetActive(not top);
		wrapper:GO('empty').gameObject:SetActive(top);

		-- 身上穿戴的套装
		local suitId = tb.EquipTable[equip.sid].suitId;
		local suitEquipTab = tb.SuitEquipTable[suitId][equip.career];		-- DataCache.myInfo.career
		local suitAttrTab = tb.SuitTable[suitId];

		local count = 0;
		-- 显示当前穿戴的套装,并计算数量
		local j=1;
		for i=1,#suitEquipTab do
			wrapper:GO('SuitCount.Suit'..j).gameObject:SetActive(true);
			wrapper:GO('SuitCount.Suit'..j..'.Value').text = tb.EquipTable[suitEquipTab[i]].show_name;
			if equipMap[suitEquipTab[i]] == true then
				setColor(wrapper:GO('SuitCount.Suit'..j),true);
				count = count + 1;
			else
				setColor(wrapper:GO('SuitCount.Suit'..j),false);
			end
			if #suitEquipTab <6 then
				-- 如果为三件套，隐藏suitAttr 2、4、6
				wrapper:GO('SuitCount.Suit'..j+1).gameObject:SetActive(false);
				j = j + 2;
			else
				j = j + 1;
			end
		end
		-- 设置当前穿戴件数

		wrapper:GO('SuitCount.text').text = string.format("套装（<color=#F69800>%s</color>）",count..'/'..#suitEquipTab);
		-- 设置套装属性
		j = 1;
		for k, v in ipairs(suitAttrTab) do
			local textObj = wrapper:GO('SuitAttr.Attr'..j..'.Value');
			if v.amount <= count then 

				textObj.text = string.format("<color=#FFDB9C>%s</color>", v.amount..'件：'..const.ATTR_NAME[v.suitAttr].."+"..v.value);
			else

				textObj.text = string.format("<color=#727272>%s</color>", v.amount..'件：'..const.ATTR_NAME[v.suitAttr].."+"..v.value);
			end
			j = j + 1;
		end
		while j <= 4 do
			wrapper:GO('SuitAttr.Attr'..j).gameObject:SetActive(false);
			j = j + 1;
		end
	end

	function EquipFloat.Start()
		this = EquipFloat.this;	
		this:BindLostFocus(closeSelf);
		EquipFloat.SetContent();	
		EventManager.bind(this.gameObject, Event.ON_TIME_SECOND_CHANGE,EquipFloat.UpdateRecoveryTime);

		--初始时先把界面移出屏幕外，防止界面在设置坐标时突然闪一下
		local rt = this:GO('content'):GetComponent("RectTransform");
		rt.anchoredPosition = Vector2.New(10000, 10000)
	end

	function EquipFloat.FirstUpdate( )
		if param.isScreenCenter then
			local rt = this:GO('content'):GetComponent("RectTransform");
			rt.pivot = Vector2.New(0.5, 0.5);
			rt.anchoredPosition = Vector2.New(0,0)
		else
			EquipFloat.fixPos();
		end
	end

	--根据点击的坐标
	function EquipFloat.fixPos()
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

	function EquipFloat.Reset()


		--隐藏对比界面
		this:GO("content.equip2").gameObject:SetActive(false);
		this:GO("content.equip2.BaseAttr").gameObject:SetActive(false);
		this:GO("content.equip2.AddAttr").gameObject:SetActive(false);
		this:GO("content.equip2.PartAttr").gameObject:SetActive(false);
		this:GO("content.equip2.Broken").gameObject:SetActive(false);
		this:GO("content.equip2.RandomAttr").gameObject:SetActive(false);
		this:GO("content.equip2.Unidentify").gameObject:SetActive(false);
		this:GO("content.equip2.Button").gameObject:SetActive(false);
		this:GO("content.equip2.XilianTips").gameObject:SetActive(false);
		this:GO("content.equip2.Suit").gameObject:SetActive(false);
		--隐藏不显示的界面
		this:GO("content.equip1.BaseAttr").gameObject:SetActive(false);
		this:GO("content.equip1.AddAttr").gameObject:SetActive(false);
		this:GO("content.equip1.PartAttr").gameObject:SetActive(false);
		this:GO("content.equip1.Broken").gameObject:SetActive(false);
		this:GO("content.equip1.RandomAttr").gameObject:SetActive(false);
		this:GO("content.equip1.Unidentify").gameObject:SetActive(false);
		this:GO("content.equip1.Button").gameObject:SetActive(false);
		this:GO("content.equip1.XilianTips").gameObject:SetActive(false);
		this:GO("content.equip1.Suit").gameObject:SetActive(false);
	end

	function EquipFloat.SetContent()
		EquipFloat.Reset();
		--设置显示内容

		--装备标志（已装备，已损坏等）
		local equipFlag = commonEnum.EquipFlag.none;
		if showType == "self" then

			if equip.quality == const.quality.unidentify then
				-- 未鉴定
				local buttonData = {Left = {{name = "出  售",fun = SaleEquip}, 
											--[[{name = "上  架",fun = tradeEquip} NSY-4740 屏蔽]]},
									Right = {{name = "鉴  定",fun = IdentifyEquip}}
								}
				ui.SetFloatButton(this:GO("content.equip1.Button"), buttonData)
				EquipFloat.SetUnidentify();
			else

				--筛选显示的内容
				if param.subType == "bag" then 
					-- 代表从背包点开的

					local buttonData = {Left = {{name = "出  售",fun = SaleEquip}},
									Right = {{name = "装  备",fun = processWear}}
								}
					ui.SetFloatButton(this:GO("content.equip1.Button"), buttonData)
					if equip.biaoshi == const.biaoshi.CouldWear then
						this:GO("content.equip1.Button.Right.btn1"):PlayUIEffectForever(this.gameObject, "anniufaguang");
					end

					local tblOutParamXiLian = {};
					local couldZhuanyi = client.equip.CouldZhuanyi(equip);
					local couldXilian = client.equip.CouldXilian(equip, tblOutParamXiLian);
					local couldWear = client.equip.showWearFlag(equip);
					local bBottomTextTip = false; --尾部文字提示

					-- 整理一下
					if DataCache.myInfo.level >= equip.level then
						buttonData = {};
						-- 先确定转移按钮,再决定洗练
						if (couldZhuanyi or couldWear) then
							buttonData.Left = {{name = "转  移",fun = processZhuanyi}};
						-- 从背包点开，身上穿有40级以上橙装
						elseif equip2 ~= nil and equip2.quality ==4 and equip2.level >= 40 then
							buttonData.Left = {{name = "锻  造",fun = processForge}};
						end

						--
						if couldXilian then
							buttonData.Right = {{name = "洗  炼",fun = processXiLian}};
						else
							-- 还需要加文字提示
							if tblOutParamXiLian.err == 1 then
								bBottomTextTip = true;
							end
						end

						-- 如果没有配置就不需要设置按钮了
						if buttonData.Left ~= nil or buttonData.Right ~= nil  then
							ui.SetFloatButton(this:GO("content.equip2.Button"), buttonData);
						else
							if bBottomTextTip then
								this:GO("content.equip2.XilianTips").gameObject:SetActive(true);
							end
						end

						if equip.biaoshi == const.biaoshi.CouldXilian then
							this:GO("content.equip2.Button.Right.btn1"):PlayUIEffectForever(this.gameObject, "anniufaguang");
						elseif equip.biaoshi == const.biaoshi.CouldZhuanyi then
							this:GO("content.equip2.Button.Left.btn1"):PlayUIEffectForever(this.gameObject, "anniufaguang");
						end
					end

					--[[if equip.quality > const.quality.green then
						if DataCache.myInfo.level >= equip.level then
							buttonData = {};

							-- 如果是白装、绿装,还需要加文字提示
							--print(equip.quality, Bag.getWearEquip(equip.buwei).quality, couldXilian, couldZhuanyi)

							if couldXilian then
								buttonData.Right = {{name = "洗  炼",fun = processXiLian}};
							else
								-- 还需要加文字提示
								if tblOutParamXiLian.err == 1 then
									bBottomTextTip = true;
								end
							end

							if (couldZhuanyi or couldWear) and couldXilian then
								buttonData.Left = {{name = "转  移",fun = processZhuanyi}};

							-- 从背包点开，身上穿有40级以上橙装
							elseif equip2 ~= nil and equip2.quality ==4 and equip2.level >= 40 then
								buttonData.Left = {{name = "锻  造",fun = processForge}};
							end

							-- 如果没有配置就不需要设置按钮了
							if buttonData.Left ~= nil or buttonData.Right ~= nil  then
								ui.SetFloatButton(this:GO("content.equip2.Button"), buttonData);
							else
								if bBottomTextTip then
									this:GO("content.equip2.XilianTips").gameObject:SetActive(true);
								end
							end
							
							if equip.biaoshi == const.biaoshi.CouldXilian then
								this:GO("content.equip2.Button.Right.btn1"):PlayUIEffectForever(this.gameObject, "anniufaguang");
							elseif equip.biaoshi == const.biaoshi.CouldZhuanyi then
								this:GO("content.equip2.Button.Left.btn1"):PlayUIEffectForever(this.gameObject, "anniufaguang");
							end
						end
					else
						-- 从背包点开，背包中装备为白绿装，身上穿有40级以上橙装
						if equip2 ~= nil and equip2.quality ==4 and equip2.level >= 40 then
							buttonData = {}
							buttonData.Left = {{name = "锻  造",fun = processForge}};
							ui.SetFloatButton(this:GO("content.equip2.Button"), buttonData);
							this:GO("content.equip2.XilianTips").gameObject:SetActive(false);
						else
							this:GO("content.equip2.XilianTips").gameObject:SetActive(false);
						end

					end--]]

				elseif param.subType == "wear" then
					--已装备标志
					equipFlag = commonEnum.EquipFlag.Wear;
					--设置强化属性，宝石属性
					EquipFloat.SetPartAttr(enhance, gemList, this:GO("content.equip1.PartAttr"))

					-- 从装备列表打开的 40级以上橙装显示锻造按钮
					if param.base.level >= 40 and param.base.quality == 4 then
						local buttonData = {}
						buttonData.Right = {{name = "锻  造",fun = processForge}};
						ui.SetFloatButton(this:GO("content.equip1.Button"), buttonData);
					end
				end	

				--设置装备信息
				EquipFloat.SetBaseInfo(equip.sid, equip.quality, enhance, equipFlag,this:GO("content.equip1.Info"))
				EquipFloat.SetBaseAttr(equip.sid, equip.quality, this:GO("content.equip1.BaseAttr"), equip)
				EquipFloat.SetAddAttr(equip, this:GO("content.equip1.AddAttr"));
				if equip.quality == 4 then 
					-- equip2 为nil 可能情况包括 从装备列表点开悬浮和从背包点开悬浮但当前部位未穿戴
					if tb.EquipTable[equip.sid].suitId ~= 0 and equip2 == nil then
						local putOnEquip = Bag.wearList[equip.buwei];
						-- 身上未穿装备(从背包中点开)
						if putOnEquip == nil then 
							EquipFloat.SetSuit(equip, client.suit.getEquipMap(), this:GO("content.equip1.Suit"),false);
						else
							-- 身上穿了装备(从装备列表中点开)
							this:GO("content.equip2").gameObject:SetActive(true);
							this:GO("content.equip2.Info").gameObject:SetActive(false);
							EquipFloat.SetSuit(equip, client.suit.getEquipMap(), this:GO("content.equip2.Suit"),true);
						end
					elseif tb.EquipTable[equip.sid].suitId ~= 0 then 
						EquipFloat.SetSuit(equip, client.suit.getEquipMap(), this:GO("content.equip1.Suit"),false);
					end	
				end
				
		
				--设置对比装备信息
				if equip2 ~= nil then
					--如果正在修复显示已损坏，否则显示已装备

					local equipFlag = equip2.recoveryTime ~= 0 and commonEnum.EquipFlag.Broken or commonEnum.EquipFlag.Wear;
					this:GO("content.equip2").gameObject:SetActive(true);
					EquipFloat.SetBaseInfo(equip2.sid, equip2.quality, enhance, equipFlag,this:GO("content.equip2.Info"))
					EquipFloat.SetBaseAttr(equip2.sid, equip2.quality, this:GO("content.equip2.BaseAttr"), equip2)
					EquipFloat.SetAddAttr(equip2, this:GO("content.equip2.AddAttr"));

					if equip2.quality == 4 and tb.EquipTable[equip2.sid].suitId ~= 0 then 
						EquipFloat.SetSuit(equip2, client.suit.getEquipMap(), this:GO("content.equip2.Suit"),false);
					end
				end
			end
		elseif showType == "show" then
			if equip.quality == const.quality.unidentify then
				EquipFloat.SetUnidentify();
			else
				EquipFloat.SetBaseInfo(equip.sid, equip.quality, enhance, equipFlag,this:GO("content.equip1.Info"))
				EquipFloat.SetBaseAttr(equip.sid, equip.quality, this:GO("content.equip1.BaseAttr"), equip)
				EquipFloat.SetAddAttr(equip, this:GO("content.equip1.AddAttr"));
				EquipFloat.SetPartAttr(enhance, gemList, this:GO("content.equip1.PartAttr"))
			end
			if equip.quality == 4 then 
				-- equip2 为nil 可能情况包括 从装备列表点开悬浮和从背包点开悬浮但当前部位未穿戴
				if tb.EquipTable[equip.sid].suitId ~= 0 then
					-- 身上穿了装备(从装备列表中点开)
					this:GO("content.equip2").gameObject:SetActive(true);
					this:GO("content.equip2.Info").gameObject:SetActive(false);
					EquipFloat.SetSuit(equip, param.equipMap, this:GO("content.equip2.Suit"),true);
				else
					EquipFloat.SetSuit(equip, param.equipMap, this:GO("content.equip1.Suit"),false);
				end	
			end
		elseif showType == "random" then
			EquipFloat.SetBaseInfo(param.sid, param.quality, enhance, equipFlag, this:GO("content.equip1.Info"))
			EquipFloat.SetBaseAttr(param.sid, param.quality, this:GO("content.equip1.BaseAttr"))
			this:GO("content.equip1.RandomAttr").gameObject:SetActive(true);
		end

	end

	
	function EquipFloat.OnDestroy( )

	end



	return EquipFloat;
end