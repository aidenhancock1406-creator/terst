-- Sweb Hub - Forsaken Full Script
local SwebHub = loadstring(game:HttpGet("https://raw.githubusercontent.com/adminabuser/terst/refs/heads/main/source.lua"))()

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

-- Utility Functions
local function getChar(plr) plr = plr or LocalPlayer return plr.Character or plr.CharacterAdded:Wait() end
local function getHumanoid(plr) local c = getChar(plr) return c and c:FindFirstChildOfClass("Humanoid") end
local function getRootPart(plr) local c = getChar(plr) if not c then return nil end return c:FindFirstChild("HumanoidRootPart") or c:FindFirstChild("Torso") or c:FindFirstChild("UpperTorso") end
local function isAlive(plr) local hum = getHumanoid(plr) return hum and hum.Health > 0 end

-- Global States
local state = {
    autoGen=false,
    infStamina=false,
    speedEnabled=false, walkSpeed=16,
    espGeneral=false,
    espPlayer=false,
    espHighlight=true,
    espName=true,
    espDistance=true,
    espHealth=true,
    colorGeneral=Color3.fromRGB(135,206,235),
    colorKiller=Color3.fromRGB(255,105,105),
    colorSurvivor=Color3.fromRGB(144,238,144),
    espTextSize=14,
    showKillers=true,
    showSurvivors=true
}

-- Window & Tabs
local Window = SwebHub:MakeWindow({
    Name = "Sweb Hub - Forsaken",
    HidePremium = false,
    SaveConfig = true,
    ConfigFolder = "SwebHubConfig",
    IntroEnabled = true,
    IntroText = "Sweb Hub - Forsaken Tools",
    IntroIcon = 108632720139222
})

local tabMain = Window:MakeTab({Name="Main", Icon="rbxassetid://108632720139222"})
local tabVisual = Window:MakeTab({Name="Visual", Icon="rbxassetid://108632720139222"})
local tabSettings = Window:MakeTab({Name="Settings", Icon="rbxassetid://108632720139222"})

-- ===== Main Tab =====
tabMain:AddToggle({Name="Auto Generator", Default=false, Callback=function(v)
    state.autoGen=v
    if v then
        spawn(function()
            while state.autoGen do
                if Workspace.Map.Ingame:FindFirstChild("Map") then
                    for _, gen in pairs(Workspace.Map.Ingame.Map:GetChildren()) do
                        if gen.Name=="Generator" and gen:FindFirstChild("Remotes") and gen.Remotes:FindFirstChild("RE") then
                            gen.Remotes.RE:FireServer()
                        end
                    end
                end
                wait(3.5)
            end
        end)
    end
end})

tabMain:AddToggle({Name="Infinite Stamina", Default=false, Callback=function(v)
    state.infStamina=v
    if v then
        spawn(function()
            while state.infStamina do
                local success, staminaModule = pcall(function()
                    return require(game.ReplicatedStorage:WaitForChild("Systems"):WaitForChild("Character"):WaitForChild("Game"):WaitForChild("Sprinting"))
                end)
                if success and staminaModule then
                    staminaModule.MaxStamina = 696969
                    staminaModule.Stamina = 696969
                    if staminaModule.__staminaChangedEvent then
                        staminaModule.__staminaChangedEvent:Fire(staminaModule.Stamina)
                    end
                end
                wait(0.1)
            end
        end)
    end
end})

tabMain:AddToggle({Name="Enable Walk Speed", Default=false, Callback=function(v)
    state.speedEnabled=v
end})

tabMain:AddSlider({Name="Walk Speed", Min=16, Max=99, Default=16, Increment=1, Callback=function(v)
    state.walkSpeed=v
end})

-- ===== Visual Tab =====
tabVisual:AddToggle({Name="Generator ESP", Default=false, Callback=function(v) state.espGeneral=v end})
tabVisual:AddToggle({Name="Player ESP", Default=false, Callback=function(v) state.espPlayer=v end})
tabVisual:AddToggle({Name="ESP Highlights", Default=true, Callback=function(v) state.espHighlight=v end})
tabVisual:AddToggle({Name="Show Names", Default=true, Callback=function(v) state.espName=v end})
tabVisual:AddToggle({Name="Show Distance", Default=true, Callback=function(v) state.espDistance=v end})
tabVisual:AddToggle({Name="Show Health", Default=true, Callback=function(v) state.espHealth=v end})
tabVisual:AddSlider({Name="ESP Text Size", Min=8, Max=24, Default=14, Increment=1, Callback=function(v) state.espTextSize=v end})
tabVisual:AddColorPicker({Name="Generator Color", Default=Color3.fromRGB(135,206,235), Callback=function(v) state.colorGeneral=v end})
tabVisual:AddColorPicker({Name="Killer Color", Default=Color3.fromRGB(255,105,105), Callback=function(v) state.colorKiller=v end})
tabVisual:AddColorPicker({Name="Survivor Color", Default=Color3.fromRGB(144,238,144), Callback=function(v) state.colorSurvivor=v end})
tabVisual:AddToggle({Name="Show Killers", Default=true, Callback=function(v) state.showKillers=v end})
tabVisual:AddToggle({Name="Show Survivors", Default=true, Callback=function(v) state.showSurvivors=v end})

-- ===== Settings Tab =====
tabSettings:AddLabel("Sweb Hub - Forsaken")
tabSettings:AddLabel("Created by JScripter")
tabSettings:AddLabel("Country: "..game:GetService("LocalizationService"):GetCountryRegionForPlayerAsync(LocalPlayer))
tabSettings:AddLabel("Executor: "..identifyexecutor())
tabSettings:AddButton({Name="Copy Job ID", Callback=function()
    if setclipboard then
        setclipboard(tostring(game.JobId))
        SwebHub:Notify("Success","Job ID copied!",5)
    else
        SwebHub:Notify("Job ID",tostring(game.JobId),5)
    end
end})

-- ===== ESP Logic =====
local function CleanupESP(parent)
    for _, child in pairs(parent:GetChildren()) do
        if child.Name:match("ESP") then child:Destroy() end
    end
end

local function CreateHighlight(target,color)
    if target:FindFirstChild("ESP_Highlight") then
        target.ESP_Highlight.FillColor=color
        target.ESP_Highlight.OutlineColor=color
        return
    end
    local highlight=Instance.new("Highlight")
    highlight.Name="ESP_Highlight"
    highlight.FillColor=color
    highlight.OutlineColor=color
    highlight.FillTransparency=0.6
    highlight.OutlineTransparency=0.2
    highlight.Adornee=target
    highlight.Parent=target
end

local function CreateBillboard(target,text,color)
    if target:FindFirstChild("ESP_Billboard") then
        target.ESP_Billboard.TextLabel.Text=text
        target.ESP_Billboard.TextLabel.TextColor3=color
        return
    end
    local billboard=Instance.new("BillboardGui")
    billboard.Name="ESP_Billboard"
    billboard.Adornee=target
    billboard.Size=UDim2.new(0,100,0,50)
    billboard.AlwaysOnTop=true
    billboard.StudsOffset=Vector3.new(0,3,0)
    local textLabel=Instance.new("TextLabel")
    textLabel.Name="TextLabel"
    textLabel.BackgroundTransparency=1
    textLabel.Font=Enum.Font.Code
    textLabel.Size=UDim2.new(1,0,1,0)
    textLabel.TextSize=state.espTextSize
    textLabel.TextColor3=color
    textLabel.TextStrokeTransparency=0.5
    textLabel.TextStrokeColor3=Color3.new(0,0,0)
    textLabel.Text=text
    textLabel.Parent=billboard
    billboard.Parent=target
end

-- ===== Runtime =====
RunService.RenderStepped:Connect(function()
    local char = getChar()
    local hum = getHumanoid()
    local root = getRootPart()

    -- WalkSpeed
    if hum then
        if state.speedEnabled then hum.WalkSpeed=state.walkSpeed else hum.WalkSpeed=16 end
    end

    -- Infinite Stamina
    if state.infStamina then
        local success, staminaModule = pcall(function()
            return require(game.ReplicatedStorage:WaitForChild("Systems"):WaitForChild("Character"):WaitForChild("Game"):WaitForChild("Sprinting"))
        end)
        if success and staminaModule then
            staminaModule.MaxStamina = 696969
            staminaModule.Stamina = 696969
            if staminaModule.__staminaChangedEvent then
                staminaModule.__staminaChangedEvent:Fire(staminaModule.Stamina)
            end
        end
    end

    -- ESP Generators
    if state.espGeneral and Workspace.Map.Ingame:FindFirstChild("Map") then
        for _, gen in pairs(Workspace.Map.Ingame.Map:GetChildren()) do
            if gen.Name=="Generator" and gen:FindFirstChild("Progress") then
                local progress=gen.Progress.Value
                local color=progress==100 and state.colorSurvivor or state.colorGeneral
                if state.espHighlight then CreateHighlight(gen,color) end
                local text=""
                if state.espName then text="Generator ("..progress.."%)" end
                if state.espDistance and root then text=text.."\nDistance: "..math.floor((root.Position-gen.Position).Magnitude) end
                CreateBillboard(gen,text,color)
            end
        end
    end

    -- ESP Players
    if state.espPlayer then
        for _, plrType in pairs(Workspace.Players:GetChildren()) do
            if (plrType.Name=="Killers" and state.showKillers) or (plrType.Name=="Survivors" and state.showSurvivors) then
                for _, plr in pairs(plrType:GetChildren()) do
                    local pRoot = plr:FindFirstChild("HumanoidRootPart")
                    local pHum = plr:FindFirstChild("Humanoid")
                    local pHead = plr:FindFirstChild("Head")
                    if pRoot and pHum and pHead then
                        local color = plrType.Name=="Killers" and state.colorKiller or state.colorSurvivor
                        if state.espHighlight then CreateHighlight(plr,color) end
                        local text=""
                        if state.espName then text=text..plr.Name end
                        if state.espDistance and root then text=text.."\nDistance: "..math.floor((root.Position-pRoot.Position).Magnitude) end
                        if state.espHealth then text=text.."\nHealth: "..math.floor(pHum.Health) end
                        CreateBillboard(pHead,text,color)
                    end
                end
            end
        end
    end

    -- Auto Generator
    if state.autoGen and Workspace.Map.Ingame:FindFirstChild("Map") then
        for _, gen in pairs(Workspace.Map.Ingame.Map:GetChildren()) do
            if gen.Name=="Generator" and gen:FindFirstChild("Remotes") and gen.Remotes:FindFirstChild("RE") then
                gen.Remotes.RE:FireServer()
            end
        end
    end
end)

-- Initialize Sweb Hub
SwebHub:Init()
print("[SwebHub] Full Feature Script Loaded. Forsaken features integrated!")
