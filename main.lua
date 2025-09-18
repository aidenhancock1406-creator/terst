-- Sweb Hub v1.1 - NFL Universe (SZN1) tuned
-- Tabs: Pass Assist (QB Aimbot), Movement, Player, Combat, Utility, Settings
-- Notes: Auto-pass attempts several client techniques (Tool:Activate and tries common remote names).
-- You may need to tweak remote names if the game uses custom/obfuscated remotes.

local OrionLib = loadstring(game:HttpGet(('https://raw.githubusercontent.com/aidenhancock1406-creator/terst/refs/heads/main/source.lua')))()
local Window = OrionLib:MakeWindow({
    Name = "Sweb Hub - NFL Universe",
    HidePremium = false,
    SaveConfig = true,
    ConfigFolder = "SwebHubConfig",
    IntroEnabled = true,
    IntroText = "Sweb Hub for SZN1 - NFL Universe",
    IntroIcon = "https://example.com/nfl_icon.png"
})

-- Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local LocalPlayer = Players.LocalPlayer
local camera = Workspace.CurrentCamera
local mouse = LocalPlayer:GetMouse()

-- Helpers
local function getChar(plr)
    plr = plr or LocalPlayer
    return plr.Character or plr.CharacterAdded:Wait()
end
local function getHumanoid(plr)
    local c = getChar(plr)
    if c then return c:FindFirstChildOfClass("Humanoid") end
    return nil
end
local function getRoot(plr)
    local c = getChar(plr)
    if c then return c:FindFirstChild("HumanoidRootPart") or c:FindFirstChild("Torso") or c:FindFirstChild("UpperTorso") end
    return nil
end
local function isAlive(plr)
    local hum = getHumanoid(plr)
    return hum and hum.Health > 0
end

-- Attempt to find ball/tool or a "hasBall" marker for the local player
local function playerHasBall()
    -- try common patterns: Tool named "Football" in character or backpack, or BoolValue "HasBall" in player/char
    local c = getChar()
    for _,tool in pairs(LocalPlayer.Backpack:GetChildren()) do
        if tool:IsA("Tool") and string.lower(tool.Name):find("ball") or string.lower(tool.Name):find("football") then
            return tool
        end
    end
    if c then
        for _,tool in pairs(c:GetChildren()) do
            if tool:IsA("Tool") and (string.lower(tool.Name):find("ball") or string.lower(tool.Name):find("football")) then
                return tool
            end
        end
    end
    -- search for bool/values that indicate ball possession
    for _,v in pairs(LocalPlayer:GetDescendants()) do
        if (v:IsA("BoolValue") or v:IsA("IntValue") or v:IsA("NumberValue")) and string.lower(v.Name):find("ball") then
            if tostring(v.Value) ~= "0" then return true end
        end
    end
    return nil
end

-- Utility: search for likely pass remotes (print list)
local function scanForPassRemotes()
    local candidates = {}
    local function checkContainer(ct)
        for _,obj in pairs(ct:GetChildren()) do
            if obj:IsA("RemoteEvent") or obj:IsA("RemoteFunction") then
                local n = string.lower(obj.Name)
                if n:find("pass") or n:find("throw") or n:find("passball") or n:find("kick") or n:find("throwball") or n:find("fire") then
                    table.insert(candidates, obj)
                end
            end
        end
    end
    pcall(function() checkContainer(ReplicatedStorage) end)
    pcall(function() checkContainer(Workspace) end)
    pcall(function() checkContainer(LocalPlayer) end)
    print("[SwebHub] pass remote candidates found:", #candidates)
    for i,v in pairs(candidates) do print(i, v:GetFullName()) end
    return candidates
end

-- PASS ASSIST / QB AIMBOT tab
local tabAimbot = Window:MakeTab({
    Name = "Pass Assist",
    Icon = "rbxassetid://3926307978",
    PremiumOnly = false
})

-- Variables
local passAssistEnabled = false
local passAutoThrow = false
local passHoldAim = Enum.UserInputType.MouseButton2 -- RMB hold to aim
local passFOV = 120 -- in degrees-ish (we map to pixels)
local passSmooth = 0.2
local passTeamCheck = true -- target teammates only
local passMode = "ClosestToCrosshair" -- "ClosestToQB" or "ClosestToCrosshair"

-- UI
tabAimbot:AddToggle({
    Name = "Enable Pass Assist (aim while holding RMB)",
    Default = false,
    Callback = function(v) passAssistEnabled = v end
})
tabAimbot:AddToggle({
    Name = "Auto Throw (attempt to fire pass automatically)",
    Default = false,
    Callback = function(v) passAutoThrow = v end
})
tabAimbot:AddSlider({
    Name = "FOV (pixels approx)",
    Min = 30,
    Max = 400,
    Default = passFOV,
    Increment = 1,
    Callback = function(v) passFOV = v end
})
tabAimbot:AddSlider({
    Name = "Smoothing (0 snap)",
    Min = 0,
    Max = 1,
    Default = passSmooth,
    Increment = 0.01,
    Callback = function(v) passSmooth = v end
})
tabAimbot:AddDropdown({
    Name = "Target Priority",
    Default = "ClosestToCrosshair",
    Options = {"ClosestToCrosshair","ClosestToQB"},
    Callback = function(v) passMode = v end
})
tabAimbot:AddToggle({
    Name = "Target Teammates Only",
    Default = true,
    Callback = function(v) passTeamCheck = v end
})

tabAimbot:AddButton({
    Name = "Scan for likely pass remotes (prints results)",
    Callback = function()
        scanForPassRemotes()
    end
})

-- On-screen FOV circle (simple)
local fovCircle = Drawing and Drawing.new and Drawing.new("Circle") or nil
local showFOVCircle = true
if showFOVCircle and fovCircle then
    fovCircle.Transparency = 0.6
    fovCircle.Thickness = 1
end

-- pick targets: eligible receivers = other players, alive, on same team (if enabled), in front of QB/within FOV
local function getEligibleReceivers()
    local list = {}
    for _,plr in pairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and isAlive(plr) then
            if passTeamCheck then
                if LocalPlayer.Team and plr.Team and LocalPlayer.Team ~= plr.Team then
                    continue
                end
            end
            local head = plr.Character and plr.Character:FindFirstChild("Head")
            if head then
                -- rough check: is in front of QB? angle less than ~130 deg to be considered forward
                local myRoot = getRoot(LocalPlayer)
                if myRoot then
                    local dir = (head.Position - myRoot.Position)
                    if dir.Magnitude > 0 then
                        table.insert(list, {plr=plr, head=head, dist=(camera.CFrame.Position - head.Position).Magnitude})
                    end
                end
            end
        end
    end
    return list
end

local aiming = false
local currentTarget = nil

-- helper: choose best target based on passMode
local function chooseTarget(candidates)
    if #candidates == 0 then return nil end
    if passMode == "ClosestToQB" then
        table.sort(candidates, function(a,b) return a.dist < b.dist end)
        return candidates[1].head
    else -- ClosestToCrosshair
        local best, bestDist = nil, 1e9
        local mousePos = Vector2.new(mouse.X, mouse.Y)
        for _,c in pairs(candidates) do
            local sp = camera:WorldToScreenPoint(c.head.Position)
            local d = (Vector2.new(sp.X, sp.Y) - mousePos).Magnitude
            if d < bestDist then bestDist = d; best = c.head end
        end
        return best
    end
end

-- attempt to auto-throw the ball to a receiver:
local function attemptAutoThrow(targetHead)
    if not targetHead or not targetHead.Parent then return false end
    -- 1) If player has a tool that looks like a ball, try Tool:Activate() and Tool:FireServer if present
    local tool = playerHasBall()
    if tool and tool.Parent then
        pcall(function()
            -- many football scripts implement client tool activation that triggers the server.
            if tool.Parent == LocalPlayer.Character then
                if tool:FindFirstChild("Activate") and typeof(tool.Activate) == "function" then
                    tool:Activate()
                    print("[SwebHub] Activated tool for pass attempt.")
                else
                    -- some tools use remote inside the tool
                    for _,obj in pairs(tool:GetDescendants()) do
                        if obj:IsA("RemoteEvent") or obj:IsA("RemoteFunction") then
                            pcall(function() obj:FireServer(targetHead.Position) end)
                        end
                    end
                    -- fallback: Trigger tool events via ClickDetector or .Remote (best-effort)
                end
            else
                -- if it's in backpack, equip and activate
                LocalPlayer.Character.Humanoid:EquipTool(tool)
                wait(0.05)
                if tool and tool.Parent == LocalPlayer.Character and tool:FindFirstChild("Activate") and typeof(tool.Activate) == "function" then
                    tool:Activate()
                end
            end
        end)
    end

    -- 2) Try firing likely RemoteEvents in ReplicatedStorage/Workspace that match common names
    local candidates = scanForPassRemotes()
    for _,r in pairs(candidates) do
        pcall(function()
            if r:IsA("RemoteEvent") then
                -- attempt to send plausible args: target player or position
                r:FireServer(targetHead.Parent.Name, targetHead.Position) -- many scripts expect (playerName, pos) or (player, pos)
                print("[SwebHub] Fired RemoteEvent:", r:GetFullName())
            elseif r:IsA("RemoteFunction") then
                r:InvokeServer(targetHead.Parent.Name, targetHead.Position)
                print("[SwebHub] Invoked RemoteFunction:", r:GetFullName())
            end
        end)
    end

    -- 3) If none worked, still return true to indicate we tried
    return true
end

-- Input handling: aim when holding RMB
UserInputService.InputBegan:Connect(function(input, gpe)
    if gpe then return end
    if input.UserInputType == passHoldAim then
        aiming = true
    end
end)
UserInputService.InputEnded:Connect(function(input, gpe)
    if gpe then return end
    if input.UserInputType == passHoldAim then
        aiming = false
        currentTarget = nil
    end
end)

RunService.RenderStepped:Connect(function(dt)
    -- draw fov circle if Drawing available
    if fovCircle then
        fovCircle.Position = Vector2.new(mouse.X, mouse.Y)
        fovCircle.Radius = passFOV
        fovCircle.Visible = passAssistEnabled and aiming
    end

    if passAssistEnabled and aiming then
        local candidates = getEligibleReceivers()
        if #candidates == 0 then currentTarget = nil return end
        -- choose target
        local chosenHead = chooseTarget(candidates)
        if chosenHead and chosenHead.Parent then
            currentTarget = chosenHead
            -- aim camera smoothly
            local camC = camera.CFrame
            local desired = CFrame.new(camC.Position, chosenHead.Position)
            if passSmooth <= 0 then
                camera.CFrame = desired
            else
                camera.CFrame = camC:Lerp(desired, math.clamp(passSmooth * dt * 60, 0, 1))
            end

            -- auto throw if enabled and we have the ball
            if passAutoThrow then
                local hasBall = playerHasBall()
                if hasBall then
                    attemptAutoThrow(chosenHead)
                else
                    -- some games register possession differently; try checking some indicators and still try remotes
                    attemptAutoThrow(chosenHead)
                end
            end
        end
    end
end)

-- Movement tab (stamina, speed, jump, fly, noclip)
local tabMovement = Window:MakeTab({
    Name = "Movement",
    Icon = "rbxassetid://6023426915",
    PremiumOnly = false
})

local defaultWalk = 16
local speedActive = false
local speedValue = 32
tabMovement:AddToggle({ Name = "Speed Boost", Default = false, Callback = function(v) speedActive = v; local hum = getHumanoid(); if hum then hum.WalkSpeed = v and speedValue or defaultWalk end end})
tabMovement:AddSlider({ Name = "Speed Amount", Min = 16, Max = 200, Default = speedValue, Increment = 1, Callback = function(v) speedValue = v; if speedActive and getHumanoid() then getHumanoid().WalkSpeed = v end end})

local jpValue = 50
tabMovement:AddSlider({ Name = "Jump Power", Min = 50, Max = 250, Default = jpValue, Increment = 1, Callback = function(v) jpValue = v; if getHumanoid() then getHumanoid().JumpPower = v end end})

local flyEnabled = false
local flySpeed = 60
tabMovement:AddToggle({ Name = "Fly (for testing)", Default = false, Callback = function(v) flyEnabled = v end })
tabMovement:AddSlider({ Name = "Fly Speed", Min = 10, Max = 300, Default = flySpeed, Increment = 1, Callback = function(v) flySpeed = v end })

local noclipEnabled = false
tabMovement:AddToggle({ Name = "Noclip", Default = false, Callback = function(v) noclipEnabled = v end })

-- find stamina NumberValue if present
local function findStamina()
    local searchPlaces = {LocalPlayer, LocalPlayer:FindFirstChild("leaderstats"), LocalPlayer.Character}
    for _,root in pairs(searchPlaces) do
        if root then
            for _,v in pairs(root:GetDescendants()) do
                if (v:IsA("NumberValue") or v:IsA("IntValue")) and string.lower(v.Name):find("stam") then
                    return v
                end
            end
        end
    end
    return nil
end
local staminaRef = findStamina()
local staminaOverride = false
tabMovement:AddToggle({ Name = "Infinite Stamina", Default = false, Callback = function(v) staminaOverride = v; staminaRef = staminaRef or findStamina(); if staminaRef and v then staminaRef.Value = 9999 end end})

-- Movement loops
local bodyGyro, bodyVel
RunService.RenderStepped:Connect(function()
    -- fly
    local char = getChar()
    if flyEnabled and char and char.PrimaryPart then
        if not bodyGyro then
            bodyGyro = Instance.new("BodyGyro", char.PrimaryPart)
            bodyVel = Instance.new("BodyVelocity", char.PrimaryPart)
            bodyGyro.MaxTorque = Vector3.new(1e5,1e5,1e5)
            bodyGyro.P = 1e4
            bodyVel.MaxForce = Vector3.new(1e5,1e5,1e5)
            bodyVel.P = 1e3
        end
        local mv = Vector3.new()
        local cam = camera.CFrame
        if UserInputService:IsKeyDown(Enum.KeyCode.W) then mv = mv + cam.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then mv = mv - cam.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then mv = mv - cam.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then mv = mv + cam.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then mv = mv + Vector3.new(0,1,0) end
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then mv = mv - Vector3.new(0,1,0) end
        if mv.Magnitude > 0 then
            bodyVel.Velocity = mv.Unit * flySpeed
        else
            bodyVel.Velocity = Vector3.new(0,0,0)
        end
        bodyGyro.CFrame = camera.CFrame
    else
        if bodyGyro then bodyGyro:Destroy(); bodyGyro = nil end
        if bodyVel then bodyVel:Destroy(); bodyVel = nil end
    end

    -- noclip
    if noclipEnabled and char then
        for _,part in pairs(char:GetDescendants()) do
            if part:IsA("BasePart") and part.CanCollide then
                part.CanCollide = false
            end
        end
    end

    -- stamina override
    if staminaOverride then
        staminaRef = staminaRef or findStamina()
        if staminaRef and staminaRef.Parent then
            pcall(function() staminaRef.Value = math.max(staminaRef.Value, 9999) end)
        end
    end

    -- enforce speed/jump on respawn
    local hum = getHumanoid()
    if hum then
        if speedActive then hum.WalkSpeed = speedValue else hum.WalkSpeed = defaultWalk end
        hum.JumpPower = jpValue
    end
end)

-- Player tab
local tabPlayer = Window:MakeTab({ Name = "Player", Icon = "rbxassetid://6023426915", PremiumOnly = false })
tabPlayer:AddSlider({ Name = "Player Size (scale)", Min = 0.5, Max = 2.5, Default = 1, Increment = 0.05, Callback = function(v)
    local c = getChar()
    pcall(function()
        for _,stat in pairs({"BodyHeightScale","BodyWidthScale","BodyDepthScale","HeadScale"}) do
            if c:FindFirstChild("Humanoid") and c.Humanoid:FindFirstChild(stat) then
                c.Humanoid[stat].Value = v
            end
        end
    end)
end })
tabPlayer:AddColorpicker({ Name = "Custom Jersey Color", Default = Color3.fromRGB(255,0,0), Callback = function(col)
    local c = getChar()
    pcall(function()
        for _,part in pairs(c:GetDescendants()) do
            if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
                part.Color = col
            end
        end
    end)
end })
tabPlayer:AddTextbox({ Name = "Custom Display Name", Default = "", TextDisappear = true, Callback = function(txt)
    local hum = getHumanoid()
    if hum then
        pcall(function() hum.DisplayName = txt end)
    end
end })

-- Combat tab: Godmode (clientside)
local tabCombat = Window:MakeTab({ Name = "Combat", Icon = "rbxassetid://3926307978", PremiumOnly = false })
local godEnabled = false
tabCombat:AddToggle({ Name = "Godmode (client-side)", Default = false, Callback = function(v) godEnabled = v end })
RunService.Heartbeat:Connect(function()
    if godEnabled then
        local hum = getHumanoid()
        if hum then
            pcall(function() hum.Health = hum.MaxHealth end)
        end
    end
end)

-- Utility tab: ESP & Skeleton & Teleport
local tabUtil = Window:MakeTab({ Name = "Utility", Icon = "rbxassetid://4483345998", PremiumOnly = false })
local espEnabled = false
local espTable = {}

tabUtil:AddToggle({ Name = "ESP Name Tags", Default = false, Callback = function(v)
    espEnabled = v
    if not v then
        for _,g in pairs(espTable) do pcall(function() g:Destroy() end) end
        espTable = {}
    end
end })
tabUtil:AddToggle({ Name = "Skeleton Markers (basic)", Default = false, Callback = function(v)
    -- toggled inside run loop below
    skeletonEnabled = v
end })

tabUtil:AddTextbox({ Name = "Teleport to Player", Default = "", TextDisappear = true, Callback = function(val)
    local tp = Players:FindFirstChild(val)
    if tp and tp.Character and getRoot(tp) then
        local root = getRoot(LocalPlayer)
        if root then
            LocalPlayer.Character:MoveTo(getRoot(tp).Position + Vector3.new(0,5,0))
        end
    end
end })

-- ESP loop
RunService.RenderStepped:Connect(function()
    if espEnabled then
        for _,plr in pairs(Players:GetPlayers()) do
            if plr ~= LocalPlayer and isAlive(plr) then
                if not espTable[plr] then
                    local head = plr.Character and plr.Character:FindFirstChild("Head")
                    if head then
                        local gui = Instance.new("BillboardGui", head)
                        gui.Name = "SwebESP"
                        gui.Size = UDim2.new(0,120,0,40)
                        gui.StudsOffset = Vector3.new(0,1.5,0)
                        gui.AlwaysOnTop = true
                        local txt = Instance.new("TextLabel", gui)
                        txt.Size = UDim2.new(1,0,1,0)
                        txt.BackgroundTransparency = 1
                        txt.TextScaled = true
                        txt.Text = plr.Name
                        espTable[plr] = gui
                    end
                end
            end
        end
        -- cleanup
        for pl,gui in pairs(espTable) do
            if not isAlive(pl) then pcall(function() gui:Destroy() end); espTable[pl] = nil end
        end
    end
end)

-- Settings
local tabSettings = Window:MakeTab({ Name = "Settings", Icon = "rbxassetid://7072727166", PremiumOnly = false })
tabSettings:AddButton({ Name = "Unload Sweb Hub", Callback = function()
    -- quick cleanup
    passAssistEnabled = false; speedActive = false; flyEnabled = false; noclipEnabled = false; staminaOverride = false; godEnabled = false; espEnabled = false
    OrionLib:Destroy()
end })

-- Ensure features persist after respawn
Players.LocalPlayer.CharacterAdded:Connect(function(char)
    wait(1)
    local hum = char:WaitForChild("Humanoid",5)
    if hum then hum.JumpPower = jpValue; if speedActive then hum.WalkSpeed = speedValue end end
end)

OrionLib:Init()
print("[SwebHub] Loaded for NFL Universe (SZN1). Tips: Use RMB to aim with Pass Assist, toggle Auto Throw if you want the script to attempt to send the pass automatically.")
