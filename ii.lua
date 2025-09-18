local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LocalPlayer = Players.LocalPlayer

local TweenOwned = ReplicatedStorage:WaitForChild("voidSky"):WaitForChild("Remotes")
    :WaitForChild("Client"):WaitForChild("Objects"):WaitForChild("Trash"):WaitForChild("TweenOwned")

local Trash = ReplicatedStorage:WaitForChild("voidSky"):WaitForChild("Client")
    :WaitForChild("Objects"):WaitForChild("Trash")

-- Get a safe parent for exploits (CoreGui or gethui())
local guiParent
if syn and syn.protect_gui then
    guiParent = gethui()
else
    guiParent = game:GetService("CoreGui")
end

-- Create GUI
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "ParentalGUI"
screenGui.ResetOnSpawn = false -- Important for non-Studio
screenGui.Parent = guiParent

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 250, 0, 400)
frame.Position = UDim2.new(0.5, -125, 0.5, -200)
frame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
frame.BorderSizePixel = 0
frame.Parent = screenGui

local layout = Instance.new("UIListLayout")
layout.Parent = frame
layout.SortOrder = Enum.SortOrder.LayoutOrder
layout.Padding = UDim.new(0, 5)

local function spawnItem(itemName, uuid)
    local targetCFrame = CFrame.new(-4.34677, 6.06641, 201.579)
    local speed = 12.47
    local param1 = true
    local param2 = false

    TweenOwned:FireClient(LocalPlayer, itemName, uuid, targetCFrame, speed, param1, param2)
end

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
