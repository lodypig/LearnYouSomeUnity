-- 游戏设置
function CreateGameSettings()
	local t = {};

	-- 默认值
	t.default_values = {

		  system_msgPush = false,
      system_hideBlood = true,
      system_hideTitle = false,
      system_fluencyMode = false,
      system_bgmMute = false,
      system_soundMute = false,

      fight_useAOE = true,
      fight_useEX = true,
      fight_useSpecial = true,
      fight_useDrug = true,
      fight_autoBuy = true,
      fight_bloodSetting = 60,
      fight_drugId = 10001001,
      fight_autoClearTiredValue = true,

      chat_channel = 4,			-- 默认世界频道
	    showChatTeam = true,
	    showChatWorld = true,
	    showChatClan = true,
	    playSpeechTeam = true,	-- 自动播放语音频道
	    playSpeechWorld = true,	-- 自动播放语音频道
	    playSpeechClan = true,	-- 自动播放语音频道

	    activityNotice = "",
	};

	-- 设置配置默认值
    t.SetDefault = function ()
    	local settings = DataCache.settings;
  		for k, v in pairs(settings) do
  			settings[k] = nil;
  		end
    	local default_values = t.default_values;
    	for k, v in pairs(default_values) do
    		settings[k] = v;
    	end
    end;

    -- 检查并打印
    t.CheckAndPrint = function (settings)
    	local default_values = t.default_values;
    	local success = true;
    	for k, v in pairs(default_values) do
    		if settings[k] == nil then
    			--print(string.format("[error] settings[%s] is missing, will auto correct !", k));
    			success = false;
    		end
    	end
    	return success;
    end;

    -- 检查值
    t.Check = function (settings)
    	local default_values = t.default_values;
    	local success = true;
    	for k, v in pairs(default_values) do
    		if settings[k] == nil then
    			success = false;
    		end
    	end
    	return success;
    end;

    -- 纠正值
    t.Correct = function (settings)
    	local default_values = t.default_values;
    	for k, v in pairs(default_values) do
    		if settings[k] == nil then
    			settings[k] = default_values[k];
    		end
    	end
    end;

    -- 清空，设置成默认值
   	t.Clear = function ()
   		t.SetDefault();
   	end;

   	-- 清空并保存
   	t.ClearAndSave = function ()
   		t.Clear();
   		t.Save();
   	end;

   	-- 隐藏所有玩家
   	t.ApplyOtherPlayerTitlesShow = function ()
   		local settings = DataCache.settings;
 			local avatars = AvatarCache.GetAllAvatars();
      -- print(#avatars);
   		for k, v in pairs(avatars) do
   			local avatar = v;
        if avatar.role_type == RoleType.OtherPlayer then
          if avatar.selected then
            local title = uFacadeUtility.GetAvatarTitle(avatar.id);
            if title ~= nil then
              -- 显示/隐藏血条
              local BloodBarWp = title:GO('Panel.BloodBar');
              if BloodBarWp ~= nil then
                BloodBarWp:Show();
              end
              local OtherTitleWp = title:GO('Panel.Other.Title');
              if OtherTitleWp ~= nil then
                if OtherTitleWp.Sprite == nil then
                  OtherTitleWp:Hide();
                else
                  OtherTitleWp:Show();
                end
              end
            end
          else
  	   			local title = uFacadeUtility.GetAvatarTitle(avatar.id);
  	   			if title ~= nil then
              -- 显示/隐藏血条
              local BloodBarWp = title:GO('Panel.BloodBar');
              if BloodBarWp ~= nil then
                if settings.system_hideBlood then
                  BloodBarWp:Hide();
                else
                  BloodBarWp:Show();
                end
              end
              -- 显示/隐藏名称
              local OtherTitleWp = title:GO('Panel.Other.Title');
              if OtherTitleWp ~= nil then
                if settings.system_hideTitle then
  	   				    OtherTitleWp:Hide();
                else
                  if OtherTitleWp.Sprite == nil then
                    OtherTitleWp:Hide();
                  else
                    OtherTitleWp:Show();
                  end
                end
              end
              -- print("Hide: " .. avatar.id);
  	   			end
          end
        end
   		end
   	end;

   	t.Apply = function ()
   		local settings = DataCache.settings;
   		-- 应用音乐开启/关闭
   		uFacadeUtility.SetMusicMute(settings.system_bgmMute);
   		-- 应用音效开启/关闭
   		uFacadeUtility.SetSoundMute(settings.system_soundMute);
   		-- 应用其他玩家头顶文字显示或隐藏
   		t.ApplyOtherPlayerTitlesShow();
   	end;

   	-- 加载
   	t.Load = function (role_uid)
      --print("Load settings:");
      --print(role_uid);
   		local key = string.format("settings_%d", role_uid);
      if not uFacadeUtility.HasPlayerPrefs(key) then
      	--print("Load Default Settings: " .. key);
      	t.SetDefault();
      	t.SaveAndApply();
      	return;
      end
      local s = uFacadeUtility.GetPlayerPrefs(key);
      if s == nil or s == "" then
      	--print("Load Default Settings: " .. key);
      	t.SetDefault();
      	t.SaveAndApply();
      	return;
      end
        
    	local settings = json.decode(s, 0);
	    t.CheckAndPrint(settings);
	    if not t.Check(settings) then
	    	t.Correct(settings);
	    	DataCache.settings = settings;
	    	t.Save();
	    else
	    	DataCache.settings = settings;
	    end
	    
      t.Apply();

      -- print(string.format("Load Settings: key=%s", key));
      -- print(settings);
   	end;

   	t.SaveAndApply = function ()
   		t.Save();
   		t.Apply();
   	end;

   	-- 保存默认值
   	t.Save = function ()
   		
   		local myInfo = DataCache.myInfo;
   		local key = string.format("settings_%d", myInfo.role_uid);
   		local settings = DataCache.settings;
      local str = json.encode(settings);
      uFacadeUtility.SavePlayerPrefs(key, str);

        -- print(string.format("Save Settings: key=%s, value=%s", key, str));
        -- print(settings);
   	end;

   	-- 创建的时候先创建默认值
    t.SetDefault();

	return t;
end


GameSettings = CreateGameSettings();