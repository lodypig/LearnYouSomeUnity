
function CreateBuffCtrl()
	local BuffCtrl = {};
	BuffCtrl.buffList = {};

  	function BuffCtrl.AddBuff(sid, useful_time, start_time)
  		for i=1,#BuffCtrl.buffList do
  			if BuffCtrl.buffList[i].sid == sid then

 				local buffTab = tb.BuffTable[sid];
  				BuffCtrl.buffList[i].useful_time = useful_time;
  				BuffCtrl.buffList[i].start_time = start_time;
				BuffCtrl.buffList[i].name = buffTab.name; 
				BuffCtrl.buffList[i].icon = buffTab.icon; 
				BuffCtrl.buffList[i].sorting_order = buffTab.sorting_order; 
				BuffCtrl.buffList[i].cd = buffTab.cd;
				BuffCtrl.buffList[i].show_cd = buffTab.show_cd;
				BuffCtrl.buffList[i].description = buffTab.description;

  				BuffCtrl.SortBuffList();
  				BuffCtrl.RefreshBuffShowArea();
  				return;
  			end
  		end
 		local buffTab = tb.BuffTable[sid];
 		if buffTab == nil then
 			return
 		end
  		table.insert(BuffCtrl.buffList,{sid = sid, useful_time = useful_time, start_time = start_time,name = buffTab.name, icon = buffTab.icon,
  		 sorting_order = buffTab.sorting_order, cd = buffTab.cd, show_cd = buffTab.show_cd, description = buffTab.description});
		
		BuffCtrl.SortBuffList();
		BuffCtrl.RefreshBuffShowArea();
  	end

  	function BuffCtrl.RemoveBuff(sid)
  		for i=1,#BuffCtrl.buffList do
  			if BuffCtrl.buffList[i].sid == sid then
  				table.remove(BuffCtrl.buffList,i);
  				BuffCtrl.SortBuffList();
  				BuffCtrl.RefreshBuffShowArea();
  				return;
  			end
  		end
  	end

  	function BuffCtrl.SortBuffList()
  		if next(BuffCtrl.buffList) ~= nil and #BuffCtrl.buffList > 1 then
  			table.sort(BuffCtrl.buffList,function (buff1,buff2)
  				if buff1.sorting_order ~= buff2.sorting_order then
  					return buff1.sorting_order < buff2.sorting_order;
  				elseif buff1.start_time ~= buff2.start_time then
  					return buff1.start_time > buff2.start_time;	
  				else
  					return buff1.sid < buff2.sid;
  				end
  			end)
  		end 
  	end

  	function BuffCtrl.RefreshBuffShowArea()
		if UIManager.GetInstance():FindUI("MainUI") ~= nil then
			UIManager.GetInstance():CallLuaMethod('MainUI.RefreshBuff');
			-- client.mainUI.RefreshBuffArea();
		end

		if UIManager.GetInstance():FindUI("UIBuffFloat") ~= nil then
			UIManager.GetInstance():CallLuaMethod('UIBuffFloat.RefreshBuff');
		end

  	end
  	return BuffCtrl;
end

client.buffCtrl = CreateBuffCtrl();
