function UILegionHongBaoResultView (param)
	local UILegionHongBaoResult = {};
	local this = nil;

	local photoImg = nil;
	local name = nil;
	local title = nil;
	local totalDiamond = nil;
	local result = nil;
	local container = nil;
	local content = nil;
	local myDiamond = nil;
	local itemPrefab = nil
	local closeBtn = nil

	local packetInfo = nil;
	local packetCfg = nil;
	local isBlank = nil;

	local imgTab  = {
					["soldier"] = {"tx_soldier_0","tx_soldier_1"},
					["bowman"] = {"tx_bowman_0","tx_bowman_1"},
					["magician"] = {"tx_magician_1","tx_magician_1"}
				};

	function UILegionHongBaoResult.Start ()
		this = UILegionHongBaoResult.this;
		photoImg = this:GO('panel.hongBao.photo._img');
		name = this:GO('panel.hongBao._name');
		title = this:GO('panel.hongBao._title');
		myDiamond = this:GO('panel.hongBao.amount._value');
		result = this:GO('panel.hongBao.bottom._result');
		container = this:GO('panel.hongBao.bottom._container');
		content = this:GO('panel.hongBao.bottom._container.Viewport._content');
		itemPrefab = this:GO('panel.hongBao.bottom._container.Viewport.item').gameObject;
		closeBtn = this:GO('panel.bg');

		-- this:GO('panel.hongBao._title'):PlayUIEffect(this.gameObject, "kaihongbao",4);

		closeBtn:BindButtonClick(UILegionHongBaoResult.Close);
		UILegionHongBaoResult.InitContent();
	end

	function UILegionHongBaoResult.InitContent()
        packetInfo = param.packetinfo;
        local receiveCount = client.legion.get_draw_packets_num(packetInfo); -- 已领红包个数
        local packetNum = packetInfo.PacketNum;				
        local warpContent = container:GetComponent("UIWarpContent");

        local diamondReceived = client.legion.get_draw_packets_diamond(packetInfo);	-- 已领取的钻石总数
        local diamondTotal = client.legion.get_redpacket_totaldiamond(packetInfo);	-- 红包中钻石总数
        local myDiamondRecived = client.legion.self_drawed(packetInfo);  			-- 我自己领取的钻石数量

        isBlank = (receiveCount == packetNum); 					-- 领完标志

        warpContent.goItemPrefab = itemPrefab;
        warpContent:BindInitializeItem(UILegionHongBaoResult.FormatItem);
        warpContent:Init(receiveCount);
        photoImg.sprite = imgTab[packetInfo.Career][packetInfo.Sex + 1];
        name.text = packetInfo.OwnerName ..'的红包';
        title.text = client.legion.get_redpacket_name(packetInfo,2);

        
        if myDiamondRecived == 0 then   -- 没抢到
    		this:GO('panel.hongBao.amount').gameObject:SetActive(false);
    		this:GO('panel.hongBao.tip').gameObject:SetActive(true);
    	else
    		this:GO('panel.hongBao.amount').gameObject:SetActive(true);
    		myDiamond.text = myDiamondRecived;
    		this:GO('panel.hongBao.tip').gameObject:SetActive(false);
        end   
        if isBlank then  -- 钻石已领完
	        result.text = packetNum.."个红包共"..diamondTotal.."钻石，已被抢完";       	
	    else			 -- 钻石没领完 
	        result.text = string.format("数量%s/%s个,共%s/%s钻石", receiveCount,packetNum,diamondReceived,diamondTotal);
	    end    
	end 

	function UILegionHongBaoResult.FormatItem(go,index)
		local wrapper = go:GetComponent("UIWrapper");
        local memberInfo = packetInfo.MemberList[index];

        wrapper:GO('flag').gameObject:SetActive( isBlank and (index == client.legion.get_most_draw_index(packetInfo)) );
        wrapper:GO('name').text = memberInfo[1];
        wrapper:GO('value').text = memberInfo[2];
	end

	function UILegionHongBaoResult.Close()
		destroy(this.gameObject);
	end

	return UILegionHongBaoResult;
end
