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

-- ============================================================
    -- CHOP TREE SYSTEM
    -- ============================================================
    local ChopTreeSystem = {}
    _G.SynceHub.ChopTreeSystem = ChopTreeSystem
    
    -- Services untuk ChopTree
    ChopTreeSystem.RepStorage = game:GetService("ReplicatedStorage")
    ChopTreeSystem.Workspace = game:GetService("Workspace")
    ChopTreeSystem.VirtualInputManager = game:GetService("VirtualInputManager")
    ChopTreeSystem.TweenService = game:GetService("TweenService")
    
    -- Remotes
    ChopTreeSystem.Remotes = nil
    ChopTreeSystem.TapButtonClick = nil
    ChopTreeSystem.TreeClick = nil
    ChopTreeSystem.AxeSwing = nil
    ChopTreeSystem.CollectCoin = nil
    ChopTreeSystem.Prestige = nil
    ChopTreeSystem.ClickWateringCan = nil
    ChopTreeSystem.ClaimWaterPurifier = nil
    ChopTreeSystem.WaterPurifier = nil
    
    -- Timing Constants
    ChopTreeSystem.TIMING = {
        TAP_SPEED = 0.01,
        MUTATION_HIT_DELAY = 0.02,
        MUTATION_LOOP_DELAY = 0.05,
        COIN_COLLECT_DELAY = 0.03,
        COIN_LOOP_DELAY = 0.2,
        PRESTIGE_INTERVAL = 5,
        USE_CANS_KEY_DELAY = 0.3,
        USE_CANS_CLICK_DELAY = 0.4,
        USE_CANS_INTERVAL = 5,
        PICKUP_CANS_DELAY = 0.3,
        PICKUP_CANS_INTERVAL = 8,
        CLAIM_PURIFIER_INTERVAL = 10,
        FILL_PURIFIER_INTERVAL = 5,
        FILL_PURIFIER_DELAY = 2,
        KEY_PRESS_DURATION = 0.05,
        CLICK_DURATION = 0.05,
        STEAL_DELAY = 0.5,
        STEAL_LOOP_INTERVAL = 3,
    }
    
    -- Config
    ChopTreeSystem.Config = {
        AutoTap = false,
        TapThreads = 5,
        AutoMutations = false,
        AutoCollectCoins = false,
        AutoPrestige = false,
        AutoUseCans = false,
        AutoPickupCans = false,
        AutoClaimPurifier = false,
        AutoFillPurifier = false,
        AutoSteal = false,
        WaterLevelThreshold = 3,
    }
    
    -- State
    ChopTreeSystem.State = {
        Running = false,
        Tapping = false,
        HittingTrees = false,
        CollectingCoins = false,
        UsingCans = false,
        PickingUpCans = false,
        Prestiging = false,
        ClaimingPurifier = false,
        FillingPurifier = false,
        Stealing = false,
    }
    
    -- Threads & Connections
    ChopTreeSystem.Connections = {}
    ChopTreeSystem.Threads = {}
    
    -- Helper: Safe Disconnect
    function ChopTreeSystem.SafeDisconnect(name)
        if ChopTreeSystem.Connections[name] then
            pcall(function() ChopTreeSystem.Connections[name]:Disconnect() end)
            ChopTreeSystem.Connections[name] = nil
        end
    end
    
    -- Helper: Safe Cancel Thread
    function ChopTreeSystem.SafeCancel(name)
        if ChopTreeSystem.Threads[name] then
            pcall(function() task.cancel(ChopTreeSystem.Threads[name]) end)
            ChopTreeSystem.Threads[name] = nil
        end
    end
    
    -- Initialize Remotes
    function ChopTreeSystem.InitRemotes()
        ChopTreeSystem.Remotes = ChopTreeSystem.RepStorage:WaitForChild("Remotes", 10)
        if not ChopTreeSystem.Remotes then
            warn("[ChopTreeSystem] Remotes folder not found")
            return false
        end
        
        ChopTreeSystem.TapButtonClick = ChopTreeSystem.Remotes:FindFirstChild("TapButtonClick")
        ChopTreeSystem.TreeClick = ChopTreeSystem.Remotes:FindFirstChild("TreeClick")
        ChopTreeSystem.AxeSwing = ChopTreeSystem.Remotes:FindFirstChild("AxeSwing")
        ChopTreeSystem.CollectCoin = ChopTreeSystem.Remotes:FindFirstChild("CollectCoin")
        ChopTreeSystem.Prestige = ChopTreeSystem.Remotes:FindFirstChild("Prestige")
        ChopTreeSystem.ClickWateringCan = ChopTreeSystem.Remotes:FindFirstChild("ClickWateringCan")
        ChopTreeSystem.ClaimWaterPurifier = ChopTreeSystem.Remotes:FindFirstChild("ClaimWaterPurifier")
        ChopTreeSystem.WaterPurifier = ChopTreeSystem.Remotes:FindFirstChild("WaterPurifier")
        
        return true
    end
    
    -- Get Player Plot
    function ChopTreeSystem.GetPlayerPlot()
        local plotVal = LocalPlayer:FindFirstChild("Plot")
        if plotVal and plotVal:IsA("ObjectValue") and plotVal.Value then
            return plotVal.Value
        end
        
        local plots = ChopTreeSystem.Workspace:FindFirstChild("Plots")
        if plots then
            for _, plot in ipairs(plots:GetChildren()) do
                if plot:GetAttribute("Plr") == LocalPlayer.Name then
                    return plot
                end
            end
        end
        
        return nil
    end
    
    -- Get Mutations
    function ChopTreeSystem.GetMutations()
        local mutations = {}
        local seen = {}
        
        local plot = ChopTreeSystem.GetPlayerPlot()
        if plot then
            for _, child in ipairs(plot:GetChildren()) do
                if child.Name == "TreeValue" and child:IsA("ObjectValue") then
                    local tree = child.Value
                    if tree and tree.Parent and not seen[tree] then
                        seen[tree] = true
                        table.insert(mutations, tree)
                    end
                end
            end
        end
        
        return mutations
    end
    
    -- Get Watering Cans
    function ChopTreeSystem.GetWateringCans()
        local cans = {}
        local seen = {}
        
        local plot = ChopTreeSystem.GetPlayerPlot()
        if plot then
            for _, desc in ipairs(plot:GetDescendants()) do
                if desc.Name == "WateringCanValue" and desc:IsA("ObjectValue") then
                    local can = desc.Value
                    if can and can.Parent and not seen[can] then
                        seen[can] = true
                        table.insert(cans, can)
                    end
                end
            end
        end
        
        return cans
    end
    
    -- Get Stealable Cans
    function ChopTreeSystem.GetStealableCans()
        local stealable = {}
        local myPlot = ChopTreeSystem.GetPlayerPlot()
        local plots = ChopTreeSystem.Workspace:FindFirstChild("Plots")
        
        if not plots then return stealable end
        
        for _, plot in ipairs(plots:GetChildren()) do
            if plot ~= myPlot then
                for _, desc in ipairs(plot:GetDescendants()) do
                    if desc.Name == "WateringCanValue" and desc:IsA("ObjectValue") then
                        local can = desc.Value
                        if can and can.Parent then
                            local canSteal = can:GetAttribute("CanSteal") or can:GetAttribute("Stealable")
                            if canSteal == nil or canSteal == true then
                                table.insert(stealable, can)
                            end
                        end
                    end
                    
                    if desc:IsA("Model") or desc:IsA("BasePart") then
                        local name = desc.Name:lower()
                        if name:find("water") and name:find("can") then
                            local canSteal = desc:GetAttribute("CanSteal") or desc:GetAttribute("Stealable")
                            if canSteal == nil or canSteal == true then
                                table.insert(stealable, desc)
                            end
                        end
                    end
                end
            end
        end
        
        return stealable
    end
    
    -- Get Main Tree
    function ChopTreeSystem.GetMainTree()
        local plot = ChopTreeSystem.GetPlayerPlot()
        if plot then
            local contents = plot:FindFirstChild("PlotContents")
            if contents then
                return contents:FindFirstChild("Tree")
            end
        end
        return nil
    end
    
    -- Get Watering Can Levels
    function ChopTreeSystem.GetWateringCanLevels()
        local levels = {}
        local data = LocalPlayer:FindFirstChild("Data")
        if data then
            local tapCans = data:FindFirstChild("TapWateringCans")
            if tapCans then
                for _, slot in ipairs(tapCans:GetChildren()) do
                    local levelVal = slot:FindFirstChild("Level")
                    if levelVal then
                        levels[slot.Name] = levelVal.Value
                    end
                end
            end
        end
        return levels
    end
    
    -- Get Highest Water Level
    function ChopTreeSystem.GetHighestWaterLevel()
        local highest = 0
        for _, level in pairs(ChopTreeSystem.GetWateringCanLevels()) do
            if level > highest then
                highest = level
            end
        end
        return highest
    end
    
    -- Should Auto Water
    function ChopTreeSystem.ShouldAutoWater()
        return ChopTreeSystem.GetHighestWaterLevel() >= ChopTreeSystem.Config.WaterLevelThreshold
    end
    
    -- Get Lowest Level Can Slot
    function ChopTreeSystem.GetLowestLevelCanSlot()
        local lowestSlot, lowestLevel = nil, 999
        local data = LocalPlayer:FindFirstChild("Data")
        if data then
            local tapCans = data:FindFirstChild("TapWateringCans")
            if tapCans then
                for _, slot in ipairs(tapCans:GetChildren()) do
                    local levelVal = slot:FindFirstChild("Level")
                    if levelVal and levelVal.Value < lowestLevel then
                        lowestLevel = levelVal.Value
                        lowestSlot = tonumber(slot.Name)
                    end
                end
            end
        end
        return lowestSlot, lowestLevel
    end
    
    -- Is Purifier Empty
    function ChopTreeSystem.IsPurifierEmpty()
        local plot = ChopTreeSystem.GetPlayerPlot()
        if plot then
            local contents = plot:FindFirstChild("PlotContents")
            if contents then
                local purifier = contents:FindFirstChild("Water Purifier")
                if purifier then
                    return not (purifier:FindFirstChild("WateringCan") or purifier:FindFirstChild("Can"))
                end
            end
        end
        return true
    end
    
    -- Get Stats
    function ChopTreeSystem.GetCoinsValue()
        local ls = LocalPlayer:FindFirstChild("leaderstats")
        if ls then
            local coins = ls:FindFirstChild("💵 Coins")
            if coins then return tostring(coins.Value) end
        end
        return "0"
    end
    
    function ChopTreeSystem.GetPrestigesValue()
        local ls = LocalPlayer:FindFirstChild("leaderstats")
        if ls then
            local prestiges = ls:FindFirstChild("👑 Prestiges")
            if prestiges then return prestiges.Value end
        end
        return 0
    end
    
    -- Has Watering Cans
    function ChopTreeSystem.HasWateringCans()
        local backpack = LocalPlayer:FindFirstChild("Backpack")
        local char = LocalPlayer.Character
        
        if backpack then
            for _, item in ipairs(backpack:GetChildren()) do
                local name = item.Name:lower()
                if name:find("water") or name:find("can") then
                    return true
                end
            end
        end
        
        if char then
            for _, item in ipairs(char:GetChildren()) do
                if item:IsA("Tool") then
                    local name = item.Name:lower()
                    if name:find("water") or name:find("can") then
                        return true
                    end
                end
            end
        end
        
        return false
    end
    
    -- Press Key Helper
    function ChopTreeSystem.PressKey(keyCode)
        pcall(function()
            ChopTreeSystem.VirtualInputManager:SendKeyEvent(true, keyCode, false, game)
            task.wait(ChopTreeSystem.TIMING.KEY_PRESS_DURATION)
            ChopTreeSystem.VirtualInputManager:SendKeyEvent(false, keyCode, false, game)
        end)
    end
    
    -- Click Mouse Helper
    function ChopTreeSystem.ClickMouse()
        pcall(function()
            ChopTreeSystem.VirtualInputManager:SendMouseButtonEvent(0, 0, 0, true, game, 1)
            task.wait(ChopTreeSystem.TIMING.CLICK_DURATION)
            ChopTreeSystem.VirtualInputManager:SendMouseButtonEvent(0, 0, 0, false, game, 1)
        end)
    end
    
    -- Hotbar Keys
    ChopTreeSystem.HotbarKeys = {
        Enum.KeyCode.Two, Enum.KeyCode.Three, Enum.KeyCode.Four,
        Enum.KeyCode.Five, Enum.KeyCode.Six, Enum.KeyCode.Seven,
        Enum.KeyCode.Eight, Enum.KeyCode.Nine,
    }
    
    -- ============================================================
    -- CORE ACTIONS
    -- ============================================================
    
    -- Tap Tree
    function ChopTreeSystem.TapTree()
        if not ChopTreeSystem.TapButtonClick then return end
        local plot = ChopTreeSystem.GetPlayerPlot()
        if plot then
            pcall(function() ChopTreeSystem.TapButtonClick:FireServer(plot) end)
        end
    end
    
    -- Hit Mutation
    function ChopTreeSystem.HitMutation(mutation)
        if not mutation or not mutation.Parent then return end
        if ChopTreeSystem.TreeClick then
            pcall(function() ChopTreeSystem.TreeClick:InvokeServer(mutation) end)
        end
        if ChopTreeSystem.AxeSwing then
            pcall(function() ChopTreeSystem.AxeSwing:FireServer() end)
        end
    end
    
    -- Hit All Mutations
    function ChopTreeSystem.HitAllMutations()
        local mutations = ChopTreeSystem.GetMutations()
        for _, mutation in ipairs(mutations) do
            if not ChopTreeSystem.Config.AutoMutations or not ChopTreeSystem.State.Running then break end
            ChopTreeSystem.HitMutation(mutation)
            task.wait(ChopTreeSystem.TIMING.MUTATION_HIT_DELAY)
        end
    end
    
    -- Collect All Coins
    function ChopTreeSystem.CollectAllCoins()
        local char = LocalPlayer.Character
        local root = char and char:FindFirstChild("HumanoidRootPart")
        if not root then return end
        
        local originalCFrame = root.CFrame
        local orbsFolder = ChopTreeSystem.Workspace:FindFirstChild("Orbs")
        
        if orbsFolder then
            for _, coin in ipairs(orbsFolder:GetChildren()) do
                if not ChopTreeSystem.Config.AutoCollectCoins or not ChopTreeSystem.State.Running then break end
                if coin and coin.Parent and coin:IsA("BasePart") and coin:GetAttribute("CanCollect") then
                    pcall(function() root.CFrame = coin.CFrame end)
                    
                    if firetouchinterest then
                        pcall(function()
                            firetouchinterest(root, coin, 0)
                            firetouchinterest(root, coin, 1)
                        end)
                    end
                    
                    if ChopTreeSystem.CollectCoin then
                        pcall(function() ChopTreeSystem.CollectCoin:FireServer(coin) end)
                    end
                    
                    task.wait(ChopTreeSystem.TIMING.COIN_COLLECT_DELAY)
                end
            end
        end
        
        pcall(function() root.CFrame = originalCFrame end)
    end
    
    -- Use Cans
    function ChopTreeSystem.UseCans()
        if ChopTreeSystem.State.UsingCans then return end
        ChopTreeSystem.State.UsingCans = true
        
        if not ChopTreeSystem.HasWateringCans() then
            ChopTreeSystem.PressKey(Enum.KeyCode.One)
            ChopTreeSystem.State.UsingCans = false
            return
        end
        
        for _, keyCode in ipairs(ChopTreeSystem.HotbarKeys) do
            if not ChopTreeSystem.Config.AutoUseCans or not ChopTreeSystem.State.Running then break end
            ChopTreeSystem.PressKey(keyCode)
            task.wait(ChopTreeSystem.TIMING.USE_CANS_KEY_DELAY)
            ChopTreeSystem.ClickMouse()
            task.wait(ChopTreeSystem.TIMING.USE_CANS_CLICK_DELAY)
        end
        
        ChopTreeSystem.PressKey(Enum.KeyCode.One)
        ChopTreeSystem.State.UsingCans = false
    end
    
    -- Pickup Cans
    function ChopTreeSystem.PickupCans()
        if ChopTreeSystem.State.PickingUpCans then return end
        ChopTreeSystem.State.PickingUpCans = true
        
        local cans = ChopTreeSystem.GetWateringCans()
        if #cans == 0 then
            ChopTreeSystem.PressKey(Enum.KeyCode.One)
            ChopTreeSystem.State.PickingUpCans = false
            return
        end
        
        for _, can in ipairs(cans) do
            if not ChopTreeSystem.Config.AutoPickupCans or not ChopTreeSystem.State.Running then break end
            if ChopTreeSystem.ClickWateringCan then
                pcall(function() ChopTreeSystem.ClickWateringCan:FireServer(can) end)
            end
            task.wait(ChopTreeSystem.TIMING.PICKUP_CANS_DELAY)
        end
        
        local tree = ChopTreeSystem.GetMainTree()
        if tree and ChopTreeSystem.ClickWateringCan then
            pcall(function() ChopTreeSystem.ClickWateringCan:FireServer(tree) end)
        end
        
        local plot = ChopTreeSystem.GetPlayerPlot()
        if plot and ChopTreeSystem.ClickWateringCan then
            pcall(function() ChopTreeSystem.ClickWateringCan:FireServer(plot) end)
        end
        
        ChopTreeSystem.PressKey(Enum.KeyCode.One)
        ChopTreeSystem.State.PickingUpCans = false
    end
    
    -- Claim Purifier
    function ChopTreeSystem.ClaimPurifier()
        if ChopTreeSystem.ClaimWaterPurifier then
            pcall(function() ChopTreeSystem.ClaimWaterPurifier:InvokeServer() end)
        end
    end
    
    -- Fill Purifier
    function ChopTreeSystem.FillPurifier()
        local slot, level = ChopTreeSystem.GetLowestLevelCanSlot()
        if slot and level < 100 and ChopTreeSystem.WaterPurifier then
            pcall(function() ChopTreeSystem.WaterPurifier:InvokeServer(slot) end)
        end
    end
    
    -- Do Prestige
    function ChopTreeSystem.DoPrestige()
        if ChopTreeSystem.Prestige then
            pcall(function() ChopTreeSystem.Prestige:InvokeServer() end)
        end
    end
    
    -- Steal Can
    function ChopTreeSystem.StealCan(can)
        if not can or not can.Parent then return end
        if ChopTreeSystem.ClickWateringCan then
            pcall(function() ChopTreeSystem.ClickWateringCan:FireServer(can) end)
        end
    end
    
    -- Steal All Cans
    function ChopTreeSystem.StealAllCans()
        local cans = ChopTreeSystem.GetStealableCans()
        for _, can in ipairs(cans) do
            if not ChopTreeSystem.Config.AutoSteal or not ChopTreeSystem.State.Running then break end
            ChopTreeSystem.StealCan(can)
            task.wait(ChopTreeSystem.TIMING.STEAL_DELAY)
        end
        return #cans
    end
    
    -- ============================================================
    -- AUTO FEATURES
    -- ============================================================
    
    -- Start Auto Tap
    function ChopTreeSystem.StartAutoTap()
        if ChopTreeSystem.State.Tapping then return end
        ChopTreeSystem.State.Tapping = true
        
        for i = 1, ChopTreeSystem.Config.TapThreads do
            ChopTreeSystem.Threads["Tap_" .. i] = task.spawn(function()
                while ChopTreeSystem.Config.AutoTap and ChopTreeSystem.State.Running do
                    ChopTreeSystem.TapTree()
                    task.wait(ChopTreeSystem.TIMING.TAP_SPEED)
                end
            end)
        end
        
        ChopTreeSystem.Threads["TapMonitor"] = task.spawn(function()
            while ChopTreeSystem.Config.AutoTap and ChopTreeSystem.State.Running do
                task.wait(0.1)
            end
            ChopTreeSystem.State.Tapping = false
        end)
    end
    
    -- Stop Auto Tap
    function ChopTreeSystem.StopAutoTap()
        ChopTreeSystem.Config.AutoTap = false
        for i = 1, ChopTreeSystem.Config.TapThreads do
            ChopTreeSystem.SafeCancel("Tap_" .. i)
        end
        ChopTreeSystem.SafeCancel("TapMonitor")
        ChopTreeSystem.State.Tapping = false
    end
    
    -- Start Auto Mutations
    function ChopTreeSystem.StartAutoMutations()
        if ChopTreeSystem.State.HittingTrees then return end
        ChopTreeSystem.State.HittingTrees = true
        
        ChopTreeSystem.Threads["Mutations"] = task.spawn(function()
            while ChopTreeSystem.Config.AutoMutations and ChopTreeSystem.State.Running do
                ChopTreeSystem.HitAllMutations()
                task.wait(ChopTreeSystem.TIMING.MUTATION_LOOP_DELAY)
            end
            ChopTreeSystem.State.HittingTrees = false
        end)
    end
    
    -- Stop Auto Mutations
    function ChopTreeSystem.StopAutoMutations()
        ChopTreeSystem.Config.AutoMutations = false
        ChopTreeSystem.SafeCancel("Mutations")
        ChopTreeSystem.State.HittingTrees = false
    end
    
    -- Start Auto Collect
    function ChopTreeSystem.StartAutoCollect()
        if ChopTreeSystem.State.CollectingCoins then return end
        ChopTreeSystem.State.CollectingCoins = true
        
        ChopTreeSystem.Threads["Collect"] = task.spawn(function()
            while ChopTreeSystem.Config.AutoCollectCoins and ChopTreeSystem.State.Running do
                ChopTreeSystem.CollectAllCoins()
                task.wait(ChopTreeSystem.TIMING.COIN_LOOP_DELAY)
            end
            ChopTreeSystem.State.CollectingCoins = false
        end)
    end
    
    -- Stop Auto Collect
    function ChopTreeSystem.StopAutoCollect()
        ChopTreeSystem.Config.AutoCollectCoins = false
        ChopTreeSystem.SafeCancel("Collect")
        ChopTreeSystem.State.CollectingCoins = false
    end
    
    -- Start Auto Prestige
    function ChopTreeSystem.StartAutoPrestige()
        if ChopTreeSystem.State.Prestiging then return end
        ChopTreeSystem.State.Prestiging = true
        
        ChopTreeSystem.Threads["Prestige"] = task.spawn(function()
            while ChopTreeSystem.Config.AutoPrestige and ChopTreeSystem.State.Running do
                ChopTreeSystem.DoPrestige()
                task.wait(ChopTreeSystem.TIMING.PRESTIGE_INTERVAL)
            end
            ChopTreeSystem.State.Prestiging = false
        end)
    end
    
    -- Stop Auto Prestige
    function ChopTreeSystem.StopAutoPrestige()
        ChopTreeSystem.Config.AutoPrestige = false
        ChopTreeSystem.SafeCancel("Prestige")
        ChopTreeSystem.State.Prestiging = false
    end
    
    -- Start Auto Use Cans
    function ChopTreeSystem.StartAutoUseCans()
        ChopTreeSystem.Threads["UseCans"] = task.spawn(function()
            while ChopTreeSystem.Config.AutoUseCans and ChopTreeSystem.State.Running do
                if ChopTreeSystem.ShouldAutoWater() then
                    task.spawn(ChopTreeSystem.UseCans)
                end
                task.wait(ChopTreeSystem.TIMING.USE_CANS_INTERVAL)
            end
        end)
    end
    
    -- Stop Auto Use Cans
    function ChopTreeSystem.StopAutoUseCans()
        ChopTreeSystem.Config.AutoUseCans = false
        ChopTreeSystem.SafeCancel("UseCans")
    end
    
    -- Start Auto Pickup Cans
    function ChopTreeSystem.StartAutoPickupCans()
        ChopTreeSystem.Threads["PickupCans"] = task.spawn(function()
            while ChopTreeSystem.Config.AutoPickupCans and ChopTreeSystem.State.Running do
                if ChopTreeSystem.ShouldAutoWater() then
                    task.spawn(ChopTreeSystem.PickupCans)
                end
                task.wait(ChopTreeSystem.TIMING.PICKUP_CANS_INTERVAL)
            end
        end)
    end
    
    -- Stop Auto Pickup Cans
    function ChopTreeSystem.StopAutoPickupCans()
        ChopTreeSystem.Config.AutoPickupCans = false
        ChopTreeSystem.SafeCancel("PickupCans")
    end
    
    -- Start Auto Claim Purifier
    function ChopTreeSystem.StartAutoClaimPurifier()
        ChopTreeSystem.Threads["ClaimPurifier"] = task.spawn(function()
            while ChopTreeSystem.Config.AutoClaimPurifier and ChopTreeSystem.State.Running do
                ChopTreeSystem.ClaimPurifier()
                task.wait(ChopTreeSystem.TIMING.CLAIM_PURIFIER_INTERVAL)
            end
        end)
    end
    
    -- Stop Auto Claim Purifier
    function ChopTreeSystem.StopAutoClaimPurifier()
        ChopTreeSystem.Config.AutoClaimPurifier = false
        ChopTreeSystem.SafeCancel("ClaimPurifier")
    end
    
    -- Start Auto Fill Purifier
    function ChopTreeSystem.StartAutoFillPurifier()
        ChopTreeSystem.Threads["FillPurifier"] = task.spawn(function()
            while ChopTreeSystem.Config.AutoFillPurifier and ChopTreeSystem.State.Running do
                if ChopTreeSystem.IsPurifierEmpty() then
                    ChopTreeSystem.FillPurifier()
                    task.wait(ChopTreeSystem.TIMING.FILL_PURIFIER_DELAY)
                end
                task.wait(ChopTreeSystem.TIMING.FILL_PURIFIER_INTERVAL)
            end
        end)
    end
    
    -- Stop Auto Fill Purifier
    function ChopTreeSystem.StopAutoFillPurifier()
        ChopTreeSystem.Config.AutoFillPurifier = false
        ChopTreeSystem.SafeCancel("FillPurifier")
    end
    
    -- Start Auto Steal
    function ChopTreeSystem.StartAutoSteal()
        if ChopTreeSystem.State.Stealing then return end
        ChopTreeSystem.State.Stealing = true
        
        ChopTreeSystem.Threads["Steal"] = task.spawn(function()
            while ChopTreeSystem.Config.AutoSteal and ChopTreeSystem.State.Running do
                ChopTreeSystem.StealAllCans()
                task.wait(ChopTreeSystem.TIMING.STEAL_LOOP_INTERVAL)
            end
            ChopTreeSystem.State.Stealing = false
        end)
    end
    
    -- Stop Auto Steal
    function ChopTreeSystem.StopAutoSteal()
        ChopTreeSystem.Config.AutoSteal = false
        ChopTreeSystem.SafeCancel("Steal")
        ChopTreeSystem.State.Stealing = false
    end
    
    -- ============================================================
    -- CLEANUP
    -- ============================================================
    function ChopTreeSystem.Cleanup()
        ChopTreeSystem.State.Running = false
        
        for k, v in pairs(ChopTreeSystem.Config) do
            if type(v) == "boolean" then
                ChopTreeSystem.Config[k] = false
            end
        end
        
        for name in pairs(ChopTreeSystem.Connections) do
            ChopTreeSystem.SafeDisconnect(name)
        end
        
        for name in pairs(ChopTreeSystem.Threads) do
            ChopTreeSystem.SafeCancel(name)
        end
    end
    
    -- Initialize on load
    task.spawn(function()
        if ChopTreeSystem.InitRemotes() then
            ChopTreeSystem.State.Running = true
        end
    end)
    
return FeatureModule