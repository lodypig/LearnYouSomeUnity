function UISkillNewView ()

	local UISkillNew = {};
	local this = nil;
	local tipBtn = nil;
	local activeSkillGroup = {};
	local talentGroup = {};
	local curLevelInfo = nil;
	local nextLevelInfo = nil;

	local selectIndex = nil;
	local selectType = nil;

	local talent_top_level = 20;
	local aoYiPanel = nil;
	local levelUpBtn = nil;
	local skillPanel = nil;
	local revertBtn = nil;
	local skillPoint = nil;
	local lockSkillItem = nil;
	local skillPointFloat = nil;
	local skillPointText = nil;

	local skill_up_effect = {};
	local resetSkillPointPanel = nil;

	function UISkillNew.Start ()
		this = UISkillNew.this;

		skillPanel = this:GO('SkillPanel');
		tipBtn = this:GO('SkillPanel.Top.tipBtn');
		revertBtn = this:GO('SkillPanel.Top.revertBtn');
		skillPoint = this:GO('SkillPanel.Top.skillPoint');
		curLevelInfo = this:GO('SkillPanel.Info.curLevel');
		nextLevelInfo = this:GO('SkillPanel.Info.nextLevel');
		lockSkillItem = this:GO('SkillPanel.BtnGroup.lockSkillItem');
		aoYiPanel = this:GO('SkillPanel.Info.aoyi');
		levelUpBtn = this:GO('SkillPanel.Info.levelUpBtn');
		skillPointFloat = this:GO('SkillPanel.skillPointFloat');
		skillPointText = this:GO('SkillPanel.Top.skillPoint');

		resetSkillPointPanel = this:GO('SkillPanel.resetSkillPoint');
		local commonDlgGO = this:GO('CommonDlg');
		for i=1,4 do
			activeSkillGroup[i] = this:GO('SkillPanel.BtnGroup.activeSkill.skillItem'..i);
		end
		for i=1,4 do
			talentGroup[i] = this:GO('SkillPanel.BtnGroup.passiveSkill.skillItem'..i);
		end
		lockSkillItem:BindButtonClick(ui.unOpenFunc);

		tipBtn:BindButtonClick(UISkillNew.showTips);
		levelUpBtn:BindButtonClick(UISkillNew.upSkill);
		revertBtn:BindButtonClick(UISkillNew.showRevertPanel);

		UISkillNew.controller = createCDC(commonDlgGO);
		UISkillNew.controller.SetButtonNumber(2);
		UISkillNew.controller.bindButtonClick(0, UISkillNew.onClose);
		UISkillNew.controller.SetButtonText(1,"技能");
		UISkillNew.controller.bindButtonClick(1, UISkillNew.onSkill);	
		UISkillNew.controller.SetButtonText(2,"专精");
		UISkillNew.controller.bindButtonClick(2, UISkillNew.onAoyi,ui.unOpenFunc);
		UISkillNew.init();
		-- 默认选中第一个技能
		selectIndex = 1;
		selectType = "skill";
		UISkillNew.onChooseSkill();

		UISkillNew.controller.SetRedPoint(1, client.redPoint.Skill());
		
        EventManager.bind(this.gameObject, Event.ON_TALENT_ZHUANJING_UNLOCK,function ()
            UISkillNew.refreshUI();
        end); -- 天赋/专精刷新界面

        EventManager.bind(this.gameObject, Event.ON_ABILITY_UNLOCK,function ()
            UISkillNew.refreshUI();
        end); -- 技能解锁刷新界面

		EventManager.bind(this.gameObject, Event.ON_TALENTBOOK_CHANGE,function ()
            UISkillNew.refreshUI();
        end); -- 天赋书变化刷新界面

        EventManager.bind(this.gameObject, Event.ON_LEVEL_UP,function ()
            UISkillNew.refreshUI();
        end); -- 等级变化刷新界面

        if SkillExhibitRTT == 0 then
      		SkillExhibitRTT = CreateSkillExhibitRTT()
      	else
      		-- print("UpdateRtt")
      		SkillExhibitRTT.UpdateRtt()
      	end

      	local role_figure = this:GO('3DRole.RoleFigure');
      	RTTManager.SetRoleFigure(role_figure, SkillExhibitRTT, false, true);
   --    	role_figure:BindButtonClick(function ()
   --    		local model_id = SkillExhibitRTT.model_id;
   --    		local state_name = "AOE";
			-- local name_hash = const.AnimatorStateNameToId[state_name];
			-- uFacadeUtility.JumpStateForModel(model_id, name_hash, 0);
   --    	end);
	end

	function UISkillNew.onSkill()
		skillPanel:Show();
	end

	function UISkillNew.showTips()
		skillPointFloat:Show();
		skillPointFloat:BindButtonClick(function ()
			skillPointFloat:Hide();
		end);
		skillPointFloat:GO("panel.num").text = "0/20";
	end

	function UISkillNew.showRevertPanel()
		resetSkillPointPanel:Show();
		local needDiamond = const.reset_skill_diamond_cost;

		if DataCache.myInfo.level >= const.free_reset_level then
            resetSkillPointPanel:GO("panel.tips"):Hide();
            resetSkillPointPanel:GO("panel.cost"):Show();
            resetSkillPointPanel:GO("panel.cost.text").text = needDiamond;
        else
        	resetSkillPointPanel:GO("panel.tips"):Show();
            resetSkillPointPanel:GO("panel.cost"):Hide();
        end

        resetSkillPointPanel:GO("panel.cancelBtn"):BindButtonClick(function ()
        	resetSkillPointPanel:Hide();
        end);
        resetSkillPointPanel:GO("panel.closeBtn"):BindButtonClick(function ()
        	resetSkillPointPanel:Hide();
        end);
        resetSkillPointPanel:GO("panel.confirmBtn"):BindButtonClick(function ()
        	if DataCache.myInfo.level >= const.free_reset_level then
        		if (DataCache.role_diamond < needDiamond) then
					ui.showCharge();
					return;
				end
        	end
			client.skillCtrl.resetAllSkill(function ()
				-- 重置回调，刷新界面，将talent/ability写回avatarController
				ui.showMsg("重置成功")
				resetSkillPointPanel:Hide();
				-- UISkillNew.refreshUI();

				EventManager.onEvent(Event.ON_TALENTBOOK_CHANGE);
			end);
        end);
	end

	function UISkillNew.init()
		local career = DataCache.myInfo.career;
		local idList = const.ProfessionAbility[career];
		local totalSkillPoint = DataCache.talentBook + client.skillCtrl.usedSkilPoint;
		skillPointText.text = "技能点: "..DataCache.talentBook.."/"..totalSkillPoint;
		for i=1,4 do
			local activeSkillInfo = client.skillCtrl.activeSkillList[i];
			local activeSkillId = idList[i];
			local activeSkillTab = tb.SkillTable[activeSkillId];
			local activeSkillItem = activeSkillGroup[i];
			activeSkillItem:GO('xuanzhong'):Hide();
			activeSkillItem:GO('name').text = activeSkillTab.name;
			activeSkillItem:GO('redPoint'):Hide();

			skill_up_effect["Skill-"..i] = this:LoadUIEffect(this.gameObject, "jinengshengji", true, true);
            skill_up_effect["Skill-"..i].transform:SetParent(activeSkillItem:GO('image.icon').transform)
            skill_up_effect["Skill-"..i].transform.localScale = Vector3.one;
            skill_up_effect["Skill-"..i].transform.localPosition = Vector3.zero;
            skill_up_effect["Skill-"..i].gameObject:SetActive(false)

			if not activeSkillInfo.unlock then
				activeSkillItem:GO('notOpen'):Show();
				activeSkillItem:GO('level'):Hide();
				activeSkillItem:GO('image.icon'):Hide();
				activeSkillItem:GO('image.lock'):Show();

				activeSkillItem:BindButtonClick(function ()
					local openLV  = client.skillCtrl.skillLevelInfo[activeSkillId][1];
					ui.showMsg("完成".. openLV .."级主线任务后解锁");					
				end);
			else
				activeSkillItem:GO('notOpen'):Hide();
				activeSkillItem:GO('level'):Show();
				activeSkillItem:GO('image.icon').sprite = activeSkillTab.icon;
				activeSkillItem:GO('image.icon'):Show();
				activeSkillItem:GO('image.lock'):Hide();

				activeSkillItem:GO('level').text = "LV."..activeSkillInfo.level.."/"..client.skillCtrl.skillLevelInfo[activeSkillInfo.id][2];

				local flag = client.skillCtrl.canSkillUp("skill", i)
				if flag then
					activeSkillItem:GO('redPoint'):Show();
				end

				activeSkillItem:BindButtonClick(function ()
					selectIndex = i;
					selectType = "skill";
					UISkillNew.onChooseSkill()					
				end);
			end
		end

		for i=1,4 do
			local talentInfo = client.skillCtrl.talentList[i];
			local talentTab = tb.TalentTable[talentInfo.id];

			local talentItem = talentGroup[i];
			talentItem:GO('xuanzhong'):Hide();
			talentItem:GO('name').text = talentTab.name;
			talentItem:GO('redPoint'):Hide();

			skill_up_effect["Talent-"..i] = this:LoadUIEffect(this.gameObject, "jinengshengji", true, true);
            skill_up_effect["Talent-"..i].transform:SetParent(talentItem:GO('image.icon').transform)
            skill_up_effect["Talent-"..i].transform.localScale = Vector3.one;
            skill_up_effect["Talent-"..i].transform.localPosition = Vector3.zero;
            skill_up_effect["Talent-"..i].gameObject:SetActive(false);

			if talentInfo.level == 0 then
				talentItem:GO('notOpen'):Show();
				talentItem:GO('level'):Hide();

				talentItem:GO('image.icon'):Hide();
				talentItem:GO('image.lock'):Show();

				talentItem:BindButtonClick(function ()
					local openLV  = client.skillCtrl.skillLevelInfo[talentInfo.id][1];
					ui.showMsg("完成"..openLV.."级主线任务后解锁");					
				end);
			else
				talentItem:GO('notOpen'):Hide();
				talentItem:GO('level'):Show();

				talentItem:GO('image.icon'):Show();
				talentItem:GO('image.lock'):Hide();
				talentItem:GO('image.icon').sprite = talentTab.icon;

				local flag = client.skillCtrl.canSkillUp("talent", i, talentInfo.id)
				if flag then
					talentItem:GO('redPoint'):Show();
				end

				talentItem:GO('level').text = "LV."..talentInfo.level.."/"..client.skillCtrl.skillLevelInfo[talentInfo.id][2];
				talentItem:BindButtonClick(function ()
					selectIndex = i;
					selectType = "talent";
					UISkillNew.onChooseSkill()			
				end);
			end
		end
	end
	function UISkillNew.upSkill()
		-- 刷新界面显示
		local callback  = function (msgTable)
			-- UISkillNew.refreshUI()

			EventManager.onEvent(Event.ON_TALENTBOOK_CHANGE);

			if selectType == "skill" then
				-- activeSkillGroup[selectIndex]:GO('image.icon'):PlayUIEffect(this.gameObject, "jinengshengji", 1);

				skill_up_effect["Skill-"..selectIndex].gameObject:SetActive(false);
				skill_up_effect["Skill-"..selectIndex].gameObject:SetActive(true);

			elseif selectType == "talent" then 
				-- talentGroup[selectIndex]:GO('image.icon'):PlayUIEffect(this.gameObject, "jinengshengji", 1);

				skill_up_effect["Talent-"..selectIndex].gameObject:SetActive(false);
				skill_up_effect["Talent-"..selectIndex].gameObject:SetActive(true);
			end 
		end;

		if selectType == "skill" then
			-- 升级技能
			client.skillCtrl.onSkillLevelUp(selectIndex,callback);
		elseif selectType == "talent" then 
			-- 升级天赋
			-- local talentInfo = client.skillCtrl.avatarController:GetTalentByIndex(selectIndex - 1);
			local talentInfo = client.skillCtrl.talentList[selectIndex];
			if talentInfo ~= nil then			
				local sid = talentInfo.id;
				client.skillCtrl.talentLevelUp_S(sid,selectIndex,callback);
			end
		end
	end

	-- 根据选中的序号和类型，设置选中效果，以及描述信息
	function UISkillNew.onChooseSkill()
		for i=1,4 do
			activeSkillGroup[i]:GO('xuanzhong'):Hide();
		end

		for i=1,4 do
			talentGroup[i]:GO('xuanzhong'):Hide();
		end

		if selectType == "skill" then
			activeSkillGroup[selectIndex]:GO('xuanzhong'):Show();
			local skillId = client.skillCtrl.activeSkillList[selectIndex].id;
			activeSkillGroup[selectIndex]:GO('level').text = "LV."..client.skillCtrl.activeSkillList[selectIndex].level.."/"..client.skillCtrl.skillLevelInfo[skillId][2];
			local rtt = GetSkillExhibitRTT();
			if rtt ~= 0 then
				rtt.PlaySkill(skillId);
			end
		elseif selectType == "talent" then
			talentGroup[selectIndex]:GO('xuanzhong'):Show();
			local talentId = client.skillCtrl.talentList[selectIndex].id;
			talentGroup[selectIndex]:GO('level').text = "LV."..client.skillCtrl.talentList[selectIndex].level.."/"..client.skillCtrl.skillLevelInfo[talentId][2];
		end
		UISkillNew.formatInfo();
	end

	-- 根据选中序号和技能类型设置描述信息
	function UISkillNew.formatInfo( )
		if selectType == "skill" then



			local activeSkillInfo = client.skillCtrl.activeSkillList[selectIndex];
			local detailInfo = tb.SkillTable[activeSkillInfo.id];

			curLevelInfo:GO('top.skillName').text = detailInfo.name;
			curLevelInfo:GO('top.type').text = "主动技能";

			local skillValue = tb.GetTableByKey(tb.SkillValueTable, {activeSkillInfo.id, activeSkillInfo.level});
			-- 设置当前描述
			local currDescText = UISkillNew.FormatSkillDesc(detailInfo.skill_describe, detailInfo.skill_value, skillValue);
			curLevelInfo:GO('description.text').text = currDescText;

			-- 设置下级描述
			local nextSkillValue = tb.GetTableByKey(tb.SkillValueTable, {activeSkillInfo.id, activeSkillInfo.level + 1});
			local nextDescText = UISkillNew.FormatSkillDesc(detailInfo.skill_describe, detailInfo.skill_value, nextSkillValue);
			nextLevelInfo:GO('description.text').text = nextDescText;

			for i=1,aoYiPanel:GO("iconGroup").transform.childCount do
				aoYiPanel:GO("iconGroup").transform:GetChild(i-1).gameObject:SetActive(false);
			end
			


			if not UISkillNew.IsBlankTable(activeSkillInfo.zhuanjin) then
				aoYiPanel:Show()
				aoYiPanel:GO("tips"):Show();
				aoYiPanel:GO("iconGroup"):Hide();
			else
				aoYiPanel:Show()
				aoYiPanel:GO("tips"):Hide();
				aoYiPanel:GO("iconGroup"):Show();
				local i=1;
				for k,v in pairs(activeSkillInfo.zhuanjin) do
					aoYiPanel:GO("iconGroup.iconItem"..i):Show()
					aoYiPanel:GO("iconGroup.iconItem"..i..".img").sprite = tb.ZhuanjinTable[k].icon

					aoYiPanel:GO("iconGroup.iconItem"..i):BindButtonClick(function (go)
						local position = go.transform.position;
						UISkillNew.showZhuanJinFloat(k,v,position);
					end)
					i = i + 1;
				end
			end
		elseif selectType == "talent" then

			-- local talentInfo = client.skillCtrl.avatarController:GetTalentByIndex(selectIndex - 1);
			local talentInfo = client.skillCtrl.talentList[selectIndex];

			local sid = talentInfo.id;
			local level = talentInfo.level;
			local detailInfo = tb.TalentTable[sid];

			curLevelInfo:GO('top.skillName').text = detailInfo.name;
			curLevelInfo:GO('top.type').text = "被动技能";

			local curTalentCfg = tb.GetTableByKey(tb.TalentLevelTable, {sid, level});
			if level == talent_top_level then
				curLevelInfo:GO('description.text').text =  UISkillNew.FormatTalentDesc(detailInfo, curTalentCfg);
				nextLevelInfo:GO('description.text').text = "已达到等级上限";
			else
				curLevelInfo:GO('description.text').text = UISkillNew.FormatTalentDesc(detailInfo, curTalentCfg);
				local nextLevelTalentCfg = tb.GetTableByKey(tb.TalentLevelTable, {sid, level + 1});
				nextLevelInfo:GO('description.text').text = UISkillNew.FormatTalentDesc(detailInfo, nextLevelTalentCfg);
			end
			aoYiPanel:Hide();
		end
	end

	function UISkillNew.IsBlankTable(tab)
		if not tab then
			return false
		end 
		for k,v in pairs (tab) do
			return true
		end
		return false
	end

	function UISkillNew.showZhuanJinFloat(zhuanJingId,level, pos)
		local aoyiFloat = this:GO("SkillPanel.aoyiFloat");
		local position = aoyiFloat.transform:InverseTransformPoint(pos);

		local panelRectTransform = aoyiFloat:GO("panel"):GetComponent("Transform")
		panelRectTransform.localPosition = Vector3.New(position.x,position.y + 146,position.z);-- Vector3.New(,panelRectTransform.position.y,panelRectTransform.position.z)

		local name = tb.ZhuanjinTable[zhuanJingId].name;
		local description = tb.ZhuanjinTable[zhuanJingId].desc;
		aoyiFloat:Show();
		aoyiFloat:BindButtonClick(function ()
			aoyiFloat:Hide();
		end)
		aoyiFloat:GO("panel.title").text = name .." "..level.."级"
		aoyiFloat:GO("panel.num").text = description
	end

	-- 用于构造技能描述字符串
	function UISkillNew.FormatSkillDesc(sourceStr, number, skillValue)
		local text = "";
		if skillValue ~= nil then
		--如果第一个技能为固定伤害类，这类没有下一级效果的预览
			if number == 1 then
				text = string.format(sourceStr, UISkillNew.FormatDesc(skillValue.effectValue1));
			elseif number == 2 then
				text = string.format(sourceStr, UISkillNew.FormatDesc(skillValue.effectValue1), UISkillNew.FormatDesc(skillValue.effectValue2));
			elseif number == 3 then
				text = string.format(sourceStr, UISkillNew.FormatDesc(skillValue.effectValue1), UISkillNew.FormatDesc(skillValue.effectValue2),
				UISkillNew.FormatDesc(skillValue.effectValue3));
			elseif number == 4 then
				text = string.format(sourceStr, UISkillNew.FormatDesc(skillValue.effectValue1), UISkillNew.FormatDesc(skillValue.effectValue2),
				UISkillNew.FormatDesc(skillValue.effectValue3), UISkillNew.FormatDesc(skillValue.effectValue4));
			elseif number == 5 then
				text = string.format(sourceStr, UISkillNew.FormatDesc(skillValue.effectValue1), UISkillNew.FormatDesc(skillValue.effectValue2),
				UISkillNew.FormatDesc(skillValue.effectValue3), UISkillNew.FormatDesc(skillValue.effectValue4), UISkillNew.FormatDesc(skillValue.effectValue5));
			elseif number == 6 then
				text = string.format(sourceStr, UISkillNew.FormatDesc(skillValue.effectValue1), UISkillNew.FormatDesc(skillValue.effectValue2),
				UISkillNew.FormatDesc(skillValue.effectValue3), UISkillNew.FormatDesc(skillValue.effectValue4), UISkillNew.FormatDesc(skillValue.effectValue5),
				UISkillNew.FormatDesc(skillValue.effectValue6));
			end
		else
			text = "已达到等级上限";
		end		
		return text;
	end

	function UISkillNew.FormatDesc(value)
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

	-- 用于构造天赋描述字符串
	function UISkillNew.FormatTalentDesc(detailInfo, levelInfo)
		local desc = detailInfo.next_desc;
		local params = Split(levelInfo.desc, ",");
		for i = 1, #params do
			local s, e = string.find(desc, "%$");
			if not s then
				break;
			end
			local pattern = "<color=#ffdb9c>" .. params[i] .. "</color>";
			desc = string.sub(desc, 1, s - 1) .. pattern .. string.sub(desc, e + 1);
		end
		return desc
	end     

	-- 升级/天赋书变化/技能解锁时
	-- 重新设置按钮显示信息（是否解锁）
	-- 根据选中的技能设置技能描述
	-- 当前天赋书信息
	function UISkillNew.refreshUI()
		UISkillNew.init();
		UISkillNew.onChooseSkill();
		UISkillNew.controller.SetRedPoint(1, client.redPoint.Skill());
	end

	function UISkillNew.onClose()
		destroy(this.gameObject);
	end

	function UISkillNew.onAoyi()

	end

	return UISkillNew;
end

ui.ShowSkill = function ()
	client.skillCtrl.getAllSkill(function ()
    	-- PanelManager:CreatePanel('UISkillNew', UIExtendType.TRANSMASK, {});
    	PanelManager:CreatePanel('UISkill', UIExtendType.TRANSMASK, {});
	end);	
end