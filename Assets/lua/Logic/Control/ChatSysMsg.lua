local formatName = function( text , type)
	if type == "special" then
		return client.tools.formatRichTextColor(text, const.mainChat.specialColor);
	elseif type == "special2" then
		return client.tools.formatRichTextColor(text, const.mainChat.specialColor2);
	else
		return client.tools.formatRichTextColor(text, const.mainChat.nameColor);
	end
end

local ChatString = {
	--世界BOSS提示
	refresh_boss_appear = "世界BOSS已出现，各位勇士可前往挑战，共同捍卫魔纹大陆！",
	kill_boss = "%s已被击杀！",

	--挖宝系统
	create_mowu = "%s不慎挖开了魔物洞窟的封印，魔物正在[%s,%s,0,0]作乱，各路英雄快前往平乱吧！",
	create_normal_mijing = "%s在挖宝时触动了封印，一个持续5分钟的宝库出现在了[%s,%s,0,0]，各路英雄快前往一探究竟！",
	create_super_mijing = "%s在挖宝时触动了封印，一个持续15分钟的高级宝库出现在了[%s,%s,0,0]，各路英雄快前往一探究竟！",

	--公会提示
	create_legion = function (Name, LegionName)
		local str = "%s成功创建了公会%s，诚邀有志之士加入。";
		return string.format(str, formatName(Name), formatName(LegionName, "special2"));
	end, 

	dismiss_legion = function()
		local str = "%s执行了解散操作，公会将在72小时后正式解散！";
		return string.format(str, formatName(client.legion.LegionBaseInfo.TuanZhangName));
	end,

	legion_construction = function (Name, CostType, CostNum, LegionAdd)
		local str = "%s捐献了%s%s，为公会增加了%d点建设度。";
		local TypeName = "钻石"
		if CostType == "money" then
			TypeName = "金币"
		end
		return string.format(str, formatName(Name), TypeName, CostNum, LegionAdd);
	end,

	legion_positionchange = function (rolename, targetname, newpos, oldpos)
		if newpos < oldpos then
			return string.format("%s将%s提升为%s，恭喜！",formatName(rolename),formatName(targetname),const.legionPos[newpos])
		else
			return string.format("%s将%s降职为%s。",formatName(rolename),formatName(targetname),const.legionPos[newpos])
		end
	end,

	leave_legion = function(Name)
		local str = "%s退出了公会。";
		return string.format(str, formatName(Name));
	end,

	legion_memberjoinin = function (rolename)
		local str = "欢迎%s加入本公会！";
		return string.format(str, formatName(rolename));
	end,

	legion_chuanwei_success = function(rolename, targetname)
		local str = "%s传位给%s，恭喜%s成为新任会长！";
		return string.format(str,formatName(rolename),formatName(targetname),formatName(targetname))
	end,

	legion_kickout = function(rolename, targetname)
		local str = "%s将%s逐出了公会";
		return string.format(str,formatName(rolename),formatName(targetname))
	end,

	legion_redpacket_overdue = function ( rolename )
		local str = "%s的红包逾期未发，现由本总管代劳发放。"
		return string.format(str, formatName(rolename));
	end,

	legion_redpacket_over = function (info)
		local info = client.legion.parseRedPacket(info)
		local mostname = ""
		local mostdiamond = 0
		for i = 1,#info.MemberList do
			if info.MemberList[i][2] > mostdiamond then
				mostdiamond = info.MemberList[i][2]
				mostname = info.MemberList[i][1]
			end
		end
		local time = math.floor(TimerManager.GetServerNowMillSecond()/1000) - info.SendTime;
		local ss = ""
		if time < 60 then
			ss = time.."秒"
		elseif time < 3600 then
			ss = math.floor(time/60).."分钟"
		elseif time < 86400 then
			ss = math.floor(time/3600).."小时"
		else 
			ss = "2天"
		end
		local str = "%s的%d个红包共%d钻石，%s被抢完，%s手气最佳，抢到了%d钻石。";
		return string.format(str, formatName(info.OwnerName),info.PacketNum,client.legion.get_redpacket_totaldiamond(info),ss, formatName(mostname),mostdiamond)
	end,

	legion_maintenance = function ()
		local str = "公会消耗了%d点建设度用于日常维护。";
		local cost = tb.legionBase[client.legion.LegionBaseInfo.Level].maintaincost
		return string.format(str, cost);
	end,

	get_yiwu = function (roleName,orangeList)
		local format = "[color:155,188,255,%s]在拾取遗物时获得了[color:255,126,40,%s]，真是羡煞旁人！]";
		local str = nil;
		--print(orangeList)
		for i=1,#orangeList do
			local equipInfo = tb.EquipTable[orangeList[i]];
			if str == nil then
				str = equipInfo.name;
			else
				str = str.."、"..equipInfo.name;
			end
		end
		return string.format(format, roleName, str)
	end,

	legion_signature = function (roleName,signature)
		local str = "%s大声说道：%s";
		return string.format(str,formatName(roleName),formatName(signature))
	end,

	leader_leave_legion = function (roleName,targetName)
		local format = "由于原会长%s退出了公会， %s自动接任成为新会长";
		return string.format(format,formatName(roleName),formatName(targetName))
	end,

	auto_chuanwei = function (roleName,signature)
		local str = "因原会长%s连续3天以上不在线，%s已自动接任成为新会长！";
		return string.format(str,formatName(roleName),formatName(signature))
	end,

	legion_predownlevel = "当前公会建设度不足以进行公会的日常维护，如果24小时后公会建设度仍然不足，公会将会被强制降级！",
	legion_downlevel = "由于公会的繁荣度长期处于较低水平，已被强制降为%d级。",
	legion_levelup = function (roleName,newLevel)
		local str =  "%s将公会成功升级到%d级！"
		return string.format(str,formatName(roleName),newLevel)
	end,
	legion_predismiss = "由于公会的繁荣度长期不足20，如不及时整顿恢复，公会将在%d天后被强制解散。",
	legion_boardchange = "公会公告：%s。",
	legion_welfare = "公会已划拨%d资金作为分红福利",
	get_welfare = function (roleName,money)
		local str = "%s领取了上周的分红福利%s金币";
		return string.format(str,formatName(roleName),formatName(money))
	end
}

local parseParam = function (param)
	if type(param) == "table" then
		for i=1, #param do
			param[i] = client.tools.ensureString(param[i]);
		end
		return unpack(param);
	else
		return param;
	end
end

client.GetChatString = function(MsgType, param)
	local temp = ChatString[MsgType]
	if temp == nil then
		return ""
	end

	if type(temp) == "function" then
		return temp(parseParam(param));
	else
		return string.format(temp, parseParam(param));
	end
end