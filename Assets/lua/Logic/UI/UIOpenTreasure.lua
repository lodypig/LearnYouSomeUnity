function UIOpenTreasureView (param) --{treasureSid,EquipList}
	local UIOpenTreasure = {};
	local this = nil;
	--第一次打开的时候使用传入的值
	local treasureSid = param.treasureSid;
	local equipList = param.equipList;
	local backEffectList = {"lueduodiguang_lanse","lueduodiguang_zise","lueduodiguang"};
	local formerEffectList = {"lueduobaoxiang_lanse","lueduobaoxiang_zise","lueduobaoxiang"};
	function UIOpenTreasure.Start ()
		this = UIOpenTreasure.this;
		UIOpenTreasure.BtnClose:BindButtonClick(function (go)
			UIOpenTreasure.Destroy();
		end)
		--装备格子生成控制器
		UIOpenTreasure.Refresh();
	end

	--更新界面，播放光效等
	function UIOpenTreasure.Refresh()
		local treasureInfo = tb.ItemTable[treasureSid];
		local itemStr = client.tools.formatColor(treasureInfo.name, const.qualityColor[treasureInfo.quality + 1]);
		local str = "恭喜，成功打开"..itemStr;
		ui.showMsg(str);
		--上方宝箱光效
		UIOpenTreasure.BoxImage:StopAllUIEffects();
		this:Delay(0.1 ,function()
			UIOpenTreasure.BoxImage:PlayUIEffectForever(this.gameObject, backEffectList[treasureInfo.quality - 1]);
			UIOpenTreasure.BoxImage:PlayUIEffectForever(this.gameObject, formerEffectList[treasureInfo.quality - 1]);			-- body
		end)

		--宝箱文字说明
		-- local str = string.format("<color=%s>%s</color>", const.qualityColor[treasureInfo.quality + 1], treasureInfo.name);
		-- UIOpenTreasure.treasureName.text = str;
		UIOpenTreasure.treasureName.text = treasureInfo.name;	


		--装备格子初始化
		for i=1,#equipList do
			UIOpenTreasure.BagItem[i].reset();
			this:Delay(0.3 * i, function()
				local equip = client.equip.parseEquip(equipList[i][2]);
				UIOpenTreasure.BagItem[i].wrapper:Show();
				UIOpenTreasure.BagItem[i].setEquip(equip);
				-- UIOpenTreasure.BagItem[i].wrapper:StopAllUIEffects();
				UIOpenTreasure.BagItem[i].wrapper:GO("_icon"):PlayUIEffect(this.gameObject, "lueduojiangli",2,function() end,true,false,UIWrapper.UIEffectAddType.Replace);
				UIOpenTreasure.BagItem[i].wrapper:BindButtonClick(function (go)
					local click_pos = go:GetComponent("UIWrapper").pointer_position
					PanelManager:CreateConstPanel('EquipFloat',UIExtendType.BLACKCANCELMASK, 
						{pos = click_pos, showType = "show", base = equip});
				end)		
			end);
		end
		for i=#equipList + 1,10 do
			UIOpenTreasure.BagItem[i].reset();
			UIOpenTreasure.BagItem[i].wrapper:Hide();
		end

		--如果还有下一个宝箱，初始化下一个宝箱的信息
		if #DataCache.treasureList ~= 0 then
			-- UIOpenTreasure.BoxItem.wrapper:Show();
			-- UIOpenTreasure.BoxItem.setTreasure(DataCache.treasureList[1]);
			-- UIOpenTreasure.BoxItem.wrapper:BindButtonClick(function (go)
			-- 	PanelManager:CreateConstPanel('ItemFloat',UIExtendType.BLACKCANCELMASK,{bDisplay = true, sid = DataCache.treasureList[1], treasureIndex = 1});
			-- end)	
			UIOpenTreasure.BtnText.text = "继续开启"
			UIOpenTreasure.BtnContinue:BindButtonClick(function (go)
				UIOpenTreasure.SendOpenTreasure();
			end)	
		else
			UIOpenTreasure.BoxItem.wrapper:Hide();
			UIOpenTreasure.BtnText.text = "关 闭"
			UIOpenTreasure.BtnContinue:BindButtonClick(function (go)
					UIOpenTreasure.Destroy();
				end)		
		end
	end

	function UIOpenTreasure.CheckEnoughSpace()
		if Bag.getBagGridCount() < 4 then
			ui.showMsg("背包空间不足，请先清理背包")
			return false
		else
			return true
		end
	end

	function UIOpenTreasure.SendOpenTreasure()
		if UIOpenTreasure.CheckEnoughSpace() == true then
			if DataCache.treasureList[1] ~= nil then
				treasureSid = DataCache.treasureList[1];
				local msg = {cmd = "open_treasure", index = 1};
				Send(msg, UIOpenTreasure.SendCallback);
			end
		end
	end

	function UIOpenTreasure.SendCallback(reply)
		local newList = reply["new_list"];
		local newEquipList = reply["equip_list"];
		if newList ~= nil then
			DataCache.treasureList = newList;
			equipList = newEquipList;
			UIOpenTreasure.Refresh();

			if ui.UIGoldBoxG then
				ui.UIGoldBoxG.Refresh();
			end
		end
	end

	function UIOpenTreasure.Destroy()
		destroy(this.gameObject);
	end
	return UIOpenTreasure;
end


