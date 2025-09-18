-- Sweb Hub - Hypershot (Full Exploit Version)
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Window
local Window = Rayfield:CreateWindow({
    Name = "Sweb Hub - Hypershot",
    Icon = 0,
    LoadingTitle = "Sweb Hub",
    LoadingSubtitle = "by Sweb",
    ShowText = "Sweb Hub",
    Theme = "Default",
    ToggleUIKeybind = "K",
    ConfigurationSaving = {Enabled = true, FolderName = "SwebHubConfigs", FileName = "HypershotHub"},
    KeySystem = true,
    KeySettings = {Title = "Sweb Hub Key", Subtitle = "Enter Key to Continue", Note = "Key: 1", FileName = "Key", SaveKey = false, GrabKeyFromSite = false, Key = {"1"}}
})

-- Tabs
local GameplayTab = Window:CreateTab("Gameplay", 4483362458)
local VisualsTab = Window:CreateTab("Visuals", 4483362458)
local SettingsTab = Window:CreateTab("Settings", 4483362458)
local CreditsTab = Window:CreateTab("Credits", 4483362458)

-- ===== Gameplay Variables =====
local AutoAimEnabled = false
local RapidFireEnabled = false
local ShootSpeedValue = 50
local FireKey = Enum.KeyCode.F

-- Auto Aim Toggle
GameplayTab:CreateToggle({Name = "Auto Aim", CurrentValue = false, Flag = "AutoAim", Callback = function(Value) AutoAimEnabled = Value end})
-- Rapid Fire Toggle
GameplayTab:CreateToggle({Name = "Rapid Fire", CurrentValue = false, Flag = "RapidFire", Callback = function(Value) RapidFireEnabled = Value end})
-- Shoot Speed Slider
GameplayTab:CreateSlider({Name = "Shoot Speed (ms)", Range = {10, 200}, Increment = 5, Suffix = "ms", CurrentValue = 50, Flag = "ShootSpeed", Callback = function(Value) ShootSpeedValue = Value end})
-- Fire Keybind
GameplayTab:CreateKeybind({Name = "Fire Keybind", CurrentKeybind = "F", HoldToInteract = true, Flag = "FireKeybind", Callback = function(Keybind) FireKey = Enum.KeyCode[Keybind] end})

-- ===== ESP Variables =====
local ESPEnabled = false
local ESPColor = Color3.fromRGB(0,255,0)
VisualsTab:CreateToggle({Name = "Player ESP", CurrentValue = false, Flag = "ESP", Callback = function(Value) ESPEnabled = Value end})
VisualsTab:CreateColorPicker({Name = "ESP Color", Color = ESPColor, Flag = "ESPColor", Callback = function(Value) ESPColor = Value end})

-- Function to create ESP boxes
local ESPBoxes = {}
local function createESP(player)
    if player == LocalPlayer then return end
    if ESPBoxes[player] then return end
    if not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") then return end
    local box = Instance.new("BoxHandleAdornment")
    box.Name = "SwebESP"
    box.Adornee = player.Character.HumanoidRootPart
    box.Color3 = ESPColor
    box.Transparency = 0.3
    box.Size = Vector3.new(2,5,2)
    box.AlwaysOnTop = true
    box.ZIndex = 10
    box.Parent = Workspace
    ESPBoxes[player] = box
end

local function removeESP(player)
    if ESPBoxes[player] then
        ESPBoxes[player]:Destroy()
        ESPBoxes[player] = nil
    end
end

Players.PlayerRemoving:Connect(removeESP)
RunService.RenderStepped:Connect(function()
    for _, player in pairs(Players:GetPlayers()) do
        if ESPEnabled then
            createESP(player)
        else
            removeESP(player)
        end
    end
end)

-- ===== Auto Aim & Rapid Fire Logic =====
local function getNearestTarget()
    local closest = nil
    local shortestDistance = math.huge
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local distance = (player.Character.HumanoidRootPart.Position - LocalPlayer.Character.HumanoidRootPart.Position).Magnitude
            if distance < shortestDistance then
                shortestDistance = distance
                closest = player
            end
        end
    end
    return closest
end

local lastFire = tick()
RunService.RenderStepped:Connect(function()
    if AutoAimEnabled or RapidFireEnabled then
        local target = getNearestTarget()
        if target and target.Character then
            local targetPos = target.Character.HumanoidRootPart.Position
            if AutoAimEnabled then
                LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(LocalPlayer.Character.HumanoidRootPart.Position, targetPos)
            end
            if RapidFireEnabled and tick() - lastFire >= ShootSpeedValue/1000 then
                lastFire = tick()
                -- Replace 'ShootRemote' with your game's actual shoot remote
                local shootRemote = ReplicatedStorage:FindFirstChild("ShootRemote")
                if shootRemote then
                    shootRemote:FireServer(targetPos)
                end
            end
        end
    end
end)

-- ===== Settings & Credits =====
SettingsTab:CreateParagraph({Title = "Settings", Content = "Adjust your hub settings here."})
CreditsTab:CreateParagraph({Title = "Credits", Content = "Sweb Hub - Hypershot\nCreated by Sweb\nRayfield UI by Sirius"})

-- ===== Notification =====
Rayfield:Notify({Title = "Sweb Hub", Content = "Full Hypershot Hub Loaded!", Duration = 5, Image = "home"})
