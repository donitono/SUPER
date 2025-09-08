-- Autofarm Module
-- Kombinasi fitur dari sanhub, kinghub, dan neoxhub

local autofarm = {}

-- Services
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

-- Variables with safe initialization
local player = Players.LocalPlayer
local character
local humanoid

-- Safe character and humanoid initialization
local function initializeCharacter()
    local success, err = pcall(function()
        character = player.Character or player.CharacterAdded:Wait()
        if character then
            humanoid = character:WaitForChild("Humanoid", 5)
        end
    end)
    
    if not success then
        warn("Failed to initialize character: " .. tostring(err))
        character = nil
        humanoid = nil
    end
    
    return character ~= nil and humanoid ~= nil
end

-- Initialize on first load
initializeCharacter()

-- Reinitialize when character respawns
player.CharacterAdded:Connect(function()
    task.wait(1) -- Wait for character to fully load
    initializeCharacter()
end)

-- Autofarm States
autofarm.autoCastEnabled = false
autofarm.autoShakeEnabled = false
autofarm.autoReelEnabled = false
autofarm.alwaysCatchEnabled = false
autofarm.shakeMode = 1 -- 1 = sanhub method, 2 = neoxhub method
autofarm.castMode = 1 -- 1 = legit, 2 = rage, 3 = random
autofarm.reelMode = 1 -- 1 = faster, 2 = normal, 3 = legit, 4 = fail

-- Auto Cast (dari kinghub dengan metodenya)
function autofarm.startAutoCast(mode)
    if not character or not humanoid then
        if not initializeCharacter() then
            warn("Cannot start auto cast - character not initialized")
            return
        end
    end
    
    autofarm.autoCastEnabled = true
    autofarm.castMode = mode or 1
    
    -- Hook untuk tool equipped
    local function onCharacterChildAdded(child)
        if not autofarm.autoCastEnabled then return end
        
        local success, err = pcall(function()
            if child:IsA("Tool") and child:FindFirstChild("events") then
                local castEvent = child.events:FindFirstChild("cast")
                if castEvent then
                    task.wait(2) -- Delay sebelum cast
                    
                    if autofarm.castMode == 1 then
                        -- Mode 1: Legit - simulate mouse click dan tunggu full power
                        local VirtualInputManager = game:GetService("VirtualInputManager")
                        VirtualInputManager:SendMouseButtonEvent(0, 0, 0, true, player, 0)
                        
                        -- Monitor power bar untuk release saat FULL (seperti kinghub)
                        if character and character:FindFirstChild("HumanoidRootPart") then
                            local humanoidRootPart = character.HumanoidRootPart
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
                        -- Mode 3: Random - legit with random timing (85-95%)
                        local VirtualInputManager = game:GetService("VirtualInputManager")
                        VirtualInputManager:SendMouseButtonEvent(0, 0, 0, true, player, 0)
                        
                        if character and character:FindFirstChild("HumanoidRootPart") then
                            local humanoidRootPart = character.HumanoidRootPart
                            local powerConnection
                            powerConnection = humanoidRootPart.ChildAdded:Connect(function(powerChild)
                                if powerChild.Name == "power" then
                                    local powerbar = powerChild:FindFirstChild("powerbar")
                                    if powerbar and powerbar:FindFirstChild("bar") then
                                        local barConnection
                                        -- Random target antara 85-95% untuk variasi yang lebih masuk akal
                                        local randomPercent = math.random(85, 95)
                                        local randomTarget = UDim2.new(randomPercent/100, 0, 1, 0)
                                        barConnection = powerbar.bar:GetPropertyChangedSignal("Size"):Connect(function()
                                            -- Bandingkan dengan UDim2 yang benar
                                            if powerbar.bar.Size.X.Scale >= (randomPercent/100) then
                                                VirtualInputManager:SendMouseButtonEvent(0, 0, 0, false, player, 0)
                                                barConnection:Disconnect()
                                                powerConnection:Disconnect()
                                                print("Random Cast: Released at " .. randomPercent .. "%")
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
        end)
        
        if not success then
            warn("Auto Cast Tool Hook Error: " .. tostring(err))
        end
    end
    
    -- Hook untuk reel finished (auto recast)
    local function onGuiRemoved(gui)
        if not autofarm.autoCastEnabled then return end
        
        local success, err = pcall(function()
            if gui.Name == "reel" then
                if character and character:FindFirstChildOfClass("Tool") then
                    local tool = character:FindFirstChildOfClass("Tool")
                    if tool and tool:FindFirstChild("events") then
                        local castEvent = tool.events:FindFirstChild("cast")
                        if castEvent then
                            task.wait(2) -- Delay sebelum recast
                            
                            if autofarm.castMode == 1 then
                                -- Legit mode recast - tunggu full power seperti kinghub
                                local VirtualInputManager = game:GetService("VirtualInputManager")
                                VirtualInputManager:SendMouseButtonEvent(0, 0, 0, true, player, 0)
                            
                                if character and character:FindFirstChild("HumanoidRootPart") then
                                    local humanoidRootPart = character.HumanoidRootPart
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
                                -- Random mode recast - random target 85-95%
                                local VirtualInputManager = game:GetService("VirtualInputManager")
                                VirtualInputManager:SendMouseButtonEvent(0, 0, 0, true, player, 0)
                                
                                if character and character:FindFirstChild("HumanoidRootPart") then
                                    local humanoidRootPart = character.HumanoidRootPart
                                    local powerConnection
                                    powerConnection = humanoidRootPart.ChildAdded:Connect(function(powerChild)
                                    if powerChild.Name == "power" then
                                        local powerbar = powerChild:FindFirstChild("powerbar")
                                        if powerbar and powerbar:FindFirstChild("bar") then
                                            local barConnection
                                            -- Random target antara 85-95% untuk variasi yang masuk akal
                                            local randomPercent = math.random(85, 95)
                                            barConnection = powerbar.bar:GetPropertyChangedSignal("Size"):Connect(function()
                                                -- Bandingkan dengan nilai yang benar
                                                if powerbar.bar.Size.X.Scale >= (randomPercent/100) then
                                                    VirtualInputManager:SendMouseButtonEvent(0, 0, 0, false, player, 0)
                                                    barConnection:Disconnect()
                                                    powerConnection:Disconnect()
                                                    print("Random Recast: Released at " .. randomPercent .. "%")
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
        end)
        
        if not success then
            warn("Auto Cast GUI Remove Hook Error: " .. tostring(err))
        end
    end
    
    -- Connect events with error handling
    local success, err = pcall(function()
        if character then
            autofarm.castConnection1 = character.ChildAdded:Connect(onCharacterChildAdded)
        end
        if player.PlayerGui then
            autofarm.castConnection2 = player.PlayerGui.ChildRemoved:Connect(onGuiRemoved)
        end
    end)
    
    if not success then
        warn("Auto Cast Connection Error: " .. tostring(err))
    else
        print("Auto Cast started with mode: " .. autofarm.castMode)
    end
end

function autofarm.stopAutoCast()
    autofarm.autoCastEnabled = false
    
    -- Disconnect connections safely
    local success, err = pcall(function()
        if autofarm.castConnection1 then
            autofarm.castConnection1:Disconnect()
            autofarm.castConnection1 = nil
        end
        if autofarm.castConnection2 then
            autofarm.castConnection2:Disconnect()
            autofarm.castConnection2 = nil
        end
    end)
    
    if not success then
        warn("Auto Cast Stop Error: " .. tostring(err))
    else
        print("Auto Cast stopped")
    end
end

-- Mode selection functions with safety checks
function autofarm.setCastMode(mode)
    if type(mode) == "number" and mode >= 1 and mode <= 3 then
        autofarm.castMode = mode
        print("Cast mode set to: " .. mode)
    else
        warn("Invalid cast mode: " .. tostring(mode))
    end
end

function autofarm.setShakeMode(mode)
    if type(mode) == "number" and mode >= 1 and mode <= 2 then
        autofarm.shakeMode = mode
        print("Shake mode set to: " .. mode)
    else
        warn("Invalid shake mode: " .. tostring(mode))
    end
end

function autofarm.setReelMode(mode)
    if type(mode) == "number" and mode >= 1 and mode <= 4 then
        autofarm.reelMode = mode
        print("Reel mode set to: " .. mode)
    else
        warn("Invalid reel mode: " .. tostring(mode))
    end
end

-- Auto Shake dengan 2 mode
function autofarm.startAutoShake(mode)
    if not character or not humanoid then
        if not initializeCharacter() then
            warn("Cannot start auto shake - character not initialized")
            return
        end
    end
    
    autofarm.autoShakeEnabled = true
    autofarm.shakeMode = mode or 1
    
    if autofarm.shakeMode == 1 then
        -- Mode 1: Method dari sanhub - RenderStepped checking
        local function handleShake()
            if not autofarm.autoShakeEnabled then return end
            
            local success, err = pcall(function()
                local playerGui = player:WaitForChild("PlayerGui", 5)
                if not playerGui then return end
                
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
                warn("Auto Shake Error: " .. tostring(err))
            end
        end
        
        -- Connect to RenderStepped untuk continuous checking
        autofarm.shakeConnection = RunService.RenderStepped:Connect(handleShake)
        
    elseif autofarm.shakeMode == 2 then
        -- Mode 2: Method dari neoxhub - DescendantAdded + tool shake event
        
        -- Method 1: GUI DescendantAdded (seperti neoxhub asli)
        local function onDescendantAdded(descendant)
            if not autofarm.autoShakeEnabled then return end
            
            local success, err = pcall(function()
                if descendant.Name == "button" and descendant.Parent and descendant.Parent.Name == "safezone" then
                    task.wait(0.3) -- Delay seperti neoxhub
                    game:GetService("GuiService").SelectedObject = descendant
                    
                    local VirtualInputManager = game:GetService("VirtualInputManager")
                    VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.Return, false, game)
                    VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.Return, false, game)
                    
                    task.wait(0.1)
                    game:GetService("GuiService").SelectedObject = nil
                    print("Shake performed (NeoxHub GUI method)")
                end
            end)
            
            if not success then
                warn("Auto Shake GUI Error: " .. tostring(err))
            end
        end
        
        -- Method 2: Tool shake event (backup method)
        local function handleToolShake()
            if not autofarm.autoShakeEnabled then return end
            
            local success, err = pcall(function()
                local tool = character:FindFirstChildOfClass("Tool")
                if tool and tool:FindFirstChild("events") then
                    local shakeEvent = tool.events:FindFirstChild("shake")
                    if shakeEvent then
                        shakeEvent:FireServer()
                        print("Shake performed (NeoxHub Tool method)")
                    end
                end
            end)
            
            if not success then
                warn("Auto Shake Tool Error: " .. tostring(err))
            end
        end
        
        -- Connect both methods
        autofarm.shakeConnection = player.PlayerGui.DescendantAdded:Connect(onDescendantAdded)
        autofarm.shakeConnection2 = RunService.RenderStepped:Connect(handleToolShake)
    end
    
    print("Auto Shake started with mode: " .. autofarm.shakeMode)
end

function autofarm.stopAutoShake()
    autofarm.autoShakeEnabled = false
    
    -- Disconnect shake connections
    if autofarm.shakeConnection then
        autofarm.shakeConnection:Disconnect()
        autofarm.shakeConnection = nil
    end
    if autofarm.shakeConnection2 then
        autofarm.shakeConnection2:Disconnect()
        autofarm.shakeConnection2 = nil
    end
    
    print("Auto Shake stopped")
end

-- Auto Reel dengan 4 mode (Updated berdasarkan debug log)
function autofarm.startAutoReel(mode)
    autofarm.autoReelEnabled = true
    autofarm.reelMode = mode or 1
    
    if autofarm.reelMode == 1 then
        -- Mode 1: Faster - instant completion
        spawn(function()
            while autofarm.autoReelEnabled do
                local success, err = pcall(function()
                    local playerGui = player:WaitForChild("PlayerGui")
                    local reel = playerGui:FindFirstChild("reel")
                    
                    if reel then
                        local bar = reel:FindFirstChild("bar")
                        if bar and bar.Visible then
                            -- Faster mode - instant completion
                            local events = ReplicatedStorage:FindFirstChild("events")
                            if events then
                                local debugProgress = events:FindFirstChild("debug_giveprogress")
                                local reelfinished = events:FindFirstChild("reelfinished")
                                
                                if debugProgress then
                                    debugProgress:FireServer(100)
                                    print("Reel: Faster mode - Debug progress!")
                                elseif reelfinished then
                                    reelfinished:FireServer(100, true)
                                    print("Reel: Faster mode - Instant finish!")
                                end
                                wait(1) -- Delay to avoid spam
                            end
                        end
                    end
                end)
                
                if not success then
                    warn("Auto Reel Faster Error: " .. tostring(err))
                end
                
                wait(0.1)
            end
        end)
        
    elseif autofarm.reelMode == 2 then
        -- Mode 2: Normal - maintain fish position to fill progress
        spawn(function()
            while autofarm.autoReelEnabled do
                local success, err = pcall(function()
                    local playerGui = player:WaitForChild("PlayerGui")
                    local reel = playerGui:FindFirstChild("reel")
                    
                    if reel then
                        local bar = reel:FindFirstChild("bar")
                        if bar and bar.Visible then
                            local fish = bar:FindFirstChild("fish")
                            local playerbar = bar:FindFirstChild("playerbar")
                            local progress = bar:FindFirstChild("progress")
                            
                            if fish and playerbar and progress then
                                local progressBar = progress:FindFirstChild("bar")
                                
                                -- Get fish and player positions
                                local fishPos = fish.Position.X.Scale
                                local playerPos = playerbar.Position.X.Scale
                                
                                -- Maintain position by clicking when fish moves away
                                if math.abs(fishPos - 0.5) > 0.15 then
                                    -- Click and hold to keep fish centered
                                    VirtualInputManager:SendMouseButtonEvent(100, 100, Enum.UserInputType.MouseButton1, true, game, 0)
                                    wait(0.1)
                                    VirtualInputManager:SendMouseButtonEvent(100, 100, Enum.UserInputType.MouseButton1, false, game, 0)
                                    print("Reel: Normal mode - Centering fish")
                                end
                            end
                        end
                    end
                end)
                
                if not success then
                    warn("Auto Reel Normal Error: " .. tostring(err))
                end
                
                wait(0.05)
            end
        end)
                                    print("Reel: Normal mode - Progress filled!")
                                else
                                    -- Alternative: FireServer reelfinished dengan parameter yang berbeda
                                    local reelAction = reelEvent:FindFirstChild("reelfinished")
                                    if reelAction then
                                        reelAction:FireServer(100) -- Tanpa success flag, mungkin akan fill bar
                                        print("Reel: Normal mode - Alternative method!")
                                    end
                                end
                            end
                            wait(0.5) -- Delay untuk avoid spam
                        end
                    end
                end)
                
                if not success then
                    warn("Auto Reel Normal Error: " .. tostring(err))
                end
                
                wait(0.1)
            end
        end)
        
    elseif autofarm.reelMode == 3 then
        -- Mode 3: Legit - follow fish with direction indicators
        spawn(function()
            while autofarm.autoReelEnabled do
                local success, err = pcall(function()
                    local playerGui = player:WaitForChild("PlayerGui")
                    local reel = playerGui:FindFirstChild("reel")
                    
                    if reel then
                        local bar = reel:FindFirstChild("bar")
                        if bar and bar.Visible then
                            local fish = bar:FindFirstChild("fish")
                            local playerbar = bar:FindFirstChild("playerbar")
                            local leftIcon = bar:FindFirstChild("licon")
                            local rightIcon = bar:FindFirstChild("ricon")
                            
                            if fish and playerbar then
                                -- Get positions
                                local fishPos = fish.Position.X.Scale
                                local playerPos = playerbar.Position.X.Scale
                                
                                -- Check direction indicators first
                                if leftIcon and leftIcon.Visible then
                                    -- Move left
                                    VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.A, false, game)
                                    wait(0.05)
                                    VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.A, false, game)
                                    print("Reel: Legit mode - Move left")
                                elseif rightIcon and rightIcon.Visible then
                                    -- Move right
                                    VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.D, false, game)
                                    wait(0.05)
                                    VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.D, false, game)
                                    print("Reel: Legit mode - Move right")
                                else
                                    -- Follow fish position with realistic movement
                                    local distance = fishPos - playerPos
                                    
                                    if math.abs(distance) > 0.05 then
                                        if distance > 0 then
                                            -- Fish is to the right, tap to move right
                                            VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.Space, false, game)
                                            wait(0.02)
                                            VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.Space, false, game)
                                            print("Reel: Legit mode - Tap right")
                                        else
                                            -- Fish is to the left, let it drift or tap lightly
                                            print("Reel: Legit mode - Let drift left")
                                        end
                                        wait(0.08) -- Realistic delay
                                    end
                                end
                            else
                                -- Fallback - simple tap pattern
                                VirtualInputManager:SendMouseButtonEvent(100, 100, Enum.UserInputType.MouseButton1, true, game, 0)
                                wait(0.1)
                                VirtualInputManager:SendMouseButtonEvent(100, 100, Enum.UserInputType.MouseButton1, false, game, 0)
                                wait(0.2)
                            end
                        end
                    end
                end)
                
                if not success then
                    warn("Auto Reel Legit Error: " .. tostring(err))
                end
                
                wait(0.02) -- Faster checking untuk responsivitas
            end
        end)
        
    elseif autofarm.reelMode == 4 then
        -- Mode 4: Fail - tidak melakukan apa-apa
        print("Reel: Fail mode - No action taken (will fail)")
        -- Tidak ada action, biarkan minigame gagal
        
    end
    
    print("Auto Reel started with mode: " .. autofarm.reelMode)
end

function autofarm.stopAutoReel()
    autofarm.autoReelEnabled = false
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

function autofarm.setReelMode(mode)
    if mode == 1 or mode == 2 or mode == 3 or mode == 4 then
        autofarm.reelMode = mode
        return true
    else
        warn("Invalid reel mode. Use 1 (faster), 2 (normal), 3 (legit), or 4 (fail)")
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
            if status.autoReel then autofarm.startAutoReel(status.reelMode) end
            if status.alwaysCatch then autofarm.startAlwaysCatch() end
        end
    end)
end

-- Initialize
handleCharacterRespawn()

return autofarm
