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
frame.Size = UDim2.new(0, 250, 0, 400)
frame.Position = UDim2.new(0.5, -125, 0.5, -200)
frame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
frame.BorderSizePixel = 0
frame.Parent = screenGui

-- Create UIGridLayout to organize buttons
local gridLayout = Instance.new("UIGridLayout")
gridLayout.CellSize = UDim2.new(0, 230, 0, 50)
gridLayout.CellPadding = UDim2.new(0, 10, 0, 10)
gridLayout.Parent = frame

-- Function to create a button for each item
local function createButton(item)
    local button = Instance.new("TextButton")
    button.Size = UDim2.new(0, 230, 0, 50)
    button.Text = item.Name
    button.BackgroundColor3 = Color3.fromRGB(0, 170, 0)
    button.TextColor3 = Color3.fromRGB(255, 255, 255)
    button.Parent = frame

    button.MouseButton1Click:Connect(function()
        local targetCFrame = CFrame.new(-4.34677, 6.06641, 201.579) -- Conveyor position
        local objectName = item.Name
        local uuid = item:FindFirstChild("UUID") and item.UUID.Value or "UNKNOWN"
        local speed = 12.47
        local param1 = true
        local param2 = false

        TweenOwned:FireClient(LocalPlayer, objectName, uuid, targetCFrame, speed, param1, param2)
    end)
end

-- Loop through all items under Trash and create buttons
local trashFolder = ReplicatedStorage:WaitForChild("voidSky"):WaitForChild("Remotes")
    :WaitForChild("Client"):WaitForChild("Objects"):WaitForChild("Trash")

for _, item in pairs(trashFolder:GetChildren()) do
    if item:IsA("Folder") or item:IsA("ModuleScript") then
        createButton(item)
    end
end
