function UIGoldBoxView ()
	local UIGoldBox = {};
	local this = nil;
	local IconList = {"dk_putongkong","tb_baoxiang1","tb_baoxiang2","tb_baoxiang3"}
	local helpShow = false;
	function UIGoldBox.Start ()
		this = UIGoldBox.this;
		UIGoldBox.BtnClose:BindButtonClick(function (go)
			UIGoldBox.Destroy();
		end)
		for i=1,15 do
			UIGoldBox.BagItem[i].wrapper:BindButtonClick(function (go)
						if DataCache.treasureList[i] ~= nil then
							PanelManager:CreateConstPanel('ItemFloat',UIExtendType.BLACKCANCELMASK,{bDisplay = false, sid = DataCache.treasureList[i], treasureIndex = i});
						end
					end)			
		end
		UIGoldBox.help:BindButtonClick(function (go)
			helpShow = not helpShow;
			UIGoldBox.helpPanel.gameObject:SetActive(helpShow);
		end)
		UIGoldBox.helpClose:BindButtonClick(function (go)
			helpShow = not helpShow;
			UIGoldBox.helpPanel.gameObject:SetActive(helpShow);
		end)
		UIGoldBox.Refresh();
		UIGoldBox.GetLatestEfficiency();
	end

	function UIGoldBox.Refresh()
		-- print("黄金圣匣界面刷新！")
		local ItemInfo = nil;
		-- print(#DataCache.treasureList)
		UIGoldBox.treasureNumber.text = "巫师宝藏："..#DataCache.treasureList;
		-- UIGoldBox.RefreshEfficiency();
		for i=1,15 do
			if i > #DataCache.treasureList then
				UIGoldBox.BagItem[i].setIcon(IconList[1]);
			else
				UIGoldBox.BagItem[i].setTreasure(DataCache.treasureList[i]);
			end		
		end
	end

	local GetEfficiencyCallBack = function(msg)
		if msg["value"] ~= nil then
			DataCache.boxEfficiency = msg["value"];
			UIGoldBox.RefreshEfficiency();
		end
	end
	function UIGoldBox.GetLatestEfficiency()
		local msg = {cmd = "get_box_efficiency"};
		Send(msg, GetEfficiencyCallBack);
	end

	function UIGoldBox.RefreshEfficiency()
		print("UIGoldBox.RefreshEfficiency!")
		local hour = math.floor(DataCache.boxEfficiency/60);
		local minute = DataCache.boxEfficiency - hour * 60;
		if minute%5 ~= 0 then
			minute = (math.floor(minute/5) + 1) * 5;
		end
		if minute == 60 then
			minute = 0;
			hour = hour + 1;
		end
		UIGoldBox.treasureEfficiency.text = "挂机约<color=#88D524>"..hour.."小时"..minute.."分钟</color>获得一个巫师宝藏";
	end

	local lastOpenSid = 0;

	function UIGoldBox.SendOpenTreasure(index)
		if UIGoldBox.CheckEnoughSpace() == true then
			if DataCache.treasureList[index] ~= nil then
				-- print("open_treasure:"..index)
				lastOpenSid = DataCache.treasureList[index];
				local msg = {cmd = "open_treasure", index = index};
				Send(msg, UIGoldBox.SendCallback);
			end
		end
	end

	function UIGoldBox.SendCallback(reply)
		local newList = reply["new_list"];
		local equipList = reply["equip_list"];
		if newList ~= nil then
			DataCache.treasureList = newList;
			UIGoldBox.Refresh();
			--打开宝藏开启界面
			PanelManager:CreateConstPanel('UIOpenTreasure', UIExtendType.BLACKMASK, {treasureSid = lastOpenSid, equipList = equipList});
		end
	end

	function UIGoldBox.CheckEnoughSpace()
		if Bag.getBagGridCount() < 4 then
			ui.showMsg("背包空间不足，请先清理背包")
			return false
		else
			return true
		end
	end

	function UIGoldBox.Destroy()
		destroy(this.gameObject);
		ui.UIGoldBoxG = nil;
	end

	
	ui.UIGoldBoxG = UIGoldBox;
	return UIGoldBox;
end


