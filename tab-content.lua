-- SynceHub tab-content.lua - Tab Creation
local TabContent = {}

function TabContent.CreateTabs(Window, Reg, WindUI, SynceHubConfig, SmartLoadConfig, BaseFolder, ElementRegistry)
    local LocalPlayer = _G.SynceHub.LocalPlayer
    
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
                        Title = "Link Disalin!",
                        Content = "Link Discord SynceHub berhasil disalin.",
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
        Desc = "- 11 Des 2025",
    })
    
    home:Paragraph({
        Title = "Info",
        Desc = "[Nothing]",
    })
    
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
        Desc = "Nama config baru/yang akan disimpan.",
        Value = "Syncehub",
        Placeholder = "e.g. LegitFarming",
        Icon = "file-pen",
        Callback = function(text)
            SelectedConfigName = text
        end
    })

    local ConfigDropdown = ConfigSection:Dropdown({
        Title = "Available Configs",
        Desc = "Pilih file config yang ada.",
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
        Desc = "Simpan settingan saat ini.",
        Icon = "save",
        Color = Color3.fromRGB(0, 255, 127),
        Callback = function()
            if SelectedConfigName == "" then return end
            
            SynceHubConfig:Save()
            task.wait(0.1)

            if SelectedConfigName ~= "Syncehub" then
                local success, err = pcall(function()
                    local mainContent = readfile(BaseFolder .. "Syncehub.json")
                    writefile(BaseFolder .. SelectedConfigName .. ".json", mainContent)
                end)
                
                if not success then
                    WindUI:Notify({ Title = "Error Write", Content = "Gagal menyalin file.", Duration = 3, Icon = "x" })
                    return
                end
            end

            WindUI:Notify({ Title = "Saved!", Content = "Config: " .. SelectedConfigName, Duration = 2, Icon = "check" })
            RefreshConfigList(ConfigDropdown)
        end
    })

    ConfigSection:Button({
        Title = "Load Config",
        Icon = "download",
        Callback = function()
            if SelectedConfigName == "" then return end
            SmartLoadConfig(SelectedConfigName)
        end
    })

    ConfigSection:Button({
        Title = "Delete Config",
        Icon = "trash-2",
        Color = Color3.fromRGB(255, 80, 80),
        Callback = function()
            if SelectedConfigName == "" or SelectedConfigName == "Syncehub" then 
                WindUI:Notify({ Title = "Gagal", Content = "Tidak bisa hapus config default/kosong.", Duration = 3 })
                return 
            end
            
            local path = BaseFolder .. SelectedConfigName .. ".json"
            
            if isfile(path) then
                delfile(path)
                WindUI:Notify({ Title = "Deleted", Content = SelectedConfigName .. " dihapus.", Duration = 2, Icon = "trash" })
                RefreshConfigList(ConfigDropdown)
                ConfigNameInput:Set("Syncehub")
                SelectedConfigName = "Syncehub"
            else
                WindUI:Notify({ Title = "Error", Content = "File tidak ditemukan.", Duration = 3, Icon = "x" })
            end
        end
    })
    
    -- Keybind Setting
    SettingsTab:Divider()
    SettingsTab:Keybind({
        Title = "Keybind",
        Desc = "Keybind to open/close ui",
        Value = "F",
        Callback = function(v)
            Window:SetToggleKey(Enum.KeyCode[v])
        end
    })
    
    WindUI:Notify({ 
        Title = "Tabs Loaded", 
        Content = "Home & Configuration ready", 
        Duration = 2, 
        Icon = "check" 
    })
end

return TabContent