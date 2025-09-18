-- Minimal Remote Watcher GUI for Steal-a-Jeffy
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LocalPlayer = Players.LocalPlayer

-- Create the GUI
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "RemoteWatcher"
screenGui.Parent = game:GetService("CoreGui") -- use CoreGui to bypass StarterGui restrictions

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 400, 0, 500)
frame.Position = UDim2.new(0, 50, 0, 50)
frame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
frame.BorderSizePixel = 0
frame.Parent = screenGui

-- Title
local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 30)
title.BackgroundTransparency = 1
title.TextColor3 = Color3.new(1,1,1)
title.Text = "Remote Watcher - Steal-a-Jeffy"
title.Font = Enum.Font.SourceSansBold
title.TextSize = 20
title.Parent = frame

-- Log box
local logBox = Instance.new("ScrollingFrame")
logBox.Size = UDim2.new(1, -10, 1, -40)
logBox.Position = UDim2.new(0, 5, 0, 35)
logBox.BackgroundColor3 = Color3.fromRGB(40,40,40)
logBox.CanvasSize = UDim2.new(0,0,2,0)
logBox.ScrollBarThickness = 5
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

-- Function to list all remotes recursively
local function getAllRemotes(root)
    local remotes = {}
    for _,obj in pairs(root:GetDescendants()) do
        if obj:IsA("RemoteEvent") or obj:IsA("RemoteFunction") then
            table.insert(remotes,obj)
        end
    end
    return remotes
end

-- Remote watcher
local remotesFolder = ReplicatedStorage:WaitForChild("voidSky"):WaitForChild("Remotes")
local remotesList = getAllRemotes(remotesFolder)

addLog("Found "..#remotesList.." remotes.")

-- Monitor remote calls from server
for _,remote in pairs(remotesList) do
    if remote:IsA("RemoteEvent") then
        remote.OnClientEvent:Connect(function(...)
            local args = {...}
            addLog("[SERVER EVENT] "..remote:GetFullName().." -> "..table.concat(args,", "))
        end)
    end
end

-- Simple input for manual fire
local inputBox = Instance.new("TextBox")
inputBox.Size = UDim2.new(1, -10, 0, 25)
inputBox.Position = UDim2.new(0,5,1,-60)
inputBox.BackgroundColor3 = Color3.fromRGB(30,30,30)
inputBox.TextColor3 = Color3.new(1,1,1)
inputBox.PlaceholderText = "Remote name, arg1, arg2..."
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
            if remote:IsA("RemoteEvent") then
                remote:FireServer(table.unpack(parts))
            elseif remote:IsA("RemoteFunction") then
                remote:InvokeServer(table.unpack(parts))
            end
            addLog("[CLIENT FIRE] "..remote:GetFullName().." -> "..table.concat(parts,", "))
        end)
    else
        addLog("[ERROR] Remote not found: "..tostring(remoteName))
    end
end)

addLog("Remote watcher ready. Type RemoteName,arg1,arg2,... to fire.")
