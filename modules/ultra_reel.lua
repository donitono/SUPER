-- Ultra Simple Reel - Always Click Method
-- Test version for immediate clicking

local UltraReel = {}

-- Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

-- Variables
local player = Players.LocalPlayer
local isReeling = false
local reelConnection = nil

-- Aggressive clicking function
local function aggressiveClick()
    -- Method 1: mouse1click
    if mouse1click then
        mouse1click()
        print("[ULTRA REEL] 🖱️ mouse1click()")
        return true
    end
    
    -- Method 2: mouse1press
    if mouse1press and mouse1release then
        mouse1press()
        task.wait(0.01)
        mouse1release()
        print("[ULTRA REEL] 🖱️ mouse1press/release()")
        return true
    end
    
    -- Method 3: VirtualInputManager
    pcall(function()
        local VIM = game:GetService("VirtualInputManager")
        local mouse = player:GetMouse()
        VIM:SendMouseButtonEvent(mouse.X, mouse.Y, 0, true, game, 0)
        task.wait(0.01)
        VIM:SendMouseButtonEvent(mouse.X, mouse.Y, 0, false, game, 0)
        print("[ULTRA REEL] 🖱️ VirtualInputManager()")
    end)
    
    -- Method 4: KeyCode Space
    pcall(function()
        local VIM = game:GetService("VirtualInputManager")
        VIM:SendKeyEvent(true, Enum.KeyCode.Space, false, game)
        task.wait(0.01)
        VIM:SendKeyEvent(false, Enum.KeyCode.Space, false, game)
        print("[ULTRA REEL] ⌨️ Space key()")
    end)
    
    return true
end

-- Ultra simple start function - just keep clicking
function UltraReel.startAutoReel()
    if isReeling then return end
    isReeling = true
    
    print("[ULTRA REEL] 🎣 Starting AGGRESSIVE clicking mode!")
    print("[ULTRA REEL] ⚠️ This will click continuously - disable when not needed!")
    
    reelConnection = RunService.Heartbeat:Connect(function()
        aggressiveClick()
        task.wait(0.1) -- Click every 0.1 seconds
    end)
end

function UltraReel.stopAutoReel()
    if reelConnection then
        reelConnection:Disconnect()
        reelConnection = nil
    end
    isReeling = false
    print("[ULTRA REEL] 🛑 Aggressive clicking stopped!")
end

function UltraReel.getStatus()
    return {
        enabled = true,
        isReeling = isReeling
    }
end

-- Dummy functions for compatibility
function UltraReel.setSensitivity(value) end
function UltraReel.setHoldThreshold(value) end
function UltraReel.setTapStrength(value) end
function UltraReel.setHoldStrength(value) end

return UltraReel
