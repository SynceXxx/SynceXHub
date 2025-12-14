
-- RemoteSpy v5 - Professional Edition
-- Modern, Smooth, Animated Remote Explorer for Roblox
-- Mobile Optimized with Sound Effects

-- ============================================
-- PART 1: Services, Colors & Sound Setup
-- ============================================

-- Services
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")

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

-- Sound Player
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

-- Utility: Create gradient
local function createGradient(parent, colors, rotation)
    local gradient = Instance.new("UIGradient")
    gradient.Color = ColorSequence.new(colors)
    gradient.Rotation = rotation or 90
    gradient.Parent = parent
    return gradient
end

-- Utility: Animate property
local function animate(object, properties, tweenInfo)
    local tween = TweenService:Create(object, tweenInfo or ANIM.NORMAL, properties)
    tween:Play()
    return tween
end

-- Utility: Button hover effect
local function addHoverEffect(button, hoverColor, normalColor)
    button.MouseEnter:Connect(function()
        playSound(SOUNDS.Hover, 0.2)
        animate(button, {BackgroundColor3 = hoverColor}, ANIM.FAST)
    end)
    
    button.MouseLeave:Connect(function()
        animate(button, {BackgroundColor3 = normalColor}, ANIM.FAST)
    end)
    
    button.MouseButton1Down:Connect(function()
        animate(button, {Size = UDim2.new(button.Size.X.Scale * 0.95, 0, button.Size.Y.Scale * 0.95, 0)}, ANIM.FAST)
    end)
    
    button.MouseButton1Up:Connect(function()
        animate(button, {Size = UDim2.new(button.Size.X.Scale / 0.95, 0, button.Size.Y.Scale / 0.95, 0)}, ANIM.FAST)
    end)
end

-- ============================================
-- PART 2: Main GUI Structure
-- Paste this BELOW Part 1
-- ============================================

-- Responsive sizing based on platform
local mainWidth = isMobile and 360 or 800
local mainHeight = isMobile and 500 or 600
local titleBarHeight = isMobile and 50 or 60

-- Main GUI Setup
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "RemoteSpyV5Pro"
screenGui.ResetOnSpawn = false
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
screenGui.Parent = game.CoreGui

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

-- Animated glow effect
spawn(function()
    while wait(2) do
        animate(borderGlow, {Transparency = 0.2}, ANIM.SMOOTH)
        wait(2)
        animate(borderGlow, {Transparency = 0.5}, ANIM.SMOOTH)
    end
end)

-- Title Bar
local titleBar = Instance.new("Frame")
titleBar.Name = "TitleBar"
titleBar.Size = UDim2.new(1, 0, 0, titleBarHeight)
titleBar.BackgroundColor3 = COLORS.BG_MEDIUM
titleBar.BorderSizePixel = 0
titleBar.Parent = mainWindow

createGradient(titleBar, {COLORS.PRIMARY, COLORS.PRIMARY_DARK}, 0)

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

-- Icon/Logo
local logoIcon = Instance.new("TextLabel")
logoIcon.Size = UDim2.new(0, titleBarHeight - 10, 0, titleBarHeight - 10)
logoIcon.Position = UDim2.new(0, 10, 0, 5)
logoIcon.BackgroundColor3 = COLORS.BG_DARK
logoIcon.BackgroundTransparency = 0.3
logoIcon.Text = "📡"
logoIcon.TextColor3 = COLORS.TEXT_PRIMARY
logoIcon.Font = Enum.Font.GothamBold
logoIcon.TextSize = isMobile and 20 or 24
logoIcon.Parent = titleBar

createRounded(logoIcon, isMobile and 8 or 10)

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

-- Control Buttons Container
local controlButtonsFrame = Instance.new("Frame")
controlButtonsFrame.Size = UDim2.new(0, isMobile and 90 : 110, 1, -10)
controlButtonsFrame.Position = UDim2.new(1, isMobile and -95 : -115, 0, 5)
controlButtonsFrame.BackgroundTransparency = 1
controlButtonsFrame.Parent = titleBar

-- Minimize Button
local minimizeBtn = Instance.new("TextButton")
minimizeBtn.Name = "MinimizeBtn"
minimizeBtn.Size = UDim2.new(0, isMobile and 35 : 40, 0, isMobile and 35 : 40)
minimizeBtn.Position = UDim2.new(0, 0, 0, 0)
minimizeBtn.BackgroundColor3 = COLORS.WARNING
minimizeBtn.Text = "−"
minimizeBtn.TextColor3 = COLORS.TEXT_PRIMARY
minimizeBtn.Font = Enum.Font.GothamBlack
minimizeBtn.TextSize = isMobile and 18 : 22
minimizeBtn.BorderSizePixel = 0
minimizeBtn.Parent = controlButtonsFrame

createRounded(minimizeBtn, 8)
addHoverEffect(minimizeBtn, COLORS.WARNING * 1.2, COLORS.WARNING)

-- Close Button
local closeBtn = Instance.new("TextButton")
closeBtn.Name = "CloseBtn"
closeBtn.Size = UDim2.new(0, isMobile and 35 : 40, 0, isMobile and 35 : 40)
closeBtn.Position = UDim2.new(0, isMobile and 45 : 50, 0, 0)
closeBtn.BackgroundColor3 = COLORS.ERROR
closeBtn.Text = "✕"
closeBtn.TextColor3 = COLORS.TEXT_PRIMARY
closeBtn.Font = Enum.Font.GothamBlack
closeBtn.TextSize = isMobile and 16 : 20
closeBtn.BorderSizePixel = 0
closeBtn.Parent = controlButtonsFrame

createRounded(closeBtn, 8)
addHoverEffect(closeBtn, COLORS.ERROR * 1.2, COLORS.ERROR)

-- ============================================
-- PART 3: Content Area & Tab System
-- Paste this BELOW Part 2
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
actionBar.Size = UDim2.new(1, -20, 0, isMobile and 40 : 50)
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

-- Action Button Creator
local function createActionButton(icon, text, color)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, isMobile and 70 : 90, 0, isMobile and 30 : 36)
    btn.BackgroundColor3 = color
    btn.BorderSizePixel = 0
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = isMobile and 11 : 13
    btn.TextColor3 = COLORS.TEXT_PRIMARY
    btn.Text = icon .. " " .. text
    btn.AutoButtonColor = false
    btn.Parent = actionBar
    
    createRounded(btn, 8)
    addHoverEffect(btn, color * 1.3, color)
    
    return btn
end

local refreshBtn = createActionButton("🔄", "Refresh", COLORS.PRIMARY)
local exportBtn = createActionButton("📋", "Export", COLORS.INFO)
local settingsBtn = createActionButton("⚙️", "Settings", COLORS.BG_LIGHTER)

-- Stats Bar
local statsBar = Instance.new("Frame")
statsBar.Name = "StatsBar"
statsBar.Size = UDim2.new(1, -20, 0, isMobile and 35 : 40)
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

-- Stat Item Creator
local function createStatItem(icon, labelText, valueText, color)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, isMobile and 80 : 100, 1, 0)
    frame.BackgroundTransparency = 1
    frame.Parent = statsBar
    
    local iconLabel = Instance.new("TextLabel")
    iconLabel.Size = UDim2.new(0, 20, 0, 20)
    iconLabel.Position = UDim2.new(0, 0, 0.5, -10)
    iconLabel.BackgroundTransparency = 1
    iconLabel.Text = icon
    iconLabel.TextSize = 16
    iconLabel.Parent = frame
    
    local textLabel = Instance.new("TextLabel")
    textLabel.Size = UDim2.new(1, -25, 0, isMobile and 12 : 14)
    textLabel.Position = UDim2.new(0, 25, 0, 2)
    textLabel.BackgroundTransparency = 1
    textLabel.Text = labelText
    textLabel.TextColor3 = COLORS.TEXT_MUTED
    textLabel.Font = Enum.Font.Gotham
    textLabel.TextSize = isMobile and 10 : 11
    textLabel.TextXAlignment = Enum.TextXAlignment.Left
    textLabel.Parent = frame
    
    local valueLabel = Instance.new("TextLabel")
    valueLabel.Size = UDim2.new(1, -25, 0, isMobile and 16 : 18)
    valueLabel.Position = UDim2.new(0, 25, 1, isMobile and -18 : -20)
    valueLabel.BackgroundTransparency = 1
    valueLabel.Text = valueText
    valueLabel.TextColor3 = color
    valueLabel.Font = Enum.Font.GothamBold
    valueLabel.TextSize = isMobile and 13 : 15
    valueLabel.TextXAlignment = Enum.TextXAlignment.Left
    valueLabel.Parent = frame
    
    return valueLabel
end

local totalRemotesValue = createStatItem("📡", "Total", "0", COLORS.PRIMARY)
local remoteEventsValue = createStatItem("🔔", "Events", "0", COLORS.SUCCESS)
local remoteFunctionsValue = createStatItem("⚡", "Functions", "0", COLORS.INFO)

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
searchBar.Size = UDim2.new(1, -20, 0, isMobile and 35 : 40)
searchBar.Position = UDim2.new(0, 10, 0, 10)
searchBar.BackgroundColor3 = COLORS.BG_LIGHT
searchBar.BorderSizePixel = 0
searchBar.Parent = remoteListContainer

createRounded(searchBar, 8)

local searchIcon = Instance.new("TextLabel")
searchIcon.Size = UDim2.new(0, 30, 1, 0)
searchIcon.BackgroundTransparency = 1
searchIcon.Text = "🔍"
searchIcon.TextSize = isMobile and 16 : 18
searchIcon.Parent = searchBar

local searchInput = Instance.new("TextBox")
searchInput.Size = UDim2.new(1, -70, 1, 0)
searchInput.Position = UDim2.new(0, 35, 0, 0)
searchInput.BackgroundTransparency = 1
searchInput.PlaceholderText = "Search remotes..."
searchInput.PlaceholderColor3 = COLORS.TEXT_MUTED
searchInput.Text = ""
searchInput.TextColor3 = COLORS.TEXT_PRIMARY
searchInput.Font = Enum.Font.Gotham
searchInput.TextSize = isMobile and 12 : 14
searchInput.TextXAlignment = Enum.TextXAlignment.Left
searchInput.ClearTextOnFocus = false
searchInput.Parent = searchBar

local clearSearchBtn = Instance.new("TextButton")
clearSearchBtn.Size = UDim2.new(0, 30, 1, 0)
clearSearchBtn.Position = UDim2.new(1, -35, 0, 0)
clearSearchBtn.BackgroundTransparency = 1
clearSearchBtn.Text = "✕"
clearSearchBtn.TextColor3 = COLORS.TEXT_MUTED
clearSearchBtn.Font = Enum.Font.GothamBold
clearSearchBtn.TextSize = isMobile and 14 : 16
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

-- ============================================
-- PART 4: Remote Entry Card Creator
-- Paste this BELOW Part 3
-- ============================================

-- Create Remote Entry Card (Modern Design)
local function createRemoteEntry(remote, path, index)
    local entryCard = Instance.new("Frame")
    entryCard.Name = "RemoteEntry_" .. index
    entryCard.Size = UDim2.new(1, -10, 0, isMobile and 85 : 95)
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
    
    -- Type Icon
    local typeIcon = Instance.new("TextLabel")
    typeIcon.Size = UDim2.new(0, isMobile and 35 : 40, 0, isMobile and 35 : 40)
    typeIcon.Position = UDim2.new(0, 12, 0, 8)
    typeIcon.BackgroundColor3 = remote:IsA("RemoteEvent") and COLORS.SUCCESS or COLORS.INFO
    typeIcon.BackgroundTransparency = 0.8
    typeIcon.Text = remote:IsA("RemoteEvent") and "🔔" or "⚡"
    typeIcon.TextSize = isMobile and 18 : 20
    typeIcon.Parent = entryCard
    
    createRounded(typeIcon, 8)
    
    -- Remote Name
    local nameLabel = Instance.new("TextLabel")
    nameLabel.Size = UDim2.new(1, isMobile and -140 : -170, 0, isMobile and 18 : 20)
    nameLabel.Position = UDim2.new(0, isMobile and 55 : 60, 0, 8)
    nameLabel.BackgroundTransparency = 1
    nameLabel.Text = remote.Name
    nameLabel.TextColor3 = COLORS.TEXT_PRIMARY
    nameLabel.Font = Enum.Font.GothamBold
    nameLabel.TextSize = isMobile and 13 : 15
    nameLabel.TextXAlignment = Enum.TextXAlignment.Left
    nameLabel.TextTruncate = Enum.TextTruncate.AtEnd
    nameLabel.Parent = entryCard
    
    -- Type Badge
    local typeBadge = Instance.new("TextLabel")
    typeBadge.Size = UDim2.new(0, isMobile and 50 : 60, 0, isMobile and 16 : 18)
    typeBadge.Position = UDim2.new(0, isMobile and 55 : 60, 0, isMobile and 28 : 30)
    typeBadge.BackgroundColor3 = remote:IsA("RemoteEvent") and COLORS.SUCCESS or COLORS.INFO
    typeBadge.BackgroundTransparency = 0.7
    typeBadge.Text = remote:IsA("RemoteEvent") and "Event" or "Function"
    typeBadge.TextColor3 = COLORS.TEXT_PRIMARY
    typeBadge.Font = Enum.Font.GothamBold
    typeBadge.TextSize = isMobile and 9 : 10
    typeBadge.Parent = entryCard
    
    createRounded(typeBadge, 4)
    
    -- Path Label
    local pathLabel = Instance.new("TextLabel")
    pathLabel.Size = UDim2.new(1, isMobile and -140 : -170, 0, isMobile and 16 : 18)
    pathLabel.Position = UDim2.new(0, isMobile and 55 : 60, 0, isMobile and 48 : 52)
    pathLabel.BackgroundTransparency = 1
    pathLabel.Text = path
    pathLabel.TextColor3 = COLORS.TEXT_MUTED
    pathLabel.Font = Enum.Font.Gotham
    pathLabel.TextSize = isMobile and 10 : 11
    pathLabel.TextXAlignment = Enum.TextXAlignment.Left
    pathLabel.TextTruncate = Enum.TextTruncate.AtEnd
    pathLabel.Parent = entryCard
    
    -- Status Indicator (bottom)
    local statusLabel = Instance.new("TextLabel")
    statusLabel.Size = UDim2.new(1, isMobile and -140 : -170, 0, isMobile and 14 : 16)
    statusLabel.Position = UDim2.new(0, isMobile and 55 : 60, 1, isMobile and -18 : -20)
    statusLabel.BackgroundTransparency = 1
    statusLabel.Text = "● Ready"
    statusLabel.TextColor3 = COLORS.SUCCESS
    statusLabel.Font = Enum.Font.Gotham
    statusLabel.TextSize = isMobile and 9 : 10
    statusLabel.TextXAlignment = Enum.TextXAlignment.Left
    statusLabel.Parent = entryCard
    
    -- Action Buttons Container
    local actionsFrame = Instance.new("Frame")
    actionsFrame.Size = UDim2.new(0, isMobile and 85 : 110, 1, -16)
    actionsFrame.Position = UDim2.new(1, isMobile and -90 : -115, 0, 8)
    actionsFrame.BackgroundTransparency = 1
    actionsFrame.Parent = entryCard
    
    local actionsLayout = Instance.new("UIListLayout")
    actionsLayout.FillDirection = Enum.FillDirection.Vertical
    actionsLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    actionsLayout.VerticalAlignment = Enum.VerticalAlignment.Center
    actionsLayout.Padding = UDim.new(0, 6)
    actionsLayout.Parent = actionsFrame
    
    -- Create Action Button
    local function createActionBtn(text, icon, color)
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(1, 0, 0, isMobile and 22 : 25)
        btn.BackgroundColor3 = color
        btn.Text = icon .. " " .. text
        btn.TextColor3 = COLORS.TEXT_PRIMARY
        btn.Font = Enum.Font.GothamBold
        btn.TextSize = isMobile and 10 : 11
        btn.BorderSizePixel = 0
        btn.AutoButtonColor = false
        btn.Parent = actionsFrame
        
        createRounded(btn, 6)
        addHoverEffect(btn, color * 1.3, color)
        
        return btn
    end
    
    local fireBtn = createActionBtn("Fire", "🚀", COLORS.PRIMARY)
    local copyBtn = createActionBtn("Copy", "📋", COLORS.INFO)
    local infoBtn = createActionBtn("Info", "ℹ️", COLORS.BG_LIGHTER)
    
    -- Button Actions
    fireBtn.MouseButton1Click:Connect(function()
        playSound(SOUNDS.Click, 0.4)
        statusLabel.Text = "● Firing..."
        statusLabel.TextColor3 = COLORS.WARNING
        
        local success = false
        if remote:IsA("RemoteEvent") then
            pcall(function()
                remote:FireServer()
                success = true
            end)
        elseif remote:IsA("RemoteFunction") then
            pcall(function()
                remote:InvokeServer()
                success = true
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
        setclipboard(path)
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
        -- Info action will be handled in Part 5
    end)
    
    -- Entry animation
    entryCard.BackgroundTransparency = 1
    entryCard.Size = UDim2.new(1, -10, 0, 0)
    
    animate(entryCard, {
        BackgroundTransparency = 0,
        Size = UDim2.new(1, -10, 0, isMobile and 85 : 95)
    }, TweenInfo.new(0.3 + index * 0.02, Enum.EasingStyle.Back, Enum.EasingDirection.Out))
    
    return entryCard
end

-- ============================================
-- PART 5: Settings Window
-- Paste this BELOW Part 4
-- ============================================

-- Settings Window
local settingsWindow = Instance.new("Frame")
settingsWindow.Name = "SettingsWindow"
settingsWindow.Size = UDim2.new(0, isMobile and 320 : 380, 0, isMobile and 400 : 450)
settingsWindow.Position = UDim2.new(0.5, isMobile and -160 : -190, 0.5, isMobile and -200 : -225)
settingsWindow.BackgroundColor3 = COLORS.BG_DARK
settingsWindow.BorderSizePixel = 0
settingsWindow.Visible = false
settingsWindow.ZIndex = 100
settingsWindow.Parent = screenGui

createRounded(settingsWindow, 16)
createShadow(settingsWindow, 50, 0.5)

-- Settings Title Bar
local settingsTitleBar = Instance.new("Frame")
settingsTitleBar.Size = UDim2.new(1, 0, 0, 50)
settingsTitleBar.BackgroundColor3 = COLORS.PRIMARY
settingsTitleBar.BorderSizePixel = 0
settingsTitleBar.Parent = settingsWindow

createGradient(settingsTitleBar, {COLORS.PRIMARY, COLORS.PRIMARY_DARK}, 0)

local settingsTitleCorner = Instance.new("UICorner")
settingsTitleCorner.CornerRadius = UDim.new(0, 16)
settingsTitleCorner.Parent = settingsTitleBar

local settingsTitleExt = Instance.new("Frame")
settingsTitleExt.Size = UDim2.new(1, 0, 0, 16)
settingsTitleExt.Position = UDim2.new(0, 0, 1, -16)
settingsTitleExt.BackgroundColor3 = COLORS.PRIMARY_DARK
settingsTitleExt.BorderSizePixel = 0
settingsTitleExt.Parent = settingsTitleBar

local settingsTitleLabel = Instance.new("TextLabel")
settingsTitleLabel.Size = UDim2.new(1, -50, 1, 0)
settingsTitleLabel.Position = UDim2.new(0, 15, 0, 0)
settingsTitleLabel.BackgroundTransparency = 1
settingsTitleLabel.Text = "⚙️ Settings"
settingsTitleLabel.TextColor3 = COLORS.TEXT_PRIMARY
settingsTitleLabel.Font = Enum.Font.GothamBlack
settingsTitleLabel.TextSize = isMobile and 18 : 20
settingsTitleLabel.TextXAlignment = Enum.TextXAlignment.Left
settingsTitleLabel.Parent = settingsTitleBar

local closeSettingsBtn = Instance.new("TextButton")
closeSettingsBtn.Size = UDim2.new(0, 35, 0, 35)
closeSettingsBtn.Position = UDim2.new(1, -42, 0, 7)
closeSettingsBtn.BackgroundColor3 = COLORS.ERROR
closeSettingsBtn.Text = "✕"
closeSettingsBtn.TextColor3 = COLORS.TEXT_PRIMARY
closeSettingsBtn.Font = Enum.Font.GothamBlack
closeSettingsBtn.TextSize = 16
closeSettingsBtn.BorderSizePixel = 0
closeSettingsBtn.Parent = settingsTitleBar

createRounded(closeSettingsBtn, 8)
addHoverEffect(closeSettingsBtn, COLORS.ERROR * 1.2, COLORS.ERROR)

-- Settings Content
local settingsContent = Instance.new("ScrollingFrame")
settingsContent.Size = UDim2.new(1, -20, 1, -70)
settingsContent.Position = UDim2.new(0, 10, 0, 60)
settingsContent.BackgroundTransparency = 1
settingsContent.BorderSizePixel = 0
settingsContent.ScrollBarThickness = 6
settingsContent.ScrollBarImageColor3 = COLORS.PRIMARY
settingsContent.CanvasSize = UDim2.new(0, 0, 0, 600)
settingsContent.Parent = settingsWindow

local settingsLayout = Instance.new("UIListLayout")
settingsLayout.FillDirection = Enum.FillDirection.Vertical
settingsLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
settingsLayout.VerticalAlignment = Enum.VerticalAlignment.Top
settingsLayout.Padding = UDim.new(0, 12)
settingsLayout.Parent = settingsContent

settingsLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    settingsContent.CanvasSize = UDim2.new(0, 0, 0, settingsLayout.AbsoluteContentSize.Y + 20)
end)

-- Settings Section Creator
local function createSettingsSection(title)
    local section = Instance.new("Frame")
    section.Size = UDim2.new(1, -10, 0, 0)
    section.BackgroundColor3 = COLORS.BG_MEDIUM
    section.BorderSizePixel = 0
    section.AutomaticSize = Enum.AutomaticSize.Y
    section.Parent = settingsContent
    
    createRounded(section, 10)
    
    local sectionLayout = Instance.new("UIListLayout")
    sectionLayout.FillDirection = Enum.FillDirection.Vertical
    sectionLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    sectionLayout.VerticalAlignment = Enum.VerticalAlignment.Top
    sectionLayout.Padding = UDim.new(0, 8)
    sectionLayout.Parent = section
    
    local sectionPadding = Instance.new("UIPadding")
    sectionPadding.PaddingLeft = UDim.new(0, 12)
    sectionPadding.PaddingRight = UDim.new(0, 12)
    sectionPadding.PaddingTop = UDim.new(0, 12)
    sectionPadding.PaddingBottom = UDim.new(0, 12)
    sectionPadding.Parent = section
    
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Size = UDim2.new(1, 0, 0, 20)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = title
    titleLabel.TextColor3 = COLORS.PRIMARY
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.TextSize = isMobile and 13 : 14
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.Parent = section
    
    return section
end

-- Toggle Switch Creator
local function createToggle(parent, labelText, defaultValue, callback)
    local toggleFrame = Instance.new("Frame")
    toggleFrame.Size = UDim2.new(1, 0, 0, 40)
    toggleFrame.BackgroundTransparency = 1
    toggleFrame.Parent = parent
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -60, 1, 0)
    label.BackgroundTransparency = 1
    label.Text = labelText
    label.TextColor3 = COLORS.TEXT_PRIMARY
    label.Font = Enum.Font.Gotham
    label.TextSize = isMobile and 12 : 13
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.TextWrapped = true
    label.Parent = toggleFrame
    
    local toggleBg = Instance.new("Frame")
    toggleBg.Size = UDim2.new(0, 50, 0, 26)
    toggleBg.Position = UDim2.new(1, -50, 0.5, -13)
    toggleBg.BackgroundColor3 = defaultValue and COLORS.SUCCESS or COLORS.BG_LIGHTER
    toggleBg.BorderSizePixel = 0
    toggleBg.Parent = toggleFrame
    
    createRounded(toggleBg, 13)
    
    local toggleKnob = Instance.new("Frame")
    toggleKnob.Size = UDim2.new(0, 20, 0, 20)
    toggleKnob.Position = defaultValue and UDim2.new(1, -23, 0.5, -10) or UDim2.new(0, 3, 0.5, -10)
    toggleKnob.BackgroundColor3 = COLORS.TEXT_PRIMARY
    toggleKnob.BorderSizePixel = 0
    toggleKnob.Parent = toggleBg
    
    createRounded(toggleKnob, 10)
    createShadow(toggleKnob, 6, 0.5)
    
    local isOn = defaultValue
    
    local toggleBtn = Instance.new("TextButton")
    toggleBtn.Size = UDim2.new(1, 0, 1, 0)
    toggleBtn.BackgroundTransparency = 1
    toggleBtn.Text = ""
    toggleBtn.Parent = toggleBg
    
    toggleBtn.MouseButton1Click:Connect(function()
        isOn = not isOn
        playSound(SOUNDS.Toggle, 0.3)
        
        animate(toggleBg, {BackgroundColor3 = isOn and COLORS.SUCCESS or COLORS.BG_LIGHTER}, ANIM.NORMAL)
        animate(toggleKnob, {Position = isOn and UDim2.new(1, -23, 0.5, -10) or UDim2.new(0, 3, 0.5, -10)}, ANIM.BOUNCE)
        
        if callback then callback(isOn) end
    end)
    
    return {frame = toggleFrame, getValue = function() return isOn end}
end

-- Slider Creator
local function createSlider(parent, labelText, minValue, maxValue, defaultValue, callback)
    local sliderFrame = Instance.new("Frame")
    sliderFrame.Size = UDim2.new(1, 0, 0, 60)
    sliderFrame.BackgroundTransparency = 1
    sliderFrame.Parent = parent
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -60, 0, 20)
    label.BackgroundTransparency = 1
    label.Text = labelText
    label.TextColor3 = COLORS.TEXT_PRIMARY
    label.Font = Enum.Font.Gotham
    label.TextSize = isMobile and 12 : 13
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = sliderFrame
    
    local valueLabel = Instance.new("TextLabel")
    valueLabel.Size = UDim2.new(0, 60, 0, 20)
    valueLabel.Position = UDim2.new(1, -60, 0, 0)
    valueLabel.BackgroundTransparency = 1
    valueLabel.Text = string.format("%.2f", defaultValue)
    valueLabel.TextColor3 = COLORS.PRIMARY
    valueLabel.Font = Enum.Font.GothamBold
    valueLabel.TextSize = isMobile and 12 : 13
    valueLabel.TextXAlignment = Enum.TextXAlignment.Right
    valueLabel.Parent = sliderFrame
    
    local sliderTrack = Instance.new("Frame")
    sliderTrack.Size = UDim2.new(1, 0, 0, 6)
    sliderTrack.Position = UDim2.new(0, 0, 0, 35)
    sliderTrack.BackgroundColor3 = COLORS.BG_LIGHTER
    sliderTrack.BorderSizePixel = 0
    sliderTrack.Parent = sliderFrame
    
    createRounded(sliderTrack, 3)
    
    local sliderFill = Instance.new("Frame")
    sliderFill.Size = UDim2.new((defaultValue - minValue) / (maxValue - minValue), 0, 1, 0)
    sliderFill.BackgroundColor3 = COLORS.PRIMARY
    sliderFill.BorderSizePixel = 0
    sliderFill.Parent = sliderTrack
    
    createRounded(sliderFill, 3)
    
    local sliderKnob = Instance.new("Frame")
    sliderKnob.Size = UDim2.new(0, 18, 0, 18)
    sliderKnob.Position = UDim2.new((defaultValue - minValue) / (maxValue - minValue), -9, 0.5, -9)
    sliderKnob.BackgroundColor3 = COLORS.PRIMARY
    sliderKnob.BorderSizePixel = 0
    sliderKnob.ZIndex = 2
    sliderKnob.Parent = sliderTrack
    
    createRounded(sliderKnob, 9)
    createShadow(sliderKnob, 8, 0.4)
    
    local isDragging = false
    local currentValue = defaultValue
    
    local function updateSlider(value)
        currentValue = math.clamp(value, minValue, maxValue)
        local normalized = (currentValue - minValue) / (maxValue - minValue)
        
        animate(sliderFill, {Size = UDim2.new(normalized, 0, 1, 0)}, ANIM.FAST)
        animate(sliderKnob, {Position = UDim2.new(normalized, -9, 0.5, -9)}, ANIM.FAST)
        
        valueLabel.Text = string.format("%.2f", currentValue)
        
        if callback then callback(currentValue) end
    end
    
    sliderKnob.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            isDragging = true
            playSound(SOUNDS.Click, 0.2)
        end
    end)
    
    sliderKnob.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            isDragging = false
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if isDragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local relativeX = (input.Position.X - sliderTrack.AbsolutePosition.X) / sliderTrack.AbsoluteSize.X
            relativeX = math.clamp(relativeX, 0, 1)
            local newValue = minValue + (maxValue - minValue) * relativeX
            updateSlider(newValue)
        end
    end)
    
    return {frame = sliderFrame, getValue = function() return currentValue end, setValue = updateSlider}
end

-- ============================================
-- PART 6: Settings Content & Show/Hide Toggle
-- Paste this BELOW Part 5
-- ============================================

-- State Variables
local includeCoreGuiRemotes = false
local scanningSpeed = 0.1
local autoRefresh = false
local isMinimized = false
local isHidden = false
local cachedRemotes = {}

-- Settings Sections
local generalSection = createSettingsSection("🔧 General Settings")
local scanningSection = createSettingsSection("🔍 Scanning Options")
local displaySection = createSettingsSection("🎨 Display Options")

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
toggleButton.Size = UDim2.new(0, isMobile and 50 : 60, 0, isMobile and 50 : 60)
toggleButton.Position = UDim2.new(1, isMobile and -65 : -75, 0, isMobile and 15 : 20)
toggleButton.BackgroundColor3 = COLORS.PRIMARY
toggleButton.Text = "📡"
toggleButton.TextSize = isMobile and 24 : 28
toggleButton.Font = Enum.Font.GothamBlack
toggleButton.BorderSizePixel = 0
toggleButton.ZIndex = 1000
toggleButton.Parent = screenGui

createRounded(toggleButton, isMobile and 25 : 30)
createShadow(toggleButton, 20, 0.5)

-- Pulsing animation for toggle button
spawn(function()
    while wait(2) do
        animate(toggleButton, {Size = UDim2.new(0, (isMobile and 50 : 60) * 1.1, 0, (isMobile and 50 : 60) * 1.1)}, ANIM.SMOOTH)
        wait(1)
        animate(toggleButton, {Size = UDim2.new(0, isMobile and 50 : 60, 0, isMobile and 50 : 60)}, ANIM.SMOOTH)
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
    minimizeBtn.Text = isMinimized and "+" or "−"
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
            Size = UDim2.new(0, isMobile and 320 : 380, 0, isMobile and 400 : 450),
            Position = UDim2.new(0.5, isMobile and -160 : -190, 0.5, isMobile and -200 : -225)
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

-- Search Functionality
searchInput:GetPropertyChangedSignal("Text"):Connect(function()
    local searchText = searchInput.Text:lower()
    clearSearchBtn.Visible = searchText ~= ""
    
    for _, entry in pairs(remoteScrollFrame:GetChildren()) do
        if entry:IsA("Frame") and entry.Name:match("RemoteEntry") then
            local nameLabel = entry:FindFirstChild("RemoteEntry_"):FindFirstChild("TextLabel")
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

-- ============================================
-- PART 7: Core Functions & Initialization (FINAL)
-- Paste this BELOW Part 6
-- ============================================

-- Find All Remotes Function
local function findAllRemotes()
    local foundRemotes = {}
    local remoteEventCount = 0
    local remoteFunctionCount = 0
    
    local function searchRecursive(parent, currentPath)
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
        emptyLabel.Text = "No remotes found\n🔍\nTry enabling CoreGui remotes in settings"
        emptyLabel.TextColor3 = COLORS.TEXT_MUTED
        emptyLabel.Font = Enum.Font.Gotham
        emptyLabel.TextSize = isMobile and 13 : 15
        emptyLabel.Parent = remoteScrollFrame
    end
    
    playSound(SOUNDS.Success, 0.3)
end

-- Export Function
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
    
    setclipboard(exportText)
    
    -- Success feedback
    animate(exportBtn, {BackgroundColor3 = COLORS.SUCCESS}, ANIM.FAST)
    exportBtn.Text = "✓ Copied!"
    playSound(SOUNDS.Success, 0.3)
    
    wait(1.5)
    animate(exportBtn, {BackgroundColor3 = COLORS.INFO}, ANIM.FAST)
    exportBtn.Text = "📋 Export"
end

-- Button Connections
refreshBtn.MouseButton1Click:Connect(refreshRemoteList)
exportBtn.MouseButton1Click:Connect(exportRemotes)

-- Auto-refresh monitor (if enabled)
spawn(function()
    local lastCount = 0
    
    while wait(5) do
        if autoRefresh and not isHidden then
            local currentRemotes = findAllRemotes()
            
            if #currentRemotes ~= lastCount then
                lastCount = #currentRemotes
                refreshRemoteList()
            end
        end
    end
end)

-- Notification System
local function showNotification(title, message, color, duration)
    local notification = Instance.new("Frame")
    notification.Size = UDim2.new(0, isMobile and 280 : 320, 0, 0)
    notification.Position = UDim2.new(1, isMobile and -290 : -330, 0, isMobile and 80 : 90)
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
    titleLabel.TextSize = isMobile and 13 : 14
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.Parent = notification
    
    local messageLabel = Instance.new("TextLabel")
    messageLabel.Size = UDim2.new(1, -20, 0, 0)
    messageLabel.Position = UDim2.new(0, 10, 0, 32)
    messageLabel.BackgroundTransparency = 1
    messageLabel.Text = message
    messageLabel.TextColor3 = COLORS.TEXT_SECONDARY
    messageLabel.Font = Enum.Font.Gotham
    messageLabel.TextSize = isMobile and 11 : 12
    messageLabel.TextXAlignment = Enum.TextXAlignment.Left
    messageLabel.TextWrapped = true
    messageLabel.AutomaticSize = Enum.AutomaticSize.Y
    messageLabel.Parent = notification
    
    -- Animate in
    animate(notification, {
        Size = UDim2.new(0, isMobile and 280 : 320, 0, messageLabel.AbsoluteSize.Y + 48)
    }, ANIM.BOUNCE)
    
    playSound(SOUNDS.Success, 0.3)
    
    -- Auto dismiss
    task.wait(duration or 3)
    
    animate(notification, {
        Position = UDim2.new(1, 10, 0, isMobile and 80 : 90)
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
        Size = UDim2.new(0, isMobile and 50 : 60, 0, isMobile and 50 : 60)
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
        "🎉 RemoteSpy v5 Loaded!",
        "Professional remote explorer ready. Tap the refresh button to scan for remotes.",
        COLORS.SUCCESS,
        4
    )
end

-- Start
initialize()

-- Clean up on script removal
screenGui.AncestryChanged:Connect(function()
    if not screenGui:IsDescendantOf(game) then
        pcall(function()
            screenGui:Destroy()
        end)
    end
end)



print("✅ RemoteSpy v5 Professional Edition Loaded!")
print("📱 Mobile Optimized | 🎨 Smooth Animations | 🔊 Sound Effects")
print("👨‍💻 Created with ❤️ | Discord: @31hw")