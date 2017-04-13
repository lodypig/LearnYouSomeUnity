function requestServerEvent()
    local requestSE = {}
    local timerlist = {}

    requestSE.cfg = 
    {
        { t = {5,2,5},       --每日5点获取登录奖励邮件，预留5秒误差
          fun = function()
            local msg = {}
            msg.cmd = "get_login_email";
            Send(msg)
          end
        }
    }

    function requestSE.Start()
        local timeNow = TimerManager.GetServerNowSecond();
        local ft = os.date("*t",timeNow)
        for i = 1,#requestSE.cfg do
            local cfg = requestSE.cfg[i]
            local t = os.time{year = ft.year,month = ft.month,day = ft.day,hour = cfg.t[1],min = cfg.t[2],sec = cfg.t[3]}
            if timeNow < t then
                local timer = Timer.New(cfg.fun, t - timeNow,1,false)
                timer:Start()
                timerlist[#timerlist + 1] = timer
            end
        end
    end

    function requestSE.OnDaychange()
        for i = 1,#timerlist do
            if timerlist[i] then
                timerlist[i]:Stop()
            end
        end
        timerlist = {}

        requestSE.Start()
    end

    return requestSE

end

client.requestSE = requestServerEvent()