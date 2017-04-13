


function CreateHorseActive (ndActive, update)
	local controller = {};
	local horseTable = nil;
	
	local tfAcitveType = ndActive:GO('_tfAcitveType');
	local tfActiveValue = ndActive:GO('_tfActiveValue');
	-- local spFlag = ndActive:GO('_btnActive._spFlag');

	local function onActiveClick()
		if client.horse.checkUnlockFunc[horseTable.active_type](horseTable) then
			if client.horse.getHorse(horseTable.sid) then
				ui.showMsg("坐骑已解锁");
			else
				client.horse.unlock(function () 
					ui.showMsg("恭喜获得新坐骑"..horseTable.show_name.."");
					update();
				end, horseTable.sid);
			end
		else
			ui.showMsg("未达成解锁条件");
		end
	end

	ndActive:GO('_btnActive'):BindButtonClick(onActiveClick);
	

	local activeFunc = {
		function (horseTable) 
			tfAcitveType.text = "无";
			tfActiveValue.gameObject:SetActive(false);
		end,
		function (horseTable) 
			tfAcitveType.text = "连续登录"..horseTable.active_value.."天";
			tfActiveValue.gameObject:SetActive(true);
			tfActiveValue.text = "0/" ..horseTable.active_value;
		end,
		function (horseTable) 
			tfAcitveType.text = "累计登录"..horseTable.active_value.."天";
			tfActiveValue.gameObject:SetActive(true);
			tfActiveValue.text = "0/" ..horseTable.active_value;
		end,
		function (horseTable) 
			tfAcitveType.text = "VIP等级达到"..horseTable.active_value;
			tfActiveValue.gameObject:SetActive(true);
			tfActiveValue.text = "0/" ..horseTable.active_value;
		end,
		function (horseTable) 
			tfAcitveType.text = "累计获得"..horseTable.active_value.."只可骑乘坐骑";
			tfActiveValue.gameObject:SetActive(true);
			tfActiveValue.text = "0/" ..horseTable.active_value;
		end,
		function (horseTable) 
			tfAcitveType.text = "人物等级"..horseTable.active_value.."级";
			tfActiveValue.gameObject:SetActive(true);
			tfActiveValue.text = DataCache.myInfo.level .."/"..horseTable.active_value;
		end
	}

	function controller.Show(_horseTable)
		horseTable = _horseTable;
		ndActive.gameObject:SetActive(true);
		activeFunc[horseTable.active_type](horseTable);
	end

	function controller.updateRolePos(node, last, now)
		node.transform:DOLocalMove(Vector3.New(-75, 0, 0), 0, false);
	end
	-- function controller.updateFlag()
	-- 	local flag = client.horse.checkUnlockFunc[horseTable.active_type](horseTable);
	-- 	spFlag.gameObject:SetActive(flag);
	-- 	return flag;
	-- end

	-- function controller.onUnlockHorseChange()
	-- 	controller.updateFlag();
	-- end
	
	function controller.Hide()
		ndActive.gameObject:SetActive(false);
	end

	return controller;
end
