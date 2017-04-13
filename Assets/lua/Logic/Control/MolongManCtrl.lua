--
-- 魔龙岛商人触发控制
--

MolongManCtrl = {}

-- MolongManCtrl.Start = function(go)
-- 	-- bind callback
-- 	local t = go:GetComponent("CircleTrigger");
-- 	t:BindEnterCallBack(MolongManCtrl.Enter)
-- 	t:BindLeaveCallBack(MolongManCtrl.Leave)
-- end

--进入 
MolongManCtrl.Enter = function()
	client.rightUpConfirm.Show("是否进行魔龙之心兑换？", function()
    	-- 初始化显示的魔龙之心数量
    	ui.ShowMolongShop();
	end, nil);
end

--离开
MolongManCtrl.Leave = function()
	client.rightUpConfirm.Hide();
end 

MolongManCtrl.Stay = function()

end 

MolongManCtrl.OnDestroy = function()
	MolongManCtrl.Leave();
end 
