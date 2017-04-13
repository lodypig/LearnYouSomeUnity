function MainUIGrowthView()
    local MainUIGrowth = {};
    local this = nil;

    local panelPos = nil;
    local panel = nil;

    local itemPrefab = nil;
    local itemGrid = nil;
    local itemList = {};

    local lastGrowth = nil;

    local detailPanel = nil;

	function  MainUIGrowth.Start()      
		this = MainUIGrowth.this;

        panel = this:GO('Panel');
        panel:Hide();

        detailPanel = this:GO("Panel.Detail");
        panelPos = panel.transform.localPosition;
        this:GO('Panel.Growth'):BindButtonClick(function ()
            if detailPanel.gameObject.activeSelf then
                detailPanel:Hide();
            else
                detailPanel:Show();
            end
        end)

        this:BindLostFocus(function ()
            detailPanel:Hide();
        end);
        detailPanel:Hide();
        itemPrefab = this:GO('Panel.Detail.Grid.Item');
        itemPrefab:Hide();
        itemGrid = this:GO('Panel.Detail.Grid');

        MainUI.initGrowth();
        EventManager.bind(this.gameObject,Event.ON_INTO_XIANGWEI, MainUIGrowth.Hide);
        EventManager.bind(this.gameObject,Event.ON_OUT_XIANGWEI, MainUIGrowth.Show);

        EventManager.bind(this.gameObject,Event.ON_SKILL_HIDE, MainUIGrowth.Hide);
        EventManager.bind(this.gameObject,Event.ON_SKILL_SHOW, MainUIGrowth.Show);

        EventManager.bind(this.gameObject,Event.ON_MAINUI_HIDE, MainUIGrowth.Hide);
        EventManager.bind(this.gameObject,Event.ON_MAINUI_SHOW, MainUIGrowth.Show);
	end

    function MainUIGrowth.FirstUpdate()

    end

    function MainUIGrowth.OnDestroy(  )
        
    end

    function MainUIGrowth.Hide()
        panel.transform:DOLocalMoveX(panelPos.x + 600, 0.5, false);
    end

    function MainUIGrowth.Show()
        if not const.InXiangWei and not const.OpenMenuFlag then
            panel.transform:DOLocalMoveX(panelPos.x, 0.3, false);
        end
    end

    function MainUIGrowth.CompleteTask(taskId )
        --上次成长目标为空，表示已经没了，不再做刷新
        if lastGrowth == nil then
            return;
        end

        detailPanel:Hide();
        local curGrowth = MainUIGrowth.getCurGrowth();

        --刷新成长目标
        if curGrowth == nil or curGrowth.id ~= lastGrowth.id then
            this:GO('Panel.Growth').transform:DOLocalMoveX(300, 0.5, false):OnComplete(function ()
                MainUIGrowth.RefreshGrowth(curGrowth);
                this:GO('Panel.Growth').transform:DOLocalMoveX(0, 0.5, false);
            end)

            ui.ShowMainUI();
            GuideManager.pause = true;

            --开放新系统UI
            playNewSystemOpen(lastGrowth.id);

            lastGrowth = curGrowth;
        end
    end

    function MainUIGrowth.RefreshGrowth(growth)
        if growth == nil then
            panel:Hide();
            return;
        end

        panel:Show();
        this:GO('Panel.Growth.Icon.Name').text = growth.name;
        this:GO('Panel.Growth.Icon.Icon').sprite = growth.icon;
        this:GO('Panel.Growth.Desc').text = growth.describe;
        this:GO('Panel.Growth.Condition').text = growth.condition;

        this:GO('Panel.Detail.ndTop.openLevel').text = string.format("角色等级达到%s级", growth.openLevel);
        local task = tb.TaskTable[growth.taskId];
        this:GO('Panel.Detail.ndTop.completeTask').text = string.format("完成主线任务<color=#64d122>%s</color>", task.name);

        --开放系统列表
        local list = growth.openSystem;
        for i=1, #list do
            if i > #itemList then
                local item = newObject(itemPrefab);
                item.transform:SetParent(itemGrid.transform);
                item.transform.localScale = Vector3.one;
                item.transform.localPosition = Vector3.zero;
                itemList[i] = item;
            end

            itemList[i].gameObject.name = i;
            itemList[i].gameObject:SetActive(true);

            itemList[i]:GO('Name').text = list[i].name;
            itemList[i]:GO('Desc').text = list[i].desc;
            itemList[i]:GO('Icon').sprite = list[i].icon;
        end

        for i=#list + 1, #itemList do
            itemList[i].gameObject:SetActive(false);
        end
    end

    --获取当前的成长目标
    function MainUIGrowth.getCurGrowth()
        local id = 1001;
        local growth;
        while tb.Growth[id] do
            growth = tb.Growth[id];

            if not client.task.getOverTaskBySid(growth.taskId) then
                return growth;
            end

            id = id+1;
        end

        return nil;
    end

    function MainUI.showGrowth(show)
        lastGrowth = MainUIGrowth.getCurGrowth();
        local scene = tb.SceneTable[DataCache.scene_sid];
        if lastGrowth == nil or scene == nil or scene.sceneType ~= "main_map" then
            panel.gameObject:SetActive(false);
        else
            panel.gameObject:SetActive(show);
        end
    end

    function MainUI.initGrowth()
        lastGrowth = MainUIGrowth.getCurGrowth();
        MainUIGrowth.RefreshGrowth(lastGrowth);
    end

    return MainUIGrowth;
end
