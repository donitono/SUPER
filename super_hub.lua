--[[
    SUPER HUB - Modular Fishing Script
    Combines features from NeoX Hub and King Hub with Fluent UI
    Version: 1.0.0
    
    Current Features:
    - Auto Cast (Legit & Rage mode)
    - Auto Shake (Multiple methods)
    - Auto Reel
]]

-- Load Fluent UI Library
local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()

-- Services
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local VirtualInputManager = game:GetService("VirtualInputManager")
local GuiService = game:GetService("GuiService")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

-- Player References
local LocalPlayer = Players.LocalPlayer
local LocalCharacter = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local HumanoidRootPart = LocalCharacter:WaitForChild("HumanoidRootPart")
local PlayerGUI = LocalPlayer:WaitForChild("PlayerGui")

-- Configuration Variables
local Config = {
    General = {
        mode = "Safe", -- "Safe", "Normal", "Risky"
        randomization = true,
        debugMode = false -- Enable untuk melihat GUI structure
    },
    AutoShake = {
        enabled = false,
        delay = 0.1,
        method = "KeyCodeEvent" -- "ClickEvent", "KeyCodeEvent"
    },
    AutoReel = {
        enabled = false,
        delay = 2,
        mode = "Normal" -- "Normal", "Perfect", "Instant"
    },
    AutoCast = {
        enabled = false,
        mode = "Legit", -- "Legit", "Rage"
        delay = 2,
        retryFailedCasts = true -- Auto retry when cast fails
    }
}

-- Mode Presets
local ModePresets = {
    Safe = {
        AutoShake = { delay = {0.8, 1.5}, method = "KeyCodeEvent" },
        AutoReel = { delay = {3, 5}, mode = "Normal" },
        AutoCast = { delay = {4, 7}, mode = "Legit" },
        description = "Safest settings with human-like delays"
    },
    Normal = {
        AutoShake = { delay = {0.3, 0.8}, method = "KeyCodeEvent" },
        AutoReel = { delay = {2, 3}, mode = "Normal" },
        AutoCast = { delay = {2, 4}, mode = "Legit" },
        description = "Balanced performance and safety"
    },
    Risky = {
        AutoShake = { delay = {0.1, 0.3}, method = "ClickEvent" },
        AutoReel = { delay = {1, 2}, mode = "Perfect" },
        AutoCast = { delay = {1, 2}, mode = "Legit" },
        description = "Fast but higher detection risk"
    },
    Rage = {
        AutoShake = { delay = {0.05, 0.1}, method = "ClickEvent" },
        AutoReel = { delay = {0.5, 1}, mode = "Instant" },
        AutoCast = { delay = {0.5, 1}, mode = "Rage" },
        description = "Maximum speed - HIGH RISK!"
    }
}

-- Connection Variables
local connections = {}

-- Create Window
local Window = Fluent:CreateWindow({
    Title = "SUPER HUB | FISCH",
    SubTitle = "Modular Fishing Features",
    TabWidth = 160,
    Size = UDim2.fromOffset(580, 460),
    Acrylic = true,
    Theme = "Dark",
    MinimizeKey = Enum.KeyCode.LeftControl
})

-- Create Tabs
local Tabs = {
    Main = Window:AddTab({ Title = "Fishing", Icon = "🎣" }),
    Settings = Window:AddTab({ Title = "Settings", Icon = "settings" })
}

-- Helper Functions
local function getRandomDelay(delayRange)
    if type(delayRange) == "table" and #delayRange == 2 then
        local min, max = delayRange[1], delayRange[2]
        return min + math.random() * (max - min)
    else
        return delayRange or 1
    end
end

local function applyModePreset(mode)
    local preset = ModePresets[mode]
    if not preset then return end
    
    -- Update config with preset values
    Config.AutoShake.method = preset.AutoShake.method
    Config.AutoReel.mode = preset.AutoReel.mode
    Config.AutoCast.mode = preset.AutoCast.mode
    
    print("Applied", mode, "mode:", preset.description)
end

local function getDelayForFeature(feature)
    local preset = ModePresets[Config.General.mode]
    if not preset or not preset[feature] then
        return Config[feature].delay
    end
    
    if Config.General.randomization then
        return getRandomDelay(preset[feature].delay)
    else
        -- Use average of range
        local delayRange = preset[feature].delay
        if type(delayRange) == "table" then
            return (delayRange[1] + delayRange[2]) / 2
        else
            return delayRange
        end
    end
end

local function WaitForSomeone(event)
    local connection
    local completed = false
    
    connection = event:Connect(function()
        completed = true
        connection:Disconnect()
    end)
    
    repeat
        wait()
    until completed
    
    return true
end

-- Auto Shake Implementation
local function setupAutoShake()
    if connections.autoShake then
        connections.autoShake:Disconnect()
    end
    
    connections.autoShake = PlayerGUI.ChildAdded:Connect(function(GUI)
        if GUI:IsA("ScreenGui") and GUI.Name == "shakeui" then
            if GUI:FindFirstChild("safezone") ~= nil then
                GUI.safezone.ChildAdded:Connect(function(child)
                    if child:IsA("ImageButton") and child.Name == "button" then
                        if Config.AutoShake.enabled == true then
                            local currentDelay = getDelayForFeature("AutoShake")
                            task.wait(currentDelay)
                            if child.Visible == true then
                                if Config.AutoShake.method == "ClickEvent" then
                                    local pos = child.AbsolutePosition
                                    local size = child.AbsoluteSize
                                    VirtualInputManager:SendMouseButtonEvent(pos.X + size.X / 2, pos.Y + size.Y / 2, 0, true, LocalPlayer, 0)
                                    VirtualInputManager:SendMouseButtonEvent(pos.X + size.X / 2, pos.Y + size.Y / 2, 0, false, LocalPlayer, 0)
                                elseif Config.AutoShake.method == "KeyCodeEvent" then
                                    while WaitForSomeone(RunService.RenderStepped) do
                                        if Config.AutoShake.enabled and GUI.safezone:FindFirstChild(child.Name) ~= nil then
                                            task.wait()
                                            pcall(function()
                                                GuiService.SelectedObject = child
                                                if GuiService.SelectedObject == child then
                                                    VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.Return, false, game)
                                                    VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.Return, false, game)
                                                end
                                            end)
                                        else
                                            GuiService.SelectedObject = nil
                                            break
                                        end
                                    end
                                end
                            end
                        end
                    end
                end)
            end
        end
    end)
end

-- Auto Reel Implementation
local function setupAutoReel()
    if connections.autoReel then
        connections.autoReel:Disconnect()
    end
    
    connections.autoReel = PlayerGUI.ChildAdded:Connect(function(GUI)
        if GUI:IsA("ScreenGui") and GUI.Name == "reel" then
            -- Debug mode - print GUI structure
            if Config.General.debugMode then
                print("=== REEL GUI DEBUG ===")
                print("GUI Name:", GUI.Name)
                print("GUI Children:")
                for _, child in pairs(GUI:GetChildren()) do
                    print("  -", child.Name, "(" .. child.ClassName .. ")")
                    if child:GetChildren() then
                        for _, grandchild in pairs(child:GetChildren()) do
                            print("    -", grandchild.Name, "(" .. grandchild.ClassName .. ")")
                            if grandchild.ClassName == "Frame" or grandchild.ClassName == "ImageLabel" then
                                if grandchild.Size then
                                    print("      Size:", grandchild.Size)
                                end
                            end
                        end
                    end
                end
                print("=====================")
            end
            
            if Config.AutoReel.enabled then
                local currentDelay = getDelayForFeature("AutoReel")
                
                if Config.AutoReel.mode == "Instant" then
                    -- Instant mode - langsung complete
                    if ReplicatedStorage:WaitForChild("events"):WaitForChild("reelfinished") ~= nil then
                        task.wait(currentDelay)
                        ReplicatedStorage.events.reelfinished:FireServer(100, false)
                    end
                    
                elseif Config.AutoReel.mode == "Perfect" then
                    -- Perfect mode - follow progress bar perfectly
                    local foundBar = false
                    local connection
                    
                    -- Try multiple possible bar locations
                    local function findProgressBar()
                        -- Common locations for progress bars
                        local possiblePaths = {
                            GUI:FindFirstChild("bar"),
                            GUI:FindFirstChild("Bar"),
                            GUI:FindFirstChild("progressbar"),
                            GUI:FindFirstChild("ProgressBar"),
                            GUI:FindFirstChild("safezone"),
                        }
                        
                        for _, parent in pairs(possiblePaths) do
                            if parent then
                                local playerbar = parent:FindFirstChild("playerbar") or 
                                                parent:FindFirstChild("bar") or
                                                parent:FindFirstChild("progress") or
                                                parent:FindFirstChild("fill")
                                if playerbar then
                                    return playerbar
                                end
                            end
                        end
                        return nil
                    end
                    
                    local playerBar = findProgressBar()
                    
                    if playerBar then
                        foundBar = true
                        connection = RunService.Heartbeat:Connect(function()
                            if GUI.Parent == nil then
                                connection:Disconnect()
                                return
                            end
                            
                            -- Check different possible progress indicators
                            local progress = 0
                            if playerBar.Size and playerBar.Size.X.Scale then
                                progress = playerBar.Size.X.Scale
                            elseif playerBar:FindFirstChild("Size") then
                                progress = playerBar.Size.X.Scale or 0
                            end
                            
                            if progress > 0.95 then -- Near completion
                                if ReplicatedStorage:WaitForChild("events"):WaitForChild("reelfinished") ~= nil then
                                    ReplicatedStorage.events.reelfinished:FireServer(100, false)
                                    connection:Disconnect()
                                end
                            end
                        end)
                    end
                    
                    -- Fallback if no progress bar found
                    if not foundBar then
                        task.wait(currentDelay)
                        if ReplicatedStorage:WaitForChild("events"):WaitForChild("reelfinished") ~= nil then
                            ReplicatedStorage.events.reelfinished:FireServer(100, false)
                        end
                    end
                    
                elseif Config.AutoReel.mode == "Normal" then
                    -- Normal mode - wait and complete realistically
                    local foundBar = false
                    local connection
                    local hasStartedReeling = false
                    local startTime = tick()
                    
                    local function findProgressBar()
                        local possiblePaths = {
                            GUI:FindFirstChild("bar"),
                            GUI:FindFirstChild("Bar"),
                            GUI:FindFirstChild("progressbar"),
                            GUI:FindFirstChild("ProgressBar"),
                            GUI:FindFirstChild("safezone"),
                        }
                        
                        for _, parent in pairs(possiblePaths) do
                            if parent then
                                local playerbar = parent:FindFirstChild("playerbar") or 
                                                parent:FindFirstChild("bar") or
                                                parent:FindFirstChild("progress") or
                                                parent:FindFirstChild("fill")
                                if playerbar then
                                    return playerbar
                                end
                            end
                        end
                        return nil
                    end
                    
                    local playerBar = findProgressBar()
                    
                    if playerBar then
                        foundBar = true
                        print("Found progress bar:", playerBar.Name)
                        connection = RunService.Heartbeat:Connect(function()
                            if GUI.Parent == nil then
                                connection:Disconnect()
                                return
                            end
                            
                            local progress = 0
                            if playerBar.Size and playerBar.Size.X.Scale then
                                progress = playerBar.Size.X.Scale
                            end
                            
                            -- Debug progress
                            if Config.General.debugMode then
                                print("Progress:", progress)
                            end
                            
                            -- Start reeling when progress begins or after a delay
                            if (progress > 0.1 or tick() - startTime > 1) and not hasStartedReeling then
                                hasStartedReeling = true
                                task.wait(currentDelay)
                            end
                            
                            -- Complete when progress is substantial but not perfect
                            if hasStartedReeling and (progress > 0.6 or tick() - startTime > 3) then
                                local randomCompletion = 0.7 + math.random() * 0.25 -- 70-95%
                                if progress >= randomCompletion or tick() - startTime > 4 then
                                    if ReplicatedStorage:WaitForChild("events"):WaitForChild("reelfinished") ~= nil then
                                        ReplicatedStorage.events.reelfinished:FireServer(100, false)
                                        connection:Disconnect()
                                        print("Reel completed at progress:", progress)
                                    end
                                end
                            end
                        end)
                    else
                        print("No progress bar found, using fallback method")
                    end
                    
                    -- Improved fallback method with timing
                    if not foundBar then
                        spawn(function()
                            local waitTime = currentDelay + math.random() * 2 -- 2-5 seconds random
                            task.wait(waitTime)
                            if GUI.Parent ~= nil and ReplicatedStorage:WaitForChild("events"):WaitForChild("reelfinished") ~= nil then
                                ReplicatedStorage.events.reelfinished:FireServer(100, false)
                                print("Fallback reel completed after", waitTime, "seconds")
                            end
                        end)
                    end
                end
            end
        end
    end)
end

-- Auto Cast Implementation
local function setupAutoCast()
    if connections.autoCast then
        connections.autoCast:Disconnect()
    end
    
    if connections.autoCastFailed then
        connections.autoCastFailed:Disconnect()
    end
    
    if connections.autoCastReset then
        connections.autoCastReset:Disconnect()
    end
    
    local lastCastTime = 0
    local hasCasted = false
    
    -- Function to perform cast
    local function performCast(tool)
        if not Config.AutoCast.enabled then return end
        
        hasCasted = true
        lastCastTime = tick()
        
        if Config.AutoCast.mode == "Legit" then
            VirtualInputManager:SendMouseButtonEvent(0, 0, 0, true, LocalPlayer, 0)
            HumanoidRootPart.ChildAdded:Connect(function()
                if HumanoidRootPart:FindFirstChild("power") ~= nil and HumanoidRootPart.power.powerbar.bar ~= nil then
                    HumanoidRootPart.power.powerbar.bar.Changed:Connect(function(property)
                        if property == "Size" then
                            if HumanoidRootPart.power.powerbar.bar.Size == UDim2.new(1, 0, 1, 0) then
                                VirtualInputManager:SendMouseButtonEvent(0, 0, 0, false, LocalPlayer, 0)
                            end
                        end
                    end)
                end
            end)
        elseif Config.AutoCast.mode == "Rage" then
            tool.events.cast:FireServer(100)
        end
        
        if Config.General.debugMode then
            print("Cast performed at", tick())
        end
    end
    
    -- Main auto cast when tool is equipped
    connections.autoCast = LocalCharacter.ChildAdded:Connect(function(child)
        if child:IsA("Tool") and child:FindFirstChild("events") and child.events:FindFirstChild("cast") and Config.AutoCast.enabled then
            local currentDelay = getDelayForFeature("AutoCast")
            task.wait(currentDelay)
            performCast(child)
        end
    end)
    
    -- Detection for rod reset events (failed cast)
    connections.autoCastReset = spawn(function()
        while Config.AutoCast.enabled do
            local tool = LocalCharacter:FindFirstChildOfClass("Tool")
            if tool and tool:FindFirstChild("events") and tool.events:FindFirstChild("reset") then
                -- Listen for reset event
                local resetConnection
                resetConnection = tool.events.reset.OnClientEvent:Connect(function()
                    if Config.General.debugMode then
                        print("Rod reset detected - likely failed cast")
                    end
                    
                    -- Only retry if we recently casted and no fish was caught
                    if hasCasted and tick() - lastCastTime < 10 and Config.AutoCast.retryFailedCasts then
                        hasCasted = false
                        task.wait(getDelayForFeature("AutoCast") + math.random(1, 3)) -- Extra delay for retry
                        
                        local currentTool = LocalCharacter:FindFirstChildOfClass("Tool")
                        if currentTool and Config.AutoCast.enabled then
                            performCast(currentTool)
                        end
                    end
                    
                    resetConnection:Disconnect()
                end)
            end
            task.wait(1) -- Check every second
        end
    end)
    
    -- Reset cast flag when fish is caught
    connections.autoCastSuccess = ReplicatedStorage:WaitForChild("events").reelfinished.OnClientEvent:Connect(function()
        hasCasted = false
        if Config.General.debugMode then
            print("Fish caught - reset cast flag")
        end
    end)
end

-- Initialize all connections
local function initializeConnections()
    setupAutoShake()
    setupAutoReel()
    setupAutoCast()
end

-- UI Components
-- Mode Selection Section
Tabs.Main:AddSection("🎯 Mode Selection")

local ModeDropdown = Tabs.Main:AddDropdown("ModeSelection", {
    Title = "Safety Mode",
    Description = "Choose your preferred safety vs speed balance",
    Values = {"Safe", "Normal", "Risky", "Rage"},
    Default = Config.General.mode,
    Callback = function(Value)
        Config.General.mode = Value
        applyModePreset(Value)
        
        -- Update all UI elements with new preset values
        local preset = ModePresets[Value]
        if preset then
            Fluent:Notify({
                Title = "Mode Changed",
                Content = "Switched to " .. Value .. " mode: " .. preset.description,
                Duration = 4
            })
        end
    end
})

local RandomizationToggle = Tabs.Main:AddToggle("Randomization", {
    Title = "Delay Randomization",
    Description = "Randomize delays within mode range for more human-like behavior",
    Default = Config.General.randomization,
    Callback = function(Value)
        Config.General.randomization = Value
        print("Delay Randomization:", Value and "Enabled" or "Disabled")
    end
})

local DebugToggle = Tabs.Main:AddToggle("DebugMode", {
    Title = "Debug Mode",
    Description = "Enable to see reel GUI structure in console",
    Default = Config.General.debugMode,
    Callback = function(Value)
        Config.General.debugMode = Value
        print("Debug Mode:", Value and "Enabled" or "Disabled")
        if Value then
            print("Debug mode enabled - reel GUI structure will be printed to console when fishing")
        end
    end
})

-- Auto Shake Section
Tabs.Main:AddSection("Auto Shake")

local AutoShakeToggle = Tabs.Main:AddToggle("AutoShake", {
    Title = "Auto Shake",
    Description = "Automatically clicks the shake button for you",
    Default = Config.AutoShake.enabled,
    Callback = function(Value)
        Config.AutoShake.enabled = Value
        print("Auto Shake:", Value and "Enabled" or "Disabled")
    end
})

local AutoShakeMethod = Tabs.Main:AddDropdown("AutoShakeMethod", {
    Title = "Auto Shake Method",
    Description = "Method to click on the shake button",
    Values = {"ClickEvent", "KeyCodeEvent"},
    Default = Config.AutoShake.method,
    Callback = function(Value)
        Config.AutoShake.method = Value
        print("Auto Shake Method:", Value)
    end
})

local AutoShakeDelay = Tabs.Main:AddSlider("AutoShakeDelay", {
    Title = "Auto Shake Delay",
    Description = "Delay before clicking shake button",
    Default = Config.AutoShake.delay,
    Min = 0,
    Max = 2,
    Rounding = 1,
    Callback = function(Value)
        Config.AutoShake.delay = Value
        print("Auto Shake Delay:", Value)
    end
})

-- Auto Reel Section
Tabs.Main:AddSection("Auto Reel")

local AutoReelToggle = Tabs.Main:AddToggle("AutoReel", {
    Title = "Auto Reel",
    Description = "Automatically reels in the fishing rod",
    Default = Config.AutoReel.enabled,
    Callback = function(Value)
        Config.AutoReel.enabled = Value
        print("Auto Reel:", Value and "Enabled" or "Disabled")
    end
})

local AutoReelMode = Tabs.Main:AddDropdown("AutoReelMode", {
    Title = "Auto Reel Mode",
    Description = "Choose how the auto reel behaves",
    Values = {"Normal", "Perfect", "Instant"},
    Default = Config.AutoReel.mode,
    Callback = function(Value)
        Config.AutoReel.mode = Value
        print("Auto Reel Mode:", Value)
    end
})

local AutoReelDelay = Tabs.Main:AddSlider("AutoReelDelay", {
    Title = "Auto Reel Delay",
    Description = "Delay before reeling in",
    Default = Config.AutoReel.delay,
    Min = 0.1,
    Max = 5,
    Rounding = 1,
    Callback = function(Value)
        Config.AutoReel.delay = Value
        print("Auto Reel Delay:", Value)
    end
})

-- Auto Cast Section
Tabs.Main:AddSection("Auto Cast")

local AutoCastToggle = Tabs.Main:AddToggle("AutoCast", {
    Title = "Auto Cast",
    Description = "Automatically casts the fishing rod",
    Default = Config.AutoCast.enabled,
    Callback = function(Value)
        Config.AutoCast.enabled = Value
        print("Auto Cast:", Value and "Enabled" or "Disabled")
    end
})

local AutoCastMode = Tabs.Main:AddDropdown("AutoCastMode", {
    Title = "Auto Cast Mode",
    Description = "Change the mode of the AutoCast",
    Values = {"Legit", "Rage"},
    Default = Config.AutoCast.mode,
    Callback = function(Value)
        Config.AutoCast.mode = Value
        print("Auto Cast Mode:", Value)
    end
})

local AutoCastDelay = Tabs.Main:AddSlider("AutoCastDelay", {
    Title = "Auto Cast Delay",
    Description = "Delay before auto casting",
    Default = Config.AutoCast.delay,
    Min = 0.1,
    Max = 5,
    Rounding = 1,
    Callback = function(Value)
        Config.AutoCast.delay = Value
        print("Auto Cast Delay:", Value)
    end
})

local AutoCastRetry = Tabs.Main:AddToggle("AutoCastRetry", {
    Title = "Retry Failed Casts",
    Description = "Automatically retry when cast doesn't hit water",
    Default = Config.AutoCast.retryFailedCasts,
    Callback = function(Value)
        Config.AutoCast.retryFailedCasts = Value
        print("Auto Cast Retry:", Value and "Enabled" or "Disabled")
    end
})

-- Settings Tab
Tabs.Settings:AddSection("Information")

Tabs.Settings:AddParagraph({
    Title = "SUPER HUB v1.4",
    Content = "A modular fishing script with multiple safety modes and failed cast retry.\n\n🟢 Safe Mode: Maximum safety, human-like delays\n🟡 Normal Mode: Balanced performance\n🟠 Risky Mode: Faster but riskier\n🔴 Rage Mode: Maximum speed, HIGH RISK!\n\n🎣 Auto Cast Features:\n• Failed cast detection and retry\n• Multiple cast modes (Legit/Rage)\n• Smart timing system\n\n🔧 Debug Mode: Enable to see system activity"
})

Tabs.Settings:AddSection("Current Mode Info")

local function updateModeInfo()
    local preset = ModePresets[Config.General.mode]
    if preset then
        local shakeDelay = preset.AutoShake.delay
        local reelDelay = preset.AutoReel.delay
        local castDelay = preset.AutoCast.delay
        
        return string.format(
            "Mode: %s\n\nShake Delay: %.1f-%.1fs\nReel Delay: %.1f-%.1fs\nCast Delay: %.1f-%.1fs\nShake Method: %s\nReel Mode: %s\nCast Mode: %s",
            Config.General.mode,
            shakeDelay[1], shakeDelay[2],
            reelDelay[1], reelDelay[2], 
            castDelay[1], castDelay[2],
            preset.AutoShake.method,
            preset.AutoReel.mode,
            preset.AutoCast.mode
        )
    end
    return "Mode info not available"
end

Tabs.Settings:AddParagraph({
    Title = "Current Settings",
    Content = updateModeInfo()
})

Tabs.Settings:AddSection("Controls")

Tabs.Settings:AddButton({
    Title = "Apply Current Mode Settings",
    Description = "Reapply the selected mode preset",
    Callback = function()
        applyModePreset(Config.General.mode)
        Fluent:Notify({
            Title = "Settings Applied",
            Content = "Mode preset " .. Config.General.mode .. " reapplied!",
            Duration = 3
        })
    end
})

Tabs.Settings:AddButton({
    Title = "Reinitialize Connections",
    Description = "Restart all auto-fishing connections",
    Callback = function()
        initializeConnections()
        Fluent:Notify({
            Title = "SUPER HUB",
            Content = "All connections reinitialized!",
            Duration = 3
        })
    end
})

-- Character respawn handling
LocalPlayer.CharacterAdded:Connect(function(character)
    LocalCharacter = character
    HumanoidRootPart = character:WaitForChild("HumanoidRootPart")
    
    -- Wait a bit for character to fully load
    task.wait(2)
    initializeConnections()
    
    Fluent:Notify({
        Title = "SUPER HUB",
        Content = "Character respawned - connections restored!",
        Duration = 3
    })
end)

-- Initialize everything
applyModePreset(Config.General.mode) -- Apply default mode
initializeConnections()

-- Welcome notification
Fluent:Notify({
    Title = "SUPER HUB v1.4",
    Content = "Successfully loaded with " .. Config.General.mode .. " mode! Failed cast retry system enabled.",
    Duration = 5
})

-- Cleanup function when script is stopped
local function cleanup()
    for name, connection in pairs(connections) do
        if connection then
            if typeof(connection) == "RBXScriptConnection" and connection.Disconnect then
                connection:Disconnect()
            elseif typeof(connection) == "thread" then
                task.cancel(connection)
            end
        end
    end
    print("SUPER HUB: Cleaned up all connections")
end

-- Setup cleanup on script exit
game:GetService("ScriptContext").Error:Connect(cleanup)
