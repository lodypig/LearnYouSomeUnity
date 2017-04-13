function UIFubenZhunBeiView ()
	local UIFubenZhunBei = {};
	local this = nil;
	local title = nil;
	local btns = nil;
	local ready = nil;
	local timetext = nil;
	local tokens = {};
	local bIsDead = false;

	function UIFubenZhunBei.Start ()
		this = UIFubenZhunBei.this;
		btns = this:GO('bk._btns');
		--title nil
		title = this:GO('bk._Top.Text');
		btns:GO('cancel'):BindButtonClick(UIFubenZhunBei.OnCancel);
		btns:GO('prepare'):BindButtonClick(UIFubenZhunBei.OnOK);		
		this:GO('bk.close'):BindButtonClick(UIFubenZhunBei.Close);

		ready = this:GO('bk._ready');
		timetext = this:GO('bk.timebk._time');
		for i = 1, const.team_max_member do			
			tokens[#tokens + 1] = this:GO('bk.tokens.token'..i);
		end
		client.FubenZhunBei.UpdatePanel = UIFubenZhunBei.UpdatePanel
		UIFubenZhunBei.UpdatePanel(client.FubenZhunBei.OkList)

		local fubenInfo = tb.fuben[client.fuben.cur_fuben_sid];
		if fubenInfo == nil then
			title.text = "随机副本";
		else
			title.text = fubenInfo.name;	--.."("..const.fubenDifficulty_text[fubenInfo.difficulty]..")";
		end
	end

	function UIFubenZhunBei.OnOK(go)
		--停止寻路动作 否则触发传送会导致位置错误
		local player = AvatarCache.me;
	    Fight.DoJumpState(player, SourceType.System, "Idle", 0);
	    uFacadeUtility.SyncStopMove();
	    
		ClearPathingInfo()
		client.fuben.q_confirm_prepare(client.fuben.cur_leader_id, client.fuben.cur_fuben_sid, 1, function() end)
	end

	function UIFubenZhunBei.OnCancel(go)
		client.fuben.q_confirm_prepare(client.fuben.cur_leader_id, client.fuben.cur_fuben_sid, 0, function() end)
		UIFubenZhunBei.Close()
	end

	function UIFubenZhunBei.Close()
		client.FubenZhunBei.UpdatePanel = nil 
		destroy(this.gameObject);
	end

	function UIFubenZhunBei.Update()
		if timetext ~= nil then
			local passTime = (TimerManager.GetServerNowMillSecond()/1000 - client.FubenZhunBei.StartTime)
			local remainTime = client.FubenZhunBei.LimitTime - passTime
			local text = os.date("%S", remainTime)
			timetext.text = text
		end
	end

	function UIFubenZhunBei.UpdatePanel(list)
		if list == nil or #list == 0 then
			return
		end
		if bIsDead == true then
			return
		end

		local count = math.min(#list, const.team_max_member)

		for i = 1,count do
			tokens[i].sprite = "tb_zuduizhunbei_2"
		end
		for i = count + 1,const.team_max_member do
			tokens[i].sprite = "tb_zuduizhunbei_1"
		end

		local haveself = client.FubenZhunBei.Haverole(DataCache.roleID)
		btns.gameObject:SetActive(not haveself)
		ready.gameObject:SetActive(haveself)
	end

	function UIFubenZhunBei.ShowCross()
		local list = client.FubenZhunBei.OkList;
		if list == nil then
			return
		end
		local count = math.min(#list, const.team_max_member);
		if count >= #tokens then
			count = #tokens - 1
		end
		tokens[count + 1].sprite = "tb_zuduizhunbei_3"
		bIsDead = true;
		this:Delay(2 , function ()
        	UIFubenZhunBei.Close();
        end);
	end

	return UIFubenZhunBei;
end

function ui.ShowFuBenZhunBei()
	PanelManager:CreatePanel('UIFubenZhunBei',UIExtendType.BLACKMASK, UIOpenType.CLOSEOTHER, {});
end