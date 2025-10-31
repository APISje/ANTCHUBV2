--[[
    ANTC HUB LOADER
    Discord: https://discord.gg/antchub
    
    CUSTOMIZATION:
    - Line ~25: Ganti BannerImageID dengan Roblox Asset ID banner Anda
    - Line ~26: Ganti LogoImageID dengan Roblox Asset ID logo Anda
]]

print("Loading ANTC HUB...")

-- Load WindUI Library
local WindUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/APISje/ANTCHUBV2/refs/heads/main/main.lua", true))()

print("ANTC HUB Library Loaded!")

-- SETTING BANNER & LOGO (GANTI DISINI)
local BannerImageID = "10723415766"
local LogoImageID = "10723415766"

-- Services
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TextChatService = game:GetService("TextChatService")
local StarterGui = game:GetService("StarterGui")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")

-- Variables untuk Development Mode & Login
local DevelopmentMode = false
local LoggedIn = false
local AuthorizedDevAccount = "aapis3308"
local DevelopmentCode = "APIS"

-- RGB Color Animation Helper
local function CreateRGBText(textObject)
    local hue = 0
    RunService.RenderStepped:Connect(function()
        hue = (hue + 0.005) % 1
        local color = Color3.fromHSV(hue, 1, 1)
        if textObject and (textObject:IsA("TextLabel") or textObject:IsA("TextButton")) then
            textObject.TextColor3 = color
        end
    end)
end

-- Global Chat Hook untuk Server Messages
local function SendServerMessage(message)
    pcall(function()
        if TextChatService:FindFirstChild("TextChannels") then
            local generalChannel = TextChatService.TextChannels:FindFirstChild("RBXGeneral")
            if generalChannel then
                generalChannel:DisplaySystemMessage("[Server] " .. message)
            end
        end
        
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
        if TextChatService:FindFirstChild("OnIncomingMessage") then
            TextChatService.OnIncomingMessage = function(message)
                if message.Text and string.find(message.Text, "%[Global%]") then
                    local newText = string.gsub(message.Text, "%[Global%]", "[Server]")
                    message.Text = newText
                end
                return message
            end
        end
        
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

task.spawn(function()
    task.wait(2)
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

print("Window Created!")

-- Apply RGB Effect to Title and Author
task.spawn(function()
    task.wait(0.5)
    local titleLabel = Window._window and Window._window.Topbar and Window._window.Topbar:FindFirstChild("Title")
    local authorLabel = Window._window and Window._window.Topbar and Window._window.Topbar:FindFirstChild("Author")
    
    if titleLabel then
        CreateRGBText(titleLabel)
    end
    if authorLabel then
        CreateRGBText(authorLabel)
    end
end)

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
            if WindowFrame and WindowFrame.Frame then
                WindowFrame.Frame.Visible = not WindowFrame.Frame.Visible
            end
        end
    end
end

-- TAB: FREE FEATURES (Visible before login ONLY)
local FreeTab = Window:Tab({
    Title = "FREE",
    Icon = "rbxassetid://10747373176"
})

local FreeSection = FreeTab:Section({
    Title = "Free Features",
    Opened = true
})

-- Fast Auto Clicker (FREE - UNLOCKED)
local FastAutoClickerEnabled = false
local AutoClickConnection = nil

FreeSection:Toggle({
    Title = "Fast Auto Clicker",
    Description = "Auto click 0ms (hanya di layar game)",
    Default = false,
    Callback = function(enabled)
        if not LoggedIn then
            FastAutoClickerEnabled = enabled
            
            if enabled then
                local VirtualInputManager = game:GetService("VirtualInputManager")
                local UserInputService = game:GetService("UserInputService")
                
                AutoClickConnection = task.spawn(function()
                    while FastAutoClickerEnabled and not LoggedIn do
                        local mouseLocation = UserInputService:GetMouseLocation()
                        local guiObjects = game:GetService("CoreGui"):GetGuiObjectsAtPosition(mouseLocation.X, mouseLocation.Y)
                        local playerGui = Players.LocalPlayer:FindFirstChild("PlayerGui")
                        if playerGui then
                            local playerGuiObjects = playerGui:GetGuiObjectsAtPosition(mouseLocation.X, mouseLocation.Y)
                            for _, obj in ipairs(playerGuiObjects) do
                                table.insert(guiObjects, obj)
                            end
                        end
                        
                        if #guiObjects == 0 then
                            VirtualInputManager:SendMouseButtonEvent(0, 0, 0, true, game, 1)
                            task.wait()
                            VirtualInputManager:SendMouseButtonEvent(0, 0, 0, false, game, 1)
                        end
                        
                        task.wait()
                    end
                end)
                
                Window:Notify({
                    Title = "ANTC HUB",
                    Description = "Fast Auto Clicker ON",
                    Duration = 3
                })
            else
                if AutoClickConnection then
                    task.cancel(AutoClickConnection)
                    AutoClickConnection = nil
                end
                
                Window:Notify({
                    Title = "ANTC HUB",
                    Description = "Fast Auto Clicker OFF",
                    Duration = 3
                })
            end
        else
            Window:Notify({
                Title = "ANTC HUB",
                Description = "LOCKED - Auto Clicker dinonaktifkan saat mode Development aktif.",
                Duration = 3
            })
        end
    end
})

-- WalkSpeed Slider (FREE)
FreeSection:Slider({
    Title = "WalkSpeed",
    Description = "Ubah kecepatan jalan",
    Default = 16,
    Min = 16,
    Max = 100,
    Callback = function(value)
        if not LoggedIn then
            WindUI.Fitur.SetWalkSpeed(value)
        end
    end
})

-- JumpPower Slider (FREE)
FreeSection:Slider({
    Title = "JumpPower",
    Description = "Ubah kekuatan lompat",
    Default = 50,
    Min = 50,
    Max = 200,
    Callback = function(value)
        if not LoggedIn then
            WindUI.Fitur.SetJumpPower(value)
        end
    end
})

-- TAB: DEVELOPMENT (Visible for login, premium features shown after login)
local DevelopmentTab = Window:Tab({
    Title = "Development",
    Icon = "rbxassetid://10747373176"
})

local DevLoginSection = DevelopmentTab:Section({
    Title = "Development Access",
    Opened = true
})

-- Input untuk kode Development
DevLoginSection:Input({
    Title = "Development Code",
    Description = "Masukkan kode untuk akses Development",
    Placeholder = "Masukkan kode APIS...",
    Callback = function(value)
        if value == DevelopmentCode then
            local playerName = Players.LocalPlayer.Name
            
            if playerName == AuthorizedDevAccount then
                DevelopmentMode = true
                LoggedIn = true
                
                -- Disable Auto Clicker when logged in
                if FastAutoClickerEnabled then
                    FastAutoClickerEnabled = false
                    if AutoClickConnection then
                        task.cancel(AutoClickConnection)
                        AutoClickConnection = nil
                    end
                end
                
                -- HIDE Free Tab after login (Development tab is already visible)
                if FreeTab and FreeTab._tab then
                    FreeTab._tab.Visible = false
                end
                
                -- SHOW Premium Features and Testing Tools sections after login
                if DevFeaturesSection and DevFeaturesSection._section then
                    DevFeaturesSection._section.Visible = true
                end
                if DevTestSection and DevTestSection._section then
                    DevTestSection._section.Visible = true
                end
                
                Window:Notify({
                    Title = "ANTC HUB Development",
                    Description = "Welcome Developer " .. playerName .. "!",
                    Duration = 5
                })
            else
                Window:Notify({
                    Title = "ANTC HUB Development",
                    Description = "Unauthorized access! Kicking in 10 seconds...",
                    Duration = 10
                })
                
                task.wait(10)
                Players.LocalPlayer:Kick("Unauthorized Development Access\nHanya " .. AuthorizedDevAccount .. " yang dapat menggunakan kode APIS")
            end
        else
            Window:Notify({
                Title = "ANTC HUB Development",
                Description = "Kode salah!",
                Duration = 3
            })
        end
    end
})

-- Development Features Section (PREMIUM - Only after login)
local DevFeaturesSection = DevelopmentTab:Section({
    Title = "Premium Features",
    Opened = true
})

-- HIDE Premium Features section until login
if DevFeaturesSection and DevFeaturesSection._section then
    DevFeaturesSection._section.Visible = false
end

-- Super Intan (PREMIUM)
DevFeaturesSection:Button({
    Title = "Super Intan (Dev)",
    Description = "Super Intan - Development Version",
    Callback = function()
        if DevelopmentMode then
            Window:Notify({
                Title = "Development",
                Description = "Super Intan Activated!",
                Duration = 3
            })
            SendServerMessage("Developer " .. Players.LocalPlayer.Name .. " activated Super Intan!")
        else
            Window:Notify({
                Title = "Development",
                Description = "LOCKED - Masukkan kode Development dulu!",
                Duration = 3
            })
        end
    end
})

-- Super Bland (PREMIUM - TRUE 0MS - NO DELAY)
local SuperBlandEnabled = false
local SuperBlandConnection = nil

DevFeaturesSection:Toggle({
    Title = "Super Bland (0-MS)",
    Description = "Super Bland dengan TRUE 0ms delay - Development Only",
    Default = false,
    Callback = function(enabled)
        if DevelopmentMode then
            SuperBlandEnabled = enabled
            
            if enabled then
                SuperBlandConnection = RunService.Heartbeat:Connect(function()
                    if SuperBlandEnabled then
                        -- Super Bland logic here with TRUE 0ms delay (no task.wait)
                        -- Runs every frame with no delay
                    end
                end)
                
                Window:Notify({
                    Title = "Development",
                    Description = "Super Bland (0-MS) Activated!",
                    Duration = 3
                })
                SendServerMessage("Developer " .. Players.LocalPlayer.Name .. " activated Super Bland (0-MS)!")
            else
                if SuperBlandConnection then
                    SuperBlandConnection:Disconnect()
                    SuperBlandConnection = nil
                end
                
                Window:Notify({
                    Title = "Development",
                    Description = "Super Bland OFF",
                    Duration = 3
                })
            end
        else
            Window:Notify({
                Title = "Development",
                Description = "LOCKED - Masukkan kode Development dulu!",
                Duration = 3
            })
        end
    end
})

-- Premium WalkSpeed
DevFeaturesSection:Slider({
    Title = "WalkSpeed Premium",
    Description = "Kecepatan jalan unlimited",
    Default = 16,
    Min = 16,
    Max = 500,
    Callback = function(value)
        if DevelopmentMode then
            WindUI.Fitur.SetWalkSpeed(value)
        else
            Window:Notify({
                Title = "Development",
                Description = "LOCKED - Masukkan kode Development dulu!",
                Duration = 3
            })
        end
    end
})

-- Premium JumpPower
DevFeaturesSection:Slider({
    Title = "JumpPower Premium",
    Description = "Kekuatan lompat unlimited",
    Default = 50,
    Min = 50,
    Max = 500,
    Callback = function(value)
        if DevelopmentMode then
            WindUI.Fitur.SetJumpPower(value)
        else
            Window:Notify({
                Title = "Development",
                Description = "LOCKED - Masukkan kode Development dulu!",
                Duration = 3
            })
        end
    end
})

-- Fly Toggle (PREMIUM)
DevFeaturesSection:Toggle({
    Title = "Fly",
    Description = "Mode terbang (WASD + Space/Shift)",
    Default = false,
    Callback = function(enabled)
        if DevelopmentMode then
            WindUI.Fitur.EnableFly(enabled, 50)
        else
            Window:Notify({
                Title = "Development",
                Description = "LOCKED - Masukkan kode Development dulu!",
                Duration = 3
            })
        end
    end
})

-- Noclip Toggle (PREMIUM)
DevFeaturesSection:Toggle({
    Title = "Noclip",
    Description = "Tembus tembok",
    Default = false,
    Callback = function(enabled)
        if DevelopmentMode then
            WindUI.Fitur.EnableNoclip(enabled)
        else
            Window:Notify({
                Title = "Development",
                Description = "LOCKED - Masukkan kode Development dulu!",
                Duration = 3
            })
        end
    end
})

-- ESP Toggle (PREMIUM)
DevFeaturesSection:Toggle({
    Title = "ESP",
    Description = "Lihat player lewat tembok",
    Default = false,
    Callback = function(enabled)
        if DevelopmentMode then
            WindUI.Fitur.EnableESP(enabled)
        else
            Window:Notify({
                Title = "Development",
                Description = "LOCKED - Masukkan kode Development dulu!",
                Duration = 3
            })
        end
    end
})

-- FullBright Toggle (PREMIUM)
DevFeaturesSection:Toggle({
    Title = "FullBright",
    Description = "Terang penuh tanpa bayangan",
    Default = false,
    Callback = function(enabled)
        if DevelopmentMode then
            WindUI.Fitur.EnableFullBright(enabled)
        else
            Window:Notify({
                Title = "Development",
                Description = "LOCKED - Masukkan kode Development dulu!",
                Duration = 3
            })
        end
    end
})

-- God Mode Premium (PREMIUM)
DevFeaturesSection:Toggle({
    Title = "God Mode Premium",
    Description = "HP unlimited - Development Only",
    Default = false,
    Callback = function(enabled)
        if DevelopmentMode then
            if enabled then
                local character = Players.LocalPlayer.Character
                if character and character:FindFirstChild("Humanoid") then
                    character.Humanoid.MaxHealth = math.huge
                    character.Humanoid.Health = math.huge
                end
                
                Window:Notify({
                    Title = "God Mode Premium",
                    Description = "God Mode Premium ON!",
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
                    Description = "God Mode Premium OFF!",
                    Duration = 3
                })
            end
        else
            Window:Notify({
                Title = "Development",
                Description = "LOCKED - Masukkan kode Development dulu!",
                Duration = 3
            })
        end
    end
})

-- Invisible Mode (PREMIUM)
local invisibleMode = false

DevFeaturesSection:Toggle({
    Title = "Invisible Mode",
    Description = "Mode invisible - Development Only",
    Default = false,
    Callback = function(enabled)
        if DevelopmentMode then
            invisibleMode = enabled
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
                    Description = "Invisible Mode ON!",
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
                    Description = "Invisible Mode OFF!",
                    Duration = 3
                })
            end
        else
            Window:Notify({
                Title = "Development",
                Description = "LOCKED - Masukkan kode Development dulu!",
                Duration = 3
            })
        end
    end
})

-- Development Testing Tools
local DevTestSection = DevelopmentTab:Section({
    Title = "Testing Tools",
    Opened = true
})

-- HIDE Testing Tools section until login
if DevTestSection and DevTestSection._section then
    DevTestSection._section.Visible = false
end

DevTestSection:Button({
    Title = "Test Server Notification",
    Description = "Test notifikasi server global",
    Callback = function()
        if DevelopmentMode then
            SendServerMessage("Claurenn_09 obtained a Shiny Zombie Shark (255kg) with a 1 in 250K chance!")
            task.wait(0.5)
            SendServerMessage("WindahJAMDINDINGxRF1 obtained a Shiny Frostborn Shark (8.29K kg) with a 1 in 500K chance!")
            
            Window:Notify({
                Title = "Development",
                Description = "Server notifications sent!",
                Duration = 3
            })
        else
            Window:Notify({
                Title = "Development",
                Description = "LOCKED - Masukkan kode Development dulu!",
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
                    Description = "Message sent: " .. value,
                    Duration = 3
                })
            end
        else
            Window:Notify({
                Title = "Development",
                Description = "LOCKED - Masukkan kode Development dulu!",
                Duration = 3
            })
        end
    end
})

DevTestSection:Button({
    Title = "Account Info",
    Description = "Lihat informasi akun",
    Callback = function()
        local info = string.format(
            "Username: %s\nUser ID: %s\nDevelopment Mode: %s\nAuthorized: %s",
            Players.LocalPlayer.Name,
            Players.LocalPlayer.UserId,
            DevelopmentMode and "Active" or "Inactive",
            Players.LocalPlayer.Name == AuthorizedDevAccount and "Yes" or "No"
        )
        
        Window:Notify({
            Title = "Account Information",
            Description = info,
            Duration = 8
        })
    end
})

-- TAB: SETTINGS (with Avatar Image)
local SettingsTab = Window:Tab({
    Title = "Settings",
    Icon = "rbxassetid://10734950309"
})

local ProfileSection = SettingsTab:Section({
    Title = "Profile & Status",
    Opened = true
})

-- Create Avatar Display Section with actual ImageLabel
task.spawn(function()
    local success, thumbnailUrl = pcall(function()
        return Players:GetUserThumbnailAsync(
            Players.LocalPlayer.UserId,
            Enum.ThumbnailType.HeadShot,
            Enum.ThumbnailSize.Size150x150
        )
    end)
    
    if success and thumbnailUrl then
        -- Find the ProfileSection Frame to add ImageLabel
        task.wait(0.5)
        
        -- Create a custom button with avatar image
        ProfileSection:Button({
            Title = "Player: " .. Players.LocalPlayer.Name,
            Description = "User ID: " .. Players.LocalPlayer.UserId .. " | Age: " .. Players.LocalPlayer.AccountAge .. " days",
            Callback = function()
                Window:Notify({
                    Title = "Profile Information",
                    Description = string.format(
                        "Username: %s\nDisplay: %s\nUser ID: %s\nAccount Age: %d days\nDev Mode: %s",
                        Players.LocalPlayer.Name,
                        Players.LocalPlayer.DisplayName,
                        Players.LocalPlayer.UserId,
                        Players.LocalPlayer.AccountAge,
                        DevelopmentMode and "Active" or "Inactive"
                    ),
                    Duration = 10
                })
            end
        })
        
        -- Try to add avatar image to the window
        -- Note: This depends on WindUI library structure
        -- Creating a simple image display in the section
        local playerGui = Players.LocalPlayer:WaitForChild("PlayerGui")
        task.spawn(function()
            task.wait(1)
            -- Try to find the Settings section and add avatar
            pcall(function()
                local windowGui = playerGui:FindFirstChild("WindUI")
                if windowGui then
                    -- Search for the profile section
                    for _, desc in ipairs(windowGui:GetDescendants()) do
                        if desc:IsA("Frame") and desc.Name:find("Section") then
                            -- Create avatar image
                            local avatarImage = Instance.new("ImageLabel")
                            avatarImage.Name = "PlayerAvatar"
                            avatarImage.Size = UDim2.new(0, 100, 0, 100)
                            avatarImage.Position = UDim2.new(0.5, -50, 0, 10)
                            avatarImage.Image = thumbnailUrl
                            avatarImage.BackgroundTransparency = 1
                            avatarImage.BorderSizePixel = 0
                            
                            -- Add corner rounding
                            local corner = Instance.new("UICorner")
                            corner.CornerRadius = UDim.new(0, 50)
                            corner.Parent = avatarImage
                            
                            avatarImage.Parent = desc
                            break
                        end
                    end
                end
            end)
        end)
    end
end)

-- Display Settings
local DisplaySection = SettingsTab:Section({
    Title = "Display Settings",
    Opened = true
})

DisplaySection:Button({
    Title = "Theme",
    Description = "Current: Dark Theme",
    Callback = function()
        Window:Notify({
            Title = "Settings",
            Description = "Theme: Dark",
            Duration = 3
        })
    end
})

-- TAB: TELEPORT
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
                Description = "Posisi tersimpan!",
                Duration = 3
            })
        else
            Window:Notify({
                Title = "ANTC HUB",
                Description = "Gagal simpan posisi!",
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
                Description = "Teleport ke posisi tersimpan!",
                Duration = 3
            })
        else
            Window:Notify({
                Title = "ANTC HUB",
                Description = "Belum ada posisi tersimpan!",
                Duration = 3
            })
        end
    end
})

-- TAB: MISC
local MiscTab = Window:Tab({
    Title = "Misc",
    Icon = "rbxassetid://10734924532"
})

local MiscSection = MiscTab:Section({
    Title = "Utilities"
})

MiscSection:Toggle({
    Title = "Anti AFK",
    Description = "Mencegah kick karena AFK",
    Default = false,
    Callback = function(enabled)
        WindUI.Fitur.EnableAntiAFK(enabled)
    end
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

-- Notification
Window:Notify({
    Title = "ANTC HUB",
    Description = "Loaded successfully! Discord: discord.gg/antchub",
    Duration = 5
})

print("ANTC HUB Loaded Successfully!")
print("Discord: discord.gg/antchub")
print("Development Mode: " .. (DevelopmentMode and "Active" or "Inactive"))
