function UILegionView ()
	local UILegion = {LegionInfo = {}, LegionMember = {}, LegionShop = {}, LegionLog = {}};
	local this = nil;
	local legionInfoPanel = nil;
	local legionMemberPanel = nil;
	local legionShopPanel = nil;
	-- local legionLogPanel = nil;
	local legionBaseTab = nil;
	-- local panel = nil;
	local oldPos = nil;
	local activesWraps= {}
	local redPointWraps = {}

	local input = nil;
	local editBox = nil;
	local saveBtn = nil;
	local maxCharNum = 128;   -- 宣言和公告的最大字数

	local legionNoticePanel = nil;


	local openFlag = {1,0,1,0,0,0}; -- 开放标识
	local contributeSprite = {['money'] = 'tb_jinbi',
						['diamond'] = 'tb_zuanshi'}; -- 贡献图标
	local levelUpSprite = {'an_juntuan_shengji','an_qingchu'}; -- 升级按钮图标

	local shopCurchoose = 1;

	local sortKey = nil;
	local level1_Flag = 1;
	local fightPoint1_Flag = 1;
	local position1_Flag = 1;
	local contribution1_Flag = 1;
	local status1_Flag = 1;

	local position2_Flag = 1;
	local contribution2_Flag = 1;
	local task2_Flag = 1;
	local camp2_Flag = 1;
	local status2_Flag = 1;

 	local textTab = {
		contribution = "公会建设度说明：\n1、公会成员完成公会相关任务玩法可提升公会建设度；\n\n2、每天5点消耗一定数值的建设度进行公会维护。\n\n维护消耗：%s/天",
		prosperity = "公会繁荣度说明：\n1、公会繁荣度反映公会成员在三天内的上线率情况；\n\n2、当公会繁荣度连续3天低于%s时，公会将会受到降级或强制解散的惩罚。",
		money = "公会资金说明：\n1、公会成员完成公会相关任务玩法可为公会增加资金；\n\n2、每周一将拨出一定比例的公会资金作为分红，发放给上周作出贡献的成员；\n\n3、提升公会等级可以提升公会资金的储存上限。\n\n储存上限：%s"
	}

	function UILegion.Start ()
		this = UILegion.this;

		UILegion.controller = createCDC(UILegion.CommonDlg)
		UILegion.controller.SetButtonNumber(3);

		UILegion.controller.SetButtonText(1,"主页");
		UILegion.controller.bindButtonClick(1,client.legion.get_legion_base_info);		

		UILegion.controller.SetButtonText(2,"成员");
		UILegion.controller.bindButtonClick(2,
			function ()
        		client.legion.get_Legion_Member_List()
        		if client.legion.get_redpoint_flag(client.legion.RedPointType.applylist) == 1 then
            		client.legion.get_Applicant_list()
				end
			end
		);

		UILegion.controller.SetButtonText(3,"商店");
		--UILegion.controller.bindButtonClick(3,client.legion.get_Legion_Shop_Info); --屏蔽之前,如果要恢复功能请解开注释,并删除下一个语句
		UILegion.controller.bindButtonClick(3, nil,client.legion.get_Legion_Shop_Info); --屏蔽之后,
		UILegion.controller.bindButtonClick(0,UILegion.Close);
		
		-- 默认打开公会主页
		UILegion.controller.activeButton(1);
		client.legion.update_redpoint_listener = UILegion.LegionInfo.UpdateRedPoint

		-- 活动相关
		for i=1,5 do
			activesWraps[i] = UILegion.activity:GO("content."..i);
			redPointWraps[i] = activesWraps[i]:GO('actBtn.flag');
		end
		for i = 1,3 do
			redPointWraps[#redPointWraps + 1] = UILegion.CommonDlg:GO('ButtonGroup.btn'..i..'.flag');
		end
		redPointWraps[#redPointWraps + 1] = UILegion.applyListBtn:GO('flag')

		-- 公会成员界面默认显示第一分页
		UILegion.LegionMember.controller = createCDC(UILegion.checkBox);
		UILegion.LegionMember.controller.SetButtonNumber(2);

		UILegion.LegionMember.controller.SetButtonText(1,"基本信息");
		UILegion.LegionMember.controller.bindButtonClick(1,function ()
			UILegion.content1.gameObject:SetActive(true)
			UILegion.content2.gameObject:SetActive(false)
		end);			

		UILegion.LegionMember.controller.SetButtonText(2,"详细信息");
		UILegion.LegionMember.controller.bindButtonClick(2,function ()
			UILegion.content1.gameObject:SetActive(false)
			UILegion.content2.gameObject:SetActive(true)
		end);
		UILegion.LegionMember.controller.activeButton(1);
	end

	function UILegion.ShowLegionInfo()
		UILegion.ShowPanel(1);
		legionBaseTab = tb.legionBase[client.legion.LegionBaseInfo.Level];
		-- 公会基本信息
		UILegion.legionName.text = client.legion.LegionBaseInfo.Name;
		UILegion.legionLevel.text = client.legion.LegionBaseInfo.Level;
		UILegion.legionBuildText.text = client.legion.LegionBaseInfo.Construction.."/"..legionBaseTab.levelupcost;
		UILegion.legionBuildFg.fillAmount = client.legion.LegionBaseInfo.Construction / legionBaseTab.levelupcost

		UILegion.leaderName.text = client.legion.LegionBaseInfo.TuanZhangName;
		UILegion.peopleCount.text = client.legion.LegionBaseInfo.MemberNum..'/'..legionBaseTab.maxmember;
		UILegion.prosperity.text = client.legion.LegionBaseInfo.Prosperity;

		UILegion.moneyText.text = client.legion.LegionBaseInfo.Money;
		UILegion.moneyfg.fillAmount = client.legion.LegionBaseInfo.Money / legionBaseTab.maxmoney;

		UILegion.announcement.text = client.legion.LegionBaseInfo.Announcement;

		UILegion.levelUpGuide:BindButtonClick(function ()
			UILegion.LegionInfo.ShowTip("contribution");
		end);
		UILegion.prosperityGuide:BindButtonClick(function ()
			UILegion.LegionInfo.ShowTip("prosperity");
		end);
		UILegion.moneyGuide:BindButtonClick(function ()
			UILegion.LegionInfo.ShowTip("money");
		end);

		if client.legion.LegionBaseInfo.Level == const.maxLegionLevel then -- 满级，临时写死
			UILegion.levelUpBtn.gameObject:SetActive(false);
			UILegion.topLevel.gameObject:SetActive(true);
			UILegion.levelUpGuide.gameObject:SetActive(false)
		else
			UILegion.topLevel.gameObject:SetActive(false);
			-- 升级按钮点击响应 没有权限的人无法看见按钮
			local Jur = math.abs(client.legion.LegionBaseInfo.SelfJur[5])
			UILegion.levelUpBtn.gameObject:SetActive(Jur == 1);
			if Jur == 1 then -- 玩家此时 具有升级的权限
				if client.legion.LegionBaseInfo.Construction >= legionBaseTab.levelupcost then
					UILegion.levelUpBtn.gameObject:SetActive(true);
					UILegion.levelUpGuide.gameObject:SetActive(false);

					UILegion.levelUpBtn:BindButtonClick(client.legion.level_Up_Legion); -- 升级成功之后应该要刷新界面,需要给level_up_Legion传递回调
				else
					UILegion.levelUpBtn.gameObject:SetActive(false);
					UILegion.levelUpGuide.gameObject:SetActive(true);
				end
			else
				UILegion.levelUpGuide.gameObject:SetActive(true)
				UILegion.levelUpBtn.gameObject:SetActive(false)
			end
		end

		if math.abs(client.legion.LegionBaseInfo.SelfJur[4]) == 1 then
			UILegion.modifyBtn.gameObject:SetActive(true);
		else
			UILegion.modifyBtn.gameObject:SetActive(false);
		end
		-- 修改公告按钮响应，需要统一接口，统一使用UILegionChangeText
		UILegion.modifyBtn:BindButtonClick(function ()
			local content = string.format( "内部公告显示在公会主页，最多输入%d字",client.legion.XuanYanCharacterLimit/2)
			ui.ShowLegionChangeText("请输入内部公告",content, client.legion.XuanYanCharacterLimit, client.legion.LegionBaseInfo.Announcement, function (text)
				if math.abs(client.legion.LegionBaseInfo.SelfJur[4]) ~= 1 then
					ui.showMsg("你的权限不足，修改失败");
					return
				end
				client.legion.change_Legion_Board(1,text,nil);
			end)
		end);

		-- 刷新红点显示
		UILegion.LegionInfo.UpdateRedPointAll()

		UILegion.activity:GO("content.1"):BindButtonClick(function ()
			local content = string.format("用于每日公会签到，可自定义签名内容，最多输入%d个字",client.legion.SignatureLimit/2)
			ui.ShowLegionChangeText("请输入个性签名", content, client.legion.SignatureLimit, client.legion.LegionBaseInfo.Signature, function (text)
				client.legion.change_signature(text,nil);
			end)
		end);
		UILegion.activity:GO("content.1.desc").text = string.format("%s<color=#8ddd10>[编辑签名]</color>", client.legion.LegionBaseInfo.Signature);
		UILegion.activity:GO("content.1.actBtn"):BindButtonClick(function ()
			client.legion.legion_signature(nil);
		end)

		UILegion.activity:GO("content.2.actBtn"):BindButtonClick(function ()
			client.legion.legion_welfare();
		end);

		UILegion.backBtn:BindButtonClick(function ()
			ui.showMsg("公会驻地正在紧张施工中，敬请期待");
		end)
		UILegion.legionlistBtn:BindButtonClick(function()
			client.legion.get_Legion_List(ui.ShowLegionList)
		end)
	end

	local updateredpointfuns = 
		{
			function(flag) 
				if flag == 1 then 
					activesWraps[1]:GO('actBtn').gameObject:SetActive(true);
					activesWraps[1]:GO('finishImg').gameObject:SetActive(false);
				else
					activesWraps[1]:GO('actBtn').gameObject:SetActive(false);
					activesWraps[1]:GO('finishImg').gameObject:SetActive(true);
				end
			end,
			function(flag)
				if flag == -2 then
					activesWraps[2]:GO('actBtn').gameObject:SetActive(false);
					activesWraps[2]:GO('finishImg').gameObject:SetActive(false);
					activesWraps[2]:GO('desc').text = "每周一将根据上周的贡献情况发放公会福利";

				elseif flag == -1 then
					activesWraps[2]:GO('actBtn').gameObject:SetActive(false);
					activesWraps[2]:GO('finishImg').gameObject:SetActive(true);
					activesWraps[2]:GO('desc').text = "每周一将根据上周的贡献情况发放公会福利";

				elseif flag >=0 then
					activesWraps[2]:GO('actBtn').gameObject:SetActive(true);
					activesWraps[2]:GO('finishImg').gameObject:SetActive(false);
					activesWraps[2]:GO('desc').text = "你分得上周的公会分红福利："..client.legion.LegionBaseInfo.CanGetMoney;
				end
			end
		}

	function UILegion.LegionInfo.UpdateRedPoint(type)
		local flag = client.legion.get_redpoint_flag(type)

		if flag ~= nil then
			if updateredpointfuns[type] ~= nil then
				updateredpointfuns[type](flag)
			end
			redPointWraps[type].gameObject:SetActive(flag ~= 0);
		end
	end

	function UILegion.LegionInfo.UpdateRedPointAll()
		for i = 1,#client.legion.RedPoint do
			UILegion.LegionInfo.UpdateRedPoint(i)
		end
	end

	-- 点击问号之后的 悬浮tips，一共有3处，显示内容需要分别定制,可以套用同一背景UI图
	-- flag分3类，prosperity、money、contribution
	function UILegion.LegionInfo.ShowTip(flag)
		UILegion.legionTips.gameObject:SetActive(true);
		UILegion.legionTips:GO('close'):BindButtonClick(function ()
			UILegion.legionTips.gameObject:SetActive(false);
		end);
		local str = nil;
		if flag == "contribution" then
			local levelCost = tb.legionBase[client.legion.LegionBaseInfo.Level].maintaincost;
			str = string.format(textTab.contribution,levelCost);
		elseif flag == "prosperity" then
			local needprosperity = tb.legionBase[client.legion.LegionBaseInfo.Level].needprosperity;
			str = string.format(textTab.prosperity,needprosperity);
		elseif flag == "money" then
			local maxmoney = tb.legionBase[client.legion.LegionBaseInfo.Level].maxmoney;
			str = string.format(textTab.money,maxmoney);
		end
		
		UILegion.legionTips:GO('text').text = str;
	end
	
	-- 显示军团成员，现在有2个滑动列表分页，需要分别初始化，需要默认显示某一页，但是刷新时不能进行统一刷新，否则会使得原本只刷新A，结果默认时切到B，表现会很奇怪
	-- 最好以回调的形式做刷新，传入需要刷新界面的callback
	function UILegion.ShowLegionMember()
		UILegion.ShowPanel(2);
		UILegion.ResetArrow(false);
		table.sort( client.legion.MemberList, UILegion.LegionMember.SortFunc );
		UILegion.LegionMember.InitContent1();
		UILegion.LegionMember.InitContent2();
		UILegion.level1:BindButtonClick(function() UILegion.ClickSortFunc("level1", 1) end);
		UILegion.fightPoint1:BindButtonClick(function() UILegion.ClickSortFunc("fightPoint1", 1) end);
		UILegion.position1:BindButtonClick(function() UILegion.ClickSortFunc("position1", 1) end);
		UILegion.contribution1:BindButtonClick(function() UILegion.ClickSortFunc("contribution1", 1) end);
		UILegion.status1:BindButtonClick(function() UILegion.ClickSortFunc("status1", 1) end);

		UILegion.position2:BindButtonClick(function() UILegion.ClickSortFunc("position2", 2) end)
		UILegion.contribution2:BindButtonClick(function() UILegion.ClickSortFunc("contribution2", 2) end)
		UILegion.task2:BindButtonClick(function() UILegion.ClickSortFunc("task2", 2) end)
		UILegion.camp2:BindButtonClick(function() UILegion.ClickSortFunc("camp2", 2) end)
		UILegion.status2:BindButtonClick(function() UILegion.ClickSortFunc("status2", 2) end)

		UILegion.logBtn:BindButtonClick(client.legion.get_dynamic_info);
		if math.abs(client.legion.LegionBaseInfo.SelfJur[1]) == 1 then 
			UILegion.applyListBtn.gameObject:SetActive(true)
		else
			UILegion.applyListBtn.gameObject:SetActive(false)
		end

		if math.abs(client.legion.LegionBaseInfo.SelfJur[4]) == 1 then 
			UILegion.xuanyanBtn.gameObject:SetActive(true)
		else
			UILegion.xuanyanBtn.gameObject:SetActive(false)
		end
		UILegion.applyListBtn:BindButtonClick(client.legion.get_Applicant_list);
		UILegion.xuanyanBtn:BindButtonClick(function ()
			local content = string.format("招人宣言显示在公会列表，最多输入%d字",client.legion.XuanYanCharacterLimit)
			ui.ShowLegionChangeText("请输入招人宣言", content,client.legion.XuanYanCharacterLimit, client.legion.LegionBaseInfo.Declaration, function (text)
				if math.abs(client.legion.LegionBaseInfo.SelfJur[4]) ~= 1 then
					ui.showMsg("你的权限不足，修改失败");
					return
				end
				client.legion.change_Legion_Board(2,text,nil);
			end)
		end);

		UILegion.exitBtn:BindButtonClick(function ()
			-- 退出公会对应操作,去除会长解散公会功能，允许会长退出公会，会长退会时执行传位，当公会只有一人时退会就会解散公会（修改主要在服务端）
			if client.legion.LegionBaseInfo.SelfPosition == 1 then
				if #client.legion.MemberList == 1 then
					local str = "确定退出公会吗？（作为公会唯一成员，退出公会意味着同时解散公会）"
					ui.showMsgBox("退出公会", str, client.legion.Last_One_Leave_Legion, nil, nil, client.legion.LegionBaseInfo.Id)
				else
					-- 公会职位、历史贡献值、角色等级、离线时间
					table.sort( client.legion.MemberList,function (info1,info2)
						if info1.Position ~= info2.Position then
							return info1.Position < info2.Position
						elseif info1.Contribution ~= info2.Contribution then
							return info1.Contribution < info2.Contribution
						elseif info1.Level ~= info2.Level then
							return info1.Level > info2.Level
						elseif info1.LogOutTime ~= info2.LogOutTime then
							if info1.LogOutTime == 0 or info2.LogOutTime == 0 then
								return info1.LogOutTime < info2.LogOutTime
							else
								return info1.LogOutTime > info2.LogOutTime
							end
						else
							return info1.Id < info2.Id;
						end
					end)
					local targetId;
					for i=1,#client.legion.MemberList do 
						if client.legion.MemberList[i].Id ~= DataCache.roleID then
							targetId = client.legion.MemberList[i].Id;
							break;
						end
					end 
					-- print("下任会长Id："..targetId)
					local str = "确定要退出公会吗？（退出公会只清除历史贡献值，不扣除当前贡献值）"
					ui.showMsgBox("退出公会", str, function ()
						client.legion.Leader_Leave_Legion(targetId)
					end, nil, nil, nil)
				end
			else
				local str = "确定要退出公会吗？（退出公会只清除历史贡献值，不扣除当前贡献值）"
				ui.showMsgBox("退出公会", str, client.legion.Leave_Legion, nil, nil, nil)
			end
		end);
	end

	function UILegion.LegionMember.SortFunc(info1,info2)
		-- 在线成员 > 离线成员；
	  	--   	离线时间短 > 离线时间长；
		  --   	战力高 > 战力低；
		  --   	等级高 > 等级低；
		  --   	会长 > 副会长 > 执法官 > 会员；
		  --   	名字首字母顺序；
		if info1.LogOutTime ~= info2.LogOutTime then
			-- 玩家在线时，LogOutTime为0，玩家离线时LogOutTime为离线那一刻的服务器时间
			if info1.LogOutTime == 0 or info2.LogOutTime == 0 then
				return info1.LogOutTime < info2.LogOutTime;
			else
				return info1.LogOutTime > info2.LogOutTime;
			end
		elseif info1.NowFp ~= info2.NowFp then
			return info1.NowFp > info2.NowFp; 
		elseif info1.Level ~= info2.Level then
			return info1.Level > info2.Level; 
		elseif info1.Position ~= info2.Position then
			return info1.Position < info2.Position; 
		elseif info1.Name ~= info2.Name then
			return info1.Name < info2.Name;
		else 
			return info1.Id < info2.Id;
		end
	end

	function UILegion.ResetArrow(IsShow)
		UILegion.levelImg1.gameObject:SetActive(IsShow);
		UILegion.fightImg1.gameObject:SetActive(IsShow);
		UILegion.conImg1.gameObject:SetActive(IsShow);
		UILegion.posImg1.gameObject:SetActive(IsShow);
		UILegion.staImg1.gameObject:SetActive(IsShow);

		UILegion.posImg2.gameObject:SetActive(IsShow);
		UILegion.conImg2.gameObject:SetActive(IsShow);
		UILegion.taskImg2.gameObject:SetActive(IsShow);
		UILegion.campImg2.gameObject:SetActive(IsShow);
		UILegion.staImg2.gameObject:SetActive(IsShow);	
	end

	function UILegion.ClickSortFunc(key, flag)
		UILegion.ResetArrow(false)
		sortKey = key;
		table.sort(client.legion.MemberList, UILegion.FuncSortByLevel);
		if sortKey == "level1" then
			level1_Flag = 1 - level1_Flag;
			if level1_Flag == 1 then
				UILegion.levelImg1.sprite = "bqy_jiantou_1"
				UILegion.levelImg1.gameObject:SetActive(true);
			else
				UILegion.levelImg1.sprite = "bqy_jiantou_2"
				UILegion.levelImg1.gameObject:SetActive(true);
			end
		end
		if sortKey == "fightPoint1" then
			fightPoint1_Flag = 1 - fightPoint1_Flag
			if fightPoint1_Flag == 1 then
				UILegion.fightImg1.sprite = "bqy_jiantou_1"
				UILegion.fightImg1.gameObject:SetActive(true);
			else
				UILegion.fightImg1.sprite = "bqy_jiantou_2"
				UILegion.fightImg1.gameObject:SetActive(true);
			end
		end
		if sortKey == "contribution1" then
			contribution1_Flag = 1 - contribution1_Flag
			if contribution1_Flag == 1 then
				UILegion.conImg1.sprite = "bqy_jiantou_1"
				UILegion.conImg1.gameObject:SetActive(true);
			else
				UILegion.conImg1.sprite = "bqy_jiantou_2"
				UILegion.conImg1.gameObject:SetActive(true);
			end
		end
		if sortKey == "position1" then
			position1_Flag = 1 - position1_Flag
			if position1_Flag == 1 then
				UILegion.posImg1.sprite = "bqy_jiantou_1"
				UILegion.posImg1.gameObject:SetActive(true);
			else
				UILegion.posImg1.sprite = "bqy_jiantou_2"
				UILegion.posImg1.gameObject:SetActive(true);
			end
		end
		if sortKey == "status1" then
			status1_Flag = 1 - status1_Flag
			if status1_Flag == 1 then
				UILegion.staImg1.sprite = "bqy_jiantou_1"
				UILegion.staImg1.gameObject:SetActive(true);
			else
				UILegion.staImg1.sprite = "bqy_jiantou_2"
				UILegion.staImg1.gameObject:SetActive(true);
			end
		end

		if sortKey == "position2" then
			position2_Flag = 1 - position2_Flag
			if position2_Flag == 1 then
				UILegion.posImg2.sprite = "bqy_jiantou_1"
				UILegion.posImg2.gameObject:SetActive(true);
			else
				UILegion.posImg2.sprite = "bqy_jiantou_2"
				UILegion.posImg2.gameObject:SetActive(true);
			end
		end
		if sortKey == "contribution2" then
			contribution2_Flag = 1 - contribution2_Flag
			if contribution2_Flag == 1 then
				UILegion.conImg2.sprite = "bqy_jiantou_1"
				UILegion.conImg2.gameObject:SetActive(true);
			else
				UILegion.conImg2.sprite = "bqy_jiantou_2"
				UILegion.conImg2.gameObject:SetActive(true);
			end
		end
		if sortKey == "task2" then
			task2_Flag = 1 - task2_Flag
			if task2_Flag == 1 then
				UILegion.taskImg2.sprite = "bqy_jiantou_1"
				UILegion.taskImg2.gameObject:SetActive(true);
			else
				UILegion.taskImg2.sprite = "bqy_jiantou_2"
				UILegion.taskImg2.gameObject:SetActive(true);
			end
		end
		if sortKey == "camp2" then
			camp2_Flag = 1 - camp2_Flag
			if camp2_Flag == 1 then
				UILegion.campImg2.sprite = "bqy_jiantou_1"
				UILegion.campImg2.gameObject:SetActive(true);
			else
				UILegion.campImg2.sprite = "bqy_jiantou_2"
				UILegion.campImg2.gameObject:SetActive(true);
			end
		end
		if sortKey == "status2" then
			status2_Flag = 1 - status2_Flag
			if status2_Flag == 1 then
				UILegion.staImg2.sprite = "bqy_jiantou_1"
				UILegion.staImg2.gameObject:SetActive(true);
			else
				UILegion.staImg2.sprite = "bqy_jiantou_2"
				UILegion.staImg2.gameObject:SetActive(true);
			end
		end
		if flag == 1 then
			UILegion.LegionMember.InitContent1();
		else
			UILegion.LegionMember.InitContent2();
		end
	end

	function UILegion.FuncSortByLevel(info1, info2)
		--分页1
		if sortKey == "level1" then
			if info1.Level ~= info2.Level then
				if level1_Flag == 1 then
					return info1.Level < info2.Level
				else
					return info1.Level > info2.Level
				end
			else
				return info1.Id < info2.Id;
			end
		end
		if sortKey == "fightPoint1" then
			if info1.NowFp ~= info2.NowFp then
				if fightPoint1_Flag == 1 then
					return info1.NowFp < info2.NowFp
				else
					return info1.NowFp > info2.NowFp
				end
			else
				return info1.Id < info2.Id;
			end
		end
		if sortKey == "position1" then
			if info1.Position ~= info2.Position then
				if position1_Flag == 1 then
					return info1.Position > info2.Position
				else
					return info1.Position < info2.Position
				end
			else
				return info1.Id < info2.Id;
			end
		end
		if sortKey == "contribution1" then
			if info1.Contribution ~= info2.Contribution then
				if contribution1_Flag == 1 then
					return info1.Contribution < info2.Contribution
				else
					return info1.Contribution > info2.Contribution
				end
			else
				return info1.Id < info2.Id;
			end
		end
		if sortKey == "status1" then
			if info1.LogOutTime ~= info2.LogOutTime then
				if status1_Flag == 1 then
					if info1.LogOutTime == 0 or info2.LogOutTime == 0 then
						return info1.LogOutTime < info2.LogOutTime
					else
						return info1.LogOutTime > info2.LogOutTime
					end
				else
					if info1.LogOutTime == 0 or info2.LogOutTime == 0 then
						return info1.LogOutTime > info2.LogOutTime
					else
						return info1.LogOutTime < info2.LogOutTime
					end
				end
			else
				return info1.Id < info2.Id;
			end
		end

		-- 分页2
		if sortKey == "position2" then
			if info1.Position ~= info2.Position then
				if position2_Flag == 1 then
					return info1.Position > info2.Position
				else
					return info1.Position < info2.Position
				end
			else
				return info1.Id < info2.Id;
			end
		end
		if sortKey == "contribution2" then
			if info1.Contribution ~= info2.Contribution then
				if contribution2_Flag == 1 then
					return info1.Contribution < info2.Contribution
				else
					return info1.Contribution > info2.Contribution
				end
			else
				return info1.Id < info2.Id;
			end
		end
		if sortKey == "task2" then
			if info1.Task ~= info2.Task then
				if task2_Flag == 1 then
					return info1.Task < info2.Task
				else
					return info1.Task > info2.Task
				end
			else
				return info1.Id < info2.Id;
			end
		end
		if sortKey == "camp2" then
			if info1.Camp ~= info2.Camp then
				if camp2_Flag == 1 then
					return info1.Camp < info2.Camp
				else
					return info1.Camp > info2.Camp
				end
			else
				return info1.Id < info2.Id;
			end
		end
		if sortKey == "status2" then
			if info1.LogOutTime ~= info2.LogOutTime then
				if status1_Flag == 1 then
					if info1.LogOutTime == 0 or info2.LogOutTime == 0 then
						return info1.LogOutTime < info2.LogOutTime
					else
						return info1.LogOutTime > info2.LogOutTime
					end
				else
					if info1.LogOutTime == 0 or info2.LogOutTime == 0 then
						return info1.LogOutTime > info2.LogOutTime
					else
						return info1.LogOutTime < info2.LogOutTime
					end
				end
			else
				return info1.Id < info2.Id;
			end
		end
	end

	function UILegion.LegionMember.InitContent1()
        local memberCount = #client.legion.MemberList;
        local itemPrefab = UILegion.item1.gameObject;
        local warpContent = UILegion.container1:GetComponent("UIWarpContent");
        warpContent.goItemPrefab = itemPrefab;
        warpContent:BindInitializeItem(UILegion.LegionMember.FormatItem1);
        warpContent:Init(memberCount);
	end 

	function UILegion.LegionMember.FormatItem1(go,index)
		local wrapper = go:GetComponent("UIWrapper");
        local memberInfo = client.legion.MemberList[index];

        local colorStr = "e4e4e4";
        local posColorStr = "e4e4e4"

        wrapper:GO('fightPoint.flag').gameObject:SetActive(false);
        -- 自己那一行
        if DataCache.roleID == memberInfo.Id then
        	wrapper:GO('bg').sprite = "dk_ziji"
        	-- if memberInfo.NowFp - memberInfo.YerterdayFP then
	        -- 	wrapper:GO('fightPoint.flag').gameObject:SetActive(true);
	        -- else
	        -- 	wrapper:GO('fightPoint.flag').gameObject:SetActive(false);
	        -- end
        else
        	wrapper:GO('bg').sprite = "dk_tiaomu"
        end

        if memberInfo.LogOutTime > 0 then
        	colorStr = "868686";
        	posColorStr = "868686";
        else
        	posColorStr = const.legionPosColor[memberInfo.Position]
        end
        wrapper:GO('name').text = string.format("<color=#%s>%s</color>",colorStr,memberInfo.Name);
    	wrapper:GO('position').text = string.format("<color=#%s>%s</color>",posColorStr,const.legionPos[memberInfo.Position]);
        wrapper:GO('level').text = string.format("<color=#%s>%d</color>",colorStr,memberInfo.Level);
        wrapper:GO('fightPoint').text = string.format("<color=#%s>%s</color>",colorStr,memberInfo.NowFp);



        wrapper:GO('contribution').text = string.format("<color=#%s>%s</color>",colorStr,memberInfo.Contribution);
        local status = wrapper:GO('status');
        local str;
        if memberInfo.LogOutTime == 0 then 
        	str = "<color=#8ddd10>在线</color>";
        else 
        	str = UILegion.LegionMember.FormatTime(memberInfo.LogOutTime);
        end
        status:GO('guaji').gameObject:SetActive(memberInfo.IsGuaJi);
        status.text = string.format("<color=#%s>%s</color>",colorStr,str);

        wrapper:SetUserData("roleId", memberInfo.Id);
        wrapper:SetUserData("legionPos", memberInfo.Position);
        wrapper:SetUserData("legionName", client.legion.LegionBaseInfo.Name);
        wrapper:SetUserData("career", memberInfo.Career);
        wrapper:SetUserData("sex", memberInfo.Sex);
        wrapper:SetUserData("roleName", memberInfo.Name);

        wrapper:BindButtonClick(UILegion.LegionMember.OnItemClick);
	end

	function UILegion.LegionMember.InitContent2()
        local memberCount = #client.legion.MemberList;
        local itemPrefab = UILegion.item2.gameObject;
        local warpContent = UILegion.container2:GetComponent("UIWarpContent");
        warpContent.goItemPrefab = itemPrefab;
        warpContent:BindInitializeItem(UILegion.LegionMember.FormatItem2);
        warpContent:Init(memberCount);
	end 

	function UILegion.LegionMember.FormatItem2(go,index)
		local wrapper = go:GetComponent("UIWrapper");
        local memberInfo = client.legion.MemberList[index];

        local colorStr = "e4e4e4";
        local posColorStr = "e4e4e4"
        -- 自己那一行
        if DataCache.roleID == memberInfo.Id then
        	wrapper:GO('bg').sprite = "dk_ziji"
        else
        	wrapper:GO('bg').sprite = "dk_tiaomu"
        end

        if memberInfo.LogOutTime > 0 then
        	colorStr = "868686";
        	posColorStr = "868686";
        else
        	posColorStr = const.legionPosColor[memberInfo.Position]
        end
        wrapper:GO('name').text = string.format("<color=#%s>%s</color>",colorStr,memberInfo.Name);
    	wrapper:GO('position').text = string.format("<color=#%s>%s</color>",posColorStr,const.legionPos[memberInfo.Position]);
        wrapper:GO('weekContribution').text = string.format("<color=#%s>%d</color>",colorStr,memberInfo.LastWeekContribution);
        wrapper:GO('task').text = string.format("<color=#%s>%s</color>",colorStr,UILegion.LegionMember.FormatCount(0));
        wrapper:GO('camp').text = string.format("<color=#%s>%s</color>",colorStr,UILegion.LegionMember.FormatCount(0));
        wrapper:GO('time').text = string.format("<color=#%s>%s</color>",colorStr,UILegion.LegionMember.FormatTime(memberInfo.JoinTime));
	
        wrapper:SetUserData("roleId", memberInfo.Id);
        wrapper:SetUserData("legionPos", memberInfo.Position);
        wrapper:SetUserData("legionName", client.legion.LegionBaseInfo.Name);
        wrapper:SetUserData("career", memberInfo.Career);
        wrapper:SetUserData("sex", memberInfo.Sex);
        wrapper:SetUserData("roleName", memberInfo.Name);

        wrapper:BindButtonClick(UILegion.LegionMember.OnItemClick);
	end

    function UILegion.LegionMember.FormatTime(t)
        local now = TimerManager.GetServerNowMillSecond()/1000;
        local intervalTime = now - t;
        local str = "刚刚";
        if intervalTime >= 2592000 then
        	str = string.format("%d月前",math.modf(intervalTime/2592000));
        elseif intervalTime >= 86400 then
            str = string.format("%d天前",math.modf(intervalTime/86400));
        elseif intervalTime > 3600 then
            str = string.format("%d小时前",math.modf(intervalTime/3600));
        elseif intervalTime > 60 then
            str = string.format("%d分钟前",math.modf(intervalTime/60));
        end
        return str;
    end

    function UILegion.LegionMember.FormatCount( t )
    	if t == 0 then
    		return "未参与"
    	else
    		return t.."次"
    	end
    end

    function UILegion.LegionMember.OnItemClick(go)
    	local wrapper = go:GetComponent("UIWrapper");
    	local roleId = wrapper:GetUserData("roleId");
    	local legionPos = wrapper:GetUserData("legionPos");
    	
    	local career = wrapper:GetUserData("career");
    	local sex = wrapper:GetUserData("sex");
    	local roleName = wrapper:GetUserData("roleName");
    	local legionName = wrapper:GetUserData("legionName");


		if roleId ~= DataCache.roleID then
            local btnList = {"sendMsg","roleInfo","addFriend"};

            GetRoleDetail(roleId, function ()
            	local otherInfo = DataCache.otherInfo;
 
				--自己有队伍 必定是邀请
                if client.team.team_uid ~= nil and client.team.team_uid ~= 0 then
                    table.insert(btnList, "inviteTeam");
                --对方有队伍 自己没有队伍 则申请
                elseif otherInfo.team_uid ~=nil and otherInfo.team_uid ~= 0 then
                    table.insert(btnList, "applyTeam");
                --两边都没有队伍 则邀请(自己先组队 然后邀请别人)
                else
                    table.insert(btnList, "inviteTeam");
                end

	            if math.abs(client.legion.LegionBaseInfo.SelfJur[2]) == 1 then -- 任免
	            	table.insert(btnList,"legionPositionAppoint");
	            	client.legion.LegionPositionAppoint = UILegion.LegionMember.LegionPositionAppoint;
	            end
	            if math.abs(client.legion.LegionBaseInfo.SelfJur[3]) == 1 then -- 开除
	            	table.insert(btnList,"legionKickout");
	            end
	            if math.abs(client.legion.LegionBaseInfo.SelfJur[6]) == 1 then -- 传位
	            	table.insert(btnList,"legionChuanWei");
	            end
            	ui.ShowOperateFloat(otherInfo, btnList, const.operateFloatPos.chat, this,nil);
            end);
        end
    end

    function UILegion.LegionMember.LegionPositionAppoint(roleInfo)
    	local appointPanel = UILegion.appoint;
    	local choicePanel = appointPanel:GO('content.choice');
    	appointPanel.gameObject:SetActive(true);
    	appointPanel:GO('content.close'):BindButtonClick(function ()
    		appointPanel.gameObject:SetActive(false);
    	end);
    	appointPanel:GO('content.name').text = string.format("给%s设置职位",roleInfo.name);
    	-- 初始时默认选中对方原本职位对应的选项
    	local curChoose = roleInfo.legion_position - 1;

    	for i=1,3 do
			if i == curChoose then
    			choicePanel:GO(i..'.choose').gameObject:SetActive(true);
			else
				choicePanel:GO(i..'.choose').gameObject:SetActive(false);
			end
			choicePanel:GO(''..i):BindButtonClick(function ()
				-- 选中第i项时 将默认选中选中框取消
				choicePanel:GO(i..'.choose').gameObject:SetActive(true);	
				choicePanel:GO(curChoose..'.choose').gameObject:SetActive(false);
				curChoose = i;
			end)
    	end

    	appointPanel:GO('content.btn'):BindButtonClick(function ()
    		client.legion.legion_Position_Appointed(roleInfo.role_uid, curChoose + 1)
    		UILegion.LegionMember.CloseLegionPositionAppoint ()
    	end);
    end

    function UILegion.LegionMember.CloseLegionPositionAppoint ()
    	UILegion.appoint.gameObject:SetActive(false);
    end

	function UILegion.ShowLegionShop()
		UILegion.ShowPanel(3); 
		UILegion.LegionShop.InitContent();
		UILegion.LegionShop.InitItemInfo();
	end

	function UILegion.LegionShop.InitContent()
        local shopItemCount = #client.legion.ShopList;
        local warpContent = UILegion.shopContainer:GetComponent("UIWarpContent");
        local itemPrefab = UILegion.shopItem.gameObject;
        warpContent.goItemPrefab = itemPrefab;
        warpContent:BindInitializeItem(UILegion.LegionShop.FormatItem);
        warpContent:Init(shopItemCount);
	end 

	function UILegion.LegionShop.FormatItem(go,index)
		local wrapper = go:GetComponent("UIWrapper");
		local shopItem = client.legion.ShopList[index]; -- 存储物品Id和购买次数Count
		local shopCfg = tb.legionshop[shopItem.Id]; -- 存储公会商店客户端导表
		local availCount = shopCfg.exchangetimes - shopItem.Count;
		
        -- Slot、Name、Price、count、lock
		local item = UILegion.LegionShop.genItem(shopItem.Id,1); -- 目前 物品一次兑换一个
		local itemCfg = tb.ItemTable[item.sid] or tb.GemTable[item.sid];
		local slotGo = wrapper:GO('BagItem');
		local slotCtrl  = CreateSlot(slotGo.gameObject);
		slotCtrl.reset();
		UILegion.LegionShop.setItemSlot(item, slotCtrl);
		slotGo:GetComponent("UIWrapper"):BindButtonClick(function ()
			-- 根据物品类型,判断是调用物品悬浮还是宝石悬浮
			if tb.ItemTable[item.sid] then
				local param = {bDisplay = true, sid = item.sid, base = item};		
				PanelManager:CreateConstPanel('ItemFloat',UIExtendType.BLACKCANCELMASK,param);
			elseif tb.GemTable[item.sid] then
				ui.ShowGemFloat(item, true , item.count);
			end
		end);
		-- 获取玩家 公会贡献度 , 公会等级
		-- local legionLevel = client.legion.LegionBaseInfo.Level;
		local legionContribution = DataCache.contribution;

		local colorStr;
		if legionContribution < shopCfg.cost then 
			colorStr  = '#E82424';
		else
			colorStr  = '#E4E4E4';
		end
		wrapper:GO('Name').text = string.format("<color=%s>%s</color>",const.qualityColor[ itemCfg.quality + 1],shopCfg.name); 
		wrapper:GO('Price').text = string.format("<color=%s>%s</color>",colorStr,shopCfg.cost);
		wrapper:GO('selected').gameObject:SetActive(index == shopCurchoose)
		-- local countGo = wrapper:GO('count');
		-- local lockGo = wrapper:GO('lock');
		-- if legionLevel >= shopCfg.needlegionlevel then
		-- 	if availCount <= 0 then 
		-- 		colorStr  = '#E82424';
		-- 	else
		-- 		colorStr  = '#E4E4E4';
		-- 	end
		-- 	countGo.text = string.format("可兑换：<color=%s>%s</color>",colorStr,availCount);
		-- 	countGo.gameObject:SetActive(true);
		-- 	lockGo.gameObject:SetActive(false);
		-- else
		-- 	countGo.gameObject:SetActive(false);
		-- 	lockGo.text = shopCfg.needlegionlevel.."级公会解锁";
		-- 	lockGo.gameObject:SetActive(true);
		-- end

		wrapper:SetUserData("index", index);
		wrapper:BindButtonClick(function (go)
			-- if legionLevel < shopCfg.needlegionlevel then
			-- 	ui.showMsg('公会达到'..shopCfg.needlegionlevel..'级后才可以兑换此物品');
   --          elseif availCount <= 0 then
   --          	ui.showMsg('今天可兑换的次数已达上限');
   --          elseif legionContribution < shopCfg.cost then
   --          	ui.showMsg('您的公会贡献值不足，无法购买');
   --          else
			-- 	local buyItem = {item = item ,name = shopCfg.name, price = shopCfg.cost};
			-- 	UILegion.LegionShop.ShowBuyItemPanel(buyItem,shopCfg.exchangetimes,availCount,legionContribution,go);
   --          end
   			local wrap = go:GetComponent('UIWrapper');
   			shopCurchoose = wrap:GetUserData("index");
   			UILegion.LegionShop.InitItemInfo();
   			-- 选中现在选择的，去除原本选中的
   			UILegion.shopContainer:GetComponent("UIWarpContent"):Refresh(#client.legion.ShopList)
		end);
	end

	-- function UILegion.LegionShop.ShowBuyItemPanel(buyItem,exchangetimes,availCount,legionContribution,go)
	-- 	legionShopPanel:GO('Buy').gameObject:SetActive(true);
	-- 	local item = buyItem.item;
	-- 	local slotCtrl  = CreateSlot(legionShopPanel:GO('Buy.BagItem').gameObject);
	-- 	slotCtrl.reset();
	-- 	UILegion.LegionShop.setItemSlot(item, slotCtrl);
	-- 	legionShopPanel:GO('Buy.Name').text = buyItem.name;

	-- 	--设置
	-- 	local count = item.count; 
	-- 	legionShopPanel:GO('Buy.Num.Text').text = 1;
	-- 	legionShopPanel:GO('Buy.Total.Text').text = buyItem.price;

	-- 	-- 点击购买按钮
	-- 	legionShopPanel:GO('Buy.BtnBuy'):BindButtonClick(function ()
	-- 		local dealCount = tonumber(legionShopPanel:GO('Buy.Num.Text').text);

	-- 		if availCount < dealCount then
	-- 			ui.showMsg('兑换次数不足');
	-- 		elseif legionContribution < dealCount * buyItem.price then
	-- 			ui.showMsg('贡献值不足，无法购买');
	-- 		else
	-- 			client.legion.buy_Shop_Item(item.sid,dealCount,function ()
	-- 				legionShopPanel:GO('Buy').gameObject:SetActive(false);
	-- 				UILegion.LegionShop.InitContent(); -- 购买成功之后刷新界面
	-- 			end);
	-- 		end
	-- 	end);

	-- 	-- 购买界面点击+.-或者使用小键盘输入时
	-- 	BindNumberChange(legionShopPanel:GO('Buy.Num'), 1, availCount, function ()
	-- 		local totalPrice = buyItem.price * tonumber(legionShopPanel:GO('Buy.Num.Text').text);
	-- 		local legionContribution = DataCache.contribution;
	-- 		local colorStr;
	-- 		if legionContribution < totalPrice then 
	-- 			colorStr  = '#E82424';
	-- 		else
	-- 			colorStr  = '#E4E4E4';
	-- 		end
	-- 		legionShopPanel:GO('Buy.Total.Text').text = string.format("<color=%s>%s</color>",colorStr,totalPrice);
	-- 	end);

	-- 	-- 点击关闭按钮
	-- 	legionShopPanel:GO('Buy.close'):BindButtonClick(function ()
	-- 		legionShopPanel:GO('Buy').gameObject:SetActive(false);
	-- 	end);
	-- end

	function UILegion.LegionShop.InitItemInfo()
		local shopItem = client.legion.ShopList[shopCurchoose]; -- 存储物品Id和购买次数Count
		local shopCfg = tb.legionshop[shopItem.Id]; -- 存储公会商店客户端导表
		local availCount = shopCfg.exchangetimes - shopItem.Count;
		local itemCfg = tb.ItemTable[shopItem.Id] or tb.GemTable[shopItem.Id]

		local gemEffect = nil;
		if tb.ItemTable[shopItem.Id] == nil then
			local buwei = tb.GemEquipTable[tb.GemTable[shopItem.Id].gem_type];
			gemEffect = string.format("3颗相同宝石可以合成一个同类型的高级宝石，可镶嵌在%s上", const.BuWei[buwei]);
		end

		UILegion.shopTips.gameObject:SetActive(true);
		UILegion.shopBuyBtn.gameObject:SetActive(true);

		UILegion.itemName.text = shopCfg.name;
		UILegion.itemInfo.text = itemCfg.use_effect or gemEffect;
		UILegion.itemCount.text = "还可购买："..availCount.."个";
		UILegion.totalCon.text = DataCache.contribution;
		
		local maxBuyCount = math.min( availCount, math.floor(DataCache.contribution/shopCfg.cost) )
		if shopCfg.needlegioncontribution > client.legion.LegionBaseInfo.HistoryContribution then
			maxBuyCount = 0;
		end
		UILegion.shopTips.gameObject:SetActive(true);
		UILegion.shopBuyBtn.gameObject:SetActive(false);
		UILegion.Buy:GO('Num.Text').text = 0;

		if shopCfg.cost > DataCache.contribution then
			UILegion.costCon.text = string.format("<color=#E82424>%s</color>",shopCfg.cost);
		else
			UILegion.costCon.text = shopCfg.cost;
		end

		if maxBuyCount > 0 then
			UILegion.shopTips.gameObject:SetActive(false);
			UILegion.shopBuyBtn.gameObject:SetActive(true);
			UILegion.Buy:GO('Num.Text').text = 1;
		elseif availCount == 0 then 
			UILegion.shopTips.text = "余量：0"
		elseif shopCfg.needlegioncontribution > client.legion.LegionBaseInfo.HistoryContribution then
			UILegion.shopTips.text = string.format("历史公会贡献值%s可购\n 当前历史公会贡献值:%s", shopCfg.needlegioncontribution, client.legion.LegionBaseInfo.HistoryContribution);
		else
			UILegion.shopTips.gameObject:SetActive(false);
			UILegion.shopBuyBtn.gameObject:SetActive(true);
		end

		-- 点击购买按钮
		UILegion.shopBuyBtn:BindButtonClick(function ()
			local dealCount = tonumber(UILegion.Buy:GO('Num.Text').text);
			if dealCount == 0 then
				ui.showMsg('贡献值不足，无法购买');
			elseif availCount < dealCount then
				ui.showMsg('兑换次数不足');
			elseif DataCache.contribution  < dealCount * shopCfg.cost then
				ui.showMsg('贡献值不足，无法购买');
			else
				if shopCfg.needlegioncontribution <= client.legion.LegionBaseInfo.HistoryContribution then
					client.legion.buy_Shop_Item(shopItem.Id,dealCount,function ()
						UILegion.shopContainer:GetComponent("UIWarpContent"):Refresh(#client.legion.ShopList)
						UILegion.LegionShop.InitItemInfo();
					end);
				else
					ui.showMsg("历史贡献值不足");
				end
			end
		end);

		-- 购买界面点击+.-或者使用小键盘输入时
		BindNumberChange(UILegion.Buy:GO('Num'), 1, maxBuyCount, function ()
			if tonumber(UILegion.Buy:GO('Num.Text').text) == 0 then
				return
			end
			local totalPrice = shopCfg.cost * tonumber(UILegion.Buy:GO('Num.Text').text);
			local legionContribution = DataCache.contribution;
			local colorStr;
			if legionContribution < totalPrice then 
				colorStr  = '#E82424';
			else
				colorStr  = '#E4E4E4';
			end
			UILegion.costCon.text = string.format("<color=%s>%s</color>",colorStr,totalPrice);
		end);

		-- 数量设为最大
		UILegion.maxBtn:BindButtonClick(function ()
			if maxBuyCount == 0 then
				return 
			end

			UILegion.Buy:GO('Num.Text').text = maxBuyCount;
			local totalPrice = shopCfg.cost * maxBuyCount;
			local legionContribution = DataCache.contribution;
			local colorStr;
			if legionContribution < totalPrice then 
				colorStr  = '#E82424';
			else
				colorStr  = '#E4E4E4';
			end
			UILegion.costCon.text = string.format("<color=%s>%s</color>",colorStr,totalPrice);
		end)
	end

	-- 生成个item给slotctrl使用
	function UILegion.LegionShop.genItem(sid,count)
		local item = {};
		if tb.ItemTable[sid] then
			item.type = const.bagType.item;
			item.quality = tb.ItemTable[sid].quality;
		elseif tb.GemTable[sid] then
			item.type = const.bagType.gem;
			item.quality = tb.GemTable[sid].quality;
		end
		item.sid = sid;
		item.count = count;
		return item;
	end
	-- slot显示
	function UILegion.LegionShop.setItemSlot(item, slotCtrl)
        slotCtrl.setItem(item);
	end

	function UILegion.ShowPanel(index)
		UILegion.legionInfo.gameObject:SetActive(index == 1);
		UILegion.legionMember.gameObject:SetActive(index == 2);
		UILegion.legionShop.gameObject:SetActive(index == 3);
		client.legion.CurrShowPanel = index
	end

	function UILegion.Close()
	 	destroy(this.gameObject);
	 	client.legion.update_redpoint_listener = nil
	end 

	return UILegion;
end

function ShowLegion()
    if DataCache.myInfo.level < 30 then
        ui.showMsg("30级解锁公会系统，努力升级吧！");
    else
        if client.newSystemOpen.isSystemOpen("legion") then
            client.newSystemOpen.onGuideComplete("legion");
        end
        client.legion.legion_buttonclick();
    end 
 end