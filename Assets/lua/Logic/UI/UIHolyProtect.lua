function UIHolyProtectView ()	
	local UIHolyProtect = {};
	local this = nil;
	local close = nil
	local list = nil;
	local content = nil;
	local itemTab = {};
	local item1 = nil;
	local item2 = nil;
	local item3 = nil;
	local item4 = nil;
	local item5 = nil;
	local item6 = nil;
	local item7 = nil;
	local item8 = nil;
	local item9 = nil;
	local item10 = nil;
	local item11 = nil;
	local item12 = nil;
	local item13 = nil;
	local Position;
	local leftArrow = nil;
	local rightArrow = nil;
	local leftState = false;
	local rightState = true;
	local effect = nil;

	function UIHolyProtect.Start()
		this = UIHolyProtect.this;
		content = this:GO('content.center.list.viewport.content');
		leftArrow = this:GO('content.center.list.viewport.left');
		rightArrow = this:GO('content.center.list.viewport.right');
		effect = this:GO('content.center.list.viewport.effect');
		Position = content.transform.localPosition;
		item1 = content:GO('item1');
		item2 = content:GO('item2');
		item3 = content:GO('item3');
		item4 = content:GO('item4');
		item5 = content:GO('item5');
		item6 = content:GO('item6');
		item7 = content:GO('item7');
		item8 = content:GO('item8');
		item9 = content:GO('item9');
		item10 = content:GO('item10');
		item11 = content:GO('item11');
		item12 = content:GO('item12');
		item13 = content:GO('item13');
		itemTab = {item1, item2, item3, item4, item5, item6, item7, item8, item9, item10, item11, item12, item13};
		this:GO('content.top.close'):BindButtonClick(UIHolyProtect.onCancelClick);
    	UIHolyProtect.Init();
    	UIHolyProtect.Select();
    	this:GO('content.center.list'):BindScrollRectValueChanged(UIHolyProtect.ContentChanged);
	end

	function UIHolyProtect.Init()
		-- 给当前已经开启的圣灵增加标识
		--client.holyProtect.GetHolyList();
		local chapter = client.holyProtect.GetHolyChapter();	
		local list = client.holyProtect.holylist;
		for i = 1, #list do
			itemTab[i]:GO('name').sprite = list[i].mini_icon;
			itemTab[i]:GO('bg').sprite = list[i].icon;
			if i >= chapter then
				itemTab[i]:GO('bg').sprite = "dk_yinbaizhishen_2";
				Util.SetGray(itemTab[i]:GO('name').gameObject, true);
				Util.SetGray(itemTab[i]:GO('left').gameObject, true);
				Util.SetGray(itemTab[i]:GO('right').gameObject, true);
			end
			itemTab[i]:BindButtonClick(function()
				UIHolyProtect.ClickItem(i); 
			end);
		end
	end

	function UIHolyProtect.Select()
		local chapter = client.holyProtect.GetHolyChapter();

		if chapter > 3 and chapter < 12 then
			content.transform:DOLocalMoveX(Position.x - 430 * (chapter-3), 1, false);
		end
		if chapter == 12 then
			content.transform:DOLocalMoveX(Position.x - 430 * (chapter-2), 1, false);
		end
		-- 第一次界面执行
		if chapter > 1 then
			if client.holyProtect.holylist[chapter-1].state == 1 and client.holyProtect.holylist[chapter-1].jindu == 1 and client.holyProtect.holylist[chapter].jindu == 0 then
				if isFirstHolyShow then
					this:Delay(1, function()
						itemTab[chapter - 1]:GO("effectObj"):PlayUIEffect(this.gameObject, "shenglin");
						end);
					isFirstHolyShow = false;
				end
			end
		end
	end

	function UIHolyProtect.ContentChanged()
		-- 处理content滑动时两边箭头的显示问题
		local Pos = content.transform.localPosition;
		if Pos.x + 430 < 0 and  Pos.x + 3396 > 0 and (not leftState or not rightState) then
			leftArrow.gameObject:SetActive(true);
			rightArrow.gameObject:SetActive(true);
			leftState = true;
			rightState = true;
		end
		if Pos.x + 3396 < 0 and rightState and (not leftState or rightState) then
			leftArrow.gameObject:SetActive(true);
			rightArrow.gameObject:SetActive(false);
			leftState = true;
			rightState = false;
		end
		if Pos.x + 430 > 0 and leftState and (leftState or not rightState) then
			leftArrow.gameObject:SetActive(false);
			rightArrow.gameObject:SetActive(true);
			leftState = false;
			rightState = true;
		end
	end

	function UIHolyProtect.ClickItem(index)
		destroy(this.gameObject);
		PanelManager:CreatePanel('UIHolyItem', UIExtendType.NONE, index);
	end

	function UIHolyProtect.onCancelClick()
		destroy(this.gameObject);
	end

	return UIHolyProtect;
end