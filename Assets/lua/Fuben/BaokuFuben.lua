--宝库脚本
BaokuFuben = {};

function BaokuFuben.handleServerMsg(msgTable)
    local mType = msgTable["type"];
    if "mijing_over" == mType then
        EventManager.onEvent(Event.ON_MIJING_OVER);
    elseif "mijing_login" == mType then
		FubenManager.OnNotify(FubenHandlerType.OnStart, msgTable);
    end
end

SetPort("mijing_broadcast",BaokuFuben.handleServerMsg);


 
