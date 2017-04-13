NoticeManager = {};
--这个在开始时初始化对应的字段文本，给设置界面使用
NoticeManager.activityText = {};
NoticeManager.bActive = {};
-- local actPush = {
--                     {name = "灵魂试炼场", period = "周一、二、三", time = "20:00"},
--                     {name = "安哥拉魔谷", period = "周日", time = "11:00"},
--                     {name = "战盟联赛", period = "周二、四、五、六", time = "21:30"},
--                     {name = "安哥拉魔谷", period = "周日", time = "11:00"},
--                     {name = "战盟联赛", period = "周二、四、五、六", time = "21:30"}
--                 }

--存储由活动id到对应的提醒id关系
NoticeManager.activity2noticeTable = {};
NoticeManager.notice2activityTable = {};
DAY_SECONDS = 86400;
NoticeManager.OfflineId = 100000;
--注册所有配置表中的提醒
NoticeManager.RegisterAllNotice = function()
    local table = NoticeManager.activity2noticeTable;   
    NoticeManager.LoadNoticeSetting();
    for k,v in pairs(tb.NoticeTable) do
        table[v.activityId] = table[v.activityId] or {};
        local temp = table[v.activityId];
        temp[#temp+1] = k;
        NoticeManager.notice2activityTable[k] = v.activityId;
        NoticeManager.generateNoticeInfo(k,v);
        NoticeManager.RegisterNoticeById(k);
    end       
end

NoticeManager.LoadNoticeSetting = function()
    local settings = DataCache.settings;
    local temp = Split(settings.activityNotice, "|");
    for i=1,#temp do
        NoticeManager.bActive[i] = tonumber(temp[i]);
    end
end

--拼接出一个活动对应的字符串并保存配置
NoticeManager.SaveSettings = function()
    local temp = "";
    for i = 1,#NoticeManager.bActive do
        if i ~= 1 then
            temp = temp.."|";
        end
        temp = temp..NoticeManager.bActive[i];
    end
    local settings = DataCache.settings;
    settings.activityNotice = temp;
    GameSettings.SaveAndApply();
end

local DayString = {"一","二","三","四","五","六","日"};
local formatDayInfo = function(tableRes)
    if tableRes[1] == 0 then
        return "每天"
    end

    local temp = "周";
    for i=1,#tableRes do
        if i ~= 1 then
            temp = temp.."、";
        end
        temp = temp..DayString[tableRes[i]];
    end
    return temp;
end

local formatActivityTime = function(tableRes)
    local temp = "";
    for i=1,#tableRes do
        if i ~= 1 then
            temp = temp.." ";
        end
        local timeTable = tableRes[i];
        temp = temp..timeTable[1]..":"..timeTable[2];
    end
    return temp;
end

NoticeManager.generateNoticeInfo = function(noticeId,noticeInfo)
    local table = NoticeManager.activityText;
    local activityId = noticeInfo.activityId;
    local item = {};
    item.activityId = activityId;
    item.name = tb.LimitedActTable[activityId].name;
    item.period = formatDayInfo(noticeInfo.noticeDay);
    item.time = formatActivityTime(noticeInfo.activityTime);   
    local index = #table+1;
    table[index] = item;
    if NoticeManager.bActive[index] == nil then
        NoticeManager.bActive[index] = 1;
    end
end

--注册某个提醒id对应的所有提醒
NoticeManager.RegisterNoticeById = function(noticeId)
    local info = tb.NoticeTable[noticeId];
    if info == nil then
        return;
    end
    if DataCache.myInfo.level < info.limitLevel then
        return;
    end
    --判断对应活动的提醒设置是否打开，未打开直接return
    local activityId = NoticeManager.notice2activityTable[noticeId];
    local index = -1;
    for i=1,#NoticeManager.activityText do
        if NoticeManager.activityText[i].activityId == activityId then
            index = i;
            break;
        end
    end
    if index == -1 or NoticeManager.bActive[index] == 0 then
      	--print(noticeId.."注册未开启！")
        return;
    end

    --获取当天是星期几
    local dayOfWeek =  TimerManager.GetDayOfWeek();

    --0说明每天都需要提醒，直接设置
    local bIsEveryDay = false;
    if info.noticeDay[1] == 0 then
        bIsEveryDay = true;
    end

    local nextTime = 0;
    local realNoticeId = 0;
    --循环处理配置的多个时间
    for i=1,#info.noticeTime do
        local hour = info.noticeTime[i][1];
        local minute = info.noticeTime[i][2];
        local second = info.noticeTime[i][3];
        if bIsEveryDay == true then
            realNoticeId = noticeId * 100 + i * 10;
            nextTime = TimerManager.GetAfterSeconds(dayOfWeek,bIsEveryDay,hour,minute,second);
            print(realNoticeId..":"..nextTime.."秒之后提醒")
            NativeManager.GetInstance():ShowNotification(realNoticeId, nextTime, "", info.noticeContent, DAY_SECONDS);
        else
            for j=1,#info.noticeDay do
                realNoticeId = noticeId * 100 + i * 10 + j;
                nextTime = TimerManager.GetAfterSeconds(info.noticeDay[i],bIsEveryDay,hour,minute,second);
                print(realNoticeId..":"..nextTime.."秒之后提醒")
                NativeManager.GetInstance():ShowNotification(realNoticeId, nextTime, "", info.noticeContent, DAY_SECONDS);
            end
        end
    end

    for i=1,#info.activityTime do
        local hour = info.activityTime[i][1];
        local minute = info.activityTime[i][2];
        local second = info.activityTime[i][3];
        if bIsEveryDay == true then
            realNoticeId = 50 + noticeId * 100 + i * 10;
            nextTime = TimerManager.GetAfterSeconds(dayOfWeek,bIsEveryDay,hour,minute,second);
            print(realNoticeId..":"..nextTime.."秒之后提醒")
            NativeManager.GetInstance():ShowNotification(realNoticeId, nextTime, "", info.startContent, DAY_SECONDS);
        else
            for j=1,#info.noticeDay do
                realNoticeId = 50 + noticeId * 100 + i * 10 + j;
                nextTime = TimerManager.GetAfterSeconds(info.noticeDay[i],bIsEveryDay,hour,minute,second);
                print(realNoticeId..":"..nextTime.."秒之后提醒")
                NativeManager.GetInstance():ShowNotification(realNoticeId, nextTime, "", info.startContent, DAY_SECONDS);
            end
        end
    end
    -- body
end

--取消某个提醒id对应的所有提醒
NoticeManager.CancelNoticeById = function(noticeId)
    local noticeInfo = tb.NoticeTable[noticeId];
    local bIsEveryDay = false;
    local realNoticeId = 0;
    if noticeInfo.noticeDay == 0 then
        bIsEveryDay = true;
    end
    for i=1,#noticeInfo.noticeTime do
        if bIsEveryDay == true then
            realNoticeId = noticeId * 100 + i * 10;
            NativeManager.GetInstance():CancelNotification(realNoticeId);
        else
            for j=1,#noticeInfo.noticeDay do
                realNoticeId = noticeId * 100 + i * 10 + j;
                NativeManager.GetInstance():CancelNotification(realNoticeId);
            end
        end
    end
    for i=1,#noticeInfo.activityTime do
        if bIsEveryDay == true then
            realNoticeId = 50 + noticeId * 100 + i * 10;
            NativeManager.GetInstance():CancelNotification(realNoticeId);
        else
            for j=1,#noticeInfo.noticeDay do
                realNoticeId = 50 + noticeId * 100 + i * 10 + j;
                NativeManager.GetInstance():CancelNotification(realNoticeId);
            end
        end
    end
    -- body
end

NoticeManager.RegisterNoticeByActivity = function(activityId)
    local noticeTable = NoticeManager.activity2noticeTable[activityId];
    if noticeTable == nil or #noticeTable == 0 then
        return;
    end
    for i=1,#noticeTable do
        NoticeManager.RegisterNoticeById(noticeTable[i]);
    end
end

NoticeManager.CancelNoticeByActivity = function(activityId)
    local noticeTable = NoticeManager.activity2noticeTable[activityId];
    if noticeTable == nil or #noticeTable == 0 then
        return;
    end

    for i=1,#noticeTable do
        NoticeManager.CancelNoticeById(noticeTable[i]);
    end
end

local tempSecond = 59;
--这里临时提供一个开始离线挂机的提醒
NoticeManager.StartOfflineNotice = function()
    -- print("Level:"..DataCache.myInfo.level)
    -- print("OfflineTime:"..DataCache.offlineTime)
    if DataCache.myInfo == nil or DataCache.myInfo.name == nil or DataCache.myInfo.level < 30 then
        return;
    end
    if DataCache.offlineTime == 0 then
        return;
    end
    if tempSecond == 60 then
        -- print("定时启动离线挂机提醒！")
        local hour = math.floor(DataCache.offlineTime/60);
        local minute = DataCache.offlineTime - 60 * hour;
        local str = "【"..DataCache.myInfo.name.."】已开始离线挂机。";
        NativeManager.GetInstance():ShowNotification(NoticeManager.OfflineId, 11*60, "", str, 0);
        tempSecond = 0;
    elseif tempSecond == 59 then
        -- print("定时取消离线挂机提醒！")
        NativeManager.GetInstance():CancelNotification(NoticeManager.OfflineId);       
    end
    tempSecond = tempSecond + 1;
end

EventManager.register(Event.ON_TIME_SECOND_CHANGE, NoticeManager.StartOfflineNotice);