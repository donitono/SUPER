-- Reel Debugger Script
-- Script untuk monitoring minigame reel dan mendeteksi events/modules yang digunakan
-- Jalankan script ini lalu masuk ke minigame reel untuk melihat data

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

print("🔍 REEL DEBUGGER STARTED - Enter reel minigame to see debug info")
print("=" .. string.rep("=", 50))

-- Variables untuk tracking
local isReelActive = false
local reelUI = nil
local debugConnection = nil
local eventConnections = {}

-- Function untuk monitor semua RemoteEvents
local function setupRemoteEventMonitoring()
    print("📡 Setting up RemoteEvent monitoring...")
    
    -- Monitor ReplicatedStorage.events
    local events = ReplicatedStorage:FindFirstChild("events")
    if events then
        for _, child in pairs(events:GetChildren()) do
            if child:IsA("RemoteEvent") then
                local connection = child.OnClientEvent:Connect(function(...)
                    if isReelActive then
                        local args = {...}
                        print("🔥 EVENT FIRED:", child.Name, "Args:", table.concat(args, ", "))
                    end
                end)
                table.insert(eventConnections, connection)
            end
        end
    end
    
    -- Monitor shared fishing events
    local sharedEvents = ReplicatedStorage:FindFirstChild("shared")
    if sharedEvents then
        local fishing = sharedEvents:FindFirstChild("modules")
        if fishing then
            fishing = fishing:FindFirstChild("fishing")
            if fishing then
                fishing = fishing:FindFirstChild("rodresources")
                if fishing then
                    fishing = fishing:FindFirstChild("events")
                    if fishing then
                        for _, child in pairs(fishing:GetChildren()) do
                            if child:IsA("RemoteEvent") then
                                local connection = child.OnClientEvent:Connect(function(...)
                                    if isReelActive then
                                        local args = {...}
                                        print("🎣 FISHING EVENT:", child.Name, "Args:", table.concat(args, ", "))
                                    end
                                end)
                                table.insert(eventConnections, connection)
                            end
                        end
                    end
                end
            end
        end
    end
end

-- Function untuk analyze reel UI structure
local function analyzeReelUI(reelGui)
    print("🎮 REEL UI DETECTED!")
    print("=" .. string.rep("=", 30))
    
    -- Print basic info
    print("UI Name:", reelGui.Name)
    print("UI Class:", reelGui.ClassName)
    print("UI Parent:", reelGui.Parent.Name)
    
    -- Analyze children
    print("\n📋 UI CHILDREN:")
    local function printChildren(parent, depth)
        depth = depth or 0
        local indent = string.rep("  ", depth)
        
        for _, child in pairs(parent:GetChildren()) do
            local info = indent .. "├─ " .. child.Name .. " (" .. child.ClassName .. ")"
            
            -- Add position/size info for GUI elements
            if child:IsA("GuiObject") then
                if child.Position then
                    info = info .. " Pos:" .. tostring(child.Position)
                end
                if child.Size then
                    info = info .. " Size:" .. tostring(child.Size)
                end
                if child.Visible ~= nil then
                    info = info .. " Visible:" .. tostring(child.Visible)
                end
            end
            
            print(info)
            
            -- Recursively print children (limit depth to avoid spam)
            if depth < 3 then
                printChildren(child, depth + 1)
            end
        end
    end
    
    printChildren(reelGui)
    print("=" .. string.rep("=", 30))
end

-- Function untuk monitor property changes
local function monitorPropertyChanges(gui)
    if not gui then return end
    
    -- Monitor common properties
    local properties = {"Position", "Size", "Visible", "BackgroundColor3", "Text"}
    
    local function setupPropertyMonitoring(obj, objName)
        for _, prop in pairs(properties) do
            local success, _ = pcall(function()
                if obj[prop] ~= nil then
                    obj:GetPropertyChangedSignal(prop):Connect(function()
                        if isReelActive then
                            print("🔄 PROPERTY CHANGED:", objName, prop, "=", tostring(obj[prop]))
                        end
                    end)
                end
            end)
        end
    end
    
    -- Monitor main GUI and children
    setupPropertyMonitoring(gui, gui.Name)
    
    local function setupChildMonitoring(parent, parentName)
        for _, child in pairs(parent:GetChildren()) do
            local childName = parentName .. "." .. child.Name
            setupPropertyMonitoring(child, childName)
            
            -- Monitor grandchildren too
            if child:IsA("GuiObject") then
                setupChildMonitoring(child, childName)
            end
        end
    end
    
    setupChildMonitoring(gui, gui.Name)
end

-- Function untuk detect input events
local function setupInputMonitoring()
    local UserInputService = game:GetService("UserInputService")
    
    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if isReelActive then
            print("⌨️ INPUT BEGIN:", input.KeyCode.Name, "GameProcessed:", gameProcessed)
        end
    end)
    
    UserInputService.InputEnded:Connect(function(input, gameProcessed)
        if isReelActive then
            print("⌨️ INPUT END:", input.KeyCode.Name, "GameProcessed:", gameProcessed)
        end
    end)
end

-- Main monitoring loop
local function startDebugging()
    debugConnection = RunService.Heartbeat:Connect(function()
        -- Check for reel UI
        local currentReelUI = playerGui:FindFirstChild("reel")
        
        if currentReelUI and not isReelActive then
            -- Reel started
            isReelActive = true
            reelUI = currentReelUI
            
            print("\n🎯 REEL MINIGAME STARTED!")
            analyzeReelUI(reelUI)
            monitorPropertyChanges(reelUI)
            
            -- Monitor for specific elements
            local bar = reelUI:FindFirstChild("bar")
            local pointer = reelUI:FindFirstChild("pointer")
            local playerbar = reelUI:FindFirstChild("playerbar")
            local safezone = reelUI:FindFirstChild("safezone")
            
            if bar then print("✅ Found: bar") end
            if pointer then print("✅ Found: pointer") end
            if playerbar then print("✅ Found: playerbar") end
            if safezone then print("✅ Found: safezone") end
            
            -- Monitor DescendantAdded/Removed
            reelUI.DescendantAdded:Connect(function(descendant)
                print("➕ DESCENDANT ADDED:", descendant.Name, descendant.ClassName)
            end)
            
            reelUI.DescendantRemoving:Connect(function(descendant)
                print("➖ DESCENDANT REMOVING:", descendant.Name, descendant.ClassName)
            end)
            
        elseif not currentReelUI and isReelActive then
            -- Reel ended
            isReelActive = false
            reelUI = nil
            print("\n🏁 REEL MINIGAME ENDED!")
            print("=" .. string.rep("=", 50))
        end
    end)
end

-- Function untuk clean up
local function cleanup()
    if debugConnection then
        debugConnection:Disconnect()
    end
    
    for _, connection in pairs(eventConnections) do
        connection:Disconnect()
    end
    
    print("🧹 Debugger cleaned up!")
end

-- Setup monitoring
setupRemoteEventMonitoring()
setupInputMonitoring()
startDebugging()

-- Commands untuk manual testing
_G.ReelDebugger = {
    stop = cleanup,
    analyze = function()
        local currentReel = playerGui:FindFirstChild("reel")
        if currentReel then
            analyzeReelUI(currentReel)
        else
            print("❌ No reel UI found!")
        end
    end,
    
    -- Test specific events
    testEvents = function()
        local events = ReplicatedStorage:FindFirstChild("events")
        if events then
            print("🧪 Testing events...")
            
            -- Test debug_giveprogress
            local debugProgress = events:FindFirstChild("debug_giveprogress")
            if debugProgress then
                print("Testing debug_giveprogress...")
                debugProgress:FireServer(100)
            end
            
            -- Test reelfinished
            local reelfinished = events:FindFirstChild("reelfinished")
            if reelfinished then
                print("Testing reelfinished...")
                reelfinished:FireServer(100, true)
            end
        end
    end
}

print("🎛️ Commands available:")
print("_G.ReelDebugger.stop() - Stop debugger")
print("_G.ReelDebugger.analyze() - Analyze current reel UI")
print("_G.ReelDebugger.testEvents() - Test reel events")
print("\n👀 Now enter a reel minigame to see debug output!")
