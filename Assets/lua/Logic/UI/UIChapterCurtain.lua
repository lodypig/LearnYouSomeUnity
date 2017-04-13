function UIChapterCurtainView(param)
	local UIChapterCurtain = {};
	local this = nil;

	local Bg = nil;
	local Title = nil;
	local Name = nil;
	local Desc = nil;
	local Panel = nil;

	local startTime;

	function UIChapterCurtain.Start()
		this = UIChapterCurtain.this;
		
		Bg = UIChapterCurtain.Bg;
		Title = UIChapterCurtain.Title;
		Desc = UIChapterCurtain.Desc;
		Name = UIChapterCurtain.Name;
		Panel = UIChapterCurtain.Panel;

		Bg.sprite = string.format("zhangjie_bg_%s", param.chapterId);
		Name.sprite = string.format("zhangjie_name_%s", param.chapterId);
		Title.text = string.format("第%s章", const.NumberTable[param.chapterId]);

		Desc.text = param.desc;
		--打字机效果
		--Desc.text = "";
		--local descText = Desc:GetComponent("Text");
		--descText:DOText(param.desc, 2.5, true, DG.Tweening.ScrambleMode.None, nil);

		local canvasGroup = Panel:GetComponent("CanvasGroup");
		canvasGroup.alpha = 0.2;
		canvasGroup:DOFade(1, 1.5);
		canvasGroup:DOFade(0, 1.5):SetDelay(2.5);

		startTime = TimerManager.GetUnityTime();
	end

	function UIChapterCurtain.Update( )
		local time = TimerManager.GetUnityTime() - startTime

		--删除界面
		if time > 4 then
			destroy(this.gameObject);
		end
	end


	return UIChapterCurtain;
end
