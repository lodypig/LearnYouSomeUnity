--主线副本管理
PlotlineFuben = {};

--todo广播给界面  倒计时
PlotlineFuben.handleServerMsg = function (msg)
	local msgType = msg.type;
	if msgType == "fuben_success" then
		FubenManager.OnNotify(FubenHandlerType.OnResult, { success = true , passtime = msg.passTime});
	elseif msgType == "fuben_fail" then
		FubenManager.OnNotify(FubenHandlerType.OnResult, { success = false });
	elseif msgType == "fuben_login" then
		FubenManager.OnNotify(FubenHandlerType.OnStart, msg);
	end
end

--离开副本
function PlotlineFuben.LeaveFuben()
	DataCache.myInfo.hp  =  DataCache.myInfo.maxHP;
	EventManager.onEvent(Event.ON_BLOOD_CHANGE);
    EventManager.onEvent(Event.ON_LEAVE_FUBEN);
	local msg = {cmd = "plotline_fuben/leave"}
    Send(msg); 
end

--挑战副本
function PlotlineFuben.ChallengeFuben(taskId)
	local msg = {cmd = "plotline_fuben/challenge", task_id = taskId}
    Send(msg);
end


SetPort('plotline_fuben_broadcast', PlotlineFuben.handleServerMsg)

