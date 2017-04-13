function ActivityFloatView(param)
	local ActivityFloat = {};
	local this = nil;
	local name = nil;
	local time = nil;
	local level = nil;
	local form = nil;
	local text = nil;
	local IconTab = nil;
	local IconBgTab = nil;

	function ActivityFloat.Start()
		this = ActivityFloat.this;		
		name = ActivityFloat.name;
		time = ActivityFloat.time;
		level = ActivityFloat.level;
		form = ActivityFloat.form;
		text = ActivityFloat.text;
		
		IconTab = ActivityFloat.icon;
		IconBgTab = ActivityFloat.iconBg;

		-- 初始化数据
		name.text = param.name;
		time.text = param.show_name;
		level.text = param.level;
		form.text = param.form;
		text.text = param.text;
		local awardText = param.awardicon;
		local awardIcon = Split(awardText, "，");
		for i = 1, #awardIcon do
			IconBgTab[i]:GetComponent("UIWrapper").sprite = awardIcon[i];
			IconTab[i].gameObject:SetActive(true);
		end
	end
	function ActivityFloat.OnDestroy()
		param.go.gameObject:SetActive(false);
	end
	return ActivityFloat;
end
