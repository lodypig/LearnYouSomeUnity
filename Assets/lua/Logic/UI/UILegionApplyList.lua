function UILegionApplyListView ()
	local UILegionApplyList = {};
	local this = nil;

	-- local clearBtn = nil;

	local chooseList = {};
	local warpContent = nil;
	local selectAll = 0;

	function UILegionApplyList.Start ()
		this = UILegionApplyList.this;

        UILegionApplyList.close:BindButtonClick(UILegionApplyList.Close)
       	UILegionApplyList.InitContent();



      --  	clearBtn:BindButtonClick(function ()
      --       if #client.legion.ApplicantList == 0 then
      --           ui.showMsg("暂时无人申请加入公会");
      --           return
      --       end
   			-- client.legion.Refuse_All_Applicant(UILegionApplyList.InitContent); -- 全部拒绝成功之后要刷新申请列表	
      --  	end);
      	UILegionApplyList.chooseAll:BindButtonClick(function ()
      		selectAll = 1- selectAll;
      		UILegionApplyList.SelectAll();
      	end)

        UILegionApplyList.pass:BindButtonClick(UILegionApplyList.OnConfirmClick);
        UILegionApplyList.refuse:BindButtonClick(UILegionApplyList.OnRejectClick);
	end


	function UILegionApplyList.InitContent()
        local applyCount = #client.legion.ApplicantList;
       	for i=1,#client.legion.ApplicantList do 
       		chooseList[i] = 0;
       	end
       	if applyCount >= 1 then
       		chooseList[1] = 1;
        end
        warpContent = UILegionApplyList.container:GetComponent("UIWarpContent");
        warpContent.goItemPrefab = UILegionApplyList.itemPrefab.gameObject;
        warpContent:BindInitializeItem(UILegionApplyList.FormatItem);
        warpContent:Init(applyCount);
        -- 公会列表为空 页面显示"暂时无人申请"
    	UILegionApplyList.blank.gameObject:SetActive(applyCount == 0);

	end 

	function UILegionApplyList.SelectAll()
		if selectAll == 1 then
			for i=1,#chooseList do
				chooseList[i] = 1
			end
			warpContent:Refresh(#client.legion.ApplicantList)
			UILegionApplyList.chooseAll:GO('dagou').gameObject:SetActive(true)
		else
			for i=1,#chooseList do
				chooseList[i] = 0
			end
			warpContent:Refresh(#client.legion.ApplicantList)
			UILegionApplyList.chooseAll:GO('dagou').gameObject:SetActive(false)
		end
	end

	function UILegionApplyList.FormatItem(go,index)
		local wrapper = go:GetComponent("UIWrapper");
        local memberInfo = client.legion.ApplicantList[index];

        wrapper:GO('name').text = memberInfo.Name;
        wrapper:GO('level').text = memberInfo.Level;
        wrapper:GO('fightPoint').text = memberInfo.FightAbility;
        wrapper:GO('time').text = UILegionApplyList.FormatApplyTime(memberInfo.ApplyTime);

        -- wrapper:SetUserData("Id", memberInfo.Id);
		wrapper:SetUserData("index", index);
        if chooseList[index] == 1 then
        	wrapper:GO('kuang.dagou').gameObject:SetActive(true);
        else
        	wrapper:GO('kuang.dagou').gameObject:SetActive(false);
        end

        wrapper:BindButtonClick(function (go)
        	local wrap = go:GetComponent('UIWrapper');
        	local index = wrap:GetUserData("index")
        	chooseList[index] = 1 - chooseList[index];
        	warpContent:Refresh(#client.legion.ApplicantList);
        end)
        -- wrapper:GO('agree'):BindButtonClick(function () UILegionApplyList.OnConfirmClick(wrapper) end);
        -- wrapper:GO('reject'):BindButtonClick(function () UILegionApplyList.OnRejectClick(wrapper) end);
	end

	function UILegionApplyList.OnConfirmClick()
		if #client.legion.ApplicantList == 0 then
			ui.showMsg("暂时无人申请加入公会")
			return
		end
		if UILegionApplyList.CheckIsAllZero() then
			ui.showMsg("请先选择申请信息")
			return
		end

		for i=1,#chooseList do
			if chooseList[i] == 1 and client.legion.ApplicantList[i] then 
				client.legion.allow_Applicant_Join_In(client.legion.ApplicantList[i].Id,function ()
					chooseList[i] = 0
					warpContent:Refresh(#client.legion.ApplicantList)
    				UILegionApplyList.blank.gameObject:SetActive(#client.legion.ApplicantList == 0);
				end); -- 同意之后需要刷新申请列表
			end
		end

	end

	function UILegionApplyList.OnRejectClick(wrapper)
		if #client.legion.ApplicantList == 0 then
			ui.showMsg("暂时无人申请加入公会")
			return
		end
		if UILegionApplyList.CheckIsAllZero() then
			ui.showMsg("请先选择申请信息")
			return
		end

		for i=1,#chooseList do
			if chooseList[i] == 1 and client.legion.ApplicantList[i] then 
				client.legion.Refuse_Applicant_Join_In(client.legion.ApplicantList[i].Id,function ()
					chooseList[i] = 0
					warpContent:Refresh(#client.legion.ApplicantList)
    				UILegionApplyList.blank.gameObject:SetActive(#client.legion.ApplicantList == 0);
				end); -- 拒绝之后需要刷新申请列表
			end
		end
	end

	function UILegionApplyList.CheckIsAllZero()
		for i=1,#chooseList do
			if chooseList[i] == 1 then
				return false
			end
		end
		return true
	end
	-- -- 按照申请时间排序 将最近申请靠前
	-- function UILegionApplyList.SortFunc(info1,info2)
	-- 	return info1.applyTime > info2.applyTime; 
	-- end

    function UILegionApplyList.FormatApplyTime(t)
        local now = TimerManager.GetServerNowMillSecond()/1000;
        local intervalTime = now - t;
        local str = "刚刚";
        if intervalTime >= 2592000 then
        	str = string.format("%d月前",math.modf(intervalTime/2592000));
        elseif intervalTime >= 86400 then
            str = string.format("%d天前",math.modf(intervalTime/86400));
        elseif intervalTime > 3600 then
            str = string.format("%d小时前",math.modf(intervalTime/3600));
        elseif intervalTime > 60 then
            str = string.format("%d分钟前",math.modf(intervalTime/60));
        end
        return str;
    end

	function UILegionApplyList.Close()
		destroy(this.gameObject);
	end

	return UILegionApplyList;
end
