local AutoReel = {}

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local GuiService = game:GetService("GuiService")
local VirtualInputManager = game:GetService("VirtualInputManager")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local isAutoReelEnabled = false
local reelConnection
local reelGui
local fishBar
local playerBar
local reelStartTime = 0
local hasInitializedPosition = false

local tapSensitivity = 0.5
local holdSensitivity = 0.5

local screenGui
local mainFrame
local titleLabel
local toggleButton
local statusLabel

local setupSliders
local toggleAutoReel
local autoReelLogic

setupSliders = function(handle, background, label, sliderType)
    local dragging = false
    
    handle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
        end
    end)
    
    handle.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local bgPos = background.AbsolutePosition.X
            local bgSize = background.AbsoluteSize.X
            local mouseX = input.Position.X
            
            local relativeX = (mouseX - bgPos) / bgSize
            relativeX = math.max(0, math.min(1, relativeX))
            
            handle.Position = UDim2.new(relativeX, -8, 0.5, -8)
            
            local percentage = math.floor(relativeX * 100)
            local value = 0.1 + (relativeX * 0.9)
            
            if sliderType == "tap" then
                tapSensitivity = value
                label.Text = "Tap Sensitivity: " .. percentage .. "%"
            else
                holdSensitivity = value
                label.Text = "Hold Sensitivity: " .. percentage .. "%"
            end
        end
    end)
    
    handle.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
    
    background.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            local bgPos = background.AbsolutePosition.X
            local bgSize = background.AbsoluteSize.X
            local mouseX = input.Position.X
            
            local relativeX = (mouseX - bgPos) / bgSize
            relativeX = math.max(0, math.min(1, relativeX))
            
            handle.Position = UDim2.new(relativeX, -8, 0.5, -8)
            
            local percentage = math.floor(relativeX * 100)
            local value = 0.1 + (relativeX * 0.9)
            
            if sliderType == "tap" then
                tapSensitivity = value
                label.Text = "Tap Sensitivity: " .. percentage .. "%"
            else
                holdSensitivity = value
                label.Text = "Hold Sensitivity: " .. percentage .. "%"
            end
        end
    end)
end

toggleAutoReel = function()
    isAutoReelEnabled = not isAutoReelEnabled
    
    if isAutoReelEnabled then
        toggleButton.Text = "ON"
        toggleButton.BackgroundColor3 = Color3.fromRGB(40, 167, 69)
        statusLabel.Text = "Status: Active"
        
        reelConnection = RunService.Heartbeat:Connect(autoReelLogic)
    else
        toggleButton.Text = "OFF"
        toggleButton.BackgroundColor3 = Color3.fromRGB(220, 53, 69)
        statusLabel.Text = "Status: Inactive"
        
        if reelConnection then
            reelConnection:Disconnect()
            reelConnection = nil
        end
    end
end

local function createUI()
    screenGui = Instance.new("ScreenGui")
    screenGui.Name = "AutoReelGui"
    screenGui.Parent = playerGui
    screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    
    mainFrame = Instance.new("Frame")
    mainFrame.Name = "MainFrame"
    mainFrame.Size = UDim2.new(0, 280, 0, 200)
    mainFrame.Position = UDim2.new(0.5, -140, 0.1, 0)
    mainFrame.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
    mainFrame.BorderSizePixel = 0
    mainFrame.Parent = screenGui
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = mainFrame
    
    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(100, 100, 100)
    stroke.Thickness = 1
    stroke.Parent = mainFrame
    
    titleLabel = Instance.new("TextLabel")
    titleLabel.Name = "TitleLabel"
    titleLabel.Size = UDim2.new(1, 0, 0, 30)
    titleLabel.Position = UDim2.new(0, 0, 0, 0)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = "Auto Reel"
    titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    titleLabel.TextScaled = true
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.Parent = mainFrame
    
    toggleButton = Instance.new("TextButton")
    toggleButton.Name = "ToggleButton"
    toggleButton.Size = UDim2.new(0.8, 0, 0, 30)
    toggleButton.Position = UDim2.new(0.1, 0, 0.2, 0)
    toggleButton.BackgroundColor3 = Color3.fromRGB(220, 53, 69)
    toggleButton.BorderSizePixel = 0
    toggleButton.Text = "OFF"
    toggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    toggleButton.TextScaled = true
    toggleButton.Font = Enum.Font.GothamBold
    toggleButton.Parent = mainFrame
    
    local toggleCorner = Instance.new("UICorner")
    toggleCorner.CornerRadius = UDim.new(0, 6)
    toggleCorner.Parent = toggleButton
    
    local tapLabel = Instance.new("TextLabel")
    tapLabel.Name = "TapLabel"
    tapLabel.Size = UDim2.new(1, 0, 0, 20)
    tapLabel.Position = UDim2.new(0, 0, 0.37, 0)
    tapLabel.BackgroundTransparency = 1
    tapLabel.Text = "Tap Sensitivity: 50%"
    tapLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    tapLabel.TextScaled = true
    tapLabel.Font = Enum.Font.Gotham
    tapLabel.Parent = mainFrame
    
    local tapSliderBg = Instance.new("Frame")
    tapSliderBg.Name = "TapSliderBg"
    tapSliderBg.Size = UDim2.new(0.8, 0, 0, 8)
    tapSliderBg.Position = UDim2.new(0.1, 0, 0.47, 0)
    tapSliderBg.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
    tapSliderBg.BorderSizePixel = 0
    tapSliderBg.Parent = mainFrame
    
    local tapSliderCorner = Instance.new("UICorner")
    tapSliderCorner.CornerRadius = UDim.new(0, 4)
    tapSliderCorner.Parent = tapSliderBg
    
    local tapSliderHandle = Instance.new("TextButton")
    tapSliderHandle.Name = "TapSliderHandle"
    tapSliderHandle.Size = UDim2.new(0, 16, 0, 16)
    tapSliderHandle.Position = UDim2.new(0.5, -8, 0.5, -8)
    tapSliderHandle.BackgroundColor3 = Color3.fromRGB(0, 150, 255)
    tapSliderHandle.BorderSizePixel = 0
    tapSliderHandle.Text = ""
    tapSliderHandle.Parent = tapSliderBg
    
    local tapHandleCorner = Instance.new("UICorner")
    tapHandleCorner.CornerRadius = UDim.new(0, 8)
    tapHandleCorner.Parent = tapSliderHandle
    
    local holdLabel = Instance.new("TextLabel")
    holdLabel.Name = "HoldLabel"
    holdLabel.Size = UDim2.new(1, 0, 0, 20)
    holdLabel.Position = UDim2.new(0, 0, 0.57, 0)
    holdLabel.BackgroundTransparency = 1
    holdLabel.Text = "Hold Sensitivity: 50%"
    holdLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    holdLabel.TextScaled = true
    holdLabel.Font = Enum.Font.Gotham
    holdLabel.Parent = mainFrame
    
    local holdSliderBg = Instance.new("Frame")
    holdSliderBg.Name = "HoldSliderBg"
    holdSliderBg.Size = UDim2.new(0.8, 0, 0, 8)
    holdSliderBg.Position = UDim2.new(0.1, 0, 0.67, 0)
    holdSliderBg.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
    holdSliderBg.BorderSizePixel = 0
    holdSliderBg.Parent = mainFrame
    
    local holdSliderCorner = Instance.new("UICorner")
    holdSliderCorner.CornerRadius = UDim.new(0, 4)
    holdSliderCorner.Parent = holdSliderBg
    
    local holdSliderHandle = Instance.new("TextButton")
    holdSliderHandle.Name = "HoldSliderHandle"
    holdSliderHandle.Size = UDim2.new(0, 16, 0, 16)
    holdSliderHandle.Position = UDim2.new(0.5, -8, 0.5, -8)
    holdSliderHandle.BackgroundColor3 = Color3.fromRGB(255, 100, 0)
    holdSliderHandle.BorderSizePixel = 0
    holdSliderHandle.Text = ""
    holdSliderHandle.Parent = holdSliderBg
    
    local holdHandleCorner = Instance.new("UICorner")
    holdHandleCorner.CornerRadius = UDim.new(0, 8)
    holdHandleCorner.Parent = holdSliderHandle
    
    statusLabel = Instance.new("TextLabel")
    statusLabel.Name = "StatusLabel"
    statusLabel.Size = UDim2.new(1, 0, 0, 18)
    statusLabel.Position = UDim2.new(0, 0, 0.77, 0)
    statusLabel.BackgroundTransparency = 1
    statusLabel.Text = "Status: Inactive"
    statusLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    statusLabel.TextScaled = true
    statusLabel.Font = Enum.Font.Gotham
    statusLabel.Parent = mainFrame
    
    local debugLabel = Instance.new("TextLabel")
    debugLabel.Name = "DebugLabel"
    debugLabel.Size = UDim2.new(1, 0, 0, 15)
    debugLabel.Position = UDim2.new(0, 0, 0.88, 0)
    debugLabel.BackgroundTransparency = 1
    debugLabel.Text = "Debug: --"
    debugLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
    debugLabel.TextScaled = true
    debugLabel.Font = Enum.Font.Gotham
    debugLabel.Parent = mainFrame
    
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
    
    setupSliders(tapSliderHandle, tapSliderBg, tapLabel, "tap")
    setupSliders(holdSliderHandle, holdSliderBg, holdLabel, "hold")
end

local function findReelElements()
    local reelScreenGui = playerGui:FindFirstChild("reel")
    if not reelScreenGui then
        return false
    end
    
    reelGui = reelScreenGui
    
    local function searchInGui(parent, depth)
        if depth > 5 then return end
        
        for _, child in pairs(parent:GetChildren()) do
            if child:IsA("Frame") then
                local fish = child:FindFirstChild("fish") or child:FindFirstChild("licon") or child:FindFirstChild("ricon")
                if fish then
                    fishBar = child
                end
                
                local playerBarFound = child:FindFirstChild("playerbar") or child:FindFirstChild("player")
                if playerBarFound then
                    playerBar = playerBarFound
                    if not fishBar then fishBar = child end
                end
                
                searchInGui(child, depth + 1)
            end
        end
    end
    
    searchInGui(reelGui, 0)
    
    if not fishBar and not playerBar then
        local container = reelGui:FindFirstChildOfClass("Frame")
        if container then
            fishBar = container
            playerBar = container:FindFirstChildOfClass("Frame")
        end
    end
    
    return fishBar and playerBar
end

local function getFishPosition()
    if not fishBar then return 0.5 end
    
    local fish = fishBar:FindFirstChild("fish") or fishBar:FindFirstChild("goal") or fishBar:FindFirstChild("licon") or fishBar:FindFirstChild("ricon")
    if fish then
        local fishPos = fish.Position.X.Scale + (fish.Size.X.Scale / 2)
        return math.max(0, math.min(1, fishPos))
    end
    
    for _, child in pairs(fishBar:GetDescendants()) do
        if child:IsA("Frame") and (child.Name:lower():find("fish") or child.Name:lower():find("goal")) then
            local fishPos = child.Position.X.Scale + (child.Size.X.Scale / 2)
            return math.max(0, math.min(1, fishPos))
        end
    end
    
    for _, child in pairs(fishBar:GetDescendants()) do
        if child:IsA("ImageLabel") and (child.Name:lower():find("fish") or child.Name:lower():find("icon")) then
            local fishPos = child.Position.X.Scale + (child.Size.X.Scale / 2)
            return math.max(0, math.min(1, fishPos))
        end
    end
    
    return 0.5
end

local function getPlayerBarPosition()
    if not playerBar then return 0.5 end
    
    local playerPos = playerBar.Position.X.Scale + (playerBar.Size.X.Scale / 2)
    return math.max(0, math.min(1, playerPos))
end

local function tapAction()
    local tapDuration = 0.02 + (tapSensitivity * 0.06)
    
    pcall(function()
        VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.Space, false, game)
        wait(tapDuration)
        VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.Space, false, game)
    end)
    
    pcall(function()
        VirtualInputManager:SendMouseButtonEvent(0, 0, 0, true, game, 1)
        wait(tapDuration)
        VirtualInputManager:SendMouseButtonEvent(0, 0, 0, false, game, 1)
    end)
end

local function holdAction()
    local holdDuration = 0.05 + (holdSensitivity * 0.1)
    
    pcall(function()
        VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.Space, false, game)
        wait(holdDuration)
        VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.Space, false, game)
    end)
    
    pcall(function()
        VirtualInputManager:SendMouseButtonEvent(0, 0, 0, true, game, 1)
        wait(holdDuration)
        VirtualInputManager:SendMouseButtonEvent(0, 0, 0, false, game, 1)
    end)
end

local function strongHoldAction()
    local strongDuration = 0.08 + (holdSensitivity * 0.12)
    
    for i = 1, 2 do
        pcall(function()
            VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.Space, false, game)
            wait(strongDuration)
            VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.Space, false, game)
            wait(0.02)
        end)
    end
end

autoReelLogic = function()
    if not isAutoReelEnabled then return end
    
    if not findReelElements() then
        statusLabel.Text = "Status: No reel detected"
        hasInitializedPosition = false
        return
    end
    
    if not hasInitializedPosition then
        reelStartTime = tick()
        hasInitializedPosition = true
        statusLabel.Text = "Status: Initializing..."
    end
    
    local currentTime = tick()
    local timeSinceStart = currentTime - reelStartTime
    
    local fishPos = getFishPosition()
    local playerPos = getPlayerBarPosition()
    local difference = fishPos - playerPos
    
    local debugLabel = screenGui.MainFrame:FindFirstChild("DebugLabel")
    if debugLabel then
        debugLabel.Text = string.format("F:%.2f P:%.2f D:%.2f T:%.1f", fishPos, playerPos, difference, timeSinceStart)
    end
    
    if timeSinceStart < 1.5 then
        local centerTarget = 0.5
        local centerDifference = centerTarget - playerPos
        
        if centerDifference > 0.15 then
            strongHoldAction()
            statusLabel.Text = "Status: Strong Centering"
        elseif centerDifference > 0.08 then
            holdAction()
            statusLabel.Text = "Status: Centering (Hold)"
        elseif centerDifference > 0.03 then
            tapAction()
            statusLabel.Text = "Status: Centering (Tap)"
        else
            statusLabel.Text = "Status: Centered, Ready"
        end
        return
    end
    
    local deadZone = 0.03
    
    if difference > deadZone then
        if difference > 0.15 then
            holdAction()
            statusLabel.Text = "Status: Hold (Fast Right)"
        elseif difference > 0.06 then
            tapAction()
            statusLabel.Text = "Status: Tap (Slow Right)"
        else
            local lightTapDuration = 0.01 + (tapSensitivity * 0.02)
            pcall(function()
                VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.Space, false, game)
                wait(lightTapDuration)
                VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.Space, false, game)
            end)
            statusLabel.Text = "Status: Light Tap"
        end
    else
        statusLabel.Text = "Status: Drift Left"
    end
end

function AutoReel.init()
    createUI()
    
    toggleButton.MouseButton1Click:Connect(toggleAutoReel)
    
    playerGui.ChildAdded:Connect(function(child)
        if child.Name == "reel" and isAutoReelEnabled then
            wait(0.5)
            hasInitializedPosition = false
            findReelElements()
        end
    end)
    
    playerGui.ChildRemoved:Connect(function(child)
        if child.Name == "reel" then
            statusLabel.Text = "Status: Reel ended"
            hasInitializedPosition = false
        end
    end)
    
    print("Auto Reel initialized! Use the GUI to toggle ON/OFF")
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
