-- Manual Event Explorer
-- Script untuk explore semua RemoteEvent yang ada tanpa hooking

local ReplicatedStorage = game:GetService("ReplicatedStorage")

print("📡 REMOTE EVENT EXPLORER")
print("=" .. string.rep("=", 40))

-- Function untuk explore events folder
local function exploreEvents()
    local events = ReplicatedStorage:FindFirstChild("events")
    if events then
        print("\n📂 EVENTS FOLDER FOUND:")
        for _, event in pairs(events:GetChildren()) do
            if event:IsA("RemoteEvent") then
                print("🔥", event.Name)
            elseif event:IsA("Folder") then
                print("📁", event.Name)
                for _, subEvent in pairs(event:GetChildren()) do
                    if subEvent:IsA("RemoteEvent") then
                        print("  └── 🔥", subEvent.Name)
                    end
                end
            end
        end
    else
        print("❌ No events folder found")
    end
end

-- Function untuk test fire event manually
local function testFireEvent(eventName, ...)
    local events = ReplicatedStorage:FindFirstChild("events")
    if events then
        local event = events:FindFirstChild(eventName)
        if event and event:IsA("RemoteEvent") then
            local args = {...}
            print(string.format("🚀 Testing: %s(%s)", eventName, table.concat(args, ", ")))
            
            local success, err = pcall(function()
                event:FireServer(...)
            end)
            
            if success then
                print("✅ Event fired successfully!")
            else
                print("❌ Error:", err)
            end
        else
            print("❌ Event not found:", eventName)
        end
    end
end

-- Global functions
_G.EventExplorer = {
    -- Show all events
    explore = function()
        exploreEvents()
    end,
    
    -- Test fire an event
    fire = function(eventName, ...)
        testFireEvent(eventName, ...)
    end,
    
    -- List specific event types
    reel = function()
        print("\n🎣 REEL-RELATED EVENTS:")
        local events = ReplicatedStorage:FindFirstChild("events")
        if events then
            for _, event in pairs(events:GetChildren()) do
                if event:IsA("RemoteEvent") and string.find(event.Name:lower(), "reel") then
                    print("🔥", event.Name)
                end
            end
        end
    end,
    
    cast = function()
        print("\n🎣 CAST-RELATED EVENTS:")
        local events = ReplicatedStorage:FindFirstChild("events")
        if events then
            for _, event in pairs(events:GetChildren()) do
                if event:IsA("RemoteEvent") and string.find(event.Name:lower(), "cast") then
                    print("🔥", event.Name)
                end
            end
        end
    end,
    
    -- Test common reel events
    testReel = function()
        print("\n🧪 TESTING COMMON REEL EVENTS:")
        
        -- Test berbagai kemungkinan event reel
        local testEvents = {
            "ReelFinished",
            "Reel_Finished", 
            "reel_finished",
            "FinishReel",
            "CompleteReel",
            "EndReel",
            "StopReel"
        }
        
        for _, eventName in ipairs(testEvents) do
            _G.EventExplorer.fire(eventName)
            wait(0.1)
        end
    end
}

-- Initial exploration
exploreEvents()

print("\n🎛️ EXPLORER COMMANDS:")
print("_G.EventExplorer.explore() - Show all events")
print("_G.EventExplorer.reel() - Show reel events")
print("_G.EventExplorer.cast() - Show cast events")
print("_G.EventExplorer.fire('EventName', args...) - Test fire event")
print("_G.EventExplorer.testReel() - Test common reel events")
print("\n💡 Use this to manually explore and test events!")
