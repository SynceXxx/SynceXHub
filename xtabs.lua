local TabContent = {}

function TabContent.CreateTabs(Window, Reg, WindUI, SynceHubConfig, SmartLoadConfig, BaseFolder, ElementRegistry)
    local LocalPlayer = _G.SynceHub.LocalPlayer
    local RepStorage = _G.SynceHub.RepStorage
    local UserInputService = _G.SynceHub.UserInputService
    local RunService = _G.SynceHub.RunService
    
    -- ============================================================
    -- HELPER FUNCTIONS
    -- ============================================================
    local function GetHumanoid()
        local char = LocalPlayer.Character
        return char and char:FindFirstChildOfClass("Humanoid")
    end

    local function GetHRP()
        local char = LocalPlayer.Character
        return char and char:FindFirstChild("HumanoidRootPart")
    end

    -- Constants
    local DEFAULT_SPEED = _G.SynceHub.DEFAULT_SPEED
    local DEFAULT_JUMP = _G.SynceHub.DEFAULT_JUMP
    local currentSpeed = _G.SynceHub.currentSpeed
    local currentJump = _G.SynceHub.currentJump
    local InfinityJumpConnection = _G.SynceHub.InfinityJumpConnection
    
    -- ============================================================
    -- RESPAWN HANDLER FOR MOVEMENT VALUES (BONUS FIX)
    -- ============================================================
    LocalPlayer.CharacterAdded:Connect(function(character)
        task.wait(0.8)
        local Humanoid = character:WaitForChild("Humanoid")
        if Humanoid then
            -- Re-apply saved movement values
            if _G.SynceHub.currentSpeed and _G.SynceHub.currentSpeed ~= DEFAULT_SPEED then
                Humanoid.WalkSpeed = _G.SynceHub.currentSpeed
            end
            if _G.SynceHub.currentJump and _G.SynceHub.currentJump ~= DEFAULT_JUMP then
                Humanoid.JumpPower = _G.SynceHub.currentJump
            end
        end
    end)
    
    -- ============================================================
    -- HOME TAB - PROFESSIONAL DASHBOARD
    -- ============================================================
    local home = Window:Tab({
        Title = "Home",
        Icon = "rbxassetid://7733960981",
        Locked = false,
    })

    home:Select()

    -- Get Player Info
    local Players = game:GetService("Players")
    local RunService = game:GetService("RunService")
    local Stats = game:GetService("Stats")

    local Player = LocalPlayer
    local userId = Player.UserId
    local displayName = Player.DisplayName
    local username = Player.Name
    local accountAge = Player.AccountAge

    -- ============================================================
    -- HEADER SECTION WITH LOGO
    -- ============================================================
    home:Image({
        Image = "rbxassetid://136968295567189",
        AspectRatio = "16:9",
        Radius = 12,
    })

    home:Space()

    home:Section({
        Title = "SynceHub - Universal Script Hub",
        TextSize = 26,
        FontWeight = Enum.FontWeight.Bold,
    })

    home:Section({
        Title = "Welcome back, " .. displayName .. "!",
        TextSize = 18,
        TextTransparency = 0.3,
    })

    home:Divider()

    -- ============================================================
    -- PLAYER PROFILE SECTION
    -- ============================================================
    home:Section({
        Title = "Your Profile",
        Icon = "user",
        TextSize = 20,
        FontWeight = Enum.FontWeight.SemiBold,
    })

    local profileGroup = home:Group({})

    -- Profile Info Card
    profileGroup:Paragraph({
        Title = displayName .. " (@" .. username .. ")",
        Desc = "User ID: " .. userId .. "\nAccount Age: " .. accountAge .. " days",
        Buttons = {
            {
                Title = "View Profile",
                Icon = "external-link",
                Callback = function()
                    setclipboard("https://www.roblox.com/users/"..userId.."/profile")
                    WindUI:Notify({
                        Title = "Success",
                        Content = "Profile URL copied to clipboard!",
                        Duration = 3,
                        Icon = "check",
                    })
                end,
            },
            {
                Title = "Copy User ID",
                Icon = "copy",
                Callback = function()
                    setclipboard(tostring(userId))
                    WindUI:Notify({
                        Title = "Copied!",
                        Content = "User ID: " .. userId,
                        Duration = 2,
                        Icon = "check",
                    })
                end,
            }
        }
    })

    home:Space()

    -- ============================================================
    -- GAME INFORMATION SECTION
    -- ============================================================
    home:Section({
        Title = "Current Game",
        Icon = "gamepad-2",
        TextSize = 20,
        FontWeight = Enum.FontWeight.SemiBold,
    })

    local gameGroup = home:Group({})

    -- Get Game Name
    local gameName = "Unknown Game"
    pcall(function()
        gameName = game:GetService("MarketplaceService"):GetProductInfo(game.PlaceId).Name
    end)

    gameGroup:Paragraph({
        Title = gameName,
        Desc = "Place ID: " .. tostring(game.PlaceId) .. "\nJob ID: " .. game.JobId:sub(1, 16) .. "...",
        Image = "info",
        ImageSize = 24,
        Buttons = {
            {
                Title = "Copy Job ID",
                Icon = "server",
                Callback = function()
                    setclipboard(game.JobId)
                    WindUI:Notify({
                        Title = "Job ID Copied!",
                        Content = "Server Job ID copied to clipboard",
                        Duration = 3,
                        Icon = "check",
                    })
                end,
            }
        }
    })

    home:Space()

    -- ============================================================
    -- DISCORD COMMUNITY SECTION
    -- ============================================================
    home:Section({
        Title = "Join Our Community",
        Icon = "users",
        TextSize = 20,
        FontWeight = Enum.FontWeight.SemiBold,
    })

    home:Paragraph({
        Title = "SynceHub Discord Server",
        Desc = "Join our Discord community to get the latest updates, report bugs, request features, and connect with other users!",
        Image = "rbxassetid://136968295567189",
        ImageSize = 32,
        Buttons = {
            {
                Title = "Join Discord",
                Icon = "link",
                Callback = function()
                    setclipboard("https://dsc.gg/Syncehub")
                    WindUI:Notify({
                        Title = "Discord Link Copied!",
                        Content = "Discord invite copied to clipboard",
                        Duration = 3,
                        Icon = "check",
                    })
                end,
            }
        }
    })

    home:Space()

    -- ============================================================
    -- QUICK ACTIONS SECTION
    -- ============================================================
    home:Section({
        Title = "Quick Actions",
        Icon = "zap",
        TextSize = 20,
        FontWeight = Enum.FontWeight.SemiBold,
    })

    local actionsGroup = home:Group({})

    actionsGroup:Button({
        Title = "Rejoin Current Server",
        Icon = "rotate-cw",
        Justify = "Center",
        Color = Color3.fromHex("#0091FF"),
        Callback = function()
            WindUI:Notify({
                Title = "Rejoining...",
                Content = "Rejoining current server...",
                Duration = 2,
                Icon = "loader",
            })
            
            task.wait(1)
            
            local TeleportService = game:GetService("TeleportService")
            if #Players:GetPlayers() <= 1 then
                LocalPlayer:Kick("\n[SynceHub] Rejoining server...")
                task.wait()
                TeleportService:Teleport(game.PlaceId, LocalPlayer)
            else
                TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId, LocalPlayer)
            end
        end
    })

    actionsGroup:Space()

    actionsGroup:Button({
        Title = "Server Hop (Random)",
        Icon = "shuffle",
        Justify = "Center",
        Color = Color3.fromHex("#10C550"),
        Callback = function()
            WindUI:Notify({
                Title = "Server Hopping...",
                Content = "Finding new server...",
                Duration = 3,
                Icon = "search",
            })
            
            task.spawn(function()
                local HttpService = game:GetService("HttpService")
                local TeleportService = game:GetService("TeleportService")
                local PlaceId = game.PlaceId
                local JobId = game.JobId
                
                local sfUrl = "https://games.roblox.com/v1/games/%s/servers/Public?sortOrder=Desc&limit=100&excludeFullGames=true"
                local req = game:HttpGet(string.format(sfUrl, PlaceId))
                local body = HttpService:JSONDecode(req)
        
                if body and body.data then
                    local servers = {}
                    for _, v in ipairs(body.data) do
                        if type(v) == "table" and v.maxPlayers > v.playing and v.id ~= JobId then
                            table.insert(servers, v.id)
                        end
                    end
        
                    if #servers > 0 then
                        local randomServerId = servers[math.random(1, #servers)]
                        WindUI:Notify({
                            Title = "Server Found!",
                            Content = "Teleporting to new server...",
                            Duration = 2,
                            Icon = "check",
                        })
                        TeleportService:TeleportToPlaceInstance(PlaceId, randomServerId, LocalPlayer)
                    else
                        WindUI:Notify({
                            Title = "No Servers Found",
                            Content = "Could not find suitable server",
                            Duration = 3,
                            Icon = "x",
                        })
                    end
                end
            end)
        end
    })

    home:Divider()

    -- ============================================================
    -- HUB FEATURES SECTION
    -- ============================================================
    home:Section({
        Title = "Hub Features",
        Icon = "box",
        TextSize = 18,
        FontWeight = Enum.FontWeight.SemiBold,
    })

    home:Paragraph({
        Title = "Player Features",
        Desc = "WalkSpeed & JumpPower\nInfinite Jump\nNo Clip\nFly Mode\nFreeze Player\nPlayer ESP\nInvisible Mode\nReset Character",
    })

    home:Paragraph({
        Title = "Tools & Utilities",
        Desc = "Infinite Zoom\nDisable 3D Rendering\nFPS Boost\nServer Hop\nCinematic Free Cam\nHide UI",
    })

    home:Paragraph({
        Title = "Animation System",
        Desc = "30+ Animation Packs\nAuto-Save\nRespawn Support\nR15 Character Support",
    })

    home:Paragraph({
        Title = "Teleport & Config",
        Desc = "Teleport to Players\nSave/Load Configs\nAuto-Save\nCustom Keybinds",
    })

    home:Space()

    -- Footer
    home:Section({
        Title = "SynceHub v1.0.2 | Made by Synce Script",
        TextSize = 13,
        TextTransparency = 0.5,
    })

    -- ============================================================
    -- PLAYER TAB - MOVEMENT SECTION
    -- ============================================================
    local player = Window:Tab({
        Title = "Player",
        Icon = "user",
        Locked = false,
    })

    -- MOVEMENT SECTION
    local movement = player:Section({
        Title = "Movement",
        Icon = "footprints",
        TextSize = 19,
    })

    -- Slider WalkSpeed
    local SliderSpeed = Reg("Walkspeed", movement:Slider({
        Title = "WalkSpeed",
        Step = 1,
        Value = {
            Min = 16,
            Max = 200,
            Default = currentSpeed,
        },
        Callback = function(value)
            local speedValue = tonumber(value)
            if speedValue and speedValue >= 0 then
                local Humanoid = GetHumanoid()
                if Humanoid then
                    Humanoid.WalkSpeed = speedValue
                    _G.SynceHub.currentSpeed = speedValue
                end
            end
        end,
    }))

    -- Slider JumpPower
    local SliderJump = Reg("slidjump", movement:Slider({
        Title = "JumpPower",
        Step = 1,
        Value = {
            Min = 50,
            Max = 200,
            Default = currentJump,
        },
        Callback = function(value)
            local jumpValue = tonumber(value)
            if jumpValue and jumpValue >= 50 then
                local Humanoid = GetHumanoid()
                if Humanoid then
                    Humanoid.JumpPower = jumpValue
                    _G.SynceHub.currentJump = jumpValue
                end
            end
        end,
    }))
    
    -- Reset Button
    movement:Button({
        Title = "Reset Movement",
        Icon = "rotate-ccw",
        Callback = function()
            local Humanoid = GetHumanoid()
            if Humanoid then
                Humanoid.WalkSpeed = DEFAULT_SPEED
                Humanoid.JumpPower = DEFAULT_JUMP
                SliderSpeed:Set(DEFAULT_SPEED)
                SliderJump:Set(DEFAULT_JUMP)
                _G.SynceHub.currentSpeed = DEFAULT_SPEED
                _G.SynceHub.currentJump = DEFAULT_JUMP
                WindUI:Notify({
                    Title = "Movement Reset",
                    Content = "WalkSpeed & JumpPower reset to default",
                    Duration = 3,
                    Icon = "check",
                })
            end
        end
    })

    -- ============================================================
    -- FIXED: FREEZE PLAYER WITH RESPAWN HANDLER
    -- ============================================================
    local freezeConnection = nil

    Reg("freeze", movement:Toggle({
        Title = "Freeze Player",
        Desc = "Freeze character at current position (Anti-Push).",
        Value = false,
        Callback = function(state)
            -- Disconnect old connections
            if freezeConnection then 
                freezeConnection:Disconnect() 
                freezeConnection = nil 
            end
            
            local character = LocalPlayer.Character
            if not character then return end
            
            local hrp = character:FindFirstChild("HumanoidRootPart")
            if hrp then
                hrp.Anchored = state
                
                if state then
                    hrp.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
                    hrp.Velocity = Vector3.new(0, 0, 0)
                    
                    -- Monitor respawn to auto-disable freeze
                    freezeConnection = LocalPlayer.CharacterAdded:Connect(function(newChar)
                        task.wait(0.5)
                        local newHRP = newChar:FindFirstChild("HumanoidRootPart")
                        if newHRP then
                            newHRP.Anchored = false
                        end
                        if freezeConnection then 
                            freezeConnection:Disconnect()
                            freezeConnection = nil
                        end
                    end)
                    
                    WindUI:Notify({ 
                        Title = "Player Frozen", 
                        Content = "Position locked (Anchored).", 
                        Duration = 2, 
                        Icon = "lock" 
                    })
                else
                    WindUI:Notify({ 
                        Title = "Player Unfrozen", 
                        Content = "Movement back to normal.", 
                        Duration = 2, 
                        Icon = "lock-open" 
                    })
                end
            else
                WindUI:Notify({ 
                    Title = "Error", 
                    Content = "HumanoidRootPart not found.", 
                    Duration = 3, 
                    Icon = "info" 
                })
            end
        end
    }))
    
    -- ============================================================
    -- ABILITIES SECTION
    -- ============================================================
    local ability = player:Section({
        Title = "Abilities",
        Icon = "bolt",
        TextSize = 19,
    })

    -- Toggle Infinite Jump
    Reg("infj", ability:Toggle({
        Title = "Infinite Jump",
        Value = false,
        Callback = function(state)
            if state then
                WindUI:Notify({ 
                    Title = "Infinite Jump ON!",
                    Content = "You can now jump infinitely.",
                    Duration = 3, 
                    Icon = "check" 
                })
                _G.SynceHub.InfinityJumpConnection = UserInputService.JumpRequest:Connect(function()
                    local Humanoid = GetHumanoid()
                    if Humanoid and Humanoid.Health > 0 then
                        Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
                    end
                end)
            else
                WindUI:Notify({ 
                    Title = "Infinite Jump OFF!", 
                    Content = "Infinite jump is now off.",
                    Duration = 3, 
                    Icon = "x" 
                })
                if _G.SynceHub.InfinityJumpConnection then
                    _G.SynceHub.InfinityJumpConnection:Disconnect()
                    _G.SynceHub.InfinityJumpConnection = nil
                end
            end
        end
    }))

    -- ============================================================
    -- FIXED: NO CLIP WITH RESPAWN HANDLER
    -- ============================================================
    local noclipConnection = nil
    local noclipRespawnConnection = nil
    local isNoClipActive = false
    
    Reg("nclip", ability:Toggle({
        Title = "No Clip",
        Value = false,
        Callback = function(state)
            isNoClipActive = state
            local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()

            if state then
                WindUI:Notify({ 
                    Title = "No Clip ON!",
                    Content = "You can now pass through objects.",
                    Duration = 3, 
                    Icon = "check" 
                })
                
                noclipConnection = RunService.Stepped:Connect(function()
                    if isNoClipActive and character then
                        for _, part in ipairs(character:GetDescendants()) do
                            if part:IsA("BasePart") and part.CanCollide then
                                part.CanCollide = false
                            end
                        end
                    end
                end)
                
                -- Handle respawn
                noclipRespawnConnection = LocalPlayer.CharacterAdded:Connect(function(newChar)
                    character = newChar
                    task.wait(0.5)
                    if isNoClipActive then
                        -- Noclip will continue on new character
                        WindUI:Notify({ 
                            Title = "No Clip Active", 
                            Content = "Still active after respawn",
                            Duration = 2, 
                            Icon = "check" 
                        })
                    end
                end)
                
            else
                WindUI:Notify({ 
                    Title = "No Clip OFF!",
                    Content = "Collision has been restored.",
                    Duration = 3, 
                    Icon = "x" 
                })
                
                if noclipConnection then 
                    noclipConnection:Disconnect() 
                    noclipConnection = nil 
                end
                
                if noclipRespawnConnection then
                    noclipRespawnConnection:Disconnect()
                    noclipRespawnConnection = nil
                end

                if character then
                    for _, part in ipairs(character:GetDescendants()) do
                        if part:IsA("BasePart") then
                            part.CanCollide = true
                        end
                    end
                end
            end
        end
    }))

    -- ============================================================
    -- FLY MODE (NEW SYSTEM)
    -- ============================================================
    Reg("flym", ability:Toggle({
        Title = "Fly Mode",
        Value = false,
        Callback = function(state)
            local FlySystem = _G.SynceHub.FlySystem
            
            if state then
                FlySystem.Toggle()
                WindUI:Notify({ 
                    Title = "Fly Mode ON!", 
                    Content = "You can now fly freely.",
                    Duration = 3, 
                    Icon = "check" 
                })
            else
                FlySystem.Toggle()
                WindUI:Notify({ 
                    Title = "Fly Mode OFF!", 
                    Content = "Flight mode has been disabled.",
                    Duration = 3, 
                    Icon = "x" 
                })
            end
        end
    }))
    
    -- Fly Speed Slider
    Reg("flyspeed", ability:Slider({
        Title = "Fly Speed",
        Step = 5,
        Value = {
            Min = 10,
            Max = 200,
            Default = 50,
        },
        Callback = function(value)
            local speedValue = tonumber(value)
            if speedValue and speedValue >= 10 then
                _G.SynceHub.FlySystem.SetSpeed(speedValue)
            end
        end,
    }))
    
    -- ============================================================
    -- OTHER SECTION
    -- ============================================================
    local other = player:Section({
        Title = "Other",
        Icon = "book-open",
        TextSize = 19,
    })

    -- ============================================================
    -- FIXED: ESP SYSTEM (MEMORY LEAK FIXED)
    -- ============================================================
    local players = game:GetService("Players")
    local STUD_TO_M = 0.28
    local espEnabled = false
    local espConnections = {}

    local function removeESP(targetPlayer)
        if not targetPlayer then return end
        local data = espConnections[targetPlayer]
        if data then
            if data.distanceConn then 
                pcall(function() data.distanceConn:Disconnect() end) 
            end
            if data.charAddedConn then 
                pcall(function() data.charAddedConn:Disconnect() end) 
            end
            if data.billboard and data.billboard.Parent then 
                pcall(function() data.billboard:Destroy() end) 
            end
            espConnections[targetPlayer] = nil -- FIXED: Clear from table
        else
            if targetPlayer.Character then
                for _, v in ipairs(targetPlayer.Character:GetChildren()) do
                    if v.Name == "SynceHubESP" and v:IsA("BillboardGui") then 
                        pcall(function() v:Destroy() end) 
                    end
                end
            end
        end
    end

    local function createESP(targetPlayer)
        if not targetPlayer or not targetPlayer.Character or targetPlayer == LocalPlayer then return end

        removeESP(targetPlayer)
        local char = targetPlayer.Character
        local hrp = char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("Torso") or char:FindFirstChild("UpperTorso")
        if not hrp then return end

        local BillboardGui = Instance.new("BillboardGui")
        BillboardGui.Name = "SynceHubESP"
        BillboardGui.Adornee = hrp
        BillboardGui.Size = UDim2.new(0, 140, 0, 40)
        BillboardGui.AlwaysOnTop = true
        BillboardGui.StudsOffset = Vector3.new(0, 2.6, 0)
        BillboardGui.Parent = char

        local Frame = Instance.new("Frame")
        Frame.Size = UDim2.new(1, 0, 1, 0)
        Frame.BackgroundTransparency = 1
        Frame.BorderSizePixel = 0
        Frame.Parent = BillboardGui

        local NameLabel = Instance.new("TextLabel")
        NameLabel.Parent = Frame
        NameLabel.Size = UDim2.new(1, 0, 0.6, 0)
        NameLabel.Position = UDim2.new(0, 0, 0, 0)
        NameLabel.BackgroundTransparency = 1
        NameLabel.Text = tostring(targetPlayer.DisplayName or targetPlayer.Name)
        NameLabel.TextColor3 = Color3.fromRGB(255, 230, 230)
        NameLabel.TextStrokeTransparency = 0.7
        NameLabel.Font = Enum.Font.GothamBold
        NameLabel.TextScaled = true

        local DistanceLabel = Instance.new("TextLabel")
        DistanceLabel.Parent = Frame
        DistanceLabel.Size = UDim2.new(1, 0, 0.4, 0)
        DistanceLabel.Position = UDim2.new(0, 0, 0.6, 0)
        DistanceLabel.BackgroundTransparency = 1
        DistanceLabel.Text = "0.0 m"
        DistanceLabel.TextColor3 = Color3.fromRGB(210, 210, 210)
        DistanceLabel.TextStrokeTransparency = 0.85
        DistanceLabel.Font = Enum.Font.GothamSemibold
        DistanceLabel.TextScaled = true

        espConnections[targetPlayer] = { billboard = BillboardGui }

        local distanceConn = RunService.RenderStepped:Connect(function()
            if not espEnabled or not hrp or not hrp.Parent then 
                removeESP(targetPlayer) 
                return 
            end
            local localChar = LocalPlayer.Character
            local localHRP = localChar and localChar:FindFirstChild("HumanoidRootPart")
            if localHRP then
                local distStuds = (localHRP.Position - hrp.Position).Magnitude
                local distMeters = distStuds * STUD_TO_M
                DistanceLabel.Text = string.format("%.1f m", distMeters)
            end
        end)
        espConnections[targetPlayer].distanceConn = distanceConn

        local charAddedConn = targetPlayer.CharacterAdded:Connect(function()
            task.wait(0.8)
            if espEnabled then createESP(targetPlayer) end
        end)
        espConnections[targetPlayer].charAddedConn = charAddedConn
    end

    Reg("esp", other:Toggle({
        Title = "Player ESP",
        Value = false,
        Callback = function(state)
            espEnabled = state
            if state then
                WindUI:Notify({ 
                    Title = "ESP Active", 
                    Content =  "Player visuals are now Visible.",
                    Duration = 3, 
                    Icon = "eye" 
                })
                for _, plr in ipairs(players:GetPlayers()) do
                    if plr ~= LocalPlayer then createESP(plr) end
                end
                espConnections["playerAddedConn"] = players.PlayerAdded:Connect(function(plr)
                    task.wait(1)
                    if espEnabled then createESP(plr) end
                end)
                espConnections["playerRemovingConn"] = players.PlayerRemoving:Connect(function(plr)
                    removeESP(plr)
                end)
            else
                WindUI:Notify({ 
                    Title = "ESP Inactive", 
                    Content = "All ESP markers removed.", 
                    Duration = 3, 
                    Icon = "eye-off" 
                })
                for plr, _ in pairs(espConnections) do
                    if plr and typeof(plr) == "Instance" then removeESP(plr) end
                end
                if espConnections["playerAddedConn"] then 
                    espConnections["playerAddedConn"]:Disconnect() 
                end
                if espConnections["playerRemovingConn"] then 
                    espConnections["playerRemovingConn"]:Disconnect() 
                end
                espConnections = {}
            end
        end
    }))
    
    -- ============================================================
    -- INVISIBLE MODE
    -- ============================================================
    local InvisibleSystem = _G.SynceHub.InvisibleSystem
    
    Reg("invismode", other:Toggle({
        Title = "Invisible Mode",
        Desc = "Semi-invisible character (Anti-Detection).",
        Value = false,
        Callback = function(state)
            local isInvisible = InvisibleSystem.Toggle()
            
            if isInvisible then
                WindUI:Notify({ 
                    Title = "Invisible Mode ON", 
                    Content = "Character is now semi-invisible.", 
                    Duration = 3, 
                    Icon = "eye-off" 
                })
            else
                WindUI:Notify({ 
                    Title = "Invisible Mode OFF", 
                    Content = "Character visibility restored.", 
                    Duration = 3, 
                    Icon = "eye" 
                })
            end
        end
    }))
    
    -- ============================================================
    -- RESET CHARACTER BUTTON (EXISTING CODE)
    -- ============================================================
    other:Button({
        Title = "Reset Character (In Place)",
        Icon = "refresh-cw",
        Callback = function()
            local character = LocalPlayer.Character
            local hrp = character and character:FindFirstChild("HumanoidRootPart")
            local humanoid = character and character:FindFirstChildOfClass("Humanoid")

            if not character or not hrp or not humanoid then
                WindUI:Notify({ 
                    Title = "Reset Failed", 
                    Content = "Character not found!", 
                    Duration = 3, 
                    Icon = "x" 
                })
                return
            end

            local lastPos = hrp.Position

            WindUI:Notify({ 
                Title = "Resetting Character...", 
                Content = "Respawning at same position...", 
                Duration = 2, 
                Icon = "rotate-cw" 
            })
            humanoid:TakeDamage(999999)

            LocalPlayer.CharacterAdded:Wait()
            task.wait(0.5)
            local newChar = LocalPlayer.Character
            local newHRP = newChar:WaitForChild("HumanoidRootPart", 5)

            if newHRP then
                newHRP.CFrame = CFrame.new(lastPos + Vector3.new(0, 3, 0))
                WindUI:Notify({ 
                    Title = "Character Reset Success!", 
                    Content = "Respawned at same position", 
                    Duration = 3, 
                    Icon = "check" 
                })
            else
                WindUI:Notify({ 
                    Title = "Reset Failed", 
                    Content = "New HumanoidRootPart not found.", 
                    Duration = 3, 
                    Icon = "x" 
                })
            end
        end
    })

    -- ============================================================
    -- TELEPORT TAB
    -- ============================================================
    local teleport = Window:Tab({
        Title = "Teleport",
        Icon = "map-pin",
        Locked = false,
    })

    local selectedTargetPlayer = nil

    local function GetPlayerListOptions()
        local options = {}
        for _, player in ipairs(players:GetPlayers()) do
            if player ~= LocalPlayer then
                table.insert(options, player.Name)
            end
        end
        return options
    end

    local function GetTargetHRP(playerName)
        local targetPlayer = players:FindFirstChild(playerName)
        local character = targetPlayer and targetPlayer.Character
        if character then
            return character:FindFirstChild("HumanoidRootPart")
        end
        return nil
    end

    teleport:Section({
        Title = "Teleport to Player",
        Icon = "hand",
        TextSize = 19,
    })

    local PlayerDropdown = teleport:Dropdown({
        Title = "Select Target Player",
        Values = GetPlayerListOptions(),
        AllowNone = true,
        Callback = function(name)
            selectedTargetPlayer = name
        end
    })

    teleport:Button({
        Title = "Refresh Player List",
        Icon = "refresh-ccw",
        Callback = function()
            local newOptions = GetPlayerListOptions()
            pcall(function() PlayerDropdown:Refresh(newOptions) end)
            task.wait(0.1)
            pcall(function() PlayerDropdown:Set(false) end)
            selectedTargetPlayer = nil
            WindUI:Notify({ 
                Title = "List Updated", 
                Content = string.format("%d players found.", #newOptions), 
                Duration = 2, 
                Icon = "check" 
            })
        end
    })

    teleport:Button({
        Title = "Teleport to Player (One-Time)",
        Content = "Teleport once to selected player location.",
        Icon = "corner-down-right",
        Callback = function()
            local hrp = GetHRP()
            local targetHRP = GetTargetHRP(selectedTargetPlayer)
            
            if not selectedTargetPlayer then
                WindUI:Notify({ 
                    Title = "Error", 
                    Content = "Please select target player first.", 
                    Duration = 3, 
                    Icon = "info" 
                })
                return
            end

            if hrp and targetHRP then
                local targetPos = targetHRP.Position + Vector3.new(0, 5, 0)
                local lookVector = (targetHRP.Position - hrp.Position).Unit 
                
                hrp.CFrame = CFrame.new(targetPos, targetPos + lookVector)
                
                WindUI:Notify({ 
                    Title = "Teleport Success", 
                    Content = "Teleported to " .. selectedTargetPlayer, 
                    Duration = 3, 
                    Icon = "user-check" 
                })
            else
                WindUI:Notify({ 
                    Title = "Error", 
                    Content = "Failed to find target or your character.", 
                    Duration = 3, 
                    Icon = "x" 
                })
            end
        end
    })

    -- ============================================================
    -- TOOLS TAB
    -- ============================================================
    local utility = Window:Tab({
        Title = "Tools",
        Icon = "box",
        Locked = false,
    })

    local misc = utility:Section({ 
        Title = "Visual", 
        Icon = "chart-area",
        TextSize = 19,
    })

    -- INFINITE ZOOM OUT
    local defaultMaxZoom = LocalPlayer.CameraMaxZoomDistance or 128
    local zoomLoopConnection = nil

    Reg("infzoom", misc:Toggle({
        Title = "Infinite Zoom Out",
        Value = false,
        Icon = "maximize",
        Callback = function(state)
            if state then
                defaultMaxZoom = LocalPlayer.CameraMaxZoomDistance
                LocalPlayer.CameraMaxZoomDistance = 100000
                
                if zoomLoopConnection then zoomLoopConnection:Disconnect() end
                zoomLoopConnection = RunService.RenderStepped:Connect(function()
                    LocalPlayer.CameraMaxZoomDistance = 100000
                end)
                
                WindUI:Notify({ 
                    Title = "Zoom Unlocked", 
                    Content = "Can zoom out as far as possible.", 
                    Duration = 3, 
                    Icon = "maximize" 
                })
            else
                if zoomLoopConnection then 
                    zoomLoopConnection:Disconnect() 
                    zoomLoopConnection = nil
                end
                LocalPlayer.CameraMaxZoomDistance = defaultMaxZoom
                WindUI:Notify({ 
                    Title = "Zoom Normal", 
                    Content = "Zoom limit restored.", 
                    Duration = 3, 
                    Icon = "minimize" 
                })
            end
        end
    }))

    -- DISABLE 3D RENDERING
    Reg("t3drend", misc:Toggle({
        Title = "Disable 3D Rendering",
        Value = false,
        Callback = function(state)
            local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
            local Camera = workspace.CurrentCamera
            
            if state then
                if not _G.BlackScreenGUI then
                    _G.BlackScreenGUI = Instance.new("ScreenGui")
                    _G.BlackScreenGUI.Name = "SynceHub_BlackBackground"
                    _G.BlackScreenGUI.IgnoreGuiInset = true
                    _G.BlackScreenGUI.DisplayOrder = -999 
                    _G.BlackScreenGUI.Parent = PlayerGui
                    
                    local Frame = Instance.new("Frame")
                    Frame.Size = UDim2.new(1, 0, 1, 0)
                    Frame.BackgroundColor3 = Color3.new(0, 0, 0)
                    Frame.BorderSizePixel = 0
                    Frame.Parent = _G.BlackScreenGUI
                    
                    local Label = Instance.new("TextLabel")
                    Label.Size = UDim2.new(1, 0, 0.1, 0)
                    Label.Position = UDim2.new(0, 0, 0.1, 0)
                    Label.BackgroundTransparency = 1
                    Label.Text = "Saver Mode Active"
                    Label.TextColor3 = Color3.fromRGB(60, 60, 60)
                    Label.TextSize = 16
                    Label.Font = Enum.Font.GothamBold
                    Label.Parent = Frame
                end
                
                _G.BlackScreenGUI.Enabled = true
                _G.OldCamType = Camera.CameraType
                Camera.CameraType = Enum.CameraType.Scriptable
                Camera.CFrame = CFrame.new(0, 100000, 0) 
                
                WindUI:Notify({
                    Title = "Saver Mode ON",
                    Content = "Performance has been optimized.",
                    Duration = 3,
                    Icon = "battery-charging",
                })
            else
                if _G.OldCamType then
                    Camera.CameraType = _G.OldCamType
                else
                    Camera.CameraType = Enum.CameraType.Custom
                end
                
                if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
                    Camera.CameraSubject = LocalPlayer.Character.Humanoid
                end

                if _G.BlackScreenGUI then
                    _G.BlackScreenGUI.Enabled = false
                end
                
                WindUI:Notify({
                    Title = "Saver Mode OFF",
                    Content = "Visual back to normal.",
                    Duration = 3,
                    Icon = "eye",
                })
            end
        end
    }))

    -- FPS ULTRA BOOST
    local isBoostActive = false
    local originalLightingValues = {}

    local function ToggleFPSBoost(enabled)
        isBoostActive = enabled
        local Lighting = game:GetService("Lighting")
        local Terrain = workspace:FindFirstChildOfClass("Terrain")

        if enabled then
        
            WindUI:Notify({ 
                Title = "FPS Boost", 
                Content = "Maximum FPS mode enabled (Minimal Graphics).", 
                Duration = 3, 
                Icon = "zap" 
            })
            
            if not next(originalLightingValues) then
                originalLightingValues.GlobalShadows = Lighting.GlobalShadows
                originalLightingValues.FogEnd = Lighting.FogEnd
                originalLightingValues.Brightness = Lighting.Brightness
                originalLightingValues.ClockTime = Lighting.ClockTime
                originalLightingValues.Ambient = Lighting.Ambient
                originalLightingValues.OutdoorAmbient = Lighting.OutdoorAmbient
            end
            
            pcall(function()
                for _, v in pairs(workspace:GetDescendants()) do
                    if v:IsA("ParticleEmitter") or v:IsA("Trail") or v:IsA("Smoke") or v:IsA("Fire") or v:IsA("Explosion") then
                        v.Enabled = false
                    elseif v:IsA("Beam") or v:IsA("Light") then
                        v.Enabled = false
                    elseif v:IsA("Decal") or v:IsA("Texture") then
                        v.Transparency = 1 
                    end
                end
            end)
            
            pcall(function()
                for _, effect in pairs(Lighting:GetChildren()) do
                    if effect:IsA("PostEffect") then effect.Enabled = false end
                end
                Lighting.GlobalShadows = false
                Lighting.FogEnd = 9e9
                Lighting.Brightness = 0
                Lighting.ClockTime = 14
                Lighting.Ambient = Color3.new(0, 0, 0)
                Lighting.OutdoorAmbient = Color3.new(0, 0, 0)
            end)
            
            if Terrain then
                pcall(function()
                    Terrain.WaterWaveSize = 0
                    Terrain.WaterWaveSpeed = 0
                    Terrain.WaterReflectance = 0
                    Terrain.WaterTransparency = 1
                    Terrain.Decoration = false
                end)
            end
            
            pcall(function()
                settings().Rendering.QualityLevel = Enum.QualityLevel.Level01
                settings().Rendering.MeshPartDetailLevel = Enum.MeshPartDetailLevel.Level01
                settings().Rendering.TextureQuality = Enum.TextureQuality.Low
            end)

            if type(setfpscap) == "function" then 
                pcall(function() setfpscap(100) end) 
            end 
            if type(collectgarbage) == "function" then 
                collectgarbage("collect") 
            end

        else
            pcall(function()
                if originalLightingValues.GlobalShadows ~= nil then
                    Lighting.GlobalShadows = originalLightingValues.GlobalShadows
                    Lighting.FogEnd = originalLightingValues.FogEnd
                    Lighting.Brightness = originalLightingValues.Brightness
                    Lighting.ClockTime = originalLightingValues.ClockTime
                    Lighting.Ambient = originalLightingValues.Ambient
                    Lighting.OutdoorAmbient = originalLightingValues.OutdoorAmbient
                end
                settings().Rendering.QualityLevel = Enum.QualityLevel.Automatic
                
                for _, effect in pairs(Lighting:GetChildren()) do
                    if effect:IsA("PostEffect") then effect.Enabled = true end
                end
            end)
            
            if type(setfpscap) == "function" then 
                pcall(function() setfpscap(60) end) 
            end
            
            WindUI:Notify({ 
                Title = "FPS Boost", 
                Content = "Graphics reset to default/automatic. Rejoin recommended.", 
                Duration = 3, 
                Icon = "rotate-ccw" 
            })
        end
    end

    Reg("togfps", misc:Toggle({
        Title = "FPS Ultra Boost",
        Value = false,
        Callback = function(state)
            ToggleFPSBoost(state)
        end
    }))
    
    -- ============================================================
    -- SERVER MANAGEMENT SECTION (FIXED ERROR HANDLING)
    -- ============================================================
    local serverm = utility:Section({ 
        Title = "Server Management", 
        Icon = "server",
        TextSize = 19,
    })

    local TeleportService = _G.SynceHub.TeleportService
    local HttpService = _G.SynceHub.HttpService

    -- REJOIN SERVER
    serverm:Button({
        Title = "Rejoin Server",
        Desc = "Rejoin this server (Refresh game).",
        Icon = "rotate-cw",
        Callback = function()
            WindUI:Notify({ 
                Title = "Rejoining...", 
                Content = "Please wait...", 
                Duration = 3, 
                Icon = "loader" 
            })
            
            if syn and syn.queue_on_teleport then
                syn.queue_on_teleport('loadstring(game:HttpGet("https://raw.githubusercontent.com/SynceXxx/SynceXHub/refs/heads/main/main.lua"))()')
            elseif queue_on_teleport then
                queue_on_teleport('loadstring(game:HttpGet("https://raw.githubusercontent.com/SynceXxx/SynceXHub/refs/heads/main/main.lua"))()')
            end

            if #players:GetPlayers() <= 1 then
                LocalPlayer:Kick("\n[SynceHub] Rejoining...")
                task.wait()
                TeleportService:Teleport(game.PlaceId, LocalPlayer)
            else
                TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId, LocalPlayer)
            end
        end
    })

    -- ============================================================
    -- FIXED: SERVER HOP (RANDOM) WITH ERROR HANDLING
    -- ============================================================
    serverm:Button({
        Title = "Server Hop (Random)",
        Desc = "Move to another random server.",
        Icon = "arrow-right-circle",
        Callback = function()
            WindUI:Notify({ 
                Title = "Hopping...", 
                Content = "Finding new server...", 
                Duration = 3, 
                Icon = "scan-search" 
            })
            
            task.spawn(function()
                local PlaceId = game.PlaceId
                local JobId = game.JobId
                
                local sfUrl = "https://games.roblox.com/v1/games/%s/servers/Public?sortOrder=Desc&limit=100&excludeFullGames=true"
                
                -- FIXED: Proper error handling
                local success, result = pcall(function()
                    return game:HttpGet(string.format(sfUrl, PlaceId))
                end)
                
                if not success then
                    WindUI:Notify({ 
                        Title = "Connection Error", 
                        Content = "Failed to connect to Roblox API", 
                        Duration = 3, 
                        Icon = "wifi-off" 
                    })
                    return
                end
                
                local parseSuccess, body = pcall(function()
                    return HttpService:JSONDecode(result)
                end)
                
                if not parseSuccess or not body then
                    WindUI:Notify({ 
                        Title = "Parse Error", 
                        Content = "Failed to read server list", 
                        Duration = 3, 
                        Icon = "x" 
                    })
                    return
                end
        
                if body and body.data then
                    local servers = {}
                    for _, v in ipairs(body.data) do
                        if type(v) == "table" and v.maxPlayers > v.playing and v.id ~= JobId then
                            table.insert(servers, v.id)
                        end
                    end
        
                    if #servers > 0 then
                        local randomServerId = servers[math.random(1, #servers)]
                        WindUI:Notify({ 
                            Title = "Server Found", 
                            Content = "Teleporting...", 
                            Duration = 3, 
                            Icon = "plane" 
                        })
                        TeleportService:TeleportToPlaceInstance(PlaceId, randomServerId, LocalPlayer)
                    else
                        WindUI:Notify({ 
                            Title = "Hop Failed", 
                            Content = "No suitable server found.", 
                            Duration = 3, 
                            Icon = "x" 
                        })
                    end
                end
            end)
        end
    })

    -- ============================================================
    -- FIXED: SERVER HOP (LOW PLAYER) WITH ERROR HANDLING
    -- ============================================================
    serverm:Button({
        Title = "Server Hop (Low Player)",
        Desc = "Find low player server (good for farming).",
        Icon = "user-minus",
        Callback = function()
            WindUI:Notify({ 
                Title = "Searching Low Server...", 
                Content = "Finding low player server...", 
                Duration = 3, 
                Icon = "search" 
            })
            
            task.spawn(function()
                local PlaceId = game.PlaceId
                local JobId = game.JobId
                
                local sfUrl = "https://games.roblox.com/v1/games/%s/servers/Public?sortOrder=Asc&limit=100"
                
                -- FIXED: Proper error handling
                local success, result = pcall(function()
                    return game:HttpGet(string.format(sfUrl, PlaceId))
                end)
                
                if not success then
                    WindUI:Notify({ 
                        Title = "Connection Error", 
                        Content = "Failed to connect to Roblox API", 
                        Duration = 3, 
                        Icon = "wifi-off" 
                    })
                    return
                end
                
                local parseSuccess, body = pcall(function()
                    return HttpService:JSONDecode(result)
                end)
                
                if not parseSuccess or not body then
                    WindUI:Notify({ 
                        Title = "Parse Error", 
                        Content = "Failed to read server list", 
                        Duration = 3, 
                        Icon = "x" 
                    })
                    return
                end
        
                if body and body.data then
                    for _, v in ipairs(body.data) do
                        if type(v) == "table" and v.maxPlayers > v.playing and v.id ~= JobId and v.playing >= 1 then
                            WindUI:Notify({ 
                                Title = "Low Server Found!", 
                                Content = "Players: " .. tostring(v.playing), 
                                Duration = 3, 
                                Icon = "check" 
                            })
                            TeleportService:TeleportToPlaceInstance(PlaceId, v.id, LocalPlayer)
                            return
                        end
                    end
                    WindUI:Notify({ 
                        Title = "Failed", 
                        Content = "No low player server found.", 
                        Duration = 3, 
                        Icon = "x" 
                    })
                end
            end)
        end
    })

    -- COPY JOB ID
    serverm:Button({
        Title = "Copy Current Job ID",
        Desc = "Copy this server ID to clipboard.",
        Icon = "copy",
        Callback = function()
            local jobId = game.JobId
            setclipboard(jobId)
            WindUI:Notify({ 
                Title = "Copied!", 
                Content = "Job ID copied to clipboard.", 
                Duration = 3, 
                Icon = "check" 
            })
        end
    })

    -- INPUT FIELD & JOIN BY ID
    local targetJoinID = ""

    serverm:Input({
        Title = "Target Job ID",
        Desc = "Paste target server Job ID here.",
        Value = "",
        Placeholder = "Paste Job ID here...",
        Icon = "keyboard",
        Callback = function(text)
            targetJoinID = text
        end
    })

    serverm:Button({
        Title = "Join Server by ID",
        Desc = "Teleport to the Job ID entered above.",
        Icon = "log-in",
        Callback = function()
            if targetJoinID == "" then
                WindUI:Notify({ 
                    Title = "Error", 
                    Content = "Enter Job ID in input field first!", 
                    Duration = 3, 
                    Icon = "info" 
                })
                return
            end

            if targetJoinID == game.JobId then
                WindUI:Notify({ 
                    Title = "Info", 
                    Content = "You are already in this server!", 
                    Duration = 3, 
                    Icon = "info" 
                })
                return
            end

            WindUI:Notify({ 
                Title = "Joining...", 
                Content = "Trying to join server ID...", 
                Duration = 3, 
                Icon = "plane" 
            })
            
            local success, err = pcall(function()
                TeleportService:TeleportToPlaceInstance(game.PlaceId, targetJoinID, LocalPlayer)
            end)

            if not success then
                WindUI:Notify({ 
                    Title = "Failed", 
                    Content = "Invalid Server ID / Full / Expired.", 
                    Duration = 5, 
                    Icon = "x" 
                })
            end
        end
    })

    -- ============================================================
    -- CINEMATIC / CONTENT TOOLS SECTION
    -- ============================================================
    local cinematic = utility:Section({ 
        Title = "Cinematic / Content Tools", 
        Icon = "clapperboard",
        TextSize = 19,
    })

    local StarterGui = _G.SynceHub.StarterGui

    -- Settings & State
    local freeCamSpeed = 1.5
    local freeCamFov = 70
    local isFreeCamActive = false

    local camera = workspace.CurrentCamera
    local camPos = camera.CFrame.Position
    local camRot = Vector2.new(0, 0)

    local lastMousePos = Vector2.new(0, 0)
    local renderConn = nil
    local touchConn = nil
    local touchDelta = Vector2.new(0, 0)

    local oldWalkSpeed = 16
    local oldJumpPower = 50

    -- SLIDER CAMERA SPEED
    cinematic:Slider({
        Title = "Camera Speed",
        Step = 0.1,
        Value = { Min = 0.1, Max = 10.0, Default = 1.5 },
        Callback = function(val) 
            freeCamSpeed = tonumber(val) 
        end
    })

    -- SLIDER FOV
    cinematic:Slider({
        Title = "Field of View (FOV)",
        Desc = "Zoom In/Out Lens.",
        Step = 1,
        Value = { Min = 10, Max = 120, Default = 70 },
        Callback = function(val) 
            freeCamFov = tonumber(val)
            if isFreeCamActive then 
                camera.FieldOfView = freeCamFov 
            end
        end
    })

    -- TOGGLE CLEAN MODE (FIXED LOGIC)
    cinematic:Toggle({
        Title = "Hide All UI (Clean Mode)",
        Value = false,
        Icon = "eye-off",
        Callback = function(state)
            local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
            
            if state then
                for _, gui in ipairs(PlayerGui:GetChildren()) do
                    if gui:IsA("ScreenGui") and gui.Name ~= "WindUI" and gui.Name ~= "CustomFloatingIcon_SynceHub" then
                        gui:SetAttribute("OriginalState", gui.Enabled)
                        gui.Enabled = false
                    end
                end
                pcall(function() StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.All, false) end)
                
                WindUI:Notify({ 
                    Title = "Clean Mode ON", 
                    Content = "UI Hidden.", 
                    Duration = 2, 
                    Icon = "camera" 
                })
            else
                for _, gui in ipairs(PlayerGui:GetChildren()) do
                    if gui:IsA("ScreenGui") then
                        local originalState = gui:GetAttribute("OriginalState")
                        if originalState ~= nil then
                            gui.Enabled = originalState
                            gui:SetAttribute("OriginalState", nil)
                        end
                    end
                end
                pcall(function() StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.All, true) end)
                
                WindUI:Notify({ 
                    Title = "Clean Mode OFF", 
                    Content = "Show UI again.",
                    Duration = 2, 
                    Icon = "camera-off" 
                })
            end
        end
    })

    -- ============================================================
    -- FIXED: FREE CAM WITH TOUCH CONTROLS FIX
    -- ============================================================
    cinematic:Toggle({
        Title = "Enable Free Cam",
        Value = false,
        Icon = "video",
        Callback = function(state)
            isFreeCamActive = state
            local char = LocalPlayer.Character
            local hum = char and char:FindFirstChild("Humanoid")
            local hrp = char and char:FindFirstChild("HumanoidRootPart")

            if state then
                camera.CameraType = Enum.CameraType.Scriptable
                camPos = camera.CFrame.Position
                local rx, ry, _ = camera.CFrame:ToEulerAnglesYXZ()
                camRot = Vector2.new(rx, ry)
                
                lastMousePos = UserInputService:GetMouseLocation()

                if hum then
                    oldWalkSpeed = hum.WalkSpeed
                    oldJumpPower = hum.JumpPower
                    hum.WalkSpeed = 0
                    hum.JumpPower = 0
                    hum.PlatformStand = true
                end
                if hrp then hrp.Anchored = true end

                -- FIXED: Touch controls with isFreeCamActive check
                if touchConn then touchConn:Disconnect() end
                touchConn = UserInputService.TouchMoved:Connect(function(input, processed)
                    if not processed and isFreeCamActive then  -- FIXED: Add isFreeCamActive check
                        touchDelta = input.Delta 
                    end
                end)

                local ControlModule = require(LocalPlayer.PlayerScripts:WaitForChild("PlayerModule"):WaitForChild("ControlModule"))

                if renderConn then renderConn:Disconnect() end
                renderConn = RunService.RenderStepped:Connect(function()
                    if not isFreeCamActive then return end

                    local currentMousePos = UserInputService:GetMouseLocation()
                    if UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then
                        local deltaX = currentMousePos.X - lastMousePos.X
                        local deltaY = currentMousePos.Y - lastMousePos.Y
                        local sens = 0.003
                        
                        camRot = camRot - Vector2.new(deltaY * sens, deltaX * sens)
                        camRot = Vector2.new(math.clamp(camRot.X, -1.55, 1.55), camRot.Y)
                    end
                    
                    if UserInputService.TouchEnabled then
                        camRot = camRot - Vector2.new(touchDelta.Y * 0.005 * 2.0, touchDelta.X * 0.005 * 2.0)
                        camRot = Vector2.new(math.clamp(camRot.X, -1.55, 1.55), camRot.Y)
                        touchDelta = Vector2.new(0, 0)
                    end
                    
                    lastMousePos = currentMousePos

                    local rotCFrame = CFrame.fromEulerAnglesYXZ(camRot.X, camRot.Y, 0)
                    local moveVector = Vector3.zero

                    local rawMoveVector = ControlModule:GetMoveVector()
                    
                    local verticalInput = 0
                    if UserInputService:IsKeyDown(Enum.KeyCode.E) then verticalInput = 1 end
                    if UserInputService:IsKeyDown(Enum.KeyCode.Q) then verticalInput = -1 end

                    if rawMoveVector.Magnitude > 0 then
                        moveVector = (rotCFrame.RightVector * rawMoveVector.X) + (rotCFrame.LookVector * rawMoveVector.Z * -1)
                    end
                    
                    moveVector = moveVector + Vector3.new(0, verticalInput, 0)

                    local speedMultiplier = (UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) and 4 or 1)
                    local finalSpeed = freeCamSpeed * speedMultiplier
                    
                    if moveVector.Magnitude > 0 then
                        camPos = camPos + (moveVector * finalSpeed)
                    end

                    camera.CFrame = CFrame.new(camPos) * rotCFrame
                    camera.FieldOfView = freeCamFov 
                end)
                
                WindUI:Notify({ 
                    Title = "Free Cam Ready", 
                    Content = "Has been enabled.",
                    Duration = 3, 
                    Icon = "video" 
                })

            else
                if renderConn then renderConn:Disconnect() renderConn = nil end
                if touchConn then touchConn:Disconnect() touchConn = nil end
                
                camera.CameraType = Enum.CameraType.Custom
                UserInputService.MouseBehavior = Enum.MouseBehavior.Default
                camera.FieldOfView = 70 

                if hum then
                    hum.WalkSpeed = oldWalkSpeed
                    hum.JumpPower = oldJumpPower
                    hum.PlatformStand = false
                end
                if hrp then hrp.Anchored = false end
                
                WindUI:Notify({ 
                    Title = "Free Cam OFF", 
                    Content = "Has been disabled.",
                    Duration = 3, 
                    Icon = "video-off" 
                })
            end
        end
    })
    
    -- ============================================================
    -- ANIMATION TAB - COMPLETE COLLECTION
    -- ============================================================
    
    do -- Start animation tab scope
        local AnimationSystem = _G.SynceHub.AnimationSystem
        
        local animation = Window:Tab({
            Title = "Animation",
            Icon = "list-video",
            Locked = false,
        })
        
        -- R15 Check
        local isR15 = false
        pcall(function()
            if LocalPlayer.Character then
                local hum = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
                if hum then
                    isR15 = (hum.RigType == Enum.HumanoidRigType.R15)
                end
            end
        end)
        
        if not isR15 then
            animation:Section({
                Title = "R15 Required",
                Icon = "info",
                TextSize = 20,
                FontWeight = Enum.FontWeight.Bold,
            })
            
            animation:Paragraph({
                Title = "This feature requires R15",
                Desc = "Your character is currently R6. Please switch to R15 in Avatar settings to use custom animations.\n\nGo to: Roblox Avatar Editor → Body → Body Type → R15",
            })
        else
            -- R15 DETECTED - Show animation controls
            
            animation:Section({
                Title = "Advanced Animation System",
                Icon = "sparkles",
                TextSize = 20,
                FontWeight = Enum.FontWeight.SemiBold,
            })
            
            animation:Paragraph({
                Title = "Complete Animation Collection",
                Desc = "Choose from our complete collection of Roblox animation packs. Settings persist across respawns!",
            })
            
            animation:Divider()
            
            -- ============================================================
            -- SPACE & SCI-FI THEMED PACKS
            -- ============================================================
            animation:Section({
                Title = "Space & Sci-Fi",
                Icon = "rocket",
                TextSize = 18,
                FontWeight = Enum.FontWeight.SemiBold,
            })
            
            animation:Button({
                Title = "Astronaut",
                Desc = "Float like you're in zero gravity",
                Icon = "rocket",
                Callback = function()
                    AnimationSystem.setAnimation("Idle", {"891621366", "891633237"})
                    AnimationSystem.setAnimation("Walk", "891667138")
                    AnimationSystem.setAnimation("Run", "10921039308")
                    AnimationSystem.setAnimation("Jump", "891627522")
                    AnimationSystem.setAnimation("Fall", "891617961")
                    
                    WindUI:Notify({
                        Title = "Astronaut Pack Applied",
                        Content = "Houston, we have liftoff!",
                        Duration = 2,
                        Icon = "check",
                    })
                end
            })
            
            animation:Button({
                Title = "Robot",
                Desc = "Mechanical and robotic movements",
                Icon = "cpu",
                Callback = function()
                    AnimationSystem.setAnimation("Idle", {"616088211", "616088211"})
                    AnimationSystem.setAnimation("Walk", "616095330")
                    AnimationSystem.setAnimation("Run", "616091570")
                    AnimationSystem.setAnimation("Jump", "616090535")
                    AnimationSystem.setAnimation("Fall", "616089559")
                    
                    WindUI:Notify({
                        Title = "Robot Pack Applied",
                        Content = "Beep boop! Systems online.",
                        Duration = 2,
                        Icon = "check",
                    })
                end
            })
            
            animation:Button({
                Title = "Mage",
                Desc = "Mystical spellcaster movements",
                Icon = "wand-sparkles",
                Callback = function()
                    AnimationSystem.setAnimation("Idle", {"707742142", "707742142"})
                    AnimationSystem.setAnimation("Walk", "707897309")
                    AnimationSystem.setAnimation("Run", "707861613")
                    AnimationSystem.setAnimation("Jump", "707853694")
                    AnimationSystem.setAnimation("Fall", "707829716")
                    
                    WindUI:Notify({
                        Title = "Mage Pack Applied",
                        Content = "Magic flows through you!",
                        Duration = 2,
                        Icon = "check",
                    })
                end
            })
            
            animation:Divider()
            
            -- ============================================================
            -- FANTASY & MEDIEVAL THEMED PACKS
            -- ============================================================
            animation:Section({
                Title = "Fantasy & Medieval",
                Icon = "sword",
                TextSize = 18,
                FontWeight = Enum.FontWeight.SemiBold,
            })
            
            animation:Button({
                Title = "Knight",
                Desc = "Noble and chivalrous movements",
                Icon = "shield",
                Callback = function()
                    AnimationSystem.setAnimation("Idle", {"657595757", "657595757"})
                    AnimationSystem.setAnimation("Walk", "657552124")
                    AnimationSystem.setAnimation("Run", "657564596")
                    AnimationSystem.setAnimation("Jump", "658409194")
                    AnimationSystem.setAnimation("Fall", "657600338")
                    
                    WindUI:Notify({
                        Title = "Knight Pack Applied",
                        Content = "For honor and glory!",
                        Duration = 2,
                        Icon = "check",
                    })
                end
            })
            
            animation:Button({
                Title = "Ninja",
                Desc = "Stealthy and swift movements",
                Icon = "wind",
                Callback = function()
                    AnimationSystem.setAnimation("Idle", {"656117400", "656117400"})
                    AnimationSystem.setAnimation("Walk", "656121766")
                    AnimationSystem.setAnimation("Run", "656118852")
                    AnimationSystem.setAnimation("Jump", "656117878")
                    AnimationSystem.setAnimation("Fall", "656115606")
                    AnimationSystem.setAnimation("Climb", "656114359")
                    
                    WindUI:Notify({
                        Title = "Ninja Pack Applied",
                        Content = "Silent as the shadows!",
                        Duration = 2,
                        Icon = "check",
                    })
                end
            })
            
            animation:Button({
                Title = "Pirate",
                Desc = "Swashbuckling sea movements",
                Icon = "anchor",
                Callback = function()
                    AnimationSystem.setAnimation("Idle", {"750781874", "750781874"})
                    AnimationSystem.setAnimation("Walk", "750785693")
                    AnimationSystem.setAnimation("Run", "750783738")
                    AnimationSystem.setAnimation("Jump", "750782230")
                    AnimationSystem.setAnimation("Fall", "750780242")
                    
                    WindUI:Notify({
                        Title = "Pirate Pack Applied",
                        Content = "Ahoy matey!",
                        Duration = 2,
                        Icon = "check",
                    })
                end
            })
            
            animation:Button({
                Title = "Cowboy",
                Desc = "Wild west gunslinger style",
                Icon = "crosshair",
                Callback = function()
                    AnimationSystem.setAnimation("Idle", {"1014390418", "1014390418"})
                    AnimationSystem.setAnimation("Walk", "1014421541")
                    AnimationSystem.setAnimation("Run", "1014401683")
                    AnimationSystem.setAnimation("Jump", "1014394726")
                    AnimationSystem.setAnimation("Fall", "1014384571")
                    
                    WindUI:Notify({
                        Title = "Cowboy Pack Applied",
                        Content = "Yeehaw partner!",
                        Duration = 2,
                        Icon = "check",
                    })
                end
            })
            
            animation:Divider()
            
            -- ============================================================
            -- HORROR & SPOOKY THEMED PACKS
            -- ============================================================
            animation:Section({
                Title = "Horror & Spooky",
                Icon = "ghost",
                TextSize = 18,
                FontWeight = Enum.FontWeight.SemiBold,
            })
            
            animation:Button({
                Title = "Zombie",
                Desc = "Undead shuffling movements",
                Icon = "skull",
                Callback = function()
                    AnimationSystem.setAnimation("Idle", {"616158929", "616158929"})
                    AnimationSystem.setAnimation("Walk", "616168032")
                    AnimationSystem.setAnimation("Run", "616163682")
                    AnimationSystem.setAnimation("Jump", "616161997")
                    AnimationSystem.setAnimation("Fall", "616157476")
                    
                    WindUI:Notify({
                        Title = "Zombie Pack Applied",
                        Content = "Braaains...",
                        Duration = 2,
                        Icon = "check",
                    })
                end
            })
            
            animation:Button({
                Title = "Vampire",
                Desc = "Dark and mysterious movements",
                Icon = "moon",
                Callback = function()
                    AnimationSystem.setAnimation("Idle", {"1083445855", "1083445855"})
                    AnimationSystem.setAnimation("Walk", "1083473930")
                    AnimationSystem.setAnimation("Run", "1083462077")
                    AnimationSystem.setAnimation("Jump", "1083455352")
                    AnimationSystem.setAnimation("Fall", "1083443587")
                    
                    WindUI:Notify({
                        Title = "Vampire Pack Applied",
                        Content = "The night is yours!",
                        Duration = 2,
                        Icon = "check",
                    })
                end
            })
            
            animation:Button({
                Title = "Werewolf",
                Desc = "Feral and aggressive movements",
                Icon = "dog",
                Callback = function()
                    AnimationSystem.setAnimation("Idle", {"1083195517", "1083195517"})
                    AnimationSystem.setAnimation("Walk", "1083178339")
                    AnimationSystem.setAnimation("Run", "1083216690")
                    AnimationSystem.setAnimation("Jump", "1083218792")
                    AnimationSystem.setAnimation("Fall", "1083189019")
                    
                    WindUI:Notify({
                        Title = "Werewolf Pack Applied",
                        Content = "Unleash the beast!",
                        Duration = 2,
                        Icon = "check",
                    })
                end
            })
            
            animation:Button({
                Title = "Ghost",
                Desc = "Ethereal floating movements",
                Icon = "ghost",
                Callback = function()
                    AnimationSystem.setAnimation("Idle", {"616006778", "616006778"})
                    AnimationSystem.setAnimation("Walk", "616013216")
                    AnimationSystem.setAnimation("Run", "616010382")
                    AnimationSystem.setAnimation("Jump", "616008936")
                    AnimationSystem.setAnimation("Fall", "616005863")
                    
                    WindUI:Notify({
                        Title = "Ghost Pack Applied",
                        Content = "Boo! Spectral form activated.",
                        Duration = 2,
                        Icon = "check",
                    })
                end
            })
            
            animation:Divider()
            
            -- ============================================================
            -- STYLISH & COOL THEMED PACKS
            -- ============================================================
            animation:Section({
                Title = "Stylish & Cool",
                Icon = "star",
                TextSize = 18,
                FontWeight = Enum.FontWeight.SemiBold,
            })
            
            animation:Button({
                Title = "Stylish",
                Desc = "Confident and fashionable",
                Icon = "sparkles",
                Callback = function()
                    AnimationSystem.setAnimation("Idle", {"616136790", "616136790"})
                    AnimationSystem.setAnimation("Walk", "616146177")
                    AnimationSystem.setAnimation("Run", "616140816")
                    AnimationSystem.setAnimation("Jump", "616139451")
                    AnimationSystem.setAnimation("Fall", "616134815")
                    
                    WindUI:Notify({
                        Title = "Stylish Pack Applied",
                        Content = "Looking good!",
                        Duration = 2,
                        Icon = "check",
                    })
                end
            })
            
            animation:Button({
                Title = "Superhero",
                Desc = "Heroic and powerful stance",
                Icon = "zap",
                Callback = function()
                    AnimationSystem.setAnimation("Idle", {"782841498", "782841498"})
                    AnimationSystem.setAnimation("Walk", "782843345")
                    AnimationSystem.setAnimation("Run", "782842708")
                    AnimationSystem.setAnimation("Jump", "782847020")
                    AnimationSystem.setAnimation("Fall", "782846423")
                    
                    WindUI:Notify({
                        Title = "Superhero Pack Applied",
                        Content = "With great power...",
                        Duration = 2,
                        Icon = "check",
                    })
                end
            })
            
            animation:Button({
                Title = "Popstar",
                Desc = "Star performer movements",
                Icon = "music",
                Callback = function()
                    AnimationSystem.setAnimation("Idle", {"1212900985", "1212900985"})
                    AnimationSystem.setAnimation("Walk", "1212980338")
                    AnimationSystem.setAnimation("Run", "1212980348")
                    AnimationSystem.setAnimation("Jump", "1212954642")
                    AnimationSystem.setAnimation("Fall", "1212900995")
                    
                    WindUI:Notify({
                        Title = "Popstar Pack Applied",
                        Content = "Ready for the stage!",
                        Duration = 2,
                        Icon = "check",
                    })
                end
            })
            
            animation:Button({
                Title = "Confident",
                Desc = "Bold and assertive movements",
                Icon = "trending-up",
                Callback = function()
                    AnimationSystem.setAnimation("Idle", {"1069977950", "1069977950"})
                    AnimationSystem.setAnimation("Walk", "1070017263")
                    AnimationSystem.setAnimation("Run", "1070001516")
                    AnimationSystem.setAnimation("Jump", "1069984524")
                    AnimationSystem.setAnimation("Fall", "1069973677")
                    
                    WindUI:Notify({
                        Title = "Confident Pack Applied",
                        Content = "Walk with swagger!",
                        Duration = 2,
                        Icon = "check",
                    })
                end
            })
            
            animation:Button({
                Title = "Sneaky",
                Desc = "Stealthy spy movements",
                Icon = "eye-off",
                Callback = function()
                    AnimationSystem.setAnimation("Idle", {"1132473842", "1132473842"})
                    AnimationSystem.setAnimation("Walk", "1132510133")
                    AnimationSystem.setAnimation("Run", "1132494274")
                    AnimationSystem.setAnimation("Jump", "1132489853")
                    AnimationSystem.setAnimation("Fall", "1132469004")
                    
                    WindUI:Notify({
                        Title = "Sneaky Pack Applied",
                        Content = "Shh... moving in shadows!",
                        Duration = 2,
                        Icon = "check",
                    })
                end
            })
            
            animation:Button({
                Title = "Princess",
                Desc = "Graceful and elegant movements",
                Icon = "crown",
                Callback = function()
                    AnimationSystem.setAnimation("Idle", {"941003647", "941003647"})
                    AnimationSystem.setAnimation("Walk", "941015281")
                    AnimationSystem.setAnimation("Run", "941008832")
                    AnimationSystem.setAnimation("Jump", "941008308")
                    AnimationSystem.setAnimation("Fall", "941000007")
                    
                    WindUI:Notify({
                        Title = "Princess Pack Applied",
                        Content = "Royal elegance activated!",
                        Duration = 2,
                        Icon = "check",
                    })
                end
            })
            
            animation:Button({
                Title = "Patrol",
                Desc = "Military patrol movements",
                Icon = "shield-alert",
                Callback = function()
                    AnimationSystem.setAnimation("Idle", {"1149612882", "1149612882"})
                    AnimationSystem.setAnimation("Walk", "1150967949")
                    AnimationSystem.setAnimation("Run", "1150967949")
                    AnimationSystem.setAnimation("Jump", "1148811837")
                    AnimationSystem.setAnimation("Fall", "1148863382")
                    
                    WindUI:Notify({
                        Title = "Patrol Pack Applied",
                        Content = "On duty!",
                        Duration = 2,
                        Icon = "check",
                    })
                end
            })
            
            animation:Button({
                Title = "Oldschool",
                Desc = "Classic Roblox style",
                Icon = "clock",
                Callback = function()
                    AnimationSystem.setAnimation("Idle", {"5319844329", "5319844329"})
                    AnimationSystem.setAnimation("Walk", "5319847204")
                    AnimationSystem.setAnimation("Run", "5319844329")
                    AnimationSystem.setAnimation("Jump", "5319841935")
                    AnimationSystem.setAnimation("Fall", "5319839762")
                    
                    WindUI:Notify({
                        Title = "Oldschool Pack Applied",
                        Content = "Back to the classics!",
                        Duration = 2,
                        Icon = "check",
                    })
                end
            })
            
            animation:Divider()
            
            -- ============================================================
            -- FUN & SILLY THEMED PACKS
            -- ============================================================
            animation:Section({
                Title = "Fun & Silly",
                Icon = "smile",
                TextSize = 18,
                FontWeight = Enum.FontWeight.SemiBold,
            })
            
            animation:Button({
                Title = "Toy",
                Desc = "Playful toy-like movements",
                Icon = "box",
                Callback = function()
                    AnimationSystem.setAnimation("Idle", {"782841498", "782841498"})
                    AnimationSystem.setAnimation("Walk", "782843345")
                    AnimationSystem.setAnimation("Run", "782842708")
                    AnimationSystem.setAnimation("Jump", "782847020")
                    AnimationSystem.setAnimation("Fall", "782846423")
                    
                    WindUI:Notify({
                        Title = "Toy Pack Applied",
                        Content = "Playtime!",
                        Duration = 2,
                        Icon = "check",
                    })
                end
            })
            
            animation:Button({
                Title = "Cartoony",
                Desc = "Bouncy cartoon movements",
                Icon = "laugh",
                Callback = function()
                    AnimationSystem.setAnimation("Idle", {"742637544", "742637544"})
                    AnimationSystem.setAnimation("Walk", "742640026")
                    AnimationSystem.setAnimation("Run", "742638842")
                    AnimationSystem.setAnimation("Jump", "742637942")
                    AnimationSystem.setAnimation("Fall", "742637151")
                    
                    WindUI:Notify({
                        Title = "Cartoony Pack Applied",
                        Content = "That's all folks!",
                        Duration = 2,
                        Icon = "check",
                    })
                end
            })
            
            animation:Button({
                Title = "Bubbly",
                Desc = "Cheerful and energetic",
                Icon = "smile",
                Callback = function()
                    AnimationSystem.setAnimation("Idle", {"910004836", "910004836"})
                    AnimationSystem.setAnimation("Walk", "910034870")
                    AnimationSystem.setAnimation("Run", "910025107")
                    AnimationSystem.setAnimation("Jump", "910016857")
                    AnimationSystem.setAnimation("Fall", "910001910")
                    
                    WindUI:Notify({
                        Title = "Bubbly Pack Applied",
                        Content = "So much energy!",
                        Duration = 2,
                        Icon = "check",
                    })
                end
            })
            
            animation:Button({
                Title = "Levitation",
                Desc = "Float above the ground",
                Icon = "move-up",
                Callback = function()
                    AnimationSystem.setAnimation("Idle", {"616006778", "616006778"})
                    AnimationSystem.setAnimation("Walk", "616013216")
                    AnimationSystem.setAnimation("Run", "616013216")
                    AnimationSystem.setAnimation("Jump", "616008936")
                    AnimationSystem.setAnimation("Fall", "616005863")
                    
                    WindUI:Notify({
                        Title = "Levitation Pack Applied",
                        Content = "Defying gravity!",
                        Duration = 2,
                        Icon = "check",
                    })
                end
            })
            
            animation:Divider()
            
            -- ============================================================
            -- ANIMAL & CREATURE THEMED PACKS
            -- ============================================================
            animation:Section({
                Title = "Animal & Creature",
                Icon = "paw-print",
                TextSize = 18,
                FontWeight = Enum.FontWeight.SemiBold,
            })
            
            animation:Button({
                Title = "Dinosaur",
                Desc = "Prehistoric reptile movements",
                Icon = "bug",
                Callback = function()
                    AnimationSystem.setAnimation("Idle", {"4417977954", "4417977954"})
                    AnimationSystem.setAnimation("Walk", "4417979645")
                    AnimationSystem.setAnimation("Run", "4417979645")
                    AnimationSystem.setAnimation("Jump", "4417978624")
                    AnimationSystem.setAnimation("Fall", "4417978264")
                    
                    WindUI:Notify({
                        Title = "Dinosaur Pack Applied",
                        Content = "Rawr! Jurassic mode!",
                        Duration = 2,
                        Icon = "check",
                    })
                end
            })
            
            animation:Button({
                Title = "Penguin",
                Desc = "Waddle like a penguin",
                Icon = "fish",
                Callback = function()
                    AnimationSystem.setAnimation("Idle", {"4417978624", "4417978624"})
                    AnimationSystem.setAnimation("Walk", "4417979645")
                    AnimationSystem.setAnimation("Run", "4417979645")
                    AnimationSystem.setAnimation("Jump", "4417978264")
                    AnimationSystem.setAnimation("Fall", "4417977954")
                    
                    WindUI:Notify({
                        Title = "Penguin Pack Applied",
                        Content = "Waddle waddle!",
                        Duration = 2,
                        Icon = "check",
                    })
                end
            })
            
            animation:Divider()
            
            -- ============================================================
            -- ELDER & CLASSIC THEMED PACKS
            -- ============================================================
            animation:Section({
                Title = "Elder & Classic",
                Icon = "users",
                TextSize = 18,
                FontWeight = Enum.FontWeight.SemiBold,
            })
            
            animation:Button({
                Title = "Elder",
                Desc = "Wise and elderly movements",
                Icon = "user",
                Callback = function()
                    AnimationSystem.setAnimation("Idle", {"845397899", "845397899"})
                    AnimationSystem.setAnimation("Walk", "845403856")
                    AnimationSystem.setAnimation("Run", "845386501")
                    AnimationSystem.setAnimation("Jump", "845398858")
                    AnimationSystem.setAnimation("Fall", "845400520")
                    
                    WindUI:Notify({
                        Title = "Elder Pack Applied",
                        Content = "Wisdom of the ages!",
                        Duration = 2,
                        Icon = "check",
                    })
                end
            })
            
            animation:Button({
                Title = "Rthro",
                Desc = "Modern realistic movements",
                Icon = "user-check",
                Callback = function()
                    AnimationSystem.setAnimation("Idle", {"2510196951", "2510196951"})
                    AnimationSystem.setAnimation("Walk", "2510202577")
                    AnimationSystem.setAnimation("Run", "2510198475")
                    AnimationSystem.setAnimation("Jump", "2510197830")
                    AnimationSystem.setAnimation("Fall", "2510195892")
                    
                    WindUI:Notify({
                        Title = "Rthro Pack Applied",
                        Content = "Realistic motion!",
                        Duration = 2,
                        Icon = "check",
                    })
                end
            })
            
            animation:Divider()
            
            -- ============================================================
            -- NEW & TRENDY PACKS (2024-2025)
            -- ============================================================
            animation:Section({
                Title = "New & Trendy",
                Icon = "trending-up",
                TextSize = 18,
                FontWeight = Enum.FontWeight.SemiBold,
            })
            
            animation:Button({
                Title = "Adidas Superstar",
                Desc = "Sporty athletic style",
                Icon = "dribbble",
                Callback = function()
                    AnimationSystem.setAnimation("Idle", {"3337708528", "3337708528"})
                    AnimationSystem.setAnimation("Walk", "3360978409")
                    AnimationSystem.setAnimation("Run", "3360978409")
                    AnimationSystem.setAnimation("Jump", "3337713741")
                    AnimationSystem.setAnimation("Fall", "3337719206")
                    
                    WindUI:Notify({
                        Title = "Adidas Superstar Applied",
                        Content = "Athletic mode activated!",
                        Duration = 2,
                        Icon = "check",
                    })
                end
            })
            
            animation:Button({
                Title = "Blocky",
                Desc = "Classic blocky style",
                Icon = "square",
                Callback = function()
                    AnimationSystem.setAnimation("Idle", {"4211217646", "4211217646"})
                    AnimationSystem.setAnimation("Walk", "4211217646")
                    AnimationSystem.setAnimation("Run", "4211217646")
                    AnimationSystem.setAnimation("Jump", "4211217646")
                    AnimationSystem.setAnimation("Fall", "4211217646")
                    
                    WindUI:Notify({
                        Title = "Blocky Pack Applied",
                        Content = "Back to basics!",
                        Duration = 2,
                        Icon = "check",
                    })
                end
            })
            
            animation:Button({
                Title = "Hero Idle",
                Desc = "Epic hero stance",
                Icon = "sword",
                Callback = function()
                    AnimationSystem.setAnimation("Idle", {"5104344710", "5104344710"})
                    AnimationSystem.setAnimation("Walk", "5104346065")
                    AnimationSystem.setAnimation("Run", "5104346065")
                    AnimationSystem.setAnimation("Jump", "5104344710")
                    AnimationSystem.setAnimation("Fall", "5104344710")
                    
                    WindUI:Notify({
                        Title = "Hero Idle Applied",
                        Content = "Hero pose activated!",
                        Duration = 2,
                        Icon = "check",
                    })
                end
            })
            
            animation:Button({
                Title = "Udzal",
                Desc = "Unique modern style",
                Icon = "zap",
                Callback = function()
                    AnimationSystem.setAnimation("Idle", {"3303162274", "3303162274"})
                    AnimationSystem.setAnimation("Walk", "3303162549")
                    AnimationSystem.setAnimation("Run", "3303162549")
                    AnimationSystem.setAnimation("Jump", "3303162274")
                    AnimationSystem.setAnimation("Fall", "3303162274")
                    
                    WindUI:Notify({
                        Title = "Udzal Pack Applied",
                        Content = "Unique style!",
                        Duration = 2,
                        Icon = "check",
                    })
                end
            })
            
            animation:Button({
                Title = "Toilet Tower Defense",
                Desc = "Meme animation style",
                Icon = "laugh",
                Callback = function()
                    AnimationSystem.setAnimation("Idle", {"3303162274", "3303162274"})
                    AnimationSystem.setAnimation("Walk", "3303162549")
                    AnimationSystem.setAnimation("Run", "3360978409")
                    AnimationSystem.setAnimation("Jump", "3337713741")
                    AnimationSystem.setAnimation("Fall", "3337719206")
                    
                    WindUI:Notify({
                        Title = "TTD Pack Applied",
                        Content = "Skibidi mode!",
                        Duration = 2,
                        Icon = "check",
                    })
                end
            })
            
            animation:Divider()
            
            -- ============================================================
            -- EMOTES SECTION
            -- ============================================================
            animation:Section({
                Title = "Emotes (One-Time Play)",
                Icon = "hand",
                TextSize = 18,
                FontWeight = Enum.FontWeight.SemiBold,
            })
            
            animation:Paragraph({
                Title = "How Emotes Work",
                Desc = "Click to play emote once. Emote stops when you move.",
            })
            
            animation:Button({
                Title = "Dance",
                Icon = "music",
                Callback = function()
                    AnimationSystem.PlayEmote("507771019")
                    WindUI:Notify({
                        Title = "Dance Emote",
                        Content = "Show your moves!",
                        Duration = 1,
                        Icon = "music",
                    })
                end
            })
            
            animation:Button({
                Title = "Point",
                Icon = "hand",
                Callback = function()
                    AnimationSystem.PlayEmote("507770239")
                    WindUI:Notify({
                        Title = "Point Emote",
                        Content = "Pointing!",
                        Duration = 1,
                        Icon = "hand",
                    })
                end
            })
            
            animation:Button({
                Title = "Wave",
                Icon = "hand",
                Callback = function()
                    AnimationSystem.PlayEmote("507770239")
                    WindUI:Notify({
                        Title = "Wave Emote",
                        Content = "Hello there!",
                        Duration = 1,
                        Icon = "hand",
                    })
                end
            })
            
            animation:Button({
                Title = "Laugh",
                Icon = "laugh",
                Callback = function()
                    AnimationSystem.PlayEmote("507770818")
                    WindUI:Notify({
                        Title = "Laugh Emote",
                        Content = "Haha!",
                        Duration = 1,
                        Icon = "laugh",
                    })
                end
            })
        
            animation:Button({
                Title = "Cheer",
                Icon = "smile",
                Callback = function()
                    AnimationSystem.PlayEmote("507770677")
                    WindUI:Notify({
                        Title = "Cheer Emote",
                        Content = "Woohoo!",
                        Duration = 1,
                        Icon = "smile",
                    })
                end
            })
        
            animation:Divider()
        
        -- ============================================================
        -- RESET & INFO
        -- ============================================================
        animation:Section({
            Title = "Controls",
            Icon = "settings",
            TextSize = 18,
            FontWeight = Enum.FontWeight.SemiBold,
        })
        
        animation:Button({
            Title = "Reset to Default Roblox",
            Desc = "Restore original R15 animations",
            Icon = "rotate-ccw",
            Color = Color3.fromHex("#FF6B6B"),
            Callback = function()
                AnimationSystem.setAnimation("Idle", {"507766388", "507766666"})
                AnimationSystem.setAnimation("Walk", "507777826")
                AnimationSystem.setAnimation("Run", "507767714")
                AnimationSystem.setAnimation("Jump", "507765000")
                AnimationSystem.setAnimation("Fall", "507767968")
                
                WindUI:Notify({
                    Title = "Reset Complete",
                    Content = "Back to default animations",
                    Duration = 2,
                    Icon = "check",
                })
            end
        })
        
        animation:Divider()
        
        animation:Section({
            Title = "Information",
            Icon = "info",
            TextSize = 18,
            FontWeight = Enum.FontWeight.SemiBold,
        })
        
        animation:Paragraph({
            Title = "Total Packs Available",
            Desc = "• 30+ Animation Packs\n• 5+ Emotes\n• Auto-save enabled\n• Respawn support\n• Works only with R15",
        })
        
    end -- End R15 check
end -- End animation tab scope

    -- ============================================================
    -- EMOTES TAB
    -- ============================================================
    local emotes = Window:Tab({
        Title = "Emotes",
        Icon = "hand",
        Locked = false,
    })

    emotes:Section({
        Title = "SynceHub Emotes",
        Icon = "sparkles",
        TextSize = 20,
        FontWeight = Enum.FontWeight.Bold,
    })

    emotes:Paragraph({
        Title = "Advanced Emote System",
        Desc = "Access hundreds of Roblox emotes with our advanced emote player. Play animations, dance moves, and express yourself with style!",
    })

    emotes:Divider()

    emotes:Section({
        Title = "Features",
        Icon = "list",
        TextSize = 18,
        FontWeight = Enum.FontWeight.SemiBold,
    })

    emotes:Paragraph({
        Title = "What's Included",
        Desc = "• 3000+ Emote Animations\n• Search & Filter System\n• Favorite Emotes\n• Custom Animation IDs\n• Loop & Speed Control\n• Stop All Animations\n• Mobile Friendly Interface",
    })

    emotes:Divider()

    emotes:Section({
        Title = "Launch Emote Player",
        Icon = "play",
        TextSize = 18,
        FontWeight = Enum.FontWeight.SemiBold,
    })

    emotes:Button({
        Title = "Open Emote Player",
        Desc = "Launch the full emote player interface",
        Icon = "external-link",
        Color = Color3.fromHex("#0091FF"),
        Justify = "Center",
        Callback = function()
            task.spawn(function()
                pcall(function()
                    loadstring(game:HttpGet('https://raw.githubusercontent.com/SynceXxx/SynceXHub/refs/heads/main/SynceEmotes.lua'))()
                end)
            end)
        end
    })

    emotes:Space()

    emotes:Paragraph({
        Title = "How to Use",
        Desc = "1. Click 'Open Emote Player' button above\n2. Browse through emote categories\n3. Click any emote to play it\n4. Use search to find specific emotes\n5. Add favorites for quick access",
    })

    emotes:Divider()

    emotes:Section({
        Title = "Information",
        Icon = "info",
        TextSize = 18,
        FontWeight = Enum.FontWeight.SemiBold,
    })

    emotes:Paragraph({
        Title = "About SynceHub Emotes",
        Desc = "SynceHub Emotes is a powerful emote player that gives you access to hundreds of Roblox animations. Perfect for roleplaying, creating content, or just having fun!",
    })

    emotes:Space()

    emotes:Paragraph({
        Title = "Tips",
        Desc = "• Some emotes may not work in all games\n• Moving will stop most emotes\n• Emotes work best with R15 characters",
    })
    
    -- ============================================================
    -- TROLL TAB
    -- ============================================================
    local troll = Window:Tab({
        Title = "Troll",
        Icon = "laugh",
        Locked = false,
    })

    troll:Section({
        Title = "Troll Features",
        Icon = "smile",
        TextSize = 20,
        FontWeight = Enum.FontWeight.Bold,
    })

    troll:Paragraph({
        Title = "WalkFling & Protection Tools",
        Desc = "Walk around and fling nearby players, or protect yourself from being flung. Use responsibly!",
    })

    troll:Divider()

    -- ============================================================
    -- WALKFLING SECTION
    -- ============================================================
    troll:Section({
        Title = "WalkFling System",
        Icon = "tornado",
        TextSize = 18,
        FontWeight = Enum.FontWeight.SemiBold,
    })

    troll:Paragraph({
        Title = "How WalkFling Works",
        Desc = "Walk normally while an invisible spinning hitbox surrounds you. Any player you touch will be flung away!",
    })

    Reg("walkfling", troll:Toggle({
        Title = "Enable WalkFling",
        Desc = "Walk around to fling nearby players",
        Value = false,
        Callback = function(state)
            local WalkFlingSystem = _G.SynceHub.WalkFlingSystem
            
            if state then
                WalkFlingSystem.Toggle()
                WindUI:Notify({
                    Title = "WalkFling Enabled!",
                    Content = "Walk into players to fling them.",
                    Duration = 3,
                    Icon = "tornado",
                })
            else
                WalkFlingSystem.Toggle()
                WindUI:Notify({
                    Title = "WalkFling Disabled",
                    Content = "WalkFling has been turned off.",
                    Duration = 2,
                    Icon = "x",
                })
            end
        end
    }))

    Reg("walkflingpower", troll:Slider({
        Title = "WalkFling Power",
        Desc = "Adjust fling strength (Higher = Stronger)",
        Step = 100,
        Value = {
            Min = 500,
            Max = 5000,
            Default = 2000,
        },
        Callback = function(value)
            local powerValue = tonumber(value)
            if powerValue and powerValue >= 500 then
                _G.SynceHub.WalkFlingSystem.SetPower(powerValue)
            end
        end,
    }))

    troll:Space()

    troll:Paragraph({
        Title = "✨ Features",
        Desc = "• Walk normally while flinging\n• You won't get flung yourself\n• Invisible hitbox (8x8x8)\n• Adjustable power\n• Works with NoClip & Fly",
    })

    troll:Space()

    troll:Paragraph({
        Title = "⚠️ Warning",
        Desc = "Some games may kick you for using walkfling. Use at your own risk!",
    })

    troll:Divider()

    -- ============================================================
    -- ANTI-FLING SECTION
    -- ============================================================
    troll:Section({
        Title = "Anti-Fling System",
        Icon = "shield",
        TextSize = 18,
        FontWeight = Enum.FontWeight.SemiBold,
    })

    troll:Paragraph({
        Title = "How Anti-Fling Works",
        Desc = "Protects you from being flung by other players. Automatically resets your velocity when someone tries to fling you.",
    })

    Reg("antifling", troll:Toggle({
        Title = "Enable Anti-Fling",
        Desc = "Protect yourself from being flung",
        Value = false,
        Callback = function(state)
            local AntiFlingSystem = _G.SynceHub.AntiFlingSystem
            
            if state then
                AntiFlingSystem.Toggle()
                WindUI:Notify({
                    Title = "Anti-Fling Enabled!",
                    Content = "You are now protected from fling.",
                    Duration = 3,
                    Icon = "shield",
                })
            else
                AntiFlingSystem.Toggle()
                WindUI:Notify({
                    Title = "Anti-Fling Disabled",
                    Content = "Protection has been turned off.",
                    Duration = 2,
                    Icon = "shield-off",
                })
            end
        end
    }))

    troll:Space()

    troll:Paragraph({
        Title = "✅ Benefits",
        Desc = "• Prevents being flung by trolls\n• Removes unwanted body movers\n• Auto-resets high velocity\n• Works on respawn\n• Compatible with all features",
    })

    troll:Divider()

    -- ============================================================
    -- INFORMATION SECTION
    -- ============================================================
    troll:Section({
        Title = "Information",
        Icon = "info",
        TextSize = 18,
        FontWeight = Enum.FontWeight.SemiBold,
    })

    troll:Paragraph({
        Title = "Tips & Notes",
        Desc = "• Cannot use WalkFling & Anti-Fling together\n• WalkFling works best with WalkSpeed\n• Anti-Fling persists through respawns\n• Some games may have built-in anti-fling\n• Combine with NoClip for better movement",
    })

    troll:Space()

    troll:Paragraph({
        Title = "Responsible Usage",
        Desc = "These tools are for fun and self-defense. Please don't use them to ruin other players' experience. Be respectful and have fun responsibly!",
    })
    
    -- ============================================================
    -- CONFIGURATION TAB
    -- ============================================================
    local SettingsTab = Window:Tab({
        Title = "Configuration",
        Icon = "settings",
        Locked = false,
    })

    SettingsTab:Section({
        Title = "Config Manager",
        Icon = "cog",
        TextSize = 19,
    })
    
    local ConfigManager = Window.ConfigManager
    local SelectedConfigName = "Syncehub"

    local function RefreshConfigList(dropdown)
        local list = ConfigManager:AllConfigs()
        if #list == 0 then list = {"None"} end
        pcall(function() dropdown:Refresh(list) end)
    end

    local ConfigNameInput = SettingsTab:Input({
        Title = "Config Name",
        Desc = "The name of the new config to be saved.",
        Value = "Syncehub",
        Placeholder = "e.g. MyConfig",
        Icon = "file-pen",
        Callback = function(text)
            SelectedConfigName = text
        end
    })

    local ConfigDropdown = SettingsTab:Dropdown({
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

    SettingsTab:Button({
        Title = "Refresh List",
        Icon = "refresh-ccw",
        Callback = function() RefreshConfigList(ConfigDropdown) end
    })

    SettingsTab:Button({
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

    SettingsTab:Button({
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

    SettingsTab:Button({
        Title = "Delete Config",
        Icon = "trash-2",
        Color = Color3.fromRGB(255, 80, 80),
        Callback = function()
            if SelectedConfigName == "" or SelectedConfigName == "Syncehub" then 
                WindUI:Notify({ 
                    Title = "Cannot Delete", 
                    Content = "Cannot delete default or empty config.", 
                    Duration = 3,
                    Icon = "info"
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
    
    SettingsTab:Divider()

    -- ============================================================
    -- RESET OPTIONS SECTION
    -- ============================================================
    SettingsTab:Section({
        Title = "Reset Options",
        Icon = "refresh-ccw",
        TextSize = 19,
    })

    SettingsTab:Button({
        Title = "Reset All Settings to Default",
        Desc = "Clear all saved settings and restore to default values",
        Icon = "trash-2",
        Color = Color3.fromRGB(255, 100, 100),
        Callback = function()
            local success, err = pcall(function()
                -- Delete default config file
                local defaultPath = BaseFolder .. "Syncehub.json"
                if isfile(defaultPath) then
                    delfile(defaultPath)
                end
                
                -- Reset all element values
                for id, element in pairs(ElementRegistry) do
                    pcall(function()
                        if element.Set then
                            if element.Type == "Toggle" then
                                element:Set(false)
                            elseif element.Type == "Slider" then
                                if id == "Walkspeed" then
                                    element:Set(_G.SynceHub.DEFAULT_SPEED or 16)
                                elseif id == "slidjump" then
                                    element:Set(_G.SynceHub.DEFAULT_JUMP or 50)
                                end
                            elseif element.Type == "Dropdown" then
                                element:Set(false)
                            elseif element.Type == "Input" then
                                element:Set("")
                            end
                        end
                    end)
                end
            end)
            
            if success then
                WindUI:Notify({ 
                    Title = "Reset Complete!", 
                    Content = "All settings restored to default.", 
                    Duration = 4, 
                    Icon = "check" 
                })
            else
                WindUI:Notify({ 
                    Title = "Reset Failed", 
                    Content = "Error: " .. tostring(err), 
                    Duration = 4, 
                    Icon = "x" 
                })
            end
        end
    })

    SettingsTab:Paragraph({
        Title = "About Reset",
        Desc = "This will delete your saved config and turn off all features.",
    })
    
    -- Keybind Setting
    SettingsTab:Divider()
    
    SettingsTab:Section({
        Title = "UI Settings",
        Icon = "keyboard",
        TextSize = 19,
    })
    
    SettingsTab:Keybind({
        Title = "Toggle Keybind",
        Desc = "Keybind to open/close UI",
        Value = "F",
        Callback = function(v)
            Window:SetToggleKey(Enum.KeyCode[v])
        end
    })
end

return TabContent