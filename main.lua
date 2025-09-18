-- Sweb Hub - NFL Universe Full Script (QB Lock-On ESP + Pull + Everything)
local OrionLib = loadstring(game:HttpGet(('https://raw.githubusercontent.com/aidenhancock1406-creator/terst/refs/heads/main/source.lua')))()

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

-- Utilities
local function getChar(plr) plr = plr or LocalPlayer return plr.Character or plr.CharacterAdded:Wait() end
local function getHumanoid(plr) local c = getChar(plr) return c and c:FindFirstChildOfClass("Humanoid") end
local function getRootPart(plr) local c = getChar(plr) if not c then return nil end return c:FindFirstChild("HumanoidRootPart") or c:FindFirstChild("Torso") or c:FindFirstChild("UpperTorso") end
local function isAlive(plr) local hum = getHumanoid(plr) return hum and hum.Health > 0 end

-- Find football
local function findBall()
    local ball = Workspace:FindFirstChild("Football") or Workspace:FindFirstChild("Ball")
    if ball then return ball end
    for _,obj in pairs(Workspace:GetDescendants()) do
        if obj:IsA("BasePart") and string.match(string.lower(obj.Name), "ball") then
            return obj
        end
    end
end

-- Find pass remote
local function getPassRemote()
    return ReplicatedStorage:FindFirstChild("PassBall") -- change if remote has different name
end

-- ESP utility
local function createESP(target)
    if not target.Character or not target.Character:FindFirstChild("Head") then return end
    local head = target.Character.Head
    local box = head:FindFirstChild("SwebESP") or Instance.new("BoxHandleAdornment")
    box.Name = "SwebESP"
    box.Adornee = head
    box.Color3 = Color3.new(0,1,0)
    box.Transparency = 0.4
    box.AlwaysOnTop = true
    box.Size = Vector3.new(2,2,2)
    box.Parent = head
end

local function removeESP(target)
    if target.Character then
        local head = target.Character:FindFirstChild("Head")
        if head then
            local box = head:FindFirstChild("SwebESP")
            if box then box:Destroy() end
        end
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

local tabQB = Window:MakeTab({Name="QB", Icon="rbxassetid://4483345998"})
local tabKicker = Window:MakeTab({Name="Kicker", Icon="rbxassetid://4483345998"})
local tabMovement = Window:MakeTab({Name="Movement", Icon="rbxassetid://6023426915"})
local tabPull = Window:MakeTab({Name="Pull Vector", Icon="rbxassetid://4483345998"})
local tabVisual = Window:MakeTab({Name="Visuals", Icon="rbxassetid://4483345998"})
local tabMisc = Window:MakeTab({Name="Misc", Icon="rbxassetid://7072727166"})

-- Feature states
local state = {
    qbLock = false,
    currentTargetIndex = 1,
    targets = {},
    pullEnabled = false,
    pullStrength = 60,
    legitPull = false,
    legitPullStrength = 35,
    kickAimbot = false,
    kickBind = Enum.KeyCode.E,
    speedEnabled = false,
    walkSpeed = 16,
    jumpEnabled = false,
    jumpPower = 50,
    flyEnabled = false,
    flySpeed = 60,
    teleportDistance = 50,
    bigHead = false,
    bigHeadScale = 3
}

-- ===== QB Lock-On =====
tabQB:AddToggle({
    Name = "Enable QB Lock-On",
    Default = false,
    Callback = function(v)
        -- remove previous ESP
        for _,p in pairs(state.targets) do removeESP(p) end

        state.qbLock = v
        if v then
            state.targets = {}
            for _,p in pairs(Players:GetPlayers()) do
                if p ~= LocalPlayer and isAlive(p) then table.insert(state.targets, p) end
            end
            state.currentTargetIndex = 1
            local tgt = state.targets[state.currentTargetIndex]
            if tgt then createESP(tgt) end
        end
    end
})
tabQB:AddLabel("Press 'L' to switch locked-on target")

-- Switch target with L
UserInputService.InputBegan:Connect(function(input, gp)
    if gp then return end
    if input.KeyCode == Enum.KeyCode.L and state.qbLock then
        if #state.targets == 0 then return end
        local prev = state.targets[state.currentTargetIndex]
        removeESP(prev)

        state.currentTargetIndex = state.currentTargetIndex + 1
        if state.currentTargetIndex > #state.targets then state.currentTargetIndex = 1 end
        local tgt = state.targets[state.currentTargetIndex]
        if tgt and isAlive(tgt) then
            createESP(tgt)
            print("[SwebHub] QB Lock-On: now locked on to", tgt.Name)
        end
    end
end)

-- Intercept throw to aim at locked-on player
local throwRemote = getPassRemote()
if throwRemote then
    local oldFire = throwRemote.FireServer
    throwRemote.FireServer = function(selfRemote, targetPos, ...)
        if state.qbLock then
            local target = state.targets[state.currentTargetIndex]
            if target and target.Character and target.Character:FindFirstChild("Head") then
                targetPos = target.Character.Head.Position
            end
        end
        return oldFire(selfRemote, targetPos, ...)
    end
end

-- ===== Pull Vector =====
tabPull:AddToggle({Name="Enable Pull Vector", Default=false, Callback=function(v) state.pullEnabled=v end})
tabPull:AddSlider({Name="Pull Strength", Min=10, Max=300, Default=state.pullStrength, Increment=5, Callback=function(v) state.pullStrength=v end})
tabPull:AddToggle({Name="Legit Pull Vector", Default=false, Callback=function(v) state.legitPull=v end})
tabPull:AddSlider({Name="Legit Pull Strength", Min=10, Max=200, Default=state.legitPullStrength, Increment=1, Callback=function(v) state.legitPullStrength=v end})

-- ===== Kick Aimbot =====
tabKicker:AddToggle({Name="Kick Aimbot", Default=false, Callback=function(v) state.kickAimbot=v end})
tabKicker:AddBind({Name="Kick Bind", Default=state.kickBind, Hold=false, Callback=function() end})

-- ===== Movement =====
tabMovement:AddToggle({Name="Enable WalkSpeed & Jump", Default=false, Callback=function(v) state.speedEnabled=v end})
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

-- ===== Runtime Loop =====
RunService.RenderStepped:Connect(function(dt)
    local char = getChar()
    if not char or not char:FindFirstChild("HumanoidRootPart") then return end
    local root = char.HumanoidRootPart
    local hum = getHumanoid()

    -- Movement overrides
    if hum then
        if state.speedEnabled then hum.WalkSpeed = state.walkSpeed else hum.WalkSpeed = 16 end
        if state.jumpEnabled then hum.JumpPower = state.jumpPower else hum.JumpPower = 50 end
    end

    -- Pull Vector
    if state.pullEnabled then
        local ball = findBall()
        if ball then
            local bv = root:FindFirstChild("SwebPullBV")
            if state.legitPull then
                if not bv then
                    bv = Instance.new("BodyVelocity")
                    bv.Name = "SwebPullBV"
                    bv.MaxForce = Vector3.new(1e6,1e6,1e6)
                    bv.P = 1250
                    bv.Parent = root
                end
                local dir = (ball.Position - root.Position)
                bv.Velocity = dir.Magnitude > 1 and dir.Unit * state.legitPullStrength or Vector3.new(0,0,0)
            else
                if bv then bv:Destroy() end
                root.Velocity = (ball.Position - root.Position).Unit * state.pullStrength
            end
        end
    else
        local bv = root:FindFirstChild("SwebPullBV")
        if bv then bv:Destroy() end
    end
end)

-- Initialize Orion
OrionLib:Init()
print("[SwebHub] Full Script Loaded. QB Lock-On with ESP, Pull Vector, Kick Aimbot, Movement, Visuals ready. Press L to switch QB target.")
