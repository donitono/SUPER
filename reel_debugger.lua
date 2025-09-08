-- Reel Debugger Script
-- Script untuk monitoring minigame reel dan mendeteksi events/modules yang digunakan
-- Jalankan script ini lalu masuk ke minigame reel untuk melihat data

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local UserInputService = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Logging system
local logData = {}
local maxLogEntries = 1000
local debugUI = nil

-- Function untuk save log to file
local function saveLogToFile()
    local success, err = pcall(function()
        local fileName = "ReelDebugLog.txt" -- Nama file sederhana
        local content = "=== REEL DEBUGGER LOG ===\n"
        content = content .. "Generated at tick: " .. tick() .. "\n"
        content = content .. "Player: " .. player.Name .. "\n"
        content = content .. "Total Entries: " .. #logData .. "\n\n"
        content = content .. table.concat(logData, "\n")
        
        -- Gunakan metode yang sama seperti dump.lua
        if writefile then
            writefile(fileName, content)
            addLog("✅ Log saved to: " .. fileName, "SUCCESS")
        else
            -- Alternative: Copy to clipboard if available
            if setclipboard then
                setclipboard(content)
                addLog("📋 Log copied to clipboard (writefile not available)", "INFO")
            else
                addLog("❌ No file writing method available", "ERROR")
            end
        end
    end)
    
    if not success then
        addLog("❌ Save failed: " .. tostring(err), "ERROR")
    end
end

-- Function untuk clear logs
local function clearLogs()
    logData = {}
    addLog("🗑️ Logs cleared", "INFO")
end

-- Function untuk analyze current reel
local function analyzeCurrentReel()
    local currentReel = playerGui:FindFirstChild("reel")
    if currentReel then
        addLog("🔍 Analyzing current reel UI...", "ANALYZE")
        analyzeReelUI(currentReel)
    else
        addLog("❌ No reel UI found for analysis", "ERROR")
    end
end

-- Function untuk test reel events
local function testReelEvents()
    local events = ReplicatedStorage:FindFirstChild("events")
    if events then
        addLog("🧪 Testing reel events...", "TEST")
        
        -- Test debug_giveprogress
        local debugProgress = events:FindFirstChild("debug_giveprogress")
        if debugProgress then
            addLog("Testing debug_giveprogress...", "TEST")
            debugProgress:FireServer(100)
        end
        
        -- Test reelfinished
        local reelfinished = events:FindFirstChild("reelfinished")
        if reelfinished then
            addLog("Testing reelfinished...", "TEST")
            reelfinished:FireServer(100, true)
        end
    else
        addLog("❌ No events folder found", "ERROR")
    end
end

-- Function untuk add log entry
local function addLog(message, category)
    category = category or "INFO"
    local timestamp = tick() -- Gunakan tick() sebagai ganti os.date()
    local logEntry = "[" .. math.floor(timestamp) .. "] [" .. category .. "] " .. message
    
    table.insert(logData, logEntry)
    print(logEntry)
    
    -- Keep only recent entries
    if #logData > maxLogEntries then
        table.remove(logData, 1)
    end
    
    -- Update UI if exists
    if debugUI and debugUI.Parent then
        updateLogDisplay()
    end
end

-- Function untuk create debug UI
local function createDebugUI()
    if debugUI and debugUI.Parent then
        debugUI:Destroy()
    end
    
    -- Main frame
    debugUI = Instance.new("ScreenGui")
    debugUI.Name = "ReelDebuggerUI"
    debugUI.ResetOnSpawn = false
    debugUI.Parent = CoreGui
    
    local mainFrame = Instance.new("Frame")
    mainFrame.Name = "MainFrame"
    mainFrame.Size = UDim2.new(0, 500, 0, 400)
    mainFrame.Position = UDim2.new(0.5, -250, 0.5, -200)
    mainFrame.BackgroundColor3 = Color3.new(0.1, 0.1, 0.1)
    mainFrame.BorderSizePixel = 2
    mainFrame.BorderColor3 = Color3.new(0.3, 0.3, 0.3)
    mainFrame.Active = true
    mainFrame.Draggable = true
    mainFrame.Parent = debugUI
    
    -- Title bar
    local titleBar = Instance.new("Frame")
    titleBar.Name = "TitleBar"
    titleBar.Size = UDim2.new(1, 0, 0, 30)
    titleBar.Position = UDim2.new(0, 0, 0, 0)
    titleBar.BackgroundColor3 = Color3.new(0.2, 0.2, 0.2)
    titleBar.BorderSizePixel = 0
    titleBar.Parent = mainFrame
    
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Name = "TitleLabel"
    titleLabel.Size = UDim2.new(1, -60, 1, 0)
    titleLabel.Position = UDim2.new(0, 5, 0, 0)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = "🔍 Reel Debugger"
    titleLabel.TextColor3 = Color3.new(1, 1, 1)
    titleLabel.TextScaled = true
    titleLabel.Font = Enum.Font.SourceSansBold
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.Parent = titleBar
    
    -- Close button
    local closeButton = Instance.new("TextButton")
    closeButton.Name = "CloseButton"
    closeButton.Size = UDim2.new(0, 25, 0, 25)
    closeButton.Position = UDim2.new(1, -30, 0, 2.5)
    closeButton.BackgroundColor3 = Color3.new(0.8, 0.2, 0.2)
    closeButton.Text = "X"
    closeButton.TextColor3 = Color3.new(1, 1, 1)
    closeButton.TextScaled = true
    closeButton.Font = Enum.Font.SourceSansBold
    closeButton.BorderSizePixel = 0
    closeButton.Parent = titleBar
    
    closeButton.MouseButton1Click:Connect(function()
        debugUI.Enabled = false
    end)
    
    -- Status label
    local statusLabel = Instance.new("TextLabel")
    statusLabel.Name = "StatusLabel"
    statusLabel.Size = UDim2.new(1, -10, 0, 25)
    statusLabel.Position = UDim2.new(0, 5, 0, 35)
    statusLabel.BackgroundTransparency = 1
    statusLabel.Text = "Status: Monitoring..."
    statusLabel.TextColor3 = Color3.new(0.8, 1, 0.8)
    statusLabel.TextScaled = true
    statusLabel.Font = Enum.Font.SourceSans
    statusLabel.TextXAlignment = Enum.TextXAlignment.Left
    statusLabel.Parent = mainFrame
    
    -- Log display
    local logFrame = Instance.new("ScrollingFrame")
    logFrame.Name = "LogFrame"
    logFrame.Size = UDim2.new(1, -10, 1, -110)
    logFrame.Position = UDim2.new(0, 5, 0, 65)
    logFrame.BackgroundColor3 = Color3.new(0.05, 0.05, 0.05)
    logFrame.BorderColor3 = Color3.new(0.3, 0.3, 0.3)
    logFrame.ScrollBarThickness = 8
    logFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
    logFrame.Parent = mainFrame
    
    local logText = Instance.new("TextLabel")
    logText.Name = "LogText"
    logText.Size = UDim2.new(1, -10, 1, 0)
    logText.Position = UDim2.new(0, 5, 0, 0)
    logText.BackgroundTransparency = 1
    logText.Text = "Logs will appear here..."
    logText.TextColor3 = Color3.new(1, 1, 1)
    logText.TextSize = 12
    logText.Font = Enum.Font.Code
    logText.TextXAlignment = Enum.TextXAlignment.Left
    logText.TextYAlignment = Enum.TextYAlignment.Top
    logText.TextWrapped = true
    logText.Parent = logFrame
    
    -- Button frame
    local buttonFrame = Instance.new("Frame")
    buttonFrame.Name = "ButtonFrame"
    buttonFrame.Size = UDim2.new(1, -10, 0, 35)
    buttonFrame.Position = UDim2.new(0, 5, 1, -40)
    buttonFrame.BackgroundTransparency = 1
    buttonFrame.Parent = mainFrame
    
    -- Save button
    local saveButton = Instance.new("TextButton")
    saveButton.Name = "SaveButton"
    saveButton.Size = UDim2.new(0, 100, 1, 0)
    saveButton.Position = UDim2.new(0, 0, 0, 0)
    saveButton.BackgroundColor3 = Color3.new(0.2, 0.6, 0.2)
    saveButton.Text = "💾 Save txt"
    saveButton.TextColor3 = Color3.new(1, 1, 1)
    saveButton.TextScaled = true
    saveButton.Font = Enum.Font.SourceSansBold
    saveButton.BorderSizePixel = 0
    saveButton.Parent = buttonFrame
    
    -- Clear button
    local clearButton = Instance.new("TextButton")
    clearButton.Name = "ClearButton"
    clearButton.Size = UDim2.new(0, 100, 1, 0)
    clearButton.Position = UDim2.new(0, 110, 0, 0)
    clearButton.BackgroundColor3 = Color3.new(0.6, 0.4, 0.2)
    clearButton.Text = "🗑️ Clear"
    clearButton.TextColor3 = Color3.new(1, 1, 1)
    clearButton.TextScaled = true
    clearButton.Font = Enum.Font.SourceSansBold
    clearButton.BorderSizePixel = 0
    clearButton.Parent = buttonFrame
    
    -- Analyze button
    local analyzeButton = Instance.new("TextButton")
    analyzeButton.Name = "AnalyzeButton"
    analyzeButton.Size = UDim2.new(0, 100, 1, 0)
    analyzeButton.Position = UDim2.new(0, 220, 0, 0)
    analyzeButton.BackgroundColor3 = Color3.new(0.2, 0.4, 0.8)
    analyzeButton.Text = "🔍 Analyze"
    analyzeButton.TextColor3 = Color3.new(1, 1, 1)
    analyzeButton.TextScaled = true
    analyzeButton.Font = Enum.Font.SourceSansBold
    analyzeButton.BorderSizePixel = 0
    analyzeButton.Parent = buttonFrame
    
    -- Test button
    local testButton = Instance.new("TextButton")
    testButton.Name = "TestButton"
    testButton.Size = UDim2.new(0, 100, 1, 0)
    testButton.Position = UDim2.new(0, 330, 0, 0)
    testButton.BackgroundColor3 = Color3.new(0.6, 0.2, 0.6)
    testButton.Text = "🧪 Test"
    testButton.TextColor3 = Color3.new(1, 1, 1)
    testButton.TextScaled = true
    testButton.Font = Enum.Font.SourceSansBold
    testButton.BorderSizePixel = 0
    testButton.Parent = buttonFrame
    
    -- Button connections
    saveButton.MouseButton1Click:Connect(function()
        saveLogToFile()
    end)
    
    clearButton.MouseButton1Click:Connect(function()
        clearLogs()
    end)
    
    analyzeButton.MouseButton1Click:Connect(function()
        analyzeCurrentReel()
    end)
    
    testButton.MouseButton1Click:Connect(function()
        testReelEvents()
    end)
    
    return mainFrame.StatusLabel, logFrame.LogText
end

-- Function untuk update log display
function updateLogDisplay()
    if not debugUI or not debugUI.Parent then return end
    
    local logText = debugUI.MainFrame.LogFrame.LogText
    local statusLabel = debugUI.MainFrame.StatusLabel
    
    -- Update log text
    local displayText = table.concat(logData, "\n")
    logText.Text = displayText
    
    -- Auto scroll to bottom
    local logFrame = debugUI.MainFrame.LogFrame
    logFrame.CanvasPosition = Vector2.new(0, math.max(0, logText.TextBounds.Y - logFrame.AbsoluteSize.Y))
    
    -- Update status
    local reelActive = playerGui:FindFirstChild("reel") ~= nil
    statusLabel.Text = "Status: " .. (reelActive and "🎣 REEL ACTIVE" or "⏳ Monitoring...")
    statusLabel.TextColor3 = reelActive and Color3.new(1, 0.8, 0.2) or Color3.new(0.8, 1, 0.8)
end

-- Function untuk monitor child added/removed
local function monitorChildChanges(parent, name)
    if not parent then return end
    
    parent.ChildAdded:Connect(function(child)
        addLog(name .. " gained child: " .. child.Name .. " (" .. child.ClassName .. ")", "CHILD")
        
        if child.Name == "reel" then
            addLog("🎣 REEL MINIGAME DETECTED!", "REEL")
            analyzeReelUI(child)
            monitorReelChanges(child)
        end
    end)
    
    parent.ChildRemoved:Connect(function(child)
        addLog(name .. " lost child: " .. child.Name .. " (" .. child.ClassName .. ")", "CHILD")
        
        if child.Name == "reel" then
            addLog("🎣 REEL MINIGAME ENDED!", "REEL")
        end
    end)
end

-- Function untuk analyze reel UI structure
function analyzeReelUI(reelGui)
    if not reelGui then return end
    
    addLog("📊 ANALYZING REEL UI STRUCTURE:", "ANALYZE")
    
    local function analyzeRecursive(obj, indent)
        local info = string.rep("  ", indent) .. "├─ " .. obj.Name .. " (" .. obj.ClassName .. ")"
        
        if obj:IsA("GuiBase2d") then
            info = info .. " - Visible: " .. tostring(obj.Visible)
            if obj:IsA("GuiObject") then
                info = info .. " - Size: " .. tostring(obj.Size)
                info = info .. " - Position: " .. tostring(obj.Position)
            end
        end
        
        if obj:IsA("TextLabel") or obj:IsA("TextButton") then
            info = info .. " - Text: '" .. obj.Text .. "'"
        end
        
        if obj:IsA("Frame") or obj:IsA("ImageLabel") then
            info = info .. " - BG Color: " .. tostring(obj.BackgroundColor3)
        end
        
        addLog(info, "STRUCTURE")
        
        for _, child in pairs(obj:GetChildren()) do
            analyzeRecursive(child, indent + 1)
        end
    end
    
    analyzeRecursive(reelGui, 0)
end

-- Function untuk monitor reel UI changes
local function monitorReelChanges(reelGui)
    if not reelGui then return end
    
    addLog("👀 Monitoring reel UI changes...", "MONITOR")
    
    local function monitorObject(obj, path)
        -- Monitor property changes
        obj:GetPropertyChangedSignal("Visible"):Connect(function()
            addLog(path .. " visibility changed: " .. tostring(obj.Visible), "PROPERTY")
        end)
        
        if obj:IsA("GuiObject") then
            obj:GetPropertyChangedSignal("Size"):Connect(function()
                addLog(path .. " size changed: " .. tostring(obj.Size), "PROPERTY")
            end)
            
            obj:GetPropertyChangedSignal("Position"):Connect(function()
                addLog(path .. " position changed: " .. tostring(obj.Position), "PROPERTY")
            end)
        end
        
        if obj:IsA("TextLabel") or obj:IsA("TextButton") then
            obj:GetPropertyChangedSignal("Text"):Connect(function()
                addLog(path .. " text changed: '" .. obj.Text .. "'", "PROPERTY")
            end)
        end
        
        if obj:IsA("Frame") or obj:IsA("ImageLabel") then
            obj:GetPropertyChangedSignal("BackgroundColor3"):Connect(function()
                addLog(path .. " color changed: " .. tostring(obj.BackgroundColor3), "PROPERTY")
            end)
        end
        
        -- Monitor children
        obj.ChildAdded:Connect(function(child)
            local childPath = path .. "." .. child.Name
            addLog(path .. " gained child: " .. child.Name, "CHILD")
            monitorObject(child, childPath)
        end)
        
        obj.ChildRemoved:Connect(function(child)
            addLog(path .. " lost child: " .. child.Name, "CHILD")
        end)
        
        -- Monitor existing children
        for _, child in pairs(obj:GetChildren()) do
            local childPath = path .. "." .. child.Name
            monitorObject(child, childPath)
        end
    end
    
    monitorObject(reelGui, "reel")
end

-- Function untuk monitor remote events
local function monitorRemoteEvents()
    local events = ReplicatedStorage:FindFirstChild("events")
    if not events then 
        addLog("❌ No events folder found in ReplicatedStorage", "ERROR")
        return 
    end
    
    addLog("📡 Monitoring remote events...", "EVENTS")
    
    for _, event in pairs(events:GetChildren()) do
        if event:IsA("RemoteEvent") then
            event.OnClientEvent:Connect(function(...)
                local args = {...}
                local argStr = ""
                for i, arg in pairs(args) do
                    if i > 1 then argStr = argStr .. ", " end
                    argStr = argStr .. tostring(arg)
                end
                addLog("📨 " .. event.Name .. "(" .. argStr .. ")", "EVENT")
            end)
        end
    end
end

-- Initialize monitoring systems
addLog("🚀 Reel Debugger initialized", "SYSTEM")
addLog("Creating debug UI...", "SYSTEM")

local statusLabel, logText = createDebugUI()

addLog("✅ Debug UI created", "SYSTEM")
addLog("Setting up monitoring systems...", "SYSTEM")

monitorChildChanges(playerGui, "PlayerGui")
monitorRemoteEvents()

-- Check if reel already exists
local existingReel = playerGui:FindFirstChild("reel")
if existingReel then
    addLog("🎣 Found existing reel UI!", "REEL")
    analyzeReelUI(existingReel)
    monitorReelChanges(existingReel)
else
    addLog("⏳ Waiting for reel minigame...", "SYSTEM")
end

addLog("✅ All monitoring systems active", "SYSTEM")
addLog("📱 Use the UI buttons to save logs, clear, analyze, or test", "SYSTEM")

-- Global commands for manual control
_G.ReelDebugger = {
    toggleUI = function()
        if debugUI and debugUI.Parent then
            debugUI.Enabled = not debugUI.Enabled
            addLog("🎛️ UI toggled: " .. tostring(debugUI.Enabled), "SYSTEM")
        end
    end,
    
    saveLog = function()
        saveLogToFile()
    end,
    
    clearLog = function()
        clearLogs()
    end,
    
    analyze = function()
        analyzeCurrentReel()
    end,
    
    test = function()
        testReelEvents()
    end
}

addLog("🎛️ Global commands available:", "SYSTEM")
addLog("_G.ReelDebugger.toggleUI() - Toggle debug UI", "SYSTEM")
addLog("_G.ReelDebugger.saveLog() - Save current log", "SYSTEM")
addLog("_G.ReelDebugger.clearLog() - Clear current log", "SYSTEM")
addLog("_G.ReelDebugger.analyze() - Analyze current reel", "SYSTEM")
addLog("_G.ReelDebugger.test() - Test reel events", "SYSTEM")
