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

local CoreGui = Services.CoreGui
local gui = Instance.new("ScreenGui")
gui.Name = "GazeEmoteGUI"
gui.Parent = CoreGui
gui.Enabled = false
gui.DisplayOrder = 999

local function createGradient(parent, colorSequence) return end

local function createCorner(parent, cornerRadius)
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, cornerRadius)
    corner.Parent = parent
    return corner
end

-- 🎨 MODERN UI ENHANCEMENT: Smooth Shadow Effect
local function createShadow(parent, intensity)
    local shadow = Instance.new("ImageLabel")
    shadow.Name = "Shadow"
    shadow.Size = UDim2.new(1, 30, 1, 30)
    shadow.Position = UDim2.new(0, -15, 0, -15)
    shadow.BackgroundTransparency = 1
    shadow.Image = "rbxassetid://5554236805"
    shadow.ImageColor3 = Color3.fromRGB(0, 0, 0)
    shadow.ImageTransparency = intensity or 0.7
    shadow.ScaleType = Enum.ScaleType.Slice
    shadow.SliceCenter = Rect.new(23, 23, 277, 277)
    shadow.ZIndex = parent.ZIndex - 1
    shadow.Parent = parent
    return shadow
end

-- 🎨 MODERN UI ENHANCEMENT: Smooth Gradient Background
local function createModernGradient(parent)
    local gradient = Instance.new("UIGradient")
    gradient.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, Color3.fromRGB(45, 45, 55)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(25, 25, 35))
    }
    gradient.Rotation = 45
    gradient.Parent = parent
    return gradient
end

-- 🎨 MODERN UI ENHANCEMENT: Hover Animation
local function addHoverEffect(button, hoverColor, normalColor)
    button.MouseEnter:Connect(function()
        TweenService:Create(button, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {
            BackgroundColor3 = hoverColor,
            Size = button.Size + UDim2.new(0, 4, 0, 2)
        }):Play()
    end)
    
    button.MouseLeave:Connect(function()
        TweenService:Create(button, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {
            BackgroundColor3 = normalColor,
            Size = button.Size - UDim2.new(0, 4, 0, 2)
        }):Play()
    end)
end

-- 🎨 MAIN CONTAINER - Enhanced Dark Theme
local mainContainer = Instance.new("Frame")
mainContainer.Size = UDim2.new(0, scale("X", 620), 0, scale("Y", 420))
mainContainer.Position = UDim2.new(0.5, -scale("X", 310), 0.5, -scale("Y", 210))
mainContainer.BackgroundColor3 = Color3.fromRGB(22, 22, 28)
mainContainer.BorderSizePixel = 0
mainContainer.Active = true
mainContainer.Draggable = true
mainContainer.ClipsDescendants = false
mainContainer.Parent = gui

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

createCorner(mainContainer, 16)
createShadow(mainContainer, 0.5)

-- Modern Gradient Overlay
local overlayGradient = Instance.new("UIGradient")
overlayGradient.Color = ColorSequence.new{
    ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(200, 200, 200))
}
overlayGradient.Transparency = NumberSequence.new{
    NumberSequenceKeypoint.new(0, 0.97),
    NumberSequenceKeypoint.new(1, 0.99)
}
overlayGradient.Rotation = 135
overlayGradient.Parent = mainContainer

-- Subtle Border Stroke
local stroke = Instance.new("UIStroke")
stroke.Color = Color3.fromRGB(60, 60, 70)
stroke.Thickness = 1
stroke.Transparency = 0.5
stroke.Parent = mainContainer

-- 🎨 MODERN TITLE BAR
local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, scale("Y", 44))
title.BackgroundColor3 = Color3.fromRGB(30, 30, 38)
title.BorderSizePixel = 0
title.Text = "  ✨ Gaze Emotes"
title.TextColor3 = Color3.fromRGB(220, 220, 230)
title.Font = Enum.Font.GothamBold
title.TextSize = scale("Y", 18)
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = mainContainer
createCorner(title, 16)

-- Title Gradient
local titleGradient = Instance.new("UIGradient")
titleGradient.Color = ColorSequence.new{
    ColorSequenceKeypoint.new(0, Color3.fromRGB(50, 50, 65)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(30, 30, 40))
}
titleGradient.Rotation = 90
titleGradient.Parent = title

-- Title Accent Line
local accentLine = Instance.new("Frame")
accentLine.Size = UDim2.new(1, 0, 0, 2)
accentLine.Position = UDim2.new(0, 0, 1, -2)
accentLine.BackgroundColor3 = Color3.fromRGB(100, 150, 255)
accentLine.BorderSizePixel = 0
accentLine.Parent = title

local accentGradient = Instance.new("UIGradient")
accentGradient.Color = ColorSequence.new{
    ColorSequenceKeypoint.new(0, Color3.fromRGB(100, 150, 255)),
    ColorSequenceKeypoint.new(0.5, Color3.fromRGB(150, 100, 255)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(100, 150, 255))
}
accentGradient.Parent = accentLine

-- 🎨 MODERN TAB BUTTONS
local catalogTabBtn = Instance.new("TextButton")
catalogTabBtn.Size = UDim2.new(0.28, 0, 0, scale("Y", 32))
catalogTabBtn.Position = UDim2.new(0.06, 0, 0, scale("Y", 52))
catalogTabBtn.BackgroundColor3 = Color3.fromRGB(80, 120, 255)
catalogTabBtn.BorderSizePixel = 0
catalogTabBtn.AutoButtonColor = false
catalogTabBtn.Text = "📚 Catalog"
catalogTabBtn.TextColor3 = Color3.new(1, 1, 1)
catalogTabBtn.Font = Enum.Font.GothamBold
catalogTabBtn.TextSize = scale("Y", 14)
catalogTabBtn.Parent = mainContainer
createCorner(catalogTabBtn, 8)

local catalogStroke = Instance.new("UIStroke")
catalogStroke.Color = Color3.fromRGB(100, 140, 255)
catalogStroke.Thickness = 2
catalogStroke.Transparency = 0.3
catalogStroke.Parent = catalogTabBtn

local savedTabBtn = Instance.new("TextButton")
savedTabBtn.Size = UDim2.new(0.28, 0, 0, scale("Y", 32))
savedTabBtn.Position = UDim2.new(0.36, 0, 0, scale("Y", 52))
savedTabBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
savedTabBtn.BorderSizePixel = 0
savedTabBtn.AutoButtonColor = false
savedTabBtn.Text = "⭐ Saved"
savedTabBtn.TextColor3 = Color3.fromRGB(180, 180, 190)
savedTabBtn.Font = Enum.Font.GothamBold
savedTabBtn.TextSize = scale("Y", 14)
savedTabBtn.Parent = mainContainer
createCorner(savedTabBtn, 8)

local savedStroke = Instance.new("UIStroke")
savedStroke.Color = Color3.fromRGB(60, 60, 70)
savedStroke.Thickness = 1
savedStroke.Transparency = 0.5
savedStroke.Parent = savedTabBtn

addHoverEffect(catalogTabBtn, Color3.fromRGB(90, 130, 255), Color3.fromRGB(80, 120, 255))
addHoverEffect(savedTabBtn, Color3.fromRGB(50, 50, 60), Color3.fromRGB(40, 40, 50))

-- 🎨 VERTICAL DIVIDER - Modern Style
local divider = Instance.new("Frame")
divider.Size = UDim2.new(0, 1, 1, -scale("Y", 92))
divider.Position = UDim2.new(0.6, 0, 0, scale("Y", 92))
divider.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
divider.BorderSizePixel = 0
divider.Parent = mainContainer

local dividerGlow = Instance.new("UIGradient")
dividerGlow.Transparency = NumberSequence.new{
    NumberSequenceKeypoint.new(0, 0.8),
    NumberSequenceKeypoint.new(0.5, 0.3),
    NumberSequenceKeypoint.new(1, 0.8)
}
dividerGlow.Rotation = 90
dividerGlow.Parent = divider

-- 🎨 CATALOG FRAME
local catalogFrame = Instance.new("Frame")
catalogFrame.Size = UDim2.new(0.6, -scale("X", 16), 1, -scale("Y", 92))
catalogFrame.Position = UDim2.new(0, scale("X", 8), 0, scale("Y", 92))
catalogFrame.BackgroundTransparency = 1
catalogFrame.Visible = true
catalogFrame.Parent = mainContainer

-- Modern Search Box
local searchBox = Instance.new("TextBox")
searchBox.Size = UDim2.new(0.55, -scale("X", 4), 0, scale("Y", 32))
searchBox.Position = UDim2.new(0, scale("X", 4), 0, scale("Y", 4))
searchBox.PlaceholderText = "🔍 Search emotes..."
searchBox.PlaceholderColor3 = Color3.fromRGB(120, 120, 130)
searchBox.BackgroundColor3 = Color3.fromRGB(32, 32, 42)
searchBox.BorderSizePixel = 0
searchBox.TextColor3 = Color3.fromRGB(220, 220, 230)
searchBox.Font = Enum.Font.Gotham
searchBox.TextSize = scale("Y", 13)
searchBox.ClearTextOnFocus = false
searchBox.Text = ""
searchBox.Parent = catalogFrame
createCorner(searchBox, 8)

local searchStroke = Instance.new("UIStroke")
searchStroke.Color = Color3.fromRGB(70, 70, 80)
searchStroke.Thickness = 1
searchStroke.Transparency = 0.6
searchStroke.Parent = searchBox

local refreshBtn = Instance.new("TextButton")
refreshBtn.Size = UDim2.new(0.22, -scale("X", 4), 0, scale("Y", 32))
refreshBtn.Position = UDim2.new(0.55, scale("X", 2), 0, scale("Y", 4))
refreshBtn.BackgroundColor3 = Color3.fromRGB(50, 130, 250)
refreshBtn.BorderSizePixel = 0
refreshBtn.AutoButtonColor = false
refreshBtn.Text = "🔄 Refresh"
refreshBtn.Font = Enum.Font.GothamBold
refreshBtn.TextSize = scale("Y", 13)
refreshBtn.TextColor3 = Color3.new(1, 1, 1)
refreshBtn.Parent = catalogFrame
createCorner(refreshBtn, 8)
addHoverEffect(refreshBtn, Color3.fromRGB(60, 140, 255), Color3.fromRGB(50, 130, 250))

local sortBtn = Instance.new("TextButton")
sortBtn.Size = UDim2.new(0.23, -scale("X", 4), 0, scale("Y", 32))
sortBtn.Position = UDim2.new(0.77, scale("X", 2), 0, scale("Y", 4))
sortBtn.BackgroundColor3 = Color3.fromRGB(80, 70, 140)
sortBtn.BorderSizePixel = 0
sortBtn.AutoButtonColor = false
sortBtn.Text = "Sort: Relevance"
sortBtn.Font = Enum.Font.GothamBold
sortBtn.TextSize = scale("Y", 11)
sortBtn.TextColor3 = Color3.new(1, 1, 1)
sortBtn.Parent = catalogFrame
createCorner(sortBtn, 8)
addHoverEffect(sortBtn, Color3.fromRGB(90, 80, 150), Color3.fromRGB(80, 70, 140))

-- 🎨 SAVED FRAME
local savedFrame = Instance.new("Frame")
savedFrame.Size = UDim2.new(0.6, -scale("X", 16), 1, -scale("Y", 92))
savedFrame.Position = UDim2.new(0, scale("X", 8), 0, scale("Y", 92))
savedFrame.BackgroundTransparency = 1
savedFrame.Visible = false
savedFrame.Parent = mainContainer

local savedSearch = Instance.new("TextBox")
savedSearch.Size = UDim2.new(1, -scale("X", 8), 0, scale("Y", 32))
savedSearch.Position = UDim2.new(0, scale("X", 4), 0, scale("Y", 4))
savedSearch.PlaceholderText = "🔍 Search saved emotes..."
savedSearch.PlaceholderColor3 = Color3.fromRGB(120, 120, 130)
savedSearch.BackgroundColor3 = Color3.fromRGB(32, 32, 42)
savedSearch.BorderSizePixel = 0
savedSearch.TextColor3 = Color3.fromRGB(220, 220, 230)
savedSearch.Font = Enum.Font.Gotham
savedSearch.TextSize = scale("Y", 13)
savedSearch.ClearTextOnFocus = false
savedSearch.Text = ""
savedSearch.Parent = savedFrame
createCorner(savedSearch, 8)

local savedSearchStroke = Instance.new("UIStroke")
savedSearchStroke.Color = Color3.fromRGB(70, 70, 80)
savedSearchStroke.Thickness = 1
savedSearchStroke.Transparency = 0.6
savedSearchStroke.Parent = savedSearch

local savedScroll = Instance.new("ScrollingFrame")
savedScroll.Size = UDim2.new(1, -scale("X", 8), 1, -scale("Y", 44))
savedScroll.Position = UDim2.new(0, scale("X", 4), 0, scale("Y", 40))
savedScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
savedScroll.ScrollBarThickness = 4
savedScroll.ScrollBarImageColor3 = Color3.fromRGB(100, 100, 120)
savedScroll.BackgroundTransparency = 1
savedScroll.BorderSizePixel = 0
savedScroll.Parent = savedFrame

local savedEmptyLabel = Instance.new("TextLabel")
savedEmptyLabel.Size = UDim2.new(1, 0, 0, scale("Y", 40))
savedEmptyLabel.Position = UDim2.new(0, 0, 0.5, -scale("Y", 20))
savedEmptyLabel.BackgroundTransparency = 1
savedEmptyLabel.Text = "No saved emotes yet 😅"
savedEmptyLabel.TextColor3 = Color3.fromRGB(140, 140, 150)
savedEmptyLabel.Font = Enum.Font.GothamBold
savedEmptyLabel.TextSize = scale("Y", 14)
savedEmptyLabel.Visible = false
savedEmptyLabel.Parent = savedScroll

local savedLayout = Instance.new("UIGridLayout")
savedLayout.CellSize = UDim2.new(0, scale("X", 120), 0, scale("Y", 200))
savedLayout.CellPadding = UDim2.new(0, scale("X", 8), 0, scale("Y", 8))
savedLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
savedLayout.Parent = savedScroll

-- 🎨 SETTINGS FRAME - Enhanced Dark Theme
local settingsFrame = Instance.new("Frame")
settingsFrame.Size = UDim2.new(0.4, -scale("X", 16), 1, -scale("Y", 92))
settingsFrame.Position = UDim2.new(0.6, scale("X", 8), 0, scale("Y", 92))
settingsFrame.BackgroundTransparency = 1
settingsFrame.Parent = mainContainer

local settingsTitle = Instance.new("TextLabel")
settingsTitle.Size = UDim2.new(1, 0, 0, scale("Y", 32))
settingsTitle.BackgroundTransparency = 1
settingsTitle.Text = "⚙️ Settings"
settingsTitle.TextColor3 = Color3.fromRGB(220, 220, 230)
settingsTitle.Font = Enum.Font.GothamBold
settingsTitle.TextSize = scale("Y", 16)
settingsTitle.TextXAlignment = Enum.TextXAlignment.Left
settingsTitle.Parent = settingsFrame

local scrollFrame = Instance.new("ScrollingFrame")
scrollFrame.Size = UDim2.new(1, -scale("X", 8), 1, -scale("Y", 40))
scrollFrame.Position = UDim2.new(0, scale("X", 4), 0, scale("Y", 36))
scrollFrame.BackgroundTransparency = 1
scrollFrame.BorderSizePixel = 0
scrollFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
scrollFrame.ScrollBarThickness = 4
scrollFrame.ScrollBarImageColor3 = Color3.fromRGB(100, 100, 120)
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

-- 🎨 MODERN SLIDER CREATOR
local function createSlider(name, min, max, default)
    Settings[name] = default or min

    local container = Instance.new("Frame")
    container.Size = UDim2.new(1, 0, 0, scale("Y", 70))
    container.BackgroundTransparency = 1
    container.Parent = scrollFrame

    local bg = Instance.new("Frame")
    bg.Size = UDim2.new(1, 0, 1, 0)
    bg.BackgroundColor3 = Color3.fromRGB(32, 32, 42)
    bg.BorderSizePixel = 0
    bg.Parent = container
    createCorner(bg, 10)
    
    local bgStroke = Instance.new("UIStroke")
    bgStroke.Color = Color3.fromRGB(60, 60, 70)
    bgStroke.Thickness = 1
    bgStroke.Transparency = 0.6
    bgStroke.Parent = bg

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.5, -scale("X", 12), 0, scale("Y", 18))
    label.Position = UDim2.new(0, scale("X", 10), 0, scale("Y", 6))
    label.BackgroundTransparency = 1
    label.Text = string.format("%s: %.2f", name, Settings[name])
    label.TextColor3 = Color3.fromRGB(200, 200, 210)
    label.Font = Enum.Font.GothamMedium
    label.TextSize = scale("Y", 12)
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = bg

    local textBox = Instance.new("TextBox")
    textBox.Size = UDim2.new(0.5, -scale("X", 20), 0, scale("Y", 22))
    textBox.Position = UDim2.new(0.5, scale("X", 10), 0, scale("Y", 4))
    textBox.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
    textBox.BorderSizePixel = 0
    textBox.Text = tostring(Settings[name])
    textBox.TextColor3 = Color3.fromRGB(220, 220, 230)
    textBox.Font = Enum.Font.GothamMedium
    textBox.TextSize = scale("Y", 12)
    textBox.ClearTextOnFocus = false
    textBox.Parent = bg
    createCorner(textBox, 6)

    local sliderBar = Instance.new("Frame")
    sliderBar.Size = UDim2.new(1, -scale("X", 24), 0, scale("Y", 6))
    sliderBar.Position = UDim2.new(0, scale("X", 12), 0, scale("Y", 42))
    sliderBar.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
    sliderBar.BorderSizePixel = 0
    sliderBar.Parent = bg
    createCorner(sliderBar, 3)

    local sliderFill = Instance.new("Frame")
    sliderFill.Size = UDim2.new(0, 0, 1, 0)
    sliderFill.BackgroundColor3 = Color3.fromRGB(80, 140, 255)
    sliderFill.BorderSizePixel = 0
    sliderFill.Parent = sliderBar
    createCorner(sliderFill, 3)
    
    local fillGradient = Instance.new("UIGradient")
    fillGradient.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, Color3.fromRGB(100, 160, 255)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(80, 140, 255))
    }
    fillGradient.Parent = sliderFill

    local thumb = Instance.new("Frame")
    thumb.Size = UDim2.new(0, scale("X", 16), 0, scale("Y", 16))
    thumb.AnchorPoint = Vector2.new(0.5, 0.5)
    thumb.Position = UDim2.new(0, 0, 0.5, 0)
    thumb.BackgroundColor3 = Color3.fromRGB(240, 240, 250)
    thumb.BorderSizePixel = 0
    thumb.Parent = sliderBar
    createCorner(thumb, 8)
    
    local thumbStroke = Instance.new("UIStroke")
    thumbStroke.Color = Color3.fromRGB(80, 140, 255)
    thumbStroke.Thickness = 2
    thumbStroke.Parent = thumb

    local function tweenVisual(rel)
        local visualRel = math.clamp(rel, 0, 1)
        TweenService:Create(sliderFill, TweenInfo.new(0.15, Enum.EasingStyle.Quad), {
            Size = UDim2.new(visualRel, 0, 1, 0)
        }):Play()
        TweenService:Create(thumb, TweenInfo.new(0.15, Enum.EasingStyle.Quad), {
            Position = UDim2.new(visualRel, 0, 0.5, 0)
        }):Play()
    end

    local function applyValue(value)
        Settings[name] = math.clamp(value, min, max)
        label.Text = string.format("%s: %.2f", name, Settings[name])
        textBox.Text = tostring(Settings[name])
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
        end
    end)

    thumb.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            updateFromInput(input)
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
        end
    end)

    textBox.FocusLost:Connect(function(enterPressed)
        if enterPressed then
            local num = tonumber(textBox.Text)
            if num then
                applyValue(num)
            else
                textBox.Text = tostring(Settings[name])
            end
        end
    end)

    Settings._sliders[name] = applyValue
    applyValue(Settings[name])
end

-- 🎨 MODERN TOGGLE CREATOR
local function createToggle(name)
    Settings[name] = Settings[name] or false

    local container = Instance.new("Frame")
    container.Size = UDim2.new(1, 0, 0, scale("Y", 42))
    container.BackgroundColor3 = Color3.fromRGB(32, 32, 42)
    container.BorderSizePixel = 0
    container.Parent = scrollFrame
    createCorner(container, 10)
    
    local containerStroke = Instance.new("UIStroke")
    containerStroke.Color = Color3.fromRGB(60, 60, 70)
    containerStroke.Thickness = 1
    containerStroke.Transparency = 0.6
    containerStroke.Parent = container

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.65, -scale("X", 12), 1, 0)
    label.Position = UDim2.new(0, scale("X", 12), 0, 0)
    label.BackgroundTransparency = 1
    label.Text = name
    label.TextColor3 = Color3.fromRGB(200, 200, 210)
    label.Font = Enum.Font.GothamMedium
    label.TextSize = scale("Y", 12)
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = container

    local toggleBtn = Instance.new("TextButton")
    toggleBtn.Size = UDim2.new(0, scale("X", 52), 0, scale("Y", 26))
    toggleBtn.Position = UDim2.new(1, -scale("X", 62), 0.5, -scale("Y", 13))
    toggleBtn.TextColor3 = Color3.new(1, 1, 1)
    toggleBtn.BorderSizePixel = 0
    toggleBtn.AutoButtonColor = false
    toggleBtn.Font = Enum.Font.GothamBold
    toggleBtn.TextSize = scale("Y", 11)
    toggleBtn.Parent = container
    createCorner(toggleBtn, 13)

    local function applyVisual(state)
        toggleBtn.Text = state and "ON" or "OFF"
        local targetColor = state and Color3.fromRGB(50, 200, 100) or Color3.fromRGB(80, 80, 90)
        TweenService:Create(toggleBtn, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {
            BackgroundColor3 = targetColor
        }):Play()
    end

    toggleBtn.MouseButton1Click:Connect(function()
        Settings[name] = not Settings[name]
        applyVisual(Settings[name])
    end)

    applyVisual(Settings[name])
    Settings._toggles[name] = applyVisual
end

function Settings:EditSlider(targetName, newValue)
    local apply = self._sliders[targetName]
    if apply then apply(newValue) end
end

function Settings:EditToggle(targetName, newValue)
    local apply = self._toggles[targetName]
    if apply then
        Settings[targetName] = newValue
        apply(newValue)
    end
end

-- 🎨 MODERN BUTTON CREATOR
local function createButton(name, callback)
    local container = Instance.new("Frame")
    container.Size = UDim2.new(1, 0, 0, scale("Y", 48))
    container.BackgroundColor3 = Color3.fromRGB(32, 32, 42)
    container.BorderSizePixel = 0
    container.Parent = scrollFrame
    createCorner(container, 10)
    
    local containerStroke = Instance.new("UIStroke")
    containerStroke.Color = Color3.fromRGB(60, 60, 70)
    containerStroke.Thickness = 1
    containerStroke.Transparency = 0.6
    containerStroke.Parent = container

    local button = Instance.new("TextButton")
    button.Size = UDim2.new(1, -scale("X", 16), 1, -scale("Y", 8))
    button.Position = UDim2.new(0, scale("X", 8), 0, scale("Y", 4))
    button.BackgroundColor3 = Color3.fromRGB(70, 130, 250)
    button.BorderSizePixel = 0
    button.AutoButtonColor = false
    button.Text = name
    button.TextColor3 = Color3.new(1, 1, 1)
    button.Font = Enum.Font.GothamBold
    button.TextSize = scale("Y", 14)
    button.Parent = container
    createCorner(button, 8)
    
    addHoverEffect(button, Color3.fromRGB(80, 140, 255), Color3.fromRGB(70, 130, 250))

    button.MouseButton1Click:Connect(function()
        if typeof(callback) == "function" then callback() end
    end)

    return button
end

local resetButton = createButton("🔄 Reset Settings", function() end)
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
    if not Settings["Allow Invisible  "] then return end
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
        if connection then connection:Disconnect() end
    end
end)

player.CharacterAdded:Connect(function(newCharacter)
    restoreCollisionStates()
    character = newCharacter
    humanoid = newCharacter:WaitForChild("Humanoid")
    saveCollisionStates()
    lastFixClipState = Settings["Allow Invisible  "]
    if connection then connection:Disconnect() end
  
  -- Catalog API Configuration
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
    print("[API] Fetching: " .. final_url)

    local response
    local success, result = pcall(function()
        return request({Url = final_url, Method = "GET"})
    end)

    if not success or not result or not result.Success then
        warn("[API] Request failed: " .. tostring(result and result.StatusMessage))
        return false
    end

    response = result.Body
    local data_table
    success, data_table = pcall(function()
        return HttpService:JSONDecode(response)
    end)

    if not success or not data_table or not data_table.data then
        warn("[API] JSON parse failed or missing data field.")
        return false
    end

    for _, item in pairs(data_table.data) do
        table.insert(ITEM_CACHE, item)
    end
    
    NEXT_API_CURSOR = data_table.nextPageCursor
    print(string.format("[API] Got %d new items. Total cached: %d", #data_table.data, #ITEM_CACHE))
    
    return true
end

local function createViewport(size, position, parent)
    local viewportContainer = Instance.new("Frame")
    viewportContainer.Size = size
    viewportContainer.BackgroundTransparency = 1
    viewportContainer.Position = position
    viewportContainer.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
    viewportContainer.BorderSizePixel = 0
    viewportContainer.Parent = parent
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = viewportContainer
    
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
    
    local dummy = Players:CreateHumanoidModelFromUserId(game:GetService("Players").LocalPlayer.UserId)
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
    end
    
    if root then
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
    
    game:GetService("RunService").RenderStepped:Connect(function(deltaTime)
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

-- 🎨 MODERN CARD CREATOR
local function createCard(item)
    local card = Instance.new("Frame")
    card.Size = UDim2.new(0, scale("X", 120), 0, scale("Y", 180))
    card.BackgroundColor3 = Color3.fromRGB(38, 38, 48)
    card.BorderSizePixel = 0
    createCorner(card, 10)
    
    local cardStroke = Instance.new("UIStroke")
    cardStroke.Color = Color3.fromRGB(65, 65, 75)
    cardStroke.Thickness = 1
    cardStroke.Transparency = 0.5
    cardStroke.Parent = card
    
    local thumbId = item.AssetId or item.Id
    
    if Settings["Preview"] == true then
        local viewport, dummy = createViewport(UDim2.fromScale(1, 1), UDim2.fromScale(0, 0), card)
        playAnimation(dummy, getanimid(thumbId))
    else
        local img = Instance.new("ImageLabel")
        img.Size = UDim2.new(1, -scale("X", 10), 0, scale("Y", 90))
        img.Position = UDim2.new(0, scale("X", 5), 0, scale("Y", 5))
        img.BackgroundTransparency = 1
        img.ScaleType = Enum.ScaleType.Fit
        pcall(function()
            img.Image = "rbxthumb://type=Asset&id=" .. tonumber(thumbId) .. "&w=150&h=150"
        end)
        img.Parent = card
        createCorner(img, 8)
    end
    
    local name = Instance.new("TextLabel")
    name.Size = UDim2.new(1, -scale("X", 10), 0, scale("Y", 28))
    name.Position = UDim2.new(0, scale("X", 5), 0, scale("Y", 100))
    name.BackgroundTransparency = 1
    name.Text = item.Name 
    name.TextSize = scale("Y", 11)
    name.TextWrapped = true
    name.Font = Enum.Font.GothamBold
    name.TextColor3 = Color3.fromRGB(220, 220, 230)
    name.Parent = card
    
    local url = "https://www.roblox.com/catalog/" .. tonumber(item.Id)
    local copyLinkButton = Instance.new("TextButton")
    copyLinkButton.Parent = card
    copyLinkButton.Size = UDim2.new(0, scale("X", 32), 0, scale("Y", 32))
    copyLinkButton.Position = UDim2.new(1, -scale("X", 37), 0, scale("Y", 5))
    copyLinkButton.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
    copyLinkButton.BorderSizePixel = 0
    copyLinkButton.Text = "🛒🔗"
    copyLinkButton.Font = Enum.Font.GothamBold
    copyLinkButton.TextSize = scale("Y", 12)
    copyLinkButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    copyLinkButton.AutoButtonColor = false
    createCorner(copyLinkButton, 8)

    copyLinkButton.MouseButton1Click:Connect(function()
        setclipboard(url)
        copyLinkButton.Text = "✅"
        copyLinkButton.BackgroundColor3 = Color3.fromRGB(50, 180, 100)
        task.wait(0.7)
        copyLinkButton.Text = "🛒🔗"
        copyLinkButton.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
    end)

    local playBtn = Instance.new("TextButton")
    playBtn.Size = UDim2.new(0.45, -scale("X", 5), 0, scale("Y", 28))
    playBtn.Position = UDim2.new(0, scale("X", 5), 1, -scale("Y", 33))
    playBtn.BackgroundColor3 = Color3.fromRGB(70, 200, 100)
    playBtn.BorderSizePixel = 0
    playBtn.AutoButtonColor = false
    playBtn.Text = "▶ Play"
    playBtn.Font = Enum.Font.GothamBold
    playBtn.TextSize = scale("Y", 11)
    playBtn.TextColor3 = Color3.new(1, 1, 1)
    playBtn.Parent = card
    createCorner(playBtn, 7)
    addHoverEffect(playBtn, Color3.fromRGB(80, 210, 110), Color3.fromRGB(70, 200, 100))
    
    playBtn.MouseButton1Click:Connect(function()
        LoadTrack(thumbId)
    end)
    
    local saveBtn = Instance.new("TextButton")
    saveBtn.Size = UDim2.new(0.45, -scale("X", 5), 0, scale("Y", 28))
    saveBtn.Position = UDim2.new(0.55, 0, 1, -scale("Y", 33))
    saveBtn.BackgroundColor3 = Color3.fromRGB(80, 130, 220)
    saveBtn.BorderSizePixel = 0
    saveBtn.AutoButtonColor = false
    saveBtn.Text = "💾 Save"
    saveBtn.Font = Enum.Font.GothamBold
    saveBtn.TextSize = scale("Y", 11)
    saveBtn.TextColor3 = Color3.new(1, 1, 1)
    saveBtn.Parent = card
    createCorner(saveBtn, 7)
    addHoverEffect(saveBtn, Color3.fromRGB(90, 140, 230), Color3.fromRGB(80, 130, 220))
    
    saveBtn.MouseButton1Click:Connect(function()
        local alreadySaved = false
        for _, saved in ipairs(savedEmotes) do
            if saved.Id == item.Id then
                alreadySaved = true
                break
            end
        end
        if not alreadySaved then
            function GetReal(id)
                local ok, obj = pcall(function()
                    return game:GetObjects("rbxassetid://"..tostring(id))
                end)
                if not ok or not obj or #obj == 0 then return end
                local target = obj[1]
                if target:IsA("Animation") and target.AnimationId ~= "" then
                    return tonumber(target.AnimationId:match("%d+"))
                elseif target:FindFirstChildOfClass("Animation") then
                    local anim = target:FindFirstChildOfClass("Animation")
                    return tonumber(anim.AnimationId:match("%d+"))
                end
            end
            table.insert(savedEmotes, {
                Id = item.Id,
                AssetId = thumbId,
                Name = item.Name or "Unknown",
                AnimationId = "rbxassetid://" .. GetReal(thumbId),
                Favorite = false
            })
            saveEmotesToData()
            saveBtn.Text = "✅ Saved!"
            saveBtn.BackgroundColor3 = Color3.fromRGB(50, 200, 100)
            task.wait(1)
            saveBtn.Text = "💾 Save"
            saveBtn.BackgroundColor3 = Color3.fromRGB(80, 130, 220)
        else
            saveBtn.Text = "Already"
            task.wait(0.7)
            saveBtn.Text = "💾 Save"
        end
    end)
    return card
end

local scroll = Instance.new("ScrollingFrame")
scroll.Size = UDim2.new(1, -scale("X", 8), 1, -scale("Y", 104))
scroll.Position = UDim2.new(0, scale("X", 4), 0, scale("Y", 40))
scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
scroll.ScrollBarThickness = 4
scroll.ScrollBarImageColor3 = Color3.fromRGB(100, 100, 120)
scroll.BackgroundTransparency = 1
scroll.BorderSizePixel = 0
scroll.Parent = catalogFrame

local layout = Instance.new("UIGridLayout", scroll)
layout.CellSize = UDim2.new(0, scale("X", 120), 0, scale("Y", 180))
layout.CellPadding = UDim2.new(0, scale("X", 6), 0, scale("Y", 6))

local emptyLabel = Instance.new("TextLabel", scroll)
emptyLabel.Size = UDim2.new(1, 0, 0, scale("Y", 36))
emptyLabel.Position = UDim2.new(0, 0, 0.5, -scale("Y", 18))
emptyLabel.BackgroundTransparency = 1
emptyLabel.Text = "Nothing here :3"
emptyLabel.TextColor3 = Color3.fromRGB(140, 140, 150)
emptyLabel.Font = Enum.Font.GothamBold
emptyLabel.TextSize = scale("Y", 14)
emptyLabel.Visible = false

-- 🎨 MODERN NAVIGATION BUTTONS
local prevBtn = Instance.new("TextButton", catalogFrame)
prevBtn.Size = UDim2.new(0.38, -scale("X", 4), 0, scale("Y", 36))
prevBtn.Position = UDim2.new(0, scale("X", 4), 1, -scale("Y", 40))
prevBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
prevBtn.BorderSizePixel = 0
prevBtn.AutoButtonColor = false
prevBtn.Text = "◀ Previous"
prevBtn.Font = Enum.Font.GothamBold
prevBtn.TextSize = scale("Y", 12)
prevBtn.TextColor3 = Color3.new(1, 1, 1)
createCorner(prevBtn, 8)
addHoverEffect(prevBtn, Color3.fromRGB(70, 70, 80), Color3.fromRGB(60, 60, 70))

local nextBtn = Instance.new("TextButton", catalogFrame)
nextBtn.Size = UDim2.new(0.38, -scale("X", 4), 0, scale("Y", 36))
nextBtn.Position = UDim2.new(0.62, scale("X", 2), 1, -scale("Y", 40))
nextBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
nextBtn.BorderSizePixel = 0
nextBtn.AutoButtonColor = false
nextBtn.Text = "Next ▶"
nextBtn.Font = Enum.Font.GothamBold
nextBtn.TextSize = scale("Y", 12)
nextBtn.TextColor3 = Color3.new(1, 1, 1)
createCorner(nextBtn, 8)
addHoverEffect(nextBtn, Color3.fromRGB(70, 70, 80), Color3.fromRGB(60, 60, 70))

local pageBox = Instance.new("TextBox", catalogFrame)
pageBox.Size = UDim2.new(0.24, 0, 0, scale("Y", 36))
pageBox.Position = UDim2.new(0.38, scale("X", 2), 1, -scale("Y", 40))
pageBox.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
pageBox.BorderSizePixel = 0
pageBox.Font = Enum.Font.GothamBold
pageBox.TextSize = scale("Y", 12)
pageBox.TextColor3 = Color3.fromRGB(220, 220, 230)
pageBox.Text = "1 / Enter page"
createCorner(pageBox, 8)

local pageNotif = Instance.new("TextLabel", catalogFrame)
pageNotif.Size = UDim2.new(0.3, 0, 0, scale("Y", 24))
pageNotif.Position = UDim2.new(0.35, 0, 1, -scale("Y", 72))
pageNotif.BackgroundTransparency = 1
pageNotif.TextColor3 = Color3.fromRGB(255, 120, 80)
pageNotif.Font = Enum.Font.GothamBold
pageNotif.TextSize = scale("Y", 11)
pageNotif.Text = ""
pageNotif.Visible = false

local function showPage()
    for _, child in ipairs(scroll:GetChildren()) do
        if child:IsA("Frame") then child:Destroy() end
    end

    local start_index = (CURRENT_PAGE_NUMBER - 1) * PAGE_SIZE_TINY + 1
    local end_index = start_index + PAGE_SIZE_TINY - 1

    local needsMoreData = false
    if start_index > #ITEM_CACHE and NEXT_API_CURSOR then
        needsMoreData = true
    end
    
    if needsMoreData then
        if pageBox then pageBox.Text = "Fetching..." end
        local fetchWorked = GetEmoteDataFromWeb()
        if not fetchWorked then
            if pageBox then pageBox.Text = "API Error" end
            return
        end
        start_index = (CURRENT_PAGE_NUMBER - 1) * PAGE_SIZE_TINY + 1
        end_index = start_index + PAGE_SIZE_TINY - 1
    end

    if pageBox then
        pageBox.Text = tostring(CURRENT_PAGE_NUMBER) .. " / Enter page"
    end
    if prevBtn then
        prevBtn.Active = (CURRENT_PAGE_NUMBER > 1)
    end
    if nextBtn then
        local canGoNext = (end_index < #ITEM_CACHE) or (NEXT_API_CURSOR ~= nil)
        nextBtn.Active = canGoNext
    end

    for i = start_index, math.min(end_index, #ITEM_CACHE) do
        local item = ITEM_CACHE[i]
        local card = createCard({
            Id = item.id,
            AssetId = item.id,
            Name = item.name or "Unknown",
            Description = item.description,
            CreatorName = item.creatorName or "Roblox",
            Price = item.price or 0,
        })
        if card then card.Parent = scroll end
        task.wait(0.01)
    end

    scroll.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + 8)
    if emptyLabel then
        emptyLabel.Visible = (#ITEM_CACHE == 0)
    end
end

local function doNewSearch(keyword)
    CURRENT_SEARCH_TEXT = keyword or ""
    CURRENT_PAGE_NUMBER = 1
    NEXT_API_CURSOR = nil
    ITEM_CACHE = {}
    if pageBox then pageBox.Text = "Loading..." end
    local fetchSuccess = GetEmoteDataFromWeb()
    if fetchSuccess then
        showPage()
    else
        if pageBox then pageBox.Text = "Failed to load" end
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
    sortBtn.Text = "Sort: " .. CURRENT_SORT_OPTION
    doNewSearch(CURRENT_SEARCH_TEXT)
end)

local function goNextPage()
    local currentStart = (CURRENT_PAGE_NUMBER * PAGE_SIZE_TINY) + 1
    if currentStart <= #ITEM_CACHE or NEXT_API_CURSOR ~= nil then
        CURRENT_PAGE_NUMBER = CURRENT_PAGE_NUMBER + 1
        showPage()
    end
end

local function goPrevPage()
    if CURRENT_PAGE_NUMBER > 1 then
        CURRENT_PAGE_NUMBER = CURRENT_PAGE_NUMBER - 1
        showPage()
    end
end

nextBtn.MouseButton1Click:Connect(goNextPage)
prevBtn.MouseButton1Click:Connect(goPrevPage)

UserInputService.InputBegan:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.Right then
        goNextPage()
    elseif input.KeyCode == Enum.KeyCode.Left then
        goPrevPage()
    end
end)

pageBox.FocusLost:Connect(function(enterPressed)
    if not enterPressed then return end
    local text = pageBox.Text:gsub("%s+", "")
    local num = tonumber(text:match("%d+"))
    if not num or num < 1 then
        pageNotif.Text = "Invalid page number"
        pageNotif.Visible = true
        task.delay(2, function() 
            if pageNotif then pageNotif.Visible = false end 
        end)
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
        pageBox.Text = "Page not available"
    end
end)

catalogTabBtn.MouseButton1Click:Connect(function()
    catalogFrame.Visible = true
    savedFrame.Visible = false
    catalogTabBtn.BackgroundColor3 = Color3.fromRGB(80, 120, 255)
    catalogTabBtn.TextColor3 = Color3.new(1, 1, 1)
    catalogStroke.Color = Color3.fromRGB(100, 140, 255)
    catalogStroke.Transparency = 0.3
    savedTabBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
    savedTabBtn.TextColor3 = Color3.fromRGB(180, 180, 190)
    savedStroke.Color = Color3.fromRGB(60, 60, 70)
    savedStroke.Transparency = 0.5
end)

-- 🎨 MODERN SAVED CARD CREATOR
local function createSavedCard(item)
    local card = Instance.new("Frame")
    card.Size = UDim2.new(0, scale("X", 120), 0, scale("Y", 200))
    card.BackgroundColor3 = Color3.fromRGB(38, 38, 48)
    card.BorderSizePixel = 0
    createCorner(card, 10)
    
    local cardStroke = Instance.new("UIStroke")
    cardStroke.Color = Color3.fromRGB(65, 65, 75)
    cardStroke.Thickness = 1
    cardStroke.Transparency = 0.5
    cardStroke.Parent = card
    
    if Settings["Preview"] == true then
        local viewport, dummy = createViewport(UDim2.fromScale(1, 1), UDim2.fromScale(0, 0), card)
        playAnimation(dummy, getanimid(item.Id))
    else
        local img = Instance.new("ImageLabel")
        img.Size = UDim2.new(1, -scale("X", 10), 0, scale("Y", 90))
        img.Position = UDim2.new(0, scale("X", 5), 0, scale("Y", 5))
        img.BackgroundTransparency = 1
        img.ScaleType = Enum.ScaleType.Fit
        img.Image = "rbxthumb://type=Asset&id=11768914234&w=150&h=150"
        img.Parent = card
        createCorner(img, 8)
    end
    
    local name = Instance.new("TextLabel")
    name.Size = UDim2.new(1, -scale("X", 10), 0, scale("Y", 28))
    name.Position = UDim2.new(0, scale("X", 5), 0, scale("Y", 100))
    name.BackgroundTransparency = 1
    name.Text = item.Name or "Unknown"
    name.TextSize = scale("Y", 11)
    name.TextWrapped = true
    name.Font = Enum.Font.GothamBold
    name.TextColor3 = Color3.fromRGB(220, 220, 230)
    name.Parent = card
    
    local playBtn = Instance.new("TextButton")
    playBtn.Size = UDim2.new(0.45, -scale("X", 5), 0, scale("Y", 28))
    playBtn.Position = UDim2.new(0, scale("X", 5), 1, -scale("Y", 33))
    playBtn.BackgroundColor3 = Color3.fromRGB(70, 200, 100)
    playBtn.BorderSizePixel = 0
    playBtn.AutoButtonColor = false
    playBtn.Text = "▶ Play"
    playBtn.Font = Enum.Font.GothamBold
    playBtn.TextSize = scale("Y", 11)
    playBtn.TextColor3 = Color3.new(1, 1, 1)
    playBtn.Parent = card
    createCorner(playBtn, 7)
    addHoverEffect(playBtn, Color3.fromRGB(80, 210, 110), Color3.fromRGB(70, 200, 100))
    
    playBtn.MouseButton1Click:Connect(function()
        LoadTrack(item.Id)
    end)
    
    local removeBtn = Instance.new("TextButton")
    removeBtn.Size = UDim2.new(0.45, -scale("X", 5), 0, scale("Y", 28))
    removeBtn.Position = UDim2.new(0.55, 0, 1, -scale("Y", 33))
    removeBtn.BackgroundColor3 = Color3.fromRGB(220, 80, 80)
    removeBtn.BorderSizePixel = 0
    removeBtn.AutoButtonColor = false
    removeBtn.Text = "🗑️ Remove"
    removeBtn.Font = Enum.Font.GothamBold
    removeBtn.TextSize = scale("Y", 11)
    removeBtn.TextColor3 = Color3.new(1, 1, 1)
    removeBtn.Parent = card
    createCorner(removeBtn, 7)
    addHoverEffect(removeBtn, Color3.fromRGB(230, 90, 90), Color3.fromRGB(220, 80, 80))
    
    local copyBtn = Instance.new("TextButton")
    copyBtn.Size = UDim2.new(0, scale("X", 48), 0, scale("Y", 24))
    copyBtn.Position = UDim2.new(0.5, -scale("X", 24), 0, scale("Y", 5))
    copyBtn.BackgroundColor3 = Color3.fromRGB(80, 100, 160)
    copyBtn.BorderSizePixel = 0
    copyBtn.AutoButtonColor = false
    copyBtn.Text = "📋 ID"
    copyBtn.Font = Enum.Font.GothamBold
    copyBtn.TextSize = scale("Y", 10)
    copyBtn.TextColor3 = Color3.new(1, 1, 1)
    copyBtn.Parent = card
    createCorner(copyBtn, 6)
    addHoverEffect(copyBtn, Color3.fromRGB(90, 110, 170), Color3.fromRGB(80, 100, 160))

    copyBtn.MouseButton1Click:Connect(function()
        if setclipboard then
            setclipboard(item.AnimationId:gsub("rbxassetid://", ""))
        end
        copyBtn.Text = "✅"
        copyBtn.BackgroundColor3 = Color3.fromRGB(50, 180, 100)
        task.wait(0.7)
        copyBtn.Text = "📋 ID"
        copyBtn.BackgroundColor3 = Color3.fromRGB(80, 100, 160)
    end)
    
    local favBtn = Instance.new("TextButton")
    favBtn.Size = UDim2.new(0, scale("X", 28), 0, scale("Y", 28))
    favBtn.Position = UDim2.new(1, -scale("X", 33), 0, scale("Y", 4))
    favBtn.Text = item.Favorite and "★" or "☆"
    favBtn.Font = Enum.Font.GothamBold
    favBtn.TextSize = scale("Y", 16)
    favBtn.TextColor3 = Color3.fromRGB(255, 220, 100)
    favBtn.BackgroundTransparency = 1
    favBtn.AutoButtonColor = false
    favBtn.Parent = card
    
    favBtn.MouseButton1Click:Connect(function()
        item.Favorite = not item.Favorite
        favBtn.Text = item.Favorite and "★" or "☆"
        TweenService:Create(favBtn, TweenInfo.new(0.2, Enum.EasingStyle.Back), {
            Rotation = item.Favorite and 360 or 0
        }):Play()
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

savedTabBtn.MouseButton1Click:Connect(function()
    catalogFrame.Visible = false
    savedFrame.Visible = true
    catalogTabBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
    catalogTabBtn.TextColor3 = Color3.fromRGB(180, 180, 190)
    catalogStroke.Color = Color3.fromRGB(60, 60, 70)
    catalogStroke.Transparency = 0.5
    savedTabBtn.BackgroundColor3 = Color3.fromRGB(80, 120, 255)
    savedTabBtn.TextColor3 = Color3.new(1, 1, 1)
    savedStroke.Color = Color3.fromRGB(100, 140, 255)
    savedStroke.Transparency = 0.3
    refreshSavedTab()
end)

local function doNewSearchInitial()
    doNewSearch("")
end

doNewSearchInitial()

local targetGui = gui

local function toggleGui()
    targetGui.Enabled = not targetGui.Enabled
end

-- 🎨 MODERN FLOATING TOGGLE BUTTON
local screonGui = Instance.new("ScreenGui")
screonGui.Name = "ToggleButtonGui"
screonGui.ResetOnSpawn = false
screonGui.Parent = CoreGui
screonGui.Enabled = true

local btn = Instance.new("TextButton")
btn.Parent = screonGui
btn.Text = "G"
btn.Font = Enum.Font.GothamBold
btn.TextSize = 24
btn.Size = UDim2.new(0, 56, 0, 56)
btn.Position = UDim2.new(0, 20, 0.5, -28)
btn.AnchorPoint = Vector2.new(0, 0.5)
btn.BackgroundColor3 = Color3.fromRGB(80, 120, 255)
btn.TextColor3 = Color3.new(1, 1, 1)
btn.BorderSizePixel = 0
btn.AutoButtonColor = false
btn.Active = true
btn.ZIndex = 10
pcall(function() btn.Draggable = true end)

local aspect = Instance.new("UIAspectRatioConstraint")
aspect.Parent = btn
aspect.AspectRatio = 1

local corner = Instance.new("UICorner")
corner.Parent = btn
corner.CornerRadius = UDim.new(0, 16)

local btnStroke = Instance.new("UIStroke")
btnStroke.Color = Color3.fromRGB(100, 140, 255)
btnStroke.Thickness = 3
btnStroke.Transparency = 0.3
btnStroke.Parent = btn

local btnGradient = Instance.new("UIGradient")
btnGradient.Color = ColorSequence.new{
    ColorSequenceKeypoint.new(0, Color3.fromRGB(100, 140, 255)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(80, 120, 255))
}
btnGradient.Rotation = 135
btnGradient.Parent = btn

createShadow(btn, 0.4)

-- Button hover effect
btn.MouseEnter:Connect(function()
    TweenService:Create(btn, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {
        Size = UDim2.new(0, 62, 0, 62),
        BackgroundColor3 = Color3.fromRGB(90, 130, 255)
    }):Play()
    TweenService:Create(btnStroke, TweenInfo.new(0.2), {
        Transparency = 0.1
    }):Play()
end)

btn.MouseLeave:Connect(function()
    TweenService:Create(btn, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {
        Size = UDim2.new(0, 56, 0, 56),
        BackgroundColor3 = Color3.fromRGB(80, 120, 255)
    }):Play()
    TweenService:Create(btnStroke, TweenInfo.new(0.2), {
        Transparency = 0.3
    }):Play()
end)

local btnFrame = btn.Parent

local function clampButtonPosition()
    local parentSize = btnFrame.AbsoluteSize
    local btnSize = btn.AbsoluteSize

    local clampedX = math.clamp(btn.Position.X.Scale * parentSize.X + btn.Position.X.Offset, 0, parentSize.X - btnSize.X)
    local clampedY = math.clamp(btn.Position.Y.Scale * parentSize.Y + btn.Position.Y.Offset, 0, parentSize.Y - btnSize.Y)

    btn.Position = UDim2.new(0, clampedX, 0, clampedY)
end

btn:GetPropertyChangedSignal("Position"):Connect(clampButtonPosition)

btn.MouseButton1Click:Connect(function()
    toggleGui()
    -- Button click animation
    local originalSize = btn.Size
    TweenService:Create(btn, TweenInfo.new(0.1, Enum.EasingStyle.Quad), {
        Size = originalSize - UDim2.new(0, 6, 0, 6)
    }):Play()
    task.wait(0.1)
    TweenService:Create(btn, TweenInfo.new(0.1, Enum.EasingStyle.Quad), {
        Size = originalSize
    }):Play()
end)

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.UserInputType == Enum.UserInputType.Keyboard and input.KeyCode == Enum.KeyCode.G then
        toggleGui()
    end
end)

gui.Enabled = true
refreshSavedTab()