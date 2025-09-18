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
screenGui.Parent = game:GetService("CoreGui") -- Use CoreGui so it works locally

-- Create main frame
local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 200, 0, 100)
frame.Position = UDim2.new(0.5, -100, 0.5, -50)
frame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
frame.BorderSizePixel = 0
frame.Parent = screenGui

-- Button to spawn item
local spawnButton = Instance.new("TextButton")
spawnButton.Size = UDim2.new(0, 180, 0, 50)
spawnButton.Position = UDim2.new(0, 10, 0, 25)
spawnButton.Text = "Spawn Timmy"
spawnButton.BackgroundColor3 = Color3.fromRGB(0, 170, 0)
spawnButton.TextColor3 = Color3.fromRGB(255, 255, 255)
spawnButton.Parent = frame

-- Function to spawn object on conveyor
spawnButton.MouseButton1Click:Connect(function()
    local targetCFrame = CFrame.new(-4.34677, 6.06641, 201.579) -- Conveyor position
    local objectName = "Timmy"
    local uuid = "3f2463e0-8df3-459b-b923-98c27f095c14"
    local speed = 12.47
    local param1 = true
    local param2 = false

    -- Fire the tween event for the local player
    TweenOwned:FireClient(LocalPlayer, objectName, uuid, targetCFrame, speed, param1, param2)
end)
