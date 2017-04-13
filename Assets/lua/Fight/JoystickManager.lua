function CreateJoystickManager()
	local t = {};
	t.is_joysticking = false;
 	t.OnBeginJoystick = function ()
 		t.is_joysticking = true;
 	end;
 	t.OnEndJoystick = function ()
 		t.is_joysticking = false;
 	end;
 	t.OnUpdateJoystick = function ()

 	end;
 	t.IsJoysticking = function()
 		return t.is_joysticking;
 	end;
 	t.Clear = function ()
 		t.is_joysticking = false;
 	end;
 	t.OnSceneLoaded = function()
 		t.OnEndJoystick()
 		--同时隐藏touch月牙图标
 		MainUI.HideJoystickTouchIcon()
 	end
	return t;
end


JoystickManager = CreateJoystickManager();