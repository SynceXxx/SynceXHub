local FeatureModule = {}

function FeatureModule.Init(Window, Reg, WindUI, LocalPlayer)
    -- Export to global scope for tab-content access
    _G.SynceHub = {
        Window = Window,
        Reg = Reg,
        WindUI = WindUI,
        LocalPlayer = LocalPlayer,
        
        -- Services
        RepStorage = game:GetService("ReplicatedStorage"),
        Players = game:GetService("Players"),
        TeleportService = game:GetService("TeleportService"),
        VirtualInputManager = game:GetService("VirtualInputManager"),
        UserInputService = game:GetService("UserInputService"),
        RunService = game:GetService("RunService"),
        HttpService = game:GetService("HttpService"),
        StarterGui = game:GetService("StarterGui"),
        
        -- Paths
        RPath = {"Packages", "_Index", "sleitnick_net@0.2.0", "net"},
        
        -- Player Constants
        DEFAULT_SPEED = 16,
        DEFAULT_JUMP = 50,
        
        -- Player State Variables
        currentSpeed = 16,
        currentJump = 50,
        InfinityJumpConnection = nil,
        
        -- NEW: Global State Trackers
        CleanModeActive = false,
        ESPPlayerRemovingConnection = nil,
        ESPPlayerAddedConnection = nil,
        LastServerHop = 0,
        
        -- FIXED: Initialize AnimationSystem here
        AnimationSystem = {},
    }
    
    -- ============================================================
    -- ADVANCED ANIMATION SYSTEM (NEW) - FIXED
    -- ============================================================
    local AnimationSystem = _G.SynceHub.AnimationSystem
    local HttpService = _G.SynceHub.HttpService
    
    -- Last saved animations
    AnimationSystem.lastAnimations = {}
    
    -- Helper Functions
    function AnimationSystem.StopAnim()
        local character = LocalPlayer.Character
        if not character then return end
        local Hum = character:FindFirstChildOfClass("Humanoid") or character:FindFirstChildOfClass("AnimationController")
        if Hum then
            for _, track in ipairs(Hum:GetPlayingAnimationTracks()) do
                track:Stop(0)
            end
        end
    end
    
    local function refresh()
        local character = LocalPlayer.Character
        if not character then return end
        local humanoid = character:WaitForChild("Humanoid", 1)
        if humanoid then
            humanoid:ChangeState(Enum.HumanoidStateType.Freefall)
        end
    end
    
    local function refreshswim()
        local character = LocalPlayer.Character
        if not character then return end
        local humanoid = character:WaitForChild("Humanoid", 1)
        if humanoid then
            humanoid:ChangeState(Enum.HumanoidStateType.GettingUp)
            task.wait(0.1)
            humanoid:ChangeState(Enum.HumanoidStateType.Swimming)
        end
    end
    
    local function refreshclimb()
        local character = LocalPlayer.Character
        if not character then return end
        local humanoid = character:WaitForChild("Humanoid", 1)
        if humanoid then
            humanoid:ChangeState(Enum.HumanoidStateType.GettingUp)
            task.wait(0.1)
            humanoid:ChangeState(Enum.HumanoidStateType.Climbing)
        end
    end
    
    local function ResetIdle()
        local character = LocalPlayer.Character
        if not character then return end
        local Hum = character:FindFirstChildOfClass("Humanoid") or character:FindFirstChildOfClass("AnimationController")
        if Hum then
            for _, v in next, Hum:GetPlayingAnimationTracks() do v:Stop(0) end
        end
        pcall(function()
            local Animate = character.Animate
            if Animate and Animate.idle then
                if Animate.idle:FindFirstChild("Animation1") then
                    Animate.idle.Animation1.AnimationId = "http://www.roblox.com/asset/?id=0"
                end
                if Animate.idle:FindFirstChild("Animation2") then
                    Animate.idle.Animation2.AnimationId = "http://www.roblox.com/asset/?id=0"
                end
            end
        end)
    end
    
    local function ResetWalk()
        local character = LocalPlayer.Character
        if not character then return end
        local Hum = character:FindFirstChildOfClass("Humanoid") or character:FindFirstChildOfClass("AnimationController")
        if Hum then
            for _, v in next, Hum:GetPlayingAnimationTracks() do v:Stop(0) end
        end
        pcall(function()
            local Animate = character.Animate
            if Animate and Animate.walk and Animate.walk.WalkAnim then
                Animate.walk.WalkAnim.AnimationId = "http://www.roblox.com/asset/?id=0"
            end
        end)
    end
    
    local function ResetRun()
        local character = LocalPlayer.Character
        if not character then return end
        local Hum = character:FindFirstChildOfClass("Humanoid") or character:FindFirstChildOfClass("AnimationController")
        if Hum then
            for _, v in next, Hum:GetPlayingAnimationTracks() do v:Stop(0) end
        end
        pcall(function()
            local Animate = character.Animate
            if Animate and Animate.run and Animate.run.RunAnim then
                Animate.run.RunAnim.AnimationId = "http://www.roblox.com/asset/?id=0"
            end
        end)
    end
    
    local function ResetJump()
        local character = LocalPlayer.Character
        if not character then return end
        local Hum = character:FindFirstChildOfClass("Humanoid") or character:FindFirstChildOfClass("AnimationController")
        if Hum then
            for _, v in next, Hum:GetPlayingAnimationTracks() do v:Stop(0) end
        end
        pcall(function()
            local Animate = character.Animate
            if Animate and Animate.jump and Animate.jump.JumpAnim then
                Animate.jump.JumpAnim.AnimationId = "http://www.roblox.com/asset/?id=0"
            end
        end)
    end
    
    local function ResetFall()
        local character = LocalPlayer.Character
        if not character then return end
        local Hum = character:FindFirstChildOfClass("Humanoid") or character:FindFirstChildOfClass("AnimationController")
        if Hum then
            for _, v in next, Hum:GetPlayingAnimationTracks() do v:Stop(0) end
        end
        pcall(function()
            local Animate = character.Animate
            if Animate and Animate.fall and Animate.fall.FallAnim then
                Animate.fall.FallAnim.AnimationId = "http://www.roblox.com/asset/?id=0"
            end
        end)
    end
    
    local function ResetSwim()
        local character = LocalPlayer.Character
        if not character then return end
        local Hum = character:FindFirstChildOfClass("Humanoid") or character:FindFirstChildOfClass("AnimationController")
        if Hum then
            for _, v in next, Hum:GetPlayingAnimationTracks() do v:Stop(0) end
        end
        pcall(function()
            local Animate = character.Animate
            if Animate and Animate.swim and Animate.swim.Swim then
                Animate.swim.Swim.AnimationId = "http://www.roblox.com/asset/?id=0"
            end
        end)
    end
    
    local function ResetSwimIdle()
        local character = LocalPlayer.Character
        if not character then return end
        local Hum = character:FindFirstChildOfClass("Humanoid") or character:FindFirstChildOfClass("AnimationController")
        if Hum then
            for _, v in next, Hum:GetPlayingAnimationTracks() do v:Stop(0) end
        end
        pcall(function()
            local Animate = character.Animate
            if Animate and Animate.swimidle and Animate.swimidle.SwimIdle then
                Animate.swimidle.SwimIdle.AnimationId = "http://www.roblox.com/asset/?id=0"
            end
        end)
    end
    
    local function ResetClimb()
        local character = LocalPlayer.Character
        if not character then return end
        local Hum = character:FindFirstChildOfClass("Humanoid") or character:FindFirstChildOfClass("AnimationController")
        if Hum then
            for _, v in next, Hum:GetPlayingAnimationTracks() do v:Stop(0) end
        end
        pcall(function()
            local Animate = character.Animate
            if Animate and Animate.climb and Animate.climb.ClimbAnim then
                Animate.climb.ClimbAnim.AnimationId = "http://www.roblox.com/asset/?id=0"
            end
        end)
    end
    
    local function freeze()
        local character = LocalPlayer.Character
        if not character then return end
        local humanoid = character:WaitForChild("Humanoid", 1)
        if humanoid then
            humanoid.PlatformStand = true
        end
        task.spawn(function()
            for i, part in ipairs(character:GetDescendants()) do
                if part:IsA("BasePart") and not part.Anchored then
                    part.Anchored = true
                end
            end
        end)
    end
    
    local function unfreeze()
        local character = LocalPlayer.Character
        if not character then return end
        local humanoid = character:WaitForChild("Humanoid", 1)
        if humanoid then
            humanoid.PlatformStand = false
        end
        task.spawn(function()
            for i, part in ipairs(character:GetDescendants()) do
                if part:IsA("BasePart") and part.Anchored then
                    part.Anchored = false
                end
            end
        end)
    end
    
    local function saveLastAnimations()
        pcall(function()
            local data = HttpService:JSONEncode(AnimationSystem.lastAnimations)
            writefile("SynceHub_Animations.json", data)
        end)
    end
    
    -- Main Function: Set Animation
    function AnimationSystem.setAnimation(animationType, animationId)
        if type(animationId) ~= "table" and type(animationId) ~= "string" then return end
        local character = LocalPlayer.Character
        if not character then return end
        local Animate = character:FindFirstChild("Animate")
        if not Animate then return end
        
        freeze()
        wait(0.1)
        
        local success, err = pcall(function()
            if animationType == "Idle" then
                AnimationSystem.lastAnimations.Idle = animationId
                ResetIdle()
                if Animate.idle:FindFirstChild("Animation1") then
                    Animate.idle.Animation1.AnimationId = "http://www.roblox.com/asset/?id=" .. animationId[1]
                end
                if Animate.idle:FindFirstChild("Animation2") then
                    Animate.idle.Animation2.AnimationId = "http://www.roblox.com/asset/?id=" .. animationId[2]
                end
                refresh()
            elseif animationType == "Walk" then
                AnimationSystem.lastAnimations.Walk = animationId
                ResetWalk()
                if Animate.walk and Animate.walk.WalkAnim then
                    Animate.walk.WalkAnim.AnimationId = "http://www.roblox.com/asset/?id=" .. animationId
                end
                refresh()
            elseif animationType == "Run" then
                AnimationSystem.lastAnimations.Run = animationId
                ResetRun()
                if Animate.run and Animate.run.RunAnim then
                    Animate.run.RunAnim.AnimationId = "http://www.roblox.com/asset/?id=" .. animationId
                end
                refresh()
            elseif animationType == "Jump" then
                AnimationSystem.lastAnimations.Jump = animationId
                ResetJump()
                if Animate.jump and Animate.jump.JumpAnim then
                    Animate.jump.JumpAnim.AnimationId = "http://www.roblox.com/asset/?id=" .. animationId
                end
                refresh()
            elseif animationType == "Fall" then
                AnimationSystem.lastAnimations.Fall = animationId
                ResetFall()
                if Animate.fall and Animate.fall.FallAnim then
                    Animate.fall.FallAnim.AnimationId = "http://www.roblox.com/asset/?id=" .. animationId
                end
                refresh()
            elseif animationType == "Swim" and Animate:FindFirstChild("swim") then
                AnimationSystem.lastAnimations.Swim = animationId
                ResetSwim()
                if Animate.swim.Swim then
                    Animate.swim.Swim.AnimationId = "http://www.roblox.com/asset/?id=" .. animationId
                end
                refreshswim()
            elseif animationType == "SwimIdle" and Animate:FindFirstChild("swimidle") then
                AnimationSystem.lastAnimations.SwimIdle = animationId
                ResetSwimIdle()
                if Animate.swimidle.SwimIdle then
                    Animate.swimidle.SwimIdle.AnimationId = "http://www.roblox.com/asset/?id=" .. animationId
                end
                refreshswim()
            elseif animationType == "Climb" then
                AnimationSystem.lastAnimations.Climb = animationId
                ResetClimb()
                if Animate.climb and Animate.climb.ClimbAnim then
                    Animate.climb.ClimbAnim.AnimationId = "http://www.roblox.com/asset/?id=" .. animationId
                end
                refreshclimb()
            end
            saveLastAnimations()
        end)
        
        if not success then
            warn("Failed to set animation:", err)
        end
        
        wait(0.1)
        unfreeze()
    end
    
    -- Load saved animations - FIXED with safety checks
    function AnimationSystem.loadLastAnimations()
        pcall(function()
            if isfile("SynceHub_Animations.json") then
                local data = readfile("SynceHub_Animations.json")
                local lastAnimationsData = HttpService:JSONDecode(data)
                if lastAnimationsData and type(lastAnimationsData) == "table" then
                    if lastAnimationsData.Idle then AnimationSystem.setAnimation("Idle", lastAnimationsData.Idle) end
                    if lastAnimationsData.Walk then AnimationSystem.setAnimation("Walk", lastAnimationsData.Walk) end
                    if lastAnimationsData.Run then AnimationSystem.setAnimation("Run", lastAnimationsData.Run) end
                    if lastAnimationsData.Jump then AnimationSystem.setAnimation("Jump", lastAnimationsData.Jump) end
                    if lastAnimationsData.Fall then AnimationSystem.setAnimation("Fall", lastAnimationsData.Fall) end
                    if lastAnimationsData.Climb then AnimationSystem.setAnimation("Climb", lastAnimationsData.Climb) end
                    if lastAnimationsData.Swim then AnimationSystem.setAnimation("Swim", lastAnimationsData.Swim) end
                    if lastAnimationsData.SwimIdle then AnimationSystem.setAnimation("SwimIdle", lastAnimationsData.SwimIdle) end
                end
            end
        end)
    end
    
    -- Play emote function
    function AnimationSystem.PlayEmote(animationId)
        AnimationSystem.StopAnim()
        local character = LocalPlayer.Character
        if not character then return end
        local humanoid = character:WaitForChild("Humanoid", 1)
        if not humanoid then return end
        
        local animation = Instance.new("Animation")
        animation.AnimationId = "rbxassetid://" .. animationId
        local animationTrack = humanoid:LoadAnimation(animation)
        animationTrack:Play()
        
        local checkMovement
        checkMovement = _G.SynceHub.RunService.RenderStepped:Connect(function()
            local moveDirection = humanoid.MoveDirection
            if moveDirection.Magnitude > 0 then
                animationTrack:Stop()
                checkMovement:Disconnect()
            end
        end)
    end
    
    -- Auto-reapply on respawn - FIXED with safety checks
    LocalPlayer.CharacterAdded:Connect(function(character)
        pcall(function()
            local hum = character:WaitForChild("Humanoid", 5)
            local animate = character:WaitForChild("Animate", 10)
            if not animate or not hum then return end
            
            task.wait(1)
            
            if AnimationSystem.lastAnimations and type(AnimationSystem.lastAnimations) == "table" then
                if AnimationSystem.lastAnimations.Idle then AnimationSystem.setAnimation("Idle", AnimationSystem.lastAnimations.Idle) end
                if AnimationSystem.lastAnimations.Walk then AnimationSystem.setAnimation("Walk", AnimationSystem.lastAnimations.Walk) end
                if AnimationSystem.lastAnimations.Run then AnimationSystem.setAnimation("Run", AnimationSystem.lastAnimations.Run) end
                if AnimationSystem.lastAnimations.Jump then AnimationSystem.setAnimation("Jump", AnimationSystem.lastAnimations.Jump) end
                if AnimationSystem.lastAnimations.Fall then AnimationSystem.setAnimation("Fall", AnimationSystem.lastAnimations.Fall) end
                if AnimationSystem.lastAnimations.Climb then AnimationSystem.setAnimation("Climb", AnimationSystem.lastAnimations.Climb) end
                if AnimationSystem.lastAnimations.Swim then AnimationSystem.setAnimation("Swim", AnimationSystem.lastAnimations.Swim) end
                if AnimationSystem.lastAnimations.SwimIdle then AnimationSystem.setAnimation("SwimIdle", AnimationSystem.lastAnimations.SwimIdle) end
            end
        end)
    end)
    
    -- Load saved animations on start
    task.spawn(function()
        task.wait(2)
        AnimationSystem.loadLastAnimations()
    end)
    
    -- ============================================================
    -- INVISIBLE SYSTEM
    -- ============================================================
    local InvisibleSystem = {}
    _G.SynceHub.InvisibleSystem = InvisibleSystem
    
    InvisibleSystem.Core = nil
    InvisibleSystem.Connections = {}
    
    function InvisibleSystem.Init()
        local InvisibleCore = {}
        InvisibleCore.__index = InvisibleCore
        
        function InvisibleCore.new(player)
            local self = setmetatable({}, InvisibleCore)
            self.player = player
            self.character = nil
            self.humanoid = nil
            self.rootPart = nil
            self.invisible = false
            self.parts = {}
            self.connections = {}
            return self
        end
        
        function InvisibleCore:setupCharacter()
            self.character = self.player.Character or self.player.CharacterAdded:Wait()
            self.humanoid = self.character:WaitForChild("Humanoid")
            self.rootPart = self.character:WaitForChild("HumanoidRootPart")
            self.parts = {}
            
            for _, obj in pairs(self.character:GetDescendants()) do
                if obj:IsA("BasePart") and obj.Transparency == 0 then
                    table.insert(self.parts, obj)
                end
            end
        end
        
        function InvisibleCore:toggleInvisibility()
            self.invisible = not self.invisible
            
            for _, part in pairs(self.parts) do
                if part and part.Parent then
                    part.Transparency = self.invisible and 0.5 or 0
                end
            end
            
            return self.invisible
        end
        
        function InvisibleCore:startHeartbeat()
            local connection = _G.SynceHub.RunService.Heartbeat:Connect(function()
                if self.invisible and self.rootPart and self.rootPart.Parent and self.humanoid and self.humanoid.Parent then
                    local cf = self.rootPart.CFrame
                    local camOffset = self.humanoid.CameraOffset
                    local hidden = cf * CFrame.new(0, -200000, 0)
                    self.rootPart.CFrame = hidden
                    self.humanoid.CameraOffset = hidden:ToObjectSpace(CFrame.new(cf.Position)).Position
                    _G.SynceHub.RunService.RenderStepped:Wait()
                    self.rootPart.CFrame = cf
                    self.humanoid.CameraOffset = camOffset
                end
            end)
            
            table.insert(self.connections, connection)
        end
        
        function InvisibleCore:cleanup()
            for _, conn in pairs(self.connections) do
                if conn and conn.Connected then
                    conn:Disconnect()
                end
            end
            self.connections = {}
            self.invisible = false
        end
        
        return InvisibleCore
    end
    
    function InvisibleSystem.Setup()
        local InvisibleCore = InvisibleSystem.Init()
        InvisibleSystem.Core = InvisibleCore.new(LocalPlayer)
        InvisibleSystem.Core:setupCharacter()
        InvisibleSystem.Core:startHeartbeat()
        
        -- Handle respawn
        local respawnConn = LocalPlayer.CharacterAdded:Connect(function()
            task.wait(0.8)
            if InvisibleSystem.Core then
                InvisibleSystem.Core:cleanup()
            end
            InvisibleSystem.Core = InvisibleCore.new(LocalPlayer)
            InvisibleSystem.Core:setupCharacter()
            InvisibleSystem.Core:startHeartbeat()
        end)
        
        table.insert(InvisibleSystem.Connections, respawnConn)
    end
    
    function InvisibleSystem.Toggle()
        if not InvisibleSystem.Core then
            InvisibleSystem.Setup()
        end
        return InvisibleSystem.Core:toggleInvisibility()
    end
    
    function InvisibleSystem.Cleanup()
        if InvisibleSystem.Core then
            InvisibleSystem.Core:cleanup()
        end
        for _, conn in pairs(InvisibleSystem.Connections) do
            if conn and conn.Connected then
                conn:Disconnect()
            end
        end
        InvisibleSystem.Connections = {}
    end
    
    -- Initialize system
    InvisibleSystem.Setup()
    
    -- ============================================================
    -- FLY SYSTEM (NEW - IMPROVED)
    -- ============================================================
    local FlySystem = {}
    _G.SynceHub.FlySystem = FlySystem
    
    FlySystem.Speed = 50
    FlySystem.Active = false
    FlySystem.Connections = {}
    FlySystem.BodyVelocity = nil
    FlySystem.BodyGyro = nil
    
    local ControlModule = require(LocalPlayer.PlayerScripts:WaitForChild("PlayerModule"):WaitForChild("ControlModule"))
    local Camera = workspace.CurrentCamera
    
    function FlySystem.SetupBodyMovers()
        local character = LocalPlayer.Character
        if not character then return end
        
        local hrp = character:FindFirstChild("HumanoidRootPart")
        if not hrp then return end
        
        -- FIXED: Remove ALL body movers first (clean slate)
        for _, obj in pairs(hrp:GetChildren()) do
            if obj:IsA("BodyVelocity") or obj:IsA("BodyGyro") then
                obj:Destroy()
            end
        end
        
        FlySystem.BodyVelocity = Instance.new("BodyVelocity")
        FlySystem.BodyVelocity.Name = "VelocityHandler"
        FlySystem.BodyVelocity.Parent = hrp
        FlySystem.BodyVelocity.MaxForce = Vector3.new(0, 0, 0)
        FlySystem.BodyVelocity.Velocity = Vector3.new(0, 0, 0)
        
        FlySystem.BodyGyro = Instance.new("BodyGyro")
        FlySystem.BodyGyro.Name = "GyroHandler"
        FlySystem.BodyGyro.Parent = hrp
        FlySystem.BodyGyro.MaxTorque = Vector3.new(0, 0, 0)
        FlySystem.BodyGyro.P = 1000
        FlySystem.BodyGyro.D = 50
    end
    
    function FlySystem.FlyLoop()
        local character = LocalPlayer.Character
        if not character then return end
        
        local humanoid = character:FindFirstChildOfClass("Humanoid")
        local hrp = character:FindFirstChild("HumanoidRootPart")
        
        if not humanoid or not hrp then return end
        
        local vel = hrp:FindFirstChild("VelocityHandler")
        local gyro = hrp:FindFirstChild("GyroHandler")
        
        if not vel or not gyro then return end
        
        if FlySystem.Active then
            vel.MaxForce = Vector3.new(9000000000, 9000000000, 9000000000)
            gyro.MaxTorque = Vector3.new(9000000000, 9000000000, 9000000000)
            humanoid.PlatformStand = true
            
            gyro.CFrame = Camera.CoordinateFrame
            
            local moveVector = ControlModule:GetMoveVector()
            vel.Velocity = Vector3.new()
            
            if moveVector.X > 0 then
                vel.Velocity = vel.Velocity + Camera.CFrame.RightVector * (moveVector.X * FlySystem.Speed)
            end
            if moveVector.X < 0 then
                vel.Velocity = vel.Velocity + Camera.CFrame.RightVector * (moveVector.X * FlySystem.Speed)
            end
            if moveVector.Z > 0 then
                vel.Velocity = vel.Velocity - Camera.CFrame.LookVector * (moveVector.Z * FlySystem.Speed)
            end
            if moveVector.Z < 0 then
                vel.Velocity = vel.Velocity - Camera.CFrame.LookVector * (moveVector.Z * FlySystem.Speed)
            end
        else
            vel.MaxForce = Vector3.new(0, 0, 0)
            vel.Velocity = Vector3.new(0, 0, 0)
            gyro.MaxTorque = Vector3.new(0, 0, 0)
            humanoid.PlatformStand = false
        end
    end
    
    function FlySystem.Toggle()
        FlySystem.Active = not FlySystem.Active
        
        if FlySystem.Active then
            if not FlySystem.Connections.renderStep then
                FlySystem.Connections.renderStep = _G.SynceHub.RunService.RenderStepped:Connect(FlySystem.FlyLoop)
            end
        else
            if FlySystem.Connections.renderStep then
                FlySystem.Connections.renderStep:Disconnect()
                FlySystem.Connections.renderStep = nil
            end
            
            local character = LocalPlayer.Character
            if character then
                local humanoid = character:FindFirstChildOfClass("Humanoid")
                local hrp = character:FindFirstChild("HumanoidRootPart")
                
                if humanoid then
                    humanoid.PlatformStand = false
                end
                
                if hrp then
                    if hrp:FindFirstChild("VelocityHandler") then
                        hrp.VelocityHandler:Destroy()
                    end
                    if hrp:FindFirstChild("GyroHandler") then
                        hrp.GyroHandler:Destroy()
                    end
                end
                
                task.wait(0.1)
                FlySystem.SetupBodyMovers()
            end
        end
        
        return FlySystem.Active
    end
    
    function FlySystem.SetSpeed(speed)
        if tonumber(speed) then
            FlySystem.Speed = tonumber(speed)
        end
    end
    
    function FlySystem.Cleanup()
        FlySystem.Active = false
        
        for _, conn in pairs(FlySystem.Connections) do
            if conn and conn.Connected then
                conn:Disconnect()
            end
        end
        FlySystem.Connections = {}
        
        local character = LocalPlayer.Character
        if character then
            local hrp = character:FindFirstChild("HumanoidRootPart")
            if hrp then
                if hrp:FindFirstChild("VelocityHandler") then
                    hrp.VelocityHandler:Destroy()
                end
                if hrp:FindFirstChild("GyroHandler") then
                    hrp.GyroHandler:Destroy()
                end
            end
            
            local humanoid = character:FindFirstChildOfClass("Humanoid")
            if humanoid then
                humanoid.PlatformStand = false
            end
        end
    end
    
    FlySystem.SetupBodyMovers()
    
    local flyRespawnConn = LocalPlayer.CharacterAdded:Connect(function()
        task.wait(0.8)
        FlySystem.SetupBodyMovers()
        
        if FlySystem.Active then
            task.wait(0.5)
            if not FlySystem.Connections.renderStep then
                FlySystem.Connections.renderStep = _G.SynceHub.RunService.RenderStepped:Connect(FlySystem.FlyLoop)
            end
        end
    end)
    
    table.insert(FlySystem.Connections, flyRespawnConn)
    
    -- ============================================================
-- GRAPHICS QUALITY SYSTEM (NEW)
-- ============================================================
local GraphicsSystem = {}
_G.SynceHub.GraphicsSystem = GraphicsSystem

local Lighting = game:GetService("Lighting")
local RunService = game:GetService("RunService")

-- Graphics State & Backup
GraphicsSystem.State = {
    CurrentPreset = "Auto",
    OriginalSettings = {},
}

-- Backup original settings
local function BackupOriginalSettings()
    pcall(function()
        GraphicsSystem.State.OriginalSettings = {
            GlobalShadows = Lighting.GlobalShadows,
            Brightness = Lighting.Brightness,
            OutdoorAmbient = Lighting.OutdoorAmbient,
            Ambient = Lighting.Ambient,
            FogEnd = Lighting.FogEnd,
            FogStart = Lighting.FogStart,
            QualityLevel = settings().Rendering.QualityLevel,
            MeshPartDetailLevel = settings().Rendering.MeshPartDetailLevel,
            PostEffects = {},
        }
        
        for _, effect in pairs(Lighting:GetChildren()) do
            if effect:IsA("PostEffect") then
                GraphicsSystem.State.OriginalSettings.PostEffects[effect.Name] = effect.Enabled
            end
        end
    end)
end

BackupOriginalSettings()

-- Graphics Presets
GraphicsSystem.Presets = {
    ["Low"] = {
        Name = "Low (Performance)",
        Description = "Maximum FPS - Minimal graphics",
        Icon = "zap",
        Color = Color3.fromHex("#FF6B6B"),
        Settings = {
            QualityLevel = Enum.QualityLevel.Level01,
            MeshPartDetailLevel = Enum.MeshPartDetailLevel.Level01,
            GlobalShadows = false,
            Brightness = 0,
            FogEnd = 100,
            FogStart = 0,
            PostEffects = false,
            Particles = false,
        }
    },
    
    ["Medium"] = {
        Name = "Medium (Balanced)",
        Description = "Balance between FPS and visuals",
        Icon = "activity",
        Color = Color3.fromHex("#FFA726"),
        Settings = {
            QualityLevel = Enum.QualityLevel.Level08,
            MeshPartDetailLevel = Enum.MeshPartDetailLevel.Level01,
            GlobalShadows = false,
            Brightness = 1,
            FogEnd = 500,
            FogStart = 0,
            PostEffects = true,
            Particles = true,
        }
    },
    
    ["High"] = {
        Name = "High (Quality)",
        Description = "High visual quality",
        Icon = "eye",
        Color = Color3.fromHex("#66BB6A"),
        Settings = {
            QualityLevel = Enum.QualityLevel.Level15,
            MeshPartDetailLevel = Enum.MeshPartDetailLevel.Level02,
            GlobalShadows = true,
            Brightness = 2,
            FogEnd = 1000,
            FogStart = 0,
            PostEffects = true,
            Particles = true,
        }
    },
    
    ["Ultra"] = {
        Name = "Ultra (Max Quality)",
        Description = "Maximum visual quality - Low FPS",
        Icon = "star",
        Color = Color3.fromHex("#AB47BC"),
        Settings = {
            QualityLevel = Enum.QualityLevel.Level21,
            MeshPartDetailLevel = Enum.MeshPartDetailLevel.Level04,
            GlobalShadows = true,
            Brightness = 3,
            FogEnd = 5000,
            FogStart = 0,
            PostEffects = true,
            Particles = true,
        }
    },
}

-- Apply Graphics Preset
function GraphicsSystem.ApplyPreset(presetName)
    local preset = GraphicsSystem.Presets[presetName]
    if not preset then return false end
    
    local settings = preset.Settings
    
    pcall(function()
        -- Apply Quality Level
        game.Settings().Rendering.QualityLevel = settings.QualityLevel
        game.Settings().Rendering.MeshPartDetailLevel = settings.MeshPartDetailLevel
        
        -- Apply Lighting
        Lighting.GlobalShadows = settings.GlobalShadows
        Lighting.Brightness = settings.Brightness
        Lighting.FogEnd = settings.FogEnd
        Lighting.FogStart = settings.FogStart
        
        -- Post Effects
        for _, effect in pairs(Lighting:GetChildren()) do
            if effect:IsA("PostEffect") then
                effect.Enabled = settings.PostEffects
            end
        end
        
        -- Particles
        if not settings.Particles then
            for _, obj in pairs(workspace:GetDescendants()) do
                if obj:IsA("ParticleEmitter") or obj:IsA("Trail") or 
                   obj:IsA("Beam") or obj:IsA("Fire") or obj:IsA("Smoke") then
                    obj.Enabled = false
                end
            end
        end
    end)
    
    GraphicsSystem.State.CurrentPreset = presetName
    
    -- Save to file
    pcall(function()
        writefile("SynceHub_Graphics.txt", presetName)
    end)
    
    return true
end

-- Restore Original
function GraphicsSystem.RestoreOriginal()
    pcall(function()
        local orig = GraphicsSystem.State.OriginalSettings
        
        Lighting.GlobalShadows = orig.GlobalShadows
        Lighting.Brightness = orig.Brightness
        Lighting.OutdoorAmbient = orig.OutdoorAmbient
        Lighting.Ambient = orig.Ambient
        Lighting.FogEnd = orig.FogEnd
        Lighting.FogStart = orig.FogStart
        
        settings().Rendering.QualityLevel = orig.QualityLevel
        settings().Rendering.MeshPartDetailLevel = orig.MeshPartDetailLevel
        
        for effectName, wasEnabled in pairs(orig.PostEffects) do
            local effect = Lighting:FindFirstChild(effectName)
            if effect and effect:IsA("PostEffect") then
                effect.Enabled = wasEnabled
            end
        end
        
        -- Re-enable particles
        for _, obj in pairs(workspace:GetDescendants()) do
            if obj:IsA("ParticleEmitter") or obj:IsA("Trail") or 
               obj:IsA("Beam") or obj:IsA("Fire") or obj:IsA("Smoke") then
                obj.Enabled = true
            end
        end
    end)
    
    GraphicsSystem.State.CurrentPreset = "Auto"
    
    pcall(function()
        if isfile("SynceHub_Graphics.txt") then
            delfile("SynceHub_Graphics.txt")
        end
    end)
end

-- FPS Counter System
GraphicsSystem.FPSCounter = {
    Enabled = false,
    Label = nil,
    Connection = nil,
}

function GraphicsSystem.CreateFPSCounter()
    if GraphicsSystem.FPSCounter.Label then return end
    
    local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
    
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "SynceHub_FPS"
    ScreenGui.ResetOnSpawn = false
    ScreenGui.DisplayOrder = 999
    ScreenGui.Parent = PlayerGui
    
    local Frame = Instance.new("Frame")
    Frame.Size = UDim2.new(0, 120, 0, 50)
    Frame.Position = UDim2.new(1, -130, 0, 10)
    Frame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    Frame.BackgroundTransparency = 0.3
    Frame.BorderSizePixel = 0
    Frame.Parent = ScreenGui
    
    local UICorner = Instance.new("UICorner")
    UICorner.CornerRadius = UDim.new(0, 8)
    UICorner.Parent = Frame
    
    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(1, 0, 1, 0)
    Label.BackgroundTransparency = 1
    Label.Text = "FPS: 60"
    Label.TextColor3 = Color3.fromRGB(0, 255, 127)
    Label.TextSize = 18
    Label.Font = Enum.Font.GothamBold
    Label.Parent = Frame
    
    GraphicsSystem.FPSCounter.Label = Label
    
    -- FPS Calculation
    local frameCount = 0
    local lastTime = tick()
    
    GraphicsSystem.FPSCounter.Connection = RunService.RenderStepped:Connect(function()
        frameCount = frameCount + 1
        local currentTime = tick()
        
        if currentTime - lastTime >= 1 then
            local fps = frameCount
            Label.Text = "FPS: " .. tostring(fps)
            
            -- Color based on FPS
            if fps >= 50 then
                Label.TextColor3 = Color3.fromRGB(0, 255, 127) -- Green
            elseif fps >= 30 then
                Label.TextColor3 = Color3.fromRGB(255, 165, 0) -- Orange
            else
                Label.TextColor3 = Color3.fromRGB(255, 69, 69) -- Red
            end
            
            frameCount = 0
            lastTime = currentTime
        end
    end)
end

function GraphicsSystem.RemoveFPSCounter()
    if GraphicsSystem.FPSCounter.Connection then
        GraphicsSystem.FPSCounter.Connection:Disconnect()
        GraphicsSystem.FPSCounter.Connection = nil
    end
    
    if GraphicsSystem.FPSCounter.Label then
        local ScreenGui = GraphicsSystem.FPSCounter.Label.Parent.Parent
        if ScreenGui then
            ScreenGui:Destroy()
        end
        GraphicsSystem.FPSCounter.Label = nil
    end
end

function GraphicsSystem.ToggleFPSCounter()
    GraphicsSystem.FPSCounter.Enabled = not GraphicsSystem.FPSCounter.Enabled
    
    if GraphicsSystem.FPSCounter.Enabled then
        GraphicsSystem.CreateFPSCounter()
    else
        GraphicsSystem.RemoveFPSCounter()
    end
    
    return GraphicsSystem.FPSCounter.Enabled
end

-- Auto-load saved preset on init
task.spawn(function()
    task.wait(2)
    pcall(function()
        if isfile("SynceHub_Graphics.txt") then
            local savedPreset = readfile("SynceHub_Graphics.txt")
            if GraphicsSystem.Presets[savedPreset] then
                GraphicsSystem.ApplyPreset(savedPreset)
            end
        end
    end)
end)

-- Cleanup function
function GraphicsSystem.Cleanup()
    GraphicsSystem.RemoveFPSCounter()
    GraphicsSystem.RestoreOriginal()
end
    
    -- ============================================================
    -- ANTI-AFK
    -- ============================================================
    local antiAfkSuccess = pcall(function()
        local player = game:GetService("Players").LocalPlayer
        for i, v in pairs(getconnections(player.Idled)) do
            if v.Disable then
                v:Disable()
            end
        end
    end)
    
    if not antiAfkSuccess then
        WindUI:Notify({ 
            Title = "Warning", 
            Content = "Anti-AFK failed to load", 
            Duration = 3, 
            Icon = "info" 
        })
    end
end

return FeatureModule