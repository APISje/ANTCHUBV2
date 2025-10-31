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

-- Buat Window
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
    Opened = true  -- Auto expand
})

-- Super Intan (LOCKED)
FishItSection:Button({
    Title = "🔒 Super Intan",
    Description = "Tahap perbaikan - Coming Soon!",
    Locked = true,
    Callback = function()
        Window:Notify({
            Title = "ANTC HUB",
            Description = "⚠️ Fitur masih dalam tahap perbaikan!",
            Duration = 3
        })
    end
})

-- Super Bland (LOCKED)
FishItSection:Button({
    Title = "🔒 Super Bland",
    Description = "Tahap uji - Coming Soon!",
    Locked = true,
    Callback = function()
        Window:Notify({
            Title = "ANTC HUB",
            Description = "⚠️ Fitur masih dalam tahap uji!",
            Duration = 3
        })
    end
})

-- Fast Auto Clicker (UNLOCKED)
local FastAutoClickerEnabled = false
local AutoClickConnection = nil

FishItSection:Toggle({
    Title = "Fast Auto Clicker",
    Description = "Auto click 0ms (tidak bisa diatur)",
    Default = false,
    Callback = function(enabled)
        FastAutoClickerEnabled = enabled
        
        if enabled then
            -- Start auto clicker
            local VirtualInputManager = game:GetService("VirtualInputManager")
            
            AutoClickConnection = task.spawn(function()
                while FastAutoClickerEnabled do
                    VirtualInputManager:SendMouseButtonEvent(0, 0, 0, true, game, 1)
                    task.wait()  -- 0ms delay
                    VirtualInputManager:SendMouseButtonEvent(0, 0, 0, false, game, 1)
                    task.wait()  -- 0ms delay
                end
            end)
            
            Window:Notify({
                Title = "ANTC HUB",
                Description = "✅ Fast Auto Clicker ON (0ms)",
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

-- Tab Misc
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
