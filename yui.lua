-- Sweb Hub - Hypershot (Full Silent Aim Version)
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Camera = Workspace.CurrentCamera
local Mouse = LocalPlayer:GetMouse()
local WorldToScreenPoint = Camera.WorldToScreenPoint

-- ===== Window =====
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

-- ===== Tabs =====
local GameplayTab = Window:CreateTab("Gameplay", 4483362458)
local VisualsTab = Window:CreateTab("Visuals", 4483362458)
local SettingsTab = Window:CreateTab("Settings", 4483362458)
local CreditsTab = Window:CreateTab("Credits", 4483362458)

-- ===== Variables =====
local AutoAimEnabled = false
local RapidFireEnabled = false
local ShootSpeedValue = 50
local FireKey = Enum.KeyCode.F
local ESPEnabled = false
local ESPColor = Color3.fromRGB(0,255,0)
local ESPBoxes = {}

-- ===== Functions =====
local function GetOnScreenPosition(V3)
    local Position, IsVisible = WorldToScreenPoint(Camera, V3)
    return Vector2.new(Position.X, Position.Y), IsVisible
end

local function GetDirection(Origin, Position)
    return (Position - Origin).Unit * (Origin - Position).Magnitude
end

local function GetMousePosition()
    return Vector2.new(Mouse.X, Mouse.Y)
end

local function GetClosestPlayer()
    local Closest, Distance = nil, 10000
    for _, Player in next, Players:GetPlayers() do
        if Player ~= LocalPlayer then
            local Character = Player.Character
            local Head = Character and Character:FindFirstChild("Head")
            local Humanoid = Character and Character:FindFirstChild("Humanoid")
            if Head and (Humanoid and Humanoid.Health > 0) then
                local ScreenPos, IsVisible = GetOnScreenPosition(Head.Position)
                if IsVisible then
                    local _Distance = (GetMousePosition() - ScreenPos).Magnitude
                    if _Distance <= Distance then
                        Closest = Head
                        Distance = _Distance
                    end
                end
            end
        end
    end
    return Closest, Distance
end

-- ===== ESP Functions =====
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

-- ===== Silent Aim / Raycast Hook =====
local oldNamecall
oldNamecall = hookmetamethod(game, "__namecall", function(...)
    local Method = getnamecallmethod()
    local Arguments = {...}
    if Arguments[1] == Workspace and Method == "Raycast" then
        if typeof(Arguments[#Arguments]) ~= "RaycastParams" then
            return oldNamecall(...)
        end
        if AutoAimEnabled then
            local HitPart = GetClosestPlayer()
            if HitPart then
                Arguments[3] = GetDirection(Arguments[2], HitPart.Position)
                return oldNamecall(unpack(Arguments))
            end
        end
    end
    return oldNamecall(...)
end)

-- ===== Gameplay Tab =====
GameplayTab:CreateToggle({Name = "Auto Aim", CurrentValue = false, Flag = "AutoAim", Callback = function(Value) AutoAimEnabled = Value end})
GameplayTab:CreateToggle({Name = "Rapid Fire", CurrentValue = false, Flag = "RapidFire", Callback = function(Value) RapidFireEnabled = Value end})
GameplayTab:CreateSlider({Name = "Shoot Speed (ms)", Range = {10,200}, Increment = 5, Suffix = "ms", CurrentValue = 50, Flag = "ShootSpeed", Callback = function(Value) ShootSpeedValue = Value end})
GameplayTab:CreateKeybind({Name = "Fire Keybind", CurrentKeybind = "F", HoldToInteract = true, Flag = "FireKeybind", Callback = function(Keybind) FireKey = Enum.KeyCode[Keybind] end})

-- ===== Rapid Fire Logic =====
local lastFire = tick()
RunService.RenderStepped:Connect(function()
    if RapidFireEnabled and LocalPlayer.Character then
        local target = GetClosestPlayer()
        if target and tick() - lastFire >= ShootSpeedValue / 1000 then
            lastFire = tick()
            local shootRemote = ReplicatedStorage:FindFirstChild("ShootRemote")
            if shootRemote then
                shootRemote:FireServer(target.Position)
            end
        end
    end
end)

-- ===== Visuals Tab =====
VisualsTab:CreateToggle({Name = "Player ESP", CurrentValue = false, Flag = "ESP", Callback = function(Value) ESPEnabled = Value end})
VisualsTab:CreateColorPicker({Name = "ESP Color", Color = ESPColor, Flag = "ESPColor", Callback = function(Value) ESPColor = Value end})

-- ===== Settings & Credits =====
SettingsTab:CreateParagraph({Title = "Settings", Content = "Adjust your hub settings here."})
CreditsTab:CreateParagraph({Title = "Credits", Content = "Sweb Hub - Hypershot\nCreated by Sweb\nRayfield UI by Sirius"})

-- ===== Notification =====
Rayfield:Notify({Title = "Sweb Hub", Content = "Hypershot Hub Loaded with Silent Aim!", Duration = 5, Image = "home"})
