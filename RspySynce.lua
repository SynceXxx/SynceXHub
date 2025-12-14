-- ============================================
-- RemoteSpy v5 - FIXED VERSION
-- Part 1: Services, Colors & Utilities
-- ============================================

-- Services
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")

-- Check clipboard function (FIX BUG #9)
if not setclipboard then
    setclipboard = function(text)
        print("Clipboard text:", text)
        warn("setclipboard() tidak support di executor kamu")
    end
end

-- Detect Platform
local isMobile = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled

-- Color Palette (Professional)
local COLORS = {
    PRIMARY = Color3.fromRGB(255, 140, 0),
    PRIMARY_DARK = Color3.fromRGB(200, 100, 0),
    PRIMARY_LIGHT = Color3.fromRGB(255, 170, 50),
    
    BG_DARK = Color3.fromRGB(15, 15, 20),
    BG_MEDIUM = Color3.fromRGB(25, 25, 35),
    BG_LIGHT = Color3.fromRGB(35, 35, 45),
    BG_LIGHTER = Color3.fromRGB(45, 45, 55),
    
    TEXT_PRIMARY = Color3.fromRGB(255, 255, 255),
    TEXT_SECONDARY = Color3.fromRGB(180, 180, 190),
    TEXT_MUTED = Color3.fromRGB(120, 120, 130),
    
    SUCCESS = Color3.fromRGB(46, 204, 113),
    WARNING = Color3.fromRGB(241, 196, 15),
    ERROR = Color3.fromRGB(231, 76, 60),
    INFO = Color3.fromRGB(52, 152, 219),
    
    SHADOW = Color3.fromRGB(0, 0, 0),
}

-- Roblox Asset IDs untuk Icons (Ganti Emoji)
local ICONS = {
    Signal = "rbxassetid://3926305904", -- Radio/Signal icon
    Event = "rbxassetid://3926307971", -- Bell icon
    Function = "rbxassetid://3926305904", -- Lightning/Zap
    Refresh = "rbxassetid://3926305904", -- Refresh
    Copy = "rbxassetid://3926307971", -- Clipboard
    Settings = "rbxassetid://3926305904", -- Settings gear
    Search = "rbxassetid://3926305904", -- Search
    Info = "rbxassetid://3926305904", -- Info
    Fire = "rbxassetid://3926307971", -- Rocket/Fire
    Close = "rbxassetid://3926305904", -- X close
    Minimize = "rbxassetid://3926307971", -- Minus
}

-- Sound Effects
local SOUNDS = {
    Click = "rbxassetid://6895079853",
    Hover = "rbxassetid://6895079853",
    Toggle = "rbxassetid://6895079853",
    Success = "rbxassetid://6895079853",
    Error = "rbxassetid://6895079853",
    Open = "rbxassetid://6895079853",
    Close = "rbxassetid://6895079853",
}

-- Sound Player (Protected with pcall - FIX BUG #6)
local function playSound(soundId, volume)
    pcall(function()
        local sound = Instance.new("Sound")
        sound.SoundId = soundId
        sound.Volume = volume or 0.3
        sound.Parent = game:GetService("SoundService")
        sound:Play()
        game:GetService("Debris"):AddItem(sound, 2)
    end)
end

-- Animation Presets
local ANIM = {
    FAST = TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
    NORMAL = TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
    SMOOTH = TweenInfo.new(0.35, Enum.EasingStyle.Quart, Enum.EasingDirection.Out),
    BOUNCE = TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
    SPRING = TweenInfo.new(0.5, Enum.EasingStyle.Elastic, Enum.EasingDirection.Out),
}

-- Utility: Create rounded frame
local function createRounded(parent, radius)
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, radius or 8)
    corner.Parent = parent
    return corner
end

-- Utility: Create shadow
local function createShadow(parent, size, transparency)
    local shadow = Instance.new("ImageLabel")
    shadow.Name = "Shadow"
    shadow.Size = UDim2.new(1, size, 1, size)
    shadow.Position = UDim2.new(0, -size/2, 0, -size/2)
    shadow.BackgroundTransparency = 1
    shadow.Image = "rbxassetid://5554236805"
    shadow.ImageColor3 = COLORS.SHADOW
    shadow.ImageTransparency = transparency or 0.7
    shadow.ScaleType = Enum.ScaleType.Slice
    shadow.SliceCenter = Rect.new(23, 23, 277, 277)
    shadow.ZIndex = 0
    shadow.Parent = parent
    return shadow
end

-- Utility: Create gradient (FIX: ColorSequence format)
local function createGradient(parent, color1, color2, rotation)
    local gradient = Instance.new("UIGradient")
    gradient.Color = ColorSequence.new(color1, color2)
    gradient.Rotation = rotation or 90
    gradient.Parent = parent
    return gradient
end

-- Utility: Animate property
local function animate(object, properties, tweenInfo)
    if not object or not object.Parent then return end
    local tween = TweenService:Create(object, tweenInfo or ANIM.NORMAL, properties)
    tween:Play()
    return tween
end

-- Utility: Create Icon (Ganti Emoji dengan ImageLabel)
local function createIcon(parent, iconId, size, position)
    local icon = Instance.new("ImageLabel")
    icon.Size = size or UDim2.new(0, 20, 0, 20)
    icon.Position = position or UDim2.new(0, 0, 0, 0)
    icon.BackgroundTransparency = 1
    icon.Image = iconId
    icon.ImageColor3 = COLORS.TEXT_PRIMARY
    icon.Parent = parent
    return icon
end

-- Utility: Button hover effect (FIX BUG #2, #3, #4 - ganti : jadi or)
local function addHoverEffect(button, hoverColor, normalColor)
    button.MouseEnter:Connect(function()
        playSound(SOUNDS.Hover, 0.2)
        animate(button, {BackgroundColor3 = hoverColor}, ANIM.FAST)
    end)
    
    button.MouseLeave:Connect(function()
        animate(button, {BackgroundColor3 = normalColor}, ANIM.FAST)
    end)
    
    button.MouseButton1Down:Connect(function()
        local currentSize = button.Size
        animate(button, {
            Size = UDim2.new(
                currentSize.X.Scale * 0.95, 
                currentSize.X.Offset * 0.95, 
                currentSize.Y.Scale * 0.95, 
                currentSize.Y.Offset * 0.95
            )
        }, ANIM.FAST)
    end)
    
    button.MouseButton1Up:Connect(function()
        local currentSize = button.Size
        animate(button, {
            Size = UDim2.new(
                currentSize.X.Scale / 0.95, 
                currentSize.X.Offset / 0.95, 
                currentSize.Y.Scale / 0.95, 
                currentSize.Y.Offset / 0.95
            )
        }, ANIM.FAST)
    end)
end

print("Loaded: Services & Utilities")

-- ============================================
-- RemoteSpy v5 - FIXED VERSION
-- Part 2: Main GUI Structure
-- ============================================

-- Responsive sizing based on platform (FIX BUG #2, #3, #4 - ganti : jadi or)
local mainWidth = isMobile and 360 or 800
local mainHeight = isMobile and 500 or 600
local titleBarHeight = isMobile and 50 or 60

-- Main GUI Setup (FIX BUG #1 - ganti CoreGui jadi PlayerGui)
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "RemoteSpyV5Pro"
screenGui.ResetOnSpawn = false
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

-- Use PlayerGui instead of CoreGui (FIX BUG #1)
local success = pcall(function()
    screenGui.Parent = Players.LocalPlayer:WaitForChild("PlayerGui")
end)

if not success then
    warn("⚠️ Gagal load GUI, coba restart executor")
    return
end

-- Main Container (for show/hide)
local mainContainer = Instance.new("Frame")
mainContainer.Name = "MainContainer"
mainContainer.Size = UDim2.new(0, mainWidth, 0, mainHeight)
mainContainer.Position = UDim2.new(0.5, -mainWidth/2, 0.5, -mainHeight/2)
mainContainer.BackgroundTransparency = 1
mainContainer.Parent = screenGui

-- Main Window
local mainWindow = Instance.new("Frame")
mainWindow.Name = "MainWindow"
mainWindow.Size = UDim2.new(1, 0, 1, 0)
mainWindow.BackgroundColor3 = COLORS.BG_DARK
mainWindow.BorderSizePixel = 0
mainWindow.ClipsDescendants = true
mainWindow.Parent = mainContainer

createRounded(mainWindow, isMobile and 12 or 16)
createShadow(mainWindow, 40, 0.6)

-- Glowing border effect
local borderGlow = Instance.new("UIStroke")
borderGlow.Color = COLORS.PRIMARY
borderGlow.Thickness = 2
borderGlow.Transparency = 0.5
borderGlow.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
borderGlow.Parent = mainWindow

-- Animated glow effect (FIX BUG #7 - tambah kondisi berhenti)
spawn(function()
    while screenGui and screenGui.Parent and mainWindow and mainWindow.Parent do
        animate(borderGlow, {Transparency = 0.2}, ANIM.SMOOTH)
        wait(2)
        if not screenGui or not screenGui.Parent then break end
        animate(borderGlow, {Transparency = 0.5}, ANIM.SMOOTH)
        wait(2)
    end
end)

-- Title Bar
local titleBar = Instance.new("Frame")
titleBar.Name = "TitleBar"
titleBar.Size = UDim2.new(1, 0, 0, titleBarHeight)
titleBar.BackgroundColor3 = COLORS.BG_MEDIUM
titleBar.BorderSizePixel = 0
titleBar.Parent = mainWindow

createGradient(titleBar, COLORS.PRIMARY, COLORS.PRIMARY_DARK, 0)

local titleBarCorner = Instance.new("UICorner")
titleBarCorner.CornerRadius = UDim.new(0, isMobile and 12 or 16)
titleBarCorner.Parent = titleBar

-- Title Bar Bottom Extension (to remove bottom rounded corners)
local titleBarExtension = Instance.new("Frame")
titleBarExtension.Size = UDim2.new(1, 0, 0, 16)
titleBarExtension.Position = UDim2.new(0, 0, 1, -16)
titleBarExtension.BackgroundColor3 = COLORS.PRIMARY_DARK
titleBarExtension.BorderSizePixel = 0
titleBarExtension.Parent = titleBar

-- Logo Icon (Ganti emoji dengan ImageLabel)
local logoFrame = Instance.new("Frame")
logoFrame.Size = UDim2.new(0, titleBarHeight - 10, 0, titleBarHeight - 10)
logoFrame.Position = UDim2.new(0, 10, 0, 5)
logoFrame.BackgroundColor3 = COLORS.BG_DARK
logoFrame.BackgroundTransparency = 0.3
logoFrame.Parent = titleBar

createRounded(logoFrame, isMobile and 8 or 10)

local logoIcon = createIcon(logoFrame, ICONS.Signal, 
    UDim2.new(0, isMobile and 24 or 28, 0, isMobile and 24 or 28),
    UDim2.new(0.5, -12, 0.5, -12))

-- Title Label
local titleLabel = Instance.new("TextLabel")
titleLabel.Size = UDim2.new(1, -200, 1, 0)
titleLabel.Position = UDim2.new(0, titleBarHeight + 5, 0, 0)
titleLabel.BackgroundTransparency = 1
titleLabel.Text = "RemoteSpy"
titleLabel.TextColor3 = COLORS.TEXT_PRIMARY
titleLabel.Font = Enum.Font.GothamBlack
titleLabel.TextSize = isMobile and 20 or 28
titleLabel.TextXAlignment = Enum.TextXAlignment.Left
titleLabel.Parent = titleBar

-- Version Badge
local versionBadge = Instance.new("TextLabel")
versionBadge.Size = UDim2.new(0, isMobile and 35 or 40, 0, isMobile and 18 or 20)
versionBadge.Position = UDim2.new(0, titleLabel.Position.X.Offset + 120, 0, (titleBarHeight - 20) / 2)
versionBadge.BackgroundColor3 = COLORS.SUCCESS
versionBadge.Text = "v5"
versionBadge.TextColor3 = COLORS.TEXT_PRIMARY
versionBadge.Font = Enum.Font.GothamBold
versionBadge.TextSize = isMobile and 10 or 12
versionBadge.Parent = titleBar

createRounded(versionBadge, 10)

-- Control Buttons Container (FIX BUG #2 - ganti : jadi or)
local controlButtonsFrame = Instance.new("Frame")
controlButtonsFrame.Size = UDim2.new(0, isMobile and 90 or 110, 1, -10)
controlButtonsFrame.Position = UDim2.new(1, isMobile and -95 or -115, 0, 5)
controlButtonsFrame.BackgroundTransparency = 1
controlButtonsFrame.Parent = titleBar

-- Minimize Button (FIX BUG #3 - ganti : jadi or)
local minimizeBtn = Instance.new("TextButton")
minimizeBtn.Name = "MinimizeBtn"
minimizeBtn.Size = UDim2.new(0, isMobile and 35 or 40, 0, isMobile and 35 or 40)
minimizeBtn.Position = UDim2.new(0, 0, 0, 0)
minimizeBtn.BackgroundColor3 = COLORS.WARNING
minimizeBtn.Text = "-"
minimizeBtn.TextColor3 = COLORS.TEXT_PRIMARY
minimizeBtn.Font = Enum.Font.GothamBlack
minimizeBtn.TextSize = isMobile and 18 or 22
minimizeBtn.BorderSizePixel = 0
minimizeBtn.Parent = controlButtonsFrame

createRounded(minimizeBtn, 8)
addHoverEffect(minimizeBtn, COLORS.WARNING * 1.2, COLORS.WARNING)

-- Close Button (FIX BUG #4 - ganti : jadi or)
local closeBtn = Instance.new("TextButton")
closeBtn.Name = "CloseBtn"
closeBtn.Size = UDim2.new(0, isMobile and 35 or 40, 0, isMobile and 35 or 40)
closeBtn.Position = UDim2.new(0, isMobile and 45 or 50, 0, 0)
closeBtn.BackgroundColor3 = COLORS.ERROR
closeBtn.Text = "X"
closeBtn.TextColor3 = COLORS.TEXT_PRIMARY
closeBtn.Font = Enum.Font.GothamBlack
closeBtn.TextSize = isMobile and 16 or 20
closeBtn.BorderSizePixel = 0
closeBtn.Parent = controlButtonsFrame

createRounded(closeBtn, 8)
addHoverEffect(closeBtn, COLORS.ERROR * 1.2, COLORS.ERROR)

print("Loaded: Main GUI Structure")

-- ============================================
-- RemoteSpy v5 - FIXED VERSION
-- Part 3: Content Area & Action Bar
-- ============================================

-- Content Container
local contentContainer = Instance.new("Frame")
contentContainer.Name = "ContentContainer"
contentContainer.Size = UDim2.new(1, 0, 1, -titleBarHeight)
contentContainer.Position = UDim2.new(0, 0, 0, titleBarHeight)
contentContainer.BackgroundTransparency = 1
contentContainer.Parent = mainWindow

-- Top Action Bar
local actionBar = Instance.new("Frame")
actionBar.Name = "ActionBar"
actionBar.Size = UDim2.new(1, -20, 0, isMobile and 40 or 50)
actionBar.Position = UDim2.new(0, 10, 0, 10)
actionBar.BackgroundColor3 = COLORS.BG_MEDIUM
actionBar.BorderSizePixel = 0
actionBar.Parent = contentContainer

createRounded(actionBar, 10)
createShadow(actionBar, 10, 0.8)

-- Action Buttons Layout
local actionButtonLayout = Instance.new("UIListLayout")
actionButtonLayout.FillDirection = Enum.FillDirection.Horizontal
actionButtonLayout.HorizontalAlignment = Enum.HorizontalAlignment.Left
actionButtonLayout.VerticalAlignment = Enum.VerticalAlignment.Center
actionButtonLayout.Padding = UDim.new(0, 8)
actionButtonLayout.Parent = actionBar

local actionButtonPadding = Instance.new("UIPadding")
actionButtonPadding.PaddingLeft = UDim.new(0, 10)
actionButtonPadding.PaddingRight = UDim.new(0, 10)
actionButtonPadding.Parent = actionBar

-- Action Button Creator (Ganti emoji dengan icon)
local function createActionButton(iconId, text, color)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, isMobile and 70 or 90, 0, isMobile and 30 or 36)
    btn.BackgroundColor3 = color
    btn.BorderSizePixel = 0
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = isMobile and 11 or 13
    btn.TextColor3 = COLORS.TEXT_PRIMARY
    btn.Text = " " .. text
    btn.AutoButtonColor = false
    btn.Parent = actionBar
    
    createRounded(btn, 8)
    addHoverEffect(btn, color * 1.3, color)
    
    -- Add icon
    local icon = createIcon(btn, iconId, 
        UDim2.new(0, 16, 0, 16),
        UDim2.new(0, 8, 0.5, -8))
    
    -- Adjust text position
    btn.TextXAlignment = Enum.TextXAlignment.Left
    local padding = Instance.new("UIPadding")
    padding.PaddingLeft = UDim.new(0, 28)
    padding.Parent = btn
    
    return btn
end

local refreshBtn = createActionButton(ICONS.Refresh, "Refresh", COLORS.PRIMARY)
local exportBtn = createActionButton(ICONS.Copy, "Export", COLORS.INFO)
local settingsBtn = createActionButton(ICONS.Settings, "Settings", COLORS.BG_LIGHTER)

-- Stats Bar
local statsBar = Instance.new("Frame")
statsBar.Name = "StatsBar"
statsBar.Size = UDim2.new(1, -20, 0, isMobile and 35 or 40)
statsBar.Position = UDim2.new(0, 10, 0, actionBar.Size.Y.Offset + 20)
statsBar.BackgroundColor3 = COLORS.BG_MEDIUM
statsBar.BorderSizePixel = 0
statsBar.Parent = contentContainer

createRounded(statsBar, 8)

local statsLayout = Instance.new("UIListLayout")
statsLayout.FillDirection = Enum.FillDirection.Horizontal
statsLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
statsLayout.VerticalAlignment = Enum.VerticalAlignment.Center
statsLayout.Padding = UDim.new(0, 20)
statsLayout.Parent = statsBar

-- Stat Item Creator (Ganti emoji dengan icon)
local function createStatItem(iconId, labelText, valueText, color)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, isMobile and 80 or 100, 1, 0)
    frame.BackgroundTransparency = 1
    frame.Parent = statsBar
    
    local iconLabel = createIcon(frame, iconId,
        UDim2.new(0, 20, 0, 20),
        UDim2.new(0, 0, 0.5, -10))
    
    local textLabel = Instance.new("TextLabel")
    textLabel.Size = UDim2.new(1, -25, 0, isMobile and 12 or 14)
    textLabel.Position = UDim2.new(0, 25, 0, 2)
    textLabel.BackgroundTransparency = 1
    textLabel.Text = labelText
    textLabel.TextColor3 = COLORS.TEXT_MUTED
    textLabel.Font = Enum.Font.Gotham
    textLabel.TextSize = isMobile and 10 or 11
    textLabel.TextXAlignment = Enum.TextXAlignment.Left
    textLabel.Parent = frame
    
    local valueLabel = Instance.new("TextLabel")
    valueLabel.Size = UDim2.new(1, -25, 0, isMobile and 16 or 18)
    valueLabel.Position = UDim2.new(0, 25, 1, isMobile and -18 or -20)
    valueLabel.BackgroundTransparency = 1
    valueLabel.Text = valueText
    valueLabel.TextColor3 = color
    valueLabel.Font = Enum.Font.GothamBold
    valueLabel.TextSize = isMobile and 13 or 15
    valueLabel.TextXAlignment = Enum.TextXAlignment.Left
    valueLabel.Parent = frame
    
    return valueLabel
end

local totalRemotesValue = createStatItem(ICONS.Signal, "Total", "0", COLORS.PRIMARY)
local remoteEventsValue = createStatItem(ICONS.Event, "Events", "0", COLORS.SUCCESS)
local remoteFunctionsValue = createStatItem(ICONS.Function, "Functions", "0", COLORS.INFO)

-- Remote List Container
local remoteListContainer = Instance.new("Frame")
remoteListContainer.Name = "RemoteListContainer"
remoteListContainer.Size = UDim2.new(1, -20, 1, -(actionBar.Size.Y.Offset + statsBar.Size.Y.Offset + 40))
remoteListContainer.Position = UDim2.new(0, 10, 0, actionBar.Size.Y.Offset + statsBar.Size.Y.Offset + 30)
remoteListContainer.BackgroundColor3 = COLORS.BG_MEDIUM
remoteListContainer.BorderSizePixel = 0
remoteListContainer.ClipsDescendants = true
remoteListContainer.Parent = contentContainer

createRounded(remoteListContainer, 10)
createShadow(remoteListContainer, 10, 0.8)

-- Search Bar
local searchBar = Instance.new("Frame")
searchBar.Name = "SearchBar"
searchBar.Size = UDim2.new(1, -20, 0, isMobile and 35 or 40)
searchBar.Position = UDim2.new(0, 10, 0, 10)
searchBar.BackgroundColor3 = COLORS.BG_LIGHT
searchBar.BorderSizePixel = 0
searchBar.Parent = remoteListContainer

createRounded(searchBar, 8)

-- Search Icon (Ganti emoji dengan icon)
local searchIconFrame = createIcon(searchBar, ICONS.Search,
    UDim2.new(0, 18, 0, 18),
    UDim2.new(0, 10, 0.5, -9))

local searchInput = Instance.new("TextBox")
searchInput.Size = UDim2.new(1, -70, 1, 0)
searchInput.Position = UDim2.new(0, 35, 0, 0)
searchInput.BackgroundTransparency = 1
searchInput.PlaceholderText = "Search remotes..."
searchInput.PlaceholderColor3 = COLORS.TEXT_MUTED
searchInput.Text = ""
searchInput.TextColor3 = COLORS.TEXT_PRIMARY
searchInput.Font = Enum.Font.Gotham
searchInput.TextSize = isMobile and 12 or 14
searchInput.TextXAlignment = Enum.TextXAlignment.Left
searchInput.ClearTextOnFocus = false
searchInput.Parent = searchBar

local clearSearchBtn = Instance.new("TextButton")
clearSearchBtn.Size = UDim2.new(0, 30, 1, 0)
clearSearchBtn.Position = UDim2.new(1, -35, 0, 0)
clearSearchBtn.BackgroundTransparency = 1
clearSearchBtn.Text = "X"
clearSearchBtn.TextColor3 = COLORS.TEXT_MUTED
clearSearchBtn.Font = Enum.Font.GothamBold
clearSearchBtn.TextSize = isMobile and 14 or 16
clearSearchBtn.Visible = false
clearSearchBtn.Parent = searchBar

-- Scrolling Frame for Remotes
local remoteScrollFrame = Instance.new("ScrollingFrame")
remoteScrollFrame.Name = "RemoteScrollFrame"
remoteScrollFrame.Size = UDim2.new(1, -20, 1, -(searchBar.Size.Y.Offset + 20))
remoteScrollFrame.Position = UDim2.new(0, 10, 0, searchBar.Size.Y.Offset + 10)
remoteScrollFrame.BackgroundTransparency = 1
remoteScrollFrame.BorderSizePixel = 0
remoteScrollFrame.ScrollBarThickness = 6
remoteScrollFrame.ScrollBarImageColor3 = COLORS.PRIMARY
remoteScrollFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
remoteScrollFrame.Parent = remoteListContainer

local remoteListLayout = Instance.new("UIListLayout")
remoteListLayout.FillDirection = Enum.FillDirection.Vertical
remoteListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
remoteListLayout.VerticalAlignment = Enum.VerticalAlignment.Top
remoteListLayout.Padding = UDim.new(0, 8)
remoteListLayout.Parent = remoteScrollFrame

-- Auto-update canvas size
remoteListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    remoteScrollFrame.CanvasSize = UDim2.new(0, 0, 0, remoteListLayout.AbsoluteContentSize.Y + 10)
end)

print("Loaded: Content Area & Action Bar")

-- ============================================
-- RemoteSpy v5 - FIXED VERSION
-- Part 4: Remote Entry Card Creator
-- ============================================

-- Create Remote Entry Card (Modern Design)
local function createRemoteEntry(remote, path, index)
    local entryCard = Instance.new("Frame")
    entryCard.Name = "RemoteEntry_" .. index
    entryCard.Size = UDim2.new(1, -10, 0, isMobile and 85 or 95)
    entryCard.BackgroundColor3 = COLORS.BG_LIGHT
    entryCard.BorderSizePixel = 0
    entryCard.ClipsDescendants = true
    
    createRounded(entryCard, 10)
    
    -- Hover effect
    local originalColor = COLORS.BG_LIGHT
    entryCard.MouseEnter:Connect(function()
        animate(entryCard, {BackgroundColor3 = COLORS.BG_LIGHTER}, ANIM.FAST)
    end)
    entryCard.MouseLeave:Connect(function()
        animate(entryCard, {BackgroundColor3 = originalColor}, ANIM.FAST)
    end)
    
    -- Left accent bar
    local accentBar = Instance.new("Frame")
    accentBar.Size = UDim2.new(0, 4, 1, 0)
    accentBar.BackgroundColor3 = remote:IsA("RemoteEvent") and COLORS.SUCCESS or COLORS.INFO
    accentBar.BorderSizePixel = 0
    accentBar.Parent = entryCard
    
    local accentCorner = Instance.new("UICorner")
    accentCorner.CornerRadius = UDim.new(0, 10)
    accentCorner.Parent = accentBar
    
    -- Type Icon Frame
    local typeIconFrame = Instance.new("Frame")
    typeIconFrame.Size = UDim2.new(0, isMobile and 35 or 40, 0, isMobile and 35 or 40)
    typeIconFrame.Position = UDim2.new(0, 12, 0, 8)
    typeIconFrame.BackgroundColor3 = remote:IsA("RemoteEvent") and COLORS.SUCCESS or COLORS.INFO
    typeIconFrame.BackgroundTransparency = 0.8
    typeIconFrame.Parent = entryCard
    
    createRounded(typeIconFrame, 8)
    
    -- Type Icon (Ganti emoji dengan icon)
    local typeIcon = createIcon(typeIconFrame, 
        remote:IsA("RemoteEvent") and ICONS.Event or ICONS.Function,
        UDim2.new(0, isMobile and 20 or 24, 0, isMobile and 20 or 24),
        UDim2.new(0.5, isMobile and -10 or -12, 0.5, isMobile and -10 or -12))
    typeIcon.ImageColor3 = remote:IsA("RemoteEvent") and COLORS.SUCCESS or COLORS.INFO
    
    -- Remote Name
    local nameLabel = Instance.new("TextLabel")
    nameLabel.Name = "RemoteName"
    nameLabel.Size = UDim2.new(1, isMobile and -140 or -170, 0, isMobile and 18 or 20)
    nameLabel.Position = UDim2.new(0, isMobile and 55 or 60, 0, 8)
    nameLabel.BackgroundTransparency = 1
    nameLabel.Text = remote.Name
    nameLabel.TextColor3 = COLORS.TEXT_PRIMARY
    nameLabel.Font = Enum.Font.GothamBold
    nameLabel.TextSize = isMobile and 13 or 15
    nameLabel.TextXAlignment = Enum.TextXAlignment.Left
    nameLabel.TextTruncate = Enum.TextTruncate.AtEnd
    nameLabel.Parent = entryCard
    
    -- Type Badge
    local typeBadge = Instance.new("TextLabel")
    typeBadge.Size = UDim2.new(0, isMobile and 50 or 60, 0, isMobile and 16 or 18)
    typeBadge.Position = UDim2.new(0, isMobile and 55 or 60, 0, isMobile and 28 or 30)
    typeBadge.BackgroundColor3 = remote:IsA("RemoteEvent") and COLORS.SUCCESS or COLORS.INFO
    typeBadge.BackgroundTransparency = 0.7
    typeBadge.Text = remote:IsA("RemoteEvent") and "Event" or "Function"
    typeBadge.TextColor3 = COLORS.TEXT_PRIMARY
    typeBadge.Font = Enum.Font.GothamBold
    typeBadge.TextSize = isMobile and 9 or 10
    typeBadge.Parent = entryCard
    
    createRounded(typeBadge, 4)
    
    -- Path Label
    local pathLabel = Instance.new("TextLabel")
    pathLabel.Size = UDim2.new(1, isMobile and -140 or -170, 0, isMobile and 16 or 18)
    pathLabel.Position = UDim2.new(0, isMobile and 55 or 60, 0, isMobile and 48 or 52)
    pathLabel.BackgroundTransparency = 1
    pathLabel.Text = path
    pathLabel.TextColor3 = COLORS.TEXT_MUTED
    pathLabel.Font = Enum.Font.Gotham
    pathLabel.TextSize = isMobile and 10 or 11
    pathLabel.TextXAlignment = Enum.TextXAlignment.Left
    pathLabel.TextTruncate = Enum.TextTruncate.AtEnd
    pathLabel.Parent = entryCard
    
    -- Status Indicator (bottom)
    local statusLabel = Instance.new("TextLabel")
    statusLabel.Name = "StatusLabel"
    statusLabel.Size = UDim2.new(1, isMobile and -140 or -170, 0, isMobile and 14 or 16)
    statusLabel.Position = UDim2.new(0, isMobile and 55 or 60, 1, isMobile and -18 or -20)
    statusLabel.BackgroundTransparency = 1
    statusLabel.Text = "● Ready"
    statusLabel.TextColor3 = COLORS.SUCCESS
    statusLabel.Font = Enum.Font.Gotham
    statusLabel.TextSize = isMobile and 9 or 10
    statusLabel.TextXAlignment = Enum.TextXAlignment.Left
    statusLabel.Parent = entryCard
    
    -- Action Buttons Container
    local actionsFrame = Instance.new("Frame")
    actionsFrame.Size = UDim2.new(0, isMobile and 85 or 110, 1, -16)
    actionsFrame.Position = UDim2.new(1, isMobile and -90 or -115, 0, 8)
    actionsFrame.BackgroundTransparency = 1
    actionsFrame.Parent = entryCard
    
    local actionsLayout = Instance.new("UIListLayout")
    actionsLayout.FillDirection = Enum.FillDirection.Vertical
    actionsLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    actionsLayout.VerticalAlignment = Enum.VerticalAlignment.Center
    actionsLayout.Padding = UDim.new(0, 6)
    actionsLayout.Parent = actionsFrame
    
    -- Create Action Button
    local function createActionBtn(text, iconId, color)
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(1, 0, 0, isMobile and 22 or 25)
        btn.BackgroundColor3 = color
        btn.Text = " " .. text
        btn.TextColor3 = COLORS.TEXT_PRIMARY
        btn.Font = Enum.Font.GothamBold
        btn.TextSize = isMobile and 10 or 11
        btn.BorderSizePixel = 0
        btn.AutoButtonColor = false
        btn.Parent = actionsFrame
        
        createRounded(btn, 6)
        addHoverEffect(btn, color * 1.3, color)
        
        -- Add icon
        local icon = createIcon(btn, iconId,
            UDim2.new(0, 12, 0, 12),
            UDim2.new(0, 6, 0.5, -6))
        
        -- Adjust text
        btn.TextXAlignment = Enum.TextXAlignment.Left
        local padding = Instance.new("UIPadding")
        padding.PaddingLeft = UDim.new(0, 22)
        padding.Parent = btn
        
        return btn
    end
    
    local fireBtn = createActionBtn("Fire", ICONS.Fire, COLORS.PRIMARY)
    local copyBtn = createActionBtn("Copy", ICONS.Copy, COLORS.INFO)
    local infoBtn = createActionBtn("Info", ICONS.Info, COLORS.BG_LIGHTER)
    
    -- Button Actions (FIX BUG #6 - Protected dengan pcall)
    fireBtn.MouseButton1Click:Connect(function()
        playSound(SOUNDS.Click, 0.4)
        statusLabel.Text = "● Firing..."
        statusLabel.TextColor3 = COLORS.WARNING
        
        local success = false
        if remote:IsA("RemoteEvent") then
            success = pcall(function()
                remote:FireServer()
            end)
        elseif remote:IsA("RemoteFunction") then
            success = pcall(function()
                remote:InvokeServer()
            end)
        end
        
        wait(0.5)
        if success then
            statusLabel.Text = "● Fired Successfully"
            statusLabel.TextColor3 = COLORS.SUCCESS
            playSound(SOUNDS.Success, 0.3)
            animate(fireBtn, {BackgroundColor3 = COLORS.SUCCESS}, ANIM.FAST)
            wait(0.3)
            animate(fireBtn, {BackgroundColor3 = COLORS.PRIMARY}, ANIM.FAST)
        else
            statusLabel.Text = "● Failed to Fire"
            statusLabel.TextColor3 = COLORS.ERROR
            playSound(SOUNDS.Error, 0.3)
        end
        
        wait(2)
        statusLabel.Text = "● Ready"
        statusLabel.TextColor3 = COLORS.SUCCESS
    end)
    
    copyBtn.MouseButton1Click:Connect(function()
        playSound(SOUNDS.Click, 0.4)
        pcall(function()
            setclipboard(path)
        end)
        statusLabel.Text = "● Path Copied!"
        statusLabel.TextColor3 = COLORS.SUCCESS
        animate(copyBtn, {BackgroundColor3 = COLORS.SUCCESS}, ANIM.FAST)
        wait(0.3)
        animate(copyBtn, {BackgroundColor3 = COLORS.INFO}, ANIM.FAST)
        wait(1.5)
        statusLabel.Text = "● Ready"
    end)
    
    infoBtn.MouseButton1Click:Connect(function()
        playSound(SOUNDS.Click, 0.3)
        animate(infoBtn, {BackgroundColor3 = COLORS.PRIMARY}, ANIM.FAST)
        wait(0.2)
        animate(infoBtn, {BackgroundColor3 = COLORS.BG_LIGHTER}, ANIM.FAST)
    end)
    
    -- Entry animation
    entryCard.BackgroundTransparency = 1
    entryCard.Size = UDim2.new(1, -10, 0, 0)
    
    animate(entryCard, {
        BackgroundTransparency = 0,
        Size = UDim2.new(1, -10, 0, isMobile and 85 or 95)
    }, TweenInfo.new(0.3 + index * 0.02, Enum.EasingStyle.Back, Enum.EasingDirection.Out))
    
    return entryCard
end

print("Loaded: Remote Entry Cards")

-- ============================================
-- RemoteSpy v5 - FIXED VERSION
-- Part 2: Main GUI Structure
-- ============================================

-- Responsive sizing based on platform (FIX BUG #2, #3, #4 - ganti : jadi or)
local mainWidth = isMobile and 360 or 800
local mainHeight = isMobile and 500 or 600
local titleBarHeight = isMobile and 50 or 60

-- Main GUI Setup (FIX BUG #1 - ganti CoreGui jadi PlayerGui)
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "RemoteSpyV5Pro"
screenGui.ResetOnSpawn = false
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

-- Use PlayerGui instead of CoreGui (FIX BUG #1)
local success = pcall(function()
    screenGui.Parent = Players.LocalPlayer:WaitForChild("PlayerGui")
end)

if not success then
    warn("⚠️ Gagal load GUI, coba restart executor")
    return
end

-- Main Container (for show/hide)
local mainContainer = Instance.new("Frame")
mainContainer.Name = "MainContainer"
mainContainer.Size = UDim2.new(0, mainWidth, 0, mainHeight)
mainContainer.Position = UDim2.new(0.5, -mainWidth/2, 0.5, -mainHeight/2)
mainContainer.BackgroundTransparency = 1
mainContainer.Parent = screenGui

-- Main Window
local mainWindow = Instance.new("Frame")
mainWindow.Name = "MainWindow"
mainWindow.Size = UDim2.new(1, 0, 1, 0)
mainWindow.BackgroundColor3 = COLORS.BG_DARK
mainWindow.BorderSizePixel = 0
mainWindow.ClipsDescendants = true
mainWindow.Parent = mainContainer

createRounded(mainWindow, isMobile and 12 or 16)
createShadow(mainWindow, 40, 0.6)

-- Glowing border effect
local borderGlow = Instance.new("UIStroke")
borderGlow.Color = COLORS.PRIMARY
borderGlow.Thickness = 2
borderGlow.Transparency = 0.5
borderGlow.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
borderGlow.Parent = mainWindow

-- Animated glow effect (FIX BUG #7 - tambah kondisi berhenti)
spawn(function()
    while screenGui and screenGui.Parent and mainWindow and mainWindow.Parent do
        animate(borderGlow, {Transparency = 0.2}, ANIM.SMOOTH)
        wait(2)
        if not screenGui or not screenGui.Parent then break end
        animate(borderGlow, {Transparency = 0.5}, ANIM.SMOOTH)
        wait(2)
    end
end)

-- Title Bar
local titleBar = Instance.new("Frame")
titleBar.Name = "TitleBar"
titleBar.Size = UDim2.new(1, 0, 0, titleBarHeight)
titleBar.BackgroundColor3 = COLORS.BG_MEDIUM
titleBar.BorderSizePixel = 0
titleBar.Parent = mainWindow

createGradient(titleBar, COLORS.PRIMARY, COLORS.PRIMARY_DARK, 0)

local titleBarCorner = Instance.new("UICorner")
titleBarCorner.CornerRadius = UDim.new(0, isMobile and 12 or 16)
titleBarCorner.Parent = titleBar

-- Title Bar Bottom Extension (to remove bottom rounded corners)
local titleBarExtension = Instance.new("Frame")
titleBarExtension.Size = UDim2.new(1, 0, 0, 16)
titleBarExtension.Position = UDim2.new(0, 0, 1, -16)
titleBarExtension.BackgroundColor3 = COLORS.PRIMARY_DARK
titleBarExtension.BorderSizePixel = 0
titleBarExtension.Parent = titleBar

-- Logo Icon (Ganti emoji dengan ImageLabel)
local logoFrame = Instance.new("Frame")
logoFrame.Size = UDim2.new(0, titleBarHeight - 10, 0, titleBarHeight - 10)
logoFrame.Position = UDim2.new(0, 10, 0, 5)
logoFrame.BackgroundColor3 = COLORS.BG_DARK
logoFrame.BackgroundTransparency = 0.3
logoFrame.Parent = titleBar

createRounded(logoFrame, isMobile and 8 or 10)

local logoIcon = createIcon(logoFrame, ICONS.Signal, 
    UDim2.new(0, isMobile and 24 or 28, 0, isMobile and 24 or 28),
    UDim2.new(0.5, -12, 0.5, -12))

-- Title Label
local titleLabel = Instance.new("TextLabel")
titleLabel.Size = UDim2.new(1, -200, 1, 0)
titleLabel.Position = UDim2.new(0, titleBarHeight + 5, 0, 0)
titleLabel.BackgroundTransparency = 1
titleLabel.Text = "RemoteSpy"
titleLabel.TextColor3 = COLORS.TEXT_PRIMARY
titleLabel.Font = Enum.Font.GothamBlack
titleLabel.TextSize = isMobile and 20 or 28
titleLabel.TextXAlignment = Enum.TextXAlignment.Left
titleLabel.Parent = titleBar

-- Version Badge
local versionBadge = Instance.new("TextLabel")
versionBadge.Size = UDim2.new(0, isMobile and 35 or 40, 0, isMobile and 18 or 20)
versionBadge.Position = UDim2.new(0, titleLabel.Position.X.Offset + 120, 0, (titleBarHeight - 20) / 2)
versionBadge.BackgroundColor3 = COLORS.SUCCESS
versionBadge.Text = "v5"
versionBadge.TextColor3 = COLORS.TEXT_PRIMARY
versionBadge.Font = Enum.Font.GothamBold
versionBadge.TextSize = isMobile and 10 or 12
versionBadge.Parent = titleBar

createRounded(versionBadge, 10)

-- Control Buttons Container (FIX BUG #2 - ganti : jadi or)
local controlButtonsFrame = Instance.new("Frame")
controlButtonsFrame.Size = UDim2.new(0, isMobile and 90 or 110, 1, -10)
controlButtonsFrame.Position = UDim2.new(1, isMobile and -95 or -115, 0, 5)
controlButtonsFrame.BackgroundTransparency = 1
controlButtonsFrame.Parent = titleBar

-- Minimize Button (FIX BUG #3 - ganti : jadi or)
local minimizeBtn = Instance.new("TextButton")
minimizeBtn.Name = "MinimizeBtn"
minimizeBtn.Size = UDim2.new(0, isMobile and 35 or 40, 0, isMobile and 35 or 40)
minimizeBtn.Position = UDim2.new(0, 0, 0, 0)
minimizeBtn.BackgroundColor3 = COLORS.WARNING
minimizeBtn.Text = "-"
minimizeBtn.TextColor3 = COLORS.TEXT_PRIMARY
minimizeBtn.Font = Enum.Font.GothamBlack
minimizeBtn.TextSize = isMobile and 18 or 22
minimizeBtn.BorderSizePixel = 0
minimizeBtn.Parent = controlButtonsFrame

createRounded(minimizeBtn, 8)
addHoverEffect(minimizeBtn, COLORS.WARNING * 1.2, COLORS.WARNING)

-- Close Button (FIX BUG #4 - ganti : jadi or)
local closeBtn = Instance.new("TextButton")
closeBtn.Name = "CloseBtn"
closeBtn.Size = UDim2.new(0, isMobile and 35 or 40, 0, isMobile and 35 or 40)
closeBtn.Position = UDim2.new(0, isMobile and 45 or 50, 0, 0)
closeBtn.BackgroundColor3 = COLORS.ERROR
closeBtn.Text = "X"
closeBtn.TextColor3 = COLORS.TEXT_PRIMARY
closeBtn.Font = Enum.Font.GothamBlack
closeBtn.TextSize = isMobile and 16 or 20
closeBtn.BorderSizePixel = 0
closeBtn.Parent = controlButtonsFrame

createRounded(closeBtn, 8)
addHoverEffect(closeBtn, COLORS.ERROR * 1.2, COLORS.ERROR)

print("Loaded: Main GUI Structure")

-- ============================================
-- RemoteSpy v5 - FIXED VERSION
-- Part 6: Settings Content & UI Controls
-- ============================================

-- State Variables
local includeCoreGuiRemotes = false
local scanningSpeed = 0.1
local autoRefresh = false
local isMinimized = false
local isHidden = false
local cachedRemotes = {}

-- Settings Sections
local generalSection = createSettingsSection("General Settings")
local scanningSection = createSettingsSection("Scanning Options")
local displaySection = createSettingsSection("Display Options")

-- General Settings
local coreGuiToggle = createToggle(generalSection, "Include CoreGui Remotes", includeCoreGuiRemotes, function(value)
    includeCoreGuiRemotes = value
end)

local autoRefreshToggle = createToggle(generalSection, "Auto-refresh on changes", autoRefresh, function(value)
    autoRefresh = value
end)

-- Scanning Settings
local speedSlider = createSlider(scanningSection, "Scanning Speed", 0.01, 1.0, scanningSpeed, function(value)
    scanningSpeed = value
end)

-- Display Settings
local compactToggle = createToggle(displaySection, "Compact View (smaller cards)", false, function(value)
    -- Will be implemented in refresh function
end)

-- Show/Hide Toggle Button (Floating)
local toggleButton = Instance.new("TextButton")
toggleButton.Name = "ToggleButton"
toggleButton.Size = UDim2.new(0, isMobile and 50 or 60, 0, isMobile and 50 or 60)
toggleButton.Position = UDim2.new(1, isMobile and -65 or -75, 0, isMobile and 15 or 20)
toggleButton.BackgroundColor3 = COLORS.PRIMARY
toggleButton.Text = ""
toggleButton.TextSize = isMobile and 24 or 28
toggleButton.Font = Enum.Font.GothamBlack
toggleButton.BorderSizePixel = 0
toggleButton.ZIndex = 1000
toggleButton.Parent = screenGui

createRounded(toggleButton, isMobile and 25 or 30)
createShadow(toggleButton, 20, 0.5)

-- Add icon to toggle button
local toggleIcon = createIcon(toggleButton, ICONS.Signal,
    UDim2.new(0, isMobile and 28 or 32, 0, isMobile and 28 or 32),
    UDim2.new(0.5, isMobile and -14 or -16, 0.5, isMobile and -14 or -16))

-- Pulsing animation for toggle button (FIX BUG #7 - tambah kondisi berhenti)
spawn(function()
    while screenGui and screenGui.Parent and toggleButton and toggleButton.Parent do
        animate(toggleButton, {Size = UDim2.new(0, (isMobile and 50 or 60) * 1.1, 0, (isMobile and 50 or 60) * 1.1)}, ANIM.SMOOTH)
        wait(1)
        if not screenGui or not screenGui.Parent then break end
        animate(toggleButton, {Size = UDim2.new(0, isMobile and 50 or 60, 0, isMobile and 50 or 60)}, ANIM.SMOOTH)
        wait(2)
    end
end)

addHoverEffect(toggleButton, COLORS.PRIMARY_LIGHT, COLORS.PRIMARY)

-- Draggable functionality
local function makeDraggable(frame)
    local dragging = false
    local dragInput, mousePos, framePos
    
    frame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            mousePos = input.Position
            framePos = frame.Position
            
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)
    
    RunService.Heartbeat:Connect(function()
        if dragging and dragInput then
            local delta = dragInput.Position - mousePos
            frame.Position = UDim2.new(
                framePos.X.Scale,
                framePos.X.Offset + delta.X,
                framePos.Y.Scale,
                framePos.Y.Offset + delta.Y
            )
        end
    end)
end

makeDraggable(titleBar)
makeDraggable(settingsTitleBar)

-- Toggle Button Functionality
toggleButton.MouseButton1Click:Connect(function()
    playSound(SOUNDS.Toggle, 0.4)
    isHidden = not isHidden
    
    if isHidden then
        -- Hide animation
        animate(mainContainer, {
            Position = UDim2.new(0.5, -mainWidth/2, 1.5, 0)
        }, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.In))
        
        animate(toggleButton, {
            BackgroundColor3 = COLORS.BG_LIGHT,
            Rotation = 180
        }, ANIM.NORMAL)
    else
        -- Show animation
        animate(mainContainer, {
            Position = UDim2.new(0.5, -mainWidth/2, 0.5, -mainHeight/2)
        }, TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out))
        
        animate(toggleButton, {
            BackgroundColor3 = COLORS.PRIMARY,
            Rotation = 0
        }, ANIM.NORMAL)
        
        playSound(SOUNDS.Open, 0.3)
    end
end)

-- Minimize Functionality
minimizeBtn.MouseButton1Click:Connect(function()
    playSound(SOUNDS.Click, 0.4)
    isMinimized = not isMinimized
    
    local targetHeight = isMinimized and titleBarHeight or mainHeight
    
    animate(mainContainer, {
        Size = UDim2.new(0, mainWidth, 0, targetHeight)
    }, ANIM.SMOOTH)
    
    contentContainer.Visible = not isMinimized
    minimizeBtn.Text = isMinimized and "+" or "-"
end)

-- Close Button
closeBtn.MouseButton1Click:Connect(function()
    playSound(SOUNDS.Close, 0.4)
    
    -- Close animation
    animate(mainContainer, {
        Size = UDim2.new(0, 0, 0, 0),
        Position = UDim2.new(0.5, 0, 0.5, 0)
    }, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.In))
    
    animate(toggleButton, {
        Size = UDim2.new(0, 0, 0, 0)
    }, ANIM.NORMAL)
    
    wait(0.35)
    screenGui:Destroy()
end)

-- Settings Window Toggle
settingsBtn.MouseButton1Click:Connect(function()
    playSound(SOUNDS.Click, 0.4)
    settingsWindow.Visible = not settingsWindow.Visible
    
    if settingsWindow.Visible then
        settingsWindow.Size = UDim2.new(0, 0, 0, 0)
        settingsWindow.Position = UDim2.new(0.5, 0, 0.5, 0)
        
        animate(settingsWindow, {
            Size = UDim2.new(0, isMobile and 320 or 380, 0, isMobile and 400 or 450),
            Position = UDim2.new(0.5, isMobile and -160 or -190, 0.5, isMobile and -200 or -225)
        }, ANIM.BOUNCE)
    end
end)

closeSettingsBtn.MouseButton1Click:Connect(function()
    playSound(SOUNDS.Click, 0.4)
    
    animate(settingsWindow, {
        Size = UDim2.new(0, 0, 0, 0),
        Position = UDim2.new(0.5, 0, 0.5, 0)
    }, TweenInfo.new(0.25, Enum.EasingStyle.Back, Enum.EasingDirection.In))
    
    wait(0.3)
    settingsWindow.Visible = false
end)

-- Search Functionality (FIX BUG #5 - Recursive search untuk cari RemoteName)
searchInput:GetPropertyChangedSignal("Text"):Connect(function()
    local searchText = searchInput.Text:lower()
    clearSearchBtn.Visible = searchText ~= ""
    
    for _, entry in pairs(remoteScrollFrame:GetChildren()) do
        if entry:IsA("Frame") and entry.Name:match("RemoteEntry") then
            -- FIX BUG #5: Recursive search untuk cari RemoteName label
            local nameLabel = entry:FindFirstChild("RemoteName", true)
            if nameLabel then
                local matches = nameLabel.Text:lower():find(searchText, 1, true) ~= nil
                entry.Visible = matches or searchText == ""
            end
        end
    end
end)

clearSearchBtn.MouseButton1Click:Connect(function()
    searchInput.Text = ""
    playSound(SOUNDS.Click, 0.3)
end)

print("Loaded: Settings & UI Controls")

-- ============================================
-- RemoteSpy v5 - FIXED VERSION
-- Part 7: Core Functions & Initialization (FINAL)
-- ============================================

-- Find All Remotes Function
local function findAllRemotes()
    local foundRemotes = {}
    local remoteEventCount = 0
    local remoteFunctionCount = 0
    
    local function searchRecursive(parent, currentPath)
        pcall(function()
            for _, child in ipairs(parent:GetChildren()) do
                local childPath = currentPath .. "." .. child.Name
                local isCoreGui = string.find(childPath, "CoreGui") ~= nil
                local isRobloxReplicatedStorage = string.find(childPath, "RobloxReplicatedStorage") ~= nil
                
                -- Check if this is a remote
                if (child:IsA("RemoteEvent") or child:IsA("RemoteFunction")) then
                    if includeCoreGuiRemotes or (not isCoreGui and not isRobloxReplicatedStorage) then
                        table.insert(foundRemotes, {
                            remote = child,
                            path = childPath,
                        })
                        
                        if child:IsA("RemoteEvent") then
                            remoteEventCount = remoteEventCount + 1
                        else
                            remoteFunctionCount = remoteFunctionCount + 1
                        end
                    end
                end
                
                -- Continue searching
                if includeCoreGuiRemotes or (not isCoreGui and not isRobloxReplicatedStorage) then
                    pcall(function()
                        searchRecursive(child, childPath)
                    end)
                end
            end
        end)
    end
    
    searchRecursive(game, "game")
    
    return foundRemotes, remoteEventCount, remoteFunctionCount
end

-- Refresh Remote List
local function refreshRemoteList()
    playSound(SOUNDS.Click, 0.4)
    
    -- Clear existing entries
    for _, child in pairs(remoteScrollFrame:GetChildren()) do
        if child:IsA("Frame") then
            child:Destroy()
        end
    end
    
    -- Show loading state
    totalRemotesValue.Text = "..."
    remoteEventsValue.Text = "..."
    remoteFunctionsValue.Text = "..."
    
    -- Find remotes
    task.wait(0.1)
    local foundRemotes, eventCount, functionCount = findAllRemotes()
    cachedRemotes = foundRemotes
    
    -- Update stats with animation
    animate(totalRemotesValue.Parent.Parent, {BackgroundColor3 = COLORS.PRIMARY}, ANIM.FAST)
    wait(0.1)
    animate(totalRemotesValue.Parent.Parent, {BackgroundColor3 = COLORS.BG_MEDIUM}, ANIM.FAST)
    
    totalRemotesValue.Text = tostring(#foundRemotes)
    remoteEventsValue.Text = tostring(eventCount)
    remoteFunctionsValue.Text = tostring(functionCount)
    
    -- Create entries with staggered animation
    for index, remoteData in ipairs(foundRemotes) do
        task.wait(0.02)
        local entry = createRemoteEntry(remoteData.remote, remoteData.path, index)
        entry.Parent = remoteScrollFrame
    end
    
    if #foundRemotes == 0 then
        -- Show empty state
        local emptyLabel = Instance.new("TextLabel")
        emptyLabel.Size = UDim2.new(1, 0, 0, 100)
        emptyLabel.Position = UDim2.new(0, 0, 0.5, -50)
        emptyLabel.BackgroundTransparency = 1
        emptyLabel.Text = "No remotes found\n\nTry enabling CoreGui remotes in settings"
        emptyLabel.TextColor3 = COLORS.TEXT_MUTED
        emptyLabel.Font = Enum.Font.Gotham
        emptyLabel.TextSize = isMobile and 13 or 15
        emptyLabel.Parent = remoteScrollFrame
    end
    
    playSound(SOUNDS.Success, 0.3)
end

-- Export Function (FIX BUG #6 - Protected dengan pcall)
local function exportRemotes()
    playSound(SOUNDS.Click, 0.4)
    
    if #cachedRemotes == 0 then
        playSound(SOUNDS.Error, 0.3)
        return
    end
    
    local exportText = "-- RemoteSpy v5 Export\n"
    exportText = exportText .. "-- Total Remotes: " .. #cachedRemotes .. "\n"
    exportText = exportText .. "-- Exported: " .. os.date("%Y-%m-%d %H:%M:%S") .. "\n\n"
    
    for i, remoteData in ipairs(cachedRemotes) do
        exportText = exportText .. string.format(
            "[%d] %s: %s\n",
            i,
            remoteData.remote.ClassName,
            remoteData.path
        )
    end
    
    pcall(function()
        setclipboard(exportText)
    end)
    
    -- Success feedback
    animate(exportBtn, {BackgroundColor3 = COLORS.SUCCESS}, ANIM.FAST)
    exportBtn.Text = " Copied!"
    playSound(SOUNDS.Success, 0.3)
    
    wait(1.5)
    animate(exportBtn, {BackgroundColor3 = COLORS.INFO}, ANIM.FAST)
    exportBtn.Text = " Export"
end

-- Button Connections
refreshBtn.MouseButton1Click:Connect(refreshRemoteList)
exportBtn.MouseButton1Click:Connect(exportRemotes)

-- Auto-refresh monitor (if enabled) (FIX BUG #7 - tambah kondisi berhenti)
spawn(function()
    local lastCount = 0
    
    while screenGui and screenGui.Parent do
        if autoRefresh and not isHidden then
            local currentRemotes = findAllRemotes()
            
            if #currentRemotes ~= lastCount then
                lastCount = #currentRemotes
                refreshRemoteList()
            end
        end
        wait(5)
    end
end)

-- Notification System
local function showNotification(title, message, color, duration)
    local notification = Instance.new("Frame")
    notification.Size = UDim2.new(0, isMobile and 280 or 320, 0, 0)
    notification.Position = UDim2.new(1, isMobile and -290 or -330, 0, isMobile and 80 or 90)
    notification.BackgroundColor3 = color or COLORS.PRIMARY
    notification.BorderSizePixel = 0
    notification.ZIndex = 999
    notification.Parent = screenGui
    
    createRounded(notification, 10)
    createShadow(notification, 20, 0.4)
    
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Size = UDim2.new(1, -20, 0, 24)
    titleLabel.Position = UDim2.new(0, 10, 0, 8)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = title
    titleLabel.TextColor3 = COLORS.TEXT_PRIMARY
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.TextSize = isMobile and 13 or 14
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.Parent = notification
    
    local messageLabel = Instance.new("TextLabel")
    messageLabel.Size = UDim2.new(1, -20, 0, 0)
    messageLabel.Position = UDim2.new(0, 10, 0, 32)
    messageLabel.BackgroundTransparency = 1
    messageLabel.Text = message
    messageLabel.TextColor3 = COLORS.TEXT_SECONDARY
    messageLabel.Font = Enum.Font.Gotham
    messageLabel.TextSize = isMobile and 11 or 12
    messageLabel.TextXAlignment = Enum.TextXAlignment.Left
    messageLabel.TextWrapped = true
    messageLabel.AutomaticSize = Enum.AutomaticSize.Y
    messageLabel.Parent = notification
    
    -- Animate in
    animate(notification, {
        Size = UDim2.new(0, isMobile and 280 or 320, 0, messageLabel.AbsoluteSize.Y + 48)
    }, ANIM.BOUNCE)
    
    playSound(SOUNDS.Success, 0.3)
    
    -- Auto dismiss
    task.wait(duration or 3)
    
    animate(notification, {
        Position = UDim2.new(1, 10, 0, isMobile and 80 or 90)
    }, ANIM.NORMAL)
    
    task.wait(0.3)
    notification:Destroy()
end

-- Initialize
local function initialize()
    -- Entry animation
    mainContainer.Size = UDim2.new(0, 0, 0, 0)
    mainContainer.Position = UDim2.new(0.5, 0, 0.5, 0)
    
    toggleButton.Size = UDim2.new(0, 0, 0, 0)
    
    wait(0.1)
    
    animate(toggleButton, {
        Size = UDim2.new(0, isMobile and 50 or 60, 0, isMobile and 50 or 60)
    }, ANIM.BOUNCE)
    
    wait(0.2)
    
    animate(mainContainer, {
        Size = UDim2.new(0, mainWidth, 0, mainHeight),
        Position = UDim2.new(0.5, -mainWidth/2, 0.5, -mainHeight/2)
    }, TweenInfo.new(0.6, Enum.EasingStyle.Back, Enum.EasingDirection.Out))
    
    playSound(SOUNDS.Open, 0.4)
    
    wait(0.7)
    
    -- Initial scan
    refreshRemoteList()
    
    -- Welcome notification
    showNotification(
        "RemoteSpy v5 Loaded!",
        "Professional remote explorer ready. Tap refresh to scan for remotes.",
        COLORS.SUCCESS,
        4
    )
end

-- Clean up on script removal (FIX BUG #7)
screenGui.AncestryChanged:Connect(function()
    if not screenGui:IsDescendantOf(game) then
        pcall(function()
            screenGui:Destroy()
        end)
    end
end)

-- Start initialization
pcall(initialize)

print("Loaded: Core Functions")
print("====================================")
print("RemoteSpy v5 FIXED VERSION LOADED!")
print("====================================")
print("All bugs fixed:")
print("  - CoreGui -> PlayerGui")
print("  - Operator : -> or")
print("  - Emoji -> Icon rbxassetid")
print("  - Protected with pcall")
print("  - Search bug fixed")
print("  - Loop with break conditions")
print("  - setclipboard check added")
print("====================================")
print("Mobile Optimized | Smooth Animations")