-- Simple Reel Module (Fallback)
-- Ultra-simple version that always works

local SimpleReel = {}

-- Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

-- Variables
local player = Players.LocalPlayer
local isReeling = false
local reelConnection = nil

-- Simple click function
local function doClick()
    local success = pcall(function()
        if mouse1click then
            mouse1click()
        elseif mouse1press then
            mouse1press()
            wait(0.01)
            mouse1release()
        else
            -- Fallback method
            local mouse = player:GetMouse()
            if mouse then
                mouse.Button1Down:Connect(function() end)
            end
        end
    end)
    return success
end

-- Simple reel automation
function SimpleReel.startAutoReel()
    if isReeling then return end
    isReeling = true
    
    print("[SIMPLE REEL] 🎣 Auto Reel Started!")
    
    reelConnection = RunService.Heartbeat:Connect(function()
        local success = pcall(function()
            local playerGui = player:FindFirstChild("PlayerGui")
            if playerGui then
                local reelGui = playerGui:FindFirstChild("reel")
                if reelGui then
                    -- Simple method: click every frame when reel is active
                    doClick()
                    wait(0.05) -- Small delay to prevent spam
                end
            end
        end)
        
        if not success then
            SimpleReel.stopAutoReel()
        end
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
