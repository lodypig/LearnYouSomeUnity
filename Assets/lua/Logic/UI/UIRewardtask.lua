function UIRewardTaskView (param)
	local UIRewardTask  = {};
	local this = nil;
	local CtrlList = {};
	local TaskInfoCtrl = nil;
	local Tip1 = nil;
	local Close = nil;
	local ConsumeIcon = nil;
	local ConsumeNum = nil;
	local RefreshBtn = nil;
	local DelayRefreshID = nil;
	local DoRefreshEffect = nil;
	local Refresh_Ex = nil;
	local OnRotateComplete = nil;
	local UpdatePeerInfo = nil;


	-- d c b a s
	local QualityColorCfg = 
	{
		{"a5c2e4ff","dk_xuanshang_d"},
		{"28ffa1ff","dk_xuanshang_c"},	
		{"68b6ffff","dk_xuanshang_b"},
		{"eb68ffff","dk_xuanshang_a"},
		{"ffb400ff","dk_xuanshang_s"},
	};
	-- 1 空闲 2 追踪 3 完成 4 已完成
	local BtnStateCfg = 
	{
		{ "an_zhuizong",""},
		{ "an_lanse_1","追踪中…"},
		{ "an_lingjiang",""},
		{ "an_lanse_1","<color=#45d238>已领奖</color>"},
	}

	function UIRewardTask.Start ()
		this = UIRewardTask.this;

		local commonDlgGO = this:GO('CommonDlg3');	--这个是UIWrapper
		UIRewardTask.controller = createCDC(commonDlgGO)
		UIRewardTask.controller.bindButtonClick(0, UIRewardTask.Close);
		UIRewardTask.controller.SetTitle("wz_xuanshangrenwu")

		Tip1 = this:GO('Panel.Tips.Tip1');
		ConsumeIcon = this:GO('Panel.Consume.Icon');
		ConsumeNum = this:GO('Panel.Consume.Num');
		RefreshBtn = this:GO('Panel.Refresh');
		RefreshBtn:BindButtonClick(
			function () 
				client.RewardTask.RefreshTasks(UIRewardTask.RefreshCallBack)
		    end)


		TaskInfoCtrl = this:GO('Panel.TaskInfo.Task');
		local TaskParent = this:GO('Panel.TaskInfo');
		local TaskInfoCtrlPos = TaskInfoCtrl.transform.localPosition;
		local Width = TaskInfoCtrl.rectSize.x;
		local Interval = 18;
		CtrlList[#CtrlList+1] = TaskInfoCtrl;
		TaskInfoCtrl.transform.name = #CtrlList;
		for i = 1,4 do
			local go = newObject(TaskInfoCtrl.gameObject);
        	go.transform:SetParent(TaskParent.transform);
        	go.transform.localScale = Vector3.one;
        	go.transform.localPosition = Vector3.New(TaskInfoCtrlPos.x +(Width+Interval)*i ,TaskInfoCtrlPos.y,TaskInfoCtrlPos.z);
        	go:SetActive(true);
			CtrlList[#CtrlList + 1] = go:GetComponent("UIWrapper");      
        	go.transform.name = #CtrlList;
		end

		UIRewardTask.UpdateTaskInfo(param.taskList);
		client.RewardTask.AddListener(UIRewardTask.UpdateTaskInfo);
		UIRewardTask.CheckUpdateTime()
	end



-------------------------------------刷新效果表现-----------------------
	local DelayEffectFun = 
	{
		{
			function() DoRefreshEffect(1) end,
			function() DoRefreshEffect(2) end,
			function() DoRefreshEffect(3) end,
			function() DoRefreshEffect(4) end,
			function() DoRefreshEffect(5) end,
		},
		{
			function() UpdatePeerInfo(1) end,
			function() UpdatePeerInfo(2) end,
			function() UpdatePeerInfo(3) end,
			function() UpdatePeerInfo(4) end,
			function() UpdatePeerInfo(5) end,
		}

	}
	function UpdatePeerInfo(index)
		local task = client.RewardTask.TaskList[index];
		local ComCtrl = CtrlList[index];
		if ComCtrl == nil then
			return
		end
		local TaskName = ComCtrl:GO('TaskName');
		local QualityPic = ComCtrl:GO('QualityPic');
		local Exp = ComCtrl:GO('Exp');
		local Content = ComCtrl:GO('Content.Text');
		local Btn = ComCtrl:GO('Btn');
		Btn:BindButtonClick(UIRewardTask.OnTaskBtnClick)
		Btn:SetUserData("index", index);
		UIRewardTask.UpdateBtn(Btn,task.state);
		local table = tb.TaskTable[task.sid];
		local Quality = task.quality + 1;
		QualityPic.sprite = QualityColorCfg[Quality][2];
		TaskName.text = string.format("<color=#%s>%s</color>",QualityColorCfg[Quality][1],table.name);
		
		local exp = math.floor(tb.RewardTaskExp[DataCache.myInfo.level].exp * tb.RewardTaskExpMul[task.quality].exp_mul / 1000)
		Exp.text = string.format("经验：%d",exp);
		Content.text = table.task_text1;
	end


	function DoRefreshEffect(index)
		iTween.RotateAdd(CtrlList[index].gameObject,Vector3.New(0,360,0),0.4)
		CtrlList[index]:PlayUIEffect(this.gameObject, "xuanshangguang",3,function () end,true,false,UIWrapper.UIEffectAddType.Replace)
		this:Delay(0.2,DelayEffectFun[2][index]);			
	end

	

	function Refresh_Ex()
		UIRewardTask.UpdateTaskInfo(client.RewardTask.TaskList);
	end
	function UIRewardTask.RefreshCallBack(list)
		local canfreshcount = 0
		for i = 1,#CtrlList do
			if client.RewardTask.TaskList[i].state < client.RewardTask.StateEnum.HaveCompleted then
				canfreshcount = canfreshcount + 1
				this:Delay((canfreshcount-1)*0.16,DelayEffectFun[1][i]);			
			end
		end
		UIRewardTask.UpdateOtherInfo()
	end

	-------------------------------------刷新效果表现-----------------------




	-------------------------------------界面一直打开着到了5点要请求一次刷新，客户端驱动-----------------------
	function UIRewardTask.CheckUpdateTime()
		local timeNow = math.floor(TimerManager.GetServerNowMillSecond()/1000);
		local timetab = os.date("*t",timeNow)
		if timetab.hour < 5 then
			local delayseconds = 5 * 3600 - timetab.hour * 3600 - timetab.min * 60 - timetab.sec;
			DelayRefreshID = this:Delay(delayseconds,
				function()client.RewardTask.GetRewardTasks(client.RewardTask.OnEqueueEvent)end)
		end
	end

	function UIRewardTask.Close()
		if DelayRefreshID ~= nil then
			this:CancelDelay(DelayRefreshID)
		end
		client.RewardTask.Clear();
		destroy(this.gameObject);
	end


	function UIRewardTask.UpdateBtn(go,state)
		local Cfg = BtnStateCfg[state];
		go.sprite = Cfg[1];
		go:GO('Text').text = Cfg[2];
		--追踪中 或 已完成
		if state == client.RewardTask.StateEnum.Tracing or state == client.RewardTask.StateEnum.HaveCompleted then
			go.buttonEnable = false;
			go.buttonImageEnable = false;
		else 
			go.buttonEnable = true;
			go.buttonImageEnable = true;
		end
	end

	function UIRewardTask.OnTaskBtnClick(go)
		local UIWrapper = go:GetComponent('UIWrapper')
		if UIWrapper.buttonEnable == false then
			return
		end
		local index = UIWrapper:GetUserData("index");
		client.RewardTask.OnTaskBtnClick(index);
		local task = client.RewardTask.TaskList[index]
		if task.state == client.RewardTask.StateEnum.Free then
			UIRewardTask.Close();
		end
		local wrapper = UIManager.GetInstance():FindUI("UIActivity");
        if wrapper then
            destroy(wrapper.gameObject);
            UIManager.GetInstance():CallLuaMethod('UIMenu.closeSelf');
        end
	end

	function UIRewardTask.UpdateTaskInfo(tasklist)
		for i = 1,#tasklist do			
			UpdatePeerInfo(i)
		end
		UIRewardTask.UpdateOtherInfo()
	end

	function UIRewardTask.UpdateOtherInfo()
		local str = ""; 
		--str = string.format("今日完成了 %d/%d\n每天凌晨5点刷新",
		--client.RewardTask.GetHaveCompletedNum(),client.RewardTask.DoNumOneDay);
		--Tip1.text = str;

		local RefreshPropCount = Bag.GetItemCountBysid(const.item.reward_task_refresh); --刷新令
		if RefreshPropCount > 0 then
			str = string.format("%d/%d",RefreshPropCount,1); --拥有/消耗
			ConsumeIcon.sprite = "tb_shuaxinling";
		else
			local color = "ffffffff";
			if DataCache.role_diamond < const.reward_task_refresh_diamond_cost then
				color = "F00F0FFF";
			end
			str = string.format("<color=#%s>%d</color>",color, const.reward_task_refresh_diamond_cost);
			ConsumeIcon.sprite = "tb_zuanshi";
		end
		ConsumeNum.text = str;
	end
	
	return UIRewardTask;
end


function ui.ShowRewardTask()
	--if client.RewardTask.TaskList == nil then
		client.RewardTask.GetRewardTasks(function (taskList) 
			PanelManager:CreatePanel('UIRewardTask',UIExtendType.BLACKMASK, {taskList = taskList});
		end);
	--else
		--PanelManager:CreateConstPanel('UIRewardTask',UIExtendType.NONE, {taskList = client.RewardTask.TaskList});
	--end
end