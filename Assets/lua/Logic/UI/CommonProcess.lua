ProcessType = {
	None = 0,
	TransmitProcess = 1,
    CBTProcess = 2,
}

function CommonProcessView(param)
	local Type = ProcessType.None;
	local CommonProcess = {};
	local this = nil;

	local Name = nil;
	local Process = nil;
	local foreground = nil;
	local background = nil;

	local SetMode = nil;
	local UpdateProgress = nil;
	local UpdateProcessText = nil;
	local BreakProcess = nil;
	local BreakProcessRed = nil;
	--内部数据
	local bProcessOn = false;
	local fNeedTime  = 0;
	local fCostTime  = 0;
	local fProgress  = 0;
	local lastTime = 0;
	local ProcessPicture = {"dk_jindu_1", "dk_jindu_2"};
	local ProcessColor = {Color.New(1, 1, 1), Color.New(255 / 255, 64 / 255, 64 / 255)}
	local callBack = nil;
	local effect = nil;

	function CommonProcess.Start()
		this = CommonProcess.this;
		Name = CommonProcess.Name;
		background = CommonProcess.background;
		Process = CommonProcess.Process;
		foreground = CommonProcess.foreground;
		this.gameObject:SetActive(false);
		effect = this:LoadUIEffect(this.gameObject, "caiji", true, true);
		effect.transform:SetParent(foreground.transform)
		effect.transform.localScale = Vector3.one;
		effect.transform.localPosition = Vector3.zero;
		CommonProcess.setEffectPos(0);
	end


	function CommonProcess.setEffectPos(value)
		foreground:GetComponent("Image"):DOFade(1, 0);
		background:GetComponent("Image"):DOFade(1, 0);
		effect:SetActive(true);
		local rt = effect:GetComponent("RectTransform");
		local min = -149;
		local max = 151;
		rt.anchoredPosition = Vector3.New(min + (max - min) * value, 0, 0);
		if value == 1 then
			Name:DOFade(1, 0, 1);
			Process:DOFade(1, 0, 1);
			foreground:GetComponent("Image"):DOFade(0, 1);
			background:GetComponent("Image"):DOFade(0, 1);
		end
	end

	function CommonProcess.StartProcess(type, needTime, CommonText , func)
		Type = type
		this.gameObject:SetActive(true);
		--设置所需的时间并重置已经经过的时间
		fNeedTime = needTime;
		fCostTime = 0;
		lastTime = TimerManager.GetUnityTime();
		--注册完成后的回调
		callBack = func;
		--设置计时状态
		bProcessOn = true;
        --设置进度条的颜色和字体颜色
        SetMode(true);
        --设置采集时显示的文本
        Name.text = CommonText;
        Process.text = "0%";
        Name:DOFade(0, 1, 0);
		Process:DOFade(0, 1, 0);
        UpdateProgress(0);
	end

	SetMode = function(bGoing)    
        if bGoing == true then
            --进度条使用的图片
            foreground.sprite = ProcessPicture[1];        
            --两段文本的颜色
            Name.textColor = ProcessColor[1];
            Process.textColor = ProcessColor[1];
        else       
            foreground.sprite = ProcessPicture[2];
            --两段文本的颜色
            Name.textColor = ProcessColor[2];
            Process.textColor = ProcessColor[2];
        end
    end

    UpdateProgress = function(progress)
    	foreground.fillAmount = progress;
    	CommonProcess.setEffectPos(progress);
	end

    UpdateProcessText = function(progress)
    	local precent = math.floor(progress * 100);
    	if precent > 100 then
    		precent = 100;
    	end
    	if precent < 0 then
    		precent = 0;
    	end
    	local str = precent.."%";
    	Process.text = str;
	end

	--因为移动或攻击打断读条
	--调用该接口会出现红色显示
	BreakProcessRed = function()
		if Type == ProcessType.TransmitProcess then
			--打断传送 则清空自动上马标志
			client.horse.ClearAutoRideFlag()
		end
		SetMode(false);
		fCostTime = 0;
		lastTime = TimerManager.GetUnityTime();

		Process.text = "中断";
		bProcessOn = false;
		callBack = nil;
		Type = ProcessType.None
	end

	--调用该接口不会出现红色显示
	BreakProcess = function()
		fCostTime = 0;
		lastTime = TimerManager.GetUnityTime();
		bProcessOn = false;
		callBack = nil;
		Type = ProcessType.None
		local player = AvatarCache.me;
		uFacadeUtility.StopAllEffects(player.id, "dutiao");
	end

	function CommonProcess.BreakProcess()
		-- print("中断读条");
		BreakProcessRed()
	end
	function CommonProcess.CancelProcess()
		-- print("取消读条");
		BreakProcess()
	end

	function CommonProcess.Update()
		if bProcessOn == true then
			fCostTime = TimerManager.GetUnityTime() - lastTime;
			fProgress = fCostTime / fNeedTime;
			if fProgress >= 1 then
				fProgress = 1
			end
			UpdateProgress(fProgress);
			UpdateProcessText(fProgress);

			--这时读条已经完成，执行回调
			if fProgress == 1 then
				bProcessOn = false;
				fCostTime = 0;
				lastTime = TimerManager.GetUnityTime();
				if callBack ~= nil then
					callBack()
				end
			end
		--如果处于结束或中断状态，600毫秒后隐藏
		else
			if fCostTime < 0.6 then
				fCostTime = TimerManager.GetUnityTime() - lastTime;
			elseif this.gameObject.activeSelf then
				this.gameObject:SetActive(false);
			end
		end
	end

	function CommonProcess.isProcess()
		return bProcessOn;
	end

	function CommonProcess.GetProcessType()
		return Type
	end

	--从闲置状态退出
	function CommonProcess.BreakIdle()
        if Type == ProcessType.CBTProcess then
            BreakProcessRed();
        end
	end

	client.commonProcess = CommonProcess;
	return CommonProcess;
end

function CreateCommonProcess()
    PanelManager:CreatePanel('CommonProcess', WindowLayer.UNDER_PANEL);
end

function MainPlayerBreakIdle()
	if client.commonProcess then
		client.commonProcess.BreakIdle()
	end
end
