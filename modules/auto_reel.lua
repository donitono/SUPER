local AutoReel = {}

-- Services
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local GuiService = game:GetService("GuiService")
local VirtualInputManager = game:GetService("VirtualInputManager")

-- Variables
local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local isAutoReelEnabled = false
local reelConnection
local reelGui
local fishBar
local playerBar

-- UI Elements
local screenGui
local mainFrame
local titleLabel
local toggleButton
local statusLabel

-- Create UI
local function createUI()
    -- Main ScreenGui
    screenGui = Instance.new("ScreenGui")
    screenGui.Name = "AutoReelGui"
    screenGui.Parent = playerGui
    screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    
    -- Main Frame
    mainFrame = Instance.new("Frame")
    mainFrame.Name = "MainFrame"
    mainFrame.Size = UDim2.new(0, 250, 0, 120)
    mainFrame.Position = UDim2.new(0.5, -125, 0.1, 0)
    mainFrame.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
    mainFrame.BorderSizePixel = 0
    mainFrame.Parent = screenGui
    
    -- UI Corner
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = mainFrame
    
    -- UI Stroke
    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(100, 100, 100)
    stroke.Thickness = 1
    stroke.Parent = mainFrame
    
    -- Title Label
    titleLabel = Instance.new("TextLabel")
    titleLabel.Name = "TitleLabel"
    titleLabel.Size = UDim2.new(1, 0, 0, 30)
    titleLabel.Position = UDim2.new(0, 0, 0, 0)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = "🎣 Auto Reel"
    titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    titleLabel.TextScaled = true
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.Parent = mainFrame
    
    -- Toggle Button
    toggleButton = Instance.new("TextButton")
    toggleButton.Name = "ToggleButton"
    toggleButton.Size = UDim2.new(0.8, 0, 0, 35)
    toggleButton.Position = UDim2.new(0.1, 0, 0.35, 0)
    toggleButton.BackgroundColor3 = Color3.fromRGB(220, 53, 69)
    toggleButton.BorderSizePixel = 0
    toggleButton.Text = "OFF"
    toggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    toggleButton.TextScaled = true
    toggleButton.Font = Enum.Font.GothamBold
    toggleButton.Parent = mainFrame
    
    -- Toggle Button Corner
    local toggleCorner = Instance.new("UICorner")
    toggleCorner.CornerRadius = UDim.new(0, 6)
    toggleCorner.Parent = toggleButton
    
    -- Status Label
    statusLabel = Instance.new("TextLabel")
    statusLabel.Name = "StatusLabel"
    statusLabel.Size = UDim2.new(1, 0, 0, 20)
    statusLabel.Position = UDim2.new(0, 0, 0.7, 0)
    statusLabel.BackgroundTransparency = 1
    statusLabel.Text = "Status: Inactive"
    statusLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    statusLabel.TextScaled = true
    statusLabel.Font = Enum.Font.Gotham
    statusLabel.Parent = mainFrame
    
    -- Debug Label for positions
    local debugLabel = Instance.new("TextLabel")
    debugLabel.Name = "DebugLabel"
    debugLabel.Size = UDim2.new(1, 0, 0, 15)
    debugLabel.Position = UDim2.new(0, 0, 0.87, 0)
    debugLabel.BackgroundTransparency = 1
    debugLabel.Text = "Debug: --"
    debugLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
    debugLabel.TextScaled = true
    debugLabel.Font = Enum.Font.Gotham
    debugLabel.Parent = mainFrame
    
    -- Make draggable
    local dragging = false
    local dragStart = nil
    local startPos = nil
    
    mainFrame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = mainFrame.Position
        end
    end)
    
    mainFrame.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragStart
            mainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
    
    mainFrame.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
end

-- Find reel GUI elements
local function findReelElements()
    local reelScreenGui = playerGui:FindFirstChild("reel")
    if not reelScreenGui then
        return false
    end
    
    reelGui = reelScreenGui
    
    -- More thorough search for reel elements
    local function searchInGui(parent, depth)
        if depth > 5 then return end -- Prevent infinite recursion
        
        for _, child in pairs(parent:GetChildren()) do
            if child:IsA("Frame") then
                -- Look for fish element (the moving target)
                local fish = child:FindFirstChild("fish") or child:FindFirstChild("licon") or child:FindFirstChild("ricon")
                if fish then
                    fishBar = child
                end
                
                -- Look for player bar (the controllable white bar)  
                local playerBarFound = child:FindFirstChild("playerbar") or child:FindFirstChild("player")
                if playerBarFound then
                    playerBar = playerBarFound
                    if not fishBar then fishBar = child end
                end
                
                -- Recursive search
                searchInGui(child, depth + 1)
            end
        end
    end
    
    searchInGui(reelGui, 0)
    
    -- Fallback: use first frame as container
    if not fishBar and not playerBar then
        local container = reelGui:FindFirstChildOfClass("Frame")
        if container then
            fishBar = container
            playerBar = container:FindFirstChildOfClass("Frame")
        end
    end
    
    return fishBar and playerBar
end

-- Calculate fish position and player bar position
local function getFishPosition()
    if not fishBar then return 0.5 end
    
    -- Method 1: Look for fish/goal indicator elements
    local fish = fishBar:FindFirstChild("fish") or fishBar:FindFirstChild("goal") or fishBar:FindFirstChild("licon") or fishBar:FindFirstChild("ricon")
    if fish then
        local fishPos = fish.Position.X.Scale + (fish.Size.X.Scale / 2)
        -- Normalize position to 0-1 range
        return math.max(0, math.min(1, fishPos))
    end
    
    -- Method 2: Look for progress bar or fish indicator
    for _, child in pairs(fishBar:GetDescendants()) do
        if child:IsA("Frame") and (child.Name:lower():find("fish") or child.Name:lower():find("goal")) then
            local fishPos = child.Position.X.Scale + (child.Size.X.Scale / 2)
            return math.max(0, math.min(1, fishPos))
        end
    end
    
    -- Method 3: Look for ImageLabel fish indicators
    for _, child in pairs(fishBar:GetDescendants()) do
        if child:IsA("ImageLabel") and (child.Name:lower():find("fish") or child.Name:lower():find("icon")) then
            local fishPos = child.Position.X.Scale + (child.Size.X.Scale / 2)
            return math.max(0, math.min(1, fishPos))
        end
    end
    
    -- Fallback: return center position
    return 0.5
end

local function getPlayerBarPosition()
    if not playerBar then return 0.5 end
    
    -- Get the actual player bar position
    local playerPos = playerBar.Position.X.Scale + (playerBar.Size.X.Scale / 2)
    
    -- Normalize position to 0-1 range  
    return math.max(0, math.min(1, playerPos))
end

-- Control methods
local function tapAction()
    -- Method 1: Virtual Input (Space key for light tap)
    pcall(function()
        VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.Space, false, game)
        wait(0.03) -- Short tap for light movement
        VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.Space, false, game)
    end)
    
    -- Method 2: Mouse button simulation  
    pcall(function()
        VirtualInputManager:SendMouseButtonEvent(0, 0, 0, true, game, 1)
        wait(0.03)
        VirtualInputManager:SendMouseButtonEvent(0, 0, 0, false, game, 1)
    end)
end

local function holdAction()
    -- Method 1: Longer space key hold for stronger movement
    pcall(function()
        VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.Space, false, game)
        wait(0.08) -- Longer hold for more movement
        VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.Space, false, game)
    end)
    
    -- Method 2: Mouse hold simulation
    pcall(function()
        VirtualInputManager:SendMouseButtonEvent(0, 0, 0, true, game, 1)
        wait(0.08)
        VirtualInputManager:SendMouseButtonEvent(0, 0, 0, false, game, 1)
    end)
end

-- Auto reel logic
local function autoReelLogic()
    if not isAutoReelEnabled then return end
    
    if not findReelElements() then
        statusLabel.Text = "Status: No reel detected"
        return
    end
    
    local fishPos = getFishPosition()
    local playerPos = getPlayerBarPosition()
    local difference = fishPos - playerPos
    
    -- Update debug info
    local debugLabel = screenGui.MainFrame:FindFirstChild("DebugLabel")
    if debugLabel then
        debugLabel.Text = string.format("F:%.2f P:%.2f D:%.2f", fishPos, playerPos, difference)
    end
    
    -- Improved control logic based on natural physics
    -- Bar naturally drifts left, so we only need to input when fish is to the right
    
    local deadZone = 0.03 -- Small dead zone to prevent jittering
    
    if difference > deadZone then
        -- Fish is to the right of player bar - need to move right
        if difference > 0.15 then
            -- Fish is far right - use hold for strong movement
            holdAction()
            statusLabel.Text = "Status: Hold (Fast Right)"
        elseif difference > 0.06 then
            -- Fish is moderately right - use tap for gentle movement  
            tapAction()
            statusLabel.Text = "Status: Tap (Slow Right)"
        else
            -- Fish is slightly right - very light tap
            pcall(function()
                VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.Space, false, game)
                wait(0.01) -- Very short tap
                VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.Space, false, game)
            end)
            statusLabel.Text = "Status: Light Tap"
        end
    else
        -- Fish is to the left or in dead zone - let bar drift left naturally
        statusLabel.Text = "Status: Drift Left"
        -- No input - bar will move left naturally
    end
end

-- Toggle auto reel
local function toggleAutoReel()
    isAutoReelEnabled = not isAutoReelEnabled
    
    if isAutoReelEnabled then
        toggleButton.Text = "ON"
        toggleButton.BackgroundColor3 = Color3.fromRGB(40, 167, 69)
        statusLabel.Text = "Status: Active"
        
        -- Start auto reel loop
        reelConnection = RunService.Heartbeat:Connect(autoReelLogic)
    else
        toggleButton.Text = "OFF"
        toggleButton.BackgroundColor3 = Color3.fromRGB(220, 53, 69)
        statusLabel.Text = "Status: Inactive"
        
        -- Stop auto reel loop
        if reelConnection then
            reelConnection:Disconnect()
            reelConnection = nil
        end
    end
end

-- Initialize
function AutoReel.init()
    createUI()
    
    -- Connect toggle button
    toggleButton.MouseButton1Click:Connect(toggleAutoReel)
    
    -- Auto-detect reel minigame start
    playerGui.ChildAdded:Connect(function(child)
        if child.Name == "reel" and isAutoReelEnabled then
            wait(0.5) -- Wait for reel GUI to fully load
            findReelElements()
        end
    end)
    
    -- Auto-disable when reel ends
    playerGui.ChildRemoved:Connect(function(child)
        if child.Name == "reel" then
            statusLabel.Text = "Status: Reel ended"
        end
    end)
    
    print("🎣 Auto Reel initialized! Use the GUI to toggle ON/OFF")
end

function AutoReel.destroy()
    if screenGui then
        screenGui:Destroy()
    end
    
    if reelConnection then
        reelConnection:Disconnect()
    end
    
    isAutoReelEnabled = false
end

return AutoReel
