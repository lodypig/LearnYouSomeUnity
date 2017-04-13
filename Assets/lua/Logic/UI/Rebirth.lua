function RebirthView ()
	local Rebirth = {};
	local this = nil;

	local TitleName = nil;
	local SafePlace = nil;
	local SafeShuoming = nil;
	local Yahei = nil;
	local Daojishi = nil;
	local OnSite = nil;
	local ImageItem = nil;
	local SiteShuoming = nil;
	local Count = nil;
	local ImageDianmond = nil;
	local SiteYahei = nil;

	local enableRebirth;
	local rebirthTime;
	local diamondNeed = 0;

	local FUBEN_REBIRTH_TIME = 5;
	local REBIRTH_TIME_ADD = 5;
	local REBIRTH_TIME_MAX = 30;
	local SAFE_REBIRTH_HPRADIO = 0.3;

	function Rebirth.Start ()
		this = Rebirth.this;
		TitleName = this:GO('Animator.TitlePanel._TitleName');
		SafePlace = this:GO('Animator._SafePlace');
		SafeShuoming = this:GO('Animator._SafePlace._SafeShuoming');
		Yahei = this:GO('Animator._SafePlace._Yahei');
		Daojishi = this:GO('Animator._SafePlace._Daojishi');
		OnSite = this:GO('Animator._OnSite');
		ImageItem = this:GO('Animator._OnSite._ImageItem');
		SiteShuoming = this:GO('Animator._OnSite._SiteShuoming');
		Count = this:GO('Animator._OnSite._Count');
		ImageDianmond = this:GO('Animator._OnSite._ImageDianmond');
		SiteYahei = this:GO('Animator._OnSite._SiteYahei');

		SafePlace:BindButtonClick(Rebirth.OnRebirthInSafePlace);
		OnSite:BindButtonClick(Rebirth.OnRebirthInSitePlace);
		Rebirth.StartCountDown();
		Rebirth.initUIShow();
		EventManager.bind(this.gameObject, Event.ON_TIME_SECOND_CHANGE, Rebirth.handleDJS);
		uFacadeUtility.SetDeadGauss(true);

	end

	function Rebirth.handleDJS()
		if not enableRebirth then
			if AvatarCache.me.is_auto_fighting == true then
				Rebirth.OnRebirthInSafePlace();
			end
			return;
		end
		rebirthTime = rebirthTime - 1;
		if rebirthTime == 0 then
			enableRebirth = false;
			Yahei.gameObject:SetActive(false);
		end
		Daojishi.text = rebirthTime;
	end

	function Rebirth.StartCountDown()
		enableRebirth = true;
		local roleInfo = DataCache.myInfo;
		local nowSecond = TimerManager.GetServerNowSecond();
		if SceneManager.IsFubenMap(DataCache.scene_sid) then
			rebirthTime = roleInfo.multiDeathTime + FUBEN_REBIRTH_TIME - nowSecond;
		else
			local needWaitTime = roleInfo.multiDeathCount * REBIRTH_TIME_ADD;
			if needWaitTime > REBIRTH_TIME_MAX then
				needWaitTime = REBIRTH_TIME_MAX;
			end
			rebirthTime = roleInfo.multiDeathTime + needWaitTime - nowSecond;
		end
		if rebirthTime < 0 then
			rebirthTime = 0;
		end
	end

	function Rebirth.initUIShow()
		local roleInfo = DataCache.myInfo;
		if roleInfo.multiDeathKiller ~= nil and roleInfo.multiDeathKiller ~= "" then
			TitleName.text = string.format("你被%s击杀了", roleInfo.multiDeathKiller);
		else
			TitleName.text = "你已死亡";
		end
		SafeShuoming.text = string.format("回复生命    %d（%d%%）", roleInfo.maxHP * SAFE_REBIRTH_HPRADIO, SAFE_REBIRTH_HPRADIO*100);
		local siteRebirthCount = roleInfo.siteRebirthCount;
		local rebirthDate = tb.rebirthInfoTable[siteRebirthCount];
		SiteShuoming.text = string.format("回复生命    %d（%d%%）", roleInfo.maxHP * rebirthDate.hpRadio, rebirthDate.hpRadio*100);

		local itemCount = Bag.GetItemCountBysid(rebirthDate.itemSid);
		if itemCount < rebirthDate.itemCount then
			diamondNeed = rebirthDate.itemCount * 10;
			ImageItem.gameObject:SetActive(false);
			ImageDianmond.gameObject:SetActive(true);
			Count.text = diamondNeed;
			if DataCache.role_diamond < diamondNeed then
				SiteYahei.gameObject:SetActive(true);
			end
		else
			Count.text = rebirthDate.itemCount;
		end
		if rebirthTime == 0 then
			enableRebirth = false;
			Yahei.gameObject:SetActive(false);
		end
		Daojishi.text = rebirthTime;
	end

	--安全点复活
	function Rebirth.OnRebirthInSafePlace()
		if enableRebirth then
			return;
		end


		local msg = {cmd = "rebone", type = "home"};
		Send(msg);
		Rebirth.close();
	end

	--原地复活
	function Rebirth.OnRebirthInSitePlace()
		if diamondNeed > 0 and DataCache.role_diamond < diamondNeed then
			SysInfoLayer.GetInstance():ShowMsg("钻石不足");
			return;
		end
		local msg = {cmd = "rebone", type = "here"};
		Send(msg, function (reply)
			--DataStruct.DumpTable(reply);
			local type = reply["type"];
			if type == "fail" then
				SysInfoLayer.GetInstance():ShowMsg(string.format("原地复活失败：%s", reply["reason"]));
			else
				DataCache.myInfo.siteRebirthCount = reply["count"];
				DataCache.myInfo.lastSiteRebirthTime = reply["time"];
				Rebirth.close();
			end
		end)
	end

	function Rebirth.close()	
		destroy(this.gameObject);
	end

	function Rebirth.OnDestroy()
		uFacadeUtility.SetDeadGauss(false);
	end

	return Rebirth;
end
