clear_tire_value_cost = 10;
no_tire_color = "31EE3A";
low_tire_color = "BF7900";
high_tire_color = "BB2424";

function UIRoleView(param)
	local UIRole = {};
	local this = nil;
	local gameObject = nil;
	local player = nil;
	local wearSlotList = {};

	


	function UIRole.Start( )
		this = UIRole.this;
		player = DataCache.myInfo;

		local commonDlgGO = this:GO('CommonDlg');	--这个是UIWrapper
		UIRole.controller = createCDC(commonDlgGO)
		UIRole.controller.SetButtonNumber(2);
		UIRole.controller.SetButtonText(1,"角色");
		UIRole.controller.bindButtonClick(1,UIRole.showAttrPanel);		
		UIRole.controller.SetButtonText(2,"背包");
		UIRole.controller.bindButtonClick(2,function() PanelManager:CreatePanel('NewUIRole', UIExtendType.NONE, {panelType = "Role"}); UIRole.closeSelf(); end);
		UIRole.controller.bindButtonClick(0,UIRole.closeSelf);
		UIRole.controller.SetTitle("wz_juese")

		UIRole.panelAttr = CreateOldPanelAttr(this:GO('AttrPanel'));
		EventManager.bind(this.gameObject,Event.ON_EXP_CHANGE,UIRole.panelAttr.showExp);
		EventManager.bind(this.gameObject,Event.ON_LEVEL_UP,UIRole.handleLevelUp);
		EventManager.bind(this.gameObject,Event.ON_BLOOD_CHANGE,UIRole.panelAttr.showHp);
		EventManager.bind(this.gameObject,Event.ON_KILL_VALUE_CHANGE,UIRole.panelAttr.showKillValue);
		EventManager.bind(this.gameObject,Event.ON_ATTR_CHANGE, UIRole.panelAttr.UpdateAttr);

		
		EventManager.bind(this.gameObject,Event.ON_EVENT_WEAREQUIP_CHANGE,UIRole.showWearEquip);
		EventManager.bind(this.gameObject,Event.ON_FIGHTNUMBER_CHANGE, UIRole.UpdateFightNumber);
		EventManager.bind(this.gameObject,Event.ON_EVENT_RED_POINT, UIRole.onRedPoint);
		EventManager.bind(this.gameObject,Event.ON_NEW_SYSTEM_OPEN_FLAG_CHANGE, UIRole.showFashionSuitNewFlag);

		local wearEquipContainer = this:GO('EquipPanel');
		local fashionBtn = wearEquipContainer:GO('FashionBtn');
		fashionBtn:BindButtonClick(function (go)
			ui.unOpenFunc();
			return
			-- local level = 22;
			-- if DataCache.myInfo.level < level then
			-- 	SysInfoLayer.GetInstance():ShowMsg(string.format("时装系统%d级开放", level));
			-- 	return;
			-- end
			-- PanelManager:CreatePanel('UISuit' , UIExtendType.BLACKMASK, {});
			-- UIRole.closeSelf();
		end);

		local  equipname, equipSlot;
		for i = 1, const.WEAREQUIP_COUNT do
			equipname =  "equip"..i;
			equipSlot = wearEquipContainer:GO(equipname);
			wearSlotList[i] = CreateSlot(equipSlot);
		end

		if param.panelType == "Bag" then
			UIRole.controller.activeButton(2);
		else
			UIRole.controller.activeButton(1);
		end
		UIRole.showWearEquip()
		UIRole.showRoleInfo()

		UIRole.showRedPoint();
		UIRole.showFashionSuitNewFlag();

		-- role rtt
		if RoleRTT == 0 then
      		RoleRTT = CreateRoleRTT()
      	else
      		RoleRTT.UpdateRtt()
      	end
		RTTManager.SetRoleFigure(this:GO('3DRole.RoleFigure'), RoleRTT, false, true);
		RTTManager.SetRoleFigure(this:GO('3DRole.MirrorFigure'), RoleRTT, true, true);
	end

	function UIRole.showRedPoint()
		UIRole.onRedPoint();
	end

	function UIRole.onRedPoint()
		local flag = this:GO('EquipPanel.FashionBtn.flag');
		if FashionSuit.hasFashionSuitRedPoint then
			flag:Show();
		else
			flag:Hide();
		end
	end

	function UIRole.showFashionSuitNewFlag()
		local newFlag = this:GO('EquipPanel.FashionBtn.newFlag');
		if client.newSystemOpen.isSystemOpen("fashionSuit") then
			newFlag:Show();
		else
			newFlag:Hide();
		end
	end

	function UIRole.wearEquipClick(index)
		local wearEquipList = Bag.wearList;
		local equip =  wearEquipList[index];
		if equip ~= nil then
			local itemCfg = tb.EquipTable[equip.sid];
			local enhanceInfo = Bag.enhanceMap[itemCfg.buwei];
			local gemInfo = client.gem.getEquipGem(itemCfg.buwei);
			if nil ~= equip then 
				local param = {showType = "self", subType = "wear", isScreenCenter = true,  index = index, base = equip, enhance = enhanceInfo, gemList = gemInfo}
				PanelManager:CreateConstPanel('EquipFloat',UIExtendType.BLACKCANCELMASK, param);
				--ui.FixFloatPosition(this,go,1);
			end
		end
	end

	function UIRole.showWearEquip()
		local equip;
		for i = 1, const.WEAREQUIP_COUNT do
			equip =  Bag.wearList[i];
			wearSlotList[i].reset();
			if nil ~= equip then 
				wearSlotList[i].setEquip(equip, false, equip.recoveryTime > 0);
				wearSlotList[i].wrapper:BindButtonClick(function () 
					UIRole.wearEquipClick(i);
				end);
			else
				wearSlotList[i].setIcon(const.EQUIP_ICON[i]);
			end
		end
	end



	function UIRole.showRoleInfo()
		this:GO("RoleInfo.Name").text =  player.name;	
		this:GO("RoleInfo.FightValue").text = "战力 "..player.fightPoint;	
	end

	function UIRole.UpdateFightNumber()
		this:GO("RoleInfo.FightValue").text =  "战力 "..player.fightPoint;	
	end

	function UIRole.showAttrPanel( )
		UIRole.panelAttr.show();
	end

	function UIRole.showBagPanel()
		UIRole.panelAttr.hide();
	end

    function UIRole.handleLevelUp()
		UIRole.panelAttr.showHp();
		UIRole.panelAttr.showExp();
	end

	function UIRole.closeSelf()
		RoleRTT:SetRttVisible(false);
		destroy(this.gameObject);
	end

	function UIRole.OnDestroy( )

	end

	return UIRole;
end

--属性界面
function CreateOldPanelAttr(wrapper)
	local PanelAttr = {};
	local player = DataCache.myInfo;

	-- 点击PK值栏 弹出悬浮提示
	local PKTip = wrapper:GO('PKTip');
	local PKGo = wrapper:GO('Info.PK');
	local ClearPKValue = wrapper:GO('ClearPKValue');

	PKGo:BindButtonClick(function ()
		PKTip:Show();
		local string;
		if DataCache.myInfo.level >= const.PKOpenLevel then
			string = "在野外杀死白名玩家将增加恶名值\n在线每30分钟降低1点";
		else
			string = "30级以下角色处于新手保护期，\n无法进行PK，也不会有死亡惩罚";
		end
		PKTip:GO('bg.text').text = string;
	end);
	
	PKTip:GO('close'):BindButtonClick(function ()
		PKTip:Hide();
	end);

	PKGo:GO('BtnClear'):BindButtonClick(function ()
		-- 显示清除杀戮值弹窗
		if math.ceil(player.kill_value) <= 0 then
			ui.showMsg("恶名值为0，无需清除");
			return;
		end
		local needDiamondNum = const.PKValueDiamond * math.ceil(player.kill_value);
		ClearPKValue:GO('text').text = "是否立即花费" .. needDiamondNum .. "钻石清除恶名值?"; 
		ClearPKValue:Show();
	end);
	ClearPKValue:GO('close'):BindButtonClick(function ()
		ClearPKValue:Hide();
	end);
	ClearPKValue:GO('btn'):BindButtonClick(function ()
		local killValue = math.ceil(player.kill_value)
		-- 界面打开期间杀戮值可能变化
		if killValue == 0 then
			ui.showMsg("恶名值为0，无需清除");
			ClearPKValue:Hide();	
			return;
		end
		local needDiamondNum = const.PKValueDiamond * math.ceil(player.kill_value);
		if needDiamondNum > DataCache.role_diamond then
			ClearPKValue:Hide();
			ui.showCharge();
		else
			-- 钻石充足，可以进行杀戮值清除
			client.killValueCtrl.ClearKillValue('diamond', needDiamondNum , function ()
				ClearPKValue:Hide();
			end);
		end
	end);
	
	function PanelAttr.Init( )
		--切页按钮
		local commonDlgGO = wrapper:GO('CheckBox');	--这个是UIWrapper
		PanelAttr.controller = createCDC(commonDlgGO)
		PanelAttr.controller.SetButtonNumber(2);
		PanelAttr.controller.SetButtonText(1,"属 性");
		PanelAttr.controller.bindButtonClick(1,PanelAttr.showAttr);		
		PanelAttr.controller.SetButtonText(2,"资 料");
		PanelAttr.controller.bindButtonClick(2,PanelAttr.showInfo);
	end

	function PanelAttr.showAttr()
		wrapper:GO('Info').gameObject:SetActive(false);
		wrapper:GO('Attr').gameObject:SetActive(true);

		PanelAttr.showExp();
		PanelAttr.showHp();
		PanelAttr.UpdateAttr();
	end

	function PanelAttr.showInfo()
		wrapper:GO('Info').gameObject:SetActive(true);
		wrapper:GO('Attr').gameObject:SetActive(false);
		PanelAttr.showKillValue();
		PanelAttr.showLegionName();
	end

	function PanelAttr.show()
		wrapper.gameObject:SetActive(true);
		
		PanelAttr.controller.activeButton(1)
	end

	function PanelAttr.hide()
		wrapper.gameObject:SetActive(false);
		clearTire:Hide();
	end

	function PanelAttr.showExp()
		local exp = tb.ExpTable[player.level].levExp;
		wrapper:GO('Attr.wenzi_exp.dk_exp.exppt').fillAmount = player.exp / exp;
		wrapper:GO('Attr.wenzi_exp.dk_exp.Text').text =  player.exp .."/".. exp;
	end

	function PanelAttr.showHp()
		wrapper:GO('Attr.wenzi_hp.dk_hp.hppt').fillAmount = player.hp / player.maxHP;
		wrapper:GO('Attr.wenzi_hp.dk_hp.Text').text =  player.hp .."/".. player.maxHP;		
	end

	function PanelAttr.showKillValue()
		local killValue = math.ceil(player.kill_value);
		local colorStr;
		if killValue == 0 then
			colorStr = "#e4e4e4"
		else
			colorStr = "#CE2041"
		end
		wrapper:GO('Info.PK.value').text = string.format("<color=%s>%s</color>", colorStr, killValue);
	end

	-- 公会发生变化时数据要更新
	function PanelAttr.showLegionName()
		local legionName = wrapper:GO('Info.Clan.value');
		if client.role.haveClan() then
			legionName.text = client.legion.LegionBaseInfo.Name;
		else
			legionName.text = "未加入";
		end
	end

	function PanelAttr.UpdateAttr()
		local FightAttrPanel = wrapper:GO('Attr.FightAttr');

		FightAttrPanel:GO('wenzi_atk.value').text = (player.phyAttackMin+player.phyAttack).."~"..(player.phyAttackMax+player.phyAttack);
		FightAttrPanel:GO('wenzi_defend.value').text = player.phyDefense;
		FightAttrPanel:GO('wenzi_hit.value').text = player.hit;
		FightAttrPanel:GO('wenzi_dodge.value').text = player.dodge;
		FightAttrPanel:GO('wenzi_crit.value').text = player.critical;
		FightAttrPanel:GO('wenzi_toughness.value').text = player.tenacity;
		FightAttrPanel:GO('wenzi_poji.value').text = player.brokenBlock;
		FightAttrPanel:GO('wenzi_gedang.value').text = player.block;	

		FightAttrPanel:GO('wenzi_addAttack.value').text = math.round(player.damageAmplifyP*100).."%";
		FightAttrPanel:GO('wenzi_reduceAttack.value').text = math.round(player.damageResistP*100).."%";	
		FightAttrPanel:GO('wenzi_ignoreDefend.value').text = math.round(player.defenseReduceP*100).."%";
		FightAttrPanel:GO('wenzi_resistAttack.value').text = math.round(player.attackReduceP*100).."%";
		FightAttrPanel:GO('wenzi_hpRecover1.value').text = player.fightHPRecover;
		FightAttrPanel:GO('wenzi_hpRecover2.value').text = player.freeHPRecover;
	end
	
	PanelAttr.Init( );
	return PanelAttr;
end
