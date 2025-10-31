--[[
    ╔═══════════════════════════════════════════════════════════╗
    ║                     ANTC HUB LOADER                       ║
    ║              Discord: https://discord.gg/antchub          ║
    ╚═══════════════════════════════════════════════════════════╝
    
    CUSTOMIZATION:
    - Line ~25: Ganti BannerImageID dengan Roblox Asset ID banner Anda
    - Line ~26: Ganti LogoImageID dengan Roblox Asset ID logo Anda
]]

print("🔄 Loading ANTC HUB...")

-- Load WindUI Library
local WindUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/APISje/ANTCHUBV2/refs/heads/main/main.lua", true))()

print("✅ ANTC HUB Library Loaded!")

-- ═══════════════════════════════════════════════════════════
-- SETTING BANNER & LOGO (GANTI DISINI)
-- ═══════════════════════════════════════════════════════════
local BannerImageID = "10723415766"  -- ← GANTI dengan Asset ID banner Anda
local LogoImageID = "10723415766"     -- ← GANTI dengan Asset ID logo/infinite Anda
-- ═══════════════════════════════════════════════════════════

-- Services
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TextChatService = game:GetService("TextChatService")
local StarterGui = game:GetService("StarterGui")

-- Variables untuk Development Mode
local DevelopmentMode = false
local AuthorizedDevAccount = "aapis3308"  -- Akun yang diizinkan untuk development
local DevelopmentCode = "APIS"

-- Global Chat Hook untuk Server Messages
local function SendServerMessage(message)
    pcall(function()
        -- Method 1: TextChatService (newer Roblox chat)
        if TextChatService:FindFirstChild("TextChannels") then
            local generalChannel = TextChatService.TextChannels:FindFirstChild("RBXGeneral")
            if generalChannel then
                generalChannel:DisplaySystemMessage("[Server] " .. message)
            end
        end
        
        -- Method 2: Legacy Chat System
        local success, result = pcall(function()
            StarterGui:SetCore("ChatMakeSystemMessage", {
                Text = "[Server] " .. message,
                Color = Color3.fromRGB(255, 85, 127),
                Font = Enum.Font.SourceSansBold,
                FontSize = Enum.FontSize.Size18
            })
        end)
    end)
end

-- Hook Global Messages untuk mengubah [Global] menjadi [Server]
local function HookGlobalMessages()
    pcall(function()
        local originalFunc
        
        -- Hook untuk TextChatService
        if TextChatService:FindFirstChild("OnIncomingMessage") then
            TextChatService.OnIncomingMessage = function(message)
                if message.Text and string.find(message.Text, "%[Global%]") then
                    local newText = string.gsub(message.Text, "%[Global%]", "[Server]")
                    message.Text = newText
                end
                return message
            end
        end
        
        -- Hook untuk legacy chat
        if ReplicatedStorage:FindFirstChild("DefaultChatSystemChatEvents") then
            local chatEvents = ReplicatedStorage.DefaultChatSystemChatEvents
            if chatEvents:FindFirstChild("OnMessageDoneFiltering") then
                chatEvents.OnMessageDoneFiltering.OnClientEvent:Connect(function(messageData)
                    if messageData.Message and string.find(messageData.Message, "%[Global%]") then
                        messageData.Message = string.gsub(messageData.Message, "%[Global%]", "[Server]")
                    end
                end)
            end
        end
    end)
end

-- Jalankan hook saat script load
task.spawn(function()
    task.wait(2)  -- Wait untuk chat system load
    HookGlobalMessages()
end)

-- Buat Window
local Window = WindUI:CreateWindow({
    Title = "ANTC HUB",
    Icon = "rbxassetid://" .. LogoImageID,
    Author = "by afiez Dev",
    Folder = "ANTCHub_Data",
    Size = UDim2.fromOffset(580, 460),
    KeySystem = false,
    Transparent = true,
    Theme = "Dark",
    SideBarWidth = 170,
    HasOutline = true
})

print("✅ Window Created!")

-- Fix Minimize Bug
local WindowFrame = Window._window
if WindowFrame and WindowFrame.Minimize then
    local originalMinimize = WindowFrame.Minimize
    WindowFrame.Minimize = function(self, ...)
        local args = {...}
        local success, err = pcall(function()
            return originalMinimize(self, table.unpack(args))
        end)
        if not success then
            warn("Minimize error caught and handled:", err)
            -- Fallback: manual minimize
            if WindowFrame and WindowFrame.Frame then
                WindowFrame.Frame.Visible = not WindowFrame.Frame.Visible
            end
        end
    end
end

-- ═══════════════════════════════════════════════════════════
-- TAB: FISH IT (GAME SPECIFIC)
-- ═══════════════════════════════════════════════════════════
local FishItTab = Window:Tab({
    Title = "FISH IT",
    Icon = "rbxassetid://10747373176"
})

local FishItSection = FishItTab:Section({
    Title = "Game Features",
    Opened = true  -- Auto expand
})

-- Super Intan (Unlock dengan Development)
FishItSection:Button({
    Title = "Super Intan",
    Description = "Unlock dengan Development Login (kode: APIS)",
    Callback = function()
        if not DevelopmentMode then
            Window:Notify({
                Title = "ANTC HUB",
                Description = "🔒 Unlock dengan Development Login! Masukkan kode APIS di tab Development.",
                Duration = 5
            })
            return
        end
        
        -- Super Intan logic untuk development
        Window:Notify({
            Title = "Super Intan",
            Description = "✅ Super Intan Activated!",
            Duration = 3
        })
        SendServerMessage("Developer " .. Players.LocalPlayer.Name .. " activated Super Intan!")
    end
})

-- Super Bland (Unlock dengan Development)
FishItSection:Button({
    Title = "Super Bland",
    Description = "Unlock dengan Development Login (kode: APIS)",
    Callback = function()
        if not DevelopmentMode then
            Window:Notify({
                Title = "ANTC HUB",
                Description = "🔒 Unlock dengan Development Login! Masukkan kode APIS di tab Development.",
                Duration = 5
            })
            return
        end
        
        -- Super Bland logic untuk development
        Window:Notify({
            Title = "Super Bland",
            Description = "✅ Super Bland Activated!",
            Duration = 3
        })
        SendServerMessage("Developer " .. Players.LocalPlayer.Name .. " activated Super Bland!")
    end
})

-- Fast Auto Clicker (UNLOCKED) - Updated untuk tidak mengganggu GUI
local FastAutoClickerEnabled = false
local AutoClickConnection = nil

FishItSection:Toggle({
    Title = "Fast Auto Clicker",
    Description = "Auto click 0ms (hanya di layar game)",
    Default = false,
    Callback = function(enabled)
        FastAutoClickerEnabled = enabled
        
        if enabled then
            -- Start auto clicker - hanya click di viewport, tidak di GUI
            local VirtualInputManager = game:GetService("VirtualInputManager")
            local UserInputService = game:GetService("UserInputService")
            local Camera = workspace.CurrentCamera
            
            AutoClickConnection = task.spawn(function()
                while FastAutoClickerEnabled do
                    -- Cek apakah mouse tidak di atas GUI
                    local mouseLocation = UserInputService:GetMouseLocation()
                    local guiObjects = game:GetService("CoreGui"):GetGuiObjectsAtPosition(mouseLocation.X, mouseLocation.Y)
                    local playerGui = Players.LocalPlayer:FindFirstChild("PlayerGui")
                    if playerGui then
                        local playerGuiObjects = playerGui:GetGuiObjectsAtPosition(mouseLocation.X, mouseLocation.Y)
                        for _, obj in ipairs(playerGuiObjects) do
                            table.insert(guiObjects, obj)
                        end
                    end
                    
                    -- Hanya click jika tidak ada GUI di bawah mouse
                    if #guiObjects == 0 then
                        VirtualInputManager:SendMouseButtonEvent(0, 0, 0, true, game, 1)
                        task.wait()
                        VirtualInputManager:SendMouseButtonEvent(0, 0, 0, false, game, 1)
                    end
                    
                    task.wait()  -- 0ms delay
                end
            end)
            
            Window:Notify({
                Title = "ANTC HUB",
                Description = "✅ Fast Auto Clicker ON (tidak mengganggu GUI)",
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
-- TAB: DEVELOPMENT (UNLOCK DENGAN KODE APIS)
-- ═══════════════════════════════════════════════════════════
local DevelopmentTab = Window:Tab({
    Title = "Development",
    Icon = "rbxassetid://10747373176"
})

local DevLoginSection = DevelopmentTab:Section({
    Title = "Development Access",
    Opened = true
})

-- Input untuk kode Development
local CodeInputBox
DevLoginSection:Input({
    Title = "Development Code",
    Description = "Masukkan kode untuk akses Development",
    Placeholder = "Masukkan kode APIS...",
    Callback = function(value)
        if value == DevelopmentCode then
            local playerName = Players.LocalPlayer.Name
            
            -- Cek apakah user adalah authorized dev account
            if playerName == AuthorizedDevAccount then
                DevelopmentMode = true
                Window:Notify({
                    Title = "ANTC HUB Development",
                    Description = "✅ Welcome Developer " .. playerName .. "!",
                    Duration = 5
                })
                
                -- Unlock Development Features
                DevLoginSection:Button({
                    Title = "✅ Development Mode Active",
                    Description = "Anda memiliki akses penuh",
                    Callback = function()
                        Window:Notify({
                            Title = "Development",
                            Description = "Development Mode: ACTIVE",
                            Duration = 3
                        })
                    end
                })
            else
                -- User tidak authorized, kick setelah 10 detik
                Window:Notify({
                    Title = "ANTC HUB Development",
                    Description = "❌ Unauthorized access! Kicking in 10 seconds...",
                    Duration = 10
                })
                
                task.wait(10)
                Players.LocalPlayer:Kick("⚠️ Unauthorized Development Access\nHanya " .. AuthorizedDevAccount .. " yang dapat menggunakan kode APIS")
            end
        else
            Window:Notify({
                Title = "ANTC HUB Development",
                Description = "❌ Kode salah!",
                Duration = 3
            })
        end
    end
})

-- Development Features Section (Unlocked Fish It)
local DevFeaturesSection = DevelopmentTab:Section({
    Title = "Development Features",
    Opened = true
})

-- Super Intan (UNLOCKED untuk Development)
DevFeaturesSection:Button({
    Title = "✅ Super Intan (Dev)",
    Description = "Super Intan - Development Version",
    Callback = function()
        if DevelopmentMode then
            Window:Notify({
                Title = "Development",
                Description = "✅ Super Intan Activated!",
                Duration = 3
            })
            SendServerMessage("Developer " .. Players.LocalPlayer.Name .. " activated Super Intan!")
            -- Add your Super Intan logic here
        else
            Window:Notify({
                Title = "Development",
                Description = "❌ Masukkan kode Development dulu!",
                Duration = 3
            })
        end
    end
})

-- Super Bland (UNLOCKED untuk Development)
DevFeaturesSection:Button({
    Title = "✅ Super Bland (Dev)",
    Description = "Super Bland - Development Version",
    Callback = function()
        if DevelopmentMode then
            Window:Notify({
                Title = "Development",
                Description = "✅ Super Bland Activated!",
                Duration = 3
            })
            SendServerMessage("Developer " .. Players.LocalPlayer.Name .. " activated Super Bland!")
            -- Add your Super Bland logic here
        else
            Window:Notify({
                Title = "Development",
                Description = "❌ Masukkan kode Development dulu!",
                Duration = 3
            })
        end
    end
})

-- Test Secret Server Notification
local DevTestSection = DevelopmentTab:Section({
    Title = "Testing Tools",
    Opened = true
})

DevTestSection:Button({
    Title = "🔔 Test Server Notification",
    Description = "Test notifikasi server global",
    Callback = function()
        if DevelopmentMode then
            -- Test berbagai jenis notifikasi
            SendServerMessage("Claurenn_09 obtained a Shiny Zombie Shark (255kg) with a 1 in 250K chance!")
            task.wait(0.5)
            SendServerMessage("WindahJAMDINDINGxRF1 obtained a Shiny Frostborn Shark (8.29K kg) with a 1 in 500K chance!")
            task.wait(0.5)
            SendServerMessage("MrPoojan: TALONNNNNNNNNN SECRET GUA MANAAAA")
            task.wait(0.5)
            SendServerMessage("NEOxPutttt obtained a CORRUPT Robot Kraken (278.64Kkg) with a 1 in 3.50M chance!")
            
            Window:Notify({
                Title = "Development",
                Description = "✅ Server notifications sent!",
                Duration = 3
            })
        else
            Window:Notify({
                Title = "Development",
                Description = "❌ Masukkan kode Development dulu!",
                Duration = 3
            })
        end
    end
})

DevTestSection:Input({
    Title = "Custom Server Message",
    Description = "Kirim custom server message",
    Placeholder = "Tulis pesan...",
    Callback = function(value)
        if DevelopmentMode then
            if value and value ~= "" then
                SendServerMessage(value)
                Window:Notify({
                    Title = "Development",
                    Description = "✅ Message sent: " .. value,
                    Duration = 3
                })
            end
        else
            Window:Notify({
                Title = "Development",
                Description = "❌ Masukkan kode Development dulu!",
                Duration = 3
            })
        end
    end
})

-- Account Proceed Info
DevTestSection:Button({
    Title = "📋 Account Info",
    Description = "Lihat informasi akun",
    Callback = function()
        local info = string.format(
            "Username: %s\nUser ID: %s\nDevelopment Mode: %s\nAuthorized: %s",
            Players.LocalPlayer.Name,
            Players.LocalPlayer.UserId,
            DevelopmentMode and "✅ Active" or "❌ Inactive",
            Players.LocalPlayer.Name == AuthorizedDevAccount and "✅ Yes" or "❌ No"
        )
        
        Window:Notify({
            Title = "Account Information",
            Description = info,
            Duration = 8
        })
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
    Opened = true  -- Auto expand
})

-- WalkSpeed Slider
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

-- JumpPower Slider
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

-- Fly Toggle
PlayerSection:Toggle({
    Title = "Fly",
    Description = "Mode terbang (WASD + Space/Shift)",
    Default = false,
    Callback = function(enabled)
        WindUI.Fitur.EnableFly(enabled, 50)
    end
})

-- Noclip Toggle
PlayerSection:Toggle({
    Title = "Noclip",
    Description = "Tembus tembok",
    Default = false,
    Callback = function(enabled)
        WindUI.Fitur.EnableNoclip(enabled)
    end
})

-- Infinite Jump Toggle
PlayerSection:Toggle({
    Title = "Infinite Jump",
    Description = "Lompat tanpa batas",
    Default = false,
    Callback = function(enabled)
        WindUI.Fitur.EnableInfiniteJump(enabled)
    end
})

-- Visual Section
local VisualSection = PlayerTab:Section({
    Title = "Visual",
    Opened = true  -- Auto expand
})

-- ESP Toggle
VisualSection:Toggle({
    Title = "ESP",
    Description = "Lihat player lewat tembok",
    Default = false,
    Callback = function(enabled)
        WindUI.Fitur.EnableESP(enabled)
    end
})

-- FullBright Toggle
VisualSection:Toggle({
    Title = "FullBright",
    Description = "Terang penuh tanpa bayangan",
    Default = false,
    Callback = function(enabled)
        WindUI.Fitur.EnableFullBright(enabled)
    end
})

-- Tab Combat
local CombatTab = Window:Tab({
    Title = "Combat",
    Icon = "rbxassetid://10747373176"
})

local CombatSection = CombatTab:Section({
    Title = "God Mode",
    Opened = true  -- Auto expand
})

-- God Mode Toggle
CombatSection:Toggle({
    Title = "God Mode",
    Description = "HP unlimited (mungkin tidak work di semua game)",
    Default = false,
    Callback = function(enabled)
        WindUI.Fitur.EnableGodMode(enabled)
    end
})

-- Tab Teleport
local TeleportTab = Window:Tab({
    Title = "Teleport",
    Icon = "rbxassetid://10734896388"
})

local TeleportSection = TeleportTab:Section({
    Title = "Position Manager",
    Opened = true  -- Auto expand
})

-- Save Position Button
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

-- Load Position Button
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

-- ═══════════════════════════════════════════════════════════
-- TAB: SETTINGS (BARU!)
-- ═══════════════════════════════════════════════════════════
local SettingsTab = Window:Tab({
    Title = "Settings",
    Icon = "rbxassetid://10734950309"
})

local ProfileSection = SettingsTab:Section({
    Title = "Profile & Status",
    Opened = true
})

-- User Profile Info dengan Avatar
ProfileSection:Button({
    Title = "👤 " .. Players.LocalPlayer.Name,
    Description = "User ID: " .. Players.LocalPlayer.UserId .. " | Dev: " .. (DevelopmentMode and "✅" or "❌"),
    Callback = function()
        local thumbnailUrl = Players:GetUserThumbnailAsync(
            Players.LocalPlayer.UserId,
            Enum.ThumbnailType.HeadShot,
            Enum.ThumbnailSize.Size150x150
        )
        
        Window:Notify({
            Title = "Profile Information",
            Description = string.format(
                "Username: %s\nDisplay: %s\nUser ID: %s\nAccount Age: %d days\nDev Mode: %s",
                Players.LocalPlayer.Name,
                Players.LocalPlayer.DisplayName,
                Players.LocalPlayer.UserId,
                Players.LocalPlayer.AccountAge,
                DevelopmentMode and "✅ Active" or "❌ Inactive"
            ),
            Duration = 8
        })
    end
})

-- Time of Day Settings (Unlocked)
local TimeSection = SettingsTab:Section({
    Title = "⏰ Time Settings",
    Opened = true
})

TimeSection:Button({
    Title = "🌅 Pagi (Morning)",
    Description = "Set waktu ke pagi hari",
    Callback = function()
        local Lighting = game:GetService("Lighting")
        Lighting.ClockTime = 6
        Lighting.Brightness = 2
        Window:Notify({
            Title = "Time Settings",
            Description = "✅ Waktu diubah ke Pagi!",
            Duration = 3
        })
    end
})

TimeSection:Button({
    Title = "☀️ Siang (Noon)",
    Description = "Set waktu ke siang hari",
    Callback = function()
        local Lighting = game:GetService("Lighting")
        Lighting.ClockTime = 12
        Lighting.Brightness = 3
        Window:Notify({
            Title = "Time Settings",
            Description = "✅ Waktu diubah ke Siang!",
            Duration = 3
        })
    end
})

TimeSection:Button({
    Title = "🌇 Sore (Afternoon)",
    Description = "Set waktu ke sore hari",
    Callback = function()
        local Lighting = game:GetService("Lighting")
        Lighting.ClockTime = 16
        Lighting.Brightness = 2
        Window:Notify({
            Title = "Time Settings",
            Description = "✅ Waktu diubah ke Sore!",
            Duration = 3
        })
    end
})

TimeSection:Button({
    Title = "🌅 Sunset",
    Description = "Set waktu ke sunset",
    Callback = function()
        local Lighting = game:GetService("Lighting")
        Lighting.ClockTime = 18
        Lighting.Brightness = 1.5
        Window:Notify({
            Title = "Time Settings",
            Description = "✅ Waktu diubah ke Sunset!",
            Duration = 3
        })
    end
})

TimeSection:Button({
    Title = "🌙 Malam (Night)",
    Description = "Set waktu ke malam hari",
    Callback = function()
        local Lighting = game:GetService("Lighting")
        Lighting.ClockTime = 0
        Lighting.Brightness = 0.5
        Window:Notify({
            Title = "Time Settings",
            Description = "✅ Waktu diubah ke Malam!",
            Duration = 3
        })
    end
})

-- ═══════════════════════════════════════════════════════════
-- TAB: ADVANCED FEATURES (MENU BARU)
-- ═══════════════════════════════════════════════════════════
local AdvancedTab = Window:Tab({
    Title = "Advanced",
    Icon = "rbxassetid://10747373176"
})

-- Speed Control dengan Reset
local SpeedSection = AdvancedTab:Section({
    Title = "Speed Control",
    Opened = true
})

local currentSpeed = 16

SpeedSection:Slider({
    Title = "Walk Speed",
    Description = "Atur kecepatan jalan (dapat di-reset)",
    Default = 16,
    Min = 16,
    Max = 500,
    Callback = function(value)
        currentSpeed = value
        local character = Players.LocalPlayer.Character
        if character and character:FindFirstChild("Humanoid") then
            character.Humanoid.WalkSpeed = value
        end
    end
})

SpeedSection:Button({
    Title = "🔄 Reset Speed",
    Description = "Reset kecepatan ke normal (16)",
    Callback = function()
        currentSpeed = 16
        local character = Players.LocalPlayer.Character
        if character and character:FindFirstChild("Humanoid") then
            character.Humanoid.WalkSpeed = 16
        end
        Window:Notify({
            Title = "Speed Control",
            Description = "✅ Speed direset ke normal (16)!",
            Duration = 3
        })
    end
})

-- Teleport ke Player (Unlocked dengan Cooldown)
local TeleportPlayerSection = AdvancedTab:Section({
    Title = "📍 Teleport to Player",
    Opened = true
})

local teleportCooldown = false

TeleportPlayerSection:Dropdown({
    Title = "Pilih Player",
    Description = "Teleport ke player (Cooldown 10 detik)",
    Options = {},
    Default = nil,
    Callback = function(selectedPlayer)
        if teleportCooldown then
            Window:Notify({
                Title = "Teleport",
                Description = "⏱️ Cooldown! Tunggu 10 detik.",
                Duration = 3
            })
            return
        end
        
        local targetPlayer = Players:FindFirstChild(selectedPlayer)
        if targetPlayer and targetPlayer.Character and targetPlayer.Character:FindFirstChild("HumanoidRootPart") then
            local localChar = Players.LocalPlayer.Character
            if localChar and localChar:FindFirstChild("HumanoidRootPart") then
                localChar.HumanoidRootPart.CFrame = targetPlayer.Character.HumanoidRootPart.CFrame
                
                teleportCooldown = true
                Window:Notify({
                    Title = "Teleport",
                    Description = "✅ Teleported to " .. selectedPlayer .. "!",
                    Duration = 3
                })
                
                task.delay(10, function()
                    teleportCooldown = false
                    Window:Notify({
                        Title = "Teleport",
                        Description = "✅ Cooldown selesai!",
                        Duration = 2
                    })
                end)
            end
        else
            Window:Notify({
                Title = "Teleport",
                Description = "❌ Player tidak ditemukan!",
                Duration = 3
            })
        end
    end
})

-- Update player list setiap 5 detik
task.spawn(function()
    while task.wait(5) do
        local playerNames = {}
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= Players.LocalPlayer then
                table.insert(playerNames, player.Name)
            end
        end
        -- Note: Dropdown update will be handled by WindUI if it supports dynamic updates
    end
end)

-- Walk on Water (Unlocked)
local WaterSection = AdvancedTab:Section({
    Title = "🌊 Water Walking",
    Opened = true
})

local walkOnWaterEnabled = false
local waterConnection

WaterSection:Toggle({
    Title = "Walk on Water",
    Description = "Berjalan di atas air",
    Default = false,
    Callback = function(enabled)
        walkOnWaterEnabled = enabled
        
        if enabled then
            waterConnection = game:GetService("RunService").Heartbeat:Connect(function()
                local character = Players.LocalPlayer.Character
                if character and character:FindFirstChild("HumanoidRootPart") then
                    local hrp = character.HumanoidRootPart
                    local region = Region3.new(hrp.Position - Vector3.new(10, 10, 10), hrp.Position + Vector3.new(10, 10, 10))
                    
                    for _, part in ipairs(workspace:FindPartsInRegion3(region, character, 100)) do
                        if part:IsA("Part") and part.Name == "Water" or part.Material == Enum.Material.Water then
                            part.CanCollide = true
                        end
                    end
                end
            end)
            
            Window:Notify({
                Title = "Walk on Water",
                Description = "✅ Walk on Water ON!",
                Duration = 3
            })
        else
            if waterConnection then
                waterConnection:Disconnect()
                waterConnection = nil
            end
            
            Window:Notify({
                Title = "Walk on Water",
                Description = "❌ Walk on Water OFF!",
                Duration = 3
            })
        end
    end
})

-- Spectator Mode (Locked - Premium)
local SpectatorSection = AdvancedTab:Section({
    Title = "👁️ Spectator Mode",
    Opened = true
})

local spectatorMode = false

SpectatorSection:Button({
    Title = "Spectator Mode",
    Description = "Premium - Unlock dengan Development Login",
    Callback = function()
        if not DevelopmentMode then
            Window:Notify({
                Title = "Spectator Mode",
                Description = "🔒 Fitur Premium! Login Development dulu dengan kode APIS.",
                Duration = 5
            })
            return
        end
        
        spectatorMode = not spectatorMode
        local character = Players.LocalPlayer.Character
        
        if spectatorMode then
            if character then
                for _, part in ipairs(character:GetDescendants()) do
                    if part:IsA("BasePart") then
                        part.CanCollide = false
                    end
                end
                
                if character:FindFirstChild("Humanoid") then
                    character.Humanoid.WalkSpeed = 100
                end
            end
            
            Window:Notify({
                Title = "Spectator Mode",
                Description = "✅ Spectator Mode ON!",
                Duration = 3
            })
        else
            if character then
                for _, part in ipairs(character:GetDescendants()) do
                    if part:IsA("BasePart") then
                        part.CanCollide = true
                    end
                end
                
                if character:FindFirstChild("Humanoid") then
                    character.Humanoid.WalkSpeed = currentSpeed
                end
            end
            
            Window:Notify({
                Title = "Spectator Mode",
                Description = "❌ Spectator Mode OFF!",
                Duration = 3
            })
        end
    end
})

SpectatorSection:Button({
    Title = "🚪 Exit Spectator",
    Description = "Keluar dari mode spectator",
    Callback = function()
        if spectatorMode then
            spectatorMode = false
            local character = Players.LocalPlayer.Character
            if character then
                for _, part in ipairs(character:GetDescendants()) do
                    if part:IsA("BasePart") then
                        part.CanCollide = true
                    end
                end
                
                if character:FindFirstChild("Humanoid") then
                    character.Humanoid.WalkSpeed = currentSpeed
                end
            end
            
            Window:Notify({
                Title = "Spectator Mode",
                Description = "✅ Exited Spectator Mode!",
                Duration = 3
            })
        end
    end
})

-- Invisible Mode (Locked - Premium)
local InvisibleSection = AdvancedTab:Section({
    Title = "👻 Invisible Mode",
    Opened = true
})

local invisibleMode = false

InvisibleSection:Button({
    Title = "Invisible",
    Description = "Premium - Unlock dengan Development Login",
    Callback = function()
        if not DevelopmentMode then
            Window:Notify({
                Title = "Invisible Mode",
                Description = "🔒 Fitur Premium! Login Development dulu dengan kode APIS.",
                Duration = 5
            })
            return
        end
        
        invisibleMode = not invisibleMode
        local character = Players.LocalPlayer.Character
        
        if invisibleMode then
            if character then
                for _, part in ipairs(character:GetDescendants()) do
                    if part:IsA("BasePart") or part:IsA("Decal") then
                        part.Transparency = 1
                    elseif part:IsA("Accessory") then
                        part.Handle.Transparency = 1
                    end
                end
            end
            
            Window:Notify({
                Title = "Invisible Mode",
                Description = "✅ Invisible Mode ON!",
                Duration = 3
            })
        else
            if character then
                for _, part in ipairs(character:GetDescendants()) do
                    if part:IsA("BasePart") or part:IsA("Decal") then
                        part.Transparency = 0
                    elseif part:IsA("Accessory") then
                        part.Handle.Transparency = 0
                    end
                end
            end
            
            Window:Notify({
                Title = "Invisible Mode",
                Description = "❌ Invisible Mode OFF!",
                Duration = 3
            })
        end
    end
})

-- God Mode Premium (Locked)
local GodModeSection = AdvancedTab:Section({
    Title = "⚡ God Mode Premium",
    Opened = true
})

GodModeSection:Toggle({
    Title = "God Mode Premium",
    Description = "Premium - Unlock dengan Development Login",
    Default = false,
    Callback = function(enabled)
        if not DevelopmentMode then
            Window:Notify({
                Title = "God Mode Premium",
                Description = "🔒 Fitur Premium! Login Development dulu dengan kode APIS.",
                Duration = 5
            })
            return
        end
        
        if enabled then
            local character = Players.LocalPlayer.Character
            if character and character:FindFirstChild("Humanoid") then
                character.Humanoid.MaxHealth = math.huge
                character.Humanoid.Health = math.huge
            end
            
            Window:Notify({
                Title = "God Mode Premium",
                Description = "✅ God Mode Premium ON!",
                Duration = 3
            })
        else
            local character = Players.LocalPlayer.Character
            if character and character:FindFirstChild("Humanoid") then
                character.Humanoid.MaxHealth = 100
                character.Humanoid.Health = 100
            end
            
            Window:Notify({
                Title = "God Mode Premium",
                Description = "❌ God Mode Premium OFF!",
                Duration = 3
            })
        end
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

-- Anti AFK Toggle
MiscSection:Toggle({
    Title = "Anti AFK",
    Description = "Mencegah kick karena AFK",
    Default = false,
    Callback = function(enabled)
        WindUI.Fitur.EnableAntiAFK(enabled)
    end
})

-- Reset Character Button
MiscSection:Button({
    Title = "Reset Character",
    Description = "Reset karakter Anda",
    Callback = function()
        WindUI.Fitur.ResetCharacter()
    end
})

-- Discord Section
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

-- Notification
Window:Notify({
    Title = "ANTC HUB",
    Description = "✅ Loaded successfully! Discord: discord.gg/antchub",
    Duration = 5
})

print("🎉 ANTC HUB Loaded Successfully!")
print("📢 Discord: discord.gg/antchub")
print("🔧 Development Mode: " .. (DevelopmentMode and "Active" or "Inactive"))
