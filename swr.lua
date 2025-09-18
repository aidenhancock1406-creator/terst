-- Sweb Hub - Shrink Hide & Seek (Fully Functional)
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

-- Window & Tabs
local Window = OrionLib:MakeWindow({
    Name = "Sweb Hub - Shrink Hide & Seek",
    HidePremium = false,
    SaveConfig = true,
    ConfigFolder = "SwebHubConfig",
    IntroEnabled = true,
    IntroText = "Sweb Hub - Shrink Hide & Seek Tools"
})

-- RightShift toggle for GUI
local guiOpen = true
UserInputService.InputBegan:Connect(function(input, processed)
    if input.KeyCode == Enum.KeyCode.RightShift then
        guiOpen = not guiOpen
        Window:Toggle(guiOpen)
    end
end)

-- Tabs
local tabHider = Window:MakeTab({Name="Hider"})
local tabSeeker = Window:MakeTab({Name="Seeker"})

-- States
local state = {
    fly=false, invisible=false, autoShrink=false, shrinkSize=0.5, noClip=false, speedEnabled=false, walkSpeed=16,
    esp=false, shrinkOther=false, shrinkPower=0.5
}

-- ===== Hider Tab =====
tabHider:AddToggle({Name="Fly", Default=false, Callback=function(v) state.fly=v end})
tabHider:AddToggle({Name="Invisible", Default=false, Callback=function(v) state.invisible=v end})
tabHider:AddToggle({Name="Auto Shrink", Default=false, Callback=function(v) state.autoShrink=v end})
tabHider:AddSlider({Name="Shrink Size", Min=0.1, Max=1, Default=0.5, Increment=0.05, Callback=function(v) state.shrinkSize=v end})
tabHider:AddToggle({Name="No Clip", Default=false, Callback=function(v) state.noClip=v end})
tabHider:AddToggle({Name="Enable WalkSpeed", Default=false, Callback=function(v) state.speedEnabled=v end})
tabHider:AddSlider({Name="WalkSpeed", Min=16, Max=200, Default=16, Increment=1, Callback=function(v) state.walkSpeed=v end})

-- ===== Seeker Tab =====
tabSeeker:AddToggle({Name="Enable ESP", Default=false, Callback=function(v) state.esp=v end})
tabSeeker:AddToggle({Name="Shrink Hiders", Default=false, Callback=function(v) state.shrinkOther=v end})
tabSeeker:AddSlider({Name="Shrink Power", Min=0.1, Max=1, Default=0.5, Increment=0.05, Callback=function(v) state.shrinkPower=v end})
tabSeeker:AddButton({Name="Teleport to Random Hider", Callback=function()
    local hiders = {}
    for _,p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and isAlive(p) then
            table.insert(hiders, p)
        end
    end
    if #hiders > 0 then
        local target = hiders[math.random(1,#hiders)]
        local root = getRootPart()
        local targetRoot = getRootPart(target)
        if root and targetRoot then
            root.CFrame = targetRoot.CFrame + Vector3.new(0,3,0)
        end
    end
end})

-- ===== Skeleton ESP =====
local skeletons = {}
local SkeletonSettings = {Color=Color3.fromRGB(255,0,0), Thickness=2, Transparency=1}

local function createSkeletonLines(plr)
    if not Drawing or not Drawing.new then return end
    local lines = {}
    local names = {
        "Head_Neck", "Neck_UpperTorso", "UpperTorso_LowerTorso",
        "LeftShoulder_LeftUpperArm", "LeftUpperArm_LeftLowerArm", "LeftLowerArm_LeftHand",
        "RightShoulder_RightUpperArm", "RightUpperArm_RightLowerArm", "RightLowerArm_RightHand",
        "LeftHip_LeftUpperLeg", "LeftUpperLeg_LeftLowerLeg", "LeftLowerLeg_LeftFoot",
        "RightHip_RightUpperLeg", "RightUpperLeg_RightLowerLeg", "RightLowerLeg_RightFoot"
    }
    for _,n in pairs(names) do
        local line = Drawing.new("Line")
        line.Color = SkeletonSettings.Color
        line.Thickness = SkeletonSettings.Thickness
        line.Transparency = SkeletonSettings.Transparency
        line.Visible = false
        lines[n] = line
    end
    skeletons[plr] = lines
end

-- Remove skeleton on player leave
Players.PlayerRemoving:Connect(function(plr)
    if skeletons[plr] then
        for _,l in pairs(skeletons[plr]) do
            pcall(function() l:Remove() end)
        end
        skeletons[plr] = nil
    end
end)

-- ===== Runtime =====
RunService.RenderStepped:Connect(function()
    local char = getChar()
    if not char or not char:FindFirstChild("HumanoidRootPart") then return end
    local root = char.HumanoidRootPart
    local hum = getHumanoid()

    -- WalkSpeed
    if hum then
        if state.speedEnabled then hum.WalkSpeed = state.walkSpeed else hum.WalkSpeed = 16 end
    end

    -- Fly
    if state.fly then
        root.Anchored = false
        local dir = Vector3.new(0,0,0)
        if UserInputService:IsKeyDown(Enum.KeyCode.W) then dir = dir + Camera.CFrame.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then dir = dir - Camera.CFrame.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then dir = dir - Camera.CFrame.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then dir = dir + Camera.CFrame.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then dir = dir + Vector3.new(0,1,0) end
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then dir = dir - Vector3.new(0,1,0) end
        if dir.Magnitude > 0 then root.Velocity = dir.Unit * 60 end
    end

    -- Invisible + NoClip
    for _,p in pairs(char:GetDescendants()) do
        if p:IsA("BasePart") or p:IsA("MeshPart") or p:IsA("Accessory") then
            p.Transparency = state.invisible and 1 or 0
            p.CanCollide = not state.noClip
        elseif p:IsA("Decal") then
            p.Transparency = state.invisible and 1 or 0
        end
    end

    -- Shrink self
    if state.autoShrink then
        for _,p in pairs(char:GetDescendants()) do
            if p:IsA("BasePart") or p:IsA("MeshPart") then
                p.Size = p.Size.Unit * state.shrinkSize
            end
        end
    end

    -- Shrinker (Seeker)
    if state.shrinkOther then
        for _,plr in pairs(Players:GetPlayers()) do
            if plr ~= LocalPlayer and isAlive(plr) then
                for _,p in pairs(plr.Character:GetDescendants()) do
                    if p:IsA("BasePart") or p:IsA("MeshPart") then
                        p.Size = p.Size.Unit * state.shrinkPower
                    end
                end
            end
        end
    end

    -- ESP Skeleton
    if state.esp then
        for _,plr in pairs(Players:GetPlayers()) do
            if plr ~= LocalPlayer and isAlive(plr) then
                if not skeletons[plr] then createSkeletonLines(plr) end
                local lines = skeletons[plr]
                local c = plr.Character
                if not c then continue end
                local function ws(pos)
                    local p, vis = Camera:WorldToViewportPoint(pos)
                    return Vector2.new(p.X,p.Y), vis
                end
                local head = c:FindFirstChild("Head")
                local upperTorso = c:FindFirstChild("UpperTorso") or c:FindFirstChild("Torso")
                local lowerTorso = c:FindFirstChild("LowerTorso") or upperTorso
                local lUpArm = c:FindFirstChild("LeftUpperArm") or c:FindFirstChild("Left Arm")
                local lLoArm = c:FindFirstChild("LeftLowerArm") or c:FindFirstChild("Left Arm")
                local lHand = c:FindFirstChild("LeftHand") or c:FindFirstChild("Left Arm")
                local rUpArm = c:FindFirstChild("RightUpperArm") or c:FindFirstChild("Right Arm")
                local rLoArm = c:FindFirstChild("RightLowerArm") or c:FindFirstChild("Right Arm")
                local rHand = c:FindFirstChild("RightHand") or c:FindFirstChild("Right Arm")
                local lUpLeg = c:FindFirstChild("LeftUpperLeg") or c:FindFirstChild("Left Leg")
                local lLoLeg = c:FindFirstChild("LeftLowerLeg") or c:FindFirstChild("Left Leg")
                local lFoot = c:FindFirstChild("LeftFoot") or c:FindFirstChild("Left Leg")
                local rUpLeg = c:FindFirstChild("RightUpperLeg") or c:FindFirstChild("Right Leg")
                local rLoLeg = c:FindFirstChild("RightLowerLeg") or c:FindFirstChild("Right Leg")
                local rFoot = c:FindFirstChild("RightFoot") or c:FindFirstChild("Right Leg")

                -- Draw lines (example: head->upperTorso)
                local function drawLine(name, from, to)
                    local line = lines[name]
                    if from and to then
                        local f,vf = ws(from.Position)
                        local t, vt = ws(to.Position)
                        line.From = f
                        line.To = t
                        line.Visible = vf and vt
                    else
                        line.Visible = false
                    end
                end
                drawLine("Head_Neck", head, upperTorso)
                drawLine("Neck_UpperTorso", upperTorso, lowerTorso)
                drawLine("UpperTorso_LowerTorso", upperTorso, lowerTorso)
                drawLine("LeftShoulder_LeftUpperArm", upperTorso, lUpArm)
                drawLine("LeftUpperArm_LeftLowerArm", lUpArm, lLoArm)
                drawLine("LeftLowerArm_LeftHand", lLoArm, lHand)
                drawLine("RightShoulder_RightUpperArm", upperTorso, rUpArm)
                drawLine("RightUpperArm_RightLowerArm", rUpArm, rLoArm)
                drawLine("RightLowerArm_RightHand", rLoArm, rHand)
                drawLine("LeftHip_LeftUpperLeg", lowerTorso, lUpLeg)
                drawLine("LeftUpperLeg_LeftLowerLeg", lUpLeg, lLoLeg)
                drawLine("LeftLowerLeg_LeftFoot", lLoLeg, lFoot)
                drawLine("RightHip_RightUpperLeg", lowerTorso, rUpLeg)
                drawLine("RightUpperLeg_RightLowerLeg", rUpLeg, rLoLeg)
                drawLine("RightLowerLeg_RightFoot", rLoLeg, rFoot)
            end
        end
    else
        for plr,lines in pairs(skeletons) do
            for _,l in pairs(lines) do l.Visible=false end
        end
    end
end)

OrionLib:Init()
print("[SwebHub] Fully Functional Shrink Hide & Seek Loaded!")
