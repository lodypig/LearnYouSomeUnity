client.gm = {};
client.gm.transmit = function(sceneSid)
	
	local msg = {cmd = "transmit", scene_sid = sceneSid}
	Send(msg, function ()
	-- 从水晶自动寻路到NPC不需要读条操作
	end);
end


client.gm.getAllSkill = function ()
	local career = DataCache.myInfo.career;
	return const.ProfessionAbility[career];
end