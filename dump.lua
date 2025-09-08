-- ⚡ Remote & Module Explorer UI + Save to File (Lengkap)
local HttpService = game:GetService("HttpService")

-- Kumpulkan semua Remote & Module
local function scanGame()
    local remotes, modules = {}, {}
    for _, obj in ipairs(game:GetDescendants()) do
        if obj:IsA("RemoteEvent") or obj:IsA("RemoteFunction") then
            table.insert(remotes, {Name=obj.Name, Path=obj:GetFullName(), Type=obj.ClassName})
        elseif obj:IsA("ModuleScript") then
            table.insert(modules, {Name=obj.Name, Path=obj:GetFullName(), Type=obj.ClassName})
        end
    end
    return remotes, modules
end

-- GUI
local sg = Instance.new("ScreenGui", game.CoreGui)
sg.Name = "ExplorerUI"

local frame = Instance.new("Frame", sg)
frame.Size = UDim2.new(0, 500, 0, 350)
frame.Position = UDim2.new(0.5, -250, 0.5, -175)
frame.BackgroundColor3 = Color3.fromRGB(30,30,30)
frame.Active = true
frame.Draggable = true

local title = Instance.new("TextLabel", frame)
title.Size = UDim2.new(1,0,0,30)
title.BackgroundColor3 = Color3.fromRGB(45,45,45)
title.Text = "⚡ Remote & Module Explorer"
title.TextColor3 = Color3.new(1,1,1)
title.Font = Enum.Font.SourceSansBold
title.TextSize = 18

-- List Frame
local listFrame = Instance.new("ScrollingFrame", frame)
listFrame.Size = UDim2.new(0.5,-15,1,-70)
listFrame.Position = UDim2.new(0,10,0,40)
listFrame.BackgroundColor3 = Color3.fromRGB(40,40,40)
listFrame.ScrollBarThickness = 6
listFrame.CanvasSize = UDim2.new(0,0,0,0)

-- Info Panel
local infoPanel = Instance.new("TextLabel", frame)
infoPanel.Size = UDim2.new(0.5,-15,1,-70)
infoPanel.Position = UDim2.new(0.5,5,0,40)
infoPanel.BackgroundColor3 = Color3.fromRGB(20,20,20)
infoPanel.TextColor3 = Color3.new(1,1,1)
infoPanel.TextWrapped = true
infoPanel.TextXAlignment = Enum.TextXAlignment.Left
infoPanel.TextYAlignment = Enum.TextYAlignment.Top
infoPanel.Font = Enum.Font.Code
infoPanel.TextSize = 14
infoPanel.Text = "Klik item untuk lihat detail..."

-- Tombol Save
local saveBtn = Instance.new("TextButton", frame)
saveBtn.Text = "💾 Save to Dump.txt"
saveBtn.Size = UDim2.new(0,180,0,30)
saveBtn.Position = UDim2.new(0,10,1,-35)
saveBtn.BackgroundColor3 = Color3.fromRGB(0,170,0)
saveBtn.TextColor3 = Color3.new(1,1,1)

-- Tombol Close
local closeBtn = Instance.new("TextButton", frame)
closeBtn.Text = "X"
closeBtn.Size = UDim2.new(0,40,0,30)
closeBtn.Position = UDim2.new(1,-50,0,0)
closeBtn.BackgroundColor3 = Color3.fromRGB(170,0,0)
closeBtn.TextColor3 = Color3.new(1,1,1)

-- Populate List
local function refreshList()
    listFrame:ClearAllChildren()
    local remotes, modules = scanGame()
    local items = {}

    for _, r in ipairs(remotes) do
        table.insert(items, {Text = "[Remote] "..r.Name, Info = r})
    end
    for _, m in ipairs(modules) do
        table.insert(items, {Text = "[Module] "..m.Name, Info = m})
    end

    for i, item in ipairs(items) do
        local btn = Instance.new("TextButton", listFrame)
        btn.Size = UDim2.new(1,-10,0,25)
        btn.Position = UDim2.new(0,5,0,(i-1)*27)
        btn.Text = item.Text
        btn.BackgroundColor3 = Color3.fromRGB(70,70,70)
        btn.TextColor3 = Color3.new(1,1,1)

        btn.MouseButton1Click:Connect(function()
            infoPanel.Text = "Name: "..item.Info.Name
                .."\nType: "..item.Info.Type
                .."\nPath: "..item.Info.Path
        end)
    end
    listFrame.CanvasSize = UDim2.new(0,0,0,#items*27)
    return remotes, modules
end

-- Save to file
saveBtn.MouseButton1Click:Connect(function()
    local remotes, modules = scanGame()
    local dump = {"🔎 Remote Dump"}
    for _, r in ipairs(remotes) do
        table.insert(dump, r.Type..": "..r.Path)
    end
    table.insert(dump, "\n📦 ModuleScript Dump")
    for _, m in ipairs(modules) do
        table.insert(dump, m.Type..": "..m.Path)
    end

    local text = table.concat(dump, "\n")
    writefile("Dump.txt", text)
    warn("[Explorer] ✅ Semua Remote & Module tersimpan di Dump.txt")
end)

closeBtn.MouseButton1Click:Connect(function()
    sg:Destroy()
end)

-- Init
refreshList()
print("[✅ Explorer] UI aktif → Semua Remote & Module ditampilkan. Bisa klik untuk detail atau Save.")
