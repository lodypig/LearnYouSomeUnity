function UpdateFightValueView(param)
	local UpdateFightValue = {};
	local this = nil;

	local isPlay = false;
	local lastTime = 0;		--当前计时
	local duration = 0; --数字滚动时间
	local fadeOutTime = 1.8 --淡出时间

	local args = nil;
	local sequence = nil;

	local textZhanLi = nil;
	local textValue = nil;
	local scrollNumRoot = nil;
	local scrollNumPrefab = nil;
	local delta = nil; --增量
	local effect = nil;
	local arrow = nil;

	function UpdateFightValue.Start()
		this = UpdateFightValue.this;

		effect = this:LoadUIEffect(this.gameObject, "zhandoulitisheng", true, true);
		effect.transform:SetParent(this:GO('Panel.Effect').transform)
		effect.transform.localScale = Vector3.one;
		effect.transform.localPosition = Vector3.zero;

		arrow = this:LoadUIEffect(this.gameObject, "lvsejiantou", true, true);
		arrow.transform:SetParent(this:GO('Panel.Value.Arrow').transform)
		arrow.transform.localScale = Vector3.one;
		arrow.transform.localPosition = Vector3.zero;

		--scrollNumRoot = this:GO("Panel.ScrollNum");
		--scrollNumPrefab = this:GO("Panel.ScrollNum.Num");
		--scrollNumPrefab.gameObject:SetActive(false)
		textValue = this:GO('Panel.Value');
		textZhanLi = this:GO('Panel.Text');
		delta = this:GO('Panel.Value.Delta');
		delta:Hide();
		
		UpdateFightValue.Play(param);
	end

	function UpdateFightValue.Update( )
		if isPlay then
			local time = TimerManager.GetUnityTime() - lastTime
			--数字跳动
			local ratio = math.min(time / duration, 1);
			textValue.text = "战"..args.lastValue + math.round(ratio * (args.fightValue - args.lastValue));

			--战力淡出
			local startTime = duration + 0.4;
			local endTime = startTime + fadeOutTime;

			if time > duration and time < startTime then
				delta:Show();
				delta.text = args.deltaNum;
			end

			if time > startTime and time < endTime then
				textValue.textColor = Color.New(1,1,1, (endTime - time) / fadeOutTime);
				textZhanLi.textColor = Color.New(1,1,1, (endTime - time) / fadeOutTime);
				delta.textColor = Color.New(1,1,1, (endTime - time) / fadeOutTime);
			end

			--时间结束隐藏战力
			if time > endTime then
				textValue.textColor = Color.New(1,1,1,0);
				textZhanLi.textColor = Color.New(1,1,1,0);
				delta.textColor = Color.New(1,1,1,0);
			end

			--删除界面
			if time > endTime + 1 then
				ui.panelFightValue = nil;
				isPlay = false;
				const.fightValueDelta = 0;
				destroy(this.gameObject);
			end
		end
	end

	function UpdateFightValue.Play(param)
		args = param;

		--战力显示
		textValue.text =  "战"..args.lastValue;
		textValue.textColor = Color.New(1,1,1,1);
		textZhanLi.textColor = Color.New(1,1,1,1);
		delta.textColor = Color.New(1,1,1,1);
		delta:Hide();
		
		--特效播放
		effect:SetActive(true);
		arrow:SetActive(true);

		--根据战力增量位置设置播放时间
		local num = string.len(args.fightValue - args.lastValue);
		if num > 2 then
			duration = 0.9;
		elseif num > 1 then
			duration = 0.6;
		else 
			duration = 0.3;
		end
		lastTime = TimerManager.GetUnityTime();
		isPlay = true;
	end

	function UpdateFightValue.Stop()
		MainUI.UpdateFightNumber();
		effect:SetActive(false);
		arrow:SetActive(false);
	end


	function UpdateFightValue.OnDestroy(  )
		
	end

	return UpdateFightValue;
end

function playFightValueEffect(lastValue, fightValue)
	const.fightValueDelta = const.fightValueDelta + (fightValue - lastValue);

	local param = {};
	param.lastValue = lastValue;
	param.fightValue = fightValue;
	param.deltaNum = const.fightValueDelta;

	if ui.panelFightValue ~= nil then
        local lua = ui.panelFightValue:GetComponent("LuaBehaviour");
		lua:CallLuaMethod("Stop");
		lua:CallLuaMethod("Play",param);
	else
		PanelManager:CreateConstPanel("UpdateFightValue", UIExtendType.NONE, function (go)
            if ui.panelFightValue ~= nil then
                destroy(ui.panelFightValue)
            end
            ui.panelFightValue = go;
        end, param, true);
	end
end