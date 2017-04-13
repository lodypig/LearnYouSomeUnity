

function AddBuffHandlers(handlers)

	-- 弓手迅捷: 40021401
	handlers[40021401] = {

		OnAddBuff = function (target_uid, source_uid, buff_sid)
			uFacadeUtility.PlayBuffEffect(source_uid, buff_sid, "archer_female_special_buff", target_uid, "");
		end,

		OnRemoveBuff = function (target_uid, source_uid, buff_sid)
			
		end,
	};

	-- 战士专精 拦截: 40012005 暂时用chuansongbaohu
	handlers[40012005] = {

		OnAddBuff = function (target_uid, source_uid, buff_sid)
			uFacadeUtility.PlayBuffEffect(source_uid, buff_sid, "chuansongbaohu", target_uid, "");
		end,

		OnRemoveBuff = function (target_uid, source_uid, buff_sid)
			
		end,
	};

	-- 迅捷专精: 40022003 
	handlers[40022003] = {

		OnAddBuff = function (target_uid, source_uid, buff_sid)
			uFacadeUtility.PlayBuffEffect(source_uid, buff_sid, "archer_female_special_buff", target_uid, "");
		end,

		OnRemoveBuff = function (target_uid, source_uid, buff_sid)
			
		end,
	};
	-- 自然亲和 专精: 40022004 
	handlers[40022004] = {

		OnAddBuff = function (target_uid, source_uid, buff_sid)
			uFacadeUtility.PlayBuffEffect(source_uid, buff_sid, "fashijiaxue", target_uid, "");
		end,

		OnRemoveBuff = function (target_uid, source_uid, buff_sid)
			
		end,
	};

	-- 虚空跳跃 专精: 40032005 
	handlers[40032005] = {

		OnAddBuff = function (target_uid, source_uid, buff_sid)
			uFacadeUtility.PlayBuffEffect(source_uid, buff_sid, "archer_female_special_buff", target_uid, "");
		end,

		OnRemoveBuff = function (target_uid, source_uid, buff_sid)
			
		end,
	};
	-- 虚空愈合 专精: 40032004 
	handlers[40032004] = {

		OnAddBuff = function (target_uid, source_uid, buff_sid)
			uFacadeUtility.PlayBuffEffect(source_uid, buff_sid, "fashijiaxue", target_uid, "");
		end,

		OnRemoveBuff = function (target_uid, source_uid, buff_sid)
			
		end,
	};

	-- 无敌 Buff
	handlers[40001010] = {

		OnAddBuff = function (target_uid, source_uid, buff_sid)
			uFacadeUtility.PlayBuffEffect(source_uid, buff_sid, "chuansongbaohu", target_uid, "");
		end,

		OnRemoveBuff = function (target_uid, source_uid, buff_sid)
			
		end,
	};

	-- 挂机保护buff
	-- handlers[40001011] = {
	-- 	OnAddBuff = function (target_uid, source_uid, buff_sid)
	-- 			print("source_uid:"..source_uid)
	-- 		print("OnAddBuff:40001011")
	-- 		--有buff的时候屏蔽头上的图标
	-- 		local title = uFacadeUtility.GetAvatarTitle(target_uid);
	-- 		Fight.SetBoxIcon(title,0)
	-- 	end,

	-- 	OnRemoveBuff = function (target_uid, source_uid, buff_sid)
	-- 			print("source_uid:"..source_uid)
	-- 		print("OnRemoveBuff:40001011")
	-- 		local target = AvatarCache.GetAvatar(target_uid);
	-- 		local title = uFacadeUtility.GetAvatarTitle(target_uid);
	-- 		Fight.SetBoxIcon(title,target.treasure_number)
	-- 	end,
	-- };

end

function CreateBuffManager()
	local t = {};

	t.BuffTable = {};
	t.handlers = {};

	-- 添加 Buff 处理
	AddBuffHandlers(t.handlers);

	-- 添加 Buff
	t.OnAddBuff = function (target_uid, source_uid, buff_sid)
		local handler = t.handlers[buff_sid];
		if handler == nil or handler.OnAddBuff == nil then
			return;
		end
		handler.OnAddBuff(target_uid, source_uid, buff_sid);
		if t.BuffTable[target_uid] == nil then
			t.BuffTable[target_uid] = {};
		end
		t.BuffTable[target_uid][buff_sid] = 1;
	end;

	-- 删除 Buff
	t.OnRemoveBuff = function (target_uid, source_uid, buff_sid)
		uFacadeUtility.RemoveBuff(target_uid, source_uid, buff_sid);
		local handler = t.handlers[buff_sid];
		if handler == nil or handler.OnRemoveBuff == nil then
			return;
		end
		handler.OnRemoveBuff(target_uid, source_uid, buff_sid);
		if t.BuffTable[target_uid] ~= nil then
			if t.BuffTable[target_uid][buff_sid] ~= nil then
				t.BuffTable[target_uid][buff_sid] = nil
			end
		end
	end;

	t.HaveBuff = function (target_uid,buff_sid)
		if t.BuffTable[target_uid] ~= nil then
			if t.BuffTable[target_uid][buff_sid] ~= nil then
				return true;
			end
		end			
		return false;
	end

	return t;
end


BuffManager = CreateBuffManager();

