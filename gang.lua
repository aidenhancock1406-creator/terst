-- SwebHub Remote Watcher + Object Inspector GUI for Steal-a-Jeffy
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local LocalPlayer = Players.LocalPlayer

-- ---------- GUI ----------
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "SwebHubAdmin"
screenGui.Parent = game:GetService("CoreGui")

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 700, 0, 700)
frame.Position = UDim2.new(0, 50, 0, 50)
frame.BackgroundColor3 = Color3.fromRGB(25,25,25)
frame.BorderSizePixel = 0
frame.Parent = screenGui

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1,0,0,30)
title.BackgroundTransparency = 1
title.TextColor3 = Color3.fromRGB(255,255,255)
title.Text = "SwebHub - Remote + Object Inspector"
title.Font = Enum.Font.SourceSansBold
title.TextSize = 22
title.Parent = frame

-- ---------- Log ----------
local logBox = Instance.new("ScrollingFrame")
logBox.Size = UDim2.new(0.6, -10, 1, -40)
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
objectBox.Size = UDim2.new(0.35, -10, 1, -40)
objectBox.Position = UDim2.new(0.625, 5, 0, 35)
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

    -- Clicking copies name to input box
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

addLog("GUI ready! Click objects to autofill, type remote+args, press Fire Remote.")
