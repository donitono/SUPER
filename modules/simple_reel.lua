-- Simple Reel Module (Fallback)
-- Versi sederhana untuk mencegah error

local SimpleReel = {}

-- Services
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

-- Variables
local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local isReeling = false
local reelConnection = nil

-- Simple reel automation
function SimpleReel.startAutoReel()
    if isReeling then return end
    isReeling = true
    
    print("[SIMPLE REEL] 🎣 Auto Reel Started!")
    
    reelConnection = RunService.Heartbeat:Connect(function()
        pcall(function()
            local reelGui = playerGui:FindFirstChild("reel")
            if reelGui then
                -- Simple method: continuous clicking
                local mouse = player:GetMouse()
                if mouse then
                    -- Simulate click
                    mouse1click()
                end
            else
                -- Stop if no reel GUI
                SimpleReel.stopAutoReel()
            end
        end)
    end)
end

function SimpleReel.stopAutoReel()
    if reelConnection then
        reelConnection:Disconnect()
        reelConnection = nil
    end
    isReeling = false
    print("[SIMPLE REEL] 🛑 Auto Reel Stopped!")
end

function SimpleReel.getStatus()
    return {
        enabled = true,
        isReeling = isReeling
    }
end

-- Dummy functions untuk compatibility
function SimpleReel.setSensitivity(value) end
function SimpleReel.setHoldThreshold(value) end
function SimpleReel.setTapStrength(value) end
function SimpleReel.setHoldStrength(value) end

return SimpleReel
