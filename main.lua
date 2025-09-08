-- Main Script
-- Load modules dan UI menggunakan Kavo Library
-- Dapat diakses secara online

-- Services
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

-- Variables
local player = Players.LocalPlayer

-- Error handling function
local function safeLoad(url, name)
    local success, result = pcall(function()
        return loadstring(game:HttpGet(url))()
    end)
    
    if success then
        print("✅ " .. name .. " loaded successfully")
        return result
    else
        warn("❌ Failed to load " .. name .. ": " .. tostring(result))
        return nil
    end
end

-- Load Kavo Library (dari repository kita sendiri)
print("🔄 Loading Kavo Library...")
local Library = safeLoad("https://raw.githubusercontent.com/donitono/SUPER/main/kavo.lua", "Kavo Library")

if not Library then
    error("Failed to load UI Library! Script cannot continue.")
    return
end

-- Load Modules (dari repository kita sendiri)
print("🔄 Loading Autofarm Module...")
local autofarm = safeLoad("https://raw.githubusercontent.com/donitono/SUPER/main/modules/autofarm.lua", "Autofarm Module")

if not autofarm then
    warn("Autofarm module failed to load - using fallback methods")
    -- Create fallback autofarm object
    autofarm = {
        setCastMode = function(mode) print("Fallback: Cast mode set to " .. mode) end,
        startAutoCast = function(mode) print("Fallback: Auto cast started") end,
        stopAutoCast = function() print("Fallback: Auto cast stopped") end,
        setShakeMode = function(mode) print("Fallback: Shake mode set to " .. mode) end,
        startAutoShake = function(mode) print("Fallback: Auto shake started") end,
        stopAutoShake = function() print("Fallback: Auto shake stopped") end,
        setReelMode = function(mode) print("Fallback: Reel mode set to " .. mode) end,
        startAutoReel = function(mode) print("Fallback: Auto reel started") end,
        stopAutoReel = function() print("Fallback: Auto reel stopped") end,
        startAlwaysCatch = function() print("Fallback: Always catch started") end,
        stopAlwaysCatch = function() print("Fallback: Always catch stopped") end,
        startAll = function(s, c, r) print("Fallback: All features started") end,
        stopAll = function() print("Fallback: All features stopped") end,
        getStatus = function() return {autoCast = false, autoShake = false, autoReel = false, alwaysCatch = false, castMode = 1, shakeMode = 1} end
    }
end

-- Create Main Window
print("🔄 Creating UI Window...")
local Window = Library.CreateLib("SUPER HUB v1.0", "DarkTheme")

-- Autofarm Tab
local AutofarmTab = Window:NewTab("🎣 Autofarm")
local AutofarmSection = AutofarmTab:NewSection("Fishing Automation")

-- Cast Mode Selection
local currentCastMode = 1
local success1, err1 = pcall(function()
    AutofarmSection:NewDropdown("Cast Mode", "Select auto cast mode", {"Mode 1 (Legit - Perfect)", "Mode 2 (Rage - Instant)", "Mode 3 (Random - Variable)"}, function(option)
        if option == "Mode 1 (Legit - Perfect)" then
            currentCastMode = 1
        elseif option == "Mode 2 (Rage - Instant)" then
            currentCastMode = 2
        elseif option == "Mode 3 (Random - Variable)" then
            currentCastMode = 3
        end
        if autofarm and autofarm.setCastMode then
            autofarm.setCastMode(currentCastMode)
        end
        print("Cast Mode changed to: " .. currentCastMode)
    end)
end)

if not success1 then warn("Failed to create Cast Mode dropdown: " .. err1) end

-- Auto Cast
local success2, err2 = pcall(function()
    AutofarmSection:NewToggle("Auto Cast", "Automatically cast fishing rod", function(state)
        if state then
            if autofarm and autofarm.startAutoCast then
                autofarm.startAutoCast(currentCastMode)
            end
            print("Auto Cast: Enabled (Mode " .. currentCastMode .. ")")
        else
            if autofarm and autofarm.stopAutoCast then
                autofarm.stopAutoCast()
            end
            print("Auto Cast: Disabled")
        end
    end)
end)

if not success2 then warn("Failed to create Auto Cast toggle: " .. err2) end

-- Auto Shake dengan Mode Selection
local currentShakeMode = 1
local success3, err3 = pcall(function()
    AutofarmSection:NewDropdown("Shake Mode", "Select auto shake mode", {"Mode 1 (SanHub)", "Mode 2 (NeoxHub)"}, function(option)
        if option == "Mode 1 (SanHub)" then
            currentShakeMode = 1
        elseif option == "Mode 2 (NeoxHub)" then
            currentShakeMode = 2
        end
        if autofarm and autofarm.setShakeMode then
            autofarm.setShakeMode(currentShakeMode)
        end
        print("Shake Mode changed to: " .. currentShakeMode)
    end)
end)

if not success3 then warn("Failed to create Shake Mode dropdown: " .. err3) end

local success4, err4 = pcall(function()
    AutofarmSection:NewToggle("Auto Shake", "Automatically shake when needed", function(state)
        if state then
            if autofarm and autofarm.startAutoShake then
                autofarm.startAutoShake(currentShakeMode)
            end
            print("Auto Shake: Enabled (Mode " .. currentShakeMode .. ")")
        else
            if autofarm and autofarm.stopAutoShake then
                autofarm.stopAutoShake()
            end
            print("Auto Shake: Disabled")
        end
    end)
end)

if not success4 then warn("Failed to create Auto Shake toggle: " .. err4) end

-- Reel Mode Selection
local currentReelMode = 1
local success5, err5 = pcall(function()
    AutofarmSection:NewDropdown("Reel Mode", "Select auto reel mode", {"Mode 1 (Faster - Instant)", "Mode 2 (Normal - Fill Bar)", "Mode 3 (Legit - Follow Line)", "Mode 4 (Fail - No Action)"}, function(option)
        if option == "Mode 1 (Faster - Instant)" then
            currentReelMode = 1
        elseif option == "Mode 2 (Normal - Fill Bar)" then
            currentReelMode = 2
        elseif option == "Mode 3 (Legit - Follow Line)" then
            currentReelMode = 3
        elseif option == "Mode 4 (Fail - No Action)" then
            currentReelMode = 4
        end
        if autofarm and autofarm.setReelMode then
            autofarm.setReelMode(currentReelMode)
        end
        print("Reel Mode changed to: " .. currentReelMode)
    end)
end)

if not success5 then warn("Failed to create Reel Mode dropdown: " .. err5) end

-- Auto Reel
local success6, err6 = pcall(function()
    AutofarmSection:NewToggle("Auto Reel", "Automatically reel in fish", function(state)
        if state then
            if autofarm and autofarm.startAutoReel then
                autofarm.startAutoReel(currentReelMode)
            end
            print("Auto Reel: Enabled (Mode " .. currentReelMode .. ")")
        else
            if autofarm and autofarm.stopAutoReel then
                autofarm.stopAutoReel()
            end
            print("Auto Reel: Disabled")
        end
    end)
end)

if not success6 then warn("Failed to create Auto Reel toggle: " .. err6) end

-- Always Catch (dari sanhub)
local success7, err7 = pcall(function()
    AutofarmSection:NewToggle("Always Catch", "Never miss a fish - perfect catch every time", function(state)
        if state then
            if autofarm and autofarm.startAlwaysCatch then
                autofarm.startAlwaysCatch()
            end
            print("Always Catch: Enabled")
        else
            if autofarm and autofarm.stopAlwaysCatch then
                autofarm.stopAlwaysCatch()
            end
            print("Always Catch: Disabled")
        end
    end)
end)

if not success7 then warn("Failed to create Always Catch toggle: " .. err7) end

-- Quick Actions
local QuickSection = AutofarmTab:NewSection("Quick Actions")

pcall(function()
    QuickSection:NewButton("Start All Autofarm", "Enable all autofarm features", function()
        if autofarm and autofarm.startAll then
            autofarm.startAll(currentShakeMode, currentCastMode, currentReelMode)
        end
        print("All Autofarm: Started with Cast Mode " .. currentCastMode .. ", Shake Mode " .. currentShakeMode .. ", Reel Mode " .. currentReelMode)
    end)
end)

pcall(function()
    QuickSection:NewButton("Stop All Autofarm", "Disable all autofarm features", function()
        if autofarm and autofarm.stopAll then
            autofarm.stopAll()
        end
        print("All Autofarm Features: Disabled")
    end)
end)

pcall(function()
    QuickSection:NewButton("Check Status", "Show current autofarm status", function()
        if autofarm and autofarm.getStatus then
            local status = autofarm.getStatus()
            print("=== Autofarm Status ===")
            print("Auto Cast: " .. tostring(status.autoCast))
            print("Auto Shake: " .. tostring(status.autoShake))
            print("Auto Reel: " .. tostring(status.autoReel))
            print("Always Catch: " .. tostring(status.alwaysCatch))
            print("Cast Mode: " .. tostring(status.castMode))
            print("Shake Mode: " .. tostring(status.shakeMode))
            print("=====================")
        else
            print("❌ Autofarm module not available")
        end
    end)
end)

-- Player Tab
local PlayerTab = Window:NewTab("👤 Player")
local PlayerSection = PlayerTab:NewSection("Player Modifications")

-- Player Speed
PlayerSection:NewSlider("Walkspeed", "Change player walkspeed", 500, 16, function(value)
    -- Fallback method langsung ke character
    local character = player.Character
    if character and character:FindFirstChild("Humanoid") then
        character.Humanoid.WalkSpeed = value
        print("Walkspeed set to: " .. value)
    end
end)

-- Jump Power
PlayerSection:NewSlider("Jump Power", "Change player jump power", 200, 50, function(value)
    -- Fallback method langsung ke character
    local character = player.Character
    if character and character:FindFirstChild("Humanoid") then
        character.Humanoid.JumpPower = value
        print("Jump Power set to: " .. value)
    end
end)

-- Infinite Oxygen
PlayerSection:NewToggle("Infinite Oxygen", "Never run out of oxygen", function(state)
    -- Fallback method
    spawn(function()
        while state do
            local character = player.Character
            if character then
                local oxygen = character:FindFirstChild("Oxygen")
                if oxygen then
                    oxygen.Value = 100
                end
            end
            wait(1)
        end
    end)
    print("Infinite Oxygen: " .. tostring(state))
end)

-- No AFK
PlayerSection:NewToggle("No AFK", "Prevent AFK kick", function(state)
    if state then
        spawn(function()
            while state do
                game:GetService("VirtualUser"):CaptureController()
                game:GetService("VirtualUser"):ClickButton2(Vector2.new())
                wait(300) -- Every 5 minutes
            end
        end)
    end
end)

-- Teleports Tab
local TeleportTab = Window:NewTab("🚀 Teleports")
local TeleportSection = TeleportTab:NewSection("Zone Teleports")

-- Common fishing zones
local zones = {
    ["Spawn"] = Vector3.new(0, 5, 0),
    ["Ocean"] = Vector3.new(1000, 5, 1000),
    ["Lake"] = Vector3.new(-500, 5, 500),
    ["River"] = Vector3.new(200, 5, -300),
    ["Deep Sea"] = Vector3.new(2000, -50, 2000)
}

for zoneName, position in pairs(zones) do
    TeleportSection:NewButton("Teleport to " .. zoneName, "Teleport to " .. zoneName, function()
        -- Fallback teleport langsung
        local character = player.Character
        if character and character:FindFirstChild("HumanoidRootPart") then
            character.HumanoidRootPart.CFrame = CFrame.new(position)
            print("Teleported to: " .. zoneName)
        else
            warn("Character or HumanoidRootPart not found!")
        end
    end)
end

-- Custom Teleport
local customTeleportSection = TeleportTab:NewSection("Custom Teleport")
local customX, customY, customZ = 0, 5, 0

customTeleportSection:NewTextBox("X Position", "Enter X coordinate", function(txt)
    customX = tonumber(txt) or 0
end)

customTeleportSection:NewTextBox("Y Position", "Enter Y coordinate", function(txt)
    customY = tonumber(txt) or 5
end)

customTeleportSection:NewTextBox("Z Position", "Enter Z coordinate", function(txt)
    customZ = tonumber(txt) or 0
end)

customTeleportSection:NewButton("Teleport to Custom Position", "Teleport to specified coordinates", function()
    local position = Vector3.new(customX, customY, customZ)
    -- Fallback teleport langsung
    local character = player.Character
    if character and character:FindFirstChild("HumanoidRootPart") then
        character.HumanoidRootPart.CFrame = CFrame.new(position)
        print("Teleported to: " .. tostring(position))
    else
        warn("Character or HumanoidRootPart not found!")
    end
end)

-- Misc Tab
local MiscTab = Window:NewTab("⚙️ Misc")
local MiscSection = MiscTab:NewSection("Miscellaneous")

-- Game modifications
MiscSection:NewToggle("Perfect Cast", "Always perfect cast", function(state)
    spawn(function()
        while state do
            local perfectCastEvent = ReplicatedStorage:FindFirstChild("events")
            if perfectCastEvent then
                local cast = perfectCastEvent:FindFirstChild("cast")
                if cast then
                    -- Override cast dengan perfect values
                    local oldFireServer = cast.FireServer
                    cast.FireServer = function(self, power, accuracy)
                        return oldFireServer(self, 100, 1) -- Perfect cast
                    end
                end
            end
            wait(1)
        end
    end)
end)

-- Rod Chams
MiscSection:NewToggle("Rod Chams", "Highlight fishing rods", function(state)
    for _, obj in pairs(workspace:GetDescendants()) do
        if obj.Name:lower():find("rod") and obj:IsA("BasePart") then
            if state then
                local highlight = Instance.new("SelectionBox")
                highlight.Parent = obj
                highlight.Adornee = obj
                highlight.Color3 = Color3.fromRGB(0, 255, 0)
                highlight.LineThickness = 2
                highlight.Transparency = 0.5
            else
                local highlight = obj:FindFirstChildOfClass("SelectionBox")
                if highlight then
                    highlight:Destroy()
                end
            end
        end
    end
end)

-- Credits Tab
local CreditsTab = Window:NewTab("ℹ️ Credits")
local CreditsSection = CreditsTab:NewSection("Script Information")

CreditsSection:NewLabel("SUPER HUB v1.0")
CreditsSection:NewLabel("Created by: donitono")
CreditsSection:NewLabel("UI Library: Kavo")
CreditsSection:NewLabel("GitHub: github.com/donitono/SUPER")

CreditsSection:NewButton("Copy Discord", "Copy Discord invite", function()
    setclipboard("https://discord.gg/superhub")
    print("Discord link copied to clipboard!")
end)

CreditsSection:NewButton("Copy GitHub", "Copy GitHub repository", function()
    setclipboard("https://github.com/donitono/SUPER")
    print("GitHub link copied to clipboard!")
end)

-- Error handling
local function handleError(err)
    warn("SUPER HUB Error: " .. tostring(err))
end

-- Wrap main execution in pcall untuk initialization tambahan
local success, err = pcall(function()
    print("=================================")
    print("    SUPER HUB v1.0 Loaded!")
    print("    UI: Kavo Library")
    if autofarm then
        print("    Modules: Autofarm (Ready)")
    else
        print("    Modules: Fallback Mode")
    end
    print("    Status: Ready for Use!")
    print("=================================")
end)

if not success then
    handleError(err)
end

-- Auto-update check dengan error handling
spawn(function()
    local success, version = pcall(function()
        return game:HttpGet("https://raw.githubusercontent.com/donitono/SUPER/main/version.txt")
    end)
    
    if success and version then
        local currentVersion = "1.0"
        if version ~= currentVersion then
            print("📢 New version available: " .. version)
            print("📢 Current version: " .. currentVersion)
            print("📢 Visit GitHub to update!")
        else
            print("✅ You have the latest version!")
        end
    else
        print("⚠️ Could not check for updates")
    end
end)
