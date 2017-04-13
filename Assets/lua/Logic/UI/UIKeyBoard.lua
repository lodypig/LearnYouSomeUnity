function UIKeyBoardView(param)	
	local UIKeyBoard = {};
	local this = nil;

	local textWrapper = param.textWrapper;
	local min = tonumber(param.min);
	local max = tonumber(param.max);

	local first = true;

	function UIKeyBoard.Start() 
		this = UIKeyBoard.this;
		
		for i=0, 9 do
			this:GO('KeyBoard.grid.btn'..i):BindButtonClick(function ()
				UIKeyBoard.OnBtnNum(i)
			end);
		end

		this:GO('KeyBoard.grid.btnDelete'):BindButtonClick(UIKeyBoard.OnBtnDelete);
		this:GO('KeyBoard.grid.btnEnter'):BindButtonClick(UIKeyBoard.Close);
		this:GO('blank'):BindButtonClick(UIKeyBoard.Close);
	end

	function UIKeyBoard.Close()		
		local text = textWrapper.text;
		local len = Util.StringLength(text);
		if len == 0 or tonumber(text) < min then
			textWrapper.text = min or 1;
		end

		if len ~= 0 and tonumber(text) >= max then
			textWrapper.text = max;
		end

		if param.callback then
			param.callback();
		end
		destroy(this.gameObject);
	end

	function UIKeyBoard.OnBtnNum(num)
		if first then
			if num ~= 0 then
				textWrapper.text = num;
				first = false;
			end

			return;
		end

		local text = textWrapper.text;
		local len = Util.StringLength(text);

		if len == 0 and num == 0 then
			return
		end

		text = text..num;
		if max ~= nil and tonumber(text) > max then
			text = max;
		end
		textWrapper.text = text;
	end

	function UIKeyBoard.OnBtnDelete()
		if first then
			textWrapper.text = "";
			first = false;
		end

		local text = textWrapper.text;
		local len = Util.StringLength(text);

		if len > 1 then
			textWrapper.text = Util.Substring(text, 0, len - 1);
		else
			textWrapper.text = "";
		end
	end

	return UIKeyBoard;
end