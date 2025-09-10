-- Auto Reel Script for Mobile/HP - Fishing Game
-- Mobile-optimized version with touch support

print("🎣 Loading Auto Reel Mobile Script...")

-- Load the mobile auto reel module
local AutoReel = loadstring(game:HttpGet("https://raw.githubusercontent.com/donitono/SUPER/main/modules/auto_reel_mobile.lua"))()

-- Initialize the auto reel system
AutoReel.init()

print("✅ Auto Reel Mobile Script loaded successfully!")
print("📱 Mobile Features:")
print("   • Touch-friendly slider controls")
print("   • +/- buttons for easy adjustment")
print("   • Larger touch targets")
print("   • Optimized for mobile devices")
print("📋 Instructions:")
print("   • Tap toggle button to turn auto reel ON/OFF")
print("   • Use +/- buttons to adjust sensitivity")
print("   • Drag sliders or tap anywhere on track")
print("   • Drag title bar to move window")

-- Mobile-specific hotkey support
local UserInputService = game:GetService("UserInputService")

-- Check if running on mobile
if UserInputService.TouchEnabled then
    print("📱 Mobile device detected - Touch controls enabled")
else
    print("🖥️ Desktop device detected - Mouse/Touch hybrid controls")
end

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    
    -- Toggle with 'R' key (works on mobile with external keyboard)
    if input.KeyCode == Enum.KeyCode.R then
        local gui = game.Players.LocalPlayer.PlayerGui:FindFirstChild("AutoReelGui")
        if gui and gui.MainFrame and gui.MainFrame.ToggleButton then
            gui.MainFrame.ToggleButton.MouseButton1Click:Fire()
        end
    end
end)

print("💡 Tips for Mobile:")
print("   • Use +/- buttons for quick adjustments")
print("   • Tap and drag slider handles")
print("   • Press R key (if keyboard available) to toggle")
print("   • Larger UI designed for finger touch")
