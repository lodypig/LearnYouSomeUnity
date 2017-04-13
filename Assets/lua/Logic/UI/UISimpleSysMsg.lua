function UISimpleSysMsgView ()
	local UISimpleSysMsg = {};
	local this = nil;
	local Panel = nil;
	local Back = nil
	local Text = nil;
	local BackInitPos = nil;
	local TextInitPos = nil;
	local BackInitColor = nil;
	local TextInitColor = nil;
	local Counter = 0;
	local TargetPos = nil;

	local DEFSHOWTIME = 2;  --显示时间
	local DEFSHOWNUM = 3; --最多显示条数

	local CtrlList = {}; --控件列表


	function UISimpleSysMsg.Start ()
		this = UISimpleSysMsg.this;

		for i = 1,3 do			
			local str = "Text"..i
			local objWrapper = this:GO(str).gameObject;     	
			objWrapper:SetActive(true);
			CtrlList[#CtrlList + 1] = objWrapper
        end

        client.SimpleSysMsg.AddListener(UISimpleSysMsg.ShowMsg);
        EventManager.bind(this.gameObject,Event.ON_ENTER_SCENE,UISimpleSysMsg.OnEnterScene);
        client.singleton.addUpdate(UISimpleSysMsg.Update);
	end

	function UISimpleSysMsg.FirstUpdate()
		Text = this:GO('Text1');
		TextInitColor = Text.textColor;
		TextInitPos = Text.transform.localPosition;
		TargetPos =  Vector3.New(TextInitPos.x,TextInitPos.y + 70,0);	

	end

	function UISimpleSysMsg.OnEnterScene( )
		for i=1,#CtrlList do
			CtrlList[i].gameObject:SetActive(false);
		end
	end

	function UISimpleSysMsg.Update()
		local msg = client.SimpleSysMsg.Dequeue() 
		if msg ~= nil then
			UISimpleSysMsg.ShowMsg(msg)
		end
	end

	function UISimpleSysMsg.ShowMsg(msg)
		if(msg == nil) then
			return
		end
		local go = CtrlList[Counter % DEFSHOWNUM + 1];
		go:SetActive(true);
		UISimpleSysMsg.Reset(go);

		go:GetComponent("UIWrapper").text = msg;
		UISimpleSysMsg.DoTween(go)

		Counter = Counter + 1;
	end

	function UISimpleSysMsg.Reset(go)			
		iTween.Stop(go);
		go.transform.localPosition = TextInitPos;
		go:GetComponent("UIWrapper").textColor = TextInitColor;
	end

	function UISimpleSysMsg.OnTweenComplete(go)
		go:SetActive(false);
	end

	function UISimpleSysMsg.DoTween(go)
		--淡出
		local hashtable = iTween.Hash("alpha",0,"time",DEFSHOWTIME+0.1,"oncomplete", "OnTweenComplete","isLocal", 
			true,"includechildren",true,"oncompleteparams",go); 

		Util.FadeToEx(go, hashtable,UISimpleSysMsg.OnTweenComplete);
		--移动
		hashtable = iTween.Hash("time",DEFSHOWTIME,"easetype", "linear","isLocal",true);
		Util.MoveToEx(go,TargetPos,hashtable,nil)
	end


	return UISimpleSysMsg;
end
