--注意：bagctrl中维护了需要提示的所有装备的列表，这个列表用于保证同部位的提示唯一
function UpEquipmentView (param) 
	local UpEquipment = {};
	local this = nil;

	local closeBtn = nil;
	local Description = nil;
	local ResetConfirmBtn = nil;
	local equip = nil;
	local equipIconCtrol = nil;

    local buwei;
    local equipment;
    local time;

    local nextEquipList = {};

	function UpEquipment.Start ()
		this = UpEquipment.this;
		Description = this:GO('Panel._UPEquipment._Description');
		ResetConfirmBtn = this:GO('Panel._UPEquipment._ResetConfirmBtn');

        local prefab = this:LoadAsset("BagItem");
        local slot = newObject(prefab);
        slot.transform:SetParent(this:GO('Panel._UPEquipment._slot').transform);
        slot.transform.localScale = Vector3.one;
        slot.transform.localPosition = Vector3.zero;
        equipIconCtrol = CreateSlot(slot);

        ResetConfirmBtn:BindButtonClick(UpEquipment.putOn);

        EventManager.bind(this.gameObject,Event.ON_TIME_SECOND_CHANGE, UpEquipment.UpdateOneSecond);
        nextEquipList = param.equipList;
        UpEquipment.ShowNextEquip();
        --UpEquipment.Reset(param.equip);
        --UpEquipment.Show(param)
	end

    function UpEquipment.closeSelf()
        ui.upEquipment = nil;
        destroy(this.gameObject);
    end

    function UpEquipment.clearEquip(equip)
        if equip == nil or equipment == nil then
            return;
        end

        if equip.id == equipment.id then
            UpEquipment.ShowNextEquip();
        else
            UpEquipment.CheckNextEquip(equip);
        end
    end

    function UpEquipment.UpdateOneSecond()
        if equipment == nil then
            return;
        end

        time = time - 1
        if time <= 0 then
            UpEquipment.putOn();
            return;
        end

        UpEquipment.setConfirmBtnText();
    end

    function UpEquipment.setConfirmBtnText( )
        ResetConfirmBtn:GO('Text').text = string.format("装备(%s)", time);
    end

    --todo 处理点击装备的事件
    function UpEquipment.putOn()
        Bag.wear(equipment);
        UpEquipment.ShowNextEquip();
    end

    --显示装备栏
    function UpEquipment.showInfo()
        Description.text = client.tools.formatColor(equipment.name, const.qualityColor[equipment.quality + 1]);
        equipIconCtrol.reset();
        equipIconCtrol.setEquip(equipment);
    end

    --显示装备发生变化
    function UpEquipment.Reset(equip)
        equipment = equip;
        UpEquipment.showInfo();
        time = 5;
        UpEquipment.setConfirmBtnText();
    end

    --显示下一件提示装备
    function UpEquipment.ShowNextEquip()
        if #nextEquipList > 0 then
            UpEquipment.Reset(nextEquipList[#nextEquipList]);
            nextEquipList[#nextEquipList] = nil;
        else
            UpEquipment.closeSelf();
        end
    end

    --检测等待提示的装备是否应该被移除
    function UpEquipment.CheckNextEquip(equip)
        local tem = {}
        for i = 1, #nextEquipList do
            if nextEquipList[i].id ~= equip.id then
                tem[#tem + 1] = nextEquipList[i];
            end
        end
        nextEquipList = tem;
    end

    --现在不会出现同部位的顶替 如果之后有可能 这部分需要注意
    function UpEquipment.Show(param)
        local equipList = param.equipList;
        nextEquipList[#nextEquipList + 1] = equipment;
        for i = 1, #equipList do
            nextEquipList[#nextEquipList + 1] = equipList[i]; 
        end   

        UpEquipment.ShowNextEquip();
    end

	return UpEquipment;
end

function ShowUpEquipment(equipList)
    local param = {};
    param.equipList = equipList;
    if ui.upEquipment ~= nil then
        local lua = ui.upEquipment:GetComponent("LuaBehaviour");
        lua:CallLuaMethod("Show", param);
    else
        PanelManager:CreateConstPanel('UpEquipment',UIExtendType.NONE, function (go)
            if ui.upEquipment ~= nil then
                destroy(ui.upEquipment)
            end
            ui.upEquipment = go;
        end,  param, true);
    end
end
                
