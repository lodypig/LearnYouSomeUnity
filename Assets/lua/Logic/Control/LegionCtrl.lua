function  CreateLegionCtrl()
	local Legion = {};
	Legion.LegionList = {}; --公会列表,公会申请界面使用
	Legion.LegionBaseInfo = {};-- 所在公会基本信息，主要用于公会主页显示
	Legion.MemberList = {};--成员列表,用于显示
	Legion.RedPacketList = {};--红包列表
	Legion.ApplicantList = {};--申请列表\
	Legion.ShopList = {};--商店列表
	Legion.DynamicList = {}; --动态
	Legion.LegionJurList = {}--权限
	Legion.CurrShowPanel = 1 --当前显示的面板
	Legion.NameCharacterLimit = 12  --公会名字字数限制
	Legion.NameCharacterMinLimit = 4 --公会名字最小字符限制
	Legion.SignatureLimit = 32 --个性签名字数限制
	Legion.XuanYanCharacterLimit = 128 --公会宣言、公告字数限制

	Legion.LegionPositionAppoint = nil; --交互菜单权限任免操作
	Legion.LegionInvitationList = {}; -- 记录收到的公会邀请，每一条记录邀请者roleid,rolename,legionname

	Legion.UpdateLegionMemberFlag = false

	--红点
	Legion.RedPoint = 
	{
		0,
		0,
		0,
		0,
		0,
		0,
		0,
		0,
		0
	}
	--类型
	Legion.RedPointType = 
	{
		qiandao = 1;
		fuli = 2;
		wanyan = 3;
		shoulie = 4;
		lingtuzhan = 5;
		zhuye = 6;
		chengyuan = 7;
		shangdian = 8;
		applylist = 9;
	}

	Legion.update_redpoint_listener = nil
	function Legion.set_redpoint_flag(type,v)  --type : Legion.RedPointType
		if v > 1 then
			Legion.RedPoint[type] = 1
		else
			Legion.RedPoint[type] = v
		end
		if Legion.update_redpoint_listener ~= nil then
			Legion.update_redpoint_listener(type)
		end
		if MainUI.showRedPoint then
			MainUI.showRedPoint()
		end
		if UIManager.GetInstance():FindUI("UIMenu") ~= nil then
			UIManager.GetInstance():CallLuaMethod('UIMenu.showRedPoint')
		end
	end
	
	function Legion.get_redpoint_flag(type)
		return Legion.RedPoint[type]
	end

	--外部查看公会内部有没有新信息
	function Legion.is_legion_have_new_info()
		for i = 1,#Legion.RedPoint do
			if Legion.RedPoint[i] == 1 then
				return true
			end
		end
		return false
	end

	--检查有没有申请标记
	function Legion.is_have_apply_flag()
		return Legion.get_redpoint_flag(Legion.RedPointType.applylist) == 1
	end


	local Msg_Error = 
	{
		--common	
		["err_not_show"] = "",
		["legion_have_dismissed"] = "该公会已解散",
		["role_level_limit"] = "30级解锁公会系统，努力升级吧！",
		["you_not_in_legion"] = "	你没有在公会中",
		["you_already_in_legion"] = "您已经在公会中了",
		["you_not_have_jurisdiction"] = "您的权限不足，无法执行此操作",
		["not_in_samelegion"] = "你们没有在同一个公会中，无法操作",
		["legion_state_predismiss"] = "公会处于预备解散状态，无法执行此操作",

			--创建
		["create_diamond_not_enough"] = "创建失败，创建公会需要花费988个钻石",
		["name_illagel_char"] = "您输入的公会名字含有非法字符，请重新输入",
		["name_too_long"] = "公会名称的长度不得超过12个字符，请重新输入",
		["name_too_short"] = "公会名称的长度不得少于4个字符，请重新输入",
		["name_rename"] = "	您输入的公会名字已存在，请重新输入",
		
			--申请加入
		["legion_member_full"] = "公会人数已满",
		["you_already_in_applylist"] = "你已经提交过申请，请耐心等待审批",

			--批准加入
		["the_role_already_in_legion"] = "该玩家已加入公会，操作失败",
		["not_in_applylist"] = "该玩家没有在申请列表中",

			--邀请
		["sender_not_have_jurisdiction"] = "邀请者没有该权限",
		["sender_not_have_legion"] = "邀请者没有在公会中",
		["invited_role_level_limit"] = "被邀请者角色等级过低",
		["you_have_send_invited"] = "你已经邀请过对方，请耐心等待",

			--解散
		["cancel_dismiss_time_limit"] = "解散失败，跟离上次取消解散不足3天",
		["already_predismiss"] = "公会已经处于解散状态",

			--修改公告
		["board_illagel_char"] = "您输入的内容含有非法字符，请重新输入",
		["board_too_long"] = "内容长度不得超过40个字符，请重新输入",
		["board_too_short"] = "内容长度不得少于4个字符，请重新输入",

			--升级
		["legion_max_level"] = "公会已满级,无法继续升级",
		["legion_construction_not_enough"] = "公会建设度不足，暂时无法升级",

			--捐献
		["con_money_not_enough"] = "金币不足,无法进行捐献",
		["con_diamond_not_enough"] = "钻石不足,无法进行捐献",
		["contribute_today_done"] = "今天已经捐献过了，明天再来吧",
		["contribute_type_not_exist"] = "捐献类型不存在",

		-- 签到
		["signature_today_done"] = "今天已经签过了，明天再来吧",

		
			--任免		
		["renmian_not_have_jurisdiction"] = "您的权限不足，无法进行任免操作",	
		["appoint_higher_pos_limit"] = "您的权限不足以任免对方",
		["position_not_change"] = "职位为改变",
		["position_not_exist"] = "职位不存在",
		["the_postion_member_full"] = "该职位成员人数已满，无法任免",

			--踢出
		["kickout_higher_pos_limit"] = "您的权限不足以将对方逐出公会",

			--更改权限
		["change_jur_arg_error"] = "参数错误",
		["change_jur_cannot_change"] = "该权限无法被修改",

			--商店
		["shop_item_not_exist"] = "该物品不存在",
		["shop_legion_level_low"] = "公会等级过低，无法购买",
		["you_contribution_not_enough"] = "你的公会贡献度不足",
		["shop_exchange_time_limit"] = "该物品购买次数已达上限",
		["bag_not_enough"] = "包裹空间不足",
		["buyitem_leavelegion_timelimit"] = "更换新公会当天无法使用公会商店",

		--红包
		["packet_not_send"] = "红包未发送",
		["packet_not_exist"] = "红包不存在",
		["packet_num_error"] = "红包发送数量有误",
		["packet_already_send"] = "红包已经发送了",
		["packet_not_yours"] = "这个红包不是你的吧",
	}



	function Legion.legion_Tip_Msg(Msg)
		local str = ""
		if Msg.type == "apply_join" then   --申请加入通知
			local info = {}
			info.Id = Msg.args[1]
			info.Name = client.tools.ensureString(Msg.args[2])
			info.Level = Msg.args[3]
			info.FightAbility = Msg.args[4]
			info.ApplyTime = Msg.args[5]
			info.Career = Msg.args[6]
			Legion.ApplicantList[#Legion.ApplicantList+1] = info
			if UIManager.GetInstance():FindUI('UILegionApplyList') ~= nil then
				UIManager.GetInstance():CallLuaMethod('UILegionApplyList.InitContent')
			else 
				Legion.set_redpoint_flag(Legion.RedPointType.applylist,1)
				if UIManager.GetInstance():FindUI('UILegionApplyList') == nil then
					Legion.set_redpoint_flag(Legion.RedPointType.chengyuan,1)		
				end
			end			
		elseif Msg.type == "congratulate_join" then --	加入成功
			client.legion.close_JoinAndCreatePanel()
			local legionName = client.tools.ensureString(Msg.args[1]);
			ui.showMsg("恭喜您加入了"..legionName)
			Legion.LegionInvitationList = {}; -- 申请被某一公会同意，本地存储的邀请列表清空
    		-- MainUI.CheckLegionInviteTip();
    		-- MainUI.CloseQuickOperateBySystem("legion"); -- 关闭队伍区还有的公会邀请

    		-- 如果开着角色信息界面，需要刷新公会信息
    		if UIManager.GetInstance():FindUI('UIRole') ~= nil then
				UIManager.GetInstance():CallLuaMethod('PanelAttr.showLegionName')
			end 

		elseif Msg.type == "refuse_apply" then --申请被拒绝
			local legionName = client.tools.ensureString(Msg.args[1]);
			ui.showMsg(legionName.."拒绝了你的入会申请")
		elseif Msg.type == "the_role_already_in_legion" then
			ui.showMsg("该玩家已在公会中")
			Legion.remove_by_id(Legion.ApplicantList,Msg.args[1])
			if UIManager.GetInstance():FindUI("UILegionApplyList") ~= nil then
				UIManager.GetInstance():CallLuaMethod("UILegionApplyList.InitContent")
			end
		elseif Msg.type == "invite_join" then --邀请加入
			local roleid = Msg.args[1]
			local rolename = client.tools.ensureString(Msg.args[2])
			local legionname = client.tools.ensureString(Msg.args[3])

			local invitationNum = #Legion.LegionInvitationList;
			local isOperated = false

			-- MainUI.ShowQuickOperate(string.format("<color=#e09f41>%s</color>邀请你加入<color=#e09f41>%s</color>",rolename, legionname),
			-- 		function() -- 点击确定,同意邀请,邀请列表中删除最后一项
			-- 			Legion.Agree_Invited(roleid);
			-- 			isOperated = true
			-- 			-- table.remove(Legion.LegionInvitationList,#Legion.LegionInvitationList)
			-- 		end,			 
			-- 		function() -- 点击取消，拒绝邀请，邀请列表中删除最后一项
			-- 			ui.showMsg("你拒绝加入"..legionname)
			-- 			Legion.Refuse_Invited(roleid);
			-- 			isOperated = true
			-- 			-- table.remove(Legion.LegionInvitationList,#Legion.LegionInvitationList)
			-- 		end,		 	
			-- 		function() -- delayFunc
			-- 			-- 每次收到一个邀请，记录下邀请者的id,公会name,邀请者的name,放在邀请列表最后
			-- 			if not isOperated and not client.role.haveClan() then   -- 延迟10秒的期间如果玩家没有加入公会，将这一条邀请加入邀请列表
			-- 				Legion.LegionInvitationList[invitationNum + 1] = {roleid = roleid, legionname = legionname, rolename = rolename}; 
			-- 			end
			-- 			MainUI.CheckLegionInviteTip(); 
			-- 		end,
			-- 		"legion"
			-- 	);

			Legion.LegionInvitationList[#Legion.LegionInvitationList + 1] = {roleid = roleid, legionname = legionname, rolename = rolename}; 		

			if #Legion.LegionInvitationList == 1 then
				local legionInfo = client.legion.LegionInvitationList[1];
	            local text = string.format("%s邀请你加入%s",legionInfo.rolename, legionInfo.legionname);
	            ui.showMsgBox("公会邀请",text,client.legion.Agree_Invited,client.legion.Refuse_Invited,nil,legionInfo.roleid);
			end

		elseif Msg.type == "invite_join_success" then
			local rolename = client.tools.ensureString(Msg.args[1])
			ui.showMsg(rolename.."接受了您的邀请，加入了公会")
		elseif Msg.type == "refuse_invite" then
			local rolename = client.tools.ensureString(Msg.args[1])
			ui.showMsg(rolename.."拒绝了你的公会邀请")
		elseif Msg.type == "leave_legion"  then --退出公会
			local rolename = client.tools.ensureString(Msg.args[1])
			for i=1,#Legion.MemberList do
				if Legion.MemberList[i].Name == rolename then
					table.remove(Legion.MemberList,i);
					break;
				end
			end
			Legion.updatePanel(2,false)
			Legion.UpdateLegionMemberFlag = true
		elseif Msg.type == "leader_leave_legion"  then -- 会长退出公会，新人接任
			local rolename = client.tools.ensureString(Msg.args[1])
			local targetname = client.tools.ensureString(Msg.args[2])
			
			for i=1,#Legion.MemberList do
				if Legion.MemberList[i].Name == rolename then
					table.remove(Legion.MemberList,i);
					break;
				end
			end
			for i=1,#Legion.MemberList do
				if Legion.MemberList[i].Name == targetname then
					Legion.MemberList[i].Position = 1;
					break;
				end
			end

			if targetname == DataCache.myInfo.name then
				local str = string.format("%s退出公会，恭喜你已成为新任会长！",rolename)
				ui.showMsg(str)
				Legion.ParseSelfJurFromClientCfg(tb.legionjurisdiction[1])
			end
			Legion.updatePanel(2,false)
			Legion.UpdateLegionMemberFlag = true

		elseif Msg.type == "activedismiss" then --公会长解散公会
			ui.showMsg("操作成功，公会将在72小时后正式解散")
			Legion.LegionBaseInfo.ActiveState = 3
			Legion.LegionBaseInfo.ActiveDismissTime = Msg.args[1]
			Legion.updatePanel(1,false)
		elseif Msg.type == "activecanceldismiss" then --公会长取消解散
			Legion.LegionBaseInfo.ActiveState = 1
		elseif Msg.type == "dismiss" then --解散了
			Legion.onClearLegionInfo()
			-- client.chat.clientSystemMsg("您所在的公会已解散。", nil,nil,"clan", false)
		elseif Msg.type == "legionconstruction" then --捐献
			Legion.LegionBaseInfo.Construction = Legion.LegionBaseInfo.Construction + Msg.args[4]
			Legion.updatePanel(1,false)
		
		elseif Msg.type == "legionsignature" then --签到
			local rolename = client.tools.ensureString(Msg.args[1])
			local signature = client.tools.ensureString(Msg.args[2])
			Legion.LegionBaseInfo.Money = Msg.args[3]
			Legion.LegionBaseInfo.Construction = Msg.args[4]
			Legion.LegionBaseInfo.HistoryContribution = Msg.args[5]
			Legion.updatePanel(1,false)



		elseif Msg.type == "positionchange" then --任免
			local rolename = client.tools.ensureString(Msg.args[1])
			local targetname = client.tools.ensureString(Msg.args[2])
			local newpos = Msg.args[3]
			local oldpos = Msg.args[4]
		elseif Msg.type == "selfpositionchange" then --自己权限改变了
			Legion.LegionBaseInfo.SelfPosition = Msg.args[1]
			Legion.ParseSelfJur(Msg.args[2])
			for i=1,#Legion.MemberList do
				if Legion.MemberList[i].Id == DataCache.roleID then
					Legion.MemberList[i].Position = Msg.args[1];
				end
			end
			ui.showMsg("您的公会权限改变了")
			Legion.updatePanel(2,false);
			Legion.UpdateLegionMemberFlag = true
		elseif Msg.type == "selfjurchange" then
			client.legion.ParseSelfJur(Msg.args[1])
			Legion.updatePanel(1,false)
		elseif Msg.type == "jurdefult" then
			for i=1,#tb.legionjurisdiction do
        		Legion.LegionJurList[i] = {};
        		for j=1,#tb.legionjurisdiction[i] do
        			Legion.LegionJurList[i][j] = tb.legionjurisdiction[i][j];
        		end
        	end
		elseif Msg.type == "kickout" then --踢出
			local rolename = client.tools.ensureString(Msg.args[1])
			local targetname = client.tools.ensureString(Msg.args[2])

			if targetname == DataCache.myInfo.name then
				Legion.onClearLegionInfo()
				str = string.format("你被%s逐出了公会",rolename)
				ui.showMsg(str)

				-- 如果开着角色信息界面，需要刷新公会信息
	    		if UIManager.GetInstance():FindUI('UIRole') ~= nil then
					UIManager.GetInstance():CallLuaMethod('PanelAttr.showLegionName')
				end

			elseif rolename ==  DataCache.myInfo.name then
				str = string.format("已将%s逐出公会",targetname)
				ui.showMsg(str)
			end			
		elseif Msg.type == "chuanwei_target_time_limit" then
			local rolename = client.tools.ensureString(Msg.args[1])
			ui.showMsg(rolename.."进入公会不足24小时，无法接受此重任")
		elseif Msg.type == "chuanwei_target_contribution_limit" then
			local rolename = client.tools.ensureString(Msg.args[1])
			ui.showMsg(rolename.."历史贡献值太低，无法接受此重任")
		elseif Msg.type == "chuanwei_success" then
			local rolename = client.tools.ensureString(Msg.args[1])
			local targetname = client.tools.ensureString(Msg.args[2])
			
			if targetname == DataCache.myInfo.name then
				str = string.format("%s传位给你，恭喜你已成为新任会长！",rolename)
				ui.showMsg(str)
				Legion.ParseSelfJurFromClientCfg(tb.legionjurisdiction[1])
			end
			if rolename == DataCache.myInfo.name then
				str = "你已成功传位予"..targetname
				ui.showMsg(str)
				Legion.ParseSelfJurFromClientCfg(tb.legionjurisdiction[4])
			end
			for i=1,#Legion.MemberList do
				if Legion.MemberList[i].Name == targetname then
					Legion.MemberList[i].Position = 1;
				elseif Legion.MemberList[i].Name == rolename then
					Legion.MemberList[i].Position = 4;
				end
			end
			Legion.updatePanel(2,false);
			Legion.UpdateLegionMemberFlag = true
		elseif Msg.type == "auto_chuanwei" then
			local rolename = client.tools.ensureString(Msg.args[1])
			local targetname = client.tools.ensureString(Msg.args[2])
			if targetname == DataCache.myInfo.name then
				Legion.ParseSelfJurFromClientCfg(tb.legionjurisdiction[1])
			end
			if rolename == DataCache.myInfo.name then
				Legion.ParseSelfJurFromClientCfg(tb.legionjurisdiction[4])
			end
			for i=1,#Legion.MemberList do
				if Legion.MemberList[i].Name == targetname then
					Legion.MemberList[i].Position = 1;
				elseif Legion.MemberList[i].Name == rolename then
					Legion.MemberList[i].Position = 4;
				end
			end
			Legion.updatePanel(2,false);
			Legion.UpdateLegionMemberFlag = true

		elseif Msg.type == "redpacket_over" then
			
		elseif Msg.type == "redpacket_overdue" then
				
		elseif Msg.type == "normal" then
			
		elseif Msg.type == "predownlevel" then	
			
		elseif Msg.type == "downlevel" then
			
		elseif Msg.type == "maintaindismiss" then
			
		elseif Msg.type == "memberjoinin" then
			
		elseif Msg.type == "boardchange" then 
			local str = client.tools.ensureString(Msg.args[2])
			if Msg.args[1] == 1 then
				Legion.LegionBaseInfo.Announcement = str
			else 
				Legion.LegionBaseInfo.Declaration = str
			end
			Legion.updatePanel(1,false)
		elseif Msg.type == "levelup" then
			Legion.LegionBaseInfo.Level = Msg.args[1]
			Legion.LegionBaseInfo.Construction = Msg.args[2]
			if Msg.args[3] == DataCache.roleID then
				ui.showMsg(string.format("恭喜您成功将公会升级到%d级！",Legion.LegionBaseInfo.Level))
			end
			
			Legion.updatePanel(1,false)
		elseif Msg.type == "join_legion_dismissed" then
			Legion.remove_by_id(Legion.LegionList,Msg.args[1])
			ui.showMsg("目标公会已解散，无法加入")
			if UIManager.GetInstance():FindUI("UIJoinLegion") ~= nil then
				UIManager.GetInstance():CallLuaMethod("UIJoinLegion.InitContent")
			end
		end
	end
	SetPort("legion_tip_msg",Legion.legion_Tip_Msg)

	local function IsErrorMsg(Msg)
		if Msg_Error[Msg.error] ~= nil then
			if Msg_Error[Msg.error] ~= "" then
				ui.showMsg(Msg_Error[Msg.error])
			end
			return true
		end
		return false
	end

	--公会解散或者退出或者被踢出后做的清理工作
	function Legion.onClearLegionInfo()
		Legion.LegionBaseInfo = {}
		if UIManager.GetInstance():FindUI('UILegion') ~= nil then
			UIManager.GetInstance():CallLuaMethod('UILegion.Close');
		end
		if UIManager.GetInstance():FindUI('UILegionHongBao') ~= nil then
			UIManager.GetInstance():CallLuaMethod('UILegionHongBao.Close');
		end
		if UIManager.GetInstance():FindUI('UILegionApplyList') ~= nil then
			UIManager.GetInstance():CallLuaMethod('UILegionApplyList.Close');
		end

		MainUI.HideHongBaoIcon()
		for k,v in pairs(Legion.RedPointType) do
			Legion.set_redpoint_flag(v,0)
		end
		client.chat.chatContentList["clan"] = {};
	end

	function Legion.is_Legion_Panel_Open()
		return UIManager.GetInstance():FindUI('UILegion') ~= nil
	end

---------------------------公会按钮响应--------------------------------
	function Legion.legion_buttonclick()
		if Legion.LegionBaseInfo.Id == nil then
			Legion.get_Legion_List(function ()
        		PanelManager:CreatePanel('UIJoinLegion',UIExtendType.TRANSMASK, {});
			end)
		else
			Legion.get_legion_base_info()
		end
	end

	function Legion.close_JoinAndCreatePanel()
		if UIManager.GetInstance():FindUI("UIJoinLegion") ~= nil then
			UIManager.GetInstance():CallLuaMethod("UIJoinLegion.Close")
		end
	end
	function Legion.send_create_Msg(name, xuanyan)
		local msg = {cmd = "create_legion", name = name, xuanyan = xuanyan};
		
        Send(msg, function (Msg)  --回调打开公会主界面
    		if IsErrorMsg(Msg) then
    			return
    		end
    		Legion.LegionInvitationList = {}; -- 公会创建之后，本地存储的邀请列表清空
    		-- MainUI.CheckLegionInviteTip(); 
    		-- MainUI.CloseQuickOperateBySystem("legion"); -- 关闭队伍区还有的公会邀请

    		client.legion.close_JoinAndCreatePanel()
			Legion.legionBaseInfoCallBack(Msg)
			
			ui.showMsg("恭喜你成功创建公会！")
    		PanelManager:CreatePanel('UILegion',UIExtendType.TRANSMASK, {});
    	end);
	end
------------------------------获取公会列表--------------------	
	function Legion.get_Legion_List_CallBack(Msg,cb)
		local list = Msg["list"]
		Legion.LegionList = {}
		for i = 1,#list do
			local info = {}
			info.Id = list[i][1]
			info.Name = client.tools.ensureString(list[i][2])
			info.Level = list[i][3]
			info.MemberNum = list[i][4]
			info.JunTuanZhang = client.tools.ensureString(list[i][5])
			info.Declaration = client.tools.ensureString(list[i][6])
			info.applyFlag = list[i][7]
			Legion.LegionList[i] = info
        end		
        -- PanelManager:CreatePanel('UIJoinLegion',UIExtendType.NONE, {});
        safe_call(cb);
	end
	function Legion.get_Legion_List(cb)
		local msg = {cmd = "get_legion_list"};
        Send(msg,function (Msg)
        	Legion.get_Legion_List_CallBack(Msg,cb)
        end);
	end

	function Legion.updatePanel(panelindex,iscallback)
		if UIManager.GetInstance():FindUI('UILegion') ~= nil then
			if iscallback == false and Legion.CurrShowPanel ~= panelindex then
				return
			end
			if panelindex == 1 then
				UIManager.GetInstance():CallLuaMethod('UILegion.ShowLegionInfo');
			elseif panelindex == 2 then
				if UIManager.GetInstance():FindUI('OperateFloat') == nil then 			-- 刷新公会成员界面时，若交互菜单被点开，此时不刷新公会成员，刷新操作放到交互菜单close里做
					UIManager.GetInstance():CallLuaMethod('UILegion.ShowLegionMember');
				end
			elseif panelindex == 3 then
				UIManager.GetInstance():CallLuaMethod('UILegion.ShowLegionShop');
			elseif panelindex == 4 then
				UIManager.GetInstance():CallLuaMethod('UILegion.ShowLegionLog');
			end
		end
	end
---------------------------------获取公会基础信息---------------------------
	function Legion.get_legion_base_info(Msg)
		local msg = {cmd = "get_legion_base_info"};
        Send(msg, function(Msg) --回调打开公会主界面
    		if IsErrorMsg(Msg) then
    			return
    		end
    		Legion.legionBaseInfoCallBack(Msg)
    		if Legion.is_Legion_Panel_Open() == false then
				PanelManager:CreatePanel('UILegion',UIExtendType.NONE, {});
			end
    	end)
	end

	function Legion.ParseSelfJur(JurList)
		Legion.LegionBaseInfo.SelfJur = {}
		for i = 1,#JurList do
			Legion.LegionBaseInfo.SelfJur[JurList[i][1]] = JurList[i][2]	
		end

	end
	function Legion.ParseSelfJurFromClientCfg(JurList)
		Legion.LegionBaseInfo.SelfJur = {}
		for i = 1,#JurList do
			Legion.LegionBaseInfo.SelfJur[i] = JurList[i]
		end
	end

	function Legion.legionBaseInfoCallBack(Msg)
		local Info = Msg["info"]
		Legion.LegionBaseInfo.Id = Info[1]
		Legion.LegionBaseInfo.Name = client.tools.ensureString(Info[2]);
		Legion.LegionBaseInfo.Level = Info[3]
		Legion.LegionBaseInfo.Construction = Info[4]
		Legion.LegionBaseInfo.Money = Info[5]
		Legion.LegionBaseInfo.MemberNum = Info[6]
		Legion.LegionBaseInfo.TuanZhangName = client.tools.ensureString(Info[7]);
		Legion.LegionBaseInfo.FightArea = client.tools.ensureString(Info[8]);
		Legion.LegionBaseInfo.SelfPosition = Info[9]
		Legion.LegionBaseInfo.Announcement = client.tools.ensureString(Info[10]);
		Legion.LegionBaseInfo.Declaration = client.tools.ensureString(Info[11]); 
		Legion.set_redpoint_flag(Legion.RedPointType.qiandao,Info[12])
		-- Legion.set_redpoint_flag(Legion.RedPointType.hongbao,Info[13])
		Legion.ParseSelfJur(Info[14])
		Legion.LegionBaseInfo.ActiveState = Info[15]  --主动解散  1:正常 3:预备解散 
		Legion.LegionBaseInfo.ActiveDismissTime = Info[16]
		Legion.LegionBaseInfo.MainTainState = Info[17] --被动解散 1:正常 2:预备降级 3:预备解散
		Legion.LegionBaseInfo.HistoryContribution = Info[18]
		Legion.LegionBaseInfo.Signature = client.tools.ensureString(Info[19])
		Legion.LegionBaseInfo.Prosperity = Info[20]
		Legion.LegionBaseInfo.CanGetMoney = tonumber(Info[21])
		Legion.set_redpoint_flag(Legion.RedPointType.fuli,Info[21])

		Legion.updatePanel(1,true)
	end

	SetPort("legion_base_info",Legion.legionBaseInfoCallBack)
-----------------------------------加入公会相关-----------------------------------
	--获取申请列表
	function Legion.get_Applicant_List_CallBack(Msg)
		if IsErrorMsg(Msg) then
        	return
        end
        local list = Msg["apply_list"]
        Legion.ApplicantList = {}
        for i = 1,#list do
        	local info = {}
        	info.Id = list[i][1]
        	info.Name = client.tools.ensureString(list[i][2])
        	info.Level = list[i][3]
        	info.FightAbility = list[i][4]
        	info.ApplyTime = list[i][5]
        	info.Career = list[i][6]
        	Legion.ApplicantList[i] = info
        end
        PanelManager:CreateConstPanel('UILegionApplyList',UIExtendType.NONE, {})
	end

	function Legion.get_Applicant_list()
		local msg = {};
		msg.cmd = "get_legion_apply_list";
        Send(msg,Legion.get_Applicant_List_CallBack)
        Legion.set_redpoint_flag(Legion.RedPointType.applylist,0)
        Legion.set_redpoint_flag(Legion.RedPointType.chengyuan,0)
	end

	--申请加入
	function Legion.apply_Join_Legion(legionId,legionName,callback)
		-- print()
		local msg = {cmd = "apply_join_legion", id = legionId};
        Send(msg, function(Msg) 
    		if IsErrorMsg(Msg) then
    			return
    		end
    		Legion.LegionList[Legion.get_index_by_id(Legion.LegionList,legionId)].applyFlag = 'true'; -- 申请成功之后将客户端存储的legionList中对应项的applyFlag置为true
    		if callback ~= nil then
    			callback(); -- 将该栏前面的打钩显示出来
    		end
    		local str = "已成功向 "..legionName.." 发送了申请";
    		ui.showMsg(str);
    	end)
	end

	function Legion.get_index_by_id(list,id)
		for i = 1,#list do
			if list[i].Id == id then
				return i
			end
		end
		return -1
	end
	function Legion.remove_by_id(list,id)
		local index = Legion.get_index_by_id(list,id)
		if index ~= -1 then
			table.remove(list,index)
		end
	end

	--允许申请人加入
	function Legion.allow_Applicant_Join_In(applicantId,callback)
		
		local msg = {cmd = "allow_Applicant_to_join", id = applicantId};
        Send(msg, function(Msg) 
    		if IsErrorMsg(Msg) then
	    		Legion.remove_by_id(Legion.ApplicantList,applicantId)
	    		if callback ~= nil then
	    			callback();
	    		end

	    		if Msg.error == "you_not_have_jurisdiction" and UIManager.GetInstance():FindUI('UILegionApplyList') ~= nil then
					UIManager.GetInstance():CallLuaMethod('UILegionApplyList.Close');
    			end

    			return
    		end
    		Legion.remove_by_id(Legion.ApplicantList,applicantId)
    		if callback ~= nil then
    			callback();
    		end
    		ui.showMsg("批准成功")
    		Legion.MemberList[#Legion.MemberList+1] = Legion.parseLegionMemberInfo(Msg["info"])
    		Legion.updatePanel(2,true)
    	end)
	end
	--拒绝申请人加入
	function Legion.Refuse_Applicant_Join_In(applicantId,callback)
		local msg = {cmd = "refuse_Applicant_to_join", id = applicantId};
        Send(msg, function(Msg) 
    		if IsErrorMsg(Msg) then
    			-- 本次处理之后一定会移除申请信息
	    		Legion.remove_by_id(Legion.ApplicantList,applicantId)
	    		if callback ~= nil then
	    			callback();
	    		end

	    		if Msg.error == "you_not_have_jurisdiction" and UIManager.GetInstance():FindUI('UILegionApplyList') ~= nil then
					UIManager.GetInstance():CallLuaMethod('UILegionApplyList.Close');
    			end
    			return
    		end
    		-- 本次处理之后一定会移除申请信息
    		Legion.remove_by_id(Legion.ApplicantList,applicantId)
    		if callback ~= nil then
    			callback();
    		end
    	end)
	end
	--全部拒绝
	function Legion.Refuse_All_Applicant(callback)
		local msg = {cmd = "refuse_all"};
        Send(msg, function(Msg) 
    		if IsErrorMsg(Msg) then
    			return
    		end
    		Legion.ApplicantList = {};
    		if callback ~= nil then
    			callback();
    		end
    	end)
	end

	--邀请加入
	function Legion.invite_Join_Legion(targetId)
		local msg = {cmd = "invite_join_legion", id = targetId};
        Send(msg, function(Msg) 
    		if IsErrorMsg(Msg) then
    			return
    		end
    		ui.showMsg("邀请成功");   -- 邀请成功给发起邀请者提示
    	end)
	end
	--同意邀请
	function Legion.Agree_Invited(invitedId) 
		local msg = {cmd = "agree_invite", id = invitedId};
        Send(msg, function(Msg) 
    		-- if IsErrorMsg(Msg) then
			if Msg_Error[Msg.error] ~= nil then
				ui.showMsg("加入失败，邀请信息已失效");
    			return
    		end
    		Legion.LegionInvitationList = {}; -- 同意邀请之后，本地存储的邀请列表清空
    		-- MainUI.CheckLegionInviteTip(); 
    		-- MainUI.CloseQuickOperateBySystem("legion"); -- 关闭队伍区还有的公会邀请
    	end)
	end
	--拒绝邀请
	function Legion.Refuse_Invited(invitedId) 
		local msg = {cmd = "refuse_legion_invite", id = invitedId};
        Send(msg, function (Msg)
        	if IsErrorMsg(Msg) then
        		return 
        	end
    		table.remove(Legion.LegionInvitationList,1)
    		Legion.CheckInvitation();
        end );
	end

	function Legion.CheckInvitation() 
		if #Legion.LegionInvitationList ~= 0 then
			local legionInfo = client.legion.LegionInvitationList[1];
            local text = string.format("%s邀请你加入%s",legionInfo.rolename, legionInfo.legionname);
            ui.showMsgBox("公会邀请",text,client.legion.Agree_Invited,client.legion.Refuse_Invited,nil,legionInfo.roleid);
		end
	end
---------------------------------退出、解散公会-----------------------
	--普通人退出公会
	function Legion.Leave_Legion()
		local msg = {cmd = "leave_legion"};
        Send(msg, IsErrorMsg);
        ui.showMsg("你已退出了公会")
        Legion.onClearLegionInfo()
	end
	--解散公会
	function Legion.Dismiss_Legion()
		local msg = {cmd = "dismiss_legion"};
        Send(msg, function(Msg) 
    		if IsErrorMsg(Msg) then
    			return
    		end
    		Legion.LegionBaseInfo.ActiveState = Msg["activestate"]
    		Legion.updatePanel(2,true);
    	end)
	end

	-- 会长退出公会，其他人接任
	function Legion.Leader_Leave_Legion(targetId)
		local msg = {cmd = "leader_leave_legion", target_id = targetId };
        Send(msg, function(Msg) 
    		if IsErrorMsg(Msg) then
    			return
    		end
        	Legion.onClearLegionInfo()
    	end)
	end

	-- 公会只剩一人，此时会长退会
	function Legion.Last_One_Leave_Legion(legionId)
		local msg = {cmd = "last_one_leave_legion", legion_id = legionId};
        Send(msg, function(Msg) 
    		if IsErrorMsg(Msg) then
    			return
    		end
    		ui.showMsg("你已退出并解散了公会");
        	Legion.onClearLegionInfo()
    	end)
	end
---------------------------------修改公告、宣言----------------------------
	function Legion.change_Legion_Board(type,content,callback)
		local msg = {cmd = "change_legion_board", type = type, content = content};
        Send(msg, function(Msg) 
    		if IsErrorMsg(Msg) then      		
    			if Msg.error == "you_not_have_jurisdiction" then
    				Legion.updatePanel(1,true)
    				return
    			end
    			if callback then   
    				callback(content);
    			end
    			return
    		end
    		if type == 1 then
    			Legion.LegionBaseInfo.Announcement = content;
    			client.chat.send("clan", content, nil, 0, nil)
    		else
    			Legion.LegionBaseInfo.Declaration = content;
    		end
    		ui.showMsg("修改成功")
    		if callback then
    			callback(content);
    		end
    	end)
	end

---------------------------------修改签名----------------------------
	function Legion.change_signature(content,callback)
		local msg = {cmd = "change_signature", content = content};
        Send(msg, function(Msg) 
    		if IsErrorMsg(Msg) then      		
    			return
    		end
    		ui.showMsg("修改成功")
			Legion.LegionBaseInfo.Signature = content;
    		Legion.updatePanel(1,true)
			if callback then   
				callback(content);
			end
    	end)
	end
---------------------------------升级---------------------------------------
	function Legion.level_Up_Legion()
		local msg = {cmd = "level_up_legion"};
        Send(msg,IsErrorMsg);
	end
--------------------------------公会捐献----------------------------------
	function Legion.legion_Contribute(type,callback)
		local msg = {cmd = "legion_contribute", type = type};
        Send(msg, function(msg) 
    		if IsErrorMsg(msg) then
    			return
    		end
    		ui.showMsg('捐献成功');
    		Legion.set_redpoint_flag(Legion.RedPointType.juanxian,0)
    		Legion.LegionBaseInfo.Construction = msg.legioncon
    		DataCache.contribution = msg.selfcon;
    		Legion.updatePanel(1,true)
    		
    		if callback ~= nil then 
    			callback(); -- 成功捐献之后刷新捐献界面
    		end
    	end)
	end
--------------------------------公会签到----------------------------------
	function Legion.legion_signature(callback)
		local msg = {cmd = "legion_signature"};
        Send(msg, function(msg) 
    		if IsErrorMsg(msg) then
    			return
    		end
    		ui.showMsg('你获得了20点公会贡献值');
    		ui.showMsg('你为公会增加了10万资金');
			
    		Legion.set_redpoint_flag(Legion.RedPointType.qiandao,0)
    		Legion.LegionBaseInfo.Construction = msg.legioncon
    		DataCache.contribution = msg.selfcon;
    		Legion.updatePanel(1,true)
    		
    		if callback ~= nil then 
    			callback(); -- 成功捐献之后刷新捐献界面
    		end
    	end)
	end
--------------------------------公会福利领工资----------------------------------
	function Legion.legion_welfare(callback)
		local msg = {cmd = "legion_welfare"};
        Send(msg, function(msg) 
    		if IsErrorMsg(msg) then
    			return
    		end
    		if Legion.LegionBaseInfo.CanGetMoney == 0 then
    			ui.showMsg('很遗憾，由于上周你没有为公会作出任何贡献，无法获得分红福利。');
    		end 
    		Legion.set_redpoint_flag(Legion.RedPointType.fuli,-1)
    		Legion.LegionBaseInfo.CanGetMoney = -1;
    		-- Legion.LegionBaseInfo.Construction = msg.legioncon
    		-- DataCache.contribution = msg.selfcon;
    		Legion.updatePanel(1,true);
    	end)
	end

-------------------------------------成员管理-------------------------------
	--获取成员列表
	function Legion.get_Legion_Member_List(callback)
		local msg = {};
		msg.cmd = "get_legion_member_list";
        Send(msg, function(Msg) 
    		if IsErrorMsg(Msg) then
    			return
    		end
    		Legion.legion_Member_CallBack(Msg)
    		Legion.updatePanel(2,true)
    		if callback ~= nil then
    			callback()
    		end
    	end)
        Legion.set_redpoint_flag(Legion.RedPointType.chengyuan,0)
	end
	
	function Legion.parseLegionMemberInfo(msginfo)
		local info = {}

		-- 	{MemberId, Name, Level, Position, SumContribution, LogOutTime, Career, IsGuaJi, NowFightAbility,YerterdayFP,LastWeekContribution,JoinTime}.
		info.Id = msginfo[1]
		info.Name = client.tools.ensureString(msginfo[2]);
		info.Level = msginfo[3]
		info.Position = msginfo[4]
		info.Contribution = msginfo[5]
		info.LogOutTime = msginfo[6]
		info.Career = msginfo[7]
		info.IsGuaJi = msginfo[8] == "true"
		info.NowFp = msginfo[9]
		info.YerterdayFP = msginfo[10]
		info.LastWeekContribution = info.Contribution - msginfo[11]
		info.JoinTime = msginfo[12]
		info.Sex = msginfo[13]
		info.Camp = 0
		info.Task = 0
		return info
	end

	function Legion.legion_Member_CallBack(Msg)
		local list = Msg["list"]
		Legion.MemberList = {}
		for i = 1,#list do				
			Legion.MemberList[i] = Legion.parseLegionMemberInfo(list[i])
		end
	end

	--任免
	function Legion.legion_Position_Appointed(targetId,position)
		local msg = {cmd = "legion_position_appointed", id = targetId, position = position};
        Send(msg, function(Msg) 
    		if IsErrorMsg(Msg) then
    			return
    		end
    		ui.showMsg('任免成功');
    		for i = 1,#Legion.MemberList do
    			if Legion.MemberList[i].Id == targetId then
    				Legion.MemberList[i].Position = position
    			end
    		end
    		Legion.updatePanel(2,true)
    	end)
	end
	--踢出
	function Legion.legion_Kickout(targetId)
		local msg = {cmd = "legion_kickout", id = targetId};
        Send(msg, function(Msg) 
    		if IsErrorMsg(Msg) then
    			return
    		end
    		Legion.remove_by_id(Legion.MemberList,targetId)
    		Legion.updatePanel(2,true)
    	end)
	end
	--传位
	function Legion.legion_Chuan_Wei(targetId)
		local msg = {cmd = "legion_chuan_wei", id = targetId};
        Send(msg, function(Msg) 
    		if IsErrorMsg(Msg) then
    			return
    		end
    		for i = 1,#Legion.MemberList do
    			if Legion.MemberList[i].Id == targetId then
    				Legion.MemberList[i].Position = 1
    			end
    			if Legion.MemberList[i].Id == DataCache.roleID then
    				Legion.MemberList[i].Position = 4
    			end
    		end
    	end)
	end


	--公会长更改权限
	function Legion.legion_Change_Jur(position,jur,callback)
		local msg = {cmd = "legion_change_jurisdiction", position = position, jur = jur};
        Send(msg, function(Msg) 
    		if IsErrorMsg(Msg) then
    			return
    		end
    		Legion.LegionJurList[position][jur] = 1-Legion.LegionJurList[position][jur]
    		if callback then
    			callback()
    		end
    	end)
	end

	--设置权限为默认
	function Legion.legion_Set_Jur_Defult(callback)
		local msg = {cmd = "legion_set_jurisdiction_defult"};
        Send(msg, function(Msg) 
    		if IsErrorMsg(Msg) then
    			return
    		end

    		for i=1,#tb.legionjurisdiction do
    			Legion.LegionJurList[i] = {};
    			for j=1,#tb.legionjurisdiction[i] do
    				Legion.LegionJurList[i][j] = tb.legionjurisdiction[i][j];
    			end
    		end	
    		
    		if callback then 
    			callback()
    		end
    	end)
	end

-------------------------------------公会商店-------------------------------
	--获取商店列表
	function Legion.get_Legion_Shop_Info_CallBack(Msg)
		if IsErrorMsg(Msg) then
        	return
        end
        Legion.ShopList = {}
        local list = Msg["list"]
        for i = 1,#list do
        	local info = {}
        	info.Id = list[i][1]
        	info.Count = list[i][2] --已兑换次数
        	
        	Legion.ShopList[i] = info
        end

        table.sort(Legion.ShopList, function(itemSid1,itemSid2)
			return tb.legionshop[itemSid1.Id].needlegioncontribution < tb.legionshop[itemSid2.Id].needlegioncontribution;
        end);
        Legion.updatePanel(3,true)
	end
	function Legion.get_Legion_Shop_Info()
		-- 暂时屏蔽
		if true then ui.showMsg("功能尚未开放"); return false; end
		-- end 暂时屏蔽
		local msg = {cmd = "get_legion_shop_info"};
        Send(msg,Legion.get_Legion_Shop_Info_CallBack)
	end
	--购买
	function Legion.buy_Shop_Item(itemId,count,callback)
		local msg = {cmd = "buy_legion_shop_item", id = itemId, count = count};
        Send(msg, function(Msg)
    		if IsErrorMsg(Msg) then
    			return
    		end
    		local id = Msg["id"]
    		local times = Msg["times"]
    		local cost = Msg["cost"]
    		local count = Msg["count"]
    		local selfconstruction = Msg["selfcon"]
    		for i = 1,#Legion.ShopList do
    			if Legion.ShopList[i].Id == id then
    				Legion.ShopList[i].Count = times
    			end
    		end
    		DataCache.contribution = selfconstruction

    		local tbcfg = tb.ItemTable[itemId]
    		if tbcfg == nil then
    			tbcfg = tb.GemTable[itemId]
    		end
    		local temp = client.tools.formatColor(tbcfg.name or tbcfg.show_name, const.qualityColor[tbcfg.quality + 1]);
    		local str = "你花费了"..cost.."点贡献值购买了"..count.."个"..temp;
    		ui.showMsg(str);
    		local strlegion = string.format("您花费%d点贡献值购买了%d个%s",cost,count,tbcfg.name or tbcfg.show_name);
			client.chat.clientSystemMsg(strlegion, nil,nil,"clan", false)

    		if callback ~= nil then
    			callback()
    		end
    	end)
	end



-----------------------------公会红包------------------------------------
	--解析红包
	function Legion.parseRedPacket(packet)
		local info = {}
		local packetinfo = packet[2] --第一个是id
		for i = 1,#packetinfo do
			info.Id = packetinfo[1][2]
			info.OwnerId = packetinfo[2][2]
			info.GenTime = packetinfo[3][2]
			info.SendTime = packetinfo[4][2]
			info.Type = packetinfo[5][2]
			info.Grade = packetinfo[6][2]
			info.PacketNum = packetinfo[7][2]
			info.MemberList = {}
			local list = packetinfo[8][2]
			for j = 1,#list do
				info.MemberList[j] = {client.tools.ensureString(list[j][1]),list[j][2]}
			end
			info.OwnerName = client.tools.ensureString(packetinfo[9][2])
			info.Career = packetinfo[10][2]
			info.Sex = packetinfo[11][2]
			return info
		end
	end
	--获取红包列表
	function Legion.Legion_RedPacket_CallBack(Msg)
		local list = Msg["list"]
		Legion.RedPacketList = {}
		for i = 1,#list do
			local info = Legion.parseRedPacket(list[i])
			Legion.RedPacketList[i] = info
		end
		Legion.on_redpacket_effect()
	end
	--红包显示类型
	function Legion.get_RedPacket_ShowType(info)
		if info.PacketNum == 0 then
			return 2 --未发送
		elseif info.PacketNum == #info.MemberList or Legion.self_drawed(info) ~= 0 then
			return 3 -- 查看
		else
			return 1 --可领取	
		end 
	end
	
	--获取自己未发送 和 其他 的红包
	function Legion.get_mynotsend_and_other_Packets()
		local mylist = {};
		local otherlist = {};
		for i = 1,#Legion.RedPacketList do
			local info = Legion.RedPacketList[i]
			if info.OwnerId == DataCache.roleID and Legion.get_RedPacket_ShowType(info) == 2 then
				mylist[#mylist + 1] = info
			else
				otherlist[#otherlist + 1] = info	
			end
		end
		return mylist,otherlist
	end
	--自己领金额 0 没有领到 其他领到金额
	function Legion.self_drawed(info)
		local list = info.MemberList
		for i = 1,#list do
			if list[i][1] == DataCache.myInfo.name then
				return list[i][2]
			end
		end
		return 0
	end
	--所有人已领金额
	function Legion.get_draw_packets_diamond(info)
		local list = info.MemberList
		local num = 0
		for i = 1,#list do
			num = num + list[i][2]
		end
		return num
	end
	--已领红包个数
	function Legion.get_draw_packets_num(info)
		return #info.MemberList
	end
	--红包钻石总额
	function Legion.get_redpacket_totaldiamond(info)
		return tb.legionredpackets[info.Grade].totaldiamond
	end
	--红包标题
	function Legion.get_redpacket_name(info,type)
		local cfg = tb.legionredpacketsevent[info.Type]
		if type == 1 then
			return cfg.title  --短名
		else
			return cfg.title2  --长名
		end
	end
	--领取最多的人的index
	function Legion.get_most_draw_index(info)
		local list = info.MemberList
		local num = 0
		local index = 1
		for i = 1,#list do
			if list[i][2] > num then
				num = list[i][2]
				index = i
			end
		end
		return index
	end
	--红包领取结果
	function Legion.get_redpacket_result(Msg)
		local info = {}
		info.career = Msg["career"]
		info.sex = Msg["sex"]
		info.packetinfo = Legion.parseRedPacket(Msg["packetinfo"])
		--显示界面
	end
	SetPort("redpacket_result",Legion.get_redpacket_result)

	function Legion.get_redpacket_byId(id)
		local info = {}
		for i = 1,#Legion.RedPacketList do
			if Legion.RedPacketList[i].Id == info.Id then
				info = Legion.RedPacketList[i]
				return info
			end
		end
		return nil 
	end

	function Legion.replace_redpacket(info)
		for i = 1,#Legion.RedPacketList do
			if Legion.RedPacketList[i].Id == info.Id then
				Legion.RedPacketList[i] = info
				return true
			end
		end
		return false
	end

	--是否有真正可以领的红包 
	function Legion.is_have_candraw_repacket()
		for i = 1,#Legion.RedPacketList do
			local info = Legion.RedPacketList[i]
			
			if info.PacketNum > #info.MemberList and Legion.self_drawed(info) == 0 then
				return true
			end
		end
		return false
	end

	--领取可领取列表中第一个红包id
	function Legion.draw_candraw_first()
		local id = 0
		for i = 1,#Legion.RedPacketList do
			local info = Legion.RedPacketList[i]
			
			if info.PacketNum > #info.MemberList and Legion.self_drawed(info) == 0 then
				id = info.Id
			end
		end
		if id == 0 then
			MainUI.HideHongBaoIcon()
		else 
			Legion.draw_Red_Packets(id)
		end
	end

	function Legion.on_redpacket_effect()
		if MainUI ~= nil then
    		if Legion.is_have_candraw_repacket() then
    			MainUI.ShowHongBaoIcon()
    		else
    			MainUI.HideHongBaoIcon()
    		end    	
    	end
    end
	--公会红包有改变时  --有人发送、自己领取
	function Legion.on_packets_change(Msg)
		local info = Legion.parseRedPacket(Msg["packetinfo"])
		
		if Legion.replace_redpacket(info) == false then
			Legion.RedPacketList[#Legion.RedPacketList + 1] = info
		end

		if UIManager.GetInstance():FindUI('UILegionHongBao') ~= nil then
			UIManager.GetInstance():CallLuaMethod('UILegionHongBao.InitContent');
		end
		local couldSendList,couldReceiveList = client.legion.get_mynotsend_and_other_Packets();
		if #couldSendList > 0 then        
        	Legion.set_redpoint_flag(Legion.RedPointType.hongbao,1)
        else
        	Legion.set_redpoint_flag(Legion.RedPointType.hongbao,0)
    	end

    	Legion.on_redpacket_effect()
	end
	SetPort("on_packets_change",Legion.on_packets_change)

	--获取红包列表
	function Legion.get_Legion_RedPackets()
		local msg = {cmd = "get_redpackets_list"};
        Send(msg, function(Msg) 
    		if IsErrorMsg(Msg) then
    			return
    		end
    		Legion.Legion_RedPacket_CallBack(Msg)
    		PanelManager:CreatePanel('UILegionHongBao',UIExtendType.NONE, {});
		end)

	end
	
	--发送红包
	function Legion.send_Red_Packets(packetId,count)
		local msg = {cmd = "send_red_packets", id = packetId, count = count};
        Send(msg, function(Msg) 
    		if IsErrorMsg(Msg) then
    			return
    		end
    		UIManager.GetInstance():CallLuaMethod('UILegionHongBao.onSendSuccess');
    	end)
	end
	--领取红包
	function Legion.draw_Red_Packets(packetId)
		local msg = {cmd = "draw_red_packets", };
		msg.id = packetId		
        Send(msg, function(Msg) 
    		if IsErrorMsg(Msg) then
    			return
    		end
    		local flag = Msg["flag"]
    		if Msg["info"] then
    			local info = Legion.parseRedPacket(Msg["info"])
    			local callback = function ()
    				PanelManager:CreateConstPanel('UILegionHongBaoResult', UIExtendType.NONE, {packetinfo = info});
    			end 
    			if flag == 1 then
    				PanelManager:CreateConstPanel('UILegionHongBaoEffect', UIExtendType.NONE, {callback = callback});
    			else
    				callback()
    			end
    		end
    		--显示结果
    	end)
	end
	------------------------------------------------公会动态----------------------------------

	--获取动态
	function Legion.parseDynamic(info)
		local parseInfo = {}
		parseInfo.Time = info[1]
		local type = info[2]
		local args = info["args"]
		for i = 1,#args do
			args[i] = "<color=#E68829>"..client.tools.ensureString(args[i]).."</color>"
		end
		parseInfo.Str = tb.legionDynamic[type]
		for i = 1,#args do
			parseInfo.Str = string.gsub(parseInfo.Str,'%$',args[i],1)
		end
		return parseInfo
	end
	function Legion.get_dynamic_info()
		local msg = {cmd = "get_dynamic_info"};
        Send(msg, function(Msg) 
    		local list = Msg["list"]
    		local parseList = {}
    		for i = 1,#list do
    			parseList[i] = Legion.parseDynamic(list[i])
    		end
    		Legion.DynamicList = {}
    		for i = 1,#parseList do
    			local t = parseList[i]
    			local info = {}
    			
    			if #Legion.DynamicList == 0 then  --第一条
    				info.type = 1
    				info.str1 = os.date("%Y年%m月%d日",t.Time)
    				info.str2 = ""
    				Legion.DynamicList[#Legion.DynamicList + 1] = info

    				Legion.DynamicList[#Legion.DynamicList + 1] = {type = 2,str1 = os.date("%H:%M:%S",t.Time),str2 = t.Str}

    			else
    				local pre = parseList[i - 1]
    				if os.date("%Y%m%d",pre.Time) ~= os.date("%Y%m%d",t.Time) then  --跨天
    					info.type = 3
    					info.str1 = ""
    					info.str2 = ""
    					Legion.DynamicList[#Legion.DynamicList + 1] = info --空行

    					Legion.DynamicList[#Legion.DynamicList + 1] = {type = 1,str1 = os.date("%Y年%m月%d日",t.Time),str2 = ""}

    					Legion.DynamicList[#Legion.DynamicList + 1] = {type = 2,str1 = os.date("%H:%M:%S",t.Time),str2 = t.Str}

    				else --正常文本
    					info.type = 2
    					info.str1 = os.date("%H:%M:%S",t.Time)
    					info.str2 = t.Str	
    					Legion.DynamicList[#Legion.DynamicList + 1] = info
    				end
    			end
    		end
    		-- Legion.updatePanel(4,true)
    		ui.ShowLegionLog();
    	end)
	end
	return Legion;
end

client.legion = CreateLegionCtrl()