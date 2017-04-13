function OperateFloatView(param)
		local OperateFloat = {};
		local this = nil;

		local roleInfo = param.roleInfo;
		local teamInfo = param.teamInfo

		local onLostFocus = function ()
			if client.legion.UpdateLegionMemberFlag and UIManager.GetInstance():FindUI('UILegion') ~= nil then				-- 如果是从公会成员界面点开的交互菜单，这时公会成员界面正好需要刷新，把刷新延后到现在做
				UIManager.GetInstance():CallLuaMethod('UILegion.ShowLegionMember');
				client.legion.UpdateLegionMemberFlag = false
			end
			OperateFloat.closeSelf();
			if param.lostFocus then
				param.lostFocus();
			end
		end

		--按钮名字
		local buttonName = {
							goTo = "前往",
							sendMsg = "发送消息",
							sendPos = "发送坐标",
							roleInfo = "查看角色",
							addFriend = "加为好友",
							removeFriend = "删除好友",
							addBlack = "加入黑名单",
							removeBlack = "移出黑名单",
							inviteTeam = "邀请组队",
							applyTeam = "申请组队",
							requireTeam = "请求组队",
							legionInvitation = "公会邀请",
							changeLeader = "提升队长",
							removeTeam = "踢出队伍",
							complain = "举报",
							legionPositionAppoint = "职位任免" ,
							legionKickout = "逐出公会",
							legionChuanWei = "公会传位",
							leaveTeam = "退出队伍",
						};

		--按钮触发函数
		local buttonFun = {};

		buttonFun.legionPositionAppoint = function ()
			if math.abs(client.legion.LegionBaseInfo.SelfJur[2]) ~= 1 then
				ui.showMsg("您的权限不足，无法进行任免操作");
			elseif client.legion.LegionBaseInfo.SelfPosition >= roleInfo.legion_position then
				ui.showMsg("您的权限不足以任免对方");
			else
				client.legion.LegionPositionAppoint(roleInfo);
			end
		end

		buttonFun.legionKickout = function ()
			if math.abs(client.legion.LegionBaseInfo.SelfJur[3]) ~= 1 then
				ui.showMsg("您的权限不足，无法进行此操作");
			elseif client.legion.LegionBaseInfo.SelfPosition >= roleInfo.legion_position then
				ui.showMsg("您的权限不足以将对方逐出公会");
			else
				local str = "确定将玩家"..roleInfo.name.."逐出公会吗？"
				ui.showMsgBox("逐出公会", str, client.legion.legion_Kickout, nil, nil, roleInfo.role_uid)
			end

		end
		buttonFun.legionChuanWei = function ()
			local str = "确定传位给"..roleInfo.name.."吗？（你将失去会长职位并成为普通会员）"
			ui.showMsgBox("公会传位", str,client.legion.legion_Chuan_Wei, nil, nil, roleInfo.role_uid)
		end


		buttonFun.goTo = function ()
			if roleInfo.state == "offline" then
				ui.showMsg("对方处于离线状态");
				return;
			end
			if SceneManager.IsXiangWeiMap(roleInfo.sceneId) or SceneManager.IsXiangWeiMap(DataCache.scene_sid) then
				ui.showMsg("该玩家不在场景内")
				return
			end

			local sceneId = roleInfo.sceneId;
			local scene = roleInfo.scene;
			local pos = roleInfo.pos;
			if pos ~= nil then
				local fenxian = scene[3]
            	TransmitScroll.ClickLinkPathing(sceneId, fenxian, Vector2.New(pos[1],pos[3]));
        	end
			onLostFocus();
		end

		buttonFun.sendMsg = function ()
			ui.unOpenFunc();
			onLostFocus();
		end

		buttonFun.sendPos = function()
			--sendPos
			if SceneManager.IsXiangWeiMap(DataCache.scene_sid) then
				ui.showMsg("该场景不能发送坐标!");
				return
			end
			--队伍  聊天频道 我在这里
	        local pos = Vector2.New(math.floor(AvatarCache.me.pos_x * 2 + 0.5), math.floor(AvatarCache.me.pos_z * 2 + 0.5));
	        local mapName = DataCache.getSceneTable().name;
	        local location = "["..mapName..","..pos.x..","..pos.y.."]我在这里！";
	        client.chat.send("team", location, nil, 0, nil);
			onLostFocus();
		end

		buttonFun.roleInfo = function ()
			GetRoleDetail(roleInfo.role_uid, function () 
				--表示从UIChat界面进入的查看角色，当关闭该界面时要回到UIChat
				if param.fromUI == "UIChat" then
					ui.showUIChat = true;
				end
				ShowOtherRoleInfo();
				end);
		end

		buttonFun.addFriend = function ()
			-- body
			ui.unOpenFunc();
		end

		buttonFun.removeFriend = function ()
			-- body
		end

		buttonFun.addBlack = function ()
			-- body
		end

		buttonFun.removeBlack = function ()
			-- body
		end

		
		buttonFun.inviteTeam = function ()
			client.team.q_invite_team(roleInfo.role_uid, roleInfo.name, roleInfo.team_uid)
		end

		buttonFun.applyTeam = function ()

			client.team.q_apply_team(roleInfo.role_uid, roleInfo.name, roleInfo.team_uid);
		end		
		

		buttonFun.requireTeam = function ()
			if roleInfo.team_uid == 0 then
		        client.team.q_invite_team(roleInfo.role_uid, roleInfo.name, roleInfo.team_uid)
	        else
	            client.team.q_apply_team(roleInfo.role_uid, roleInfo.name, roleInfo.team_uid);
	        end
		end

		buttonFun.legionInvitation = function ()
			client.legion.invite_Join_Legion(roleInfo.role_uid);
		end
		
		buttonFun.changeLeader = function ()
			-- body
			client.team.q_change_leader(roleInfo.role_uid)
		end

		buttonFun.removeTeam = function ()
			--ui.showMsgBox(string.format("确定要将<%s>踢出队伍吗？", roleInfo.name), function ()
			client.team.q_kick(roleInfo.role_uid);
			--	end);
		end

		buttonFun.leaveTeam = function()
			client.team.q_leave()
		end

		buttonFun.complain = function ()
			-- body
			ui.unOpenFunc();
		end

		function OperateFloat.Start()
			this = OperateFloat.this;
			this:BindLostFocus(onLostFocus);

			OperateFloat.buttonPrefab.gameObject:SetActive(false);
			--this:GO('content.Info.Head.Icon').sprite = string.format("tx_%s_%s",roleInfo.career,roleInfo.sex);
			--this:GO('content.Info.Name').text = roleInfo.name;
			
			local panelRect = this:GO("content"):GetComponent("RectTransform");
			local canvasScaler = this:GetComponent("CanvasScaler");

			panelRect.anchoredPosition = param.posInfo.pos;	
			panelRect.anchorMin = param.posInfo.anchorMin;
			panelRect.anchorMax = param.posInfo.anchorMax;
			panelRect.pivot = param.posInfo.pivot;

			OperateFloat.headImg.sprite = const.RoleImgTab[roleInfo.career][roleInfo.sex + 1];
			OperateFloat.roleName.text = roleInfo.name;
			if not roleInfo.legion_name or roleInfo.legion_name == "" then
				OperateFloat.legionName.text = "无";
			else
				OperateFloat.legionName.text = roleInfo.legion_name;
			end

			for _,v in pairs(param.btnList) do
				OperateFloat.addButton(buttonName[v], function ()
					buttonFun[v]();
					onLostFocus()
				end );
			end

			--播放弹出动画
			OperateFloat.buttonGrid.transform.localScale = Vector3.zero;
			OperateFloat.buttonGrid.transform:DOScale(Vector3.one, 0.2);
		end
	
		function OperateFloat.closeSelf()
			destroy(this.gameObject)
			OperateFloat.this = nil;
		end

		function OperateFloat.addButton(name, fun)
			local go = newObject(OperateFloat.buttonPrefab.gameObject);
            go.gameObject:SetActive(true);	
            go.transform:SetParent(OperateFloat.buttonGrid.transform);
            go.transform.localScale = Vector3.one;
            go.transform.localPosition = Vector3.zero;

            local wrapper = go:GetComponent("UIWrapper");  
            wrapper:BindButtonClick(fun);
            wrapper:GO("Text").text = name;
		end

		return OperateFloat;
end

function ui.ShowOperateFloat(roleInfo, btnList, posInfo, canvasObject, lostFocus, fromUI)
	local param = { roleInfo = roleInfo, btnList = btnList, posInfo = posInfo, fromUI = fromUI};

    -- if not posInfo.screenMatchMode then
    --     local canvasScaler = canvasObject:GetComponent("CanvasScaler");
    --     posInfo.screenMatchMode = canvasScaler.screenMatchMode;
    --     posInfo.matchWidthOrHeight = canvasScaler.matchWidthOrHeight;
    -- end

    param.lostFocus = lostFocus;
    PanelManager:CreateConstPanel('OperateFloat',UIExtendType.NONE, param)
    -- PanelManager:CreateConstPanel('OperateFloat',UIExtendType.NONE, param, posInfo.screenMatchMode, posInfo.matchWidthOrHeight);
 end
