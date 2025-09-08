-- Reel Instant Fill Script
-- Script untuk test semua method membuat progress bar reel langsung penuh

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local VirtualInputManager = game:GetService("VirtualInputManager")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

print("🎣 REEL INSTANT FILL TESTER")
print("=" .. string.rep("=", 40))

-- Method 1: debug_giveprogress
local function testDebugGiveProgress()
    local events = ReplicatedStorage:FindFirstChild("events")
    if events then
        local debugProgress = events:FindFirstChild("debug_giveprogress")
        if debugProgress then
            print("✅ Found debug_giveprogress - Testing...")
            debugProgress:FireServer(100)
            debugProgress:FireServer(200)
            debugProgress:FireServer(999)
            return true
        end
    end
    print("❌ debug_giveprogress not found")
    return false
end

-- Method 2: reelfinished variations
local function testReelFinished()
    local events = ReplicatedStorage:FindFirstChild("events")
    if events then
        local reelfinished = events:FindFirstChild("reelfinished")
        if reelfinished then
            print("✅ Found reelfinished - Testing variations...")
            
            -- Test different parameters
            reelfinished:FireServer(100, true)
            wait(0.1)
            reelfinished:FireServer(100)
            wait(0.1)
            reelfinished:FireServer(200, true)
            wait(0.1)
            reelfinished:FireServer(999, true)
            wait(0.1)
            reelfinished:FireServer(100, false)
            return true
        end
    end
    print("❌ reelfinished not found")
    return false
end

-- Method 3: reel event variations
local function testReelEvent()
    local events = ReplicatedStorage:FindFirstChild("events")
    if events then
        local reel = events:FindFirstChild("reel")
        if reel then
            print("✅ Found reel event - Testing...")
            reel:FireServer(100, true)
            reel:FireServer(100)
            reel:FireServer("complete")
            reel:FireServer("finish", 100)
            return true
        end
    end
    print("❌ reel event not found")
    return false
end

-- Method 4: progress event
local function testProgressEvent()
    local events = ReplicatedStorage:FindFirstChild("events")
    if events then
        local progress = events:FindFirstChild("progress")
        if progress then
            print("✅ Found progress event - Testing...")
            progress:FireServer(100)
            progress:FireServer(1)
            progress:FireServer("full")
            return true
        end
    end
    print("❌ progress event not found")
    return false
end

-- Method 5: Complete event
local function testCompleteEvent()
    local events = ReplicatedStorage:FindFirstChild("events")
    if events then
        local complete = events:FindFirstChild("complete")
        if complete then
            print("✅ Found complete event - Testing...")
            complete:FireServer()
            complete:FireServer(100)
            complete:FireServer(true)
            return true
        end
    end
    print("❌ complete event not found")
    return false
end

-- Method 6: Fishing events in shared folder
local function testSharedFishingEvents()
    local shared = ReplicatedStorage:FindFirstChild("shared")
    if shared then
        local modules = shared:FindFirstChild("modules")
        if modules then
            local fishing = modules:FindFirstChild("fishing")
            if fishing then
                local rodresources = fishing:FindFirstChild("rodresources")
                if rodresources then
                    local events = rodresources:FindFirstChild("events")
                    if events then
                        print("✅ Found shared fishing events - Testing...")
                        
                        for _, event in pairs(events:GetChildren()) do
                            if event:IsA("RemoteEvent") then
                                print("Testing shared event:", event.Name)
                                event:FireServer(100)
                                event:FireServer(100, true)
                                event:FireServer("complete")
                                wait(0.1)
                            end
                        end
                        return true
                    end
                end
            end
        end
    end
    print("❌ shared fishing events not found")
    return false
end

-- Method 7: Direct progress bar manipulation
local function testDirectProgressBar()
    local reel = playerGui:FindFirstChild("reel")
    if reel then
        local bar = reel:FindFirstChild("bar")
        if bar then
            local progress = bar:FindFirstChild("progress")
            if progress then
                local progressBar = progress:FindFirstChild("bar")
                if progressBar then
                    print("✅ Found progress bar - Testing direct manipulation...")
                    
                    -- Try to modify size directly
                    progressBar.Size = UDim2.new(1, 0, 1, 0)
                    print("Set progress bar size to full")
                    
                    -- Try to modify position
                    progressBar.Position = UDim2.new(0, 0, 0, 0)
                    print("Set progress bar position")
                    
                    return true
                end
            end
        end
    end
    print("❌ progress bar UI not found")
    return false
end

-- Method 8: Fish position manipulation
local function testFishManipulation()
    local reel = playerGui:FindFirstChild("reel")
    if reel then
        local bar = reel:FindFirstChild("bar")
        if bar then
            local fish = bar:FindFirstChild("fish")
            local playerbar = bar:FindFirstChild("playerbar")
            
            if fish and playerbar then
                print("✅ Found fish and playerbar - Testing manipulation...")
                
                -- Try to move fish to center
                fish.Position = UDim2.new(0.5, 0, 0.5, 0)
                print("Moved fish to center")
                
                -- Try to move playerbar to fish
                playerbar.Position = fish.Position
                print("Moved playerbar to fish position")
                
                return true
            end
        end
    end
    print("❌ fish/playerbar not found")
    return false
end

-- Auto test when reel appears
local function autoTest()
    local connection
    connection = RunService.Heartbeat:Connect(function()
        local reel = playerGui:FindFirstChild("reel")
        if reel then
            print("\n🎣 REEL DETECTED - TESTING ALL METHODS:")
            print("=" .. string.rep("=", 40))
            
            -- Test all methods
            testDebugGiveProgress()
            wait(0.2)
            testReelFinished()
            wait(0.2)
            testReelEvent()
            wait(0.2)
            testProgressEvent()
            wait(0.2)
            testCompleteEvent()
            wait(0.2)
            testSharedFishingEvents()
            wait(0.2)
            testDirectProgressBar()
            wait(0.2)
            testFishManipulation()
            
            print("=" .. string.rep("=", 40))
            print("✅ ALL METHODS TESTED!")
            
            -- Disconnect after testing
            connection:Disconnect()
        end
    end)
end

-- Manual commands
_G.ReelInstant = {
    testAll = function()
        print("🧪 MANUAL TEST ALL METHODS:")
        testDebugGiveProgress()
        testReelFinished()
        testReelEvent()
        testProgressEvent()
        testCompleteEvent()
        testSharedFishingEvents()
        testDirectProgressBar()
        testFishManipulation()
        print("✅ Manual test completed!")
    end,
    
    debugProgress = function()
        testDebugGiveProgress()
    end,
    
    reelFinished = function()
        testReelFinished()
    end,
    
    directBar = function()
        testDirectProgressBar()
    end,
    
    fishManip = function()
        testFishManipulation()
    end
}

-- Start auto testing
autoTest()

print("🎛️ MANUAL COMMANDS:")
print("_G.ReelInstant.testAll() - Test all methods")
print("_G.ReelInstant.debugProgress() - Test debug_giveprogress")
print("_G.ReelInstant.reelFinished() - Test reelfinished")
print("_G.ReelInstant.directBar() - Test direct bar manipulation")
print("_G.ReelInstant.fishManip() - Test fish manipulation")
print("\n⏳ Waiting for reel minigame to auto-test...")
