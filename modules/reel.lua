-- Reel Minigame Automation Module
-- Mengontrol bar putih untuk mengikuti pergerakan ikan

local Reel = {}

-- Services
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

-- Variables
local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local reelConnection = nil
local isReeling = false

-- Settings
local Settings = {
    enabled = false,
    sensitivity = 0.5, -- 0.1 = lebih halus, 1.0 = lebih agresif
    holdThreshold = 0.3, -- jarak dimana bot akan hold instead of tap
    tapStrength = 0.5, -- kekuatan tap (0.1-1.0)
    holdStrength = 0.8, -- kekuatan hold (0.1-1.0)
    reactionTime = 0.05 -- delay reaction dalam detik
}

-- Fungsi untuk mendapatkan reel GUI
local function getReelGui()
    return playerGui:FindFirstChild("reel")
end

-- Fungsi untuk mendapatkan progress bar dan fish position
local function getReelElements(reelGui)
    if not reelGui then return nil end
    
    local playerbar = reelGui:FindFirstChild("playerbar")
    local fish = reelGui:FindFirstChild("fish")
    local progress = reelGui:FindFirstChild("progress")
    
    return {
        playerbar = playerbar,
        fish = fish,
        progress = progress,
        reelGui = reelGui
    }
end

-- Fungsi untuk menghitung posisi relatif
local function getRelativePosition(element)
    if not element then return 0 end
    
    -- Mendapatkan posisi X relatif (0-1)
    local position = element.Position.X.Scale + (element.Position.X.Offset / element.Parent.AbsoluteSize.X)
    return math.clamp(position, 0, 1)
end

-- Fungsi untuk menghitung ukuran relatif
local function getRelativeSize(element)
    if not element then return 0 end
    
    -- Mendapatkan ukuran X relatif (0-1)
    local size = element.Size.X.Scale + (element.Size.X.Offset / element.Parent.AbsoluteSize.X)
    return math.clamp(size, 0, 1)
end

-- Fungsi untuk simulasi input
local function simulateInput(inputType, strength)
    strength = strength or 0.5
    
    if inputType == "tap" then
        -- Simulasi tap (click cepat)
        UserInputService:GetPropertyChangedSignal("MouseBehavior"):Connect(function() end)
        
        -- Kirim mouse click event
        local mouse = player:GetMouse()
        if mouse then
            -- Simulasi mouse down
            game:GetService("VirtualInputManager"):SendMouseButtonEvent(
                mouse.X, mouse.Y, 0, true, game, 0
            )
            
            -- Wait sebentar lalu release
            wait(0.05 * strength)
            
            game:GetService("VirtualInputManager"):SendMouseButtonEvent(
                mouse.X, mouse.Y, 0, false, game, 0
            )
        end
        
    elseif inputType == "hold" then
        -- Simulasi hold (tahan lebih lama)
        local mouse = player:GetMouse()
        if mouse then
            game:GetService("VirtualInputManager"):SendMouseButtonEvent(
                mouse.X, mouse.Y, 0, true, game, 0
            )
            
            wait(0.1 * strength)
            
            game:GetService("VirtualInputManager"):SendMouseButtonEvent(
                mouse.X, mouse.Y, 0, false, game, 0
            )
        end
    end
end

-- Fungsi utama untuk mengontrol reel
local function controlReel()
    local reelGui = getReelGui()
    if not reelGui then return end
    
    local elements = getReelElements(reelGui)
    if not elements.playerbar or not elements.fish then return end
    
    -- Dapatkan posisi bar putih (player bar)
    local playerPos = getRelativePosition(elements.playerbar)
    local playerSize = getRelativeSize(elements.playerbar)
    local playerCenter = playerPos + (playerSize / 2)
    
    -- Dapatkan posisi ikan (garis hitam)
    local fishPos = getRelativePosition(elements.fish)
    local fishSize = getRelativeSize(elements.fish)
    local fishCenter = fishPos + (fishSize / 2)
    
    -- Hitung perbedaan posisi
    local difference = fishCenter - playerCenter
    local distance = math.abs(difference)
    
    -- Tentukan aksi berdasarkan posisi
    if distance > 0.02 then -- Dead zone untuk menghindari jitter
        if difference > 0 then
            -- Ikan di kanan, bar putih harus bergerak kanan
            if distance > Settings.holdThreshold then
                -- Jarak jauh, gunakan hold (gerakan kencang)
                simulateInput("hold", Settings.holdStrength)
                print("[REEL] 🎯 HOLD RIGHT - Distance:", math.floor(distance * 100) .. "%")
            else
                -- Jarak dekat, gunakan tap (gerakan pelan)
                simulateInput("tap", Settings.tapStrength)
                print("[REEL] 👆 TAP RIGHT - Distance:", math.floor(distance * 100) .. "%")
            end
        else
            -- Ikan di kiri, biarkan bar putih bergerak kiri (tidak perlu input)
            print("[REEL] ⬅️ DRIFT LEFT - Distance:", math.floor(distance * 100) .. "%")
        end
    else
        print("[REEL] ✅ ON TARGET - Perfect position!")
    end
    
    -- Delay sesuai reaction time
    wait(Settings.reactionTime)
end

-- Fungsi untuk memulai reel automation
function Reel.startAutoReel()
    if isReeling then return end
    isReeling = true
    Settings.enabled = true
    
    print("[REEL] 🎣 Auto Reel Started!")
    
    reelConnection = RunService.Heartbeat:Connect(function()
        if not Settings.enabled then return end
        
        local reelGui = getReelGui()
        if reelGui then
            pcall(controlReel)
        else
            -- Jika reel GUI tidak ada, stop automation
            Reel.stopAutoReel()
        end
    end)
end

-- Fungsi untuk menghentikan reel automation
function Reel.stopAutoReel()
    if reelConnection then
        reelConnection:Disconnect()
        reelConnection = nil
    end
    
    isReeling = false
    Settings.enabled = false
    print("[REEL] 🛑 Auto Reel Stopped!")
end

-- Fungsi untuk mengatur sensitivity
function Reel.setSensitivity(value)
    Settings.sensitivity = math.clamp(value, 0.1, 1.0)
    print("[REEL] ⚙️ Sensitivity set to:", Settings.sensitivity)
end

-- Fungsi untuk mengatur hold threshold
function Reel.setHoldThreshold(value)
    Settings.holdThreshold = math.clamp(value, 0.1, 0.8)
    print("[REEL] ⚙️ Hold threshold set to:", Settings.holdThreshold)
end

-- Fungsi untuk mengatur tap strength
function Reel.setTapStrength(value)
    Settings.tapStrength = math.clamp(value, 0.1, 1.0)
    print("[REEL] ⚙️ Tap strength set to:", Settings.tapStrength)
end

-- Fungsi untuk mengatur hold strength
function Reel.setHoldStrength(value)
    Settings.holdStrength = math.clamp(value, 0.1, 1.0)
    print("[REEL] ⚙️ Hold strength set to:", Settings.holdStrength)
end

-- Fungsi untuk mendapatkan status
function Reel.getStatus()
    return {
        enabled = Settings.enabled,
        isReeling = isReeling,
        sensitivity = Settings.sensitivity,
        holdThreshold = Settings.holdThreshold,
        tapStrength = Settings.tapStrength,
        holdStrength = Settings.holdStrength
    }
end

-- Auto-start detection
spawn(function()
    while true do
        wait(0.1)
        
        if Settings.enabled and not isReeling then
            local reelGui = getReelGui()
            if reelGui then
                print("[REEL] 🎯 Reel minigame detected! Starting automation...")
                Reel.startAutoReel()
            end
        end
        
        if isReeling and not getReelGui() then
            print("[REEL] 🎣 Reel minigame ended! Stopping automation...")
            Reel.stopAutoReel()
        end
    end
end)

return Reel
