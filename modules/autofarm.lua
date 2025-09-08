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
autofarm.currentlyHolding = false -- Track current hold state

-- Auto Reel stop function
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

-- Auto Reel dengan 2 mode  
function autofarm.startAutoReel(mode)
    autofarm.autoReelEnabled = true
    autofarm.reelMode = mode or 1
    
    spawn(function()
        while autofarm.autoReelEnabled do
            local success, err = pcall(function()
                local playerGui = player:WaitForChild("PlayerGui")
                local reel = playerGui:FindFirstChild("reel")
                
                if reel and reel.Visible then
                    if autofarm.reelMode == 1 then
                        -- Mode 1: Legit - Hold/Release system untuk control bar putih
                        local fish = reel:FindFirstChild("fish")
                        local playerbar = reel:FindFirstChild("playerbar") 
                        local bar = reel:FindFirstChild("bar") -- Progress bar
                        
                        if fish and playerbar and bar then
                            -- Get fish position (garis hitam vertikal)
                            local fishX = fish.Position.X.Scale
                            
                            -- Get current playerbar position dan size
                            local currentPlayerX = playerbar.Position.X.Scale
                            local playerBarSize = playerbar.Size.X.Scale
                            
                            -- Calculate bar boundaries (zona bar putih)
                            local barLeft = currentPlayerX
                            local barRight = currentPlayerX + playerBarSize
                            local barCenter = currentPlayerX + (playerBarSize / 2)
                            
                            -- Check apakah garis hitam dalam zona bar putih
                            local fishInBar = fishX >= barLeft and fishX <= barRight
                            
                            -- Decision logic untuk hold/release dengan tolerance
                            local shouldHold = false
                            local tolerance = playerBarSize * 0.1 -- 10% tolerance untuk stability
                            
                            if fishInBar then
                                -- Jika fish sudah di dalam bar, maintain dengan toleransi
                                -- Hold jika fish lebih ke kanan dari center+tolerance
                                if fishX > (barCenter + tolerance) then
                                    shouldHold = true -- Hold untuk maintain fish di kanan
                                elseif fishX < (barCenter - tolerance) then
                                    shouldHold = false -- Release untuk maintain fish di kiri
                                else
                                    -- Dalam tolerance zone, maintain current state
                                    shouldHold = autofarm.currentlyHolding
                                end
                            else
                                -- Jika fish di luar bar, move bar untuk catch fish
                                if fishX > (barRight + tolerance) then
                                    -- Fish jauh di sebelah kanan bar, perlu hold untuk geser bar ke kanan
                                    shouldHold = true
                                elseif fishX < (barLeft - tolerance) then
                                    -- Fish jauh di sebelah kiri bar, perlu release untuk geser bar ke kiri
                                    shouldHold = false
                                else
                                    -- Fish dekat dengan bar edge, maintain current state untuk stability
                                    shouldHold = autofarm.currentlyHolding
                                end
                            end
                            
                            -- Execute hold/release decision dengan anti-spam
                            local VirtualInputManager = game:GetService("VirtualInputManager")
                            
                            if shouldHold and not autofarm.currentlyHolding then
                                -- Start holding - send mouse down
                                VirtualInputManager:SendMouseButtonEvent(0, 0, 0, true, player, 0)
                                autofarm.currentlyHolding = true
                            elseif not shouldHold and autofarm.currentlyHolding then
                                -- Stop holding - send mouse up
                                VirtualInputManager:SendMouseButtonEvent(0, 0, 0, false, player, 0)
                                autofarm.currentlyHolding = false
                            end
                            
                            -- Debug info
                            local status = fishInBar and "IN_BAR" or "OUT_BAR"
                            local action = shouldHold and "HOLD" or "RELEASE"
                            local holding = autofarm.currentlyHolding and "HOLDING" or "NOT_HOLDING"
                            local debugInfo = string.format(
                                "Fish=%.0f%%, Bar=%.0f%%->%.0f%%, Status=%s, Action=%s, State=%s",
                                fishX*100, barLeft*100, barRight*100, status, action, holding
                            )
                                fishX*100, barLeft*100, barRight*100, barCenter*100, status, action
                            )
                            print("Auto Reel Legit: " .. debugInfo)
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
            
            -- Adaptive delay berdasarkan rod characteristics
            if autofarm.reelMode == 1 then
                -- Dynamic delay berdasarkan deteksi speed rod
                local playerGui = player:WaitForChild("PlayerGui")
                local reel = playerGui:FindFirstChild("reel")
                if reel then
                    local playerbar = reel:FindFirstChild("playerbar")
                    if playerbar then
                        local barSize = playerbar.Size.X.Scale
                        -- Rod dengan bar kecil = pergerakan cepat = delay lebih kecil
                        if barSize < 0.15 then
                            wait(0.01) -- Very fast rod (small bar)
                        elseif barSize < 0.25 then
                            wait(0.015) -- Fast rod
                        else
                            wait(0.02) -- Normal/slow rod
                        end
                    else
                        wait(0.02) -- Default
                    end
                else
                    wait(0.02) -- Default when no reel UI
                end
            else
                wait(0.1) -- Normal delay untuk instant mode
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
