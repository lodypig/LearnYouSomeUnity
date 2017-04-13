function LevelUpView(param)
	local LevelUp = {};
	local this = nil;
	local level, time;

	function  LevelUp.Start()

		this = LevelUp.this;
		EventManager.bind(this.gameObject,Event.ON_TIME_SECOND_CHANGE, LevelUp.updateClose);
		level = param.level;
		time = param.time;
		LevelUp.showNum(level);
		--this:GO('shengjiBg.num').text = level;	
	end

	function LevelUp.updateClose()
		time = time - 1;
		if  time <= 0 then
			destroy(this.gameObject)
		end
	end

	function LevelUp.OnDestroy()
		
	end

	function LevelUp.showNum(level)
		if math.modf(level/10) == 0 then
			-- 十位数设置为透明
			this:GO('shengjiui.GameObject.Image (1)').gameObject:SetActive(false);
			this:GO('shengjiui.GameObject.Image').sprite = const.LEVEL_ICON[level % 10];
		else
			this:GO('shengjiui.GameObject.Image (1)').gameObject:SetActive(true);
			this:GO('shengjiui.GameObject.Image').sprite = const.LEVEL_ICON[level % 10];
			this:GO('shengjiui.GameObject.Image (1)').sprite = const.LEVEL_ICON[math.modf(level/10)];
		end
	end
	return LevelUp;
end

function showLevelUp(level, time) 
	local param = {level = level, time = time};
	PanelManager:CreateConstPanel("LevelUp", UIExtendType.NONE, param);
end