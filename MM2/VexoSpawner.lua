local players = game:GetService("Players")
local tweenz = game:GetService("TweenService")
local rs = game:GetService("ReplicatedStorage")
local runstuff = game:GetService("RunService")
local uis = game:GetService("UserInputService")
local coregui = game:GetService("CoreGui")

local me = players.LocalPlayer
local mygui = me:WaitForChild("PlayerGui")

local itemdb = require(rs:WaitForChild("Database"):WaitForChild("Sync"):WaitForChild("Item"))
local pdata = require(rs:WaitForChild("Modules"):WaitForChild("ProfileData"))
local giftevent = rs:WaitForChild("ItemGift")

-- the three things that actually update the inventory visually
local invremote = rs:WaitForChild("Remotes"):WaitForChild("Inventory")
local invchanged = invremote:WaitForChild("InventoryDataChanged")
local profilechanged = invremote:WaitForChild("ProfileDataChanged")
local updateclient = rs:WaitForChild("UpdateDataClient")

local anims = true

local function giveitems(list)
    -- add each item to profiledata owned table then fire the events
    for _, key in ipairs(list) do
        -- stick it in owned
        if pdata.Weapons and pdata.Weapons.Owned then
            pdata.Weapons.Owned[key] = 1
        end

        -- fire inventory data changed exactly like the server does
        invchanged:Fire("Weapons", key, 1)

        -- fire updateclient with false + full pdata just like the real handler
        updateclient:Fire(false, pdata)

        if anims then
            firesignal(giftevent.OnClientEvent, key, "Weapons", 1)
        end
    end

    -- fire profilechanged once at the end so the gui refreshes
    profilechanged:Fire("Weapons", pdata.Weapons)

    -- auto click claim if anims on
    if anims then
        task.delay(0.05, function()
            for _, obj in mygui:GetDescendants() do
                if obj.Name == "Claim" and (obj:IsA("ImageButton") or obj:IsA("TextButton")) then
                    firesignal(obj.Activated)
                    break
                end
            end
        end)
    end
end

local old = coregui:FindFirstChild("mm2vaultgui")
if old then old:Destroy() end

local gui = Instance.new("ScreenGui")
gui.Name = "mm2vaultgui"
gui.IgnoreGuiInset = true
gui.ResetOnSpawn = false
gui.ZIndexBehavior = Enum.ZIndexBehavior.Global
gui.DisplayOrder = 999999
gui.Parent = coregui

local main = Instance.new("Frame")
main.Size = UDim2.new(0, 0, 0, 0)
main.Position = UDim2.new(0.5, -130, 0.5, -190)
main.BackgroundTransparency = 1
main.BorderSizePixel = 0
main.ZIndex = 10
main.Parent = gui

Instance.new("UICorner", main).CornerRadius = UDim.new(0, 18)

local grad = Instance.new("UIGradient")
grad.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(120, 220, 255)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(80, 0, 180)),
})
grad.Rotation = 135
grad.Parent = main

local outline = Instance.new("UIStroke")
outline.Color = Color3.fromRGB(170, 230, 255)
outline.Thickness = 1.5
outline.Transparency = 0.3
outline.Parent = main

local glass = Instance.new("Frame")
glass.Size = UDim2.new(1, -10, 1, -10)
glass.Position = UDim2.new(0, 5, 0, 5)
glass.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
glass.BackgroundTransparency = 0.92
glass.BorderSizePixel = 0
glass.ZIndex = 11
glass.Parent = main
Instance.new("UICorner", glass).CornerRadius = UDim.new(0, 14)

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 40)
title.Position = UDim2.new(0, 0, 0, 8)
title.BackgroundTransparency = 1
title.Text = "Vexo Spawner"
title.Font = Enum.Font.GothamBold
title.TextSize = 22
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.TextTransparency = 1
title.ZIndex = 12
title.Parent = main

local function makebtn(text, ypos, color, cb)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 220, 0, 34)
    btn.Position = UDim2.new(0.5, -110, 0, ypos)
    btn.BackgroundColor3 = color
    btn.Text = text
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 15
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.TextTransparency = 1
    btn.BorderSizePixel = 0
    btn.ZIndex = 12
    btn.AutoButtonColor = false
    btn.Parent = main
    btn.Active = true

    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 12)

    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(200, 240, 255)
    stroke.Transparency = 0.5
    stroke.Parent = btn

    btn.MouseEnter:Connect(function()
        tweenz:Create(btn, TweenInfo.new(0.15, Enum.EasingStyle.Quad), {
            Size = UDim2.new(0, 226, 0, 36)
        }):Play()
    end)
    btn.MouseLeave:Connect(function()
        tweenz:Create(btn, TweenInfo.new(0.15, Enum.EasingStyle.Quad), {
            Size = UDim2.new(0, 220, 0, 34)
        }):Play()
    end)
    btn.MouseButton1Click:Connect(function()
        if not btn.Active then return end
        local down = tweenz:Create(btn, TweenInfo.new(0.08, Enum.EasingStyle.Quad), {Size = UDim2.new(0, 210, 0, 30)})
        local up   = tweenz:Create(btn, TweenInfo.new(0.12, Enum.EasingStyle.Back),  {Size = UDim2.new(0, 220, 0, 34)})
        down:Play(); down.Completed:Wait(); up:Play()
        cb(btn)
    end)

    return btn
end

local y = 52

local btn1 = makebtn("⬡  Unlock Pearl", y, Color3.fromRGB(100, 30, 200), function()
    giveitems({"Pearl_K"})
end)
y = y + 42

local btn2 = makebtn("✦  Unlock PearlShine", y, Color3.fromRGB(15, 85, 185), function()
    giveitems({"Pearl_G"})
end)
y = y + 42

local btn3 = makebtn("★  Unlock All Godly", y, Color3.fromRGB(140, 85, 0), function(self)
    self.Active = false
    task.spawn(function()
        local list = {}
        for key, data in pairs(itemdb) do
            if type(data) == "table" and data.Rarity == "Godly" then
                table.insert(list, key)
            end
        end
        for i, key in ipairs(list) do
            self.Text = ("Collecting %d/%d"):format(i, #list)
            task.wait(0)
        end
        giveitems(list)
        self.Text = "★  Unlock All Godly"
        self.Active = true
    end)
end)
y = y + 42

local btn4 = makebtn("⚡  Unlock EVERYTHING", y, Color3.fromRGB(160, 20, 20), function(self)
    self.Active = false
    task.spawn(function()
        local list = {}
        for key, data in pairs(itemdb) do
            if type(data) == "table" then
                table.insert(list, key)
            end
        end
        for i, key in ipairs(list) do
            self.Text = ("Collecting %d/%d"):format(i, #list)
            task.wait(0)
        end
        giveitems(list)
        self.Text = "⚡  Unlock EVERYTHING"
        self.Active = true
    end)
end)
y = y + 42

local togglebtn = makebtn("Animation: ON", y, Color3.fromRGB(30, 160, 30), function(self)
    anims = not anims
    self.Text = anims and "Animation: ON" or "Animation: OFF"
    self.BackgroundColor3 = anims and Color3.fromRGB(30, 160, 30) or Color3.fromRGB(160, 30, 30)
end)
y = y + 42

local tbg = Instance.new("Frame")
tbg.Size = UDim2.new(0, 220, 0, 30)
tbg.Position = UDim2.new(0.5, -110, 0, y)
tbg.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
tbg.BackgroundTransparency = 0.85
tbg.BorderSizePixel = 0
tbg.ZIndex = 12
tbg.Parent = main
Instance.new("UICorner", tbg).CornerRadius = UDim.new(0, 10)

local tbstroke = Instance.new("UIStroke")
tbstroke.Color = Color3.fromRGB(200, 240, 255)
tbstroke.Transparency = 0.4
tbstroke.Parent = tbg

local tb = Instance.new("TextBox")
tb.Size = UDim2.new(1, -12, 1, 0)
tb.Position = UDim2.new(0, 6, 0, 0)
tb.BackgroundTransparency = 1
tb.Text = ""
tb.PlaceholderText = "item key e.g. Seer, Fang..."
tb.PlaceholderColor3 = Color3.fromRGB(160, 160, 200)
tb.TextColor3 = Color3.fromRGB(255, 255, 255)
tb.TextSize = 13
tb.Font = Enum.Font.Gotham
tb.TextXAlignment = Enum.TextXAlignment.Left
tb.ClearTextOnFocus = false
tb.ZIndex = 13
tb.Parent = tbg

tb.Focused:Connect(function()
    tweenz:Create(tbstroke, TweenInfo.new(0.15), {Color = Color3.fromRGB(200, 130, 255), Transparency = 0}):Play()
end)
tb.FocusLost:Connect(function()
    tweenz:Create(tbstroke, TweenInfo.new(0.15), {Color = Color3.fromRGB(200, 240, 255), Transparency = 0.4}):Play()
end)

y = y + 38

local btnc = makebtn("Unlock Custom", y, Color3.fromRGB(25, 110, 70), function(self)
    local raw = tb.Text:match("^%s*(.-)%s*$")
    if raw == "" then return end
    task.spawn(function()
        local found = {}
        if itemdb[raw]       then table.insert(found, raw)       end
        if itemdb[raw.."_K"] then table.insert(found, raw.."_K") end
        if itemdb[raw.."_G"] then table.insert(found, raw.."_G") end
        local prev = self.Text
        if #found > 0 then
            giveitems(found)
            self.Text = "✔ Sent!"
        else
            self.Text = "✘ Not found"
        end
        task.delay(1.5, function() self.Text = prev end)
    end)
end)

local finalh = y + 44

tweenz:Create(main, TweenInfo.new(0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
    Size = UDim2.new(0, 260, 0, finalh),
    BackgroundTransparency = 0.15,
}):Play()

task.wait(0.2)
tweenz:Create(title, TweenInfo.new(0.3), {TextTransparency = 0}):Play()

for _, b in ipairs({btn1, btn2, btn3, btn4, togglebtn, btnc}) do
    tweenz:Create(b, TweenInfo.new(0.3), {TextTransparency = 0}):Play()
end

local dragging = false
local draginput, dragstart, startpos

main.InputBegan:Connect(function(inp)
    if inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragstart = inp.Position
        startpos = main.Position
        inp.Changed:Connect(function()
            if inp.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

main.InputChanged:Connect(function(inp)
    if inp.UserInputType == Enum.UserInputType.MouseMovement or inp.UserInputType == Enum.UserInputType.Touch then
        draginput = inp
    end
end)

uis.InputChanged:Connect(function(inp)
    if inp == draginput and dragging then
        local delta = inp.Position - dragstart
        tweenz:Create(main, TweenInfo.new(0.05, Enum.EasingStyle.Quad), {
            Position = UDim2.new(startpos.X.Scale, startpos.X.Offset + delta.X, startpos.Y.Scale, startpos.Y.Offset + delta.Y)
        }):Play()
    end
end)
