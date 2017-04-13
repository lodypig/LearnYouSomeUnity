function UIBossRewardView(param)
	local UIBossReward = {};
	local duration = 0.5
	local this = nil
	local lastTime = 0
	local isPlay = false
	local hashtable = nil

	function UIBossReward.closeSelf()
		destroy(this.gameObject)
	end

	function UIBossReward.Start()
		this = UIBossReward.this
		UIBossReward.diwenRect = this:GO('diwen'):GetComponent('RectTransform')
		UIBossReward.diwen_StartSize = UIBossReward.diwenRect.sizeDelta.x
		UIBossReward.diwen_EndSize = 519

		UIBossReward.info = this:GO('info')
		UIBossReward.SetInfo()
		UIBossReward.info:Hide()

		this:GO('info.okbtn'):BindButtonClick(UIBossReward.closeSelf)

        lastTime = TimerManager.GetUnityTime();

		isPlay = true
		UIBossReward.Title = this:GO('title')

		local TargetPos = Vector3(0,254,0)
		hashtable = iTween.Hash("time",duration,"easetype", "linear","isLocal",true);
		Util.MoveToEx(UIBossReward.Title.gameObject, TargetPos,hashtable,nil);
	end

	function UIBossReward.Update()
		if isPlay then
			local time = TimerManager.GetUnityTime() - lastTime
			
			if time > duration then
				time = duration
				isPlay = false
				UIBossReward.info:Show()
			end
			local diwen_now = time / duration * (UIBossReward.diwen_EndSize - UIBossReward.diwen_StartSize)
			UIBossReward.diwenRect.sizeDelta = Vector2.New(UIBossReward.diwen_StartSize + diwen_now, UIBossReward.diwen_StartSize + diwen_now)
		end
	end

	function UIBossReward.SetInfo()
		-- param:hurt_rank, my_rank, my_award
		--伤害排名
		local meinRank = false
		for i=1,5 do
			local rank = param.hurtrank[i]
			local ui = this:GO('info.rank.'..i)
			if rank ~= nil then
				if tonumber(rank[1]) == DataCache.myInfo.role_uid then
					meinRank = true
				end
				local name = tostring(client.tools.ensureString(rank[2]))
				local hurtvalue = tonumber(rank[3])
				if name ~= nil and hurtvalue ~= nil then
					ui:GO('text').text = string.format("%s: %d", name, hurtvalue)
				else 
					ui:GO('text').text = ""
				end
				ui:Show()
			else
				ui:Hide()
			end
		end
		--我的排名
		if not meinRank then
			this:GO('info.rank.my'):Show()
			this:GO('info.rank.my.num').text = string.format("%s", param.myrank[1])
			this:GO('info.rank.my.text').text = string.format("%s: %s", client.tools.ensureString(param.myrank[2]), param.myrank[3])
		else
			this:GO('info.rank.my'):Hide()
		end
		--我的排名奖励
		local awardlist = param.myaward
		local item_prefab = this:LoadAsset("BagItem")
		local reward_part = this:GO('info.reward')
		for k,v in pairs(awardlist) do
			local award_id = v[1]
			local award_num = v[2]
			--UI
            local go = newObject(item_prefab);
            go:SetActive(true);
            go.name = award_id;
            go.transform:SetParent(reward_part.transform);
            go.transform.localScale = Vector3.one;
            go.transform.localPosition = Vector3.zero;
            -- local wrapper = go:GetComponent("UIWrapper")
            -- wrapper:BindButtonClick(rewardClick)
			local slotCtrl = CreateSlot(go);
			--同时组织物品提示(拾取信息 && 聊天栏系统频道)
			if award_id == "gold" then
				--金币
				local moneyid = const.numercialNameToId.money
				local jinBiItem = {sid = moneyid , quality = tb.ItemTable[moneyid].quality , count = award_num};
				slotCtrl.reset();
				slotCtrl.setItem(jinBiItem);
				--local itemtip = "金币 x "..award_num
				--local tip = string.format("你获得了%s", itemtip)
				--client.SimpleSysMsg.ShowMsg(itemtip)
				--client.chat.clientSystemMsg(tip)
			 --物品提示直接通用做
			else
			 	--物品ID
			 	local itemsid = tonumber(award_id)
			 	slotCtrl.reset();
			 	slotCtrl.setItemFromSid(itemsid)
			 	slotCtrl.setAttr(award_num)
			 	-- local itemtip = ""
			 	-- local tip = ""
			 	-- local itemname = tb.ItemTable[itemsid].name
			 	-- if award_num > 1 then
			 	-- 	itemtip = itemname.."x"..award_num
			 	-- else
			 	-- 	itemtip = itemname
			 	-- end
			 	-- tip = string.format("你获得了%s", itemtip)
			 	-- client.SimpleSysMsg.ShowMsg(itemtip)
			 	-- client.chat.clientSystemMsg(tip)
			end
		end
	end

	return UIBossReward
end
