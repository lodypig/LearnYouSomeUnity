function UIHolyItemView(k)	
	local UIHolyItem = {};
	local this = nil;
	local close = nil
	local item1 = nil;
	local param = client.holyProtect.holylist[k];
	function UIHolyItem.Start()

		this = UIHolyItem.this;
		this:GO('Panel.close'):BindButtonClick(UIHolyItem.onCancelClick);
		this:GO('Panel.Icon').sprite = param.icon;
		this:GO('Panel.name').sprite = param.big_icon;
		this:GO('Panel.origin_text').text = "　　".. param.origin;
		local chapter = client.holyProtect.GetHolyChapter();
		local career = DataCache.myInfo.career;
		local skillIcon = nil;
		local skillName = nil;
		local skillDescribe = nil;
		if career == "soldier" then
			skillName = param.skill_name1;
			skillIcon = param.skill_icon1;
			skillDescribe = param.skill_1;
 		elseif career == "magician" then
 			skillName = param.skill_name2;
			skillIcon = param.skill_icon2;
			skillDescribe = param.skill_2;
 		elseif career == "bowman" then
 			skillName = param.skill_name3;
			skillIcon = param.skill_icon3;
			skillDescribe = param.skill_3;
		end
		this:GO('Panel.bottom.skill_value').text = skillDescribe;
		this:GO('Panel.bottom.zhufu_value.value').text = skillName;
		this:GO('Panel.bottom.zhufu').sprite = skillIcon;
		this:GO('Panel.bottom.awake_value').text = param.awake_way;
		if k < chapter then
			this:GO('Panel.Icon.state').gameObject:SetActive(false);
			this:GO('Panel.bottom.zhufu.effect'):PlayUIEffectForever(this.gameObject, "shenlin2");
			
		else
			if k == chapter then
				Util.SetGray(this:GO('Panel.Icon').gameObject, true);
				if param.jindu == 1 then
					this:GO('Panel.Icon.awake').gameObject:SetActive(true);
					this:GO('Panel.Icon.state').gameObject:SetActive(true);
					this:GO('Panel.Icon.state').sprite = "dk_fuwen_1";
					this:GO('Panel.Icon.effect'):PlayUIEffectForever(this.gameObject, "shenglin1");
				else
					this:GO('Panel.Icon.state').sprite = "dk_fuwen_2";
					this:GO('Panel.Icon.sleep').gameObject:SetActive(true);
				end
			else
				Util.SetGray(this:GO('Panel.Icon').gameObject, true);
				this:GO('Panel.Icon.state').gameObject:SetActive(true);
				this:GO('Panel.Icon.state').sprite = "dk_fuwen_2";
				this:GO('Panel.Icon.sleep').gameObject:SetActive(true);
			end
		end

		this:GO('Panel.Icon'):BindButtonClick(function()
			if k == chapter then
				if param.state == 1 then
					if param.jindu ~= 1 then
						ui.showMsg("圣灵沉睡中，快去通过主线任务激活圣灵吧");
					else
						ui.showMsgBox(nil, "是否进入副本？", function() 

							local sceneId = DataCache.scene_sid;
	                		if SceneManager.IsFubenMap(sceneId) then
	                			ui.showMsg("当前状态无法进入副本");
	                			return;
	                		end
	        				if client.role.haveTeam() then
	        					ui.showMsgBox(nil, "主线副本只可单人进入，是否退出组队并进入？",function() 
	        						client.team.q_leave();
	        						AutoPathfindingManager.Cancel();
	        						local mainTaskId = client.task.mainTaskSid;
									PlotlineFuben.ChallengeFuben(mainTaskId);
									destroy(this.gameObject);
								end);
	        				else
	        					AutoPathfindingManager.Cancel();
		        				local mainTaskId = client.task.mainTaskSid;
								PlotlineFuben.ChallengeFuben(mainTaskId);
								destroy(this.gameObject);
							end
						end);
					end 
				end
			else
				if k < chapter then
					ui.showMsg("该圣灵已激活")
				else
					ui.showMsg("圣灵沉睡中，快去通过主线任务激活圣灵吧");
				end
			end
		end);
	end

	function UIHolyItem.onCancelClick()
		PanelManager:CreatePanel('UIHolyProtect', UIExtendType.BLACKMASK, {});
		destroy(this.gameObject);
	end

	return UIHolyItem;
end