local widgetInfo = DockWidgetPluginGuiInfo.new(
	Enum.InitialDockState.Float, -- Widget will be initialized in floating panel
	false, -- Widget will be initially enabled
	false, -- Don't override the previous enabled state
	200, -- Default width of the floating window
	300, -- Default height of the floating window
	150, -- Minimum width of the floating window (optional)
	150 -- Minimum height of the floating window (optional)
)
local Widget = plugin:CreateDockWidgetPluginGui("Selection+", widgetInfo)
local Module = require(script.Parent.SelectionPlus) --require(game.ReplicatedStorage.Source.SelectionPlus) for vsc
local InitMod = Module.Start()

Widget.Title = "Select"
--// Create new widget GUI
local UI = script.Parent.MainFrame
local ButtonsList = UI.ButtonsMenu.ScrollingFrame

script.Parent.MainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
script.Parent.MainFrame.Size = UDim2.new(1, 0, 1, 0)
script.Parent.MainFrame.Parent = Widget

local ToolBar = plugin:CreateToolbar("Selection+")
local PluginButton = ToolBar:CreateButton("Selection", "Selection+", "rbxassetid://12443815286")
PluginButton.ClickableWhenViewportHidden = false

--// Toggle UI
local function PluginClick()
	Widget.Enabled = not Widget.Enabled
	if Widget.Enabled == true then
		InitMod = Module.Start()
	else
		InitMod:End()
		for _, v in pairs(ButtonsList:GetChildren()) do
			if v:IsA("TextButton") then
				v:SetAttribute("Selected", false)
				v.BackgroundColor3 = Color3.fromRGB(54, 54, 54)
			end
		end
	end
	plugin:Deactivate()
end
PluginButton.Click:Connect(PluginClick)

for _, v in pairs(ButtonsList:GetChildren()) do
	if v:IsA("TextButton") then
		v:SetAttribute("Selected", false)
		v.MouseButton1Down:Connect(function()
			if InitMod ~= nil then
				if v:GetAttribute("Selected") == false then
					--SelectionAdd
					v:SetAttribute("Selected", true)
					v.BackgroundColor3 = Color3.fromRGB(59, 67, 80)
					InitMod:Add(v)
				else
					--SelectionRemove
					v:SetAttribute("Selected", false)
					v.BackgroundColor3 = Color3.fromRGB(54, 54, 54)
					InitMod:Remove(v)
				end
			end
		end)
	end
end

--// Materials
for _, v in pairs(Enum.Material:GetEnumItems()) do
	local NewButton = UI.ButtonsMenu.MaterialsPicker.Template:Clone()
	NewButton.Visible = true
	local tostr = tostring(v)
	local new = string.gsub(tostr, "Enum.Material.", "")
	NewButton.Text = new
	NewButton.Parent = UI.ButtonsMenu.MaterialsPicker.ScrollingFrame
	NewButton.MouseButton1Down:Connect(function()
		UI.ButtonsMenu.SelectMaterial.Text = new
		UI.ButtonsMenu.MaterialsPicker.Visible = false
	end)
end

UI.ButtonsMenu.SelectMaterial.MouseButton1Down:Connect(function()
	UI.ButtonsMenu.MaterialsPicker.Visible = not UI.ButtonsMenu.MaterialsPicker.Visible
end)
UI.ButtonsMenu.MaterialConfirm.MouseButton1Down:Connect(function()
	if InitMod ~= nil then
		InitMod:SelectMaterial(UI.ButtonsMenu.SelectMaterial.Text)
	end
end)

UI.ButtonsMenu.Confirm.MouseButton1Down:Connect(function()
	if InitMod ~= nil then
		InitMod:Select()
	end
end)

UI.ButtonsMenu.SelectParent.MouseButton1Down:Connect(function()
	if InitMod ~= nil then
		InitMod:SelectParent()
	end
end)

UI.ButtonsMenu.SearchConfirm.MouseButton1Down:Connect(function()
	if InitMod ~= nil then
		if UI.TextLabel.Text ~= nil then
			InitMod:SelectSearch(UI.TextLabel.Text)
		end
	end
end)

UI.ButtonsMenu.ColorConfirm.MouseButton1Down:Connect(function()
	if InitMod ~= nil then
		InitMod:SelectColor(UI.ColorLabel.Text)
	end
end)
