-- Autofarm Module
-- Kombinasi fitur dari sanhub, kinghub, dan neoxhub

local autofarm = {}

-- Services
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

-- Variables
local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")

-- Autofarm States
autofarm.autoCastEnabled = false
autofarm.autoShakeEnabled = false
autofarm.autoReelEnabled = false
autofarm.alwaysCatchEnabled = false
autofarm.shakeMode = 1 -- 1 = sanhub method, 2 = neoxhub method
autofarm.castMode = 1 -- 1 = legit, 2 = rage, 3 = random

-- Auto Cast (dari kinghub dengan metodenya)
function autofarm.startAutoCast(mode)
    autofarm.autoCastEnabled = true
    autofarm.castMode = mode or 1
    
    -- Hook untuk tool equipped
    local function onCharacterChildAdded(child)
        if not autofarm.autoCastEnabled then return end
        
        if child:IsA("Tool") and child:FindFirstChild("events") then
            local castEvent = child.events:FindFirstChild("cast")
            if castEvent then
                task.wait(2) -- Delay sebelum cast
                
                local success, err = pcall(function()
                    if autofarm.castMode == 1 then
                        -- Mode 1: Legit - simulate mouse click dan tunggu full power
                        local VirtualInputManager = game:GetService("VirtualInputManager")
                        VirtualInputManager:SendMouseButtonEvent(0, 0, 0, true, player, 0)
                        
                        -- Monitor power bar untuk release saat FULL (seperti kinghub)
                        local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
                        if humanoidRootPart then
                            local powerConnection
                            powerConnection = humanoidRootPart.ChildAdded:Connect(function(powerChild)
                                if powerChild.Name == "power" then
                                    local powerbar = powerChild:FindFirstChild("powerbar")
                                    if powerbar and powerbar:FindFirstChild("bar") then
                                        local barConnection
                                        barConnection = powerbar.bar:GetPropertyChangedSignal("Size"):Connect(function()
                                            -- Release saat mencapai FULL power (100%) seperti kinghub
                                            if powerbar.bar.Size == UDim2.new(1, 0, 1, 0) then
                                                VirtualInputManager:SendMouseButtonEvent(0, 0, 0, false, player, 0)
                                                barConnection:Disconnect()
                                                powerConnection:Disconnect()
                                            end
                                        end)
                                    end
                                end
                            end)
                        end
                        
                    elseif autofarm.castMode == 2 then
                        -- Mode 2: Rage - direct FireServer
                        castEvent:FireServer(100)
                        
                    elseif autofarm.castMode == 3 then
                        -- Mode 3: Random - legit with random timing (85-100%)
                        local VirtualInputManager = game:GetService("VirtualInputManager")
                        VirtualInputManager:SendMouseButtonEvent(0, 0, 0, true, player, 0)
                        
                        local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
                        if humanoidRootPart then
                            local powerConnection
                            powerConnection = humanoidRootPart.ChildAdded:Connect(function(powerChild)
                                if powerChild.Name == "power" then
                                    local powerbar = powerChild:FindFirstChild("powerbar")
                                    if powerbar and powerbar:FindFirstChild("bar") then
                                        local barConnection
                                        -- Random target antara 85-100% untuk variasi
                                        local randomTarget = math.random(85, 100) / 100
                                        barConnection = powerbar.bar:GetPropertyChangedSignal("Size"):Connect(function()
                                            if powerbar.bar.Size.X.Scale >= randomTarget then
                                                VirtualInputManager:SendMouseButtonEvent(0, 0, 0, false, player, 0)
                                                barConnection:Disconnect()
                                                powerConnection:Disconnect()
                                            end
                                        end)
                                    end
                                end
                            end)
                        end
                    end
                end)
                
                if not success then
                    warn("Auto Cast Error: " .. tostring(err))
                end
            end
        end
    end
    
    -- Hook untuk reel finished (auto recast)
    local function onGuiRemoved(gui)
        if not autofarm.autoCastEnabled then return end
        
        if gui.Name == "reel" then
            local tool = character:FindFirstChildOfClass("Tool")
            if tool and tool:FindFirstChild("events") then
                local castEvent = tool.events:FindFirstChild("cast")
                if castEvent then
                    task.wait(2) -- Delay sebelum recast
                    
                    local success, err = pcall(function()
                        if autofarm.castMode == 1 then
                            -- Legit mode recast - tunggu full power seperti kinghub
                            local VirtualInputManager = game:GetService("VirtualInputManager")
                            VirtualInputManager:SendMouseButtonEvent(0, 0, 0, true, player, 0)
                            
                            local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
                            if humanoidRootPart then
                                local powerConnection
                                powerConnection = humanoidRootPart.ChildAdded:Connect(function(powerChild)
                                    if powerChild.Name == "power" then
                                        local powerbar = powerChild:FindFirstChild("powerbar")
                                        if powerbar and powerbar:FindFirstChild("bar") then
                                            local barConnection
                                            barConnection = powerbar.bar:GetPropertyChangedSignal("Size"):Connect(function()
                                                -- Release saat mencapai FULL power (100%) seperti kinghub
                                                if powerbar.bar.Size == UDim2.new(1, 0, 1, 0) then
                                                    VirtualInputManager:SendMouseButtonEvent(0, 0, 0, false, player, 0)
                                                    barConnection:Disconnect()
                                                    powerConnection:Disconnect()
                                                end
                                            end)
                                        end
                                    end
                                end)
                            end
                            
                        elseif autofarm.castMode == 2 then
                            -- Rage mode recast
                            castEvent:FireServer(100)
                            
                        elseif autofarm.castMode == 3 then
                            -- Random mode recast - random target 85-100%
                            local VirtualInputManager = game:GetService("VirtualInputManager")
                            VirtualInputManager:SendMouseButtonEvent(0, 0, 0, true, player, 0)
                            
                            local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
                            if humanoidRootPart then
                                local powerConnection
                                powerConnection = humanoidRootPart.ChildAdded:Connect(function(powerChild)
                                    if powerChild.Name == "power" then
                                        local powerbar = powerChild:FindFirstChild("powerbar")
                                        if powerbar and powerbar:FindFirstChild("bar") then
                                            local barConnection
                                            -- Random target antara 85-100% untuk variasi
                                            local randomTarget = math.random(85, 100) / 100
                                            barConnection = powerbar.bar:GetPropertyChangedSignal("Size"):Connect(function()
                                                if powerbar.bar.Size.X.Scale >= randomTarget then
                                                    VirtualInputManager:SendMouseButtonEvent(0, 0, 0, false, player, 0)
                                                    barConnection:Disconnect()
                                                    powerConnection:Disconnect()
                                                end
                                            end)
                                        end
                                    end
                                end)
                            end
                        end
                    end)
                    
                    if not success then
                        warn("Auto Cast Recast Error: " .. tostring(err))
                    end
                end
            end
        end
    end
    
    -- Connect events
    autofarm.castConnection1 = character.ChildAdded:Connect(onCharacterChildAdded)
    autofarm.castConnection2 = player.PlayerGui.ChildRemoved:Connect(onGuiRemoved)
    
    print("Auto Cast started with mode: " .. autofarm.castMode)
end

function autofarm.stopAutoCast()
    autofarm.autoCastEnabled = false
    
    -- Disconnect connections
    if autofarm.castConnection1 then
        autofarm.castConnection1:Disconnect()
        autofarm.castConnection1 = nil
    end
    if autofarm.castConnection2 then
        autofarm.castConnection2:Disconnect()
        autofarm.castConnection2 = nil
    end
    
    print("Auto Cast stopped")
end

-- Auto Shake dengan 2 mode
function autofarm.startAutoShake(mode)
    autofarm.autoShakeEnabled = true
    autofarm.shakeMode = mode or 1
    
    if autofarm.shakeMode == 1 then
        -- Mode 1: Method dari sanhub - RenderStepped checking
        local function handleShakeSanHub()
            if not autofarm.autoShakeEnabled then return end
            
            local success, err = pcall(function()
                local playerGui = player:WaitForChild("PlayerGui")
                local shakeUI = playerGui:FindFirstChild("shakeui")
                
                if shakeUI then
                    local safezone = shakeUI:FindFirstChild("safezone")
                    if safezone then
                        local button = safezone:FindFirstChild("button")
                        if button then
                            -- Set selected object dan send return key
                            game:GetService("GuiService").SelectedObject = button
                            if game:GetService("GuiService").SelectedObject == button then
                                local VirtualInputManager = game:GetService("VirtualInputManager")
                                VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.Return, false, game)
                                VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.Return, false, game)
                                print("Shake performed (SanHub method)")
                            end
                        end
                    end
                end
            end)
            
            if not success then
                warn("Auto Shake SanHub Error: " .. tostring(err))
            end
        end
        
        -- Connect to RenderStepped untuk continuous checking
        autofarm.shakeConnection = RunService.RenderStepped:Connect(handleShakeSanHub)
        
    elseif autofarm.shakeMode == 2 then
        -- Mode 2: Method dari neoxhub - DescendantAdded detection
        local function handleShakeNeoxHub(descendant)
            if not autofarm.autoShakeEnabled then return end
            
            local success, err = pcall(function()
                -- Detect shake button seperti neoxhub
                if descendant.Name == "button" and descendant.Parent and descendant.Parent.Name == "safezone" then
                    task.wait(0.3) -- Delay seperti di neoxhub
                    
                    -- Set selected object
                    game:GetService("GuiService").SelectedObject = descendant
                    
                    -- Send return key
                    local VirtualInputManager = game:GetService("VirtualInputManager")
                    VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.Return, false, game)
                    VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.Return, false, game)
                    
                    task.wait(0.1) -- Small delay
                    game:GetService("GuiService").SelectedObject = nil
                    
                    print("Shake performed (NeoxHub method)")
                end
            end)
            
            if not success then
                warn("Auto Shake NeoxHub Error: " .. tostring(err))
            end
        end
        
        -- Connect to DescendantAdded seperti neoxhub
        autofarm.shakeConnection = player.PlayerGui.DescendantAdded:Connect(handleShakeNeoxHub)
    end
    
    print("Auto Shake started with mode: " .. autofarm.shakeMode)
end

function autofarm.stopAutoShake()
    autofarm.autoShakeEnabled = false
    
    -- Disconnect shake connection
    if autofarm.shakeConnection then
        autofarm.shakeConnection:Disconnect()
        autofarm.shakeConnection = nil
    end
    
    print("Auto Shake stopped")
end

-- Auto Reel States
autofarm.autoReelEnabled = false
autofarm.reelMode = 1 -- 1 = legit (follow fish), 2 = instant (perfect)

-- Auto Reel stop function
function autofarm.stopAutoReel()
    autofarm.autoReelEnabled = false
    print("Auto Reel stopped")
end

-- Auto Reel dengan 2 mode  
function autofarm.startAutoReel(mode)
    autofarm.autoReelEnabled = true
    autofarm.reelMode = mode or 1
    
    spawn(function()
        while autofarm.autoReelEnabled do
            local success, err = pcall(function()
                local playerGui = player:WaitForChild("PlayerGui")
                local reel = playerGui:FindFirstChild("reel")
                
                -- Debug: Print all children of PlayerGui untuk identify UI elements
                if not reel then
                    print("DEBUG: Reel UI not found, searching for alternatives...")
                    for _, child in pairs(playerGui:GetChildren()) do
                        if child:IsA("ScreenGui") or child:IsA("Frame") then
                            print("DEBUG: Found GUI element: " .. child.Name)
                            if child.Name:lower():find("reel") or child.Name:lower():find("fish") or child.Name:lower():find("mini") then
                                reel = child
                                print("DEBUG: Using alternative reel UI: " .. child.Name)
                                break
                            end
                        end
                    end
                end
                
                if reel and reel.Visible then
                    if autofarm.reelMode == 1 then
                        -- Mode 1: Legit - Follow fish line dengan mouse hold/release simulation
                        local fish = reel:FindFirstChild("fish")
                        local playerbar = reel:FindFirstChild("playerbar") 
                        local bar = reel:FindFirstChild("bar") -- Progress bar
                        
                        -- Fallback detection untuk UI elements yang berbeda
                        if not fish then fish = reel:FindFirstChild("Fish") end
                        if not fish then fish = reel:FindFirstChild("fishline") end
                        if not playerbar then playerbar = reel:FindFirstChild("PlayerBar") end
                        if not playerbar then playerbar = reel:FindFirstChild("player") end
                        if not bar then bar = reel:FindFirstChild("progressbar") end
                        if not bar then bar = reel:FindFirstChild("progress") end
                        
                        if fish and playerbar then
                            -- Get fish position (garis hitam)
                            local fishX = fish.Position.X.Scale
                            local fishY = fish.Position.Y.Scale
                            
                            -- Get current playerbar position dan size
                            local currentPlayerX = playerbar.Position.X.Scale
                            local playerBarSize = playerbar.Size.X.Scale -- Deteksi panjang bar putih
                            
                            -- Calculate if fish is in the center zone of player bar
                            local playerBarCenter = currentPlayerX + (playerBarSize / 2)
                            local centerDistance = math.abs(fishX - playerBarCenter)
                            local tolerance = playerBarSize * 0.4 -- 40% tolerance dari center
                            
                            -- Check fish position relative to player bar
                            local fishInLeftSide = fishX < (currentPlayerX + playerBarSize * 0.3)
                            local fishInRightSide = fishX > (currentPlayerX + playerBarSize * 0.7)
                            local fishInCenter = not fishInLeftSide and not fishInRightSide
                            
                            -- Determine if we should hold mouse or release
                            local shouldHold = false
                            
                            if fishInCenter then
                                -- Fish di tengah - tahan mouse untuk maintain position
                                shouldHold = true
                            elseif fishInLeftSide then
                                -- Fish di kiri - release mouse untuk bergerak kiri
                                shouldHold = false
                            elseif fishInRightSide then
                                -- Fish di kanan - tahan mouse untuk bergerak kanan
                                shouldHold = true
                            end
                            
                            -- Implement mouse hold/release based on fish position
                            local VirtualInputManager = game:GetService("VirtualInputManager")
                            
                            if shouldHold then
                                -- Hold mouse untuk control reel
                                VirtualInputManager:SendMouseButtonEvent(0, 0, 0, true, player, 0)
                            else
                                -- Release mouse untuk let reel move naturally
                                VirtualInputManager:SendMouseButtonEvent(0, 0, 0, false, player, 0)
                            end
                            
                            -- Enhanced debug info
                            local debugInfo = string.format(
                                "Fish=%.0f%%, Player=%.0f%%, Size=%.0f%%, Center=%.0f%%, Hold=%s, Zone=%s",
                                fishX*100, currentPlayerX*100, playerBarSize*100, playerBarCenter*100, 
                                tostring(shouldHold), 
                                fishInCenter and "CENTER" or (fishInLeftSide and "LEFT" or "RIGHT")
                            )
                            print("Auto Reel Legit: " .. debugInfo)
                        else
                            -- Fallback: Jika tidak bisa detect fish/playerbar, gunakan general mouse hold
                            local VirtualInputManager = game:GetService("VirtualInputManager")
                            VirtualInputManager:SendMouseButtonEvent(0, 0, 0, true, player, 0)
                            wait(0.1)
                            VirtualInputManager:SendMouseButtonEvent(0, 0, 0, false, player, 0)
                            print("Auto Reel Legit: Fallback mode - no fish/playerbar detected")
                        end
                        end
                        
                    elseif autofarm.reelMode == 2 then
                        -- Mode 2: Instant - Perfect reel (seperti implementasi lama)
                        local bar = reel:FindFirstChild("bar")
                        if bar and bar.Visible then
                            -- Auto reel ketika bar muncul
                            local reelEvent = ReplicatedStorage:FindFirstChild("events")
                            if reelEvent then
                                local reelAction = reelEvent:FindFirstChild("reelfinished")
                                if reelAction then
                                    reelAction:FireServer(100, true) -- Perfect reel
                                    print("Auto Reel Instant: Perfect reel applied!")
                                end
                            end
                            
                            -- Alternative method - simulate space key press
                            UserInputService:SendKeyEvent(true, Enum.KeyCode.Space, false, game)
                            wait(0.05)
                            UserInputService:SendKeyEvent(false, Enum.KeyCode.Space, false, game)
                        end
                    end
                end
                
                -- Backup method - check for reel prompt
                local reelPrompt = playerGui:FindFirstChild("ReelPrompt")
                if reelPrompt and reelPrompt.Visible then
                    local reelEvent = ReplicatedStorage:FindFirstChild("events")
                    if reelEvent then
                        local reel = reelEvent:FindFirstChild("reel")
                        if reel then
                            reel:FireServer()
                        end
                    end
                end
            end)
            
            if not success then
                warn("Auto Reel Error: " .. tostring(err))
            end
            
            -- Adaptive delay berdasarkan mode dan rod characteristics
            if autofarm.reelMode == 1 then
                -- Mode Legit: Sangat cepat untuk responsive fish following
                wait(0.01) -- 100 FPS untuk smooth tracking
            else
                -- Mode Instant: Normal delay
                wait(0.1) -- 10 FPS untuk instant mode
            end
        end
    end)
end

-- Always Catch (dari sanhub)
function autofarm.startAlwaysCatch()
    autofarm.alwaysCatchEnabled = true
    
    spawn(function()
        -- Hook reelfinished event untuk always catch
        local replicatedStorage = ReplicatedStorage
        local events = replicatedStorage:WaitForChild("events")
        local reelfinished = events:WaitForChild("reelfinished")
        
        -- Store original FireServer method
        local originalFireServer = reelfinished.FireServer
        
        -- Override FireServer method
        reelfinished.FireServer = function(self, ...)
            local args = {...}
            if autofarm.alwaysCatchEnabled then
                -- Always catch dengan perfect score
                args[1] = 100  -- Perfect score
                args[2] = true -- Success flag
                print("Always Catch: Perfect catch applied!")
            end
            return originalFireServer(self, unpack(args))
        end
        
        print("Always Catch: Hook installed successfully!")
    end)
end

function autofarm.stopAlwaysCatch()
    autofarm.alwaysCatchEnabled = false
    
    -- Restore original FireServer method
    spawn(function()
        local replicatedStorage = ReplicatedStorage
        local events = replicatedStorage:FindFirstChild("events")
        if events then
            local reelfinished = events:FindFirstChild("reelfinished")
            if reelfinished then
                -- Note: Dalam implementasi nyata, kita perlu store original method
                -- Untuk sekarang, kita hanya disable flag
                print("Always Catch: Disabled")
            end
        end
    end)
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

-- Error handling dan reconnection
-- Error handling dan reconnection
local function handleCharacterRespawn()
    player.CharacterAdded:Connect(function(newCharacter)
        character = newCharacter
        humanoid = character:WaitForChild("Humanoid")
        
        -- Restart autofarm jika sedang aktif
        local status = autofarm.getStatus()
        if status.autoCast or status.autoShake or status.autoReel or status.alwaysCatch then
            wait(2) -- Wait for character to load
            if status.autoCast then autofarm.startAutoCast(status.castMode) end
            if status.autoShake then autofarm.startAutoShake(status.shakeMode) end
            if status.autoReel then autofarm.startAutoReel(status.reelMode) end
            if status.alwaysCatch then autofarm.startAlwaysCatch() end
        end
    end)
end

-- Initialize
handleCharacterRespawn()

return autofarm
