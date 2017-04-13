function UIActivityView(param)
	local this = nil;
	local UIActivity = {};
	local dailyPanel = nil;
	--local wrapContent = nil;
	local itemPrefab = nil;
	local Panel = nil;
	local Item = nil;
	local Content = nil;
	local barground = nil;
	local bar1 = nil;
	local bar2 = nil;
	local bar3 = nil;
	local bar4 = nil;
	local bar5 = nil;

	local barImg1 = nil;
	local barImg2 = nil;
	local barImg3 = nil;
	local barImg4 = nil;
	local barImg5 = nil;
	local barImgTab = {};
	local active_value = nil;

	local activeValue_1 = nil;
	local activeValue_2 = nil;
	local activeValue_3 = nil;
	local activeValue_4 = nil;
	local activeValue_5 = nil;
	local activeTab = {};
	local yilinqu1 = nil;
	local yilinqu2 = nil;
	local yilinqu3 = nil;
	local yilinqu4 = nil;
	local yilinqu5 = nil;
	local yilinquTab = {};
	local time = nil;
	local outLineGuaJi = nil;
	local active1 = nil;
	local active2 = nil;
	local active3 = nil;
	local active4 = nil;
	local active5 = nil;
	local active_wrapper_1 = nil;
	local active_wrapper_2 = nil;
	local active_wrapper_3 = nil;
	local active_wrapper_4 = nil;
	local active_wrapper_5 = nil;
	local active_wrapperTab = {};
	local shanbai = nil;
	local effect1 = nil;
	local effect2 = nil;
	local effect3 = nil;
	local effect4 = nil;
	local effect5 = nil;
	local active_iconTab = {};
	local effectTab = {};
	local jinduTab = {0, 0, 0, 0 ,0};
	local buyGuajibtn = nil;
	local lock = nil;
	local guaji = nil;
	local right = nil;
	local activeEffect_1 = nil;
	local activeEffect_2 = nil;
	local activeEffect_3 = nil;
	local activeEffect_4 = nil;
	local activeEffect_5 = nil;
	local activeEffectTab = nil;
	----------------------------------------------资源找回-------------------------------------------
	function UIActivity.Start()
		this = UIActivity.this;
		Panel = this:GO('Panel');
		client.activity.mainTip = false;
		UIManager.GetInstance():CallLuaMethod("MainUI.DeleteActivityTip");
		dailyPanel = Panel:GO('DailyPanel');
		-------------------------------------------------------------------------默认打开显示日常活动
		--Item = dailyPanel:GO('Top.view.viewport.Item');
		--Content = dailyPanel:GO('Top.view.viewport');
		bar1 = Panel:GO('DailyPanel.Center.jindutiao1');
		bar2 = Panel:GO('DailyPanel.Center.jindutiao2');
		bar3 = Panel:GO('DailyPanel.Center.jindutiao3');
		bar4 = Panel:GO('DailyPanel.Center.jindutiao4');
		bar5 = Panel:GO('DailyPanel.Center.jindutiao5');
		active_value = Panel:GO('DailyPanel.Center.sfValue');

		barImg1 = bar1:GO('jindu'):GetComponent("Image");
		barImg2 = bar2:GO('jindu'):GetComponent("Image");
		barImg3 = bar3:GO('jindu'):GetComponent("Image");
		barImg4 = bar4:GO('jindu'):GetComponent("Image");
		barImg5 = bar5:GO('jindu'):GetComponent("Image");
		barImgTab = {barImg1, barImg2, barImg3, barImg4, barImg5};

		activeValue_1 = Panel:GO('DailyPanel.Center.active1.value');
		activeValue_2 = Panel:GO('DailyPanel.Center.active2.value');
		activeValue_3 = Panel:GO('DailyPanel.Center.active3.value');
		activeValue_4 = Panel:GO('DailyPanel.Center.active4.value');
		activeValue_5 = Panel:GO('DailyPanel.Center.active5.value');
		activeTab = {activeValue_1, activeValue_2, activeValue_3, activeValue_4, activeValue_5};

		active1 = Panel:GO('DailyPanel.Center.active1');
		active2 = Panel:GO('DailyPanel.Center.active2');
		active3 = Panel:GO('DailyPanel.Center.active3');
		active4 = Panel:GO('DailyPanel.Center.active4');
		active5 = Panel:GO('DailyPanel.Center.active5');
		active_iconTab = {active1, active2, active3, active4, active5};

		-- 事件爆点特效
		effect4 = active4:GO('effect'):GetComponent("UIWrapper");
		effect5 = active5:GO('effect'):GetComponent("UIWrapper");
		effectTab = {0,0,0,effect4,effect5}; 

		-- 设置点击事件以及特效
		active_wrapper_1 = Panel:GO('DailyPanel.Center.active1'):GetComponent("UIWrapper");
		active_wrapper_2 = Panel:GO('DailyPanel.Center.active2'):GetComponent("UIWrapper");
		active_wrapper_3 = Panel:GO('DailyPanel.Center.active3'):GetComponent("UIWrapper");
		active_wrapper_4 = Panel:GO('DailyPanel.Center.active4'):GetComponent("UIWrapper");
		active_wrapper_5 = Panel:GO('DailyPanel.Center.active5'):GetComponent("UIWrapper");
		active_wrapperTab = {active_wrapper_1, active_wrapper_2, active_wrapper_3, active_wrapper_4, active_wrapper_5};

		--已领取图标
		yilinqu1 = active_wrapper_1:GO('icon');
		yilinqu2 = active_wrapper_2:GO('icon');
		yilinqu3 = active_wrapper_3:GO('icon');
		yilinqu4 = active_wrapper_4:GO('icon');
		yilinqu5 = active_wrapper_5:GO('icon');
		yilinquTab = {yilinqu1, yilinqu2, yilinqu3, yilinqu4, yilinqu5};

		time = Panel:GO('DailyPanel.Bottom.Right.Effect');
		outLineGuaJi = Panel:GO('DailyPanel.Bottom.Right.Time');
		guaji = Panel:GO('DailyPanel.Bottom.Right.Bg');
		buyGuajibtn = Panel:GO('DailyPanel.Bottom.Right.add');
		lock = Panel:GO('DailyPanel.Bottom.Right.lock');
		right = Panel:GO('DailyPanel.Bottom.Right');

		--活跃值特效loadUI------------------------------------
		this:Delay(0.01, function() 
			UIActivity.InitEffect();
			UIActivity.ShowActiveValue(client.activity.activeValue);
		end);
		-----------------------------------------------------------------------------------
		local commonDlgGO = this:GO('CommonDlg');
		UIActivity.controller = createCDC(commonDlgGO)
		UIActivity.controller.SetButtonNumber(3);
		UIActivity.controller.SetButtonText(1,"日常");
		UIActivity.controller.SetButtonText(2,"限时");
		UIActivity.controller.SetButtonText(3,"找回");
        client.activity.GetTimesList();

		UIActivity.dailyAct = CreateDailyAct(this:GO('Panel.DailyPanel.Top') ,this);
		UIActivity.limitedAct = CreateLimitAct(this:GO('Panel.DailyPanel.Top2'), this);
		UIActivity.findbackAct = CreateFindBackAct(this:GO('Panel.FindBackPanel'), this);

		UIActivity.controller.bindButtonClick(0,UIActivity.closeSelf);
		UIActivity.controller.bindButtonClick(1,UIActivity.OpenDailyAct);
		UIActivity.controller.bindButtonClick(2,UIActivity.OpenLimitedAct);
		UIActivity.controller.bindButtonClick(3,UIActivity.OpenFindBackAct);

		EventManager.bind(this.gameObject,Event.ON_LEVEL_UP, function() 
			UIActivity.dailyAct.Refresh();
			UIActivity.limitedAct.Refresh();
			UIActivity.ShowRedPoint();
			UIActivity.ShowOutLineGuaijiTime();
			end);

		EventManager.bind(this.gameObject,Event.ON_CBT_Changed, function()
			UIActivity.dailyAct.Refresh();
			UIActivity.ShowRedPoint();
		end);

		EventManager.bind(this.gameObject,Event.ON_FINDBACKTIMES_CHANGE, UIActivity.findbackAct.Refresh)
		EventManager.bind(this.gameObject,Event.ON_BUY_OFFLINE_TIME, UIActivity.ShowOutLineGuaijiTime);
		EventManager.bind(this.gameObject,Event.ON_ACTIVE_VALUE_CHANGE, UIActivity.ActiveValueRefresh);
		EventManager.bind(this.gameObject,Event.ON_ACTIVE_LIST_CHANGE, UIActivity.ShowRedPoint);
		-- EventBinder.RegisterEvent(this.gameObject,Event.ON_EVENT_RED_POINT, function()
		-- 	UIActivity.dailyAct.Refresh();
		-- 	UIActivity.limitedAct.Refresh();
		-- 	UIActivity.ShowRedPoint();
		-- end);

		-- 活跃度进度初始化
        UIActivity.ShowProgressBar(client.activity.activeValue);
        UIActivity.ShowOutLineGuaijiTime();
		UIActivity.ShowRedPoint();
		if param.page == "dailyAct" then
			UIActivity.controller.activeButton(1);
		elseif param.page == "limitedAct" then
			UIActivity.controller.activeButton(2);
		elseif param.page == "findbackAct" then
			UIActivity.controller.activeButton(3);
		end
		return UIActivity;
	end

	function UIActivity.InitEffect()
		--活跃值特效loadUI------------------------------------
		activeEffect_1 = this:LoadUIEffect(this.gameObject, "huodongjiemian", true, true);
		activeEffect_2 = this:LoadUIEffect(this.gameObject, "huodongjiemian", true, true);
		activeEffect_3 = this:LoadUIEffect(this.gameObject, "huodongjiemian", true, true);
		activeEffect_4 = this:LoadUIEffect(this.gameObject, "huodongjiemian", true, true);
		activeEffect_5 = this:LoadUIEffect(this.gameObject, "huodongjiemian", true, true);
		activeEffectTab = {activeEffect_1, activeEffect_2, activeEffect_3, activeEffect_4, activeEffect_5};
		for i = 1, 5 do
			activeEffectTab[i].transform:SetParent(active_wrapperTab[i].transform)
        	activeEffectTab[i].transform.localScale = Vector3.one;
        	activeEffectTab[i].transform.localPosition = Vector3.zero;
		end
	end

	function UIActivity.Update()
		if getServerDayIndex(5, 0, 0) > client.activity.nowServerDay then
			client.activity.RequestXuanShang(function ()
				client.activity.GetTimesList();
				UIActivity.dailyAct.Refresh();
				UIActivity.limitedAct.Refresh();
				UIActivity.ActiveValueRefresh()
				end);
			client.activity.GetResourceInfo(function(reply)
					local list = reply["list"];
					client.activity.HandleFindData(list);
					client.activity.RequestLevel(function()  
						UIActivity.findbackAct.Refresh();
						end);
				end);
			client.activity.nowServerDay = getServerDayIndex(5, 0, 0);
		end
	end

	function UIActivity.closeSelf()
		destroy(this.gameObject);
	end

	function UIActivity.ActHide()
		Panel:GO('DailyPanel').gameObject:SetActive(false);
	end 

	function UIActivity.ActShow()
		Panel:GO('DailyPanel').gameObject:SetActive(true);
	end 

	function UIActivity.OpenDailyAct()
		UIActivity.ActShow();
		UIActivity.dailyAct.show();
		UIActivity.limitedAct.hide();
		UIActivity.findbackAct.hide();
	end

	function UIActivity.OpenLimitedAct()
		UIActivity.ActShow();
		UIActivity.dailyAct.hide();
		UIActivity.limitedAct.show();
		UIActivity.findbackAct.hide();
	end

	function UIActivity.OpenFindBackAct()
		UIActivity.ActHide();
		UIActivity.findbackAct.show();
	end
	
	function UIActivity.ActiveValueRefresh()
		UIActivity.ShowProgressBar(client.activity.activeValue);
		UIActivity.ShowActiveValue(client.activity.activeValue);
	end

	-- 显示进度条进度
	function UIActivity.ShowProgressBar(value)
		-- 取value的上边值（1-5）
		local k = UIActivity.get_TopK(value);
		if value <= tb.ActiveTab[5].value then
			if k == 1 then
				jinduTab[1] = value;
				jinduTab[2] = 0;
				jinduTab[3] = 0;
				jinduTab[4] = 0;
				jinduTab[5] = 0;
			else
				jinduTab[1] = tb.ActiveTab[1].value;
				for i = 2, k do
					if i ~= k then
						jinduTab[i] = tb.ActiveTab[i].value - tb.ActiveTab[i-1].value;
					else
						jinduTab[i] = value - tb.ActiveTab[i-1].value;
					end
				end
			end
		else
			for i = 1, 5 do
				if i == 1 then 
					jinduTab[i] = tb.ActiveTab[i].value;
				else
					jinduTab[i] = tb.ActiveTab[i].value - tb.ActiveTab[i-1].value
				end
			end
		end
		for i = 1, 5 do
			active_wrapperTab[i]:GO('bg').sprite = tb.ActiveTab[i].icon;
			if tb.ActiveTab[i].count ~= nil then
				active_wrapperTab[i]:GO('count').gameObject:SetActive(true);
				active_wrapperTab[i]:GO('count').text = formatMoney(tb.ActiveTab[i].count);
			end
			activeTab[i].text = tb.ActiveTab[i].value.."活跃";
			activeTab[i].gameObject:SetActive(true);
			if i == 1 then
				barImgTab[i].fillAmount = jinduTab[i]/tb.ActiveTab[i].value;
			else
				barImgTab[i].fillAmount = jinduTab[i]/(tb.ActiveTab[i].value - tb.ActiveTab[i-1].value);
			end 
			active_wrapperTab[i]:BindButtonClick(function() 
				UIActivity.BarClick(i)
			end);
		end
	end

	function UIActivity.ShowActiveValue(value)
		local k = UIActivity.get_BottomK(value);
		active_value.text = value;
		active_value.gameObject:SetActive(true);
		if k > 0 then
			for i = 1, k do
				if client.activity.activelist[i][2] == 1 then
					yilinquTab[i]:SetNaiveSize();
					yilinquTab[i].gameObject:SetActive(true);
					activeEffectTab[i].gameObject:SetActive(false);
				else
					yilinquTab[i].gameObject:SetActive(false);
					-- active_wrapperTab[i]:PlayUIEffectForever(this.gameObject, "huodongjiemian");
					activeEffectTab[i].gameObject:SetActive(true);
				end
			end
			if k ~= 5 then
				for i = k+1, 5 do
					activeEffectTab[i].gameObject:SetActive(false);
				end
			end
		else
			for i = 1, 5 do
				yilinquTab[i].gameObject:SetActive(false);
				-- active_wrapperTab[i]:StopAllUIEffects();
				activeEffectTab[i].gameObject:SetActive(false);
			end
		end
	end

	function UIActivity.BarClick(k)
		--点击具体的某一个按钮领取活跃值奖励，此时播放领取特效,k位下边值
		local index = UIActivity.get_BottomK(client.activity.activeValue);
		local list = client.activity.activelist;
		if list[k][2] == 0 and k <= index then
			activeEffectTab[k].gameObject:SetActive(false);
			-- active_wrapperTab[k]:StopAllUIEffects();
			--播放领取特效
			-- if (k == 4) or (k == 5) then
			-- 	active_wrapperTab[k]:PlayUIEffect(this.gameObject, "shanbai");
			-- 	effectTab[k]:PlayUIEffect(this.gameObject, "shiqu_tuowei_baise");
			-- 	if k == 4 then
			-- 		local position = effect4.transform.position;
			-- 		--print(position);
			-- 		--print(effect4.gameObject)
			-- 		iTween.MoveTo(effect4.gameObject, Vector3.New(position.x + 1.3, position.y -1.3, position.z), 1.5);
			-- 	end
			-- 	if k == 5 then
			-- 		local position = effect5.transform.position;
			-- 		iTween.MoveTo(effect5.gameObject, Vector3.New(position.x - 1.3, position.y -1.3, position.z), 1.5);
			-- 	end

			-- 	this:Delay(1.5, function()
			-- 		time:GetComponent("UIWrapper"):PlayUIEffect(this.gameObject, "baodian_act", 1);
			-- 		end);
			-- 	this:Delay(1.5, function()
			-- 		yilinquTab[k].gameObject:SetActive(true)
			-- 		end);
			-- else
			yilinquTab[k].gameObject:SetActive(true);
			-- end
			client.activity.GetActiveReward(k, function(reply)
				local id = reply["id"];
				if id == 4 or id == 5 then
					local award = reply["value"];
					local newTime = reply["total"];
					if DataCache.offlineTime < 1200 then
						local hour = award / 60;
						ui.showMsg("获得"..hour.."小时离线挂机时间(最多累积20小时)");
						this:Delay(1.5, function ()
							UIActivity.ShowOffLineTime(newTime);
							DataCache.offlineTime = newTime;
						end);
					else
						ui.showMsg("最多累积20小时离线挂机时间");
					end
				end
			end);
			client.activity.activelist[k][2] = 1;
			EventManager.onEvent(Event.ON_ACTIVE_LIST_CHANGE);
		else
			local item_id = tb.ActiveTab[k].sid;
			PanelManager:CreateConstPanel('ActItemFloat',UIExtendType.BLACKCANCELMASK,{sid = item_id, index = k});
		end
	end

	function UIActivity.ShowOutLineGuaijiTime()
		-- local openGuaji = client.userCtrl.IsOpenGuaji()
		-- local data = DataCache.offlineTime;
		-- buyGuajibtn.gameObject:SetActive(openGuaji);
		-- lock.gameObject:SetActive(not openGuaji);
		-- outLineGuaJi.gameObject:SetActive(openGuaji);

		-- right:BindButtonClick(ui.GuajiTips);
		-- buyGuajibtn:BindButtonClick(ui.buyGuajiTime);
		-- UIActivity.ShowOffLineTime(data);
	end

	function UIActivity.get_TopK(value)
		local k = nil;
		if value <= tb.ActiveTab[1].value then
			k = 1;
		else
			if value > tb.ActiveTab[5].value then
				k = 5;
			else
				for i = 1, 4 do
					if value > tb.ActiveTab[i].value and value <= tb.ActiveTab[i+1].value then
						k = i+1;
					end
				end
			end
		end
		return k;
	end

	function UIActivity.get_BottomK(value)
		local k = nil;
		if value < tb.ActiveTab[1].value then
			k = 0;
		else
			if value >= tb.ActiveTab[5].value then
				k = 5;
			else
				for i = 1, 4 do
					if value >= tb.ActiveTab[i].value and value < tb.ActiveTab[i+1].value then
						k = i;
					end
				end
			end
		end 
		return k;
	end

	function UIActivity.ShowOffLineTime(data)
		if data == nil then
			data = 0;
		end
		local hour = math.modf(data/60);
		local minute = data % 60;
		local str = nil;
		if hour == 0 then
			str = minute.."分钟";
		else

			str = hour.."小时"..minute.."分钟";

		end
		outLineGuaJi.text = str;
	end

	function UIActivity.ShowPageRed1()
		UIActivity.controller.SetRedPoint(1, client.activity.CheckPageRed1() or client.activity.getActiveValueRed());
	end
	function UIActivity.ShowPageRed2()
		activity.RequestBossState(function(bossStateList)
			local flag = client.activity.CheckBossRed(bossStateList)
			UIActivity.controller.SetRedPoint(2, flag);
		end);
	end

	function UIActivity.ShowRedPoint()
		-- UIActivity.ShowPageRed1();
		UIActivity.ShowPageRed2();
	end

	return UIActivity;
end

-----------------日常活动-----------------------------------------
function CreateDailyAct(wrapper, this)
	local UIDailyAct = {};
	function UIDailyAct.Init()
		local itemPrefab = wrapper:GO("view.viewport.item").gameObject;
		-- 数据操作转到ctrl中
		local dailyList =  client.activity.getDailyAct();
		itemPrefab:SetActive(false);
		local warpContent = wrapper:GO("view"):GetComponent("UIWarpContent");
		warpContent.goItemPrefab = itemPrefab;
		warpContent:BindInitializeItem(UIDailyAct.FormatItem);
		warpContent:Init(#dailyList);
	end

	function UIDailyAct.FormatItem(go, index)
		local wrapper = go:GetComponent("UIWrapper"):GO('Item');
		local clickBg = wrapper:GO('spBg');
		clickBg.gameObject:SetActive(false);
		wrapper:UnbindAllButtonClick();
		wrapper:BindButtonClick(function()
			clickBg.gameObject:SetActive(true);
			UIDailyAct.Click(index, clickBg);
		end);

		local list = client.activity.dailyActList;
		local item = list[index];
		wrapper:GO('spIcon.Icon').sprite = item.icon;
		wrapper:GO('spIcon.Icon'):SetNaiveSize();
		wrapper:GO('sfName').text = item.name;
		if item.left_top ~= nil then
			-- 左上角推荐图片代入
			wrapper:GO('left_top').gameObject:SetActive(true);
			wrapper:GO('left_top').sprite = item.left_top;
		end
		-- 将次数与活跃值隐藏
		local times = wrapper:GO('sfTimes');
		local active = wrapper:GO('sfActive');
		times.gameObject:SetActive(false);
		active.gameObject:SetActive(false);
		if item.times then
			times.gameObject:SetActive(true);
			local str = client.activity.TimesList[item.id].."/"..item.times;
			-- if client.activity.TimesList[item.id] == item.times then
			-- 	times:GO('times').text = string.format("<color=#cf1010>%s</color>", str);
			-- else
			-- 	times:GO('times').text = str;
			-- end
			times:GO('times').text = str;
		end

		if item.times_text then
			times.gameObject:SetActive(true);
			times:GO('times').text = item.times_text;
		end

		if item.active_value then
			active.gameObject:SetActive(true);
			if item.id == const.ActivityId.moLongChuE then
				if client.activity.TimesList[item.id] == item.times then
					active:GO('value').text = item.total_value.."/"..item.total_value;
				else
					active:GO('value').text = "0/"..item.total_value;
				end
			else
				active:GO('value').text = client.activity.TimesList[item.id] * item.active_value.."/"..item.total_value;
			end
		end

		--将按钮和已完成和显示条件隐藏 
		local btn = wrapper:GO('btn');
		local btntext = btn:GO('text');
		local cost = btn:GO('cost');
		local Result = wrapper:GO('spResult');
		local condition = wrapper:GO('sfCondition');
		btn.gameObject:SetActive(false);
		cost.gameObject:SetActive(false);
		Result.gameObject:SetActive(false);
		condition.gameObject:SetActive(false);
		if item.done == const.ActShowStart.cando then

			btn.gameObject:SetActive(true);
			btn:BindButtonClick(function()
				UIDailyAct.ClickBtn(item.id);
				end);
			if item.id == const.ActivityId.outLine then
				btntext.text = "设置";
			else
				btntext.text = "前往";
			end
		end
		if item.done == const.ActShowStart.done then
			if item.id == const.ActivityId.shiLianMiJing then
				btn.gameObject:SetActive(true);
				cost.gameObject:SetActive(true);
				btntext.text = "助战";
				cost:GO('value').text = "100";
			else
				Result.gameObject:SetActive(true);
			end
		end
		if item.done == const.ActShowStart.showButNotStart then
			-- 已显示未开启的活动显示等级
			condition.gameObject:SetActive(true);
			local str = string.format("<color=#cf1010>%s".."级开启".."</color>", item.level);
			wrapper:GO('sfCondition.value').text = str;
		end
		-- 红点
		-- if client.activity.CheckRed(item.id) then
		-- 	wrapper:GO('spIcon.redpoint').gameObject:SetActive(true);
		-- else
		-- 	wrapper:GO('spIcon.redpoint').gameObject:SetActive(false);
		-- end
	end

	function UIDailyAct.Click(i, gameObject)
		local data = client.activity.dailyActList[i];
		data.go = gameObject;
		PanelManager:CreateConstPanel("ActivityFloat", UIExtendType.BLACKCANCELMASK, data);
	end

	function UIDailyAct.ClickBtn(id)
		if id == const.ActivityId.xuanShang then
			client.RewardTask.GetRewardTasks(function (taskList) 
			PanelManager:CreatePanel('UIRewardTask',UIExtendType.BLACKMASK, {taskList = taskList});
		end);
		end
		if id == const.ActivityId.cangBaoTu then
			PanelManager:CreatePanel('UICangBaoTu' , UIExtendType.BLACKMASK, {});
		end
		if id == const.ActivityId.shiLianMiJing then
			ui.showMsg("暂未开放，敬请期待！");
			--PanelManager:CreatePanel('UIFuben' , UIExtendType.BLACKMASK, {});
		end
		if id == const.ActivityId.moLongDao then
			ui.ShowMolongTask();
		end
		if id == const.ActivityId.moLongChuE then
			ui.showMsg("暂未开放!");
		end
		if id == const.ActivityId.wild then
			local scene = tb.SceneTable[DataCache.scene_sid];
            if not scene.transfer then
                ui.showMsg("特殊区域无法使用野外挂机功能");
                return;
            end
			
			UIDailyAct.GetRecommandNpc(function (npcSid)
				local npcInfo = tb.NPCTable[npcSid];
				local phyDeffenseText;
				local color;
				local str;
				local scene_npc_info = tb.MapOnlyNPCTable[npcSid]
				if tonumber(scene_npc_info.phyDeffense) > DataCache.myInfo.phyDefense then
					-- 怪物推荐战力大于角色战力，显示红色
					color = "156,35,35";
				else
					-- 怪物推荐战力小于等于角色战力，显示绿色
					color = "43,228,47";
				end
				phyDeffenseText = "[color:"..color..","..scene_npc_info.phyDeffense.."]";
				str = string.format("是否立即前往推荐挂机点［LV.%d %s］（推荐防御力: %s）进行挂机？", npcInfo.level, npcInfo.name, phyDeffenseText)
				ui.showMsgBox("野外挂机", str,
					function ()
						local posX = scene_npc_info.pos[1] + math.random(-10,10);
						local posY = scene_npc_info.pos[2] + math.random(-10,10);

						local pos = Vector2.New(posX,posY);
						TransmitScroll.ClickLinkPathing(scene_npc_info.scene_id, DataCache.fenxian, pos,
						function ()
							local player = AvatarCache.me;
							local class = Fight.GetClass(player);
							class.HandUp(player, true);
						end);
						UIManager.GetInstance():CallLuaMethod('UIActivity.closeSelf');
					end, nil);
			end);
		end
		if id == const.ActivityId.outLine then
			PanelManager:CreatePanel('UISetting',  UIExtendType.BLACKMASK, {});
		end
		if id == const.ActivityId.monsterHead then
			ui.showMsg("暂未开放!");
		end
	end

	function UIDailyAct.Refresh()
		UIDailyAct.Init();
	end

	function UIDailyAct.hide()
		wrapper.gameObject:SetActive(false);
	end

	function UIDailyAct.show()
		wrapper.gameObject:SetActive(true);
		--UIDailyAct.Refresh();
	end

	function UIDailyAct.GetRecommandNpc(callback)
    	local msg = {cmd = "get_offline_npc"}
        Send(msg, function(returnMsg)
            local npcSid = returnMsg["npc"];
            callback(npcSid);
		end)
    end


	UIDailyAct.Init();
	return UIDailyAct;
end

-----------------限时活动-----------------------------------------
function CreateLimitAct(wrapper, this)
	local UILimitedAct = {};

	function UILimitedAct.Init()

		local itemPrefab = wrapper:GO("view.viewport.item").gameObject;
		-- 数据操作转到ctrl中
		local LimitList =  client.activity.getLimitedAct();
		itemPrefab:SetActive(false);
		local warpContent = wrapper:GO("view"):GetComponent("UIWarpContent");
		warpContent.goItemPrefab = itemPrefab;
		warpContent:BindInitializeItem(UILimitedAct.FormatItem);
		warpContent:Init(#LimitList);
	end

	function UILimitedAct.FormatItem(go, index)
		local wrapper = go:GetComponent("UIWrapper"):GO('Item');
		local clickBg = wrapper:GO('spBg');
		clickBg.gameObject:SetActive(false);

		wrapper:UnbindAllButtonClick();
		wrapper:BindButtonClick(function()
			clickBg.gameObject:SetActive(true);
			UILimitedAct.Click(index, clickBg);
		end);

		local list = client.activity.limitedActList;
		local item = list[index];

		wrapper:GO('spIcon.Icon').sprite = item.icon;
		wrapper:GO('spIcon.Icon'):SetNaiveSize();
		wrapper:GO('sfName').text = item.name;
		if item.left_top ~= nil then
			-- 左上角推荐图片代入
			wrapper:GO('left_top').gameObject:SetActive(true);
			wrapper:GO('left_top').sprite = item.left_top;
		end
		-- 将次数与活跃值隐藏
		local times = wrapper:GO('sfTimes');
		local active = wrapper:GO('sfActive');
		times.gameObject:SetActive(false);
		active.gameObject:SetActive(false);
		if item.times then
			times.gameObject:SetActive(true);
			str = client.activity.TimesList[item.id].."/"..item.times;
			times:GO('times').text = str;
		end

		if item.times_text then
			times.gameObject:SetActive(true);
			times:GO('times').text = item.times_text;
		end
		
		if item.active_value then
			active.gameObject:SetActive(true);
			active:GO('value').text = client.activity.TimesList[item.id] * item.active_value.."/"..item.total_value;
		end
		-- 对按钮，已完成，显示条件进行设置
		local btn = wrapper:GO('btn');
		local btntext = btn:GO('text');
		local Result = wrapper:GO('spResult');
		local condition = wrapper:GO('sfCondition');
		btn.gameObject:SetActive(false);
		Result.gameObject:SetActive(false);
		condition.gameObject:SetActive(false);

		if item.done == const.ActShowStart.cando then
			btn.gameObject:SetActive(true);
			btn:BindButtonClick(function()
				UILimitedAct.ClickBtn(item.id);
				end);
			btntext.text = "前往"
		end
		if item.id == const.ActivityId.SceneBoss then
			if client.activity.CheckBossRed(activity.BossStateList) then
				wrapper:GO('spIcon.redpoint').gameObject:SetActive(true);
			else
				wrapper:GO('spIcon.redpoint').gameObject:SetActive(false)
			end
		end
	end

	function UILimitedAct.Click(i, gameObject)
		local data = client.activity.limitedActList[i];
		data.go = gameObject;
		PanelManager:CreateConstPanel("ActivityFloat", UIExtendType.BLACKCANCELMASK, data);
	end

	function UILimitedAct.ClickBtn(id)
		if id == const.ActivityId.Legion then
			ui.showMsg("暂未开放");
		end
		if id == const.ActivityId.SceneBoss then
			destroy(this.gameObject);
			activity.RequestBossState(function()
				PanelManager:CreatePanel('UIBoss', UIExtendType.TRANSMASK, {});
			end);
		end
	end

	function UILimitedAct.Refresh()
		UILimitedAct.Init();
	end

	function UILimitedAct.hide()
		wrapper.gameObject:SetActive(false);
	end

	function UILimitedAct.show()
		wrapper.gameObject:SetActive(true);
		--UILimitedAct.Refresh();
	end

	UILimitedAct.Init();

	return UILimitedAct;
end

-----------------资源找回-----------------------------------------
function CreateFindBackAct(_wrapper, this)
	local UIFindBackAct = {};
	local wrapper = _wrapper:GO('Top');
	local buy = _wrapper:GO('Buy');
	local toggle_diamond = _wrapper:GO('Bottom.group.diamond.bg.show');
	local toggle_money = _wrapper:GO('Bottom.group.money.bg.show');
	local toggle_diamond_select = _wrapper:GO('Bottom.group.diamond.bg');
	local toggle_money_select = _wrapper:GO('Bottom.group.money.bg');
	toggle_diamond.gameObject:SetActive(client.activity.recordResourceState);
	toggle_money.gameObject:SetActive(not client.activity.recordResourceState);

	toggle_diamond_select:BindButtonClick(function() 
		if not toggle_diamond:IsShow() then
			toggle_diamond.gameObject:SetActive(true);
			toggle_money.gameObject:SetActive(false);
			client.activity.recordResourceState = toggle_diamond:IsShow();
		end
		UIFindBackAct.Init();
	 end);

	toggle_money_select:BindButtonClick(function() 
		if not toggle_money:IsShow() then
			toggle_diamond.gameObject:SetActive(false);
			toggle_money.gameObject:SetActive(true);
			client.activity.recordResourceState = toggle_diamond:IsShow();
		end
		UIFindBackAct.Init()
	 end);

	client.activity.GetResourceInfo(function(reply) 
		local list = reply["list"];
			client.activity.HandleFindData(list)
		end);

	function UIFindBackAct.Init()
		local itemPrefab = wrapper:GO("view.viewport.item").gameObject;
		-- 数据操作转到ctrl中
		local findBackList =  client.activity.getBackAct();
		itemPrefab:SetActive(false);
		local warpContent = wrapper:GO("view"):GetComponent("UIWarpContent");
		warpContent.goItemPrefab = itemPrefab;
		if #findBackList ~= 0 then
			warpContent:BindInitializeItem(UIFindBackAct.FormatItem);
			warpContent:Init(#findBackList);
		end
		-- 请求服务端获取可召回次数
	end

	function UIFindBackAct.FormatItem(go, index)
		local wrapper = go:GetComponent("UIWrapper"):GO('_item');
		local clickBg = wrapper:GO('spBg');
		local btn = wrapper:GO('btn');
		local btn_diamond = wrapper:GO('btn.diamond');
		local btn_money = wrapper:GO('btn.money');
		local list = client.activity.findBackActList;
		local item = list[index];
		local str = nil;
		if toggle_diamond:IsShow() then
			btn_diamond.gameObject:SetActive(true);
			btn_diamond:GO('value').text = item.cost_diamond[client.activity.five_clock_level - item.level + 1][2];
			btn_money.gameObject:SetActive(false);
		else
			btn_money.gameObject:SetActive(true);
			btn_money:GO('value').text = item.cost_money[client.activity.five_clock_level - item.level + 1][2];
			btn_diamond.gameObject:SetActive(false);
		end

		--目前没有VIP系统，VIP次数暂且置为0
		local num1 = item.canFind - client.activity.resource_Info_doneFind[const.SidToIndex[item.id]];
		local num2 = 0; 
		wrapper:UnbindAllButtonClick();
		-- wrapper:BindButtonClick(function()
		-- 	clickBg.gameObject:SetActive(true);
		-- 	UIFindBackAct.Click(index, clickBg);
		-- end);

		btn:BindButtonClick(function ()
			if item.IsFindDone == 0 then
				if num1 == 1 then
					if toggle_diamond:IsShow() then
						if DataCache.role_diamond >= item.cost_diamond[client.activity.five_clock_level - item.level + 1][2] then
							client.activity.ResourceFindBack(item.id, 1, 1, client.activity.five_clock_level);
						else
							ui.showMsgBox(nil, "钻石不足，请充值！", ui.showChargePage);
						end
					else
						if DataCache.role_money >= item.cost_money[client.activity.five_clock_level - item.level + 1][2] then
							client.activity.ResourceFindBack(item.id, 1, 0, client.activity.five_clock_level);
						else
							ui.showMsg("金币不足");
						end
					end
				else
					UIFindBackAct.ClickFindBack(index, go, item, toggle_diamond:IsShow());
				end
			end
		end)

		clickBg.gameObject:SetActive(false);
		wrapper:GO('sfName').text = item.name;

		if num2 ~= 0 then
			if num1 ~= 0 then
				str = string.format("可找回<color=#8bbb10>%s</color>次，VIP额外<color=#8bbb10>+%s</color>", num1, num2);
				wrapper:GO('btn').gameObject:SetActive(true);
				wrapper:GO('spDone').gameObject:SetActive(false);
			else
				str = string.format("可找回<color=#cf1010>%s</color>次，VIP额外<color=#8bbb10>+%s</color>", num1, num2);
				wrapper:GO('btn').gameObject:SetActive(false);
				wrapper:GO('spDone').gameObject:SetActive(true);
			end
		else
			if num1 ~= 0 then
				str = string.format("可找回<color=#8bbb10>%s</color>次",num1);
				wrapper:GO('btn').gameObject:SetActive(true);
				wrapper:GO('spDone').gameObject:SetActive(false);
			else
				str = string.format("可找回<color=#cf1010>%s</color>次",num1);
				wrapper:GO('btn').gameObject:SetActive(false);
				wrapper:GO('spDone').gameObject:SetActive(true);
			end
		end
		
		wrapper:GO('sfText').text = str;

		local icon1 = wrapper:GO('grid.icon1'):GetComponent("UIWrapper")
		local icon2 = wrapper:GO('grid.icon2'):GetComponent("UIWrapper");
		local icon3 = wrapper:GO('grid.icon3'):GetComponent("UIWrapper");
		local icon4 = wrapper:GO('grid.icon4'):GetComponent("UIWrapper");
		wrapper:GO('grid.icon1').gameObject:SetActive(false);
		wrapper:GO('grid.icon2').gameObject:SetActive(false);
		wrapper:GO('grid.icon3').gameObject:SetActive(false);
		wrapper:GO('grid.icon4').gameObject:SetActive(false);
		icon1:BindButtonClick(function() 
			local param = {sid = 10020005};
			PanelManager:CreateConstPanel('ActItemFloat',UIExtendType.BLACKCANCELMASK, param);
		end);
		icon2:BindButtonClick(function() 
			local param = {sid = 10000001};
			PanelManager:CreateConstPanel('ActItemFloat',UIExtendType.BLACKCANCELMASK, param);
		end);


		-- 经验显示
		if toggle_diamond:IsShow() then
			local str = item.diamond_find_exp[client.activity.five_clock_level - item.level+1][2];
			if str ~= 0 then
				icon1:GO('count').text = formatMoney(str);
				icon1.sprite = const.QUALITY_A_BG[1];
				icon1:GO('bg').sprite = "tb_exp";
				icon1:GO('bg'):SetNaiveSize();
				icon1.gameObject:SetActive(true);
			end
		else
			local str = item.money_find_exp[client.activity.five_clock_level - item.level+1][2];
			if str ~= 0 then
				icon1:GO('count').text = formatMoney(str);
				icon1.sprite = const.QUALITY_A_BG[1];
				icon1:GO('bg').sprite = "tb_exp";
				icon1:GO('bg'):SetNaiveSize();
				icon1.gameObject:SetActive(true);
			end
		end

		-- 金币显示
		if toggle_diamond:IsShow() then
			local str = item.diamond_find_money[client.activity.five_clock_level - item.level+1][2];
			if str ~= 0 then
				icon2:GO('count').text = formatMoney(str);
				icon2.sprite = const.QUALITY_A_BG[1];
				icon2:GO('bg').sprite = "tb_jinbi_wupin";
				icon2:GO('bg'):SetNaiveSize();
				icon2.gameObject:SetActive(true);
			end
		else
			local str = item.money_find_money[client.activity.five_clock_level - item.level+1][2];
			if str ~= 0 then
				icon2:GO('count').text = formatMoney(str);
				icon2.sprite = const.QUALITY_A_BG[1];
				icon2:GO('bg').sprite = "tb_jinbi_wupin";
				icon2:GO('bg'):SetNaiveSize();
				icon2.gameObject:SetActive(true);
			end
		end

		if toggle_diamond:IsShow() then
			local sidItem = item.diamond_find_item[client.activity.five_clock_level - item.level+1][2];
			for i = 1, #sidItem do
				if #sidItem[i][1] == 1 then
					local count = icon3:GO('count');
					local bg = icon3:GO('bg');
					local num = sidItem[i][2];
					local sid = sidItem[i][1][1];
					if tb.ItemTable[sid] ~= nil then
						bg.sprite = tb.ItemTable[sid].icon;
						icon3.sprite = const.QUALITY_A_BG[tb.ItemTable[sid].quality+1];
					end
					if tb.GemTable[sid] ~= nil then
						bg.sprite = tb.GemTable[sid].icon;
						icon3.sprite = const.QUALITY_A_BG[tb.GemTable[sid].quality+1];
					end
					if tb.EquipTable[sid] ~= nil then
						bg.sprite = tb.EquipTable[sid].icon;
						icon3.sprite = const.QUALITY_A_BG[tb.EquipTable[sid].quality+1];
					end
					count.text = num;
					icon3.gameObject:SetActive(true);
					icon3:SetNaiveSize();
					bg:SetNaiveSize();

					icon3:BindButtonClick(function() 
					local param = {sid = sid};
					PanelManager:CreateConstPanel('ActItemFloat',UIExtendType.BLACKCANCELMASK, param);
				end);
				else
					local count = icon4:GO('count');
					local bg = icon4:GO('bg');
					for j = 1, #sidItem[i][1] do
						local sid = sidItem[i][1][j]; 
						local num = sidItem[i][2];
						if tb.ItemTable[sid] ~= nil then
							-- bg.sprite = "tb_hongbaoshi_1";
						end 
						if tb.GemTable[sid] ~= nil then
							bg.sprite = "tb_hongbaoshi_1";
							icon4.sprite = const.QUALITY_A_BG[tb.GemTable[sid].quality+1];
						end 
						if tb.EquipTable[sid] ~= nil then
							-- bg.sprite = "tb_hongbaoshi_1";
						end 
						count.text = num;
						icon4.gameObject:SetActive(true);
						icon4:SetNaiveSize();
						bg:SetNaiveSize();

						icon4:BindButtonClick(function() 
						local param = {sid = 11150001};
						PanelManager:CreateConstPanel('ActItemFloat',UIExtendType.BLACKCANCELMASK, param);
					end);
					end
				end
			end
		else
			local sidItem = item.money_find_item[client.activity.five_clock_level - item.level +1][2];
			for i = 1, #sidItem do
				if #sidItem[i][1] == 1 then
					local count = icon3:GO('count');
					local bg = icon3:GO('bg');
					local num = sidItem[i][2];
					local sid = sidItem[i][1][1];
					if tb.ItemTable[sid] ~= nil then
						bg.sprite = tb.ItemTable[sid].icon;
						icon3.sprite = const.QUALITY_A_BG[tb.ItemTable[sid].quality+1];
					end
					if tb.GemTable[sid] ~= nil then
						bg.sprite = tb.GemTable[sid].icon;
						icon3.sprite = const.QUALITY_A_BG[tb.GemTable[sid].quality+1];
					end
					if tb.EquipTable[sid] ~= nil then
						bg.sprite = tb.EquipTable[sid].icon;
						icon3.sprite = const.QUALITY_A_BG[tb.EquipTable[sid].quality+1];
					end
					count.text = num;
					icon3.gameObject:SetActive(true);
					icon3:SetNaiveSize();
					bg:SetNaiveSize();

					icon3:BindButtonClick(function() 
					local param = {sid = sid};
					PanelManager:CreateConstPanel('ActItemFloat',UIExtendType.BLACKCANCELMASK, param);
				end);
				else
					local count = icon4:GO('count');
					local bg = icon4:GO('bg');
					for j = 1, #sidItem[i][1] do
						local sid = sidItem[i][1][j]; 
						local num = sidItem[i][2];
						if tb.ItemTable[sid] ~= nil then
							-- bg.sprite = "tb_hongbaoshi_1";
						end 
						if tb.GemTable[sid] ~= nil then
							bg.sprite = "tb_hongbaoshi_1";
							icon4.sprite = const.QUALITY_A_BG[tb.GemTable[sid].quality+1];
						end 
						if tb.EquipTable[sid] ~= nil then
							-- bg.sprite = "tb_hongbaoshi_1";
						end 
						count.text = num;
						icon4.gameObject:SetActive(true);
						icon4:SetNaiveSize();
						bg:SetNaiveSize();

						icon4:BindButtonClick(function() 
						local param = {sid = 11150001};
						PanelManager:CreateConstPanel('ActItemFloat',UIExtendType.BLACKCANCELMASK, param);
					end);
					end
				end
			end
		end
	end

	function UIFindBackAct.ClickFindBack(i, gameObject, item, flag)
		local param = {};
		param.index = i;
		param.diamond = flag;
		param.item = item;
		PanelManager:CreateConstPanel('UIResourceFindBack', UIExtendType.BLACKMASK, param);
	end

	function UIFindBackAct.hide()
		_wrapper.gameObject:SetActive(false);
	end

	function UIFindBackAct.show()
		_wrapper.gameObject:SetActive(true);
		--UIFindBackAct.Refresh();
	end

	function UIFindBackAct.Refresh()
		UIFindBackAct.Init();
	end

	UIFindBackAct.Init();
	return UIFindBackAct;
end