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
        
        -- Animation System
        AnimationSystem = {},
    }
    
    -- ============================================================
    -- ANIMATION SYSTEM
    -- ============================================================
    local AnimationSystem = _G.SynceHub.AnimationSystem
    
    AnimationSystem.Presets = {
        -- Default Roblox
        ["Default"] = {
            name = "Default",
            idle = {507766388},
            walk = 507777826,
            run = 507767714,
            jump = 507765000,
            fall = 507767968,
            swim = 507784897,
            climb = 507765644,
        },
        
        -- Stylish
        ["Stylish"] = {
            name = "Stylish",
            idle = {616136790},
            walk = 616146177,
            run = 616140816,
            jump = 616139451,
            fall = 616134815,
            swim = 616148096,
            climb = 616144772,
        },
        
        -- Zombie
        ["Zombie"] = {
            name = "Zombie",
            idle = {616158929},
            walk = 616168032,
            run = 616163682,
            jump = 616161997,
            fall = 616157476,
            swim = 616165109,
            climb = 616156119,
        },
        
        -- Knight
        ["Knight"] = {
            name = "Knight",
            idle = {657595757},
            walk = 657552124,
            run = 657564596,
            jump = 658409194,
            fall = 657600338,
            swim = 657560551,
            climb = 658360781,
        },
        
        -- Superhero
        ["Superhero"] = {
            name = "Superhero",
            idle = {782841498},
            walk = 782842708,
            run = 782842708,
            jump = 782847020,
            fall = 782846423,
            swim = 782843345,
            climb = 782843869,
        },
        
        -- Ninja
        ["Ninja"] = {
            name = "Ninja",
            idle = {656117400},
            walk = 656121766,
            run = 656118852,
            jump = 656117878,
            fall = 656115606,
            swim = 656119721,
            climb = 656114359,
        },
        
        -- Elder
        ["Elder"] = {
            name = "Elder",
            idle = {845397899},
            walk = 845403856,
            run = 845386501,
            jump = 845398858,
            fall = 845400520,
            swim = 845401742,
            climb = 845392038,
        },
        
        -- Pirate
        ["Pirate"] = {
            name = "Pirate",
            idle = {750781874},
            walk = 750785693,
            run = 750783738,
            jump = 750782230,
            fall = 750780242,
            swim = 750784579,
            climb = 750779899,
        },
        
        -- Cartoony
        ["Cartoony"] = {
            name = "Cartoony",
            idle = {742637544},
            walk = 742640026,
            run = 742638842,
            jump = 742637942,
            fall = 742637151,
            swim = 742639220,
            climb = 742636889,
        },
        
        -- Toy
        ["Toy"] = {
            name = "Toy",
            idle = {782841498},
            walk = 782843345,
            run = 782842708,
            jump = 782847020,
            fall = 782846423,
            swim = 782843345,
            climb = 782843869,
        },
    }
    
    function AnimationSystem.Apply(player, animationSet)
        if not player or not player.Character then 
            return false, "Character not found" 
        end
        
        local character = player.Character
        local humanoid = character:FindFirstChildOfClass("Humanoid")
        
        if not humanoid then 
            return false, "Humanoid not found" 
        end
        
        local animate = character:FindFirstChild("Animate")
        if not animate then
            return false, "Animate script not found"
        end
        
        local function ChangeAnim(animName, animId)
            local animFolder = animate:FindFirstChild(animName)
            if animFolder then
                for _, anim in pairs(animFolder:GetChildren()) do
                    if anim:IsA("Animation") then
                        anim.AnimationId = "rbxassetid://" .. tostring(animId)
                    end
                end
            end
        end
        
        if animationSet.idle then
            for i, idleId in ipairs(animationSet.idle) do
                ChangeAnim("idle", idleId)
            end
        end
        
        if animationSet.walk then ChangeAnim("walk", animationSet.walk) end
        if animationSet.run then ChangeAnim("run", animationSet.run) end
        if animationSet.jump then ChangeAnim("jump", animationSet.jump) end
        if animationSet.fall then ChangeAnim("fall", animationSet.fall) end
        if animationSet.swim then ChangeAnim("swim", animationSet.swim) end
        if animationSet.climb then ChangeAnim("climb", animationSet.climb) end
        
        humanoid.WalkSpeed = humanoid.WalkSpeed + 0.01
        task.wait(0.1)
        humanoid.WalkSpeed = humanoid.WalkSpeed - 0.01
        
        return true, "Animations applied successfully"
    end
    
    function AnimationSystem.ApplyPreset(player, presetName)
        local preset = AnimationSystem.Presets[presetName]
        if not preset then
            return false, "Preset not found"
        end
        return AnimationSystem.Apply(player, preset)
    end
    
    function AnimationSystem.ApplyCustom(player, customIds)
        local animSet = {
            idle = customIds.idle or {507766388},
            walk = customIds.walk or 507777826,
            run = customIds.run or 507767714,
            jump = customIds.jump or 507765000,
            fall = customIds.fall or 507767968,
            swim = customIds.swim or 507784897,
            climb = customIds.climb or 507765644,
        }
        return AnimationSystem.Apply(player, animSet)
    end
    
    function AnimationSystem.Reset(player)
        return AnimationSystem.ApplyPreset(player, "Default")
    end
    
    function AnimationSystem.GetPresets()
        local presets = {}
        for name, data in pairs(AnimationSystem.Presets) do
            table.insert(presets, name)
        end
        table.sort(presets)
        return presets
    end
    
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