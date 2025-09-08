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
                -- Random delay sebelum cast untuk terlihat natural
                local randomDelay = math.random(150, 350) / 100 -- 1.5 - 3.5 detik
                task.wait(randomDelay)
                
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
                    -- Random delay sebelum recast untuk terlihat natural
                    local randomRecastDelay = math.random(200, 400) / 100 -- 2 - 4 detik
                    task.wait(randomRecastDelay)
                    
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
    
        print("Auto Reel started (Random delays enabled)")
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
        -- Mode 1: Method dari sanhub - RenderStepped checking dengan random delays
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
                            -- Random delay sebelum shake
                            local randomDelay = math.random(20, 60) / 1000 -- 0.02 - 0.06 detik
                            task.wait(randomDelay)
                            
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
        -- Mode 2: Method dari neoxhub - DescendantAdded detection dengan random delays
        local function handleShakeNeoxHub(descendant)
            if not autofarm.autoShakeEnabled then return end
            
            local success, err = pcall(function()
                -- Detect shake button seperti neoxhub
                if descendant.Name == "button" and descendant.Parent and descendant.Parent.Name == "safezone" then
                    -- Random delay sebelum shake (variasi dari 0.2-0.5 detik)
                    local randomDelay = math.random(200, 500) / 1000
                    task.wait(randomDelay)
                    
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
    
    print("Auto Shake started with mode: " .. autofarm.shakeMode .. " (Random delays enabled)")
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

-- Auto Reel (dari sanhub dengan random delays)
function autofarm.startAutoReel()
    autofarm.autoReelEnabled = true
    
    spawn(function()
        while autofarm.autoReelEnabled do
            local success, err = pcall(function()
                -- Method dari sanhub dengan random timing
                local playerGui = player:WaitForChild("PlayerGui")
                local reel = playerGui:FindFirstChild("reel")
                
                if reel then
                    local bar = reel:FindFirstChild("bar")
                    if bar and bar.Visible then
                        -- Random delay sebelum reel (0.1-0.3 detik)
                        local randomDelay = math.random(100, 300) / 1000
                        task.wait(randomDelay)
                        
                        -- Auto reel ketika bar muncul
                        local reelEvent = ReplicatedStorage:FindFirstChild("events")
                        if reelEvent then
                            local reelAction = reelEvent:FindFirstChild("reelfinished")
                            if reelAction then
                                reelAction:FireServer(100, true) -- Perfect reel
                            end
                        end
                        
                        -- Alternative method - simulate space key press dengan random timing
                        local keyDelay = math.random(20, 50) / 1000 -- 0.02-0.05 detik
                        UserInputService:SendKeyEvent(true, Enum.KeyCode.Space, false, game)
                        wait(keyDelay)
                        UserInputService:SendKeyEvent(false, Enum.KeyCode.Space, false, game)
                    end
                end
                
                -- Backup method - check for reel prompt dengan random response
                local reelPrompt = playerGui:FindFirstChild("ReelPrompt")
                if reelPrompt and reelPrompt.Visible then
                    -- Random delay untuk reaksi prompt
                    local promptDelay = math.random(80, 150) / 1000
                    task.wait(promptDelay)
                    
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
            
            -- Random wait time antara loop checks
            local loopDelay = math.random(80, 120) / 1000 -- 0.08-0.12 detik
            wait(loopDelay)
        end
    end)
end

function autofarm.stopAutoReel()
    autofarm.autoReelEnabled = false
end

-- Always Catch (dari sanhub) dengan random response timing
function autofarm.startAlwaysCatch()
    autofarm.alwaysCatchEnabled = true
    
    spawn(function()
        -- Hook reelfinished event untuk always catch
        local replicatedStorage = ReplicatedStorage
        local events = replicatedStorage:WaitForChild("events")
        local reelfinished = events:WaitForChild("reelfinished")
        
        -- Store original FireServer method
        local originalFireServer = reelfinished.FireServer
        
        -- Override FireServer method dengan random processing time
        reelfinished.FireServer = function(self, ...)
            local args = {...}
            if autofarm.alwaysCatchEnabled then
                -- Random delay untuk simulate thinking time
                local thinkingDelay = math.random(10, 40) / 1000 -- 0.01-0.04 detik
                task.wait(thinkingDelay)
                
                -- Random success rate (95-100% untuk variasi)
                local successRate = math.random(95, 100)
                
                -- Always catch dengan random perfect scores
                args[1] = successRate  -- Score antara 95-100
                args[2] = true -- Success flag
                print("Always Catch: Perfect catch applied! (" .. successRate .. "%)")
            end
            return originalFireServer(self, unpack(args))
        end
        
        print("Always Catch: Hook installed successfully! (Random timing enabled)")
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
        castMode = autofarm.castMode
    }
end

-- Start all autofarm features
function autofarm.startAll(shakeMode, castMode)
    shakeMode = shakeMode or 1
    castMode = castMode or 1
    autofarm.startAutoCast(castMode)
    autofarm.startAutoShake(shakeMode)
    autofarm.startAutoReel()
    autofarm.startAlwaysCatch()
end

-- Stop all autofarm features
function autofarm.stopAll()
    autofarm.stopAutoCast()
    autofarm.stopAutoShake()
    autofarm.stopAutoReel()
    autofarm.stopAlwaysCatch()
end

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
            if status.autoReel then autofarm.startAutoReel() end
            if status.alwaysCatch then autofarm.startAlwaysCatch() end
        end
    end)
end

-- Initialize
handleCharacterRespawn()

return autofarm
