function UIJoinLegionView ()
	local UIJoinLegion = {};
	local this = nil;

	local curGo = nil;
    local oldPos;
    local nameEditBox;
    local xuanyanEditBox;

    local errMsg = {
		nameillegalChar = "您输入的公会名字含有非法字符，请重新输入",
		xuanyanillegalChar = "您输入的公会宣言含有非法字符，请重新输入",
		nametooShort = "公会名称的长度不得少于4个字符，请重新输入",
	}


	function UIJoinLegion.Start ()
		this = UIJoinLegion.this;

		local commonDlgGO = UIJoinLegion.panel:GO('CommonDlg');
		UIJoinLegion.controller = createCDC(commonDlgGO)
		UIJoinLegion.controller.SetButtonNumber(2);
		UIJoinLegion.controller.SetButtonText(1,"申请");
		UIJoinLegion.controller.bindButtonClick(1, function () UIJoinLegion.showPanel(1); end);		
		UIJoinLegion.controller.SetButtonText(2,"创建");
		UIJoinLegion.controller.bindButtonClick(2, function () UIJoinLegion.showPanel(2); end);
		UIJoinLegion.controller.bindButtonClick(0, UIJoinLegion.Close);

		UIJoinLegion.controller.activeButton(1);
       	UIJoinLegion.InitContent();
       	UIJoinLegion.InitCreatePanel();
       	UIJoinLegion.applyBtn:BindButtonClick(UIJoinLegion.OnApplyClick);
       	UIJoinLegion.connectBtn:BindButtonClick(ui.unOpenFunc);
	end

	-- 初始化content内容，数据发生变化 且界面在打开时 外部调用此方法即可
	function UIJoinLegion.InitContent()
		table.sort( client.legion.LegionList, UIJoinLegion.SortFunc );
        local legionCount = #client.legion.LegionList; 
        local warpContent = UIJoinLegion.container:GetComponent("UIWarpContent");
        warpContent.goItemPrefab = UIJoinLegion.itemPrefab.gameObject;
        warpContent:BindInitializeItem(UIJoinLegion.FormatItem);
        warpContent:Init(legionCount);
        -- 公会列表为空 页面显示"暂时没有可加入的公会",右侧公会宣言置空
        if legionCount > 0 then 
        	UIJoinLegion.blank.gameObject:SetActive(false);
        	UIJoinLegion.xuanyanText.text = "";
        	-- 初始化当前选中的go为content第一个,设置选中态和右侧宣言内容
        	curGo = UIJoinLegion.content:GO('0');
        	curGo:GO('spSelected').gameObject:SetActive(true);
        	UIJoinLegion.xuanyanText.text = curGo:GetUserData("xuanyan");
        	UIJoinLegion.legionName.text = curGo:GetUserData("legionName");
        	
        else
        	UIJoinLegion.blank.gameObject:SetActive(true);
        	UIJoinLegion.xuanyanText.text = "";
        	UIJoinLegion.legionName.text = "";
        end
	end 

	function UIJoinLegion.FormatItem(go,index)
		local wrapper = go:GetComponent("UIWrapper");
        local legionInfo = client.legion.LegionList[index];
        local legionBaseTab = tb.legionBase[legionInfo.Level];

        wrapper:SetUserData("xuanyan", legionInfo.Declaration);
        wrapper:SetUserData("legionId", legionInfo.Id);
        wrapper:SetUserData("legionName", legionInfo.Name);

        wrapper:GO('dagou').gameObject:SetActive(legionInfo.applyFlag == 'true');
        wrapper:GO('name').text = legionInfo.Name;
        wrapper:GO('level').text = legionInfo.Level;
        wrapper:GO('count').text = legionInfo.MemberNum..'/'..legionBaseTab.maxmember;
        wrapper:GO('leader').text = legionInfo.JunTuanZhang;
        wrapper:GO('spSelected').gameObject:SetActive(false);
        wrapper:BindButtonClick(UIJoinLegion.OnItemClick);
	end

	-- 优先显示未满员的公会；
	-- 优先显示人数最多的公会；
	-- 优先显示公会等级较高的公会；
	function UIJoinLegion.SortFunc(info1,info2)

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
	function UIJoinLegion.OnItemClick(go)
		if curGo ~= nil then
			curGo:GetComponent("UIWrapper"):GO('spSelected').gameObject:SetActive(false);
		end
		UIJoinLegion.xuanyanText.text = go:GetComponent("UIWrapper"):GetUserData("xuanyan");
		UIJoinLegion.legionName.text = go:GetComponent("UIWrapper"):GetUserData("legionName");

		go:GetComponent("UIWrapper"):GO('spSelected').gameObject:SetActive(true);
		curGo = go;
	end

	function UIJoinLegion.OnApplyClick()
		if curGo == nil then
			ui.showMsg("当前没有可加入的公会");
			return
		end
		
		client.legion.apply_Join_Legion(curGo:GetComponent("UIWrapper"):GetUserData('legionId'),curGo:GetComponent("UIWrapper"):GetUserData('legionName'),function ()
			curGo:GetComponent("UIWrapper"):GO('dagou').gameObject:SetActive(true); -- 申请成功在该栏前打钩
		end);
	end

	function UIJoinLegion.showPanel(index)
		UIJoinLegion.joinPanel.gameObject:SetActive(index == 1);
		UIJoinLegion.createPanel.gameObject:SetActive(index == 2);
	end

	-- 初始化创建面板的显示
	function UIJoinLegion.InitCreatePanel()
		oldPos = UIJoinLegion.panel:GetComponent('Transform').localPosition;
		UIJoinLegion.costValue.text = const.createLegionCost;
		UIJoinLegion.textCount.text = string.format("0/%d",client.legion.XuanYanCharacterLimit/2)
		-- 点击输入框以外的位置，关闭输入框
		UIJoinLegion.panel:BindButtonClick(UIJoinLegion.CloseKeyBoard);
		-- 输入框相关,一个输入名称，一个输入宣言
		UIJoinLegion.inputName.inputText = "";
		UIJoinLegion.inputXuanYan.inputText = "";

		nameEditBox = UIJoinLegion.inputName:GetComponent('EditBox');
		nameEditBox.characterLimit = client.legion.NameCharacterLimit
		nameEditBox.iscenter = true

		xuanyanEditBox = UIJoinLegion.inputXuanYan:GetComponent('EditBox');
		xuanyanEditBox.characterLimit = client.legion.XuanYanCharacterLimit
		xuanyanEditBox.iscenter = true
		xuanyanEditBox.multiline = true
		
		UIJoinLegion.inputName:BindButtonClick(UIJoinLegion.nameOpenKeyBoard);
		UIJoinLegion.inputXuanYan:BindButtonClick(UIJoinLegion.xuanyanOpenKeyBoard);

        nameEditBox:SetCallBack(UIJoinLegion.OnHeightChange, UIJoinLegion.nameEditResult);
        xuanyanEditBox:SetCallBack(UIJoinLegion.OnHeightChangeXuanYan, UIJoinLegion.xuanyanEditResult);

		UIJoinLegion.inputName:BindInputFiledValueChanged(UIJoinLegion.nameInputChanged);
		UIJoinLegion.inputXuanYan:BindInputFiledValueChanged(UIJoinLegion.xuanyanInputChanged);

		-- 创建公会按钮事件
		UIJoinLegion.createLegion:BindButtonClick( function ()
			local legionName = UIJoinLegion.inputName.inputText;
			local legionXuanyan = UIJoinLegion.inputXuanYan.inputText;

			if legionName == "" then
				ui.showMsg("请输入公会名！")
				return
			end
			if StrFiltermanger.Instance:IsFileter(legionName) then
				ui.showMsg(errMsg.nameillegalChar)
				return
			end
			if Util.StringByteLength(legionName) < client.legion.NameCharacterMinLimit then
				ui.showMsg(errMsg.nametooShort)
				return
			end
			if legionXuanyan == "" then
				ui.showMsg("请输入公会宣言！")
				return
			end
			if StrFiltermanger.Instance:IsFileter(legionXuanyan) then
				ui.showMsg(errMsg.xuanyanillegalChar)
				return
			end

			if DataCache.role_diamond < const.createLegionCost then 
				ui.showMsg("创建失败，创建公会需要花费988个钻石");
			else
				--[[创建公会回调，
					传递的param为legionName和legionXuanyan
					判断公会名称是否符合规范，失败则重要信息区提示
					成功则获取到公会信息，同时调用UIJoinLegion.Close
				]]
				client.legion.send_create_Msg(legionName, legionXuanyan);	
			end
		end);
	end

	function UIJoinLegion.OnHeightChange(posY)		
		UIJoinLegion.panel:GetComponent('Transform').localPosition = Vector3.New(oldPos.x, oldPos.y + posY, oldPos.z);
	end
	function UIJoinLegion.OnHeightChangeXuanYan(posY)		
		UIJoinLegion.panel:GetComponent('Transform').localPosition = Vector3.New(oldPos.x, oldPos.y + posY, oldPos.z);
	end

	-- 打开键盘，获取已输入的文字
	function UIJoinLegion.nameOpenKeyBoard()
        local curText = UIJoinLegion.inputName.inputText;
        nameEditBox:showEditBox(curText);
    end
	function UIJoinLegion.xuanyanOpenKeyBoard()
        local curText = UIJoinLegion.inputXuanYan.inputText;
        xuanyanEditBox:showEditBox(curText);
    end

    -- editbox 点击发送时的回调
    function UIJoinLegion.nameEditResult(text)
    	UIJoinLegion.inputName.inputText = text;

    	UIJoinLegion.inputName.gameObject:SetActive(true);
    	UIJoinLegion.panel:GetComponent('Transform').localPosition = oldPos;
    end

    function UIJoinLegion.xuanyanEditResult(text)
    	UIJoinLegion.inputXuanYan.inputText = text;
    	UIJoinLegion.textCount.text = string.format("%d/%d",math.ceil( Util.StringByteLength(text)/2 ),client.legion.XuanYanCharacterLimit/2);	
    	UIJoinLegion.inputXuanYan.gameObject:SetActive(true);
    	UIJoinLegion.panel:GetComponent('Transform').localPosition = oldPos;
    end

    -- inputField发生变化时，更新文本框显示
	function UIJoinLegion.nameInputChanged(text, _inputIndex)
		UIJoinLegion.inputName.inputText = text;
	end

	function UIJoinLegion.xuanyanInputChanged(text, _inputIndex)
		UIJoinLegion.inputXuanYan.inputText = text;
		UIJoinLegion.textCount.text = string.format("%d/%d",math.ceil( Util.StringByteLength(text)/2 ),client.legion.XuanYanCharacterLimit/2);
	end

	-- 关闭键盘
    function UIJoinLegion.CloseKeyBoard()
		if NativeManager.GetInstance().isKeyboardOpened then
			NativeManager.GetInstance():CloseEditBox();
			UIJoinLegion.panel:GetComponent('Transform').localPosition = oldPos;
		end
    end

	function UIJoinLegion.Close()
		client.legion.UIJoinLegionAddListener = nil;
		UIJoinLegion.CloseKeyBoard();
		destroy(this.gameObject);
	end

	return UIJoinLegion;
end