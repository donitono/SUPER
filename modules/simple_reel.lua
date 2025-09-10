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

-- Simple click function with multiple methods
local function doClick()
    local success = false
    
    -- Method 1: mouse1click (most common)
    pcall(function()
        if mouse1click then
            mouse1click()
            success = true
            print("[SIMPLE REEL] 🖱️ Click (mouse1click)")
        end
    end)
    
    -- Method 2: mouse1press/release
    if not success then
        pcall(function()
            if mouse1press and mouse1release then
                mouse1press()
                task.wait(0.05)
                mouse1release()
                success = true
                print("[SIMPLE REEL] 🖱️ Click (mouse1press)")
            end
        end)
    end
    
    -- Method 3: VirtualInputManager
    if not success then
        pcall(function()
            local VirtualInputManager = game:GetService("VirtualInputManager")
            local mouse = player:GetMouse()
            if VirtualInputManager and mouse then
                VirtualInputManager:SendMouseButtonEvent(mouse.X, mouse.Y, 0, true, game, 0)
                task.wait(0.01)
                VirtualInputManager:SendMouseButtonEvent(mouse.X, mouse.Y, 0, false, game, 0)
                success = true
                print("[SIMPLE REEL] 🖱️ Click (VirtualInput)")
            end
        end)
    end
    
    -- Method 4: Key simulation (Space bar)
    if not success then
        pcall(function()
            local UserInputService = game:GetService("UserInputService")
            UserInputService:GetPropertyChangedSignal("InputBegan"):Connect(function() end)
            game:GetService("VirtualInputManager"):SendKeyEvent(true, Enum.KeyCode.Space, false, game)
            task.wait(0.01)
            game:GetService("VirtualInputManager"):SendKeyEvent(false, Enum.KeyCode.Space, false, game)
            success = true
            print("[SIMPLE REEL] ⌨️ Click (Space key)")
        end)
    end
    
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
                if reelGui and reelGui.Visible then
                    print("[SIMPLE REEL] 🎯 Reel GUI detected - attempting click...")
                    
                    -- Try to click multiple times for reliability
                    local clicked = doClick()
                    if clicked then
                        print("[SIMPLE REEL] ✅ Click successful!")
                    else
                        print("[SIMPLE REEL] ❌ Click failed, trying alternative...")
                        -- Alternative: try to interact with reel elements directly
                        for _, child in pairs(reelGui:GetChildren()) do
                            if child:IsA("Frame") or child:IsA("TextButton") then
                                pcall(function()
                                    if child.Visible then
                                        local conn
                                        conn = child.MouseButton1Click:Connect(function()
                                            conn:Disconnect()
                                        end)
                                        child.MouseButton1Click:Fire()
                                    end
                                end)
                            end
                        end
                    end
                    
                    task.wait(0.1) -- Wait between clicks
                else
                    -- Debug: show what GUIs are available
                    local guis = {}
                    for _, child in pairs(playerGui:GetChildren()) do
                        if child:IsA("ScreenGui") then
                            table.insert(guis, child.Name)
                        end
                    end
                    if #guis > 0 then
                        print("[SIMPLE REEL] 📋 Available GUIs:", table.concat(guis, ", "))
                    end
                end
            end
        end)
        
        if not success then
            print("[SIMPLE REEL] ❌ Error in main loop")
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
