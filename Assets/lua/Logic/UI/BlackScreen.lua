function BlackScreenView (param)
	local BlackScreen = {};
	local this = nil;
	--缓存传入的文本信息
	local pageInfo = {};
	local pageIndex = 1;
	local TextGroup = nil;
	--读取表格中的黑幕数据，初始化成3行一章的格式
	local LoadPageInfo = function(sid)
		local temp = {};
		local pIndex = 1;
		local dIndex = 1;
		local tableContent = tb.BlackScreenTable[sid];
		for i=1,#tableContent do
			if dIndex > 3 then
				pIndex = pIndex + 1;
				dIndex = 1;
			end
			if temp[pIndex] == nil then
				temp[pIndex] = {};
			end
			temp[pIndex][dIndex] = tableContent[i]
			dIndex = dIndex + 1;
		end
		return temp;
	end

	function BlackScreen.Start ()
		this = BlackScreen.this;
		TextGroup = this:GO('Panel.TextGroup');
		pageInfo = LoadPageInfo(param.sid);
		BlackScreen.FormatPage();
	end

	function BlackScreen.Close()
		if TaskTrigger.HaveEventNow(param.realId) then			
			TaskTrigger.DoNextEvent(param.realId);
		end
		destroy(this.gameObject);
	end

	local ResizeItem = function(size)		
		for i = size+1,3 do

		end
	end

	--控制一页的播放
	BlackScreen.FormatPage = function()
		TextGroup:SetAlpha(1);
		if pageInfo[pageIndex] == nil then
			BlackScreen.Close();
			return;
		end
		--先把字填进去
		for i=1,3 do
			if pageInfo[pageIndex][i] ~= nil then
				local Text = TextGroup:GO('_Text'..i);
				Text.text = pageInfo[pageIndex][i];
				Text:SetAlpha(0);
				this:Delay((i-1)*2, function()
					Text:DOFade(0, 1, 1.5);
            	end);
			end
		end
		this:Delay(#pageInfo[pageIndex]*2 + 2 , function()
			TextGroup:DOFade(1, 0, 1.5);
        end);
		this:Delay(#pageInfo[pageIndex]*2 + 4 , function()
			for i=1,3 do
				local Text = TextGroup:GO('_Text'..i);
				Text:SetAlpha(0);
			end	
			pageIndex = pageIndex + 1;
			BlackScreen.FormatPage();	
    	end);
	end

	return BlackScreen;
end
