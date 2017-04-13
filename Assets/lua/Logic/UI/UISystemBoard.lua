function UISystemBoardView ()
	local UISystemBoard = {};
	local this = nil;
	
	local SystemBoardBack = nil;
	local SystemBoardBackPos = nil;
	local SystemBoardText = nil;
	local SystemBoardTextInitPos = nil;


	local CurrBoard = nil; --当前公告
	local DEFSHOWTIMES = 2;  --define 循环播放次数
	local showTimes = 0; --当前公告已经播放次数

	function UISystemBoard.Start ()
		this = UISystemBoard.this;
		SystemBoardBack = this:GO('Panel.Back');
		SystemBoardBackPos = SystemBoardBack.transform.localPosition;
		SystemBoardText = this:GO('Panel.Back.Text'):GetComponent("LRichText");
		SystemBoardTextInitPos = SystemBoardText.transform.localPosition;
		UISystemBoard.Reset();
		client.SystemBoard.AddListener(UISystemBoard.StartPlay);
		
	end

	function UISystemBoard.StartPlay()
		if CurrBoard ~= nil then
			return;
		end		
		CurrBoard = client.SystemBoard.Dequeue();
		if CurrBoard == nil then
			UISystemBoard.OnExit();
			return;
		end
		SystemBoardText.text = CurrBoard;
		UISystemBoard.doTween();
	end

	function UISystemBoard.doTween()
		showTimes = showTimes + 1;
		local textWidth = SystemBoardText.realLineWidth;
		local backWidth = SystemBoardBack.rectSize.x;
		local position = Vector3.New(-(textWidth + backWidth) + SystemBoardTextInitPos.x,SystemBoardTextInitPos.y,SystemBoardTextInitPos.z)
		local hashtable = iTween.Hash("time",10, "oncomplete", "OnTweenComplete",
		"oncompleteparams",SystemBoardText.gameObject,"EaseType","linear","isLocal",true)
		Util.MoveToEx(SystemBoardText.gameObject, position,hashtable,UISystemBoard.OnTweenComplete);
		
	end	

	function UISystemBoard.RePlay()
		SystemBoardText.transform.localPosition = SystemBoardTextInitPos;
		UISystemBoard.doTween();
	end

	function UISystemBoard.OnTweenComplete(go)
		if showTimes < DEFSHOWTIMES then   --重播
			UISystemBoard.RePlay()
		else
			UISystemBoard.Reset();
			if client.SystemBoard.IsListEmpty() then
				UISystemBoard.OnExit()
			else
				UISystemBoard.StartPlay();
			end
		end
	end

	function UISystemBoard.Reset()
		CurrBoard = nil;
		showTimes = 0;
		SystemBoardText.transform.localPosition = SystemBoardTextInitPos;

	end

	function UISystemBoard.OnExit()
		iTween.FadeTo(SystemBoardBack.gameObject, 0 ,0.5);
		this:Delay(0.6, function() 
			client.SystemBoard.Clear();
			destroy(this.gameObject);end);
	end


	return UISystemBoard;
end