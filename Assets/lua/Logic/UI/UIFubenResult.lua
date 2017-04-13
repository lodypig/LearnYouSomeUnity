function UIFubenResultView(param)
	local UIFubenResult = {};
	local this = nil;
	local time = 10;

	local itemPrefab = nil;
    local itemGrid = nil;
    local itemList = {};

	function UIFubenResult.Start( )
		this = UIFubenResult.this;

		itemPrefab = this:GO('Win.Award.ItemList.BagItem');
        itemPrefab:Hide();
        itemGrid = this:GO('Win.Award.ItemList');

		this:GO('Bg'):BindButtonClick(UIFubenResult.OnExit);

		local result = param.result;

		if result == "win" then
			this:GO('Win').gameObject:SetActive(true);
			this:GO('Lose').gameObject:SetActive(false);

			local fubenData = tb.fuben[client.fuben.curFubenId];
	        local passTime = client.tools.formatTime(param.passtime);
	        
	        this:GO('Win.PassTime.Time').text = string.format("%02s:%02s", passTime.minute, passTime.second);
	        UIFubenResult.FromatAward(this:GO('Win.Award.Base'), param.baseAward)

	        --评分
	        UIFubenResult.PlayAppraise(param.appraise);

	        --评分奖励
	        UIFubenResult.FromatAward(this:GO('Win.Award.Appraise'), param.appraiseAward)

			this:GO('Effect'):PlayUIEffectForever(this.gameObject, "zhandoushengli");

			UIFubenResult.InitAwardItemList();
		else
			this:GO('Win').gameObject:SetActive(false);
			this:GO('Lose').gameObject:SetActive(true);

			this:GO('Effect'):PlayUIEffectForever(this.gameObject, "zhandoushibai");
		end

		EventManager.bind(this.gameObject, Event.ON_TIME_SECOND_CHANGE, UIFubenResult.onRefresh1Sec);
	end

	--播放评分特效
	function UIFubenResult.PlayAppraise(appraise)
		if appraise == nil then
			this:GO('Win.Appraise'):Hide();
			return;
		end
		this:GO('Win.Appraise'):Show();
		if appraise > 1 then
			appraise = appraise - 1;
			for i=1,appraise do
				this:Delay(0.4*i, function()
					this:GO('Win.Appraise.s'..i):PlayUIEffectForever(this.gameObject, "zhandoushengli_s");
				end)
			end
		else
			this:Delay(0.4, function()
				this:GO('Win.Appraise.s1'):PlayUIEffectForever(this.gameObject, "zhandoushengli_a");
			end)
		end
	end

	function UIFubenResult.FromatAward(wrapper, award)
		local count = 0;
		if award ~= nil then
			wrapper:GO('Money').gameObject:SetActive(award.money ~= nil);
			if award.money ~= nil then
				wrapper:GO('Money.Text').text = client.tools.formatNumber2(award.money);
				count = count + 1;
			end

			wrapper:GO('Diamond').gameObject:SetActive(award.diamond ~= nil);
			if award.diamond ~= nil then
				wrapper:GO('Diamond.Text').text = client.tools.formatNumber2(award.diamond);
				count = count + 1;
			end

			wrapper:GO('Exp').gameObject:SetActive(award.exp ~= nil);
			if award.exp ~= nil then
				wrapper:GO('Exp.Text').text = client.tools.formatNumber2(award.exp);
				count = count + 1;
			end
		end
		wrapper.gameObject:SetActive(count > 0)
	end

	function UIFubenResult.InitAwardItemList()
        local list = param.itemList;
        if list == nil then
        	return
        end
        for i=1, #list do
        	local data = list[i];
            local item = newObject(itemPrefab);
            item.transform:SetParent(itemGrid.transform);
            item.transform.localScale = Vector3.one;
            item.transform.localPosition = Vector3.zero;
            itemList[i] = item;
            
            itemList[i].gameObject.name = i;
            itemList[i].gameObject:SetActive(true);
			itemList[i]:BindButtonClick(function( )
				UIFubenResult.awardItemClick(data);
			end);

            local slotCtrl = CreateSlot(item);
            slotCtrl.reset();
            slotCtrl.setData(data);
        end
	end

	function UIFubenResult.awardItemClick(data)
		if data.isEquip then 
			local param = {};
			if data.equip ~= nil then
				param = {showType = "show",isScreenCenter = true ,base = data.equip, enhance = nil};
			else
				param = {showType = "random",isScreenCenter = true ,sid = data.id, quality = data.quality};
			end
			--PanelManager:CreateConstPanel('EquipFloat',UIExtendType.BLACKCANCELMASK, param);
		elseif data.isItem then
			local param = {bDisplay = true, sid = data.id};
			--PanelManager:CreateConstPanel('ItemFloat',UIExtendType.BLACKCANCELMASK,param);
		end	
	end


	function UIFubenResult.onRefresh1Sec( )
		time = time - 1
		if time < 0 then
			UIFubenResult.OnExit();
			return;
		end

		this:GO('ExitTime').text = string.format("轻触屏幕退出 %ss", time);
	end

	function UIFubenResult.OnExit( )
		if param.fubenType == "plotline" then
			PlotlineFuben.LeaveFuben();
		else
			client.fuben.q_leave_fuben();
		end
		UIFubenResult.closeSelf();
	end

	function UIFubenResult.OnDestroy(  )
        
	end

	function UIFubenResult.closeSelf()
		destroy(this.gameObject);
	end


	return UIFubenResult;
end
