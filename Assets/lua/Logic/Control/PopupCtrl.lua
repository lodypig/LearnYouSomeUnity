

createPopup = function(go)
	local controller = {}
	controller.go = go
	controller.itemCount = 0
	controller.itemList = {}

	--start
	controller.Start = function(go)
		controller.Content = go:GO('Grid.Content')
		controller.prefab = go:GO('Grid.popupItem')
		controller.Grid = go:GO('Grid')
	end	

	--Add
	controller.AddPopupItem = function(text, callback)
		local item = newObject(controller.prefab)
		item.transform:SetParent(controller.Content.transform)
		item.gameObject:SetActive(true)
		item:GO('Text').text = text
		item.transform.name = text
		item.transform.localScale = Vector3.one;
		item:BindButtonClick(callback)
		controller.itemCount = controller.itemCount + 1
		controller.itemList[controller.itemCount] = item
	end

	--clear 
	controller.ClearPopupItem = function()
		for i=1,#controller.itemList do
			if controller.itemList[i]~= nil and controller.itemList[i].gameObject ~= nil then
				destroy(controller.itemList[i].gameObject)
			end
		end
		controller.itemList = {}
	end

	--UpdateHeight
	controller.UpdateHeight = function()
		local vect2 = controller.Grid:GetComponent("RectTransform").sizeDelta;
		if controller.itemCount > 3 then
			vect2.y = controller.cellSize[2] * 3.5
		else
			vect2.y = controller.cellSize[2] * controller.itemCount
		end
		controller.Grid:GetComponent("RectTransform").sizeDelta = vect2
	end

	--SetCellSize
	controller.SetCellSize = function(x,y)
		controller.cellSize = {x,y}
		local vect2 = controller.Grid:GetComponent("RectTransform").sizeDelta;
		vect2.x = x
		controller.Grid:GetComponent("RectTransform").sizeDelta = vect2
	end

	controller.Start(go)
	return controller;
end