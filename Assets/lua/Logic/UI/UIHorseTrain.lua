function CreateHorseTrain (ndTrain, onUpdate, this, wrapper)
	local controller = {};

	local spRide = ndTrain:GO('_spRide');

	local atfTrainActive = ndTrain:GO('ndTop._atfTrainActive');
	local tfTrainActive = ndTrain:GO('ndTop._tfTrainActive');
	local atfTrainRide = ndTrain:GO('ndTop._atfTrainRide');
	local tfTrainRide = ndTrain:GO('.ndTop._tfTrainRide');
	local atfTrainMax = ndTrain:GO('ndTop._atfTrainMax');
	local tfTrainMax = ndTrain:GO('ndTop._tfTrainMax');
	local tfAddFP = ndTrain:GO('ndAttrContent._tfAddFP');
	local spRide = ndTrain:GO('_spRide');
	local btnRide = ndTrain:GO('_btnRide');
	local ndAttrGrid = ndTrain:GO('ndAttrContent.ndAttrGrid');


	local ndCost = ndTrain:GO('ndCost');

	local ndAttr = {
		ndAttrGrid:GO('_ndAttr1'),
		ndAttrGrid:GO('_ndAttr2'),
		ndAttrGrid:GO('_ndAttr3'),
		ndAttrGrid:GO('_ndAttr4'),
		ndAttrGrid:GO('_ndAttr5'),
	};


	local tfAddAttrType = {};
	local tfAddAttrValue = {};
	local tfAddAttrNext = {};
	local horse;
	local horseTable;
	local spStar = {};	

	for i = 1, #ndAttr do
		tfAddAttrType[i] = ndAttr[i]:GO('_tfAddAttrType');
		tfAddAttrValue[i] = ndAttr[i]:GO('_tfAddAttrValue');
		tfAddAttrNext[i] = ndAttr[i]:GO('_tfAddAttrNext');
		spStar[i] = {};
		local ndStarGrid = ndAttr[i]:GO('_ndStarGrid');
		for j = 1, client.horse.MAX_STAR do			
			spStar[i][j] = ndStarGrid:GO("star"..j);
		end
	end

	local spCost = ndTrain:GO('ndCost.costinfo');
	local spCostPos = spCost.transform.localPosition;
	local tfCostMaterial = ndTrain:GO('ndCost.costinfo.material._tfCostMaterial');
	local spCostMaterial = ndTrain:GO('ndCost.costinfo.material');
	local btnTrain = ndTrain:GO('ndCost._btnTrain');
	local spFlag = ndTrain:GO('ndCost._btnTrain._spFlag');
	local CostDiamond = ndTrain:GO('ndCost.autoSupplyMaterial');
	local tfCostDiamond = ndTrain:GO('ndCost.autoSupplyMaterial._tfCostDiamond');
	local spKuang = ndTrain:GO('ndCost.autoSupplyMaterial._spKuang');
	local spGou = ndTrain:GO('ndCost.autoSupplyMaterial._spKuang._spGou');

	local function updateTop()
		spRide.gameObject:SetActive(client.horse.ride_horse == horseTable.sid);

		atfTrainRide.text = horseTable.ride_enhance;
		atfTrainMax.text = horseTable.max_enhance;
		
		local rideColor = (horse.enhance_lv >= horseTable.ride_enhance) and const.colorP.white or const.colorP.gray;
		local maxColor = (horse.enhance_lv >= horseTable.max_enhance) and const.colorP.white or const.colorP.gray;

		atfTrainRide.textColor = rideColor;		
		tfTrainRide.textColor = rideColor;
		atfTrainMax.textColor = maxColor;
		tfTrainMax.textColor = maxColor;
	end

	local function setMaxAttr(horseTable, horse, index)
		for i = 1, client.horse.MAX_STAR do
			spStar[index][i].gameObject:SetActive(false);
		end

		local addValue = tb.horseAddAttrTable[horseTable.attr[index]];
		tfAddAttrType[index].text = const.ATTR_NAME[horseTable.attr[index]];
		tfAddAttrValue[index].text = ((horse.enhance_lv - index) * client.horse.MAX_STAR) * addValue;		
		tfAddAttrNext[index].text = '';
		tfAddAttrType[index].textColor = const.colorP.white;
		tfAddAttrValue[index].textColor = const.colorP.white;
	end

	local function setAttr(horseTable, horse, index)
		for i = 1, horse.star[index] do
			spStar[index][i].sprite = "tb_xingxing_zuoqi_2";
			spStar[index][i].gameObject:SetActive(true);
		end		
		for i = horse.star[index] + 1, client.horse.MAX_STAR do
			spStar[index][i].sprite = "tb_xingxing_zuoqi_1";
			spStar[index][i].gameObject:SetActive(true);
		end
		local addValue = tb.horseAddAttrTable[horseTable.attr[index]];
		
		tfAddAttrType[index].text = const.ATTR_NAME[horseTable.attr[index]];
		tfAddAttrValue[index].text = ((horse.enhance_lv - index) * client.horse.MAX_STAR) * addValue;
		if horse.star[index] > 0 then
			tfAddAttrNext[index].text = '+'..horse.star[index] * addValue;
		else
			tfAddAttrNext[index].text = '';
		end

		tfAddAttrType[index].textColor = const.colorP.white;
		tfAddAttrValue[index].textColor = const.colorP.white;
	end

	local function SetGrayAttr(horseTable, horse, index)
		for i = 1, client.horse.MAX_STAR do
			spStar[index][i].sprite = "tb_xingxing_zuoqi_1";
			spStar[index][i].gameObject:SetActive(true);
		end

		tfAddAttrType[index].text = const.ATTR_NAME[horseTable.attr[index]];
		tfAddAttrValue[index].text = index .."阶开启";
		tfAddAttrNext[index].text = '';

		tfAddAttrType[index].textColor = const.colorP.gray;
		tfAddAttrValue[index].textColor = const.colorP.gray;
	end

	local function updateAttr()
		tfAddFP.text = "+"..client.horse.calcFP(horseTable, horse);
		for i = #horseTable.attr + 1, 5 do
			ndAttr[i].gameObject:SetActive(false);
		end

		for i = 1, #horseTable.attr do
			ndAttr[i].gameObject:SetActive(true);
			if horse.enhance_lv >= horseTable.max_enhance then
				setMaxAttr(horseTable, horse, i);
			elseif horse.enhance_lv >= i then
				setAttr(horseTable, horse, i);
			else
				SetGrayAttr(horseTable, horse, i);
			end
		end
	end

	local function updateAuto(horseTable, horse)		
		spGou.gameObject:SetActive(client.horse.ui_auto_train);
		if client.horse.ui_auto_train then
			local trainTable = tb.horseTrainTable[horse.enhance_lv];			
			local count = Bag.GetItemCountBysid(trainTable.train_cost_material);
			local cost = trainTable.train_cost_count;
			tfCostDiamond.gameObject:SetActive(true);
			tfCostDiamond.text = (cost - count) * trainTable.train_material_diamond;
		else
			tfCostDiamond.gameObject:SetActive(false);
		end
	end

	spKuang:BindButtonClick(function ()
		client.horse.ui_auto_train = not client.horse.ui_auto_train;
		spGou.gameObject:SetActive(client.horse.ui_auto_train);
		updateAuto(horseTable, horse);
	end)

	local function updateCost()
		if horse.enhance_lv >= horseTable.max_enhance then
			ndCost.gameObject:SetActive(false);
			return;
		end

		ndCost.gameObject:SetActive(true);
		local trainTable = tb.horseTrainTable[horse.enhance_lv];
		local count = Bag.GetItemCountBysid(trainTable.train_cost_material);
		-- print("背包中有的："..count);
		-- print("实际消耗的："..trainTable.train_cost_count);
		if count < trainTable.train_cost_count then
			spCost.transform.localPosition = spCostPos;
			CostDiamond.gameObject:SetActive(true);
		else
			spCost.transform.localPosition = Vector3.New(spCostPos.x + 260, spCostPos.y, spCostPos.z);
			CostDiamond.gameObject:SetActive(false);
		end
		tfCostMaterial.text = client.tools.formatColor(count, const.color.red, count, trainTable.train_cost_count).. "/" .. trainTable.train_cost_count;
		updateAuto(horseTable, horse);
	end

	
	local function onTrainClick()
		-- if client.horse.isMaxStar(horseTable.sid) then
		local trainTable = tb.horseTrainTable[horse.enhance_lv];			
		local count = Bag.GetItemCountBysid(trainTable.train_cost_material);
		local cost = trainTable.train_cost_count;
		local cb = function (success, addIndex, star)
				if success == 1 then
					local image = "dk_zhongyaoxinxiqu_2";
					local color = Color.New(255/255, 255/255, 143/255);
					ui.showMsg("培养成功", image, color);
					horse = client.horse.getHorse(horseTable.sid);
					spStar[addIndex][star]:PlayUIEffect(this.gameObject, "zuoqipeiyang", 1);
					this:Delay(0.5, updateAttr);
				else
					ui.showMsg("培养失败");
				end	
				if client.horse.isMaxStar(horseTable.sid) then
					this:Delay(1, function ()
						EventManager.onEvent(Event.ON_HORSE_UNLOCK_OR_CANUPGRADE);
						onUpdate();
					end );
				else
					this:Delay(1, onUpdate);
				end					
			end;

		if count >= cost then
			client.horse.train(cb, horse.sid, cost);
		else
			if client.horse.ui_auto_train then
				local diamond = (cost - count) * trainTable.train_material_diamond;			
				if DataCache.role_diamond < diamond then
					ui.showCharge();
					return;
				else
					client.horse.train(cb, horse.sid, count);
				end
			else				
				ui.showMsg("饲料不足");
			end
		end
	end


	btnTrain:BindButtonClick(onTrainClick)
	function controller.Show(_horseTable, _horse)
		horseTable = _horseTable;
		horse = _horse;
		ndTrain.gameObject:SetActive(true);		
		updateTop();
		updateAttr();
		updateCost();
		initRide(spRide, btnRide, horseTable.sid, horse.enhance_lv >= horseTable.ride_enhance, onUpdate);
		spCostMaterial:UnbindAllButtonClick();
		spCostMaterial:BindButtonClick(function () 
			local param = {bDisplay = true, index = i, sid = tb.horseTrainTable[horse.enhance_lv].train_cost_material};
			PanelManager:CreateConstPanel('ItemFloat',UIExtendType.BLACKCANCELMASK,param);
		end);
	end

	function controller.Hide()
		ndTrain.gameObject:SetActive(false);
	end

	-- function controller.updateFlag()
	-- 	local flag = client.horse.checkCouldTrain(horse);
	-- 	spFlag.gameObject:SetActive(flag);
	-- 	return flag;
	-- end

	function controller.onItemChange()
		updateCost();
		-- controller.updateFlag();
	end

	function controller.updateRolePos(node, last, now)
		if last == now then
			node.transform:DOLocalMove(Vector3.New(-75, 0, 0), 1, false);
		else
			node.transform:DOLocalMove(Vector3.New(-75, 0, 0), 0, false);
		end
	end

	return controller;
end


function initRide(spRide, btnRide, horseSid, couldRide, update)
	spRide.gameObject:SetActive(horseSid == client.horse.ride_horse);
	btnRide.gameObject:SetActive(horseSid ~= client.horse.ride_horse and couldRide);
	
	btnRide:UnbindAllButtonClick();
	btnRide:BindButtonClick(function () 
		client.horse.active(function () 
			--加载准备好新的坐骑模型
			local player = DataCache.me;
			if player ~= nil then
				local ac = player:GetComponent('AvatarController');
				if ac ~= nil and ac.HorseID ~= horseSid then
					local horseInfo = client.horse.horseMap[horseSid]
					local bShowMaxEffect = (horseInfo ~= nil) and (client.horse.isMaxEnhance(horseInfo))
		            ac:LuaLoadHorse(horseSid, bShowMaxEffect);
		        end
		    end
			btnRide.gameObject:SetActive(false);
			spRide.gameObject:SetActive(true);
			update();
		end, horseSid);
	end);
end