-- SYNCE EMOTES UI - PART 1/5
-- Copy dan paste part ini terlebih dahulu

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
local SAVE_FILE = "SynceEmotes_SavedData.json"

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

-- END OF PART 1
-- Lanjutkan dengan copy paste Part 2

-- SYNCE EMOTES UI - PART 2/5
-- Copy dan paste di BAWAH Part 1

local CoreGui = Services.CoreGui
local gui = Instance.new("ScreenGui")
gui.Name = "SynceEmoteGUI"
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

-- Blue Ocean Theme Colors
local THEME = {
    Background = Color3.fromRGB(15, 25, 45),
    CardBg = Color3.fromRGB(20, 35, 60),
    Primary = Color3.fromRGB(30, 144, 255),
    Secondary = Color3.fromRGB(0, 191, 255),
    Accent = Color3.fromRGB(64, 224, 208),
    Text = Color3.fromRGB(240, 248, 255),
    Success = Color3.fromRGB(0, 206, 209),
    Danger = Color3.fromRGB(255, 69, 96)
}

local mainContainer = Instance.new("Frame")
mainContainer.Size = UDim2.new(0, scale("X", 600), 0, scale("Y", 400))
mainContainer.Position = UDim2.new(0.5, -scale("X", 300), 0.5, -scale("Y", 200))
mainContainer.BackgroundColor3 = THEME.Background
mainContainer.Active = true
mainContainer.Draggable = true
mainContainer.Parent = gui
mainContainer.ClipsDescendants = false
createCorner(mainContainer, 20)

-- Shadow effect
local shadow = Instance.new("ImageLabel")
shadow.Name = "Shadow"
shadow.Size = UDim2.new(1, 40, 1, 40)
shadow.Position = UDim2.new(0.5, 0, 0.5, 0)
shadow.AnchorPoint = Vector2.new(0.5, 0.5)
shadow.BackgroundTransparency = 1
shadow.Image = "rbxasset://textures/ui/GuiImagePlaceholder.png"
shadow.ImageColor3 = Color3.fromRGB(0, 0, 0)
shadow.ImageTransparency = 0.7
shadow.ScaleType = Enum.ScaleType.Slice
shadow.SliceCenter = Rect.new(10, 10, 118, 118)
shadow.ZIndex = 0
shadow.Parent = mainContainer

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

-- Gradient overlay
local gradientOverlay = Instance.new("Frame")
gradientOverlay.Size = UDim2.new(1, 0, 1, 0)
gradientOverlay.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
gradientOverlay.BackgroundTransparency = 1
gradientOverlay.Parent = mainContainer
createCorner(gradientOverlay, 20)

local gradient = Instance.new("UIGradient")
gradient.Color = ColorSequence.new(THEME.Primary, THEME.Secondary)
gradient.Transparency = NumberSequence.new{
    NumberSequenceKeypoint.new(0, 0.95),
    NumberSequenceKeypoint.new(1, 0.98)
}
gradient.Rotation = 45
gradient.Parent = gradientOverlay

-- Animated gradient rotation
spawn(function()
    while wait(0.05) do
        if gradient and gradient.Parent then
            gradient.Rotation = (gradient.Rotation + 0.5) % 360
        end
    end
end)

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, scale("Y", 50))
title.BackgroundColor3 = THEME.CardBg
title.BackgroundTransparency = 0.3
title.Text = "✨ Synce Emotes"
title.TextColor3 = THEME.Text
title.Font = Enum.Font.GothamBold
title.TextSize = scale("Y", 24)
title.Parent = mainContainer
createCorner(title, 20)

-- Title gradient
local titleGradient = Instance.new("UIGradient")
titleGradient.Color = ColorSequence.new(THEME.Accent, THEME.Primary)
titleGradient.Rotation = 90
titleGradient.Parent = title

-- Fade in animation
title.BackgroundTransparency = 1
title.TextTransparency = 1
TweenService:Create(title, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
    BackgroundTransparency = 0.3,
    TextTransparency = 0
}):Play()

local catalogTabBtn = Instance.new("TextButton")
catalogTabBtn.Size = UDim2.new(0.3, 0, 0, scale("Y", 35))
catalogTabBtn.Position = UDim2.new(0.05, 0, 0, scale("Y", 60))
catalogTabBtn.BackgroundColor3 = THEME.Primary
catalogTabBtn.Text = "🌊 Catalog"
catalogTabBtn.TextColor3 = THEME.Text
catalogTabBtn.Font = Enum.Font.GothamBold
catalogTabBtn.TextSize = scale("Y", 16)
catalogTabBtn.AutoButtonColor = false
catalogTabBtn.Parent = mainContainer
createCorner(catalogTabBtn, 12)

-- Hover animation for catalog button
catalogTabBtn.MouseEnter:Connect(function()
    TweenService:Create(catalogTabBtn, TweenInfo.new(0.2), {
        Size = UDim2.new(0.3, 0, 0, scale("Y", 38)),
        BackgroundColor3 = THEME.Secondary
    }):Play()
end)
catalogTabBtn.MouseLeave:Connect(function()
    TweenService:Create(catalogTabBtn, TweenInfo.new(0.2), {
        Size = UDim2.new(0.3, 0, 0, scale("Y", 35)),
        BackgroundColor3 = THEME.Primary
    }):Play()
end)

local savedTabBtn = Instance.new("TextButton")
savedTabBtn.Size = UDim2.new(0.3, 0, 0, scale("Y", 35))
savedTabBtn.Position = UDim2.new(0.36, 0, 0, scale("Y", 60))
savedTabBtn.BackgroundColor3 = THEME.CardBg
savedTabBtn.Text = "💾 Saved"
savedTabBtn.TextColor3 = THEME.Text
savedTabBtn.Font = Enum.Font.GothamBold
savedTabBtn.TextSize = scale("Y", 16)
savedTabBtn.AutoButtonColor = false
savedTabBtn.Parent = mainContainer
createCorner(savedTabBtn, 12)

-- Hover animation for saved button
savedTabBtn.MouseEnter:Connect(function()
    TweenService:Create(savedTabBtn, TweenInfo.new(0.2), {
        Size = UDim2.new(0.3, 0, 0, scale("Y", 38)),
        BackgroundColor3 = Color3.fromRGB(30, 50, 80)
    }):Play()
end)
savedTabBtn.MouseLeave:Connect(function()
    TweenService:Create(savedTabBtn, TweenInfo.new(0.2), {
        Size = UDim2.new(0.3, 0, 0, scale("Y", 35)),
        BackgroundColor3 = THEME.CardBg
    }):Play()
end)

local divider = Instance.new("Frame")
divider.Size = UDim2.new(0, scale("X", 1), 1, -scale("Y", 100))
divider.Position = UDim2.new(0.6, 0, 0, scale("Y", 100))
divider.BackgroundColor3 = THEME.Accent
divider.BackgroundTransparency = 0.7
divider.BorderSizePixel = 0
divider.Parent = mainContainer

local catalogFrame = Instance.new("Frame")
catalogFrame.Size = UDim2.new(0.6, -scale("X", 10), 1, -scale("Y", 100))
catalogFrame.Position = UDim2.new(0, scale("X", 5), 0, scale("Y", 100))
catalogFrame.BackgroundTransparency = 1
catalogFrame.Visible = true
catalogFrame.Parent = mainContainer

local searchBox = Instance.new("TextBox")
searchBox.Size = UDim2.new(0.6, -scale("X", 8), 0, scale("Y", 32))
searchBox.Position = UDim2.new(0, scale("X", 8), 0, 0)
searchBox.PlaceholderText = "🔍 Search emotes..."
searchBox.PlaceholderColor3 = Color3.fromRGB(150, 170, 200)
searchBox.BackgroundColor3 = THEME.CardBg
searchBox.TextColor3 = THEME.Text
searchBox.Font = Enum.Font.Gotham
searchBox.TextSize = scale("Y", 14)
searchBox.ClearTextOnFocus = false
searchBox.Text = ""
searchBox.Parent = catalogFrame
createCorner(searchBox, 10)

-- Search box focus animation
searchBox.Focused:Connect(function()
    TweenService:Create(searchBox, TweenInfo.new(0.2), {
        BackgroundColor3 = Color3.fromRGB(30, 50, 80)
    }):Play()
end)
searchBox.FocusLost:Connect(function()
    TweenService:Create(searchBox, TweenInfo.new(0.2), {
        BackgroundColor3 = THEME.CardBg
    }):Play()
end)

local refreshBtn = Instance.new("TextButton")
refreshBtn.Size = UDim2.new(0.2, -scale("X", 4), 0, scale("Y", 32))
refreshBtn.Position = UDim2.new(0.6, scale("X", 4), 0, 0)
refreshBtn.BackgroundColor3 = THEME.Success
refreshBtn.Text = "🔄"
refreshBtn.Font = Enum.Font.GothamBold
refreshBtn.TextSize = scale("Y", 18)
refreshBtn.TextColor3 = THEME.Text
refreshBtn.AutoButtonColor = false
refreshBtn.Parent = catalogFrame
createCorner(refreshBtn, 10)

-- Refresh button animation
refreshBtn.MouseButton1Click:Connect(function()
    local rotation = 0
    for i = 1, 20 do
        rotation = rotation + 18
        refreshBtn.Rotation = rotation
        wait(0.01)
    end
    refreshBtn.Rotation = 0
end)

local sortBtn = Instance.new("TextButton")
sortBtn.Size = UDim2.new(0.2, -scale("X", 8), 0, scale("Y", 32))
sortBtn.Position = UDim2.new(0.8, scale("X", 4), 0, 0)
sortBtn.BackgroundColor3 = THEME.Primary
sortBtn.Text = "📊"
sortBtn.Font = Enum.Font.GothamBold
sortBtn.TextSize = scale("Y", 18)
sortBtn.TextColor3 = THEME.Text
sortBtn.AutoButtonColor = false
sortBtn.Parent = catalogFrame
createCorner(sortBtn, 10)

-- END OF PART 2
-- Lanjutkan dengan copy paste Part 3

-- SYNCE EMOTES UI - PART 3/5
-- Copy dan paste di BAWAH Part 2

local savedFrame = Instance.new("Frame")
savedFrame.Size = UDim2.new(0.6, -scale("X", 10), 1, -scale("Y", 100))
savedFrame.Position = UDim2.new(0, scale("X", 5), 0, scale("Y", 100))
savedFrame.BackgroundTransparency = 1
savedFrame.Visible = false
savedFrame.Parent = mainContainer

local savedSearch = Instance.new("TextBox")
savedSearch.Size = UDim2.new(1, -scale("X", 16), 0, scale("Y", 32))
savedSearch.Position = UDim2.new(0, scale("X", 8), 0, 0)
savedSearch.PlaceholderText = "🔍 Search saved..."
savedSearch.PlaceholderColor3 = Color3.fromRGB(150, 170, 200)
savedSearch.BackgroundColor3 = THEME.CardBg
savedSearch.TextColor3 = THEME.Text
savedSearch.Font = Enum.Font.Gotham
savedSearch.TextSize = scale("Y", 14)
savedSearch.ClearTextOnFocus = false
savedSearch.Text = ""
savedSearch.Parent = savedFrame
createCorner(savedSearch, 10)

local savedScroll = Instance.new("ScrollingFrame")
savedScroll.Size = UDim2.new(1, -scale("X", 16), 1, -scale("Y", 40))
savedScroll.Position = UDim2.new(0, scale("X", 8), 0, scale("Y", 40))
savedScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
savedScroll.ScrollBarThickness = 4
savedScroll.ScrollBarImageColor3 = THEME.Primary
savedScroll.BackgroundTransparency = 1
savedScroll.BorderSizePixel = 0
savedScroll.Parent = savedFrame

local savedEmptyLabel = Instance.new("TextLabel")
savedEmptyLabel.Size = UDim2.new(1, 0, 0, scale("Y", 40))
savedEmptyLabel.Position = UDim2.new(0, 0, 0.5, -scale("Y", 20))
savedEmptyLabel.BackgroundTransparency = 1
savedEmptyLabel.Text = "🌊 No saved emotes yet"
savedEmptyLabel.TextColor3 = THEME.Accent
savedEmptyLabel.Font = Enum.Font.GothamBold
savedEmptyLabel.TextSize = scale("Y", 16)
savedEmptyLabel.Visible = false
savedEmptyLabel.Parent = savedScroll

local savedLayout = Instance.new("UIGridLayout")
savedLayout.CellSize = UDim2.new(0, scale("X", 120), 0, scale("Y", 200))
savedLayout.CellPadding = UDim2.new(0, scale("X", 10), 0, scale("Y", 10))
savedLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
savedLayout.Parent = savedScroll

local settingsFrame = Instance.new("Frame")
settingsFrame.Size = UDim2.new(0.4, -scale("X", 10), 1, -scale("Y", 100))
settingsFrame.Position = UDim2.new(0.6, scale("X", 5), 0, scale("Y", 100))
settingsFrame.BackgroundTransparency = 1
settingsFrame.Parent = mainContainer

local settingsTitle = Instance.new("TextLabel")
settingsTitle.Size = UDim2.new(1, 0, 0, scale("Y", 32))
settingsTitle.BackgroundTransparency = 1
settingsTitle.Text = "⚙️ Settings"
settingsTitle.TextColor3 = THEME.Accent
settingsTitle.Font = Enum.Font.GothamBold
settingsTitle.TextSize = scale("Y", 18)
settingsTitle.Parent = settingsFrame

local scrollFrame = Instance.new("ScrollingFrame")
scrollFrame.Size = UDim2.new(1, -scale("X", 10), 1, -scale("Y", 40))
scrollFrame.Position = UDim2.new(0, scale("X", 5), 0, scale("Y", 35))
scrollFrame.BackgroundTransparency = 1
scrollFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
scrollFrame.ScrollBarThickness = 4
scrollFrame.ScrollBarImageColor3 = THEME.Primary
scrollFrame.BorderSizePixel = 0
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

local function createSlider(name, min, max, default)
    Settings[name] = default or min

    local container = Instance.new("Frame")
    container.Size = UDim2.new(1, 0, 0, scale("Y", 70))
    container.BackgroundTransparency = 1
    container.Parent = scrollFrame

    local bg = Instance.new("Frame")
    bg.Size = UDim2.new(1, 0, 1, 0)
    bg.BackgroundColor3 = THEME.CardBg
    bg.BackgroundTransparency = 0.3
    bg.BorderSizePixel = 0
    bg.Parent = container
    createCorner(bg, 12)

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.5, -scale("X", 10), 0, scale("Y", 20))
    label.Position = UDim2.new(0, 10, 0, 5)
    label.BackgroundTransparency = 1
    label.Text = string.format("%s: %.2f", name, Settings[name])
    label.TextColor3 = THEME.Text
    label.Font = Enum.Font.Gotham
    label.TextSize = scale("Y", 12)
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = bg

    local textBox = Instance.new("TextBox")
    textBox.Size = UDim2.new(0.5, -scale("X", 20), 0, scale("Y", 22))
    textBox.Position = UDim2.new(0.5, scale("X", 10), 0, scale("Y", 4))
    textBox.BackgroundColor3 = THEME.Background
    textBox.BackgroundTransparency = 0.5
    textBox.BorderSizePixel = 0
    textBox.Text = tostring(Settings[name])
    textBox.TextColor3 = THEME.Text
    textBox.Font = Enum.Font.Gotham
    textBox.TextSize = scale("Y", 12)
    textBox.ClearTextOnFocus = false
    textBox.Parent = bg
    createCorner(textBox, 8)

    local sliderBar = Instance.new("Frame")
    sliderBar.Size = UDim2.new(1, -scale("X", 30), 0, scale("Y", 8))
    sliderBar.Position = UDim2.new(0, scale("X", 15), 0, scale("Y", 45))
    sliderBar.BackgroundColor3 = THEME.Background
    sliderBar.BackgroundTransparency = 0.5
    sliderBar.BorderSizePixel = 0
    sliderBar.Parent = bg
    createCorner(sliderBar, 4)

    local sliderFill = Instance.new("Frame")
    sliderFill.Size = UDim2.new(0, 0, 1, 0)
    sliderFill.BackgroundColor3 = THEME.Primary
    sliderFill.BorderSizePixel = 0
    sliderFill.Parent = sliderBar
    createCorner(sliderFill, 4)

    -- Animated gradient on slider fill
    local fillGradient = Instance.new("UIGradient")
    fillGradient.Color = ColorSequence.new(THEME.Primary, THEME.Secondary)
    fillGradient.Parent = sliderFill

    local thumb = Instance.new("Frame")
    thumb.Size = UDim2.new(0, scale("X", 18), 0, scale("Y", 18))
    thumb.AnchorPoint = Vector2.new(0.5, 0.5)
    thumb.Position = UDim2.new(0, 0, 0.5, 0)
    thumb.BackgroundColor3 = THEME.Accent
    thumb.BorderSizePixel = 0
    thumb.Parent = sliderBar
    createCorner(thumb, 9)

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
            TweenService:Create(thumb, TweenInfo.new(0.1), {Size = UDim2.new(0, scale("X", 22), 0, scale("Y", 22))}):Play()
        end
    end)

    thumb.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            updateFromInput(input)
            TweenService:Create(thumb, TweenInfo.new(0.1), {Size = UDim2.new(0, scale("X", 22), 0, scale("Y", 22))}):Play()
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
            TweenService:Create(thumb, TweenInfo.new(0.1), {Size = UDim2.new(0, scale("X", 18), 0, scale("Y", 18))}):Play()
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

-- END OF PART 3
-- Lanjutkan dengan copy paste Part 4

-- SYNCE EMOTES UI - PART 4/5
-- Copy dan paste di BAWAH Part 3

local function createToggle(name)
    Settings[name] = Settings[name] or false

    local container = Instance.new("Frame")
    container.Size = UDim2.new(1, 0, 0, scale("Y", 45))
    container.BackgroundColor3 = THEME.CardBg
    container.BackgroundTransparency = 0.3
    container.BorderSizePixel = 0
    container.Parent = scrollFrame
    createCorner(container, 12)

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.65, -scale("X", 10), 1, 0)
    label.Position = UDim2.new(0, scale("X", 10), 0, 0)
    label.BackgroundTransparency = 1
    label.Text = name
    label.TextColor3 = THEME.Text
    label.Font = Enum.Font.Gotham
    label.TextSize = scale("Y", 12)
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = container

    local toggleBtn = Instance.new("TextButton")
    toggleBtn.Size = UDim2.new(0, scale("X", 50), 0, scale("Y", 26))
    toggleBtn.Position = UDim2.new(1, -scale("X", 60), 0.5, -scale("Y", 13))
    toggleBtn.TextColor3 = THEME.Text
    toggleBtn.Font = Enum.Font.GothamBold
    toggleBtn.TextSize = scale("Y", 11)
    toggleBtn.AutoButtonColor = false
    toggleBtn.BorderSizePixel = 0
    toggleBtn.Parent = container
    createCorner(toggleBtn, 13)

    local indicator = Instance.new("Frame")
    indicator.Size = UDim2.new(0, scale("X", 20), 0, scale("Y", 20))
    indicator.Position = UDim2.new(0, scale("X", 3), 0.5, -scale("Y", 10))
    indicator.BorderSizePixel = 0
    indicator.Parent = toggleBtn
    createCorner(indicator, 10)

    local function applyVisual(state)
        toggleBtn.Text = state and "ON" or "OFF"
        local targetBgColor = state and THEME.Success or THEME.Danger
        local targetIndicatorPos = state and UDim2.new(1, -scale("X", 23), 0.5, -scale("Y", 10)) or UDim2.new(0, scale("X", 3), 0.5, -scale("Y", 10))
        
        TweenService:Create(toggleBtn, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {
            BackgroundColor3 = targetBgColor
        }):Play()
        
        TweenService:Create(indicator, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
            Position = targetIndicatorPos,
            BackgroundColor3 = THEME.Text
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

local function createButton(name, callback)
    local container = Instance.new("Frame")
    container.Size = UDim2.new(1, 0, 0, scale("Y", 50))
    container.BackgroundColor3 = THEME.CardBg
    container.BackgroundTransparency = 0.3
    container.BorderSizePixel = 0
    container.Parent = scrollFrame
    createCorner(container, 12)

    local button = Instance.new("TextButton")
    button.Size = UDim2.new(1, -scale("X", 20), 1, -scale("Y", 10))
    button.Position = UDim2.new(0, scale("X", 10), 0, scale("Y", 5))
    button.BackgroundColor3 = THEME.Primary
    button.Text = name
    button.TextColor3 = THEME.Text
    button.Font = Enum.Font.GothamBold
    button.TextSize = scale("Y", 14)
    button.AutoButtonColor = false
    button.BorderSizePixel = 0
    button.Parent = container
    createCorner(button, 10)

    local btnGradient = Instance.new("UIGradient")
    btnGradient.Color = ColorSequence.new(THEME.Primary, THEME.Secondary)
    btnGradient.Rotation = 45
    btnGradient.Parent = button

    button.MouseEnter:Connect(function()
        TweenService:Create(button, TweenInfo.new(0.2), {
            Size = UDim2.new(1, -scale("X", 15), 1, -scale("Y", 5))
        }):Play()
    end)

    button.MouseLeave:Connect(function()
        TweenService:Create(button, TweenInfo.new(0.2), {
            Size = UDim2.new(1, -scale("X", 20), 1, -scale("Y", 10))
        }):Play()
    end)

    button.MouseButton1Click:Connect(function()
        TweenService:Create(button, TweenInfo.new(0.1), {
            Size = UDim2.new(1, -scale("X", 25), 1, -scale("Y", 15))
        }):Play()
        wait(0.1)
        TweenService:Create(button, TweenInfo.new(0.1), {
            Size = UDim2.new(1, -scale("X", 20), 1, -scale("Y", 10))
        }):Play()
        
        if typeof(callback) == "function" then
            callback()
        end
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
        return request({
            Url = final_url,
            Method = "GET"
        })
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

-- END OF PART 4
-- Lanjutkan dengan copy paste Part 5 (TERAKHIR)

-- SYNCE EMOTES UI - PART 5/5 (FINAL)
-- Copy dan paste di BAWAH Part 4
-- Ini adalah bagian terakhir!

local function createViewport(size, position, parent)
    local viewportContainer = Instance.new("Frame")
    viewportContainer.Size = size
    viewportContainer.BackgroundTransparency = 1
    viewportContainer.Position = position
    viewportContainer.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
    viewportContainer.BorderSizePixel = 0
    viewportContainer.Parent = parent
    createCorner(viewportContainer, 8)
    
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
    if hrp then
        hrp.Transparency = 1
    end
    
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

local function createCard(item)
    local card = Instance.new("Frame")
    card.Size = UDim2.new(0, scale("X", 120), 0, scale("Y", 180))
    card.BackgroundColor3 = THEME.CardBg
    card.BackgroundTransparency = 0.2
    card.BorderSizePixel = 0
    createCorner(card, 12)
    
    -- Card hover effect
    card.MouseEnter:Connect(function()
        TweenService:Create(card, TweenInfo.new(0.2), {
            BackgroundTransparency = 0,
            Size = UDim2.new(0, scale("X", 125), 0, scale("Y", 185))
        }):Play()
    end)
    card.MouseLeave:Connect(function()
        TweenService:Create(card, TweenInfo.new(0.2), {
            BackgroundTransparency = 0.2,
            Size = UDim2.new(0, scale("X", 120), 0, scale("Y", 180))
        }):Play()
    end)
    
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
        img.BorderSizePixel = 0
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
    name.TextColor3 = THEME.Text
    name.Parent = card
    
    local url = "https://www.roblox.com/catalog/" .. tonumber(item.Id)
    local copyLinkButton = Instance.new("TextButton")
    copyLinkButton.Parent = card
    copyLinkButton.Size = UDim2.new(0, scale("X", 32), 0, scale("Y", 32))
    copyLinkButton.Position = UDim2.new(1, -scale("X", 38), 0, scale("Y", 5))
    copyLinkButton.BackgroundColor3 = THEME.Primary
    copyLinkButton.Text = "🔗"
    copyLinkButton.Font = Enum.Font.GothamBold
    copyLinkButton.TextSize = scale("Y", 16)
    copyLinkButton.TextColor3 = THEME.Text
    copyLinkButton.AutoButtonColor = false
    copyLinkButton.BorderSizePixel = 0
    createCorner(copyLinkButton, 8)

    copyLinkButton.MouseButton1Click:Connect(function()
        setclipboard(url)
        copyLinkButton.Text = "✅"
        TweenService:Create(copyLinkButton, TweenInfo.new(0.2), {BackgroundColor3 = THEME.Success}):Play()
        task.wait(0.7)
        copyLinkButton.Text = "🔗"
        TweenService:Create(copyLinkButton, TweenInfo.new(0.2), {BackgroundColor3 = THEME.Primary}):Play()
    end)

    local playBtn = Instance.new("TextButton")
    playBtn.Size = UDim2.new(0.45, -scale("X", 5), 0, scale("Y", 28))
    playBtn.Position = UDim2.new(0, scale("X", 5), 1, -scale("Y", 33))
    playBtn.BackgroundColor3 = THEME.Success
    playBtn.Text = "▶"
    playBtn.Font = Enum.Font.GothamBold
    playBtn.TextSize = scale("Y", 14)
    playBtn.TextColor3 = THEME.Text
    playBtn.AutoButtonColor = false
    playBtn.BorderSizePixel = 0
    playBtn.Parent = card
    createCorner(playBtn, 8)
    
    playBtn.MouseButton1Click:Connect(function()
        LoadTrack(thumbId)
        TweenService:Create(playBtn, TweenInfo.new(0.1), {Size = UDim2.new(0.45, -scale("X", 7), 0, scale("Y", 26))}):Play()
        wait(0.1)
        TweenService:Create(playBtn, TweenInfo.new(0.1), {Size = UDim2.new(0.45, -scale("X", 5), 0, scale("Y", 28))}):Play()
    end)
    
    local saveBtn = Instance.new("TextButton")
    saveBtn.Size = UDim2.new(0.45, -scale("X", 5), 0, scale("Y", 28))
    saveBtn.Position = UDim2.new(0.55, 0, 1, -scale("Y", 33))
    saveBtn.BackgroundColor3 = THEME.Primary
    saveBtn.Text = "💾"
    saveBtn.Font = Enum.Font.GothamBold
    saveBtn.TextSize = scale("Y", 14)
    saveBtn.TextColor3 = THEME.Text
    saveBtn.AutoButtonColor = false
    saveBtn.BorderSizePixel = 0
    saveBtn.Parent = card
    createCorner(saveBtn, 8)
    
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
            saveBtn.Text = "✅"
            TweenService:Create(saveBtn, TweenInfo.new(0.2), {BackgroundColor3 = THEME.Success}):Play()
            task.wait(1)
            saveBtn.Text = "💾"
            TweenService:Create(saveBtn, TweenInfo.new(0.2), {BackgroundColor3 = THEME.Primary}):Play()
        else
            saveBtn.Text = "✓"
            task.wait(0.7)
            saveBtn.Text = "💾"
        end
    end)
    return card
end

local scroll = Instance.new("ScrollingFrame")
scroll.Size = UDim2.new(1, -scale("X", 16), 1, -scale("Y", 100))
scroll.Position = UDim2.new(0, scale("X", 8), 0, scale("Y", 40))
scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
scroll.ScrollBarThickness = 4
scroll.ScrollBarImageColor3 = THEME.Primary
scroll.BackgroundTransparency = 1
scroll.BorderSizePixel = 0
scroll.Parent = catalogFrame

local layout = Instance.new("UIGridLayout", scroll)
layout.CellSize = UDim2.new(0, scale("X", 120), 0, scale("Y", 180))
layout.CellPadding = UDim2.new(0, scale("X", 8), 0, scale("Y", 8))

local emptyLabel = Instance.new("TextLabel", scroll)
emptyLabel.Size = UDim2.new(1, 0, 0, scale("Y", 40))
emptyLabel.Position = UDim2.new(0, 0, 0.5, -scale("Y", 20))
emptyLabel.BackgroundTransparency = 1
emptyLabel.Text = "🌊 No emotes found"
emptyLabel.TextColor3 = THEME.Accent
emptyLabel.Font = Enum.Font.GothamBold
emptyLabel.TextSize = scale("Y", 16)
emptyLabel.Visible = false

local prevBtn = Instance.new("TextButton", catalogFrame)
prevBtn.Size = UDim2.new(0.4, -scale("X", 6), 0, scale("Y", 36))
prevBtn.Position = UDim2.new(0, scale("X", 4), 1, -scale("Y", 40))
prevBtn.BackgroundColor3 = THEME.Primary
prevBtn.Text = "◀ Prev"
prevBtn.Font = Enum.Font.GothamBold
prevBtn.TextSize = scale("Y", 14)
prevBtn.TextColor3 = THEME.Text
prevBtn.AutoButtonColor = false
prevBtn.BorderSizePixel = 0
createCorner(prevBtn, 10)

local nextBtn = Instance.new("TextButton", catalogFrame)
nextBtn.Size = UDim2.new(0.4, -scale("X", 6), 0, scale("Y", 36))
nextBtn.Position = UDim2.new(0.6, scale("X", 2), 1, -scale("Y", 40))
nextBtn.BackgroundColor3 = THEME.Primary
nextBtn.Text = "Next ▶"
nextBtn.Font = Enum.Font.GothamBold
nextBtn.TextSize = scale("Y", 14)
nextBtn.TextColor3 = THEME.Text
nextBtn.AutoButtonColor = false
nextBtn.BorderSizePixel = 0
createCorner(nextBtn, 10)

local pageBox = Instance.new("TextBox", catalogFrame)
pageBox.Size = UDim2.new(0.2, 0, 0, scale("Y", 36))
pageBox.Position = UDim2.new(0.4, scale("X", 2), 1, -scale("Y", 40))
pageBox.BackgroundTransparency = 1
pageBox.Font = Enum.Font.Gotham
pageBox.TextSize = scale("Y", 12)
pageBox.TextColor3 = THEME.Text
pageBox.Text = "1"
pageBox.BorderSizePixel = 0

local pageNotif = Instance.new("TextLabel", catalogFrame)
pageNotif.Size = UDim2.new(0.3, 0, 0, scale("Y", 24))
pageNotif.Position = UDim2.new(0.35, 0, 1, -scale("Y", 68))
pageNotif.BackgroundTransparency = 1
pageNotif.TextColor3 = THEME.Danger
pageNotif.Font = Enum.Font.Gotham
pageNotif.TextSize = scale("Y", 12)
pageNotif.Text = ""
pageNotif.Visible = false

local function updateNavVisibility()
    prevBtn.Visible = (currentPageNumber > 1)
    if currentPages and typeof(currentPages.IsFinished) == "boolean" then
        nextBtn.Visible = not currentPages.IsFinished
    else
        nextBtn.Visible = true
    end
end

local RunService = game:GetService("RunService")
local isLoading = false

local function showPage()
    for _, child in ipairs(scroll:GetChildren()) do
        if child:IsA("Frame") then
            child:Destroy()
        end
    end

    local start_index = (CURRENT_PAGE_NUMBER - 1) * PAGE_SIZE_TINY + 1
    local end_index = start_index + PAGE_SIZE_TINY - 1

    local needsMoreData = false
    if start_index > #ITEM_CACHE and NEXT_API_CURSOR then
        needsMoreData = true
    end
    
    if needsMoreData then
        if pageBox then pageBox.Text = "Loading..." end
        local fetchWorked = GetEmoteDataFromWeb()
        if not fetchWorked then
            if pageBox then pageBox.Text = "Error" end
            return
        end
        start_index = (CURRENT_PAGE_NUMBER - 1) * PAGE_SIZE_TINY + 1
        end_index = start_index + PAGE_SIZE_TINY - 1
    end

    if pageBox then
        pageBox.Text = tostring(CURRENT_PAGE_NUMBER)
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
        
        if card then
            card.Parent = scroll
        end
        
        task.wait(0.01)
    end

    scroll.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + 8)
    
    if emptyLabel then
        emptyLabel.Visible = (#ITEM_CACHE == 0)
    end
end

local function fetchPagesTo(targetPage)
    local pages = getPages(currentKeyword)
    if not pages then return nil end
    for i = 2, targetPage do
        if pages.IsFinished then break end
        local ok, err = pcall(function() pages:AdvanceToNextPageAsync() end)
        if not ok then break end
    end
    return pages
end

local function doNewSearch(keyword)
    CURRENT_SEARCH_TEXT = keyword or ""
    CURRENT_PAGE_NUMBER = 1
    NEXT_API_CURSOR = nil
    ITEM_CACHE = {}
    
    if pageBox then
        pageBox.Text = "Loading..."
    end
    
    local fetchSuccess = GetEmoteDataFromWeb()
    
    if fetchSuccess then
        showPage()
    else
        if pageBox then
            pageBox.Text = "Failed"
        end
    end
end

refreshBtn.MouseButton1Click:Connect(function()
    doNewSearch(searchBox.Text)
end)

searchBox.FocusLost:Connect(function(enterPressed)
    if enterPressed then
        doNewSearch(searchBox.Text)
    end
end)

local currentSortIndex = 1

sortBtn.MouseButton1Click:Connect(function()
    currentSortIndex = currentSortIndex % #THE_SORT_LIST + 1
    CURRENT_SORT_OPTION = THE_SORT_LIST[currentSortIndex]
    sortBtn.Text = "📊"
    doNewSearch(CURRENT_SEARCH_TEXT)
end)

local UserInputService = game:GetService("UserInputService")

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
        pageNotif.Text = "Invalid page"
        pageNotif.Visible = true
        task.delay(2, function() 
            if pageNotif then 
                pageNotif.Visible = false 
            end 
        end)
        pageBox.Text = tostring(CURRENT_PAGE_NUMBER)
        return
    end
    
    local targetPage = math.floor(num)
    if targetPage == CURRENT_PAGE_NUMBER then
        pageBox.Text = tostring(CURRENT_PAGE_NUMBER)
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

catalogTabBtn.MouseButton1Click:Connect(function()
    catalogFrame.Visible = true
    savedFrame.Visible = false
    TweenService:Create(catalogTabBtn, TweenInfo.new(0.2), {BackgroundColor3 = THEME.Primary}):Play()
    TweenService:Create(savedTabBtn, TweenInfo.new(0.2), {BackgroundColor3 = THEME.CardBg}):Play()
end)

local function createSavedCard(item)
    local card = Instance.new("Frame")
    card.Size = UDim2.new(0, scale("X", 120), 0, scale("Y", 200))
    card.BackgroundColor3 = THEME.CardBg
    card.BackgroundTransparency = 0.2
    card.BorderSizePixel = 0
    createCorner(card, 12)
    
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
        img.BorderSizePixel = 0
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
    name.TextColor3 = THEME.Text
    name.Parent = card
    
    local playBtn = Instance.new("TextButton")
    playBtn.Size = UDim2.new(0.45, -scale("X", 5), 0, scale("Y", 28))
    playBtn.Position = UDim2.new(0, scale("X", 5), 1, -scale("Y", 33))
    playBtn.BackgroundColor3 = THEME.Success
    playBtn.Text = "▶"
    playBtn.Font = Enum.Font.GothamBold
    playBtn.TextSize = scale("Y", 14)
    playBtn.TextColor3 = THEME.Text
    playBtn.AutoButtonColor = false
    playBtn.BorderSizePixel = 0
    playBtn.Parent = card
    createCorner(playBtn, 8)
    playBtn.MouseButton1Click:Connect(function()
        LoadTrack(item.Id)
    end)
    
    local removeBtn = Instance.new("TextButton")
    removeBtn.Size = UDim2.new(0.45, -scale("X", 5), 0, scale("Y", 28))
    removeBtn.Position = UDim2.new(0.55, 0, 1, -scale("Y", 33))
    removeBtn.BackgroundColor3 = THEME.Danger
    removeBtn.Text = "✕"
    removeBtn.Font = Enum.Font.GothamBold
    removeBtn.TextSize = scale("Y", 14)
    removeBtn.TextColor3 = THEME.Text
    removeBtn.AutoButtonColor = false
    removeBtn.BorderSizePixel = 0
    removeBtn.Parent = card
    createCorner(removeBtn, 8)
    
    local copyBtn = Instance.new("TextButton")
    copyBtn.Size = UDim2.new(0, scale("X", 40), 0, scale("Y", 24))
    copyBtn.Position = UDim2.new(0.5, -scale("X", 20), 0, scale("Y", 5))
    copyBtn.BackgroundColor3 = THEME.Primary
    copyBtn.Text = "📋"
    copyBtn.Font = Enum.Font.GothamBold
    copyBtn.TextSize = scale("Y", 12)
    copyBtn.TextColor3 = THEME.Text
    copyBtn.AutoButtonColor = false
    copyBtn.BorderSizePixel = 0
    copyBtn.Parent = card
    createCorner(copyBtn, 6)

    copyBtn.MouseButton1Click:Connect(function()
        if setclipboard then
            setclipboard(item.AnimationId:gsub("rbxassetid://", ""))
        end
        copyBtn.Text = "✅"
        task.wait(0.7)
        copyBtn.Text = "📋"
    end)
    
    local favBtn = Instance.new("TextButton")
    favBtn.Size = UDim2.new(0, scale("X", 24), 0, scale("Y", 24))
    favBtn.Position = UDim2.new(1, -scale("X", 30), 0, scale("Y", 5))
    favBtn.Text = item.Favorite and "★" or "☆"
    favBtn.Font = Enum.Font.GothamBold
    favBtn.TextSize = scale("Y", 16)
    favBtn.TextColor3 = Color3.fromRGB(255, 215, 0)
    favBtn.BackgroundTransparency = 1
    favBtn.BorderSizePixel = 0
    favBtn.Parent = card
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

savedTabBtn.MouseButton1Click:Connect(function()
    catalogFrame.Visible = false
    savedFrame.Visible = true
    TweenService:Create(catalogTabBtn, TweenInfo.new(0.2), {BackgroundColor3 = THEME.CardBg}):Play()
    TweenService:Create(savedTabBtn, TweenInfo.new(0.2), {BackgroundColor3 = THEME.Primary}):Play()
    refreshSavedTab()
end)

local function doNewSearchInitial()
    doNewSearch("")
end