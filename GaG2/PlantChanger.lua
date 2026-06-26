local COLORS = {
    Background = Color3.fromRGB(13, 13, 18),
    Secondary = Color3.fromRGB(35, 35, 48),
    Accent = Color3.fromRGB(124, 58, 237),
    AccentHover = Color3.fromRGB(147, 85, 255),
    Text = Color3.fromRGB(255, 255, 255),
    SubText = Color3.fromRGB(170, 170, 170),
    Stroke = Color3.fromRGB(90, 90, 120)
}

local R = game:GetService("ReplicatedStorage")
local WeightFormat = require(R.SharedModules.WeightFormat)
local orig = WeightFormat.FormatGrams
local scaledNames = {}

WeightFormat.FormatGrams = function(p1)
    local n = tonumber(p1) or 0
    local tooltip = game:GetService("Players").LocalPlayer.PlayerGui:FindFirstChild("PlantHoverTooltip")
    if tooltip then
        local frame = tooltip:FindFirstChild("Frame")
        if frame then
            local nameLabel = frame:FindFirstChild("Name")
            if nameLabel and scaledNames[nameLabel.Text] then
                return orig(n * scaledNames[nameLabel.Text])
            end
        end
    end
    return orig(n)
end

local P = game:GetService("Players").LocalPlayer
local plotId = P:GetAttribute("PlotId")

local TweenService = game:GetService("TweenService")

local gui = Instance.new("ScreenGui")
gui.Parent = P.PlayerGui

local main = Instance.new("Frame")
main.Size = UDim2.new(0, 260, 0, 340)
main.Position = UDim2.new(0.5, -130, 0.5, -170)
main.BackgroundColor3 = COLORS.Background
main.BorderSizePixel = 0
main.ZIndex = 2
main.Parent = gui

local stroke = Instance.new("UIStroke")
stroke.Color = COLORS.Stroke
stroke.Thickness = 1.5
stroke.Transparency = .2
stroke.Parent = main

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 14)
corner.Parent = main

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 35)
title.BackgroundTransparency = 1
title.TextColor3 = COLORS.Text
title.Text = "⚡ VEXO PLANT SIZER"
title.Font = Enum.Font.GothamBold
title.TextSize = 17
title.ZIndex = 3
title.Parent = main

local accent = Instance.new("Frame")
accent.Size = UDim2.new(1, 0, 0, 2)
accent.Position = UDim2.new(0, 0, 1, -2)
accent.BackgroundColor3 = COLORS.Accent
accent.BorderSizePixel = 0
accent.ZIndex = 3
accent.Parent = title

local scroll = Instance.new("ScrollingFrame")
scroll.Size = UDim2.new(1, -10, 1, -45)
scroll.Position = UDim2.new(0, 5, 0, 40)
scroll.BackgroundTransparency = 1
scroll.BorderSizePixel = 0
scroll.ScrollBarThickness = 4
scroll.ScrollBarImageColor3 = COLORS.Accent
scroll.ZIndex = 3
scroll.Parent = main

local layout = Instance.new("UIListLayout")
layout.Padding = UDim.new(0, 8)
layout.Parent = scroll

local padding = Instance.new("UIPadding")
padding.PaddingTop = UDim.new(0, 8)
padding.PaddingBottom = UDim.new(0, 8)
padding.PaddingLeft = UDim.new(0, 8)
padding.PaddingRight = UDim.new(0, 8)
padding.Parent = scroll

local dragging, dragStart, startPos
title.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = main.Position
    end
end)
game:GetService("UserInputService").InputChanged:Connect(function(input)
    if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
        local delta = input.Position - dragStart
        main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)
game:GetService("UserInputService").InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
end)

local function scaleParts(model)
    local fruits = model:FindFirstChild("Fruits")
    local target = fruits or model
    for _, part in pairs(target:GetDescendants()) do
        if part:IsA("BasePart") then
            part.Size = part.Size * 5
        end
    end
end

local seen = {}
local groups = {}
local count = 0

for _, plant in ipairs(workspace.Gardens["Plot" .. plotId].Plants:GetChildren()) do
    local name = plant:GetAttribute("SeedName")
    if name then
        if not seen[name] then
            seen[name] = true
            groups[name] = {}
            count = count + 1

            local btn = Instance.new("TextButton")
            btn.Size = UDim2.new(1, -10, 0, 35)
            btn.BackgroundColor3 = COLORS.Secondary
            btn.TextColor3 = COLORS.Text
            btn.Text = name
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 16
    btn.TextColor3 = Color3.new(1,1,1)
            btn.BorderSizePixel = 0
            btn.ZIndex = 4
            btn.Parent = scroll

            local btnCorner = Instance.new("UICorner")
            btnCorner.CornerRadius = UDim.new(0, 10)
            btnCorner.Parent = btn

            local btnStroke = Instance.new("UIStroke")
            btnStroke.Color = COLORS.Stroke
            btnStroke.Thickness = 1.2
            btnStroke.Parent = btn

            local grad = Instance.new("UIGradient")
grad.Color = ColorSequence.new{
    ColorSequenceKeypoint.new(0, Color3.fromRGB(85, 85, 110)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(55, 55, 75))
}
            grad.Rotation = 90
            grad.Parent = btn

            btn.MouseEnter:Connect(function()
                TweenService:Create(btn, TweenInfo.new(.15), {
                    BackgroundColor3 = COLORS.Accent
                }):Play()
            end)
            btn.MouseLeave:Connect(function()
                TweenService:Create(btn, TweenInfo.new(.15), {
                    BackgroundColor3 = COLORS.Secondary
                }):Play()
            end)

            btn.MouseButton1Down:Connect(function()
                TweenService:Create(btn, TweenInfo.new(.08), {
                    Size = UDim2.new(1, -14, 0, 32)
                }):Play()
            end)
            btn.MouseButton1Up:Connect(function()
                TweenService:Create(btn, TweenInfo.new(.08), {
                    Size = UDim2.new(1, -10, 0, 35)
                }):Play()
            end)

            btn.MouseButton1Click:Connect(function()
                for _, p in pairs(groups[name]) do
                    scaleParts(p)
                end
                scaledNames[name] = (scaledNames[name] or 1) * 5
            end)
        end
        table.insert(groups[name], plant)
    end
end

scroll.CanvasSize = UDim2.new(0, 0, 0, count * 43)

local function getBaseWeight(toolName)
    local weightStr = toolName:match("%[(.-)kg%]")
    return tonumber(weightStr)
end

local function updateTool(tool)
    if tool:GetAttribute("Fruit") == nil then return end
    local seedName = tool:GetAttribute("SeedName") or tool.Name:match("^(.-)%s*%[")
    local multi = (seedName and scaledNames[seedName]) or 1
    local base = getBaseWeight(tool.Name)
    if not base then return end
    local newWeight = base * multi
    tool:SetAttribute("Weight", newWeight)
    tool.Name = tool.Name:gsub("%[.-%]", "[" .. string.format("%.2f", newWeight) .. "kg]")
end

P.Backpack.ChildAdded:Connect(function(tool)
    if tool:IsA("Tool") then
        updateTool(tool)
    end
end)

for _, tool in pairs(P.Backpack:GetChildren()) do
    if tool:IsA("Tool") then
        updateTool(tool)
    end
end

local scaledVisuals = {}

local function tryScaleVisual(model)
    if scaledVisuals[model] then return end
    local owner = model:GetAttribute("Owner")
    if not owner or owner ~= P.UserId then return end
    task.spawn(function()
        local deadline = os.clock() + 5
        while os.clock() < deadline do
            local parts = model:GetDescendants()
            local hasParts = false
            for _, d in pairs(parts) do
                if d:IsA("BasePart") then hasParts = true break end
            end
            if hasParts then break end
            task.wait(0.1)
        end
        if scaledVisuals[model] then return end
        local plantModel = model:FindFirstChildWhichIsA("Model")
        if not plantModel then return end
        local seedName = plantModel:GetAttribute("SeedName")
        if not seedName then return end
        local multi = scaledNames[seedName] or 1
        if multi == 1 then return end
        scaledVisuals[model] = true
        for _, part in pairs(model:GetDescendants()) do
            if part:IsA("BasePart") then
                part.Size = part.Size * multi
            end
        end
    end)
end

local pottedVisuals = workspace:WaitForChild("PottedPlantVisuals", 10)
if pottedVisuals then
    for _, model in pairs(pottedVisuals:GetChildren()) do
        tryScaleVisual(model)
    end
    pottedVisuals.ChildAdded:Connect(function(model)
        tryScaleVisual(model)
    end)
end
