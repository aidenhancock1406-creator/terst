-- Big Paintball 2 Hub using Fluent GUI
-- Author: Sweb

-- Load Fluent and Addons
local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
local SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/SaveManager.lua"))()
local InterfaceManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/InterfaceManager.lua"))()

-- Services
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local Mouse = LocalPlayer:GetMouse()

-- Create Window
local Window = Fluent:CreateWindow({
    Title = "Big Paintball 2 Hub",
    SubTitle = "by Sweb",
    Size = UDim2.fromOffset(600, 500),
    Theme = "Dark"
})

-- Tabs
local Tabs = {
    Aimbot = Window:AddTab({ Title = "Aimbot" }),
    ESP = Window:AddTab({ Title = "ESP" }),
    Misc = Window:AddTab({ Title = "Misc" })
}

-- Variables
local Aimbot = { Enabled=false, HitPart="Head", FOV=100, Smoothness=0.2, Keybind=Enum.KeyCode.MouseButton2 }
local ESPEnabled = false
local ESPObjects = {}
local WalkSpeed = 50
local JumpPower = 50
local AutoShoot = false

-- Functions
local function GetClosestPlayer()
    local closest = nil
    local shortest = math.huge
    for _, plr in pairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
            local part = plr.Character:FindFirstChild(Aimbot.HitPart)
            if part then
                local screenPos, onScreen = Camera:WorldToViewportPoint(part.Position)
                if onScreen then
                    local dist = (Vector2.new(screenPos.X, screenPos.Y) - Vector2.new(Mouse.X, Mouse.Y)).Magnitude
                    if dist < shortest and dist <= Aimbot.FOV then
                        closest = plr
                        shortest = dist
                    end
                end
            end
        end
    end
    return closest
end

local function CreateESP(player)
    if ESPObjects[player] then return end
    if player.Character then
        local highlight = Instance.new("Highlight")
        highlight.Adornee = player.Character
        highlight.FillColor = Color3.fromRGB(255,0,0)
        highlight.FillTransparency = 0.5
        highlight.OutlineColor = Color3.fromRGB(255,255,255)
        highlight.Parent = workspace
        ESPObjects[player] = highlight
    end
end

local function RemoveESP(player)
    if ESPObjects[player] then
        ESPObjects[player]:Destroy()
        ESPObjects[player] = nil
    end
end

-- GUI Elements

-- Aimbot
Tabs.Aimbot:AddToggle("AimbotToggle", {Title="Enable Aimbot", Default=false, Callback=function(val) Aimbot.Enabled=val end})
Tabs.Aimbot:AddDropdown("HitPartDropdown", {Title="Hit Part", Values={"Head","Torso"}, Default=1, Callback=function(val) Aimbot.HitPart=val end})
Tabs.Aimbot:AddSlider("FOVSlider", {Title="FOV", Min=50, Max=300, Default=100, Callback=function(val) Aimbot.FOV=val end})
Tabs.Aimbot:AddSlider("SmoothSlider", {Title="Smoothness", Min=0.05, Max=1, Default=0.2, Callback=function(val) Aimbot.Smoothness=val end})
Tabs.Aimbot:AddKeybind("AimKeybind", {Title="Aim Key", Default=Enum.KeyCode.MouseButton2, Mode="Hold", Callback=function(val) Aimbot.Keybind=val end})

-- ESP
Tabs.ESP:AddToggle("ESPEnabled", {Title="Enable ESP", Default=false, Callback=function(val) ESPEnabled=val end})

-- Misc
Tabs.Misc:AddSlider("SpeedSlider", {Title="WalkSpeed", Min=16, Max=200, Default=50, Callback=function(val) WalkSpeed=val end})
Tabs.Misc:AddSlider("JumpSlider", {Title="JumpPower", Min=50, Max=300, Default=50, Callback=function(val) JumpPower=val end})
Tabs.Misc:AddToggle("AutoShootToggle", {Title="Auto Shoot", Default=false, Callback=function(val) AutoShoot=val end})
Tabs.Misc:AddButton("TeleportTower", {Title="Teleport to Tower", Callback=function()
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(0,50,0)
    end
end})

-- INIT GUI
Window:Init()

-- Main Loop
RunService.RenderStepped:Connect(function()
    -- Aimbot
    if Aimbot.Enabled and UserInputService:IsKeyDown(Aimbot.Keybind) then
        local target = GetClosestPlayer()
        if target and target.Character and target.Character:FindFirstChild(Aimbot.HitPart) then
            local part = target.Character[Aimbot.HitPart]
            Camera.CFrame = Camera.CFrame:Lerp(CFrame.new(Camera.CFrame.Position, part.Position), Aimbot.Smoothness)
        end
    end

    -- ESP
    for _, plr in pairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and ESPEnabled then
            CreateESP(plr)
        else
            RemoveESP(plr)
        end
    end

    -- Misc
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        LocalPlayer.Character.Humanoid.WalkSpeed = WalkSpeed
        LocalPlayer.Character.Humanoid.JumpPower = JumpPower
    end

    if AutoShoot and Mouse.Target then
        mouse1click()
    end
end)
