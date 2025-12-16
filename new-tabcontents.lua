-- ============================================================
-- SYNCEHUB FIXED VERSION - PART 1
-- SALIN PART 1 INI DULU, LALU LANJUT KE PART 2
-- ============================================================

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
        Image = "rbxassetid://114915707934715",
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
        Image = "rbxassetid://114915707934715",
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

    home:Section({
        Title = "Update History",
        Icon = "clock",
        TextSize = 18,
        FontWeight = Enum.FontWeight.SemiBold,
    })

    home:Paragraph({
        Title = "Version Beta - 14 Dec 2025",
        Desc = "[FIXED] All critical bugs patched\n[FIXED] Memory leaks resolved\n[FIXED] Respawn handlers added\n[FIXED] Better error handling\n[+] Improved stability",
    })

    home:Paragraph({
        Title = "Player Features",
        Desc = "[+] WalkSpeed & JumpPower sliders\n[+] Infinite Jump toggle\n[+] No Clip mode with respawn handler\n[+] Fly Mode with proper cleanup\n[+] Freeze Player with respawn fix\n[+] Player ESP (memory leak fixed)\n[+] Reset Character in place",
    })

    home:Paragraph({
        Title = "Tools & Utilities",
        Desc = "[+] Infinite Zoom Out\n[+] Disable 3D Rendering\n[+] FPS Ultra Boost\n[+] Server Management (better error handling)\n[+] Cinematic Free Cam\n[+] Hide All UI (Clean Mode)",
    })

    home:Space()

    -- Footer
    home:Section({
        Title = "SynceHub v1.0 Beta (Fixed) | Made by SynceHub",
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
-- SYNCEHUB FIXED VERSION - PART 2
-- SALIN PART 2 INI DAN TEMPEL DI BAWAH PART 1
-- ============================================================

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
    -- FIXED: FLY MODE WITH PROPER CLEANUP
    -- ============================================================
    local flyConnection = nil
    local isFlying = false
    local flySpeed = 60
    local bodyGyro, bodyVel
    
    Reg("flym", ability:Toggle({
        Title = "Fly Mode",
        Value = false,
        Callback = function(state)
            local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
            local humanoidRootPart = character:WaitForChild("HumanoidRootPart")
            local humanoid = character:WaitForChild("Humanoid")

            if state then
                WindUI:Notify({ 
                    Title = "Fly Mode ON!", 
                    Content = "You can now fly freely.",
                    Duration = 3, 
                    Icon = "check" 
                })
                isFlying = true

                bodyGyro = Instance.new("BodyGyro")
                bodyGyro.P = 9e4
                bodyGyro.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
                bodyGyro.CFrame = humanoidRootPart.CFrame
                bodyGyro.Parent = humanoidRootPart

                bodyVel = Instance.new("BodyVelocity")
                bodyVel.Velocity = Vector3.zero
                bodyVel.MaxForce = Vector3.new(9e9, 9e9, 9e9)
                bodyVel.Parent = humanoidRootPart

                local cam = workspace.CurrentCamera
                local moveDir = Vector3.zero
                local jumpPressed = false

                UserInputService.JumpRequest:Connect(function()
                    if isFlying then 
                        jumpPressed = true 
                        task.delay(0.2, function() jumpPressed = false end) 
                    end
                end)

                flyConnection = RunService.RenderStepped:Connect(function()
                    if not isFlying or not humanoidRootPart or not bodyGyro or not bodyVel then return end
                    
                    bodyGyro.CFrame = cam.CFrame
                    moveDir = humanoid.MoveDirection

                    if jumpPressed then
                        moveDir = moveDir + Vector3.new(0, 1, 0)
                    elseif UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then
                        moveDir = moveDir - Vector3.new(0, 1, 0)
                    end

                    if moveDir.Magnitude > 0 then 
                        moveDir = moveDir.Unit * flySpeed 
                    end

                    bodyVel.Velocity = moveDir
                end)

            else
                WindUI:Notify({ 
                    Title = "Fly Mode OFF!", 
                    Content = "Flight mode has been disabled.",
                    Duration = 3, 
                    Icon = "x" 
                })
                isFlying = false

                if flyConnection then 
                    flyConnection:Disconnect() 
                    flyConnection = nil 
                end
                
                -- FIXED: Proper cleanup from character
                if humanoidRootPart then
                    for _, obj in pairs(humanoidRootPart:GetChildren()) do
                        if obj:IsA("BodyGyro") or obj:IsA("BodyVelocity") then
                            pcall(function() obj:Destroy() end)
                        end
                    end
                end
                
                bodyGyro = nil
                bodyVel = nil
            end
        end
    }))
    
    -- ============================================================
-- SYNCEHUB FIXED VERSION - PART 3
-- SALIN PART 3 INI DAN TEMPEL DI BAWAH PART 2
-- ============================================================

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
-- SYNCEHUB FIXED VERSION - PART 4
-- SALIN PART 4 INI DAN TEMPEL DI BAWAH PART 3
-- ============================================================

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
-- SYNCEHUB FIXED VERSION - PART 5
-- SALIN PART 5 INI DAN TEMPEL DI BAWAH PART 4
-- ============================================================

    -- ============================================================
    -- TOOLS TAB
    -- ============================================================
    local utility = Window:Tab({
        Title = "Tools",
        Icon = "box",
        Locked = false,
    })

    local misc = utility:Section({ 
        Title = "Misc. Area", 
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
-- SYNCEHUB FIXED VERSION - PART 6
-- SALIN PART 6 INI DAN TEMPEL DI BAWAH PART 5
-- ============================================================

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
-- SYNCEHUB FIXED VERSION - PART 7 (FINAL PART)
-- SALIN PART 7 INI DAN TEMPEL DI BAWAH PART 6
-- INI PART TERAKHIR UNTUK tabdancontent.lua!
-- ============================================================

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
    -- ANIMATION PLAYER TAB
    -- ============================================================
    local animation = Window:Tab({
        Title = "Animation",
        Icon = "list-video",
        Locked = false,
    })

    -- Animation State Variables
    local currentTrack = nil
    local currentAnimId = ""
    local loopEnabled = true
    local animSpeed = 1

    -- Helper Functions
    local function GetAnimator()
        local char = LocalPlayer.Character
        if not char then return nil end
        
        local humanoid = char:FindFirstChildOfClass("Humanoid")
        if not humanoid then return nil end
        
        local animator = humanoid:FindFirstChildOfClass("Animator")
        if not animator then
            animator = Instance.new("Animator")
            animator.Parent = humanoid
        end
        
        return animator
    end

    local function StopCurrentAnimation()
        if currentTrack then
            currentTrack:Stop()
            currentTrack:Destroy()
            currentTrack = nil
        end
    end

    -- ============================================================
    -- HEADER
    -- ============================================================
    animation:Section({
        Title = "Animation Player",
        Icon = "film",
        TextSize = 22,
        FontWeight = Enum.FontWeight.Bold,
    })

    animation:Paragraph({
        Title = "Custom Animation Player",
        Desc = "Play custom Roblox animations on your character. Enter an Animation ID to get started!",
    })

    animation:Divider()

    -- ============================================================
    -- CONTROLS SECTION
    -- ============================================================
    animation:Section({
        Title = "Animation Controls",
        Icon = "settings",
        TextSize = 18,
        FontWeight = Enum.FontWeight.SemiBold,
    })

    -- Animation ID Input
    local animIdInput = Reg("AnimationID", animation:Input({
        Title = "Animation ID",
        Desc = "Enter the Roblox Animation ID (numbers only)",
        Placeholder = "e.g. 507766388",
        Icon = "hash",
        Value = "",
        Callback = function(text)
            currentAnimId = text
        end
    }))

    -- Loop Toggle
    Reg("AnimLoop", animation:Toggle({
        Title = "Loop Animation",
        Desc = "Repeat animation continuously",
        Value = true,
        Callback = function(state)
            loopEnabled = state
            if currentTrack then
                currentTrack.Looped = state
            end
        end
    }))

    -- Speed Slider
    Reg("AnimSpeed", animation:Slider({
        Title = "Animation Speed",
        Desc = "Adjust playback speed (0.1x - 5x)",
        Step = 0.1,
        Value = {
            Min = 0.1,
            Max = 5,
            Default = 1,
        },
        Callback = function(value)
            animSpeed = value
            if currentTrack and currentTrack.IsPlaying then
                currentTrack:AdjustSpeed(value)
            end
        end
    }))

    animation:Space()

    -- ============================================================
    -- PLAY/STOP BUTTONS
    -- ============================================================

    -- Play Button
    animation:Button({
        Title = "Play Animation",
        Icon = "play",
        Justify = "Center",
        Color = Color3.fromHex("#10C550"),
        Callback = function()
            -- Validation
            if currentAnimId == "" or currentAnimId == nil then
                WindUI:Notify({
                    Title = "No Animation ID",
                    Content = "Please enter an Animation ID first!",
                    Duration = 3,
                    Icon = "alert-triangle",
                })
                return
            end
            
            -- Check if ID is valid number
            if not tonumber(currentAnimId) then
                WindUI:Notify({
                    Title = "Invalid ID",
                    Content = "Animation ID must be numbers only!",
                    Duration = 3,
                    Icon = "x",
                })
                return
            end
            
            local animator = GetAnimator()
            if not animator then
                WindUI:Notify({
                    Title = "Error",
                    Content = "Could not find Animator!",
                    Duration = 3,
                    Icon = "alert-triangle",
                })
                return
            end
            
            -- Stop current animation
            StopCurrentAnimation()
            
            -- Load and play new animation
            local success, errorMsg = pcall(function()
                local anim = Instance.new("Animation")
                anim.AnimationId = "rbxassetid://" .. currentAnimId
                
                currentTrack = animator:LoadAnimation(anim)
                currentTrack.Looped = loopEnabled
                currentTrack.Priority = Enum.AnimationPriority.Action
                
                currentTrack:Play()
                currentTrack:AdjustSpeed(animSpeed)
                
                WindUI:Notify({
                    Title = "Animation Playing",
                    Content = "Animation ID: " .. currentAnimId,
                    Duration = 3,
                    Icon = "play",
                })
            end)
            
            if not success then
                WindUI:Notify({
                    Title = "Load Failed",
                    Content = "Failed to load animation. Check ID!",
                    Duration = 3,
                    Icon = "x",
                })
            end
        end
    })

    -- Stop Button
    animation:Button({
        Title = "Stop Animation",
        Icon = "square",
        Justify = "Center",
        Color = Color3.fromHex("#EF4F1D"),
        Callback = function()
            if currentTrack then
                StopCurrentAnimation()
                
                WindUI:Notify({
                    Title = "Animation Stopped",
                    Content = "Animation has been stopped",
                    Duration = 2,
                    Icon = "square",
                })
            else
                WindUI:Notify({
                    Title = "No Animation",
                    Content = "No animation is currently playing",
                    Duration = 2,
                    Icon = "info",
                })
            end
        end
    })

    animation:Divider()

    -- ============================================================
    -- PRESET ANIMATIONS
    -- ============================================================
    animation:Section({
        Title = "Preset Animations",
        Icon = "bookmark",
        TextSize = 18,
        FontWeight = Enum.FontWeight.SemiBold,
    })

    animation:Section({
        Title = "Popular animations you can try",
        TextSize = 14,
        TextTransparency = 0.4,
    })

    -- Preset List
    local presets = {
        {Name = "Default Dance", ID = "507766388"},
        {Name = "Orange Justice", ID = "507770239"},
        {Name = "Floss", ID = "507770677"},
        {Name = "Take The L", ID = "507766666"},
        {Name = "Electro Shuffle", ID = "507771019"},
        {Name = "Robot", ID = "507771955"},
        {Name = "Hype", ID = "507771378"},
        {Name = "Twist", ID = "507765644"},
    }

    for i, preset in ipairs(presets) do
        animation:Button({
            Title = preset.Name,
            Icon = "play",
            Callback = function()
                currentAnimId = preset.ID
                animIdInput:Set(preset.ID)
                
                WindUI:Notify({
                    Title = "Preset Selected",
                    Content = preset.Name .. " - Click Play to start!",
                    Duration = 2,
                    Icon = "check",
                })
            end
        })
        
        if i < #presets then
            animation:Space()
        end
    end

    animation:Divider()

    -- ============================================================
    -- HOW TO USE
    -- ============================================================
    animation:Section({
        Title = "How to Use",
        Icon = "help-circle",
        TextSize = 18,
        FontWeight = Enum.FontWeight.SemiBold,
    })

    animation:Paragraph({
        Title = "Finding Animation IDs",
        Desc = "1. Go to Roblox website\n2. Search for animations in the catalog\n3. Open an animation page\n4. Copy the number from the URL\n5. Paste it in the Animation ID field above\n6. Click Play Animation\n\nExample URL: roblox.com/library/507766388/\nAnimation ID: 507766388",
    })

    animation:Paragraph({
        Title = "Tips & Notes",
        Desc = "[+] You can adjust speed while animation is playing\n[+] Enable/disable loop before playing\n[+] Use preset animations for quick testing\n[~] Some animations may not work (creator permissions)\n[~] Stop animation before playing a new one",
    })

    -- Cleanup on character respawn
    LocalPlayer.CharacterAdded:Connect(function()
        StopCurrentAnimation()
    end)
    
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
    
    -- Keybind Setting
    SettingsTab:Divider()
    
    SettingsTab:Section({
        Title = "UI Settings",
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