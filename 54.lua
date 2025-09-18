-- Sweb Hub - Shrink Hide & Seek Full
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")

local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local Humanoid = Character:FindFirstChildOfClass("Humanoid")
local Root = Character:FindFirstChild("HumanoidRootPart") or Character:FindFirstChild("Torso")

-- Skeleton ESP Settings
local SkeletonSettings = {Color = Color3.new(0, 1, 0), Thickness = 2, Transparency = 1}
local skeletons = {}

-- Hider/Seeker State
local state = {
    fly = false,
    invisible = false,
    shrink = false,
    shrinkSize = 0.5,
    noClip = false,
    speedEnabled = false,
    walkSpeed = 16,
    esp = false,
    shrinkOther = false,
    shrinkPower = 0.5
}

-- ===== Drawing Skeleton ESP =====
local function createLine()
    local line = Drawing.new("Line")
    return line
end

local function removeSkeleton(skeleton)
    for _, line in pairs(skeleton) do
        line:Remove()
    end
end

local function trackPlayer(plr)
    local skeleton = {}
    local function updateSkeleton()
        if not plr.Character or not plr.Character:FindFirstChild("HumanoidRootPart") then
            for _, line in pairs(skeleton) do line.Visible = false end
            return
        end

        local character = plr.Character
        local humanoid = character:FindFirstChild("Humanoid")
        local joints = {}
        local connections = {}

        if humanoid.RigType == Enum.HumanoidRigType.R15 then
            joints = {
                ["Head"] = character:FindFirstChild("Head"),
                ["UpperTorso"] = character:FindFirstChild("UpperTorso"),
                ["LowerTorso"] = character:FindFirstChild("LowerTorso"),
                ["LeftUpperArm"] = character:FindFirstChild("LeftUpperArm"),
                ["LeftLowerArm"] = character:FindFirstChild("LeftLowerArm"),
                ["LeftHand"] = character:FindFirstChild("LeftHand"),
                ["RightUpperArm"] = character:FindFirstChild("RightUpperArm"),
                ["RightLowerArm"] = character:FindFirstChild("RightLowerArm"),
                ["RightHand"] = character:FindFirstChild("RightHand"),
                ["LeftUpperLeg"] = character:FindFirstChild("LeftUpperLeg"),
                ["LeftLowerLeg"] = character:FindFirstChild("LeftLowerLeg"),
                ["RightUpperLeg"] = character:FindFirstChild("RightUpperLeg"),
                ["RightLowerLeg"] = character:FindFirstChild("RightLowerLeg")
            }
            connections = {
                {"Head","UpperTorso"},{"UpperTorso","LowerTorso"},
                {"LowerTorso","LeftUpperLeg"},{"LeftUpperLeg","LeftLowerLeg"},
                {"LowerTorso","RightUpperLeg"},{"RightUpperLeg","RightLowerLeg"},
                {"UpperTorso","LeftUpperArm"},{"LeftUpperArm","LeftLowerArm"},{"LeftLowerArm","LeftHand"},
                {"UpperTorso","RightUpperArm"},{"RightUpperArm","RightLowerArm"},{"RightLowerArm","RightHand"}
            }
        else
            joints = {
                ["Head"] = character:FindFirstChild("Head"),
                ["Torso"] = character:FindFirstChild("Torso"),
                ["LeftLeg"] = character:FindFirstChild("Left Leg"),
                ["RightLeg"] = character:FindFirstChild("Right Leg"),
                ["LeftArm"] = character:FindFirstChild("Left Arm"),
                ["RightArm"] = character:FindFirstChild("Right Arm")
            }
            connections = {
                {"Head","Torso"},{"Torso","LeftArm"},{"Torso","RightArm"},{"Torso","LeftLeg"},{"Torso","RightLeg"}
            }
        end

        for index, conn in ipairs(connections) do
            local jointA, jointB = joints[conn[1]], joints[conn[2]]
            if jointA and jointB then
                local posA, onScreenA = Camera:WorldToViewportPoint(jointA.Position)
                local posB, onScreenB = Camera:WorldToViewportPoint(jointB.Position)
                local line = skeleton[index] or createLine()
                skeleton[index] = line
                line.Color = SkeletonSettings.Color
                line.Thickness = SkeletonSettings.Thickness
                line.Transparency = SkeletonSettings.Transparency
                if onScreenA and onScreenB then
                    line.From = Vector2.new(posA.X,posA.Y)
                    line.To = Vector2.new(posB.X,posB.Y)
                    line.Visible = state.esp
                else line.Visible = false end
            elseif skeleton[index] then
                skeleton[index].Visible = false
            end
        end
    end

    RunService.RenderStepped:Connect(function()
        if state.esp and plr ~= LocalPlayer then updateSkeleton() end
    end)
    skeletons[plr] = skeleton
end

local function untrackPlayer(plr)
    if skeletons[plr] then
        removeSkeleton(skeletons[plr])
        skeletons[plr] = nil
    end
end

for _,plr in pairs(Players:GetPlayers()) do if plr~=LocalPlayer then trackPlayer(plr) end end
Players.PlayerAdded:Connect(function(plr) if plr~=LocalPlayer then trackPlayer(plr) end end)
Players.PlayerRemoving:Connect(untrackPlayer)

-- ===== Main Loop =====
RunService.RenderStepped:Connect(function()
    local char = LocalPlayer.Character
    if not char then return end
    local hum = char:FindFirstChildOfClass("Humanoid")
    local root = char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("Torso")

    -- WalkSpeed
    if state.speedEnabled and hum then hum.WalkSpeed = state.walkSpeed else if hum then hum.WalkSpeed=16 end end

    -- Fly
    if state.fly and root then
        local dir = Vector3.new()
        if UserInputService:IsKeyDown(Enum.KeyCode.W) then dir+=Camera.CFrame.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then dir-=Camera.CFrame.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then dir-=Camera.CFrame.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then dir+=Camera.CFrame.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then dir+=Vector3.new(0,1,0) end
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then dir-=Vector3.new(0,1,0) end
        root.Velocity = dir.Magnitude>0 and dir.Unit*60 or Vector3.new()
    end

    -- Invisible + NoClip
    for _,p in pairs(char:GetDescendants()) do
        if p:IsA("BasePart") or p:IsA("MeshPart") then
            p.Transparency = state.invisible and 1 or 0
            p.CanCollide = not state.noClip
        elseif p:IsA("Decal") then
            p.Transparency = state.invisible and 1 or 0
        end
    end

    -- Shrink
    if state.shrink then
        for _,p in pairs(char:GetDescendants()) do
            if p:IsA("BasePart") or p:IsA("MeshPart") then
                p.Size = p.Size.Unit*state.shrinkSize
            end
        end
    end

    -- Shrink Other (Seeker)
    if state.shrinkOther then
        for _,plr in pairs(Players:GetPlayers()) do
            if plr~=LocalPlayer and plr.Character then
                for _,p in pairs(plr.Character:GetDescendants()) do
                    if p:IsA("BasePart") or p:IsA("MeshPart") then
                        p.Size = p.Size.Unit*state.shrinkPower
                    end
                end
            end
        end
    end
end)
