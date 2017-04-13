function xilianView (param)
	local xilian = {};
	local this = nil;
	local srcEquip;
	local dstEquip;
	local srcEquipTab;
	local dstEquipTab;
	local srcBaseAttrTab;
	local dstBaseAttrTab;
	local leftMin = {index = nil,value = nil};
	local rightMax = {index = nil,value = nil};
	local leftObj;
	local rightObj;
	-- 记录上一次左右装备附加属性选中的序号，当为0时表示上次未选中任一栏
	local leftIndex = 0;
	local rightIndex = 0;
	-- 洗炼所需金钱
	local needMoney;
	-- 标志抽奖动画是否播放，当动画播放时，所有的buttonClick和loseFocus事件不能响应
	local signal = false;

	-- local anImage = {
	-- 	'an_xuanzhongyuan_1',
	-- 	'an_xuanzhongyuan_2',
	-- };

	-- 抽取特效存储的变量
	local stopIndex;	-- 最终停在哪一栏
	local index = 1; -- 当前亮区位置
	local time = 0.1;   -- 初始速度
	local endIndex = 2;   -- 决定在哪一格变慢
	local cycle = 1;	-- 记录当前圈数 
	local endCycle = 3;   -- 设定加速转动圈数
	local flag = false;   -- 结束转动标志 
	local quick = 0;   -- 定义启动到加速步数

	-- 计算右侧装备附加属性 在左侧装备中的品质
	local getAttrQuality = function(sid, attr, value)
		local quality = 4;
		local range;
		while quality >= 1 do
			local equipAttrInfo = tb.GetTableByKey(tb.AttrQualityTable, {sid, quality})
			if equipAttrInfo ~= nil then
				range = tb.GetTableByKey(tb.AttrQualityTable, {sid, quality})[attr];
				if value >= range[1] then
					return quality;
				end
			end
			quality = quality - 1;
		end
		return quality;
	end

	-- 交换上一次选中栏和当前选中栏的显示效果，若上一次未选择任何一栏，只设置当前栏的选中效果
	local function swapState(oldIndex,newIndex,equipObj,type)
		local wrapper = equipObj:GetComponent('UIWrapper');
		local tempAttr;
		if(oldIndex ~= 0) then
			wrapper:GO('_addAttr._attr'..oldIndex..'._xuanzhongkuang').gameObject:SetActive(false);
			-- 左边选中时需要设置按钮的选中色
			if type == 0 then
				wrapper:GO('_addAttr._attr'..oldIndex..'._an2'):Hide();

			end
		end
		wrapper:GO('_addAttr._attr'..newIndex..'._xuanzhongkuang').gameObject:SetActive(true);
		if type == 0 then
			wrapper:GO('_addAttr._attr'..newIndex..'._an2'):Show();
		end
	end

	-- 抽取右侧装备附加属性动画
	-- 第一圈慢速，然后开始快速三圈，第五圈慢速，第六圈走到停止位时终止
	local function show(callback)
		if(index > #srcEquip.addAttr) then
			index = 1;
			cycle = cycle +1;
		end
		if(flag == false) then
			-- 第一圈慢速走完，第二圈开始快速
			if(quick >= #srcEquip.addAttr) then
				time = 0.1;
			end
			-- 在第endCycle+1圈时，走到第endIndex栏时开始减速
			if(cycle == endCycle and index == endIndex) then
				time = 0.1;
				flag = true;
			end
		end
		this:Delay(time,function ()
			swapState(rightIndex,index,rightObj,1)
			rightIndex = index;
			quick = quick + 1;
			index = index + 1;
			-- 当出现结束标志，并且处于第六圈，走到停止位时递归终止
			if(flag ~= true or index-1 ~= stopIndex or cycle ~= endCycle +1) then
				show(callback);
			else
				this:Delay(0.2,function ()
					callback();
				end);
			end
		end);
	end

	-- 装备的基本属性包括三种，有两种显示方式，分别是"攻击 +数值"和"生命  +数值    防御  +数值"
	local handleText = function (tab)
		local text = "";
		if(tab.phyAttackMin ~= 0) then
			text = text..'攻击  +'..tab.phyAttackMax;
		end
		if(tab.maxHP ~= 0) then
			text = text..'生命  +'..tab.maxHP..'\n';
		end
		if(tab.phyDefense ~= 0) then
			text = text..'防御  +'..tab.phyDefense;
		end
		return text;
	end

	-- 初始化左右两侧装备的附加属性，有6种，处理方式不同，左侧的属性若不足6种，为空的显示"(空属性)"，右侧为空则不显示
	local setLeftAddAttr = function ()
		local tempObj;
		local addAttr;
		for i = 1,6 do
			tempObj = this:GO("_content._leftEquip._addAttr._attr"..i);
			local wrapper = tempObj:GetComponent("UIWrapper");
			local text = wrapper:GO('_text');
			local _xuanzhongkuang = wrapper:GO('_xuanzhongkuang').gameObject;
			local _an2 = wrapper:GO('_an2');
			local _tuijian = wrapper:GO('_tuijian').gameObject;

			--附加属性现在有6条，是一个table，一共6个属性栏，没有的部分填空属性，属性值如何对应属性颜色？
			if (i <= #dstEquip.addAttr)  then
				addAttr = dstEquip.addAttr[i];

				text.text = string.format("<color=%s>%s</color>",const.qualityColor[addAttr[3] + 1],const.ATTR_NAME[addAttr[1]].."  +"..addAttr[2]); 
				-- text.text = const.ATTR_NAME[addAttr[1]].."  +"..addAttr[2];
				
				if(#dstEquip.addAttr == 6 and i == leftMin.index and leftMin.value < rightMax.value) then
					_xuanzhongkuang:SetActive(true);
					_tuijian:SetActive(true);
					_an2:Show();
					leftIndex = i;
				end 
			else
				if(i == #dstEquip.addAttr +1) then
					_xuanzhongkuang:SetActive(true);
					_tuijian:SetActive(true);
					_an2:Show()
					leftIndex = i;
					text.text = "(空属性)";
				else
					tempObj:Hide();
				end
			end
			wrapper:BindButtonClick(function ()
				if(signal == false) then
					if(i ~= leftIndex) then
						swapState(leftIndex,i,leftObj,0);
						leftIndex = i;
					end
				end
			end);
		end
	end

	local setRightAddAttr = function ()
		local tempObj;
		local addAttr;
		this:GO("_content._rightEquip._addAttr._attr1._xuanzhongkuang").gameObject:SetActive(true);
		for i = 1,6 do
			tempObj = this:GO("_content._rightEquip._addAttr._attr"..i);
			local wrapper = tempObj:GetComponent("UIWrapper");
			local text = wrapper:GO('_text');

			if (i <= #srcEquip.addAttr)  then
				addAttr = srcEquip.addAttr[i];
				text.text = string.format("<color=%s>%s</color>",const.qualityColor[getAttrQuality(dstEquip.sid, addAttr[1], addAttr[2]) + 1],const.ATTR_NAME[addAttr[1]].."  +"..addAttr[2]); 
				-- text.text = const.ATTR_NAME[addAttr[1]].."  +"..addAttr[2]; 
			else
				wrapper.gameObject:SetActive(false);
			end
		end
	end

	-- 寻找左右附加属性列表中左边附加属性的最小值及其序号,右边的最大值及其序号
	local findLeftMin = function ()
		local value = dstEquip.addAttr[1][2] * tb.AttrFPointTable[dstEquip.addAttr[1][1]];
		local index = 1;
		for i = 2,#dstEquip.addAttr do
			local addAttr = dstEquip.addAttr[i];
			local weight = tb.AttrFPointTable[addAttr[1]];
			if addAttr[2] * weight < value then 
				index = i;
				value = addAttr[2] * weight;
			end
		end
		leftMin.index = index;
		leftMin.value = value;
	end

	local findRightMax = function ()
		local value = srcEquip.addAttr[1][2] * tb.AttrFPointTable[srcEquip.addAttr[1][1]];
		local index = 1;

		for i = 2,#srcEquip.addAttr do
			local addAttr = srcEquip.addAttr[i];
			local weight = tb.AttrFPointTable[addAttr[1]];
			if addAttr[2] * weight > value then 
				index = i;
				value = addAttr[2] * weight;
			end
		end
		rightMax.index = index;
		rightMax.value = value;
	end

	
	local init = function ()
		this:GO('_content._leftEquip._top._tubiao._frame').sprite = const.QUALITY_BG[dstEquip.quality + 1];
		this:GO('_content._leftEquip._top._tubiao._icon').sprite = dstEquipTab.icon;			
		this:GO('_content._leftEquip._top._tubiao.level').text = dstEquipTab.level;			
		this:GO('_content._leftEquip._top._title').text = string.format("<color=%s>%s</color>",const.qualityColor[dstEquip.quality + 1],dstEquipTab.show_name);
		this:GO('_content._leftEquip._top._level').text = "等级  "..dstEquipTab.level.."级";
		this:GO('_content._leftEquip._top._baseAttr').text = handleText(dstBaseAttrTab);

		this:GO('_content._rightEquip._top._tubiao._frame').sprite = const.QUALITY_BG[srcEquip.quality + 1];
		this:GO('_content._rightEquip._top._tubiao._icon').sprite = srcEquipTab.icon;
		this:GO('_content._rightEquip._top._tubiao.level').text = srcEquipTab.level;			
		this:GO('_content._rightEquip._top._title').text = string.format("<color=%s>%s</color>",const.qualityColor[srcEquip.quality + 1],srcEquipTab.show_name);
		this:GO('_content._rightEquip._top._level').text = "等级  "..srcEquipTab.level.."级";
		this:GO('_content._rightEquip._top._baseAttr').text = handleText(srcBaseAttrTab);

		setLeftAddAttr();
		setRightAddAttr();
		this:GO('_content._cost._value').text = tb.PurifyCostTable[srcEquipTab.level];
	end

	-- 增加特殊引导的一个标识，传给服务端进行特殊处理,Special = true 时即为引导时的特殊处理
	local sendXiLian = function (Special)
		local msg = { cmd = "equip/purify" , bag_index = srcEquip.pos, selected_add_attr = leftIndex, sid = Special};
		Send(msg, function(msg)
			-- 接收服务端发来的结束索引
			stopIndex = msg.index;
			signal = true;
			show(function () 
				-- 传递两个参数给xilianSuccess,一个是新的从服务端接受的新装备newEquip,一个是玩家选择替换的属性索引leftIndex,newEquip.temp_attr作为新属性,newEquip.addAttr[leftIndex]作为原属性
				local param = {equip = client.equip.parseEquip(msg.new_equip),index = leftIndex};
				-- 选中洗炼的条目之后，播放洗炼特效，同时将装备的icon渐隐
				this:GO('_content._rightEquip._top._tubiao'):PlayUIEffect( this.gameObject, "xilian", 0.5 );
				iTween.FadeTo(this:GO('_content._rightEquip._top._tubiao._icon').gameObject, 0 ,0.5);
				this:Delay(0.6,function ()
					ui.ShowXiLianSuccess(param);
					destroy(this.gameObject);
				end)
			end);
		end);

	end

	function xilian.Start()
		this = xilian.this;
		-- equip中包括sid,level,quality,buwei,addAttr,pos,id
		-- equipTable中包括level,show_name,icon,buwei
		srcEquip = param;
		dstEquip = Bag.getWearEquip(srcEquip.buwei);

		srcEquipTab = tb.EquipTable[srcEquip.sid];
		dstEquipTab = tb.EquipTable[dstEquip.sid];
		srcBaseAttrTab = tb.GetTableByKey(tb.baseAttrTable, {srcEquip.sid, srcEquip.quality});
		dstBaseAttrTab = tb.GetTableByKey(tb.baseAttrTable, {dstEquip.sid, dstEquip.quality});

		leftObj = this:GO('_content._leftEquip');
		rightObj = this:GO('_content._rightEquip');
		findLeftMin();
		findRightMax();
		init();

		needMoney = tb.PurifyCostTable[srcEquipTab.level];
		this:GO('_content._btn'):GetComponent('UIWrapper'):BindButtonClick(function ()
			if(signal == false) then
				if(leftIndex <= 0 or leftIndex > 6) then
					ui.showMsg("请选择一个属性进行洗炼");
				elseif (needMoney > DataCache.role_money) then
					ui.showBuyMoney()
				else
					sendXiLian(srcEquip.sid);
				end
			end

		end);

		this:GO('blank'):GetComponent('UIWrapper'):BindButtonClick(function ()
			if(signal == false) then
				destroy(this.gameObject);
			end
		end);
	end
	return xilian;
end

--param 接收equip,也就是srcEquip,然后根据部位获取dstEquip
ui.ShowXiLian = function (param) 
	PanelManager:CreateConstPanel('xilian',UIExtendType.BLACKCANCELMASK,param);
	-- PanelManager:CreatePanel("ui", "xilian", param);
end