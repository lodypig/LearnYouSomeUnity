

function UIAreaMapView (param)
	local UIAreaMap = {};
	local this = nil;

    local NPCEffectName = "ditufankui_npc"
    local GuaiEffectName = "ditufankui_guai"

	--UI
	local CurMap = nil;
    local fenXianText = nil;
	local thumbnail = nil;
	local mapImg = nil;
	local path_cell = nil;
	local paths = nil;
	local obj = nil;
	local me = nil;
	local nails = nil;
	local nail = nil;
    local nailInfo = nil;
	local duiyou = nil;
	local duiyous = nil;
	local listpopup = nil;
	local viewport = nil;
	local npclstcontent = nil;
	local prefab = nil;
	local titlename = nil;
	local CM_titleSprite = nil;
    local fenxianPanel = nil;
    local fenxianContent = nil;
    local fenxianPrefab = nil;

	--data
	local npclist = {}
	local npcitemlist = {}
	local npcinfolist = {}
	local npcnaillist = {}
    local fenxianitemlist = {}

	--logic
	local mapImgSize = nil;
	local mapSize = nil;
	local mapImgScale_x = nil;
	local mapImgScale_y = nil;

	local CM_mapsid = nil;

	local curPage = nil
	local PAGE_CURRENT = 1
	local PAGE_WORLD = 2

    local selectIndex
    local curNail
    local curSelectItem = nil;

    local fenxianChangeFlag = false;

	function UIAreaMap.Start()		
		this = UIAreaMap.this;
		----------------当前地图------------------
		CurMap = this:GO('_curMap');
		fenXianText = this:GO('_curMap._fenXianText');
        thumbnail = this:GO('_curMap._thumbnail');
		mapImg = this:GO('_curMap._thumbnail._mapImg');
		path_cell = this:GO('_curMap._thumbnail._mapImg._path_cell');
		paths = this:GO('_curMap._thumbnail._mapImg._paths');
		obj = this:GO('_curMap._thumbnail._mapImg._obj');
		me = this:GO('_curMap._thumbnail._mapImg._me');
		nails = this:GO('_curMap._thumbnail._mapImg._nails');
		nail = this:GO('_curMap._thumbnail._mapImg._nail');
        nailInfo = this:GO('_curMap._thumbnail._mapImg._nails._nailInfo');
		duiyou = this:GO('_curMap._thumbnail._mapImg._duiyou');
		duiyous = this:GO('_curMap._thumbnail._mapImg._duiyous');
		listpopup = this:GO('_curMap._listpopup');
		viewport = this:GO('_curMap._listpopup._viewport');
		npclstcontent = this:GO('_curMap._listpopup._viewport._npclstcontent');
		prefab = this:GO('_curMap._listpopup._viewport._prefab');
		titlename = this:GO('_titleName');

        fenxianPanel = this:GO("_curMap.SwitchPanel");
        fenxianContent = this:GO("_curMap.SwitchPanel._listpopup._viewport");
		fenxianPrefab = this:GO('_curMap.SwitchPanel._listpopup._viewport.Panel._fenxianPrefab');

		this:GO("_curMap.BtnSwitch"):BindButtonClick(UIAreaMap.CM_ShowSwitchPanel);
        this:GO("_curMap.BtnGo"):BindButtonClick(UIAreaMap.CM_GoPathing);
		this:GO("_curMap.SwitchPanel"):BindButtonClick(UIAreaMap.CM_HideSwitchPanel);

		obj:Hide()
		prefab:Hide()
		mapImg:BindButtonClick(UIAreaMap.CM_ClickAutoPathing)
		UIAreaMap.CM_HideSwitchPanel() 

		-----------------------------------------------

		local commonDlgGO = this:GO('CommonDlg');	--这个是UIWrapper
		UIAreaMap.controller = createCDC(commonDlgGO)
		UIAreaMap.controller.SetButtonNumber(2);
		UIAreaMap.controller.SetButtonText(1,"当前");
		UIAreaMap.controller.SetButtonText(2,"世界");
		UIAreaMap.controller.bindButtonClick(0,UIAreaMap.closeSelf);
		UIAreaMap.controller.bindButtonClick(1,UIAreaMap.OpenCurMap);
		UIAreaMap.controller.bindButtonClick(2,UIAreaMap.OpenWorldMap,function ()
			if DataCache.scene_sid == tb.SceneAlias2Id["linfengpingyuan"] then
				ui.showMsg("当前区域无法打开世界地图");
				return false;
			else
				return true;
			end
		end);

		-----------------------------------------------
        UIAreaMap.InitMap()
		--默认打开当前地图
		if param.page == "curMap" then
			UIAreaMap.controller.activeButton(1)
		elseif param.page == "worldMap" then
			UIAreaMap.controller.activeButton(2)
		end

		--如果已经组队，则更新出队友位置所在的图标
		if client.team.team_uid ~= 0 then
			local teamList = client.team.getTeamList();
			for i=1,#teamList do
				UIAreaMap.UpdateTeamMemberNail(teamList[i].role_uid, teamList[i].pos, teamList[i].state, teamList[i].scene);
			end
		end

		EventManager.bind(this.gameObject,Event.ON_LEVEL_UP,UIAreaMap.handleLevelUp);		
	end

	function UIAreaMap.closeSelf()
		uFacadeUtility.ClearPathDrawer();
		client.areamap = nil;
        destroy(this.gameObject);
	end

	function UIAreaMap.Update()
		if curPage == PAGE_CURRENT then
			UIAreaMap.CM_UpdateMyPos()
		end
	end

	------------------------------------------------------------------------
	---
	--- 当前地图 
	---
	------------------------------------------------------------------------

	function UIAreaMap.OpenCurMap()
		curPage = PAGE_CURRENT
		--show it
		this:GO('_worldMap'):Hide()
		this:GO('_curMap'):Show()
		--title
		local sceneTable = tb.SceneTable[DataCache.scene_sid];		
		titlename.text = sceneTable.name;
		-- UIAreaMap.controller.SetTitle("wz_"..sceneTable.alias);
	end

    function UIAreaMap.InitMap()
		CM_mapsid = DataCache.scene_sid
		UIAreaMap.OpenMap()
        UIAreaMap.InitWorldMap()
	end

	function UIAreaMap.OpenMap()
        --nailInfo:Hide()
		UIAreaMap.CM_InitMapArea()
		UIAreaMap.CM_UpdateMyPos()
        UIAreaMap.CM_InitNpcList()
        UIAreaMap.CM_shownpclist()
        UIAreaMap.CM_shownpcnail()
        UIAreaMap.CM_handleDefaultSelect()
	end


    --处理默认选中。有npc为当前适宜挂机npc，默认选中
    function UIAreaMap.CM_handleDefaultSelect()
    	local msg = {cmd = "get_offline_npc"}
        Send(msg, function(returnMsg)
            local npcSid = returnMsg["npc"];
            for i=1,#npcinfolist do
                local v = npcinfolist[i]
                if npcSid == v.npc_id then
                    UIAreaMap.CM_ClickNpcListItem(npcitemlist[i])
                    break
                end
            end
		end)
    end

    --取消选中状态
    function UIAreaMap.CM_handleCancelSelect()
        if curSelectItem ~= nil then
			curSelectItem:GO('Select').gameObject:SetActive(false);
		end
        selectIndex = nil
        nailInfo:Hide()
        --todo停止特效
        if curNail ~= nil then
            curNail:GO("Effect"):StopUIEffect(GuaiEffectName);
            curNail:GO("Effect"):StopUIEffect(NPCEffectName);
		end
    end

	function UIAreaMap.CM_InitMapArea()
        fenXianText.text = string.format("%s", DataCache.fenxian)
		obj:Hide()
		prefab:Hide()
		local sceneAlias = tb.SceneTable[DataCache.scene_sid].alias;
		mapImg.sprite = sceneAlias;

		mapImg:GetComponent("Image"):SetNativeSize();
		local RectT = mapImg:GetComponent("RectTransform")
		mapImgSize = RectT.sizeDelta;
		-- RectT.anchoredPosition = Vector2.New(-mapImgSize.x/2, -mapImgSize.y/2)

		local sceneTable = tb.SceneTable[DataCache.scene_sid];
		local sceneW = sceneTable.sceneW;
		local sceneH = sceneTable.sceneH;

		mapSize = Vector2.New(sceneW,sceneH)

		mapImgScale_x = mapImgSize.x/sceneW;
		mapImgScale_y = mapImgSize.y/sceneH;

        if fenxianChangeFlag then
           UIAreaMap.closeSelf();
           ui.showMsg("换线成功")
        end

		uFacadeUtility.SetDrawUnit(path_cell.gameObject, paths.gameObject, obj.gameObject, mapImgScale_x, mapImgScale_y);
	end

--创建分线按钮
	function UIAreaMap.CM_AddFenXianItem(index, countInfo)
		local item = newObject(fenxianPrefab)
		item:BindButtonClick(UIAreaMap.CM_ClickFenXian_Callback)
  --       local countInfoStr = "流畅"
  --       if countInfo > 0 then
  --           countInfoStr = "拥挤"
  --       end
		-- item:GO('Text').text = string.format("%d线（%s）", index, countInfoStr)
		item:GO('Text').text = string.format("%s  线", const.NumberTable[index])
		item.transform.name = tostring(index)
		item.transform:SetParent(fenxianContent:GO("Panel").transform)
		item.transform.localScale = Vector3.one;
		item.transform.localPosition = Vector3.zero;
		item:Show()
        return item
	end
--销毁分线按钮
    function UIAreaMap.CM_ClearFenXianItem()
		for i=1,#fenxianitemlist do
			destroy(fenxianitemlist[i].gameObject)
		end
		fenxianitemlist = {}
	end

	--显示分线UI
	function UIAreaMap.CM_ShowSwitchPanel()
	
		local scene_info = tb.SceneTable[DataCache.scene_sid];
        if scene_info.fenxianFlag == "true" then
            UIAreaMap.CM_ClearFenXianItem();
            local msg = {cmd = "fenxian_count", scene_sid = CM_mapsid}
            --返回分线信息，0表示流畅，1表示拥挤
            Send(msg, function(returnMsg)
                local fenxianInfo = returnMsg["info"];
                -- print("#fenxianInfo:"..(#fenxianInfo))
                -- DataStruct.DumpTable(fenxianInfo)
                for i=1,#fenxianInfo do
                    fenxianitemlist[i] = UIAreaMap.CM_AddFenXianItem(i, fenxianInfo[i])
                end
                fenxianPanel.gameObject:SetActive(true);
            end)
        else
            ui.showMsg("该地图不能使用此功能")
        end
	end

	function UIAreaMap.CM_HideSwitchPanel() 
		fenxianPanel.gameObject:SetActive(false);
	end


	function UIAreaMap.CM_ClickFenXian_Callback(go)
    	local fenxian = tonumber(go.transform.name);
        if DataCache.fenxian == fenxian then
            ui.showMsg("你已经在这个分线中！")
        else
            local msg = {cmd = "fenxian_transmit", fenxian_id = fenxian}
            StopPathing();
            fenxianChangeFlag = true;
            Send(msg, function() 
            end)
        end
        UIAreaMap.CM_HideSwitchPanel() 
	end


	function UIAreaMap.CM_AddNPCItem(v, index)
		local item = newObject(prefab)
		item:BindButtonClick(UIAreaMap.CM_ClickNpcListItem)
		item:GO('Text').text = v.name
		item:GO('Text').textColor = Color.New(208/255, 176/255, 127/255);
		item:GO('Icon').sprite = v.iconname;
		item:GO('Select').gameObject:SetActive(false);
		item.transform.name = tostring(index)
		item.transform:SetParent(npclstcontent.transform)
		item.transform.localScale = Vector3.one;
		item.transform.localPosition = Vector3.zero;
		item:Show()
		return item
	end

	-- 点击自动寻路到目标点，并开启自动战斗
	local clickNpcListItemTransform = function(index)
		local npcinfo = npcinfolist[index];
		local info = npclist[npcinfo.index];
		--monster..
		if info.npc_type == MapNPCType.MapNPC_monster then
			local pos = info.pos;
			local dst_x = pos[1];
			local dst_z = pos[2];
			AutoPathfindingManager.StartPathfinding_S(dst_x, 0, dst_z, false, function ()
				local player = AvatarCache.me;
				if player ~= nil then
					local player_class = Fight.GetClass(player);
					player_class.HandUp(player, true);
				end
			end);
			-- ArriveTriggerEvent.ATE_AutoFight, false, nil)
		--portal
		elseif info.npc_type == MapNPCType.MapNPC_portal then
			local pos = info.pos;
			local dst_x = pos[1];
			local dst_z = pos[2];
			AutoPathfindingManager.StartPathfinding_S(dst_x, 0, dst_z, false);
			--获取传送门目标场景与位置 直接传送！
		--funcnpc	
		elseif info.npc_type == MapNPCType.MapNPC_funcnpc then
			local pos = info.pos;
			local dst_x = pos[1];
			local dst_z = pos[2];
			--print("走到: " .. info.sid);
			AutoPathfindingManager.StartPathfinding_S(dst_x, 0, dst_z, false, function ()
				--print("111111111111111111111111111");
				local npcSid = info.sid;
				InteractionManager.OnClick(npcSid);
			end);
		--transmit point
		elseif info.npc_type == MapNPCType.MapNPC_transmitpt then
			local pos = info.pos;
			local dst_x = pos[1];
			local dst_z = pos[2];
			AutoPathfindingManager.StartPathfinding_S(dst_x, 0, dst_z, false, function () end);
		end
	end

    local clickNpcListItemInfo = function (go)
		local wrapper = go:GetComponent("UIWrapper");
		curSelectItem = wrapper;
		curSelectItem:GO('Select').gameObject:SetActive(true);
		--
		local index = tonumber(go.transform.name)
		local npcinfo = npcinfolist[index];
		local info = npclist[npcinfo.index];
        local nail = npcnaillist[index]
        curNail = nail

        if info.showGJFlag then
        	local color = "#2be42f"
            if DataCache.myInfo.phyDefense < info.phyDeffense then
                color = "#CF1010"
            end
            nailInfo:GO('phyText').text = string.format("<color=#e4e4e4>推荐防御力：</color><color=%s>%d</color>", color, info.phyDeffense)
            nailInfo:GO('expText').text = string.format("<color=#e4e4e4>标准挂机经验：%s</color>", info.guajiExp)
            --根据npc的位置，设置悬浮的坐标
            local posXRadio = info.pos[1] / mapSize.x
            local posYRadio = info.pos[2] / mapSize.y
            if posXRadio <= 0.5 and posYRadio <= 0.5 then
                nailInfo.transform.pivot = Vector2.New(0, 0)
                nailInfo.transform.localPosition = Vector3.New(10 + nail.transform.localPosition.x, 10 + nail.transform.localPosition.y, nail.transform.localPosition.z)
            elseif posXRadio <= 0.5 and posYRadio >= 0.5 then
                nailInfo.transform.pivot = Vector2.New(0, 1)
                nailInfo.transform.localPosition = Vector3.New(10 + nail.transform.localPosition.x, nail.transform.localPosition.y - 10, nail.transform.localPosition.z)
            elseif posXRadio >= 0.5 and posYRadio <= 0.5 then
                nailInfo.transform.pivot = Vector2.New(1, 0)
                nailInfo.transform.localPosition = Vector3.New(nail.transform.localPosition.x - 10, 10 + nail.transform.localPosition.y, nail.transform.localPosition.z)
            else
                nailInfo.transform.pivot = Vector2.New(1, 1)
                nailInfo.transform.localPosition = Vector3.New(nail.transform.localPosition.x - 10, nail.transform.localPosition.y - 10, nail.transform.localPosition.z)
            end
            nailInfo:Show()
        else
        	nailInfo:Hide()
        end
		--monster..
		if info.npc_type == MapNPCType.MapNPC_monster then
            --特效
            nail:GO("Effect"):PlayUIEffectForever(nail.gameObject, GuaiEffectName);
        else
            --特效
            nail:GO("Effect"):PlayUIEffectForever(nail.gameObject, NPCEffectName);
        end
	end

    function UIAreaMap.CM_ClickNpcListItem(go)
		local index = tonumber(go.transform.name)
        if index == selectIndex then
            clickNpcListItemTransform(index)
        else
            UIAreaMap.CM_handleCancelSelect()
            go:GetComponent("UIWrapper"):GO('Text').textColor = Color.New(253/255, 253/255, 228/255);
            if index ~= selectIndex and curSelectItem ~= nil then
            	curSelectItem:GO('Text').textColor = Color.New(208/255, 176/255, 127/255);
            end
            selectIndex = index;
            clickNpcListItemInfo(go);
        end
	end

    function UIAreaMap.CM_GoPathing(go)
        if nil == selectIndex then
            ui.showMsg("请先选择前往的目标")
        else
            clickNpcListItemTransform(selectIndex)
        end
	end

	function UIAreaMap.CM_ClearNPCItem()
		for i = 1, #npcitemlist do
			destroy(npcitemlist[i].gameObject)
		end
		npcitemlist = {}
	end

	--更新我的位置
	function UIAreaMap.CM_UpdateMyPos()
		if CM_mapsid ~= DataCache.scene_sid then
			me:Hide()
		else
			me:Show()
		end
		--转换pos
		local player = AvatarCache.me;
		local pos_x = player.pos_x;
		local pos_y = player.pos_y;
		local pos_z = player.pos_z;
		local nailPos = Vector2.New(pos_x * mapImgScale_x, pos_z * mapImgScale_y)
		me:GetComponent("RectTransform").anchoredPosition = nailPos
	end

	function UIAreaMap.Update()
		UIAreaMap.CM_UpdatePath();
		UIAreaMap.CM_UpdateMyPos();
	end

	-- 	--更新寻路路径 
	function UIAreaMap.CM_UpdatePath()
		local player = AvatarCache.me;
		if player == nil then
			return;
		end
		local is_auto_pathfinding = AutoPathfindingManager.IsAutoPathfinding();
		if is_auto_pathfinding then
			local path = {};
			local pos_x = player.pos_x;
			local pos_y = player.pos_y;
			local pos_z = player.pos_z;
			local local_path = AutoPathfindingManager.GetLocalPath();
			--DataStruct.DumpTable(local_path)
			local dst_x = local_path.dst_x;
			local dst_y = local_path.dst_y;
			local dst_z = local_path.dst_z;
			uFacadeUtility.CalcPath(pos_x, pos_y, pos_z, dst_x, dst_y, dst_z, path);
			if #path > 0 then
				uFacadeUtility.GeneratePath(path, 4); -- 默认 4 米一个点
			end
		else
			uFacadeUtility.ClearPath();
		end
	end

	function UIAreaMap.CM_ClickAutoPathing()
		--pointer_position(即鼠标坐标 跟Input.mousePosition是一样的)是屏幕坐标
		--需要转化成世界坐标
		--然后转化到mapImg的坐标系中 获取到的r_offset就是相对于原来mapImg大小的坐标
        UIAreaMap.CM_handleCancelSelect();
		local clickPos = mapImg.pointer_position
		local UICamera = GameObject.Find("UI Camera"):GetComponent("Camera")
		local w_clickPos = UICamera:ScreenToWorldPoint(clickPos)
		local r_offset = mapImg.transform:InverseTransformPoint(w_clickPos)

		local dst_x = r_offset.x / mapImgScale_x;

		local dst_y = 0;
		local dst_z = r_offset.y / mapImgScale_y;

		
		local player = AvatarCache.me;
		local pos_x = player.pos_x;
		local pos_y = player.pos_y;
		local pos_z = player.pos_z;

		local flag = ClickMoveManager.ClickPosCanNavigate(dst_x, dst_y, dst_z)
		local canroutto = uFacadeUtility.CanRouteTo(Vector3.New(pos_x,pos_y,pos_z),Vector3.New(dst_x,dst_y,dst_z))

		if not canroutto then
			local temp = uFacadeUtility.SamplePosition(Vector3.New(pos_x,pos_y,pos_z),Vector3.New(dst_x,dst_y,dst_z),100)
			dst_x = temp.x
			dst_y = temp.y
			dst_z = temp.z
		end
		

		AutoPathfindingManager.StartPathfinding_S(dst_x, dst_y, dst_z, false);
	end

	function UIAreaMap.CM_shownpclist()
		UIAreaMap.CM_ClearNPCItem()
		for i= 1, #npcinfolist do
			local v = npcinfolist[i]
			if v ~= nil and v.npc_type ~= MapNPCType.MapNPC_transmitpt then
			 	npcitemlist[i] = UIAreaMap.CM_AddNPCItem(v, i)
			end
		end
	end


	function UIAreaMap.GenerateMapNPCList(CM_mapsid)
		local list = {};
		-- print(UIAreaMap.GenerateMapNPCList)
		-- print(CM_mapsid)
		local scene_npc_info = tb.MapNpcTable[CM_mapsid]
		if scene_npc_info ~= nil then
			for k, v in pairs(scene_npc_info) do
				list[#list + 1] = v;
			end
		end
		table.sort(list, function(a,b)
			return a.sort < b.sort
		end)
		return list;
	end


	function UIAreaMap.CM_InitNpcList()
		npclist = {}
		npcinfolist = {}
		npclist = UIAreaMap.GenerateMapNPCList(CM_mapsid);
		if npclist == nil then
			return
		end
		-- DataStruct.DumpTable(npclist)
		for i = 1, #npclist do
		 	local info = npclist[i];
		 	local name;
            if info.showFlag then
                if info.npc_type == MapNPCType.MapNPC_monster then
                    --level读取npc表的配置
                    local pro = tb.NPCTable[info.sid]
                    if pro ~= nil then
                        name = string.format("%s %s级", info.name, pro.level)
                    else
                        name = string.format("%s", info.name)
                    end
                else
                    name = info.name
                end
                npcinfolist[#npcinfolist+1] = {name = name, iconname = info.img, title = info.title, npc_id = info.npc_id, npc_pos = info.pos, index=i, npc_type = info.npc_type}
            end
		end
		-- DataStruct.DumpTable(npcinfolist)
	end

	function UIAreaMap.CM_ClearNPCNail()
		for i=1,#npcnaillist do
			destroy(npcnaillist[i].gameObject)
		end
		npcnaillist = {}
	end

	function UIAreaMap.CM_shownpcnail()
		UIAreaMap.CM_ClearNPCNail()
		for i = 1, #npcinfolist do
			local v = npcinfolist[i]
			local item = newObject(nail)
			if v.title == "传送门" then
				item:GO('Text').text = v.name
			else 
				item:GO('Text').text = ""
			end
			-- print(v.name)
			-- print(v.iconname)
			item.sprite = v.iconname;
			item.transform.name = v.name
			item.transform:SetParent(nails.transform)
			item.transform.localPosition = Vector3.zero;
			local nailPos = Vector2.New(v.npc_pos[1] * mapImgScale_x, v.npc_pos[2] * mapImgScale_y)
			item:GetComponent("RectTransform").anchoredPosition = nailPos
			item.transform.localScale = Vector3.one;
			item:Show()
		 	npcnaillist[i] = item
		end
        --保证信息悬浮在最下面 不被遮挡
        nailInfo:GetComponent("RectTransform"):SetAsLastSibling();
	end

	------------------------------------------------------------------------
	---
	--- 世界地图 
	---
	------------------------------------------------------------------------
	local toSceneSid = nil
	local toScenePos = nil
	function UIAreaMap.OpenWorldMap()
		curPage = PAGE_WORLD
		--show it
		this:GO('_worldMap'):Show()
		this:GO('_curMap'):Hide()
		titlename.text = "世界地图";
		-- UIAreaMap.controller.SetTitle("wz_world")
	end

	function UIAreaMap.FormatLockIcon()
		
		--等级未达到要求显示锁图标

	end

	function UIAreaMap.handleLevelUp()
		if curPage == PAGE_WORLD then
			UIAreaMap.InitWorldMap();
		end
	end

    function UIAreaMap.InitWorldMap()
		local pro = tb.SceneTable[DataCache.scene_sid]
		if pro ~= nil then
			--当前所在地图 标志
			local curMapItem = this:GO('_worldMap.bk.'..pro.alias)
			if curMapItem ~= nil then
				this:GO('_worldMap.cursor'):Show()
				local pos = curMapItem:GetComponent('RectTransform').anchoredPosition
				this:GO('_worldMap.cursor'):GetComponent("RectTransform").anchoredPosition = Vector3.New(pos.x, pos.y + 66, pos.z)
			else
				this:GO('_worldMap.cursor'):Hide()
			end
		end
		--初始化按钮回调 && 名字
		local level = DataCache.myInfo.level;
		local items = this:GO('_worldMap.bk'):GetComponent("Transform")
		for i=1,items.childCount do
			local child = items:GetChild(i-1)
			local name = child.gameObject.name
			this:GO('_worldMap.bk.'..name):BindButtonClick(UIAreaMap.WM_MapBtnClick)
			local scene_sid = tb.SceneAlias2Id[name]
			if scene_sid ~= nil then
				local pro = tb.SceneTable[scene_sid]
				local str = "";
				if pro.level ~= 1 then
					str = pro.name .. " " .. pro.level;
				else
					str = pro.name
				end
				if level < pro.level then
					this:GO('_worldMap.bk.'..name..".name.text").text = client.tools.formatColor(str,"#a8a8a8");
					this:GO('_worldMap.bk.'..name..".name.lock"):Show();
				else
					this:GO('_worldMap.bk.'..name..".name.text").text = client.tools.formatColor(str,"#e9d385");
					this:GO('_worldMap.bk.'..name..".name.lock"):Hide();
				end


			end
		end
		--特殊地图按钮
		-- items = this:GO('_worldMap.specBtn'):GetComponent("Transform")
		-- for i=1,items.childCount do
		-- 	local child = items:GetChild(i-1)
		-- 	local name = child.gameObject.name
		-- 	this:GO('_worldMap.specBtn.'..name):BindButtonClick(UIAreaMap.WM_MapBtnClick)
		-- 	local scene_sid = tb.SceneAlias2Id[name]
		-- 	if scene_sid ~= nil then
		-- 		local pro = tb.SceneTable[scene_sid]
		-- 		this:GO('_worldMap.specBtn.'..name..".name.text").text = pro.name
		-- 	end
		-- end
	end

	function UIAreaMap.WM_MapBtnClick(go)
		local sid = tb.SceneAlias2Id[go.name]
		local level = DataCache.myInfo.level;
		local fromSceneSid = DataCache.scene_sid;
		if fromSceneSid ~= sid then
			if fromSceneSid == client.MolongTask.sceneSid and client.MolongTask.BIsStart == true then
				local tip = "当前正处于护送任务过程中，离开魔龙岛会导致任务失败，是否继续？";
				ui.showMsgBox(nil, tip, function()
					--DoTransform
					PortalCrystal.SendTramsitMsg(sid)
					--关闭界面
					UIAreaMap.closeSelf()
				end)
			elseif level >= tb.SceneTable[sid].level then
				-- 临时添加 NSY-4756 start
				if tb.SceneTable[sid].name == "魔龙岛" then
					ui.showMsg("暂未开放，敬请期待")
					return ;
				end
				-- 临时添加 NSY-4756 end
				local str = string.format("确定传送到%s（%s级）吗？",tb.SceneTable[sid].name, tb.SceneTable[sid].level);
				ui.showMsgBox(nil, str, function() 
					UIAreaMap.MapTransmit(sid, false);
					end);

			else
				-- 临时添加 NSY-4756 start
				if tb.SceneTable[sid].name == "魔龙岛" then
					ui.showMsg("暂未开放，敬请期待")
					return ;
				end
				-- 临时添加 NSY-4756 end
				local str = string.format("传送到该地图需要%s级", tb.SceneTable[sid].level);
				ui.showMsg(str);
			end
		end
	end

	function UIAreaMap.MapTransmit(sid, skipCfm)
		if sid == nil then
			ui.showMsg("暂未开放") 
			return
		end
		local pro = tb.SceneTable[sid]
		if pro == nil then
			ui.showMsg("暂未开放") 
			return
		end  
		if sid == CM_mapsid then
			return
		end
		local fromSceneSid = DataCache.scene_sid;
		--一系列复杂的寻路加传送加读条操作
		if not client.tools.transmitCheck(fromSceneSid, sid) then
			return
		end
		toSceneSid = sid
		--提示
		if fromSceneSid < 2000 then
			--一般地图要传出再提示
			--暂时处理
			--目前还没有规划特殊地图和禁止传送区域   linh
			local tip
			if pro.level > 1 then
				tip = string.format("确定传送到%s(%d级)吗？", pro.name, pro.level)
			else
				tip = string.format("确定传送到%s吗？", pro.name)
			end

			ui.showMsgBox(nil, tip, function()
				--停止自动寻路
				AutoPathfindingManager.Cancel();
				--DoTransform
				PortalCrystal.SendTramsitMsg(toSceneSid)
				--关闭界面
				UIAreaMap.closeSelf()
			end)
		else
			--停止自动寻路
			AutoPathfindingManager.Cancel();
			--DoTransform
			PortalCrystal.SendTramsitMsg(toSceneSid)
			--关闭界面
			UIAreaMap.closeSelf()
		end
	end

	local team_member_nails = {}

	--更新队员位置图钉
	function UIAreaMap.UpdateTeamMemberNail(role_uid, pos, state, scene)
		if curPage ~= PAGE_CURRENT or role_uid == DataCache.myInfo.role_uid then
			return
		end
		local go = nil;
		if team_member_nails[role_uid] == nil then
			go = newObject(duiyou)
			go.name = role_uid
			go.transform:SetParent(duiyous.transform);
			go.transform.localScale = Vector3.one;
			go.transform.localPosition = Vector3.zero;
			go.gameObject:SetActive(true)
			team_member_nails[role_uid] = go
		else
			go = team_member_nails[role_uid];
		end
		local wrapper = go:GetComponent("UIWrapper");
		if client.team.isLeader(role_uid) == true then
			wrapper.sprite = "tb_duizhang";
		else
			wrapper.sprite = "tb_duiyou";
		end
		local nailPos = Vector2.New(pos[1] * mapImgScale_x, pos[3] * mapImgScale_y)
		local member = team_member_nails[role_uid]
		--离线或不在当前场景当前分线 隐藏
		local sceneid = scene[1]
		local fenxian = scene[3]
		if state == "offline" or (sceneid ~= DataCache.scene_sid or fenxian ~= DataCache.fenxian) then
			member.gameObject:SetActive(false)
		else
			member.gameObject:SetActive(true)
		end
		member:GetComponent("RectTransform").anchoredPosition = nailPos
	end
	
	--清空队员图钉
	function UIAreaMap.ClearTeamNail()
		for k,v in pairs(team_member_nails) do
			if v ~= nil then
				destroy(v.gameObject)
			end
		end
		team_member_nails = {}
	end

	function UIAreaMap.ClearTeamMemberNail(role_uid)
		if team_member_nails[role_uid] ~= nil then
			destroy(team_member_nails[role_uid].gameObject)
			team_member_nails[role_uid] = nil
		end
	end

	client.areamap = UIAreaMap
	return UIAreaMap;
end