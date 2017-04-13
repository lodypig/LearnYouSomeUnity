
function ServerRoleSettingCtrl()
	local Setting = {};
	--服务器角色设置数据索引
	Setting.SettingIndex = {
		AutoTeam = 1,
		FriendChat = 2,
		BeginOffline = 3,
		OfflineDead = 4,
		OfflineTimeout = 5,
		OfflineLevelUp = 6,
		OfflineBagFull = 7,
	}

	--设置默认为true
	for k,v in pairs(Setting.SettingIndex) do
		Setting[v] = true;
	end
	-- Setting.AutoTeam = true

	-- get
	Setting.get_server_role_setting = function()
		local msg = { cmd = "get_role_setting"};
		Send(msg, function(msg)
			if msg.role_setting ~= nil and #msg.role_setting ~= 0 then
				for k,v in pairs(msg.role_setting) do
					-- print("role_setting:"..k..","..v)
					Setting[k] = (v==1);
				end
	   		end
     	end);
	end

	--set auto team
	Setting.set_server_role_setting = function(settingIndex,toggle)
		local value = 0;
		if toggle == true then
			value = 1;
		end
		local msg = { cmd = "set_role_setting", index = settingIndex, value = value};
		Send(msg, function(msg)
    		if msg.ret == "ok" then
    			Setting[settingIndex] = toggle
    		end
     	end);
	end

	Setting.get_setting_value = function(settingIndex)
		return Setting[settingIndex];
	end

	return Setting
end

SRSetting = ServerRoleSettingCtrl()
