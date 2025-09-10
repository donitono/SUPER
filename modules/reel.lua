-- Reel Minigame Automation Module
-- Simple and reliable version

local Reel = {}

-- Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

-- Variables
local player = Players.LocalPlayer
local isReeling = false
local reelConnection = nil

-- Settings
local Settings = {
    enabled = false,
    sensitivity = 0.5,
    holdThreshold = 0.3,
    tapStrength = 0.5,
    holdStrength = 0.8,
    reactionTime = 0.05
}
}

-- Simple function to get reel GUI
local function getReelGui()
    local playerGui = player:FindFirstChild("PlayerGui")
    if playerGui then
        return playerGui:FindFirstChild("reel")
    end
    return nil
end

-- Simple input simulation with multiple fallbacks
local function simulateClick()
    local success = false
    
    print("[REEL] 🎯 Attempting to click...")
    
    -- Method 1: mouse1click
    if not success then
        pcall(function()
            if mouse1click then
                mouse1click()
                success = true
                print("[REEL] ✅ Click successful (mouse1click)")
            end
        end)
    end
    
    -- Method 2: mouse1press/release
    if not success then
        pcall(function()
            if mouse1press and mouse1release then
                mouse1press()
                task.wait(0.02)
                mouse1release()
                success = true
                print("[REEL] ✅ Click successful (mouse1press)")
            end
        end)
    end
    
    -- Method 3: Space key
    if not success then
        pcall(function()
            local VirtualInputManager = game:GetService("VirtualInputManager")
            VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.Space, false, game)
            task.wait(0.01)
            VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.Space, false, game)
            success = true
            print("[REEL] ✅ Click successful (Space key)")
        end)
    end
    
    return success
end

-- Main reel control function
local function controlReel()
    local reelGui = getReelGui()
    if not reelGui then 
        print("[REEL] ❌ No reel GUI found")
        return 
    end
    
    print("[REEL] 🎯 Reel GUI found - controlling...")
    
    -- Simple continuous clicking method
    local clicked = simulateClick()
    if not clicked then
        print("[REEL] ❌ All click methods failed")
    end
    
    task.wait(0.05)
end
-- Start auto reel function
function Reel.startAutoReel()
    if isReeling then return end
    isReeling = true
    Settings.enabled = true
    
    print("[REEL] 🎣 Auto Reel Started! Monitoring for reel minigame...")
    
    reelConnection = RunService.Heartbeat:Connect(function()
        if not Settings.enabled then return end
        
        local success = pcall(function()
            local reelGui = getReelGui()
            if reelGui then
                print("[REEL] 🎯 Reel minigame detected!")
                controlReel()
            else
                -- Debug: show available GUIs every 5 seconds
                if tick() % 5 < 0.1 then
                    local playerGui = player:FindFirstChild("PlayerGui")
                    if playerGui then
                        local guis = {}
                        for _, child in pairs(playerGui:GetChildren()) do
                            if child:IsA("ScreenGui") then
                                table.insert(guis, child.Name)
                            end
                        end
                        print("[REEL] 📋 Waiting for reel... Available GUIs:", table.concat(guis, ", "))
                    end
                end
            end
        end)
        
        if not success then
            print("[REEL] ❌ Error in main loop")
            Reel.stopAutoReel()
        end
    end)
end

-- Stop auto reel function
function Reel.stopAutoReel()
    if reelConnection then
        reelConnection:Disconnect()
        reelConnection = nil
    end
    
    isReeling = false
    Settings.enabled = false
    print("[REEL] 🛑 Auto Reel Stopped!")
end

-- Settings functions
function Reel.setSensitivity(value)
    Settings.sensitivity = math.clamp(value or 0.5, 0.1, 1.0)
end

function Reel.setHoldThreshold(value)
    Settings.holdThreshold = math.clamp(value or 0.3, 0.1, 0.8)
end

function Reel.setTapStrength(value)
    Settings.tapStrength = math.clamp(value or 0.5, 0.1, 1.0)
end

function Reel.setHoldStrength(value)
    Settings.holdStrength = math.clamp(value or 0.8, 0.1, 1.0)
end

-- Get status function
function Reel.getStatus()
    return {
        enabled = Settings.enabled,
        isReeling = isReeling,
        sensitivity = Settings.sensitivity,
        holdThreshold = Settings.holdThreshold,
        tapStrength = Settings.tapStrength,
        holdStrength = Settings.holdStrength
    }
end

return Reel
