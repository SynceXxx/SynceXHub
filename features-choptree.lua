local FeatureModule = {}

function FeatureModule.Init(Window, Reg, WindUI, LocalPlayer)
    -- ============================================================
    -- CHOP YOUR TREE - FEATURE MODULE
    -- ============================================================
    
    local Players = game:GetService("Players")
    local ReplicatedStorage = game:GetService("ReplicatedStorage")
    local RunService = game:GetService("RunService")
    local Workspace = game:GetService("Workspace")
    local VirtualInputManager = game:GetService("VirtualInputManager")
    local UserInputService = game:GetService("UserInputService")
    local TweenService = game:GetService("TweenService")
    
    -- Wait for Remotes
    local Remotes = ReplicatedStorage:WaitForChild("Remotes", 10)
    
    if not Remotes then
        WindUI:Notify({
            Title = "Game Not Supported",
            Content = "This game doesn't have required remotes",
            Duration = 5,
            Icon = "x",
        })
        return
    end
    
    -- Remote References
    local TapButtonClick = Remotes:FindFirstChild("TapButtonClick")
    local TreeClick = Remotes:FindFirstChild("TreeClick")
    local AxeSwing = Remotes:FindFirstChild("AxeSwing")
    local CollectCoin = Remotes:FindFirstChild("CollectCoin")
    local Prestige = Remotes:FindFirstChild("Prestige")
    local ClickWateringCan = Remotes:FindFirstChild("ClickWateringCan")
    local ClaimWaterPurifier = Remotes:FindFirstChild("ClaimWaterPurifier")
    local WaterPurifier = Remotes:FindFirstChild("WaterPurifier")
    
    -- ============================================================
    -- TIMING CONFIGURATION
    -- ============================================================
    local TIMING = {
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
        STATS_UPDATE_INTERVAL = 1,
        KEY_PRESS_DURATION = 0.05,
        CLICK_DURATION = 0.05,
        STEAL_DELAY = 0.5,
        STEAL_LOOP_INTERVAL = 3,
    }
    
    -- ============================================================
    -- CONFIG & STATE
    -- ============================================================
    local Config = {
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
    
    local State = {
        Running = true,
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
    
    local Connections = {}
    local Threads = {}
    
    -- ============================================================
    -- UTILITY FUNCTIONS
    -- ============================================================
    local function SafeDisconnect(name)
        if Connections[name] then
            pcall(function() Connections[name]:Disconnect() end)
            Connections[name] = nil
        end
    end
    
    local function SafeCancel(name)
        if Threads[name] then
            pcall(function() task.cancel(Threads[name]) end)
            Threads[name] = nil
        end
    end
    
    local function DisconnectAll()
        for name in pairs(Connections) do
            SafeDisconnect(name)
        end
    end
    
    local function CancelAllThreads()
        for name in pairs(Threads) do
            SafeCancel(name)
        end
    end
    
    -- ============================================================
    -- GAME-SPECIFIC HELPER FUNCTIONS
    -- ============================================================
    local function GetPlayerPlot()
        local plotVal = LocalPlayer:FindFirstChild("Plot")
        if plotVal and plotVal:IsA("ObjectValue") and plotVal.Value then
            return plotVal.Value
        end
        
        local plots = Workspace:FindFirstChild("Plots")
        if plots then
            for _, plot in ipairs(plots:GetChildren()) do
                if plot:GetAttribute("Plr") == LocalPlayer.Name then
                    return plot
                end
            end
        end
        
        return nil
    end
    
    local function GetMutations()
        local mutations = {}
        local seen = {}
        
        local plot = GetPlayerPlot()
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
    
    local function GetWateringCans()
        local cans = {}
        local seen = {}
        
        local plot = GetPlayerPlot()
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
    
    local function GetStealableCans()
        local stealable = {}
        local myPlot = GetPlayerPlot()
        local plots = Workspace:FindFirstChild("Plots")
        
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
    
    local function GetMainTree()
        local plot = GetPlayerPlot()
        if plot then
            local contents = plot:FindFirstChild("PlotContents")
            if contents then
                return contents:FindFirstChild("Tree")
            end
        end
        return nil
    end
    
    local function GetWateringCanLevels()
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
    
    local function GetHighestWaterLevel()
        local highest = 0
        for _, level in pairs(GetWateringCanLevels()) do
            if level > highest then
                highest = level
            end
        end
        return highest
    end
    
    local function ShouldAutoWater()
        return GetHighestWaterLevel() >= Config.WaterLevelThreshold
    end
    
    local function GetLowestLevelCanSlot()
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
    
    local function IsPurifierEmpty()
        local plot = GetPlayerPlot()
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
    
    local function GetCoinsValue()
        local ls = LocalPlayer:FindFirstChild("leaderstats")
        if ls then
            local coins = ls:FindFirstChild("💵 Coins")
            if coins then return tostring(coins.Value) end
        end
        return "0"
    end
    
    local function GetPrestigesValue()
        local ls = LocalPlayer:FindFirstChild("leaderstats")
        if ls then
            local prestiges = ls:FindFirstChild("👑 Prestiges")
            if prestiges then return prestiges.Value end
        end
        return 0
    end
    
    local function HasWateringCans()
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
    
    -- ============================================================
    -- INPUT SIMULATION
    -- ============================================================
    local function PressKey(keyCode)
        pcall(function()
            VirtualInputManager:SendKeyEvent(true, keyCode, false, game)
            task.wait(TIMING.KEY_PRESS_DURATION)
            VirtualInputManager:SendKeyEvent(false, keyCode, false, game)
        end)
    end
    
    local function ClickMouse()
        pcall(function()
            VirtualInputManager:SendMouseButtonEvent(0, 0, 0, true, game, 1)
            task.wait(TIMING.CLICK_DURATION)
            VirtualInputManager:SendMouseButtonEvent(0, 0, 0, false, game, 1)
        end)
    end
    
    local HotbarKeys = {
        Enum.KeyCode.Two, Enum.KeyCode.Three, Enum.KeyCode.Four,
        Enum.KeyCode.Five, Enum.KeyCode.Six, Enum.KeyCode.Seven,
        Enum.KeyCode.Eight, Enum.KeyCode.Nine,
    }
    
    -- ============================================================
    -- CORE ACTION FUNCTIONS
    -- ============================================================
    local function TapTree()
        if not TapButtonClick then return end
        local plot = GetPlayerPlot()
        if plot then
            pcall(function() TapButtonClick:FireServer(plot) end)
        end
    end
    
    local function HitMutation(mutation)
        if not mutation or not mutation.Parent then return end
        if TreeClick then
            pcall(function() TreeClick:InvokeServer(mutation) end)
        end
        if AxeSwing then
            pcall(function() AxeSwing:FireServer() end)
        end
    end
    
    local function HitAllMutations()
        local mutations = GetMutations()
        for _, mutation in ipairs(mutations) do
            if not Config.AutoMutations or not State.Running then break end
            HitMutation(mutation)
            task.wait(TIMING.MUTATION_HIT_DELAY)
        end
    end
    
    local function CollectAllCoins()
        local char = LocalPlayer.Character
        local root = char and char:FindFirstChild("HumanoidRootPart")
        if not root then return end
        
        local originalCFrame = root.CFrame
        local orbsFolder = Workspace:FindFirstChild("Orbs")
        
        if orbsFolder then
            for _, coin in ipairs(orbsFolder:GetChildren()) do
                if not Config.AutoCollectCoins or not State.Running then break end
                if coin and coin.Parent and coin:IsA("BasePart") and coin:GetAttribute("CanCollect") then
                    pcall(function() root.CFrame = coin.CFrame end)
                    
                    if firetouchinterest then
                        pcall(function()
                            firetouchinterest(root, coin, 0)
                            firetouchinterest(root, coin, 1)
                        end)
                    end
                    
                    if CollectCoin then
                        pcall(function() CollectCoin:FireServer(coin) end)
                    end
                    
                    task.wait(TIMING.COIN_COLLECT_DELAY)
                end
            end
        end
        
        pcall(function() root.CFrame = originalCFrame end)
    end
    
    local function StealCan(can)
        if not can or not can.Parent then return end
        if ClickWateringCan then
            pcall(function() ClickWateringCan:FireServer(can) end)
        end
    end
    
    local function StealAllCans()
        local cans = GetStealableCans()
        for _, can in ipairs(cans) do
            if not Config.AutoSteal or not State.Running then break end
            StealCan(can)
            task.wait(TIMING.STEAL_DELAY)
        end
        return #cans
    end
    
    local function UseCans()
        if State.UsingCans then return end
        State.UsingCans = true
        
        if not HasWateringCans() then
            PressKey(Enum.KeyCode.One)
            State.UsingCans = false
            return
        end
        
        for _, keyCode in ipairs(HotbarKeys) do
            if not Config.AutoUseCans or not State.Running then break end
            PressKey(keyCode)
            task.wait(TIMING.USE_CANS_KEY_DELAY)
            ClickMouse()
            task.wait(TIMING.USE_CANS_CLICK_DELAY)
        end
        
        PressKey(Enum.KeyCode.One)
        State.UsingCans = false
    end
    
    local function PickupCans()
        if State.PickingUpCans then return end
        State.PickingUpCans = true
        
        local cans = GetWateringCans()
        if #cans == 0 then
            PressKey(Enum.KeyCode.One)
            State.PickingUpCans = false
            return
        end
        
        for _, can in ipairs(cans) do
            if not Config.AutoPickupCans or not State.Running then break end
            if ClickWateringCan then
                pcall(function() ClickWateringCan:FireServer(can) end)
            end
            task.wait(TIMING.PICKUP_CANS_DELAY)
        end
        
        local tree = GetMainTree()
        if tree and ClickWateringCan then
            pcall(function() ClickWateringCan:FireServer(tree) end)
        end
        
        local plot = GetPlayerPlot()
        if plot and ClickWateringCan then
            pcall(function() ClickWateringCan:FireServer(plot) end)
        end
        
        PressKey(Enum.KeyCode.One)
        State.PickingUpCans = false
    end
    
    local function ClaimPurifier()
        if ClaimWaterPurifier then
            pcall(function() ClaimWaterPurifier:InvokeServer() end)
        end
    end
    
    local function FillPurifier()
        local slot, level = GetLowestLevelCanSlot()
        if slot and level < 100 and WaterPurifier then
            pcall(function() WaterPurifier:InvokeServer(slot) end)
        end
    end
    
    local function DoPrestige()
        if Prestige then
            pcall(function() Prestige:InvokeServer() end)
        end
    end
    
    -- ============================================================
    -- AUTO SYSTEMS
    -- ============================================================
    local function StartAutoTap()
        if State.Tapping then return end
        State.Tapping = true
        
        for i = 1, Config.TapThreads do
            Threads["Tap_" .. i] = task.spawn(function()
                while Config.AutoTap and State.Running do
                    TapTree()
                    task.wait(TIMING.TAP_SPEED)
                end
            end)
        end
        
        Threads["TapMonitor"] = task.spawn(function()
            while Config.AutoTap and State.Running do
                task.wait(0.1)
            end
            State.Tapping = false
        end)
    end
    
    local function StopAutoTap()
        Config.AutoTap = false
        for i = 1, Config.TapThreads do
            SafeCancel("Tap_" .. i)
        end
        SafeCancel("TapMonitor")
        State.Tapping = false
    end
    
    local function StartAutoMutations()
        if State.HittingTrees then return end
        State.HittingTrees = true
        
        Threads["Mutations"] = task.spawn(function()
            while Config.AutoMutations and State.Running do
                HitAllMutations()
                task.wait(TIMING.MUTATION_LOOP_DELAY)
            end
            State.HittingTrees = false
        end)
    end
    
    local function StopAutoMutations()
        Config.AutoMutations = false
        SafeCancel("Mutations")
        State.HittingTrees = false
    end
    
    local function StartAutoCollect()
        if State.CollectingCoins then return end
        State.CollectingCoins = true
        
        Threads["Collect"] = task.spawn(function()
            while Config.AutoCollectCoins and State.Running do
                CollectAllCoins()
                task.wait(TIMING.COIN_LOOP_DELAY)
            end
            State.CollectingCoins = false
        end)
    end
    
    local function StopAutoCollect()
        Config.AutoCollectCoins = false
        SafeCancel("Collect")
        State.CollectingCoins = false
    end
    
    local function StartAutoPrestige()
        if State.Prestiging then return end
        State.Prestiging = true
        
        Threads["Prestige"] = task.spawn(function()
            while Config.AutoPrestige and State.Running do
                DoPrestige()
                task.wait(TIMING.PRESTIGE_INTERVAL)
            end
            State.Prestiging = false
        end)
    end
    
    local function StopAutoPrestige()
        Config.AutoPrestige = false
        SafeCancel("Prestige")
        State.Prestiging = false
    end
    
    local function StartAutoUseCans()
        Threads["UseCans"] = task.spawn(function()
            while Config.AutoUseCans and State.Running do
                if ShouldAutoWater() then
                    task.spawn(UseCans)
                end
                task.wait(TIMING.USE_CANS_INTERVAL)
            end
        end)
    end
    
    local function StopAutoUseCans()
        Config.AutoUseCans = false
        SafeCancel("UseCans")
    end
    
    local function StartAutoPickupCans()
        Threads["PickupCans"] = task.spawn(function()
            while Config.AutoPickupCans and State.Running do
                if ShouldAutoWater() then
                    task.spawn(PickupCans)
                end
                task.wait(TIMING.PICKUP_CANS_INTERVAL)
            end
        end)
    end
    
    local function StopAutoPickupCans()
        Config.AutoPickupCans = false
        SafeCancel("PickupCans")
    end
    
    local function StartAutoClaimPurifier()
        Threads["ClaimPurifier"] = task.spawn(function()
            while Config.AutoClaimPurifier and State.Running do
                ClaimPurifier()
                task.wait(TIMING.CLAIM_PURIFIER_INTERVAL)
            end
        end)
    end
    
    local function StopAutoClaimPurifier()
        Config.AutoClaimPurifier = false
        SafeCancel("ClaimPurifier")
    end
    
    local function StartAutoFillPurifier()
        Threads["FillPurifier"] = task.spawn(function()
            while Config.AutoFillPurifier and State.Running do
                if IsPurifierEmpty() then
                    FillPurifier()
                    task.wait(TIMING.FILL_PURIFIER_DELAY)
                end
                task.wait(TIMING.FILL_PURIFIER_INTERVAL)
            end
        end)
    end
    
    local function StopAutoFillPurifier()
        Config.AutoFillPurifier = false
        SafeCancel("FillPurifier")
    end
    
    local function StartAutoSteal()
        if State.Stealing then return end
        State.Stealing = true
        
        Threads["Steal"] = task.spawn(function()
            while Config.AutoSteal and State.Running do
                local stolen = StealAllCans()
                task.wait(TIMING.STEAL_LOOP_INTERVAL)
            end
            State.Stealing = false
        end)
    end
    
    local function StopAutoSteal()
        Config.AutoSteal = false
        SafeCancel("Steal")
        State.Stealing = false
    end
    
    -- ============================================================
    -- CLEANUP FUNCTION
    -- ============================================================
    local function Cleanup()
        State.Running = false
        
        for k, v in pairs(Config) do
            if type(v) == "boolean" then
                Config[k] = false
            end
        end
        
        for k, v in pairs(State) do
            if type(v) == "boolean" and k ~= "Running" then
                State[k] = false
            end
        end
        
        task.wait(0.1)
        
        DisconnectAll()
        CancelAllThreads()
    end
    
    -- ============================================================
    -- EXPORT TO GLOBAL
    -- ============================================================
    _G.SynceHub = _G.SynceHub or {}
    _G.SynceHub.ChopTree = {
        -- Config & State
        Config = Config,
        State = State,
        TIMING = TIMING,
        
        -- Core Actions
        TapTree = TapTree,
        HitAllMutations = HitAllMutations,
        CollectAllCoins = CollectAllCoins,
        UseCans = UseCans,
        PickupCans = PickupCans,
        ClaimPurifier = ClaimPurifier,
        FillPurifier = FillPurifier,
        DoPrestige = DoPrestige,
        StealCan = StealCan,
        StealAllCans = StealAllCans,
        
        -- Helper Functions
        GetPlayerPlot = GetPlayerPlot,
        GetMutations = GetMutations,
        GetWateringCans = GetWateringCans,
        GetStealableCans = GetStealableCans,
        GetMainTree = GetMainTree,
        GetWateringCanLevels = GetWateringCanLevels,
        GetHighestWaterLevel = GetHighestWaterLevel,
        GetLowestLevelCanSlot = GetLowestLevelCanSlot,
        IsPurifierEmpty = IsPurifierEmpty,
        ShouldAutoWater = ShouldAutoWater,
        HasWateringCans = HasWateringCans,
        GetCoinsValue = GetCoinsValue,
        GetPrestigesValue = GetPrestigesValue,
        
        -- Auto Systems
        StartAutoTap = StartAutoTap,
        StopAutoTap = StopAutoTap,
        StartAutoMutations = StartAutoMutations,
        StopAutoMutations = StopAutoMutations,
        StartAutoCollect = StartAutoCollect,
        StopAutoCollect = StopAutoCollect,
        StartAutoPrestige = StartAutoPrestige,
        StopAutoPrestige = StopAutoPrestige,
        StartAutoUseCans = StartAutoUseCans,
        StopAutoUseCans = StopAutoUseCans,
        StartAutoPickupCans = StartAutoPickupCans,
        StopAutoPickupCans = StopAutoPickupCans,
        StartAutoClaimPurifier = StartAutoClaimPurifier,
        StopAutoClaimPurifier = StopAutoClaimPurifier,
        StartAutoFillPurifier = StartAutoFillPurifier,
        StopAutoFillPurifier = StopAutoFillPurifier,
        StartAutoSteal = StartAutoSteal,
        StopAutoSteal = StopAutoSteal,
        
        -- Cleanup
        Cleanup = Cleanup,
    }
    
    WindUI:Notify({
        Title = "Chop Your Tree",
        Content = "Features loaded successfully!",
        Duration = 3,
        Icon = "check",
    })
end

return FeatureModule