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
    statusLabel.Size = UDim2.new(1, 0, 0, 25)
    statusLabel.Position = UDim2.new(0, 0, 0.75, 0)
    statusLabel.BackgroundTransparency = 1
    statusLabel.Text = "Status: Inactive"
    statusLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    statusLabel.TextScaled = true
    statusLabel.Font = Enum.Font.Gotham
    statusLabel.Parent = mainFrame
    
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
    
    -- Look for fish bar (the black line that moves)
    fishBar = reelGui:FindFirstChild("bar") or reelGui:FindFirstChildOfClass("Frame")
    if fishBar then
        -- Look for player bar (white bar that we control)
        playerBar = fishBar:FindFirstChild("playerbar") or fishBar:FindFirstChild("player")
        if not playerBar then
            -- Look in different structure
            for _, child in pairs(fishBar:GetChildren()) do
                if child:IsA("Frame") and child.Name:lower():find("player") then
                    playerBar = child
                    break
                end
            end
        end
    end
    
    return fishBar and playerBar
end

-- Calculate fish position and player bar position
local function getFishPosition()
    if not fishBar then return 0.5 end
    
    -- Try to find fish indicator element
    local fish = fishBar:FindFirstChild("fish") or fishBar:FindFirstChild("goal")
    if fish then
        return fish.Position.X.Scale + (fish.Size.X.Scale / 2)
    end
    
    -- Fallback: use bar position if fish element not found
    return fishBar.Position.X.Scale + (fishBar.Size.X.Scale / 2)
end

local function getPlayerBarPosition()
    if not playerBar then return 0.5 end
    
    return playerBar.Position.X.Scale + (playerBar.Size.X.Scale / 2)
end

-- Control methods
local function tapAction()
    -- Method 1: Virtual Input (Space/Return key)
    pcall(function()
        VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.Space, false, game)
        wait(0.05)
        VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.Space, false, game)
    end)
    
    -- Method 2: Mouse click simulation
    pcall(function()
        local mouse = game.Players.LocalPlayer:GetMouse()
        mouse.Button1Down:Connect(function() end)
        mouse.Button1Up:Connect(function() end)
    end)
end

local function holdAction()
    -- Method 1: Hold Space key
    pcall(function()
        VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.Space, false, game)
        wait(0.1)
        VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.Space, false, game)
    end)
    
    -- Method 2: Rapid taps for hold effect
    for i = 1, 3 do
        tapAction()
        wait(0.02)
    end
end

-- Auto reel logic
local function autoReelLogic()
    if not isAutoReelEnabled then return end
    
    if not findReelElements() then
        statusLabel.Text = "Status: No reel detected"
        return
    end
    
    statusLabel.Text = "Status: Reeling..."
    
    local fishPos = getFishPosition()
    local playerPos = getPlayerBarPosition()
    local difference = fishPos - playerPos
    
    -- Control logic based on fish position
    if math.abs(difference) > 0.05 then -- Dead zone to prevent jittering
        if difference > 0.1 then
            -- Fish is far to the right, hold for faster movement
            holdAction()
        elseif difference > 0.02 then
            -- Fish is slightly to the right, tap for slow movement
            tapAction()
        end
        -- If difference is negative or small, let bar drift left naturally
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
