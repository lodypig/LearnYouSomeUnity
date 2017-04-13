tb.EquipGemTable =  {
	[1] =  2,
	[2] =  3,
	[5] =  5,
	[6] =  4,
	[9] =  1,
	[3] =  7,
	[4] =  9,
	[7] =  8,
	[8] =  10,
	[10] =  6
}


tb.GemEquipTable =  {
	[2] =  1,
	[3] =  2,
	[5] =  5,
	[4] =  6,
	[1] =  9,
	[7] =  3,
	[9] =  4,
	[8] =  7,
	[10] =  8,
	[6] =  10
}


---- 写几个装备通用接口,借用个地方
_equip_kit = {
	
	-- 参数1: equip 某实际装备数据
	-- 参数2: equipCfg 这件装备对应 equipTable.lua中的配置
	-- 返回值 : 价格(number)
	get_equip_price = function(equip, equipCfg)
		if nil == equip or nil == equipCfg then	return 0;	end

		if nil == equip.quality then
			print("_Equip_Kit:get_equip_price ==> equip.quality 为 nil !"); --必要的打印提示,防止查脚本各种蛋疼
			return 0;
		end

		if 0 == equip.quality then
			return equipCfg.price or 0
		elseif 1 == equip.quality then
			return equipCfg.price1 or 0
		elseif 2 == equip.quality then
			return equipCfg.price2 or 0
		elseif 3 == equip.quality then
			return equipCfg.price3 or 0
		elseif 4 == equip.quality then
			return equipCfg.price4 or 0
		elseif 5 == equip.quality then
			return equipCfg.price5 or 0
		elseif 6 == equip.quality then
			return equipCfg.price6 or 0
		else 
			return 0;
		end
	end,
}