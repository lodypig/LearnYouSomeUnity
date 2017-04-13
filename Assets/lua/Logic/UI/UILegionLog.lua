function UILegionLogView()
	local UILegionLog = {};
	local this = nil;

	function UILegionLog.Start ()
		this = UILegionLog.this;

		UILegionLog.ShowLegionLog();
		UILegionLog.close:BindButtonClick(UILegionLog.Close);
	end
	
	function UILegionLog.ShowLegionLog()
		local itemPrefab = UILegionLog.itemPrefab.gameObject;

		local curCount = UILegionLog.content.transform.childCount;
		local newCount = #client.legion.DynamicList;
		local logItem;

		for i=1,#client.legion.DynamicList do
			local logInfo = client.legion.DynamicList[i];
			if i <= curCount then 
				logItem = UILegionLog.content.transform:GetChild(i-1).gameObject;
			else
				logItem = newObject(itemPrefab);
				logItem.transform:SetParent(UILegionLog.content:GetComponent("RectTransform"));
				logItem.gameObject:SetActive(true);
				logItem.transform.name = i;
				logItem.transform.localScale = Vector3.one;
				logItem.transform.localPosition = Vector3.zero;
			end

			local wrap = logItem:GetComponent("UIWrapper")
			if logInfo.type == 1 then 						--  只有日期
				wrap:GO('Time').text = string.format("<color=#ebd29d>%s</color>",logInfo.str1);
				wrap:GO('Text').text = "";
				wrap:GO('line').gameObject:SetActive(false);

			elseif logInfo.type == 2 then 					--  时分 + 事件string
				wrap:GO('Time').text = string.format("<color=#8ddd10>%s</color>",logInfo.str1);
				wrap:GO('Text').text = logInfo.str2;
				wrap:GO('line').gameObject:SetActive(false);

			else 											--  空行 、显示分割线
				wrap:GO('Time').text = "";
				wrap:GO('Text').text = "";
				wrap:GO('line').gameObject:SetActive(true);

			end
		end
	end

	function UILegionLog.Close()
		destroy(this.gameObject);
	end

	return UILegionLog
end

ui.ShowLegionLog  = function ()
	PanelManager:CreateConstPanel('UILegionLog',UIExtendType.NONE, nil);
end

