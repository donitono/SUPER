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
local reelStartTime = 0
local hasInitializedPosition = false

-- Sensitivity settings
local tapSensitivity = 0.5 -- 0.1 to 1.0 (affects tap duration)
local holdSensitivity = 0.5 -- 0.1 to 1.0 (affects hold duration)

-- UI Elements
local screenGui
local mainFrame
local titleLabel
local toggleButton
local statusLabel

-- Forward declarations
local setupMobileSliders
local toggleAutoReel
local autoReelLogic

-- Mobile-friendly slider setup
setupMobileSliders = function(handle, background, label, sliderType)
    local function updateSlider()
        local currentValue = sliderType == "tap" and tapSensitivity or holdSensitivity
        local percentage = math.floor((currentValue - 0.1) / 0.9 * 100)
        handle.Position = UDim2.new((currentValue - 0.1) / 0.9, -8, 0.5, -8)
        label.Text = (sliderType == "tap" and "Tap" or "Hold") .. " Sensitivity: " .. percentage .. "%"
    end
    
    -- Decrease button
    local decreaseBtn = Instance.new("TextButton")
    decreaseBtn.Size = UDim2.new(0, 25, 0, 25)
    decreaseBtn.Position = UDim2.new(0, -30, 0.5, -12)
    decreaseBtn.BackgroundColor3 = Color3.fromRGB(70, 130, 180)
    decreaseBtn.Text = "-"
    decreaseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    decreaseBtn.TextScaled = true
    decreaseBtn.Font = Enum.Font.GothamBold
    decreaseBtn.Parent = background
    
    local decreaseCorner = Instance.new("UICorner")
    decreaseCorner.CornerRadius = UDim.new(0, 12)
    decreaseCorner.Parent = decreaseBtn
    
    -- Increase button
    local increaseBtn = Instance.new("TextButton")
    increaseBtn.Size = UDim2.new(0, 25, 0, 25)
    increaseBtn.Position = UDim2.new(1, 5, 0.5, -12)
    increaseBtn.BackgroundColor3 = Color3.fromRGB(70, 130, 180)
    increaseBtn.Text = "+"
    increaseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    increaseBtn.TextScaled = true
    increaseBtn.Font = Enum.Font.GothamBold
    increaseBtn.Parent = background
    
    local increaseCorner = Instance.new("UICorner")
    increaseCorner.CornerRadius = UDim.new(0, 12)
    increaseCorner.Parent = increaseBtn
    
    -- Button functions
    decreaseBtn.MouseButton1Click:Connect(function()
        if sliderType == "tap" then
            tapSensitivity = math.max(0.1, tapSensitivity - 0.1)
        else
            holdSensitivity = math.max(0.1, holdSensitivity - 0.1)
        end
        updateSlider()
    end)
    
    increaseBtn.MouseButton1Click:Connect(function()
        if sliderType == "tap" then
            tapSensitivity = math.min(1.0, tapSensitivity + 0.1)
        else
            holdSensitivity = math.min(1.0, holdSensitivity + 0.1)
        end
        updateSlider()
    end)
    
    -- Touch support for slider handle (improved)
    local dragging = false
    
    handle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
        end
    end)
    
    -- Global input handling for better mobile support
    local function handleInput(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local bgPos = background.AbsolutePosition.X
            local bgSize = background.AbsoluteSize.X
            local inputX = input.Position.X
            
            local relativeX = (inputX - bgPos) / bgSize
            relativeX = math.max(0, math.min(1, relativeX))
            
            local value = 0.1 + (relativeX * 0.9)
            
            if sliderType == "tap" then
                tapSensitivity = value
            else
                holdSensitivity = value
            end
            
            updateSlider()
        end
    end
    
    UserInputService.InputChanged:Connect(handleInput)
    
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)
    
    -- Background tap support
    background.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            local bgPos = background.AbsolutePosition.X
            local bgSize = background.AbsoluteSize.X
            local inputX = input.Position.X
            
            local relativeX = (inputX - bgPos) / bgSize
            relativeX = math.max(0, math.min(1, relativeX))
            
            local value = 0.1 + (relativeX * 0.9)
            
            if sliderType == "tap" then
                tapSensitivity = value
            else
                holdSensitivity = value
            end
            
            updateSlider()
        end
    end)
    
    -- Initialize slider position
    updateSlider()
end

-- Toggle auto reel function
toggleAutoReel = function()
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

-- Create UI
local function createUI()
    -- Main ScreenGui
    screenGui = Instance.new("ScreenGui")
    screenGui.Name = "AutoReelGui"
    screenGui.Parent = playerGui
    screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    
    -- Main Frame (wider for mobile buttons)
    mainFrame = Instance.new("Frame")
    mainFrame.Name = "MainFrame"
    mainFrame.Size = UDim2.new(0, 320, 0, 200)
    mainFrame.Position = UDim2.new(0.5, -160, 0.1, 0)
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
    titleLabel.Text = "🎣 Auto Reel (Mobile)"
    titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    titleLabel.TextScaled = true
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.Parent = mainFrame
    
    -- Toggle Button
    toggleButton = Instance.new("TextButton")
    toggleButton.Name = "ToggleButton"
    toggleButton.Size = UDim2.new(0.8, 0, 0, 35)
    toggleButton.Position = UDim2.new(0.1, 0, 0.2, 0)
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
    
    -- Tap Sensitivity Label
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
    
    -- Tap Sensitivity Slider Background
    local tapSliderBg = Instance.new("Frame")
    tapSliderBg.Name = "TapSliderBg"
    tapSliderBg.Size = UDim2.new(0.6, 0, 0, 8)
    tapSliderBg.Position = UDim2.new(0.2, 0, 0.47, 0)
    tapSliderBg.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
    tapSliderBg.BorderSizePixel = 0
    tapSliderBg.Parent = mainFrame
    
    local tapSliderCorner = Instance.new("UICorner")
    tapSliderCorner.CornerRadius = UDim.new(0, 4)
    tapSliderCorner.Parent = tapSliderBg
    
    -- Tap Sensitivity Slider Handle
    local tapSliderHandle = Instance.new("TextButton")
    tapSliderHandle.Name = "TapSliderHandle"
    tapSliderHandle.Size = UDim2.new(0, 20, 0, 20)
    tapSliderHandle.Position = UDim2.new(0.5, -10, 0.5, -10)
    tapSliderHandle.BackgroundColor3 = Color3.fromRGB(0, 150, 255)
    tapSliderHandle.BorderSizePixel = 0
    tapSliderHandle.Text = ""
    tapSliderHandle.Parent = tapSliderBg
    
    local tapHandleCorner = Instance.new("UICorner")
    tapHandleCorner.CornerRadius = UDim.new(0, 10)
    tapHandleCorner.Parent = tapSliderHandle
    
    -- Hold Sensitivity Label
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
    
    -- Hold Sensitivity Slider Background
    local holdSliderBg = Instance.new("Frame")
    holdSliderBg.Name = "HoldSliderBg"
    holdSliderBg.Size = UDim2.new(0.6, 0, 0, 8)
    holdSliderBg.Position = UDim2.new(0.2, 0, 0.67, 0)
    holdSliderBg.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
    holdSliderBg.BorderSizePixel = 0
    holdSliderBg.Parent = mainFrame
    
    local holdSliderCorner = Instance.new("UICorner")
    holdSliderCorner.CornerRadius = UDim.new(0, 4)
    holdSliderCorner.Parent = holdSliderBg
    
    -- Hold Sensitivity Slider Handle
    local holdSliderHandle = Instance.new("TextButton")
    holdSliderHandle.Name = "HoldSliderHandle"
    holdSliderHandle.Size = UDim2.new(0, 20, 0, 20)
    holdSliderHandle.Position = UDim2.new(0.5, -10, 0.5, -10)
    holdSliderHandle.BackgroundColor3 = Color3.fromRGB(255, 100, 0)
    holdSliderHandle.BorderSizePixel = 0
    holdSliderHandle.Text = ""
    holdSliderHandle.Parent = holdSliderBg
    
    local holdHandleCorner = Instance.new("UICorner")
    holdHandleCorner.CornerRadius = UDim.new(0, 10)
    holdHandleCorner.Parent = holdSliderHandle
    
    -- Status Label
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
    
    -- Debug Label for positions
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
    
    -- Make draggable
    local dragging = false
    local dragStart = nil
    local startPos = nil
    
    titleLabel.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = mainFrame.Position
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            mainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
    
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)
    
    -- Setup mobile-friendly sliders
    setupMobileSliders(tapSliderHandle, tapSliderBg, tapLabel, "tap")
    setupMobileSliders(holdSliderHandle, holdSliderBg, holdLabel, "hold")
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

-- Calculate fish position and player bar position
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

-- Control methods
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
    -- Real hold - menahan lama (0.3-0.8 detik)
    local holdDuration = 0.3 + (holdSensitivity * 0.5)  -- 0.3 to 0.8 seconds
    
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
    -- Very strong hold - menahan sangat lama (0.6-1.2 detik)
    local strongDuration = 0.6 + (holdSensitivity * 0.6)  -- 0.6 to 1.2 seconds
    
    pcall(function()
        VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.Space, false, game)
        wait(strongDuration)
        VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.Space, false, game)
    end)
    
    pcall(function()
        VirtualInputManager:SendMouseButtonEvent(0, 0, 0, true, game, 1)
        wait(strongDuration)
        VirtualInputManager:SendMouseButtonEvent(0, 0, 0, false, game, 1)
    end)
end

-- Auto reel logic
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
        
        if centerDifference > 0.2 then
            strongHoldAction()
            statusLabel.Text = "Status: Strong Hold Centering"
        elseif centerDifference > 0.1 then
            holdAction()
            statusLabel.Text = "Status: Hold Centering"
        elseif centerDifference > 0.05 then
            -- Medium tap for centering
            local mediumTapDuration = 0.08 + (tapSensitivity * 0.12)
            pcall(function()
                VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.Space, false, game)
                wait(mediumTapDuration)
                VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.Space, false, game)
            end)
            statusLabel.Text = "Status: Medium Tap Centering"
        elseif centerDifference > 0.02 then
            tapAction()
            statusLabel.Text = "Status: Light Tap Centering"
        else
            statusLabel.Text = "Status: Centered, Ready"
        end
        return
    end
    
    local deadZone = 0.03
    
    if difference > deadZone then
        if difference > 0.2 then
            strongHoldAction()
            statusLabel.Text = "Status: Strong Hold (Very Fast)"
        elseif difference > 0.1 then
            holdAction()
            statusLabel.Text = "Status: Hold (Fast)"
        elseif difference > 0.05 then
            -- Medium tap for moderate speed
            local mediumTapDuration = 0.08 + (tapSensitivity * 0.12)
            pcall(function()
                VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.Space, false, game)
                wait(mediumTapDuration)
                VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.Space, false, game)
            end)
            statusLabel.Text = "Status: Medium Tap"
        else
            tapAction()
            statusLabel.Text = "Status: Light Tap"
        end
    else
        statusLabel.Text = "Status: Drift Left"
    end
end

-- Initialize
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
    
    print("🎣 Auto Reel (Mobile) initialized! Use the GUI to toggle ON/OFF")
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
