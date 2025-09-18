-- SwebHub Remote Watcher + Object Inspector GUI for Steal-a-Jeffy (Upgraded)
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer

-- ---------- GUI ----------
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "SwebHubAdmin"
screenGui.Parent = LocalPlayer:WaitForChild("PlayerGui") -- use PlayerGui for live Roblox

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 1000, 0, 700) -- larger window
frame.Position = UDim2.new(0.05, 0, 0.05, 0)
frame.BackgroundColor3 = Color3.fromRGB(25,25,25)
frame.BorderSizePixel = 0
frame.Parent = screenGui

-- Make draggable
frame.Active = true
frame.Draggable = true

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1,0,0,30)
title.BackgroundTransparency = 1
title.TextColor3 = Color3.fromRGB(255,255,255)
title.Text = "SwebHub - Remote + Object Inspector + Spawner"
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

-- ---------- Remote Helpers ----------
local function getAllRemotes(root)
    local remotes = {}
    for _,obj in pairs(root:GetDescendants()) do
        if obj:IsA("RemoteEvent") or obj:IsA("RemoteFunction") then
            table.insert(remotes,obj)
        end
    end
    return remotes
end

local remotesFolder = ReplicatedStorage:WaitForChild("voidSky"):WaitForChild("Remotes")
local remotesList = getAllRemotes(remotesFolder)
addLog("Found "..#remotesList.." remotes.")

-- Monitor server events
for _,remote in pairs(remotesList) do
    if remote:IsA("RemoteEvent") then
        remote.OnClientEvent:Connect(function(...)
            local args = {...}
            addLog("[SERVER EVENT] "..remote:GetFullName().." -> "..table.concat(args,", "))
        end)
    end
end

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

-- Display objects
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
        if inputBox then
            inputBox.Text = obj.Name
            addLog("[INFO] Selected object: "..obj:GetFullName())
        end
    end)
end
objectBox.CanvasSize = UDim2.new(0,0,0,#workspaceObjects*22)

-- ---------- Manual Remote Fire ----------
local inputBox = Instance.new("TextBox")
inputBox.Size = UDim2.new(1, -10, 0, 25)
inputBox.Position = UDim2.new(0,5,1,-60)
inputBox.BackgroundColor3 = Color3.fromRGB(30,30,30)
inputBox.TextColor3 = Color3.new(1,1,1)
inputBox.PlaceholderText = "RemoteName,arg1,arg2,..."
inputBox.Font = Enum.Font.SourceSans
inputBox.TextSize = 16
inputBox.Parent = frame

local fireBtn = Instance.new("TextButton")
fireBtn.Size = UDim2.new(1, -10, 0, 25)
fireBtn.Position = UDim2.new(0,5,1,-30)
fireBtn.BackgroundColor3 = Color3.fromRGB(50,50,50)
fireBtn.TextColor3 = Color3.new(1,1,1)
fireBtn.Text = "Fire Remote"
fireBtn.Font = Enum.Font.SourceSans
fireBtn.TextSize = 16
fireBtn.Parent = frame

local function fireRemote(remote, args)
    args = args or {}
    if remote:IsA("RemoteEvent") then
        remote:FireServer(table.unpack(args))
    elseif remote:IsA("RemoteFunction") then
        remote:InvokeServer(table.unpack(args))
    end
end

fireBtn.MouseButton1Click:Connect(function()
    local text = inputBox.Text
    local parts = {}
    for val in string.gmatch(text,"[^,]+") do
        val = val:gsub("^%s*(.-)%s*$","%1")
        local n = tonumber(val)
        if n then val = n end
        table.insert(parts,val)
    end
    local remoteName = table.remove(parts,1)
    local remote = remotesFolder:FindFirstChild(remoteName,true)
    if remote then
        pcall(function()
            fireRemote(remote, parts)
            addLog("[CLIENT FIRE] "..remote:GetFullName().." -> "..table.concat(parts,", "))
        end)
    else
        addLog("[ERROR] Remote not found: "..tostring(remoteName))
    end
end)

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
local conveyorItems = {"SpawnItem","Jeffy","Brainrot"} -- adjust names from game
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
        local remote = remotesFolder:FindFirstChild("VFX",true)
        if remote then
            fireRemote(remote, {"Conveyor",name})
            addLog("[SPAWNER] Fired "..name.." via Conveyor")
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
