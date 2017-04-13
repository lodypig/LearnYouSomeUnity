function MainUITaskView()
    local MainUITask = {};
    local this = nil;

    --任务面板
    local RightTaskPanel = nil;
    local panelPos = nil;
    local taskPanelState = 0;
    local taskPanelShow = 1;
    local taskHideBtn = nil;
    local taskHideBtnPos = nil;

    local taskItem = nil;
    local taskGrid = nil;
    local tasklGirdPosition = nil;
    local taskPanel = nil;
    local fubenTaskItem = nil;
    local fubenTaskPanel = nil;
    local taskNameMap = {};
    local itemlen = nil;

    local taskProgress = nil;
    local fubenTask = nil;
    local ProtectTaskText = nil;
    local taskEffectObj = nil;
        --成长目标
    local chengZhangmubiao = nil;
    local nowIndex = -1; --表示没有成长目标

	function  MainUITask.Start()      
		this = MainUITask.this;

        --任务区域  
        RightTaskPanel = this:GO('RightTask');
        panelPos = RightTaskPanel:GO('taskPanel').transform.localPosition;
        taskHideBtn = this:GO('taskHideBtn');
        taskHideBtn:BindButtonClick(MainUI.HideTaskPanel);
        taskItem = this:GO('RightTask.taskPanel.taskList.Grid.taskItem');
        taskItem.gameObject:SetActive(false);
        taskGrid = this:GO('RightTask.taskPanel.taskList.Grid._Content');
        tasklGirdPosition = taskGrid:GetComponent("RectTransform").localPosition;
        MainUI.__taskGrid = taskGrid;
        taskPanel = this:GO('RightTask.taskPanel');
        taskEffectObj = this:GO('taskEffectObj');
        taskProgress = this:GO('RightTask.taskPanel.taskProgress')
        --成长目标
        chengZhangmubiao = this:GO('RightTask.ChengZhangMuBiao');

        taskProgress:BindButtonClick(function()
            local SceneInfo = tb.SceneTable[DataCache.scene_sid];
            if SceneInfo.sceneType == "fuben_map" then
                ui.showMsg("在副本中无法打开圣灵界面");
                return;
            end
            local chapter = client.holyProtect.GetHolyChapter();
            PanelManager:CreatePanel('UIHolyItem', UIExtendType.NONE, chapter);
            end);

        EventManager.bind(this.gameObject,Event.ON_TIME_SECOND_CHANGE,MainUI.UpdateProtectText);     
        EventManager.bind(this.gameObject,Event.ON_MAINUI_HIDE, MainUITask.Hide);
        EventManager.bind(this.gameObject,Event.ON_MAINUI_SHOW, MainUITask.Show);
	end

    function MainUITask.FirstUpdate()
        taskHideBtnPos = taskHideBtn:GetComponent("RectTransform").position;
        MainUI.FormatTaskList();
    end

    function MainUITask.OnDestroy(  )
        
    end

    function MainUITask.Hide()
        taskPanel.transform:DOLocalMoveX(panelPos.x - 600, 0.5, false);
    end
    -- 点击按钮飘出
    function MainUITask.MoveOut()
        taskPanel.transform:DOLocalMoveX(panelPos.x - 300, 0.3, false):SetEase(DG.Tweening.Ease.InBack);
    end 

    function MainUITask.Show()
        if const.leftPanelShrink then
            taskPanel.transform:DOLocalMoveX(panelPos.x, 0.3, false);
        end
    end

    function MainUITask.MoveIn()
        taskPanel.transform:DOLocalMoveX(panelPos.x, 0.3, false);
    end

    function MainUITask.SetActive(isShow)
        RightTaskPanel.gameObject:SetActive(isShow);
    end

    --获取等级对应的成长目标index
    function MainUI.getCZMUIndex(playerLevel)
        local temIndex = 0;
        local temInfo;
        while tb.CZMBTable[temIndex] do
            temInfo = tb.CZMBTable[temIndex];
            if temInfo.minLevel <= playerLevel and temInfo.maxLevel >= playerLevel then
                return temIndex;
            end
            temIndex = temIndex+1;
        end
        return -1;
    end
    
     -- 初始化成长目标
    function MainUI.InitCZMU()
        nowIndex = MainUI.getCZMUIndex(DataCache.myInfo.level);
        if nowIndex >= 0 then
            local temInfo = tb.CZMBTable[nowIndex];
            chengZhangmubiao:GO('Text').text = temInfo.describe;
            chengZhangmubiao.gameObject:SetActive(true);
        end
    end

    function MainUI.handleCZMULevelUp()
        if nowIndex < 0 then 
            return;
        end
        local temIndex = MainUI.getCZMUIndex(DataCache.myInfo.level);
        if nowIndex == temIndex then
            return;
        end
        nowIndex = temIndex;
        if temIndex < 0 then
            chengZhangmubiao.gameObject:SetActive(false);
            return;
        end
        local temInfo = tb.CZMBTable[temIndex];
    
        --成长目标发生变化 
        local oldPositionX = chengZhangmubiao.transform.localPosition.x;
        chengZhangmubiao.transform:DOLocalMoveX(oldPositionX+300, 0.5, false):OnComplete(function() 
            chengZhangmubiao:GO('Text').text = temInfo.describe;
            chengZhangmubiao.transform:DOLocalMoveX(oldPositionX, 0.5, false);
        end);
    end


    --任务面板相关
    local markClick = function(go)
        local wrapper = go:GetComponent("UIWrapper");  
        local index = wrapper:GetUserData("Index");
        local taskList = client.task.getTaskList();
        local taskInfo = taskList[index];
        local tasktable = tb.TaskTable[taskInfo.sid];
        if taskInfo == nil then
            return;
        end

        --如果是藏宝图任务，点击打开藏宝图界面
        if tasktable.task_type == 14 then
            PanelManager:CreatePanel('UICangBaoTu' , UIExtendType.BLACKMASK, {});
            return
        end
        
        if tasktable.task_module_type == commonEnum.taskModuleType.XuanShang then
            ui.ShowRewardTask()
        elseif tasktable.task_module_type == commonEnum.taskModuleType.QuYu then
            ui.ShowMolongTask()
        else
            MainUI.ShowTaskPanel(tasktable.task_module_type)
        end
    end

    function MainUI.RefreshTaskListLater(time)
        MainUI.FormatTaskList();
        MainUI.SwitchToTraceTask();
        -- if MainUI.isShow == true then
        --     MainUI.FormatTaskList();
        --     MainUI.SwitchToTraceTask();           
        -- else
        --     this:Delay(time, function()
        --                 MainUI.FormatTaskList();
        --                 MainUI.SwitchToTraceTask();
        --             end);
        -- end
    end

    function MainUI.SwitchToTraceTask()
        local taskList = client.task.getTaskList();
        local index = -1;
        for i=1,#taskList do
            if taskList[i].sid == client.task.CurTraceTaskSid then
                index = i;
                break;
            end
        end

        if index ~= -1 then
            local taskInfo = taskList[index];

            --点击了第index项，将该项移动到第一条位置
            --tasklGirdPosition = taskGrid:GetComponent("RectTransform").localPosition;
            --transform:DOLocalMoveX(300, 0.3, false)
            local rect = taskGrid:GetComponent("RectTransform")     
            local NewPosition = Vector3.New(tasklGirdPosition.x , tasklGirdPosition.y + (66 * (index - 1)), tasklGirdPosition.z);
            --如果是最后一项，位置有所区别
            if #taskList>1 and index == #taskList then
                NewPosition = Vector3.New(tasklGirdPosition.x , tasklGirdPosition.y + (-79 + 96 *(index - 1)), tasklGirdPosition.z);
            end
            taskGrid.transform:DOLocalMove(NewPosition, 0.2, false)
            -- iTween.MoveTo(taskGrid.gameObject, NewPosition, 0.2);       
        end     
    end   

    --追踪区任务点击后的处理
    local taskClick = function(taskObj)
        local index = taskNameMap[taskObj.name];
        local taskList = client.task.getTaskList();
        local taskInfo = taskList[index];

        -- 点击了第index项，将该项移动到第一条位置
        -- local rect = taskGrid:GetComponent("RectTransform")     
        -- local NewPosition = Vector3.New(tasklGirdPosition.x , tasklGirdPosition.y + (96 * (index - 1)) * scale.y, tasklGirdPosition.z);
        -- --如果是最后一项，位置有所区别
        -- if #taskList>1 and index == #taskList then
        --     NewPosition = Vector3.New(tasklGirdPosition.x , tasklGirdPosition.y + (-79 + 96 *(index - 1)) * scale.y, tasklGirdPosition.z);
        -- end
        -- iTween.MoveTo(taskGrid.gameObject, NewPosition, 0.2);



        local tasktable = tb.TaskTable[taskInfo.sid];
        if taskInfo == nil then
          	--print("任务id未找到")
            return;
        end
        if (SceneManager.IsXiangWeiMap(DataCache.scene_sid) and DataCache.scene_sid ~= tasktable.xiangwei_sceneid) then
           XiangWeiFuben.confirmExit() 
           return
        end

        if tasktable.task_tips ~= nil then
            ui.showMsg(tasktable.task_tips)  
            return;
        end
        if client.task.isTaskComplete(taskInfo.sid) then
            if client.task.taskClickEvent[tasktable.task_module_type] ~= nil then                
                client.task.taskClickEvent[tasktable.task_module_type](taskInfo)
            else
                if tasktable.task_module_type ~= commonEnum.taskModuleType.QuYu and client.MolongTask.BIsStart == true then
                    local tip = "当前正处于护送任务过程中，离开魔龙岛会导致任务失败，是否继续？"
                    ui.showMsgBox(nil, tip, function()
                        client.task.TaskAutoGo(taskInfo.sid);
                    end) 
                else
                    client.task.TaskAutoGo(taskInfo.sid);
                end            
            end
        else
            if tasktable.task_module_type ~= commonEnum.taskModuleType.QuYu and client.MolongTask.BIsStart == true then
                local tip = "当前正处于护送任务过程中，离开魔龙岛会导致任务失败，是否继续？"
                ui.showMsgBox(nil, tip, function()
                    client.task.TaskAutoGo(taskInfo.sid);
                end) 
            else
                client.task.TaskAutoGo(taskInfo.sid);
            end
        end
    end


    --根据任务的个数生成相应的空任务条目
    local ResizeTaskList = function(count)
        local curCount = taskGrid.transform.childCount;
        local grid = taskGrid;
        -- 根据条目数决定content的长度
        --local rtTrans = grid:GetComponent("RectTransform");
        -- local height = count * 91.6 + 3;
        -- local size = rtTrans.sizeDelta;
        -- if count > 0 then
        --     height = height + (count-1) * 13;
        -- end
        -- size.y = height;
        -- rtTrans.sizeDelta = size;
        --rtTrans.anchoredPosition = tasklGirdPosition;
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
                local go = newObject(taskItem.gameObject);
                go:SetActive(true);
                go.name = 'Task'..tostring(i);
                go.transform:SetParent(grid.transform);
                go.transform.localScale = Vector3.one;
                go.transform.localPosition = Vector3.zero;
                taskNameMap[go.name] = i;
                local wrapper = go:GetComponent("UIWrapper");  
                wrapper:BindButtonClick(taskClick);
                
                local mark = wrapper:GO('Panel.mark');
                mark:BindButtonClick(markClick);
                mark:SetUserData("Index",i);
            end
        end      
    end

    local FormatTaskTitle = function(taskInfo, taskTableInfo)
        local taskType = taskTableInfo.task_type;
        local rawStr;
        local name;
        if taskType == 14 then --藏宝图
            rawStr = "[宝藏]";
            name = client.tools.ensureString(taskInfo.otherInfo[1]);
        else
            if taskTableInfo.task_module_type ~= 1 then
                rawStr = "["..commonEnum.taskModuleTypeName[taskTableInfo.task_module_type].."]";
            else
                rawStr = "";
            end
            name = taskTableInfo.name;
        end
        local str = string.format("<color=%s>%s</color>",commonEnum.taskColor[taskInfo.quality+1],rawStr);
        return str.." "..name;
    end

    local FormatTaskContent = function(taskInfo,taskTableInfo)
        --if taskInfo.success_data[1] 
        --这里需要区分任务的类型，拼接出相应的任务内容
        --获取任务类型
        local taskType = taskTableInfo.task_type;
        local completeType = TaskCompleteType[taskType];
        if completeType == nil then
        --  	--print("completeType == nil")
            return; --没有获取到完成类型，需要在TaskCompleteType添加对应的完成类型
        end
        local str = "";
        -- 获取到的是任务的进度数量，拼接一个任务描述，并判断任务是否已经完成
        if completeType == 1 then
            --这个有时候是个空列表,要给个0值
            if taskInfo.success_data[1] == nil then
                taskInfo.success_data[1] = 0;
            end
            local teskDes = "";
            if taskTableInfo.task_des ~= "" then
                teskDes = taskTableInfo.task_des;
            else
                if taskType == 1 or taskType == 3 then --击杀npc
                    local monsterId = taskTableInfo.successCondition[1].v1;
                    local monsterInfo = tb.NPCTable[monsterId];
                    teskDes = string.format("击杀%s",monsterInfo.name);
                elseif taskType == 2 or taskType == 4 then --击杀npc收集物品
                    local itemInfo = tb.ItemTable[taskTableInfo.successCondition[1].v3];
                    teskDes = string.format("收集%s",itemInfo.name);
                elseif taskType == 6 then --采集物品
                    local npcInfo = tb.NPCTable[taskTableInfo.successCondition[1].v1];
                    local itemInfo = tb.ItemTable[taskTableInfo.successCondition[1].v3];
                    teskDes = string.format("在%s处采集%s",npcInfo.name,itemInfo.name);
                elseif taskType == 7 then --采集无物品
                    local npcInfo = tb.NPCTable[taskTableInfo.successCondition[1].v1];
                    local times = taskTableInfo.successCondition[1].v2;
                    teskDes = string.format("在%s处采集%s次",npcInfo.name,times);
                else
                    teskDes = taskTableInfo.task_des;
                end
            end
            local curNumber = 0;
            local totalNumber = 0;
            for  i=1,#taskTableInfo.successCondition do
                curNumber = curNumber + taskInfo.success_data[i];
                totalNumber = totalNumber + taskTableInfo.successCondition[i].v2;
            end
            str = string.format("%s<color=#f1f1f1>(%s/%s)</color>",teskDes,curNumber,totalNumber);
        elseif completeType == 2 then
            if taskTableInfo.task_des ~= "" then
                str = taskTableInfo.task_des;
            else
                if taskType == 5 then --对话npc
                    str = taskTableInfo.task_des;
                elseif taskType == 8 then --探索区域
                    local mapName = tb.SceneTable[taskTableInfo.successCondition[1].v1].name;
                    local location = taskTableInfo.successCondition[1].v2;
                    str = string.format("去%s(%s,%s)处探索",mapName,location[1]*2,location[2]*2);
                elseif taskType == 12 then --升级
                    local level = taskTableInfo.successCondition[1].v2;
                    str = string.format("升到%s级",level);
                elseif taskType == 13 then --
                    str = string.format("%s<color=#f1f1f1>(%s/%s)</color>",taskTableInfo.task_des,client.MolongTask.ReachNumber,client.MolongTask.TotalNumber)
                    --taskTableInfo.task_des;
                elseif taskType == 14 then --藏宝任务
                    str = string.format("前往%s寻找宝藏",client.tools.ensureString(taskInfo.otherInfo[1]));
                else
                    str = taskTableInfo.task_des;
                end
            end
        end
        return str;
    end

    local GetOverallAmount = function(taskTableInfo)
        if TaskCompleteType[taskTableInfo.task_type] == 1 then
            return taskTableInfo.successCondition[1].v2;
        else
            return 1;
        end
    end

    local GetText = function(str)
        local text1 = (string.gsub(str, "<color.->", ","));
        local text2 = (string.gsub(text1, "</color.->", ","));
        local temp = Split(text2, ",");
        str = "";
        for i = 1, #temp do
            str = str..temp[i];
        end
        return str;
    end

    local IsHaveCharacter = function(str)
        for i = 1, string.len(str) do
            if string.byte(str, i) <= 127 then
                return true;
            end
        end
        return false;
    end

    local FormatTaskFanelContent = function(taskInfo,taskTableInfo,taskContent)
        local str = nil;
        if taskInfo.sid == client.MolongTask.ProtectTaskSid then      
            str = client.MolongTask.GetProtectStr();
        else
            str = FormatTaskContent(taskInfo,taskTableInfo);
        end
        -- local pos = string.find(str, "%(",1);        
        -- local length = string.len(str)
        -- if length <= 36 then
        --     taskContent:GetComponent("Text").alignment = UnityEngine.TextAnchor.UpperRight;
        -- else
        --     taskContent:GetComponent("Text").alignment = UnityEngine.TextAnchor.UpperLeft;
        -- end
        -- if pos ~= nil and pos >= 27 and pos <= 36 then 
        --   	--print("pos:"..pos)
        --     str = string.sub(str,1,pos-1).."\n"..string.sub(str,pos);
        -- end
        -- if client.task.isTaskComplete(taskInfo.sid) then
        --     str = string.format("<color=%s>%s</color>",const.taskCompleteColor,str);           
        -- end
        taskContent.text = str;
        str = GetText(str);
        local length = string.len(str);
        local isHaveCharFlag = IsHaveCharacter(str);
        --去掉富文本得到纯文字
        return length, isHaveCharFlag;
    end

    local FormatTaskItem = function(index,taskInfo)
        local Taskid = taskInfo.sid;
        local taskTableInfo = tb.TaskTable[Taskid];
        local taskObj = taskGrid.transform:GetChild(index-1).gameObject;
        local wrapper = taskObj:GetComponent("UIWrapper");  
        local panel = wrapper:GO("Panel");
        local taskTitle = panel:GO("title");
        local taskText = panel:GO("title.text");
        local taskContent = panel:GO("content");
        local progressBack = panel:GO("progressBack");
        local progressBar = panel:GO("progressBar");
        local effectObj = wrapper:GO("effectObj");
        local effectDone = wrapper:GO("effectDone");
        local completeObj = wrapper:GO("completeObj");
        local len = 0;
        local isHaveChar = false;
        taskText.transform.localPosition = Vector3.New(116.3, 0.5, 0);
        if taskInfo.sid == client.MolongTask.ProtectTaskSid then      
            ProtectTaskText = taskContent;
        end
        if taskTableInfo.task_module_type == 1 and taskTableInfo.task_type ~= 14 then
            taskTitle.sprite = "tb_zhuxian_di";
            taskTitle.imageColor = Color.New(1,1,1,1);
        else
            taskTitle.imageColor = Color.New(1,1,1,0);
            taskText.transform.localPosition = Vector3.New(85.3, 0.5, 0);
        end
        taskText.text = FormatTaskTitle(taskInfo, taskTableInfo);
        wrapper:BindButtonClick(taskClick);
        --新的版本中不显示进度条，进度条代码先保留
        --如果配置了显示进度条，则根据任务的进度初始化进度条
        -- if taskTableInfo.show_progress == 1 then
        --     --progressBack.gameObject:SetActive(true);
        --     --progressBar.gameObject:SetActive(true);

        --     local taskType = taskTableInfo.task_type;
        --     local completeType = TaskCompleteType[taskType];
        --     local percent = 0;
        --     if completeType == 1 then
        --         local overall = GetOverallAmount(taskTableInfo);
        --         local nowNumber = 0;
        --         if taskInfo.success_data[1] ~= nil then
        --             nowNumber = taskInfo.success_data[1];
        --         end
        --         percent = nowNumber/overall;
        --         progressBar.fillAmount = percent;
        --     elseif taskType == 13 then
        --         if Taskid == client.MolongTask.ProtectTaskSid then

        --             local overall = client.MolongTask.TotalNumber;
        --             percent = client.MolongTask.ReachNumber/overall;
        --             progressBar.fillAmount = percent;
        --         end
        --     end

        --     if client.task.TaskUpdatetable[Taskid] ~= nil and client.task.TaskUpdatetable[Taskid] == true then
        --         --进度为0时不播放这个光效
        --         if taskInfo.success_data[1] ~= 0 then
        --             progressBack:PlayUIEffect(this.gameObject, "jingyantiao1", 2 ,function(effect)
        --                 local rect = effect:GetComponent("RectTransform");
        --                 rect.localPosition = Vector3.New(-8,0,0);              
        --             end, true);
        --             progressBar:PlayUIEffect(this.gameObject, "jingyantiao2", 2 ,function(effect)
        --                 local rect = effect:GetComponent("RectTransform");
        --                 local rectBar =  progressBar:GetComponent("RectTransform");
        --                 rect.localPosition = Vector3.New(-rectBar.sizeDelta.x/2+ rectBar.sizeDelta.x*percent,0,0);              
        --             end, true);
        --         end
        --         client.task.TaskUpdatetable[Taskid] = false;
        --     end
        -- else
        --     progressBack.gameObject:SetActive(false);
        --     progressBar.gameObject:SetActive(false);           
        -- end
        -- completeObj:PlayUIEffectForever(this.gameObject, "dianjilingjiang");
        completeObj:StopAllUIEffects();

        local completeFunc = function(callback)
            -- effectObj:StopAllUIEffects();
            local msg = {cmd = "complete_task", sid = taskInfo.sid};
            Send(msg, function(reMsg)
                if callback ~= nil then
                    callback();
                end
            end);
            wrapper:BindButtonClick(taskClick);
        end;
        local btnCompleteFunc = function (go)
                completeFunc(nil);
            end;
        --完成的优先级比接受更高
        --如果这个任务已经完成，并进行过对话，播放任务完成光效

        if client.task.isTaskComplete(taskInfo.sid) then
            --主线任务现在都走自动提交流程，这里可以过滤掉
            if taskTableInfo.task_module_type ~= commonEnum.taskModuleType.ZhuXian then
                --如果是悬赏任务条件完成，播放一个点击领奖的光效，点击事件变为打开界面
                if taskTableInfo.task_module_type == commonEnum.taskModuleType.XuanShang then
                    -- FormatTaskFanelContent(taskInfo,taskTableInfo,taskContent);
                    taskContent.text = "";
                    -- completeObj:PlayUIEffectForever(this.gameObject, "dianjilingjiang");
                    completeObj:PlayUIEffect(this.gameObject, "dianjilingjiang",3,function () end,true,true,UIWrapper.UIEffectAddType.Replace);
                    wrapper:BindButtonClick(ui.ShowRewardTask)     
                --其他不需要到npc处提交的任务也是播放一个点击领奖的光效，点击事件是提交任务      
                elseif taskTableInfo.task_module_type == commonEnum.taskModuleType.QuYu then
                    taskContent.text = "";
                    client.task.TalkOverTable[taskInfo.sid] = nil;
                    wrapper:UnbindAllButtonClick();
                    completeFunc(function ()
                        local taskIndex = -1;
                        local taskList = client.MolongTask.TaskList;
                        for i = 1, #taskList do
                            local task = taskList[i];
                            if task.sid == taskTableInfo.sid then
                                taskIndex = i;
                                break;
                            end
                        end
                        if taskIndex ~= -1 then
                            local msg = {cmd = "finish_completed_molong_task", index = taskIndex};
                            Send(msg);
                        end                                  
                    end);
                else
                    --这里是容错，一般不会走到
                    completeFunc(nil);
                    wrapper:UnbindAllButtonClick();
                    len, isHaveChar = FormatTaskFanelContent(taskInfo,taskTableInfo,taskContent);
                    wrapper:BindButtonClick(taskClick); 
                end
            else
                len, isHaveChar = FormatTaskFanelContent(taskInfo,taskTableInfo,taskContent);
                wrapper:BindButtonClick(btnCompleteFunc);
            end
        --如果这个任务是新接任务，播放接受任务的光效，任务内容从右边划入
        elseif taskInfo.bIsNew ~= nil and taskInfo.bIsNew == true then
            taskContent.text = "";
            effectDone:PlayUIEffect(this.gameObject, "shuaxinrenwu", 1.5);
            len, isHaveChar = FormatTaskFanelContent(taskInfo,taskTableInfo,taskContent);
            local pos = panel.transform.localPosition;
            panel.transform.localPosition = Vector2.New(pos.x+300,pos.y);
            panel.transform:DOLocalMoveX(pos.x, 0.5, false);
            taskInfo.bIsNew = false;  
        --直接生成任务说明
        else
            wrapper:BindButtonClick(taskClick);
            len, isHaveChar = FormatTaskFanelContent(taskInfo,taskTableInfo,taskContent);
        end

        if client.task.CurTraceTaskSid == taskInfo.sid then
            effectObj:PlayUIEffect(this.gameObject, "zidongrenwu",3,function () end,true,true,UIWrapper.UIEffectAddType.Keep);
            effectObj:PlayUIEffect(this.gameObject, "zidongrenwu2",3,function () end,true,true,UIWrapper.UIEffectAddType.Keep);
        else
            effectObj:StopAllUIEffects();
        end
        wrapper:GO('effectObj').transform.localScale = Vector3.one;
        local position = wrapper:GO('effectObj').transform.localPosition;
        -- wrapper:GO('effectObj').transform:DOLocalMoveY(-94.5, 0, false);
        wrapper:GO('effectObj').transform.localPosition =Vector3.New(135, -96, 0);
        
        if isHaveChar then
            if len >= 33 and len < 65 then
                wrapper:GO('effectObj').transform.localScale = Vector3.New(1, 1.3, 1);
                wrapper:GO('effectObj').transform.localPosition = Vector3.New(135, -125, 0);
            end
            if len >= 65 then
                wrapper:GO('effectObj').transform.localScale = Vector3.New(1, 1.6, 1);
                wrapper:GO('effectObj').transform.localPosition = Vector3.New(135, -154, 0);
            end
        else
            if len >= 34 and len <= 66 then
                wrapper:GO('effectObj').transform.localScale = Vector3.New(1, 1.3, 1);
                wrapper:GO('effectObj').transform.localPosition = Vector3.New(135, -125, 0);
                -- wrapper:GO('effectObj').transform:DOLocalMoveY(position.y - 28, 0, false);
            end
            if len >= 67 then
                wrapper:GO('effectObj').transform.localScale = Vector3.New(1, 1.6, 1);
                wrapper:GO('effectObj').transform.localPosition = Vector3.New(135, -154, 0);
            end
        end
    end

    --初始化任务进度区域
    local FormatTaskProgress = function()
        if client.task.mainTaskSid == 0 then
            return;
        end
        client.holyProtect.GetHolyList();
        local taskTableInfo = tb.TaskTable[client.task.mainTaskSid];
        local ChapterIndex = taskTableInfo.chapter;
        local Progress = taskTableInfo.progress;
        local holyInfo = tb.holyTable[ChapterIndex];
        taskProgress:GO('jindu.jindu.value').fillAmount = taskTableInfo.progress/100;
        local progressText = "";
        if taskTableInfo.progress == 100 then
            progressText = "前往唤醒";
            taskProgress:GO('effectObj'):PlayUIEffectForever(this.gameObject,"shenglinshouhu");
        else
            progressText = taskTableInfo.progress.."%";
            taskProgress:GO('effectObj'):StopAllUIEffects();
        end
        taskProgress:GO('jindu.jindu.text').text = progressText;
        if holyInfo ~= nil then
            taskProgress:GO('jindu.text').text = holyInfo.name;
        end

    end 

    function MainUI.CompleteTaskEffect(taskSid)
        --读取任务相关奖励信息
        local taskTableInfo = tb.TaskTable[taskSid];
        if taskTableInfo.money_award == 0 and taskTableInfo.exp_award == 0 
            and #taskTableInfo.items_award == 0 then
        else
            taskEffectObj:PlayUIEffect(this.gameObject, "renwuwancheng1", 1.5);
            -- if taskTableInfo.money_award ~= 0 then
            --     ui.showMoneyMsg(taskTableInfo.money_award);
            -- end
        end
    end

    --根据人物的任务相关信息初始化任务列表
    function MainUI.FormatTaskList()
        local taskList = client.task.getTaskList();   
        ResizeTaskList(#taskList);
        ProtectTaskText = nil;
        for i = 1, #taskList do
            FormatTaskItem(i,taskList[i]);
        end
        FormatTaskProgress();
    end

    --更新任务进度
    function MainUI.UpdateTaskProgress(taskId,number)
        
    end

    --更新任务状态
    function MainUI.UpdateTaskState(taskId,state)
        
    end


    --显示任务
    function MainUI.ShowTaskPanel(type)
        PanelManager:CreatePanel('UITask',  UIExtendType.BLACKMASK, {task_module_type = type});
    end

    --收起或恢复任务面板
    function MainUI.HideTaskPanel()
        if taskPanelShow == 1 then
            RightTaskPanel.gameObject:SetActive(false);
            taskPanelShow = 0;
            local position = taskHideBtn:GetComponent("RectTransform").position;            
            taskHideBtn.transform.localEulerAngles = Vector3.New(0, 0 , 0);
            position.x = position.x + 300 * scale.x;
            iTween.MoveTo(taskHideBtn.gameObject, position, 0.1);
            
        else
            RightTaskPanel.gameObject:SetActive(true);
            taskPanelShow = 1;
            taskHideBtn.transform.localEulerAngles = Vector3.New(0, 0 , 180);
            iTween.MoveTo(taskHideBtn.gameObject, taskHideBtnPos,0.1);
            
        end
    end

    local oldSceneType = nil;
    function MainUI.UpdateProtectText()
        local SceneInfo = tb.SceneTable[DataCache.scene_sid];
        if oldSceneType ~= SceneInfo.sceneType then
            oldSceneType = SceneInfo.sceneType;
            if SceneInfo.sceneType == "fuben_map" then
                taskProgress:GO('jindu.jindu').gameObject:SetActive(false);
                taskProgress:GO('effectObj').gameObject:SetActive(false);
                taskProgress:GO('jindu.Tips').gameObject:SetActive(true);
            else
                taskProgress:GO('jindu.jindu').gameObject:SetActive(true);
                taskProgress:GO('effectObj').gameObject:SetActive(true);
                taskProgress:GO('jindu.Tips').gameObject:SetActive(false);           
            end
        end

        if ProtectTaskText ~= nil then
            if client.MolongTask.BIsStart == true then
                ProtectTaskText.text = client.MolongTask.GetProtectStr();
            end        
        end
    end

    return MainUITask;
end
