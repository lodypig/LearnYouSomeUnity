function CreateRTTManager()
	local t = {}

	t.cells = {}
	t.cellcount = 0

	t.renderTexs = {}

	t.ExistsCell = function(name)
		return t.cells[name] ~= nil
	end

	t.GetCell = function(name)
		return t.cells[name]
	end

	t.CreateCell = function(name, width, height, bMirror, bShadow)
		if t.cells[name] ~= nil then
			return t.cells[name]
		end
		local cell = CreateRTTCell(name, width, height, bMirror, bShadow)
		t.cells[name] = cell
		t.cellcount = t.cellcount + 1
		t.Update()
		return cell
	end

	t.CreateRenderTexture = function(width, height, bMirror)
		-- print("CreateRenderTexture")
		local renderTexKey = string.format("%dx%d", width, height);
		if bMirror then
			renderTexKey = string.format("%dx%d_Mirror", width, height);
		end
		-- print(renderTexKey)
		if t.renderTexs[renderTexKey] == nil then
			t.renderTexs[renderTexKey] = UnityEngine.RenderTexture.New(width, height, 32)
		end
		return t.renderTexs[renderTexKey]
	end

	t.DestroyCell = function(name)
		if t.cells[name] ~= nil then
			local cell = t.cells[name]
			t.cells[name] = nil
			cell.destroy()
			t.cellcount = t.cellcount - 1
		end
	end

	t.DestroyAllCells = function()
		for k,v in pairs(t.cells) do
			v.destroy()
		end
		t.cells = {}
		t.cellcount = 0
	end

	t.Update = function()
		if t.cellcount > 0 then
			local offset = Vector3.down * 10000
			local i = 0
			local interval = 50
			for k,v in pairs(t.cells) do
				v.transform.localPosition = Vector3(i * interval, -10000, 0)
				i = i + 1
			end
		end
	end

	t.SetRoleFigure = function(wrapper, rtt, bMirror, bReset)
		-- print("SetRoleFigure!!")
		if wrapper == nil then
			return
		end
		if rtt == nil then
			return
		end
		local cell = rtt.cell
		if cell == nil then
			return
		end
		local rf = rtt.roleFigure
		if rf == nil then
			rf = CreateRoleFigure(wrapper)
			rf.Init(wrapper)
			rtt.roleFigure = rf
		else
			--镜像不要init bind
			if not bMirror then
				rf.Init(wrapper)
			end
		end
		rf.cell = cell
		if bMirror then
			wrapper.material = cell.mirror_material
		else
			wrapper.material = cell.material
		end
		if bReset == true then
			rtt:ResetRotation()
		end
	end

	return t
end

RTTManager = CreateRTTManager()