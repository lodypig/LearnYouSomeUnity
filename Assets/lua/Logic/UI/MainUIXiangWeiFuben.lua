function MainUIXiangWeiFubenView ()
	local MainUIXiangWeiFuben = {};
	local this = nil;

	local Panel = nil;
	local btnExit = nil;
	local btnExitPos = nil;
	function MainUIXiangWeiFuben.Start ()
		this = MainUIXiangWeiFuben.this;
		Panel = this:GO('_Panel');
		btnExit = this:GO('_Panel._btnExit');
		btnExitPos = btnExit.transform.localPosition
		const.InXiangWei = true;
		EventManager.onEvent(Event.ON_INTO_XIANGWEI);
		btnExit:BindButtonClick(MainUIXiangWeiFuben.onExit);
		EventManager.bind(this.gameObject,Event.ON_SKILL_HIDE, MainUIXiangWeiFuben.Hide);
		EventManager.bind(this.gameObject,Event.ON_SKILL_SHOW, MainUIXiangWeiFuben.Show);

		EventManager.bind(this.gameObject,Event.ON_MAINUI_HIDE, MainUIXiangWeiFuben.Hide);
        EventManager.bind(this.gameObject,Event.ON_MAINUI_SHOW, MainUIXiangWeiFuben.Show);
        if const.OpenMenuFlag then
        	btnExit.transform.localPosition = Vector3.New(btnExitPos.x + 300, btnExitPos.y, btnExitPos.z);
        end
	end

	function MainUIXiangWeiFuben.onExit(go)
		XiangWeiFuben.confirmExit()
	end
	function XiangWeiFuben.confirmExit()
		local str = "是否离开本场战斗？";
		ui.showMsgBox("", str,function() 
				XiangWeiFuben.leave()
				end)
	end

	function MainUIXiangWeiFuben.Hide()
        btnExit.transform:DOLocalMoveX(btnExitPos.x + 600, 0.5, false);
    end

    function MainUIXiangWeiFuben.Show()
    	if not const.OpenMenuFlag then
        	btnExit.transform:DOLocalMoveX(btnExitPos.x, 0.3, false);
        end
    end

	function MainUIXiangWeiFuben.onDestroy()
		const.InXiangWei = false;
		EventManager.onEvent(Event.ON_OUT_XIANGWEI);
		destroy(this.gameObject);
	end

	return MainUIXiangWeiFuben;
end
