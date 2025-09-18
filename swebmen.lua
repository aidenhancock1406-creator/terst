local OrionLib = loadstring(game:HttpGet(('https://raw.githubusercontent.com/aidenhancock1406-creator/terst/refs/heads/main/source.lua')))() 
local Window = OrionLib:MakeWindow({
	Name = "Sweb Hub - NFL Universe",
	HidePremium = false,
	SaveConfig = true,
	ConfigFolder = "SwebHubConfig",
	IntroEnabled = true,
	IntroText = "Welcome to Sweb Hub",
	IntroIcon = "rbxassetid://1234567890", -- Replace with a valid NFL-related icon ID
	Icon = "rbxassetid://1234567890", -- Replace with a valid NFL-related icon ID
	CloseCallback = function()
		print("Sweb Hub closed")
	end
})

-- Key system
local validKey = "NFL123" -- Replace with your desired key
local userKey = ""
local keyVerified = false

local function verifyKey()
	if userKey == validKey then
		keyVerified = true
		print("Key verified!")
	else
		print("Invalid key!")
	end
end

local KeyTab = Window:MakeTab({
	Name = "Key System",
	Icon = "rbxassetid://4483345998",
	PremiumOnly = false
})

KeyTab:AddTextbox({
	Name = "Enter Key",
	Default = "",
	TextDisappear = true,
	Callback = function(Value)
		userKey = Value
		verifyKey()
	end
})

KeyTab:AddButton({
	Name = "Verify Key",
	Callback = function()
		verifyKey()
	end
})

if not keyVerified then
	return -- Prevent further execution until the key is verified
end

-- NFL Universe Menu
local Tab = Window:MakeTab({
	Name = "NFL Universe",
	Icon = "rbxassetid://4483345998",
	PremiumOnly = false
})

Tab:AddButton({
	Name = "Teleport to Stadium",
	Callback = function()
		print("Teleporting to stadium...")
		-- Add teleportation logic here
	end    
})

Tab:AddToggle({
	Name = "Enable Speed Boost",
	Default = false,
	Callback = function(Value)
		print("Speed Boost:", Value)
		-- Add speed boost logic here
	end    
})

Tab:AddSlider({
	Name = "Set Player Speed",
	Min = 16,
	Max = 100,
	Default = 16,
	Color = Color3.fromRGB(0, 255, 0),
	Increment = 1,
	ValueName = "Speed",
	Callback = function(Value)
		print("Player Speed set to:", Value)
		-- Add player speed adjustment logic here
	end    
})

Tab:AddDropdown({
	Name = "Select Team",
	Default = "None",
	Options = {"Team A", "Team B", "Team C"},
	Callback = function(Value)
		print("Selected Team:", Value)
		-- Add team selection logic here
	end    
})

Tab:AddLabel("NFL Universe Features")
Tab:AddParagraph("Instructions", "Use the options above to customize your NFL Universe experience.")

OrionLib:Init()
