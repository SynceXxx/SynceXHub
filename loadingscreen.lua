-- ============================================================
-- SYNCEHUB PROFESSIONAL LOADING SCREEN
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
    
    -- Background Overlay (Semi-transparent)
    local Background = Instance.new("Frame")
    Background.Name = "Background"
    Background.Size = UDim2.new(1, 0, 1, 0)
    Background.Position = UDim2.new(0, 0, 0, 0)
    Background.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    Background.BackgroundTransparency = 0.3
    Background.BorderSizePixel = 0
    Background.Parent = ScreenGui
    
    -- Main Loading Container (Small & Centered)
    local Container = Instance.new("Frame")
    Container.Name = "Container"
    Container.Size = UDim2.new(0, 380, 0, 180)
    Container.Position = UDim2.new(0.5, 0, 0.5, 0)
    Container.AnchorPoint = Vector2.new(0.5, 0.5)
    Container.BackgroundColor3 = Color3.fromRGB(18, 24, 38)
    Container.BorderSizePixel = 0
    Container.ClipsDescendants = false
    Container.Parent = Background
    
    -- Rounded Corners (UICorner)
    local ContainerCorner = Instance.new("UICorner")
    ContainerCorner.CornerRadius = UDim.new(0, 16)
    ContainerCorner.Parent = Container
    
    -- Gradient Background
    local Gradient = Instance.new("UIGradient")
    Gradient.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, Color3.fromRGB(25, 35, 55)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(15, 20, 35))
    }
    Gradient.Rotation = 45
    Gradient.Parent = Container
    
    -- Glow Effect (UIStroke)
    local Stroke = Instance.new("UIStroke")
    Stroke.Color = Color3.fromRGB(100, 150, 255)
    Stroke.Thickness = 2
    Stroke.Transparency = 0.5
    Stroke.Parent = Container
    
    -- Logo Image (Your Logo - Transparent)
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
    Status.TextColor3 = Color3.fromRGB(150, 180, 255)
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
    ProgressBG.BackgroundColor3 = Color3.fromRGB(30, 40, 60)
    ProgressBG.BorderSizePixel = 0
    ProgressBG.BackgroundTransparency = 1
    ProgressBG.Parent = Container
    
    local ProgressBGCorner = Instance.new("UICorner")
    ProgressBGCorner.CornerRadius = UDim.new(1, 0)
    ProgressBGCorner.Parent = ProgressBG
    
    -- Progress Bar Fill
    local ProgressFill = Instance.new("Frame")
    ProgressFill.Name = "ProgressFill"
    ProgressFill.Size = UDim2.new(0, 0, 1, 0)
    ProgressFill.BackgroundColor3 = Color3.fromRGB(100, 150, 255)
    ProgressFill.BorderSizePixel = 0
    ProgressFill.Parent = ProgressBG
    
    local ProgressFillCorner = Instance.new("UICorner")
    ProgressFillCorner.CornerRadius = UDim.new(1, 0)
    ProgressFillCorner.Parent = ProgressFill
    
    -- Progress Fill Gradient
    local ProgressGradient = Instance.new("UIGradient")
    ProgressGradient.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, Color3.fromRGB(80, 120, 255)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(120, 180, 255))
    }
    ProgressGradient.Parent = ProgressFill
    
    -- ============================================================
    -- PARTICLE EFFECTS (Flying Particles)
    -- ============================================================
    local function CreateParticle()
        local Particle = Instance.new("Frame")
        Particle.Size = UDim2.new(0, math.random(3, 6), 0, math.random(3, 6))
        Particle.Position = UDim2.new(math.random(0, 100) / 100, 0, math.random(0, 100) / 100, 0)
        Particle.BackgroundColor3 = Color3.fromRGB(100, 150, 255)
        Particle.BackgroundTransparency = math.random(50, 80) / 100
        Particle.BorderSizePixel = 0
        Particle.Parent = Container
        
        local ParticleCorner = Instance.new("UICorner")
        ParticleCorner.CornerRadius = UDim.new(1, 0)
        ParticleCorner.Parent = Particle
        
        -- Animate particle floating
        local animTime = math.random(20, 40) / 10
        local tweenInfo = TweenInfo.new(animTime, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut, -1, true)
        local tween = TweenService:Create(Particle, tweenInfo, {
            Position = UDim2.new(
                Particle.Position.X.Scale + math.random(-20, 20) / 100,
                0,
                Particle.Position.Y.Scale + math.random(-20, 20) / 100,
                0
            ),
            BackgroundTransparency = 0.9
        })
        tween:Play()
        
        return Particle
    end
    
    -- Create multiple particles
    local particles = {}
    for i = 1, 15 do
        table.insert(particles, CreateParticle())
    end
    
    -- ============================================================
    -- SOUND EFFECT
    -- ============================================================
    local Sound = Instance.new("Sound")
    Sound.SoundId = "rbxassetid://6958727243" -- Smooth UI sound
    Sound.Volume = 0.3
    Sound.Parent = ScreenGui
    pcall(function()
        Sound:Play()
    end)
    
    -- ============================================================
    -- ANIMATIONS
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
    
    -- Fade in Logo
    local logoTween = TweenService:Create(Logo, fadeInfo, {
        ImageTransparency = 0
    })
    logoTween:Play()
    
    -- Rotate Logo animation (continuous)
    local rotateInfo = TweenInfo.new(3, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut, -1)
    spawn(function()
        while Container.Parent do
            local rotateTween = TweenService:Create(Logo, rotateInfo, {
                Rotation = 360
            })
            rotateTween:Play()
            rotateTween.Completed:Wait()
            Logo.Rotation = 0
        end
    end)
    
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
    local stages = {
        {text = "Initializing...", progress = 0.15, wait = 0.3},
        {text = "Loading WindUI Library...", progress = 0.35, wait = 0.4},
        {text = "Setting up features...", progress = 0.55, wait = 0.3},
        {text = "Loading configurations...", progress = 0.75, wait = 0.3},
        {text = "Creating interface...", progress = 0.90, wait = 0.3},
        {text = "Finalizing...", progress = 1.0, wait = 0.2},
    }
    
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
        
        task.wait(waitTime)
    end
    
    -- Return object with methods
    return {
        ScreenGui = ScreenGui,
        Container = Container,
        Status = Status,
        ProgressFill = ProgressFill,
        Stages = stages,
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
            local bgFade = TweenService:Create(Background, fadeInfo, {BackgroundTransparency = 1})
            bgFade:Play()
            bgFade.Completed:Wait()
            
            -- Destroy
            ScreenGui:Destroy()
        end
    }
end

return LoadingScreen