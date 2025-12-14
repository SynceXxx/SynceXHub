-- RemoteSpy v5 UI
-- Modern remote explorer for Roblox with orange/black theme

-- Services
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")

-- Color palette
local COLORS = {
    ORANGE = Color3.fromRGB(255, 140, 0),
    DARK_BLACK = Color3.fromRGB(20, 20, 20),
    MEDIUM_BLACK = Color3.fromRGB(30, 30, 30),
    LIGHT_BLACK = Color3.fromRGB(40, 40, 40),
    WHITE = Color3.fromRGB(255, 255, 255),
    DARK_ORANGE = Color3.fromRGB(200, 100, 0),
}

-- Main GUI setup
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "RemoteSpyV5"
screenGui.Parent = game.CoreGui

-- Main window
local mainWindow = Instance.new("Frame")
mainWindow.Size = UDim2.new(0, 800, 0, 600)
mainWindow.Position = UDim2.new(0.5, -400, 0.5, -300)
mainWindow.BackgroundColor3 = COLORS.DARK_BLACK
mainWindow.BorderSizePixel = 0
mainWindow.Active = true
mainWindow.Draggable = true
mainWindow.Parent = screenGui

-- Window border
local windowBorder = Instance.new("Frame")
windowBorder.Size = UDim2.new(1, 8, 1, 8)
windowBorder.Position = UDim2.new(0, -4, 0, -4)
windowBorder.BackgroundColor3 = COLORS.ORANGE
windowBorder.BorderSizePixel = 0
windowBorder.ZIndex = 0
windowBorder.Parent = mainWindow

-- Title bar
local titleBar = Instance.new("Frame")
titleBar.Size = UDim2.new(1, 0, 0, 60)
titleBar.Position = UDim2.new(0, 0, 0, 0)
titleBar.BackgroundColor3 = COLORS.ORANGE
titleBar.BorderSizePixel = 0
titleBar.Parent = mainWindow

-- Title text
local titleLabel = Instance.new("TextLabel")
titleLabel.Size = UDim2.new(1, -160, 1, 0)
titleLabel.Position = UDim2.new(0, 0, 0, 0)
titleLabel.BackgroundTransparency = 1
titleLabel.Text = "RemoteSpy v5"
titleLabel.TextColor3 = COLORS.WHITE
titleLabel.Font = Enum.Font.GothamBlack
titleLabel.TextSize = 40
titleLabel.Parent = titleBar

-- Close button
local closeButton = Instance.new("TextButton")
closeButton.Size = UDim2.new(0, 50, 0, 40)
closeButton.Position = UDim2.new(1, -55, 0, 10)
closeButton.BackgroundColor3 = COLORS.DARK_ORANGE
closeButton.Text = "X"
closeButton.TextColor3 = COLORS.WHITE
closeButton.Font = Enum.Font.GothamBlack
closeButton.TextSize = 28
closeButton.BorderSizePixel = 0
closeButton.Parent = titleBar

-- Minimize button
local minimizeButton = Instance.new("TextButton")
minimizeButton.Size = UDim2.new(0, 80, 0, 40)
minimizeButton.Position = UDim2.new(1, -145, 0, 10)
minimizeButton.BackgroundColor3 = COLORS.DARK_ORANGE
minimizeButton.Text = "-"
minimizeButton.TextColor3 = COLORS.WHITE
minimizeButton.Font = Enum.Font.GothamBlack
minimizeButton.TextSize = 36
minimizeButton.BorderSizePixel = 0
minimizeButton.Parent = titleBar

-- Subtitle
local subtitleLabel = Instance.new("TextLabel")
subtitleLabel.Size = UDim2.new(1, 0, 0, 30)
subtitleLabel.Position = UDim2.new(0, 0, 0, 60)
subtitleLabel.BackgroundTransparency = 1
subtitleLabel.Text = "A modern remote explorer for Roblox"
subtitleLabel.TextColor3 = COLORS.ORANGE
subtitleLabel.Font = Enum.Font.Gotham
subtitleLabel.TextSize = 20
subtitleLabel.Parent = mainWindow

-- Top buttons
local topButtonNames = {"Refresh", "Settings", "Export", "Help", "About"}
local topButtons = {}

for index, buttonName in ipairs(topButtonNames) do
    local button = Instance.new("TextButton")
    button.Size = UDim2.new(0, 120, 0, 36)
    button.Position = UDim2.new(0, 20 + (index - 1) * 130, 0, 100)
    button.BackgroundColor3 = COLORS.ORANGE
    button.Text = buttonName
    button.TextColor3 = COLORS.WHITE
    button.Font = Enum.Font.GothamBold
    button.TextSize = 20
    button.BorderSizePixel = 0
    button.Parent = mainWindow
    
    topButtons[buttonName] = button
end

-- Status label
local statusLabel = Instance.new("TextLabel")
statusLabel.Size = UDim2.new(1, -40, 0, 30)
statusLabel.Position = UDim2.new(0, 20, 0, 150)
statusLabel.BackgroundTransparency = 1
statusLabel.Text = "Remotes found in this game. Click a button to interact."
statusLabel.TextColor3 = COLORS.ORANGE
statusLabel.Font = Enum.Font.Gotham
statusLabel.TextSize = 18
statusLabel.TextXAlignment = Enum.TextXAlignment.Left
statusLabel.Parent = mainWindow

-- Remote list container
local remoteListFrame = Instance.new("ScrollingFrame")
remoteListFrame.Size = UDim2.new(1, -40, 1, -220)
remoteListFrame.Position = UDim2.new(0, 20, 0, 190)
remoteListFrame.BackgroundColor3 = COLORS.MEDIUM_BLACK
remoteListFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
remoteListFrame.ScrollBarThickness = 10
remoteListFrame.BorderSizePixel = 0
remoteListFrame.Parent = mainWindow

-- Settings window
local settingsWindow = Instance.new("Frame")
settingsWindow.Size = UDim2.new(0, 350, 0, 300)
settingsWindow.Position = UDim2.new(0.5, -175, 0.5, -150)
settingsWindow.BackgroundColor3 = COLORS.MEDIUM_BLACK
settingsWindow.Visible = false
settingsWindow.Parent = screenGui
settingsWindow.BorderSizePixel = 0

-- Settings title bar
local settingsTitleBar = Instance.new("TextLabel")
settingsTitleBar.Size = UDim2.new(1, 0, 0, 50)
settingsTitleBar.BackgroundColor3 = COLORS.ORANGE
settingsTitleBar.Text = "Settings"
settingsTitleBar.TextColor3 = COLORS.WHITE
settingsTitleBar.Font = Enum.Font.GothamBlack
settingsTitleBar.TextSize = 28
settingsTitleBar.Parent = settingsWindow

-- State variables
local includeCoreGuiRemotes = false
local isMinimized = false
local isDraggingMainWindow = false
local isDraggingSettingsWindow = false
local isResizing = false
local scanningSpeed = 0.1
local isScanning = false
local cachedRemotes = {}

-- Drag handling for main window
local dragStartPosition
local dragStartOffset

titleBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        isDraggingMainWindow = true
        dragStartPosition = input.Position
        dragStartOffset = mainWindow.Position
        
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                isDraggingMainWindow = false
            end
        end)
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if isDraggingMainWindow and input.UserInputType == Enum.UserInputType.MouseMovement then
        local delta = input.Position - dragStartPosition
        mainWindow.Position = UDim2.new(
            dragStartOffset.X.Scale,
            dragStartOffset.X.Offset + delta.X,
            dragStartOffset.Y.Scale,
            dragStartOffset.Y.Offset + delta.Y
        )
    end
end)

-- Drag handling for settings window
local settingsDragStartPosition
local settingsDragStartOffset

settingsTitleBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        isDraggingSettingsWindow = true
        settingsDragStartPosition = input.Position
        settingsDragStartOffset = settingsWindow.Position
        
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                isDraggingSettingsWindow = false
            end
        end)
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if isDraggingSettingsWindow and input.UserInputType == Enum.UserInputType.MouseMovement then
        local delta = input.Position - settingsDragStartPosition
        settingsWindow.Position = UDim2.new(
            settingsDragStartOffset.X.Scale,
            settingsDragStartOffset.X.Offset + delta.X,
            settingsDragStartOffset.Y.Scale,
            settingsDragStartOffset.Y.Offset + delta.Y
        )
    end
end)

-- Create remote entry UI
local function createRemoteEntry(remote, path)
    local entryFrame = Instance.new("Frame")
    entryFrame.Size = UDim2.new(1, 0, 0, 70)
    entryFrame.BackgroundColor3 = COLORS.LIGHT_BLACK
    entryFrame.BorderSizePixel = 0
    
    -- Remote name
    local nameLabel = Instance.new("TextLabel")
    nameLabel.Size = UDim2.new(1, -220, 0, 28)
    nameLabel.Position = UDim2.new(0, 10, 0, 6)
    nameLabel.BackgroundTransparency = 1
    nameLabel.Text = "[" .. remote.ClassName .. "] " .. remote.Name
    nameLabel.TextColor3 = COLORS.ORANGE
    nameLabel.Font = Enum.Font.GothamBold
    nameLabel.TextSize = 20
    nameLabel.TextXAlignment = Enum.TextXAlignment.Left
    nameLabel.Parent = entryFrame
    
    -- Path
    local pathLabel = Instance.new("TextLabel")
    pathLabel.Size = UDim2.new(1, -220, 0, 22)
    pathLabel.Position = UDim2.new(0, 10, 0, 36)
    pathLabel.BackgroundTransparency = 1
    pathLabel.Text = path
    pathLabel.TextColor3 = COLORS.WHITE
    pathLabel.Font = Enum.Font.Gotham
    pathLabel.TextSize = 15
    pathLabel.TextXAlignment = Enum.TextXAlignment.Left
    pathLabel.Parent = entryFrame
    
    -- Fire button
    local fireButton = Instance.new("TextButton")
    fireButton.Size = UDim2.new(0, 60, 0, 28)
    fireButton.Position = UDim2.new(1, -200, 0, 21)
    fireButton.BackgroundColor3 = COLORS.ORANGE
    fireButton.Text = "Fire"
    fireButton.TextColor3 = COLORS.WHITE
    fireButton.Font = Enum.Font.GothamBold
    fireButton.TextSize = 15
    fireButton.BorderSizePixel = 0
    fireButton.Parent = entryFrame
    
    -- Copy button
    local copyButton = Instance.new("TextButton")
    copyButton.Size = UDim2.new(0, 60, 0, 28)
    copyButton.Position = UDim2.new(1, -135, 0, 21)
    copyButton.BackgroundColor3 = COLORS.ORANGE
    copyButton.Text = "Copy"
    copyButton.TextColor3 = COLORS.WHITE
    copyButton.Font = Enum.Font.GothamBold
    copyButton.TextSize = 15
    copyButton.BorderSizePixel = 0
    copyButton.Parent = entryFrame
    
    -- Info button
    local infoButton = Instance.new("TextButton")
    infoButton.Size = UDim2.new(0, 60, 0, 28)
    infoButton.Position = UDim2.new(1, -70, 0, 21)
    infoButton.BackgroundColor3 = COLORS.DARK_BLACK
    infoButton.Text = "Info"
    infoButton.TextColor3 = COLORS.ORANGE
    infoButton.Font = Enum.Font.Gotham
    infoButton.TextSize = 15
    infoButton.BorderSizePixel = 0
    infoButton.Parent = entryFrame
    
    -- Button actions
    fireButton.MouseButton1Click:Connect(function()
        if remote:IsA("RemoteEvent") then
            remote:FireServer()
        elseif remote:IsA("RemoteFunction") then
            pcall(function()
                remote:InvokeServer()
            end)
        end
    end)
    
    copyButton.MouseButton1Click:Connect(function()
        setclipboard(path)
    end)
    
    infoButton.MouseButton1Click:Connect(function()
        statusLabel.Text = "[" .. remote.ClassName .. "] " .. remote.Name .. " | Path: " .. path
    end)
    
    return entryFrame
end

-- Find all remotes recursively
local function findAllRemotes()
    local foundRemotes = {}
    
    local function searchRecursive(parent, currentPath)
        for _, child in ipairs(parent:GetChildren()) do
            local childPath = currentPath .. "." .. child.Name
            local isCoreGui = child == game:GetService("CoreGui")
            local isRobloxReplicatedStorage = child == game:GetService("RobloxReplicatedStorage")
            
            -- Check if this is a remote
            if (child:IsA("RemoteEvent") or child:IsA("RemoteFunction")) and
               (includeCoreGuiRemotes or (not isCoreGui and not isRobloxReplicatedStorage)) then
                table.insert(foundRemotes, {
                    remote = child,
                    path = childPath,
                })
            end
            
            -- Continue searching
            if includeCoreGuiRemotes or (not isCoreGui and not isRobloxReplicatedStorage) then
                searchRecursive(child, childPath)
            end
        end
    end
    
    searchRecursive(game, "game")
    return foundRemotes
end

-- Refresh the remote list
local function refreshRemoteList()
    if isScanning then
        isScanning = false
        task.wait(0.1)
    end
    
    remoteListFrame:ClearAllChildren()
    cachedRemotes = findAllRemotes()
    
    local yPosition = 0
    for _, remoteData in ipairs(cachedRemotes) do
        local entry = createRemoteEntry(remoteData.remote, remoteData.path)
        entry.Position = UDim2.new(0, 0, 0, yPosition)
        entry.Parent = remoteListFrame
        yPosition += 65
    end
    
    remoteListFrame.CanvasSize = UDim2.new(0, 0, 0, yPosition)
    statusLabel.Text = "Remotes found: " .. #cachedRemotes
end

-- Export all remotes to clipboard
local function exportRemotes()
    local exportText = ""
    
    for _, remoteData in ipairs(cachedRemotes) do
        exportText ..= remoteData.remote.ClassName .. ": " .. remoteData.path .. "\n"
    end
    
    setclipboard(exportText)
    statusLabel.Text = "Exported all remote paths to clipboard!"
end

-- Initialize settings window controls
local includeCoreGuiButton = Instance.new("TextButton")
includeCoreGuiButton.Size = UDim2.new(1, -40, 0, 40)
includeCoreGuiButton.Position = UDim2.new(0, 20, 0, 70)
includeCoreGuiButton.BackgroundColor3 = includeCoreGuiRemotes and COLORS.ORANGE or COLORS.LIGHT_BLACK
includeCoreGuiButton.Text = "Include CoreGui remotes: " .. (includeCoreGuiRemotes and "YES" or "NO")
includeCoreGuiButton.TextColor3 = COLORS.WHITE
includeCoreGuiButton.Font = Enum.Font.GothamBold
includeCoreGuiButton.TextSize = 18
includeCoreGuiButton.BorderSizePixel = 0
includeCoreGuiButton.Parent = settingsWindow

-- Speed control
local speedLabel = Instance.new("TextLabel")
speedLabel.Size = UDim2.new(1, -40, 0, 24)
speedLabel.Position = UDim2.new(0, 20, 0, 170)
speedLabel.BackgroundTransparency = 1
speedLabel.Text = "Scanning Speed: " .. string.format("%.3f", scanningSpeed)
speedLabel.TextColor3 = COLORS.ORANGE
speedLabel.Font = Enum.Font.GothamBold
speedLabel.TextSize = 16
speedLabel.TextXAlignment = Enum.TextXAlignment.Left
speedLabel.Parent = settingsWindow

local speedTrack = Instance.new("Frame")
speedTrack.Size = UDim2.new(1, -40, 0, 8)
speedTrack.Position = UDim2.new(0, 20, 0, 200)
speedTrack.BackgroundColor3 = COLORS.LIGHT_BLACK
speedTrack.BorderSizePixel = 0
speedTrack.Parent = settingsWindow

local speedHandle = Instance.new("Frame")
speedHandle.Size = UDim2.new(0, 16, 0, 24)
speedHandle.Position = UDim2.new((scanningSpeed - 0.01) / 0.99, -8, 0, 192)
speedHandle.BackgroundColor3 = COLORS.ORANGE
speedHandle.BorderSizePixel = 0
speedHandle.Parent = settingsWindow
speedHandle.ZIndex = 2
speedHandle.Active = true

-- Close settings button
local closeSettingsButton = Instance.new("TextButton")
closeSettingsButton.Size = UDim2.new(1, -40, 0, 40)
closeSettingsButton.Position = UDim2.new(0, 20, 0, 220)
closeSettingsButton.BackgroundColor3 = COLORS.ORANGE
closeSettingsButton.Text = "Close"
closeSettingsButton.TextColor3 = COLORS.WHITE
closeSettingsButton.Font = Enum.Font.GothamBold
closeSettingsButton.TextSize = 20
closeSettingsButton.BorderSizePixel = 0
closeSettingsButton.Parent = settingsWindow

-- Speed slider functionality
local isDraggingSpeed = false

local function updateSpeedDisplay()
    speedHandle.Position = UDim2.new((scanningSpeed - 0.01) / 0.99, -8, 0, 192)
    speedLabel.Text = "Scanning Speed: " .. string.format("%.3f", scanningSpeed)
end

speedHandle.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        isDraggingSpeed = true
    end
end)

speedHandle.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        isDraggingSpeed = false
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if isDraggingSpeed and input.UserInputType == Enum.UserInputType.MouseMovement then
        local relativeX = (input.Position.X - speedTrack.AbsolutePosition.X) / speedTrack.AbsoluteSize.X
        relativeX = math.clamp(relativeX, 0, 1)
        scanningSpeed = math.floor((0.01 + relativeX * 0.99) * 1000) / 1000
        updateSpeedDisplay()
    end
end)

-- Minimize/restore functionality
local function toggleMinimize()
    if isResizing then return end
    
    isMinimized = not isMinimized
    isResizing = true
    
    subtitleLabel.Visible = not isMinimized
    
    for _, child in pairs(mainWindow:GetChildren()) do
        if child ~= titleBar and child ~= windowBorder then
            child.Visible = not isMinimized
        end
    end
    
    local targetSize = isMinimized and UDim2.new(0, 800, 0, 60) or UDim2.new(0, 800, 0, 600)
    local startSize = mainWindow.Size
    local duration = 30
    
    for frame = 1, duration do
        if not isResizing then return end
        
        local progress = frame / duration
        mainWindow.Size = UDim2.new(
            startSize.X.Scale + (targetSize.X.Scale - startSize.X.Scale) * progress,
            startSize.X.Offset + (targetSize.X.Offset - startSize.X.Offset) * progress,
            startSize.Y.Scale + (targetSize.Y.Scale - startSize.Y.Scale) * progress,
            startSize.Y.Offset + (targetSize.Y.Offset - startSize.Y.Offset) * progress
        )
        task.wait(0.0008)
    end
    
    mainWindow.Size = targetSize
    isResizing = false
end

-- Button event connections
topButtons.Refresh.MouseButton1Click:Connect(refreshRemoteList)

topButtons.Export.MouseButton1Click:Connect(exportRemotes)

topButtons.Help.MouseButton1Click:Connect(function()
    statusLabel.Text = "Click 'Fire' to trigger a remote, 'Copy' to copy its path, 'Export' to copy all paths."
end)

topButtons.About.MouseButton1Click:Connect(function()
    statusLabel.Text = "RemoteSpy v5 | Orange/Black Theme | 2025 | @31hw on discord"
end)

topButtons.Settings.MouseButton1Click:Connect(function()
    settingsWindow.Visible = not settingsWindow.Visible
end)

includeCoreGuiButton.MouseButton1Click:Connect(function()
    includeCoreGuiRemotes = not includeCoreGuiRemotes
    includeCoreGuiButton.BackgroundColor3 = includeCoreGuiRemotes and COLORS.ORANGE or COLORS.LIGHT_BLACK
    includeCoreGuiButton.Text = "Include CoreGui remotes: " .. (includeCoreGuiRemotes and "YES" or "NO")
    refreshRemoteList()
end)

closeSettingsButton.MouseButton1Click:Connect(function()
    settingsWindow.Visible = false
end)

minimizeButton.MouseButton1Click:Connect(toggleMinimize)

closeButton.MouseButton1Click:Connect(function()
    screenGui:Destroy()
    if script and script.Parent then
        pcall(function()
            script:Destroy()
        end)
    end
end)

-- Set z-index for settings window
settingsWindow.ZIndex = 1000
for _, child in ipairs(settingsWindow:GetChildren()) do
    if child:IsA("GuiObject") then
        child.ZIndex = 1001
    end
end

-- Initialize
updateSpeedDisplay()
refreshRemoteList()