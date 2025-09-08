-- Remote Event Spy Script
-- Script untuk spy/monitor semua remote events yang digunakan script lain secara real-time

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")

local player = Players.LocalPlayer

print("🕵️ REMOTE EVENT SPY STARTED")
print("=" .. string.rep("=", 50))

-- Storage untuk log events
local eventLogs = {}
local maxLogs = 1000

-- Function untuk add log
local function addEventLog(eventName, args, source)
    local timestamp = tick()
    local logEntry = {
        time = timestamp,
        event = eventName,
        args = args,
        source = source or "Unknown",
        formattedTime = os.date("%H:%M:%S", timestamp)
    }
    
    table.insert(eventLogs, logEntry)
    
    -- Keep only recent logs
    if #eventLogs > maxLogs then
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
    
    print(string.format("[%s] 🔥 %s(%s) - Source: %s", logEntry.formattedTime, eventName, argsStr, source))
end

-- Hook all RemoteEvents in ReplicatedStorage
local function hookRemoteEvents()
    local events = ReplicatedStorage:FindFirstChild("events")
    if events then
        print("📡 Hooking events folder...")
        
        for _, event in pairs(events:GetChildren()) do
            if event:IsA("RemoteEvent") then
                print("🎯 Hooking:", event.Name)
                
                -- Hook the FireServer method
                local originalFireServer = event.FireServer
                event.FireServer = function(self, ...)
                    local args = {...}
                    addEventLog(event.Name, args, "Script/Hack")
                    
                    -- Call original function
                    return originalFireServer(self, ...)
                end
                
                -- Also listen for server events
                event.OnClientEvent:Connect(function(...)
                    local args = {...}
                    addEventLog(event.Name .. " (Server->Client)", args, "Server")
                end)
            end
        end
    end
    
    -- Hook shared events if they exist
    local shared = ReplicatedStorage:FindFirstChild("shared")
    if shared then
        local function hookSharedEvents(parent, path)
            for _, child in pairs(parent:GetChildren()) do
                if child:IsA("RemoteEvent") then
                    local fullPath = path .. "." .. child.Name
                    print("🎯 Hooking shared:", fullPath)
                    
                    local originalFireServer = child.FireServer
                    child.FireServer = function(self, ...)
                        local args = {...}
                        addEventLog(fullPath, args, "Script/Hack")
                        return originalFireServer(self, ...)
                    end
                    
                    child.OnClientEvent:Connect(function(...)
                        local args = {...}
                        addEventLog(fullPath .. " (Server->Client)", args, "Server")
                    end)
                elseif child:IsA("Folder") then
                    hookSharedEvents(child, path .. "." .. child.Name)
                end
            end
        end
        
        hookSharedEvents(shared, "shared")
    end
end

-- Monitor new events that get added
local function monitorNewEvents()
    local function setupEventHook(event, path)
        if event:IsA("RemoteEvent") then
            print("🆕 New event detected:", path)
            
            local originalFireServer = event.FireServer
            event.FireServer = function(self, ...)
                local args = {...}
                addEventLog(path, args, "Script/Hack (New)")
                return originalFireServer(self, ...)
            end
            
            event.OnClientEvent:Connect(function(...)
                local args = {...}
                addEventLog(path .. " (Server->Client)", args, "Server (New)")
            end)
        end
    end
    
    -- Monitor ReplicatedStorage changes
    local function monitorFolder(folder, basePath)
        folder.ChildAdded:Connect(function(child)
            local fullPath = basePath .. "." .. child.Name
            setupEventHook(child, fullPath)
            
            if child:IsA("Folder") then
                monitorFolder(child, fullPath)
            end
        end)
        
        -- Monitor existing children
        for _, child in pairs(folder:GetChildren()) do
            if child:IsA("Folder") then
                monitorFolder(child, basePath .. "." .. child.Name)
            end
        end
    end
    
    monitorFolder(ReplicatedStorage, "ReplicatedStorage")
end

-- Function untuk filter events by name
local function filterEvents(searchTerm)
    print(string.format("\n🔍 FILTERING EVENTS: '%s'", searchTerm))
    print("=" .. string.rep("=", 40))
    
    local filteredCount = 0
    for _, log in ipairs(eventLogs) do
        if string.find(string.lower(log.event), string.lower(searchTerm)) then
            local argsStr = ""
            if log.args and #log.args > 0 then
                for i, arg in ipairs(log.args) do
                    if i > 1 then argsStr = argsStr .. ", " end
                    argsStr = argsStr .. tostring(arg)
                end
            end
            
            print(string.format("[%s] 🔥 %s(%s) - %s", log.formattedTime, log.event, argsStr, log.source))
            filteredCount = filteredCount + 1
        end
    end
    
    print(string.format("📊 Found %d events matching '%s'", filteredCount, searchTerm))
end

-- Function untuk show recent events
local function showRecentEvents(count)
    count = count or 20
    print(string.format("\n📋 LAST %d EVENTS:", count))
    print("=" .. string.rep("=", 40))
    
    local startIndex = math.max(1, #eventLogs - count + 1)
    for i = startIndex, #eventLogs do
        local log = eventLogs[i]
        local argsStr = ""
        if log.args and #log.args > 0 then
            for j, arg in ipairs(log.args) do
                if j > 1 then argsStr = argsStr .. ", " end
                argsStr = argsStr .. tostring(arg)
            end
        end
        
        print(string.format("[%s] 🔥 %s(%s) - %s", log.formattedTime, log.event, argsStr, log.source))
    end
end

-- Function untuk save logs to file
local function saveLogsToFile()
    local fileName = "RemoteEventSpy_" .. os.date("%Y%m%d_%H%M%S") .. ".txt"
    local content = "=== REMOTE EVENT SPY LOG ===\n"
    content = content .. "Generated: " .. os.date("%Y-%m-%d %H:%M:%S") .. "\n"
    content = content .. "Player: " .. player.Name .. "\n"
    content = content .. "Total Events Captured: " .. #eventLogs .. "\n\n"
    
    for _, log in ipairs(eventLogs) do
        local argsStr = ""
        if log.args and #log.args > 0 then
            for i, arg in ipairs(log.args) do
                if i > 1 then argsStr = argsStr .. ", " end
                argsStr = argsStr .. tostring(arg)
            end
        end
        
        content = content .. string.format("[%s] %s(%s) - %s\n", log.formattedTime, log.event, argsStr, log.source)
    end
    
    if writefile then
        writefile(fileName, content)
        print("💾 Spy log saved to:", fileName)
    elseif setclipboard then
        setclipboard(content)
        print("📋 Spy log copied to clipboard")
    else
        print("❌ Cannot save - no file/clipboard function available")
    end
end

-- Initialize hooking
hookRemoteEvents()
monitorNewEvents()

-- Global commands for manual control
_G.RemoteEventSpy = {
    -- Show recent events
    recent = function(count)
        showRecentEvents(count)
    end,
    
    -- Filter events by name
    filter = function(searchTerm)
        filterEvents(searchTerm)
    end,
    
    -- Show reel-related events only
    reel = function()
        filterEvents("reel")
    end,
    
    -- Show cast-related events only
    cast = function()
        filterEvents("cast")
    end,
    
    -- Show shake-related events only
    shake = function()
        filterEvents("shake")
    end,
    
    -- Save all logs to file
    save = function()
        saveLogsToFile()
    end,
    
    -- Clear logs
    clear = function()
        eventLogs = {}
        print("🗑️ Event logs cleared")
    end,
    
    -- Show stats
    stats = function()
        print(string.format("📊 SPY STATS:"))
        print(string.format("Total Events Captured: %d", #eventLogs))
        print(string.format("Memory Usage: ~%d KB", #eventLogs * 0.1))
        
        -- Count by event name
        local eventCounts = {}
        for _, log in ipairs(eventLogs) do
            eventCounts[log.event] = (eventCounts[log.event] or 0) + 1
        end
        
        print("\n📈 TOP EVENTS:")
        local sortedEvents = {}
        for eventName, count in pairs(eventCounts) do
            table.insert(sortedEvents, {name = eventName, count = count})
        end
        table.sort(sortedEvents, function(a, b) return a.count > b.count end)
        
        for i = 1, math.min(10, #sortedEvents) do
            local event = sortedEvents[i]
            print(string.format("%d. %s: %d times", i, event.name, event.count))
        end
    end
}

print("\n🎛️ SPY COMMANDS:")
print("_G.RemoteEventSpy.recent(20) - Show last 20 events")
print("_G.RemoteEventSpy.filter('reel') - Filter events by name")
print("_G.RemoteEventSpy.reel() - Show reel events only")
print("_G.RemoteEventSpy.cast() - Show cast events only") 
print("_G.RemoteEventSpy.shake() - Show shake events only")
print("_G.RemoteEventSpy.save() - Save logs to file")
print("_G.RemoteEventSpy.clear() - Clear all logs")
print("_G.RemoteEventSpy.stats() - Show statistics")
print("\n🕵️ Monitoring active - All remote events will be logged!")
print("Use other scripts/hacks now to see what events they use.")
