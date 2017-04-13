function UIWorldBoardView ()
	local UIWorldBoard = {};
	local this = nil;
	--local Back = nil
	--local BoardText = nil;	
	--local BackInitColor = nil;
	--local TextInitColor = nil;
	--local ShowTime = 3;     --显示时间
	--local FadeTime = 2;		--淡出时间

	local CurrBoard = nil; --当前公告
	local DEFSHOWTIMES = 1;  --define 循环播放次数
	local showTimes = 0; --当前公告已经播放次数

	local WorldBoardBack = nil;
	local WorldBoardBackPos = nil;
	local WorldBoardText = nil;
	local WorldBoardTextInitPos = nil;

	function UIWorldBoard.Start ()
		this = UIWorldBoard.this;
		WorldBoardBack = this:GO('Panel.Back');
		WorldBoardBackPos = WorldBoardBack.transform.localPosition;
		WorldBoardText = this:GO('Panel.Back.Text'):GetComponent("LRichText");
		WorldBoardTextInitPos = WorldBoardText.transform.localPosition;

		UIWorldBoard.Reset();
		client.WorldBoard.AddListener(UIWorldBoard.StartPlay);
		
	end

	function UIWorldBoard.Reset()
		CurrBoard = nil;
		showTimes = 0;
		WorldBoardText.transform.localPosition = WorldBoardTextInitPos;
	end

	function UIWorldBoard.StartPlay()
		if CurrBoard ~= nil then
			return;
		end		
		CurrBoard = client.WorldBoard.Dequeue();
		if CurrBoard == nil then
			UIWorldBoard.OnExit();
			return;
		end
		WorldBoardText.text = CurrBoard;
		UIWorldBoard.doTween();
	end

	function UIWorldBoard.doTween()
		showTimes = showTimes + 1;
		local textWidth = WorldBoardText.realLineWidth;
		local backWidth = WorldBoardBack.rectSize.x;

		local position = Vector3.New(-(textWidth + backWidth) + WorldBoardTextInitPos.x,WorldBoardTextInitPos.y,WorldBoardTextInitPos.z)

		local hashtable = iTween.Hash("time",20, "oncomplete", "OnTweenComplete",
		"oncompleteparams",WorldBoardText.gameObject,"EaseType","linear","isLocal",true)
		Util.MoveToEx(WorldBoardText.gameObject, position,hashtable,UIWorldBoard.OnTweenComplete);
		
	end	

	function UIWorldBoard.RePlay()
		WorldBoardText.transform.localPosition = WorldBoardTextInitPos;
		UIWorldBoard.doTween();
	end

	function UIWorldBoard.OnTweenComplete(go)
		if showTimes < DEFSHOWTIMES then   --重播
			UIWorldBoard.RePlay()
		else
			UIWorldBoard.Reset();
			if client.WorldBoard.IsListEmpty() then
				UIWorldBoard.OnExit()
			else
				UIWorldBoard.StartPlay();
			end
		end
	end

	function UIWorldBoard.Reset()
		CurrBoard = nil;
		showTimes = 0;
		WorldBoardText.transform.localPosition = WorldBoardTextInitPos;

	end

	function UIWorldBoard.OnExit()
		iTween.FadeTo(WorldBoardBack.gameObject, 0 ,0.5);
		this:Delay(0.6, function() 
			client.WorldBoard.Clear();
			destroy(this.gameObject);end);
	end

	return UIWorldBoard;
end


-------------------------原来的逻辑 每条显示2秒不滚动------------------------------
	--[[function UIWorldBoard.Start ()
		this = UIWorldBoard.this;
		Back = this:GO('Panel.Back');
		BoardText = this:GO('Panel.Back.Text'):GetComponent("LRichText");
		client.WorldBoard.AddListener(UIWorldBoard.StartPlay);
		BackInitColor = Back.imageColor; --背景图初始颜色
	end

	function UIWorldBoard.OnTweenComplete(go)
		CurrBoard = nil;
		Back.imageColor = BackInitColor;
		if client.WorldBoard.IsListEmpty() then
			UIWorldBoard.OnExit()
		else
			UIWorldBoard.StartPlay();
		end
		
	end

	function UIWorldBoard.StartPlay()
		if CurrBoard ~= nil then
			--正在播放
			return;
		end		
		
		CurrBoard = client.WorldBoard.Dequeue();
		if CurrBoard == nil then
			UIWorldBoard.OnExit();
			return;
		end
		BoardText.text = CurrBoard;
		ui.setNodeWidth(Back.gameObject,BoardText.realLineWidth) 
		this:Delay(ShowTime, UIWorldBoard.DoTween); --显示X秒后淡出
	end

	function UIWorldBoard.DoTween()
		local hashtable = iTween.Hash("alpha",0,"time",FadeTime,"oncomplete", "OnTweenComplete","isLocal", 
			true,"oncompleteparams",Back.gameObject,"includechildren",true); --此tween对child也生效
		Util.FadeToEx(Back.gameObject, hashtable,UIWorldBoard.OnTweenComplete);
	end

	function UIWorldBoard.OnExit()
		CurrBoard = nil;
		client.WorldBoard.Clear()
		destroy(this.gameObject);
	end]]
