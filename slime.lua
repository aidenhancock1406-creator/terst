-- Sweb Hub - NFL Universe (All requested features)
-- Single-file OrionLib script
-- Drop into executor that supports loadstring, Drawing API, BodyGyro/BodyVelocity, etc.

local OrionLib = loadstring(game:HttpGet(('https://raw.githubusercontent.com/aidenhancock1406-creator/terst/refs/heads/main/source.lua')))()

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera
local Mouse = LocalPlayer:GetMouse()

-- ====== Utilities ======
local function getChar(plr)
    plr = plr or LocalPlayer
    return plr.Character or plr.CharacterAdded:Wait()
end
local function getHumanoid(plr)
    local c = getChar(plr)
    return c and c:FindFirstChildOfClass("Humanoid")
end
local function getRootPart(plr)
    local c = getChar(plr)
    if not c then return nil end
    return c:FindFirstChild("HumanoidRootPart") or c:FindFirstChild("Torso") or c:FindFirstChild("UpperTorso")
end
local function isAlive(plr)
    local hum = getHumanoid(plr)
    return hum and hum.Health > 0
end
local function findBall()
    -- Try common places for the football object in NFL Universe
    -- ADJUST IF NEEDED: name "Football" or a part in workspace named "Ball"
    local ball = Workspace:FindFirstChild("Football") or Workspace:FindFirstChild("Ball") or Workspace:FindFirstChild("football")
    if not ball then
        -- try searching descendants
        for _,obj in pairs(Workspace:GetDescendants()) do
            if obj:IsA("BasePart") and string.match(string.lower(obj.Name), "ball") then
                return obj
            end
        end
    end
    return ball
end
local function findLikelyReceivers()
    local list = {}
    for _,p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and isAlive(p) and p.Character then
            local head = p.Character:FindFirstChild("Head")
            local root = getRootPart(p)
            if head and root then
                table.insert(list, p)
            end
        end
    end
    return list
end

-- Clean up holder
local CLEANUP = {}

local function addCleanup(fn)
    table.insert(CLEANUP, fn)
end
local function doCleanup()
    for _,fn in ipairs(CLEANUP) do
        pcall(fn)
    end
    CLEANUP = {}
end

-- ====== Window & Tabs ======
local Window = OrionLib:MakeWindow({
    Name = "Sweb Hub - NFL Tools",
    HidePremium = false,
    SaveConfig = true,
    ConfigFolder = "SwebHubConfig",
    IntroEnabled = true,
    IntroText = "Sweb Hub - NFL Universe Tools",
    IntroIcon = "https://example.com/nfl_icon.png"
})

-- Tabs
local tabQB = Window:MakeTab({Name="QB", Icon="rbxassetid://4483345998"})
local tabKicker = Window:MakeTab({Name="Kicker", Icon="rbxassetid://4483345998"})
local tabMovement = Window:MakeTab({Name="Movement", Icon="rbxassetid://6023426915"})
local tabPull = Window:MakeTab({Name="Pull Vector", Icon="rbxassetid://4483345998"})
local tabVisual = Window:MakeTab({Name="Visuals", Icon="rbxassetid://4483345998"})
local tabMisc = Window:MakeTab({Name="Misc", Icon="rbxassetid://7072727166"})

-- ====== DRAWING HELPERS ======
local DrawingAvailable = (typeof(drawing) == "table" or type(Drawing) == "table" or type(drawing) == "function")
local function NewCircle()
    if DrawingAvailable then
        local circ = Drawing.new and Drawing.new("Circle") or Drawing.Circle and Drawing.Circle.new and Drawing.Circle.new()
        return circ
    end
    return nil
end
local function NewLine()
    if DrawingAvailable then
        local line = Drawing.new and Drawing.new("Line") or Drawing.Line and Drawing.Line.new and Drawing.Line.new()
        return line
    end
    return nil
end

-- ====== Feature States ======
local state = {
    -- Pull
    pullEnabled = false,
    pullStrength = 60,
    legitPull = false,
    legitPullStrength = 35,
    -- Movement
    speedEnabled = false,
    walkSpeed = 16,
    jumpEnabled = false,
    jumpPower = 50,
    flyEnabled = false,
    flySpeed = 60,
    -- Teleport
    teleportDistance = 50,
    -- Kick Aimbot
    kickAimbot = false,
    kickBind = Enum.KeyCode.E,
    kickAimbotFOV = 180,
    kickAimbotSmooth = 0.35,
    -- Landing Indicator
    landingIndicator = false,
    landingPredictionSamples = 60,
    -- Park Matchmaking
    parkSupport = false,
    -- Click tackle
    clickTackle = false,
    tackleDashSpeed = 120,
    tackleRange = 10,
    -- Big head
    bigHead = false,
    bigHeadScale = 3,
}

-- ====== QB: Pass Assist FOV (visual only) and Kick Aimbot ======
local fovCircle = NewCircle()
if fovCircle then
    fovCircle.Color = Color3.fromRGB(0,255,0)
    fovCircle.Thickness = 2
    fovCircle.Transparency = 0.7
    fovCircle.Filled = false
    fovCircle.Radius = 120
    fovCircle.Position = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)
    fovCircle.Visible = false
end
tabQB:AddToggle({
    Name = "Pass Assist FOV (visual)",
    Default = false,
    Callback = function(v)
        if fovCircle then
            fovCircle.Visible = v
        end
    end
})

-- Kick Aimbot UI
tabKicker:AddToggle({
    Name = "Kick Aimbot (aim & attempt kick)",
    Default = false,
    Callback = function(v) state.kickAimbot = v end
})
tabKicker:AddSlider({
    Name = "Kick Aimbot FOV (px)",
    Min = 50, Max = 800, Default = state.kickAimbotFOV, Increment = 5,
    Callback = function(v) state.kickAimbotFOV = v end
})
tabKicker:AddSlider({
    Name = "Kick Aim Smooth",
    Min = 0, Max = 1, Default = state.kickAimbotSmooth, Increment = 0.01,
    Callback = function(v) state.kickAimbotSmooth = v end
})
tabKicker:AddBind({
    Name = "Kick Bind (press to attempt a kick at target)",
    Default = state.kickBind,
    Hold = false,
    Callback = function()
        -- On bind pressed we attempt to take a shot at the best target
        -- Implementation below uses the same logic as the aimbot loop with attemptKick() call
        -- immediate trigger handled in InputBegan below
    end
})

-- helper: find best target head in FOV from center/mouse
local function getBestReceiverInFOV(fovPixels)
    local best = nil
    local bestDist = math.huge
    local mousePos = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2) -- center-based FOV
    for _,p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and isAlive(p) and p.Character then
            local head = p.Character:FindFirstChild("Head")
            if head then
                local sp = Camera:WorldToScreenPoint(head.Position)
                local screenPos = Vector2.new(sp.X, sp.Y)
                local d = (screenPos - mousePos).Magnitude
                if d <= fovPixels and d < bestDist then
                    bestDist = d
                    best = head
                end
            end
        end
    end
    return best
end

-- attempt to trigger pass/kick using heuristic methods
local function attemptKick(targetHead)
    if not targetHead or not targetHead.Parent then return false end

    -- 1) Try to find a tool named like ball/football in character/backpack and activate it
    local tool = nil
    for _,obj in pairs(LocalPlayer.Character:GetChildren()) do
        if obj:IsA("Tool") and string.match(string.lower(obj.Name), "ball") then tool = obj; break end
    end
    if not tool then
        for _,obj in pairs(LocalPlayer.Backpack:GetChildren()) do
            if obj:IsA("Tool") and string.match(string.lower(obj.Name), "ball") then tool = obj; break end
        end
    end
    if tool then
        pcall(function()
            if tool.Parent ~= LocalPlayer.Character then
                LocalPlayer.Character.Humanoid:EquipTool(tool)
                wait(0.05)
            end
            -- many football tools use Activate
            if typeof(tool.Activate) == "function" then tool:Activate() end
            -- try to call remote events under tool
            for _,d in pairs(tool:GetDescendants()) do
                if d:IsA("RemoteEvent") then
                    pcall(function() d:FireServer(targetHead.Parent.Name, targetHead.Position) end)
                elseif d:IsA("RemoteFunction") then
                    pcall(function() d:InvokeServer(targetHead.Parent.Name, targetHead.Position) end)
                end
            end
        end)
        print("[SwebHub] Attempted kick using tool:", tool.Name)
        return true
    end

    -- 2) Try scanning ReplicatedStorage/Workspace for a pass/throw remote
    local function scanContainer(ct)
        local candidates = {}
        for _,o in pairs(ct:GetDescendants()) do
            if (o:IsA("RemoteEvent") or o:IsA("RemoteFunction")) and string.match(string.lower(o.Name), "pass") or string.match(string.lower(o.Name), "throw") or string.match(string.lower(o.Name), "kick") then
                table.insert(candidates, o)
            end
        end
        return candidates
    end
    local candidates = {}
    for _,ct in pairs({ReplicatedStorage, Workspace, LocalPlayer, LocalPlayer.Character}) do
        pcall(function()
            for _,c in pairs(scanContainer(ct)) do table.insert(candidates, c) end
        end)
    end
    for _,r in pairs(candidates) do
        pcall(function()
            if r:IsA("RemoteEvent") then
                r:FireServer(targetHead.Position)
                print("[SwebHub] Fired RemoteEvent:", r:GetFullName())
            elseif r:IsA("RemoteFunction") then
                r:InvokeServer(targetHead.Position)
                print("[SwebHub] Invoked RemoteFunction:", r:GetFullName())
            end
        end)
        return true
    end

    -- 3) fallback: just face the target and try to interact (simulate key press)
    if targetHead.Parent and targetHead.Parent:FindFirstChild("HumanoidRootPart") then
        local root = getRootPart()
        if root then
            root.CFrame = CFrame.new(root.Position, targetHead.Position)
        end
    end

    return false
end

-- Kick aimbot runtime (smoothly aim camera at chosen receiver; automatic attempt on bind)
local kickMousePressed = false
UserInputService.InputBegan:Connect(function(inp, gp)
    if gp then return end
    if inp.UserInputType == Enum.UserInputType.MouseButton1 and state.kickAimbot and kickMousePressed then
        -- handled by bind later
    end
    -- detect bind
    if inp.KeyCode == state.kickBind and state.kickAimbot then
        -- find best target and attempt kick
        local best = getBestReceiverInFOV(state.kickAimbotFOV)
        if best then
            -- smooth camera aim: lerp over short time
            local camC = Camera.CFrame
            local desired = CFrame.new(camC.Position, best.Position)
            local steps = 8
            for i = 1,steps do
                Camera.CFrame = camC:Lerp(desired, math.clamp(state.kickAimbotSmooth * (i/steps) * 60, 0, 1))
                wait()
            end
            attemptKick(best)
        end
    end
end)

-- ====== Movement: WalkSpeed, JumpPower, Fly, Teleport Forward, Big Head ======
-- WalkSpeed toggle + slider
local speedToggle, jumpToggle, flyToggle, bigHeadToggle
tabMovement:AddToggle({
    Name = "Enable WalkSpeed",
    Default = false,
    Callback = function(v) state.speedEnabled = v end
})
tabMovement:AddSlider({
    Name = "WalkSpeed Amount",
    Min = 16, Max = 200, Default = state.walkSpeed, Increment = 1,
    Callback = function(v) state.walkSpeed = v end
})
tabMovement:AddToggle({
    Name = "Enable JumpPower",
    Default = false,
    Callback = function(v) state.jumpEnabled = v end
})
tabMovement:AddSlider({
    Name = "JumpPower Amount",
    Min = 50, Max = 300, Default = state.jumpPower, Increment = 1,
    Callback = function(v) state.jumpPower = v end
})

-- Fly
tabMovement:AddToggle({
    Name = "Enable Fly",
    Default = false,
    Callback = function(v) state.flyEnabled = v end
})
tabMovement:AddSlider({
    Name = "Fly Speed",
    Min = 10, Max = 300, Default = state.flySpeed, Increment = 1,
    Callback = function(v) state.flySpeed = v end
})

-- Teleport forward (button + distance slider)
tabMovement:AddSlider({
    Name = "Teleport Forward Distance",
    Min = 10, Max = 500, Default = state.teleportDistance, Increment = 1,
    Callback = function(v) state.teleportDistance = v end
})
tabMovement:AddButton({
    Name = "Teleport Forward Now",
    Callback = function()
        local root = getRootPart()
        if root then
            local forward = Camera.CFrame.LookVector.Unit * state.teleportDistance
            local newPos = root.Position + forward
            pcall(function() root.CFrame = CFrame.new(newPos) end)
        end
    end
})

-- Big Head
tabVisual:AddToggle({
    Name = "Big Head",
    Default = false,
    Callback = function(v)
        state.bigHead = v
        if not v then
            -- revert heads
            for _,p in pairs(Players:GetPlayers()) do
                if p.Character and p.Character:FindFirstChild("Head") then
                    pcall(function() p.Character.Head.Size = Vector3.new(2,1,1) end)
                end
            end
        end
    end
})
tabVisual:AddSlider({
    Name = "Big Head Scale",
    Min = 1.5, Max = 6, Default = state.bigHeadScale, Increment = 0.1,
    Callback = function(v) state.bigHeadScale = v end
})

-- ====== Pull Vector + Legit Pull Vector Tab ======
tabPull:AddToggle({
    Name = "Enable Pull Vector (magnet)",
    Default = false,
    Callback = function(v) state.pullEnabled = v end
})
tabPull:AddSlider({
    Name = "Pull Strength",
    Min = 10, Max = 300, Default = state.pullStrength, Increment = 5,
    Callback = function(v) state.pullStrength = v end
})
tabPull:AddToggle({
    Name = "Legit Pull Vector (smooth predictive)",
    Default = false,
    Callback = function(v) state.legitPull = v end
})
tabPull:AddSlider({
    Name = "Legit Pull Strength",
    Min = 10, Max = 200, Default = state.legitPullStrength, Increment = 1,
    Callback = function(v) state.legitPullStrength = v end
})

-- ====== Click Tackle ======
tabMisc:AddToggle({
    Name = "Click Tackle (click a player to dash tackle)",
    Default = false,
    Callback = function(v) state.clickTackle = v end
})
tabMisc:AddSlider({
    Name = "Tackle Dash Speed",
    Min = 40, Max = 300, Default = state.tackleDashSpeed, Increment = 5,
    Callback = function(v) state.tackleDashSpeed = v end
})
tabMisc:AddSlider({
    Name = "Tackle Range",
    Min = 3, Max = 30, Default = state.tackleRange, Increment = 1,
    Callback = function(v) state.tackleRange = v end
})

-- ====== Football Landing Indicator ======
local landingCircle = NewCircle()
if landingCircle then
    landingCircle.Color = Color3.fromRGB(255,0,0)
    landingCircle.Thickness = 2
    landingCircle.Transparency = 0.7
    landingCircle.Filled = false
    landingCircle.Visible = false
end

tabKicker:AddToggle({
    Name = "Show Football Landing Indicator",
    Default = false,
    Callback = function(v) state.landingIndicator = v; if not v and landingCircle then landingCircle.Visible = false end end
})
tabKicker:AddSlider({
    Name = "Prediction Samples",
    Min = 10, Max = 200, Default = state.landingPredictionSamples, Increment = 5,
    Callback = function(v) state.landingPredictionSamples = v end
})

-- ====== Park Matchmaking Support ======
tabMisc:AddToggle({
    Name = "Park Matchmaking Support (try auto-click join)",
    Default = false,
    Callback = function(v) state.parkSupport = v end
})

-- ====== Runtime Loops & Logic ======
-- Fly implementation (using BodyVelocity + BodyGyro placed/removed cleanly)
local flyBV, flyBG
local flyConnection
local function enableFly(enable)
    local char = getChar()
    if not char or not char.PrimaryPart then return end
    if enable then
        if not flyBV then
            flyBV = Instance.new("BodyVelocity")
            flyBG = Instance.new("BodyGyro")
            flyBV.MaxForce = Vector3.new(1e5,1e5,1e5)
            flyBV.P = 1250
            flyBG.MaxTorque = Vector3.new(1e5,1e5,1e5)
            flyBG.P = 1250
            flyBV.Parent = char.PrimaryPart
            flyBG.Parent = char.PrimaryPart
        end
    else
        if flyBV then flyBV:Destroy(); flyBV = nil end
        if flyBG then flyBG:Destroy(); flyBG = nil end
    end
end

-- Click tackle handling
local tackleActive = false
local clickConn
local function onClickTackle()
    if not state.clickTackle then return end
    local mTarget = Mouse.Target
    if not mTarget then return end
    local p = Players:GetPlayerFromCharacter(mTarget.Parent)
    if not p or p == LocalPlayer then return end
    -- attempt dash towards them if within distance
    local myRoot = getRootPart()
    local theirRoot = getRootPart(p)
    if not myRoot or not theirRoot then return end
    local dist = (theirRoot.Position - myRoot.Position).Magnitude
    if dist > state.tackleRange then return end
    -- dash: set velocity towards target for brief moment
    local dir = (theirRoot.Position - myRoot.Position).Unit
    local vel = dir * state.tackleDashSpeed
    pcall(function() myRoot.Velocity = vel end)
    -- optional: change state to PlatformStand for small time
    local hum = getHumanoid()
    if hum then
        hum.PlatformStand = true
        delay(0.4, function() if hum then hum.PlatformStand = false end end)
    end
end

-- Pull Vector implementations
local function applyPullToBall()
    local ball = findBall()
    local char = getChar()
    if not ball or not char or not char:FindFirstChild("HumanoidRootPart") then return end
    local hrp = char.HumanoidRootPart
    if state.legitPull then
        -- smooth predictive pull: use BodyVelocity and move toward a predicted ball position
        local bvName = "SwebPullBV"
        local existingBV = hrp:FindFirstChild(bvName)
        if not existingBV then
            local bv = Instance.new("BodyVelocity")
            bv.Name = bvName
            bv.MaxForce = Vector3.new(1e5,1e5,1e5)
            bv.P = 1000
            bv.Parent = hrp
            addCleanup(function() pcall(function() bv:Destroy() end) end)
            existingBV = bv
        end
        local bv = existingBV
        -- predict ball position by taking current velocity into account for short duration
        local ballVel = (ball.Velocity or Vector3.new())
        local predictPos = ball.Position + ballVel * 0.2
        local dir = (predictPos - hrp.Position)
        if dir.Magnitude > 1 then
            bv.Velocity = dir.Unit * state.legitPullStrength
        else
            bv.Velocity = Vector3.new(0,0,0)
        end
    else
        -- instant pull: set HRP velocity directly toward ball
        local dir = (ball.Position - hrp.Position)
        if dir.Magnitude > 1 then
            pcall(function() hrp.Velocity = dir.Unit * state.pullStrength end)
        end
    end
end

-- Landing indicator: simulate trajectory to find approximate landing point
local function predictLandingPoint(part, samples)
    if not part then return nil end
    local gravity = workspace.Gravity or 196.2
    local pos = part.Position
    local vel = part.Velocity or Vector3.new()
    local dt = 1/60
    local lastPos = pos
    for i = 1, samples do
        vel = vel + Vector3.new(0, -gravity * dt, 0)
        pos = pos + vel * dt
        -- if we find a position where Y <= ground (approx using Raycast)
        local rayOrigin = lastPos
        local rayDir = pos - lastPos
        local r = Workspace:Raycast(rayOrigin, rayDir, RaycastParams.new())
        if r and r.Position then
            return r.Position
        end
        lastPos = pos
    end
    return pos -- fallback, last simulated pos
end

-- Park matchmaking helper: try to find buttons labeled join/match/queue and click them
local function runParkSupport()
    if not state.parkSupport then return end
    -- search for TextButtons in PlayerGui with keywords
    local gui = LocalPlayer:FindFirstChildWhichIsA("PlayerGui")
    if gui then
        for _,child in pairs(gui:GetDescendants()) do
            if child:IsA("TextButton") and child.Visible and child.Active then
                local name = string.lower(child.Name)
                local text = child.Text and string.lower(child.Text) or ""
                if text:find("join") or text:find("match") or text:find("play") or name:find("match") or name:find("join") then
                    pcall(function() child:Activate(); child.MouseButton1Click:Connect(function() end) end)
                    print("[SwebHub] Attempted to click matchmaking button:", child:GetFullName())
                    -- only click one per run
                    return
                end
            end
        end
    end
end

-- ====== Main Render/Heartbeat Loop ======
local renderConn
renderConn = RunService.RenderStepped:Connect(function(dt)
    -- Update FOV circle center and visibility (if present)
    if fovCircle then
        fovCircle.Position = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)
        fovCircle.Radius = state.kickAimbotFOV
    end

    -- WalkSpeed enforcement
    if state.speedEnabled then
        local hum = getHumanoid()
        if hum then
            hum.WalkSpeed = state.walkSpeed
        end
    end

    -- JumpPower enforcement
    if state.jumpEnabled then
        local hum = getHumanoid()
        if hum then
            hum.JumpPower = state.jumpPower
        end
    end

    -- Fly logic: keep BV/BG updated
    if state.flyEnabled then
        enableFly(true)
        local char = getChar()
        if char and char.PrimaryPart and flyBV and flyBG then
            local mv = Vector3.new()
            local cam = Camera.CFrame
            if UserInputService:IsKeyDown(Enum.KeyCode.W) then mv = mv + cam.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.S) then mv = mv - cam.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.A) then mv = mv - cam.RightVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.D) then mv = mv + cam.RightVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.Space) then mv = mv + Vector3.new(0,1,0) end
            if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then mv = mv - Vector3.new(0,1,0) end
            if mv.Magnitude > 0 then
                flyBV.Velocity = mv.Unit * state.flySpeed
            else
                flyBV.Velocity = Vector3.new(0,0,0)
            end
            flyBG.CFrame = Camera.CFrame
        end
    else
        enableFly(false)
    end

    -- Pull Vector handling
    if state.pullEnabled then
        local success, err = pcall(applyPullToBall)
        if not success then
            -- ignore
        end
    else
        -- cleanup potential BodyVelocity named SwebPullBV
        local hrp = getRootPart()
        if hrp and hrp:FindFirstChild("SwebPullBV") then
            pcall(function() hrp.SwebPullBV:Destroy() end)
        end
    end

    -- Kick Aimbot visual (if enabled: track and smooth aim to best target while not pressing bind)
    if state.kickAimbot then
        -- auto aim camera softly toward best receiver within FOV if the user holds right mouse button
        if UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then
            local bestHead = getBestReceiverInFOV(state.kickAimbotFOV)
            if bestHead then
                local camC = Camera.CFrame
                local desired = CFrame.new(camC.Position, bestHead.Position)
                if state.kickAimbotSmooth <= 0 then
                    Camera.CFrame = desired
                else
                    Camera.CFrame = camC:Lerp(desired, math.clamp(state.kickAimbotSmooth * dt * 60, 0, 1))
                end
            end
        end
    end

    -- Football landing indicator
    if state.landingIndicator then
        local ball = findBall()
        if ball and landingCircle then
            local landPos = predictLandingPoint(ball, state.landingPredictionSamples)
            if landPos then
                local screenPos, onScreen = Camera:WorldToScreenPoint(landPos)
                if onScreen then
                    landingCircle.Position = Vector2.new(screenPos.X, screenPos.Y)
                    landingCircle.Radius = 8
                    landingCircle.Visible = true
                else
                    landingCircle.Visible = false
                end
            else
                landingCircle.Visible = false
            end
        else
            if landingCircle then landingCircle.Visible = false end
        end
    end

    -- Park matchmaking
    if state.parkSupport then
        pcall(runParkSupport)
    end

    -- Big Head
    if state.bigHead then
        for _,p in pairs(Players:GetPlayers()) do
            if p.Character and p.Character:FindFirstChild("Head") then
                local head = p.Character.Head
                pcall(function()
                    head.Size = Vector3.new(state.bigHeadScale, state.bigHeadScale, state.bigHeadScale)
                end)
            end
        end
    end
end)

addCleanup(function()
    if renderConn then renderConn:Disconnect() end
end)

-- ====== Mouse click tackle connection ======
local clickConn
clickConn = Mouse.Button1Down:Connect(function()
    if state.clickTackle then
        onClickTackle()
    end
end)
addCleanup(function() if clickConn then clickConn:Disconnect() end end)

-- ====== Teleport Forward bind (Q for example) ======
-- Add a bind button via UserInputService
UserInputService.InputBegan:Connect(function(input, gp)
    if gp then return end
    if input.KeyCode == Enum.KeyCode.Q then
        local root = getRootPart()
        if root then
            local forward = Camera.CFrame.LookVector.Unit * state.teleportDistance
            local newPos = root.Position + forward
            pcall(function() root.CFrame = CFrame.new(newPos) end)
        end
    end
end)

-- ====== Unload button ======
local settingsTab = Window:MakeTab({Name="Settings", Icon="rbxassetid://7072727166"})
settingsTab:AddButton({
    Name = "Unload Sweb Hub (clean)",
    Callback = function()
        -- revert walk/jump/fly/pull things
        state.pullEnabled = false
        state.legitPull = false
        state.flyEnabled = false
        state.speedEnabled = false
        state.jumpEnabled = false
        state.landingIndicator = false
        -- remove drawing objects
        if fovCircle then pcall(function() fovCircle.Visible = false; fovCircle:Remove() end) end
        if landingCircle then pcall(function() landingCircle.Visible = false; landingCircle:Remove() end) end
        -- revert big head
        for _,p in pairs(Players:GetPlayers()) do
            if p.Character and p.Character:FindFirstChild("Head") then
                pcall(function() p.Character.Head.Size = Vector3.new(2,1,1) end)
            end
        end
        doCleanup()
        OrionLib:Destroy()
        print("[SwebHub] Unloaded")
    end
})

-- ====== Notes + debug prints ======
print("[SwebHub] Loaded: Pull Vector, Legit Pull, WalkSpeed, JumpPower, Fly, Teleport Forward, Kick Aimbot, Landing Indicator, Park Support, Click Tackle, Big Head")
print("[SwebHub] Tips: Press Q to teleport forward. Hold RMB to auto aim (kick aimbot). Use the Kick Bind (E by default) to attempt a targeted kick. Tweak object names if the game uses different ones.")

-- Initialize Orion
OrionLib:Init()
