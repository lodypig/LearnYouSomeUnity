
--这两个库 以后可能会用到先标记一下
--local lpeg = require "lpeg"
--local json = require "cjson"

LuaCache = {};
--管理器--
Main = {};
local this = Main;

local game;
local transform;
local gameObject;
local WWW = UnityEngine.WWW;
local shouldShowPaiHang = true;

local GetPaiHangRank = function ()
    local msg = {cmd = "get_pai_hang_rank"}
    Send(msg, function (msg) 
        shouldShowPaiHang = false;
        if (msg.zhanli > 0 and DataCache.myInfo.level >= 20) then      
            ui.showMsg(string.format("恭喜你荣登战力榜第%s名，威名远扬!", msg.zhanli));
        end

        if (msg.level > 0 and DataCache.myInfo.level >= 20) then
            ui.showMsg(string.format("恭喜你荣登等级榜第%s名，威名远扬!", msg.level));
        end
    end);
end

local CheckAndShowOfflineFight = function ()
    --开启了离线挂机
    if DataCache.guaji_award and DataCache.guaji_award.last_time then
        print("显示离线挂机界面")
        print(DataCache.guaji_award)
        ui.ShowOfflineReward(DataCache.guaji_award);
        local class = Fight.GetClass(AvatarCache.me);
        class.HandUp(AvatarCache.me,true);
    end 
    DataCache.guaji_award = nil;
end

function Main.Awake()
    --warn('Awake--->>>');
end

--启动事件--
function Main.Start()
	--warn('Start--->>>');
end

-- Bag = 1
-- 初始化界面的逻辑控制
function initLogicCtrl()
     BagCtrl();
     FashionSuitCtrl();
end


function Main.OnPlayerInitOK()
    if shouldShowPaiHang then
        GetPaiHangRank();
    end
    CheckAndShowOfflineFight();
end


--初始化完成，发送链接服务器信息--
function Main.OnInitOK()
    -- TODO 需要把加载文件写到一个单独的文件中，一次把所有文件加载完成
    initLogicCtrl();
    ui.ShowSysLayer();
end

function Main.OnDestroy()
    --warn('OnDestroy--->>>');
end
function OnLoadScene()
    --Util.BindLoadingFunc(HideLoadScene)
    if client.MolongTask.TaskList == nil then
        client.MolongTask.GetMolongTasks(nil);
    end
    -- showMainScene();
    EventManager.bind(PanelManager.UIRoot.gameObject, Event.ON_RELOGIN, CheckAndShowOfflineFight);
    --处理mainui右上角的地图名称
    UIManager.GetInstance():CallLuaMethod('MainUI.UpdateSceneName');
    EventManager.onEvent(Event.ON_ENTER_SCENE);
    --tab地图更新
    UIManager.GetInstance():CallLuaMethod('UIAreaMap.CM_InitMapArea');
    Send({cmd = "confirm_login"});
end

function OnRoleCreateFinished(bFirstLoad)

    --print("7. OnRoleCreateFinished");

    --TODO
    --新切入图 可能在传送水晶范围 设置不弹出提示
    --PortalCrystal.SetOneTimeNotCheck()
    --TODO 速度更新
    -- local player = AvatarCache.me;
    -- if player ~= nil then
    --     local ac = player:GetComponent('AvatarController');
    --     if ac ~= nil then
    --         ac:SpeedUp(DataCache.myInfo.speed * 1000);
    --     end
    -- end

    ---------------- 骑乘相关 ------------------
    --初次登陆 必然要下马
    -- print("OnRoleCreateFinished")
    -- print(bFirstLoad)
    if bFirstLoad then
        -- print("ini!")
        client.horse.RideHorse(false)
    else
        local ridehorse = false
        --检查立即上马标记
        if client.horse.Flag_SceneLoadRide == true then
            --print("oh! Flag_SceneLoadRide true!!!")
            ridehorse = true
        end
        --检查当前地图是否可以骑乘
        local mapsid = DataCache.scene_sid
        if tb.AreaTable[mapsid] ~= nil and tb.AreaTable[mapsid].default.rider == false then
            --下马
            ridehorse = false
            client.horse.ClearAutoRideFlag()
        end
        --
        if ridehorse then
            --print("RideHorse OnRoleCreateFinished")
            client.horse.RideHorse(true)
        end
    end
    ---------------------------------------------
    --红包----
    --print("8. MainUI.HideHongBaoIcon");
    if MainUI.HideHongBaoIcon ~= nil then
        MainUI.HideHongBaoIcon();
    end
    
    --第一次触发引导（临时）
    GuideManager.firstGuide();
    --获取
    -- 请求获取坐骑信息，回调中检查主界面红点
    client.horse.getServerHorse(function ()
        MainUI.showRedPoint();
        MainUIMenu.showRedPoint();
    end)
    client.fuben.q_get_fuben_record();

end

function OnRoleReborn(player)
    --重生
    PortalCrystal.SetOneTimeNotCheck()
    if player == AvatarCache.me then
        MainUI.OnCancelSelectObj()
    end
end

function OnRoleTransmit(player)
    if player == AvatarCache.me then
        MainUI.OnCancelSelectObj()
    end
   PortalCrystal.SetOneTimeNotCheck() 
end

local SendRegistrationID = function()
    local RegistrationID = NativeManager.GetInstance():GetRegistrationID();
    if RegistrationID ~= "" then
        -- print("上传RegistrationID:"..RegistrationID);
        local msg = {cmd = "save_reg_id", regId = RegistrationID}
        Send(msg);
    else
        -- print("未获取到RegistrationID!")
    end
end

function showMainScene()

    --print("2. showMainScene");
    local uiManager = UIManager.GetInstance();
    destroy(uiManager:FindUI('Login').gameObject);
    showLowBlood();
    showMainUI();
    CreateCollectProcess();
    CreateCommonProcess();
    CreateRightUpConfirm();
    CreateChatAssist();
    client.task.InitTaskList();
    client.enhance.getValueList(function()
        MainUI.showRedPoint();
        MainUIMenu.showRedPoint();
     end);  
    ui.InitSysLastTime()
    NoticeManager.RegisterAllNotice();
    SendRegistrationID();
end

function showLowBlood( )
    PanelManager:CreateConstPanel('LowBlood', false, true);   
end
