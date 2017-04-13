TimerManager = (function()
	local offset;
	local frameCount = 0;
	local lastDaySecond = 0;
	local t = {};
	local initFlag = false;
	local DAY_SECONDS = 86400;
	local HOUR_SECONDS = 3600;
	local nowSecond = 0;
	local nowMillSecond = 0;
	local unityTime;

	t.GetServerNowSecond = function ()
		if initFlag then
			return nowSecond;
		end
		error("TimeManager_not_init");
		return nil;
	end;

	t.GetServerNowMillSecond = function ()
		if initFlag then
			return nowMillSecond;
		end
		error("TimeManager_not_init");
		return nil;
	end;

	t.GetUnityTime = function ()
		return unityTime;
	end

	t.Update = function (localTime, temUnityTime)
		unityTime = temUnityTime;
		if offset == nil then
			return;
		end
		frameCount = frameCount + 1;
		nowMillSecond = localTime + offset;
		local temnowSecond = nowMillSecond / 1000;
		if nowSecond == 0 then
			nowSecond = temnowSecond;
			lastDaySecond = nowSecond;
			return;	
		end
		if nowSecond < temnowSecond then
			nowSecond = temnowSecond;
			EventManager.onEvent(Event.ON_TIME_SECOND_CHANGE);
		end
		if frameCount % 1000 == 0 and lastDaySecond > 0 and not t.SameDayCheck(lastDaySecond) then
			lastDaySecond = nowSecond;
			EventManager.onEvent(Event.ON_TIME_DAY_CHANGE);
		end	
	end;

	t.PingBack = function (offsetTime)
		initFlag = true;
		offset = offsetTime;
	end
	
	t.SameDayCheck = function (timeSecond)
		local offset = 5*60*60;
		local checkDate = os.date("*t", timeSecond - offset);
		local nowDate = os.date("*t", nowSecond - offset);
		return checkDate.year == nowDate.year and 
		checkDate.month == nowDate.month and checkDate.day == nowDate.day 
	end

	t.GetDayOfWeek = function()
		local date = os.date("*t", nowSecond); 
		--从周天开始 从1到7
		local dweek = date.wday - 1;
		if dweek == 0 then
			return 7;
		end
		return dweek;
	end

	t.GetAfterSeconds = function (dayOfWeek, everyDayFalg, hour, minute, second)
		local date = os.date("*t", nowSecond);
		local result = (hour - date.hour) * HOUR_SECONDS + (minute - date.min)*60 + (second - date.sec);
		if everyDayFalg then  --第二天或者今天的指定时间点
			if result < 0 then
				return result+DAY_SECONDS;
			end
			return result;
		else		--第二周或者这个周的指定时间点
			local dayDelta = dayOfWeek - t.GetDayOfWeek();
			result = dayDelta * DAY_SECONDS + result;
			if result < 0 then
				return result + 7 * DAY_SECONDS;
			end
			return result;
		end
	end

	return t;
end)()
