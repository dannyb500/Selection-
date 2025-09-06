local SelectPlus = {}
SelectPlus.__index = SelectPlus
local SelectionService = game:GetService("Selection")

function SelectPlus.Start()
	local self = setmetatable({}, SelectPlus)
	self.Selected = {}
	return self
end

function SelectPlus:Add(TextButton: string)
	self.Selected[TextButton.Text] = true
end

function SelectPlus:Remove(TextButton)
	self.Selected[TextButton.Text] = false
end

function SelectPlus:Select()
	local NewSelection = {}
	for _, Selected in pairs(SelectionService:Get()) do
		for _, v in pairs(Selected:GetDescendants()) do
			local S = self.Selected
			if S[v.ClassName] == true then
				table.insert(NewSelection, v)
			end
		end
	end
	SelectionService:Set(NewSelection)
end

function SelectPlus:SelectParent()
	local NewSelection = {}
	for _, Selected in pairs(SelectionService:Get()) do
		table.insert(NewSelection, Selected.Parent)
	end
	SelectionService:Set(NewSelection)
end

function SelectPlus:SelectSearch(Input)
	local NewSelection = {}
	for _, Selected in pairs(SelectionService:Get()) do
		for _, v in pairs(Selected:GetDescendants()) do
			if v.Name == Input or v.ClassName == Input then
				table.insert(NewSelection, v)
			end
		end
	end
	SelectionService:Set(NewSelection)
end

function hasProperty(object, propertyName)
	local success, _ = pcall(function()
		object[propertyName] = object[propertyName]
	end)
	return success
end

function SelectPlus:SelectColor(Input)
	local NewSelection = {}
	for _, Selected in pairs(SelectionService:Get()) do
		for _, v in pairs(Selected:GetDescendants()) do
			if hasProperty(v, "Color") then
				local split = string.split(Input, ",")
				if v.Color == Color3.fromRGB(split[1], split[2], split[3]) then
					table.insert(NewSelection, v)
				end
			end
		end
	end
	SelectionService:Set(NewSelection)
end

function SelectPlus:SelectMaterial(Input)
	local NewSelection = {}
	for _, Selected in pairs(SelectionService:Get()) do
		for _, v in pairs(Selected:GetDescendants()) do
			if hasProperty(v, "Material") then
				if v.Material == Enum.Material[Input] then
					table.insert(NewSelection, v)
				end
			end
		end
	end
	SelectionService:Set(NewSelection)
end

function SelectPlus:End()
	self = nil
end

return SelectPlus