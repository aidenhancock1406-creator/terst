-- Parent this to StarterGui
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LocalPlayer = Players.LocalPlayer

-- Remote
local TweenOwned = ReplicatedStorage:WaitForChild("voidSky"):WaitForChild("Remotes")
    :WaitForChild("Client"):WaitForChild("Objects"):WaitForChild("Trash"):WaitForChild("TweenOwned")

-- Folder containing all spawnable items
local Trash = ReplicatedStorage:WaitForChild("voidSky"):WaitForChild("Client")
    :WaitForChild("Objects"):WaitForChild("Trash")

-- GUI Setup
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "ParentalGUI"
screenGui.Parent = game:GetService("CoreGui")

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 250, 0, 400)
frame.Position = UDim2.new(0.5, -125, 0.5, -200)
frame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
frame.BorderSizePixel = 0
frame.Parent = screenGui

-- UIListLayout for auto-stacking buttons
local layout = Instance.new("UIListLayout")
layout.Parent = frame
layout.SortOrder = Enum.SortOrder.LayoutOrder
layout.Padding = UDim.new(0, 5)

-- Function to spawn an item on the conveyor
local function spawnItem(itemName, uuid)
    local targetCFrame = CFrame.new(-4.34677, 6.06641, 201.579) -- Conveyor position
    local speed = 12.47
    local param1 = true
    local param2 = false

    TweenOwned:FireClient(LocalPlayer, itemName, uuid, targetCFrame, speed, param1, param2)
end

-- Create a button for each item in Trash
for _, item in pairs(Trash:GetChildren()) do
    local itemName = item.Name
    local uuid = item:GetAttribute("UUID") or "NoUUID"

    local button = Instance.new("TextButton")
    button.Size = UDim2.new(1, -10, 0, 35)
    button.Text = itemName
    button.BackgroundColor3 = Color3.fromRGB(0, 170, 0)
    button.TextColor3 = Color3.fromRGB(255, 255, 255)
    button.Parent = frame

    button.MouseButton1Click:Connect(function()
        spawnItem(itemName, uuid)
    end)
end
