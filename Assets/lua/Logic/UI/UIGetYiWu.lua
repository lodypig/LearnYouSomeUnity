function UIGetYiWuView (param) --{treasureSid,EquipList}
	local UIGetYiWu = {};
	local this = nil;
	--这边的时间需要随时间更新
	local constSid = {10052001,10052002,10052003};
	local ds = AvatarCache.GetAvatar(param.boxId);

	function UIGetYiWu.Start ()
		this = UIGetYiWu.this;
		UIGetYiWu.BtnClose:BindButtonClick(function (go)
			UIGetYiWu.Destroy();
		end)
		UIGetYiWu.BtnCancel:BindButtonClick(function (go)
			UIGetYiWu.Destroy();
		end)

		UIGetYiWu.Title.text = param.name;

		if DataCache.myInfo.id == param.killer then
			UIGetYiWu.Self:Hide();
			UIGetYiWu.Other:Show();			
			for i=1,3 do
				UIGetYiWu.BagItem[i].setTreasure(constSid[i]);
				UIGetYiWu.BagItem[i].wrapper:BindButtonClick(function (go)
					PanelManager:CreateConstPanel('ItemFloat',UIExtendType.BLACKCANCELMASK,{bDisplay = true, sid = constSid[i]});
				end)	
			end
		else
			UIGetYiWu.Self:Show();
			UIGetYiWu.Other:Hide();
		end

		UIGetYiWu.BtnCancel:BindButtonClick(function (go)
			--print("UIGetYiWu.BtnCancel")
			UIGetYiWu.Destroy();
		end)

		UIGetYiWu.BtnConfirm:BindButtonClick(function (go)
			--print("UIGetYiWu.BtnConfirm")
			if DataCache.myInfo.kill_value >= 100 and DataCache.myInfo.id == param.killer then
				ui.showMsg("当前处于红名状态，无法拾取他人遗物");
				UIGetYiWu.Destroy();
				return;
			end

			if TreasureCtrl.GetFreeCell() < 4 and DataCache.myInfo.id ~= param.killer then
				ui.showMsg("黄金圣匣的空间不足以容纳，请先整理");
			else
				local str = "拾取遗物中";
				MainUI.HideTreasureBtn();
				client.commonProcess.StartProcess(ProcessType.CBTProcess, 3, str, function() 

					if DataCache.scene_sid == 20040004 then
						local msg = {cmd = "client_event", type = "client_operate", tasksid = 990000031};
						Send(msg);
					end

					if #TreasureCtrl.TreasureList > 0 then
						MainUI.ShowTreasureBtn();
					end

					local msg = {cmd = "open_yiwu",boxId = param.boxId};
					Send(msg);
					Fight.DoJumpState(ds, SourceType.System, "Die", 0);

				end)
			end
			UIGetYiWu.Destroy();
		end)
		-- --装备格子生成控制器
		-- UIOpenTreasure.Refresh();
	end

	function UIGetYiWu.Update()
		local NowSecond = TimerManager.GetServerNowSecond();
		local DestroySecond = ds.box_time;
		local RemainingSecond  = DestroySecond - NowSecond;
		-- print("DestroySecond:"..DestroySecond)
		-- print("NowSecond:"..NowSecond)
		if RemainingSecond <= 0 then
			UIGetYiWu.Destroy()
		else
			local minute = math.floor(RemainingSecond/60);
			local second = RemainingSecond%60;
			-- print("RemainingSecond:"..RemainingSecond)
			-- print("minute:"..minute)
			-- print("second:"..second)
			local str = "<color=#8DDD10>"..minute.."分"..second.."秒</color>后消失";
			UIGetYiWu.TimeText.text = str;
		end
	end

	function UIGetYiWu.Destroy()
		destroy(this.gameObject);
	end
	return UIGetYiWu;
end


