local toolbar = plugin:CreateToolbar("STUDIO TESTING")
local createPoints = toolbar:CreateButton("TEST","TEST", "rbxassetid://12885495090", "Bezier Pro")
local ChangeHistoryService = game:GetService("ChangeHistoryService")
local StudioService = game:GetService("StudioService")
local createHit = false
local loggedInUserId = StudioService:GetUserId()
local Player = game.Players:GetPlayerByUserId(loggedInUserId)
local mouse = Player:GetMouse()


-- // CREATE FOLDER // --

local folder

if game.ServerStorage:FindFirstChild("Bezier_Pro_Storage") then	
	folder = game.ServerStorage:FindFirstChild("Bezier_Pro_Storage")
else
	folder = Instance.new("Folder")
    folder.Parent = game.ServerStorage
	folder.Name = "Bezier_Pro_Storage"
end
local ViewportModel = require(script.ViewportFrameModule)

-- // CREATE WIDGET // --

local UI = plugin:CreateDockWidgetPluginGui(
	"TEST",
	DockWidgetPluginGuiInfo.new(
		Enum.InitialDockState.Float,  -- Widget will be initialized in floating panel
		false,   -- Widget will be initially enabled
		false,  -- Don't override the previous enabled state
		200,    -- Default width of the floating window
		300,    -- Default height of the floating window
		150,    -- Minimum width of the floating window (optional)
		150     -- Minimum height of the floating window (optional)
	))

UI.Title = "Bezier Pro"
local GUI = script.Parent.Frame:Clone()
GUI.Parent = UI

local nodestable = {}
local Lines = {}
local highlightedparts = {}
local nodehighlight = {}
local active

local count = 0
local open = false

local grid = false
local gridmodel = nil

createPoints.Click:Connect(function()
	UI.Enabled = not UI.Enabled
	if UI.Enabled == false then
		if gridmodel then
			gridmodel:Destroy()
			grid  = false
			GUI.Grid.Text = "Show Grid"
		end
		if game.Workspace:FindFirstChild("BezierProGrid") then
			game.Workspace:FindFirstChild("BezierProGrid"):Destroy()
			grid = false
			gridmodel = nil
			GUI.Grid.Text = "Show Grid"
		end
		if active then
			if active:IsA("BasePart") then
				active:Destroy()
				open = false
				GUI.CreateRoad.Text = "Create Curve"
			end
		end
		plugin:Deactivate()
	end
end)

-- // VARS // --

local Bezier=require(script.Parent.Bezier)
local part

local ViewportCamera = Instance.new("Camera")
ViewportCamera.Parent =  GUI.ViewportFrame
GUI.ViewportFrame.CurrentCamera = ViewportCamera
local viewportCf

-- // SCROLLFRAME BUTTONS // --
function scrollframe()
	for _,parts in pairs(GUI.ScrollFrame:GetChildren()) do
		if parts:IsA("TextButton") then
			parts:Destroy()
		end
	end
	for _,v in pairs(game.ServerStorage:WaitForChild("Bezier_Pro_Storage"):GetChildren()) do
		local temp = GUI.Template:Clone()
		temp.Parent = GUI.ScrollFrame
		temp.Text = v.Name
		temp.Name = v.Name
		temp.Visible = true
		temp.MouseButton1Click:Connect(function()
			part = game.ServerStorage:WaitForChild("Bezier_Pro_Storage"):WaitForChild(v.Name)

			local vpfModel = ViewportModel.new(GUI.ViewportFrame, ViewportCamera)
			local cf, _ 
			local partClone = part:Clone()
			if partClone:IsA("Model") then
				cf,_ = partClone:GetBoundingBox()
				partClone.Parent = GUI.ViewportFrame
			end



			vpfModel:SetModel(partClone)

			local theta = 0
			local distance = vpfModel:GetFitDistance(cf.Position)


			viewportCf = {cf, distance, theta}


			for _,parts in pairs(GUI.ScrollFrame:GetChildren()) do

				if parts:IsA("TextButton") then
					if parts.Name ~= v.Name then
						parts.TextColor3 = Color3.fromRGB(255, 255, 255)
						parts.BackgroundColor3 = Color3.fromRGB(34, 34, 34)
					else

						parts.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
						parts.TextColor3 = Color3.fromRGB(34, 34, 34)
					end
				end
			end
		end)
	end
end

scrollframe()

GUI.Refresh.MouseButton1Click:Connect(function()
	scrollframe()
end)





-- // GRID UPDATE // --

GUI.Grid.MouseButton1Click:Connect(function()
	if grid == false then
		grid = true
		local gridm = script.Parent.GRID:Clone()
		gridm.Parent = game.Workspace
		gridm.Name = "GRID"
		gridmodel = gridm
		GUI.Grid.Text = "Disable Grid"
	else
		gridmodel:Destroy()
		gridmodel = nil
		grid = false
		GUI.Grid.Text = "Show Grid"
	end	
end)

local theta = 0

game:GetService("RunService").Heartbeat:Connect(function(dt)
	if gridmodel ~= nil then
		--gridmodel:PivotTo(game.Workspace.CurrentCamera.CFrame)
		if tonumber(GUI.GridHeight.Text) ~= nil then
			gridmodel.CFrame = CFrame.new(Vector3.new(game.Workspace.CurrentCamera.CFrame.Position.X,game.Workspace.CurrentCamera.CFrame.Position.Y - tonumber(GUI.GridHeight.Text),game.Workspace.CurrentCamera.CFrame.Position.Z)) + Vector3.new(0, 0, 0)
		end
	end

	if viewportCf ~= nil then

		theta = theta + math.rad(20 * dt)	

		local orientation = CFrame.fromEulerAnglesYXZ(math.rad(-20), theta, 0)

		GUI.ViewportFrame.CurrentCamera.CFrame = CFrame.new(viewportCf[1].Position) * orientation * CFrame.new(0, 0, viewportCf[2])

	end
end)
-- // TEXT HOVER // -- 

for _,v in pairs(GUI:GetChildren()) do
	if v:IsA("TextButton") then
		v.MouseEnter:Connect(function()
			local tweeninf1 = TweenInfo.new(.2)
			local tween1 = game:GetService("TweenService"):Create(v, tweeninf1, {BackgroundColor3 = Color3.fromRGB(255, 255, 255),TextColor3 = Color3.fromRGB(34, 34, 34)})
			tween1:Play()
		end)
		v.MouseLeave:Connect(function()
			local tweeninf1 = TweenInfo.new(.2)
			local tween1 = game:GetService("TweenService"):Create(v, tweeninf1, {BackgroundColor3 = Color3.fromRGB(34, 34, 34),TextColor3 = Color3.fromRGB(255, 255, 255)})
			tween1:Play()
		end)
	end
end





-- // UNLOCK NODES // --

GUI.NodeUnlock.MouseButton1Click:Connect(function()
	for _,v in pairs(game.Workspace:FindFirstChild("Nodes"):GetChildren()) do
		v.Locked = false
	end
end)

-- // CREATE CURVE // --

local nodes

if game.Workspace:FindFirstChild("Nodes") ~= nil then
	nodes = game.Workspace:FindFirstChild("Nodes")
else
	nodes = Instance.new("Folder")
    nodes.Parent = game.Workspace
	nodes.Name = "Nodes"
end

-- // CREATE NODE // --

function CreatePart()
	count = count + 1
	local node = Instance.new("Part")
    node.Parent = nodes
	node.Shape = "Ball"
	node.Locked = true
	node.Color = Color3.fromRGB(97, 213, 255)
	node.Size = Vector3.new(2.5,2.5,2.5)
	local highlight = Instance.new("Highlight")
    highlight.Parent = node
	highlight.DepthMode = Enum.HighlightDepthMode.Occluded
	highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
	highlight.FillTransparency = 1
	node.Material = Enum.Material.SmoothPlastic
	node.Anchored = true
	node.CanCollide = false
	node.Parent = nodes
	node.Name = "Node"..count
	active = node
end


-- // PLACE NODE // --

function CreateNode()
	print(mouse.Target.Parent.Name)
	if mouse.Target.Parent.Name ~= "Nodes" then
		count = count + 1
		local clone = active:Clone()
		clone.Parent = nodes
		clone.Name = "Node"..count
		mouse.TargetFilter = clone
		clone.CFrame = CFrame.new(mouse.Hit.Position) + Vector3.new(0, 0, 0) 
		table.insert(nodestable,clone)
		table.insert(nodehighlight,clone.Highlight)
		ChangeHistoryService:SetWaypoint("Created node.")
	else
		count = count + 1
		local clone = mouse.Target
		clone.Parent = nodes
		clone.Name = "Node"..count
		mouse.TargetFilter = clone
		clone.CFrame = CFrame.new(mouse.Hit.Position) + Vector3.new(0, 0, 0) 
		table.insert(nodestable,clone)
		if clone:FindFirstChildOfClass("Highlight") then
			table.insert(nodehighlight,clone.Highlight)
		end
		ChangeHistoryService:SetWaypoint("Created node.")
	end
end


-- // BUTTON // --


GUI.CreateRoad.MouseButton1Click:Connect(function()
	if part ~= nil then
		if open == false then
			open = true
			CreatePart()
			createHit = false
			GUI.CreateRoad.Text = "Stop Curve"
		else
			open = false
			active:Destroy()
			GUI.CreateRoad.Text = "Create Curve"
		end
	else
		GUI.ErrorFrame.Visible = true
		task.wait(3)
		GUI.ErrorFrame.Visible = false
	end
end)

mouse.Move:Connect(function()
	if active ~= nil then
		mouse.TargetFilter = active
		if mouse.Target ~= nil then
			if mouse.Target.Parent.Name ~= "Nodes" then 
				active.CFrame = CFrame.new(mouse.Hit.Position) + Vector3.new(0, 0, 0) 
				active.Color = Color3.fromRGB(97, 213, 255)
			else
				active.CFrame = CFrame.new(mouse.Target.Position) + Vector3.new(0,0,0)
				active.Color = Color3.fromRGB(44, 255, 11)
			end 
		end
	end
end)
local roadModel:Model = nil

mouse.Button1Down:Connect(function()
	if open == true then
		CreateNode()
	end
end)

function myCoroutine()
	while task.wait(1) do
		if createHit == false then
			if count >= 3  then
				local NewBezier = Bezier.new(unpack(nodestable))

				local newmodel = Instance.new("Model")
                newmodel.Parent = game.Workspace
				roadModel = newmodel
				local view = Instance.new("Highlight")
                view.Parent = newmodel

				view.DepthMode = Enum.HighlightDepthMode.Occluded
				highlightedparts = {}
				Lines = {}
				table.insert(highlightedparts, view)
				view.FillTransparency = 1
				view.OutlineColor = Color3.fromRGB(255, 255, 255)
				local numPoints = tonumber(GUI.Amount.Text) or 0

				for _ = 1, numPoints do
					local TargetPart = part:Clone()
					TargetPart.Parent = newmodel
					table.insert(Lines, TargetPart)
				end

				for i = 1, #Lines - 1 do
					local t = (i - 1) / (#Lines - 1)
					local position = NewBezier:CalculatePositionAt(t)
					local derivative = NewBezier:CalculateDerivativeAt(t)
					local lookVector = derivative.Unit
					local endPosition = position + lookVector
					Lines[i]:PivotTo(CFrame.lookAt(position, endPosition))
				end
				roadModel:ClearAllChildren()
			end
        else
            return
		end
	end
end


local co = coroutine.create(myCoroutine)
coroutine.resume(co)


-- // CONFIRM CREATE // -- 

GUI.Create.MouseButton1Click:Connect(function()
	if part ~= nil then
		createHit = true
		local tweens

		for _,v in pairs(highlightedparts) do
			local TweenService = game:GetService("TweenService")
			local Tween = TweenService:Create(v,TweenInfo.new(0.5,Enum.EasingStyle.Linear),{OutlineColor = Color3.fromRGB(75, 198, 68)}) --Create Color Tween
			Tween:Play()
			tweens = Tween
		end

		tweens.Completed:Wait()

		for _,destroy in pairs(highlightedparts) do
			destroy:Destroy()
		end
		for _,destroy in pairs(nodehighlight) do
			destroy:Destroy()
		end
		count = 1
		nodestable = {}
		roadModel = {}
		Lines = {}

		if active then
			if active:IsA("BasePart") then
				active:Destroy()
				open = false
				GUI.CreateRoad.Text = "Create Curve"
			end
		end
		ChangeHistoryService:SetWaypoint("Created road.")
	else
		GUI.ErrorFrame.Visible = true
		task.wait(3)
		GUI.ErrorFrame.Visible = false
	end
end)
