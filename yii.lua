-- Sweb Hub - Hypershot Full Cheat Hub
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Camera = Workspace.CurrentCamera
local Mouse = LocalPlayer:GetMouse()

-- ===== Variables =====
local AutoAimEnabled = false
local SilentAimEnabled = false
local RapidFireEnabled = false
local ShootSpeedValue = 50
local ESPEnabled = false
local ESPColor = Color3.fromRGB(0,255,0)
local ESPBoxes = {}
local FireKey = Enum.KeyCode.F

-- ===== Window =====
local Window = Rayfield:CreateWindow({
    Name = "Sweb Hub - Hypershot",
    LoadingTitle = "Sweb Hub",
    LoadingSubtitle = "Full Exploit Menu",
    ShowText = "Sweb Hub",
    Theme = "Default",
    ToggleUIKeybind = "K",
    ConfigurationSaving = {Enabled=true, FolderName="SwebHubConfigs", FileName="HypershotHub"},
    KeySystem = true,
    KeySettings = {Title="Sweb Hub Key", Subtitle="Enter Key to Continue", Note="Key: 1", FileName="Key", SaveKey=false, GrabKeyFromSite=false, Key={"1"}}
})

-- ===== Tabs =====
local GameplayTab = Window:CreateTab("Gameplay", 4483362458)
local VisualsTab = Window:CreateTab("Visuals", 4483362458)
local SettingsTab = Window:CreateTab("Settings", 4483362458)
local CreditsTab = Window:CreateTab("Credits", 4483362458)

-- ===== Helper Functions =====
local function GetOnScreenPosition(V3)
    local Position, IsVisible = Camera:WorldToViewportPoint(V3)
    return Vector2.new(Position.X, Position.Y), IsVisible
end

local function GetMousePosition()
    return Vector2.new(Mouse.X, Mouse.Y)
end

local function GetClosestPlayer()
    local Closest, Distance = nil, 10000
    for _, Player in next, Players:GetPlayers() do
        if Player ~= LocalPlayer then
            local Char = Player.Character
            local Head = Char and Char:FindFirstChild("Head")
            local Hum = Char and Char:FindFirstChild("Humanoid")
            if Head and Hum and Hum.Health > 0 then
                local ScreenPos, Vis = GetOnScreenPosition(Head.Position)
                if Vis then
                    local _Distance = (GetMousePosition() - ScreenPos).Magnitude
                    if _Distance < Distance then
                        Closest = Head
                        Distance = _Distance
                    end
                end
            end
        end
    end
    return Closest
end

-- ===== ESP Functions =====
local function createESP(player)
    if player == LocalPlayer then return end
    if ESPBoxes[player] then return end
    local Char = player.Character
    if Char and Char:FindFirstChild("HumanoidRootPart") then
        local box = Instance.new("BoxHandleAdornment")
        box.Adornee = Char.HumanoidRootPart
        box.Color3 = ESPColor
        box.Transparency = 0.3
        box.Size = Vector3.new(2,5,2)
        box.AlwaysOnTop = true
        box.ZIndex = 10
        box.Parent = Workspace
        ESPBoxes[player] = box
    end
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
    local Args = {...}
    if Args[1] == Workspace and Method == "Raycast" then
        if typeof(Args[#Args]) ~= "RaycastParams" then
            return oldNamecall(...)
        end
        if SilentAimEnabled then
            local Target = GetClosestPlayer()
            if Target then
                Args[3] = (Target.Position - Args[2]).Unit * (Target.Position - Args[2]).Magnitude
                return oldNamecall(unpack(Args))
            end
        end
    end
    return oldNamecall(...)
end)

-- ===== Gameplay Tab =====
GameplayTab:CreateToggle({Name="Auto Aim (Silent)", CurrentValue=false, Flag="SilentAim", Callback=function(Value) SilentAimEnabled = Value end})
GameplayTab:CreateToggle({Name="Rapid Fire", CurrentValue=false, Flag="RapidFire", Callback=function(Value) RapidFireEnabled = Value end})
GameplayTab:CreateSlider({Name="Shoot Speed (ms)", Range={10,200}, Increment=5, Suffix="ms", CurrentValue=50, Flag="ShootSpeed", Callback=function(Value) ShootSpeedValue = Value end})
GameplayTab:CreateKeybind({Name="Fire Keybind", CurrentKeybind="F", HoldToInteract=true, Flag="FireKeybind", Callback=function(Keybind) FireKey = Enum.KeyCode[Keybind] end})

-- ===== Rapid Fire Logic =====
local lastFire = tick()
RunService.RenderStepped:Connect(function()
    if RapidFireEnabled and LocalPlayer.Character then
        local Target = GetClosestPlayer()
        if Target and tick() - lastFire >= ShootSpeedValue/1000 then
            lastFire = tick()
            local ShootRemote = ReplicatedStorage:FindFirstChild("ShootRemote")
            if ShootRemote then
                ShootRemote:FireServer(Target.Position)
            end
        end
    end
end)

-- ===== Visuals Tab =====
VisualsTab:CreateToggle({Name="Player ESP", CurrentValue=false, Flag="ESP", Callback=function(Value) ESPEnabled = Value end})
VisualsTab:CreateColorPicker({Name="ESP Color", Color=ESPColor, Flag="ESPColor", Callback=function(Value) ESPColor = Value end})

-- ===== Settings Tab =====
SettingsTab:CreateLabel("Settings and Misc")
SettingsTab:CreateKeybind({Name="Toggle UI", CurrentKeybind="K", HoldToInteract=false, Flag="ToggleUI", Callback=function() end})

-- ===== Credits =====
CreditsTab:CreateParagraph({Title="Credits", Content="Sweb Hub - Hypershot\nCreated by Sweb\nRayfield UI by Sirius"})

-- ===== Notification =====
Rayfield:Notify({Title="Sweb Hub", Content="Full Exploit Hub Loaded!", Duration=5, Image="home"})
