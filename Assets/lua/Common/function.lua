--查找对象--
function find(str)
	return GameObject.Find(str);
end

function destroy(obj)
    EventManager.removeGO(obj);
    GameObject.Destroy(obj);
end

function newObject(prefab)
	return GameObject.Instantiate(prefab);
end

--创建面板--
function createPanel(name)
	PanelManager:CreatePanel(name);
end

function loadPrefab(name)
	warn(PanelManager)
	PanelManager:LoadPrefab(name);
end

function child(str)
	return transform:FindChild(str);
end

function subGet(childNode, typeName)
	return child(childNode):GetComponent(typeName);
end

function findPanel(str)
	local obj = find(str);
	if obj == nil then
		error(str.." is null");
		return nil;
	end
	return obj:GetComponent("LuaBehaviour");
end

-- function formatMoney(money)
--     local strMoney = "";
--     local preTemp = "";
--     local sufTemp = "";
--     --判断是否超过1000，不超过直接返回
--     if money < 1000 then
--         strMoney = money;
--     --这种情况插入一个逗号
--     elseif money < 1000000 then
--         preTemp = string.sub(money,1,-4);  --前面几位
--         sufTemp = string.sub(money,-3,-1);  --末三位数
--         strMoney = preTemp..","..sufTemp;
--     elseif money < 1000000000 then
--         preTemp = string.sub(money,-6,-4);  --中间三位
--         sufTemp = string.sub(money,-3,-1);  --末三位数
--         strMoney = preTemp..","..sufTemp;
--         preTemp = string.sub(money,1,-7);  --前面几位
--         strMoney = preTemp..","..strMoney;
--     else --这种太大的直接返回
--         strMoney = money;
--     end
--     return strMoney;
-- end

function  formatMoney(money)
    local strMoney = "";
    local preTemp = "";
    local surTemp = "";
    if money < 100000 then
        strMoney = money;
    elseif money < 100000000 then
        strMoney = string.sub(money,1,-5).."万";
    elseif money < 10000000000000 then
        preTemp = string.sub(money,1,-9);
        surTemp = string.sub(money,-8,-7);
        strMoney = preTemp.."."..surTemp.."亿";
    else
        strMoney = string.sub(money,1,-9).."亿";
    end
    return strMoney;
end

function formatEquipBase(table, usecolor)
	if table == nil then
		return
	end
    --local result = {}
	local result = ""
	local proName = {
		"phyAttackMin",
        "phyDefense",
        "maxHP",
    }
    local format = "%s %d"
    if usecolor == true then
    	format = "<color=#7E7E7E>%s</color>  <color=white>%d</color>"
    end
    for i = 1, #proName do
	    local value = table[proName[i]]
		if value ~= 0 then
			local text = string.format(format, const.ATTR_NAME[proName[i]], value)
            result = result..text.."\n"
            --insert fail??? why??
			--table.insert(result, text.."\n")
		end
    end
    --return table.concat(result)
    return result
end



ui.unOpenFunc = function ()
    ui.showMsg("敬请期待!");
    return false;
end

ui.showChargePage = function ()
    ui.unOpenFunc();
    return false;
end

function ui.showCharge()
    ui.showMsgBox(nil, "钻石不足，请充值！", ui.showChargePage);
end

ui.showBuyMoneyPage = function ()
    PanelManager:CreateConstPanel('UIBuyMoney', UIExtendType.BLACKMASK, nil);
end

function ui.showBuyMoney()
    ui.showMsgBox(nil, "金币不足，是否前往获取？", ui.showBuyMoneyPage, nil);
end

function ui.buyGuajiTime()
    local remain_time = client.tools.formatTime(DataCache.offlineTime*60);
    if remain_time.hour >= const.BuyGuajiTimeMax then
        ui.showMsg("已达到离线挂机时间上限");
    else
        PanelManager:CreateConstPanel('UIBuyGuajiTime', UIExtendType.BLACKMASK, nil);
    end
end

function ui.GuajiTips()
    local openGuaji = client.userCtrl.IsOpenGuaji();
    local tips;
    local remain_time = client.tools.formatTime(DataCache.offlineTime*60);

    if openGuaji then
        tips = string.format("当前离线挂机时间：%s小时%s分钟，最多可累计%s小时。", remain_time.hour, remain_time.minute, const.BuyGuajiTimeMax);
    else
        tips = string.format("%s级解锁离线挂机功能，离线10分钟后，角色自动前往推荐地点挂机！", const.GuajiLevel);
    end
    ui.showMsg(tips);
end

function ui.ShowMainUI()
    --显示主界面
    UIManager.GetInstance():CallLuaMethod('UIChat.HideUI');
    UIManager.GetInstance():DestoryAllUI();
end

--此功能未完成，暂时没用
function ui.ShowHeadChat(id, content, color)
    -- body
    local chatBubble = nil;

    chatBubble.gameObject.SetActive(true);
    local richText = chatBubble:GO("Text"):GetComponent("LRichText");
    richText.normalTextColor = color;
    richText.text = content;

    local rt = chatBubble:GetComponent("RectTransform");
    rt.sizeDelta = Vector2.New(rt.sizeDelta.x, richText.realLineHeight + 30);

    iTween.FadeTo(chatBubble.gameObject, 1, 0.1);
    chatBubble.transform.localScale = Vector3.zero;
    chatBubble.transform:DOScale(Vector3.one, 0.2)

end

function DoFastBuy()
   ui.showMsg("快速购买暂未开放") 
end


-- 进队列
function Enqueue(queue, value)
    if queue == nil then
        return;
    end
    queue[#queue + 1] = value;
end

-- 出队列
function Dequeue(queue)
    if queue == nil or #queue == 0 then
        return nil;
    end

    local count = #queue;
    local value = queue[1];
    for i = 1, count - 1 do
        queue[i] = queue[i + 1];
    end
    queue[count] = nil;
    return value;
end

function string.rfind(str, pattern)
    str = string.reverse(str)
    local j = string.find(str, pattern)
    if j == nil then
        return nil;
    end
    return string.len(str) - j + 1
end

function Split(szFullString, szSeparator)
    local nFindStartIndex = 1;
    local nSplitIndex = 1;
    local nSplitArray = {};
    while true do  
       local nFindLastIndex = string.find(szFullString, szSeparator, nFindStartIndex);
       if not nFindLastIndex then
        nSplitArray[nSplitIndex] = string.sub(szFullString, nFindStartIndex, string.len(szFullString));
        break;
       end;
       nSplitArray[nSplitIndex] = string.sub(szFullString, nFindStartIndex, nFindLastIndex - 1);
       nFindStartIndex = nFindLastIndex + string.len(szSeparator);
       nSplitIndex = nSplitIndex + 1;
    end;
    return nSplitArray;
end 

function ReverseTable(tab)  
    local tmp = {}  
    for i = 1, #tab do  
        local key = #tab  
        tmp[i] = table.remove(tab)  
    end  
    return tmp  
end  