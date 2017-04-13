Event = {
    "ON_CACHE_CHANGE",
    "ON_ROLE_INFO_CHANGE",
    "ON_EXP_CHANGE",
    "ON_LEVEL_UP",
    "ON_EVENT_ITEM_CHANGE",
    "ON_EVENT_EQUIP_CHANGE",
    "ON_EVENT_GEM_CHANGE",
    "ON_EVENT_WEAREQUIP_CHANGE",
    "ON_BLOOD_CHANGE",
    "ON_EVENT_GET_NEW_EQUIP",

    --time
    "ON_TIME_SECOND_CHANGE",
    "ON_TIME_HALF_SECOND_CHANGE",
    "ON_TIME_DAY_CHANGE",

    -- role info
    "ON_MONEY_CHANGE",
    "ON_DIAMOND_CHANGE",
    "ON_GOUMAILI_CHANGE",
    "ON_JINGTIE_CHANGE",
    "ON_TALENTBOOK_CHANGE",
    "ON_TILI_CHANGE",
    "ON_RECEIVE_TILI_CHANGE",
    "ON_START_AUTO_PATHFINDING",
    "ON_END_AUTO_PATHFINDING",

    -- attrs
    "ON_KILL_VALUE_CHANGE",
    "ON_PK_MODE_CHANGE",
    "ON_ATTR_CHANGE",
    "ON_FIGHTNUMBER_CHANGE",
    "ON_AUTO_FIGHT_CHANGE",
    "ON_TIRED_VALUE_CHANGE",
    "ON_EVENT_RED_POINT",
    "ON_FIGHT_STATE_TIME",

    -- target
    "ON_TARGET_SELECT",
    "ON_TARGET_CANCEL_SELECT",
    "ON_TARGET_UPDATE",

    -- relogin
    "ON_RELOGIN",

    -- task
    "ON_ADD_TASK",
    "ON_TASK_COMPLETED",
    "ON_TASK_CHANGE",
    "ON_ENTER_SCENE",
    "ON_FUBEN_TASK_CHANGE",
    "ON_FUBEN_TASK_COMPLETED",
    "ON_FUBEN_TASK_COMPLETED_EFFECT",
    "ON_LEAVE_FUBEN",

    -- fuben
    "ON_FUBEN_MATCH_CHANGE",
    "ON_OUT_XIANGWEI",
    "ON_INTO_XIANGWEI",

    -- mijing
    "ON_MIJING_OVER",
    "ON_MIJING_NPC_DEAD",

    --team
    "ON_TEAM_MEMBER_HP_CHANGE",
    "ON_REDPOINT_TEAMMSG",

    "ON_EVENT_BETTER_EQUIP",
    "ON_ABILITY_UNLOCK",

    --NPC
    "ON_NPC_REMOVE",
    
    --guide
    "ON_GUIDE_SHOW_UI",
    "ON_GUIDE_COMPLETE_TASK",
    "ON_GUIDE_CHANGE_SCENE",

    --newSystemOpenFlag
    "ON_NEW_SYSTEM_OPEN_FLAG_CHANGE",
    --宝石拆卸/镶嵌
    "ON_GEM_PUT_OR_REMOVE",
    --坐骑解锁/可进阶
    "ON_HORSE_UNLOCK_OR_CANUPGRADE",

    --ui
    "ON_BAG_FORBIDEN_CHANGE",
    "ON_CBT_Changed",
    "ON_MAINUI_HIDE",
    "ON_MAINUI_SHOW",
    "ON_SKILL_SHOW",
    "ON_SKILL_HIDE",
    "ON_MAIN_MENU_SHOW",
    "ON_MAIN_MENU_HIDE",
    "ON_CENTERCHILD_COMPLETE",

    "ON_CHANGE_SCENENAME", --修改主界面上面的地图名信息

    "ON_CONTRIBUTION_CHANEG",
    "ON_ATTACKED",
    "ON_FINDBACKTIMES_CHANGE",
    "ON_BUY_OFFLINE_TIME",
    "ON_ACTIVE_VALUE_CHANGE",
    "ON_ACTIVE_LIST_CHANGE",

    -- 天赋解锁/专精解锁
    "ON_TALENT_ZHUANJING_UNLOCK",
    "ON_TREASURE_BOX_CHANGE"
  
};

for i = 1, #Event do
    Event[Event[i]] = i;
    Event[i] = nil;
end

-- use a free chain to optimize performance and make a stable index
-- the first element in event list table is the HEAD of the free chain, 0 means no free element

--  start:        {[0]}
-- add func1:     {[0], func1}
-- ...
-- add funcN:     {[0], func1, func2, func3,... funcN}
-- remove func3   {[3], func1, func2, 0, ... funcN}  // now has a free element 3
-- remove func5   {[5], func1, func2, 0, func4, 3, ... funcN}  // now free chain is 5 -> 3
-- remove func8   {[8], func1, func2, 0, func4, 3, func6, func7, 5, ... funcN}
-- notice the free chain 8 -> 5 -> 3 -> 0
-- add funcN+1;   {[5], func1, func2, 0, func4, 3, funcfuncN+1, ... funcN}
-- funcN + 1 is set at 8, which is the head of the free chain point to, 
-- at the same time, head is update to 5, while current free chain is 5 -> 3 -> 0

EventManager = (function ()
    local module = {};
    local funList = {};
    local goMap = {};
    
    local removeIndex = function (event, index)
        -- f[index] = free, free = index;
        local fl = funList[event];
        fl[index] = fl[1]; 
        fl[1] = index;
        module.checkFunList();
    end

    local bind = function (go, event, func)
        local index = module.register(event, func);
        goMap[go] = goMap[go] or {};
        goMap[go][#goMap[go] + 1] = {event, index};
        return index;
    end

    
    local register = function (event, func)
        -- funList[event] 如果为空 funList[event] = {0}
        -- 否则不变
        funList[event] = funList[event] or {0}; -- funList[1] is reserved for the head of free chain, represent the latest free position
        local f = funList[event];
        local index;
        
        if f[1] == 0 then
            -- no free position, add to tail
            index = #f + 1;
            f[index] = func;
        else
            -- find free position
            index = f[1];
            f[1] = f[index];  -- head = head.next
            f[index] = func;
        end

        module.checkFunList();

        return index;
    end


    local removeFunc = function (e, f)
    -- #funcList[e] raise an error if no one has ever register an event of type e 
        local fl = funList[e];
        for i = 1, #fl[e] do
            if fl[e][i] == f then
                removeIndex(e, i);                          
            end
        end
    end

    local removeGO = function (go)      
    -- all gameObject called destroy will step here, check if the gameObject has ever bind an event
        if goMap[go] then
            local gl = goMap[go];
            for i = 1, #gl do
                local e = gl[i];
                removeIndex(e[1], e[2]);
            end
            goMap[go] = nil;
        end
    end

    local onEvent = function (event, ...)
        local fl = funList[event];
        if fl then
            for i = 2, #fl do
                if type(fl[i]) == "function" then
                    fl[i](...);
                end
            end
        end
    end

    local clear = function ()
        funList = {};
        goMap = {};
    end

    module.bind = bind;
    module.register = register;

    module.onEvent = onEvent;

    module.removeIndex = removeIndex;
    module.removeGO = removeGO;
    module.removeFunc = removeFunc;

    module.clear = clear;

    module.checkFunList = checkFunList;
    module.onCreateUI = function (uiName)
        module.onEvent(Event.ON_GUIDE_SHOW_UI, uiName);
    end

    return module;
end
)()