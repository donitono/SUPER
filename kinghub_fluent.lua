-- Self-contained fluent stub (inlined to avoid second HTTP request / require issues)
local Options, Toggles = {}, {}
getgenv = getgenv or function() return _G end
local env = getgenv()
env.Options = env.Options or Options
env.Toggles = env.Toggles or Toggles

local Library = { _watermark = '', _unloadCbs = {}, Unloaded = false }

local function makeGroupBox(name)
    local gb = { Name = name }
    function gb:AddLabel(text)
        local label = { Text = text }
        function label:AddKeyPicker(key, data)
            Options[key] = { Value = data.Default, Raw = data }
            function Options[key]:SetValue(v) self.Value = v if self.Callback then pcall(self.Callback,v) end end
            return Options[key]
        end
        return label
    end
    function gb:AddButton(cfg)
        if type(cfg) == 'string' then cfg = { Text = cfg, Func = function() end } end
        return cfg
    end
    function gb:AddToggle(key, data)
        Toggles[key] = { Value = data.Default, Callback = data.Callback }
        function Toggles[key]:SetValue(v) self.Value=v if self.Callback then pcall(self.Callback,v) end end
        return Toggles[key]
    end
    function gb:AddSlider(key, data)
        Options[key] = { Value = data.Default, Min=data.Min, Max=data.Max, Callback=data.Callback }
        function Options[key]:SetValue(v) self.Value=v if self.Callback then pcall(self.Callback,v) end end
        return Options[key]
    end
    function gb:AddDropdown(key, data)
        Options[key] = { Value=data.Default, Values=data.Values, Callback=data.Callback, SpecialType=data.SpecialType }
        function Options[key]:SetValue(v) self.Value=v if self.Callback then pcall(self.Callback,v) end end
        return Options[key]
    end
    function gb:AddDependencyBox()
        local box = { _rules = {} }
        function box:SetupDependencies(rules) self._rules = rules end
        function box:AddDropdown(...) return gb:AddDropdown(...) end
        function box:AddSlider(...) return gb:AddSlider(...) end
        function box:AddToggle(...) return gb:AddToggle(...) end
        function box:AddLabel(...) return gb:AddLabel(...) end
        return box
    end
    return gb
end

local function makeTab(name)
    local tab = { Name=name, Left={}, Right={} }
    function tab:AddLeftGroupbox(n) local g=makeGroupBox(n) table.insert(self.Left,g) return g end
    function tab:AddRightGroupbox(n) local g=makeGroupBox(n) table.insert(self.Right,g) return g end
    return tab
end

function Library:CreateWindow(cfg)
    local win = { Title = cfg.Title, Tabs = {} }
    function win:AddTab(name)
        local t = makeTab(name)
        self.Tabs[name]=t
        return t
    end
    return win
end
function Library:SetWatermark(t) self._watermark=t end
function Library:Notify(msg) print('[Fluent Notify] '.. tostring(msg)) end
function Library:OnUnload(cb) table.insert(self._unloadCbs, cb) end
function Library:Unload()
    if self.Unloaded then return end
    for _,cb in ipairs(self._unloadCbs) do pcall(cb) end
    self.Unloaded=true
end

local ThemeManager = { SetLibrary=function()end, SetFolder=function()end, ApplyToTab=function()end }
local SaveManager = { SetLibrary=function()end, IgnoreThemeSettings=function()end, SetIgnoreIndexes=function()end, SetFolder=function()end, BuildConfigSection=function()end, LoadAutoloadConfig=function()end }

-- Expose keybind placeholder
Library.ToggleKeybind = nil

local Window = Library:CreateWindow({
    Title = 'Fisch V1.2.3 (FLUENT)',
    Center = true,
    AutoShow = true,
    TabPadding = 8,
    MenuFadeTime = 0.2
})

-- FPS watermark (simplified)
local FrameTimer, FrameCounter, FPS = tick(), 0, 60
local RunService = game:GetService('RunService')
local Stats = game:GetService('Stats')
local WatermarkConnection = RunService.RenderStepped:Connect(function()
    FrameCounter += 1
    if tick() - FrameTimer >= 1 then
        FPS = FrameCounter; FrameTimer = tick(); FrameCounter = 0
    end
    local ping = 0
    local okPing, pingItem = pcall(function() return Stats.Network.ServerStatsItem['Data Ping']:GetValue() end)
    if okPing and pingItem then ping = pingItem end
    Library:SetWatermark(string.format('Rinns Hub V1.2.3 | %d fps | %d ms', math.floor(FPS), math.floor(ping)))
end)

-- Tabs
local Tabs = {
    Main = Window:AddTab('Main'),
    Teleports = Window:AddTab('Teleports'),
    LocalPlayer = Window:AddTab('LocalPlayer'),
    Settings = Window:AddTab('Settings')
}

-- Data tables
local teleportSpots, racistPeople, fisktable = {}, {}, {}
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

-- Services / locals
local Players = game:GetService('Players')
local ReplicatedStorage = game:GetService('ReplicatedStorage')
local Workspace = game:GetService('Workspace')
local VirtualInputManager = game:GetService('VirtualInputManager')
local VirtualUser = game:GetService('VirtualUser')
local HttpService = game:GetService('HttpService')

local LocalPlayer = Players.LocalPlayer
local LocalCharacter = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local HumanoidRootPart = LocalCharacter:WaitForChild('HumanoidRootPart')
local PlayerGUI = LocalPlayer:WaitForChild('PlayerGui')

local ActiveFolder = Workspace:FindFirstChild('active')
local FishingZonesFolder = Workspace:WaitForChild('zones'):WaitForChild('fishing')
local TpSpotsFolder = Workspace:WaitForChild('world'):WaitForChild('spawns'):WaitForChild('TpSpots')
local NpcFolder = Workspace:WaitForChild('world'):WaitForChild('npcs')

-- Feature state flags
local autoShake, autoShakeDelay, autoShakeMethod = false, 0.1, 'KeyCodeEvent'
local autoReel, autoReelDelay = false, 2
local autoCast, autoCastMode, autoCastDelay = false, 'Legit', 2
local ZoneCast, Zone = false, 'Brine Pool'
local Noclip, AntiDrown, CollarPlayer, Target = false, false, false, nil
local FreezeChar = false

-- SafeZone
local SafeZone = Instance.new('Part')
SafeZone.Parent = Workspace
SafeZone.Size = Vector3.new(50, 2, 50)
SafeZone.CFrame = CFrame.new(9999, 9999, 9999)
SafeZone.Anchored = true

-- Populate lists
for _, v in ipairs(FishingZonesFolder:GetChildren()) do table.insert(fisktable, v.Name) end
FishingZonesFolder.ChildAdded:Connect(function(c) if not table.find(fisktable, c.Name) then table.insert(fisktable, c.Name) end end)
for _, v in ipairs(TpSpotsFolder:GetChildren()) do table.insert(teleportSpots, v.Name) end
for _, v in ipairs(NpcFolder:GetChildren()) do if v.Name ~= 'mirror Area' then table.insert(racistPeople, v.Name) end end
NpcFolder.ChildAdded:Connect(function(c) if c.Name ~= 'mirror Area' then table.insert(racistPeople, c.Name) end end)

-- Connections (recreated with simplified error checking)
local autoreelandshakeConnection = PlayerGUI.ChildAdded:Connect(function(GUI)
    if GUI:IsA('ScreenGui') and GUI.Name == 'shakeui' then
        local safe = GUI:FindFirstChild('safezone')
        if safe then
            safe.ChildAdded:Connect(function(child)
                if child:IsA('ImageButton') and child.Name == 'button' and autoShake then
                    task.wait(autoShakeDelay)
                    if child.Visible then
                        if autoShakeMethod == 'ClickEvent' then
                            local pos, size = child.AbsolutePosition, child.AbsoluteSize
                            VirtualInputManager:SendMouseButtonEvent(pos.X + size.X/2, pos.Y + size.Y/2, 0, false, LocalPlayer, 0)
                        elseif autoShakeMethod == 'KeyCodeEvent' then
                            -- placeholder: would fire input
                        end
                    end
                end
            end)
        end
    end
    if GUI:IsA('ScreenGui') and GUI.Name == 'reel' then
        if autoReel and ReplicatedStorage:FindFirstChild('events') and ReplicatedStorage.events:FindFirstChild('reelfinished') then
            task.spawn(function()
                while autoReel and GUI.Parent do
                    task.wait(autoReelDelay)
                    pcall(function() ReplicatedStorage.events.reelfinished:FireServer(100, false) end)
                end
            end)
        end
    end
end)

local autoCastConnection = LocalCharacter.ChildAdded:Connect(function(child)
    if child:IsA('Tool') and autoCast then
        local okCast = pcall(function() return child:WaitForChild('events'):WaitForChild('cast') end)
        if okCast then
            task.wait(autoCastDelay)
            if autoCastMode == 'Legit' then
                VirtualInputManager:SendMouseButtonEvent(0,0,0,true,LocalPlayer,0)
                HumanoidRootPart.ChildAdded:Connect(function()
                    local power = HumanoidRootPart:FindFirstChild('power')
                    if power and power:FindFirstChild('powerbar') and power.powerbar:FindFirstChild('bar') then
                        power.powerbar.bar.Changed:Connect(function(prop)
                            if prop == 'Size' and power.powerbar.bar.Size == UDim2.new(1,0,1,0) then
                                VirtualInputManager:SendMouseButtonEvent(0,0,0,false,LocalPlayer,0)
                            end
                        end)
                    end
                end)
            else
                pcall(function() child.events.cast:FireServer(100) end)
            end
        end
    end
end)

local autoCastConnection2 = PlayerGUI.ChildRemoved:Connect(function(GUI)
    if GUI.Name == 'reel' and autoCast then
        local tool = LocalCharacter:FindFirstChildOfClass('Tool')
        if tool and tool:FindFirstChild('events') and tool.events:FindFirstChild('cast') then
            task.wait(autoCastDelay)
            if autoCastMode == 'Legit' then
                VirtualInputManager:SendMouseButtonEvent(0,0,0,true,LocalPlayer,0)
            else
                pcall(function() tool.events.cast:FireServer(100) end)
            end
        end
    end
end)

local ZoneConnection = LocalCharacter.ChildAdded:Connect(function(child)
    if ZoneCast and child:IsA('Tool') and FishingZonesFolder:FindFirstChild(Zone) then
        child.ChildAdded:Connect(function(b)
            if b.Name == 'bobber' then
                task.spawn(function()
                    task.wait(1)
                    while ZoneCast and b.Parent do
                        b.CFrame = FishingZonesFolder[Zone].CFrame
                        task.wait()
                    end
                end)
            end
        end)
    end
end)

local CollarConnection = LocalCharacter.ChildAdded:Connect(function(child)
    if CollarPlayer and child:IsA('Tool') and Target and Players:FindFirstChild(Target) then
        child.ChildAdded:Connect(function(b)
            if b.Name == 'bobber' then
                task.spawn(function()
                    task.wait(1)
                    while CollarPlayer and b.Parent and Players:FindFirstChild(Target) and Players[Target].Character do
                        local head = Players[Target].Character:FindFirstChild('Head')
                        if head then b.CFrame = head.CFrame + Vector3.new(0,-1,0) end
                        task.wait()
                    end
                end)
            end
        end)
    end
end)

local NoclipConnection = RunService.Stepped:Connect(function()
    if Noclip and LocalCharacter then
        for _, part in ipairs(LocalCharacter:GetDescendants()) do
            if part:IsA('BasePart') and part.CanCollide then part.CanCollide = false end
        end
    end
end)

-- UI groups (mirroring original)
local AutoShakeGroup = Tabs.Main:AddLeftGroupbox('AutoShake')
local AutoReelGroup = Tabs.Main:AddLeftGroupbox('AutoReel')
local AutoCastGroup = Tabs.Main:AddLeftGroupbox('AutoCast')
local FishUtilitiesGroup = Tabs.Main:AddRightGroupbox('Fish Utilities')
local ZoneCastGroup = Tabs.Main:AddRightGroupbox('ZoneCast')
local CollarPlayerGroup = Tabs.Main:AddRightGroupbox('CollarPlayer')

AutoShakeGroup:AddToggle('AutoShake', { Text='Enabled', Default=false, Callback=function(v) autoShake=v end })
local AutoShakeSettings = AutoShakeGroup:AddDependencyBox()
AutoShakeSettings:AddDropdown('AutoShakeMode', { Text='Auto Shake Method', Values={'ClickEvent','KeyCodeEvent'}, Default=autoShakeMethod, Callback=function(v) autoShakeMethod=v end })
local AutoShakeKeyCodeEventText = AutoShakeSettings:AddDependencyBox()
AutoShakeKeyCodeEventText:AddLabel('Inspired from rblxscripts.net!')
AutoShakeKeyCodeEventText:AddLabel('Huge shoutout to them.')
AutoShakeKeyCodeEventText:SetupDependencies({ { Options.AutoShakeMode, 'KeyCodeEvent' } })
AutoShakeSettings:AddSlider('AutoShakeDelay', { Text='AutoShake Delay', Default=autoShakeDelay, Min=0, Max=10, Rounding=1, Callback=function(v) autoShakeDelay=v end })
AutoShakeSettings:SetupDependencies({ { Toggles.AutoShake, true } })

AutoReelGroup:AddToggle('AutoReel', { Text='Enabled', Default=false, Callback=function(v) autoReel=v end })
local AutoReelSettings = AutoReelGroup:AddDependencyBox()
AutoReelSettings:AddSlider('AutoReelDelay', { Text='AutoReel Delay', Default=autoReelDelay, Min=0, Max=10, Rounding=1, Callback=function(v) autoReelDelay=v end })
AutoReelSettings:SetupDependencies({ { Toggles.AutoReel, true } })

AutoCastGroup:AddToggle('AutoCast', { Text='Enabled', Default=false, Callback=function(v)
    autoCast = v
end })
local AutoCastSettings = AutoCastGroup:AddDependencyBox()
AutoCastSettings:AddSlider('AutoCastDelay', { Text='AutoCast Delay', Default=autoCastDelay, Min=0, Max=10, Rounding=1, Callback=function(v) autoCastDelay=v end })
AutoCastSettings:AddDropdown('AutoCastMode', { Text='Auto Cast Mode', Values={'Legit','Rage'}, Default=autoCastMode, Callback=function(v) autoCastMode=v end })
AutoCastSettings:SetupDependencies({ { Toggles.AutoCast, true } })

FishUtilitiesGroup:AddButton({ Text='Sell a fish', Func=function()
    pcall(function() Workspace.world.npcs['Marc Merchant'].merchant.sell:InvokeServer() end)
end })
FishUtilitiesGroup:AddButton({ Text='Sell ALL fish', Func=function()
    pcall(function() Workspace.world.npcs['Marc Merchant'].merchant.sellall:InvokeServer() end)
end })
FishUtilitiesGroup:AddButton({ Text='Appraise fish 🐟 (450C$)', Func=function()
    pcall(function() Workspace.world.npcs['Appraiser'].appraiser.appraise:InvokeServer() end)
end })

ZoneCastGroup:AddToggle('ZoneCast', { Text='Enabled', Default=false, Callback=function(v) ZoneCast=v end })
local ZoneCastDropdowns = ZoneCastGroup:AddDependencyBox()
ZoneCastDropdowns:AddDropdown('ZoneCastValue',{ Text='Zone', Values=fisktable, Default=Zone, Callback=function(v) Zone=v end })
ZoneCastDropdowns:SetupDependencies({ { Toggles.ZoneCast, true } })

CollarPlayerGroup:AddToggle('CollarPlayer', { Text='Enabled', Default=false, Callback=function(v) CollarPlayer=v end })
local CollarPlayerDropdown = CollarPlayerGroup:AddDependencyBox()
CollarPlayerDropdown:AddDropdown('CollarTarget', { Text='Player', Values = {}, Callback=function(v) Target=v end, SpecialType='Player' })
CollarPlayerDropdown:SetupDependencies({ { Toggles.CollarPlayer, true } })

-- Teleports tab
local TeleportsGroup = Tabs.Teleports:AddLeftGroupbox('Teleports')
TeleportsGroup:AddDropdown('PlaceTeleport', { Text='Place teleport', Values=teleportSpots, Default='', Callback=function(v)
    if v ~= '' and HumanoidRootPart and TpSpotsFolder:FindFirstChild(v) then
        HumanoidRootPart.CFrame = TpSpotsFolder[v].CFrame + Vector3.new(0,5,0)
    end
end })
TeleportsGroup:AddDropdown('NPCTeleport', { Text='Teleport to Npc', Values=racistPeople, Default='', Callback=function(v)
    if v ~= '' and HumanoidRootPart and NpcFolder:FindFirstChild(v) then
        local hrp = NpcFolder[v]:FindFirstChild('HumanoidRootPart')
        if hrp then HumanoidRootPart.CFrame = hrp.CFrame + Vector3.new(0,1,0) end
    end
end })
TeleportsGroup:AddDropdown('ItemTeleport', { Text='Teleport to item', Values={'Bait_Crate','Carbon_Rod','Crab_Cage','Fast_Rod','Flimsy_Rod','GPS','Long_Rod','Lucky_Rod','Plastic_Rod','Training_Rod'}, Default='', Callback=function(v)
    if v ~= '' and HumanoidRootPart and itemSpots[v] then HumanoidRootPart.CFrame = itemSpots[v] end
end })

local TeleportToSafeZoneGroup = Tabs.Teleports:AddRightGroupbox('Safe Zone')
TeleportToSafeZoneGroup:AddButton({ Text='Teleport to safe zone', Func=function()
    if HumanoidRootPart then HumanoidRootPart.CFrame = SafeZone.CFrame + Vector3.new(0,2,0) end
end })

-- LocalPlayer tab
local LocalPlayerGroup = Tabs.LocalPlayer:AddLeftGroupbox('LocalPlayer')
LocalPlayerGroup:AddToggle('Noclip', { Text='Noclip', Default=false, Callback=function(v) Noclip=v end })
LocalPlayerGroup:AddToggle('AntiDrown', { Text='Disable Oxygen', Default=false, Callback=function(v)
    AntiDrown = v
    local function disableOxy(char)
        local client = char:FindFirstChild('client')
        local oxygen = client and client:FindFirstChild('oxygen')
        if oxygen then oxygen.Enabled = not AntiDrown end
    end
    disableOxy(LocalCharacter)
    if AntiDrown and not _G._AntiDrownHook then
        _G._AntiDrownHook = LocalPlayer.CharacterAdded:Connect(function(ch)
            LocalCharacter = ch; HumanoidRootPart = ch:WaitForChild('HumanoidRootPart'); task.wait(1); disableOxy(ch)
        end)
    elseif not AntiDrown and _G._AntiDrownHook then
        _G._AntiDrownHook:Disconnect(); _G._AntiDrownHook=nil
    end
end })

local ResetRodGroup = Tabs.LocalPlayer:AddRightGroupbox('Reset')
ResetRodGroup:AddButton({ Text='Reset rod', Func=function()
    local tool = LocalCharacter:FindFirstChildOfClass('Tool')
    if tool and tool:FindFirstChild('events') and tool.events:FindFirstChild('reset') then
        pcall(function() tool.events.reset:FireServer() end)
    end
end })

local AntiAfkGroup = Tabs.LocalPlayer:AddRightGroupbox('AntiAFK')
AntiAfkGroup:AddButton({ Text='Anti-AFK', Func=function()
    Library:Notify('Anti-AFK is now running!')
    LocalPlayer.Idled:Connect(function()
        VirtualUser:CaptureController(); VirtualUser:ClickButton2(Vector2.new())
    end)
end })

local FreezeCharacterGroup = Tabs.LocalPlayer:AddLeftGroupbox('Freeze Character')
FreezeCharacterGroup:AddToggle('FreezeCharacter', { Text='Enabled', Default=false, Callback=function(v)
    local oldpos = HumanoidRootPart and HumanoidRootPart.CFrame
    FreezeChar = v
    if v then
        task.spawn(function()
            while FreezeChar and HumanoidRootPart do
                HumanoidRootPart.CFrame = oldpos
                task.wait()
            end
        end)
    end
end })

-- Settings / Credits
local SettingsGroup = Tabs.Settings:AddLeftGroupbox('Settings')
local CreditsGroup = Tabs.Settings:AddRightGroupbox('Credits')
CreditsGroup:AddLabel('Made by kylosilly and netpa!')
CreditsGroup:AddLabel('Made with love and hate :3')
CreditsGroup:AddButton({ Text='Copy Fisch Discord Link', Func=function() if setclipboard then setclipboard('https://discord.gg/DEkfE99JFh') end end })
CreditsGroup:AddButton({ Text='Copy Main Discord link', Func=function() if setclipboard then setclipboard('https://discord.gg/VudXCDCaBN') end end })
CreditsGroup:AddLabel('البرود يا جماعه هو الحل')

SettingsGroup:AddButton('Unload', function() Library:Unload() end)

SettingsGroup:AddLabel('Menu bind'):AddKeyPicker('MenuKeybind', { Default='End', NoUI=true, Text='Menu keybind' })
Library.ToggleKeybind = Options.MenuKeybind

-- Theme & Save stubs
ThemeManager:SetLibrary(Library)
SaveManager:SetLibrary(Library)
SaveManager:IgnoreThemeSettings()
SaveManager:SetIgnoreIndexes({ 'MenuKeybind' })
ThemeManager:SetFolder('RinnsHub')
SaveManager:SetFolder('RinnsHub/Fisch')
SaveManager:BuildConfigSection(Tabs.Settings)
ThemeManager:ApplyToTab(Tabs.Settings)
SaveManager:LoadAutoloadConfig()

-- Version check (will just print if fails)
local Version = '1.2.3'
task.spawn(function()
    local success, LatestVer = pcall(function()
        local raw = game:HttpGet('https://raw.githubusercontent.com/kylosilly/femboyware/refs/heads/main/fischver')
        return HttpService:JSONDecode(raw)
    end)
    if success and LatestVer and Version ~= LatestVer then
        Library:Notify('You are using an outdated version of the Fisch script.')
        Library:Notify('Join our fisch discord server to get the new script.')
    end
end)

-- Unload cleanup
Library:OnUnload(function()
    Library.Unloaded = true
    autoShake=false; autoReel=false; autoCast=false; ZoneCast=false; CollarPlayer=false; FreezeChar=false
    if AntiDrown and _G._AntiDrownHook then
        _G._AntiDrownHook:Disconnect(); _G._AntiDrownHook=nil
    end
    AntiDrown=false; Noclip=false
    WatermarkConnection:Disconnect()
    autoreelandshakeConnection:Disconnect()
    autoCastConnection:Disconnect()
    autoCastConnection2:Disconnect()
    ZoneConnection:Disconnect()
    CollarConnection:Disconnect()
    NoclipConnection:Disconnect()
end)

Library:Notify('Fisch Fluent version loaded.')
