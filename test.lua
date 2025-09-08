-- SUPER HUB Testing Script
-- Load from GitHub and test functionality

print("=== SUPER HUB Testing ===")
print("Loading from GitHub...")

-- Test load main script
local success, err = pcall(function()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/donitono/SUPER/main/main.lua"))()
end)

if success then
    print("✅ SUPER HUB loaded successfully!")
    print("🎯 Ready for testing:")
    print("   - Check if UI appears")
    print("   - Test Auto Cast toggle")
    print("   - Test Auto Shake modes")
    print("   - Test Auto Reel toggle")
    print("   - Test Quick Actions")
else
    print("❌ Error loading SUPER HUB:")
    print(tostring(err))
end

print("=== Testing Instructions ===")
print("1. Check if Kavo UI window appears")
print("2. Go to Autofarm tab")
print("3. Test each toggle individually:")
print("   • Auto Cast")
print("   • Auto Shake (try both modes)")
print("   • Auto Reel")
print("4. Try 'Start All Autofarm' button")
print("5. Use 'Check Status' to verify")
print("6. Test basic teleport and player features")
print("============================")
