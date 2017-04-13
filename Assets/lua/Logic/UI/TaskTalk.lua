function TaskTalkView (param)
	local TaskTalk = {};
	local this = nil;
	local taskSid = -1;
	local LoadRealNpcModel = true;

	local leftImage = nil;
	local rightImage = nil;
	local leftRoleFigure = nil;
	local leftRoleFigureGO = nil;

	local panel = nil;
	local title = nil;
	local content = nil;

	local nextBtn = nil;
	local skipAll = nil;
	local nextPageObj = nil;
	local cellGroup = nil;

	-- local pastTime = 0;
	-- local autoCloseTime = 5;

	local TaskTalkInfo = nil;
	local TaskInfo = nil;
	local TaskTableInfo = nil;

	local CurPage = 0; 
	local TotalPageNumber = 0;

	local leftRoleFigurePos = nil;
	local panelPos = nil;
	local contentPos = nil;

	local itemAward = {};
	local equipAward = {};
	local ItemObj2Info = {};
	local EquipObj2Info = {};

	function TaskTalk.Start ()
		this = TaskTalk.this;
		taskSid = param.TaskId;
		leftImage = this:GO('LeftImage');
		rightImage = this:GO('RightImage');
		leftRoleFigureGO = this:GO('LeftRoleFigure');
		-- rightRoleFigure = this:GO('RightRoleFigure');

		panel = this:GO('Panel');
		title = panel:GO('Title');
		content = panel:GO('Content');

		nextBtn = this:GO('Panel.NextBtn');
		skipAll = this:GO('SkipAll');
		cellGroup = content:GO('CellGroup');
		nextPageObj = this:GO('Panel.NextPage');

		nextBtn:BindButtonClick(TaskTalk.NextPage);
		skipAll:BindButtonClick(TaskTalk.Skip);

		--这里开启毛玻璃效果先禁用
		--Util.SetGaussianBlur(true);

		-------PlayerRTT
		if ChatPlayerRTT == 0 then
			ChatPlayerRTT = CreateChatPlayerRTT()
		else
			ChatPlayerRTT.UpdateRtt()
		end
		------------------

		contentPos = content.transform.localPosition;
		leftRoleFigurePos = leftRoleFigureGO.transform.localPosition;
		panelPos = panel.transform.localPosition;

		panel.transform.localPosition = Vector3.New(panelPos.x,panelPos.y - 300,panelPos.z)
		panel.transform:DOLocalMoveY(panelPos.y, 0.5, false);

		leftRoleFigureGO.transform.localPosition = Vector3.New(leftRoleFigurePos.x - 500,leftRoleFigurePos.y,leftRoleFigurePos.z)
		leftRoleFigureGO.transform:DOLocalMoveX(leftRoleFigurePos.x, 0.5, false);

		TaskTalk.Init();
	end

	function TaskTalk.NextPage()
		if CurPage == TotalPageNumber then
			TaskTalk.Skip();
		else
			CurPage = CurPage + 1;
			TaskTalk.FormatPage();
		end
	end

	--跳过全部对话，直接发送对话完成消息，关闭对话窗口，
	function TaskTalk.Skip()
		TaskTalk.Close();
		--先检查是否为触发脚本走过来的
		if TaskTrigger.HaveEventNow(param.realId) then			
			TaskTrigger.DoNextEvent(param.realId);
		else
			TaskTalk.SendCompleteMsg();
		end
	end

	function TaskTalk.Init()
		if taskSid ~= nil then
			TaskInfo = client.task.getTaskBySid(taskSid);
		else --没有传进任务的sid
			TaskTalk.Close();
			return; 
		end
		
		TaskTableInfo = tb.TaskTable[taskSid];		
		TaskTalkInfo = tb.TaskTalkTable[taskSid];
		if TaskTalkInfo == nil then
			TaskTalkInfo = tb.TaskTalkTable[10000];
		end

		nextPageObj:PlayUIEffectForever(this.gameObject, "jixu");
		--记录下总页数，将当前所在页置为1
		TotalPageNumber = #TaskTalkInfo;
		CurPage = 1;
		TaskTalk.FormatPage(true);
	end

	-- function TaskTalk.SetShadow(active)
	-- 	if active == "right" then
	-- 		leftRoleFigure:SetShadow(true);
	-- 		rightRoleFigure:SetShadow(false);
	-- 	else
	-- 		leftRoleFigure:SetShadow(false);
	-- 		rightRoleFigure:SetShadow(true);			
	-- 	end
	-- end
	function TaskTalk.FormatTitleColor(name)
		return "<color=#decaa7>"..name.."</color>";
	end

	function TaskTalk.FormatPage(bIsFirst)
		if TaskTalkInfo == nil then
			return;
		end
		local PageInfo = TaskTalkInfo[CurPage];
		-- if PageInfo.active == "left" then
		-- 	actor = PageInfo.left; 
		-- else
		-- 	actor = PageInfo.right; 
		-- end

		if PageInfo.active == "self" then
			title.text = TaskTalk.FormatTitleColor(DataCache.myInfo.name);
			if ChatNPCRTT ~= 0 then
				ChatNPCRTT:SetRttVisible(false)
				ChatPlayerRTT:SetRttVisible(true)
			end
			RTTManager.SetRoleFigure(leftRoleFigureGO, ChatPlayerRTT, false, false)
		else
			local NpcInfo = tb.NPCTable[PageInfo.active];
			title.text = TaskTalk.FormatTitleColor(NpcInfo.name);
			--根据npc配置中的模型来读取
			if LoadRealNpcModel == true then
				-------NPCRTT
				if ChatNPCRTT == 0 then
					ChatNPCRTT = CreateChatNPCRTT(NpcInfo.style.."_Prefab")
				else
					ChatNPCRTT.UpdateRtt(NpcInfo.style.."_Prefab")
				end
			end
			if ChatPlayerRTT ~= 0 then
				ChatPlayerRTT:SetRttVisible(false)
				ChatNPCRTT:SetRttVisible(true)
			end
			RTTManager.SetRoleFigure(leftRoleFigureGO, ChatNPCRTT, false, false)
		end
		--这里用来给人物蒙灰，暂时禁用
		--TaskTalk.SetShadow(PageInfo.active);
		local finalContent = string.gsub(PageInfo.content, "Player", DataCache.myInfo.name)
		content.text = finalContent;
		--不是第一页时文本内容的淡入
		if bIsFirst == nil or bIsFirst == false then
			content.transform.localPosition = Vector3.New(contentPos.x,contentPos.y + 50,contentPos.z)
			content.transform:DOLocalMoveY(contentPos.y, 0.3, false);
			content:DOFade(0,1,0.3);
			-- local cavansGroup = content:GetComponent("CanvasGroup");
			-- cavansGroup.alpha = 0;
			-- cavansGroup:DOFade(1,0.3);
		end

		--从任务表读取奖励并加载
		if PageInfo.bShowReward ~= nil and PageInfo.bShowReward == true then
			if #TaskTableInfo.items_award ~= 0 or TaskTableInfo.specReward[DataCache.myInfo.career] ~= nil then
				TaskTalk.FormatReward(TaskTableInfo);
			end
		end
	end

	function TaskTalk.createTempItem(sid,count,i)	
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

	local FormatItem = function(wrapper, index)
		local slotCtrl = wrapper:GetUserData("ctrl");
		--这里生成物品
		if index <= #itemAward then
			slotCtrl.setItemFromSid(TaskTableInfo.items_award[index][2][1]);
			slotCtrl.setAttr(TaskTableInfo.items_award[index][2][2]);
			local item = TaskTalk.createTempItem(TaskTableInfo.items_award[index][2][1],TaskTableInfo.items_award[index][2][2],index);
			ItemObj2Info[wrapper.gameObject.name] = item;
		--这里生成装备
		else
			local rewardId = TaskTableInfo.specReward[DataCache.myInfo.career].award[index-#itemAward][2];
			local equipInfo = tb.EquipRewardTable[rewardId];
			local equip = client.equip.createTempEquip(equipInfo.itemSid,equipInfo.addAttr,equipInfo.quality);
			slotCtrl.setEquip(equip);
			EquipObj2Info[wrapper.gameObject.name] = equip;
		end
	end

	local rewardClick = function(taskObj)  
		local click_pos = taskObj:GetComponent("UIWrapper").pointer_position

        if ItemObj2Info[taskObj.name] ~= nil then
        	local item = ItemObj2Info[taskObj.name];
            if item.type == "gem" then
                ui.ShowFullGemFloat(item, true, item.count)
            else
                local param = {pos = click_pos, bDisplay = true, base = item, sid = item.sid, index = item.i};
                PanelManager:CreateFullScreenPanel('ItemFloat',UIExtendType.TRANSCANCELMASK,function() end,param);
            end
			-- PanelManager:CreateConstPanel('ItemFloat',UIExtendType.BLACKCANCELMASK,param);
		elseif EquipObj2Info[taskObj.name] ~= nil then
			local equip = EquipObj2Info[taskObj.name];
			local param = {pos = click_pos, showType = "show",base = equip,enhance = nil};
			PanelManager:CreateFullScreenPanel('EquipFloat',UIExtendType.TRANSCANCELMASK,function() end,param);
			-- PanelManager:CreateConstPanel('EquipFloat',UIExtendType.BLACKCANCELMASK,param);
		end
    end

	function TaskTalk.FormatReward(TaskTableInfo)
		cellGroup.gameObject:SetActive(true);
		itemAward =  TaskTableInfo.items_award;
		if TaskTableInfo.specReward[DataCache.myInfo.career] ~= nil then
			equipAward = TaskTableInfo.specReward[DataCache.myInfo.career].award;
		end
		local rewardNumber = #itemAward+ #equipAward;

		if rewardNumber < 4 then
			for i = rewardNumber+1,4 do
				local cell = cellGroup:GO("BagItem"..i);
				cell.gameObject:SetActive(false);
			end
		end

		for i = 1,rewardNumber do
			local cell = cellGroup:GO("BagItem"..i);
			local slotCtrl = CreateSlot(cell.gameObject);
			cell:SetUserData("ctrl",slotCtrl);
			cell:BindButtonClick(rewardClick);
			FormatItem(cell,i);
		end
	end

	function TaskTalk.SendCompleteMsg()
		--对话完成，发送对话完成消息到服务器
		local msg = {cmd = "client_event", type = "talk_npc", npc = TaskTableInfo.successCondition[1].v1, tasksid = taskSid};
		Send(msg, function (msgTable)
			client.task.TalkOverTable[taskSid] = true;
		end);
	end

	function TaskTalk.Close()
		-- Util.SetGaussianBlur(false);
		ChatPlayerRTT:SetRttVisible(false)
		if ChatNPCRTT ~= 0 then
			ChatNPCRTT:SetRttVisible(false)
			ChatNPCRTT:ClearModels(true)		--del material also
		end
		destroy(this.gameObject);
	end	

	return TaskTalk;
end
