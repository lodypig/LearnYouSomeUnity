--秘境NPC身上挂着的触发器
cbtMJCtrl = {}

cbtMJCtrl.bActiveCheck = false
cbtMJCtrl.bTime2StarAction = 0
cbtMJCtrl.OneTimeNotCheck = false

cbtMJCtrl.handleOK = function(msgTable)
    local MJType = msgTable["mijing_type"];
    if "normal" == MJType then
        ui.showMsg("消耗1把银钥匙");
    else
        ui.showMsg("消耗1把金钥匙");
    end
end

cbtMJCtrl.handleFail = function(msgTable)
    local reason = msgTable["reason"];
    if "alread_closed" == reason then
        ui.showMsg("秘境入口已经关闭");
    else
        local MJType = msgTable["mijing_type"];
        local countStr;
        local yaoshiStr;
        if "super" == MJType then
            countStr = "高级宝库"
            yaoshiStr = "金钥匙"
        else
            countStr = "宝库"
            yaoshiStr = "银钥匙"
        end
        if "count_limit" == reason then
            ui.showMsg(string.format("今日%s次数已用完", countStr));
        elseif "consume_limit" == reason then
            ui.showMsg(string.format("%s数量不足", yaoshiStr));
        else
            ui.showMsg("未知原因失败");
        end
    end
end


cbtMJCtrl.OnDestroy = function(ds)
	-- 销毁
    client.rightUpConfirm.Hide();
end

--进入 
cbtMJCtrl.Enter = function(ds)
    cbtMJCtrl.bActiveCheck = true
end

--离开
cbtMJCtrl.Leave = function(ds)
	--取消检查功能
	cbtMJCtrl.bActiveCheck = false
	cbtMJCtrl.bTime2StarAction = 0
	client.rightUpConfirm.Hide()
	--hide messagebox
end 

--开始计算0.3传送延迟起始时间
cbtMJCtrl.Stay = function(ds)
	if cbtMJCtrl.bActiveCheck == true then
		--是否停止走动
		if cbtMJCtrl.CheckMove() then
			--重新计时
			cbtMJCtrl.bTime2StarAction = 0
			return
		end
		if cbtMJCtrl.bTime2StarAction == 0 then
			--开始0.3s后传送计时
			cbtMJCtrl.bTime2StarAction = TimerManager.GetServerNowMillSecond()
		elseif cbtMJCtrl.bTime2StarAction > 0 and TimerManager.GetServerNowMillSecond() - PortalCrystal.bTime2StarAction >= 100 then		--检查循环本来就有延迟 这里只设置100ms
			--开始传送
			cbtMJCtrl.ActionEvent(ds)
			--
			cbtMJCtrl.bActiveCheck = false
			cbtMJCtrl.bTime2StarAction = 0
		end
	end
end  

cbtMJCtrl.CheckMove = function()

	local player = AvatarCache.me;
	local is_auto_fighting = player.is_auto_fighting;
	if is_auto_fighting then
	 	return true
	end
	-- if controller:IsMoving() or controller:IsRouting() then
	-- 	return true
	-- end
	return false
end

cbtMJCtrl.ActionEvent = function(ds)
	client.rightUpConfirm.Show("是否要进入宝库？", function()
       cbtMJCtrl.enter_mijing(ds)
	end, nil)
end

 --进入秘境
cbtMJCtrl.enter_mijing = function (ds)
		local msg = {cmd = "enter_mijing", npc = ds.id};        
        Send(msg, function(msg)             
            local rType = msg["type"];
            if rType == "ok" then
                cbtMJCtrl.handleOK(msg);
            else
                cbtMJCtrl.handleFail(msg);
            end
        end); 
	end

