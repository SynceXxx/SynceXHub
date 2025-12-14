-- ============================================================
-- SYNCEHUB PROFESSIONAL LOADING SCREEN (FIXED - PROGRESS BAR ROUNDED)
-- File: loadingscreen.lua
-- ============================================================

local LoadingScreen = {}

function LoadingScreen.Show()
    local Players = game:GetService("Players")
    local TweenService = game:GetService("TweenService")
    local LocalPlayer = Players.LocalPlayer
    local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
    
    -- Create ScreenGui
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "SynceHubLoading"
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    ScreenGui.ResetOnSpawn = false
    ScreenGui.IgnoreGuiInset = true
    ScreenGui.DisplayOrder = 999999
    ScreenGui.Parent = PlayerGui
    
    -- Background TRANSPARAN (tidak pakai image)
    local Background = Instance.new("Frame")
    Background.Name = "Background"
    Background.Size = UDim2.new(1, 0, 1, 0)
    Background.Position = UDim2.new(0, 0, 0, 0)
    Background.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    Background.BackgroundTransparency = 0.5  -- Semi-transparan
    Background.BorderSizePixel = 0
    Background.Parent = ScreenGui
    
    -- Main Loading Container
    local Container = Instance.new("Frame")
    Container.Name = "Container"
    Container.Size = UDim2.new(0, 420, 0, 240)
    Container.Position = UDim2.new(0.5, 0, 0.5, 0)
    Container.AnchorPoint = Vector2.new(0.5, 0.5)
    Container.BackgroundColor3 = Color3.fromRGB(10, 15, 25)
    Container.BorderSizePixel = 0
    Container.ClipsDescendants = true  -- Penting untuk image background
    Container.Parent = Background
    
    -- IMAGE BACKGROUND DI DALAM CONTAINER
    local ContainerBG = Instance.new("ImageLabel")
    ContainerBG.Name = "ContainerBG"
    ContainerBG.Size = UDim2.new(1, 0, 1, 0)
    ContainerBG.Position = UDim2.new(0, 0, 0, 0)
    ContainerBG.BackgroundTransparency = 1
    ContainerBG.Image = "rbxassetid://76050087063551"
    ContainerBG.ScaleType = Enum.ScaleType.Crop
    ContainerBG.ImageTransparency = 0
    ContainerBG.BorderSizePixel = 0
    ContainerBG.ZIndex = 1
    ContainerBG.Parent = Container
    
    -- Rounded corners untuk background image
    local ContainerBGCorner = Instance.new("UICorner")
    ContainerBGCorner.CornerRadius = UDim.new(0, 16)
    ContainerBGCorner.Parent = ContainerBG
    
    -- Dark Overlay di atas image (agar text lebih jelas)
    local Overlay = Instance.new("Frame")
    Overlay.Size = UDim2.new(1, 0, 1, 0)
    Overlay.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    Overlay.BackgroundTransparency = 0.4
    Overlay.BorderSizePixel = 0
    Overlay.ZIndex = 2
    Overlay.Parent = Container
    
    -- Rounded corners untuk overlay
    local OverlayCorner = Instance.new("UICorner")
    OverlayCorner.CornerRadius = UDim.new(0, 16)
    OverlayCorner.Parent = Overlay
    
    -- Rounded Corners
    local ContainerCorner = Instance.new("UICorner")
    ContainerCorner.CornerRadius = UDim.new(0, 16)
    ContainerCorner.Parent = Container
    
    -- Border Glow (Ocean Blue)
    local Stroke = Instance.new("UIStroke")
    Stroke.Color = Color3.fromRGB(0, 128, 128)
    Stroke.Thickness = 2
    Stroke.Transparency = 0.1
    Stroke.Parent = Container
    
    -- Logo Image
    local Logo = Instance.new("ImageLabel")
    Logo.Name = "Logo"
    Logo.Size = UDim2.new(0, 90, 0, 90)
    Logo.Position = UDim2.new(0.5, 0, 0, 30)
    Logo.AnchorPoint = Vector2.new(0.5, 0)
    Logo.BackgroundTransparency = 1
    Logo.Image = "rbxassetid://130348378128532"
    Logo.ScaleType = Enum.ScaleType.Fit
    Logo.ImageTransparency = 1
    Logo.ZIndex = 3
    Logo.Parent = Container
    
    -- Title Text
    local Title = Instance.new("TextLabel")
    Title.Name = "Title"
    Title.Size = UDim2.new(1, -40, 0, 35)
    Title.Position = UDim2.new(0.5, 0, 0, 130)
    Title.AnchorPoint = Vector2.new(0.5, 0)
    Title.BackgroundTransparency = 1
    Title.Text = "SynceHub Universal"
    Title.TextColor3 = Color3.fromRGB(255, 255, 255)
    Title.TextSize = 28
    Title.Font = Enum.Font.GothamBold
    Title.TextTransparency = 1
    Title.ZIndex = 3
    Title.Parent = Container
    
    -- Status Text
    local Status = Instance.new("TextLabel")
    Status.Name = "Status"
    Status.Size = UDim2.new(1, -40, 0, 20)
    Status.Position = UDim2.new(0.5, 0, 0, 170)
    Status.AnchorPoint = Vector2.new(0.5, 0)
    Status.BackgroundTransparency = 1
    Status.Text = "Initializing..."
    Status.TextColor3 = Color3.fromRGB(100, 170, 255)
    Status.TextSize = 14
    Status.Font = Enum.Font.Gotham
    Status.TextTransparency = 1
    Status.ZIndex = 3
    Status.Parent = Container
    
    -- Progress Bar Background (LEBIH PENDEK & ROUNDED)
    local ProgressBG = Instance.new("Frame")
    ProgressBG.Name = "ProgressBG"
    ProgressBG.Size = UDim2.new(0, 360, 0, 6)  -- Fixed width 360px (lebih pendek dari container 420px)
    ProgressBG.Position = UDim2.new(0.5, 0, 1, -30)
    ProgressBG.AnchorPoint = Vector2.new(0.5, 0)
    ProgressBG.BackgroundColor3 = Color3.fromRGB(30, 40, 60)
    ProgressBG.BorderSizePixel = 0
    ProgressBG.BackgroundTransparency = 1
    ProgressBG.ZIndex = 3
    ProgressBG.ClipsDescendants = true  -- PENTING: Bikin rounded corners bekerja!
    ProgressBG.Parent = Container
    
    local ProgressBGCorner = Instance.new("UICorner")
    ProgressBGCorner.CornerRadius = UDim.new(1, 0)  -- Fully rounded
    ProgressBGCorner.Parent = ProgressBG
    
    -- Progress Bar Fill (PUTIH dengan gradient)
    local ProgressFill = Instance.new("Frame")
    ProgressFill.Name = "ProgressFill"
    ProgressFill.Size = UDim2.new(0, 0, 1, 0)
    ProgressFill.BackgroundColor3 = Color3.fromRGB(255, 255, 255)  -- PUTIH
    ProgressFill.BorderSizePixel = 0
    ProgressFill.ZIndex = 4
    ProgressFill.Parent = ProgressBG
    
    -- Rounded corners untuk progress fill
    local ProgressFillCorner = Instance.new("UICorner")
    ProgressFillCorner.CornerRadius = UDim.new(1, 0)  -- Fully rounded
    ProgressFillCorner.Parent = ProgressFill
    
    -- Progress Fill Gradient (Putih ke abu-abu terang)
    local ProgressGradient = Instance.new("UIGradient")
    ProgressGradient.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, Color3.fromRGB(240, 240, 240)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 255, 255))
    }
    ProgressGradient.Parent = ProgressFill
    
    -- ============================================================
    -- SOUND EFFECT
    -- ============================================================
    local Sound = Instance.new("Sound")
    Sound.SoundId = "rbxassetid://6958727243"
    Sound.Volume = 6
    Sound.Parent = ScreenGui
    pcall(function()
        Sound:Play()
    end)
    
    -- ============================================================
    -- ANIMATIONS
    -- ============================================================
    
    -- Initial animation setup
    Container.Size = UDim2.new(0, 0, 0, 0)
    Background.BackgroundTransparency = 1
    
    -- Fade in background
    local bgFadeIn = TweenService:Create(Background, TweenInfo.new(0.3), {
        BackgroundTransparency = 0.5
    })
    bgFadeIn:Play()
    
    -- Tween Info
    local tweenInfo = TweenInfo.new(0.6, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
    local fadeInfo = TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    
    -- Animate Container Pop-in
    local containerTween = TweenService:Create(Container, tweenInfo, {
        Size = UDim2.new(0, 420, 0, 240)
    })
    containerTween:Play()
    
    -- Wait a bit then fade in elements
    task.wait(0.3)
    
    -- Fade in Logo
    local logoTween = TweenService:Create(Logo, fadeInfo, {
        ImageTransparency = 0
    })
    logoTween:Play()
    
    task.wait(0.2)
    
    -- Fade in Title
    local titleTween = TweenService:Create(Title, fadeInfo, {
        TextTransparency = 0
    })
    titleTween:Play()
    
    task.wait(0.1)
    
    -- Fade in Status
    local statusTween = TweenService:Create(Status, fadeInfo, {
        TextTransparency = 0
    })
    statusTween:Play()
    
    task.wait(0.1)
    
    -- Fade in Progress Bar
    local progressBGTween = TweenService:Create(ProgressBG, fadeInfo, {
        BackgroundTransparency = 0
    })
    progressBGTween:Play()
    
    -- ============================================================
    -- LOADING STAGES WITH PROGRESS
    -- ============================================================
    local function UpdateProgress(text, progress, waitTime)
        Status.Text = text
        
        -- Animate progress bar (multiply by 360 since we use fixed width now)
        local targetWidth = 360 * progress  -- Max 360px
        local progressTween = TweenService:Create(ProgressFill, TweenInfo.new(0.3, Enum.EasingStyle.Quad), {
            Size = UDim2.new(0, targetWidth, 1, 0)
        })
        progressTween:Play()
        
        -- Pulse effect on status text
        local pulseTween = TweenService:Create(Status, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, 1, true), {
            TextSize = 15
        })
        pulseTween:Play()
        
        if waitTime then
            task.wait(waitTime)
        end
    end
    
    -- Return object with methods
    return {
        ScreenGui = ScreenGui,
        Container = Container,
        Background = Background,
        Status = Status,
        ProgressFill = ProgressFill,
        UpdateProgress = UpdateProgress,
        
        -- Method to close loading screen SMOOTH
        Close = function(self)
            -- Fade out sound
            if Sound then
                local soundFade = TweenService:Create(Sound, TweenInfo.new(0.5), {Volume = 0})
                soundFade:Play()
            end
            
            -- Fade out progress bar first
            TweenService:Create(ProgressBG, TweenInfo.new(0.2), {BackgroundTransparency = 1}):Play()
            TweenService:Create(ProgressFill, TweenInfo.new(0.2), {BackgroundTransparency = 1}):Play()
            
            task.wait(0.1)
            
            -- Fade out text elements
            TweenService:Create(Status, TweenInfo.new(0.3), {TextTransparency = 1}):Play()
            task.wait(0.1)
            TweenService:Create(Title, TweenInfo.new(0.3), {TextTransparency = 1}):Play()
            task.wait(0.1)
            TweenService:Create(Logo, TweenInfo.new(0.3), {ImageTransparency = 1}):Play()
            
            task.wait(0.2)
            
            -- Shrink container dengan fade
            TweenService:Create(Overlay, TweenInfo.new(0.3), {BackgroundTransparency = 1}):Play()
            TweenService:Create(ContainerBG, TweenInfo.new(0.3), {ImageTransparency = 1}):Play()
            
            local closeTween = TweenService:Create(Container, TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.In), {
                Size = UDim2.new(0, 0, 0, 0)
            })
            closeTween:Play()
            closeTween.Completed:Wait()
            
            -- Fade out background transparan
            local bgFadeOut = TweenService:Create(Background, TweenInfo.new(0.3), {
                BackgroundTransparency = 1
            })
            bgFadeOut:Play()
            bgFadeOut.Completed:Wait()
            
            -- Destroy
            if Sound then Sound:Stop() end
            ScreenGui:Destroy()
        end
    }
end

return LoadingScreen