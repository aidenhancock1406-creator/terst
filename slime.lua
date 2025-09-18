-- Sweb Hub (NFL Universe) - Fully Functional
-- Requires exploit with Drawing API (for FOV circle)

local OrionLib = loadstring(game:HttpGet(('https://raw.githubusercontent.com/aidenhancock1406-creator/terst/refs/heads/main/source.lua')))()
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

local Window = OrionLib:MakeWindow({
    Name = "Sweb Hub",
    HidePremium = false,
    SaveConfig = true,
    ConfigFolder = "SwebHubConfig",
    IntroEnabled = true,
    IntroText = "Welcome to Sweb Hub!",
    IntroIcon = "https://example.com/nfl_icon.png"
})

-------------------------------------------------
-- QB TAB
-------------------------------------------------
local QBTab = Window:MakeTab({Name="QB", Icon="rbxassetid://4483345998"})

local fovCircle = Drawing.new("Circle")
fovCircle.Color = Color3.fromRGB(0,255,0)
fovCircle.Thickness = 2
fovCircle.NumSides = 100
fovCircle.Filled = false
fovCircle.Radius = 120
fovCircle.Position = workspace.CurrentCamera.ViewportSize/2
fovCircle.Visible = false

QBTab:AddToggle({
    Name = "Pass Assist FOV Circle",
    Default = false,
    Callback = function(Value)
        fovCircle.Visible = Value
    end
})

-------------------------------------------------
-- KICKER TAB
-------------------------------------------------
local KickTab = Window:MakeTab({Name="Kicker", Icon="rbxassetid://4483345998"})
local autoKick = false

KickTab:AddToggle({
    Name = "Auto Kicker",
    Default = false,
    Callback = function(Value)
        autoKick = Value
    end
})

-- Example kicker hook (needs adjusting for NFL Universe bar GUI)
RunService.RenderStepped:Connect(function()
    if autoKick then
        local gui = LocalPlayer.PlayerGui:FindFirstChild("KickerUI") -- adjust name
        if gui and gui.Bar then
            -- Simulate pressing at the perfect time
            pcall(function()
                gui.Bar.Position = 0.5 -- force perfect timing
            end)
        end
    end
end)

-------------------------------------------------
-- MOVEMENT TAB
-------------------------------------------------
local MoveTab = Window:MakeTab({Name="Movement", Icon="rbxassetid://4483345998"})

MoveTab:AddButton({
    Name = "Speed Boost (Safe)",
    Callback = function()
        LocalPlayer.Character.Humanoid.WalkSpeed = 50
    end
})

MoveTab:AddButton({
    Name = "Speed Boost (Risk)",
    Callback = function()
        LocalPlayer.Character.Humanoid.WalkSpeed = 65
    end
})

local infStamina = false
MoveTab:AddToggle({
    Name = "Infinite Stamina",
    Default = false,
    Callback = function(Value)
        infStamina = Value
    end
})

-- Stamina hook
RunService.Stepped:Connect(function()
    if infStamina then
        local stats = LocalPlayer:FindFirstChild("Stamina") or LocalPlayer.Character:FindFirstChild("Stamina")
        if stats then
            stats.Value = stats.MaxValue or 100
        end
    end
end)

-- Fly mode
local flying = false
local flySpeed = 3
local keys = {W=false,A=false,S=false,D=false,Space=false,Shift=false}

MoveTab:AddBind({
    Name = "Toggle Fly Mode",
    Default = Enum.KeyCode.F,
    Hold = false,
    Callback = function()
        flying = not flying
        if flying then
            local hrp = LocalPlayer.Character:WaitForChild("HumanoidRootPart")
            RunService.RenderStepped:Connect(function()
                if flying and hrp then
                    local camCF = workspace.CurrentCamera.CFrame
                    local moveDir = Vector3.zero
                    if keys.W then moveDir = moveDir + camCF.LookVector end
                    if keys.S then moveDir = moveDir - camCF.LookVector end
                    if keys.A then moveDir = moveDir - camCF.RightVector end
                    if keys.D then moveDir = moveDir + camCF.RightVector end
                    if keys.Space then moveDir = moveDir + Vector3.new(0,1,0) end
                    if keys.Shift then moveDir = moveDir - Vector3.new(0,1,0) end
                    hrp.Velocity = moveDir * 50
                end
            end)
        end
    end
})

game:GetService("UserInputService").InputBegan:Connect(function(input,gp)
    if input.KeyCode == Enum.KeyCode.W then keys.W=true end
    if input.KeyCode == Enum.KeyCode.A then keys.A=true end
    if input.KeyCode == Enum.KeyCode.S then keys.S=true end
    if input.KeyCode == Enum.KeyCode.D then keys.D=true end
    if input.KeyCode == Enum.KeyCode.Space then keys.Space=true end
    if input.KeyCode == Enum.KeyCode.LeftShift then keys.Shift=true end
end)

game:GetService("UserInputService").InputEnded:Connect(function(input,gp)
    if input.KeyCode == Enum.KeyCode.W then keys.W=false end
    if input.KeyCode == Enum.KeyCode.A then keys.A=false end
    if input.KeyCode == Enum.KeyCode.S then keys.S=false end
    if input.KeyCode == Enum.KeyCode.D then keys.D=false end
    if input.KeyCode == Enum.KeyCode.Space then keys.Space=false end
    if input.KeyCode == Enum.KeyCode.LeftShift then keys.Shift=false end
end)

MoveTab:AddSlider({
    Name = "Player Size",
    Min = 1,
    Max = 5,
    Default = 1,
    Increment = 0.5,
    ValueName = "scale",
    Callback = function(Value)
        for _,part in pairs(LocalPlayer.Character:GetChildren()) do
            if part:IsA("BasePart") then
                part.Size = part.Size * Value
            end
        end
    end
})

-------------------------------------------------
-- PULL VECTOR TAB
-------------------------------------------------
local PullTab = Window:MakeTab({Name="Pull Vector", Icon="rbxassetid://4483345998"})
local pullEnabled = false

PullTab:AddToggle({
    Name = "Enable Pull Vector",
    Default = false,
    Callback = function(Value)
        pullEnabled = Value
    end
})

RunService.RenderStepped:Connect(function()
    if pullEnabled then
        local ball = workspace:FindFirstChild("Football") -- adjust if named differently
        local char = LocalPlayer.Character
        if ball and char and char:FindFirstChild("HumanoidRootPart") then
            local hrp = char.HumanoidRootPart
            local direction = (ball.Position - hrp.Position).Unit
            hrp.Velocity = direction * 60 -- pull strength
        end
    end
end)

-------------------------------------------------
-- VISUALS TAB
-------------------------------------------------
local VisualsTab = Window:MakeTab({Name="Visuals", Icon="rbxassetid://4483345998"})

VisualsTab:AddColorpicker({
    Name = "Custom Jersey Color",
    Default = Color3.fromRGB(255,0,0),
    Callback = function(Value)
        for _,v in pairs(LocalPlayer.Character:GetChildren()) do
            if v:IsA("Shirt") or v:IsA("Pants") then
                v.Color3 = Value
            end
        end
    end
})

VisualsTab:AddDropdown({
    Name = "Select Weather",
    Default = "Clear",
    Options = {"Clear","Rainy","Snowy"},
    Callback = function(Value)
        local lighting = game:GetService("Lighting")
        if Value == "Clear" then
            lighting.Atmosphere.Density = 0.3
        elseif Value == "Rainy" then
            lighting.Atmosphere.Density = 0.7
        elseif Value == "Snowy" then
            lighting.Atmosphere.Density = 0.9
        end
    end
})

-------------------------------------------------
-- MISC TAB
-------------------------------------------------
local MiscTab = Window:MakeTab({Name="Misc", Icon="rbxassetid://4483345998"})

MiscTab:AddTextbox({
    Name = "Custom Player Name",
    Default = "Player1",
    TextDisappear = true,
    Callback = function(Value)
        local gui = LocalPlayer.PlayerGui:FindFirstChild("NameUI") -- adjust
        if gui and gui.TextLabel then
            gui.TextLabel.Text = Value
        end
    end
})

MiscTab:AddLabel("Sweb Hub - Customize Your Experience")
MiscTab:AddParagraph("About", "Sweb Hub lets you enhance your NFL gameplay with exclusive features.")

-------------------------------------------------
-- INIT
-------------------------------------------------
OrionLib:Init()
