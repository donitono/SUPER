-- Test Main Script
print("Starting test...")

-- Test loading the simplified autofarm module
local success, autofarm = pcall(function()
    return loadstring(game:HttpGet("https://raw.githubusercontent.com/donitono/SUPER/main/test_autofarm.lua"))()
end)

if success then
    print("Test autofarm loaded successfully!")
    if autofarm and autofarm.test then
        autofarm.test()
    else
        print("ERROR: Autofarm module is nil or missing test function")
    end
else
    print("ERROR loading test autofarm:", autofarm) -- autofarm will contain error message if failed
end

-- Test loading the actual autofarm module
print("\nTesting actual autofarm module...")
local success2, autofarm2 = pcall(function()
    return loadstring(game:HttpGet("https://raw.githubusercontent.com/donitono/SUPER/main/modules/autofarm.lua"))()
end)

if success2 then
    print("Actual autofarm loaded successfully!")
    if autofarm2 then
        print("Autofarm module returned:", type(autofarm2))
    else
        print("ERROR: Actual autofarm module returned nil")
    end
else
    print("ERROR loading actual autofarm:", autofarm2) -- autofarm2 will contain error message if failed
end
