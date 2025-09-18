-- SwebHub Remote Spawner GUI for Steal-a-Jeffy
local OrionLib = loadstring(game:HttpGet("https://raw.githubusercontent.com/adminabuser/terst/refs/heads/main/source.lua"))()

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LocalPlayer = game:GetService("Players").LocalPlayer

-- ---------- Helpers ----------
local function getRemotes(root)
    local remotes = {}
    for _, obj in pairs(root:GetDescendants()) do
        if obj:IsA("RemoteEvent") or obj:IsA("RemoteFunction") then
            table.insert(remotes, obj)
        end
    end
    return remotes
end

local function fireRemote(remote, args)
    args = args or {}
    if remote:IsA("RemoteEvent") then
        remote:FireServer(table.unpack(args))
    elseif remote:IsA("RemoteFunction") then
        remote:InvokeServer(table.unpack(args))
    end
end

-- ---------- Window ----------
local Window = OrionLib:MakeWindow({
    Name = "SwebHub - Remote Spawner",
    HidePremium = true,
    SaveConfig = false
})

local tab = Window:MakeTab({Name = "Spawner", Icon = "rbxassetid://4483345998"})

-- ---------- State ----------
local state = {
    selectedRemote = nil,
    remotesList = {},
    argsText = "",
    logLines = {}
}

-- ---------- Remote List ----------
tab:AddButton({
    Name = "Scan Remotes",
    Callback = function()
        local ok, remotes = pcall(getRemotes, ReplicatedStorage:WaitForChild("voidSky").Remotes)
        if ok then
            state.remotesList = remotes
            notifyText = "Found "..#remotes.." remotes."
            OrionLib:MakeNotification({Name="Spawner", Content=notifyText, Time=3})
        else
            OrionLib:MakeNotification({Name="Spawner", Content="Failed to scan remotes.", Time=3})
        end
    end
})

-- Dropdown for selecting remote
local dropdown = tab:AddDropdown({
    Name = "Select Remote",
    Options = {},
    Default = "None",
    Callback = function(opt)
        for _, r in pairs(state.remotesList) do
            if tostring(r) == opt then
                state.selectedRemote = r
            end
        end
    end
})

-- Update dropdown options after scanning
tab:AddButton({
    Name = "Refresh Dropdown",
    Callback = function()
        local opts = {}
        for _, r in pairs(state.remotesList) do
            table.insert(opts, tostring(r))
        end
        dropdown:Refresh(opts, true)
    end
})

-- Args textbox
local argsBox = tab:AddTextbox({
    Name = "Args (comma-separated)",
    Default = "",
    TextDisappear = false,
    Callback = function(val)
        state.argsText = val
    end
})

-- Fire Remote button
tab:AddButton({
    Name = "Fire Remote",
    Callback = function()
        if not state.selectedRemote then
            OrionLib:MakeNotification({Name="Spawner", Content="Select a remote first.", Time=3})
            return
        end

        -- parse args from comma-separated string
        local args = {}
        for val in string.gmatch(state.argsText, "[^,]+") do
            val = val:gsub("^%s*(.-)%s*$", "%1") -- trim spaces
            local n = tonumber(val)
            if n then val = n end
            table.insert(args, val)
        end

        pcall(function()
            fireRemote(state.selectedRemote, args)
            OrionLib:MakeNotification({Name="Spawner", Content="Fired "..tostring(state.selectedRemote), Time=3})
            table.insert(state.logLines, "Fired "..tostring(state.selectedRemote).." with args: "..table.concat(args, ","))
        end)
    end
})

-- Log textbox
local logBox = tab:AddTextbox({
    Name = "Log (latest actions)",
    Default = "",
    TextDisappear = false,
    Callback = function(v) end
})

-- Update log periodically
task.spawn(function()
    while true do
        task.wait(0.5)
        if #state.logLines > 0 then
            logBox:SetValue(table.concat(state.logLines, "\n"))
        end
    end
end)

-- Initialize Orion
OrionLib:Init()
print("[SwebHub] Remote Spawner GUI loaded.")
