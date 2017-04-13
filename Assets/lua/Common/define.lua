
--定义 一些管理器
MapNPCType = {};
MapNPCType.MapNPC_monster = 0;
MapNPCType.MapNPC_portal = 1;
MapNPCType.MapNPC_funcnpc = 2;
MapNPCType.MapNPC_transmitpt = 3;


ArriveTriggerEvent = {};
ArriveTriggerEvent.ATE_None = 0;
ArriveTriggerEvent.ATE_AutoFight = 1;
ArriveTriggerEvent.ATE_Interacte = 2;
ArriveTriggerEvent.ATE_AutoTransmit = 3;
ArriveTriggerEvent.ATE_Callback = 4;

GameObject = UnityEngine.GameObject;
ArrayList = System.Collections.ArrayList;
Camera = UnityEngine.Camera;
Screen = UnityEngine.Screen;
Screen.sleepTimeout = UnityEngine.SleepTimeout.NeverSleep;


tb = {};

function safe_call(func)
	if func then
		func()
	end
end


local unicode_to_utf8_helper = {};
unicode_to_utf8_helper.bit12 = 2^12; 
unicode_to_utf8_helper.bit6 = 2^6;

function unicode_to_utf8(unicodetable) 
    local op1, op2, op3;
    local unicode;
    local t = {};
    for i = 1, #unicodetable do
        unicode = unicodetable[i]
        if unicode <= 0x007f then 
            t[i] = string.char(unicode % 0x7f);
        elseif unicode >= 0x0080 and unicode <= 0x07ff then 
        	op1 = math.floor(unicode / unicode_to_utf8_helper.bit6) + 192;  -- 1100000
        	op2 = math.floor(unicode % unicode_to_utf8_helper.bit6) + 128;
            t[i] = string.char(op1, op2);
        elseif unicode >= 0x0800 and unicode <= 0xffff then 
        	op1 = math.floor(unicode / unicode_to_utf8_helper.bit12) + 224;
        	op2 = math.floor((unicode % unicode_to_utf8_helper.bit12) / unicode_to_utf8_helper.bit6) + 128;
        	op3 = math.floor(unicode % unicode_to_utf8_helper.bit6) + 128;
            t[i] = string.char(op1, op2, op3);
        else
         	return unicodetable;
        end       
    end
    return table.concat(t);
end

--equip.add_attr = [{attr_type, attr_value, quality}]
tb.GetFightPoint = function(career,addAttr)
	local fight_point = {};
	for i = 1, #addAttr do
		local attrFPRadio = tb.AttrFPointTable[addAttr[i][1]];
		--print(attrFightTab);
		table.insert(fight_point ,attrFPRadio * addAttr[i][2]);

	end
	--print("返回point")
	return fight_point;
end


tb.GetTableByKey = function (table, KeyList)  
	local key = KeyList[1];
	for i = 2, #KeyList do
		key = key.."-" .. KeyList[i];
	end
	return table[key];
end


PanelManager = PanelManager.Instance;


ui = {};
MainUI = {};
client = {};
const = {};
commonEnum = {};
client.tools = {};

client.tools.ensuerList = function (list)
	-- 有些服务器消息发送空列表[]，会被解析成nil
	if not list then
		return nil;
	end

	if type(list) == "table" then
		return list;
	end

	if type(list) == "string" then
		local l = {};
		for i = 1, #list do
			l[i] = string.byte(list, i);
		end
		return l;
	end
	--print("bag arg of ensuerList : " .. type(list));
	--print(debug.traceback());
end

client.tools.arr2table = function (arr)
	return client.tools.parseArr({}, arr);
end

client.tools.parseArr = function (table, arr)
	local temp;
	for i = 0, arr.Count - 1 do
		temp = arr:get_Item(i);
		if (type(temp) == "userdata") then
			table[i + 1] = client.tools.parseArr({}, temp);
		else 
			table[i + 1] = temp;
		end
	end
	return table;
end


client.StopCollect = function ()
	if client._StopCollect ~= nil then
		client._StopCollect();
	end
end


client.tools.foreach = function (table, func) 
	for i = 1, #table do
		func(i, table[i]);
	end		
end	

client.tools.filter = function (table, func)
	local temp = {};
	for i = 1, #table do
		if func(table[i]) then
			temp[#temp + 1] = table[i];
		end
	end
	return temp;
end

client.tools.ensureString = function (s)
	if type(s) == "table" then
		return unicode_to_utf8(s);
	end
	return s;
end

client.tools.formatColor = function (text, color, condition, checkCondition)
	local changeColor = true;
	if condition and checkCondition then
		if type(condition) == "number" and type(checkCondition) == "number" then
			changeColor = condition < checkCondition;
		end
		if type(condition) == "string" and type(checkCondition) == "string" then
			changeColor = condition ~= checkCondition;
		end
	end

	if changeColor then
		return string.format("<color=%s>%s</color>", color, text);
	else
		return text
	end
end

client.tools.formatRichTextColor = function (text, color)
	if text == nil then
		return "";
	else
		return string.format("[color:%s,%s,%s,%s]", color.r, color.g, color.b, text);
	end
end

client.tools.formatNumber = function (number)
	if type(number) == "number" then
		if number > 999999999 then
			return math.floor(number / 100000000).."亿";
		elseif number > 99999 then
			return math.floor(number / 10000).."万";
		else
			return number;
		end
	else
		return number;
	end
end

client.tools.formatNumber2 = function ( number )
	if type(number) == "number" then
		if number > 99999999 then
			return math.floor(number / 100000000).."亿";
		elseif number > 9999 then
			return math.floor(number / 10000).."万";
		else
			return number;
		end
	else
		return number;
	end
end

client.tools.formatTime = function (second)
	local time = {};

	if second ~= nil then
		second = math.round(second);
		time.day = math.floor(second/86400)
		time.hour = math.fmod(math.floor(second/3600), 24)
		time.minute = math.fmod(math.floor(second/60), 60)
		time.second = math.fmod(second, 60)
	end
	
	return time;
end

-- 判断两个时间是否是在同一天(lastTime, currTime 是 1970 年 1 月 1 日凌晨以来的秒数)
client.tools.IsTheSameDay = function (lastTime, currTime)
	if lastTime == nil then
		return false;
	end
	if currTime == nil then
		return false;
	end
	if lastTime == 0 then
		return false;
	end
	if currTime == 0 then
		return false;
	end
	local delta = 5 * 3600;
	local lastDT = os.date("*t", lastTime - delta);
	local currDT = os.date("*t", currTime - delta);
	if lastDT.year == currDT.year and lastDT.month == currDT.month and lastDT.day == currDT.day then
		return true;
	end
	return false;
end

client.tools.exp2level = function (exp)
	local level = 1;
	local table = tb.ExpTable[level];
	while exp >= table.levExp do
		exp = exp - table.levExp;
		level = level + 1;
		table = tb.ExpTable[level];
	end

	return level, exp;
end

--只能解析形如data = {{1, element}, {2, element}, {3, {{1, element}, {2, element}}}
client.tools.parseArrayList = function(data)	
	local arList = ArrayList.New()
	for i=1,#data do
		local d = data[i]
		if type(d) == 'table'then
			arList:Add(client.tools.parseArrayList(d))
		else
			arList:Add(d)
		end
	end
	return arList
end

--传送检查
client.tools.transmitCheck = function(start_sid, end_sid)
	local level = DataCache.myInfo.level
	if start_sid == nil then
		start_sid = DataCache.scene_sid;
	end
	local start_pro = tb.SceneTable[start_sid]
	local end_pro = tb.SceneTable[end_sid]
	--落点地图限制
	--落点等级
	if end_pro.level > level then
		ui.showMsg("传送到该地图需要"..end_pro.level.."级")	
		return false
	end
	--限制传送区域
	if start_sid ~= end_sid then
		if end_pro.transfer == false then
			ui.showMsg("目标处于特殊区域，无法寻路")	
			return false
		end

		if start_pro.transfer == false then
			ui.showMsg("你处于特殊区域，无法寻路")	
			return false
		end
	end

	--角色死亡
	local player = AvatarCache.me;
	if player ~= nil then
		if Checker.CheckIsDead(player) then
			ui.showMsg("死亡状态下无法传送")	
			return false
		end
	end
	return true
end

--为table生成一些索引table 方便查找
tb.GenIndexTable = function(tableName, keyName)
	local IndexTbName = string.format("%s_i_%s", tableName, keyName)
	local table = tb[tableName]
	tb[IndexTbName] = {}
	local IndexTable = tb[IndexTbName]
	for k,v in pairs(table) do
		if v[keyName] == nil then
			return
		end
		IndexTable[v[keyName]] = k
	end
end

--坐标链接中有些场景名字带了几分线，使用find找出对应的数据
tb.FindSceneId = function(sceneName)
	local table = tb.SceneTable;
	for k,v in pairs(table) do
		if string.find(sceneName, v.name) ~= nil then
			return k;
		end
	end
	return 0;
end

EmptyFun = function() end


StartPathing = function(pos, flyShoe, cb)	
	AutoPathfindingManager.StartPathfinding_S(pos.x, 0, pos.y, flyShoe, cb);
end

ClearPathingInfo = function()
	AutoPathfindingManager.Clear();
end

-- 停止自动寻路
StopPathing = function()
    local player = AvatarCache.me;
    Fight.DoJumpState(player, SourceType.System, "Idle", 0);
	ClearPathingInfo();
end

GetAvatarController = function()
	local player = AvatarCache.me;
    if player == nil then
        return nil
    end
    return player:GetComponent('AvatarController');
end

tableContains = function (table, element)
  for _, value in pairs(table) do
    if value == element then
      return true
    end
  end
  return false
end

SetMainCameraInfo = function(Pos, Rot, Scale, FieldOfView, bOrth, bOrthSize)
	local MainCamera = Camera.main
	if MainCamera ~= nil then
		MainCamera.transform.localPosition = Pos
		MainCamera.transform.localEulerAngles = Rot
		MainCamera.transform.localScale = Scale
		MainCamera.fieldOfView = FieldOfView
		MainCamera.orthographic = bOrth
		if bOrth == true then
			MainCamera.orthographicSize = bOrthSize
		end
	end
end

function getServerDayIndex(Hour,Minute,Second)
    local timeNow = TimerManager.GetServerNowSecond();
    return (timeNow + 28800 +  86400 - Hour * 3600 - Minute * 60 - Second) / 86400;
end


client.singleton = (function()
	local t = {};
	local updateList = {};
	t.Update = function ()
		InstanceManager.Update();
		ControlLogic.Update();
		TargetSelecter.Update();
		FubenManager.Update();
		AreaManager.Update();
		GuideManager.update();		
	end;

	t.addUpdate = function (func)
		for i = 1, #updateList do
			updateList[i]();
		end
	end

-- 在update中remove可能导致后面跳过
	t.removeUpdate = function (func)
		local l = updateList;
		for i = 1, #l do
			if l[i] == func then
				l[i] = l[#l];
				l[#l] = nil;
			end
		end
	end

	return t;
end)();