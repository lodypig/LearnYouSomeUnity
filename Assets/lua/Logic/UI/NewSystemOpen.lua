function NewSystemOpenView(param)
	local NewSystemOpen = {};
	local this = nil;

	local itemPrefab = nil;
    local itemGrid = nil;
    local itemList = {};

    local init = false;
	local lastTime = 0;		--当前计时
	local canClick = false;--2秒后可点击屏幕
	local stop = false;	--加个开关，防止连续点击多次播放特效

	function NewSystemOpen.Start()
		this = NewSystemOpen.this;

		itemPrefab = this:GO('Panel.Grid.Item');
        itemPrefab:Hide();
        itemGrid = this:GO('Panel.Grid');

        this:GO('ClickMask'):BindButtonClick(NewSystemOpen.Play);

        lastTime = TimerManager.GetUnityTime();
	end

	function NewSystemOpen.Update()
		if stop then
			return;
		end

		local time = TimerManager.GetUnityTime() - lastTime

		if time > 0.2 and init == false then
			NewSystemOpen.Init();
		end

		if time > 2 and canClick == false then
			canClick = true;
		end
	end

	function NewSystemOpen.Init()
		init = true;
		local growth = tb.Growth[param.growth_id];

        local list = growth.openSystem;
        for i=1, #list do
            local item = newObject(itemPrefab);
            item.transform:SetParent(itemGrid.transform);
            item.transform.localScale = Vector3.one;
            item.transform.localPosition = Vector3.zero;
            itemList[i] = item;
            

            itemList[i].gameObject.name = i;
            itemList[i].gameObject:SetActive(true);

            itemList[i]:GO('Name').text = list[i].name;
            itemList[i]:GO('Icon').sprite = list[i].icon;
            itemList[i]:SetUserData("flyPath", list[i].ui_path);
            itemList[i]:GO('Effect'):PlayUIEffect(this.gameObject, "chengzhangxitong1", 2);
        end

	end

	function NewSystemOpen.Play()
		if canClick then
			for i=1, #itemList do
				local path = itemList[i]:GetUserData("flyPath");
				local target = NewSystemOpen.getTarget(path);
				if target then
					target:PlayUIEffect(this.gameObject, "chengzhangxitong", 5, function (go)
		    		go.transform.position = itemList[i].transform.position;
				    go.transform:DOMove(target.transform.position,1,false):OnComplete(function ()
				    	go:SetActive(false);
				    	target:PlayUIEffect(this.gameObject, "chengzhangxitong2", 0.5, function ( effect )
				    		local effectController = effect:GetComponent("EffectController");
            				effectController:BindDestroyFunction(NewSystemOpen.Close);
				    	end, true)
				    	 end)
					end, true, false, UIWrapper.UIEffectAddType.Overlying);
				else
					--print("成长目标飞往的对象路径找不到: " .. path);
					NewSystemOpen.Close();
				end
			end
			
			stop = true;
			canClick =  false;
			this:GO('Panel'):Hide();
		end
	end

	function NewSystemOpen.getTarget(path)
		local pos = string.find(path, "%.");
        if pos ~= nil then
            local uiName = string.sub(path, 1, pos - 1);
            local target = string.sub(path, pos + 1);
            local ui = UIManager.GetInstance():FindUI(uiName);

            if ui ~= nil then
                local lua = ui.gameObject:GetComponent("LuaBehaviour");
                if lua ~= nil  then
                   return lua:GO(target);
                end
            end
        end

        return nil;
	end

	function NewSystemOpen.Close()
        GuideManager.pause = false;
		destroy(this.gameObject);
	end

	return NewSystemOpen;
end

function playNewSystemOpen(growthId)
	local param = {growth_id = growthId};
	PanelManager:CreateConstPanel("NewSystemOpen", UIExtendType.NONE, param);
end