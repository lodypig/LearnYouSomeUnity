const.str.horse_lock = "未解锁"
const.str.horse_level = {
	"（1阶）",
	"（2阶）",
	"（3阶）",
	"（4阶）",
	"（5阶）",
	"（6阶）",
	"（7阶）",
	"（8阶）",
	"（9阶）",
	"（10阶）"
}

CreateHorseItem = function (go) 
	local Controller = {};
	local slot = go:GetComponent("UIWrapper");	
	Controller.wrapper = slot;	

	local spFlag = slot:GO("_spFlag");
	local tfName = slot:GO("_tfName");
	local tfEnhanceLv = slot:GO("_tfEnhanceLv");
	local spRide = slot:GO("_spRide");
	local spLock = slot:GO("_spLock");
	local spChoose = slot:GO("_spChoose");
	local spNotChoose = slot:GO("_spNotChoose");

	function Controller.SetHorse(horseTable, lock, enhanceLv, ride, flag)
		spFlag.gameObject:SetActive(flag == true);
		spRide.gameObject:SetActive(ride == true);
		spLock.gameObject:SetActive(lock == true);
		local color = lock and const.color.gray or const.color.white1;
		local text = lock and const.str.horse_lock or const.str.horse_level[enhanceLv];
		slot.sprite = horseTable.unselect_icon;
		tfEnhanceLv.text = client.tools.formatColor(text, color);
		tfName.text = client.tools.formatColor(horseTable.show_name, color);
	end

	function Controller.SetChoose(choose)
		spChoose.gameObject:SetActive(choose == true);
		spNotChoose.gameObject:SetActive(choose ~= true);
	end

	function Controller.SelectItem(slot, flag, i, horse)
		local horseTable = client.horse.horseTableCache[i];
		if flag then
			-- 选中
			slot.sprite = horseTable.show_icon;
			if horse ~= nil then
				-- 已解锁
				slot:GO("_tfName").text = client.tools.formatColor(horseTable.show_name, "#f1f1f1ff");
				slot:GO('_tfEnhanceLv').text = client.tools.formatColor(const.str.horse_level[horse.enhance_lv], "#f1f1f1ff");
			else
				-- 未解锁	
				slot:GO('_tfName').text = client.tools.formatColor(horseTable.show_name, "#c9c9c9ff");
				slot:GO('_tfEnhanceLv').text = client.tools.formatColor("未解锁", "#c9c9c9ff");
			end
		else
			slot.sprite = horseTable.unselect_icon;
			if horse ~= nil then
				-- 已解锁
				slot:GO("_tfName").text = client.tools.formatColor(horseTable.show_name, "#afac8dff");
				slot:GO('_tfEnhanceLv').text = client.tools.formatColor(const.str.horse_level[horse.enhance_lv], "#afac8dff");
			else
				-- 未解锁
				slot:GO('_tfName').text = client.tools.formatColor(horseTable.show_name, "#6c6c6dff");
				slot:GO('_tfEnhanceLv').text = client.tools.formatColor("未解锁", "#6c6c6dff");
			end
		end
	end

	return Controller;
end
