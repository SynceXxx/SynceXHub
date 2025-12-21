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