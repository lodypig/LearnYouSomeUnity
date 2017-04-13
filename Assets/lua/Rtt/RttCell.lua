function CreateRTTCell(name, width, height, bMirror, bShadow)
	local t = {}

	t.cellname = name
	t.width = width
	t.height = height
	t.refCount = 0
	t.CurModelName = 0
	t.bMirror = false
	t.bShadow = false

	t.RttModels = {}

	--create 
	t.RttRoot = GameObject.New("RttCell")
	t.camGo = GameObject.New(string.format("RTTCamera_%s", t.cellname))
	local camT = t.camGo.transform
	camT.parent = t.RttRoot.transform;
	camT.localPosition = Vector3.New(0,0,-10)
	camT.localEulerAngles = Vector3.zero;
	camT.localScale = Vector3.one;
	t.RttCamera = t.camGo:AddComponent(typeof(Camera))
	t.RttCamera.clearFlags = UnityEngine.CameraClearFlags.SolidColor

	t.RttMat = uFacadeUtility.CreateMaterial("MW/RTT")
	local RttTex = RTTManager.CreateRenderTexture(t.width, t.height, false)
	t.RttMat.mainTexture = RttTex

	t.RttCamera.targetTexture = RttTex
	t.RttCamera.backgroundColor = Color.New(0, 0, 0, 0)
    t.RttRoot.transform.position = Vector3.zero
    t.RttRoot.transform.localPosition = Vector3.zero

    --正在创建模型 控制
    t.ModelCreating = {}

    --镜像
    if bMirror == true then
    	t.m_camGO = GameObject.New(string.format("RTTCamera_%s_Mirror", t.cellname))
		local m_camT = t.m_camGO.transform
		m_camT.parent = t.RttRoot.transform;
		m_camT.localPosition = Vector3.New(0,0,-10)
		m_camT.localEulerAngles = Vector3.zero;
		m_camT.localScale = Vector3.one;
		t.MirrorCamera = t.m_camGO:AddComponent(typeof(Camera))
		t.MirrorCamera.clearFlags = UnityEngine.CameraClearFlags.SolidColor

		t.MirrorMat = uFacadeUtility.CreateMaterial("MW/RTTMirror")
		local MirrorTex = RTTManager.CreateRenderTexture(t.width, t.height, true)
		t.MirrorMat.mainTexture = MirrorTex

		t.MirrorCamera.targetTexture = MirrorTex
		t.MirrorCamera.backgroundColor = Color.New(0, 0, 0, 0)
		t.bMirror = true
    end

	t.bShadow = bShadow
	setmetatable(t, t)

    --value
    t.__index = function(t,k)
    	if k == "transform" then
    		if t.RttRoot == nil then
    			return nil
    		end
    		return t.RttRoot.transform
    	elseif k == "camera" then
    		return t.RttCamera
    	elseif k == "material" then
    		return t.RttMat
    	elseif k == "mirror_material" then
    		return t.MirrorMat
    	elseif k == "models" then
    		return t.RttModels
    	elseif k == "name" then
    		return t.cellname
    	elseif k == "gameObject" then
    		if t.RttRoot == nil then
    			return nil
    		end
    		return t.RttRoot.gameObject
    	end
    	if t.prototype[k] == nil then
    		--print("Index Error: "..k)
    	end
		return t.prototype[k]
	end

	t.setShadow = function()
		--阴影
	    if t.bShadow == true then
	    	uFacadeUtility.AddCameraShadowBlit(t.camGo)
	    end
	end
	-- --function
	-- --重置旋转
	-- t.ResetRotation = function(rotation)
	-- 	for i =1, #t.RttModels do
	-- 		local model = t.RttModels[i]
	-- 		if model ~= nil then
	-- 			model.transform.localEulerAngles = rotation
	-- 		end
	-- 	end
	-- end

	t.destroy = function()
		t.Release()
		t.DestroyAllModels(true)
		if t.RttRoot ~= nil then
			destroy(t.RttRoot)
			t.RttRoot = nil
			t.RttCamera = nil
			t.RttTex = nil
			t.MirrorCamera = nil
			t.MirrorTex = nil
		end
	end

	t.IsExistModel = function(modelname)
		if t.RttModels == nil or modelname == nil then
			return nil;
		end
		return t.RttModels[modelname]
	end

	t.AddModel = function(keyname, model)
		if t.RttModels ~= nil then
			if t.RttModels[keyname] ~= nil then
				--print("Error RttModel Add Duplicate!!")
			end
			-- print("AddModel  "..keyname)
			-- print(model)
			t.RttModels[keyname] = model
			model.transform:SetParent(t.RttRoot.transform) 
		end
	end

	t.DestroyModel = function(keyname)
		if t.RttModels == nil or keyname == nil or t.RttModels[keyname] == nil then
			return
		end
		destroy(t.RttModels[keyname])
		t.RttModels[keyname] = nil
		if t.CurModelName == keyname then
			t.CurModelName = 0
		end
	end

	t.DestroyAllModels = function(DestroyMaterial)
		for k,v in pairs(t.RttModels) do
			if DestroyMaterial == true then
				--先清除其Material
				uFacadeUtility.ReleaseMaterial(v)
			end
			destroy(v)
		end
		t.RttModels = {}
		t.ModelCreating = {}
		t.CurModelName = 0
	end

	t.SetVisible = function(value)
		if t.RttRoot ~= nil then
			t.RttRoot:SetActive(value)
		end
	end

	--不用了要调用Release 释放mainTexture
	t.Release = function()
		if t.RttMat ~= nil then
			GameObject.DestroyImmediate(t.RttMat)
			t.RttMat = null
		end
		if t.bMirror and t.MirrorMat ~= nil then
			GameObject.DestroyImmediate(t.MirrorMat)
			t.MirrorMat = null
		end
	end

	t.RefreshModelShow = function(curKey)
		for k,v in pairs(t.RttModels) do
			if k == curKey then
				v.gameObject:SetActive(true)
			else
				v.gameObject:SetActive(false)
			end
		end
	end


	--模型正在创建
	t.IsModelCreating = function(keyName)
		if keyName == nil then
			return false
		end
		return t.ModelCreating[keyName] ~= nil and t.ModelCreating[keyName] == true
	end

	t.SetModelCreatingFlag = function(keyName, flag)
		-- print("SetModelCreatingFlag  "..keyName)
		-- print(flag)
		if keyName == nil then
			return
		end
		t.ModelCreating[keyName] = flag
	end

	return t
end
