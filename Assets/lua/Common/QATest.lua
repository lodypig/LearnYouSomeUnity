
function createQA()
    local QA = {}


    function QA.collectEquip(level)
        local list = {}
        for k,v in pairs(tb.EquipTable) do
            if v.level == level and v.career == DataCache.myInfo.career then
                list[#list+1] = k
            end
        end
        return list
    end

    --穿戴level级品质为quality的全身装备
    function QA.equipAll(level,quality)
        local list = QA.collectEquip(level)
        local msg = {};
        msg.cmd = "gm_add_equip"
        msg.level = quality
        msg.prosperity = 0;
        msg.count = 1

        for i = 1,#list do
            msg.equip_id = list[i]
             Send(msg, function(msg) end);
        end
    end

    --强化全身装备到level级
    function QA.enhanceAll(level)
        for i = 1,10 do
            for j = 1,level do
                client.enhance.enhance(function() end,i,true)
            end
        end
        Bag.InitWearList()
    end

    --全部脱下
    function QA.takeOffAll()
        local msg = {cmd = "take_off",}
        for i = 1,10 do
            msg.equipment_index = i
            Send(msg);
        end
    end


    function QA.collectGem(buwei,level)
        local need_type = tb.EquipGemTable[buwei];
        local minId = nil
        for k,v in pairs(tb.GemTable) do
            if need_type == v.gem_type then
                if minId == nil or k <= minId then
                    minId = k
                end
            end
        end
        return minId + (level - 1)
    end
    --添加全套宝石
    function QA.addGemAll(level,count)
        local msg = {};
        msg.cmd = "gm_add_item"
        msg.count = count

        for i = 1,10 do
            msg.item_id = QA.collectGem(i,level)
            Send(msg)
        end
    end

    --镶嵌
    function QA.putOnGemAll(level)
        local itemList = Bag.GetShow(const.bagType.gem);
        for i = 1,10 do
            local list = Bag.GetShowGem(i)
            local gem = nil
            for k = 1,#list do
                if list[k].sid == QA.collectGem(i,level) then
                    gem = list[k]
                    break
                end
            end
            if gem ~= nil then
                for j = 1,4 do
                    client.gem.putOn(function() end,i,gem,j)
                end
            end
        end
    end
    --拆下
    function QA.takeOffGemAll()
        for i = 1,10 do
            local gemlist = client.gem.getEquipGem(i)
            for j = 1,#gemlist do
                client.gem.removeEquipGem(function() end,i,gemlist[j])
            end
        end
    end
    --坐骑培养
    function QA.horseTrain(index,level)
        local horse = client.horse.horseList[index]
        if horse then
             QA.horseTraintimer = Timer.New(
                function()
                    if horse.enhance_lv < level then
                        if client.horse.isMaxStar(horse.sid) == false then
                            client.horse.train(function() end, horse.sid, 0)
                        else
                            client.horse.enhance(function() end, horse.sid, 0)
                        end
                    else
                        QA.horseTraintimer:Stop()
                    end
                end, 0.01,-1,false)
            QA.horseTraintimer:Start()
        end
    end

    function QA.testDrop(killerId)
        local msg = {cmd = "drop_treasure",killerId = killerId};
        Send(msg);
    end

    function QA.addTask(taskSid)
        local msg = {cmd = "gm_add_task",sid = taskSid};
        Send(msg);
    end

    function QA.finishTask(taskSid)
        if taskSid == nil then
            taskSid = client.task.mainTaskSid;
        end
        local msg = {cmd = "gm_complete_task",sid = taskSid};
        Send(msg);
    end

    function QA.deleteTask(taskSid)
        local msg = {cmd = "gm_delete_task",sid = taskSid};
        Send(msg);
    end

    --直接切换主线任务，过程简单，只适用于主线
    function QA.changeMainTask(taskSid)
        local curSid = client.task.mainTaskSid
        local taskInfo = tb.TaskTable[taskSid];
        if taskInfo.task_module_type ~= 1 or taskInfo.chapter == 0 then
            print("输入的不是主线任务sid")
        end
        QA.deleteTask(curSid);
        MainUI.this:Delay(0.5, function()
            QA.addTask(taskSid);
        end)
    end
    --完成指定主线之前的所有任务，只适用于主线
    function QA.skip2Task(taskSid)
        local curSid = client.task.mainTaskSid
        local taskInfo = tb.TaskTable[taskSid];
        if taskInfo.task_module_type ~= 1 or taskInfo.chapter == 0 then
            print("输入的不是主线任务sid")
        end
        local number = taskSid - curSid;
        for i=0,number-1 do
            MainUI.this:Delay(0.5 * i, function()
                QA.finishTask(curSid+i);
            end)
        end
    end

    function QA.test()
    end

    return QA
end

client.qa = createQA()