function CreateRoleFigure(wrapper)
	local t = {}

	t.OneObj = nil
	t.cell = nil
	t.wrapper = nil

	t.RotateRole = function(go, delta)
		-- print("RoleFigure RotateRole")
		local role = nil
		if t.cell ~= nil then
			-- print("t.cell ~ nil")
			if t.cell.CurModelName == 0 or t.cell.RttModels[t.cell.CurModelName] == nil then
				-- print(t.cell.CurModelName)
				--DataStruct.DumpTable(t.cell.RttModels)
				return
			end
			role = t.cell.RttModels[t.cell.CurModelName]
		else
			role = t.OneObj
		end

		if role == nil then
			-- print("return role nil")
			return
		end
		local x = delta.x;
		local angles = role.transform.rotation.eulerAngles
		role.transform.rotation = Quaternion.Euler(angles.x, angles.y - x, angles.z)
	end

	t.Init = function(w)
		t.wrapper = w		
		if t.RotateRole ~= nil then
			-- print("init Bind ETDrag")
			t.wrapper:BindETDrag(t.RotateRole)
		else 
			--print("t.RotateRole nill  !!!")
		end
		t.wrapper.sprite = ""
	end

	t.Release = function()
		t.cell.Release()
	end

	t.Init(wrapper)

	return t
end