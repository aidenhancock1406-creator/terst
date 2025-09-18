-- Sweb Hub - NFL Universe Full Script (Patched Version with Tabs)
local OrionLib = loadstring(game:HttpGet('https://raw.githubusercontent.com/aidenhancock1406-creator/terst/refs/heads/main/source.lua'))()

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

-- Utilities
local function getChar(plr) plr = plr or LocalPlayer return plr.Character or plr.CharacterAdded:Wait() end
local function getHumanoid(plr) local c = getChar(plr) return c and c:FindFirstChildOfClass("Humanoid") end
local function getRootPart(plr) local c = getChar(plr) if not c then return nil end return c:FindFirstChild("HumanoidRootPart") or c:FindFirstChild("Torso") or c:FindFirstChild("UpperTorso") end
local function isAlive(plr) local hum = getHumanoid(plr) return hum and hum.Health > 0 end
local function findBall()
    local ball = Workspace:FindFirstChild("Football") or Workspace:FindFirstChild("Ball")
    if ball then return ball end
    for _,obj in pairs(Workspace:GetDescendants()) do
        if obj:IsA("BasePart") and string.match(string.lower(obj.Name), "ball") then return obj end
    end
end

-- Window & Tabs
local Window = OrionLib:MakeWindow({
    Name = "Sweb Hub - NFL Universe",
    HidePremium = false,
    SaveConfig = true,
    ConfigFolder = "SwebHubConfig",
    IntroEnabled = true,
    IntroText = "Sweb Hub - NFL Universe Tools (Patched)",
    IntroIcon = "https://example.com/nfl_icon.png"
})

-- Tabs
local tabMagCatch = Window:MakeTab({Name="Mag Catch (patched)", Icon="rbxassetid://4483345998"})
local tabAimbot = Window:MakeTab({Name="Aimbot Pass (patched)", Icon="rbxassetid://4483345998"})
local tabESP = Window:MakeTab({Name="ESP", Icon="rbxassetid://4483345998"})
local tabMovement = Window:MakeTab({Name="Movement", Icon="rbxassetid://6023426915"})
local tabVisual = Window:MakeTab({Name="Visuals", Icon="rbxassetid://4483345998"})
local tabMisc = Window:MakeTab({Name="Misc", Icon="rbxassetid://7072727166"})

-- States
local state = {
    esp=false,
    speedEnabled=false, walkSpeed=16,
    jumpEnabled=false, jumpPower=50,
    flyEnabled=false, flySpeed=60,
    teleportDistance=50,
    bigHead=false, bigHeadScale=3
}

-- ===== ESP =====
tabESP:AddToggle({Name="Enable Skeleton ESP", Default=false, Callback=function(v) state.esp=v end})

-- ===== Movement =====
tabMovement:AddToggle({Name="Enable WalkSpeed", Default=false, Callback=function(v) state.speedEnabled=v end})
tabMovement:AddSlider({Name="WalkSpeed", Min=16, Max=200, Default=16, Increment=1, Callback=function(v) state.walkSpeed=v end})
tabMovement:AddToggle({Name="Enable JumpPower", Default=false, Callback=function(v) state.jumpEnabled=v end})
tabMovement:AddSlider({Name="JumpPower", Min=50, Max=200, Default=50, Increment=1, Callback=function(v) state.jumpPower=v end})
tabMovement:AddToggle({Name="Enable Fly", Default=false, Callback=function(v) state.flyEnabled=v end})
tabMovement:AddSlider({Name="Fly Speed", Min=10, Max=200, Default=60, Increment=5, Callback=function(v) state.flySpeed=v end})
tabMovement:AddButton({Name="Teleport Forward", Callback=function()
    local root = getRootPart()
    if root then root.CFrame = root.CFrame + (root.CFrame.LookVector * state.teleportDistance) end
end})

-- ===== Visuals =====
tabVisual:AddToggle({Name="Big Head", Default=false, Callback=function(v)
    state.bigHead=v
    for _,p in pairs(Players:GetPlayers()) do
        local head = p.Character and p.Character:FindFirstChild("Head")
        if head then
            head.Size = v and Vector3.new(state.bigHeadScale,state.bigHeadScale,state.bigHeadScale) or Vector3.new(2,1,1)
        end
    end
end})

-- ===== Misc =====
tabMisc:AddButton({Name="Click Tackle (Hitbox Expander)", Callback=function()
    for _,p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and isAlive(p) then
            local char = getChar(p)
            for _,part in pairs(char:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.Size = part.Size * 2
                end
            end
        end
    end
end})

-- ===== Runtime =====
local SkeletonLines = {}
RunService.RenderStepped:Connect(function()
    local char = getChar()
    if not char or not char:FindFirstChild("HumanoidRootPart") then return end
    local root = char.HumanoidRootPart
    local hum = getHumanoid()

    -- WalkSpeed & JumpPower
    if hum then
        if state.speedEnabled then hum.WalkSpeed = state.walkSpeed else hum.WalkSpeed = 16 end
        if state.jumpEnabled then hum.JumpPower = state.jumpPower else hum.JumpPower = 50 end
    end

    -- Fly
    if state.flyEnabled and root then
        root.Anchored = false
        local flyDir = Vector3.new(0,0,0)
        if UserInputService:IsKeyDown(Enum.KeyCode.W) then flyDir = flyDir + (Camera.CFrame.LookVector) end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then flyDir = flyDir - (Camera.CFrame.LookVector) end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then flyDir = flyDir - (Camera.CFrame.RightVector) end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then flyDir = flyDir + (Camera.CFrame.RightVector) end
        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then flyDir = flyDir + Vector3.new(0,1,0) end
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then flyDir = flyDir - Vector3.new(0,1,0) end
        root.Velocity = flyDir.Unit * state.flySpeed
    end

    -- Skeleton ESP
    for _,line in pairs(SkeletonLines) do
        line:Remove()
    end
    SkeletonLines = {}

    if state.esp then
        for _,p in pairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and isAlive(p) then
                local c = getChar(p)
                local parts = {"Head","UpperTorso","LowerTorso","LeftUpperArm","LeftLowerArm","RightUpperArm","RightLowerArm","LeftUpperLeg","LeftLowerLeg","RightUpperLeg","RightLowerLeg"}
                local connections = {}
                local function drawLine(part0, part1)
                    if part0 and part1 then
                        local line = Drawing.new("Line")
                        line.Color = Color3.fromRGB(255,0,0)
                        line.From = Camera:WorldToViewportPoint(part0.Position)
                        line.To = Camera:WorldToViewportPoint(part1.Position)
                        line.Thickness = 2
                        line.Transparency = 1
                        table.insert(SkeletonLines,line)
                    end
                end
                -- Head to UpperTorso
                drawLine(c:FindFirstChild("Head"), c:FindFirstChild("UpperTorso"))
                -- UpperTorso connections
                drawLine(c:FindFirstChild("UpperTorso"), c:FindFirstChild("LeftUpperArm"))
                drawLine(c:FindFirstChild("UpperTorso"), c:FindFirstChild("RightUpperArm"))
                drawLine(c:FindFirstChild("UpperTorso"), c:FindFirstChild("LowerTorso"))
                -- LowerTorso connections
                drawLine(c:FindFirstChild("LowerTorso"), c:FindFirstChild("LeftUpperLeg"))
                drawLine(c:FindFirstChild("LowerTorso"), c:FindFirstChild("RightUpperLeg"))
                -- Arms and legs segments
                drawLine(c:FindFirstChild("LeftUpperArm"), c:FindFirstChild("LeftLowerArm"))
                drawLine(c:FindFirstChild("RightUpperArm"), c:FindFirstChild("RightLowerArm"))
                drawLine(c:FindFirstChild("LeftUpperLeg"), c:FindFirstChild("LeftLowerLeg"))
                drawLine(c:FindFirstChild("RightUpperLeg"), c:FindFirstChild("RightLowerLeg"))
            end
        end
    end
end)

-- Initialize Orion
OrionLib:Init()
print("[SwebHub] Patched version loaded. Mag Catch & Aimbot tabs present but patched. Skeleton ESP, Hitbox Expander, Movement ready.")
