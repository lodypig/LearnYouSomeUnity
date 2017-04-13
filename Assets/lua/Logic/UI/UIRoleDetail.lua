function UIRoleDetailView(param)
	local UIRoleDetail = {};
	local this = nil;
	local player = nil;
	local equipList = {};
	local enhanceList = {};

	function UIRoleDetail.Start( )
		this = UIRoleDetail.this;
		player = DataCache.otherInfo;
		UIRoleDetail.parseEquipList();
      
		local commonDlgGO = this:GO('CommonDlg3');	--这个是UIWrapper
		UIRoleDetail.controller = createCDC(commonDlgGO)
		UIRoleDetail.controller.bindButtonClick(0,UIRoleDetail.closeSelf);		
		UIRoleDetail.showRole();

	end

	function UIRoleDetail.parseEquipList()
		if player == nil then
			return
		end

		if player.equipment == nil then
			return;
		end

		--解析装备
		equipList = player.equipment; --client.tools.arr2table(player.equipment);
		-- print("装备数据")
		-- DataStruct.DumpTable(equipData)
		-- for i = 1, #equipData do
		-- 	local equip = equipData[i];
		-- 	if 0 == equip then
		-- 		equipList[i] = nil;
		-- 	else
		-- 		equipList[i] = equip;	--client.equip.parseEquip(equip);
		-- 		equipList[i].pos = i;
		-- 	end
		-- end


        if player.enhance == nil then
			return;
		end

		--解析强化等级	
		-- local enhanceData = player.enhance; --client.tools.arr2table(player.enhance);
		-- print("强化等级")
		-- DataStruct.DumpTable(enhanceData)
		-- local info;
		-- for i = 1, #enhanceData do
		-- 	local slot = {};
		-- 	info = enhanceData[i];
		-- 	slot.buwei = info[1];
		-- 	slot.level = info[2];
		-- 	enhanceList[i] = slot;		
		-- end
		enhanceList = player.enhance
	end

	function UIRoleDetail.showRole( )
		UIRoleDetail.showRoleAttr();
		UIRoleDetail.showEquip();
		UIRoleDetail.show3DRole();
	end

	function UIRoleDetail.showEquip( )
		local equipMapInfo = {};
		for i = 1, #equipList do
			local equip = equipList[i];
			if equip ~= nil then
				local equipSid = equip.sid;
				local equip_data = tb.EquipTable[equipSid];
				local suitId = equip_data.suitId;
				local recoveryTime = equip.recoveryTime;

				if recoveryTime == 0 and suitId ~= 0 and equip.quality == 4 then
					equipMapInfo[equipSid] = true;
				end
			end
		end
		for i = 1, const.WEAREQUIP_COUNT do
			local wrapper = this:GO("EquipPanel.equip"..i);
			local slot = CreateSlot(wrapper.gameObject);
			
			local equip = equipList[i];
			local enhanceInfo = {};
			local gemInfo = {};
			enhanceInfo.level = enhanceList[i][2];
			gemInfo = DataCache.otherInfo.gemMap[i];
			slot.reset();
			if equip then
                slot.setWareEquip(equip);
				wrapper:BindButtonClick(function ()
					PanelManager:CreateConstPanel('EquipFloat',UIExtendType.BLACKCANCELMASK,{showType = "show",isScreenCenter = true,  base = equip, equipMap = equipMapInfo, enhance = enhanceInfo, gemList = gemInfo});
				end);
			else
				slot.setIcon(const.EQUIP_ICON[i]);
				slot.setFrame(const.QUALITY_BG_Equip[1])
			end
		end
	end

	function UIRoleDetail.showRoleAttr( )
		-- this:GO('AttrPanel.Name').text = player.name;
		-- this:GO('AttrPanel.wenzi_hp.dk_hp.Text').text = player.maxHP;
		this:GO('AttrPanel.BaseInfo.Name.value').text = player.name;
		this:GO('FightPoint.value').text = player.fightPoint;
		-- this:GO("AttrPanel.fightValue").text =  "战力 "..player.fightPoint;
		this:GO('AttrPanel.BaseInfo.Level.value').text = player.level;
		local legionName;
		if not player.legion_name or player.legion_name == "" then
			legionName = "未加入"
		else
			legionName = player.legion_name
		end
		this:GO('AttrPanel.BaseInfo.Clan.value').text = legionName;
		this:GO('AttrPanel.BaseInfo.headImg.img').sprite = const.RoleImgTab[player.career][player.sex + 1];
		--战斗属性
		local FightAttrPanel = this:GO('AttrPanel.FightAttr');
		FightAttrPanel:GO('maxhp.value').text = player.maxHP;

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

	function UIRoleDetail.show3DRole( )
		local equipTable = {};
		if equipList ~= nil then
			for i=1, #equipList do
				if equipList[i] ~= nil then
					equipTable[#equipTable + 1] = {sid = equipList[i].sid, id = 0, quality = 0};
				end
			end
		end

		-- role rtt
		if OtherRoleRTT == 0 then
      		OtherRoleRTT = CreateOtherRoleRTT()
      	else
      		OtherRoleRTT.UpdateRtt(DataCache.otherInfo)
      	end
		RTTManager.SetRoleFigure(this:GO('3DRole.RoleFigure'), OtherRoleRTT, false, true);
		RTTManager.SetRoleFigure(this:GO('3DRole.MirrorFigure'), OtherRoleRTT, true, true);
	end

	function UIRoleDetail.showMounts( )
		-- body
	end

	function UIRoleDetail.closeSelf()
		OtherRoleRTT:SetRttVisible(false);
		destroy(this.gameObject);
	end

	function UIRoleDetail.OnDestroy( )
	end

	return UIRoleDetail;
end

function ShowOtherRoleInfo()
	PanelManager:CreatePanel('UIRoleDetail',  UIExtendType.NONE, {});
end

function GetRoleDetail(roleId, callback)
	local msg = {cmd = "get_role_attr", role_uid = roleId}
    Send(msg, function (msg) 
    	DataCache.otherInfo = {}
    	DataCache.ParseAttr(msg.attr, DataCache.otherInfo)
    	--转换
    	callback()
    end)
end
