-- Autofarm Module
-- Kombinasi fitur dari sanhub, kinghub, dan neoxhub
-- Fixed version with proper syntax

local autofarm = {}

-- Services
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

-- Anti-Detection Settings
local antiDetection = {
    enabled = true,
    humanDelay = {min = 0.05, max = 0.15}, -- Random delays
    reactionTime = {min = 0.1, max = 0.3}, -- Human reaction time
    accuracy = {min = 85, max = 98}, -- Not always perfect
    missChance = 2, -- 2% chance to "miss" like human
}

-- Utility function untuk human-like delays
local function humanDelay(minTime, maxTime)
    if not antiDetection.enabled then
        return wait(0.01)
    end
    
    minTime = minTime or antiDetection.humanDelay.min
    maxTime = maxTime or antiDetection.humanDelay.max
    local delay = minTime + (maxTime - minTime) * math.random()
    wait(delay)
end

-- Random miss function untuk simulate human error
local function shouldMiss()
    if not antiDetection.enabled then
        return false
    end
    return math.random(1, 100) <= antiDetection.missChance
end

-- Variables  
local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")

-- Anti-Detection: Secure Event Handling
local originalFireServer = nil
local originalSendKeyEvent = nil
local originalSendMouseEvent = nil

-- Store original methods untuk restore later
local function storeOriginalMethods()
    if not originalSendKeyEvent then
        originalSendKeyEvent = game:GetService("VirtualInputManager").SendKeyEvent
    end
    if not originalSendMouseEvent then
        originalSendMouseEvent = game:GetService("VirtualInputManager").SendMouseButtonEvent
    end
end

-- Secure input wrapper dengan anti-detection
local function secureKeyEvent(keyCode, isPressed)
    storeOriginalMethods()
    
    -- Random human reaction delay
    humanDelay(antiDetection.reactionTime.min, antiDetection.reactionTime.max)
    
    -- Sometimes miss like human
    if shouldMiss() then
        return -- Simulate miss/delay
    end
    
    -- Execute with original method
    originalSendKeyEvent(game:GetService("VirtualInputManager"), isPressed, keyCode, false, game)
end

local function secureMouseEvent(button, isPressed)
    storeOriginalMethods()
    
    -- Human delay
    humanDelay()
    
    -- Miss chance
    if shouldMiss() then
        return
    end
    
    -- Execute
    originalSendMouseEvent(game:GetService("VirtualInputManager"), 0, 0, button, isPressed, player, 0)
end

-- Autofarm States
autofarm.autoCastEnabled = false
autofarm.autoShakeEnabled = false
autofarm.autoReelEnabled = false
autofarm.alwaysCatchEnabled = false
autofarm.shakeMode = 1 -- 1 = sanhub method, 2 = neoxhub method
autofarm.castMode = 1 -- 1 = legit, 2 = rage, 3 = random
autofarm.reelMode = 1 -- 1 = legit, 2 = instant
autofarm.currentlyHolding = false

-- Auto Cast (dari kinghub dengan metodenya)
function autofarm.startAutoCast(mode)
    autofarm.autoCastEnabled = true
    autofarm.castMode = mode or 1
    
    print("Auto Cast started with mode: " .. autofarm.castMode)
end

function autofarm.stopAutoCast()
    autofarm.autoCastEnabled = false
    print("Auto Cast stopped")
end

-- Auto Shake dengan 2 mode
function autofarm.startAutoShake(mode)
    autofarm.autoShakeEnabled = true
    autofarm.shakeMode = mode or 1
    
    print("Auto Shake started with mode: " .. autofarm.shakeMode)
end

function autofarm.stopAutoShake()
    autofarm.autoShakeEnabled = false
    print("Auto Shake stopped")
end

-- Auto Reel dengan 2 mode  
function autofarm.startAutoReel(mode)
    autofarm.autoReelEnabled = true
    autofarm.reelMode = mode or 1
    
    print("Auto Reel started with mode: " .. autofarm.reelMode)
end

function autofarm.stopAutoReel()
    autofarm.autoReelEnabled = false
    
    -- Release any held mouse button
    if autofarm.currentlyHolding then
        local VirtualInputManager = game:GetService("VirtualInputManager")
        VirtualInputManager:SendMouseButtonEvent(0, 0, 0, false, player, 0)
        autofarm.currentlyHolding = false
    end
    
    print("Auto Reel stopped")
end

-- Always Catch (dari sanhub)
function autofarm.startAlwaysCatch()
    autofarm.alwaysCatchEnabled = true
    print("Always Catch: Enabled")
end

function autofarm.stopAlwaysCatch()
    autofarm.alwaysCatchEnabled = false
    print("Always Catch: Disabled")
end

-- Utility Functions
function autofarm.setShakeMode(mode)
    if mode == 1 or mode == 2 then
        autofarm.shakeMode = mode
        return true
    else
        warn("Invalid shake mode. Use 1 (sanhub) or 2 (neoxhub)")
        return false
    end
end

function autofarm.setCastMode(mode)
    if mode == 1 or mode == 2 or mode == 3 then
        autofarm.castMode = mode
        return true
    else
        warn("Invalid cast mode. Use 1 (legit), 2 (rage), or 3 (random)")
        return false
    end
end

function autofarm.getStatus()
    return {
        autoCast = autofarm.autoCastEnabled,
        autoShake = autofarm.autoShakeEnabled,
        autoReel = autofarm.autoReelEnabled,
        alwaysCatch = autofarm.alwaysCatchEnabled,
        shakeMode = autofarm.shakeMode,
        castMode = autofarm.castMode,
        reelMode = autofarm.reelMode
    }
end

-- Start all autofarm features
function autofarm.startAll(shakeMode, castMode, reelMode)
    shakeMode = shakeMode or 1
    castMode = castMode or 1
    reelMode = reelMode or 1
    autofarm.startAutoCast(castMode)
    autofarm.startAutoShake(shakeMode)
    autofarm.startAutoReel(reelMode)
    autofarm.startAlwaysCatch()
    print("All Autofarm Started: Cast=" .. castMode .. ", Shake=" .. shakeMode .. ", Reel=" .. reelMode)
end

-- Stop all autofarm features
function autofarm.stopAll()
    autofarm.stopAutoCast()
    autofarm.stopAutoShake()
    autofarm.stopAutoReel()
    autofarm.stopAlwaysCatch()
end

return autofarm
