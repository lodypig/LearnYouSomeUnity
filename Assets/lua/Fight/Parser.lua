function CreateParser()
	local t = {};
	t.ParseKVMessage = function (msg)
		local info = {};
		if msg == nil then
			return info;
		end
		for i = 1, #msg do
			local msg_item = msg[i];
			info[msg_item[1]] = msg_item[2];
		end
		return info;
	end;

	return t;
end

Parser = CreateParser();