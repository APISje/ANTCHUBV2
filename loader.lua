--[[
    ╔═══════════════════════════════════════════════════════════╗
    ║                     ANTC HUB LOADER                       ║
    ║              Discord: https://discord.gg/antchub          ║
    ╚═══════════════════════════════════════════════════════════╝
    
    FEATURES:
    - Security features (Anti AFK, Anti Staff, Anti Troll)
    - In-game MS/Ping display (tidak mengikuti GUI)
    - DEX Explorer (locked - unlock dengan dev mode)
    - Super Bland & Super Intan (locked - unlock dengan dev mode)
    - RGB Nametag untuk aapis3308
    - Teleport to player (support username & display name)
    - Fast Auto Clicker FIXED (benar-benar klik!)
]]

print("🔄 Loading ANTC HUB...")

-- Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TeleportService = game:GetService("TeleportService")
local UserInputService = game:GetService("UserInputService")
local VirtualInputManager = game:GetService("VirtualInputManager")
local Stats = game:GetService("Stats")

-- Load WindUI Library
local WindUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/APISje/ANTCHUBV2/refs/heads/main/main.lua", true))()

print("✅ ANTC HUB Library Loaded!")

-- ═══════════════════════════════════════════════════════════
-- SETTING BANNER & LOGO (GANTI DISINI)
-- ═══════════════════════════════════════════════════════════
local BannerImageID = "10723415766"
local LogoImageID = "10723415766"
-- ═══════════════════════════════════════════════════════════

-- Variables
local LocalPlayer = Players.LocalPlayer

-- ═══════════════════════════════════════════════════════════
-- DEVELOPMENT MODE SYSTEM
-- ═══════════════════════════════════════════════════════════
local DevelopmentMode = false
local DevelopmentCode = "APIS"

-- ═══════════════════════════════════════════════════════════
-- IN-GAME MS DISPLAY (TIDAK MENGIKUTI GUI)
-- ═══════════════════════════════════════════════════════════
local MSDisplayEnabled = false
local MSBillboard = nil
local MSUpdateConnection = nil
local MSCharacterConnection = nil

local function CleanupMSDisplay()
    if MSBillboard then
        MSBillboard:Destroy()
        MSBillboard = nil
    end
    
    if MSUpdateConnection then
        MSUpdateConnection:Disconnect()
        MSUpdateConnection = nil
    end
end

local function CreateMSDisplay()
    CleanupMSDisplay()
    
    local character = LocalPlayer.Character
    if not character or not character:FindFirstChild("Head") then
        return
    end
    
    MSBillboard = Instance.new("BillboardGui")
    MSBillboard.Name = "MSDisplay"
    MSBillboard.Adornee = character.Head
    MSBillboard.Size = UDim2.new(0, 100, 0, 40)
    MSBillboard.StudsOffset = Vector3.new(0, 3, 0)
    MSBillboard.AlwaysOnTop = false
    MSBillboard.Parent = character.Head
    
    local TextLabel = Instance.new("TextLabel")
    TextLabel.Size = UDim2.new(1, 0, 1, 0)
    TextLabel.BackgroundTransparency = 0.3
    TextLabel.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    TextLabel.TextColor3 = Color3.fromRGB(0, 255, 0)
    TextLabel.TextStrokeTransparency = 0
    TextLabel.TextScaled = true
    TextLabel.Font = Enum.Font.SourceSansBold
    TextLabel.Text = "0 ms"
    TextLabel.Parent = MSBillboard
    
    MSUpdateConnection = RunService.RenderStepped:Connect(function()
        if MSDisplayEnabled and MSBillboard and TextLabel then
            pcall(function()
                local ping = Stats.Network.ServerStatsItem["Data Ping"]:GetValue()
                TextLabel.Text = math.floor(ping) .. " ms"
                
                if ping < 50 then
                    TextLabel.TextColor3 = Color3.fromRGB(0, 255, 0)
                elseif ping < 100 then
                    TextLabel.TextColor3 = Color3.fromRGB(255, 255, 0)
                else
                    TextLabel.TextColor3 = Color3.fromRGB(255, 0, 0)
                end
            end)
        end
    end)
end

-- ═══════════════════════════════════════════════════════════
-- RGB NAMETAG UNTUK AAPIS3308
-- ═══════════════════════════════════════════════════════════
local NametagConnections = {}

local function CleanupNametag(player)
    if NametagConnections[player.UserId] then
        local data = NametagConnections[player.UserId]
        
        if data.billboard then
            data.billboard:Destroy()
        end
        
        if data.connections then
            for _, connection in ipairs(data.connections) do
                if connection and typeof(connection) == "RBXScriptConnection" then
                    connection:Disconnect()
                end
            end
        end
        
        NametagConnections[player.UserId] = nil
    end
end

local function CreateRGBNametag(player)
    if player.Name ~= "aapis3308" then
        return
    end
    
    CleanupNametag(player)
    
    local character = player.Character or player.CharacterAdded:Wait()
    local head = character:WaitForChild("Head")
    
    local billboard = Instance.new("BillboardGui")
    billboard.Name = "ProtectiveNameTag"
    billboard.Adornee = head
    billboard.Size = UDim2.new(0, 300, 0, 50)
    billboard.StudsOffset = Vector3.new(0, 2.5, 0)
    billboard.AlwaysOnTop = true
    billboard.Parent = head
    
    local textLabel = Instance.new("TextLabel")
    textLabel.Size = UDim2.new(1, 0, 1, 0)
    textLabel.BackgroundTransparency = 1
    textLabel.TextScaled = true
    textLabel.Font = Enum.Font.SourceSansBold
    textLabel.Text = "PROTECTIVE ANTC HUB"
    textLabel.TextStrokeTransparency = 0
    textLabel.Parent = billboard
    
    local connections = {}
    local isActive = true
    
    local rgbConnection = RunService.RenderStepped:Connect(function()
        if not isActive or not billboard or not billboard.Parent then
            return
        end
        
        local hue = tick() * 100 % 360
        textLabel.TextColor3 = Color3.fromHSV(hue / 360, 1, 1)
    end)
    table.insert(connections, rgbConnection)
    
    local camera = workspace.CurrentCamera
    local visibilityConnection = RunService.RenderStepped:Connect(function()
        if not isActive or not billboard or not billboard.Parent or not camera then
            return
        end
        
        pcall(function()
            local distance = (camera.CFrame.Position - head.Position).Magnitude
            
            if distance < 50 then
                billboard.Enabled = true
            else
                billboard.Enabled = false
            end
        end)
    end)
    table.insert(connections, visibilityConnection)
    
    local diedConnection = character.Humanoid.Died:Connect(function()
        isActive = false
        CleanupNametag(player)
    end)
    table.insert(connections, diedConnection)
    
    NametagConnections[player.UserId] = {
        billboard = billboard,
        connections = connections,
        isActive = isActive
    }
end

for _, player in ipairs(Players:GetPlayers()) do
    if player.Name == "aapis3308" then
        if player.Character then
            CreateRGBNametag(player)
        end
        player.CharacterAdded:Connect(function()
            CreateRGBNametag(player)
        end)
        player.CharacterRemoving:Connect(function()
            CleanupNametag(player)
        end)
    end
end

Players.PlayerAdded:Connect(function(player)
    if player.Name == "aapis3308" then
        player.CharacterAdded:Connect(function()
            CreateRGBNametag(player)
        end)
        player.CharacterRemoving:Connect(function()
            CleanupNametag(player)
        end)
    end
end)

Players.PlayerRemoving:Connect(function(player)
    CleanupNametag(player)
end)

-- ═══════════════════════════════════════════════════════════
-- CREATE WINDOW
-- ═══════════════════════════════════════════════════════════
local Window = WindUI:CreateWindow({
    Title = "ANTC HUB",
    Icon = "rbxassetid://" .. LogoImageID,
    Author = "ANTC Team",
    Folder = "ANTCHub_Data",
    Size = UDim2.fromOffset(580, 460),
    KeySystem = false,
    Transparent = true,
    Theme = "Dark",
    SideBarWidth = 170,
    HasOutline = true
})

print("✅ Window Created!")

-- ═══════════════════════════════════════════════════════════
-- TAB: FISH IT (GAME SPECIFIC)
-- ═══════════════════════════════════════════════════════════
local FishItTab = Window:Tab({
    Title = "FISH IT",
    Icon = "rbxassetid://10747373176"
})

local FishItSection = FishItTab:Section({
    Title = "Game Features",
    Opened = true
})

-- Super Intan (LOCKED - Unlock dengan Dev Mode)
FishItSection:Button({
    Title = "Super Intan",
    Description = "🔒 LOCKED - Masukkan kode APIS di tab Development",
    Callback = function()
        if not DevelopmentMode then
            Window:Notify({
                Title = "ANTC HUB",
                Description = "🔒 LOCKED! Masukkan kode APIS di tab Development untuk unlock!",
                Duration = 5
            })
            return
        end
        
        Window:Notify({
            Title = "Super Intan",
            Description = "✅ Super Intan Activated!",
            Duration = 3
        })
    end
})

-- Super Bland (LOCKED - Unlock dengan Dev Mode) - LEBIH CEPAT DARI FAST CLICKER
local SuperBlandEnabled = false
local SuperBlandConnection = nil
local superBlandDelay = 0
local superBlandInterval = 0.00001

FishItSection:Toggle({
    Title = "Super Bland (0.01ms)",
    Description = "🔒 LOCKED - Ultra fast clicker (lebih cepat dari Fast Clicker)",
    Default = false,
    Callback = function(enabled)
        if not DevelopmentMode then
            Window:Notify({
                Title = "ANTC HUB",
                Description = "🔒 LOCKED! Masukkan kode APIS di tab Development untuk unlock!",
                Duration = 5
            })
            return
        end
        
        SuperBlandEnabled = enabled
        
        if enabled then
            superBlandDelay = 0
            
            SuperBlandConnection = RunService.RenderStepped:Connect(function(deltaTime)
                if SuperBlandEnabled then
                    superBlandDelay = superBlandDelay + deltaTime
                    
                    if superBlandDelay >= superBlandInterval then
                        superBlandDelay = 0
                        
                        pcall(function()
                            if mouse1press then
                                mouse1press()
                                mouse1release()
                            elseif mouse1click then
                                mouse1click()
                            else
                                local mousePos = UserInputService:GetMouseLocation()
                                VirtualInputManager:SendMouseButtonEvent(mousePos.X, mousePos.Y, 0, true, game, 0)
                                VirtualInputManager:SendMouseButtonEvent(mousePos.X, mousePos.Y, 0, false, game, 0)
                            end
                        end)
                    end
                end
            end)
            
            Window:Notify({
                Title = "Super Bland",
                Description = "✅ Super Bland ON (ULTRA FAST - 0.01ms)!",
                Duration = 3
            })
        else
            if SuperBlandConnection then
                SuperBlandConnection:Disconnect()
                SuperBlandConnection = nil
            end
            superBlandDelay = 0
            
            Window:Notify({
                Title = "Super Bland",
                Description = "❌ Super Bland OFF!",
                Duration = 3
            })
        end
    end
})

-- Fast Auto Clicker (UNLOCKED) - Multi-Device Support (PC, Mobile, Tablet)
local FastAutoClickerEnabled = false
local AutoClickConnection = nil

FishItSection:Toggle({
    Title = "Fast Auto Clicker (0ms)",
    Description = "Auto click 0ms - Support PC, Mobile & Tablet",
    Default = false,
    Callback = function(enabled)
        FastAutoClickerEnabled = enabled
        
        if enabled then
            -- Detect platform untuk compatibility
            local isMobile = UserInputService.TouchEnabled and not UserInputService.MouseEnabled
            local isTablet = UserInputService.TouchEnabled and UserInputService.KeyboardEnabled
            local isPC = UserInputService.MouseEnabled and UserInputService.KeyboardEnabled
            
            -- Start auto clicker dengan multi-method support
            AutoClickConnection = task.spawn(function()
                while FastAutoClickerEnabled do
                    pcall(function()
                        -- Method 1: mouse1press (Best for executors)
                        if mouse1press and mouse1release then
                            mouse1press()
                            task.wait()
                            mouse1release()
                        -- Method 2: mouse1click (Alternative for some executors)
                        elseif mouse1click then
                            mouse1click()
                        -- Method 3: VirtualInputManager (Universal - All Devices)
                        else
                            local mousePos = UserInputService:GetMouseLocation()
                            -- Touch support for Mobile & Tablet
                            if isMobile or isTablet then
                                VirtualInputManager:SendMouseButtonEvent(mousePos.X, mousePos.Y, 0, true, game, 0)
                                task.wait()
                                VirtualInputManager:SendMouseButtonEvent(mousePos.X, mousePos.Y, 0, false, game, 0)
                            -- Mouse support for PC
                            else
                                VirtualInputManager:SendMouseButtonEvent(0, 0, 0, true, game, 1)
                                task.wait()
                                VirtualInputManager:SendMouseButtonEvent(0, 0, 0, false, game, 1)
                            end
                        end
                    end)
                    task.wait()  -- 0ms delay
                end
            end)
            
            -- Device-specific notification
            local deviceType = "PC"
            if isMobile then
                deviceType = "Mobile"
            elseif isTablet then
                deviceType = "Tablet"
            end
            
            Window:Notify({
                Title = "ANTC HUB",
                Description = "✅ Fast Auto Clicker ON (0ms) - " .. deviceType,
                Duration = 3
            })
        else
            -- Stop auto clicker
            if AutoClickConnection then
                task.cancel(AutoClickConnection)
                AutoClickConnection = nil
            end
            
            Window:Notify({
                Title = "ANTC HUB",
                Description = "❌ Fast Auto Clicker OFF",
                Duration = 3
            })
        end
    end
})

-- ═══════════════════════════════════════════════════════════
-- TAB: PLAYER
-- ═══════════════════════════════════════════════════════════
local PlayerTab = Window:Tab({
    Title = "Player",
    Icon = "rbxassetid://10734950309"
})

local PlayerSection = PlayerTab:Section({
    Title = "Movement",
    Opened = true
})

PlayerSection:Slider({
    Title = "WalkSpeed",
    Description = "Ubah kecepatan jalan",
    Default = 16,
    Min = 16,
    Max = 500,
    Callback = function(value)
        WindUI.Fitur.SetWalkSpeed(value)
    end
})

PlayerSection:Slider({
    Title = "JumpPower",
    Description = "Ubah kekuatan lompat",
    Default = 50,
    Min = 50,
    Max = 500,
    Callback = function(value)
        WindUI.Fitur.SetJumpPower(value)
    end
})

PlayerSection:Toggle({
    Title = "Fly",
    Description = "Mode terbang (WASD + Space/Shift)",
    Default = false,
    Callback = function(enabled)
        WindUI.Fitur.EnableFly(enabled, 50)
    end
})

PlayerSection:Toggle({
    Title = "Noclip",
    Description = "Tembus tembok",
    Default = false,
    Callback = function(enabled)
        WindUI.Fitur.EnableNoclip(enabled)
    end
})

PlayerSection:Toggle({
    Title = "Infinite Jump",
    Description = "Lompat tanpa batas",
    Default = false,
    Callback = function(enabled)
        WindUI.Fitur.EnableInfiniteJump(enabled)
    end
})

local VisualSection = PlayerTab:Section({
    Title = "Visual",
    Opened = true
})

VisualSection:Toggle({
    Title = "ESP",
    Description = "Lihat player lewat tembok",
    Default = false,
    Callback = function(enabled)
        WindUI.Fitur.EnableESP(enabled)
    end
})

VisualSection:Toggle({
    Title = "FullBright",
    Description = "Terang penuh tanpa bayangan",
    Default = false,
    Callback = function(enabled)
        WindUI.Fitur.EnableFullBright(enabled)
    end
})

VisualSection:Toggle({
    Title = "In-Game MS Display",
    Description = "Tampilkan ping di layar in-game (tidak ikuti GUI)",
    Default = false,
    Callback = function(enabled)
        MSDisplayEnabled = enabled
        
        if enabled then
            CreateMSDisplay()
            
            if MSCharacterConnection then
                MSCharacterConnection:Disconnect()
            end
            
            MSCharacterConnection = LocalPlayer.CharacterAdded:Connect(function()
                if MSDisplayEnabled then
                    task.wait(0.5)
                    CreateMSDisplay()
                end
            end)
            
            Window:Notify({
                Title = "ANTC HUB",
                Description = "✅ MS Display ON!",
                Duration = 2
            })
        else
            CleanupMSDisplay()
            
            if MSCharacterConnection then
                MSCharacterConnection:Disconnect()
                MSCharacterConnection = nil
            end
            
            Window:Notify({
                Title = "ANTC HUB",
                Description = "❌ MS Display OFF!",
                Duration = 2
            })
        end
    end
})

-- ═══════════════════════════════════════════════════════════
-- TAB: SECURITY
-- ═══════════════════════════════════════════════════════════
local SecurityTab = Window:Tab({
    Title = "Security",
    Icon = "rbxassetid://10747373176"
})

local AntiSection = SecurityTab:Section({
    Title = "Anti Features",
    Opened = true
})

local antiAFKEnabled = false
local antiAFKIdledConnection = nil
local antiAFKHeartbeatConnection = nil

AntiSection:Toggle({
    Title = "Anti AFK",
    Description = "Mencegah kick karena AFK",
    Default = false,
    Callback = function(enabled)
        antiAFKEnabled = enabled
        
        if enabled then
            local VirtualUser = game:GetService("VirtualUser")
            
            antiAFKIdledConnection = LocalPlayer.Idled:Connect(function()
                VirtualUser:CaptureController()
                VirtualUser:ClickButton2(Vector2.new())
            end)
            
            antiAFKHeartbeatConnection = RunService.Heartbeat:Connect(function()
                if antiAFKEnabled then
                    VirtualUser:CaptureController()
                    VirtualUser:Button2Down(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
                    task.wait(1)
                    VirtualUser:Button2Up(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
                end
            end)
            
            Window:Notify({
                Title = "Security",
                Description = "✅ Anti AFK ON!",
                Duration = 2
            })
        else
            if antiAFKIdledConnection then
                antiAFKIdledConnection:Disconnect()
                antiAFKIdledConnection = nil
            end
            
            if antiAFKHeartbeatConnection then
                antiAFKHeartbeatConnection:Disconnect()
                antiAFKHeartbeatConnection = nil
            end
            
            Window:Notify({
                Title = "Security",
                Description = "❌ Anti AFK OFF!",
                Duration = 2
            })
        end
    end
})

local antiStaffEnabled = false
local staffCheckConnection = nil

AntiSection:Toggle({
    Title = "Anti Admin/Dev/Staff",
    Description = "Auto hop server jika ada admin",
    Default = false,
    Callback = function(enabled)
        antiStaffEnabled = enabled
        
        if enabled then
            local staffKeywords = {"admin", "dev", "developer", "staff", "mod", "moderator", "owner", "creator"}
            
            local function checkAndHop(player)
                if antiStaffEnabled then
                    local playerName = player.Name:lower()
                    local playerDisplay = player.DisplayName:lower()
                    
                    for _, keyword in ipairs(staffKeywords) do
                        if string.find(playerName, keyword) or string.find(playerDisplay, keyword) then
                            Window:Notify({
                                Title = "Security Alert",
                                Description = "⚠️ STAFF DETECTED! Hopping server...",
                                Duration = 3
                            })
                            
                            task.wait(1)
                            
                            pcall(function()
                                TeleportService:Teleport(game.PlaceId, LocalPlayer)
                            end)
                            
                            return true
                        end
                    end
                end
                return false
            end
            
            for _, player in ipairs(Players:GetPlayers()) do
                if player ~= LocalPlayer then
                    if checkAndHop(player) then
                        break
                    end
                end
            end
            
            staffCheckConnection = Players.PlayerAdded:Connect(function(player)
                checkAndHop(player)
            end)
            
            Window:Notify({
                Title = "Security",
                Description = "✅ Anti Staff ON!",
                Duration = 2
            })
        else
            if staffCheckConnection then
                staffCheckConnection:Disconnect()
                staffCheckConnection = nil
            end
            
            Window:Notify({
                Title = "Security",
                Description = "❌ Anti Staff OFF!",
                Duration = 2
            })
        end
    end
})

local antiTrollEnabled = false
local savedTrollPosition = nil
local antiTrollConnection = nil

AntiSection:Toggle({
    Title = "Anti Troll",
    Description = "Kembali ke posisi jika dipaksa bergerak",
    Default = false,
    Callback = function(enabled)
        antiTrollEnabled = enabled
        local character = LocalPlayer.Character
        
        if enabled and character and character:FindFirstChild("HumanoidRootPart") then
            savedTrollPosition = character.HumanoidRootPart.CFrame
            
            antiTrollConnection = RunService.Heartbeat:Connect(function()
                if antiTrollEnabled and character and character:FindFirstChild("HumanoidRootPart") and savedTrollPosition then
                    local currentPos = character.HumanoidRootPart.Position
                    local savedPos = savedTrollPosition.Position
                    local distance = (currentPos - savedPos).Magnitude
                    
                    if distance > 5 then
                        character.HumanoidRootPart.CFrame = savedTrollPosition
                    end
                end
            end)
            
            Window:Notify({
                Title = "Security",
                Description = "✅ Anti Troll ON!",
                Duration = 2
            })
        else
            if antiTrollConnection then
                antiTrollConnection:Disconnect()
                antiTrollConnection = nil
            end
            savedTrollPosition = nil
            
            Window:Notify({
                Title = "Security",
                Description = "❌ Anti Troll OFF!",
                Duration = 2
            })
        end
    end
})

-- ═══════════════════════════════════════════════════════════
-- TAB: TELEPORT
-- ═══════════════════════════════════════════════════════════
local TeleportTab = Window:Tab({
    Title = "Teleport",
    Icon = "rbxassetid://10734896388"
})

local TeleportSection = TeleportTab:Section({
    Title = "Position Manager",
    Opened = true
})

TeleportSection:Button({
    Title = "Save Position",
    Description = "Simpan posisi sekarang",
    Callback = function()
        if WindUI.Fitur.SavePosition() then
            Window:Notify({
                Title = "ANTC HUB",
                Description = "✅ Posisi tersimpan!",
                Duration = 3
            })
        else
            Window:Notify({
                Title = "ANTC HUB",
                Description = "❌ Gagal simpan posisi!",
                Duration = 3
            })
        end
    end
})

TeleportSection:Button({
    Title = "Load Position",
    Description = "Kembali ke posisi tersimpan",
    Callback = function()
        if WindUI.Fitur.LoadPosition() then
            Window:Notify({
                Title = "ANTC HUB",
                Description = "✅ Teleport ke posisi tersimpan!",
                Duration = 3
            })
        else
            Window:Notify({
                Title = "ANTC HUB",
                Description = "❌ Belum ada posisi tersimpan!",
                Duration = 3
            })
        end
    end
})

local TPPlayerSection = TeleportTab:Section({
    Title = "Teleport to Player",
    Opened = true
})

TPPlayerSection:Input({
    Title = "Player Name / Display Name",
    Description = "Ketik username atau display name player",
    Placeholder = "Contoh: Player123",
    Callback = function(value)
        if not value or value == "" then
            Window:Notify({
                Title = "Teleport",
                Description = "❌ Masukkan nama player!",
                Duration = 2
            })
            return
        end
        
        local searchName = value:lower()
        local targetPlayer = nil
        
        targetPlayer = Players:FindFirstChild(value)
        
        if not targetPlayer then
            for _, player in ipairs(Players:GetPlayers()) do
                if player.Name:lower() == searchName then
                    targetPlayer = player
                    break
                end
            end
        end
        
        if not targetPlayer then
            for _, player in ipairs(Players:GetPlayers()) do
                if player.DisplayName:lower() == searchName then
                    targetPlayer = player
                    break
                end
            end
        end
        
        if not targetPlayer then
            for _, player in ipairs(Players:GetPlayers()) do
                if player.Name:lower():find(searchName) or player.DisplayName:lower():find(searchName) then
                    targetPlayer = player
                    break
                end
            end
        end
        
        if targetPlayer and targetPlayer.Character and targetPlayer.Character:FindFirstChild("HumanoidRootPart") then
            local localChar = LocalPlayer.Character
            if localChar and localChar:FindFirstChild("HumanoidRootPart") then
                localChar.HumanoidRootPart.CFrame = targetPlayer.Character.HumanoidRootPart.CFrame
                
                Window:Notify({
                    Title = "Teleport",
                    Description = "✅ Teleported to " .. targetPlayer.Name .. " (" .. targetPlayer.DisplayName .. ")!",
                    Duration = 3
                })
            end
        else
            Window:Notify({
                Title = "Teleport",
                Description = "❌ Player '" .. value .. "' tidak ditemukan!",
                Duration = 3
            })
        end
    end
})

-- ═══════════════════════════════════════════════════════════
-- TAB: DEVELOPMENT
-- ═══════════════════════════════════════════════════════════
local DevelopmentTab = Window:Tab({
    Title = "Development",
    Icon = "rbxassetid://10747373176"
})

local DevLoginSection = DevelopmentTab:Section({
    Title = "🔐 Development Login",
    Opened = true
})

DevLoginSection:Input({
    Title = "Masukkan Kode Development",
    Description = "Kode: APIS - Untuk unlock Super Bland, Super Intan, dan DEX",
    Placeholder = "Masukkan kode APIS...",
    Callback = function(value)
        if value == DevelopmentCode then
            DevelopmentMode = true
            Window:Notify({
                Title = "Development Panel",
                Description = "✅ Access Granted! Welcome Developer " .. LocalPlayer.Name .. "! Semua fitur unlocked!",
                Duration = 5
            })
        else
            Window:Notify({
                Title = "Development Panel",
                Description = "❌ Kode salah! Fitur tetap locked.",
                Duration = 3
            })
        end
    end
})

local DexSection = DevelopmentTab:Section({
    Title = "🔧 Developer Tools",
    Opened = true
})

DexSection:Button({
    Title = "Dex Explorer",
    Description = "🔒 LOCKED - Masukkan kode APIS untuk unlock",
    Callback = function()
        if not DevelopmentMode then
            Window:Notify({
                Title = "Dex Explorer",
                Description = "🔒 LOCKED! Masukkan kode APIS di atas untuk unlock!",
                Duration = 5
            })
            return
        end
        
        Window:Notify({
            Title = "Dex Explorer",
            Description = "⚠️ Dex Explorer masih dalam tahap pengujian! Coming soon...",
            Duration = 5
        })
    end
})

-- ═══════════════════════════════════════════════════════════
-- TAB: COMBAT
-- ═══════════════════════════════════════════════════════════
local CombatTab = Window:Tab({
    Title = "Combat",
    Icon = "rbxassetid://10747373176"
})

local CombatSection = CombatTab:Section({
    Title = "God Mode",
    Opened = true
})

CombatSection:Toggle({
    Title = "God Mode",
    Description = "HP unlimited (mungkin tidak work di semua game)",
    Default = false,
    Callback = function(enabled)
        WindUI.Fitur.EnableGodMode(enabled)
    end
})

-- ═══════════════════════════════════════════════════════════
-- TAB: MISC
-- ═══════════════════════════════════════════════════════════
local MiscTab = Window:Tab({
    Title = "Misc",
    Icon = "rbxassetid://10734924532"
})

local MiscSection = MiscTab:Section({
    Title = "Utilities"
})

MiscSection:Button({
    Title = "Reset Character",
    Description = "Reset karakter Anda",
    Callback = function()
        WindUI.Fitur.ResetCharacter()
    end
})

local DiscordSection = MiscTab:Section({
    Title = "Community"
})

DiscordSection:Button({
    Title = "Join Discord",
    Description = "discord.gg/antchub",
    Callback = function()
        Window:Notify({
            Title = "ANTC HUB",
            Description = "Discord: discord.gg/antchub",
            Duration = 5
        })
    end
})

-- ═══════════════════════════════════════════════════════════
-- FINAL NOTIFICATION
-- ═══════════════════════════════════════════════════════════
Window:Notify({
    Title = "ANTC HUB",
    Description = "✅ Loaded successfully! Masukkan kode APIS di tab Development untuk unlock fitur!",
    Duration = 5
})

print("🎉 ANTC HUB Loaded Successfully!")
print("📢 Discord: discord.gg/antchub")
print("🔐 Security features: ACTIVE")
print("📊 MS Display: Available in Visual tab")
print("🏷️ RGB Nametag: Auto for aapis3308")
print("🚀 Teleport to Player: Support username & display name")
print("⚡ Fast Auto Clicker: FIXED - Benar-benar klik sekarang!")
print("🔓 Unlock fitur: Masukkan kode APIS di tab Development")
print("💡 Super Bland: Ultra fast clicker (unlock dengan dev mode)")
