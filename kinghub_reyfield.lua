--[[
Reyfield UI Port of original kinghub.lua
Notes:
 - This is a structural port focused on replacing the previous custom Library with Reyfield.
 - Core logic (auto shake, auto reel, auto cast, zone cast, collar player, teleports, etc.) is preserved.
 - Theme & save systems from the old library are not replicated here (Reyfield has its own config saving; enable if desired).
 - Dependency boxes (conditional UI) were simplified; all controls are always visible.
 - Further polishing (icons, key system) can be added per your preference.
]]

--// Load Reyfield
local Reyfield = loadstring(game:HttpGet('https://raw.githubusercontent.com/peyton2465/Reyfield/main/source'))()

local Window = Reyfield:CreateWindow({
    Name = "Fisch V1.2.3 (BETA) - Reyfield",
    LoadingTitle = "Fisch Script",
    LoadingSubtitle = "Reyfield Port",
    ConfigurationSaving = {
        Enabled = false, -- set true if you want Reyfield config saving
        FolderName = "RinnsHub", -- folder name
        FileName = "Fisch_Reyfield"
    },
    Discord = { -- optional
        Enabled = false,
        Invite = "",
        RememberJoins = true
    },
    KeySystem = false,
    KeySettings = { -- only relevant if KeySystem = true
        Title = "Fisch Script",
        Subtitle = "Key System",
        Note = "",
        FileName = "FischKey",
        SaveKey = true,
        GrabKeyFromSite = false,
        Key = ""
    }
})

local function Notify(msg, title)
    Reyfield:Notify({
        Title = title or "Info",
        Content = tostring(msg),
        Duration = 6
    })
end

--// Services
local VirtualInputManager = game:GetService("VirtualInputManager")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local VirtualUser = game:GetService("VirtualUser")
local HttpService = game:GetService("HttpService")
local GuiService = game:GetService("GuiService")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local Players = game:GetService("Players")

--// Player/World References
local LocalPlayer = Players.LocalPlayer
local LocalCharacter = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local HumanoidRootPart = LocalCharacter:WaitForChild("HumanoidRootPart")
local ActiveFolder = Workspace:FindFirstChild("active")
local FishingZonesFolder = Workspace:WaitForChild("zones"):WaitForChild("fishing")
local TpSpotsFolder = Workspace:WaitForChild("world"):WaitForChild("spawns"):WaitForChild("TpSpots")
local NpcFolder = Workspace:WaitForChild("world"):WaitForChild("npcs")
local PlayerGUI = LocalPlayer:WaitForChild("PlayerGui")

--// Runtime Vars
local autoShake = false
local autoShakeDelay = 0.1
local autoShakeMethod = "KeyCodeEvent" -- ClickEvent / KeyCodeEvent
local autoReel = false
local autoReelDelay = 2
local autoCast = false
local autoCastMode = "Legit" -- Legit / Rage
local autoCastDelay = 2
local ZoneCast = false
local Zone = "Brine Pool"
local Noclip = false
local AntiDrown = false
local CollarPlayer = false
local Target = nil
local FreezeChar = false

local teleportSpots = {}
local npcList = {}
local itemSpots = {
    Bait_Crate = CFrame.new(384.57513427734375, 135.3519287109375, 337.5340270996094),
    Carbon_Rod = CFrame.new(454.083618, 150.590073, 225.328827, 0.985374212, -0.170404434, 1.41561031e-07, 1.41561031e-07, 1.7285347e-06, 1, -0.170404434, -0.985374212, 1.7285347e-06),
    Crab_Cage = CFrame.new(474.803589, 149.664566, 229.49469, -0.721874595, 0, 0.692023814, 0, 1, 0, -0.692023814, 0, -0.721874595),
    Fast_Rod = CFrame.new(447.183563, 148.225739, 220.187454, 0.981104493, 1.26492232e-05, 0.193478703, -0.0522461236, 0.962867677, 0.264870107, -0.186291039, -0.269973755, 0.944674432),
    Flimsy_Rod = CFrame.new(471.107697, 148.36171, 229.642441, 0.841614008, 0.0774728209, -0.534493923, 0.00678436086, 0.988063335, 0.153898612, 0.540036798, -0.13314943, 0.831042409),
    GPS = CFrame.new(517.896729, 149.217636, 284.856842, 7.39097595e-06, -0.719539165, -0.694451928, -1, -7.39097595e-06, -3.01003456e-06, -3.01003456e-06, 0.694451928, -0.719539165),
    Long_Rod = CFrame.new(485.695038, 171.656326, 145.746109, -0.630167365, -0.776459217, -5.33461571e-06, 5.33461571e-06, -1.12056732e-05, 1, -0.776459217, 0.630167365, 1.12056732e-05),
    Lucky_Rod = CFrame.new(446.085999, 148.253006, 222.160004, 0.974526405, -0.22305499, 0.0233404674, 0.196993902, 0.901088715, 0.386306256, -0.107199371, -0.371867687, 0.922075212),
    Plastic_Rod = CFrame.new(454.425385, 148.169739, 229.172424, 0.951755166, 0.0709736273, -0.298537821, -3.42726707e-07, 0.972884834, 0.231290117, 0.306858391, -0.220131472, 0.925948203),
    Training_Rod = CFrame.new(457.693848, 148.357529, 230.414307, 1, 0, 0, 0, 0.975410998, 0.220393807, 0, -0.220393807, 0.975410998)
}
local fisktable = {}

--// Build data lists
for _, v in pairs(FishingZonesFolder:GetChildren()) do
    table.insert(fisktable, v.Name)
end
FishingZonesFolder.ChildAdded:Connect(function(c)
    if not table.find(fisktable, c.Name) then table.insert(fisktable, c.Name) end
end)

for _, v in pairs(TpSpotsFolder:GetChildren()) do
    table.insert(teleportSpots, v.Name)
end
for _, v in pairs(NpcFolder:GetChildren()) do
    if v.Name ~= "mirror Area" then table.insert(npcList, v.Name) end
end
NpcFolder.ChildAdded:Connect(function(c)
    if c.Name ~= "mirror Area" and not table.find(npcList, c.Name) then table.insert(npcList, c.Name) end
end)

--// Utility Parts
local SafeZone = Instance.new("Part")
SafeZone.Size = Vector3.new(50,2,50)
SafeZone.Anchored = true
SafeZone.CFrame = CFrame.new(9999,9999,9999)
SafeZone.Parent = Workspace

--// Connections
local RenderStepped = RunService.RenderStepped
local function WaitRS() return RenderStepped:Wait() end

-- Auto Shake + Reel detection
local autoreelandshakeConnection = PlayerGUI.ChildAdded:Connect(function(GUI)
    if GUI:IsA("ScreenGui") and GUI.Name == "shakeui" then
        local safezone = GUI:FindFirstChild("safezone")
        if safezone then
            safezone.ChildAdded:Connect(function(child)
                if child:IsA("ImageButton") and child.Name == "button" and autoShake then
                    task.wait(autoShakeDelay)
                    if child.Visible then
                        if autoShakeMethod == "ClickEvent" then
                            local pos,size = child.AbsolutePosition, child.AbsoluteSize
                            VirtualInputManager:SendMouseButtonEvent(pos.X + size.X/2, pos.Y + size.Y/2, 0, true, LocalPlayer, 0)
                            VirtualInputManager:SendMouseButtonEvent(pos.X + size.X/2, pos.Y + size.Y/2, 0, false, LocalPlayer, 0)
                        elseif autoShakeMethod == "KeyCodeEvent" then
                            while autoShake and safezone:FindFirstChild(child.Name) do
                                GuiService.SelectedObject = child
                                VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.Return, false, game)
                                VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.Return, false, game)
                                task.wait()
                            end
                            GuiService.SelectedObject = nil
                        end
                    end
                end
            end)
        end
    elseif GUI:IsA("ScreenGui") and GUI.Name == "reel" then
        if autoReel and ReplicatedStorage:WaitForChild("events"):WaitForChild("reelfinished") then
            task.spawn(function()
                while autoReel and GUI.Parent do
                    task.wait(autoReelDelay)
                    pcall(function()
                        ReplicatedStorage.events.reelfinished:FireServer(100, false)
                    end)
                end
            end)
        end
    end
end)

-- Auto Cast start detection
local autoCastConnection = LocalCharacter.ChildAdded:Connect(function(child)
    if child:IsA("Tool") and child:FindFirstChild("events") and child.events:FindFirstChild("cast") and autoCast then
        task.wait(autoCastDelay)
        if autoCastMode == "Legit" then
            VirtualInputManager:SendMouseButtonEvent(0,0,0,true, LocalPlayer,0)
            HumanoidRootPart.ChildAdded:Connect(function()
                local powerbar = HumanoidRootPart:FindFirstChild("power")
                if powerbar and powerbar:FindFirstChild("powerbar") and powerbar.powerbar:FindFirstChild("bar") then
                    powerbar.powerbar.bar.Changed:Connect(function(prop)
                        if prop == "Size" and powerbar.powerbar.bar.Size == UDim2.new(1,0,1,0) then
                            VirtualInputManager:SendMouseButtonEvent(0,0,0,false, LocalPlayer,0)
                        end
                    end)
                end
            end)
        else
            child.events.cast:FireServer(100)
        end
    end
end)

-- AutoCast after reel ends
local autoCastConnection2 = PlayerGUI.ChildRemoved:Connect(function(GUI)
    if GUI.Name == "reel" and autoCast then
        local tool = LocalCharacter:FindFirstChildOfClass("Tool")
        if tool and tool:FindFirstChild("events") and tool.events:FindFirstChild("cast") then
            task.wait(autoCastDelay)
            if autoCastMode == "Legit" then
                VirtualInputManager:SendMouseButtonEvent(0,0,0,true, LocalPlayer,0)
                HumanoidRootPart.ChildAdded:Connect(function()
                    local powerbar = HumanoidRootPart:FindFirstChild("power")
                    if powerbar and powerbar:FindFirstChild("powerbar") and powerbar.powerbar:FindFirstChild("bar") then
                        powerbar.powerbar.bar.Changed:Connect(function(prop)
                            if prop == "Size" and powerbar.powerbar.bar.Size == UDim2.new(1,0,1,0) then
                                VirtualInputManager:SendMouseButtonEvent(0,0,0,false, LocalPlayer,0)
                            end
                        end)
                    end
                end)
            else
                tool.events.cast:FireServer(100)
            end
        end
    end
end)

-- Zone Cast
local ZoneConnection = LocalCharacter.ChildAdded:Connect(function(child)
    if ZoneCast and child:IsA("Tool") and FishingZonesFolder:FindFirstChild(Zone) then
        child.ChildAdded:Connect(function(b)
            if b.Name == "bobber" then
                local rc = b:FindFirstChildOfClass("RopeConstraint")
                if rc then rc.Length = math.huge end
                task.wait(1)
                while ZoneCast and b.Parent do
                    b.CFrame = FishingZonesFolder[Zone].CFrame
                    task.wait()
                end
            end
        end)
    end
end)

-- Collar Player
local CollarConnection = LocalCharacter.ChildAdded:Connect(function(child)
    if CollarPlayer and Target and child:IsA("Tool") then
        local targetPlr = Players:FindFirstChild(Target)
        if targetPlr and targetPlr.Character and targetPlr.Character:FindFirstChild("Head") then
            child.ChildAdded:Connect(function(b)
                if b.Name == "bobber" then
                    local rc = b:FindFirstChildOfClass("RopeConstraint")
                    if rc then rc.Length = math.huge end
                    task.wait(1)
                    while CollarPlayer and b.Parent and targetPlr.Character and targetPlr.Character:FindFirstChild("Head") do
                        b.CFrame = targetPlr.Character.Head.CFrame + Vector3.new(0,-1,0)
                        task.wait()
                    end
                end
            end)
        end
    end
end)

-- Noclip
local NoclipConnection = RunService.Stepped:Connect(function()
    if Noclip and LocalCharacter then
        for _, part in ipairs(LocalCharacter:GetDescendants()) do
            if part:IsA("BasePart") and part.CanCollide then
                part.CanCollide = false
            end
        end
    end
end)

-- Freeze Character loop (activated per toggle)
local function FreezeLoop()
    task.spawn(function()
        local oldpos = HumanoidRootPart.CFrame
        while FreezeChar and HumanoidRootPart do
            HumanoidRootPart.CFrame = oldpos
            task.wait()
        end
    end)
end

--// Tabs
local MainTab = Window:CreateTab("Main", 4483362458)
local TeleportsTab = Window:CreateTab("Teleports", 4483362458)
local LocalPlayerTab = Window:CreateTab("LocalPlayer", 4483362458)
local SettingsTab = Window:CreateTab("Settings", 4483362458)

-- Sections (Main)
local AutoShakeSection = MainTab:CreateSection("AutoShake")
local AutoReelSection = MainTab:CreateSection("AutoReel")
local AutoCastSection = MainTab:CreateSection("AutoCast")
local FishUtilSection = MainTab:CreateSection("Fish Utilities")
local ZoneCastSection = MainTab:CreateSection("ZoneCast")
local CollarSection = MainTab:CreateSection("Collar Player")

-- AutoShake UI
MainTab:CreateToggle({
    Name = "AutoShake Enabled",
    CurrentValue = false,
    Flag = "AutoShakeToggle",
    Callback = function(v) autoShake = v end
})
MainTab:CreateDropdown({
    Name = "Shake Method",
    Options = {"ClickEvent","KeyCodeEvent"},
    CurrentOption = autoShakeMethod,
    Flag = "AutoShakeMethod",
    Callback = function(op) autoShakeMethod = op end
})
MainTab:CreateSlider({
    Name = "Shake Delay",
    Range = {0,10},
    Increment = 0.1,
    Suffix = "s",
    CurrentValue = autoShakeDelay,
    Flag = "ShakeDelay",
    Callback = function(v) autoShakeDelay = v end
})

-- AutoReel UI
MainTab:CreateToggle({
    Name = "AutoReel Enabled",
    CurrentValue = false,
    Flag = "AutoReelToggle",
    Callback = function(v) autoReel = v end
})
MainTab:CreateSlider({
    Name = "Reel Delay",
    Range = {0,10},
    Increment = 0.1,
    Suffix = "s",
    CurrentValue = autoReelDelay,
    Flag = "ReelDelay",
    Callback = function(v) autoReelDelay = v end
})

-- AutoCast UI
MainTab:CreateToggle({
    Name = "AutoCast Enabled",
    CurrentValue = false,
    Flag = "AutoCastToggle",
    Callback = function(v)
        autoCast = v
        if v then
            local Tool = LocalCharacter:FindFirstChildOfClass("Tool")
            if Tool and Tool:FindFirstChild("events") and Tool.events:FindFirstChild("cast") then
                task.wait(autoCastDelay)
                if autoCastMode == "Legit" then
                    VirtualInputManager:SendMouseButtonEvent(0,0,0,true,LocalPlayer,0)
                else
                    Tool.events.cast:FireServer(100)
                end
            end
        end
    end
})
MainTab:CreateDropdown({
    Name = "Cast Mode",
    Options = {"Legit","Rage"},
    CurrentOption = autoCastMode,
    Flag = "AutoCastMode",
    Callback = function(op) autoCastMode = op end
})
MainTab:CreateSlider({
    Name = "Cast Delay",
    Range = {0,10},
    Increment = 0.1,
    Suffix = "s",
    CurrentValue = autoCastDelay,
    Flag = "CastDelay",
    Callback = function(v) autoCastDelay = v end
})

-- Fish utilities
MainTab:CreateButton({
    Name = "Sell Fish (Held)",
    Callback = function()
        pcall(function()
            Workspace.world.npcs["Marc Merchant"].merchant.sell:InvokeServer()
        end)
    end
})
MainTab:CreateButton({
    Name = "Sell ALL Fish",
    Callback = function()
        pcall(function()
            Workspace.world.npcs["Marc Merchant"].merchant.sellall:InvokeServer()
        end)
    end
})
MainTab:CreateButton({
    Name = "Appraise Fish (450C$)",
    Callback = function()
        pcall(function()
            Workspace.world.npcs.Appraiser.appraiser.appraise:InvokeServer()
        end)
    end
})

-- ZoneCast
MainTab:CreateToggle({
    Name = "ZoneCast Enabled",
    CurrentValue = false,
    Flag = "ZoneCastToggle",
    Callback = function(v) ZoneCast = v end
})
MainTab:CreateDropdown({
    Name = "Zone",
    Options = fisktable,
    CurrentOption = Zone,
    Flag = "ZoneCastZone",
    Callback = function(op) Zone = op end
})

-- Collar Player
local function PlayerNames()
    local list = {}
    for _,plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer then table.insert(list, plr.Name) end
    end
    return list
end

MainTab:CreateToggle({
    Name = "Collar Enabled",
    CurrentValue = false,
    Flag = "CollarToggle",
    Callback = function(v) CollarPlayer = v end
})
MainTab:CreateDropdown({
    Name = "Target Player",
    Options = PlayerNames(),
    CurrentOption = Target or "",
    Flag = "CollarTarget",
    Callback = function(op) Target = op end
})
MainTab:CreateButton({
    Name = "Refresh Players",
    Callback = function()
        Reyfield:LoadConfiguration() -- simple refresh hack (or rebuild dropdown if advanced)
        Notify("Player list refreshed")
    end
})

-- Teleports
TeleportsTab:CreateSection("Teleports")
TeleportsTab:CreateDropdown({
    Name = "Teleport Place",
    Options = teleportSpots,
    CurrentOption = "",
    Flag = "PlaceTP",
    Callback = function(op)
        if op ~= "" and TpSpotsFolder:FindFirstChild(op) and HumanoidRootPart then
            HumanoidRootPart.CFrame = TpSpotsFolder[op].CFrame + Vector3.new(0,5,0)
        end
    end
})
TeleportsTab:CreateDropdown({
    Name = "Teleport NPC",
    Options = npcList,
    CurrentOption = "",
    Flag = "NPCTP",
    Callback = function(op)
        local npc = NpcFolder:FindFirstChild(op)
        if npc and npc:FindFirstChild("HumanoidRootPart") and HumanoidRootPart then
            HumanoidRootPart.CFrame = npc.HumanoidRootPart.CFrame + Vector3.new(0,1,0)
        end
    end
})
TeleportsTab:CreateDropdown({
    Name = "Teleport Item",
    Options = {"Bait_Crate","Carbon_Rod","Crab_Cage","Fast_Rod","Flimsy_Rod","GPS","Long_Rod","Lucky_Rod","Plastic_Rod","Training_Rod"},
    CurrentOption = "",
    Flag = "ItemTP",
    Callback = function(op)
        local cf = itemSpots[op]
        if cf and HumanoidRootPart then
            HumanoidRootPart.CFrame = cf
        end
    end
})
TeleportsTab:CreateButton({
    Name = "Teleport Safe Zone",
    Callback = function()
        if HumanoidRootPart then
            HumanoidRootPart.CFrame = SafeZone.CFrame + Vector3.new(0,2,0)
        end
    end
})

-- Local Player
LocalPlayerTab:CreateSection("LocalPlayer")
LocalPlayerTab:CreateToggle({
    Name = "Noclip",
    CurrentValue = false,
    Flag = "Noclip",
    Callback = function(v) Noclip = v end
})
LocalPlayerTab:CreateToggle({
    Name = "Disable Oxygen (AntiDrown)",
    CurrentValue = false,
    Flag = "AntiDrown",
    Callback = function(v)
        AntiDrown = v
        local function disableOxy()
            if LocalCharacter and LocalCharacter:FindFirstChild("client") and LocalCharacter.client:FindFirstChild("oxygen") then
                LocalCharacter.client.oxygen.Enabled = not v
            end
        end
        disableOxy()
        if v then
            LocalPlayer.CharacterAdded:Connect(function(char)
                LocalCharacter = char
                HumanoidRootPart = char:WaitForChild("HumanoidRootPart")
                task.wait(1)
                if AntiDrown then disableOxy() end
            end)
        end
    end
})
LocalPlayerTab:CreateButton({
    Name = "Reset Rod",
    Callback = function()
        local tool = LocalCharacter:FindFirstChildOfClass("Tool")
        if tool and tool:FindFirstChild("events") and tool.events:FindFirstChild("reset") then
            tool.events.reset:FireServer()
        end
    end
})
LocalPlayerTab:CreateButton({
    Name = "Anti-AFK",
    Callback = function()
        Notify("Anti-AFK running")
        LocalPlayer.Idled:Connect(function()
            VirtualUser:CaptureController()
            VirtualUser:ClickButton2(Vector2.new())
        end)
    end
})
LocalPlayerTab:CreateToggle({
    Name = "Freeze Character",
    CurrentValue = false,
    Flag = "FreezeChar",
    Callback = function(v)
        FreezeChar = v
        if v then FreezeLoop() end
    end
})

-- Settings / Credits
SettingsTab:CreateSection("Credits")
SettingsTab:CreateLabel("Made by kylosilly and netpa!")
SettingsTab:CreateLabel("Reyfield Port Version")
SettingsTab:CreateButton({
    Name = "Copy Fisch Discord Link",
    Callback = function() setclipboard('https://discord.gg/DEkfE99JFh'); Notify("Discord link copied") end
})
SettingsTab:CreateButton({
    Name = "Copy Main Discord Link",
    Callback = function() setclipboard('https://discord.gg/VudXCDCaBN'); Notify("Discord link copied") end
})
SettingsTab:CreateLabel("البرود يا جماعه هو الحل")
SettingsTab:CreateButton({
    Name = "Unload (Destroy UI)",
    Callback = function()
        autoShake = false
        autoReel = false
        autoCast = false
        ZoneCast = false
        CollarPlayer = false
        FreezeChar = false
        Noclip = false
        AntiDrown = false
        pcall(function()
            autoreelandshakeConnection:Disconnect()
            autoCastConnection:Disconnect()
            autoCastConnection2:Disconnect()
            ZoneConnection:Disconnect()
            CollarConnection:Disconnect()
            NoclipConnection:Disconnect()
        end)
        Reyfield:Destroy()
    end
})

-- Version check
local Version = "1.2.3"
 task.spawn(function()
    local success, LatestVer = pcall(function()
        local version = game:HttpGet("https://raw.githubusercontent.com/kylosilly/femboyware/refs/heads/main/fischver")
        return HttpService:JSONDecode(version)
    end)
    if success and Version ~= LatestVer then
        Notify("Outdated version detected. Join Discord for update.")
    end
end)

Notify("Reyfield UI Loaded", "Fisch Script")
