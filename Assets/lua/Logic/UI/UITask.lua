function UITaskView (param)
	local UITask = {};
	local this = nil;

	local TaskZone = nil;
	local DefaultInfo = nil;
	local TaskName = nil;
	local TaskTarget = nil;
	local ExpText = nil;
	local MoneyText = nil;
	local BagItem = nil;
	local RewardGrid = nil;
	local RewardGirdPosition = nil;
	local AcceptBtn = nil;
	local TaskInfo = {};

	local ShowMainTask = nil;
	local ShowRewardTask = nil;	
	local ResizeRewardList = nil;
	local Index2ObjMap = {};	--index对应的gameObject
	local RewardNameMap = {};

	local rewardClick = nil;
	local FormatItem = nil;
	local itemAward = {};
	local equipAward = {};
	local ItemObj2Info = {};
	local EquipObj2Info = {};

	function UITask.Start ()
		this = UITask.this;

		local commonDlgGO = this:GO('CommonDlg2');
		UITask.controller = createCDC(commonDlgGO)
		UITask.controller.SetButtonNumber(3);
		UITask.controller.SetButtonText(1,"主线任务");
		UITask.controller.bindButtonClick(1,ShowMainTask);
		UITask.controller.SetButtonText(2,"支线任务");
		UITask.controller.bindButtonClick(2,ShowRewardTask,ui.unOpenFunc);
		UITask.controller.SetButtonText(3,"指引任务");
		UITask.controller.bindButtonClick(3,ShowRewardTask,ui.unOpenFunc);		
		UITask.controller.bindButtonClick(0,UITask.Close);
		-- UITask.controller.SetTitle("wz_renwu")

		TaskZone = this:GO('Panel.TaskZone');
		DefaultInfo = this:GO('Panel.DefaultInfo');
		TaskName = this:GO('Panel.TaskZone._TaskName');
		TaskTarget = this:GO('Panel.TaskZone._TaskTarget');
		
		ExpText = this:GO('Panel.TaskZone._ExpText'):GetComponent("LRichText");
		MoneyText = this:GO('Panel.TaskZone._MoneyText'):GetComponent("LRichText");
		BagItem = this:GO('Panel.TaskZone.RewardContainer.Grid._BagItem');
		RewardGrid = this:GO('Panel.TaskZone.RewardContainer.Grid._Content');
		RewardGirdPosition = RewardGrid:GetComponent("RectTransform").anchoredPosition;
		AcceptBtn = this:GO('Panel.TaskZone._AcceptBtn');

		AcceptBtn:BindButtonClick(UITask.AutoGo);

		UITask.controller.activeButton(param.task_module_type);
	end

	ShowRewardTask = function()
		ui.unOpenFunc();
	end



	ShowMainTask = function()
		--获取玩家当前主线任务的ID
		local taskList = client.task.getTaskList();
		if #taskList == 0 then
			DefaultInfo.gameObject:SetActive(true)
			TaskZone.gameObject:SetActive(false)
			return;
		else
			DefaultInfo.gameObject:SetActive(false)
			TaskZone.gameObject:SetActive(true)	
		end

		local mainTaskid = 0;
		for i=1,#taskList do
			local taskTableInfo = tb.TaskTable[taskList[i].sid];
			if taskTableInfo.task_module_type == commonEnum.taskModuleType.ZhuXian then
				mainTaskid = taskList[i].sid;
				break;
			end
		end
		if mainTaskid == 0 then
			DefaultInfo.gameObject:SetActive(true)
			TaskZone.gameObject:SetActive(false)
			return;
		end
		--获取相关的任务信息
		TaskInfo = tb.TaskTable[mainTaskid];
		if TaskInfo ~= nil then
			TaskName.text = TaskInfo.name;
			TaskTarget.text = TaskInfo.task_text1;
			ExpText.text = "经验："..TaskInfo.exp_award.." [#505:0]";
			MoneyText.text = "金钱："..TaskInfo.money_award.." [#506:0]";
			itemAward =  TaskInfo.items_award;
			if TaskInfo.specReward[DataCache.myInfo.career] ~= nil then
				equipAward = TaskInfo.specReward[DataCache.myInfo.career].award;
			end
			local rewardNumber = #itemAward+ #equipAward;
			ResizeRewardList(rewardNumber);
			ItemObj2Info = {};
			EquipObj2Info = {};
			for i=1,rewardNumber do
				FormatItem(Index2ObjMap[i],i);
			end
		end
	end
	--根据奖励的个数生成相应的奖励格子
    ResizeRewardList = function(count)
        local curCount = RewardGrid.transform.childCount;
        local grid = RewardGrid;
        -- 根据条目数决定content的长度
        local rtTrans = grid:GetComponent("RectTransform");
        local width = count * 94 + 3;
        local size = rtTrans.sizeDelta;
        if count > 1 then
            width = width + (count-1) * 10;
        end
        size.x = width;
        rtTrans.sizeDelta = size;
        rtTrans.anchoredPosition = RewardGirdPosition;
        --如果要缩小格子的数量
        if count <= curCount then
            for i = 1,curCount do
                grid.transform:GetChild(i-1).gameObject:SetActive(i <= count);
            end
        else
            for i = 1, curCount do
                grid.transform:GetChild(i-1).gameObject:SetActive(true);
            end
            for i = curCount+1,count do
                local go = newObject(BagItem.gameObject);
                go:SetActive(true);
                go.name = 'Item'..tostring(i);
                go.transform:SetParent(grid.transform);
                go.transform.localScale = Vector3.one;
                go.transform.localPosition = Vector3.zero;
                RewardNameMap[go.name] = i;
                Index2ObjMap[i] = go;
                local wrapper = go:GetComponent("UIWrapper");  
                wrapper:BindButtonClick(rewardClick);
				local slotCtrl = CreateSlot(go);
				wrapper:SetUserData("ctrl",slotCtrl);
            end
        end        
    end

    rewardClick = function(taskObj)  
		local click_pos = taskObj:GetComponent("UIWrapper").pointer_position

        if ItemObj2Info[taskObj.name] ~= nil then
        	local item = ItemObj2Info[taskObj.name];
            if item.type == "gem" then
                ui.ShowGemFloat(item, true, item.count)
            else
                local param = {pos = click_pos, bDisplay = true, base = item, sid = item.sid, index = item.i};
                PanelManager:CreateConstPanel('ItemFloat',UIExtendType.BLACKCANCELMASK,param);
            end
		elseif EquipObj2Info[taskObj.name] ~= nil then
			local equip = EquipObj2Info[taskObj.name];
			local param = {pos = click_pos, showType = "show",base = equip,enhance = nil};
			PanelManager:CreateConstPanel('EquipFloat',UIExtendType.BLACKCANCELMASK,param);
		end
    end

	FormatItem = function(go, index)
		local wrapper = go:GetComponent("UIWrapper");
		local slotCtrl = wrapper:GetUserData("ctrl");
		--这里生成物品
		if index <= #itemAward then
			slotCtrl.setItemFromSid(TaskInfo.items_award[index][2][1]);
			slotCtrl.setAttr(TaskInfo.items_award[index][2][2]);
			local item = UITask.createTemItem(TaskInfo.items_award[index][2][1],TaskInfo.items_award[index][2][2],index);
			ItemObj2Info[go.name] = item;
		--这里生成装备
		else
			local rewardId = TaskInfo.specReward[DataCache.myInfo.career].award[index-#itemAward][2];
			local equipInfo = tb.EquipRewardTable[rewardId];
			local equip = client.equip.createTempEquip(equipInfo.itemSid,equipInfo.addAttr,equipInfo.quality);
			slotCtrl.setEquip(equip);
			EquipObj2Info[go.name] = equip;
		end
	end

	UITask.createTemItem = function(sid,count,i)	
		local item = {};
        item.type = "item"
        if tb.GemTable[sid] then
            item.type = "gem"
        end
		item.sid = sid;
		item.count = count;
		item.i = i;
		return item;
	end

	UITask.AutoGo = function()
		client.task.TaskAutoGo(TaskInfo.sid);
		UITask.Close();
		UIManager.GetInstance():CallLuaMethod('UIMenu.closeSelf');
	end

	UITask.Close = function()
		destroy(this.gameObject);
	end

	return UITask;
end
