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
    
    spawn(function()
        while autofarm.autoCastEnabled do
            local success, err = pcall(function()
                local castEvent = ReplicatedStorage:FindFirstChild("events")
                if castEvent then
                    local cast = castEvent:FindFirstChild("cast")
                    if cast then
                        if autofarm.castMode == 1 then
                            -- Mode 1: Legit - consistent good cast
                            local power = math.random(85, 95) -- Realistic power range
                            local accuracy = 1 -- Good accuracy
                            cast:FireServer(power, accuracy)
                            
                        elseif autofarm.castMode == 2 then
                            -- Mode 2: Rage - maximum power always
                            cast:FireServer(100, 1) -- 100% power, perfect accuracy
                            
                        elseif autofarm.castMode == 3 then
                            -- Mode 3: Random - legit but with random power
                            local power = math.random(70, 100) -- Wide random range
                            local accuracy = math.random(1, 1) -- Keep accuracy good
                            cast:FireServer(power, accuracy)
                        end
                    end
                end
                
                -- Alternative method - menggunakan Tool activation
                local tool = character:FindFirstChildOfClass("Tool")
                if tool then
                    tool:Activate()
                end
            end)
            
            if not success then
                warn("Auto Cast Error: " .. tostring(err))
            end
            
            -- Different delays based on mode
            if autofarm.castMode == 1 then
                wait(math.random(0.15, 0.25)) -- Legit: human-like delay
            elseif autofarm.castMode == 2 then
                wait(0.1) -- Rage: fast casting
            elseif autofarm.castMode == 3 then
                wait(math.random(0.1, 0.3)) -- Random: random delay
            end
        end
    end)
end

function autofarm.stopAutoCast()
    autofarm.autoCastEnabled = false
end

-- Auto Shake dengan 2 mode
function autofarm.startAutoShake(mode)
    autofarm.autoShakeEnabled = true
    autofarm.shakeMode = mode or 1
    
    spawn(function()
        while autofarm.autoShakeEnabled do
            local success, err = pcall(function()
                if autofarm.shakeMode == 1 then
                    -- Mode 1: Method dari sanhub
                    local shakeEvent = ReplicatedStorage:FindFirstChild("events")
                    if shakeEvent then
                        local shake = shakeEvent:FindFirstChild("shake")
                        if shake then
                            shake:FireServer(100, true)
                        end
                    end
                    
                elseif autofarm.shakeMode == 2 then
                    -- Mode 2: Method dari neoxhub (lebih advanced)
                    local playerGui = player:WaitForChild("PlayerGui")
                    local shakeUI = playerGui:FindFirstChild("shakeui")
                    
                    if shakeUI then
                        local safezone = shakeUI:FindFirstChild("safezone")
                        if safezone then
                            local button = safezone:FindFirstChild("button")
                            if button and button.Visible then
                                -- Simulate button click
                                local buttonPosition = button.AbsolutePosition
                                local buttonSize = button.AbsoluteSize
                                local centerX = buttonPosition.X + (buttonSize.X / 2)
                                local centerY = buttonPosition.Y + (buttonSize.Y / 2)
                                
                                -- Fire mouse click event
                                game:GetService("VirtualInputManager"):SendMouseButtonEvent(centerX, centerY, 0, true, game, 1)
                                wait(0.05)
                                game:GetService("VirtualInputManager"):SendMouseButtonEvent(centerX, centerY, 0, false, game, 1)
                            end
                        end
                    end
                    
                    -- Backup method untuk neoxhub
                    local shakeEvent = ReplicatedStorage:FindFirstChild("events")
                    if shakeEvent then
                        local shake = shakeEvent:FindFirstChild("shake")
                        if shake then
                            shake:FireServer(math.random(95, 100), true)
                        end
                    end
                end
            end)
            
            if not success then
                warn("Auto Shake Error: " .. tostring(err))
            end
            
            wait(0.05) -- Faster response untuk shake
        end
    end)
end

function autofarm.stopAutoShake()
    autofarm.autoShakeEnabled = false
end

-- Auto Reel (dari sanhub)
function autofarm.startAutoReel()
    autofarm.autoReelEnabled = true
    
    spawn(function()
        while autofarm.autoReelEnabled do
            local success, err = pcall(function()
                -- Method dari sanhub
                local playerGui = player:WaitForChild("PlayerGui")
                local reel = playerGui:FindFirstChild("reel")
                
                if reel then
                    local bar = reel:FindFirstChild("bar")
                    if bar and bar.Visible then
                        -- Auto reel ketika bar muncul
                        local reelEvent = ReplicatedStorage:FindFirstChild("events")
                        if reelEvent then
                            local reelAction = reelEvent:FindFirstChild("reelfinished")
                            if reelAction then
                                reelAction:FireServer(100, true) -- Perfect reel
                            end
                        end
                        
                        -- Alternative method - simulate space key press
                        UserInputService:SendKeyEvent(true, Enum.KeyCode.Space, false, game)
                        wait(0.05)
                        UserInputService:SendKeyEvent(false, Enum.KeyCode.Space, false, game)
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
            
            wait(0.1)
        end
    end)
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
