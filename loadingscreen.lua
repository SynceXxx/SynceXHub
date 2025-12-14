-- ============================================================
-- SYNCEHUB PROFESSIONAL LOADING SCREEN (FIXED)
-- File: loadingscreen.lua
-- Upload file ini ke GitHub dengan nama: loadingscreen.lua
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
    
    -- Background with Image
    local Background = Instance.new("ImageLabel")
    Background.Name = "Background"
    Background.Size = UDim2.new(1, 0, 1, 0)
    Background.Position = UDim2.new(0, 0, 0, 0)
    Background.BackgroundTransparency = 1
    Background.Image = "rbxassetid://76050087063551"
    Background.ScaleType = Enum.ScaleType.Crop
    Background.ImageTransparency = 0
    Background.BorderSizePixel = 0
    Background.Parent = ScreenGui
    
    -- Dark Overlay for better contrast
    local Overlay = Instance.new("Frame")
    Overlay.Size = UDim2.new(1, 0, 1, 0)
    Overlay.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    Overlay.BackgroundTransparency = 0.4
    Overlay.BorderSizePixel = 0
    Overlay.Parent = Background
    
    -- Main Loading Container (Small & Centered)
    local Container = Instance.new("Frame")
    Container.Name = "Container"
    Container.Size = UDim2.new(0, 380, 0, 180)
    Container.Position = UDim2.new(0.5, 0, 0.5, 0)
    Container.AnchorPoint = Vector2.new(0.5, 0.5)
    Container.BackgroundColor3 = Color3.fromRGB(10, 15, 25)
    Container.BorderSizePixel = 0
    Container.ClipsDescendants = false
    Container.Parent = Background
    
    -- Rounded Corners (UICorner)
    local ContainerCorner = Instance.new("UICorner")
    ContainerCorner.CornerRadius = UDim.new(0, 16)
    ContainerCorner.Parent = Container
    
    -- Ocean Blue Gradient Background
    local Gradient = Instance.new("UIGradient")
    Gradient.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, Color3.fromRGB(15, 35, 65)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(10, 25, 50))
    }
    Gradient.Rotation = 45
    Gradient.Parent = Container
    
    -- Ocean Blue Glow Effect (UIStroke)
    local Stroke = Instance.new("UIStroke")
    Stroke.Color = Color3.fromRGB(30, 100, 180)
    Stroke.Thickness = 2
    Stroke.Transparency = 0.3
    Stroke.Parent = Container
    
    -- Logo Image (No Rotation)
    local Logo = Instance.new("ImageLabel")
    Logo.Name = "Logo"
    Logo.Size = UDim2.new(0, 70, 0, 70)
    Logo.Position = UDim2.new(0.5, 0, 0, 20)
    Logo.AnchorPoint = Vector2.new(0.5, 0)
    Logo.BackgroundTransparency = 1
    Logo.Image = "rbxassetid://130348378128532"
    Logo.ScaleType = Enum.ScaleType.Fit
    Logo.ImageTransparency = 1
    Logo.Parent = Container
    
    -- Title Text
    local Title = Instance.new("TextLabel")
    Title.Name = "Title"
    Title.Size = UDim2.new(1, -40, 0, 30)
    Title.Position = UDim2.new(0.5, 0, 0, 100)
    Title.AnchorPoint = Vector2.new(0.5, 0)
    Title.BackgroundTransparency = 1
    Title.Text = "SynceHub"
    Title.TextColor3 = Color3.fromRGB(255, 255, 255)
    Title.TextSize = 24
    Title.Font = Enum.Font.GothamBold
    Title.TextTransparency = 1
    Title.Parent = Container
    
    -- Status Text
    local Status = Instance.new("TextLabel")
    Status.Name = "Status"
    Status.Size = UDim2.new(1, -40, 0, 20)
    Status.Position = UDim2.new(0.5, 0, 0, 135)
    Status.AnchorPoint = Vector2.new(0.5, 0)
    Status.BackgroundTransparency = 1
    Status.Text = "Initializing..."
    Status.TextColor3 = Color3.fromRGB(100, 170, 255)
    Status.TextSize = 14
    Status.Font = Enum.Font.Gotham
    Status.TextTransparency = 1
    Status.Parent = Container
    
    -- Progress Bar Background
    local ProgressBG = Instance.new("Frame")
    ProgressBG.Name = "ProgressBG"
    ProgressBG.Size = UDim2.new(1, -60, 0, 4)
    ProgressBG.Position = UDim2.new(0.5, 0, 1, -20)
    ProgressBG.AnchorPoint = Vector2.new(0.5, 0)
    ProgressBG.BackgroundColor3 = Color3.fromRGB(20, 40, 70)
    ProgressBG.BorderSizePixel = 0
    ProgressBG.BackgroundTransparency = 1
    ProgressBG.Parent = Container
    
    local ProgressBGCorner = Instance.new("UICorner")
    ProgressBGCorner.CornerRadius = UDim.new(1, 0)
    ProgressBGCorner.Parent = ProgressBG
    
    -- Progress Bar Fill (Ocean Blue)
    local ProgressFill = Instance.new("Frame")
    ProgressFill.Name = "ProgressFill"
    ProgressFill.Size = UDim2.new(0, 0, 1, 0)
    ProgressFill.BackgroundColor3 = Color3.fromRGB(30, 100, 180)
    ProgressFill.BorderSizePixel = 0
    ProgressFill.Parent = ProgressBG
    
    local ProgressFillCorner = Instance.new("UICorner")
    ProgressFillCorner.CornerRadius = UDim.new(1, 0)
    ProgressFillCorner.Parent = ProgressFill
    
    -- Progress Fill Gradient (Ocean Blue)
    local ProgressGradient = Instance.new("UIGradient")
    ProgressGradient.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, Color3.fromRGB(25, 80, 160)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(50, 130, 220))
    }
    ProgressGradient.Parent = ProgressFill
    
    -- ============================================================
    -- SOUND EFFECT
    -- ============================================================
    local Sound = Instance.new("Sound")
    Sound.SoundId = "rbxassetid://6958727243"
    Sound.Volume = 0.3
    Sound.Parent = ScreenGui
    pcall(function()
        Sound:Play()
    end)
    
    -- ============================================================
    -- ANIMATIONS (NO ROTATION, NO PARTICLES)
    -- ============================================================
    
    -- Initial animation setup
    Container.Size = UDim2.new(0, 0, 0, 0)
    
    -- Tween Info
    local tweenInfo = TweenInfo.new(0.6, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
    local fadeInfo = TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    
    -- Animate Container Pop-in
    local containerTween = TweenService:Create(Container, tweenInfo, {
        Size = UDim2.new(0, 380, 0, 180)
    })
    containerTween:Play()
    
    -- Wait a bit then fade in elements
    task.wait(0.3)
    
    -- Fade in Logo (NO ROTATION)
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
    -- LOADING STAGES WITH PROGRESS (FIXED)
    -- ============================================================
    local function UpdateProgress(text, progress, waitTime)
        Status.Text = text
        
        -- Animate progress bar
        local progressTween = TweenService:Create(ProgressFill, TweenInfo.new(0.3, Enum.EasingStyle.Quad), {
            Size = UDim2.new(progress, 0, 1, 0)
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
        Status = Status,
        ProgressFill = ProgressFill,
        UpdateProgress = UpdateProgress,
        
        -- Method to close loading screen
        Close = function(self)
            -- Fade out sound
            if Sound then
                local soundFade = TweenService:Create(Sound, TweenInfo.new(0.5), {Volume = 0})
                soundFade:Play()
                soundFade.Completed:Wait()
                Sound:Stop()
            end
            
            -- Fade out elements
            TweenService:Create(Logo, fadeInfo, {ImageTransparency = 1}):Play()
            TweenService:Create(Title, fadeInfo, {TextTransparency = 1}):Play()
            TweenService:Create(Status, fadeInfo, {TextTransparency = 1}):Play()
            TweenService:Create(ProgressBG, fadeInfo, {BackgroundTransparency = 1}):Play()
            
            task.wait(0.2)
            
            -- Shrink container
            local closeTween = TweenService:Create(Container, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.In), {
                Size = UDim2.new(0, 0, 0, 0)
            })
            closeTween:Play()
            closeTween.Completed:Wait()
            
            -- Fade out background
            local bgFade = TweenService:Create(Background, fadeInfo, {ImageTransparency = 1})
            bgFade:Play()
            bgFade.Completed:Wait()
            
            -- Destroy
            ScreenGui:Destroy()
        end
    }
end

return LoadingScreen