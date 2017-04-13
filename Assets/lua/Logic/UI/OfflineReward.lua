function OfflineRewardView (param)
	local OfflineReward = {};
	local this = nil;
	local CurPage = 2;
	local RewardPanel = nil;
	local DeadInfoPanel = nil;
	local itemPrefab = nil;
	local grid = nil;
	local realNumber = 0;
	local flag = nil;
	--local equQuality = {"white", "green", "bule", "purple", "orange"}

	function OfflineReward.Start ()
		this = OfflineReward.this;
		local reward = param.reward;
		RewardPanel = this:GO('Panel.RewardPanel');
		DeadInfoPanel = this:GO('Panel.DeadInfoPanel');
		itemPrefab = DeadInfoPanel:GO("ScrollView.Viewport.Item").gameObject;
		grid = DeadInfoPanel:GO("ScrollView.Viewport.ButtonGroup");
		--绑定按钮点击
		this:GO('Panel.RewardBtn'):BindButtonClick(OfflineReward.ShowRewardPanel);
		this:GO('Panel.DeadInfoBtn'):BindButtonClick(OfflineReward.ShowDeadInfoPanel);
		this:GO('Panel.BtnClose'):BindButtonClick(OfflineReward.Close);

		flag = this:GO('Panel.DeadInfoBtn.flag');

		if reward.dead_info ~= nil then
			for i=1,#reward.dead_info do
				if reward.dead_info[i][4][1] ~= 0 or reward.dead_info[i][4][2] ~= 0 or reward.dead_info[i][4][2] ~= 0 then
					realNumber = realNumber + 1;
				end
			end
		end
		--初始化两个面板并显示奖励面板
		OfflineReward.FormatRewardPanel(reward)
		OfflineReward.FormatDeadInfoPanel(reward)
		OfflineReward.ShowRewardPanel();
	end

	function OfflineReward.FormatRewardPanel(reward)
		local remain_time = client.tools.formatTime(DataCache.offlineTime*60);
		local guaji_time = client.tools.formatTime(reward.last_time*60);
		--初始化上方信息
		RewardPanel:GO('Content.Time.Value').text = string.format("%s小时%s分", guaji_time.hour, guaji_time.minute);
		local totalExp = client.role.getTotalExp();
		local preExp = totalExp - reward.exp;
		local preLevel = client.tools.exp2level(preExp);
		if DataCache.myInfo.level > preLevel then
			RewardPanel:GO('Content.Level.Value').text = string.format("%s级→ %s级", preLevel, DataCache.myInfo.level);
		else
			RewardPanel:GO('Content.Level.Value').text = string.format("%s级", DataCache.myInfo.level);
		end
		RewardPanel:GO('Content.Exp.Value').text = client.tools.formatNumber2(reward.exp);

		--初始化拾取
		local equList = reward.equip;
		local pickText = "";
		for i= #equList,1,-1 do
			local count = equList[i][2];
			if count ~= nil and count > 0 then
				pickText = pickText..string.format("<color=%s>%s色装备X%s</color> ", const.qualityColor[i], const.Quality2Name[i], count);
			end
		end 

		if pickText == "" then
			RewardPanel:GO('Pick.Value').text = "<color=#e4e4e4>无</color>";
		else
			RewardPanel:GO('Pick.Value').text = pickText;
		end
	end

	local FormatEmptyList = function(count)
	    for i = 1,count do
	        local go = newObject(itemPrefab);
	        go:SetActive(true);
	        go.name = 'item'..tostring(i);
	        go.transform:SetParent(grid.transform);
	        go.transform.localScale = Vector3.one;
	        go.transform.localPosition = Vector3.zero;
	    end
    end

    local FormatDeadItem = function(deadInfo,index)
    	--print(deadInfo)
		local item = grid:GO("item"..index);
		local killerName = client.tools.ensureString(deadInfo[3])
		--print(killerName)
		item:GO('deadText').text = os.date("%m-%d %H:%M:%S", deadInfo[1])..string.format(" 被<color=#ffffff>%s</color>击杀", killerName);
		item:GO('number1').text = "X"..deadInfo[4][1]..",";
		item:GO('number2').text = "X"..deadInfo[4][2]..",";
		item:GO('number3').text = "X"..deadInfo[4][3];
    end

	function OfflineReward.FormatDeadInfoPanel(reward)
		if realNumber ~= 0 then
			flag:Show();
			FormatEmptyList(realNumber);
			local index = 1;
			for i=1,#reward.dead_info do
				FormatDeadItem(reward.dead_info[i],index);
				index = index + 1;
			end
		else
			flag:Hide();
			DeadInfoPanel:GO("ScrollView"):Hide();
			DeadInfoPanel:GO("Tips"):Show();
		end	
	end

	local SetButtonState = function(Btn,bPress)
		if bPress == true then
			Btn.sprite = "bqy_liang";
			Btn:GO("Text").color = Color.New(255/255, 225/255, 152/255, 255/255);
		else
			Btn.sprite = "bqy_an";
			Btn:GO("Text").color = Color.New(125/255, 121/255, 117/255, 255/255);			
		end
	end

	function OfflineReward.ShowRewardPanel()
		if CurPage == 2 then
			SetButtonState(this:GO('Panel.RewardBtn'),true);
			SetButtonState(this:GO('Panel.DeadInfoBtn'),false);
			RewardPanel:Show();
			DeadInfoPanel:Hide();
			CurPage = 1;
		end
	end	

	function OfflineReward.ShowDeadInfoPanel()
		if CurPage == 1 then
			flag:Hide();
			SetButtonState(this:GO('Panel.RewardBtn'),false);
			SetButtonState(this:GO('Panel.DeadInfoBtn'),true);
			RewardPanel:Hide();
			DeadInfoPanel:Show();
			CurPage = 2;
		end
	end	

	function OfflineReward.Retrieve()
		OfflineReward.Close()
	end

	function OfflineReward.Close()
		destroy(this.gameObject);
	end

	return OfflineReward;
end

function ui.ShowOfflineReward(reward)
	 PanelManager:CreateConstPanel('OfflineReward',UIExtendType.BLACKMASK, {reward = reward});
end