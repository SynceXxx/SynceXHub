-- ============================================================
-- SYNCE EMOTES - BLUE OCEAN EDITION
-- PART 1: Setup, Services & Theme Configuration
-- Created by SynceHub Team
-- ============================================================

-- ============================================================
-- BLUE OCEAN THEME
-- ============================================================
local BlueOceanTheme = {
    -- Main Backgrounds
    MainBG = Color3.fromRGB(15, 23, 42),
    SecondaryBG = Color3.fromRGB(30, 41, 59),
    CardBG = Color3.fromRGB(40, 50, 70),
    
    -- Accents
    Primary = Color3.fromRGB(30, 144, 255),
    PrimaryHover = Color3.fromRGB(56, 189, 248),
    Success = Color3.fromRGB(34, 197, 94),
    Warning = Color3.fromRGB(251, 146, 60),
    Error = Color3.fromRGB(239, 68, 68),
    
    -- Text (Clean - No Stroke)
    Text = Color3.fromRGB(248, 250, 252),
    TextSecondary = Color3.fromRGB(148, 163, 184),
    
    -- UI Elements
    Border = Color3.fromRGB(51, 65, 85),
    Divider = Color3.fromRGB(71, 85, 105),
    ButtonBG = Color3.fromRGB(51, 65, 85),
    ButtonHover = Color3.fromRGB(71, 85, 105),
    
    -- Size (Tidak terlalu lebar)
    Width = 560,
    Height = 380,
}

-- ============================================================
-- SCREEN & SCALING SETUP
-- ============================================================
local Screen = setmetatable({}, {
    __index = function(_, key)
        local cam = workspace.CurrentCamera
        local size = cam and cam.ViewportSize or Vector2.new(1920, 1080)
        if key == "Width" then
            return size.X
        elseif key == "Height" then
            return size.Y
        elseif key == "Size" then
            return size
        end 
    end
})

local UserInputService = game:GetService("UserInputService")
local ScreenSize = workspace.CurrentCamera.ViewportSize

function scale(axis, value)
    local isMobile = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled
    local baseWidth, baseHeight = 1920, 1080
    local scaleFactor = isMobile and 2 or 1.5

    if axis == "X" then
        return value * (ScreenSize.X / baseWidth) * scaleFactor
    elseif axis == "Y" then
        return value * (ScreenSize.Y / baseHeight) * scaleFactor
    end
end

function missing(t, f, fallback)
    if type(f) == t then return f end
    return fallback 
end

cloneref = missing("function", cloneref, function(...) return ... end)

-- ============================================================
-- SERVICES
-- ============================================================
local Services = setmetatable({}, {
    __index = function(_, name)
        return cloneref(game:GetService(name))
    end
})

local Players = Services.Players
local RunService = Services.RunService
local UserInputService = Services.UserInputService
local TweenService = Services.TweenService
local HttpService = Services.HttpService

-- ============================================================
-- PLAYER & CHARACTER SETUP
-- ============================================================
local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")
local lastPosition = character.PrimaryPart and character.PrimaryPart.Position or Vector3.new()

player.CharacterAdded:Connect(function(newCharacter)
    character = newCharacter
    humanoid = newCharacter:WaitForChild("Humanoid")
    lastPosition = character.PrimaryPart and character.PrimaryPart.Position or Vector3.new()
end)

-- ============================================================
-- SETTINGS & CONFIGURATION
-- ============================================================
local Settings = {}
Settings["Stop Emote When Moving"] = true
Settings["Fade In"] = 0.1
Settings["Fade Out"] = 0.1
Settings["Weight"] = 1
Settings["Speed"] = 1
Settings["Allow Invisible"] = true
Settings["Time Position"] = 0
Settings["Freeze On Finish"] = false
Settings["Looped"] = true
Settings["Stop Other Animations On Play"] = true
Settings["Preview"] = false

-- ============================================================
-- SAVE FILE & EMOTE STORAGE
-- ============================================================
local savedEmotes = {}
local SAVE_FILE = "SynceEmotes_Saved.json"

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

-- ============================================================
-- ANIMATION TRACKING
-- ============================================================
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
        for _, t in pairs(humanoid.Animator:GetPlayingAnimationTracks()) do
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

-- ============================================================
-- STOP EMOTE WHEN MOVING
-- ============================================================
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

print("[Synce Emotes] Part 1 loaded ✓")
print("[Synce Emotes] Services & Settings initialized")

-- ============================================================
-- SYNCE EMOTES - BLUE OCEAN EDITION
-- PART 2: UI Creation & Helper Functions
-- Paste after Part 1
-- ============================================================

-- ============================================================
-- HELPER FUNCTIONS
-- ============================================================
local function createCorner(parent, cornerRadius)
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, cornerRadius)
    corner.Parent = parent
    return corner
end

local function createStroke(parent, color, thickness, transparency)
    local stroke = Instance.new("UIStroke")
    stroke.Color = color or BlueOceanTheme.Border
    stroke.Thickness = thickness or 2
    stroke.Transparency = transparency or 0.3
    stroke.Parent = parent
    return stroke
end

-- ============================================================
-- MAIN GUI SETUP
-- ============================================================
local CoreGui = Services.CoreGui
local gui = Instance.new("ScreenGui")
gui.Name = "SynceEmoteGUI"
gui.Parent = CoreGui
gui.Enabled = false
gui.DisplayOrder = 999

-- ============================================================
-- MAIN CONTAINER
-- ============================================================
local mainContainer = Instance.new("Frame")
mainContainer.Size = UDim2.new(0, BlueOceanTheme.Width, 0, BlueOceanTheme.Height)
mainContainer.Position = UDim2.new(0.5, -(BlueOceanTheme.Width/2), 0.5, -(BlueOceanTheme.Height/2))
mainContainer.BackgroundColor3 = BlueOceanTheme.MainBG
mainContainer.Active = true
mainContainer.Draggable = true
mainContainer.Parent = gui

createCorner(mainContainer, 12)
createStroke(mainContainer, BlueOceanTheme.Border, 2, 0.3)

-- Add shadow
local shadow = Instance.new("ImageLabel")
shadow.Name = "Shadow"
shadow.BackgroundTransparency = 1
shadow.Image = "rbxassetid://5554236805"
shadow.ImageColor3 = Color3.fromRGB(0, 0, 0)
shadow.ImageTransparency = 0.7
shadow.ScaleType = Enum.ScaleType.Slice
shadow.SliceCenter = Rect.new(23, 23, 277, 277)
shadow.Size = UDim2.new(1, 30, 1, 30)
shadow.Position = UDim2.new(0, -15, 0, -15)
shadow.ZIndex = -1
shadow.Parent = mainContainer

-- Position clamping
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

-- ============================================================
-- TITLE BAR
-- ============================================================
local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, scale("Y", 36))
title.BackgroundColor3 = BlueOceanTheme.SecondaryBG
title.Text = "Synce Emotes"
title.TextColor3 = BlueOceanTheme.Text
title.Font = Enum.Font.GothamBold
title.TextScaled = true
title.TextStrokeTransparency = 1 -- Clean look
title.Parent = mainContainer
createCorner(title, 8)

-- ============================================================
-- TAB BUTTONS
-- ============================================================
local catalogTabBtn = Instance.new("TextButton")
catalogTabBtn.Size = UDim2.new(0.3, 0, 0, scale("Y", 24))
catalogTabBtn.Position = UDim2.new(0.05, 0, 0, scale("Y", 40))
catalogTabBtn.BackgroundColor3 = BlueOceanTheme.Primary
catalogTabBtn.Text = "Catalog"
catalogTabBtn.TextColor3 = BlueOceanTheme.Text
catalogTabBtn.Font = Enum.Font.GothamBold
catalogTabBtn.TextScaled = true
catalogTabBtn.TextStrokeTransparency = 1
catalogTabBtn.Parent = mainContainer
createCorner(catalogTabBtn, 6)

local savedTabBtn = Instance.new("TextButton")
savedTabBtn.Size = UDim2.new(0.3, 0, 0, scale("Y", 24))
savedTabBtn.Position = UDim2.new(0.35, 0, 0, scale("Y", 40))
savedTabBtn.BackgroundColor3 = BlueOceanTheme.ButtonBG
savedTabBtn.Text = "Saved"
savedTabBtn.TextColor3 = BlueOceanTheme.Text
savedTabBtn.Font = Enum.Font.GothamBold
savedTabBtn.TextScaled = true
savedTabBtn.TextStrokeTransparency = 1
savedTabBtn.Parent = mainContainer
createCorner(savedTabBtn, 6)

-- ============================================================
-- DIVIDER
-- ============================================================
local divider = Instance.new("Frame")
divider.Size = UDim2.new(0, scale("X", 2), 1, -scale("Y", 70))
divider.Position = UDim2.new(0.6, -scale("X", 1), 0, scale("Y", 70))
divider.BackgroundColor3 = BlueOceanTheme.Divider
divider.Parent = mainContainer
createCorner(divider, 1)

-- ============================================================
-- CATALOG FRAME
-- ============================================================
local catalogFrame = Instance.new("Frame")
catalogFrame.Size = UDim2.new(0.6, -scale("X", 10), 1, -scale("Y", 70))
catalogFrame.Position = UDim2.new(0, scale("X", 5), 0, scale("Y", 70))
catalogFrame.BackgroundTransparency = 1
catalogFrame.Visible = true
catalogFrame.Parent = mainContainer

local searchBox = Instance.new("TextBox")
searchBox.Size = UDim2.new(0.6, -scale("X", 8), 0, scale("Y", 28))
searchBox.Position = UDim2.new(0, scale("X", 8), 0, 0)
searchBox.PlaceholderText = "Search..."
searchBox.BackgroundColor3 = BlueOceanTheme.CardBG
searchBox.TextColor3 = BlueOceanTheme.Text
searchBox.PlaceholderColor3 = BlueOceanTheme.TextSecondary
searchBox.Font = Enum.Font.Gotham
searchBox.TextScaled = true
searchBox.TextStrokeTransparency = 1
searchBox.ClearTextOnFocus = false
searchBox.Text = ""
searchBox.Parent = catalogFrame
createCorner(searchBox, 6)

local refreshBtn = Instance.new("TextButton")
refreshBtn.Size = UDim2.new(0.2, -scale("X", 4), 0, scale("Y", 28))
refreshBtn.Position = UDim2.new(0.6, scale("X", 4), 0, 0)
refreshBtn.BackgroundColor3 = BlueOceanTheme.Primary
refreshBtn.Text = "Refresh"
refreshBtn.Font = Enum.Font.GothamBold
refreshBtn.TextScaled = true
refreshBtn.TextStrokeTransparency = 1
refreshBtn.TextColor3 = BlueOceanTheme.Text
refreshBtn.Parent = catalogFrame
createCorner(refreshBtn, 6)

local sortBtn = Instance.new("TextButton")
sortBtn.Size = UDim2.new(0.2, -scale("X", 8), 0, scale("Y", 28))
sortBtn.Position = UDim2.new(0.8, scale("X", 4), 0, 0)
sortBtn.BackgroundColor3 = BlueOceanTheme.ButtonBG
sortBtn.Text = "Sort: Relevance"
sortBtn.Font = Enum.Font.GothamBold
sortBtn.TextScaled = true
sortBtn.TextStrokeTransparency = 1
sortBtn.TextColor3 = BlueOceanTheme.Text
sortBtn.Parent = catalogFrame
createCorner(sortBtn, 6)

-- ============================================================
-- SAVED FRAME
-- ============================================================
local savedFrame = Instance.new("Frame")
savedFrame.Size = UDim2.new(0.6, -scale("X", 10), 1, -scale("Y", 70))
savedFrame.Position = UDim2.new(0, scale("X", 5), 0, scale("Y", 70))
savedFrame.BackgroundTransparency = 1
savedFrame.Visible = false
savedFrame.Parent = mainContainer

local savedSearch = Instance.new("TextBox")
savedSearch.Size = UDim2.new(1, -scale("X", 16), 0, scale("Y", 28))
savedSearch.Position = UDim2.new(0, scale("X", 8), 0, 0)
savedSearch.PlaceholderText = "Search Saved..."
savedSearch.BackgroundColor3 = BlueOceanTheme.CardBG
savedSearch.TextColor3 = BlueOceanTheme.Text
savedSearch.PlaceholderColor3 = BlueOceanTheme.TextSecondary
savedSearch.Font = Enum.Font.Gotham
savedSearch.TextScaled = true
savedSearch.TextStrokeTransparency = 1
savedSearch.ClearTextOnFocus = false
savedSearch.Text = ""
savedSearch.Parent = savedFrame
createCorner(savedSearch, 6)

local savedScroll = Instance.new("ScrollingFrame")
savedScroll.Size = UDim2.new(1, -scale("X", 16), 1, -scale("Y", 40))
savedScroll.Position = UDim2.new(0, scale("X", 8), 0, scale("Y", 36))
savedScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
savedScroll.ScrollBarThickness = 6
savedScroll.ScrollBarImageColor3 = BlueOceanTheme.Primary
savedScroll.BackgroundTransparency = 1
savedScroll.Parent = savedFrame

local savedEmptyLabel = Instance.new("TextLabel")
savedEmptyLabel.Size = UDim2.new(1, 0, 0, scale("Y", 36))
savedEmptyLabel.Position = UDim2.new(0, 0, 0.5, -scale("Y", 18))
savedEmptyLabel.BackgroundTransparency = 1
savedEmptyLabel.Text = "No saved emotes yet"
savedEmptyLabel.TextColor3 = BlueOceanTheme.TextSecondary
savedEmptyLabel.Font = Enum.Font.GothamBold
savedEmptyLabel.TextScaled = true
savedEmptyLabel.TextStrokeTransparency = 1
savedEmptyLabel.Visible = false
savedEmptyLabel.Parent = savedScroll

local savedLayout = Instance.new("UIGridLayout")
savedLayout.CellSize = UDim2.new(0, scale("X", 120), 0, scale("Y", 200))
savedLayout.CellPadding = UDim2.new(0, scale("X", 8), 0, scale("Y", 8))
savedLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
savedLayout.Parent = savedScroll

-- ============================================================
-- SETTINGS FRAME
-- ============================================================
local settingsFrame = Instance.new("Frame")
settingsFrame.Size = UDim2.new(0.4, -scale("X", 10), 1, -scale("Y", 70))
settingsFrame.Position = UDim2.new(0.6, scale("X", 5), 0, scale("Y", 70))
settingsFrame.BackgroundTransparency = 1
settingsFrame.Parent = mainContainer

local settingsTitle = Instance.new("TextLabel")
settingsTitle.Size = UDim2.new(1, 0, 0, scale("Y", 28))
settingsTitle.BackgroundTransparency = 1
settingsTitle.Text = "Settings"
settingsTitle.TextColor3 = BlueOceanTheme.Text
settingsTitle.Font = Enum.Font.GothamBold
settingsTitle.TextScaled = true
settingsTitle.TextStrokeTransparency = 1
settingsTitle.Parent = settingsFrame

local scrollFrame = Instance.new("ScrollingFrame")
scrollFrame.Size = UDim2.new(1, -scale("X", 20), 1, -scale("Y", 40))
scrollFrame.Position = UDim2.new(0, scale("X", 10), 0, scale("Y", 30))
scrollFrame.BackgroundTransparency = 1
scrollFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
scrollFrame.ScrollBarThickness = 6
scrollFrame.ScrollBarImageColor3 = BlueOceanTheme.Primary
scrollFrame.Parent = settingsFrame

local function lockX()
    scrollFrame.CanvasPosition = Vector2.new(0, scrollFrame.CanvasPosition.Y)
end
scrollFrame:GetPropertyChangedSignal("CanvasPosition"):Connect(lockX)

local listLayout = Instance.new("UIListLayout", scrollFrame)
listLayout.Padding = UDim.new(0, 6)
listLayout.FillDirection = Enum.FillDirection.Vertical
listLayout.SortOrder = Enum.SortOrder.LayoutOrder

listLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    scrollFrame.CanvasSize = UDim2.new(0, 0, 0, listLayout.AbsoluteContentSize.Y + 10)
end)

print("[Synce Emotes] Part 2 loaded ✓")
print("[Synce Emotes] UI created successfully")

-- ============================================================
-- SYNCE EMOTES - BLUE OCEAN EDITION
-- PART 3: Settings Controls, Sliders & Toggles
-- Paste after Part 2
-- ============================================================

Settings._sliders = {}
Settings._toggles = {}

-- ============================================================
-- SLIDER CREATOR
-- ============================================================
local function createSlider(name, min, max, default)
    Settings[name] = default or min

    local container = Instance.new("Frame")
    container.Size = UDim2.new(1, 0, 0, scale("Y", 65))
    container.BackgroundTransparency = 1
    container.Parent = scrollFrame

    local bg = Instance.new("Frame")
    bg.Size = UDim2.new(1, 0, 1, 0)
    bg.BackgroundColor3 = BlueOceanTheme.CardBG
    bg.Parent = container
    createCorner(bg, 8)

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.5, -scale("X", 10), 0, scale("Y", 20))
    label.Position = UDim2.new(0, 10, 0, 5)
    label.BackgroundTransparency = 1
    label.Text = string.format("%s: %.2f", name, Settings[name])
    label.TextColor3 = BlueOceanTheme.Text
    label.Font = Enum.Font.Gotham
    label.TextScaled = true
    label.TextStrokeTransparency = 1
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = bg

    local textBox = Instance.new("TextBox")
    textBox.Size = UDim2.new(0.5, -scale("X", 20), 0, scale("Y", 20))
    textBox.Position = UDim2.new(0.5, scale("X", 10), 0, scale("Y", 5))
    textBox.BackgroundColor3 = BlueOceanTheme.SecondaryBG
    textBox.Text = tostring(Settings[name])
    textBox.TextColor3 = BlueOceanTheme.Text
    textBox.Font = Enum.Font.Gotham
    textBox.TextScaled = true
    textBox.TextStrokeTransparency = 1
    textBox.ClearTextOnFocus = false
    textBox.Parent = bg
    createCorner(textBox, 6)

    local sliderBar = Instance.new("Frame")
    sliderBar.Size = UDim2.new(1, -scale("X", 40), 0, scale("Y", 12))
    sliderBar.Position = UDim2.new(0, scale("X", 20), 0, scale("Y", 35))
    sliderBar.BackgroundColor3 = BlueOceanTheme.SecondaryBG
    sliderBar.Parent = bg
    createCorner(sliderBar, 6)

    local sliderFill = Instance.new("Frame")
    sliderFill.Size = UDim2.new(0, 0, 1, 0)
    sliderFill.BackgroundColor3 = BlueOceanTheme.Primary
    sliderFill.Parent = sliderBar
    createCorner(sliderFill, 6)

    local thumb = Instance.new("Frame")
    thumb.Size = UDim2.new(0, scale("X", 20), 0, scale("Y", 20))
    thumb.AnchorPoint = Vector2.new(0.5, 0.5)
    thumb.Position = UDim2.new(0, 0, 0.5, 0)
    thumb.BackgroundColor3 = BlueOceanTheme.Text
    thumb.Parent = sliderBar
    createCorner(thumb, 10)

    local function tweenVisual(rel)
        local visualRel = math.clamp(rel, 0, 1)
        TweenService:Create(sliderFill, TweenInfo.new(0.15), {Size = UDim2.new(visualRel, 0, 1, 0)}):Play()
        TweenService:Create(thumb, TweenInfo.new(0.15), {Position = UDim2.new(visualRel, 0, 0.5, 0)}):Play()
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

-- ============================================================
-- TOGGLE CREATOR
-- ============================================================
local function createToggle(name)
    Settings[name] = Settings[name] or false

    local container = Instance.new("Frame")
    container.Size = UDim2.new(1, 0, 0, scale("Y", 40))
    container.BackgroundColor3 = BlueOceanTheme.CardBG
    container.Parent = scrollFrame
    createCorner(container, 6)

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.7, -scale("X", 10), 1, 0)
    label.Position = UDim2.new(0, scale("X", 10), 0, 0)
    label.BackgroundTransparency = 1
    label.Text = name
    label.TextColor3 = BlueOceanTheme.Text
    label.Font = Enum.Font.Gotham
    label.TextScaled = true
    label.TextStrokeTransparency = 1
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = container

    local toggleBtn = Instance.new("TextButton")
    toggleBtn.Size = UDim2.new(0, scale("X", 60), 0, scale("Y", 24))
    toggleBtn.Position = UDim2.new(1, -scale("X", 70), 0.5, -scale("Y", 12))
    toggleBtn.TextColor3 = BlueOceanTheme.Text
    toggleBtn.Font = Enum.Font.GothamBold
    toggleBtn.TextScaled = true
    toggleBtn.TextStrokeTransparency = 1
    toggleBtn.Parent = container
    createCorner(toggleBtn, 12)

    local function applyVisual(state)
        toggleBtn.Text = state and "ON" or "OFF"
        toggleBtn.BackgroundColor3 = state and BlueOceanTheme.Success or BlueOceanTheme.Error
    end

    toggleBtn.MouseButton1Click:Connect(function()
        Settings[name] = not Settings[name]
        applyVisual(Settings[name])
    end)

    applyVisual(Settings[name])
    Settings._toggles[name] = applyVisual
end

-- ============================================================
-- BUTTON CREATOR
-- ============================================================
local function createButton(name, callback)
    local container = Instance.new("Frame")
    container.Size = UDim2.new(1, 0, 0, scale("Y", 45))
    container.BackgroundColor3 = BlueOceanTheme.CardBG
    container.Parent = scrollFrame
    createCorner(container, 6)

    local button = Instance.new("TextButton")
    button.Size = UDim2.new(1, -scale("X", 20), 1, -scale("Y", 10))
    button.Position = UDim2.new(0, scale("X", 10), 0, scale("Y", 5))
    button.BackgroundColor3 = BlueOceanTheme.Primary
    button.Text = name
    button.TextColor3 = BlueOceanTheme.Text
    button.Font = Enum.Font.GothamBold
    button.TextScaled = true
    button.TextStrokeTransparency = 1
    button.Parent = container
    createCorner(button, 8)

    button.MouseButton1Click:Connect(function()
        if typeof(callback) == "function" then
            callback()
        end
    end)

    return button
end

-- ============================================================
-- EDIT FUNCTIONS
-- ============================================================
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

-- ============================================================
-- CREATE ALL SETTINGS CONTROLS
-- ============================================================
local resetButton = createButton("Reset Settings", function() end)
createToggle("Preview")
createToggle("Stop Emote When Moving")
createToggle("Looped")
createSlider("Speed", 0, 5, Settings["Speed"])
createSlider("Time Position", 0, 1, Settings["Time Position"])
createSlider("Weight", 0, 1, Settings["Weight"])
createSlider("Fade In", 0, 2, Settings["Fade In"])
createSlider("Fade Out", 0, 2, Settings["Fade Out"])
createToggle("Allow Invisible")
createToggle("Stop Other Animations On Play")

-- Reset button functionality
resetButton.MouseButton1Click:Connect(function()
    Settings:EditToggle("Stop Emote When Moving", true)
    Settings:EditToggle("Stop Other Animations On Play", true)
    Settings:EditToggle("Preview", false)
    Settings:EditSlider("Fade In", 0.1)
    Settings:EditSlider("Fade Out", 0.1)
    Settings:EditSlider("Weight", 1)
    Settings:EditSlider("Speed", 1)
    Settings:EditToggle("Allow Invisible", true)
    Settings:EditSlider("Time Position", 0)
    Settings:EditToggle("Freeze On Finish", false)
    Settings:EditToggle("Looped", true)
end)

-- ============================================================
-- COLLISION FIX (Allow Invisible)
-- ============================================================
local originalCollisionStates = {}
local lastFixClipState = Settings["Allow Invisible"]

local function saveCollisionStates()
    for _, part in ipairs(character:GetDescendants()) do
        if part:IsA("BasePart") and part ~= character.PrimaryPart then
            originalCollisionStates[part] = part.CanCollide
        end
    end
end

local function disableCollisionsExceptRootPart()
    if not Settings["Allow Invisible"] then return end
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
        local currentFixClip = Settings["Allow Invisible"]
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
    lastFixClipState = Settings["Allow Invisible"]
end)

print("[Synce Emotes] Part 3 loaded ✓")
print("[Synce Emotes] Settings controls created")

-- ============================================================
-- SYNCE EMOTES - BLUE OCEAN EDITION
-- PART 4: Catalog System, API & Card Creation
-- Paste after Part 3
-- ============================================================

-- ============================================================
-- CATALOG API CONFIGURATION
-- ============================================================
local CATALOG_URL = "https://catalog.roproxy.com/v2/search/items/details"
local EMOTE_ASSET_TYPE = 61
local BIG_FETCH_LIMIT = 120
local PAGE_SIZE_TINY = 10
local THE_SORT_LIST = {"Updated", "Relevance", "Favorited", "Sales", "PriceAsc", "PriceDesc"}

-- State Management
local ITEM_CACHE = {}
local NEXT_API_CURSOR = nil
local CURRENT_PAGE_NUMBER = 1
local CURRENT_SORT_OPTION = "Updated"
local CURRENT_SEARCH_TEXT = ""

-- ============================================================
-- API FETCH FUNCTION
-- ============================================================
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
        return request({
            Url = final_url,
            Method = "GET"
        })
    end)

    if not success or not result or not result.Success then
        return false
    end

    response = result.Body

    local data_table
    success, data_table = pcall(function()
        return HttpService:JSONDecode(response)
    end)

    if not success or not data_table or not data_table.data then
        return false
    end

    for _, item in pairs(data_table.data) do
        table.insert(ITEM_CACHE, item)
    end
    
    NEXT_API_CURSOR = data_table.nextPageCursor
    return true
end

-- ============================================================
-- CARD CREATOR (CATALOG)
-- ============================================================
local function createCard(item)
    local card = Instance.new("Frame")
    card.Size = UDim2.new(0, scale("X", 120), 0, scale("Y", 180))
    card.BackgroundColor3 = BlueOceanTheme.CardBG
    card.Parent = nil
    createCorner(card, 8)
    
    local thumbId = item.id or item.Id or item.AssetId
    
    -- Thumbnail
    local img = Instance.new("ImageLabel")
    img.Size = UDim2.new(1, -scale("X", 10), 0, scale("Y", 90))
    img.Position = UDim2.new(0, scale("X", 5), 0, scale("Y", 5))
    img.BackgroundTransparency = 1
    img.ScaleType = Enum.ScaleType.Fit
    pcall(function()
        img.Image = "rbxthumb://type=Asset&id=" .. tonumber(thumbId) .. "&w=150&h=150"
    end)
    img.Parent = card
    createCorner(img, 6)
    
    -- Name
    local name = Instance.new("TextLabel")
    name.Size = UDim2.new(1, -scale("X", 10), 0, scale("Y", 28))
    name.Position = UDim2.new(0, scale("X", 5), 0, scale("Y", 100))
    name.BackgroundTransparency = 1
    name.Text = item.name or item.Name or "Unknown"
    name.TextScaled = true
    name.TextWrapped = true
    name.Font = Enum.Font.GothamBold
    name.TextColor3 = BlueOceanTheme.Text
    name.TextStrokeTransparency = 1
    name.Parent = card
    
    -- Copy Link Button
    local copyBtn = Instance.new("TextButton")
    copyBtn.Size = UDim2.new(0, scale("X", 36), 0, scale("Y", 36))
    copyBtn.Position = UDim2.new(1, -scale("X", 42), 0, scale("Y", 5))
    copyBtn.BackgroundColor3 = BlueOceanTheme.ButtonBG
    copyBtn.Text = "🔗"
    copyBtn.Font = Enum.Font.GothamBold
    copyBtn.TextScaled = true
    copyBtn.TextColor3 = BlueOceanTheme.Text
    copyBtn.TextStrokeTransparency = 1
    copyBtn.Parent = card
    createCorner(copyBtn, 8)
    
    copyBtn.MouseButton1Click:Connect(function()
        local url = "https://www.roblox.com/catalog/" .. tostring(item.id or item.Id)
        setclipboard(url)
        copyBtn.Text = "✅"
        copyBtn.BackgroundColor3 = BlueOceanTheme.Success
        task.wait(0.7)
        copyBtn.Text = "🔗"
        copyBtn.BackgroundColor3 = BlueOceanTheme.ButtonBG
    end)
    
    -- Play Button
    local playBtn = Instance.new("TextButton")
    playBtn.Size = UDim2.new(0.45, -scale("X", 5), 0, scale("Y", 24))
    playBtn.Position = UDim2.new(0, scale("X", 5), 1, -scale("Y", 29))
    playBtn.BackgroundColor3 = BlueOceanTheme.Success
    playBtn.Text = "Play"
    playBtn.Font = Enum.Font.GothamBold
    playBtn.TextScaled = true
    playBtn.TextColor3 = BlueOceanTheme.Text
    playBtn.TextStrokeTransparency = 1
    playBtn.Parent = card
    createCorner(playBtn, 6)
    
    playBtn.MouseButton1Click:Connect(function()
        LoadTrack(thumbId)
    end)
    
    -- Save Button
    local saveBtn = Instance.new("TextButton")
    saveBtn.Size = UDim2.new(0.45, -scale("X", 5), 0, scale("Y", 24))
    saveBtn.Position = UDim2.new(0.55, 0, 1, -scale("Y", 29))
    saveBtn.BackgroundColor3 = BlueOceanTheme.Primary
    saveBtn.Text = "Save"
    saveBtn.Font = Enum.Font.GothamBold
    saveBtn.TextScaled = true
    saveBtn.TextColor3 = BlueOceanTheme.Text
    saveBtn.TextStrokeTransparency = 1
    saveBtn.Parent = card
    createCorner(saveBtn, 6)
    
    saveBtn.MouseButton1Click:Connect(function()
        local alreadySaved = false
        for _, saved in ipairs(savedEmotes) do
            if saved.Id == (item.id or item.Id) then
                alreadySaved = true
                break
            end
        end
        if not alreadySaved then
            local realId = getanimid(thumbId)
            table.insert(savedEmotes, {
                Id = item.id or item.Id,
                AssetId = thumbId,
                Name = item.name or item.Name or "Unknown",
                AnimationId = "rbxassetid://" .. tostring(realId),
                Favorite = false
            })
            saveEmotesToData()
            saveBtn.Text = "Saved!"
            saveBtn.BackgroundColor3 = BlueOceanTheme.Success
            task.wait(1)
            saveBtn.Text = "Save"
            saveBtn.BackgroundColor3 = BlueOceanTheme.Primary
        else
            saveBtn.Text = "Already"
            task.wait(0.7)
            saveBtn.Text = "Save"
        end
    end)
    
    return card
end

-- ============================================================
-- CATALOG SCROLL SETUP
-- ============================================================
local scroll = Instance.new("ScrollingFrame")
scroll.Size = UDim2.new(1, -scale("X", 16), 1, -scale("Y", 100))
scroll.Position = UDim2.new(0, scale("X", 8), 0, scale("Y", 36))
scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
scroll.ScrollBarThickness = 6
scroll.ScrollBarImageColor3 = BlueOceanTheme.Primary
scroll.BackgroundTransparency = 1
scroll.Parent = catalogFrame

local layout = Instance.new("UIGridLayout", scroll)
layout.CellSize = UDim2.new(0, scale("X", 120), 0, scale("Y", 180))
layout.CellPadding = UDim2.new(0, scale("X", 5), 0, scale("Y", 5))

local emptyLabel = Instance.new("TextLabel", scroll)
emptyLabel.Size = UDim2.new(1, 0, 0, scale("Y", 36))
emptyLabel.Position = UDim2.new(0, 0, 0.5, -scale("Y", 18))
emptyLabel.BackgroundTransparency = 1
emptyLabel.Text = "No emotes found"
emptyLabel.TextColor3 = BlueOceanTheme.TextSecondary
emptyLabel.Font = Enum.Font.GothamBold
emptyLabel.TextScaled = true
emptyLabel.TextStrokeTransparency = 1
emptyLabel.Visible = false

-- ============================================================
-- PAGINATION BUTTONS
-- ============================================================
local prevBtn = Instance.new("TextButton", catalogFrame)
prevBtn.Size = UDim2.new(0.4, -scale("X", 6), 0, scale("Y", 32))
prevBtn.Position = UDim2.new(0, scale("X", 4), 1, -scale("Y", 36))
prevBtn.BackgroundColor3 = BlueOceanTheme.ButtonBG
prevBtn.Text = "< Prev"
prevBtn.Font = Enum.Font.GothamBold
prevBtn.TextScaled = true
prevBtn.TextColor3 = BlueOceanTheme.Text
prevBtn.TextStrokeTransparency = 1
createCorner(prevBtn, 6)

local nextBtn = Instance.new("TextButton", catalogFrame)
nextBtn.Size = UDim2.new(0.4, -scale("X", 6), 0, scale("Y", 32))
nextBtn.Position = UDim2.new(0.6, scale("X", 2), 1, -scale("Y", 36))
nextBtn.BackgroundColor3 = BlueOceanTheme.ButtonBG
nextBtn.Text = "Next >"
nextBtn.Font = Enum.Font.GothamBold
nextBtn.TextScaled = true
nextBtn.TextColor3 = BlueOceanTheme.Text
nextBtn.TextStrokeTransparency = 1
createCorner(nextBtn, 6)

local pageBox = Instance.new("TextBox", catalogFrame)
pageBox.Size = UDim2.new(0.2, 0, 0, scale("Y", 32))
pageBox.Position = UDim2.new(0.4, scale("X", 2), 1, -scale("Y", 36))
pageBox.BackgroundTransparency = 1
pageBox.Font = Enum.Font.Gotham
pageBox.TextScaled = true
pageBox.TextColor3 = BlueOceanTheme.Text
pageBox.TextStrokeTransparency = 1
pageBox.Text = "1"

-- ============================================================
-- PAGE DISPLAY FUNCTION
-- ============================================================
local function showPage()
    for _, child in ipairs(scroll:GetChildren()) do
        if child:IsA("Frame") then
            child:Destroy()
        end
    end

    local start_index = (CURRENT_PAGE_NUMBER - 1) * PAGE_SIZE_TINY + 1
    local end_index = start_index + PAGE_SIZE_TINY - 1

    if start_index > #ITEM_CACHE and NEXT_API_CURSOR then
        pageBox.Text = "Loading..."
        local fetchWorked = GetEmoteDataFromWeb()
        if not fetchWorked then
            pageBox.Text = "Error"
            return
        end
        start_index = (CURRENT_PAGE_NUMBER - 1) * PAGE_SIZE_TINY + 1
        end_index = start_index + PAGE_SIZE_TINY - 1
    end

    pageBox.Text = tostring(CURRENT_PAGE_NUMBER)
    prevBtn.Active = (CURRENT_PAGE_NUMBER > 1)
    nextBtn.Active = (end_index < #ITEM_CACHE) or (NEXT_API_CURSOR ~= nil)

    for i = start_index, math.min(end_index, #ITEM_CACHE) do
        local item = ITEM_CACHE[i]
        local card = createCard(item)
        if card then
            card.Parent = scroll
        end
        task.wait(0.01)
    end

    scroll.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + 8)
    emptyLabel.Visible = (#ITEM_CACHE == 0)
end

-- ============================================================
-- SEARCH & NAVIGATION
-- ============================================================
local function doNewSearch(keyword)
    CURRENT_SEARCH_TEXT = keyword or ""
    CURRENT_PAGE_NUMBER = 1
    NEXT_API_CURSOR = nil
    ITEM_CACHE = {}
    pageBox.Text = "Loading..."
    local fetchSuccess = GetEmoteDataFromWeb()
    if fetchSuccess then
        showPage()
    else
        pageBox.Text = "Failed"
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
    sortBtn.Text = "Sort: " .. CURRENT_SORT_OPTION
    doNewSearch(CURRENT_SEARCH_TEXT)
end)

nextBtn.MouseButton1Click:Connect(function()
    local currentStart = (CURRENT_PAGE_NUMBER * PAGE_SIZE_TINY) + 1
    if currentStart <= #ITEM_CACHE or NEXT_API_CURSOR ~= nil then
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

pageBox.FocusLost:Connect(function(enterPressed)
    if not enterPressed then return end
    local num = tonumber(pageBox.Text)
    if num and num >= 1 then
        CURRENT_PAGE_NUMBER = math.floor(num)
        showPage()
    end
end)

-- Initial load
doNewSearch("")

print("[Synce Emotes] Part 4 loaded ✓")
print("[Synce Emotes] Catalog system ready")

-- ============================================================
-- SYNCE EMOTES - BLUE OCEAN EDITION
-- PART 5: Saved Tab, Custom Toggle Button & Finalization
-- Paste after Part 4 - This is the FINAL part!
-- ============================================================

-- ============================================================
-- SAVED CARD CREATOR
-- ============================================================
local function createSavedCard(item)
    local card = Instance.new("Frame")
    card.Size = UDim2.new(0, scale("X", 120), 0, scale("Y", 200))
    card.BackgroundColor3 = BlueOceanTheme.CardBG
    createCorner(card, 8)
    
    -- Thumbnail
    local img = Instance.new("ImageLabel")
    img.Size = UDim2.new(1, -scale("X", 10), 0, scale("Y", 90))
    img.Position = UDim2.new(0, scale("X", 5), 0, scale("Y", 5))
    img.BackgroundTransparency = 1
    img.ScaleType = Enum.ScaleType.Fit
    img.Image = "rbxthumb://type=Asset&id=" .. tostring(item.AssetId or item.Id) .. "&w=150&h=150"
    img.Parent = card
    createCorner(img, 6)
    
    -- Name
    local name = Instance.new("TextLabel")
    name.Size = UDim2.new(1, -scale("X", 10), 0, scale("Y", 28))
    name.Position = UDim2.new(0, scale("X", 5), 0, scale("Y", 100))
    name.BackgroundTransparency = 1
    name.Text = item.Name or "Unknown"
    name.TextScaled = true
    name.TextWrapped = true
    name.Font = Enum.Font.GothamBold
    name.TextColor3 = BlueOceanTheme.Text
    name.TextStrokeTransparency = 1
    name.Parent = card
    
    -- Copy AnimId Button
    local copyBtn = Instance.new("TextButton")
    copyBtn.Size = UDim2.new(0, scale("X", 40), 0, scale("Y", 24))
    copyBtn.Position = UDim2.new(0.5, -scale("X", 20), 0, scale("Y", 5))
    copyBtn.BackgroundColor3 = BlueOceanTheme.ButtonBG
    copyBtn.Text = "Copy ID"
    copyBtn.Font = Enum.Font.GothamBold
    copyBtn.TextScaled = true
    copyBtn.TextColor3 = BlueOceanTheme.Text
    copyBtn.TextStrokeTransparency = 1
    copyBtn.Parent = card
    createCorner(copyBtn, 6)
    
    copyBtn.MouseButton1Click:Connect(function()
        if setclipboard then
            setclipboard(item.AnimationId:gsub("rbxassetid://", ""))
        end
        copyBtn.Text = "✓"
        task.wait(0.7)
        copyBtn.Text = "Copy ID"
    end)
    
    -- Favorite Button
    local favBtn = Instance.new("TextButton")
    favBtn.Size = UDim2.new(0, scale("X", 24), 0, scale("Y", 24))
    favBtn.Position = UDim2.new(1, -scale("X", 30), 0, scale("Y", 5))
    favBtn.Text = item.Favorite and "★" or "☆"
    favBtn.Font = Enum.Font.GothamBold
    favBtn.TextScaled = true
    favBtn.TextColor3 = Color3.fromRGB(255, 255, 0)
    favBtn.BackgroundTransparency = 1
    favBtn.TextStrokeTransparency = 1
    favBtn.Parent = card
    
    favBtn.MouseButton1Click:Connect(function()
        item.Favorite = not item.Favorite
        favBtn.Text = item.Favorite and "★" or "☆"
        saveEmotesToData()
    end)
    
    -- Play Button
    local playBtn = Instance.new("TextButton")
    playBtn.Size = UDim2.new(0.45, -scale("X", 5), 0, scale("Y", 24))
    playBtn.Position = UDim2.new(0, scale("X", 5), 1, -scale("Y", 29))
    playBtn.BackgroundColor3 = BlueOceanTheme.Success
    playBtn.Text = "Play"
    playBtn.Font = Enum.Font.GothamBold
    playBtn.TextScaled = true
    playBtn.TextColor3 = BlueOceanTheme.Text
    playBtn.TextStrokeTransparency = 1
    playBtn.Parent = card
    createCorner(playBtn, 6)
    
    playBtn.MouseButton1Click:Connect(function()
        LoadTrack(item.Id)
    end)
    
    -- Remove Button
    local removeBtn = Instance.new("TextButton")
    removeBtn.Size = UDim2.new(0.45, -scale("X", 5), 0, scale("Y", 24))
    removeBtn.Position = UDim2.new(0.55, 0, 1, -scale("Y", 29))
    removeBtn.BackgroundColor3 = BlueOceanTheme.Error
    removeBtn.Text = "Remove"
    removeBtn.Font = Enum.Font.GothamBold
    removeBtn.TextScaled = true
    removeBtn.TextColor3 = BlueOceanTheme.Text
    removeBtn.TextStrokeTransparency = 1
    removeBtn.Parent = card
    createCorner(removeBtn, 6)
    
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

-- ============================================================
-- REFRESH SAVED TAB FUNCTION
-- ============================================================
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

-- ============================================================
-- TAB SWITCHING
-- ============================================================
catalogTabBtn.MouseButton1Click:Connect(function()
    catalogFrame.Visible = true
    savedFrame.Visible = false
    catalogTabBtn.BackgroundColor3 = BlueOceanTheme.Primary
    savedTabBtn.BackgroundColor3 = BlueOceanTheme.ButtonBG
end)

savedTabBtn.MouseButton1Click:Connect(function()
    catalogFrame.Visible = false
    savedFrame.Visible = true
    catalogTabBtn.BackgroundColor3 = BlueOceanTheme.ButtonBG
    savedTabBtn.BackgroundColor3 = BlueOceanTheme.Primary
    refreshSavedTab()
end)

-- ============================================================
-- CUSTOM TOGGLE BUTTON WITH YOUR IMAGE
-- ============================================================
local toggleGui = Instance.new("ScreenGui")
toggleGui.Name = "SynceToggleButton"
toggleGui.ResetOnSpawn = false
toggleGui.Parent = CoreGui
toggleGui.Enabled = true

local toggleBtn = Instance.new("ImageButton")
toggleBtn.Name = "ToggleButton"
toggleBtn.Size = UDim2.new(0, 60, 0, 60)
toggleBtn.Position = UDim2.new(0, 20, 0.5, -30)
toggleBtn.AnchorPoint = Vector2.new(0, 0.5)
toggleBtn.BackgroundColor3 = BlueOceanTheme.CardBG
toggleBtn.BackgroundTransparency = 0.1
toggleBtn.BorderSizePixel = 0
toggleBtn.Image = "rbxassetid://130348378128532" -- Your image
toggleBtn.ScaleType = Enum.ScaleType.Fit
toggleBtn.ImageTransparency = 0
toggleBtn.Active = true
toggleBtn.Draggable = true
toggleBtn.Parent = toggleGui

createCorner(toggleBtn, 12)
createStroke(toggleBtn, BlueOceanTheme.Primary, 2, 0.5)

-- Glow effect
local glow = Instance.new("ImageLabel")
glow.Name = "Glow"
glow.BackgroundTransparency = 1
glow.Image = "rbxassetid://5554236805"
glow.ImageColor3 = BlueOceanTheme.Primary
glow.ImageTransparency = 0.7
glow.ScaleType = Enum.ScaleType.Slice
glow.SliceCenter = Rect.new(23, 23, 277, 277)
glow.Size = UDim2.new(1, 20, 1, 20)
glow.Position = UDim2.new(0, -10, 0, -10)
glow.ZIndex = -1
glow.Parent = toggleBtn

-- Position clamping
local function clampTogglePosition()
    local parentSize = toggleGui.AbsoluteSize
    local btnSize = toggleBtn.AbsoluteSize
    local x = toggleBtn.Position.X.Offset
    local y = toggleBtn.Position.Y.Scale * parentSize.Y + toggleBtn.Position.Y.Offset
    local clampedX = math.clamp(x, 0, parentSize.X - btnSize.X)
    local clampedY = math.clamp(y, 0, parentSize.Y - btnSize.Y)
    toggleBtn.Position = UDim2.new(0, clampedX, 0, clampedY)
end

toggleBtn:GetPropertyChangedSignal("Position"):Connect(clampTogglePosition)

-- Hover animations
toggleBtn.MouseEnter:Connect(function()
    TweenService:Create(toggleBtn, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {
        Size = UDim2.new(0, 65, 0, 65),
        BackgroundColor3 = BlueOceanTheme.ButtonHover
    }):Play()
end)

toggleBtn.MouseLeave:Connect(function()
    TweenService:Create(toggleBtn, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {
        Size = UDim2.new(0, 60, 0, 60),
        BackgroundColor3 = BlueOceanTheme.CardBG
    }):Play()
end)

-- Toggle function with smooth animation
local isOpen = false

toggleBtn.MouseButton1Click:Connect(function()
    isOpen = not isOpen
    
    if isOpen then
        gui.Enabled = true
        local mainC = gui:FindFirstChild("Frame")
        if mainC then
            mainC.GroupTransparency = 1
            TweenService:Create(mainC, TweenInfo.new(0.3, Enum.EasingStyle.Quad), {
                GroupTransparency = 0
            }):Play()
        end
    else
        local mainC = gui:FindFirstChild("Frame")
        if mainC then
            local tween = TweenService:Create(mainC, TweenInfo.new(0.3, Enum.EasingStyle.Quad), {
                GroupTransparency = 1
            })
            tween:Play()
            tween.Completed:Connect(function()
                gui.Enabled = false
            end)
        else
            gui.Enabled = false
        end
    end
end)

-- Keyboard shortcut (G key)
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Enum.KeyCode.G then
        toggleBtn.MouseButton1Click:Fire()
    end
end)

-- ============================================================
-- FINALIZATION
-- ============================================================
gui.Enabled = true
refreshSavedTab()

print("╔═══════════════════════════════════════╗")
print("║     SYNCE EMOTES - BLUE OCEAN        ║")
print("║         Successfully Loaded!          ║")
print("╠═══════════════════════════════════════╣")
print("║  • Press 'G' to toggle GUI            ║")
print("║  • Drag button to reposition          ║")
print("║  • All emotes saved automatically     ║")
print("╚═══════════════════════════════════════╝")
print("[Synce Emotes] All 5 parts loaded successfully ✓")