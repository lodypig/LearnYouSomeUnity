function UILegionListView ()
	local UILegionList = {};
	local this = nil;

	local curGo;
	function UILegionList.Start ()
		this = UILegionList.this;

		local commonDlgGO = UILegionList.panel:GO('CommonDlg');
		UILegionList.controller = createCDC(commonDlgGO)
		UILegionList.controller.SetButtonNumber(0);
		-- UILegionList.controller.SetButtonText(1,"申请");

		UILegionList.controller.bindButtonClick(0, UILegionList.Close);

		UILegionList.controller.activeButton(1);
       	UILegionList.InitContent();
	end

	-- 初始化content内容，数据发生变化 且界面在打开时 外部调用此方法即可
	function UILegionList.InitContent()
		table.sort( client.legion.LegionList, UILegionList.SortFunc );
        local legionCount = #client.legion.LegionList; 
        local warpContent = UILegionList.container:GetComponent("UIWarpContent");
        warpContent.goItemPrefab = UILegionList.itemPrefab.gameObject;
        warpContent:BindInitializeItem(UILegionList.FormatItem);
        warpContent:Init(legionCount);
        -- 公会列表为空 页面显示"暂时没有可加入的公会",右侧公会宣言置空
        if legionCount > 0 then 
        	UILegionList.xuanyanText.text = "";
        	-- 初始化当前选中的go为content第一个,设置选中态和右侧宣言内容
        	curGo = UILegionList.content:GO('0');
        	curGo:GO('spSelected').gameObject:SetActive(true);
        	UILegionList.xuanyanText.text = curGo:GetUserData("xuanyan");
        	UILegionList.legionName.text = curGo:GetUserData("legionName");
        	
        else
        	UILegionList.xuanyanText.text = "";
        	UILegionList.legionName.text = "";
        end
	end 

	function UILegionList.FormatItem(go,index)
		local wrapper = go:GetComponent("UIWrapper");
        local legionInfo = client.legion.LegionList[index];
        local legionBaseTab = tb.legionBase[legionInfo.Level];

        wrapper:SetUserData("xuanyan", legionInfo.Declaration);
        wrapper:SetUserData("legionId", legionInfo.Id);
        wrapper:SetUserData("legionName", legionInfo.Name);

        wrapper:GO('name').text = legionInfo.Name;
        wrapper:GO('level').text = legionInfo.Level;
        wrapper:GO('count').text = legionInfo.MemberNum..'/'..legionBaseTab.maxmember;
        wrapper:GO('leader').text = legionInfo.JunTuanZhang;
        wrapper:GO('spSelected').gameObject:SetActive(false);
        wrapper:BindButtonClick(UILegionList.OnItemClick);
	end

	-- 优先显示未满员的公会；
	-- 优先显示人数最多的公会；
	-- 优先显示公会等级较高的公会；
	function UILegionList.SortFunc(info1,info2)

		local legionBaseTab1 = tb.legionBase[info1.Level];
		local legionBaseTab2 = tb.legionBase[info2.Level];

		local capacity1 = legionBaseTab1.maxmember - info1.MemberNum;
		local capacity2 = legionBaseTab2.maxmember - info2.MemberNum;

		if  capacity1 > 0 and capacity2 <= 0 or capacity1 <= 0 and capacity2 > 0 then -- 异或操作
			return capacity1 > 0;
		elseif info1.MemberNum ~= info2.MemberNum then
			return info1.MemberNum > info2.MemberNum;
		else
			return info1.Level > info2.Level;
		end
	end

	-- 取消上次选中go的选中状态，将右侧宣言设置为当前点击的wrapper中的数据
	function UILegionList.OnItemClick(go)
		if curGo ~= nil then
			curGo:GetComponent("UIWrapper"):GO('spSelected').gameObject:SetActive(false);
		end
		UILegionList.xuanyanText.text = go:GetComponent("UIWrapper"):GetUserData("xuanyan");
		UILegionList.legionName.text = go:GetComponent("UIWrapper"):GetUserData("legionName");

		go:GetComponent("UIWrapper"):GO('spSelected').gameObject:SetActive(true);
		curGo = go;
	end

	function UILegionList.Close()
		destroy(this.gameObject);
	end

	return UILegionList;
end
ui.ShowLegionList = function ()
    PanelManager:CreatePanel('UILegionList',UIExtendType.TRANSMASK, {});
end