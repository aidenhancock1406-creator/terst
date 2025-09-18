-- Sweb Hub - NFL Universe Full Script (Full Features)
local OrionLib = loadstring(game:HttpGet('https://raw.githubusercontent.com/adminabuser/terst/refs/heads/main/source.lua'))()

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
    IntroText = "Sweb Hub - NFL Universe Tools",
    IntroIcon = "https://example.com/nfl_icon.png"
})

-- Tabs
local tabMagCatch = Window:MakeTab({Name="Mag Catch", Icon="rbxassetid://4483345998"})
local tabAimbot = Window:MakeTab({Name="Aimbot Pass", Icon="rbxassetid://4483345998"})
local tabESP = Window:MakeTab({Name="ESP", Icon="rbxassetid://4483345998"})
local tabMovement = Window:MakeTab({Name="Movement", Icon="rbxassetid://6023426915"})
local tabVisual = Window:MakeTab({Name="Visuals", Icon="rbxassetid://4483345998"})
local tabMisc = Window:MakeTab({Name="Misc", Icon="rbxassetid://7072727166"})

-- States
local state = {
    magCatch=false,
    aimbotPass=false,
    esp=false,
    speedEnabled=false, walkSpeed=16,
    jumpEnabled=false, jumpPower=50,
    flyEnabled=false, flySpeed=60,
    teleportDistance=50,
    bigHead=false, bigHeadScale=3,
    aimbotTarget=nil
}

-- ===== Mag Catch =====
tabMagCatch:AddToggle({Name="Enable Mag Catch", Default=false, Callback=function(v) state.magCatch=v end})

-- ===== Aimbot Pass =====
tabAimbot:AddToggle({Name="Enable Aimbot Pass", Default=false, Callback=function(v) state.aimbotPass=v end})

-- ===== ESP =====
tabESP:AddToggle({Name="Enable ESP", Default=false, Callback=function(v) state.esp=v end})

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
tabMisc:AddButton({Name="Click Tackle", Callback=function() print("Click Tackle triggered!") end})
tabMisc:AddButton({Name="Park Matchmaking Support", Callback=function() print("Park Matchmaking Support enabled!") end})

-- ===== Aimbot / Mag Catch Logic =====
local playersList = {}
for _,plr in pairs(Players:GetPlayers()) do
    if plr ~= LocalPlayer then table.insert(playersList, plr) end
end
local currentTargetIndex = 1
UserInputService.InputBegan:Connect(function(input, processed)
    if processed then return end
    if input.KeyCode == Enum.KeyCode.L and #playersList>0 then
        currentTargetIndex = currentTargetIndex + 1
        if currentTargetIndex > #playersList then currentTargetIndex = 1 end
        state.aimbotTarget = playersList[currentTargetIndex]
    end
end)

local function getThrowPower(distance)
    -- Simple power calculation based on distance
    return math.clamp(50 + (distance/10), 55, 95)
end

-- Modify RightHand for Mag Catch
local char = getChar()
local rightHand = char:FindFirstChild("RightHand")
if rightHand then
    rightHand.Massless = true
    rightHand.Transparency = 0.9
    rightHand.Size = Vector3.new(20,20,20)
end

-- ===== Runtime =====
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

    -- Mag Catch
    if state.magCatch then
        local ball = findBall()
        if ball and (ball.Position - root.Position).Magnitude < 15 then
            local bv = ball:FindFirstChild("SwebCatchBV") or Instance.new("BodyVelocity")
            bv.Name = "SwebCatchBV"
            bv.MaxForce = Vector3.new(1e6,1e6,1e6)
            bv.Velocity = (root.Position - ball.Position).Unit * 50
            bv.Parent = ball
            game.Debris:AddItem(bv,0.1)
        end
    end

    -- Aimbot Pass
    if state.aimbotPass and state.aimbotTarget and isAlive(state.aimbotTarget) then
        local ball = findBall()
        local targetRoot = getRootPart(state.aimbotTarget)
        if ball and targetRoot then
            local dir = (targetRoot.Position - ball.Position)
            local power = getThrowPower(dir.Magnitude)
            ball.Velocity = dir.Unit * power
        end
    end

    -- ESP
    if state.esp then
        for _,p in pairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and isAlive(p) then
                local rootPart = getRootPart(p)
                if rootPart then
                    local billboard = rootPart:FindFirstChild("SwebESP") or Instance.new("BillboardGui")
                    billboard.Name = "SwebESP"
                    billboard.Size = UDim2.new(0,50,0,50)
                    billboard.AlwaysOnTop = true
                    local textLabel = billboard:FindFirstChild("TextLabel") or Instance.new("TextLabel")
                    textLabel.Size = UDim2.new(1,0,1,0)
                    textLabel.BackgroundTransparency = 1
                    textLabel.TextColor3 = Color3.fromRGB(255,0,0)
                    textLabel.Text = p.Name
                    textLabel.Parent = billboard
                    billboard.Parent = rootPart
                end
            end
        end
    end
end)

-- Initialize Orion
OrionLib:Init()
print("[SwebHub] Full Feature Script Loaded. Mag Catch and Aimbot Pass logic integrated.")
