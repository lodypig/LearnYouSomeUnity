function HolyProtectCtrl()
	local HolyProtect = {};
	HolyProtect.holylist = nil;

	function HolyProtect.GetHolyList()
		-- 此处将副本进度增加一个开启状态，state = 1为已开启，state = 0为没开启，
		-- 先假设已经到了第六章，前五章圣灵为已开启状态
		local mainTaskId = client.task.mainTaskSid;
		local chapter = client.holyProtect.GetHolyChapter();
		local progress = tb.TaskTable[mainTaskId].progress;
		local holylist = tb.holyTable;
		for i = 1, #holylist do
			if i < chapter then
				holylist[i].state = 1;
				holylist[i].jindu = 1;
			else
				if i == chapter then
					holylist[i].state = 1;
					if progress == 100 then
						holylist[i].jindu = 1;
					else
						holylist[i].jindu = 0;
					end
				else
					holylist[i].state = 0;
					holylist[i].jindu = 0;
				end
			end
		end
		HolyProtect.holylist = holylist;
	end

	function HolyProtect.GetHolyChapter()
		local mainTaskId = client.task.mainTaskSid;
		local chapter = tb.TaskTable[mainTaskId].chapter;
		return chapter;
	end

	return HolyProtect;
end
client.holyProtect = HolyProtectCtrl(); 