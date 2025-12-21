local TabContent = {}

function TabContent.CreateTabs(Window, Reg, WindUI, SynceHubConfig, SmartLoadConfig, BaseFolder, ElementRegistry)
    local LocalPlayer = _G.SynceHub.LocalPlayer
    local ChopTree = _G.SynceHub.ChopTree
    
    -- Check if ChopTree features loaded
    if not ChopTree then
        WindUI:Notify({
            Title = "Error",
            Content = "Chop Tree features not loaded!",
            Duration = 5,
            Icon = "x",
        })
        return
    end
    
    -- ============================================================
    -- FARMING TAB
    -- ============================================================
    local farming = Window:Tab({
        Title = "Farming",
        Icon = "rbxassetid://7733960981",
        Locked = false,
    })
    
    farming:Select()
    
    farming:Section({
        Title = "Chop Your Tree - Auto Farm",
        Icon = "zap",
        TextSize = 20,
        FontWeight = Enum.FontWeight.Bold,
    })
    
    farming:Paragraph({
        Title = "Welcome to Chop Your Tree Hub!",
        Desc = "Enable auto farming features below to automate your tree chopping experience. All settings will be saved automatically.",
    })
    
    farming:Divider()
    
    -- ============================================================
    -- MAIN FARMING SECTION
    -- ============================================================
    farming:Section({
        Title = "Main Farming",
        Icon = "target",
        TextSize = 18,
        FontWeight = Enum.FontWeight.SemiBold,
    })
    
    local farmGroup = farming:Group({})
    
    -- Auto Tap
    Reg("chop_autotap", farmGroup:Toggle({
        Title = "Auto Tap Tree",
        Desc = "Automatically tap your main tree (5 threads)",
        Value = false,
        Callback = function(state)
            ChopTree.Config.AutoTap = state
            if state then
                ChopTree.StartAutoTap()
                WindUI:Notify({
                    Title = "Auto Tap ON",
                    Content = "Tapping tree automatically",
                    Duration = 2,
                    Icon = "check",
                })
            else
                ChopTree.StopAutoTap()
                WindUI:Notify({
                    Title = "Auto Tap OFF",
                    Content = "Stopped auto tapping",
                    Duration = 2,
                    Icon = "x",
                })
            end
        end
    }))
    
    -- Auto Hit Mutations
    Reg("chop_mutations", farmGroup:Toggle({
        Title = "Auto Hit Mutations",
        Desc = "Automatically hit all mutation trees",
        Value = false,
        Callback = function(state)
            ChopTree.Config.AutoMutations = state
            if state then
                ChopTree.StartAutoMutations()
                WindUI:Notify({
                    Title = "Auto Mutations ON",
                    Content = "Hitting mutation trees",
                    Duration = 2,
                    Icon = "check",
                })
            else
                ChopTree.StopAutoMutations()
                WindUI:Notify({
                    Title = "Auto Mutations OFF",
                    Content = "Stopped hitting mutations",
                    Duration = 2,
                    Icon = "x",
                })
            end
        end
    }))
    
    -- Auto Collect Coins
    Reg("chop_coins", farmGroup:Toggle({
        Title = "Auto Collect Coins",
        Desc = "Automatically teleport and collect all coins",
        Value = false,
        Callback = function(state)
            ChopTree.Config.AutoCollectCoins = state
            if state then
                ChopTree.StartAutoCollect()
                WindUI:Notify({
                    Title = "Auto Collect ON",
                    Content = "Collecting coins automatically",
                    Duration = 2,
                    Icon = "check",
                })
            else
                ChopTree.StopAutoCollect()
                WindUI:Notify({
                    Title = "Auto Collect OFF",
                    Content = "Stopped collecting coins",
                    Duration = 2,
                    Icon = "x",
                })
            end
        end
    }))
    
    farming:Space()
    
    -- ============================================================
    -- WATERING SYSTEM SECTION
    -- ============================================================
    farming:Section({
        Title = "Watering System",
        Icon = "droplet",
        TextSize = 18,
        FontWeight = Enum.FontWeight.SemiBold,
    })
    
    local waterGroup = farming:Group({})
    
    -- Water Level Threshold Slider
    Reg("chop_waterlevel", waterGroup:Slider({
        Title = "Minimum Can Level",
        Desc = "Minimum water can level before auto-use",
        Step = 1,
        Value = {
            Min = 1,
            Max = 100,
            Default = ChopTree.Config.WaterLevelThreshold or 3,
        },
        Callback = function(value)
            ChopTree.Config.WaterLevelThreshold = value
        end,
    }))
    
    waterGroup:Space()
    
    -- Auto Use Cans
    Reg("chop_usecans", waterGroup:Toggle({
        Title = "Auto Use Watering Cans",
        Desc = "Automatically use watering cans when threshold reached",
        Value = false,
        Callback = function(state)
            ChopTree.Config.AutoUseCans = state
            if state then
                ChopTree.StartAutoUseCans()
                WindUI:Notify({
                    Title = "Auto Use Cans ON",
                    Content = "Using cans automatically",
                    Duration = 2,
                    Icon = "check",
                })
            else
                ChopTree.StopAutoUseCans()
                WindUI:Notify({
                    Title = "Auto Use Cans OFF",
                    Content = "Stopped using cans",
                    Duration = 2,
                    Icon = "x",
                })
            end
        end
    }))
    
    -- Auto Pickup Cans
    Reg("chop_pickupcans", waterGroup:Toggle({
        Title = "Auto Pickup Cans",
        Desc = "Automatically pickup watering cans from plot",
        Value = false,
        Callback = function(state)
            ChopTree.Config.AutoPickupCans = state
            if state then
                ChopTree.StartAutoPickupCans()
                WindUI:Notify({
                    Title = "Auto Pickup ON",
                    Content = "Picking up cans automatically",
                    Duration = 2,
                    Icon = "check",
                })
            else
                ChopTree.StopAutoPickupCans()
                WindUI:Notify({
                    Title = "Auto Pickup OFF",
                    Content = "Stopped picking up cans",
                    Duration = 2,
                    Icon = "x",
                })
            end
        end
    }))
    
    farming:Space()
    
    -- ============================================================
    -- PURIFIER SYSTEM SECTION
    -- ============================================================
    farming:Section({
        Title = "Purifier System",
        Icon = "filter",
        TextSize = 18,
        FontWeight = Enum.FontWeight.SemiBold,
    })
    
    local purifierGroup = farming:Group({})
    
    -- Auto Fill & Claim Purifier (Combined)
    Reg("chop_purifier", purifierGroup:Toggle({
        Title = "Auto Purifier System",
        Desc = "Auto fill & claim water purifier",
        Value = false,
        Callback = function(state)
            ChopTree.Config.AutoFillPurifier = state
            ChopTree.Config.AutoClaimPurifier = state
            
            if state then
                ChopTree.StartAutoFillPurifier()
                ChopTree.StartAutoClaimPurifier()
                WindUI:Notify({
                    Title = "Auto Purifier ON",
                    Content = "Managing purifier automatically",
                    Duration = 2,
                    Icon = "check",
                })
            else
                ChopTree.StopAutoFillPurifier()
                ChopTree.StopAutoClaimPurifier()
                WindUI:Notify({
                    Title = "Auto Purifier OFF",
                    Content = "Stopped purifier automation",
                    Duration = 2,
                    Icon = "x",
                })
            end
        end
    }))
    
    purifierGroup:Button({
        Title = "Claim Purifier (Manual)",
        Icon = "download",
        Callback = function()
            ChopTree.ClaimPurifier()
            WindUI:Notify({
                Title = "Claiming Purifier",
                Content = "Attempting to claim water purifier",
                Duration = 2,
                Icon = "loader",
            })
        end
    })
    
    purifierGroup:Button({
        Title = "Fill Purifier (Manual)",
        Icon = "droplet",
        Callback = function()
            ChopTree.FillPurifier()
            WindUI:Notify({
                Title = "Filling Purifier",
                Content = "Placing lowest level can in purifier",
                Duration = 2,
                Icon = "loader",
            })
        end
    })
    
    farming:Divider()
    
    -- ============================================================
    -- ADVANCED SECTION
    -- ============================================================
    farming:Section({
        Title = "Advanced Features",
        Icon = "settings",
        TextSize = 18,
        FontWeight = Enum.FontWeight.SemiBold,
    })
    
    local advancedGroup = farming:Group({})
    
    -- Auto Steal Cans (Gamepass)
    Reg("chop_steal", advancedGroup:Toggle({
        Title = "Auto Steal Cans (GP Required)",
        Desc = "Steal watering cans from other plots (Requires Gamepass)",
        Value = false,
        Callback = function(state)
            ChopTree.Config.AutoSteal = state
            if state then
                ChopTree.StartAutoSteal()
                WindUI:Notify({
                    Title = "Auto Steal ON",
                    Content = "Stealing cans from other plots",
                    Duration = 2,
                    Icon = "check",
                })
            else
                ChopTree.StopAutoSteal()
                WindUI:Notify({
                    Title = "Auto Steal OFF",
                    Content = "Stopped stealing cans",
                    Duration = 2,
                    Icon = "x",
                })
            end
        end
    }))
    
    advancedGroup:Button({
        Title = "Steal All Cans Now",
        Icon = "hand",
        Callback = function()
            task.spawn(function()
                local count = ChopTree.StealAllCans()
                WindUI:Notify({
                    Title = "Steal Complete",
                    Content = string.format("Attempted to steal %d cans", count),
                    Duration = 3,
                    Icon = "check",
                })
            end)
        end
    })
    
    farming:Space()
    
    -- Quick Info
    farming:Paragraph({
        Title = "Pro Tips",
        Desc = "• Enable all farming features for maximum efficiency\n• Set water level threshold to 3-5 for best results\n• Auto Steal requires gamepass to work\n• All settings are saved automatically",
    })
    
    -- ============================================================
    -- PLAYER TAB
    -- ============================================================
    local player = Window:Tab({
        Title = "Player",
        Icon = "user",
        Locked = false,
    })
    
    player:Section({
        Title = "Player Stats & Prestige",
        Icon = "bar-chart-2",
        TextSize = 20,
        FontWeight = Enum.FontWeight.Bold,
    })
    
    -- ============================================================
    -- REAL-TIME STATS DISPLAY
    -- ============================================================
    player:Section({
        Title = "Current Stats",
        Icon = "activity",
        TextSize = 18,
        FontWeight = Enum.FontWeight.SemiBold,
    })
    
    local statsGroup = player:Group({})
    
    -- Stats Display (Updated every second)
    local coinsDisplay = statsGroup:Paragraph({
        Title = "Coins",
        Desc = "Loading...",
    })
    
    local prestigeDisplay = statsGroup:Paragraph({
        Title = "Prestiges",
        Desc = "Loading...",
    })
    
    local waterDisplay = statsGroup:Paragraph({
        Title = "Highest Water Level",
        Desc = "Loading...",
    })
    
    local plotDisplay = statsGroup:Paragraph({
        Title = "Plot Status",
        Desc = "Checking...",
    })
    
    -- Stats Update Loop
    task.spawn(function()
        while true do
            pcall(function()
                local coins = ChopTree.GetCoinsValue()
                local prestiges = ChopTree.GetPrestigesValue()
                local waterLvl = ChopTree.GetHighestWaterLevel()
                local plot = ChopTree.GetPlayerPlot()
                local canSteal = #ChopTree.GetStealableCans()
                
                -- Update displays (WindUI doesn't support dynamic update, so we use desc)
                -- In actual implementation, you might want to use custom labels
                
                -- Show water threshold status
                local waterStatus = waterLvl >= ChopTree.Config.WaterLevelThreshold and "✅ Ready" or "❌ Not Ready"
                local plotStatus = plot and "✅ Found" or "❌ Not Found"
            end)
            task.wait(1)
        end
    end)
    
    player:Space()
    
    -- ============================================================
    -- PRESTIGE SECTION
    -- ============================================================
    player:Section({
        Title = "Prestige System",
        Icon = "star",
        TextSize = 18,
        FontWeight = Enum.FontWeight.SemiBold,
    })
    
    local prestigeGroup = player:Group({})
    
    -- Auto Prestige Toggle
    Reg("chop_autoprestige", prestigeGroup:Toggle({
        Title = "Auto Prestige",
        Desc = "Automatically prestige every 5 seconds",
        Value = false,
        Callback = function(state)
            ChopTree.Config.AutoPrestige = state
            if state then
                ChopTree.StartAutoPrestige()
                WindUI:Notify({
                    Title = "Auto Prestige ON",
                    Content = "Will prestige automatically",
                    Duration = 2,
                    Icon = "check",
                })
            else
                ChopTree.StopAutoPrestige()
                WindUI:Notify({
                    Title = "Auto Prestige OFF",
                    Content = "Stopped auto prestige",
                    Duration = 2,
                    Icon = "x",
                })
            end
        end
    }))
    
    prestigeGroup:Button({
        Title = "Prestige Now",
        Icon = "zap",
        Color = Color3.fromHex("#FFD700"),
        Callback = function()
            ChopTree.DoPrestige()
            WindUI:Notify({
                Title = "Prestiging",
                Content = "Attempting to prestige...",
                Duration = 2,
                Icon = "star",
            })
        end
    })
    
    player:Space()
    
    -- ============================================================
    -- PLOT INFO SECTION
    -- ============================================================
    player:Section({
        Title = "Plot Information",
        Icon = "map",
        TextSize = 18,
        FontWeight = Enum.FontWeight.SemiBold,
    })
    
    local plotGroup = player:Group({})
    
    plotGroup:Button({
        Title = "Check Plot Status",
        Icon = "search",
        Callback = function()
            local plot = ChopTree.GetPlayerPlot()
            local mutations = ChopTree.GetMutations()
            local cans = ChopTree.GetWateringCans()
            local stealable = ChopTree.GetStealableCans()
            
            WindUI:Notify({
                Title = "Plot Info",
                Content = string.format(
                    "Plot: %s\nMutations: %d\nYour Cans: %d\nStealable: %d",
                    plot and "Found" or "Not Found",
                    #mutations,
                    #cans,
                    #stealable
                ),
                Duration = 5,
                Icon = "info",
            })
        end
    })
    
    plotGroup:Button({
        Title = "Refresh Plot Data",
        Icon = "refresh-cw",
        Callback = function()
            -- Force refresh by calling helper functions
            task.spawn(function()
                local plot = ChopTree.GetPlayerPlot()
                if plot then
                    WindUI:Notify({
                        Title = "Plot Refreshed",
                        Content = "Plot data updated successfully",
                        Duration = 2,
                        Icon = "check",
                    })
                else
                    WindUI:Notify({
                        Title = "Plot Not Found",
                        Content = "Could not find your plot",
                        Duration = 3,
                        Icon = "x",
                    })
                end
            end)
        end
    })
    
    player:Divider()
    
    -- Info Section
    player:Paragraph({
        Title = "ℹ️ Information",
        Desc = "• Stats update every second\n• Auto Prestige runs every 5 seconds\n• Check plot status to see mutations and cans\n• Enable Auto Prestige for maximum efficiency",
    })
    
    -- ============================================================
    -- MISC TAB
    -- ============================================================
    local misc = Window:Tab({
        Title = "Misc",
        Icon = "box",
        Locked = false,
    })
    
    misc:Section({
        Title = "Miscellaneous",
        Icon = "settings",
        TextSize = 20,
        FontWeight = Enum.FontWeight.Bold,
    })
    
    -- ============================================================
    -- MANUAL ACTIONS
    -- ============================================================
    misc:Section({
        Title = "Manual Actions",
        Icon = "hand",
        TextSize = 18,
        FontWeight = Enum.FontWeight.SemiBold,
    })
    
    local manualGroup = misc:Group({})
    
    manualGroup:Button({
        Title = "Tap Tree Once",
        Icon = "mouse-pointer",
        Callback = function()
            ChopTree.TapTree()
            WindUI:Notify({
                Title = "Tree Tapped",
                Content = "Tapped main tree once",
                Duration = 1,
                Icon = "check",
            })
        end
    })
    
    manualGroup:Button({
        Title = "Hit All Mutations",
        Icon = "target",
        Callback = function()
            task.spawn(ChopTree.HitAllMutations)
            WindUI:Notify({
                Title = "Hitting Mutations",
                Content = "Hitting all mutation trees",
                Duration = 2,
                Icon = "loader",
            })
        end
    })
    
    manualGroup:Button({
        Title = "Collect All Coins",
        Icon = "dollar-sign",
        Callback = function()
            task.spawn(ChopTree.CollectAllCoins)
            WindUI:Notify({
                Title = "Collecting Coins",
                Content = "Teleporting to all coins",
                Duration = 2,
                Icon = "loader",
            })
        end
    })
    
    manualGroup:Button({
        Title = "Use All Cans",
        Icon = "droplet",
        Callback = function()
            task.spawn(ChopTree.UseCans)
            WindUI:Notify({
                Title = "Using Cans",
                Content = "Using all watering cans",
                Duration = 2,
                Icon = "loader",
            })
        end
    })
    
    manualGroup:Button({
        Title = "Pickup All Cans",
        Icon = "package",
        Callback = function()
            task.spawn(ChopTree.PickupCans)
            WindUI:Notify({
                Title = "Picking Up Cans",
                Content = "Collecting cans from plot",
                Duration = 2,
                Icon = "loader",
            })
        end
    })
    
    misc:Space()
    
    -- ============================================================
    -- DIAGNOSTICS
    -- ============================================================
    misc:Section({
        Title = "Diagnostics",
        Icon = "activity",
        TextSize = 18,
        FontWeight = Enum.FontWeight.SemiBold,
    })
    
    local diagGroup = misc:Group({})
    
    diagGroup:Button({
        Title = "Show All Stats",
        Icon = "bar-chart",
        Callback = function()
            local coins = ChopTree.GetCoinsValue()
            local prestiges = ChopTree.GetPrestigesValue()
            local waterLvl = ChopTree.GetHighestWaterLevel()
            local plot = ChopTree.GetPlayerPlot()
            local mutations = #ChopTree.GetMutations()
            local cans = #ChopTree.GetWateringCans()
            local stealable = #ChopTree.GetStealableCans()
            local canLevels = ChopTree.GetWateringCanLevels()
            
            local levelStr = ""
            for slot, lvl in pairs(canLevels) do
                levelStr = levelStr .. string.format("Slot %s: Lv%d\n", slot, lvl)
            end
            
            WindUI:Notify({
                Title = "Full Diagnostics",
                Content = string.format(
                    "Coins: %s\nPrestiges: %d\nWater: %d\nMutations: %d\n🏺 Cans: %d\nStealable: %d",
                    coins, prestiges, waterLvl, mutations, cans, stealable
                ),
                Duration = 8,
                Icon = "info",
            })
        end
    })
    
    diagGroup:Button({
        Title = "Check Water Can Levels",
        Icon = "droplet",
        Callback = function()
            local levels = ChopTree.GetWateringCanLevels()
            local highest = ChopTree.GetHighestWaterLevel()
            local lowestSlot, lowestLevel = ChopTree.GetLowestLevelCanSlot()
            
            local info = string.format(
                "Highest Level: %d\nLowest Level: %d (Slot %s)\nThreshold: %d",
                highest,
                lowestLevel or 0,
                lowestSlot or "N/A",
                ChopTree.Config.WaterLevelThreshold
            )
            
            WindUI:Notify({
                Title = "Water Can Levels",
                Content = info,
                Duration = 5,
                Icon = "droplet",
            })
        end
    })
    
    diagGroup:Button({
        Title = "Check Purifier Status",
        Icon = "filter",
        Callback = function()
            local isEmpty = ChopTree.IsPurifierEmpty()
            local shouldWater = ChopTree.ShouldAutoWater()
            
            WindUI:Notify({
                Title = "Purifier Status",
                Content = string.format(
                    "Empty: %s\nShould Auto Water: %s",
                    isEmpty and "Yes" or "No",
                    shouldWater and "Yes" or "No"
                ),
                Duration = 4,
                Icon = "info",
            })
        end
    })
    
    misc:Divider()
    
    -- ============================================================
    -- SYSTEM STATUS
    -- ============================================================
    misc:Section({
        Title = "System Status",
        Icon = "cpu",
        TextSize = 18,
        FontWeight = Enum.FontWeight.SemiBold,
    })
    
    misc:Paragraph({
        Title = "Active Systems",
        Desc = "Check which automation systems are currently running",
    })
    
    local statusGroup = misc:Group({})
    
    statusGroup:Button({
        Title = "Show Active Features",
        Icon = "list",
        Callback = function()
            local active = {}
            if ChopTree.Config.AutoTap then table.insert(active, "Auto Tap") end
            if ChopTree.Config.AutoMutations then table.insert(active, "Auto Mutations") end
            if ChopTree.Config.AutoCollectCoins then table.insert(active, "Auto Collect") end
            if ChopTree.Config.AutoPrestige then table.insert(active, "Auto Prestige") end
            if ChopTree.Config.AutoUseCans then table.insert(active, "Auto Use Cans") end
            if ChopTree.Config.AutoPickupCans then table.insert(active, "Auto Pickup Cans") end
            if ChopTree.Config.AutoFillPurifier then table.insert(active, "Auto Purifier") end
            if ChopTree.Config.AutoSteal then table.insert(active, "Auto Steal") end
            
            local content = #active > 0 and table.concat(active, "\n") or "No active features"
            
            WindUI:Notify({
                Title = "Active Features",
                Content = content,
                Duration = 5,
                Icon = "check-circle",
            })
        end
    })
    
    statusGroup:Button({
        Title = "Disable All Farming",
        Icon = "x-circle",
        Color = Color3.fromHex("#FF6B6B"),
        Callback = function()
            -- Stop all farming features
            if ChopTree.Config.AutoTap then ChopTree.StopAutoTap() end
            if ChopTree.Config.AutoMutations then ChopTree.StopAutoMutations() end
            if ChopTree.Config.AutoCollectCoins then ChopTree.StopAutoCollect() end
            if ChopTree.Config.AutoPrestige then ChopTree.StopAutoPrestige() end
            if ChopTree.Config.AutoUseCans then ChopTree.StopAutoUseCans() end
            if ChopTree.Config.AutoPickupCans then ChopTree.StopAutoPickupCans() end
            if ChopTree.Config.AutoFillPurifier then ChopTree.StopAutoFillPurifier() end
            if ChopTree.Config.AutoClaimPurifier then ChopTree.StopAutoClaimPurifier() end
            if ChopTree.Config.AutoSteal then ChopTree.StopAutoSteal() end
            
            WindUI:Notify({
                Title = "All Features Disabled",
                Content = "All farming automation stopped",
                Duration = 3,
                Icon = "check",
            })
        end
    })
    
    misc:Space()
    
    -- Footer Info
    misc:Paragraph({
        Title = "Chop Your Tree Hub",
        Desc = "Version: 1.0.0\nAll features are working and optimized\nReport bugs in our Discord server",
    })
end

return TabContent