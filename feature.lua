-- SynceHub feature.lua - Core Features & Helpers
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
        
        -- Paths
        RPath = {"Packages", "_Index", "sleitnick_net@0.2.0", "net"},
    }
   
    -- Anti-AFK
    pcall(function()
        local player = game:GetService("Players").LocalPlayer
        for i, v in pairs(getconnections(player.Idled)) do
            if v.Disable then
                v:Disable()
            end
        end
    end)
    
    WindUI:Notify({ 
        Title = "Features Loaded", 
        Content = "Core features initialized", 
        Duration = 2, 
        Icon = "check" 
    })
end

return FeatureModule