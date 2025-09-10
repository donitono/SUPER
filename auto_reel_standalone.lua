-- Auto Reel Script for Fishing Game
-- Standalone version with simple UI

print("Loading Auto Reel Script...")

-- Load the auto reel module with error handling
local success, AutoReel = pcall(function()
    return loadstring(game:HttpGet("https://raw.githubusercontent.com/donitono/SUPER/main/modules/auto_reel_clean.lua"))()
end)

if not success then
    print("Failed to load Auto Reel module, trying backup...")
    -- Fallback to original if clean version fails
    local success2, AutoReel2 = pcall(function()
        return loadstring(game:HttpGet("https://raw.githubusercontent.com/donitono/SUPER/main/modules/auto_reel.lua"))()
    end)
    
    if success2 then
        AutoReel = AutoReel2
        success = true
    else
        error("Failed to load Auto Reel module: " .. tostring(AutoReel2))
    end
end

-- Initialize the auto reel system
local initSuccess, initError = pcall(function()
    AutoReel.init()
end)

if not initSuccess then
    error("Failed to initialize Auto Reel: " .. tostring(initError))
end

print("Auto Reel Script loaded successfully!")
print("Instructions:")
print("- Click the toggle button to turn auto reel ON/OFF")
print("- The script will automatically detect reel minigames")
print("- White bar will follow the fish position automatically")
print("- Use sliders to adjust tap and hold sensitivity")

-- Add hotkey support
local UserInputService = game:GetService("UserInputService")

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    
    if input.KeyCode == Enum.KeyCode.R then
        local gui = game.Players.LocalPlayer.PlayerGui:FindFirstChild("AutoReelGui")
        if gui and gui.MainFrame and gui.MainFrame.ToggleButton then
            gui.MainFrame.ToggleButton.MouseButton1Click:Fire()
        end
    end
end)

print("Tip: Press 'R' key to quickly toggle auto reel on/off")
