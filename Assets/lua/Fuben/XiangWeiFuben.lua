--宝库脚本
XiangWeiFuben = {};
XiangWeiFuben.Entered_TaskId = {}

function XiangWeiFuben.isHaveEntered(tasksid)
	return XiangWeiFuben.Entered_TaskId[tasksid] == true
end

function XiangWeiFuben.handleServerMsg(msgTable)
    local mType = msgTable["type"];
    local tasksid = msgTable["tasksid"];
    local success = msgTable["success"];
    if "leave" == mType then
        AutoPathfindingManager.Cancel();
        DataCache.myInfo.hp  =  DataCache.myInfo.maxHP;
        EventManager.onEvent(Event.ON_BLOOD_CHANGE);
        EventManager.onEvent(Event.ON_LEAVE_FUBEN);

        UIManager.GetInstance():CallLuaMethod("Rebirth.close")
        
        
    	if success == 0 then
    		TaskTrigger.ResetState(tasksid)
        end 
        
        if UIManager.GetInstance():FindUI("MainUIXiangWeiFuben") ~= nil then
			UIManager.GetInstance():CallLuaMethod('MainUIXiangWeiFuben.onDestroy')
		end
    elseif "enter" == mType then
		XiangWeiFuben.Entered_TaskId[tasksid] = true
		FubenManager.OnNotify(FubenHandlerType.OnStart);
    end
end

function XiangWeiFuben.enter(tasksid)
	local msg = {cmd = "xiangwei_fuben/enter", task_id = tasksid}
    Send(msg);
end

function XiangWeiFuben.leave()
    DataCache.myInfo.hp  =  DataCache.myInfo.maxHP;
    EventManager.onEvent(Event.ON_BLOOD_CHANGE);
    EventManager.onEvent(Event.ON_LEAVE_FUBEN);

	local msg = {cmd = "xiangwei_fuben/leave"}
    Send(msg);
end


SetPort("xiangwei_broadcast",XiangWeiFuben.handleServerMsg);


 
