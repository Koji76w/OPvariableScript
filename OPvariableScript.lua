local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local player = Players.LocalPlayer

-- GUI Setup
local screenGui = Instance.new("ScreenGui", player:WaitForChild("PlayerGui"))
screenGui.Name = "VariableEditorModern"
screenGui.ResetOnSpawn = false
screenGui.IgnoreGuiInset = true

local frame = Instance.new("Frame", screenGui)
frame.Size = UDim2.new(0, 600, 0, 100)
frame.Position = UDim2.new(0, 40, 0, 40)
frame.BackgroundColor3 = Color3.fromRGB(245, 245, 245)
frame.BorderSizePixel = 0
frame.Active = true
frame.Draggable = false
frame.ClipsDescendants = true
frame.ZIndex = 2

-- Rounded corners and shadow
Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 8)

local shadow = Instance.new("ImageLabel", frame)
shadow.AnchorPoint = Vector2.new(0.5, 0.5)
shadow.Position = UDim2.new(0.5, 0, 0.5, 4)
shadow.Size = UDim2.new(1, 12, 1, 12)
shadow.BackgroundTransparency = 1
shadow.Image = "rbxassetid://1316045217"
shadow.ImageTransparency = 0.6
shadow.ScaleType = Enum.ScaleType.Slice
shadow.SliceCenter = Rect.new(10, 10, 118, 118)
shadow.ZIndex = 1

-- Title
local title = Instance.new("TextLabel", frame)
title.Size = UDim2.new(1, -40, 0, 30)
title.Position = UDim2.new(0, 10, 0, 0)
title.Text = "Variable Editor"
title.TextColor3 = Color3.fromRGB(30, 30, 30)
title.BackgroundTransparency = 1
title.Font = Enum.Font.GothamBold
title.TextXAlignment = Enum.TextXAlignment.Left
title.TextSize = 20

-- Toggle Button
local toggleButton = Instance.new("TextButton", frame)
toggleButton.Size = UDim2.new(0, 30, 0, 30)
toggleButton.Position = UDim2.new(1, -35, 0, 0)
toggleButton.Text = "−"
toggleButton.BackgroundColor3 = Color3.fromRGB(230, 230, 230)
toggleButton.TextColor3 = Color3.fromRGB(60, 60, 60)
toggleButton.Font = Enum.Font.GothamBold
toggleButton.TextSize = 20
Instance.new("UICorner", toggleButton).CornerRadius = UDim.new(0, 6)

-- Search Bar
local searchBox = Instance.new("TextBox", frame)
searchBox.Size = UDim2.new(0, 180, 0, 30)
searchBox.Position = UDim2.new(0, 10, 0, 40)
searchBox.PlaceholderText = "Search variable..."
searchBox.BackgroundColor3 = Color3.fromRGB(240, 240, 240)
searchBox.TextColor3 = Color3.fromRGB(30, 30, 30)
searchBox.Font = Enum.Font.Gotham
searchBox.TextSize = 14
Instance.new("UICorner", searchBox).CornerRadius = UDim.new(0, 6)

-- Dropdown
local dropdown = Instance.new("TextButton", frame)
dropdown.Size = UDim2.new(0, 200, 0, 30)
dropdown.Position = UDim2.new(0, 200, 0, 40)
dropdown.Text = "Select Variable"
dropdown.BackgroundColor3 = Color3.fromRGB(240, 240, 240)
dropdown.TextColor3 = Color3.fromRGB(30, 30, 30)
dropdown.Font = Enum.Font.Gotham
dropdown.TextSize = 14
Instance.new("UICorner", dropdown).CornerRadius = UDim.new(0, 6)

-- Input Box
local inputBox = Instance.new("TextBox", frame)
inputBox.Size = UDim2.new(0, 120, 0, 30)
inputBox.Position = UDim2.new(0, 410, 0, 40)
inputBox.PlaceholderText = "Enter value"
inputBox.BackgroundColor3 = Color3.fromRGB(240, 240, 240)
inputBox.TextColor3 = Color3.fromRGB(30, 30, 30)
inputBox.Font = Enum.Font.Gotham
inputBox.TextSize = 14
Instance.new("UICorner", inputBox).CornerRadius = UDim.new(0, 6)

-- Apply Button
local applyButton = Instance.new("TextButton", frame)
applyButton.Size = UDim2.new(0, 120, 0, 30)
applyButton.Position = UDim2.new(0, 540, 0, 40)
applyButton.Text = "Apply"
applyButton.BackgroundColor3 = Color3.fromRGB(100, 180, 255)
applyButton.TextColor3 = Color3.new(1, 1, 1)
applyButton.Font = Enum.Font.GothamBold
applyButton.TextSize = 14
Instance.new("UICorner", applyButton).CornerRadius = UDim.new(0, 6)

-- Editable Properties
local editableProps = {}

local function scanForEditableProps(obj)
    for _, child in ipairs(obj:GetChildren()) do
        if child:IsA("NumberValue") or child:IsA("IntValue") then
            table.insert(editableProps, {
                name = child:GetFullName() .. ".Value",
                object = child,
                property = "Value"
            })
        end
        if child:IsA("Humanoid") then
            for _, prop in ipairs({"WalkSpeed", "JumpPower", "Health", "MaxHealth"}) do
                if child[prop] ~= nil then
                    table.insert(editableProps, {
                        name = child:GetFullName() .. "." .. prop,
                        object = child,
                        property = prop
                    })
                end
            end
        end
        scanForEditableProps(child)
    end
end

scanForEditableProps(workspace)

-- Dropdown Logic
local selected = nil
dropdown.MouseButton1Click:Connect(function()
    local menu = Instance.new("ScrollingFrame", frame)
    menu.Size = UDim2.new(0, 580, 0, 100)
    menu.Position = UDim2.new(0, 10, 0, 80)
    menu.BackgroundColor3 = Color3.fromRGB(250, 250, 250)
    menu.CanvasSize = UDim2.new(0, 0, 0, #editableProps * 25)
    menu.ScrollBarThickness = 6
    menu.ZIndex = 3
    Instance.new("UICorner", menu).CornerRadius = UDim.new(0, 6)

    for i, entry in ipairs(editableProps) do
        if searchBox.Text == "" or string.find(string.lower(entry.name), string.lower(searchBox.Text)) then
            local option = Instance.new("TextButton", menu)
            option.Size = UDim2.new(1, 0, 0, 25)
            option.Position = UDim2.new(0, 0, 0, (i - 1) * 25)
            option.Text = entry.name
            option.TextXAlignment = Enum.TextXAlignment.Left
            option.BackgroundColor3 = Color3.fromRGB(235, 235, 235)
            option.TextColor3 = Color3.fromRGB(30, 30, 30)
            option.Font = Enum.Font.Gotham
            option.TextSize = 13
            Instance.new("UICorner", option).CornerRadius = UDim.new(0, 4)

            option.MouseButton1Click:Connect(function()
                selected = entry
                dropdown.Text = entry.name
                menu:Destroy()
            end)
        end
    end
end)

-- Apply Logic
applyButton.MouseButton1Click:Connect(function()
    if selected and inputBox.Text ~= "" then
        local newValue = tonumber(inputBox.Text)
        if newValue then
            selected.object[selected.property] = newValue
            print("Changed", selected.name, "to", newValue)
        else
            warn("Invalid number input")
        end
    end
end)

-- Minimize/Expand with Tween
local minimized = false
local anchorPosition = frame.Position
local originalSize = frame.Size
local minimizedSize = UDim2.new(0, 180, 0, 30)

local function updateFrame(animated)
    local goalSize = minimized and minimizedSize or originalSize
    local goalPos = minimized
        and UDim2.new(anchorPosition.X.Scale, anchorPosition.X.Offset + (originalSize.X.Offset - minimizedSize.X.Offset), anchorPosition.Y.Scale, anchorPosition.Y.Offset)
        or anchorPosition

    if animated then
                TweenService:Create(frame, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            Size = goalSize,
            Position = goalPos
        }):Play()
    else
        frame.Size = goalSize
        frame.Position = goalPos
    end

    local visible = not minimized
    searchBox.Visible = visible
    dropdown.Visible = visible
    inputBox.Visible = visible
    applyButton.Visible = visible
    toggleButton.Text = minimized and "+" or "−"
end

toggleButton.MouseButton1Click:Connect(function()
    minimized = not minimized
    updateFrame(true)
end)
