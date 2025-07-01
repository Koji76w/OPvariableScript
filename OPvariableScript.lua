local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local player = Players.LocalPlayer

-- GUI Setup
local screenGui = Instance.new("ScreenGui", player:WaitForChild("PlayerGui"))
screenGui.Name = "PropertyEditorGUI"
screenGui.ResetOnSpawn = false

local frame = Instance.new("Frame", screenGui)
frame.Size = UDim2.new(0, 600, 0, 170)
frame.Position = UDim2.new(0, 20, 0, 20)
frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
frame.BorderSizePixel = 10
frame.BorderColor3 = Color3.fromRGB(30, 30, 30)
frame.Active = true

-- Title
local title = Instance.new("TextLabel", frame)
title.Size = UDim2.new(1, -40, 0, 20)
title.Position = UDim2.new(0, 10, 0, 0)
title.Text = "Variable Editor"
title.TextColor3 = Color3.new(1, 1, 1)
title.BackgroundTransparency = 1
title.Font = Enum.Font.SourceSansBold
title.TextXAlignment = Enum.TextXAlignment.Left
title.TextSize = 18

-- Toggle Button
local toggleButton = Instance.new("TextButton", frame)
toggleButton.Size = UDim2.new(0, 30, 0, 20)
toggleButton.Position = UDim2.new(1, -35, 0, 0)
toggleButton.Text = "−"
toggleButton.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
toggleButton.TextColor3 = Color3.new(1, 1, 1)
toggleButton.Font = Enum.Font.SourceSansBold
toggleButton.TextSize = 18

-- Dropdown
local dropdown = Instance.new("TextButton", frame)
dropdown.Size = UDim2.new(0, 200, 0, 30)
dropdown.Position = UDim2.new(0, 10, 0, 30)
dropdown.Text = "Select Property"
dropdown.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
dropdown.TextColor3 = Color3.new(1, 1, 1)
dropdown.TextXAlignment = Enum.TextXAlignment.Left
dropdown.ClipsDescendants = true
dropdown.ZIndex = 1

-- Input Box
local inputBox = Instance.new("TextBox", frame)
inputBox.Size = UDim2.new(0, 150, 0, 30)
inputBox.Position = UDim2.new(0, 220, 0, 30)
inputBox.PlaceholderText = "Enter new value"
inputBox.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
inputBox.TextColor3 = Color3.new(1, 1, 1)

-- Apply Button
local applyButton = Instance.new("TextButton", frame)
applyButton.Size = UDim2.new(0, 150, 0, 30)
applyButton.Position = UDim2.new(0, 380, 0, 30)
applyButton.Text = "Apply Change"
applyButton.BackgroundColor3 = Color3.fromRGB(70, 130, 180)
applyButton.TextColor3 = Color3.new(1, 1, 1)

-- Value Preview
local valuePreview = Instance.new("TextLabel", frame)
valuePreview.Size = UDim2.new(0, 580, 0, 20)
valuePreview.Position = UDim2.new(0, 10, 0, 65)
valuePreview.BackgroundTransparency = 1
valuePreview.TextColor3 = Color3.fromRGB(200, 200, 200)
valuePreview.TextXAlignment = Enum.TextXAlignment.Left
valuePreview.Font = Enum.Font.SourceSans
valuePreview.TextSize = 16
valuePreview.Text = ""

-- Search Box
local searchBox = Instance.new("TextBox", frame)
searchBox.Size = UDim2.new(0, 150, 0, 30)
searchBox.Position = UDim2.new(0, 10, 0, 100)
searchBox.PlaceholderText = "Search value (e.g. 16)"
searchBox.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
searchBox.TextColor3 = Color3.new(1, 1, 1)

-- Search Button
local searchButton = Instance.new("TextButton", frame)
searchButton.Size = UDim2.new(0, 150, 0, 30)
searchButton.Position = UDim2.new(0, 170, 0, 100)
searchButton.Text = "Search"
searchButton.BackgroundColor3 = Color3.fromRGB(70, 130, 180)
searchButton.TextColor3 = Color3.new(1, 1, 1)

-- Editable Properties
local editableProps = {}

local function addEditable(object, property)
	table.insert(editableProps, {
		name = object:GetFullName() .. "." .. property,
		object = object,
		property = property
	})
end

-- Deep Scan Function
local function deepScan(container)
	for _, obj in ipairs(container:GetDescendants()) do
		if obj:IsA("NumberValue") or obj:IsA("IntValue") then
			addEditable(obj, "Value")
		elseif obj:IsA("Humanoid") then
			local humanoidProps = {
				"WalkSpeed", "JumpPower", "Health", "MaxHealth",
				"BodyDepthScale", "BodyHeightScale", "BodyWidthScale",
				"HeadScale", "BodyTypeScale"
			}
			for _, prop in ipairs(humanoidProps) do
				if obj[prop] then
					addEditable(obj, prop)
				end
			end
		end
	end
end

-- Scan Services
local containers = {
	game.Workspace, game.ReplicatedStorage, game.StarterGui,
	game.StarterPack, game.StarterPlayer, game.Lighting,
	game.Players, game:GetService("ReplicatedFirst"), game:GetService("SoundService")
}
for _, container in ipairs(containers) do
	pcall(function() deepScan(container) end)
end
for _, plr in ipairs(Players:GetPlayers()) do
	pcall(function() deepScan(plr) end)
end

-- Dropdown Logic
local selected = nil
local dropdownOpen = false

local function closeDropdown()
	local menu = frame:FindFirstChild("DropdownMenu")
	if menu then
		menu:Destroy()
	end
	dropdownOpen = false
end

local function openDropdown(filteredList)
	closeDropdown()
	dropdownOpen = true

	local menu = Instance.new("ScrollingFrame", frame)
	menu.Name = "DropdownMenu"
	menu.Size = UDim2.new(0, 580, 0, 120)
	menu.Position = UDim2.new(0, 10, 0, 135)
	menu.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
	menu.CanvasSize = UDim2.new(0, 0, 0, #filteredList * 25)
	menu.ScrollBarThickness = 6
	menu.ZIndex = 2

	for i, entry in ipairs(filteredList) do
		local option = Instance.new("TextButton", menu)
		option.Size = UDim2.new(1, 0, 0, 25)
		option.Position = UDim2.new(0, 0, 0, (i - 1) * 25)
		option.Text = entry.name
		option.TextXAlignment = Enum.TextXAlignment.Left
		option.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
		option.TextColor3 = Color3.new(1, 1, 1)
		option.ZIndex = 3

		option.MouseButton1Click:Connect(function()
			selected = entry
			closeDropdown()
			dropdown.Text = entry.name
			valuePreview.Text = "Current Value: " .. tostring(entry.object[entry.property])
		end)
	end
end

dropdown.MouseButton1Click:Connect(function()
	openDropdown(editableProps)
end)

searchButton.MouseButton1Click:Connect(function()
	local searchValue = tonumber(searchBox.Text)
	if searchValue then
		local results = {}
		for _, entry in ipairs(editableProps) do
			if tonumber(entry.object[entry.property]) == searchValue then
				table.insert(results, entry)
			end
		end
		openDropdown(results)
	else
		valuePreview.Text = "❌ Invalid search input"
	end
end)

-- Apply Changes
applyButton.MouseButton1Click:Connect(function()
	if selected and inputBox.Text ~= "" then
		local newValue = tonumber(inputBox.Text)
		if newValue then
			selected.object[selected.property] = newValue
			valuePreview.Text = "Current Value: " .. tostring(newValue)
			inputBox.Text = ""
		else
			valuePreview.Text = "❌ Invalid number input"
		end
	end
end)

-- Collapse / Expand
local minimized = false
local anchorPosition = frame.Position
local originalSize = frame.Size
local minimizedSize = UDim2.new(0, 180, 0, 30)

local function updateFrame()
	if minimized then
		frame.Size = minimizedSize
		frame.Position = UDim2.new(anchorPosition.X.Scale, anchorPosition.X.Offset + (originalSize.X.Offset - minimizedSize.X.Offset), anchorPosition.Y.Scale, anchorPosition.Y.Offset)
		for _, v in pairs(frame:GetChildren()) do
			if v ~= title and v ~= toggleButton then
				v.Visible = false
			end
		end
		toggleButton.Text = "+"
	else
		frame.Size = originalSize
		frame.Position = anchorPosition
		for _, v in pairs(frame:GetChildren()) do
			v.Visible = true
		end
		toggleButton.Text = "−"
	end
end

toggleButton.MouseButton1Click:Connect(function()
	minimized = not minimized
	updateFrame()
end)

-- Dragging System
local dragging = false
frame.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		dragging = true
		input.Changed:Connect(function()
			if input.UserInputState == Enum.UserInputState.End then
				dragging = false
			end
		end)
	end
end)

UserInputService.InputChanged:Connect(function(input)
	if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
		local mousePos = UserInputService:GetMouseLocation()
		anchorPosition = minimized
			and UDim2.new(0, mousePos.X, 0, mousePos.Y)
			or UDim2.new(0, mousePos.X - frame.Size.X.Offset / 2, 0, mousePos.Y - 10)
		frame.Position = anchorPosition
	end
end)
