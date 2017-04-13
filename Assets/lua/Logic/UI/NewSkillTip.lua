function NewSkillTipView(param)
	local NewSkillTip = {};
	local this = nil;
	local icon = nil;
	local skillInfo = nil;
	local effectGo = nil;
	local baodianEffectGo = nil;
	local target = nil;


	function NewSkillTip.Start()
		this = NewSkillTip.this;
		target = this:GO('Panel.UI');
		skillInfo = tb.SkillTable[param.skillId];
        -- this:GO('Panel.UI.Icon').sprite = skillInfo.icon;
		-- this:GO('Panel.UI.Icon').imageColor = Color.New(1,1,1,0);

		target:GO('Text').text = "新技能解锁:"..skillInfo.name
		
		effectGo = this:GO('Panel.Effect');
		baodianEffectGo = this:GO('Panel.baodianEffect');
		-- this:Delay(2, NewSkillTip.Play);
		MainUI.OpenSkillPanel(); -- 打开技能面板
		NewSkillTip.Play()
	end

	function NewSkillTip.Play()
		effectGo:PlayUIEffect(this.gameObject, "xinzengjinengtixingxiaoguo", 2, function (go)   	-- 新技能旋转特效 2秒播完
			local wrapper = go:GetComponent("UIWrapper");
			wrapper:GO("icon").sprite = skillInfo.icon;
		end, false);
		
		local hashtable = iTween.Hash("alpha",1,"time", 0.5, "oncomplete", "OnTweenComplete",   	-- “新技能解锁文字”渐现 0.5秒播完
			"oncompleteparams",target.gameObject);
		Util.FadeToEx(target.gameObject, hashtable, function () end);

		this:Delay(1, NewSkillTip.FadeOut);
	end

	function NewSkillTip.FadeOut()																	-- 1.5秒后 “新技能解锁文字”渐隐 0.5秒隐掉
		local hashtable = iTween.Hash("alpha",0,"time", 1, "oncomplete", "OnTweenComplete",
			"oncompleteparams",target.gameObject);
		Util.FadeToEx(target.gameObject, hashtable, function () end);
		this:Delay(0.5,function ()
			baodianEffectGo:PlayUIEffect(this.gameObject, "baodian", 0.33, function () end, false);	-- 文字渐隐之后 播放"曝点" 0.33秒播完
			-- this:Delay(0.33,function ()															-- "曝点" 和 "移动轨迹"一起播

			local index = NewSkillTip.GetSkillIndex(param.skillId);
			local skillBtn = this:GO('SkillPanel.btn'..index);

			effectGo:PlayUIEffect(this.gameObject, "jinengguiji", 1.3, function (go)				-- "曝点" 播完 播放"移动轨迹" 1.5秒播完
			    local wrapper = go:GetComponent("UIWrapper");
			    wrapper:GO("Image").sprite = skillInfo.icon;
			    this:Delay( 0.5,function ()	
			    	effectGo.transform:DOMove(skillBtn.transform.position,0.3,false):SetEase(DG.Tweening.Ease.Linear);
			    end)
			end, false);

			this:Delay( 0.8,function ()																-- "移动轨迹" 之后开始播放解锁特效
				MainUI.UnlockSkill(param.skillId);
			end)
			this:Delay( 1.3,function ()																-- "移动轨迹" 之后开始播放解锁特效
				destroy(this.gameObject)
			end)
			-- end)			
		end)
	end

	function NewSkillTip.GetSkillIndex(id)
        local career = DataCache.myInfo.career;
        local idList = const.ProfessionAbility[career];
        for i = 1,#idList do
            local skillID = idList[i];
            if skillID == id then
                return i;
            end
        end
        return 0;
    end

	return NewSkillTip;
end

function playNewSkillTip(skillId)
	local param = {skillId = skillId};
	PanelManager:CreateConstPanel("NewSkillTip", UIExtendType.NONE, function(go)
	end , param, true);
end