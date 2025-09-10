-- Auto Reel Test Script
print("Starting Auto Reel Test...")

-- Test basic functionality
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

print("Services loaded successfully")

-- Simple test module
local TestAutoReel = {}

function TestAutoReel.init()
    print("TestAutoReel initialized")
    
    -- Create simple GUI
    local player = Players.LocalPlayer
    local playerGui = player:WaitForChild("PlayerGui")
    
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "TestAutoReelGui"
    screenGui.Parent = playerGui
    
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 200, 0, 100)
    frame.Position = UDim2.new(0.5, -100, 0.5, -50)
    frame.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    frame.Parent = screenGui
    
    local button = Instance.new("TextButton")
    button.Size = UDim2.new(0.8, 0, 0.5, 0)
    button.Position = UDim2.new(0.1, 0, 0.25, 0)
    button.Text = "Test Button"
    button.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
    button.Parent = frame
    
    button.MouseButton1Click:Connect(function()
        print("Test button clicked!")
    end)
    
    print("Test GUI created successfully")
end

-- Initialize
TestAutoReel.init()
print("Auto Reel Test completed successfully")
