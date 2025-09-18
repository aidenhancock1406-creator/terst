-- SwebHub Admin GUI Loader
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local HttpService = game:GetService("HttpService")

-- ---------- ScreenGui ----------
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "SwebHubAdmin"
screenGui.ResetOnSpawn = false
screenGui.Parent = LocalPlayer:WaitForChild("PlayerGui") -- important for Roblox live

-- ---------- Main Frame ----------
local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 1000, 0, 700)
frame.Position = UDim2.new(0.05,0,0.05,0)
frame.BackgroundColor3 = Color3.fromRGB(25,25,25)
frame.BorderSizePixel = 0
frame.Active = true
frame.Draggable = true
frame.Parent = screenGui

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1,0,0,30)
title.Position = UDim2.new(0,0,0,0)
title.BackgroundTransparency = 1
title.TextColor3 = Color3.fromRGB(255,255,255)
title.Text = "SwebHub - Remote + Object Inspector + Spawner"
title.Font = Enum.Font.SourceSansBold
title.TextSize = 22
title.Parent = frame

-- ---------- Log ----------
local logBox = Instance.new("ScrollingFrame")
logBox.Size = UDim2.new(0.5, -10, 1, -40)
logBox.Position = UDim2.new(0,5,0,35)
logBox.BackgroundColor3 = Color3.fromRGB(40,40,40)
logBox.ScrollBarThickness = 8
logBox.CanvasSize = UDim2.new(0,0,0,0)
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

addLog("SwebHub GUI Loaded Successfully!")
