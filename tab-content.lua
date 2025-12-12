-- SynceHub tab-content.lua - Tab Creation - PART 1
-- SALIN PART 1 DULU, LALU LANJUT KE PART 2

local TabContent = {}

function TabContent.CreateTabs(Window, Reg, WindUI, SynceHubConfig, SmartLoadConfig, BaseFolder, ElementRegistry)
    local LocalPlayer = _G.SynceHub.LocalPlayer
    local RepStorage = _G.SynceHub.RepStorage
    
    -- ============================================================
    -- HOME TAB
    -- ============================================================
    local home = Window:Tab({
        Title = "Home",
        Icon = "rbxassetid://7733960981",
        Locked = false,
    })
    
    home:Select()
    
    home:Section({
        Title = "Join Discord Server SynceHub",
        TextSize = 18,
    })

    home:Paragraph({
        Title = "SynceHub Community",
        Desc = "Join Our Community Discord Server to get the latest updates, support, and connect with other users!",
        Image = "rbxassetid://114915707934715",
        ImageSize = 24,
        Buttons = {
            {
                Title = "Copy Link",
                Icon = "link",
                Callback = function()
                    setclipboard("https://dsc.gg/Syncehub")
                    WindUI:Notify({
                        Title = "Link Copied!",
                        Content = "SynceHub Discord link successfully copied.",
                        Duration = 3,
                        Icon = "copy",
                    })
                end,
            }
        }
    })

    home:Divider()
    
    home:Section({
        Title = "What's New?",
        TextSize = 24,
        FontWeight = Enum.FontWeight.SemiBold,
    })

    home:Image({
        Image = "rbxassetid://114915707934715",
        AspectRatio = "16:9",
        Radius = 9,
    })

    home:Space()

    home:Paragraph({
        Title = "Version Beta",
        Desc = "- 13 Dec 2025",
    })
    
    home:Paragraph({
        Title = "Recent Updates",
        Desc = "• Added Plant Evolution support\n• Fixed config manager bugs\n• Improved error handling\n• Better notifications",
    })
    
    -- ============================================================
    -- PLANT EVOLUTION TAB
    -- ============================================================
    local plantTab = Window:Tab({
        Title = "Plant Evolution",
        Icon = "flower",
        Locked = false,
    })
    
    -- Plant Evolution Core Functions
    local PlantFunctions = {
        InfWins = function()
            pcall(function()
                RepStorage.Remote.Event.Egg.OpenEgg:FireServer(unpack({20, -50}))
            end)
        end,
        
        InfSpin = function()
            pcall(function()
                RepStorage.Remote.Function.Activity.TryDoSpin:InvokeServer(unpack({-100}))
                RepStorage.Remote.Function.Activity.TryDoSpin:InvokeServer(unpack({100}))
            end)
        end,
        
        BuyEggs = function(amount, eggType)
            amount = amount or _G.SynceHub.EggAmount or 20
            eggType = eggType or _G.SynceHub.EggType or 3
            pcall(function()
                RepStorage.Remote.Event.Egg.OpenEgg:FireServer(unpack({amount, eggType}))
            end)
        end,
        
        GetOPPets = function()
            pcall(function()
                RepStorage.Remote.Event.Activity.ActivityBuy:FireServer(unpack({2}))
            end)
        end,
        
        AddPetSlot = function()
            pcall(function()
                RepStorage.Remote.Event.Activity.ActivityBuy:FireServer(unpack({3}))
            end)
        end
    }
    
    -- Main Functions Section
    plantTab:Section({
        Title = "Main Functions",
        TextSize = 20,
    })
    
    plantTab:Button({
        Title = "Infinite Wins",
        Desc = "Execute infinite wins once",
        Icon = "trophy",
        Callback = function()
            PlantFunctions.InfWins()
            WindUI:Notify({
                Title = "Executed",
                Content = "Infinite Wins triggered",
                Duration = 2,
                Icon = "check"
            })
        end
    })
    
    plantTab:Button({
        Title = "Infinite Spin",
        Desc = "Execute infinite spin once",
        Icon = "rotate-cw",
        Callback = function()
            PlantFunctions.InfSpin()
            WindUI:Notify({
                Title = "Executed",
                Content = "Infinite Spin triggered",
                Duration = 2,
                Icon = "check"
            })
        end
    })
    
    plantTab:Button({
        Title = "Get OP Pets",
        Desc = "Get overpowered pets",
        Icon = "sparkles",
        Callback = function()
            PlantFunctions.GetOPPets()
            WindUI:Notify({
                Title = "Executed",
                Content = "OP Pets request sent",
                Duration = 2,
                Icon = "check"
            })
        end
    })
    
    plantTab:Button({
        Title = "Add Pet Slot",
        Desc = "Add additional pet slot",
        Icon = "plus-square",
        Callback = function()
            PlantFunctions.AddPetSlot()
            WindUI:Notify({
                Title = "Executed",
                Content = "Pet Slot added",
                Duration = 2,
                Icon = "check"
            })
        end
    })
    
    plantTab:Divider()
    
    -- Egg Settings Section
    plantTab:Section({
        Title = "Egg Settings",
        TextSize = 18,
    })
    
    Reg("PlantEgg_Amount", plantTab:Slider({
        Title = "Egg Amount",
        Desc = "Number of eggs to open",
        Min = 1,
        Max = 100,
        Default = 20,
        Callback = function(value)
            _G.SynceHub.EggAmount = value
        end
    }))
    
    Reg("PlantEgg_Type", plantTab:Dropdown({
        Title = "Egg Type",
        Desc = "Select egg type to open",
        Values = {"Basic (1)", "Premium (2)", "Best (3)"},
        Value = "Best (3)",
        Callback = function(value)
            if value == "Basic (1)" then
                _G.SynceHub.EggType = 1
            elseif value == "Premium (2)" then
                _G.SynceHub.EggType = 2
            else
                _G.SynceHub.EggType = 3
            end
        end
    }))
    
    plantTab:Button({
        Title = "Buy Eggs",
        Desc = "Buy eggs with current settings",
        Icon = "shopping-cart",
        Color = Color3.fromRGB(0, 255, 127),
        Callback = function()
            PlantFunctions.BuyEggs()
            WindUI:Notify({
                Title = "Executed",
                Content = string.format("Buying %d eggs (Type: %d)", _G.SynceHub.EggAmount, _G.SynceHub.EggType),
                Duration = 2,
                Icon = "check"
            })
        end
    })
    
    plantTab:Divider()
    
-- SynceHub tab-content.lua - PART 2
-- SALIN PART 2 DAN TEMPEL DI BAWAH PART 1

    -- Auto Functions Section
    plantTab:Section({
        Title = "Auto Functions",
        TextSize = 18,
    })
    
    Reg("PlantAuto_Delay", plantTab:Slider({
        Title = "Auto Delay",
        Desc = "Delay between auto executions (seconds)",
        Min = 0.1,
        Max = 5,
        Default = 0.5,
        Increment = 0.1,
        Callback = function(value)
            _G.SynceHub.AutoDelay = value
        end
    }))
    
    Reg("PlantAuto_InfWins", plantTab:Toggle({
        Title = "Auto Infinite Wins",
        Desc = "Automatically execute infinite wins",
        Default = false,
        Callback = function(enabled)
            _G.SynceHub.AutoInfWins = enabled
            if enabled then
                spawn(function()
                    while _G.SynceHub.AutoInfWins do
                        PlantFunctions.InfWins()
                        wait(_G.SynceHub.AutoDelay)
                    end
                end)
            end
        end
    }))
    
    Reg("PlantAuto_InfSpin", plantTab:Toggle({
        Title = "Auto Infinite Spin",
        Desc = "Automatically execute infinite spin",
        Default = false,
        Callback = function(enabled)
            _G.SynceHub.AutoInfSpin = enabled
            if enabled then
                spawn(function()
                    while _G.SynceHub.AutoInfSpin do
                        PlantFunctions.InfSpin()
                        wait(_G.SynceHub.AutoDelay)
                    end
                end)
            end
        end
    }))
    
    Reg("PlantAuto_BuyEggs", plantTab:Toggle({
        Title = "Auto Buy Eggs",
        Desc = "Automatically buy eggs",
        Default = false,
        Callback = function(enabled)
            _G.SynceHub.AutoBuyEggs = enabled
            if enabled then
                spawn(function()
                    while _G.SynceHub.AutoBuyEggs do
                        PlantFunctions.BuyEggs()
                        wait(_G.SynceHub.AutoDelay)
                    end
                end)
            end
        end
    }))
    
    Reg("PlantAuto_OPPets", plantTab:Toggle({
        Title = "Auto Get OP Pets",
        Desc = "Automatically get OP pets",
        Default = false,
        Callback = function(enabled)
            _G.SynceHub.AutoOPPets = enabled
            if enabled then
                spawn(function()
                    while _G.SynceHub.AutoOPPets do
                        PlantFunctions.GetOPPets()
                        wait(_G.SynceHub.AutoDelay)
                    end
                end)
            end
        end
    }))
    
    Reg("PlantAuto_PetSlot", plantTab:Toggle({
        Title = "Auto Add Pet Slot",
        Desc = "Automatically add pet slots",
        Default = false,
        Callback = function(enabled)
            _G.SynceHub.AutoPetSlot = enabled
            if enabled then
                spawn(function()
                    while _G.SynceHub.AutoPetSlot do
                        PlantFunctions.AddPetSlot()
                        wait(_G.SynceHub.AutoDelay)
                    end
                end)
            end
        end
    }))
    
    plantTab:Divider()
    
    -- Master Controls
    plantTab:Section({
        Title = "Master Controls",
        TextSize = 18,
    })
    
    Reg("PlantAuto_All", plantTab:Toggle({
        Title = "Auto ALL",
        Desc = "Enable all auto functions at once",
        Default = false,
        Callback = function(enabled)
            _G.SynceHub.AutoAll = enabled
            if enabled then
                spawn(function()
                    while _G.SynceHub.AutoAll do
                        pcall(function()
                            PlantFunctions.InfWins()
                            PlantFunctions.InfSpin()
                            PlantFunctions.GetOPPets()
                            PlantFunctions.AddPetSlot()
                            PlantFunctions.BuyEggs()
                        end)
                        wait(_G.SynceHub.AutoDelay)
                    end
                end)
            end
        end
    }))
    
    plantTab:Button({
        Title = "Stop All Auto Functions",
        Desc = "Disable all running auto functions",
        Icon = "stop-circle",
        Color = Color3.fromRGB(255, 80, 80),
        Callback = function()
            _G.SynceHub.AutoInfWins = false
            _G.SynceHub.AutoInfSpin = false
            _G.SynceHub.AutoBuyEggs = false
            _G.SynceHub.AutoOPPets = false
            _G.SynceHub.AutoPetSlot = false
            _G.SynceHub.AutoAll = false
            
            WindUI:Notify({
                Title = "Stopped",
                Content = "All auto functions disabled",
                Duration = 2,
                Icon = "x"
            })
        end
    })
    
 -- SynceHub tab-content.lua - PART 3 (FINAL)
-- SALIN PART 3 DAN TEMPEL DI BAWAH PART 2

    -- ============================================================
    -- CONFIGURATION TAB
    -- ============================================================
    local SettingsTab = Window:Tab({
        Title = "Configuration",
        Icon = "settings",
        Locked = false,
    })

    local ConfigSection = SettingsTab:Section({
        Title = "Config Manager",
        TextSize = 20,
    })
    
    local ConfigManager = Window.ConfigManager
    local SelectedConfigName = "Syncehub"

    local function RefreshConfigList(dropdown)
        local list = ConfigManager:AllConfigs()
        if #list == 0 then list = {"None"} end
        pcall(function() dropdown:Refresh(list) end)
    end

    local ConfigNameInput = ConfigSection:Input({
        Title = "Config Name",
        Desc = "The name of the new config to be saved.",
        Value = "Syncehub",
        Placeholder = "e.g. MyConfig",
        Icon = "file-pen",
        Callback = function(text)
            SelectedConfigName = text
        end
    })

    local ConfigDropdown = ConfigSection:Dropdown({
        Title = "Available Configs",
        Desc = "Select the existing config file.",
        Values = ConfigManager:AllConfigs() or {"None"},
        Value = "Syncehub",
        AllowNone = true,
        Callback = function(val)
            if val and val ~= "None" then
                SelectedConfigName = val
                ConfigNameInput:Set(val)
            end
        end
    })

    ConfigSection:Button({
        Title = "Refresh List",
        Icon = "refresh-ccw",
        Callback = function() RefreshConfigList(ConfigDropdown) end
    })

    ConfigSection:Divider()

    ConfigSection:Button({
        Title = "Save Config",
        Desc = "Save current settings.",
        Icon = "save",
        Color = Color3.fromRGB(0, 255, 127),
        Callback = function()
            if SelectedConfigName == "" then 
                WindUI:Notify({ 
                    Title = "Error", 
                    Content = "Config name cannot be empty", 
                    Duration = 3, 
                    Icon = "x" 
                })
                return 
            end
            
            SynceHubConfig:Save()
            task.wait(0.1)

            if SelectedConfigName ~= "Syncehub" then
                local success, err = pcall(function()
                    local mainContent = readfile(BaseFolder .. "Syncehub.json")
                    writefile(BaseFolder .. SelectedConfigName .. ".json", mainContent)
                end)
                
                if not success then
                    WindUI:Notify({ 
                        Title = "Save Failed", 
                        Content = "Failed to copy file: " .. tostring(err), 
                        Duration = 3, 
                        Icon = "x" 
                    })
                    return
                end
            end

            WindUI:Notify({ 
                Title = "Saved!", 
                Content = "Config saved: " .. SelectedConfigName, 
                Duration = 2, 
                Icon = "check" 
            })
            RefreshConfigList(ConfigDropdown)
        end
    })

    ConfigSection:Button({
        Title = "Load Config",
        Icon = "download",
        Callback = function()
            if SelectedConfigName == "" then 
                WindUI:Notify({ 
                    Title = "Error", 
                    Content = "Config name cannot be empty", 
                    Duration = 3, 
                    Icon = "x" 
                })
                return 
            end
            SmartLoadConfig(SelectedConfigName)
        end
    })

    ConfigSection:Button({
        Title = "Delete Config",
        Icon = "trash-2",
        Color = Color3.fromRGB(255, 80, 80),
        Callback = function()
            if SelectedConfigName == "" or SelectedConfigName == "Syncehub" then 
                WindUI:Notify({ 
                    Title = "Cannot Delete", 
                    Content = "Cannot delete default or empty config.", 
                    Duration = 3,
                    Icon = "alert-triangle"
                })
                return 
            end
            
            local path = BaseFolder .. SelectedConfigName .. ".json"
            
            if isfile(path) then
                delfile(path)
                WindUI:Notify({ 
                    Title = "Deleted", 
                    Content = "Config " .. SelectedConfigName .. " deleted successfully.", 
                    Duration = 2, 
                    Icon = "trash" 
                })
                RefreshConfigList(ConfigDropdown)
                ConfigNameInput:Set("Syncehub")
                SelectedConfigName = "Syncehub"
            else
                WindUI:Notify({ 
                    Title = "Delete Failed", 
                    Content = "File not found.", 
                    Duration = 3, 
                    Icon = "x" 
                })
            end
        end
    })
    
    -- Keybind Setting
    SettingsTab:Divider()
    
    SettingsTab:Section({
        Title = "UI Settings",
        TextSize = 18,
    })
    
    SettingsTab:Keybind({
        Title = "Toggle Keybind",
        Desc = "Keybind to open/close UI",
        Value = "F",
        Callback = function(v)
            Window:SetToggleKey(Enum.KeyCode[v])
        end
    })
    
    WindUI:Notify({ 
        Title = "Tabs Loaded", 
        Content = "All features ready to use!", 
        Duration = 2, 
        Icon = "check" 
    })
end

return TabContent