function SuitCtrl()
	local Suit = {};
	Suit.equipMap = nil; --记录身上穿的套装 格式为{[equipSid1] = true,...[equipSidN] = true}
 	Suit.initEquipMap = function ()
 		Suit.equipMap = {};
    	for i = 1, #Bag.wearList do
			local equip = Bag.wearList[i];
			if equip ~= nil then
				local equipSid = equip.sid;
				local equip_data = tb.EquipTable[equipSid];
				local suitId = equip_data.suitId;
				local recoveryTime = equip.recoveryTime;

				if recoveryTime == 0 and suitId ~= 0 and equip.quality == 4 then
					Suit.equipMap[equipSid] = true;
				end
			end
		end
    end

    Suit.updateEquipMap = function (oldEquip, newEquip)
    	if not Suit.equipMap then
    		return;
    	end

    	if oldEquip ~= nil and oldEquip.quality == 4 then
    		Suit.equipMap[oldEquip.sid] = nil;
	    end

    	if newEquip ~= nil then
	    	local newEquipRT = newEquip.recoveryTime;
	    	if newEquipRT == 0 and newEquip.quality == 4 then
	    		Suit.equipMap[newEquip.sid] = true;
	    	end
	    end	   
    end

    Suit.getEquipMap = function ()
    	if Suit.equipMap == nil then
    		Suit.initEquipMap();
    	end
    	return Suit.equipMap;                                                                                                
    end
    return Suit;
end
client.suit = SuitCtrl();