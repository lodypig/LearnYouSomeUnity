function TeamOperateFloatView(param)
		local TeamOperateFloat = {};
		local this = nil;
		local memberInfo = nil;

		local operate1_Pos = nil;
		local operate2_Pos = nil;

		--队友的条目
		local teamObj = nil; 

		local onLostFocus = function ()
			TeamOperateFloat.Hide();
		end	

		TeamOperateFloat.goTo = function ()
			if memberInfo.state == "offline" then
				ui.showMsg("对方处于离线状态");
				return;
			end

			local sceneId = memberInfo.sceneId;
			local scene = memberInfo.scene;
			local pos = memberInfo.pos;
			if pos ~= nil then
				local fenxian = scene[3]
            	TransmitScroll.ClickLinkPathing(sceneId, fenxian, Vector2.New(pos[1],pos[3]));
        	end
			onLostFocus();
		end

		TeamOperateFloat.sendMsg = function ()
			-- body
			ui.unOpenFunc();
			onLostFocus();

		end

		TeamOperateFloat.addFriend = function ()
			-- body
			ui.unOpenFunc();
			onLostFocus();

		end

		TeamOperateFloat.roleInfo = function ()
			GetRoleDetail(memberInfo.role_uid, ShowOtherRoleInfo)
			onLostFocus();
		end
		
		TeamOperateFloat.changeLeader = function ()
			-- body
			client.team.q_change_leader(memberInfo.role_uid)
			onLostFocus();

		end

		TeamOperateFloat.removeTeam = function ()
			client.team.q_kick(memberInfo.role_uid);
			onLostFocus();

		end

		TeamOperateFloat.LeaveTeam = function ()
	        client.team.q_leave();
			onLostFocus();

	    end

	    TeamOperateFloat.SendLocation = function()
	        local pos = Vector2.New(math.floor(DataCache.me.transform.position.x * 2 + 0.5), math.floor(DataCache.me.transform.position.z * 2 + 0.5));
	        local mapName = DataCache.getSceneTable().name;
	        local location = "["..mapName..","..pos.x..","..pos.y.."]";
	        client.chat.send("team", location, nil, 0, nil);
			onLostFocus();

	    end
		
		function TeamOperateFloat.Start()
			this = TeamOperateFloat.this;
			this:BindLostFocus(onLostFocus);

			--设置坐标
			local pos = this:GO("Panel.operate2").transform.localPosition;
			pos.x = pos.x - 600;
			this:GO("Panel.operate2").transform.localPosition = pos;
			operate2_Pos = pos;

			pos = this:GO("Panel.operate1").transform.localPosition;
			pos.x = pos.x - 600;
			this:GO("Panel.operate1").transform.localPosition = pos;
			operate1_Pos = pos;

			this:GO("Panel.operate2.btnGo"):BindButtonClick(TeamOperateFloat.goTo);
			this:GO("Panel.operate2.btnSend"):BindButtonClick(TeamOperateFloat.sendMsg);
			this:GO("Panel.operate2.btnSearch"):BindButtonClick(TeamOperateFloat.roleInfo);
			this:GO("Panel.operate2.btnAddFriend"):BindButtonClick(TeamOperateFloat.addFriend);
			this:GO("Panel.operate2.btnLeader"):BindButtonClick(TeamOperateFloat.changeLeader);
			this:GO("Panel.operate2.btnKick"):BindButtonClick(TeamOperateFloat.removeTeam);

			this:GO("Panel.operate1.btnLeave"):BindButtonClick(TeamOperateFloat.LeaveTeam);
			this:GO("Panel.operate1.btnLocation"):BindButtonClick(TeamOperateFloat.SendLocation);

		end

		function TeamOperateFloat.FirstUpdate( )
			TeamOperateFloat.Show(param);
		end

		function TeamOperateFloat.Hide()
			this:GO('Panel.operate1').transform:DOLocalMoveX(operate1_Pos.x, 0.3, false);
			this:GO('Panel.operate2').transform:DOLocalMoveX(operate2_Pos.x, 0.3, false);
			if teamObj ~= nil then
				teamObj.gameObject:SetActive(true);
			end
		end

		function TeamOperateFloat.Show(param)
			if teamObj ~= nil then
				teamObj.gameObject:SetActive(true);
			end

			memberInfo = param.data;

			--队长才显示的拉按钮
			local isLeader = client.role.isTeamLeader();
			this:GO("Panel.operate2.btnLeader").gameObject:SetActive(isLeader and (memberInfo.state == "online"));
			this:GO("Panel.operate2.btnKick").gameObject:SetActive(isLeader);

			--隐藏当前选中队员
			teamObj = param.teamObj;
			teamObj.gameObject:SetActive(false);

			this:GO("Panel.operate1").transform.localPosition = operate1_Pos;
			this:GO("Panel.operate2").transform.localPosition = operate2_Pos;

			this:GO("Panel.operate2.target").text = "操作目标："..memberInfo.name;

			--根据点击的队伍设置悬浮框位置
			local pos = this:GO("Panel.operate2").transform.position;
			pos.y = param.posY;
			this:GO("Panel.operate2").transform.position = pos;

			--移入动画
			this:GO('Panel.operate1').transform:DOLocalMoveX(operate1_Pos.x + 600, 0.3, false);
			this:GO('Panel.operate2').transform:DOLocalMoveX(operate2_Pos.x + 600, 0.3, false);
		end
	
		function TeamOperateFloat.closeSelf()
			destroy(this.gameObject)
		end

		return TeamOperateFloat;
end
