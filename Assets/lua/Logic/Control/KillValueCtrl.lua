
function CreateKillValueCtrl()
	local KillValueCtrl = {};

  	-- 使用钻石清除杀戮值
  	function KillValueCtrl.ClearKillValue(clearType, itemNum, callback)
  		local msg = {cmd = "player_lib/clear_sin_value", type = clearType, num = itemNum};
  		Send(msg, function (Msg)
  			safe_call(callback);
  		end);
  	end

  	return KillValueCtrl;
end

client.killValueCtrl = CreateKillValueCtrl();
