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

-- Enhanced clicking function using same method as auto shake
local function aggressiveClick()
    local success = false
    
    -- Method 1: GuiService + Return key (proven to work for shake)
    pcall(function()
        local playerGui = player:FindFirstChild("PlayerGui")
        if playerGui then
            -- Look for any clickable UI element
            for _, gui in pairs(playerGui:GetChildren()) do
                if gui:IsA("ScreenGui") and gui.Visible then
                    for _, descendant in pairs(gui:GetDescendants()) do
                        if descendant:IsA("TextButton") or descendant:IsA("Frame") then
                            if descendant.Visible and descendant.Active then
                                game:GetService("GuiService").SelectedObject = descendant
                                local VirtualInputManager = game:GetService("VirtualInputManager")
                                VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.Return, false, game)
                                VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.Return, false, game)
                                success = true
                                print("[ULTRA REEL] ✅ GuiService + Return key")
                                return
                            end
                        end
                    end
                end
            end
        end
    end)
    
    -- Method 2: Tool events (like auto shake backup)
    if not success then
        pcall(function()
            local character = player.Character
            if character then
                local tool = character:FindFirstChildOfClass("Tool")
                if tool and tool:FindFirstChild("events") then
                    for _, event in pairs(tool.events:GetChildren()) do
                        if event:IsA("RemoteEvent") then
                            event:FireServer()
                            success = true
                            print("[ULTRA REEL] ✅ Tool event: " .. event.Name)
                            break
                        end
                    end
                end
            end
        end)
    end
    
    -- Method 3: Return key globally
    if not success then
        pcall(function()
            local VirtualInputManager = game:GetService("VirtualInputManager")
            VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.Return, false, game)
            VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.Return, false, game)
            success = true
            print("[ULTRA REEL] ✅ Return key")
        end)
    end
    
    -- Method 4: Space key
    if not success then
        pcall(function()
            local VirtualInputManager = game:GetService("VirtualInputManager")
            VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.Space, false, game)
            VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.Space, false, game)
            success = true
            print("[ULTRA REEL] ✅ Space key")
        end)
    end
    
    return success
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
