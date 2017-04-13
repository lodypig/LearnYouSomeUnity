function UIBuffFloatView ()
	local UIBuffFloat = {};
	local this = nil;
	local closeArea = nil;
	local content = nil;
	local itemPrefab = nil;
	local container = nil;
	local panelRect = nil;
	local PANEL_MAX_HEIGHT = 500;
	local CONTENT_MAX_HEIGHT = 480;

	function UIBuffFloat.Start ()
		this = UIBuffFloat.this;
		closeArea = this:GO('Blank');
		container = this:GO('panel.container');
		content = this:GO('panel.container.Grid._Content');
		itemPrefab = this:GO('panel.container.Grid._Item');

		panelRect = this:GO('panel'):GetComponent("RectTransform");
		UIBuffFloat.ShowBuffContent();

		closeArea:BindButtonClick(UIBuffFloat.Close);
        EventManager.bind(this.gameObject, Event.ON_TIME_SECOND_CHANGE, UIBuffFloat.ShowBuffContent);

	end

	function UIBuffFloat.Close()
		destroy(this.gameObject);
	end

	function UIBuffFloat.ShowBuffContent()
		if next(client.buffCtrl.buffList) == nil then
			UIBuffFloat.Close();
			return;
		end

		local buffItem;
		local buffInfo;
		local curCount = content.transform.childCount;
		local newCount = #client.buffCtrl.buffList;

		local contentHeight = 0;
		for i=1,newCount do
			buffInfo = client.buffCtrl.buffList[i];
			if i <= curCount then 
				buffItem = content.transform:GetChild(i-1).gameObject;
				buffItem:SetActive(true);
			else
				buffItem = newObject(itemPrefab);
				buffItem.transform:SetParent(content:GetComponent("RectTransform"));
				buffItem.gameObject:SetActive(true);
				buffItem.transform.name = i;
				buffItem.transform.localScale = Vector3.one;
				buffItem.transform.localPosition = Vector3.zero;
			end

			local wrap = buffItem:GetComponent("UIWrapper")
			local line_transform = wrap:GO('line').transform;
			local itemHeight;
			wrap:GO('image').sprite = buffInfo.icon;
			wrap:GO('name').text = buffInfo.name;
			wrap:GO('time').text = UIBuffFloat.formatTime (buffInfo.start_time + buffInfo.useful_time);	
			wrap:GO('description').text = string.format( buffInfo.description, math.ceil(DataCache.myInfo.kill_value) );
			-- 15 为item间距，31为buff icon高度，10为item内部间距，1为分割线高度
			itemHeight = 31 + 10 + wrap:GO('description'):GetComponent("Text").preferredHeight + 10 +1;
			contentHeight = contentHeight + 15 +itemHeight;

			line_transform.localPosition = Vector3.New(line_transform.localPosition.x, -itemHeight, line_transform.localPosition.z);
		end
		for i=newCount+1,curCount do
			content.transform:GetChild(i-1).gameObject:SetActive(false);
		end


		-- local contentHeight = content.transform.sizeDelta.y;
		local scrollRect = container:GetComponent('ScrollRect');
		if contentHeight > CONTENT_MAX_HEIGHT then
			panelRect.sizeDelta = Vector2.New(400, PANEL_MAX_HEIGHT);
			scrollRect.movementType = UnityEngine.UI.ScrollRect.MovementType.Elastic;
		else
			panelRect.sizeDelta = Vector2.New(400, contentHeight + 20);
			scrollRect.movementType = UnityEngine.UI.ScrollRect.MovementType.Clamped;
		end

	end

    function UIBuffFloat.formatTime(t)    	
        local now = TimerManager.GetServerNowMillSecond();
        local deadLine_seconds;
        local text;
        local day;
        local hour;
        local minute;
        local second;

        if now > t then
        	return "永久";
        else

        	deadLine_seconds = (t - now)/1000;
        	if deadLine_seconds > 86400 then
        		day = math.floor(deadLine_seconds / 86400);
        		hour =math.ceil((deadLine_seconds - day * 86400)/3600);
        		text = day.."天"..hour.."小时"
        	elseif deadLine_seconds > 3600 then
        		hour = math.floor(deadLine_seconds / 3600);
        		minute = math.ceil((deadLine_seconds - hour * 3600)/60);
        		text = hour.."小时"..minute.."分";
    		elseif deadLine_seconds > 60 then
    			minute = math.floor(deadLine_seconds / 60);
        		second = math.ceil(deadLine_seconds - minute * 60);
        		text = minute.."分"..second.."秒";
        	else
        		second = math.ceil(deadLine_seconds);
        		text = second.."秒";
        	end
        	return text;
        end
    end


	function UIBuffFloat.RefreshBuff()
		-- 当有buff remove/add时延迟0.1秒检查，防止remove之后又add导致界面被关闭无法打开
		local timer = Timer.New(function ()
			UIBuffFloat.ShowBuffContent();
		end, 0.1, 1, false);
        timer:Start();
	end

	return UIBuffFloat;
end

function ui.ShowBuffFloat()
	PanelManager:CreateConstPanel('UIBuffFloat',UIExtendType.NONE, {});
end
