function UINewSkillView ()

	local UINewSkill = {};
	local this = nil;


	-- 天赋最高等级
	local talent_top_level = 20;
	-- 技能左侧列表
	local leftBtnGroup = {};
	-- 天赋元素
	local talentElements = {};
	-- 天赋
	local talentList = {};
	-- 当前选中
	local selectIndex = 0;
	-- 当前选中的天赋索引
	local selectedTalentIndex = 1;
	-- 技能列表
	local skillList = {};
	-- 按钮映射
	local ButtonMap= {};
	-- 技能信息
	local skillInfo = nil;
	-- 详情信息
	local detailInfo = nil;
	-- 角色控制器
	local avatarController = nil;
	-- 通常颜色
	local normalColor = nil;
	-- 红色
	local redColor = nil;

	local CoolDown = nil;
	local NeedLevel = nil;
	local SkillNeedLevel = nil;
	local BtnComfirm = nil;
	local SkillMoneyCost = nil;
	local TalentBookCount = nil;
	local ResetBtn = nil;
	local TitleName = nil;
	local CurrDescContent = nil;
	local NextDescContent = nil;
	local UpgradeBtn = nil;
	local HelpBtn = nil;
	local RulePanel = nil;
	local RuleMaskBtn = nil;
	local RuleCloseBtn = nil;
	local ResetConfirmPanel = nil;
	local ResetCancelBtn = nil;
	local ResetConfirmBtn = nil;
	local SkillTitleName = nil;
	local CurrDesc = nil;
	local NeedLevelConst = nil;
	local NextDesc = nil;
	local Amount = nil;
	local Button1 = nil;
	local Button2 = nil;
	local Button3 = nil;
	local Button4 = nil;
	local Talent1 = nil;
	local Talent2 = nil;
	local Talent3 = nil;
	local Talent4 = nil;

	local PassiveSkillBtnflag = nil;
	local PassiveSkillsCtrl = {};
	local PassiveSkillsInfo = {};
	local SelectedPassiveSkill = nil;
	local PassiveSkillName = nil;
	local PassiveSkillCurPoint = nil;
	local PassiveSkillLevelUpAddPoint = nil;
	local PassiveSkillNeedMoney = nil;
	local PassiveSkillLevelUpAndCost = nil;

	local effect_beidong = nil;
	UINewSkill.PassiveSkillLevelUpCallBackMsg = nil;

	function UINewSkill.Start ()
		this = UINewSkill.this;
		SkillTitleName = this:GO('Panel.ZhuDongPanel.SkillZone.CurrLevel.DescTitle._SkillTitleName');
		CurrDesc = this:GO('Panel.ZhuDongPanel.SkillZone.CurrLevel.Content._CurrDesc');
		CoolDown = this:GO('Panel.ZhuDongPanel.SkillZone.CurrLevel.CoolDown._CoolDown');
		NeedLevel = this:GO('Panel.ZhuDongPanel.SkillZone.NextLevel.NeedLevel._NeedLevel');
		SkillNeedLevel = this:GO('Panel.ZhuDongPanel.SkillZone.NextLevel.NeedLevel');
		NeedLevelConst = this:GO('Panel.ZhuDongPanel.SkillZone.NextLevel.NeedLevel._NeedLevelConst');
		NextDesc = this:GO('Panel.ZhuDongPanel.SkillZone.NextLevel.Description._NextDesc');
		Amount = this:GO('Panel.ZhuDongPanel.SkillZone.Upgrade.Money._Amount');
		BtnComfirm = this:GO('Panel.ZhuDongPanel.SkillZone.Upgrade._BtnComfirm');
		SkillMoneyCost = this:GO('Panel.ZhuDongPanel.SkillZone.Upgrade.Money');
		TalentBookCount = this:GO('Panel.TianFuPanel.TalentBook._TalentBoolCount');
		ResetBtn = this:GO('Panel.TianFuPanel._ResetBtn');
		TitleName = this:GO('Panel.TianFuPanel.CurrDesc.DescTitle._TitleName');
		CurrDescContent = this:GO('Panel.TianFuPanel.CurrDesc._CurrDescContent');
		NextDescContent = this:GO('Panel.TianFuPanel.NextDesc._NextDescContent');
		UpgradeBtn = this:GO('Panel.TianFuPanel._UpgradeBtn');
		RulePanel = this:GO('Panel.TianFuPanel._RulePanel');
		RuleMaskBtn = this:GO('Panel.TianFuPanel._RulePanel._RuleMaskBtn');
		RuleCloseBtn = this:GO('Panel.TianFuPanel._RulePanel._RuleCloseBtn');
		ResetConfirmPanel = this:GO('Panel.TianFuPanel._ResetConfirmPanel');
		ResetConfirmBtn = this:GO('Panel.TianFuPanel._ResetConfirmPanel._ResetConfirmBtn');
		ResetCancelBtn = this:GO('Panel.TianFuPanel._ResetConfirmPanel._ResetCancelBtn');

		HelpBtn = this:GO('Panel.TianFuPanel._HelpBtn');
		Button1 = this:GO('Panel.ZhuDongPanel.LeftBtnGroup._Button1');
		Button2 = this:GO('Panel.ZhuDongPanel.LeftBtnGroup._Button2');
		Button3 = this:GO('Panel.ZhuDongPanel.LeftBtnGroup._Button3');
		Button4 = this:GO('Panel.ZhuDongPanel.LeftBtnGroup._Button4');

		Talent1 = this:GO('Panel.TianFuPanel.Talents._Talent1');
		Talent2 = this:GO('Panel.TianFuPanel.Talents._Talent2');
		Talent3 = this:GO('Panel.TianFuPanel.Talents._Talent3');
		Talent4 = this:GO('Panel.TianFuPanel.Talents._Talent4');

		-- 获取通用界面模板
		local commonDlgGO = this:GO('Panel.CommonDlg');	--这个是UIWrapper
		-- 创建控制器
		local controller = createCDC(commonDlgGO)
		controller.SetTitle("wz_jineng");
		controller.bindButtonClick(0, UINewSkill.onClose);
		controller.SetButtonNumber(3);
		controller.SetButtonText(1,"主动");
		controller.bindButtonClick(1, UINewSkill.onPositiveSkill);		
		controller.SetButtonText(2,"被动");
		controller.bindButtonClick(2, UINewSkill.onPassiveSkill,ui.unOpenFunc);
		
		controller.SetButtonText(3,"天赋");
		controller.bindButtonClick(3, UINewSkill.onTianFu,function ()
			if DataCache.myInfo.level < 30 then
				ui.showMsg("30级解锁天赋系统!");
				return false;
			else
				return true;
			end
		end);
		-- 创建元素
		UINewSkill.buildElements();

		-- 显示主动技能页面
		UINewSkill.onPositiveSkill();

		-- -- 选中第一个技能
		for i = 1,9 do 
			local pskill = this:GO('Panel.BeiDongPanel.skills.skill_'..i)
			pskill:BindButtonClick(UINewSkill.OnPassiveSkillSelected);
			PassiveSkillsCtrl[i] = {}
			PassiveSkillsCtrl[i].self = pskill;
			PassiveSkillsCtrl[i].icon = pskill:GO('icon')
			PassiveSkillsCtrl[i].mask = pskill:GO('mask')
			PassiveSkillsCtrl[i].selected = pskill:GO('selected')
			PassiveSkillsCtrl[i].flag = pskill:GO('flag')
		end

		PassiveSkillName = this:GO('Panel.BeiDongPanel.rightcontent.skillinfo.name')
		PassiveSkillCurPoint = this:GO('Panel.BeiDongPanel.rightcontent.skillinfo.now_point')
		PassiveSkillLevelUpAddPoint = this:GO('Panel.BeiDongPanel.rightcontent.skillinfo.levelupaddpoint')
		PassiveSkillNeedMoney = this:GO('Panel.BeiDongPanel.rightcontent.levelupandcost.moneynum')
		this:GO('Panel.BeiDongPanel.rightcontent.levelupandcost.levelup'):BindButtonClick(UINewSkill.OnPassiveSkillLevelUp)
		PassiveSkillBtnflag = commonDlgGO:GO('ButtonGroup.btn2.flag');
		PassiveSkillLevelUpAndCost = this:GO('Panel.BeiDongPanel.rightcontent.levelupandcost');

		UINewSkill.RequestPassiveSkills()
		-- 界面创建时红点初始化
		UINewSkill.TalentSetRedPoint()
		UINewSkill.ActiveSkillSetRedPoint()
	end

	function UINewSkill.onClose()
		UINewSkill.CloseSelf();
	end

	function UINewSkill.showPanel(index)
		local panels = {};
		panels[1] = this:GO('Panel.ZhuDongPanel');
		panels[2] = this:GO('Panel.BeiDongPanel');
		panels[3] = this:GO('Panel.TianFuPanel');
		for i = 1, 3 do
			panels[i]:Hide();
		end
		panels[index]:Show();
	end

	function UINewSkill.onPositiveSkill()
		-- 选中可以升级的、编号最小的主动技能
		local index = UINewSkill.PositiveSkillCanUpGradeIndex();
		UINewSkill.SetButtonSelected(leftBtnGroup[index]);
		UINewSkill.showPanel(1);
	end

	function UINewSkill.onPassiveSkill()
		-- 选中可以升级的、编号最小的被动技能
		local index = UINewSkill.PassiveSkillCanUpGradeIndex();
		UINewSkill.OnPassiveSkillSelected(PassiveSkillsCtrl[index].self.gameObject)
		UINewSkill.showPanel(2);
	end	

	function UINewSkill.onTianFu()
		if next(talentList) then
			UINewSkill.showPanel(3);
			UINewSkill.SetTalentSelected(1);
			UINewSkill.FormatTalentGroup();
		else
			UINewSkill.getTalent_S(function ()
				UINewSkill.showPanel(3);
				UINewSkill.SetTalentSelected(1);
				UINewSkill.FormatTalentGroup();
			end);
		end
	end

	function UINewSkill.isAllTalentLevel0()		
		for i = 1, 4 do
			local talent = talentList[i];
			if talent ~= nil then
				if talent.level > 0 then
					return false;
				end
			end
		end
		return true;
	end	 

	-- 创建界面元素
	function UINewSkill.buildElements()		
		-- 获取角色控制器
		local class = Fight.GetClass(AvatarCache.me);
		skillList = class.skills.skills;
		-- 设置技能列表
		-- 冷却颜色值
		normalColor = CoolDown.textColor;
		-- 等级需求颜色值
		redColor = NeedLevel.textColor;
		-- 技能按钮列表
		leftBtnGroup[1] = Button1;
		leftBtnGroup[2] = Button2;
		leftBtnGroup[3] = Button3;
		leftBtnGroup[4] = Button4;
		for i = 1, 4 do
			local button = leftBtnGroup[i];
			ButtonMap[button.gameObject.name] = i;
			button:BindButtonClick(UINewSkill.SetButtonSelected);
		end
		
		-- 初始化左边
		UINewSkill.FormatLeftBtnGroup();
		selectIndex = 1;
		UINewSkill.FormatSkillInfo();

		BtnComfirm:BindButtonClick(UINewSkill.ConfirmSkillLevelUp);

		-- 天赋
		talentElements[1] = Talent1;
		talentElements[2] = Talent2;
		talentElements[3] = Talent3;
		talentElements[4] = Talent4;

		-- 在这里获取的talentlist信息不全，注释掉，让点击天赋的时候请求服务端获取

		-- 设置天赋列表
		-- for i = 1, 4 do
		-- 	talentList[i] = avatarController:GetTalentByIndex(i - 1);
		-- end

		-- 添加天赋点击事件
		UINewSkill.buildAllTalentHandler();

		-- 重置天赋
		ResetBtn:BindButtonClick(function (go)
			local wrapper = go:GetComponent("UIWrapper");
			if wrapper.buttonEnable then
                if DataCache.myInfo.level >= 50 then
                    ResetConfirmPanel:GO("Cost"):Show();
                    ResetConfirmPanel:GO("Text"):Hide();
                end
                local costText = ResetConfirmPanel:GO('Cost.Numb');
                costText.text = string.format("%d", const.reset_talent_diamond_cost);
				ResetConfirmPanel:Show();
			end
		end);

		-- 升级天赋
		UpgradeBtn:BindButtonClick(function (go)
			local talentInfo = avatarController:GetTalentByIndex(selectedTalentIndex - 1);
			if talentInfo ~= nil then			
				local sid = talentInfo.data.id;
				UINewSkill.talentLevelUp_S(sid);
			end
		end);

		-- 天赋说明
		HelpBtn:BindButtonClick(function (go)
			RulePanel:Show();
		end);

		-- 天赋规则面板
		RuleCloseBtn:BindButtonClick(function (go)
			RulePanel:Hide();
		end);

		RuleMaskBtn:BindButtonClick(function (go)
			RulePanel:Hide();
		end);

		RulePanel:Hide();

		-- 天赋重置面板
		ResetConfirmBtn:BindButtonClick(function (go)
			ResetConfirmPanel:Hide();
			if DataCache.role_diamond < const.reset_talent_diamond_cost then
				ui.showCharge();
				return;
			end
			UINewSkill.resetTalent_S();
		end);

		ResetCancelBtn:BindButtonClick(function (go)
			ResetConfirmPanel:Hide();
		end);

		ResetConfirmPanel:Hide();
		-- 天赋书
		TalentBookCount.text = tostring(DataCache.talentBook);
		-- 注册天赋书事件处理
		EventManager.bind(this.gameObject, Event.ON_TALENTBOOK_CHANGE, UINewSkill.onTalentBookChange);
		-- 注册角色升级事件处理
		EventManager.bind(this.gameObject, Event.ON_LEVEL_UP, function ()
			UINewSkill.FormatLeftBtnGroup();
			UINewSkill.FormatSkillInfo();
			UINewSkill.SetButtonSelectedByIndex(selectIndex);
			UINewSkill.ActiveSkillSetRedPoint()		-- 升级，主动技能红点判断
			UINewSkill.RequestPassiveSkills() 		-- 升级，更新被动技能面板
		end);

		EventManager.bind(this.gameObject,Event.ON_MONEY_CHANGE,function ()
			UINewSkill.FormatLeftBtnGroup();
			UINewSkill.FormatSkillInfo();
			UINewSkill.SetButtonSelectedByIndex(selectIndex);
			UINewSkill.ActiveSkillSetRedPoint()		-- 金钱变化，刷新界面
			UINewSkill.RequestPassiveSkills() 		-- 金钱变化，更新被动技能面板
		end);

		-- 技能解锁
		EventManager.bind(this.gameObject, Event.ON_ABILITY_UNLOCK, function ()
			local class = Fight.GetClass(AvatarCache.me);
			skillList = class.skills.skills;

			UINewSkill.FormatLeftBtnGroup();
			UINewSkill.FormatSkillInfo();
			UINewSkill.SetButtonSelectedByIndex(selectIndex);
			UINewSkill.ActiveSkillSetRedPoint()		-- 技能解锁，主动技能红点判断
		end);
	end

	function UINewSkill.CloseSelf()
		if UINewSkill.this ~= nil then	
			destroy(this.gameObject);
		end
		UINewSkill.this = nil;
	end

	-- 初始化左边的技能列表
	function  UINewSkill.FormatLeftBtnGroup()
		for i = 1, 4 do			
			UINewSkill.FormatSkillButton(i, leftBtnGroup[i], skillList[i]);
		end
	end

	-- 判断技能是否未解锁
	function UINewSkill.IsSkillLocked(index)
		local skill = skillList[index];
		return skill == nil;
	end

	function UINewSkill.FormatSkillButton(index, button, skill)
		local career = DataCache.myInfo.career;
		local idList = const.ProfessionAbility[career];
		local skillID = idList[index];

		local skillInfo = tb.SkillTable[skillID];
		if skill == nil then
			local name = button:GO('Name');
			local icon = button:GO('Icon');
			icon:Hide();
			local lock = button:GO('Lock');
			local lock_desc = button:GO('LockDesc');

			local nextLevelSkillInfo = SkillUpTable[0][index];
			local unlock_level = nextLevelSkillInfo.level;
			lock_desc.text = string.format("%d级解锁", unlock_level);
			local flag = button:GO('Flag');
			local selected = button:GO('SelectFrame');
			local condition = button:GO('Condition');
			local lv = button:GO('Lv');
			
			-- 设置技能名称和等级
			name.text = skillInfo.name;
			-- 设置技能图标
			icon.sprite = skillInfo.icon;
			lock:Show();
			lock_desc:Show();
			flag:Hide();
			selected:Hide();
			condition:Hide();
			name:Hide();
			lv:Hide();
		else
			local name = button:GO('Name');
			local icon = button:GO('Icon');
			local lock = button:GO('Lock');
			local lock_desc = button:GO('LockDesc');
			local flag = button:GO('Flag');
			local selected = button:GO('SelectFrame');
			local condition = button:GO('Condition');
			local lv = button:GO('Lv');

			-- 设置技能名称和等级
			name.text = skillInfo.name;
			name:Show();
			lv.text = "(lv." .. skill.Level .. ")";
			lv:Show();
			-- 设置技能图标
			icon:Show();
			icon.sprite = skillInfo.icon;

			lock:Hide();
			lock_desc:Hide();

			local nextLevelSkillInfo = SkillUpTable[skill.Level][index];
			if nextLevelSkillInfo == nil or (nextLevelSkillInfo.cost == 0 and nextLevelSkillInfo.level == 0) or (nextLevelSkillInfo.level > DataCache.myInfo.level or nextLevelSkillInfo.cost > DataCache.role_money) then
				flag:Hide();
			else
				flag:Show();
			end
			
			selected:Hide();
			condition:Hide();
		end		
	end

	function UINewSkill.SetButtonSelected(go)
		-- 获取技能索引
		local index = ButtonMap[go.name];
		UINewSkill.SetButtonSelectedByIndex(index);
	end
	
	function UINewSkill.SetButtonSelectedByIndex(index)
		if UINewSkill.IsSkillLocked(index) then
			local nextLevelSkillInfo = SkillUpTable[0][index];
			ui.showMsg(string.format("角色达到%d级时解锁", nextLevelSkillInfo.level));
		else
			--处理按钮的选中状态			
			for i = 1, 4 do
				if not UINewSkill.IsSkillLocked(i) then
					local frame = leftBtnGroup[i]:GO('SelectFrame');
					frame.gameObject:SetActive(false);
				end
			end
			local selectedframe = leftBtnGroup[index]:GO('SelectFrame');
			selectedframe.gameObject:SetActive(true);

			selectIndex = index;
			UINewSkill.FormatSkillInfo();
		end
	end

	-- 设置技能信息
	function UINewSkill.FormatSkillInfo()
		local player = DataCache.myInfo;
		skillInfo = skillList[selectIndex];
		detailInfo = tb.SkillTable[skillInfo.Data.ID];
		local levelUpInfo = SkillUpTable[skillInfo.Level][selectIndex];
		--根据技能信息生成右边技能面板的内容
		SkillTitleName.text = detailInfo.name .. " " .. skillInfo.Level .. "级";

		-- 设置 cd 时间
		local skillCD = tb.GetTableByKey(tb.SkillCDTable, {skillInfo.Data.ID, skillInfo.Level});
		local cd = 0;
		if skillCD ~= nil then
			cd = skillCD;
		else
			cd = detailInfo.cd/1000.0;
		end
		CoolDown.text = cd.."秒";
		
		-- 需求等级
		NeedLevel.text = levelUpInfo.level.."级";		
		-- 设置等级升级限制
		if player.level >= levelUpInfo.level then
			NeedLevelConst.textColor = normalColor;
			NeedLevel.textColor = normalColor;
		else
			NeedLevelConst.textColor = redColor;
			NeedLevel.textColor = redColor;
		end

		--TODO:生成描述相关信息
		local skillValue = tb.GetTableByKey(tb.SkillValueTable, {skillInfo.Data.ID, skillInfo.Level});
		-- 设置当前描述
		local currDescText = UINewSkill.FormatTotalDesc(detailInfo.skill_describe, detailInfo.skill_value, skillValue);
		CurrDesc.text = currDescText;

		local nextSkillValue = tb.GetTableByKey(tb.SkillValueTable, {skillInfo.Data.ID, skillInfo.Level + 1});
		-- 设置下级描述
		local nextDescText = UINewSkill.FormatTotalDesc(detailInfo.skill_describe, detailInfo.skill_value, nextSkillValue);
		NextDesc.text = nextDescText;

		--显示升级消耗相关信息
		if nextSkillValue ~= nil then
			SkillMoneyCost:Show();
			Amount.text = levelUpInfo.cost;
			BtnComfirm:Show();
			SkillNeedLevel:Show();
		else
			SkillMoneyCost:Hide();
			BtnComfirm:Hide();
			SkillNeedLevel:Hide();
		end
	end

	function UINewSkill.FormatTotalDesc(sourceStr, number, skillValue)
		local text = "";
		if skillValue ~= nil then
		--如果第一个技能为固定伤害类，这类没有下一级效果的预览
			if number == 1 then
				text = string.format(sourceStr, UINewSkill.FormatDesc(skillValue.effectValue1));
			elseif number == 2 then
				text = string.format(sourceStr, UINewSkill.FormatDesc(skillValue.effectValue1), UINewSkill.FormatDesc(skillValue.effectValue2));
			elseif number == 3 then
				text = string.format(sourceStr, UINewSkill.FormatDesc(skillValue.effectValue1), UINewSkill.FormatDesc(skillValue.effectValue2),
				UINewSkill.FormatDesc(skillValue.effectValue3));
			elseif number == 4 then
				text = string.format(sourceStr, UINewSkill.FormatDesc(skillValue.effectValue1), UINewSkill.FormatDesc(skillValue.effectValue2),
				UINewSkill.FormatDesc(skillValue.effectValue3), UINewSkill.FormatDesc(skillValue.effectValue4));
			elseif number == 5 then
				text = string.format(sourceStr, UINewSkill.FormatDesc(skillValue.effectValue1), UINewSkill.FormatDesc(skillValue.effectValue2),
				UINewSkill.FormatDesc(skillValue.effectValue3), UINewSkill.FormatDesc(skillValue.effectValue4), UINewSkill.FormatDesc(skillValue.effectValue5));
			elseif number == 6 then
				text = string.format(sourceStr, UINewSkill.FormatDesc(skillValue.effectValue1), UINewSkill.FormatDesc(skillValue.effectValue2),
				UINewSkill.FormatDesc(skillValue.effectValue3), UINewSkill.FormatDesc(skillValue.effectValue4), UINewSkill.FormatDesc(skillValue.effectValue5),
				UINewSkill.FormatDesc(skillValue.effectValue6));
			end
		else
			text = "已达到等级上限";
		end		
		return text;
	end

	function UINewSkill.FormatDesc(value)
		local str = "";
		if value == nil then
			return str;
		end
		--有#说明显示下一级颜色，并补括号
		if string.find(value,"#") == 1 then
			value = string.sub(value,2,string.len(value));
			str = string.format("<color=#24bb4fff>%s</color>",value);
		--没有#说明显示普通颜色
		else
			str = string.format("<color=#24bb4fff>%s</color>",value);
		end
		return str;
	end

	function UINewSkill.ConfirmSkillLevelUp(go)	
		--local index = ButtonMap[go.name];
		local skillInfo = skillList[selectIndex];
		local levelUpInfo = SkillUpTable[skillInfo.Level][selectIndex];
		if DataCache.myInfo.level < levelUpInfo.level then
			ui.showMsg("角色等级不足");
			return;
		end

		if DataCache.role_money < levelUpInfo.cost then
			ui.showMsg("金币不足");
			return;
		end

		local msg = {cmd = "skill_up", skill_tid = skillInfo.Data.ID , skill_level = skillInfo.Level};
		Send(msg, UINewSkill.callback);
	end

	function UINewSkill.callback(MsgTable)		
		local newLevel = MsgTable.skill_level;
		ui.showMsg(detailInfo.name.."成功升级到"..newLevel.."级!");
		--改动本地结构
		local skillInfo = skillList[selectIndex];
		if skillInfo == nil then
			-- 获取角色控制器
			local avatarController = DataCache.me:GetComponent("AvatarController");
			skillInfo = avatarController:GetSkillByTypeAndIndex(const.skillType[selectIndex][1], const.skillType[selectIndex][2]);
			skillList[selectIndex] = skillInfo;
		end

		skillInfo.Level = newLevel;
		local ability = DataCache.myInfo.ability;
		local career = DataCache.myInfo.career;

		local index = const.skillIndex[career][selectIndex];
		local ability_skill = ability:get_Item(index);
		ability_skill:set_Item(1, newLevel);

		--刷新界面
		local detailInfo = tb.SkillTable[skillInfo.Data.ID];
		SkillTitleName.text = detailInfo.name .. " " .. skillInfo.Level .. "级";
		UINewSkill.FormatSkillInfo();

		--改动存到对应的C#结构中
		avatarController:SetSkillLevel(const.skillType[selectIndex][1], const.skillType[selectIndex][2], newLevel);

		local button = leftBtnGroup[selectIndex];
		UINewSkill.FormatSkillButton(selectIndex, button, skillInfo);	
		UINewSkill.SetButtonSelectedByIndex(selectIndex);

		AudioManager.PlaySoundFromAssetBundle("skill_upgrade");

		UINewSkill.ActiveSkillSetRedPoint()			-- 主动技能升级，主动技能红点判断
	end

	function UINewSkill.PositiveSkillCanUpGradeIndex()
		for i = 1, 4 do
			if skillList[i] ~= nil then
				local nextLevelSkillInfo = SkillUpTable[skillList[i].Level][i];
				if not( nextLevelSkillInfo == nil or (nextLevelSkillInfo.cost == 0 and nextLevelSkillInfo.level == 0) or
				 		(nextLevelSkillInfo.level > DataCache.myInfo.level or nextLevelSkillInfo.cost > DataCache.role_money) 
				 	) then

					return i;
				end
			end
		end
		return selectIndex;
	end

	----------------------- 天赋面板 -----------------------------------------------------
	-- 天赋书刷新
	function UINewSkill.onTalentBookChange()
		-- 天赋书
		TalentBookCount.text = tostring(DataCache.talentBook);
		UINewSkill.TalentSetRedPoint();				-- 天赋书变化，天赋红点判断
		UINewSkill.FormatTalentGroup();				-- 天赋界面刷新
	end

	-- 根据职业获取天赋列表
	function UINewSkill.getTalentInfoDict(career)
		local result = {};
		local t = tb.TalentTable;
		for k, v in pairs(t) do
			if v.career == career then
				result[k] = v;
			end
		end
		return result;
	end

	-- 请求获取天赋
	function UINewSkill.getTalent_S(cb)
		local msg = {cmd = "get_talent", role_id = DataCache.myInfo.id};
		Send(msg, function (reply) UINewSkill.onGetTalent(cb, reply) end);
	end

	-- 获取天赋回调
	function UINewSkill.onGetTalent(cb, reply)
		local t = nil;
		local career = DataCache.myInfo.career;
		t = UINewSkill.getTalentInfoDict(career);
		avatarController:RemoveAllTalents();
		for k, v in pairs(t) do
			avatarController:AddTalent(k);
		end

		for i = 1, 4 do
			talentList[i] = avatarController:GetTalentByIndex(i - 1);
		end

		local msg = reply["msg"];
		for i = 1, #msg do
			local msgContent = msg[i];
			local sid = msgContent[1];
			local talent = avatarController:GetTalentById(sid);
			local level = msgContent[2];
			talent.level = level;		
		end
		cb();
	end

	-- 请求天赋升级
	function UINewSkill.talentLevelUp_S(sid)
		-- 判断是否已经是最高等级
		local talentInfo = avatarController:GetTalentById(sid);
		if talentInfo.level == talent_top_level then
			ui.showMsg("该天赋已达到等级上限!");
			return;
		end

		-- 判断天赋升级需要消耗的天赋书
		local talentLevelInfo = tb.GetTableByKey(tb.TalentLevelTable, { talentInfo.data.id, talentInfo.level });
		if talentLevelInfo ~= nil then
			local talentBook = DataCache.talentBook;
			if talentBook < talentLevelInfo.count then
				ui.showMsg("天赋点不足，无法升级!");
				return;
			end
		else
			local talentBook = DataCache.talentBook;
			if talentBook == 0 then
				ui.showMsg("天赋点不足，无法升级!");
				return;
			end
		end

		local msg = {cmd = "up_talent", sid = sid};
		Send(msg, UINewSkill.onTalentLevelUp);
	end

	-- 天赋升级回调
	function UINewSkill.onTalentLevelUp(reply)
		local type = reply["type"];

		if type == "success" then
			local talentElement = talentElements[selectedTalentIndex];
			talentElement:PlayUIEffect(this.gameObject, "tianfushengji", 1);

			local talentInfo = avatarController:GetTalentByIndex(selectedTalentIndex - 1);
			local new_level = talentInfo.level + 1;
			if new_level > talent_top_level then
				new_level = talent_top_level;
			end
			talentInfo.level = new_level;
			UINewSkill.FormatTalent(selectedTalentIndex, talentElements[selectedTalentIndex], talentInfo)
			UINewSkill.LoadTalentDetailInfo();

			TalentBookCount.text = tostring(DataCache.talentBook);
			ui.showMsg("天赋升级成功");
			UINewSkill.TalentSetRedPoint()			-- 天赋升级，天赋红点判断
		else
			ui.showMsg("XXXXXXX  [错误] 天赋升级失败!!!");
		end
		UINewSkill.FormatTalentGroup();
	end

	-- 请求天赋重置
	function UINewSkill.resetTalent_S()
		local msg = {cmd = "reset_talent"};
		Send(msg, UINewSkill.onResetTalent);
	end

	-- 天赋重置回调
	function UINewSkill.onResetTalent(reply)
		local type = reply["type"];
		if type == "success" then
			avatarController:ResetTalents();
			UINewSkill.FormatTalentGroup();
			UINewSkill.LoadTalentDetailInfo();
			UINewSkill.TalentSetRedPoint()			-- 天赋重置，天赋红点判断
		end
	end

	--初始化左边的技能列表
	function  UINewSkill.FormatTalentGroup()
		for i = 1, 4 do			
			UINewSkill.FormatTalent(i, talentElements[i], avatarController:GetTalentByIndex(i - 1));
		end

		if UINewSkill.isAllTalentLevel0() then
			ResetBtn.buttonEnable = false;
		else
			ResetBtn.buttonEnable = true;
		end
	end

	function UINewSkill.SetTalentSelected(index)
		--处理按钮的选中状态
		for i = 1, 4 do			
			talentElements[i]:GO('selected'):Hide();
		end
		local selectedElement = talentElements[index];
		selectedElement:GO('selected'):Show();
		selectedTalentIndex = index;

		UINewSkill.LoadTalentDetailInfo();
	end

	-- 加载当前等级描述信息
	function UINewSkill.LoadCurrTalentDescInfo(level, detailInfo, levelInfo)
		if level == 0 then
			CurrDescContent.text = "";
			CurrDescContent:Show();
		else
			if levelInfo == nil then
				-- 当前等级信息
				CurrDescContent.text = "没有等级配置";
			else
				local desc = detailInfo.desc;
				local params = Split(levelInfo.desc, ",");
				for i = 1, #params do
					local s, e = string.find(desc, "%$");
					if not s then
						break;
					end

					local pattern = "<color=green>" .. params[i] .. "</color>";
					desc = string.sub(desc, 1, s - 1) .. pattern .. string.sub(desc, e + 1);
				end
				CurrDescContent.text = desc;
			end
			CurrDescContent:Show();
		end
	end

	-- 加载下个等级描述信息
	function UINewSkill.LoadNextTalentDescInfo(level, detailInfo, levelInfo)
		if levelInfo == nil then
			-- 当前等级信息
			NextDescContent.text = "没有等级配置";
		else
			local desc = detailInfo.next_desc;
			local params = Split(levelInfo.desc, ",");
			for i = 1, #params do
				local s, e = string.find(desc, "%$");
				if not s then
					break;
				end
				local pattern = "<color=green>" .. params[i] .. "</color>";
				desc = string.sub(desc, 1, s - 1) .. pattern .. string.sub(desc, e + 1);
			end
			NextDescContent.text = desc;
		end
	end

	-- 加载天赋详情
	function UINewSkill.LoadTalentDetailInfo()
		local talentInfo = avatarController:GetTalentByIndex(selectedTalentIndex - 1);
		local sid = talentInfo.data.id;
		local level = talentInfo.level;
		local detailInfo = tb.TalentTable[sid];
		TitleName.text = detailInfo.name.. " " .. level .. "级";

		local currLevelInfo = tb.GetTableByKey(tb.TalentLevelTable, {sid, level});
		if level == talent_top_level then
			-- 加载当前等级信息
			UINewSkill.LoadCurrTalentDescInfo(level, detailInfo, currLevelInfo);
			-- 加载没有下个等级信息
			NextDescContent.text = "已达到等级上限";
		else
			-- 加载当前等级信息
			UINewSkill.LoadCurrTalentDescInfo(level, detailInfo, currLevelInfo);
			-- 加载下个等级信息
			local nextLevelInfo = tb.GetTableByKey(tb.TalentLevelTable, {sid, level + 1});
			UINewSkill.LoadNextTalentDescInfo(level + 1, detailInfo, nextLevelInfo);
		end		
	end

	function UINewSkill.OnTalentSelected(go)
		local wrapper = go:GetComponent('UIWrapper');
		local index = wrapper:GetUserData("index");
		local talent = talentList[index];
		UINewSkill.SetTalentSelected(index);
	end

	function UINewSkill.buildAllTalentHandler()
		for i = 1, #talentElements do
			UINewSkill.buildOneTalentHandler(i, talentElements[i]);
		end
	end

	function UINewSkill.buildOneTalentHandler(index, button)
		button:SetUserData("index", index);
		button:BindButtonClick(UINewSkill.OnTalentSelected);
	end

	function UINewSkill.FormatTalent(index, button, talent)		
		if talent == nil then
			return;
	 	end	 	
	 	-- 获取元素
		local icon = button:GO('icon');
		--local selected = button:GO('selected');
		local lv = button:GO('lv.lv');
		local lv_title = button:GO('lv.lv_title');
		local mask = button:GO('mask');
		local flag = button:GO('flag');

	 	-- 获取技能信息
		local talentInfo = tb.TalentTable[talent.data.id];
	 	-- 设置天赋图标		
		icon:Show();
		if talent.level == 0 then
			mask:Hide();
			icon.sprite = talentInfo.mask_icon;
			lv.text = "0";
			lv:Hide();
			lv_title:Hide();
		else
			mask:Hide();
			icon.sprite = talentInfo.icon;
			lv.text = tostring(talent.level);
			lv:Show();
			lv_title:Show();
		end

		if DataCache.talentBook > 0 and talent.level < talent_top_level then
			flag:Show();
		else
			flag:Hide();
		end		
	end
-----------------------------天赋面板 End -------------------------------------------------

-----------------------------被动技能面板-----------------------
	--请求被动技能
	function UINewSkill.RequestPassiveSkills()
		if DataCache.myInfo.level >= 20 then
			local msg = {cmd = "getpassiveskills"};
			Send(msg, UINewSkill.UpdatePassiveSkills);
		end
	end

	function UINewSkill.CanPassiveSkillLevelUp(pSkill)
		if pSkill.actived == 0 then
			return false
		end

		local needMoney = tb.PassiveSkillLevelUpTable[pSkill.level].money;
		if pSkill.level < DataCache.myInfo.level and needMoney <= DataCache.role_money then
			return true;
		end

		return false
	end

	function UINewSkill.HavePassiveSkillCanLevelUp()
		for i = 1,#PassiveSkillsInfo do 
			local pSkill = passiveskillinfo[i];
			if UINewSkill.CanPassiveSkillLevelUp(pSkill) == true then
				return true
			end
		end
		return false
	end
	
	--更新被动技能面板
	function UINewSkill.UpdatePassiveSkills(msg)
		local PassiveSkills = msg["passiveskillinfo"]
		PassiveSkillBtnflag:Hide();
		local triggeractived = {};--触发激活 

		for i = 1, #PassiveSkills do
			local pSkill = {};
			pSkill.sid = PassiveSkills[i][1];
			pSkill.actived = PassiveSkills[i][2];
			pSkill.level = PassiveSkills[i][3];

			if PassiveSkillsInfo[i] ~= nil and PassiveSkillsInfo[i].actived == 0 and pSkill.actived == 1 then
				triggeractived[#triggeractived + 1] = i
			end

			PassiveSkillsCtrl[i].self:SetUserData("index",i);
			PassiveSkillsInfo[i] = pSkill;
			--未开启蒙版
			if pSkill.actived == 1 then
				PassiveSkillsCtrl[i].mask:Hide();
			else
				PassiveSkillsCtrl[i].mask:Show();
			end	

			--升级标记
			if UINewSkill.CanPassiveSkillLevelUp(pSkill) == true then
				PassiveSkillsCtrl[i].flag:Show();
				PassiveSkillBtnflag:Show();
			else
				PassiveSkillsCtrl[i].flag:Hide();				
			end
			--更新选中的
			if  SelectedPassiveSkill ~= nil and SelectedPassiveSkill.sid == pSkill.sid then
				SelectedPassiveSkill = pSkill
				SelectedPassiveSkill.index = i; -- 记录选中的被动索引
			end
			
			for i = 1,#triggeractived do
				local activedname = tb.PassiveSkillTable[PassiveSkillsInfo[triggeractived[i]].sid].name
				ui.showMsg(activedname.."已激活");
				PassiveSkillsCtrl[triggeractived[i]].self:PlayUIEffect(this.gameObject, "bdjnjs",1)
			end
		end

		if SelectedPassiveSkill == nil then
			UINewSkill.OnPassiveSkillSelected(PassiveSkillsCtrl[1].self.gameObject)
		else
			UINewSkill.UpdateSelectInfo(SelectedPassiveSkill)
		end
	end

	--选中被动技能
	function UINewSkill.OnPassiveSkillSelected(go)
	    local wrapper = go:GetComponent('UIWrapper');
	    local index = wrapper:GetUserData("index")
	    local newSelect = PassiveSkillsInfo[index];

	    if SelectedPassiveSkill ~= nil then
	    	if SelectedPassiveSkill.sid == newSelect.sid then
	    		return
	    	end
	    	PassiveSkillsCtrl[SelectedPassiveSkill.index].selected:Hide()
	    end
	    PassiveSkillsCtrl[index].selected:Show()
	    if effect_beidong then
	    	effect_beidong:SetParent(PassiveSkillsCtrl[index].self.gameObject.transform);
	    	effect_beidong.localPosition = Vector3.New(0, 0, 0);
	    else
	    	PassiveSkillsCtrl[index].self:PlayUIEffect(this.gameObject, "beidong", 1, function (go) 	    		
	    		effect_beidong = go:GetComponent("Transform");
			end, true, true, UIWrapper.UIEffectAddType.Replace);
	    end
	    SelectedPassiveSkill = newSelect;
	    SelectedPassiveSkill.index = index;

	    UINewSkill.UpdateSelectInfo(SelectedPassiveSkill)
	end

	function UINewSkill.UpdateSelectInfo(pSkill)
		local passivetable = tb.PassiveSkillTable[pSkill.sid] 
		local nowpoint = tb.PassiveSkillEffectTable[pSkill.sid.."-"..pSkill.level].value
		local nextpoint = tb.PassiveSkillEffectTable[pSkill.sid.."-"..(pSkill.level+1)].value 

		local name = passivetable.name;
		if pSkill.actived == 1 then
			name = name.." lv."..pSkill.level
		end
		PassiveSkillName.text = name;

		if pSkill.actived == 0 then
			PassiveSkillCurPoint.text = string.format("<color=#6C6C6CFF>%s达到%d级解锁</color>",tb.PassiveSkillTable[pSkill.sid-1].name,passivetable.needprelevel )
			PassiveSkillLevelUpAddPoint:Hide();
			PassiveSkillLevelUpAndCost:Hide();
			return;
		else
			PassiveSkillCurPoint:Show();
			PassiveSkillLevelUpAddPoint:Show();
			PassiveSkillLevelUpAndCost:Show();
		end
		local nowpointstr = string.format("<color=#00ff00ff>%d</color>",nowpoint);

		PassiveSkillCurPoint.text = string.format("<color=#B0B0B3FF>"..passivetable.content.."</color>",nowpointstr);
		PassiveSkillLevelUpAddPoint.text = string.format("<color=#138FFFFF>升级：提高<color=#00ff00ff>%d</color>点</color>",nextpoint-nowpoint)

		local needmoney = tb.PassiveSkillLevelUpTable[pSkill.level].money
		local moneyColor = Color.New(108/255, 108/255, 108/255)
		if needmoney > DataCache.role_money then
			moneyColor = Color.New(1, 0,0) 
		end
		PassiveSkillNeedMoney.textColor = moneyColor
		PassiveSkillNeedMoney.text = needmoney
	end

	--升级被动技能
	function UINewSkill.OnPassiveSkillLevelUp(go)
		if SelectedPassiveSkill.level >= DataCache.myInfo.level then
			ui.showMsg("被动等级不能超过角色等级");
			return
		end

		if tb.PassiveSkillLevelUpTable[SelectedPassiveSkill.level].money > DataCache.role_money then
			ui.showBuyMoney()
			return
		end

		local msg = {cmd = "passiveskill_levelup", skillsid = SelectedPassiveSkill.sid};
		Send(msg,  function(msg) 
			if msg.type == "ok" then
				ui.showMsg("升级成功");
				local haveNewActived = false
				local PassiveSkills = msg["passiveskillinfo"]
				for i = 1, #PassiveSkills do
					local pSkill = {};
					pSkill.sid = PassiveSkills[i][1];
					pSkill.actived = PassiveSkills[i][2];
					pSkill.level = PassiveSkills[i][3];

					if PassiveSkillsInfo[i] ~= nil and PassiveSkillsInfo[i].actived == 0 and pSkill.actived == 1 then
						haveNewActived = true
					end
				end

				if haveNewActived then
					UINewSkill.PassiveSkillLevelUpCallBackMsg = msg
					SelectedPassiveSkill.level = SelectedPassiveSkill.level + 1
					UINewSkill.UpdateSelectInfo(SelectedPassiveSkill)
					this:Delay(0.4,function() 
					UINewSkill.UpdatePassiveSkills(UINewSkill.PassiveSkillLevelUpCallBackMsg) end)
				else
					UINewSkill.UpdatePassiveSkills(msg)
				end
			end
		end);
	end

	function UINewSkill.PassiveSkillCanUpGradeIndex()
		for i = 1,#PassiveSkillsInfo do 
			local pSkill = PassiveSkillsInfo[i];
			if UINewSkill.CanPassiveSkillLevelUp(pSkill) == true then
				return i;
			end
		end
		return SelectedPassiveSkill.index;
	end
-----------------------------被动技能面板End-----------------------


-----------------------------主动、天赋红点设置-----------------------
	function UINewSkill.ActiveSkillSetRedPoint()
		local redPoint = this:GO('Panel.CommonDlg.ButtonGroup.btn1.flag');
		if UINewSkill.IsHaveSkillCanUpGrade() then
			redPoint:Show();
		else
			redPoint:Hide();
		end
		UINewSkill.SetUIMenuRedPoint()
	end
	function UINewSkill.TalentSetRedPoint()
		local redPoint = this:GO('Panel.CommonDlg.ButtonGroup.btn3.flag');
		if UINewSkill.IsHaveTalentBook() then
			redPoint:Show();
		else
			redPoint:Hide();
		end
		UINewSkill.SetUIMenuRedPoint()
	end

	function UINewSkill.IsHaveTalentBook()
		return DataCache.talentBook > 0;
	end
	function UINewSkill.IsHaveSkillCanUpGrade()
		local flag = false;
		local avatarCtrl = DataCache.me:GetComponent("AvatarController");
		for i=1,4 do
			local activeSkillInfo = avatarCtrl:GetSkillByTypeAndIndex(const.skillType[i][1], const.skillType[i][2]);

			if activeSkillInfo ~= nil then
				local nextLevelSkillInfo = SkillUpTable[activeSkillInfo.Level][i];
				if not( nextLevelSkillInfo == nil or (nextLevelSkillInfo.cost == 0 and nextLevelSkillInfo.level == 0) 
					or (nextLevelSkillInfo.level > DataCache.myInfo.level or nextLevelSkillInfo.cost > DataCache.role_money) ) then

						flag = true;
						break;
				end
			end
		end
		return flag;
	end

	-- 主动技能 或 天赋 红点显示发生变化时，发送事件给UIMenu处理 
	function UINewSkill.SetUIMenuRedPoint()
		EventManager.onEvent(Event.ON_EVENT_RED_POINT);
	end

-----------------------------主动、天赋红点设置-----------------------	
	return UINewSkill;
end