function UILegionHongBaoView ()
	local UILegionHongBao = {};
	local this = nil;

	local Container = nil;
	local itemPrefab = nil;
	local container = nil;
	local item = nil;
	local sendPacketPanel = nil;
	local title = nil;
	local sendRedPacketBtn = nil;
	local value = nil;

	local couldSendContainer= nil;
	local couldSendItemPrefab= nil;
	local couldReceiveContainer= nil;
	local couldReceiveItemPrefab= nil;


	local couldSendList = nil;
	local couldReceiveList = nil;

	local hongBaoWZSprite = {[1] = "an_lingqu",
							[2] = "an_weifa",
							[3] = "an_chakan"};


	function UILegionHongBao.Start ()
		this = UILegionHongBao.this;
		couldSendContainer = this:GO('couldSend._Container');
		couldSendItemPrefab = this:GO('couldSend._Container.Viewport._itemPrefab').gameObject;
		couldReceiveContainer = this:GO('couldReceive._container');
		couldReceiveItemPrefab = this:GO('couldReceive._container.Viewport._item').gameObject;

		sendPacketPanel = this:GO('_sendPanel');
		
		value = this:GO('_sendPanel.hongBao.bottom.panel.total._value');

		-- 设置界面名称、关闭按钮绑定销毁事件
		local commonDlgGO = this:GO('CommonDlg3');
        UILegionHongBao.controller = createCDC(commonDlgGO);
        UILegionHongBao.controller.SetTitle("wz_juntuanhongbao");
        UILegionHongBao.controller.bindButtonClick(0,UILegionHongBao.Close);

       	UILegionHongBao.InitContent();
	end

	function UILegionHongBao.InitContent()
		couldSendList,couldReceiveList = client.legion.get_mynotsend_and_other_Packets();

		-- 自己的 可发送红包
        local couldSendCount = #couldSendList;
        local couldSendWarpContent = couldSendContainer:GetComponent("UIWarpContent");
        couldSendWarpContent.goItemPrefab = couldSendItemPrefab;
        couldSendWarpContent:BindInitializeItem(UILegionHongBao.FormatCouldSendItem);
        couldSendWarpContent:Init(couldSendCount);
        this:GO('couldSend.blank').gameObject:SetActive(couldSendCount == 0);

        -- 其他的红包 包括 可领取的、别人未发送的、可以查看的
        table.sort( couldReceiveList, function (packetInfo1,packetInfo2)
        	local packetType1 = client.legion.get_RedPacket_ShowType(packetInfo1);
        	local packetType2 = client.legion.get_RedPacket_ShowType(packetInfo2);

        	if packetType1 ~= packetType2 then
        		return client.legion.get_RedPacket_ShowType(packetInfo1) < client.legion.get_RedPacket_ShowType(packetInfo2);
        	else
        		return packetInfo1.SendTime < packetInfo2.SendTime;
        	end
        end);

        local couldReceiveCount = #couldReceiveList;
        local couldReceiveWarpContent = couldReceiveContainer:GetComponent("UIWarpContent");
        couldReceiveWarpContent.goItemPrefab = couldReceiveItemPrefab;
        couldReceiveWarpContent:BindInitializeItem(UILegionHongBao.FormatCouldReceiveItem);
        couldReceiveWarpContent:Init(couldReceiveCount);
        this:GO('couldReceive.blank').gameObject:SetActive(couldReceiveCount == 0);
	end 

	function UILegionHongBao.FormatCouldSendItem(go,index)
		local wrapper = go:GetComponent("UIWrapper");
        local packetInfo = couldSendList[index];

		local shortTitle = client.legion.get_redpacket_name(packetInfo,1);
		local longTitle = client.legion.get_redpacket_name(packetInfo,2);
        wrapper:GO('type').text = shortTitle;

        wrapper:SetUserData("longTitle", longTitle);
        wrapper:SetUserData("Grade", packetInfo.Grade);
        wrapper:SetUserData("Id", packetInfo.Id);

        wrapper:BindButtonClick(UILegionHongBao.SendPacket);
	end

	function UILegionHongBao.SendPacket(go)
		local wrapper = go:GetComponent("UIWrapper");
		local totalDiamond = sendPacketPanel:GO('hongBao.bottom.panel.total._value');
		local packetTitle = sendPacketPanel:GO('hongBao._title');
		local close = sendPacketPanel:GO('bg');
		local sendPacketBtn = sendPacketPanel:GO('hongBao.bottom._sendRedPacketBtn');
		local amount = sendPacketPanel:GO('hongBao.bottom.panel.amount');

		local packetCfg = tb.legionredpackets[wrapper:GetUserData("Grade")];

		sendPacketPanel.gameObject:SetActive(true);
		close:BindButtonClick(UILegionHongBao.CloseSendPanel);

		-- 初始值设置
		totalDiamond.text = packetCfg.totaldiamond;
		packetTitle.text = wrapper:GetUserData("longTitle");
		amount:GO('Text').text = packetCfg.defaultnum;
		
		BindNumberChange(amount, packetCfg.minnum, packetCfg.maxnum);

		sendPacketBtn:BindButtonClick(function ()
				local count = tonumber(amount:GO('Text').text)
				if count < packetCfg.minnum then
					ui.showMsg("数量不能低于最小额度")
					return
				end
				client.legion.send_Red_Packets(wrapper:GetUserData("Id"),tonumber(amount:GO('Text').text));	
			-- body
		end); 
	end 

	function UILegionHongBao.onSendSuccess() -- 发送成功之后关闭发送红包面板，刷新整个红包界面
		UILegionHongBao.CloseSendPanel();
		UILegionHongBao.InitContent();
	end

	function UILegionHongBao.CloseSendPanel()
		sendPacketPanel.gameObject:SetActive(false);
	end

	function UILegionHongBao.FormatCouldReceiveItem(go,index)
		local wrapper = go:GetComponent("UIWrapper");
        local packetInfo = couldReceiveList[index];
        local packetType = client.legion.get_RedPacket_ShowType(packetInfo); -- 三种状态，可领、未发、查看
        local packetCfg = tb.legionredpackets[packetInfo.Grade];

		local Title = client.legion.get_redpacket_name(packetInfo,2);

        wrapper:GO('name.text').text = packetInfo.OwnerName;
        wrapper:GO('type').text = Title;
        -- 类型决定红包标识是否打开 及 文字显示
        local closeGo = wrapper:GO('close');
        local openGo = wrapper:GO('open');

        closeGo.gameObject:SetActive(packetType ~= 3);
    	openGo.gameObject:SetActive(packetType == 3);

        wrapper:GO('operate').sprite = hongBaoWZSprite[packetType];
        wrapper:GO('totalCount.value').text = client.legion.get_redpacket_totaldiamond(packetInfo)

        wrapper:BindButtonClick(function ()
        	if packetType == 2 then
        		ui.showMsg("红包还未发出");
        	else
        		client.legion.draw_Red_Packets(packetInfo.Id);
        	end
        end)-- 点击之后若成功应打开红包结果界面，并刷新红包界面
	end 

	function UILegionHongBao.Close()
		destroy(this.gameObject);
	end

	return UILegionHongBao;
end
