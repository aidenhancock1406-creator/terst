-- ---------- Dynamic Spawner Tab ----------
local spawnerLabel = Instance.new("TextLabel")
spawnerLabel.Size = UDim2.new(0.25, -10, 0, 30)
spawnerLabel.Position = UDim2.new(0.75, 5, 0, 35)
spawnerLabel.Text = "Spawner (Dynamic Objects)"
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

-- Locate all spawnable objects dynamically
local objectsFolder = ReplicatedStorage:WaitForChild("voidSky"):WaitForChild("Remotes"):WaitForChild("Client"):WaitForChild("Objects")

local buttonIndex = 0
for _, category in pairs(objectsFolder:GetChildren()) do
    for _, itemRemote in pairs(category:GetChildren()) do
        if itemRemote:IsA("RemoteEvent") then
            buttonIndex = buttonIndex + 1
            local btn = Instance.new("TextButton")
            btn.Size = UDim2.new(1, -10, 0, 25)
            btn.Position = UDim2.new(0,5,0,(buttonIndex-1)*30)
            btn.BackgroundColor3 = Color3.fromRGB(60,60,60)
            btn.TextColor3 = Color3.fromRGB(255,255,255)
            btn.Font = Enum.Font.SourceSans
            btn.TextSize = 16
            btn.Text = category.Name.." | "..itemRemote.Name
            btn.Parent = spawnerBox

            -- Clicking fires the RemoteEvent to spawn the object
            btn.MouseButton1Click:Connect(function()
                pcall(function()
                    -- Example arguments based on your previous find:
                    -- Player, ObjectName, ID, CFrame, Speed, Boolean1, Boolean2
                    local targetPlayer = LocalPlayer
                    local objectName = itemRemote.Name
                    local objectID = HttpService:GenerateGUID(false) -- generate unique ID
                    local spawnCFrame = CFrame.new(LocalPlayer.Character.HumanoidRootPart.Position + Vector3.new(0,5,0))
                    local speed = 10
                    local flag1, flag2 = true, false

                    itemRemote:FireServer(targetPlayer, objectName, objectID, spawnCFrame, speed, flag1, flag2)
                    addLog("[SPAWNER] Fired "..objectName.." via "..category.Name)
                end)
            end)
        end
    end
end

spawnerBox.CanvasSize = UDim2.new(0,0,0,buttonIndex*30)
