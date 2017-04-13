CommonRTT = 
{	
	class = "CommonRTT",
	width = 600,
	height = 700 ,
	camera = nil,
	mirror_camera = nil,
	rt = nil,
	roleFigure = nil,
	cell = nil,
	camGOPosition = Vector3(0.14, 3.231, -13.51),
	camGORotation = Quaternion.Euler(9.69, 0, 0),
	mirror_camGOPosition = Vector3(0.14, -3.231, -13.51),
	mirror_camGORotation = Quaternion.Euler(342.1, 0, 0),
	camOrthographicSize = 1.5,
	camOrthographic = true,
	camFieldOfView = 60,
	InitialRTTRotation =  Vector3(0,180,0),
	bMirror = false,
	bShadow = false,
	curShowModelName = nil,
}

function CommonRTT:new(o)
	o = o or {}
	self.__index = self
	setmetatable(o, self)
	return o
end

CommonRTT.__index = function(t,k)
	if k == "role" then
		return self:GetCellModel()
	end
	return prototype[k]
end

function CommonRTT:GetCellModel()
	-- print("GetCellModel")
	local cell = RTTManager.GetCell(self.class)
	if cell == nil then
		-- print("cell return nil")
		return nil
	end
	if cell.CurModelName == 0 or cell.RttModels[cell.CurModelName] == nil then
		-- print("cell.CurModelName   ")
		-- DataStruct.DumpTable(cell.RttModels)
		return nil
	end
	return cell.RttModels[cell.CurModelName]
end

function CommonRTT:ComInitRtt(modelName, modelMaterialName, luaName, callback)
	-- print("--------------CommonRTT:ComInitRtt")
	--创建cell
	self.cell = RTTManager.CreateCell(self.class, self.width, self.height, self.bMirror, self.bShadow)
	UnityEngine.Object.DontDestroyOnLoad(self.cell.gameObject)

	local keyName = (modelMaterialName ~= nil) and modelMaterialName or modelName
	self:SetCurShowModel(keyName)

	-- print("SetModelCreatingFlag true  Init   "..keyName)
	self.cell.SetModelCreatingFlag(keyName, true)
	--创建cell model
	uFacadeUtility.CreateModel(Vector3.zero, modelName, modelMaterialName, luaName, function(avatar)
		self.cell.DestroyAllModels(false)
		local modelkeyName = (modelMaterialName ~= nil) and modelMaterialName or modelName
		avatar.gameObject.name = modelkeyName
		local _oldKey = self.cell.CurModelName
		self.cell.CurModelName = modelkeyName
		self.cell.AddModel(modelkeyName, avatar)
		avatar.transform.localPosition = Vector3.zero
		avatar.transform.localEulerAngles = self.InitialRTTRotation

		self.cell.RttCamera.transform.localPosition = self.camGOPosition
		self.cell.RttCamera.transform.rotation = self.camGORotation
		self.cell.RttCamera.orthographic = self.camOrthographic
		self.cell.RttCamera.orthographicSize = self.camOrthographicSize
		self.cell.RttCamera.fieldOfView = self.camFieldOfView
		self.cell.RttCamera.cullingMask = GameLayer.GetMask_RTT()

		self.cell.camGo.gameObject:SetActive(true)
		self.camera = self.cell.camGo

		if self.cell.bMirror == true then
			self.cell.MirrorCamera.transform.localPosition = self.mirror_camGOPosition
			self.cell.MirrorCamera.transform.rotation = self.mirror_camGORotation
			self.cell.MirrorCamera.fieldOfView = self.camFieldOfView
			self.cell.MirrorCamera.orthographic = self.camOrthographic
			self.cell.MirrorCamera.orthographicSize = self.camOrthographicSize
			self.mirror_camera = self.cell.MirrorCamera.gameObject
		end
		--model animator enable
		-- print("SetModelCreatingFlag  "..modelkeyName)
		-- print("false")
		self.cell.SetModelCreatingFlag(modelkeyName, false)
		-- DataStruct.DumpTable(self.cell.ModelCreating)
		if callback ~= nil then
			callback(avatar);
		end
		if _oldKey ~= 0 and self.cell.RttModels[_oldKey] ~= nil then
			local _old_avatar = self.cell.RttModels[_oldKey]
			_old_avatar.gameObject:SetActive(false)
		end
		avatar.gameObject:SetActive(true)
		self:SetRttVisible(true)

		--
		self.cell.setShadow()
	end)
end

function CommonRTT:ComUpdateRtt(modelName, modelMaterialName, bDeleteOld, callback)
	-- print("--------------CommonRTT:ComUpdateRtt")
	local oldKey = self.cell.CurModelName
	-- print(oldKey)
	local keyName = (modelMaterialName ~= nil) and modelMaterialName or modelName
	if oldKey ~= 0 and self.cell.RttModels[oldKey] ~= nil then
		local old_avatar = self.cell.RttModels[oldKey]
		--相同模型
		if oldKey == keyName then
			--call一下update
			if callback ~= nil then
				callback(old_avatar);
			end
			self:SetRttVisible(true)
			self:SetCurShowModel(keyName)
			return
		end
		local ExistModel = self.cell.IsExistModel(keyName)
		-- print("Update "..keyName)
		-- print(ExistModel)
		if ExistModel ~= nil then
			old_avatar.gameObject:SetActive(false)
			ExistModel.gameObject:SetActive(true)
			self.cell.CurModelName = keyName
			--同模型不同材质的时装后面要去掉 先用modelMaterialName做命名区分
			--call一下update
			if callback ~= nil then
				callback(ExistModel);
			end
			self:SetRttVisible(true)
			self:SetCurShowModel(keyName)
			return
		end
		--是否删除原来的
		if bDeleteOld == true then
			--清除RTT中RttModel
			self.cell.DestroyModel(oldKey)
			self.cell.CurModelName = 0
		else
			old_avatar.gameObject:SetActive(false)
		end
	end
	--是否正在创建
	if self.cell.IsModelCreating(keyName) then
		self:SetCurShowModel(keyName)
		return
	end
	
	-- print("SetModelCreatingFlag true  Update   "..keyName)
	self.cell.SetModelCreatingFlag(keyName, true)
	self:SetCurShowModel(keyName)
	--不存在 创建cell model  
	-- self:SetCameraVisible(true)
	uFacadeUtility.CreateModel(Vector3.zero, modelName, modelMaterialName, "", function(avatar)
		local modelkeyName = (modelMaterialName ~= nil) and modelMaterialName or modelName
		-- print(">>>> CreateModel! "..modelkeyName)
		avatar.gameObject.name = modelkeyName
		self.cell.AddModel(modelkeyName, avatar)
		local _oldKey = self.cell.CurModelName
		self.cell.CurModelName = modelkeyName
		avatar.transform.localPosition = Vector3.zero
		avatar.transform.localEulerAngles = self.InitialRTTRotation
		-- print("Update SetModelCreatingFlag   "..modelkeyName)
		-- print("false")
		self.cell.SetModelCreatingFlag(modelkeyName, false)
		-- DataStruct.DumpTable(self.cell.ModelCreating)
		if callback ~= nil then
			callback(avatar);
		end
		if _oldKey ~= 0 and self.cell.RttModels[_oldKey] ~= nil then
			local _old_avatar = self.cell.RttModels[oldKey]
			_old_avatar.gameObject:SetActive(false)
		end
		self:SetRttVisible(true)
		--当前选中不是该模型 则隐藏
		if self.curShowModelName ~= modelkeyName then
			avatar.transform.gameObject:SetActive(false)
		end
	end)
end

function CommonRTT:SetCurShowModel(curKey)
	if self.curShowModelName ~= nil and self.cell.RttModels[self.curShowModelName] ~= nil then
		self.cell.RttModels[self.curShowModelName].gameObject:SetActive(false)
	end
	self.curShowModelName = curKey
	if self.cell.RttModels[self.curShowModelName] ~= nil then
		self.cell.RttModels[self.curShowModelName].gameObject:SetActive(true)
	end
end

function CommonRTT:RefreshShow()
	self.cell.RefreshModelShow(self.curShowModelName)
end

function CommonRTT:ClearModels(clearMaterial)
	self.cell.DestroyAllModels(clearMaterial)
end

function CommonRTT:SetVisible(flag)
	local model = self:GetCellModel()
	if model == nil then
		return
	end
	model.gameObject:SetActive(flag)	
	self:SetCameraVisible(flag)
	if flag == true then
		self:ResetRotation(self.InitialRTTRotation)
	end
end

function CommonRTT:SetCameraVisible(flag)
	self.camera:SetActive(flag)
	if self.mirror_camera ~= nil then
		self.mirror_camera:SetActive(flag)
	end
end

function CommonRTT:SetRttVisible(value)
	if self.cell ~= nil then
		self.cell.SetVisible(value)
	end
	self:SetVisible(value)
end

function CommonRTT:ResetRotation()
	local model = self:GetCellModel()
	if model ~= nil then
		model.transform.localEulerAngles = self.InitialRTTRotation
	end
end

function CommonRTT:RotateRole(go, delta)
	-- print("CommonRTT:RotateRole")
	if self.role == nil then
		-- print("???return")
		return
	end
	local x = delta.x
	local angles = role.transform.rotation.eulerAngles
	self.role.transform.rotation = Quaternion.Euler(angles.x, angles.y - x, angles.z)
end