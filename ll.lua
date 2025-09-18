-- SwebHub Remote Watcher + Object Inspector GUI for Steal-a-Jeffy (TweenOwned Focus)
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer

-- ---------- GUI ----------
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "SwebHubAdmin"
screenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 1000, 0, 700)
frame.Position = UDim2.new(0.05, 0, 0.05, 0)
frame.BackgroundColor3 = Color3.fromRGB(25,25,25)
frame.BorderSizePixel = 0
frame.Active = true
frame.Draggable = true
frame.Parent = screenGui

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1,0,0,30)
title.BackgroundTransparency = 1
title.TextColor3 = Color3.fromRGB(255,255,255)
title.Text = "SwebHub - TweenOwned Watcher + Object Inspector + Spawner"
title.Font = Enum.Font.SourceSansBold
title.TextSize = 22
title.Parent = frame

-- ---------- Log ----------
local logBox = Instance.new("ScrollingFrame")
logBox.Size = UDim2.new(0.5, -10, 1, -40)
logBox.Position = UDim2.new(0, 5, 0, 35)
logBox.BackgroundColor3 = Color3.fromRGB(40,40,40)
logBox.CanvasSize = UDim2.new(0,0,2,0)
logBox.ScrollBarThickness = 8
logBox.Parent = frame

local function addLog(text)
    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, -10, 0, 20)
    lbl.Position = UDim2.new(0, 5, 0, #logBox:GetChildren()*20)
    lbl.BackgroundTransparency = 1
    lbl.TextColor3 = Color3.fromRGB(255,255,255)
    lbl.Font = Enum.Font.SourceSans
    lbl.TextSize = 16
    lbl.Text = text
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Parent = logBox
    logBox.CanvasSize = UDim2.new(0,0,0,#logBox:GetChildren()*20)
end

-- ---------- TweenOwned Remote Watcher ----------
local trashFolder = ReplicatedStorage:WaitForChild("voidSky")
                               :WaitForChild("Remotes")
                               :WaitForChild("Client")
                               :WaitForChild("Objects")
                               :WaitForChild("Trash")
local tweenOwnedRemote = trashFolder:WaitForChild("TweenOwned")
addLog("Monitoring TweenOwned remote...")

local lastTweenCall

tweenOwnedRemote.OnClientEvent:Connect(function(...)
    local args = {...}
    lastTweenCall = args
    local argStrings = {}
    for i,v in pairs(args) do
        table.insert(argStrings, tostring(v))
    end
    addLog("[TweenOwned Fired] "..table.concat(argStrings,", "))
end)

-- Button to copy and fire last call
local fireLastBtn = Instance.new("TextButton")
fireLastBtn.Size = UDim2.new(0, 150, 0, 25)
fireLastBtn.Position = UDim2.new(0.75, 5, 0.55, 0)
fireLastBtn.BackgroundColor3 = Color3.fromRGB(80,80,80)
fireLastBtn.TextColor3 = Color3.fromRGB(255,255,255)
fireLastBtn.Font = Enum.Font.SourceSans
fireLastBtn.TextSize = 16
fireLastBtn.Text = "Copy + Fire TweenOwned"
fireLastBtn.Parent = frame

fireLastBtn.MouseButton1Click:Connect(function()
    if lastTweenCall then
        pcall(function()
            tweenOwnedRemote:FireServer(unpack(lastTweenCall))
            addLog("[Replay] Fired TweenOwned with copied args")
        end)
    else
        addLog("[ERROR] No TweenOwned call to copy")
    end
end)

-- ---------- Workspace Object Inspector ----------
local objectBox = Instance.new("ScrollingFrame")
objectBox.Size = UDim2.new(0.25, -10, 1, -40)
objectBox.Position = UDim2.new(0.5, 5, 0, 35)
objectBox.BackgroundColor3 = Color3.fromRGB(40,40,40)
objectBox.CanvasSize = UDim2.new(0,0,2,0)
objectBox.ScrollBarThickness = 8
objectBox.Parent = frame

local workspaceObjects = Workspace:GetDescendants()
addLog("Found "..#workspaceObjects.." objects in Workspace.")

local inputBox = Instance.new("TextBox")
inputBox.Size = UDim2.new(1, -10, 0, 25)
inputBox.Position = UDim2.new(0,5,1,-60)
inputBox.BackgroundColor3 = Color3.fromRGB(30,30,30)
inputBox.TextColor3 = Color3.new(1,1,1)
inputBox.PlaceholderText = "Selected Object Name"
inputBox.Font = Enum.Font.SourceSans
inputBox.TextSize = 16
inputBox.Parent = frame

for i, obj in pairs(workspaceObjects) do
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -10, 0, 20)
    btn.Position = UDim2.new(0,5,0,(i-1)*22)
    btn.BackgroundColor3 = Color3.fromRGB(50,50,50)
    btn.TextColor3 = Color3.fromRGB(255,255,255)
    btn.Font = Enum.Font.SourceSans
    btn.TextSize = 14
    btn.Text = obj:GetFullName().." | "..obj.ClassName
    btn.TextXAlignment = Enum.TextXAlignment.Left
    btn.Parent = objectBox

    btn.MouseButton1Click:Connect(function()
        inputBox.Text = obj.Name
        addLog("[INFO] Selected object: "..obj:GetFullName())
    end)
end
objectBox.CanvasSize = UDim2.new(0,0,0,#workspaceObjects*22)

-- ---------- Spawner Tab ----------
local spawnerLabel = Instance.new("TextLabel")
spawnerLabel.Size = UDim2.new(0.25, -10, 0, 30)
spawnerLabel.Position = UDim2.new(0.75, 5, 0, 35)
spawnerLabel.Text = "Spawner (Conveyor Items)"
spawnerLabel.TextColor3 = Color3.fromRGB(255,255,255)
spawnerLabel.BackgroundTransparency = 0.5
spawnerLabel.BackgroundColor3 = Color3.fromRGB(50,50,50)
spawnerLabel.Font = Enum.Font.SourceSansBold
spawnerLabel.TextSize = 18
spawnerLabel.Parent = frame

local spawnerBox = Instance.new("ScrollingFrame")
spawnerBox.Size = UDim2.new(0.25, -10, 0.5, -40)
spawnerBox.Position = UDim2.new(0.75, 5, 0, 70)
spawnerBox.BackgroundColor3 = Color3.fromRGB(40,40,40)
spawnerBox.CanvasSize = UDim2.new(0,0,2,0)
spawnerBox.ScrollBarThickness = 8
spawnerBox.Parent = frame

-- Example conveyor items
local conveyorItems = {"SpawnItem","Jeffy","Brainrot"} -- adjust to game
for i,name in pairs(conveyorItems) do
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -10, 0, 25)
    btn.Position = UDim2.new(0,5,0,(i-1)*30)
    btn.BackgroundColor3 = Color3.fromRGB(60,60,60)
    btn.TextColor3 = Color3.fromRGB(255,255,255)
    btn.Font = Enum.Font.SourceSans
    btn.TextSize = 16
    btn.Text = name
    btn.Parent = spawnerBox

    btn.MouseButton1Click:Connect(function()
        local remote = trashFolder:FindFirstChild("TweenOwned",true)
        if remote then
            -- Fire remote as a simple spawn, you may adjust args
            pcall(function()
                remote:FireServer(LocalPlayer, name, "exampleUUID", CFrame.new(0,5,0), 5, true, false)
                addLog("[SPAWNER] Fired "..name.." via TweenOwned")
            end)
        end
    end)
end
spawnerBox.CanvasSize = UDim2.new(0,0,0,#conveyorItems*30)

-- ---------- Toggle Menu ----------
local guiVisible = true
UserInputService.InputBegan:Connect(function(input, processed)
    if processed then return end
    if input.KeyCode == Enum.KeyCode.RightShift then
        guiVisible = not guiVisible
        frame.Visible = guiVisible
    end
end)

addLog("SwebHub ready! RightShift to toggle menu.")
