function SkillTip_TalentView(param)
	local SkillTip_Talent = {};
	local this = nil;
	local skillInfo = nil;
	local effectGo = nil;
	local baodianEffectGo = nil;
	local target = nil;


	function SkillTip_Talent.Start()
		this = SkillTip_Talent.this;
		target = this:GO('Panel.UI');

		if param.type == "Talent" then
			skillInfo = tb.TalentTable[param.skillId];
			target:GO('Text').text = "新技能解锁:"..skillInfo.name
		elseif param.type == "ZhuanJing" then 
			skillInfo = tb.ZhuanjinTable[param.skillId];
			target:GO('Text').text = "新专精解锁:"..skillInfo.name
		end

		effectGo = this:GO('Panel.Effect');
		baodianEffectGo = this:GO('Panel.baodianEffect');
		SkillTip_Talent.Play()
	end

	function SkillTip_Talent.Play()
		effectGo:PlayUIEffect(this.gameObject, "xinzengjineng1", 4, function (go)   	-- 新技能旋转特效 2秒播完
			local wrapper = go:GetComponent("UIWrapper");
			wrapper:GO("icon").sprite = skillInfo.icon;
		end, false);
		
		local hashtable = iTween.Hash("alpha",1,"time", 0.5, "oncomplete", "OnTweenComplete",   	-- “新技能解锁文字”渐现 0.5秒播完
			"oncompleteparams",target.gameObject);
		Util.FadeToEx(target.gameObject, hashtable, function () end);

		this:Delay(3, SkillTip_Talent.FadeOut);
	end

	function SkillTip_Talent.FadeOut()																	-- 1.5秒后 “新技能解锁文字”渐隐 0.5秒隐掉
		local hashtable = iTween.Hash("alpha",0,"time", 1, "oncomplete", "OnTweenComplete",
			"oncompleteparams",target.gameObject);
		Util.FadeToEx(target.gameObject, hashtable, function () end);
		this:Delay(0.5,function ()
		-- 	baodianEffectGo:PlayUIEffect(this.gameObject, "baodian", 0.33, function () end, false);	-- 文字渐隐之后 播放"曝点" 0.33秒播完

			-- this:Delay( 0.33,function ()																-- "移动轨迹" 之后开始播放解锁特效
				destroy(this.gameObject)
			-- end)
		end)
	end
	return SkillTip_Talent;
end

function playSkillTip_Talent(skillId, type)
	local param = {skillId = skillId, type = type};
	PanelManager:CreateConstPanel("SkillTip_Talent", UIExtendType.NONE, function(go)
	end , param, true);
end