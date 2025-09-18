-- Parent this to StarterGui
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LocalPlayer = Players.LocalPlayer

-- Remote
local TweenOwned = ReplicatedStorage:WaitForChild("voidSky"):WaitForChild("Remotes")
    :WaitForChild("Client"):WaitForChild("Objects"):WaitForChild("Trash"):WaitForChild("TweenOwned")

-- Create ScreenGui
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "ParentalGUI"
screenGui.Parent = game:GetService("CoreGui")

-- Main frame
local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 300, 0, 400)
frame.Position = UDim2.new(0.5, -150, 0.5, -200)
frame.BackgroundColor3 = Color3.fromRGB(60, 60, 60) -- Slightly lighter grey
frame.BorderSizePixel = 2
frame.BorderColor3 = Color3.fromRGB(0,0,0)
frame.Parent = screenGui

-- Title
local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 30)
title.Position = UDim2.new(0, 0, 0, 0)
title.Text = "Trash Spawner"
title.TextColor3 = Color3.fromRGB(255,255,255)
title.BackgroundColor3 = Color3.fromRGB(30,30,30)
title.Parent = frame

-- ScrollingFrame for buttons
local scrollFrame = Instance.new("ScrollingFrame")
scrollFrame.Size = UDim2.new(1, -10, 1, -40)
scrollFrame.Position = UDim2.new(0, 5, 0, 35)
scrollFrame.BackgroundTransparency = 1
scrollFrame.ScrollBarThickness = 6
scrollFrame.Parent = frame

-- UIGridLayout to organize buttons
local gridLayout = Instance.new("UIGridLayout")
gridLayout.CellSize = UDim2.new(0, 280, 0, 50)
gridLayout.CellPadding = UDim2.new(0, 5, 0, 5)
gridLayout.Parent = scrollFrame

-- Function to create buttons
local function createButton(item)
    local button = Instance.new("TextButton")
    button.Size = UDim2.new(0, 280, 0, 50)
    button.Text = item.Name
    button.BackgroundColor3 = Color3.fromRGB(0, 170, 0)
    button.TextColor3 = Color3.fromRGB(255, 255, 255)
    button.Parent = scrollFrame

    button.MouseButton1Click:Connect(function()
        local targetCFrame = CFrame.new(-4.34677, 6.06641, 201.579)
        local objectName = item.Name
        local uuid = item:FindFirstChild("UUID") and item.UUID.Value or "UNKNOWN"
        local speed = 12.47
        local param1 = true
        local param2 = false

        TweenOwned:FireClient(LocalPlayer, objectName, uuid, targetCFrame, speed, param1, param2)
    end)
end

-- Load all items
local trashFolder = ReplicatedStorage:WaitForChild("voidSky"):WaitForChild("Remotes")
    :WaitForChild("Client"):WaitForChild("Objects"):WaitForChild("Trash")

for _, item in pairs(trashFolder:GetChildren()) do
    createButton(item)
end
