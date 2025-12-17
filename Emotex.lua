-- ========================================
-- GAZE EMOTES - REDESIGNED UI (PART 1/5)
-- Modern Dark Theme with Smooth Animations
-- ========================================

local Screen= setmetatable({}, {
__index= function(_, key)
local cam= workspace.CurrentCamera
local size= cam and cam.ViewportSize or Vector2.new(1920, 1080)
if key== "Width" then
return size.X
elseif key== "Height" then
return size.Y
elseif key== "Size" then
return size
end end})

local UserInputService = game:GetService("UserInputService")
local Screen = workspace.CurrentCamera.ViewportSize

function scale(axis, value)
    local isMobile = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled
    local baseWidth, baseHeight = 1920, 1080
    local scaleFactor = isMobile and 2 or 1.5

    if axis == "X" then
        return value * (Screen.X / baseWidth) * scaleFactor
    elseif axis == "Y" then
        return value * (Screen.Y / baseHeight) * scaleFactor
    end
end

function missing(t, f, fallback)
    if type(f) == t then return f end
    return fallback 
end

cloneref = missing("function", cloneref, function(...) return ... end)

local Services = setmetatable({}, {
    __index = function(_, name)
        return cloneref(game:GetService(name))
    end
})

local Players = Services.Players
local RunService = Services.RunService
local UserInputService = Services.UserInputService
local TweenService = Services.TweenService
local AvatarEditorService = Services.AvatarEditorService
local HttpService = Services.HttpService

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")
local lastPosition = character.PrimaryPart and character.PrimaryPart.Position or Vector3.new()

player.CharacterAdded:Connect(function(newCharacter)
    character = newCharacter
    humanoid = newCharacter:WaitForChild("Humanoid")
    lastPosition = character.PrimaryPart and character.PrimaryPart.Position or Vector3.new()
end)

local Settings = {}
Settings["Stop Emote When Moving"] = true
Settings["Fade In"]     = 0.1
Settings["Fade Out"]    = 0.1
Settings["Weight"]      = 1
Settings["Speed"]       = 1
Settings["Allow Invisible  "]    = true
Settings["Time Position"] = 0
Settings["Freeze On Finish"] = false
Settings["Looped"] = true
Settings["Stop Other Animations On Play"] = true
Settings["Preview"]    = false

local savedEmotes = {}
local SAVE_FILE = "GazeEmotes_NewNEWN3WSaved.json"

local function loadSavedEmotes()
    local success, data = pcall(function()
        if readfile and isfile and isfile(SAVE_FILE) then
            return HttpService:JSONDecode(readfile(SAVE_FILE))
        end
        return {}
    end)
    if success and type(data) == "table" then
        savedEmotes = data
    else
        savedEmotes = {}
    end
    for _, v in ipairs(savedEmotes) do
        if not v.AnimationId then
            if v.AssetId then
                v.AnimationId = "rbxassetid://" .. tostring(v.AssetId)
            else
                v.AnimationId = "rbxassetid://" .. tostring(v.Id)
            end
        end
        if v.Favorite == nil then
            v.Favorite = false
        end
    end
end

local function saveEmotesToData()
    pcall(function()
        if writefile then
            writefile(SAVE_FILE, HttpService:JSONEncode(savedEmotes))
        end
    end)
end

loadSavedEmotes()

local CurrentTrack = nil

local function LoadTrack(id)
    if CurrentTrack then 
        CurrentTrack:Stop(Settings["Fade Out"]) 
    end
    local animId
    local ok, result = pcall(function() 
        return game:GetObjects("rbxassetid://" .. tostring(id)) 
    end)
    if ok and result and #result > 0 then
        local anim = result[1]
        if anim:IsA("Animation") then
            animId = anim.AnimationId
        else
            animId = "rbxassetid://" .. tostring(id)
        end
    else
        animId = "rbxassetid://" .. tostring(id)
    end
    local newAnim = Instance.new("Animation")
    newAnim.AnimationId = animId
    local newTrack = humanoid:LoadAnimation(newAnim)
    newTrack.Priority = Enum.AnimationPriority.Action4
    local weight = Settings["Weight"]
    if weight == 0 then weight = 0.001 end
    if Settings["Stop Other Animations On Play"] then
    for _,t in pairs(humanoid.Animator:GetPlayingAnimationTracks())do
        if t.Priority ~= Enum.AnimationPriority.Action4 then
            t:Stop()
        end
    end
    end
    newTrack:Play(Settings["Fade In"], weight, Settings["Speed"])
    CurrentTrack = newTrack 
    CurrentTrack.TimePosition = math.clamp(Settings["Time Position"], 0, 1) * (CurrentTrack.Length or 1)
    CurrentTrack.Priority = Enum.AnimationPriority.Action4
    CurrentTrack.Looped = Settings["Looped"]
    return newTrack
end

local function getanimid(assetId)
    local success, objects = pcall(function()
        return game:GetObjects("rbxassetid://" .. tostring(assetId))
    end)
    
    if success and objects and #objects > 0 then
        local obj = objects[1]
        if obj:IsA("Animation") then
            return tonumber(obj.AnimationId:match("%d+")) or assetId
        elseif obj:FindFirstChildOfClass("Animation") then
            local anim = obj:FindFirstChildOfClass("Animation")
            return tonumber(anim.AnimationId:match("%d+")) or assetId
        end
    end
    return assetId
end

RunService.RenderStepped:Connect(function()
if Settings["Looped"] and CurrentTrack and CurrentTrack.IsPlaying then
	CurrentTrack.Looped = Settings["Looped"]
end

if character:FindFirstChild("HumanoidRootPart") then
	local root = character.HumanoidRootPart
	if Settings["Stop Emote When Moving"] and CurrentTrack and CurrentTrack.IsPlaying then
		local moved = (root.Position - lastPosition).Magnitude > 0.1
		local jumped = humanoid and humanoid:GetState() == Enum.HumanoidStateType.Jumping
		if moved or jumped then
			CurrentTrack:Stop(Settings["Fade Out"])
			CurrentTrack = nil
		end
	end
	lastPosition = root.Position
end
end)

-- ========================================
-- MODERN UI DESIGN FUNCTIONS (FIXED)
-- ========================================

local function createSmoothTween(instance, properties, duration)
    duration = duration or 0.3
    local tween = TweenService:Create(
        instance,
        TweenInfo.new(duration, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
        properties
    )
    tween:Play()
    return tween
end

local function createGradient(parent, colorSequence)
    local gradient = Instance.new("UIGradient")
    gradient.Color = colorSequence or ColorSequence.new(Color3.fromRGB(30, 30, 35), Color3.fromRGB(20, 20, 25))
    gradient.Rotation = 90
    gradient.Parent = parent
    return gradient
end

local function createCorner(parent, cornerRadius)
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, cornerRadius)
    corner.Parent = parent
    return corner
end

local function createStroke(parent, color, thickness)
    local stroke = Instance.new("UIStroke")
    stroke.Color = color or Color3.fromRGB(60, 60, 70)
    stroke.Thickness = thickness or 1
    stroke.Transparency = 0.5
    stroke.Parent = parent
    return stroke
end

-- FIXED: addHoverEffect hanya untuk TextButton
local function addHoverEffect(button, hoverColor, normalColor)
    -- Cek apakah button adalah TextButton atau memiliki child TextButton
    if not button:IsA("TextButton") and not button:IsA("ImageButton") then
        return -- Skip jika bukan button
    end
    
    normalColor = normalColor or button.BackgroundColor3
    
    button.MouseEnter:Connect(function()
        createSmoothTween(button, {BackgroundColor3 = hoverColor}, 0.2)
    end)
    
    button.MouseLeave:Connect(function()
        createSmoothTween(button, {BackgroundColor3 = normalColor}, 0.2)
    end)
    
    button.MouseButton1Down:Connect(function()
        createSmoothTween(button, {Size = button.Size - UDim2.new(0, scale("X", 2), 0, scale("Y", 2))}, 0.1)
    end)
    
    button.MouseButton1Up:Connect(function()
        createSmoothTween(button, {Size = button.Size + UDim2.new(0, scale("X", 2), 0, scale("Y", 2))}, 0.1)
    end)
end

-- ========================================
-- MAIN GUI CONTAINER
-- ========================================

local CoreGui = Services.CoreGui
local gui = Instance.new("ScreenGui")
gui.Name = "GazeEmoteGUI"
gui.Parent = CoreGui
gui.Enabled = false
gui.DisplayOrder = 999
gui.ResetOnSpawn = false

local mainContainer = Instance.new("Frame")
mainContainer.Size = UDim2.new(0, scale("X", 650), 0, scale("Y", 450))
mainContainer.Position = UDim2.new(0.5, -scale("X", 325), 0.5, -scale("Y", 225))
mainContainer.BackgroundColor3 = Color3.fromRGB(18, 18, 22)
mainContainer.Active = true
mainContainer.Draggable = true
mainContainer.Parent = gui
mainContainer.ClipsDescendants = true

createCorner(mainContainer, 16)
createStroke(mainContainer, Color3.fromRGB(70, 70, 85), 2)

local shadow = Instance.new("ImageLabel")
shadow.Size = UDim2.new(1, 40, 1, 40)
shadow.Position = UDim2.new(0, -20, 0, -20)
shadow.BackgroundTransparency = 1
shadow.Image = "rbxasset://textures/ui/GuiImagePlaceholder.png"
shadow.ImageColor3 = Color3.fromRGB(0, 0, 0)
shadow.ImageTransparency = 0.7
shadow.ScaleType = Enum.ScaleType.Slice
shadow.SliceCenter = Rect.new(10, 10, 90, 90)
shadow.ZIndex = -1
shadow.Parent = mainContainer

createGradient(mainContainer, ColorSequence.new{
    ColorSequenceKeypoint.new(0, Color3.fromRGB(22, 22, 28)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(15, 15, 20))
})

local parentFrame = mainContainer.Parent

local function clampPosition()
    local parentSize = parentFrame.AbsoluteSize
    local containerSize = mainContainer.AbsoluteSize
    local extraX = containerSize.X * 0.5
    local extraY = containerSize.Y * 0.5
    local x = mainContainer.Position.X.Scale * parentSize.X + mainContainer.Position.X.Offset
    local y = mainContainer.Position.Y.Scale * parentSize.Y + mainContainer.Position.Y.Offset
    local clampedX = math.clamp(x, -extraX, parentSize.X - containerSize.X + extraX)
    local clampedY = math.clamp(y, -extraY, parentSize.Y - containerSize.Y + extraY)
    mainContainer.Position = UDim2.new(0, clampedX, 0, clampedY)
end

mainContainer:GetPropertyChangedSignal("Position"):Connect(clampPosition)

-- END OF PART 1
-- Continue with Part 2...

-- ========================================
-- GAZE EMOTES - REDESIGNED UI (PART 2/5)
-- Header, Tabs, and Controls - FIXED
-- ========================================

-- PASTE THIS AFTER PART 1

-- ========================================
-- HEADER & TITLE
-- ========================================

local titleBar = Instance.new("Frame")
titleBar.Size = UDim2.new(1, 0, 0, scale("Y", 50))
titleBar.BackgroundColor3 = Color3.fromRGB(25, 25, 32)
titleBar.Parent = mainContainer
createCorner(titleBar, 16)

local titleIcon = Instance.new("TextLabel")
titleIcon.Size = UDim2.new(0, scale("X", 40), 0, scale("Y", 40))
titleIcon.Position = UDim2.new(0, scale("X", 10), 0.5, -scale("Y", 20))
titleIcon.BackgroundColor3 = Color3.fromRGB(100, 80, 200)
titleIcon.Text = "🎭"
titleIcon.TextColor3 = Color3.new(1, 1, 1)
titleIcon.Font = Enum.Font.GothamBold
titleIcon.TextScaled = true
titleIcon.Parent = titleBar
createCorner(titleIcon, 10)

local title = Instance.new("TextLabel")
title.Size = UDim2.new(0, scale("X", 200), 0, scale("Y", 30))
title.Position = UDim2.new(0, scale("X", 60), 0.5, -scale("Y", 15))
title.BackgroundTransparency = 1
title.Text = "Gaze Emotes"
title.TextColor3 = Color3.fromRGB(240, 240, 255)
title.Font = Enum.Font.GothamBold
title.TextSize = scale("Y", 20)
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = titleBar

local titleAccent = Instance.new("TextLabel")
titleAccent.Size = UDim2.new(0, scale("X", 80), 0, scale("Y", 16))
titleAccent.Position = UDim2.new(0, scale("X", 60), 0.5, scale("Y", 8))
titleAccent.BackgroundTransparency = 1
titleAccent.Text = "Professional"
titleAccent.TextColor3 = Color3.fromRGB(150, 130, 230)
titleAccent.Font = Enum.Font.Gotham
titleAccent.TextSize = scale("Y", 12)
titleAccent.TextXAlignment = Enum.TextXAlignment.Left
titleAccent.Parent = titleBar

-- ========================================
-- TAB BUTTONS (NO GRADIENT)
-- ========================================

local tabContainer = Instance.new("Frame")
tabContainer.Size = UDim2.new(1, -scale("X", 20), 0, scale("Y", 40))
tabContainer.Position = UDim2.new(0, scale("X", 10), 0, scale("Y", 60))
tabContainer.BackgroundTransparency = 1
tabContainer.Parent = mainContainer

local catalogTabBtn = Instance.new("TextButton")
catalogTabBtn.Size = UDim2.new(0.48, -scale("X", 5), 1, 0)
catalogTabBtn.Position = UDim2.new(0, 0, 0, 0)
catalogTabBtn.BackgroundColor3 = Color3.fromRGB(80, 60, 180)
catalogTabBtn.Text = "📚 Catalog"
catalogTabBtn.TextColor3 = Color3.new(1, 1, 1)
catalogTabBtn.Font = Enum.Font.GothamBold
catalogTabBtn.TextSize = scale("Y", 16)
catalogTabBtn.Parent = tabContainer
createCorner(catalogTabBtn, 10)

addHoverEffect(catalogTabBtn, Color3.fromRGB(100, 80, 200), Color3.fromRGB(80, 60, 180))

local savedTabBtn = Instance.new("TextButton")
savedTabBtn.Size = UDim2.new(0.48, -scale("X", 5), 1, 0)
savedTabBtn.Position = UDim2.new(0.52, scale("X", 5), 0, 0)
savedTabBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
savedTabBtn.Text = "⭐ Saved"
savedTabBtn.TextColor3 = Color3.fromRGB(180, 180, 200)
savedTabBtn.Font = Enum.Font.GothamBold
savedTabBtn.TextSize = scale("Y", 16)
savedTabBtn.Parent = tabContainer
createCorner(savedTabBtn, 10)

addHoverEffect(savedTabBtn, Color3.fromRGB(50, 50, 60), Color3.fromRGB(40, 40, 50))

-- ========================================
-- DIVIDER LINE
-- ========================================

local divider = Instance.new("Frame")
divider.Size = UDim2.new(0, scale("X", 2), 1, -scale("Y", 110))
divider.Position = UDim2.new(0.62, -scale("X", 1), 0, scale("Y", 110))
divider.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
divider.BorderSizePixel = 0
divider.Parent = mainContainer
createCorner(divider, 1)

-- ========================================
-- CATALOG FRAME
-- ========================================

local catalogFrame = Instance.new("Frame")
catalogFrame.Size = UDim2.new(0.62, -scale("X", 15), 1, -scale("Y", 115))
catalogFrame.Position = UDim2.new(0, scale("X", 10), 0, scale("Y", 110))
catalogFrame.BackgroundTransparency = 1
catalogFrame.Visible = true
catalogFrame.Parent = mainContainer

-- Search Box (Modern)
local searchContainer = Instance.new("Frame")
searchContainer.Size = UDim2.new(0.45, 0, 0, scale("Y", 36))
searchContainer.Position = UDim2.new(0, 0, 0, 0)
searchContainer.BackgroundColor3 = Color3.fromRGB(30, 30, 38)
searchContainer.Parent = catalogFrame
createCorner(searchContainer, 10)

local searchIcon = Instance.new("TextLabel")
searchIcon.Size = UDim2.new(0, scale("X", 30), 1, 0)
searchIcon.Position = UDim2.new(0, scale("X", 5), 0, 0)
searchIcon.BackgroundTransparency = 1
searchIcon.Text = "🔍"
searchIcon.TextSize = scale("Y", 16)
searchIcon.Parent = searchContainer

local searchBox = Instance.new("TextBox")
searchBox.Size = UDim2.new(1, -scale("X", 40), 1, 0)
searchBox.Position = UDim2.new(0, scale("X", 35), 0, 0)
searchBox.PlaceholderText = "Search animations..."
searchBox.PlaceholderColor3 = Color3.fromRGB(100, 100, 120)
searchBox.BackgroundTransparency = 1
searchBox.TextColor3 = Color3.fromRGB(230, 230, 250)
searchBox.Font = Enum.Font.Gotham
searchBox.TextSize = scale("Y", 14)
searchBox.TextXAlignment = Enum.TextXAlignment.Left
searchBox.ClearTextOnFocus = false
searchBox.Text = ""
searchBox.Parent = searchContainer

searchBox:GetPropertyChangedSignal("Text"):Connect(function()
    if searchBox.Text ~= "" then
        createSmoothTween(searchContainer, {BackgroundColor3 = Color3.fromRGB(40, 40, 50)}, 0.2)
    else
        createSmoothTween(searchContainer, {BackgroundColor3 = Color3.fromRGB(30, 30, 38)}, 0.2)
    end
end)

-- Refresh Button (NO GRADIENT)
local refreshBtn = Instance.new("TextButton")
refreshBtn.Size = UDim2.new(0.25, -scale("X", 4), 0, scale("Y", 36))
refreshBtn.Position = UDim2.new(0.47, scale("X", 2), 0, 0)
refreshBtn.BackgroundColor3 = Color3.fromRGB(40, 120, 220)
refreshBtn.Text = "🔄 Refresh"
refreshBtn.Font = Enum.Font.GothamBold
refreshBtn.TextSize = scale("Y", 13)
refreshBtn.TextColor3 = Color3.new(1, 1, 1)
refreshBtn.Parent = catalogFrame
createCorner(refreshBtn, 10)

addHoverEffect(refreshBtn, Color3.fromRGB(60, 140, 240), Color3.fromRGB(40, 120, 220))

-- Sort Button (NO GRADIENT)
local sortBtn = Instance.new("TextButton")
sortBtn.Size = UDim2.new(0.28, -scale("X", 6), 0, scale("Y", 36))
sortBtn.Position = UDim2.new(0.72, scale("X", 4), 0, 0)
sortBtn.BackgroundColor3 = Color3.fromRGB(60, 50, 120)
sortBtn.Text = "📊 Sort"
sortBtn.Font = Enum.Font.GothamBold
sortBtn.TextSize = scale("Y", 12)
sortBtn.TextColor3 = Color3.new(1, 1, 1)
sortBtn.Parent = catalogFrame
createCorner(sortBtn, 10)

addHoverEffect(sortBtn, Color3.fromRGB(80, 70, 140), Color3.fromRGB(60, 50, 120))

-- ========================================
-- SAVED FRAME
-- ========================================

local savedFrame = Instance.new("Frame")
savedFrame.Size = UDim2.new(0.62, -scale("X", 15), 1, -scale("Y", 115))
savedFrame.Position = UDim2.new(0, scale("X", 10), 0, scale("Y", 110))
savedFrame.BackgroundTransparency = 1
savedFrame.Visible = false
savedFrame.Parent = mainContainer

local savedSearchContainer = Instance.new("Frame")
savedSearchContainer.Size = UDim2.new(1, 0, 0, scale("Y", 36))
savedSearchContainer.Position = UDim2.new(0, 0, 0, 0)
savedSearchContainer.BackgroundColor3 = Color3.fromRGB(30, 30, 38)
savedSearchContainer.Parent = savedFrame
createCorner(savedSearchContainer, 10)

local savedSearchIcon = Instance.new("TextLabel")
savedSearchIcon.Size = UDim2.new(0, scale("X", 30), 1, 0)
savedSearchIcon.Position = UDim2.new(0, scale("X", 5), 0, 0)
savedSearchIcon.BackgroundTransparency = 1
savedSearchIcon.Text = "⭐"
savedSearchIcon.TextSize = scale("Y", 16)
savedSearchIcon.Parent = savedSearchContainer

local savedSearch = Instance.new("TextBox")
savedSearch.Size = UDim2.new(1, -scale("X", 40), 1, 0)
savedSearch.Position = UDim2.new(0, scale("X", 35), 0, 0)
savedSearch.PlaceholderText = "Search saved emotes..."
savedSearch.PlaceholderColor3 = Color3.fromRGB(100, 100, 120)
savedSearch.BackgroundTransparency = 1
savedSearch.TextColor3 = Color3.fromRGB(230, 230, 250)
savedSearch.Font = Enum.Font.Gotham
savedSearch.TextSize = scale("Y", 14)
savedSearch.TextXAlignment = Enum.TextXAlignment.Left
savedSearch.ClearTextOnFocus = false
savedSearch.Text = ""
savedSearch.Parent = savedSearchContainer

-- Scroll Frames
local savedScroll = Instance.new("ScrollingFrame")
savedScroll.Size = UDim2.new(1, 0, 1, -scale("Y", 44))
savedScroll.Position = UDim2.new(0, 0, 0, scale("Y", 44))
savedScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
savedScroll.ScrollBarThickness = 4
savedScroll.BackgroundTransparency = 1
savedScroll.BorderSizePixel = 0
savedScroll.ScrollBarImageColor3 = Color3.fromRGB(80, 80, 100)
savedScroll.Parent = savedFrame

local savedEmptyLabel = Instance.new("TextLabel")
savedEmptyLabel.Size = UDim2.new(1, 0, 0, scale("Y", 40))
savedEmptyLabel.Position = UDim2.new(0, 0, 0.5, -scale("Y", 20))
savedEmptyLabel.BackgroundTransparency = 1
savedEmptyLabel.Text = "💫 No saved emotes yet"
savedEmptyLabel.TextColor3 = Color3.fromRGB(150, 150, 170)
savedEmptyLabel.Font = Enum.Font.GothamBold
savedEmptyLabel.TextSize = scale("Y", 16)
savedEmptyLabel.Visible = false
savedEmptyLabel.Parent = savedScroll

local savedLayout = Instance.new("UIGridLayout")
savedLayout.CellSize = UDim2.new(0, scale("X", 125), 0, scale("Y", 210))
savedLayout.CellPadding = UDim2.new(0, scale("X", 10), 0, scale("Y", 10))
savedLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
savedLayout.Parent = savedScroll

-- ========================================
-- SETTINGS FRAME (RIGHT SIDE)
-- ========================================

local settingsFrame = Instance.new("Frame")
settingsFrame.Size = UDim2.new(0.38, -scale("X", 15), 1, -scale("Y", 115))
settingsFrame.Position = UDim2.new(0.62, scale("X", 5), 0, scale("Y", 110))
settingsFrame.BackgroundTransparency = 1
settingsFrame.Parent = mainContainer

local settingsTitle = Instance.new("TextLabel")
settingsTitle.Size = UDim2.new(1, 0, 0, scale("Y", 32))
settingsTitle.BackgroundTransparency = 1
settingsTitle.Text = "⚙️ Settings"
settingsTitle.TextColor3 = Color3.fromRGB(240, 240, 255)
settingsTitle.Font = Enum.Font.GothamBold
settingsTitle.TextSize = scale("Y", 18)
settingsTitle.TextXAlignment = Enum.TextXAlignment.Left
settingsTitle.Parent = settingsFrame

local scrollFrame = Instance.new("ScrollingFrame")
scrollFrame.Size = UDim2.new(1, -scale("X", 5), 1, -scale("Y", 40))
scrollFrame.Position = UDim2.new(0, 0, 0, scale("Y", 38))
scrollFrame.BackgroundTransparency = 1
scrollFrame.BorderSizePixel = 0
scrollFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
scrollFrame.ScrollBarThickness = 4
scrollFrame.ScrollBarImageColor3 = Color3.fromRGB(80, 80, 100)
scrollFrame.Parent = settingsFrame

local function lockX()
    scrollFrame.CanvasPosition = Vector2.new(0, scrollFrame.CanvasPosition.Y)
end
scrollFrame:GetPropertyChangedSignal("CanvasPosition"):Connect(lockX)

local listLayout = Instance.new("UIListLayout", scrollFrame)
listLayout.Padding = UDim.new(0, 8)
listLayout.FillDirection = Enum.FillDirection.Vertical
listLayout.SortOrder = Enum.SortOrder.LayoutOrder

listLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    scrollFrame.CanvasSize = UDim2.new(0, 0, 0, listLayout.AbsoluteContentSize.Y + 10)
end)

function GetReal(id)
    local ok, obj = pcall(function()
        return game:GetObjects("rbxassetid://"..tostring(id))
    end)
    if ok and obj and #obj > 0 then
        local anim = obj[1]
        if anim:IsA("Animation") and anim.AnimationId ~= "" then
            return tonumber(anim.AnimationId:match("%d+"))
        end
    end
end

Settings._sliders = {}
Settings._toggles = {}

-- END OF PART 2
-- Continue with Part 3...

-- ========================================
-- GAZE EMOTES - REDESIGNED UI (PART 3/5)
-- Sliders, Toggles - NO GRADIENT/STROKE
-- ========================================

-- PASTE THIS AFTER PART 2

-- ========================================
-- MODERN SLIDER CREATOR (NO GRADIENT)
-- ========================================

local function createSlider(name, min, max, default)
    Settings[name] = default or min

    local container = Instance.new("Frame")
    container.Size = UDim2.new(1, 0, 0, scale("Y", 75))
    container.BackgroundColor3 = Color3.fromRGB(28, 28, 36)
    container.Parent = scrollFrame
    createCorner(container, 12)

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.5, -scale("X", 10), 0, scale("Y", 22))
    label.Position = UDim2.new(0, scale("X", 12), 0, scale("Y", 8))
    label.BackgroundTransparency = 1
    label.Text = string.format("%s", name)
    label.TextColor3 = Color3.fromRGB(220, 220, 240)
    label.Font = Enum.Font.GothamBold
    label.TextSize = scale("Y", 13)
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = container

    local valueLabel = Instance.new("TextLabel")
    valueLabel.Size = UDim2.new(0, scale("X", 50), 0, scale("Y", 22))
    valueLabel.Position = UDim2.new(1, -scale("X", 62), 0, scale("Y", 8))
    valueLabel.BackgroundColor3 = Color3.fromRGB(40, 100, 200)
    valueLabel.Text = string.format("%.2f", Settings[name])
    valueLabel.TextColor3 = Color3.new(1, 1, 1)
    valueLabel.Font = Enum.Font.GothamBold
    valueLabel.TextSize = scale("Y", 12)
    valueLabel.Parent = container
    createCorner(valueLabel, 6)

    local sliderBar = Instance.new("Frame")
    sliderBar.Size = UDim2.new(1, -scale("X", 24), 0, scale("Y", 16))
    sliderBar.Position = UDim2.new(0, scale("X", 12), 0, scale("Y", 45))
    sliderBar.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
    sliderBar.Parent = container
    createCorner(sliderBar, 8)

    local sliderFill = Instance.new("Frame")
    sliderFill.Size = UDim2.new(0, 0, 1, 0)
    sliderFill.BackgroundColor3 = Color3.fromRGB(80, 140, 255)
    sliderFill.Parent = sliderBar
    createCorner(sliderFill, 8)

    local thumb = Instance.new("Frame")
    thumb.Size = UDim2.new(0, scale("X", 24), 0, scale("Y", 24))
    thumb.AnchorPoint = Vector2.new(0.5, 0.5)
    thumb.Position = UDim2.new(0, 0, 0.5, 0)
    thumb.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    thumb.Parent = sliderBar
    createCorner(thumb, 12)

    local function tweenVisual(rel)
        local visualRel = math.clamp(rel, 0, 1)
        createSmoothTween(sliderFill, {Size = UDim2.new(visualRel, 0, 1, 0)}, 0.15)
        createSmoothTween(thumb, {Position = UDim2.new(visualRel, 0, 0.5, 0)}, 0.15)
    end

    local function applyValue(value)
        Settings[name] = math.clamp(value, min, max)
        valueLabel.Text = string.format("%.2f", Settings[name])
        local rel = (Settings[name] - min) / (max - min)
        tweenVisual(rel)

        if CurrentTrack and CurrentTrack.IsPlaying then
            if name == "Speed" then
                CurrentTrack:AdjustSpeed(Settings["Speed"])
            elseif name == "Weight" then
                local weight = Settings["Weight"]
                if weight == 0 then weight = 0.001 end
                CurrentTrack:AdjustWeight(weight)
            elseif name == "Time Position" then
                if CurrentTrack.Length > 0 then
                    CurrentTrack.TimePosition = math.clamp(value, 0, 1) * CurrentTrack.Length
                end
            end
        end
    end

    local dragging = false
    local function updateFromInput(input)
        local relX = math.clamp((input.Position.X - sliderBar.AbsolutePosition.X) / sliderBar.AbsoluteSize.X, 0, 1)
        local value = math.floor((min + (max - min) * relX) * 100) / 100
        applyValue(value)
    end

    sliderBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            updateFromInput(input)
            createSmoothTween(thumb, {Size = UDim2.new(0, scale("X", 28), 0, scale("Y", 28))}, 0.1)
        end
    end)

    thumb.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            updateFromInput(input)
            createSmoothTween(thumb, {Size = UDim2.new(0, scale("X", 28), 0, scale("Y", 28))}, 0.1)
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            updateFromInput(input)
        end
    end)

    UserInputService.InputEnded:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) then
            dragging = false
            createSmoothTween(thumb, {Size = UDim2.new(0, scale("X", 24), 0, scale("Y", 24))}, 0.1)
        end
    end)

    Settings._sliders[name] = applyValue
    applyValue(Settings[name])
end

-- ========================================
-- MODERN TOGGLE CREATOR (NO GRADIENT)
-- ========================================

local function createToggle(name)
    Settings[name] = Settings[name] or false

    local container = Instance.new("Frame")
    container.Size = UDim2.new(1, 0, 0, scale("Y", 50))
    container.BackgroundColor3 = Color3.fromRGB(28, 28, 36)
    container.Parent = scrollFrame
    createCorner(container, 12)

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.65, -scale("X", 10), 1, 0)
    label.Position = UDim2.new(0, scale("X", 12), 0, 0)
    label.BackgroundTransparency = 1
    label.Text = name
    label.TextColor3 = Color3.fromRGB(220, 220, 240)
    label.Font = Enum.Font.GothamBold
    label.TextSize = scale("Y", 13)
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = container

    local toggleTrack = Instance.new("Frame")
    toggleTrack.Size = UDim2.new(0, scale("X", 60), 0, scale("Y", 30))
    toggleTrack.Position = UDim2.new(1, -scale("X", 72), 0.5, -scale("Y", 15))
    toggleTrack.BackgroundColor3 = Color3.fromRGB(60, 60, 75)
    toggleTrack.Parent = container
    createCorner(toggleTrack, 15)

    local toggleThumb = Instance.new("Frame")
    toggleThumb.Size = UDim2.new(0, scale("X", 24), 0, scale("Y", 24))
    toggleThumb.Position = UDim2.new(0, scale("X", 3), 0.5, -scale("Y", 12))
    toggleThumb.BackgroundColor3 = Color3.fromRGB(200, 200, 210)
    toggleThumb.Parent = toggleTrack
    createCorner(toggleThumb, 12)

    local function applyVisual(state)
        if state then
            createSmoothTween(toggleTrack, {BackgroundColor3 = Color3.fromRGB(80, 200, 120)}, 0.25)
            createSmoothTween(toggleThumb, {
                Position = UDim2.new(1, -scale("X", 27), 0.5, -scale("Y", 12)),
                BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            }, 0.25)
        else
            createSmoothTween(toggleTrack, {BackgroundColor3 = Color3.fromRGB(60, 60, 75)}, 0.25)
            createSmoothTween(toggleThumb, {
                Position = UDim2.new(0, scale("X", 3), 0.5, -scale("Y", 12)),
                BackgroundColor3 = Color3.fromRGB(200, 200, 210)
            }, 0.25)
        end
    end

    local toggleBtn = Instance.new("TextButton")
    toggleBtn.Size = UDim2.new(1, 0, 1, 0)
    toggleBtn.BackgroundTransparency = 1
    toggleBtn.Text = ""
    toggleBtn.Parent = toggleTrack

    toggleBtn.MouseButton1Click:Connect(function()
        Settings[name] = not Settings[name]
        applyVisual(Settings[name])
    end)

    toggleBtn.MouseEnter:Connect(function()
        createSmoothTween(toggleThumb, {Size = UDim2.new(0, scale("X", 26), 0, scale("Y", 26))}, 0.15)
    end)

    toggleBtn.MouseLeave:Connect(function()
        createSmoothTween(toggleThumb, {Size = UDim2.new(0, scale("X", 24), 0, scale("Y", 24))}, 0.15)
    end)

    applyVisual(Settings[name])
    Settings._toggles[name] = applyVisual
end

-- ========================================
-- UNIFIED EDIT FUNCTIONS
-- ========================================

function Settings:EditSlider(targetName, newValue)
    local apply = self._sliders[targetName]
    if apply then
        apply(newValue)
    end
end

function Settings:EditToggle(targetName, newValue)
    local apply = self._toggles[targetName]
    if apply then
        Settings[targetName] = newValue
        apply(newValue)
    end
end

-- ========================================
-- MODERN BUTTON CREATOR (NO GRADIENT)
-- ========================================

local function createButton(name, callback)
    local container = Instance.new("Frame")
    container.Size = UDim2.new(1, 0, 0, scale("Y", 50))
    container.BackgroundColor3 = Color3.fromRGB(80, 60, 180)
    container.Parent = scrollFrame
    createCorner(container, 12)

    local button = Instance.new("TextButton")
    button.Size = UDim2.new(1, 0, 1, 0)
    button.BackgroundTransparency = 1
    button.Text = name
    button.TextColor3 = Color3.new(1, 1, 1)
    button.Font = Enum.Font.GothamBold
    button.TextSize = scale("Y", 15)
    button.Parent = container

    addHoverEffect(container, Color3.fromRGB(100, 80, 200), Color3.fromRGB(80, 60, 180))

    button.MouseButton1Click:Connect(function()
        if typeof(callback) == "function" then
            callback()
        end
    end)

    return button
end

-- ========================================
-- CREATE ALL SETTINGS CONTROLS
-- ========================================

local resetButton = createButton("🔄 Reset All Settings", function() end)
createToggle("Preview")
createToggle("Stop Emote When Moving")
createToggle("Looped")
createSlider("Speed", 0, 5, Settings["Speed"])
createSlider("Time Position", 0, 1, Settings["Time Position"])
createSlider("Weight", 0, 1, Settings["Weight"])
createSlider("Fade In", 0, 2, Settings["Fade In"])
createSlider("Fade Out", 0, 2, Settings["Fade Out"])
createToggle("Allow Invisible   ")
createToggle("Stop Other Animations On Play")

resetButton.MouseButton1Click:Connect(function()
    Settings:EditToggle("Stop Emote When Moving", true)
    Settings:EditToggle("Stop Other Animations On Play", true)
    Settings:EditToggle("Preview", false)
    Settings:EditSlider("Fade In", 0.1)
    Settings:EditSlider("Fade Out", 0.1)
    Settings:EditSlider("Weight", 1)
    Settings:EditSlider("Speed", 1)
    Settings:EditToggle("Allow Invisible  ", true)
    Settings:EditSlider("Time Position", 0)
    Settings:EditToggle("Freeze On Finish", false)
    Settings:EditToggle("Looped", true)
end)

-- ========================================
-- COLLISION HANDLING (UNCHANGED)
-- ========================================

local originalCollisionStates = {}
local lastFixClipState = Settings["Allow Invisible  "]

local function saveCollisionStates()
    for _, part in ipairs(character:GetDescendants()) do
        if part:IsA("BasePart") and part ~= character.PrimaryPart then
            originalCollisionStates[part] = part.CanCollide
        end
    end
end

local function disableCollisionsExceptRootPart()
    if not Settings["Allow Invisible  "] then
        return
    end
    for _, part in ipairs(character:GetDescendants()) do
        if part:IsA("BasePart") and part ~= character.PrimaryPart then
            part.CanCollide = false
        end
    end
end

local function restoreCollisionStates()
    for part, canCollide in pairs(originalCollisionStates) do
        if part and part.Parent then
            part.CanCollide = canCollide
        end
    end
    originalCollisionStates = {}
end

saveCollisionStates()

local connection
connection = RunService.Stepped:Connect(function()
    if character and character.Parent then
        local currentFixClip = Settings["Allow Invisible  "]
        if lastFixClipState ~= currentFixClip then
            if currentFixClip then
                saveCollisionStates()
                disableCollisionsExceptRootPart()
            else
                restoreCollisionStates()
            end
            lastFixClipState = currentFixClip
        elseif currentFixClip then
            disableCollisionsExceptRootPart()
        end
    else
        restoreCollisionStates()
        if connection then
            connection:Disconnect()
        end
    end
end)

player.CharacterAdded:Connect(function(newCharacter)
    restoreCollisionStates()
    character = newCharacter
    humanoid = newCharacter:WaitForChild("Humanoid")
    saveCollisionStates()
    lastFixClipState = Settings["Allow Invisible  "]
    if connection then
        connection:Disconnect()
    end
    connection = RunService.Stepped:Connect(function()
        if character and character.Parent then
            local currentFixClip = Settings["Allow Invisible  "]
            if lastFixClipState ~= currentFixClip then
                if currentFixClip then
                    saveCollisionStates()
                    disableCollisionsExceptRootPart()
                else
                    restoreCollisionStates()
                end
                lastFixClipState = currentFixClip
            elseif currentFixClip then
                disableCollisionsExceptRootPart()
            end
        else
            restoreCollisionStates()
            if connection then
                connection:Disconnect()
            end
        end
    end)
end)

-- END OF PART 3
-- Continue with Part 4A...

-- ========================================
-- GAZE EMOTES - REDESIGNED UI (PART 4A/5)
-- Catalog System & Cards - FIXED
-- ========================================

-- PASTE THIS AFTER PART 3

-- ========================================
-- CATALOG API CONFIGURATION
-- ========================================

local CATALOG_URL = "https://catalog.roproxy.com/v2/search/items/details"
local EMOTE_ASSET_TYPE = 61
local BIG_FETCH_LIMIT = 120
local PAGE_SIZE_TINY = 10
local THE_SORT_LIST = {"Updated", "Relevance", "Favorited", "Sales", "PriceAsc", "PriceDesc"}

local ITEM_CACHE = {}
local NEXT_API_CURSOR = nil
local CURRENT_PAGE_NUMBER = 1
local CURRENT_SORT_OPTION = "Updated"
local CURRENT_SEARCH_TEXT = ""

local function GetEmoteDataFromWeb()
    local url_parts = {
        CATALOG_URL .. "?model.assetTypeIds=" .. EMOTE_ASSET_TYPE,
        "&model.includeNotForSale=true",
        "&limit=" .. BIG_FETCH_LIMIT,
        "&sortOrder=Desc",
        "&model.sortType=" .. CURRENT_SORT_OPTION
    }
    
    if CURRENT_SEARCH_TEXT ~= "" then
        url_parts[#url_parts + 1] = "&model.keyword=" .. HttpService:UrlEncode(CURRENT_SEARCH_TEXT)
    end
    
    if NEXT_API_CURSOR then
        url_parts[#url_parts + 1] = "&cursor=" .. NEXT_API_CURSOR
    end
    
    local final_url = table.concat(url_parts)
    local response
    local success, result = pcall(function()
        return request({Url = final_url, Method = "GET"})
    end)

    if not success or not result or not result.Success then
        warn("API Request Failed")
        return false
    end

    response = result.Body
    local data_table
    success, data_table = pcall(function()
        return HttpService:JSONDecode(response)
    end)

    if not success or not data_table or not data_table.data then
        warn("JSON Parse Failed")
        return false
    end

    for _, item in pairs(data_table.data) do
        table.insert(ITEM_CACHE, item)
    end
    
    NEXT_API_CURSOR = data_table.nextPageCursor
    print("Loaded " .. #data_table.data .. " items. Total: " .. #ITEM_CACHE)
    return true
end

-- ========================================
-- VIEWPORT CREATOR FOR PREVIEWS
-- ========================================

local function createViewport(size, position, parent)
    local viewportContainer = Instance.new("Frame")
    viewportContainer.Size = size
    viewportContainer.BackgroundTransparency = 1
    viewportContainer.Position = position
    viewportContainer.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
    viewportContainer.BorderSizePixel = 0
    viewportContainer.Parent = parent
    createCorner(viewportContainer, 12)
    
    local viewport = Instance.new("ViewportFrame")
    viewport.Size = UDim2.new(1, -4, 1, -4)
    viewport.Position = UDim2.new(0, 2, 0, 2)
    viewport.BackgroundColor3 = Color3.fromRGB(10, 10, 15)
    viewport.BackgroundTransparency = 1
    viewport.BorderSizePixel = 0
    viewport.Parent = viewportContainer
    
    local worldModel = Instance.new("WorldModel")
    worldModel.Parent = viewport
    
    local camera = Instance.new("Camera")
    camera.CameraType = Enum.CameraType.Scriptable
    viewport.CurrentCamera = camera
    
    local dummy = Players:CreateHumanoidModelFromUserId(player.UserId)
    dummy.Parent = worldModel
    
    local hrp = dummy:FindFirstChild("HumanoidRootPart")
    if hrp then hrp.Transparency = 1 end
    
    for _, part in ipairs(dummy:GetDescendants()) do
        if part:IsA("BasePart") then
            part.CanCollide = false
        end
    end
    
    local root = dummy.PrimaryPart or dummy:FindFirstChild("HumanoidRootPart") or dummy:FindFirstChildWhichIsA("BasePart")
    if root then
        dummy.PrimaryPart = root
        dummy:SetPrimaryPartCFrame(CFrame.new(0, 0, 0))
        camera.CFrame = CFrame.new(root.Position + Vector3.new(0, 2, 8), root.Position)
    end
    
    local dummyData = {
        Dummy = dummy,
        Viewport = viewport,
        Camera = camera,
        WorldModel = worldModel,
        Humanoid = dummy:FindFirstChildWhichIsA("Humanoid"),
        CurrentAnim = nil
    }
    
    local rotationAngle = 0
    local rotationSpeed = math.rad(30)
    
    RunService.RenderStepped:Connect(function(deltaTime)
        if dummyData.Humanoid and root then
            rotationAngle = rotationAngle + rotationSpeed * deltaTime
            local x = math.sin(rotationAngle) * 6
            local z = math.cos(rotationAngle) * 6
            dummyData.Camera.CFrame = CFrame.new(root.Position + Vector3.new(x, 3, z), root.Position)
        end
    end)
    
    return viewportContainer, dummyData
end

local function playAnimation(dummyData, animId)
    if not dummyData or not dummyData.Humanoid then return end
    
    if dummyData.CurrentAnim then
        dummyData.CurrentAnim:Stop()
        dummyData.CurrentAnim:Destroy()
    end
    
    if not dummyData.Humanoid:FindFirstChildOfClass("Animator") then
        Instance.new("Animator", dummyData.Humanoid)
    end
    
    local animation = Instance.new("Animation")
    animation.AnimationId = "rbxassetid://" .. tostring(animId)
    
    local animator = dummyData.Humanoid:FindFirstChildOfClass("Animator")
    local animTrack = animator:LoadAnimation(animation)
    
    dummyData.CurrentAnim = animTrack
    animTrack.Looped = true
    animTrack:Play()
    
    return animTrack
end

-- ========================================
-- MODERN CARD CREATOR (NO GRADIENT/STROKE)
-- ========================================

local function createCard(item)
    local card = Instance.new("Frame")
    card.Size = UDim2.new(0, scale("X", 125), 0, scale("Y", 195))
    card.BackgroundColor3 = Color3.fromRGB(32, 32, 40)
    card.Parent = scroll
    createCorner(card, 16)

    local thumbId = item.AssetId or item.Id
    
    if Settings["Preview"] == true then
        local viewport, dummy = createViewport(
            UDim2.fromScale(1, 0.55),
            UDim2.fromScale(0, 0),
            card
        )
        playAnimation(dummy, getanimid(thumbId))
    else
        local img = Instance.new("ImageLabel")
        img.Size = UDim2.new(1, -scale("X", 10), 0, scale("Y", 100))
        img.Position = UDim2.new(0, scale("X", 5), 0, scale("Y", 5))
        img.BackgroundTransparency = 1
        img.ScaleType = Enum.ScaleType.Fit
        pcall(function()
            img.Image = "rbxthumb://type=Asset&id=" .. tonumber(thumbId) .. "&w=150&h=150"
        end)
        img.Parent = card
        createCorner(img, 12)
    end

    local name = Instance.new("TextLabel")
    name.Size = UDim2.new(1, -scale("X", 10), 0, scale("Y", 32))
    name.Position = UDim2.new(0, scale("X", 5), 0, scale("Y", 110))
    name.BackgroundTransparency = 1
    name.Text = item.Name 
    name.TextScaled = true
    name.TextWrapped = true
    name.Font = Enum.Font.GothamBold
    name.TextColor3 = Color3.fromRGB(230, 230, 250)
    name.Parent = card

    local playBtn = Instance.new("TextButton")
    playBtn.Size = UDim2.new(0.45, -scale("X", 5), 0, scale("Y", 28))
    playBtn.Position = UDim2.new(0, scale("X", 5), 1, -scale("Y", 33))
    playBtn.BackgroundColor3 = Color3.fromRGB(80, 200, 120)
    playBtn.Text = "▶ Play"
    playBtn.Font = Enum.Font.GothamBold
    playBtn.TextSize = scale("Y", 12)
    playBtn.TextColor3 = Color3.new(1, 1, 1)
    playBtn.Parent = card
    createCorner(playBtn, 10)
    addHoverEffect(playBtn, Color3.fromRGB(100, 220, 140), Color3.fromRGB(80, 200, 120))

    playBtn.MouseButton1Click:Connect(function()
        LoadTrack(thumbId)
    end)

    local saveBtn = Instance.new("TextButton")
    saveBtn.Size = UDim2.new(0.45, -scale("X", 5), 0, scale("Y", 28))
    saveBtn.Position = UDim2.new(0.55, 0, 1, -scale("Y", 33))
    saveBtn.BackgroundColor3 = Color3.fromRGB(80, 120, 220)
    saveBtn.Text = "💾 Save"
    saveBtn.Font = Enum.Font.GothamBold
    saveBtn.TextSize = scale("Y", 12)
    saveBtn.TextColor3 = Color3.new(1, 1, 1)
    saveBtn.Parent = card
    createCorner(saveBtn, 10)
    addHoverEffect(saveBtn, Color3.fromRGB(100, 140, 240), Color3.fromRGB(80, 120, 220))

    saveBtn.MouseButton1Click:Connect(function()
        local alreadySaved = false
        for _, saved in ipairs(savedEmotes) do
            if saved.Id == item.Id then
                alreadySaved = true
                break
            end
        end
        if not alreadySaved then
            local function GetRealId(id)
                local ok, obj = pcall(function()
                    return game:GetObjects("rbxassetid://"..tostring(id))
                end)
                if not ok or not obj or #obj == 0 then return id end
                local target = obj[1]
                if target:IsA("Animation") and target.AnimationId ~= "" then
                    return tonumber(target.AnimationId:match("%d+")) or id
                elseif target:FindFirstChildOfClass("Animation") then
                    local anim = target:FindFirstChildOfClass("Animation")
                    return tonumber(anim.AnimationId:match("%d+")) or id
                end
                return id
            end
            
            table.insert(savedEmotes, {
                Id = item.Id,
                AssetId = thumbId,
                Name = item.Name or "Unknown",
                AnimationId = "rbxassetid://" .. GetRealId(thumbId),
                Favorite = false
            })
            saveEmotesToData()
            createSmoothTween(saveBtn, {BackgroundColor3 = Color3.fromRGB(100, 220, 100)}, 0.3)
            saveBtn.Text = "✓ Saved"
            task.wait(1)
            createSmoothTween(saveBtn, {BackgroundColor3 = Color3.fromRGB(80, 120, 220)}, 0.3)
            saveBtn.Text = "💾 Save"
        else
            saveBtn.Text = "✓ Already"
            task.wait(0.7)
            saveBtn.Text = "💾 Save"
        end
    end)

    return card
end

-- END OF PART 4A
-- Continue with Part 4B (Final)...

-- ========================================
-- GAZE EMOTES - REDESIGNED UI (PART 4B/5 - FINAL)
-- Scroll, Navigation, Saved Cards - FIXED
-- ========================================

-- PASTE THIS AFTER PART 4A

local scroll = Instance.new("ScrollingFrame")
scroll.Size = UDim2.new(1, 0, 1, -scale("Y", 110))
scroll.Position = UDim2.new(0, 0, 0, scale("Y", 44))
scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
scroll.ScrollBarThickness = 4
scroll.BackgroundTransparency = 1
scroll.BorderSizePixel = 0
scroll.ScrollBarImageColor3 = Color3.fromRGB(80, 80, 100)
scroll.Parent = catalogFrame

local layout = Instance.new("UIGridLayout", scroll)
layout.CellSize = UDim2.new(0, scale("X", 125), 0, scale("Y", 195))
layout.CellPadding = UDim2.new(0, scale("X", 8), 0, scale("Y", 8))
layout.HorizontalAlignment = Enum.HorizontalAlignment.Center

local emptyLabel = Instance.new("TextLabel", scroll)
emptyLabel.Size = UDim2.new(1, 0, 0, scale("Y", 40))
emptyLabel.Position = UDim2.new(0, 0, 0.5, -scale("Y", 20))
emptyLabel.BackgroundTransparency = 1
emptyLabel.Text = "🔍 No results found"
emptyLabel.TextColor3 = Color3.fromRGB(150, 150, 170)
emptyLabel.Font = Enum.Font.GothamBold
emptyLabel.TextSize = scale("Y", 16)
emptyLabel.Visible = false

local prevBtn = Instance.new("TextButton", catalogFrame)
prevBtn.Size = UDim2.new(0.4, -scale("X", 6), 0, scale("Y", 36))
prevBtn.Position = UDim2.new(0, scale("X", 4), 1, -scale("Y", 40))
prevBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 75)
prevBtn.Text = "◀ Previous"
prevBtn.Font = Enum.Font.GothamBold
prevBtn.TextSize = scale("Y", 13)
prevBtn.TextColor3 = Color3.new(1, 1, 1)
createCorner(prevBtn, 12)
addHoverEffect(prevBtn, Color3.fromRGB(80, 80, 100), Color3.fromRGB(60, 60, 75))

local nextBtn = Instance.new("TextButton", catalogFrame)
nextBtn.Size = UDim2.new(0.4, -scale("X", 6), 0, scale("Y", 36))
nextBtn.Position = UDim2.new(0.6, scale("X", 2), 1, -scale("Y", 40))
nextBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 75)
nextBtn.Text = "Next ▶"
nextBtn.Font = Enum.Font.GothamBold
nextBtn.TextSize = scale("Y", 13)
nextBtn.TextColor3 = Color3.new(1, 1, 1)
createCorner(nextBtn, 12)
addHoverEffect(nextBtn, Color3.fromRGB(80, 80, 100), Color3.fromRGB(60, 60, 75))

local pageBox = Instance.new("TextBox", catalogFrame)
pageBox.Size = UDim2.new(0.2, 0, 0, scale("Y", 36))
pageBox.Position = UDim2.new(0.4, scale("X", 2), 1, -scale("Y", 40))
pageBox.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
pageBox.Font = Enum.Font.GothamBold
pageBox.TextSize = scale("Y", 13)
pageBox.TextColor3 = Color3.new(1, 1, 1)
pageBox.Text = "Page 1"
createCorner(pageBox, 12)

local function showPage()
    for _, child in ipairs(scroll:GetChildren()) do
        if child:IsA("Frame") then child:Destroy() end
    end

    local start_index = (CURRENT_PAGE_NUMBER - 1) * PAGE_SIZE_TINY + 1
    local end_index = start_index + PAGE_SIZE_TINY - 1

    if start_index > #ITEM_CACHE and NEXT_API_CURSOR then
        pageBox.Text = "Loading..."
        local success = GetEmoteDataFromWeb()
        if not success then
            pageBox.Text = "Error"
            emptyLabel.Text = "❌ Failed to load"
            emptyLabel.Visible = true
            return
        end
        start_index = (CURRENT_PAGE_NUMBER - 1) * PAGE_SIZE_TINY + 1
        end_index = start_index + PAGE_SIZE_TINY - 1
    end

    pageBox.Text = "Page " .. tostring(CURRENT_PAGE_NUMBER)

    for i = start_index, math.min(end_index, #ITEM_CACHE) do
        local item = ITEM_CACHE[i]
        createCard({
            Id = item.id,
            AssetId = item.id,
            Name = item.name or "Unknown"
        })
        task.wait(0.01)
    end

    scroll.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + 8)
    emptyLabel.Visible = (#ITEM_CACHE == 0)
end

local function doNewSearch(keyword)
    CURRENT_SEARCH_TEXT = keyword or ""
    CURRENT_PAGE_NUMBER = 1
    NEXT_API_CURSOR = nil
    ITEM_CACHE = {}
    pageBox.Text = "Loading..."
    
    local success = GetEmoteDataFromWeb()
    if success then
        showPage()
    else
        pageBox.Text = "Failed"
        emptyLabel.Text = "❌ Search failed"
        emptyLabel.Visible = true
    end
end

refreshBtn.MouseButton1Click:Connect(function()
    doNewSearch(searchBox.Text)
end)

searchBox.FocusLost:Connect(function(enterPressed)
    if enterPressed then doNewSearch(searchBox.Text) end
end)

local currentSortIndex = 1
sortBtn.MouseButton1Click:Connect(function()
    currentSortIndex = currentSortIndex % #THE_SORT_LIST + 1
    CURRENT_SORT_OPTION = THE_SORT_LIST[currentSortIndex]
    sortBtn.Text = "📊 " .. CURRENT_SORT_OPTION
    doNewSearch(CURRENT_SEARCH_TEXT)
end)

nextBtn.MouseButton1Click:Connect(function()
    local currentStart = (CURRENT_PAGE_NUMBER * PAGE_SIZE_TINY) + 1
    if currentStart <= #ITEM_CACHE or NEXT_API_CURSOR then
        CURRENT_PAGE_NUMBER = CURRENT_PAGE_NUMBER + 1
        showPage()
    end
end)

prevBtn.MouseButton1Click:Connect(function()
    if CURRENT_PAGE_NUMBER > 1 then
        CURRENT_PAGE_NUMBER = CURRENT_PAGE_NUMBER - 1
        showPage()
    end
end)

UserInputService.InputBegan:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.Right then
        if CURRENT_PAGE_NUMBER * PAGE_SIZE_TINY < #ITEM_CACHE or NEXT_API_CURSOR then
            CURRENT_PAGE_NUMBER = CURRENT_PAGE_NUMBER + 1
            showPage()
        end
    elseif input.KeyCode == Enum.KeyCode.Left then
        if CURRENT_PAGE_NUMBER > 1 then
            CURRENT_PAGE_NUMBER = CURRENT_PAGE_NUMBER - 1
            showPage()
        end
    end
end)

pageBox.FocusLost:Connect(function(enterPressed)
    if not enterPressed then return end
    local text = pageBox.Text:gsub("%s+", "")
    local num = tonumber(text:match("%d+"))
    if not num or num < 1 then
        pageBox.Text = "Page " .. tostring(CURRENT_PAGE_NUMBER)
        return
    end
    local targetPage = math.floor(num)
    if targetPage == CURRENT_PAGE_NUMBER then
        pageBox.Text = "Page " .. tostring(CURRENT_PAGE_NUMBER)
        return
    end
    local requiredItems = (targetPage * PAGE_SIZE_TINY)
    while #ITEM_CACHE < requiredItems and NEXT_API_CURSOR ~= nil do
        GetEmoteDataFromWeb()
    end
    if #ITEM_CACHE >= requiredItems then
        CURRENT_PAGE_NUMBER = targetPage
        showPage()
    else
        pageBox.Text = "Not available"
    end
end)

local function createSavedCard(item)
    local card = Instance.new("Frame")
    card.Size = UDim2.new(0, scale("X", 125), 0, scale("Y", 210))
    card.BackgroundColor3 = Color3.fromRGB(32, 32, 40)
    createCorner(card, 16)

    if Settings["Preview"] then
        local viewport, dummy = createViewport(UDim2.fromScale(1, 0.5), UDim2.fromScale(0, 0), card)
        playAnimation(dummy, getanimid(item.Id))
    else
        local img = Instance.new("ImageLabel")
        img.Size = UDim2.new(1, -scale("X", 10), 0, scale("Y", 100))
        img.Position = UDim2.new(0, scale("X", 5), 0, scale("Y", 5))
        img.BackgroundTransparency = 1
        img.ScaleType = Enum.ScaleType.Fit
        pcall(function()
            img.Image = "rbxthumb://type=Asset&id=" .. tonumber(item.Id) .. "&w=150&h=150"
        end)
        img.Parent = card
        createCorner(img, 12)
    end

    local name = Instance.new("TextLabel")
    name.Size = UDim2.new(1, -scale("X", 10), 0, scale("Y", 32))
    name.Position = UDim2.new(0, scale("X", 5), 0, scale("Y", 110))
    name.BackgroundTransparency = 1
    name.Text = item.Name or "Unknown"
    name.TextScaled = true
    name.TextWrapped = true
    name.Font = Enum.Font.GothamBold
    name.TextColor3 = Color3.fromRGB(230, 230, 250)
    name.Parent = card

    local playBtn = Instance.new("TextButton")
    playBtn.Size = UDim2.new(0.45, -scale("X", 5), 0, scale("Y", 28))
    playBtn.Position = UDim2.new(0, scale("X", 5), 1, -scale("Y", 33))
    playBtn.BackgroundColor3 = Color3.fromRGB(80, 200, 120)
    playBtn.Text = "▶ Play"
    playBtn.Font = Enum.Font.GothamBold
    playBtn.TextSize = scale("Y", 12)
    playBtn.TextColor3 = Color3.new(1, 1, 1)
    playBtn.Parent = card
    createCorner(playBtn, 10)
    addHoverEffect(playBtn, Color3.fromRGB(100, 220, 140), Color3.fromRGB(80, 200, 120))

    playBtn.MouseButton1Click:Connect(function()
        LoadTrack(item.Id)
    end)

    local removeBtn = Instance.new("TextButton")
    removeBtn.Size = UDim2.new(0.45, -scale("X", 5), 0, scale("Y", 28))
    removeBtn.Position = UDim2.new(0.55, 0, 1, -scale("Y", 33))
    removeBtn.BackgroundColor3 = Color3.fromRGB(220, 80, 80)
    removeBtn.Text = "🗑 Remove"
    removeBtn.Font = Enum.Font.GothamBold
    removeBtn.TextSize = scale("Y", 11)
    removeBtn.TextColor3 = Color3.new(1, 1, 1)
    removeBtn.Parent = card
    createCorner(removeBtn, 10)
    addHoverEffect(removeBtn, Color3.fromRGB(240, 100, 100), Color3.fromRGB(220, 80, 80))

    local copyBtn = Instance.new("TextButton")
    copyBtn.Size = UDim2.new(0, scale("X", 45), 0, scale("Y", 24))
    copyBtn.Position = UDim2.new(0.5, -scale("X", 22.5), 0, scale("Y", 148))
    copyBtn.BackgroundColor3 = Color3.fromRGB(100, 100, 180)
    copyBtn.Text = "📋 ID"
    copyBtn.Font = Enum.Font.GothamBold
    copyBtn.TextSize = scale("Y", 11)
    copyBtn.TextColor3 = Color3.new(1, 1, 1)
    copyBtn.Parent = card
    createCorner(copyBtn, 8)
    addHoverEffect(copyBtn, Color3.fromRGB(120, 120, 200), Color3.fromRGB(100, 100, 180))

    copyBtn.MouseButton1Click:Connect(function()
        if setclipboard then
            setclipboard(item.AnimationId:gsub("rbxassetid://", ""))
        end
        copyBtn.Text = "✓ Copied"
        task.wait(0.7)
        copyBtn.Text = "📋 ID"
    end)

    local favBtn = Instance.new("TextButton")
    favBtn.Size = UDim2.new(0, scale("X", 28), 0, scale("Y", 28))
    favBtn.Position = UDim2.new(1, -scale("X", 34), 0, scale("Y", 6))
    favBtn.Text = item.Favorite and "★" or "☆"
    favBtn.Font = Enum.Font.GothamBold
    favBtn.TextSize = scale("Y", 18)
    favBtn.TextColor3 = Color3.fromRGB(255, 215, 0)
    favBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
    favBtn.Parent = card
    createCorner(favBtn, 14)

    favBtn.MouseButton1Click:Connect(function()
        item.Favorite = not item.Favorite
        favBtn.Text = item.Favorite and "★" or "☆"
        saveEmotesToData()
    end)

    removeBtn.MouseButton1Click:Connect(function()
        for i, saved in ipairs(savedEmotes) do
            if saved.Id == item.Id then
                table.remove(savedEmotes, i)
                saveEmotesToData()
                refreshSavedTab()
                break
            end
        end
    end)

    return card
end

function refreshSavedTab()
    for _, child in ipairs(savedScroll:GetChildren()) do
        if child:IsA("Frame") then child:Destroy() end
    end
    local text = (savedSearch.Text or ""):lower()
    local results = {}
    for _, item in ipairs(savedEmotes) do
        if text == "" or (item.Name and item.Name:lower():find(text)) then
            table.insert(results, item)
        end
    end
    table.sort(results, function(a, b)
        if a.Favorite ~= b.Favorite then
            return a.Favorite
        else
            return false
        end
    end)
    if #results > 0 then
        savedEmptyLabel.Visible = false
        for _, item in ipairs(results) do
            createSavedCard(item).Parent = savedScroll
        end
    else
        savedEmptyLabel.Visible = true
    end
    savedScroll.CanvasSize = UDim2.new(0, 0, 0, savedLayout.AbsoluteContentSize.Y + 8)
end

savedSearch:GetPropertyChangedSignal("Text"):Connect(refreshSavedTab)

catalogTabBtn.MouseButton1Click:Connect(function()
    catalogFrame.Visible = true
    savedFrame.Visible = false
    createSmoothTween(catalogTabBtn, {BackgroundColor3 = Color3.fromRGB(80, 60, 180)}, 0.3)
    createSmoothTween(catalogTabBtn, {TextColor3 = Color3.new(1, 1, 1)}, 0.3)
    createSmoothTween(savedTabBtn, {BackgroundColor3 = Color3.fromRGB(40, 40, 50)}, 0.3)
    createSmoothTween(savedTabBtn, {TextColor3 = Color3.fromRGB(180, 180, 200)}, 0.3)
end)

savedTabBtn.MouseButton1Click:Connect(function()
    catalogFrame.Visible = false
    savedFrame.Visible = true
    createSmoothTween(catalogTabBtn, {BackgroundColor3 = Color3.fromRGB(40, 40, 50)}, 0.3)
    createSmoothTween(catalogTabBtn, {TextColor3 = Color3.fromRGB(180, 180, 200)}, 0.3)
    createSmoothTween(savedTabBtn, {BackgroundColor3 = Color3.fromRGB(60, 180, 120)}, 0.3)
    createSmoothTween(savedTabBtn, {TextColor3 = Color3.new(1, 1, 1)}, 0.3)
    refreshSavedTab()
end)

doNewSearch("")

-- ========================================
-- TOGGLE BUTTON (NO GRADIENT)
-- ========================================

local screonGui = Instance.new("ScreenGui")
screonGui.Name = "ToggleButtonGui"
screonGui.ResetOnSpawn = false
screonGui.Parent = CoreGui
screonGui.Enabled = true

local btn = Instance.new("TextButton")
btn.Parent = screonGui
btn.Text = "🎭"
btn.Font = Enum.Font.GothamBold
btn.TextSize = scale("Y", 24)
btn.TextColor3 = Color3.new(1, 1, 1)
btn.Size = UDim2.new(0, 60, 0, 60)
btn.Position = UDim2.new(0, 20, 0.5, -30)
btn.BackgroundColor3 = Color3.fromRGB(80, 60, 180)
btn.Active = true
btn.Draggable = true
createCorner(btn, 16)

addHoverEffect(btn, Color3.fromRGB(100, 80, 200), Color3.fromRGB(80, 60, 180))

local btnFrame = btn.Parent

local function clampButtonPosition()
    local parentSize = btnFrame.AbsoluteSize
    local btnSize = btn.AbsoluteSize
    local clampedX = math.clamp(btn.Position.X.Scale * parentSize.X + btn.Position.X.Offset, 0, parentSize.X - btnSize.X)
    local clampedY = math.clamp(btn.Position.Y.Scale * parentSize.Y + btn.Position.Y.Offset, 0, parentSize.Y - btnSize.Y)
    btn.Position = UDim2.new(0, clampedX, 0, clampedY)
end

btn:GetPropertyChangedSignal("Position"):Connect(clampButtonPosition)

local function toggleGui()
    gui.Enabled = not gui.Enabled
    if gui.Enabled then
        mainContainer.Size = UDim2.new(0, 0, 0, 0)
        createSmoothTween(mainContainer, {
            Size = UDim2.new(0, scale("X", 650), 0, scale("Y", 450))
        }, 0.4)
    end
end

btn.MouseButton1Click:Connect(toggleGui)

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.UserInputType == Enum.UserInputType.Keyboard and input.KeyCode == Enum.KeyCode.G then
        toggleGui()
    end
end)

gui.Enabled = true
refreshSavedTab()

print("✨ Gaze Emotes UI Redesigned - Successfully Loaded!")
print("📌 Press 'G' or click 🎭 to toggle")

-- ========================================
-- END - ALL DONE! 🎉
-- ========================================