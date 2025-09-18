-- Sweb Hub - Shrink Hide & Seek
local OrionLib = loadstring(game:HttpGet('https://raw.githubusercontent.com/adminabuser/terst/refs/heads/main/source.lua'))()

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")

local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local Humanoid = Character:FindFirstChildOfClass("Humanoid")
local Root = Character:FindFirstChild("HumanoidRootPart") or Character:FindFirstChild("Torso")
local Camera = Workspace.CurrentCamera

-- ===== State =====
local state = {
    fly=false,
    invisible=false,
    shrink=false,
    shrinkSize=0.5,
    noClip=false,
    speedEnabled=false,
    walkSpeed=16,
    esp=false,
    shrinkOther=false,
    shrinkPower=0.5
}

-- ===== Skeleton ESP =====
local SkeletonSettings = {Color=Color3.new(0,1,0), Thickness=2, Transparency=1}
local skeletons = {}

local function createLine() return Drawing.new("Line") end

local function removeSkeleton(skel)
    for _,line in pairs(skel) do line:Remove() end
end

local function trackPlayer(plr)
    local skel = {}
    local function update()
        if not plr.Character or not plr.Character:FindFirstChild("HumanoidRootPart") then
            for _,l in pairs(skel) do l.Visible=false end
            return
        end
        local c = plr.Character
        local hum = c:FindFirstChild("Humanoid")
        if not hum then return end
        local joints = {}
        local conns = {}
        if hum.RigType==Enum.HumanoidRigType.R15 then
            joints = {
                ["Head"]=c:FindFirstChild("Head"),
                ["UpperTorso"]=c:FindFirstChild("UpperTorso"),
                ["LowerTorso"]=c:FindFirstChild("LowerTorso"),
                ["LeftUpperArm"]=c:FindFirstChild("LeftUpperArm"),
                ["LeftLowerArm"]=c:FindFirstChild("LeftLowerArm"),
                ["LeftHand"]=c:FindFirstChild("LeftHand"),
                ["RightUpperArm"]=c:FindFirstChild("RightUpperArm"),
                ["RightLowerArm"]=c:FindFirstChild("RightLowerArm"),
                ["RightHand"]=c:FindFirstChild("RightHand"),
                ["LeftUpperLeg"]=c:FindFirstChild("LeftUpperLeg"),
                ["LeftLowerLeg"]=c:FindFirstChild("LeftLowerLeg"),
                ["RightUpperLeg"]=c:FindFirstChild("RightUpperLeg"),
                ["RightLowerLeg"]=c:FindFirstChild("RightLowerLeg")
            }
            conns = {
                {"Head","UpperTorso"},{"UpperTorso","LowerTorso"},
                {"LowerTorso","LeftUpperLeg"},{"LeftUpperLeg","LeftLowerLeg"},
                {"LowerTorso","RightUpperLeg"},{"RightUpperLeg","RightLowerLeg"},
                {"UpperTorso","LeftUpperArm"},{"LeftUpperArm","LeftLowerArm"},{"LeftLowerArm","LeftHand"},
                {"UpperTorso","RightUpperArm"},{"RightUpperArm","RightLowerArm"},{"RightLowerArm","RightHand"}
            }
        else
            joints = {
                ["Head"]=c:FindFirstChild("Head"),
                ["Torso"]=c:FindFirstChild("Torso"),
                ["LeftLeg"]=c:FindFirstChild("Left Leg"),
                ["RightLeg"]=c:FindFirstChild("Right Leg"),
                ["LeftArm"]=c:FindFirstChild("Left Arm"),
                ["RightArm"]=c:FindFirstChild("Right Arm")
            }
            conns = {{"Head","Torso"},{"Torso","LeftArm"},{"Torso","RightArm"},{"Torso","LeftLeg"},{"Torso","RightLeg"}}
        end
        for i,conn in ipairs(conns) do
            local a,b=joints[conn[1]],joints[conn[2]]
            if a and b then
                local posA,onA=Camera:WorldToViewportPoint(a.Position)
                local posB,onB=Camera:WorldToViewportPoint(b.Position)
                local line = skel[i] or createLine()
                skel[i]=line
                line.Color=SkeletonSettings.Color
                line.Thickness=SkeletonSettings.Thickness
                line.Transparency=SkeletonSettings.Transparency
                if onA and onB then
                    line.From=Vector2.new(posA.X,posA.Y)
                    line.To=Vector2.new(posB.X,posB.Y)
                    line.Visible=state.esp
                else line.Visible=false end
            elseif skel[i] then skel[i].Visible=false end
        end
    end
    RunService.RenderStepped:Connect(function() if plr and plr.Parent then update() end end)
    skeletons[plr]=skel
end

local function untrackPlayer(plr)
    if skeletons[plr] then removeSkeleton(skeletons[plr]) skeletons[plr]=nil end
end

for _,plr in pairs(Players:GetPlayers()) do if plr~=LocalPlayer then trackPlayer(plr) end end
Players.PlayerAdded:Connect(function(plr) if plr~=LocalPlayer then trackPlayer(plr) end end)
Players.PlayerRemoving:Connect(untrackPlayer)

-- ===== GUI =====
local Window = OrionLib:MakeWindow({Name="Sweb Hub - Shrink Hide & Seek", HidePremium=false, SaveConfig=true, ConfigFolder="SwebHubConfig", IntroEnabled=true, IntroText="Sweb Hub - Shrink Hide & Seek", IntroIcon="https://example.com/icon.png"})

-- Tabs
local tabHider = Window:MakeTab({Name="Hider", Icon="rbxassetid://4483345998"})
local tabSeeker = Window:MakeTab({Name="Seeker", Icon="rbxassetid://4483345998"})

-- ===== Hider Toggles =====
tabHider:AddToggle({Name="Fly", Default=false, Callback=function(v) state.fly=v end})
tabHider:AddToggle({Name="Invisible", Default=false, Callback=function(v) state.invisible=v end})
tabHider:AddToggle({Name="Shrink", Default=false, Callback=function(v) state.shrink=v end})
tabHider:AddSlider({Name="Shrink Size", Min=0.1, Max=1, Default=0.5, Increment=0.05, Callback=function(v) state.shrinkSize=v end})
tabHider:AddToggle({Name="No-Clip", Default=false, Callback=function(v) state.noClip=v end})
tabHider:AddToggle({Name="WalkSpeed", Default=false, Callback=function(v) state.speedEnabled=v end})
tabHider:AddSlider({Name="WalkSpeed Value", Min=16, Max=100, Default=16, Increment=1, Callback=function(v) state.walkSpeed=v end})

-- ===== Seeker Toggles =====
tabSeeker:AddToggle({Name="ESP Skeleton", Default=false, Callback=function(v) state.esp=v end})
tabSeeker:AddToggle({Name="Shrink Hiders", Default=false, Callback=function(v) state.shrinkOther=v end})
tabSeeker:AddSlider({Name="Shrink Power", Min=0.1, Max=1, Default=0.5, Increment=0.05, Callback=function(v) state.shrinkPower=v end})

-- ===== GUI Toggle =====
UserInputService.InputBegan:Connect(function(input, processed)
    if processed then return end
    if input.KeyCode==Enum.KeyCode.RightShift then
        Window:Toggle()
    end
end)

OrionLib:Init()
print("[SwebHub] Shrink Hide & Seek Menu Loaded!")
