function RightUpConfirmView()
	local RightUpConfirm = {};
	local this = nil;

	local backImage = nil;
	local content = nil;
	local X = nil;
	local J = nil;

	local position; -- 获取的panel位置
	local panelObj;
	--logic
	local okFunc = nil
	local cancelFunc = nil

	--move
	local sequence = nil
	local flyfinalPos = nil

	function RightUpConfirm.Start()
		this = RightUpConfirm.this;
		backImage = this:GO('Panel._backImage');
		content = this:GO('Panel._content');
		X = this:GO('Panel._X');
		J = this:GO('Panel._J');

		--
		X:BindButtonClick(RightUpConfirm.Cancel);
		J:BindButtonClick(RightUpConfirm.OK);
		--动画参数
		flyfinalPos = content.transform.localPosition;
		this:GO('Panel').gameObject:SetActive(false);
		panelObj = this:GO('Panel');

        EventManager.bind(this.gameObject,Event.ON_MAINUI_HIDE, RightUpConfirm.moveRight);
        EventManager.bind(this.gameObject,Event.ON_MAINUI_SHOW, RightUpConfirm.moveLeft);
	end

	function RightUpConfirm.FirstUpdate(  )
		position = panelObj.transform.localPosition;
	end

	function RightUpConfirm.PrepareAniData()
		backImage.transform.localScale = Vector3.New(1, 0, 1)
		X.imageColor = Color.New(1,1,1,0)
		J.imageColor = Color.New(1,1,1,0)
		content.transform.localPosition = Vector3.New(flyfinalPos.x + 400, flyfinalPos.y, flyfinalPos.z)
	end

	function RightUpConfirm.moveRight()
		panelObj.transform:DOLocalMoveX(position.x + 250 ,0.5,  false):SetEase(DG.Tweening.Ease.Linear);
	end

	function RightUpConfirm.moveLeft()
		panelObj.transform:DOLocalMoveX(position.x ,0.3,  false):SetEase(DG.Tweening.Ease.Linear);
	end

	function RightUpConfirm.Show(str, func_ok, func_cancel)
		content.text = str
		okFunc = func_ok
		cancelFunc = func_cancel

		--初始化动画数据
		RightUpConfirm.PrepareAniData()
		this:GO('Panel').gameObject:SetActive(true)

		if sequence ~= nil then
			sequence:Restart(true);
		else
			--构建动画过程
			sequence = DG.Tweening.DOTween.Sequence()
			--1) 背景展开
			sequence:Append(backImage.transform:DOScale(Vector3.New(1, 1, 1), 0.4))
			--sequence:AppendInterval(0.4)
			--2) 按钮旋转与alpha + 文字飞入
			sequence:Append(X:GetComponent("Image"):DOFade(1, 0.4))
			sequence:Join(X.transform:DOLocalRotate(Vector3.New(0,0, 360), 0.4, DG.Tweening.RotateMode.LocalAxisAdd))
			sequence:Join(J:GetComponent("Image"):DOFade(1, 0.4))
			sequence:Join(J.transform:DOLocalRotate(Vector3.New(0,0, 360), 0.4, DG.Tweening.RotateMode.LocalAxisAdd))
			sequence:Join(content.transform:DOLocalMoveX(flyfinalPos.x, 0.4, false))
			sequence:SetAutoKill(false);
		end

		MainUI.showGrowth(false)
	end

	function RightUpConfirm.OK()
		if okFunc ~= nil then
			okFunc()
		end
		RightUpConfirm.Hide()
	end

	function RightUpConfirm.Cancel()
		if cancelFunc ~= nil then
			cancelFunc()
		end
		RightUpConfirm.Hide()
	end

	function RightUpConfirm.Hide()
		-- if sequence ~= nil then
		-- 	sequence:PlayBackwards()
		-- end
		this:GO('Panel').gameObject:SetActive(false)
		MainUI.showGrowth(true)	
	end

	client.rightUpConfirm = RightUpConfirm;
	return RightUpConfirm;
end



function CreateRightUpConfirm()
	PanelManager:CreateConstPanel('RightUpConfirm',UIExtendType.NONE,nil);
end