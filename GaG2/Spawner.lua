-- we need the goodies
local theBoxOfStuff = game:GetService("ReplicatedStorage")
local theHomies = game:GetService("Players")
local screenJunk = game:GetService("CoreGui")
local moveItRealSmooth = game:GetService("TweenService")
local noiseMaker = game:GetService("SoundService")
local clickyThing = game:GetService("UserInputService")

-- where the seeds live
local seedNest = theBoxOfStuff:WaitForChild("Assets"):WaitForChild("Seeds")
local meMyself = theHomies.LocalPlayer
local myEyes = workspace.CurrentCamera

-- seed data modules and images
local seedInfoBook = require(theBoxOfStuff:WaitForChild("SharedModules"):WaitForChild("SeedData"))
local seedSelfies = theBoxOfStuff:WaitForChild("SharedModules"):WaitForChild("SeedData"):WaitForChild("SeedImages")

-- dirt and plant sfx, stolen from the real game lol
local dirtClump = theBoxOfStuff:WaitForChild("Assets"):WaitForChild("Dirt")
local plantSoundEffect = noiseMaker:WaitForChild("SFX"):WaitForChild("PlantSFX")
local garbageBin = workspace:FindFirstChild("Temporary") or workspace

-- the magic word we search for in part names
local secretWord = "PlantAreaColumn"

-- the exact lil fingerprint size of a real plant column
local columnDimensions = Vector3.new(44, 0.5, 15.999893188476562)
local wiggleRoom = 0.05

-- checks if a size is basically the column size (floats are sneaky liars)
local function isItColumnSize(size)
	return math.abs(size.X - columnDimensions.X) <= wiggleRoom
		and math.abs(size.Y - columnDimensions.Y) <= wiggleRoom
		and math.abs(size.Z - columnDimensions.Z) <= wiggleRoom
end

-- nuke old gui if it exists (no clutter allowed)
local oldTrash = screenJunk:FindFirstChild("SeedSpawnerGui")
if oldTrash then oldTrash:Destroy() end

-- make the screen widget
local mainScreen = Instance.new("ScreenGui")
mainScreen.Name = "SeedSpawnerGui"
mainScreen.ResetOnSpawn = false
mainScreen.Parent = screenJunk

-- the big daddy frame
local bigFrame = Instance.new("Frame")
bigFrame.Size = UDim2.new(0, 200, 0, 310)
bigFrame.Position = UDim2.new(0.5, -100, 0.5, -155)
bigFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 22)
bigFrame.BorderSizePixel = 0
bigFrame.Active = true
bigFrame.Draggable = true  -- drag me around
bigFrame.Parent = mainScreen

-- roundy boi for the main panel
local roundCorner = Instance.new("UICorner")
roundCorner.CornerRadius = UDim.new(0, 10)
roundCorner.Parent = bigFrame

-- title text
local headerText = Instance.new("TextLabel")
headerText.Size = UDim2.new(1, 0, 0, 30)
headerText.BackgroundTransparency = 1
headerText.Text = "Seed Spawner"
headerText.TextColor3 = Color3.fromRGB(240, 240, 245)
headerText.TextSize = 12
headerText.Font = Enum.Font.GothamBold
headerText.Parent = bigFrame

-- searchy searchy
local findBox = Instance.new("TextBox")
findBox.Size = UDim2.new(1, -16, 0, 24)
findBox.Position = UDim2.new(0, 8, 0, 32)
findBox.BackgroundColor3 = Color3.fromRGB(32, 32, 36)
findBox.BorderSizePixel = 0
findBox.Text = ""
findBox.PlaceholderText = "Search seeds..."
findBox.TextColor3 = Color3.fromRGB(255, 255, 255)
findBox.PlaceholderColor3 = Color3.fromRGB(120, 120, 130)
findBox.TextSize = 11
findBox.Font = Enum.Font.Gotham
findBox.TextXAlignment = Enum.TextXAlignment.Left
findBox.ClearTextOnFocus = false
findBox.Parent = bigFrame

-- roundy for search
local findRoundy = Instance.new("UICorner")
findRoundy.CornerRadius = UDim.new(0, 5)
findRoundy.Parent = findBox

-- padding for search
local findPad = Instance.new("UIPadding")
findPad.PaddingLeft = UDim.new(0, 6)
findPad.Parent = findBox

-- scroll scroll scroll
local scrollThing = Instance.new("ScrollingFrame")
scrollThing.Size = UDim2.new(1, -16, 1, -145)
scrollThing.Position = UDim2.new(0, 8, 0, 62)
scrollThing.BackgroundTransparency = 1
scrollThing.BorderSizePixel = 0
scrollThing.CanvasSize = UDim2.new(0, 0, 0, 0)
scrollThing.ScrollBarThickness = 2
scrollThing.ScrollBarImageColor3 = Color3.fromRGB(50, 50, 55)
scrollThing.Parent = bigFrame

-- list layout for the scroll box
local listSorter = Instance.new("UIListLayout")
listSorter.Parent = scrollThing
listSorter.SortOrder = Enum.SortOrder.LayoutOrder
listSorter.Padding = UDim.new(0, 4)

-- variant panel at the bottom
local variantArea = Instance.new("Frame")
variantArea.Size = UDim2.new(1, -16, 0, 26)
variantArea.Position = UDim2.new(0, 8, 1, -73)
variantArea.BackgroundTransparency = 1
variantArea.Parent = bigFrame

-- grid layout for variants
local variantGridLayout = Instance.new("UIGridLayout")
variantGridLayout.CellSize = UDim2.new(0, 58, 1, 0)
variantGridLayout.CellPadding = UDim2.new(0, 5, 0, 0)
variantGridLayout.Parent = variantArea

-- spawny spawny button
local spawnButton = Instance.new("TextButton")
spawnButton.Size = UDim2.new(1, -16, 0, 30)
spawnButton.Position = UDim2.new(0, 8, 1, -38)
spawnButton.BackgroundColor3 = Color3.fromRGB(46, 204, 113)
spawnButton.Text = "Select a Seed"
spawnButton.TextColor3 = Color3.fromRGB(255, 255, 255)
spawnButton.TextSize = 11
spawnButton.Font = Enum.Font.GothamBold
spawnButton.Parent = bigFrame

-- roundy for button
local buttonRoundy = Instance.new("UICorner")
buttonRoundy.CornerRadius = UDim.new(0, 5)
buttonRoundy.Parent = spawnButton

-- state variables
local selectedSeed = nil
local selectedVariant = "Normal"
local rowTable = {}
local variantButtonTable = {}

-- helper to get seed data
local function getSeedInfo(seedName)
	for _, data in ipairs(seedInfoBook) do
		if data.SeedName == seedName then
			return data
		end
	end
	return nil
end

-- helper to get seed image id
local function getSeedPicture(seedName)
	local stringValue = seedSelfies:FindFirstChild(seedName)
	if stringValue and stringValue:IsA("StringValue") then
		return stringValue.Value
	end
	return "rbxassetid://0"
end

-- update canvas size when content changes
listSorter:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
	scrollThing.CanvasSize = UDim2.new(0, 0, 0, listSorter.AbsoluteContentSize.Y)
end)

-- select a seed (highlight it)
local function pickSeed(seedName, container)
	selectedSeed = seedName
	spawnButton.Text = "Spawn " .. selectedVariant .. " " .. seedName
	
	for _, entry in ipairs(rowTable) do
		entry.Frame.BackgroundColor3 = Color3.fromRGB(28, 28, 32)
	end
	container.BackgroundColor3 = Color3.fromRGB(34, 66, 124)
end

-- select a variant (Normal/Golden/Rainbow)
local function pickVariant(variantName)
	selectedVariant = variantName
	if selectedSeed then
		spawnButton.Text = "Spawn " .. selectedVariant .. " " .. selectedSeed
	end
	for name, btn in pairs(variantButtonTable) do
		if name == variantName then
			btn.BackgroundColor3 = Color3.fromRGB(41, 128, 185)
		else
			btn.BackgroundColor3 = Color3.fromRGB(32, 32, 36)
		end
	end
end

-- create variant buttons
local variantOptions = {"Normal", "Golden", "Rainbow"}
for _, vName in ipairs(variantOptions) do
	local variantButton = Instance.new("TextButton")
	variantButton.BackgroundColor3 = Color3.fromRGB(32, 32, 36)
	variantButton.BorderSizePixel = 0
	variantButton.Text = vName
	variantButton.TextColor3 = Color3.fromRGB(230, 230, 235)
	variantButton.TextSize = 10
	variantButton.Font = Enum.Font.GothamBold
	variantButton.Parent = variantArea
	
	local variantCorner = Instance.new("UICorner")
	variantCorner.CornerRadius = UDim.new(0, 4)
	variantCorner.Parent = variantButton
	
	variantButton.MouseButton1Click:Connect(function()
		pickVariant(vName)
	end)
	variantButtonTable[vName] = variantButton
end
pickVariant("Normal")

-- populate seed list
for _, seed in ipairs(seedNest:GetChildren()) do
	if seed:IsA("BasePart") then
		local textureId = getSeedPicture(seed.Name)
		
		local rowFrame = Instance.new("Frame")
		rowFrame.Size = UDim2.new(1, 0, 0, 32)
		rowFrame.BackgroundColor3 = Color3.fromRGB(28, 28, 32)
		rowFrame.BorderSizePixel = 0
		rowFrame.Parent = scrollThing
		rowFrame:SetAttribute("SeedToolTip", seed.Name)
		
		local rowCorner = Instance.new("UICorner")
		rowCorner.CornerRadius = UDim.new(0, 4)
		rowCorner.Parent = rowFrame
		
		local seedIcon = Instance.new("ImageLabel")
		seedIcon.Size = UDim2.new(0, 22, 0, 22)
		seedIcon.Position = UDim2.new(0, 5, 0, 5)
		seedIcon.BackgroundTransparency = 1
		seedIcon.Image = textureId
		seedIcon.Parent = rowFrame
		
		local seedNameLabel = Instance.new("TextLabel")
		seedNameLabel.Size = UDim2.new(1, -38, 1, 0)
		seedNameLabel.Position = UDim2.new(0, 32, 0, 0)
		seedNameLabel.BackgroundTransparency = 1
		seedNameLabel.Text = seed.Name
		seedNameLabel.TextColor3 = Color3.fromRGB(230, 230, 235)
		seedNameLabel.TextSize = 11
		seedNameLabel.Font = Enum.Font.GothamBold
		seedNameLabel.TextXAlignment = Enum.TextXAlignment.Left
		seedNameLabel.Parent = rowFrame
		
		local selectButton = Instance.new("TextButton")
		selectButton.Size = UDim2.new(1, 0, 1, 0)
		selectButton.BackgroundTransparency = 1
		selectButton.Text = ""
		selectButton.Parent = rowFrame
		
		selectButton.MouseButton1Click:Connect(function()
			pickSeed(seed.Name, rowFrame)
		end)
		
		table.insert(rowTable, {
			Name = seed.Name:lower(),
			Frame = rowFrame
		})
	end
end

-- search filter
findBox:GetPropertyChangedSignal("Text"):Connect(function()
	local query = findBox.Text:lower()
	for _, entry in ipairs(rowTable) do
		if query == "" or entry.Name:find(query, 1, true) then
			entry.Frame.Visible = true
		else
			entry.Frame.Visible = false
		end
	end
end)

-- find existing seed tool in inventory
local function findExistingSeed(name, variant)
	local expectedName = (variant == "Normal") and (name .. " Seed") or (variant .. " " .. name .. " Seed")
	local backpack = meMyself:FindFirstChild("Backpack")
	if backpack then
		local found = backpack:FindFirstChild(expectedName)
		if found and found:IsA("Tool") then return found end
	end
	local char = meMyself.Character
	if char then
		local found = char:FindFirstChild(expectedName)
		if found and found:IsA("Tool") then return found end
	end
	return nil
end

-- plays the lil plant sfx, copied vibe from the leak
local function makePlantSound()
	local cloneSfx = plantSoundEffect:Clone()
	cloneSfx.PlaybackSpeed = 1 + math.random(-10, 10) / 100
	cloneSfx.Parent = garbageBin
	cloneSfx:Play()
	cloneSfx.Ended:Connect(function()
		cloneSfx:Destroy()
	end)
end

-- makes the dirt mound poof up, stays forever this time
local function makeDirtPuff(plantPos)
	local dirtClone = dirtClump:Clone()
	dirtClone.Position = plantPos - Vector3.new(0, 0.01, 0)
	dirtClone.Orientation = Vector3.new(dirtClump.Orientation.X, math.random(-180, 180), dirtClump.Orientation.Z)
	dirtClone.Size = Vector3.new(0.1, 0.8, 0.8)
	dirtClone.Transparency = 1
	dirtClone.Anchored = true
	dirtClone.CanCollide = false
	dirtClone.Parent = garbageBin
	
	moveItRealSmooth:Create(dirtClone, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
		Size = Vector3.new(0.1, 2, 2),
		Transparency = 0
	}):Play()
end

-- spawn button click, makes the actual tool with attributes
spawnButton.MouseButton1Click:Connect(function()
	if not selectedSeed then return end
	
	local existingTool = findExistingSeed(selectedSeed, selectedVariant)
	if existingTool then
		local currentCount = existingTool:GetAttribute("Count") or 1
		existingTool:SetAttribute("Count", currentCount + 1)
	else
		local targetPart = seedNest:FindFirstChild(selectedSeed)
		local backpack = meMyself:FindFirstChild("Backpack")
		
		if targetPart and backpack then
			local data = getSeedInfo(selectedSeed)
			local yHeight = data and data.YHeight or 0
			
			local NewTool = Instance.new("Tool")
			
			if selectedVariant == "Normal" then
				NewTool.Name = selectedSeed .. " Seed"
				NewTool:SetAttribute("SeedTool", selectedSeed)
			else
				NewTool.Name = selectedVariant .. " " .. selectedSeed .. " Seed"
				NewTool:SetAttribute("SeedTool", selectedSeed)
				NewTool:SetAttribute("Variant", selectedVariant)
				NewTool:SetAttribute("Tier", selectedVariant)
			end
			
			NewTool.TextureId = getSeedPicture(selectedSeed)
			NewTool:SetAttribute("Count", 1)
			NewTool:SetAttribute("MainCategory", "Seed")
			NewTool:SetAttribute("ToolDescendants", 0)
			
			if yHeight > 0 then
				local scaledHeight = yHeight * 0.1
				NewTool.Grip = CFrame.new(0, -scaledHeight, 0)
			end
			
			local clonedPart = targetPart:Clone()
			clonedPart.Name = "Handle"
			clonedPart.Parent = NewTool
			NewTool.Parent = backpack
		end
	end
	
	local originalText = spawnButton.Text
	spawnButton.Text = "Added!"
	spawnButton.BackgroundColor3 = Color3.fromRGB(39, 174, 96)
	task.wait(0.25)
	spawnButton.Text = originalText
	spawnButton.BackgroundColor3 = Color3.fromRGB(46, 204, 113)
end)

-- the planting click handler
local function tryPlantingAt(targetPos)
	local char = meMyself.Character
	if not char then return end
	
	local equippedTool = char:FindFirstChildWhichIsA("Tool")
	if not equippedTool then return end
	
	local seedName = equippedTool:GetAttribute("SeedTool")
	if not seedName then return end
	
	makePlantSound()
	makeDirtPuff(targetPos)
	
	local currentCount = equippedTool:GetAttribute("Count") or 1
	if currentCount > 1 then
		equippedTool:SetAttribute("Count", currentCount - 1)
	else
		equippedTool:Destroy()
	end
end

-- checks if THIS exact part is a real plantable column, name AND size both gotta match
local function isItPlantColumn(part)
	if not part or not part:IsA("BasePart") then return false end
	if not part.Name:lower():find(secretWord:lower(), 1, true) then return false end
	return isItColumnSize(part.Size)
end

-- detect clicks, raycast has to land directly on the real column part, no nearby guessing
clickyThing.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed then return end
	if input.UserInputType ~= Enum.UserInputType.MouseButton1 and input.UserInputType ~= Enum.UserInputType.Touch then return end
	
	local char = meMyself.Character
	if not char then return end
	local equippedTool = char:FindFirstChildWhichIsA("Tool")
	if not equippedTool or not equippedTool:GetAttribute("SeedTool") then return end
	
	local mousePos = clickyThing:GetMouseLocation()
	local viewRay = myEyes:ViewportPointToRay(mousePos.X, mousePos.Y)
	
	local raySettings = RaycastParams.new()
	raySettings.FilterType = Enum.RaycastFilterType.Exclude
	raySettings.FilterDescendantsInstances = {char}
	
	local rayHit = workspace:Raycast(viewRay.Origin, viewRay.Direction * 500, raySettings)
	if not rayHit then return end
	
	local hitPart = rayHit.Instance
	if isItPlantColumn(hitPart) then
		tryPlantingAt(rayHit.Position)
	end
end)
