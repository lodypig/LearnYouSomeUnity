client.MsgFormatCtrl = {
	refresh_boss_appear = {
		format_str = "世界BOSS已出现，各位勇士可前往挑战，共同捍卫魔纹大陆！",
		format_fun = function(format, ParseType)
			activity.RequestBossState();
			return string.format(format);
		end
	},
	kill_boss = {
		format_str = "%s已被击杀！",
		format_fun = function(format, bossname) --, killername)
			activity.RequestBossState();
			return string.format(format, client.tools.ensureString(bossname)) --, client.tools.ensureString(killername))
		end
	},
	create_legion = {
		format_str = "[color:255,255,255,%s][color:230,213,157,成功创建了公会][color:239,101,59,%s][color:230,213,157,，诚邀有志之士加入。]",
		format_fun = function(format, juntuanzhangname, legionname)
			return string.format(format, client.tools.ensureString(juntuanzhangname), client.tools.ensureString(legionname))
		end
	},
	get_yiwu = {
		format_str = "[color:155,188,255,%s][color:255,255,255,在拾取遗物时获得了][color:255,126,40,%s][color:255,255,255,，真是羡煞旁人！]";
		format_fun = function(format, roleName, orangeList) --, killername)
			local str = nil;
			for i=1,#orangeList do
				local equipInfo = tb.EquipTable[orangeList[i]];
				if str == nil then
					str = equipInfo.name;
				else
					str = str.."、"..equipInfo.name;
				end
			end
			return string.format(format, client.tools.ensureString(roleName), str)
		end
	},
}


client.MsgFormatCtrl.GetString = function(FormatType, content)
	local temp = client.MsgFormatCtrl[FormatType]
	if temp == nil then
		return nil
	end
	if temp.format_fun == nil then
		return string.format(temp.format_str, unpack(content))
	else
		return temp.format_fun(temp.format_str, unpack(content))
	end
end