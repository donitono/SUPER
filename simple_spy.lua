-- Simple Remote Event Monitor
-- Versi yang lebih simple dan compatible untuk semua executor

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer

print("🕵️ SIMPLE REMOTE SPY STARTED")
print("=" .. string.rep("=", 40))

-- Storage untuk log events
local eventLogs = {}

-- Function untuk add log
local function addLog(eventName, args, source)
    local timestamp = tick()
    local logEntry = {
        time = timestamp,
        event = eventName,
        args = args or {},
        source = source or "Unknown"
    }
    
    table.insert(eventLogs, logEntry)
    
    -- Keep only last 100 logs
    if #eventLogs > 100 then
        table.remove(eventLogs, 1)
    end
    
    -- Print to console
    local argsStr = ""
    if args and #args > 0 then
        for i, arg in ipairs(args) do
            if i > 1 then argsStr = argsStr .. ", " end
            argsStr = argsStr .. tostring(arg)
        end
    end
    
    print(string.format("[%.0f] 🔥 %s(%s)", timestamp, eventName, argsStr))
end

-- Monitor RemoteEvents menggunakan metahook yang lebih aman
local function startMonitoring()
    -- Wait for events folder
    local events
    local attempts = 0
    while not events and attempts < 10 do
        events = ReplicatedStorage:FindFirstChild("events")
        if not events then
            wait(1)
            attempts = attempts + 1
        end
    end
    
    if not events then
        print("❌ Events folder not found!")
        return
    end
    
    print("📡 Found events folder, monitoring...")
    
    -- Monitor existing events
    for _, event in pairs(events:GetChildren()) do
        if event:IsA("RemoteEvent") then
            print("👀 Watching:", event.Name)
            
            -- Monitor when event is fired (this is safer)
            spawn(function()
                while event.Parent do
                    local success, result = pcall(function()
                        -- Try to detect when the event is used
                        -- This is a passive monitoring approach
                        local connections = getconnections and getconnections(event.OnClientEvent) or {}
                        if #connections > 0 then
                            addLog(event.Name, {"Detected usage"}, "Script Activity")
                        end
                    end)
                    wait(0.5)
                end
            end)
        end
    end
    
    -- Monitor new events being added
    events.ChildAdded:Connect(function(child)
        if child:IsA("RemoteEvent") then
            print("🆕 New event detected:", child.Name)
            addLog("NEW_EVENT", {child.Name}, "System")
        end
    end)
end

-- Global commands
_G.SimpleSpy = {
    -- Show recent events
    show = function(count)
        count = count or 20
        print("\n📋 RECENT EVENTS:")
        local startIndex = math.max(1, #eventLogs - count + 1)
        for i = startIndex, #eventLogs do
            local log = eventLogs[i]
            local argsStr = table.concat(log.args, ", ")
            print(string.format("[%.0f] %s(%s)", log.time, log.event, argsStr))
        end
        print(string.format("Total: %d events", #eventLogs))
    end,
    
    -- Filter by name
    filter = function(name)
        print("\n🔍 FILTERED EVENTS:", name)
        for _, log in ipairs(eventLogs) do
            if string.find(log.event:lower(), name:lower()) then
                local argsStr = table.concat(log.args, ", ")
                print(string.format("[%.0f] %s(%s)", log.time, log.event, argsStr))
            end
        end
    end,
    
    -- Clear logs
    clear = function()
        eventLogs = {}
        print("🗑️ Logs cleared")
    end,
    
    -- Save logs
    save = function()
        local content = "=== SIMPLE SPY LOG ===\n"
        for _, log in ipairs(eventLogs) do
            local argsStr = table.concat(log.args, ", ")
            content = content .. string.format("[%.0f] %s(%s)\n", log.time, log.event, argsStr)
        end
        
        if writefile then
            writefile("SimpleSpy.txt", content)
            print("💾 Saved to SimpleSpy.txt")
        elseif setclipboard then
            setclipboard(content)
            print("📋 Copied to clipboard")
        else
            print("❌ No save method available")
        end
    end
}

-- Start monitoring
spawn(startMonitoring)

print("\n🎛️ COMMANDS:")
print("_G.SimpleSpy.show() - Show recent events")
print("_G.SimpleSpy.filter('reel') - Filter events")
print("_G.SimpleSpy.clear() - Clear logs")
print("_G.SimpleSpy.save() - Save logs")
print("\n🕵️ Simple monitoring active!")
