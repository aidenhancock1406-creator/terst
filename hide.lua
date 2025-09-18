-- Sweb Hub - Shrink Hide & Seek
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
    IntroText = "Sweb Hub - Shrink Hide & Seek Tools",
    IntroIcon = "https://example.com/shrink_icon.png"
})

-- Tabs
local tabHider = Window:MakeTab({Name="Hider", Icon="rbxassetid://4483345998"})
local tabSeeker = Window:MakeTab({Name="Seeker", Icon="rbxassetid://4483345998"})

-- States
local state = {
    -- Hider
    fly=false, invisible=false, autoShrink=false, shrinkSize=0.5, noClip=false, speedEnabled=false, walkSpeed=16,
    -- Seeker
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

-- ===== Runtime =====
RunService.RenderStepped:Connect(function()
    local char = getChar()
    if not char or not char:FindFirstChild("HumanoidRootPart") then return end
    local root = char.HumanoidRootPart
    local hum = getHumanoid()

    -- Hider WalkSpeed
    if hum then
        if state.speedEnabled then hum.WalkSpeed = state.walkSpeed else hum.WalkSpeed = 16 end
    end

    -- Fly
    if state.fly and root then
        root.Anchored = false
        local flyDir = Vector3.new(0,0,0)
        if UserInputService:IsKeyDown(Enum.KeyCode.W) then flyDir = flyDir + Camera.CFrame.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then flyDir = flyDir - Camera.CFrame.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then flyDir = flyDir - Camera.CFrame.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then flyDir = flyDir + Camera.CFrame.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then flyDir = flyDir + Vector3.new(0,1,0) end
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then flyDir = flyDir - Vector3.new(0,1,0) end
        if flyDir.Magnitude > 0 then
            root.Velocity = flyDir.Unit * 60
        end
    end

    -- Invisible
    if state.invisible then
        for _,part in pairs(char:GetChildren()) do
            if part:IsA("BasePart") then
                part.Transparency = 1
                if part:FindFirstChildOfClass("Decal") then
                    part:FindFirstChildOfClass("Decal").Transparency = 1
                end
            end
        end
    end

    -- Auto Shrink
    if state.autoShrink then
        for _,part in pairs(char:GetChildren()) do
            if part:IsA("BasePart") then
                part.Size = Vector3.new(state.shrinkSize,state.shrinkSize,state.shrinkSize)
            end
        end
    end

    -- No Clip
    if state.noClip then
        for _,part in pairs(char:GetChildren()) do
            if part:IsA("BasePart") then
                part.CanCollide = false
            end
        end
    else
        for _,part in pairs(char:GetChildren()) do
            if part:IsA("BasePart") then
                part.CanCollide = true
            end
        end
    end

    -- Seeker ESP
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

    -- Shrinker (Seeker)
    if state.shrinkOther then
        for _,p in pairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and isAlive(p) then
                local rootPart = getRootPart(p)
                if rootPart then
                    for _,part in pairs(p.Character:GetChildren()) do
                        if part:IsA("BasePart") then
                            part.Size = Vector3.new(state.shrinkPower,state.shrinkPower,state.shrinkPower)
                        end
                    end
                end
            end
        end
    end
end)

-- Initialize Orion
OrionLib:Init()
print("[SwebHub] Shrink Hide & Seek Script Loaded. Hider and Seeker features integrated.")
