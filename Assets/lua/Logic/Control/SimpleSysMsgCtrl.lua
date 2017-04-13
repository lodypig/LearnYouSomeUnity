function CreateSimpleSysMsgCtrl()
	local SimpleSysMsg = {};
	SimpleSysMsg.List = {}
	SimpleSysMsg.OnEqueueEvent = nil;

	SimpleSysMsg.AddListener = function (listener)
		SimpleSysMsg.OnEqueueEvent = listener;

	end

	function  SimpleSysMsg.ShowMsg(msg)
		SimpleSysMsg.List[#SimpleSysMsg.List + 1] = msg
	end

	function SimpleSysMsg.Dequeue()
		if #SimpleSysMsg.List > 0 then
			return table.remove(SimpleSysMsg.List,1) 
		else
			return nil
		end
	end

	function SimpleSysMsg.Test()
		for i = 1,20 do
			SimpleSysMsg.List[i] = "test "..i
		end
	end

	return SimpleSysMsg;
end
client.SimpleSysMsg = CreateSimpleSysMsgCtrl();