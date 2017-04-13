function HorseCtrl()
	local module = {};
	module.horseList = nil;
	module.horseMap = nil;
	module.ride_horse = 0;
	module.put_on_horse = 0;
	module.MAX_STAR = 10;
	module.ui_auto_train = false;
	module.ui_auto_enhance = false;
	module.OPEN_LEVEL = 18;
	module.horseTableCache = nil;

	--------------------- init -----------------------------

	local function initDataCache()
		module.horseTableCache = {};		
		for i,v in pairs(tb.HorseTable) do
			module.horseTableCache[#module.horseTableCache + 1] = i;
		end
		table.sort(module.horseTableCache);
		for i = 1, #module.horseTableCache do
			module.horseTableCache[i] = tb.HorseTable[module.horseTableCache[i]];
		end
	end

	initDataCache();

	-------------------- msg parse-----------------------------
	-- 解析坐骑sample
	local function parseHorse(sample)
		local horse = {};
		horse.sid = sample[1];
		local info = sample[2];
		horse.enhance_lv = info[1];
		horse.id = info[2];
		horse.progress = info[3];
		horse.star = info[4];
		horse.train_time = info[5];
		return horse;
	end

	-- 解析坐骑列表
	local function parseHorseList(horseMsg)
		local horseList = {};
		local horseMap = {};
		local horse;
		for i = 1, #horseMsg do
			horse = parseHorse(horseMsg[i]);
			horseList[#horseList + 1] = horse;
			horseMap[horse.sid] = horse;
		end
		return horseList, horseMap;
	end

	--------------------msg api section -----------------------------
	-- 获取服务器所有坐骑信息
	function module.getServerHorse(cb)
		local msg = {cmd = "get_all_horse"};
		Send(msg, function (reMsg) 
			if #reMsg.horse_list == 0 then
				safe_call(cb);
				return;
			end
			module.horseList, module.horseMap = parseHorseList(reMsg.horse_list);
			module.ride_horse = reMsg.ride_hrose[1];
			safe_call(cb);
		end);
	end

	-- 解锁坐骑
	function module.unlock(cb, horseSid)
		local msg = {cmd = "active_horse", sid = horseSid};
		Send(msg, function (reMsg) 
			if module.horseList == nil then
				module.horseList = {};
				module.horseMap = {};
			end
			local horse = parseHorse(reMsg.horse);
			module.ride_horse = reMsg.ride_horse[1];
			module.horseList[#module.horseList + 1] = horse;
			module.horseMap[horse.sid] = horse;
			safe_call(cb);
			EventManager.onEvent(Event.ON_HORSE_UNLOCK_OR_CANUPGRADE);
		end);
	end

	-- 培养坐骑
	function module.train(cb, horseSid, count)
		local msg = {cmd = "train_horse", sid = horseSid, count = count};
		Send(msg, function (reMsg) 
			if reMsg.success == 1 then
				local horse = module.horseMap[horseSid];
				horse.star[reMsg.add_index] = horse.star[reMsg.add_index] + 1;
				cb(reMsg.success, reMsg.add_index, horse.star[reMsg.add_index]);
			else
				cb(reMsg.success);
			end
		end);
	end

	-- 坐骑进阶
	function module.enhance(cb, horseSid, count)
		local msg = {cmd = "enhance_horse", sid = horseSid, count = count};
		Send(msg, function (reMsg)
			local horse = module.horseMap[horseSid];
			local horseTable = tb.HorseTable[horseSid];
			local success = false;
			if reMsg.enhance_lv > horse.enhance_lv then
				success = true;
				for i = 1, #horse.star do
					horse.star[i] = 0;
				end
				if #horse.star < #horseTable.attr then
					horse.star[#horse.star + 1] = 0;
				end
			end
			module.ride_horse = reMsg.ride_horse[1];
			horse.enhance_lv = reMsg.enhance_lv;
			horse.progress = reMsg.progress;
			cb(success, reMsg.critical);
		end);
	end

	-- 激活坐骑
	function module.active(cb, horseSid)
		local msg = {cmd = "ride_horse", sid = horseSid};
		Send(msg, function (reMsg)
			if reMsg.type == 1 then
				module.ride_horse = horseSid;	
			end
			cb();
		end);
	end

	-- 上下坐骑
	function module.putOnHorse(cb, isPutOn)
		local msg = {cmd = "put_on_horse", isPutOn = isPutOn};
		Send(msg, cb);
	end

	--------------------logic api section -----------------------------	
	-- Horse = {sid, enhance_lv, id, refresh_day, progress, star, train_time}
	-- 通过sid获取Horse
	function module.getHorse(sid)
		return module.horseMap and module.horseMap[sid];
	end

	-- 服务器登录时发送坐骑sid
	function module.onLoginMsg(ride_horse)
		if ride_horse == nil or ride_horse == 0 then
			module.ride_horse = 0;
		else
			module.ride_horse = ride_horse[1];
			module.put_on_horse = ride_horse[2];
		end
	end

	function module.checkHorseStatus()
		--是否处于上马状态
		if module.put_on_horse == 1 then
			Util.Ride(module.ride_horse);
		end
	end

	function module.isMaxEnhance(horse)
		return horse and (horse.enhance_lv >= tb.HorseTable[horse.sid].max_enhance)
	end

	-- 判断某个坐骑是否培养满星
	function module.isMaxStar(horseSid)
		if not module.horseMap then
			return false;
		end
		local horse = module.horseMap[horseSid];
		if not horse then
			return false;
		end
		for i = 1, #horse.star do
			if horse.star[i] < module.MAX_STAR then
				return false;
			end
		end

		if horse.enhance_lv >= tb.HorseTable[horse.sid].max_enhance then
			return false;
		end
		return true;
	end
	-- 获取坐骑某一个属性附加值
	function module.getHorseAddValue(horseTable, horse, index)
		local addValue = tb.horseAddAttrTable[horseTable.attr[index]];
		return ((horse.enhance_lv - index) * module.MAX_STAR + horse.star[index]) * addValue;
	end

	-- 计算坐骑的战力
	function module.calcFP(horseTable, horse)
		local addValue, addFPValue;
		local fp = 0;
		local career = DataCache.myInfo.career;
		for i = 1, #horse.star do
			addFPValue = tb.AttrFPointTable[horseTable.attr[i]];
			addValue = module.getHorseAddValue(horseTable, horse, i);
			fp = fp + addValue * addFPValue;
		end
		return math.floor(fp);
	end

	function module.checkCouldTrain(horse)
		local horseTrainTable = tb.horseTrainTable[horse.enhance_lv];
		return Bag.GetItemCountBysid(horseTrainTable.train_cost_material) >= horseTrainTable.train_cost_count and DataCache.role_money >= horseTrainTable.train_cost_money;
	end

	function module.checkCouldEnhance(horse)
		local horseTrainTable = tb.horseTrainTable[horse.enhance_lv];
		return Bag.GetItemCountBysid(horseTrainTable.enhance_cost_material) >= horseTrainTable.enhance_cost_count and DataCache.role_money >= horseTrainTable.enhance_cost_money;
	end

	function module.checkCouldUp(horse)
		local horseTable = tb.HorseTable[horse.sid];
		if horse.enhance_lv == horseTable.max_enhance then
			return false;
		end
		if module.isMaxStar(horse.sid) then
			return module.checkCouldEnhance(horse);
		else
			return module.checkCouldTrain(horse);
		end
	end

	-- 判断当前是否有可以乘坐的坐骑  有：true， 没有：false
	function module.checkCanRide()
		local flag = false;
		for i = 1, #module.horseList do
			local horseSid = module.horseList[i].sid;
			if module.horseList[i].enhance_lv >= tb.HorseTable[horseSid].ride_enhance then
				flag = true;
				break;
			end
		end
		return flag;
	end

	function module.SwitchRideHorse()
		local ac = AvatarCache.me;
	    if ac == nil then
	        return
	    end
	    module.RideHorseCtrl(ac, not ac.is_riding)
	end

	function module.RideHorse(ride)
		local ac = AvatarCache.me;
	    if ac == nil then
	        return
	    end
	    if ac.is_riding == ride then
	    	return
	    end
	    -- print(debug.traceback())
	    module.RideHorseCtrl(ac, ride)
	end

	function module.RideHorseCtrl(ac, ride)
		if ride == false then
			--当前激活的坐骑id
	        if module.ride_horse == 0 then
	        	return
	        end
			--*** 下马
	        --应该立即处理所有与马有关的显示
	        --服务器回复的消息其实是没有用的 有用的是速度变化的消息
	        --这样子显示才是正常的
	        --print(debug.traceback())

	        uFacadeUtility.UnRideHorse(ac.id)
	        module.putOnHorse(function() end, 0)
		else
			-- print(debug.traceback())
			--*** 上马
			--判断是否可以上马...
	        if not module.CanRideHorse(ac) then
	            return
	        end

            uFacadeUtility.RideHorse(ac.id)

            module.putOnHorse(function() end, 1)
            --既然上马了 就清空自动上马标记 类似重置
			module.ClearAutoRideFlag()
		end
	end

	----------------------------------------------------
	--一系列自动上马操作
	----------------------------------------------------
	module.Flag_SceneLoadRide = false
	module.Flag_FightLeaveRide = false
	module.Flag_3sRide = false

	--脱战骑乘检查
	function module.FightLeaveRideCheck()
		if module.Flag_FightLeaveRide == true then
			module.Delay3sRide()
			module.Flag_FightLeaveRide = false
		end
	end

	--清空所有自动骑乘标记
	--1) 进入战斗状态清空(攻击 或 被打)
	function module.ClearAutoRideFlag()
		module.Flag_SceneLoadRide = false
		module.Flag_FightLeaveRide = false
		module.Flag_3sRide = false
	end

	--延迟3s后上马
	function module.Delay3sRide()
		module.Flag_3sRide = true

		MainUI.this:Delay(3, function()
			module.Flag_3sRide = false
			--如果当前已经停止寻路 则无需再进行骑乘操作
			-- print("Delay 3s Ride callback!!")
			if AutoPathfindingManager.IsAutoPathfinding() then
				-- print("in")
				module.RideHorse(true)
			end
		end)
	end
	----------------------------------------------------

	function module.CanRideHorse(ac)

		if DataCache.myInfo == nil then
			return false
		end
		--尝试准备坐骑数据

        if DataCache.myInfo.level < module.OPEN_LEVEL then
            return false
        end
        --是否处于战斗状态(server)

        if DataCache.myInfo.fight_state_time > 0 then
            return false
        end
        --是否处于自动战斗中
        if ac.IsAutoFighting then
        	return false
        end
        --当前激活的坐骑id
        if module.ride_horse == 0 then
        	return false
        end
        --地图以及区域是否可以上马
        --TODO 配置 该地图无法骑马

        local mapsid = DataCache.scene_sid
    	if tb.AreaTable[mapsid] ~= nil and tb.AreaTable[mapsid].default.rider == false then
    		return false
    	end
        --死亡判断

        if DataCache.myInfo.hp <= 0 then
        	return false
        end
        --
        return true
	end

	-------------------检查坐骑解锁条件---------------------------------
	module.checkUnlockFunc = {
		function (horseTable) 
			return true;
		end,
		function (horseTable) 
			return false;
		end,
		function (horseTable) 
			return false;
		end,
		function (horseTable) 
			return false;
		end,
		function (horseTable) 
			return false;
		end,		
		function (horseTable)
			return DataCache.myInfo.level >= horseTable.active_value;
		end
	}

	--检查当前状态机状态与坐骑动画播放
	function module.CheckHorseAnimatorPlay(ds, aniName)
		--如果有骑马 则播放aniName
		if ds.is_riding then
			uFacadeUtility.HorseAnimatorPlay(ds.id, aniName)
		end
	end

	function module.LoadHorse()

	end

	return module;
end

client.horse = HorseCtrl();