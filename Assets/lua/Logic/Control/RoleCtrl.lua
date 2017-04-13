function CreateRoleCtrl()
	local role = {}

	--玩家是否有队伍
	role.haveTeam = function ()
		return client.team.haveTeam()
	end

	role.isTeamLeader = function( )
		return client.team.isLeader(DataCache.roleID);
	end

	--玩家是否有公会
	role.haveClan = function ( )
		return client.legion.LegionBaseInfo.Id ~= nil
	end

	--玩家所在地图分线
	role.getLine = function ()
		return DataCache.fenxianID;
	end

	role.getTotalExp = function ()
		local exp = 0;
		for i=1, DataCache.myInfo.level - 1 do
			exp = exp + tb.ExpTable[i].levExp;
		end
		exp = exp + DataCache.myInfo.exp;
		return exp;
	end
	
	return role;
end

client.role = CreateRoleCtrl();