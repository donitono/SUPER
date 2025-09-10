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

-- Enhanced detection function
local function isReelActive()
    local playerGui = player:FindFirstChild("PlayerGui")
    if not playerGui then return false end
    
    -- Method 1: Look for "reel" GUI
    local reelGui = playerGui:FindFirstChild("reel")
    if reelGui and reelGui.Visible then
        print("[SIMPLE REEL] 🎯 Found 'reel' GUI")
        return true, reelGui
    end
    
    -- Method 2: Look for any GUI with reel-related text
    for _, gui in pairs(playerGui:GetChildren()) do
        if gui:IsA("ScreenGui") and gui.Visible then
            for _, descendant in pairs(gui:GetDescendants()) do
                if descendant:IsA("TextLabel") and descendant.Visible then
                    local text = descendant.Text:lower()
                    if text:find("click") and text:find("hold") then
                        print("[SIMPLE REEL] 🎯 Found reel text: '" .. descendant.Text .. "' in GUI: " .. gui.Name)
                        return true, gui
                    end
                    if text:find("tap") and text:find("hold") then
                        print("[SIMPLE REEL] 🎯 Found reel text: '" .. descendant.Text .. "' in GUI: " .. gui.Name)
                        return true, gui
                    end
                end
            end
        end
    end
    
    -- Method 3: Look for progress bars or specific UI elements
    for _, gui in pairs(playerGui:GetChildren()) do
        if gui:IsA("ScreenGui") and gui.Visible then
            local playerbar = gui:FindFirstChild("playerbar", true)
            local progress = gui:FindFirstChild("progress", true)
            local fish = gui:FindFirstChild("fish", true)
            
            if playerbar or (progress and fish) then
                print("[SIMPLE REEL] 🎯 Found reel elements in GUI: " .. gui.Name)
                return true, gui
            end
        end
    end
    
    return false, nil
end

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

-- Simple reel automation with enhanced detection
function SimpleReel.startAutoReel()
    if isReeling then return end
    isReeling = true
    
    print("[SIMPLE REEL] 🎣 Auto Reel Started!")
    
    reelConnection = RunService.Heartbeat:Connect(function()
        local success = pcall(function()
            local active, reelGui = isReelActive()
            
            if active and reelGui then
                print("[SIMPLE REEL] 🎯 Reel minigame active - clicking!")
                
                -- Try to click multiple times for reliability
                local clicked = doClick()
                if clicked then
                    print("[SIMPLE REEL] ✅ Click successful!")
                else
                    print("[SIMPLE REEL] ❌ Click failed, trying alternative...")
                    
                    -- Alternative method: Try to find clickable elements
                    for _, descendant in pairs(reelGui:GetDescendants()) do
                        if descendant:IsA("TextButton") or descendant:IsA("Frame") then
                            pcall(function()
                                if descendant.Visible and descendant.Active then
                                    descendant.MouseButton1Click:Fire()
                                    print("[SIMPLE REEL] 🎯 Fired click on: " .. descendant.Name)
                                end
                            end)
                        end
                    end
                end
                
                task.wait(0.05) -- Small delay between clicks
            else
                -- Debug: List all visible GUIs
                local playerGui = player:FindFirstChild("PlayerGui")
                if playerGui then
                    local visibleGuis = {}
                    for _, child in pairs(playerGui:GetChildren()) do
                        if child:IsA("ScreenGui") and child.Visible then
                            table.insert(visibleGuis, child.Name)
                        end
                    end
                    
                    if #visibleGuis > 0 and tick() % 3 < 0.1 then -- Every 3 seconds
                        print("[SIMPLE REEL] 📋 No reel detected. Visible GUIs:", table.concat(visibleGuis, ", "))
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
