-- Auto Reel Script for Fishing Game
-- Standalone version with simple UI

print("🎣 Loading Auto Reel Script...")

-- Load the auto reel module
local AutoReel = loadstring(game:HttpGet("https://raw.githubusercontent.com/donitono/SUPER/main/modules/auto_reel.lua"))()

-- Initialize the auto reel system
AutoReel.init()

print("✅ Auto Reel Script loaded successfully!")
print("📋 Instructions:")
print("   • Click the toggle button to turn auto reel ON/OFF")
print("   • The script will automatically detect reel minigames")
print("   • White bar will follow the fish position automatically")
print("   • Tap = slow movement right")
print("   • Hold = fast movement right") 
print("   • No input = bar drifts left")

-- Optional: Add hotkey support
local UserInputService = game:GetService("UserInputService")

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    
    -- Toggle with 'R' key
    if input.KeyCode == Enum.KeyCode.R then
        -- Simulate button click
        local gui = game.Players.LocalPlayer.PlayerGui:FindFirstChild("AutoReelGui")
        if gui and gui.MainFrame and gui.MainFrame.ToggleButton then
            gui.MainFrame.ToggleButton.MouseButton1Click:Fire()
        end
    end
end)

print("💡 Tip: Press 'R' key to quickly toggle auto reel on/off")
