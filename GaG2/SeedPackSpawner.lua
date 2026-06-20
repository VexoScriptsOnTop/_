-- big brain getters
local coolStorage = game:GetService("ReplicatedStorage")
local peeps = game:GetService("Players")
local guiStuff = game:GetService("CoreGui")
local tweenBoi = game:GetService("TweenService")
local soundBoi = game:GetService("SoundService")
local inputBoi = game:GetService("UserInputService")
local runBoi = game:GetService("RunService")

-- seed central
local seedyFolder = coolStorage:WaitForChild("Assets"):WaitForChild("Seeds")
local packFolder = coolStorage:WaitForChild("Assets"):WaitForChild("SeedPacks")
local localBoi = peeps.LocalPlayer
local camBoi = workspace.CurrentCamera

-- the lore books
local seedModule = require(coolStorage:WaitForChild("SharedModules"):WaitForChild("SeedData"))
local packModule = require(coolStorage:WaitForChild("SharedModules"):WaitForChild("SeedPackData"))
local seedPics = coolStorage:WaitForChild("SharedModules"):WaitForChild("SeedData"):WaitForChild("SeedImages")

-- dirt n noise
local dirtAsset = coolStorage:WaitForChild("Assets"):WaitForChild("Dirt")
local plantSfx = soundBoi:WaitForChild("SFX"):WaitForChild("PlantSFX")
local tempFolder = workspace:FindFirstChild("Temporary") or workspace

-- magic word go brrr
local dirtKeyword = "PlantAreaColumn"
local columnSize = Vector3.new(44, 0.5, 15.999893188476562)
local sizeWiggleRoom = 0.05

local function isColumnSize(size)
	return math.abs(size.X - columnSize.X) <= sizeWiggleRoom
		and math.abs(size.Y - columnSize.Y) <= sizeWiggleRoom
		and math.abs(size.Z - columnSize.Z) <= sizeWiggleRoom
end

-- zoom lookups
local seedLookup = {}
for _, data in ipairs(seedModule) do
	seedLookup[data.SeedName] = data
end

local picLookup = {}
for _, img in ipairs(seedPics:GetChildren()) do
	if img:IsA("StringValue") then
		picLookup[img.Name] = img.Value
	end
end

local function getSeedImageId(seedName)
	return picLookup[seedName] or "rbxassetid://0"
end

-- delete ALL the impostors
for _, gui in ipairs(guiStuff:GetChildren()) do
	if gui.Name == "SeedPackSpawnerGui" then
		gui:Destroy()
	end
end

-- screen thingy
local screenWidget = Instance.new("ScreenGui")
screenWidget.Name = "SeedPackSpawnerGui"
screenWidget.ResetOnSpawn = false
screenWidget.Parent = guiStuff

local function slapCorner(parent, radius)
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, radius)
	corner.Parent = parent
	return corner
end

-- chunky boi frame
local mainPanel = Instance.new("Frame")
mainPanel.Size = UDim2.new(0, 200, 0, 280)
mainPanel.Position = UDim2.new(0.5, -100, 0.5, -140)
mainPanel.BackgroundColor3 = Color3.fromRGB(20, 20, 22)
mainPanel.BorderSizePixel = 0
mainPanel.Active = true
mainPanel.Draggable = true
mainPanel.Parent = screenWidget
slapCorner(mainPanel, 10)

local titleText = Instance.new("TextLabel")
titleText.Size = UDim2.new(1, 0, 0, 30)
titleText.BackgroundTransparency = 1
titleText.Text = "Seed Pack Spawner"
titleText.TextColor3 = Color3.fromRGB(240, 240, 245)
titleText.TextSize = 12
titleText.Font = Enum.Font.GothamBold
titleText.Parent = mainPanel

local searchBox = Instance.new("TextBox")
searchBox.Size = UDim2.new(1, -16, 0, 24)
searchBox.Position = UDim2.new(0, 8, 0, 32)
searchBox.BackgroundColor3 = Color3.fromRGB(32, 32, 36)
searchBox.BorderSizePixel = 0
searchBox.Text = ""
searchBox.PlaceholderText = "Search packs..."
searchBox.TextColor3 = Color3.fromRGB(255, 255, 255)
searchBox.PlaceholderColor3 = Color3.fromRGB(120, 120, 130)
searchBox.TextSize = 11
searchBox.Font = Enum.Font.Gotham
searchBox.TextXAlignment = Enum.TextXAlignment.Left
searchBox.ClearTextOnFocus = false
searchBox.Parent = mainPanel
slapCorner(searchBox, 5)

local searchPad = Instance.new("UIPadding")
searchPad.PaddingLeft = UDim.new(0, 6)
searchPad.Parent = searchBox

local scrollBox = Instance.new("ScrollingFrame")
scrollBox.Size = UDim2.new(1, -16, 1, -106)
scrollBox.Position = UDim2.new(0, 8, 0, 62)
scrollBox.BackgroundTransparency = 1
scrollBox.BorderSizePixel = 0
scrollBox.CanvasSize = UDim2.new(0, 0, 0, 0)
scrollBox.ScrollBarThickness = 2
scrollBox.ScrollBarImageColor3 = Color3.fromRGB(50, 50, 55)
scrollBox.Parent = mainPanel

local listLayout = Instance.new("UIListLayout")
listLayout.Parent = scrollBox
listLayout.SortOrder = Enum.SortOrder.LayoutOrder
listLayout.Padding = UDim.new(0, 4)

local spawnBtn = Instance.new("TextButton")
spawnBtn.Size = UDim2.new(1, -16, 0, 30)
spawnBtn.Position = UDim2.new(0, 8, 1, -38)
spawnBtn.BackgroundColor3 = Color3.fromRGB(46, 204, 113)
spawnBtn.Text = "Select a Pack"
spawnBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
spawnBtn.TextSize = 11
spawnBtn.Font = Enum.Font.GothamBold
spawnBtn.Parent = mainPanel
slapCorner(spawnBtn, 5)

local chosenPack = nil
local rowList = {}

listLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
	scrollBox.CanvasSize = UDim2.new(0, 0, 0, listLayout.AbsoluteContentSize.Y)
end)

local function selectPack(packName, container)
	chosenPack = packName
	spawnBtn.Text = "Spawn " .. packName

	for _, entry in ipairs(rowList) do
		entry.Frame.BackgroundColor3 = Color3.fromRGB(28, 28, 32)
	end
	container.BackgroundColor3 = Color3.fromRGB(34, 66, 124)
end

for _, packData in ipairs(packModule.Data) do
	local RowFrame = Instance.new("Frame")
	RowFrame.Size = UDim2.new(1, 0, 0, 32)
	RowFrame.BackgroundColor3 = Color3.fromRGB(28, 28, 32)
	RowFrame.BorderSizePixel = 0
	RowFrame.Parent = scrollBox
	slapCorner(RowFrame, 4)

	local icon = Instance.new("ImageLabel")
	icon.Size = UDim2.new(0, 22, 0, 22)
	icon.Position = UDim2.new(0, 5, 0, 5)
	icon.BackgroundTransparency = 1
	icon.Image = packData.IMG or "rbxassetid://0"
	icon.Parent = RowFrame

	local NameLabel = Instance.new("TextLabel")
	NameLabel.Size = UDim2.new(1, -38, 1, 0)
	NameLabel.Position = UDim2.new(0, 32, 0, 0)
	NameLabel.BackgroundTransparency = 1
	NameLabel.Text = packData.PackName
	NameLabel.TextColor3 = Color3.fromRGB(230, 230, 235)
	NameLabel.TextSize = 11
	NameLabel.Font = Enum.Font.GothamBold
	NameLabel.TextXAlignment = Enum.TextXAlignment.Left
	NameLabel.Parent = RowFrame

	local SelectBtn = Instance.new("TextButton")
	SelectBtn.Size = UDim2.new(1, 0, 1, 0)
	SelectBtn.BackgroundTransparency = 1
	SelectBtn.Text = ""
	SelectBtn.Parent = RowFrame

	SelectBtn.MouseButton1Click:Connect(function()
		selectPack(packData.PackName, RowFrame)
	end)

	table.insert(rowList, {
		Name = packData.PackName:lower(),
		Frame = RowFrame
	})
end

searchBox:GetPropertyChangedSignal("Text"):Connect(function()
	local query = searchBox.Text:lower()
	for _, entry in ipairs(rowList) do
		entry.Frame.Visible = (query == "" or entry.Name:find(query, 1, true) ~= nil)
	end
end)

local function findExistingPackTool(packName)
	local backpack = localBoi:FindFirstChild("Backpack")
	if backpack then
		local found = backpack:FindFirstChild(packName)
		if found and found:IsA("Tool") then return found end
	end
	local char = localBoi.Character
	if char then
		local found = char:FindFirstChild(packName)
		if found and found:IsA("Tool") then return found end
	end
	return nil
end

local function rollSeedFromPack(packName)
	local data = packModule.GetData(packName)
	if not data then return nil end

	if data.Seeds and #data.Seeds > 0 then
		local totalChance = 0
		for _, entry in ipairs(data.Seeds) do
			totalChance = totalChance + entry.Chance
		end
		local roll = math.random() * totalChance
		local runningTotal = 0
		for _, entry in ipairs(data.Seeds) do
			runningTotal = runningTotal + entry.Chance
			if roll <= runningTotal then
				return entry.SeedName
			end
		end
		return data.Seeds[#data.Seeds].SeedName
	end

	local allNames = {}
	for _, seed in ipairs(seedModule) do
		table.insert(allNames, seed.SeedName)
	end
	if #allNames == 0 then return nil end
	return allNames[math.random(1, #allNames)]
end

local function grantSeedTool(seedName)
	local targetPart = seedyFolder:FindFirstChild(seedName)
	local backpack = localBoi:FindFirstChild("Backpack")
	if not (targetPart and backpack) then return end

	local existingTool = backpack:FindFirstChild(seedName .. " Seed")
	if existingTool then
		local currentCount = existingTool:GetAttribute("Count") or 1
		existingTool:SetAttribute("Count", currentCount + 1)
		return
	end

	local data = seedLookup[seedName]
	local yHeight = data and data.YHeight or 0

	local NewTool = Instance.new("Tool")
	NewTool.Name = seedName .. " Seed"
	NewTool:SetAttribute("SeedTool", seedName)
	NewTool.TextureId = getSeedImageId(seedName)
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

local activeBillboardAnchor = nil

local function showWonSeedBillboard(worldPos, seedName)
	if activeBillboardAnchor then
		activeBillboardAnchor:Destroy()
		activeBillboardAnchor = nil
	end

	local billboard = Instance.new("BillboardGui")
	billboard.Name = "WonSeedReveal"
	billboard.Size = UDim2.fromOffset(140, 60)
	billboard.StudsOffset = Vector3.new(0, 3, 0)
	billboard.AlwaysOnTop = true

	local anchorPart = Instance.new("Part")
	anchorPart.Size = Vector3.new(0.1, 0.1, 0.1)
	anchorPart.Transparency = 1
	anchorPart.Anchored = true
	anchorPart.CanCollide = false
	anchorPart.CanQuery = false
	anchorPart.Position = worldPos
	anchorPart.Parent = tempFolder
	billboard.Adornee = anchorPart
	billboard.Parent = anchorPart

	activeBillboardAnchor = anchorPart

	local holder = Instance.new("Frame")
	holder.Size = UDim2.fromScale(1, 1)
	holder.BackgroundTransparency = 1
	holder.Parent = billboard

	local pic = Instance.new("ImageLabel")
	pic.Size = UDim2.fromOffset(40, 40)
	pic.Position = UDim2.new(0.5, -20, 0, 0)
	pic.BackgroundTransparency = 1
	pic.Image = getSeedImageId(seedName)
	pic.Parent = holder

	local nameTag = Instance.new("TextLabel")
	nameTag.Size = UDim2.new(1, 0, 0, 18)
	nameTag.Position = UDim2.new(0, 0, 0, 42)
	nameTag.BackgroundTransparency = 1
	nameTag.Text = seedName
	nameTag.TextColor3 = Color3.fromRGB(255, 255, 255)
	nameTag.TextStrokeTransparency = 0
	nameTag.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
	nameTag.TextSize = 14
	nameTag.Font = Enum.Font.GothamBold
	nameTag.Parent = holder

	pic.Size = UDim2.fromOffset(0, 0)
	nameTag.TextTransparency = 1
	nameTag.TextStrokeTransparency = 1
	tweenBoi:Create(pic, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
		Size = UDim2.fromOffset(40, 40)
	}):Play()
	tweenBoi:Create(nameTag, TweenInfo.new(0.35, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
		TextTransparency = 0,
		TextStrokeTransparency = 0.2
	}):Play()

	task.delay(2.5, function()
		if anchorPart ~= activeBillboardAnchor then return end
		tweenBoi:Create(anchorPart, TweenInfo.new(1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			Position = worldPos + Vector3.new(0, 2, 0)
		}):Play()
		tweenBoi:Create(pic, TweenInfo.new(0.8, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			ImageTransparency = 1
		}):Play()
		tweenBoi:Create(nameTag, TweenInfo.new(0.8, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			TextTransparency = 1,
			TextStrokeTransparency = 1
		}):Play()
		task.delay(1, function()
			if anchorPart == activeBillboardAnchor then
				activeBillboardAnchor = nil
			end
			anchorPart:Destroy()
		end)
	end)
end

-- HOW HIGH THE WHOLE SHOW FLOATS, bump this if it still feels low
local floatHeight = -1.5
local currentCircleAngle = 0

local function playFakePackOpenFx(openPos, packModel, wonSeed)
	currentCircleAngle = (currentCircleAngle + 45) % 360
	local rad = math.rad(currentCircleAngle)
	local radius = 4
	
	local floatPos = openPos + Vector3.new(math.cos(rad) * radius, floatHeight, math.sin(rad) * radius)

	local fxModel = packModel:Clone()

	for _, descendant in ipairs(fxModel:GetDescendants()) do
		if descendant:IsA("BasePart") then
			descendant.Anchored = true
			descendant.CanCollide = false
			descendant.CanQuery = false
		end
	end

	local dropStart = floatPos + Vector3.new(0, 10, 0)
	if fxModel:IsA("Model") then
		fxModel:PivotTo(CFrame.new(dropStart))
	else
		fxModel.Position = dropStart
	end
	fxModel.Parent = tempFolder

	local dropSound = plantSfx:Clone()
	dropSound.PlaybackSpeed = 1
	dropSound.Parent = tempFolder
	dropSound:Play()
	dropSound.Ended:Connect(function() dropSound:Destroy() end)

	local elapsed = 0
	local dropTime = 0.9
	while elapsed < dropTime do
		elapsed = elapsed + runBoi.Heartbeat:Wait()
		local alpha = tweenBoi:GetValue(math.clamp(elapsed / dropTime, 0, 1), Enum.EasingStyle.Bounce, Enum.EasingDirection.Out)
		local pos = dropStart:Lerp(floatPos, alpha)
		if fxModel:IsA("Model") then
			fxModel:PivotTo(CFrame.new(pos))
		else
			fxModel.Position = pos
		end
	end

	local shakeTime = 0
	while shakeTime < 1 do
		shakeTime = shakeTime + runBoi.Heartbeat:Wait()
		local wiggle = math.sin(shakeTime * 30) * 0.08
		if fxModel:IsA("Model") then
			fxModel:PivotTo(CFrame.new(floatPos) * CFrame.Angles(0, wiggle, 0))
		else
			fxModel.CFrame = CFrame.new(floatPos) * CFrame.Angles(0, wiggle, 0)
		end
	end

	local popSound = plantSfx:Clone()
	popSound.PlaybackSpeed = 1.4
	popSound.Parent = tempFolder
	popSound:Play()
	popSound.Ended:Connect(function() popSound:Destroy() end)

	local mainPart = fxModel:IsA("Model") and fxModel.PrimaryPart or fxModel
	if mainPart then
		tweenBoi:Create(mainPart, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
			Size = mainPart.Size * 1.4
		}):Play()
	end

	for _, descendant in ipairs(fxModel:GetDescendants()) do
		if descendant:IsA("BasePart") then
			tweenBoi:Create(descendant, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
				Transparency = 1
			}):Play()
		end
	end

	-- billboard floats at the same height now, not on the ground
	showWonSeedBillboard(floatPos, wonSeed)

	task.delay(0.6, function()
		fxModel:Destroy()
	end)
end

spawnBtn.MouseButton1Click:Connect(function()
	if not chosenPack then return end

	local existingTool = findExistingPackTool(chosenPack)
	if existingTool then
		local currentCount = existingTool:GetAttribute("Count") or 1
		existingTool:SetAttribute("Count", currentCount + 1)
	else
		local packModel = packFolder:FindFirstChild(chosenPack)
		local backpack = localBoi:FindFirstChild("Backpack")

		if packModel and backpack then
			local NewTool = Instance.new("Tool")
			NewTool.Name = chosenPack
			NewTool:SetAttribute("SeedPack", chosenPack)
			NewTool:SetAttribute("Count", 1)
			NewTool:SetAttribute("MainCategory", "SeedPack")

			local handlePart
			if packModel:IsA("BasePart") then
				handlePart = packModel:Clone()
				handlePart.Name = "Handle"
				handlePart.Parent = NewTool
			elseif packModel:IsA("Model") then
				local sourceHandle = packModel.PrimaryPart or packModel:FindFirstChildWhichIsA("BasePart")
				if sourceHandle then
					for _, piece in ipairs(packModel:GetChildren()) do
						local pieceClone = piece:Clone()
						if pieceClone.Name == sourceHandle.Name then
							pieceClone.Name = "Handle"
						end
						pieceClone.Parent = NewTool
					end
					handlePart = NewTool:FindFirstChild("Handle")
				end
			end

			if handlePart then
				NewTool.Parent = backpack
			else
				NewTool:Destroy()
			end
		end
	end

	local originalText = spawnBtn.Text
	spawnBtn.Text = "Added!"
	spawnBtn.BackgroundColor3 = Color3.fromRGB(39, 174, 96)
	task.wait(0.25)
	spawnBtn.Text = originalText
	spawnBtn.BackgroundColor3 = Color3.fromRGB(46, 204, 113)
end)

local function playPlantNoise()
	local cloneSfx = plantSfx:Clone()
	cloneSfx.PlaybackSpeed = 1 + math.random(-10, 10) / 100
	cloneSfx.Parent = tempFolder
	cloneSfx:Play()
	cloneSfx.Ended:Connect(function()
		cloneSfx:Destroy()
	end)
end

local function spawnDirtPoof(plantPos)
	local dirtClone = dirtAsset:Clone()
	dirtClone.Position = plantPos - Vector3.new(0, 0.01, 0)
	dirtClone.Orientation = Vector3.new(dirtAsset.Orientation.X, math.random(-180, 180), dirtAsset.Orientation.Z)
	dirtClone.Size = Vector3.new(0.1, 0.8, 0.8)
	dirtClone.Transparency = 1
	dirtClone.Anchored = true
	dirtClone.CanCollide = false
	dirtClone.Parent = tempFolder

	tweenBoi:Create(dirtClone, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
		Size = Vector3.new(0.1, 2, 2),
		Transparency = 0
	}):Play()
end

local function tryPlantAtPoint(targetPos)
	local char = localBoi.Character
	if not char then return end

	local equippedTool = char:FindFirstChildWhichIsA("Tool")
	if not equippedTool then return end

	local seedName = equippedTool:GetAttribute("SeedTool")
	if not seedName then return end

	playPlantNoise()
	spawnDirtPoof(targetPos)

	local currentCount = equippedTool:GetAttribute("Count") or 1
	if currentCount > 1 then
		equippedTool:SetAttribute("Count", currentCount - 1)
	else
		equippedTool:Destroy()
	end
end

local function isPlantColumn(part)
	if not part or not part:IsA("BasePart") then return false end
	if not part.Name:lower():find(dirtKeyword:lower(), 1, true) then return false end
	return isColumnSize(part.Size)
end

local packOpenLock = false

local function openPackTool(packTool, openPos)
	if packOpenLock then return end
	packOpenLock = true

	local packName = packTool:GetAttribute("SeedPack")
	if not packName then
		packOpenLock = false
		return
	end

	local rolledSeed = rollSeedFromPack(packName)

	local currentCount = packTool:GetAttribute("Count") or 1
	if currentCount > 1 then
		packTool:SetAttribute("Count", currentCount - 1)
	else
		packTool:Destroy()
	end

	local packModel = packFolder:FindFirstChild(packName)
	if packModel and rolledSeed then
		task.spawn(function()
			local ok, err = pcall(playFakePackOpenFx, openPos, packModel, rolledSeed)
			if not ok then
				warn("[SeedPackSpawnerGui] fx error: " .. tostring(err))
			end
		end)
	end

	if rolledSeed then
		task.delay(0.9, function()
			grantSeedTool(rolledSeed)
		end)
	end

	task.delay(0.1, function()
		packOpenLock = false
	end)
end

-- EQUIP DEBOUNCE, the actual fix for "opens as soon as I hold it"
-- tracks which tool is currently the equipped one, and refuses to let it open
-- for a short grace period right after becoming equipped, no matter what fires
local equippedToolTracker = nil
local equipGraceUntil = {}
local equipGraceSeconds = 0.35

local function watchToolEquip(tool)
	if not tool:IsA("Tool") then return end

	tool.Equipped:Connect(function()
		equippedToolTracker = tool
		equipGraceUntil[tool] = os.clock() + equipGraceSeconds
	end)

	tool.Unequipped:Connect(function()
		if equippedToolTracker == tool then
			equippedToolTracker = nil
		end
		equipGraceUntil[tool] = nil
	end)
end

local function hookAllTools(container)
	for _, child in ipairs(container:GetChildren()) do
		watchToolEquip(child)
	end
	container.ChildAdded:Connect(watchToolEquip)
end

local function setupCharacterEquipWatch(char)
	hookAllTools(char)
end

if localBoi.Character then
	setupCharacterEquipWatch(localBoi.Character)
end
localBoi.CharacterAdded:Connect(setupCharacterEquipWatch)

local backpackInst = localBoi:FindFirstChildOfClass("Backpack")
if backpackInst then
	hookAllTools(backpackInst)
end
localBoi.ChildAdded:Connect(function(child)
	if child:IsA("Backpack") then
		hookAllTools(child)
	end
end)

-- checks if a tool is allowed to open right now, false during its equip grace period
local function canToolOpenNow(tool)
	local graceEnd = equipGraceUntil[tool]
	if graceEnd and os.clock() < graceEnd then
		return false
	end
	return true
end

local function getAimPoint()
	local char = localBoi.Character
	if not char then return nil end

	local mousePos = inputBoi:GetMouseLocation()
	local viewRay = camBoi:ViewportPointToRay(mousePos.X, mousePos.Y)

	local rayParams = RaycastParams.new()
	rayParams.FilterType = Enum.RaycastFilterType.Exclude
	rayParams.FilterDescendantsInstances = {char}

	local rayResult = workspace:Raycast(viewRay.Origin, viewRay.Direction * 500, rayParams)
	return rayResult
end

inputBoi.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed then return end
	if input.UserInputType ~= Enum.UserInputType.MouseButton1 then return end

	local char = localBoi.Character
	if not char then return end
	local equippedTool = char:FindFirstChildWhichIsA("Tool")
	if not equippedTool then return end
	if not canToolOpenNow(equippedTool) then return end

	local rayResult = getAimPoint()
	local playerPos = char:FindFirstChild("HumanoidRootPart") and char.HumanoidRootPart.Position or Vector3.new(0, 0, 0)

	if equippedTool:GetAttribute("SeedPack") then
		openPackTool(equippedTool, playerPos)
		return
	end

	if equippedTool:GetAttribute("SeedTool") and rayResult and isPlantColumn(rayResult.Instance) then
		tryPlantAtPoint(rayResult.Position)
	end
end)

local touchStartPos = nil
local touchStartTime = 0
local touchStartCamCFrame = nil
local tapMoveLimit = 25
local tapTimeLimit = 0.5
local tapCamRotateLimit = 0.02

inputBoi.InputBegan:Connect(function(input, gameProcessed)
	if input.UserInputType ~= Enum.UserInputType.Touch then return end
	touchStartPos = input.Position
	touchStartTime = os.clock()
	touchStartCamCFrame = camBoi.CFrame
end)

inputBoi.InputChanged:Connect(function(input, gameProcessed)
	if input.UserInputType ~= Enum.UserInputType.Touch then return end
	if touchStartPos then
		local movedDist = (input.Position - touchStartPos).Magnitude
		if movedDist > tapMoveLimit then
			touchStartPos = nil
		end
	end
end)

inputBoi.InputEnded:Connect(function(input, gameProcessed)
	if input.UserInputType ~= Enum.UserInputType.Touch then return end
	if not touchStartPos then return end

	local movedDist = (input.Position - touchStartPos).Magnitude
	local heldTime = os.clock() - touchStartTime

	local camRotated = false
	if touchStartCamCFrame then
		local lookA = touchStartCamCFrame.LookVector
		local lookB = camBoi.CFrame.LookVector
		local dot = lookA:Dot(lookB)
		camRotated = dot < (1 - tapCamRotateLimit)
	end

	touchStartPos = nil
	touchStartCamCFrame = nil

	if movedDist > tapMoveLimit or heldTime > tapTimeLimit or camRotated then return end

	local char = localBoi.Character
	if not char then return end
	local equippedTool = char:FindFirstChildWhichIsA("Tool")
	if not equippedTool then return end
	if not canToolOpenNow(equippedTool) then return end

	local rayResult = getAimPoint()
	local playerPos = char:FindFirstChild("HumanoidRootPart") and char.HumanoidRootPart.Position or Vector3.new(0, 0, 0)

	if equippedTool:GetAttribute("SeedPack") then
		openPackTool(equippedTool, playerPos)
		return
	end

	if equippedTool:GetAttribute("SeedTool") and rayResult and isPlantColumn(rayResult.Instance) then
		tryPlantAtPoint(rayResult.Position)
	end
end)
