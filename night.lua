-- Sweb Hub - 99 Nights in the Forest
-- Credits: Original Devs @xz, @goof, GUI Lib @weakhoes

getgenv().Config = {
    Invite = "SwebHub",
    Version = "1.0",
}

getgenv().luaguardvars = {
    DiscordName = "Sweb#4503",
}

-- Load Informant.Wtf library
local library = loadstring(game:HttpGet("https://raw.githubusercontent.com/weakhoes/Roblox-UI-Libs/refs/heads/main/2%20Informant.wtf%20Lib%20(FIXED)/informant.wtf%20Lib%20Source.lua"))()
library:init()

-- Create main window
local Window = library.NewWindow({
    title = "Sweb Hub",
    size = UDim2.new(0, 550, 0, 650)
})

-- Create tabs
local tabs = {
    Player = Window:AddTab("Player"),
    Items = Window:AddTab("Items"),
    Visuals = Window:AddTab("Visuals"),
    Misc = Window:AddTab("Misc"),
    Settings = library:CreateSettingsTab(Window)
}

-- Create sections in tabs
local sections = {
    PlayerSection = tabs.Player:AddSection("Player", 1),
    ItemsSection = tabs.Items:AddSection("Auto Farm", 1),
    VisualsSection = tabs.Visuals:AddSection("ESP / Visuals", 1),
    MiscSection = tabs.Misc:AddSection("Misc", 1)
}

-- Player Tab Toggles
sections.PlayerSection:AddToggle({
    enabled = true,
    text = "WalkSpeed",
    flag = "WalkSpeedToggle",
    tooltip = "Enable custom walkspeed",
    risky = false,
    callback = function(state)
        print("WalkSpeed toggle:", state)
    end
})

sections.PlayerSection:AddSlider({
    text = "WalkSpeed Value",
    flag = "WalkSpeedValue",
    suffix = "",
    value = 16,
    min = 16,
    max = 500,
    increment = 1,
    tooltip = "Adjust walkspeed",
    risky = false,
    callback = function(val)
        print("WalkSpeed set to:", val)
    end
})

sections.PlayerSection:AddToggle({
    enabled = false,
    text = "JumpPower",
    flag = "JumpPowerToggle",
    tooltip = "Enable custom jumppower",
    risky = false,
    callback = function(state)
        print("JumpPower toggle:", state)
    end
})

sections.PlayerSection:AddSlider({
    text = "JumpPower Value",
    flag = "JumpPowerValue",
    suffix = "",
    value = 50,
    min = 50,
    max = 300,
    increment = 1,
    tooltip = "Adjust jumppower",
    risky = false,
    callback = function(val)
        print("JumpPower set to:", val)
    end
})

-- Items Tab
sections.ItemsSection:AddToggle({
    enabled = false,
    text = "Bring All Items",
    flag = "BringAllItems",
    tooltip = "Bring all items to your inventory",
    risky = false,
    callback = function(state)
        print("Bring All Items:", state)
    end
})

sections.ItemsSection:AddToggle({
    enabled = false,
    text = "Auto Fuel Campfire",
    flag = "AutoFuelCampfire",
    tooltip = "Automatically fuel the campfire",
    risky = false,
    callback = function(state)
        print("Auto Fuel Campfire:", state)
    end
})

sections.ItemsSection:AddToggle({
    enabled = false,
    text = "Auto Cook",
    flag = "AutoCook",
    tooltip = "Automatically cook food",
    risky = false,
    callback = function(state)
        print("Auto Cook:", state)
    end
})

sections.ItemsSection:AddToggle({
    enabled = false,
    text = "Auto Eat",
    flag = "AutoEat",
    tooltip = "Automatically eat when hungry",
    risky = false,
    callback = function(state)
        print("Auto Eat:", state)
    end
})

sections.ItemsSection:AddSlider({
    text = "Auto Eat Range",
    flag = "AutoEatRange",
    suffix = "m",
    value = 10,
    min = 5,
    max = 50,
    increment = 1,
    tooltip = "Adjust the range for auto eating",
    risky = false,
    callback = function(val)
        print("Auto Eat Range set to:", val)
    end
})

-- Visuals Tab
sections.VisualsSection:AddToggle({
    enabled = false,
    text = "ESP for Players",
    flag = "ESPPlayers",
    tooltip = "Enable ESP for players",
    risky = false,
    callback = function(state)
        print("ESP for Players:", state)
    end
})

sections.VisualsSection:AddToggle({
    enabled = false,
    text = "ESP for Chests",
    flag = "ESPChests",
    tooltip = "Enable ESP for chests",
    risky = false,
    callback = function(state)
        print("ESP for Chests:", state)
    end
})

sections.VisualsSection:AddToggle({
    enabled = false,
    text = "ESP for Mobs",
    flag = "ESPMobs",
    tooltip = "Enable ESP for mobs",
    risky = false,
    callback = function(state)
        print("ESP for Mobs:", state)
    end
})

sections.VisualsSection:AddToggle({
    enabled = false,
    text = "ESP for Lost Children",
    flag = "ESPLostChildren",
    tooltip = "Enable ESP for lost children",
    risky = false,
    callback = function(state)
        print("ESP for Lost Children:", state)
    end
})

-- Misc Tab
sections.MiscSection:AddButton({
    enabled = true,
    text = "Teleport to Campfire",
    flag = "TeleportCampfire",
    tooltip = "Teleport to the nearest campfire",
    risky = false,
    callback = function()
        print("Teleporting to Campfire...")
    end
})

sections.MiscSection:AddButton({
    enabled = true,
    text = "Teleport to Child 1",
    flag = "TeleportChild1",
    tooltip = "Teleport to Child 1",
    risky = false,
    callback = function()
        print("Teleporting to Child 1...")
    end
})

sections.MiscSection:AddButton({
    enabled = true,
    text = "Teleport to Child 2",
    flag = "TeleportChild2",
    tooltip = "Teleport to Child 2",
    risky = false,
    callback = function()
        print("Teleporting to Child 2...")
    end
})

sections.MiscSection:AddButton({
    enabled = true,
    text = "Teleport to Child 3",
    flag = "TeleportChild3",
    tooltip = "Teleport to Child 3",
    risky = false,
    callback = function()
        print("Teleporting to Child 3...")
    end
})

sections.MiscSection:AddButton({
    enabled = true,
    text = "Teleport to Child 4",
    flag = "TeleportChild4",
    tooltip = "Teleport to Child 4",
    risky = false,
    callback = function()
        print("Teleporting to Child 4...")
    end
})

sections.MiscSection:AddButton({
    enabled = true,
    text = "Save Position",
    flag = "SavePosition",
    tooltip = "Save your current position",
    risky = false,
    callback = function()
        print("Position saved.")
    end
})

sections.MiscSection:AddButton({
    enabled = true,
    text = "Teleport to Saved Position",
    flag = "TeleportSavedPosition",
    tooltip = "Teleport to your saved position",
    risky = false,
    callback = function()
        print("Teleporting to saved position...")
    end
})

-- Send startup notification
library:SendNotification("Sweb Hub Loaded!", 5, Color3.new(0, 255, 0))
