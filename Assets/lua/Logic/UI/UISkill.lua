function UISkillView ()
	local UISkill = {};
	local this = nil;
	local RoleFigure = nil;
	local skill1 = nil;
	local skill2 = nil;
	local skill3 = nil;
	local skill4 = nil;
	local desc = nil;
	local levelUpBtn = nil;
	local levelUpAllBtn = nil;
	local expNumb = nil;
	local skills = {};
	local controller = nil;
	local selectIndex = 1;

	function UISkill.Start ()
		this = UISkill.this;
		RoleFigure = this:GO('SkillPanel.3DRole._RoleFigure');
		skill1 = this:GO('SkillPanel.skills._skill1');
		skill2 = this:GO('SkillPanel.skills._skill2');
		skill3 = this:GO('SkillPanel.skills._skill3');
		skill4 = this:GO('SkillPanel.skills._skill4');
		desc = this:GO('SkillInfo._desc');
		levelUpBtn = this:GO('Buttons._levelUpBtn');
		levelUpAllBtn = this:GO('Buttons._levelUpAllBtn');
		expNumb = this:GO('Exp._expNumb');

		-- 设置控制器
		local commonDlgGO = this:GO('CommonDlg');
		UISkill.controller = createCDC(commonDlgGO);
		UISkill.controller.SetButtonNumber(0);
		UISkill.controller.bindButtonClick(0, UISkill.onClose);

		-- RTT
		UISkill.LoadSkillRTT();

		-- 技能升级
		levelUpBtn:BindButtonClick(function ()

			client.skillCtrl.onSkillLevelUp(selectIndex, function (msgTable)
				-- 刷新当前技能
				UISkill.RefreshSelectedSkill();
				-- 刷新经验值
				UISkill.RefreshExp();
				-- 播放升级特效
				UISkill.PlayLevelUpEffect(selectIndex);
			end);
		end);

		-- 全部升级
		levelUpAllBtn:BindButtonClick(function ()

			local count = UISkill.GetNumOfCanLevelUp();

			-- 判断是否有可升级技能
			if count == 0 then
				ui.showMsg("没有可升级技能");
				return;
			end

			-- 升级全部
			UISkill.levelUpAll(function ()

			end);

		end);

		-- 加载技能
		UISkill.LoadUISkills();
		-- 设置当前技能
		UISkill.SetSelectedSkill(selectIndex);
		-- 设置经验值
		UISkill.RefreshExp();
	end

	-- 播放升级特效
	function UISkill.PlayLevelUpEffect(index)
		local skill = skills[index];
		local icon = skill:GO('icon');
		icon:PlayUIEffect(this.gameObject, "jinengshengji", 1);
	end

	-- 刷新当前选中技能
	function UISkill.RefreshSelectedSkill()
		-- 获取技能id
		local skillId = UISkill.GetSkillIdByIndex(selectIndex);
		-- 获取技能等级
		local skillLevel = UISkill.GetSkillLevel(selectIndex);
		-- 刷新技能
		UISkill.RefreshSkill(selectIndex);
		-- 加载技能描述
		UISkill.LoadSkillDesc(selectIndex);
		-- 刷新红点
		UISkill.RefreshRedPoint(selectIndex);
		-- 刷新技能经验
		UISkill.RefreshExp();
		-- 播放技能升级
		UISkill.PlayLevelUpEffect(selectIndex);
	end


	-- 判断技能是否是最高等级
	function UISkill.IsTopMost(index)
		local skillId = UISkill.GetSkillIdByIndex(index)
		local skillLevel = UISkill.GetSkillLevel(index);
		local skillValue = tb.GetTableByKey(tb.SkillValueTable, {skillId, skillLevel + 1});
		return skillValue == nil;
	end

	-- 判断是否能升级
	function UISkill.CanLevelUp(index)
		return client.skillCtrl.canSkillUp("skill", index);
	end

	-- 刷新红点
	function UISkill.RefreshRedPoint(index)
		local show = UISkill.CanLevelUp(index);
		UISkill.SetRedPoint(index, show);
	end

	-- 显示红点提示
	function UISkill.SetRedPoint(index, show)
		local skill = skills[index];
		local redPoint = skill:GO('redPoint');
		if show then
			redPoint:Show();
		else
			redPoint:Hide();
		end
	end

	-- 获取能升级技能数量
	function UISkill.GetNumOfCanLevelUp()
		local count = 0;
		for i = 1, #skills do
			local skillId = UISkill.GetSkillIdByIndex(i);
			if not UISkill.IsLockedSkill(skillId) then
				if UISkill.CanLevelUp(i) then
					count = count + 1;
				end
			end
		end
		return count;
	end

	-- 升级全部
	function UISkill.levelUpAll(callback)
		local count = #skills;
		UISkill.levelUpAllImpl(1, count, callback);
	end

	-- 升级全部（Impl)
	function UISkill.levelUpAllImpl(index, count, callback)
		if index > count then
			callback();
			return;
		end
		local skillId = UISkill.GetSkillIdByIndex(index);
		if not UISkill.CanLevelUp(index) then
			UISkill.levelUpAllImpl(index + 1, count, callback);
		else
			UISkill.levelUpSkill(index, function (msgTable)

				if selectIndex == index then
					UISkill.RefreshSelectedSkill();
				else
					-- 获取技能id
					local skillId = UISkill.GetSkillIdByIndex(index);
					-- 获取技能等级
					local skillLevel = UISkill.GetSkillLevel(index);
					-- 刷新技能
					UISkill.RefreshSkill(index);
					-- 刷新红点
					UISkill.RefreshRedPoint(index);
					-- 刷新经验值
					UISkill.RefreshExp();
					-- 播放升级特效
					UISkill.PlayLevelUpEffect(index);
				end
				-- 继续升级剩下的技能
				UISkill.levelUpAllImpl(index + 1, count, callback);
			end);
		end
	end

	-- 升级单个技能
	function UISkill.levelUpSkill(index, callback)
		client.skillCtrl.onSkillLevelUp(index, callback);
	end

	function UISkill.onClose()
		destroy(this.gameObject);
	end

	function UISkill.LoadSkillRTT()
		-- 初始化 RTT
		if SkillExhibitRTT == 0 then
      		SkillExhibitRTT = CreateSkillExhibitRTT()
      	else
      		-- print("UpdateRtt")
      		SkillExhibitRTT.UpdateRtt()
      	end
      	-- 设置当前显示位置
      	RTTManager.SetRoleFigure(RoleFigure, SkillExhibitRTT, false, true);
      	SkillExhibitRTT.SetModelDirAndSave(0, 135, 0);
      	SkillExhibitRTT.SetModelPosAndSave(0, 0, 0);
	end

	-- 加载绑定
	function UISkill.LoadUISkill(index)
		local skill = skills[index];
		local icon = skill:GO('icon');

		icon:BindButtonClick(function ()
			local skillId = UISkill.GetSkillIdByIndex(index);
			if UISkill.IsLockedSkill(skillId) then
				return;
			end
			selectIndex = index;
			UISkill.SetSelectedSkill(index);
		end);
	end

	-- 加载技能列表
	function UISkill.LoadUISkills()
		skills[1] = skill1;
		skills[2] = skill2;
		skills[3] = skill3;
		skills[4] = skill4;
		for i = 1, #skills do
			UISkill.LoadUISkill(i);
		end
	end

	-- 播放技能展示
	function UISkill.PlaySkillExhibit(skillId)
		local rtt = GetSkillExhibitRTT();
		if rtt ~= 0 then
			rtt.PlaySkill(skillId);
		end
	end

	function UISkill.GetLuaNameByCareer(career)
		if career == "bowman" then
			return "Bowman";
		end
		if career == "magician" then
			return "Magician";
		end
		if career == "solider" then
			return "Solider";
		end
		return "";
	end

	-- 根据索引获取技能id
	function UISkill.GetSkillIdByIndex(index)
		local myInfo = DataCache.myInfo;
		local career = myInfo.career;
		local skillList = const.ProfessionAbility[career];
		local skillId = skillList[index];
		return skillId;
	end

	-- 获取技能等级
	function UISkill.GetSkillLevel(index)
		return client.skillCtrl.GetSkillLevel(index);
	end

	-- 设置一般
	function UISkill.SetNormal(index)

		local skill = skills[index];
		local normal = skill:GO('normal');
		local selected = skill:GO('selected');
		local lock = skill:GO('lock');
		normal:Show();
		selected:Hide();
		lock:Hide();

		local name = skill:GO('name');
		local skillId = UISkill.GetSkillIdByIndex(index);
		local skillData = tb.SkillTable[skillId];
		name.text = skillData.name;

		local level = skill:GO('level');
		local skillLevel = UISkill.GetSkillLevel(index);
		level.text = string.format("Lv:%d", skillLevel);

		local icon = skill:GO('icon');
		icon.sprite = skillData.icon;

		UISkill.RefreshRedPoint(index);
	end

	-- 设置激活
	function UISkill.SetActive(index)
		local skill = skills[index];
		local normal = skill:GO('normal');
		local selected = skill:GO('selected');
		local lock = skill:GO('lock');
		normal:Hide();
		selected:Show();
		lock:Hide();
		local name = skill:GO('name');
		local skillId = UISkill.GetSkillIdByIndex(index);
		local skillData = tb.SkillTable[skillId];
		name.text = skillData.name;
		local level = skill:GO('level');
		local skillLevel = UISkill.GetSkillLevel(index);
		level.text = string.format("Lv:%d", skillLevel);

		print(skillLevel);

		local icon = skill:GO('icon');
		icon.sprite = skillData.icon;

		UISkill.RefreshRedPoint(index);
	end

	-- 设置锁定
	function UISkill.SetLocked(index)
		local skill = skills[index];
		local normal = skill:GO('normal');
		local selected = skill:GO('selected');
		local lock = skill:GO('lock');
		normal:Hide();
		selected:Hide();
		lock:Show();

		local name = skill:GO('name');
		local skillId = UISkill.GetSkillIdByIndex(index);
		local skillData = tb.SkillTable[skillId];
		name.text = skillData.name;

		local level = skill:GO('level');
		local skillLevel = UISkill.GetSkillLevel(index);
		level.text = string.format("Lv:%d", skillLevel);

		local icon = skill:GO('icon');
		icon.sprite = skillData.icon;

		UISkill.SetRedPoint(index, false);
	end

	-- 判断技能是否解锁
	function UISkill.IsLockedSkill(skillId)
		local myInfo = DataCache.myInfo;
		local abilities = myInfo.ability;
		for k = 1, #abilities do
			local ability = abilities[k];
			if ability[1] == skillId then
				return false;
			end
		end
		return true;
	end

	-- 设置选中状态
	function UISkill.SetSelectedState(index)
		local count = #skills;
		for i = 1, count do
			UISkill.RefreshSkill(i);
		end
	end

	-- 设置选中的技能索引
	function UISkill.SetSelectedSkill(index)
		-- 获取技能id
		local skillId = UISkill.GetSkillIdByIndex(index);
		-- 设置选中状态
		UISkill.SetSelectedState(index);
		-- 加载技能描述
		UISkill.LoadSkillDesc(index);
		-- 播放技能展示
		UISkill.PlaySkillExhibit(skillId);
	end

	function UISkill.RefreshExp()
		local myInfo = DataCache.myInfo;
		expNumb.text = string.format("%d", myInfo.skill_exp);
	end

	-- 刷新技能信息
	function UISkill.RefreshSkill(index)
		local skillId = UISkill.GetSkillIdByIndex(index);
		if UISkill.IsLockedSkill(skillId) then
			UISkill.SetLocked(index);
		else
			if selectIndex == index then
				UISkill.SetActive(index);
			else
				UISkill.SetNormal(index);
			end
		end
	end

	-- 格式化技能描述
	function UISkill.FormatDesc(value)
		local str = "";
		if value == nil then
			return str;
		end
		--有#说明显示下一级颜色，并补括号
		if string.find(value,"#") == 1 then
			value = string.sub(value,2,string.len(value));
			str = string.format("<color=#ffdb9c>%s</color>",value);
		--没有#说明显示普通颜色
		else
			str = string.format("<color=#ffdb9c>%s</color>",value);
		end
		return str;
	end


	-- 格式化技能描述
	function UISkill.FormatSkillDesc(sourceStr, number, skillValue)
		local text = "";
		if skillValue ~= nil then
		--如果第一个技能为固定伤害类，这类没有下一级效果的预览
			if number == 1 then
				text = string.format(sourceStr, UISkill.FormatDesc(skillValue.effectValue1));
			elseif number == 2 then
				text = string.format(sourceStr, UISkill.FormatDesc(skillValue.effectValue1), UISkill.FormatDesc(skillValue.effectValue2));
			elseif number == 3 then
				text = string.format(sourceStr, UISkill.FormatDesc(skillValue.effectValue1), UISkill.FormatDesc(skillValue.effectValue2),
				UISkill.FormatDesc(skillValue.effectValue3));
			elseif number == 4 then
				text = string.format(sourceStr, UISkill.FormatDesc(skillValue.effectValue1), UISkill.FormatDesc(skillValue.effectValue2),
				UISkill.FormatDesc(skillValue.effectValue3), UISkill.FormatDesc(skillValue.effectValue4));
			elseif number == 5 then
				text = string.format(sourceStr, UISkill.FormatDesc(skillValue.effectValue1), UISkill.FormatDesc(skillValue.effectValue2),
				UISkill.FormatDesc(skillValue.effectValue3), UISkill.FormatDesc(skillValue.effectValue4), UISkill.FormatDesc(skillValue.effectValue5));
			elseif number == 6 then
				text = string.format(sourceStr, UISkill.FormatDesc(skillValue.effectValue1), UISkill.FormatDesc(skillValue.effectValue2),
				UISkill.FormatDesc(skillValue.effectValue3), UISkill.FormatDesc(skillValue.effectValue4), UISkill.FormatDesc(skillValue.effectValue5),
				UISkill.FormatDesc(skillValue.effectValue6));
			end
		else
			text = "已达到等级上限";
		end		
		return text;
	end

	-- 显示技能信息
	function UISkill.LoadSkillDesc(index)
		local skillId = UISkill.GetSkillIdByIndex(index);
		local skillLevel = UISkill.GetSkillLevel(index);
		local skillValue = tb.GetTableByKey(tb.SkillValueTable, {skillId, skillLevel});
		local detailInfo = tb.SkillTable[skillId];
		-- 设置当前描述
		local currDescText = UISkill.FormatSkillDesc(detailInfo.skill_describe, detailInfo.skill_value, skillValue);
		desc.text = currDescText;
	end

	return UISkill;
end
