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

-- Simple input simulation
local function simulateClick()
    local success = pcall(function()
        if mouse1click then
            mouse1click()
        elseif mouse1press then
            mouse1press()
            wait(0.01)
            mouse1release()
        end
    end)
    return success
end

-- Main reel control function
local function controlReel()
    local reelGui = getReelGui()
    if not reelGui then return end
    
    -- Simple continuous clicking method
    simulateClick()
    wait(0.1)
end
-- Start auto reel function
function Reel.startAutoReel()
    if isReeling then return end
    isReeling = true
    Settings.enabled = true
    
    print("[REEL] 🎣 Auto Reel Started!")
    
    reelConnection = RunService.Heartbeat:Connect(function()
        if not Settings.enabled then return end
        
        local success = pcall(controlReel)
        if not success then
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
