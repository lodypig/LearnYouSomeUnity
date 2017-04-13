function UIRankingListView ()
	local UIRankingList = {};
	local this = nil;
	local FightNumberBtn = nil;
	local LevelBtn = nil;
	local BadNameBtn = nil;
	local Content = nil;
	local Close = nil;
	local InfoConst1 = nil;
	local InfoValue1 = nil;
	local InfoConst2 = nil;
	local InfoValue2 = nil;

	local myInfo = nil;

	local levelRankList = {};
	local zhanLiRankList = {};
	local sinRankList = {};
	local currentRankList;

	local currentSelect = nil;
	local itemPrefab = nil;
	local warpContent = nil;
	local cellGirdPosition = nil;

	local rankImage = { "tb_paihangbang_1",
						"tb_paihangbang_2",
						"tb_paihangbang_3"};

	local parseRanker = function (info, rankerType)	
		local ranker = {};
		ranker.id = info[1];
		--info[2]有可能是string  有可能是table(中文的话)
		if type(info[2]) == "string" then
			ranker.name = info[2]
		else
			ranker.name = client.tools.ensureString(info[2])
		end
		ranker.value = info[3];
		if rankerType == "level" then
			ranker.exp = info[4];
			ranker.level = ranker.value;
		else
			ranker.level = info[4];
		end
		ranker.legionName = client.tools.ensureString(info[5])
		ranker.career = info[6];
		ranker.sex = info[7];
		return ranker;
	end

	local getServerRankList = function (type, subType, list, func)
		local msg = {};
		msg.cmd = "get_pai_hang";
		msg.type = type;
		msg.subtype = subType;

		Send(msg, function (msg)
			local myRank = nil
			for i = 1, #msg.list do
				local ranker = parseRanker(msg.list[i], msg.type);
				if ranker.level >= 20 then
					list[#list + 1] = ranker;
				end
			end

			--如果是等级排行榜，根据经验再排序
			if type == "level" then
				table.sort(list, function (a, b)
					if a.level ~= b.level then
						return a.level > b.level;
					end
					if a.exp ~= b.exp then
						return a.exp > b.exp; 
					end
					return a.id > b.id;
				end)
			end

			for i=1,#list do
				if list[i].id == DataCache.roleID then
					myRank = i;
					break;
				end
			end

			list.myRank = myRank;
			list.myValue = msg.myValue;
			list.myName = DataCache.myInfo.name;
			
			func();
		end);
	end

	local formatMe = function (list)
		myInfo.gameObject:SetActive(true);
		local wrapper = myInfo:GetComponent("UIWrapper");
		local Image = wrapper:GO("rankImage");
		local Text = wrapper:GO("rankText");
		local Name = wrapper:GO("Name");
		local Value = wrapper:GO("Value");
		local guild = wrapper:GO("Guild");
		guild.textColor = Color.New(108/255, 108/255, 109/255);

		if client.role.haveClan() then
			guild.textColor = Color.New(228/255, 228/255, 228/255);
			guild.text = client.legion.LegionBaseInfo.Name;
		else
			guild.textColor = Color.New(108/255, 108/255, 109/255);
			guild.text = "未加入";
		end

		if list.myRank then	
			if list.myRank < 4 then				
				Image.sprite = rankImage[list.myRank];
				Image.gameObject:SetActive(true);
				Text.gameObject:SetActive(false);
			else
				Image.gameObject:SetActive(false);
				Text.gameObject:SetActive(true);
				Text.text = list.myRank;
			end
		else
			Image.gameObject:SetActive(false);
			Text.gameObject:SetActive(true);
			Text.text = "未上榜";
		end
		Name.text = list.myName;
		if list.myValue ~= nil and list.myValue ~= "none" then
			Value.text = math.round(list.myValue);
		else
			Value.text = 0;
		end
	end

	local formatShowList = function (valueName)
		this:GO('Content.Title._ValueName').text = valueName;
		warpContent:Init(#currentRankList);
		formatMe(currentRankList);
	end

	local getServerRankListAndShow = function (type, subType, valueName) 
		getServerRankList(type, subType, currentRankList, function () 
			formatShowList(valueName);
		end);
	end

	function UIRankingList.Start ()
		this = UIRankingList.this;

		local commonDlgGO = this:GO('CommonDlg2');
		UIRankingList.controller = createCDC(commonDlgGO, true)
		UIRankingList.controller.SetButtonNumber(3);
		UIRankingList.controller.SetButtonText(1,"战力榜");		
		UIRankingList.controller.bindButtonClick(1, UIRankingList.SelectFightNumber);
		UIRankingList.controller.SetButtonText(2,"等级榜");
		UIRankingList.controller.bindButtonClick(2, UIRankingList.SelectLevel);
		UIRankingList.controller.SetButtonText(3,"屠杀榜");
		UIRankingList.controller.bindButtonClick(3, UIRankingList.SelectBadName);	

		UIRankingList.controller.bindButtonClick(0, UIRankingList.closeSelf);
		UIRankingList.controller.SetTitle("wz_paihangbang")

		--子榜按钮
		local subButton = this:GO('SubButton');
		UIRankingList.controller2 = createCDC(subButton, true);

		Content = this:GO('Content.Container.Grid._Content');
		myInfo = this:GO("Content.MyInfo");
		myInfo:GO('Face.faceImage').sprite = const.RoleImgTab[DataCache.myInfo.career][DataCache.myInfo.sex + 1];
		myInfo.gameObject:SetActive(false);
		-- -- 将bg移到Frame之上
		-- local pos = this:GO('CommonDlg2.Frame'):GetComponent('RectTransform'):GetSiblingIndex();
		-- local rt = this:GO('bg'):GetComponent('RectTransform');
		-- rt:SetParent(this:GO('CommonDlg2'):GetComponent('RectTransform'));
		-- rt.localScale = Vector3.one;
		-- rt:SetSiblingIndex(pos);

		itemPrefab = this:GO('Content.Container.Grid.Item').gameObject;
		itemPrefab:SetActive(false);
		cellGirdPosition = Content:GetComponent("RectTransform").anchoredPosition;
		warpContent = this:GO('Content.Container'):GetComponent("UIWarpContent");
		warpContent.goItemPrefab = itemPrefab;
		warpContent:BindInitializeItem(UIRankingList.FormatListItem);

		UIRankingList.controller.activeButton(1);	
	end

	function UIRankingList.closeSelf()
		destroy(this.gameObject);
	end

	function UIRankingList.ShowSubButton(index)
		UIRankingList.controller2.wrapper.gameObject:SetActive(true);
		local rt = UIRankingList.controller2.wrapper:GetComponent('RectTransform');
		rt:SetParent(this:GO('CommonDlg2.ButtonGroup').transform);
		rt:SetSiblingIndex(index);
	end

	function UIRankingList.HideSubButton()
		UIRankingList.controller2.wrapper.gameObject:SetActive(false);
	end

	function UIRankingList.SetButtonArrow(index, state)
		local controller = UIRankingList.controller;
		for i = 1,controller.maxBtnNum do
			local arrow = controller.wrapper:GO("ButtonGroup.btn"..i..".arrow");
			local angle;

			if index == i and state == "up" then
				arrow.gameObject:SetActive(true);
				angle = Vector3.New(0, 0, 180);
				arrow.transform.localEulerAngles = angle
			elseif index == i and state == "down" then
				arrow.gameObject:SetActive(true);
				angle = Vector3.New(0, 0, 0);
				arrow.transform.localEulerAngles = angle
			elseif index == i and state == "hide" then
				arrow:Hide();
			else
				angle = Vector3.New(0, 0, 0);
				arrow.transform.localEulerAngles = angle
			end
		end
	end

	function  UIRankingList.SelectFightNumber()
		this:GO('CommonDlg2.ButtonGroup.btn1').sprite = "bqy_erji_1_paihangbang"
		if UIRankingList.curButtonIndex == 1 then
			UIRankingList.SetButtonArrow(1, "down");
			UIRankingList.HideSubButton()
			UIRankingList.curButtonIndex = 0;
			return;
		end

		UIRankingList.curButtonIndex = 1;
		UIRankingList.SetButtonArrow(1, "up");
		UIRankingList.ShowSubButton(1)

		-- 重构成配置 liupr
		local tbl = {
			{"战力总排行", function () UIRankingList.SelectFightNumberSub("all"); end},
			--{"装备战力榜", function () UIRankingList.SelectFightNumberSub("equip"); end },
			--{"技能战力榜", function () UIRankingList.SelectFightNumberSub("ability"); end},
			--{"坐骑战力榜", function () UIRankingList.SelectFightNumberSub("horse"); end},
		}
		local cfg_size =#tbl;
		UIRankingList.controller2.SetButtonNumber(cfg_size);
		for i=1, cfg_size do
			UIRankingList.controller2.SetButtonText(i, tbl[i][1]);
			UIRankingList.controller2.bindButtonClick(i, tbl[i][2]);
		end
		-- end 重构

		--[[
		UIRankingList.controller2.SetButtonNumber(4);
		UIRankingList.controller2.SetButtonText(1,"战力总排行");		
		UIRankingList.controller2.bindButtonClick(1, function ()
			UIRankingList.SelectFightNumberSub("all");
		end);
		UIRankingList.controller2.SetButtonText(2,"装备战力榜");
		UIRankingList.controller2.bindButtonClick(2, function ()
			UIRankingList.SelectFightNumberSub("equip");
		end);
		UIRankingList.controller2.SetButtonText(3,"技能战力榜");
		UIRankingList.controller2.bindButtonClick(3, function ()
			UIRankingList.SelectFightNumberSub("ability");
		end);	
		UIRankingList.controller2.SetButtonText(4,"坐骑战力榜");
		UIRankingList.controller2.bindButtonClick(4, function ()
			UIRankingList.SelectFightNumberSub("horse");
		end);	
--]]
		UIRankingList.controller2.activeButton(1);
	end

	function UIRankingList.SelectFightNumberSub(type)
		currentRankList = zhanLiRankList[type];
		if (currentRankList ~= nil and #currentRankList > 0) then
			formatShowList("战斗力");
		else
			currentRankList = {};
			getServerRankListAndShow("zhanli", type, "战斗力");
			zhanLiRankList[type] = currentRankList;
		end	
	end

	function  UIRankingList.SelectLevel()
		this:GO('CommonDlg2.ButtonGroup.btn2').sprite = "bqy_erji_1_paihangbang"
		if UIRankingList.curButtonIndex == 2 then
			UIRankingList.SetButtonArrow(2, "down");
			UIRankingList.HideSubButton()
			UIRankingList.curButtonIndex = 0;
			return;
		end

		UIRankingList.curButtonIndex = 2;
		UIRankingList.SetButtonArrow(2, "up");
		UIRankingList.ShowSubButton(2)

		UIRankingList.controller2.SetButtonNumber(4);
		UIRankingList.controller2.SetButtonText(1,"等级总排行");		
		UIRankingList.controller2.bindButtonClick(1, function () 
			UIRankingList.SelectLevelSub("all");
		end);
		UIRankingList.controller2.SetButtonText(2,"龙魂斗士榜");
		UIRankingList.controller2.bindButtonClick(2, function ()
			UIRankingList.SelectLevelSub("soldier");
		end);
		UIRankingList.controller2.SetButtonText(3,"圣痕射手榜");
		UIRankingList.controller2.bindButtonClick(3, function ()
			UIRankingList.SelectLevelSub("bowman");
		end);	
		UIRankingList.controller2.SetButtonText(4,"神谕魔导榜");
		UIRankingList.controller2.bindButtonClick(4, function ()
			UIRankingList.SelectLevelSub("magician");
		end);	
		UIRankingList.controller2.activeButton(1);	
	end

	function  UIRankingList.SelectLevelSub(career)
		currentRankList = levelRankList[career];

		if currentRankList ~= nil and #currentRankList > 0 then
			formatShowList("等级");
		else
			currentRankList = {};
			getServerRankListAndShow("level", career, "等级");
			levelRankList[career] = currentRankList;
		end	
	end

	function  UIRankingList.SelectBadName()
		this:GO('CommonDlg2.ButtonGroup.btn3').sprite = "an_zhankai_2"
		if UIRankingList.curButtonIndex == 3 then
			return;
		end

		UIRankingList.curButtonIndex = 3;
		UIRankingList.SetButtonArrow(3, "hide");
		UIRankingList.HideSubButton()

		currentRankList = sinRankList;
		if (#sinRankList > 0) then
			formatShowList("恶名值");
		else  
			--UIRankingList.ResizeCellTo(0);
			--currentRankList = sinRankList;
			getServerRankListAndShow("sin", "all","历史屠杀值");
			sinRankList = currentRankList;
		end		
	end

	function UIRankingList.FormatListItem(go, index)
		local ranker = currentRankList[index];
		if ranker == nil then
			return
		end
		local wrapper = go:GetComponent("UIWrapper");
		if wrapper ~= nil then
			local Image = wrapper:GO("rankImage");
			local Text = wrapper:GO("rankText");
			local name = wrapper:GO("Name");
			local guild = wrapper:GO("Guild");
			local value = wrapper:GO("Value")
			local titleName = wrapper:GO("titleName");
			if titleName ~= nil then
				titleName.gameObject:SetActive(false); -- NSY-4738 屏蔽
			end
			--index 1-3 改变图片
			name.text = ranker.name;
			wrapper:GO("Face.faceImage").sprite = const.RoleImgTab[ranker.career][ranker.sex + 1];
			wrapper:GO("Value").text = math.round(ranker.value);	--取整
			if ranker.legionName == "" or ranker.legionName == nil then
				guild.textColor = Color.New(108/255, 108/255, 109/255);
				guild.text = "未加入";
			else
				guild.textColor = Color.New(228/255, 228/255, 228/255);
				guild.text = ranker.legionName;
			end

			name.textColor = Color.New(228/255, 228/255, 228/255);
			Text.textColor = Color.New(228/255, 228/255, 228/255);
			wrapper:GO("Value").textColor = Color.New(228/255, 228/255, 228/255);
			if ranker.id == DataCache.roleID then 
				name.textColor = Color.New(254/255, 180/255, 95/255);
				Text.textColor = Color.New(254/255, 180/255, 95/255);
				guild.textColor = Color.New(254/255, 180/255, 95/255);
				wrapper:GO("Value").textColor = Color.New(254/255, 180/255, 95/255);
			end

			if index < 4 then			
				Image.sprite = rankImage[index];
				Image.gameObject:SetActive(true);
				Text.gameObject:SetActive(false);
			else
				Image.gameObject:SetActive(false);
				Text.gameObject:SetActive(true);
				Text.text = index;
			end
		
			--changeByLiuz
			local ranker = currentRankList[index];
			wrapper:BindButtonClick(function ()
				if ranker.id ~= DataCache.roleID then
					local spSelected = wrapper:GO('spSelected').gameObject;
	                local btnList = {"sendMsg","roleInfo","addFriend"};
	                
                    GetRoleDetail(ranker.id, function ()
                    	UIRankingList.ShowSelect(spSelected);
                    	if client.role.haveClan() and math.abs(client.legion.LegionBaseInfo.SelfJur[1]) == 1 and DataCache.otherInfo.offline == false and DataCache.otherInfo.level >= 30 then
				            table.insert(btnList,"legionInvitation");
				        end 
	                	ui.ShowOperateFloat(DataCache.otherInfo, btnList, const.operateFloatPos.rank, this,function() UIRankingList.LostSelect(spSelected); end);
                    end);
	            end
		    end)
		end	
	end

	function UIRankingList.ShowSelect(go)
        go:SetActive(true);
    end

    function UIRankingList.LostSelect(go)
        go:SetActive(false);
    end

	return UIRankingList;
end

