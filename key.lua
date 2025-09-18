-- Define the key required to access the UI
local requiredKey = "swbhubkey7"

-- Load the Orion library
local OrionLib = loadstring(game:HttpGet(('https://raw.githubusercontent.com/aidenhancock1406-creator/terst/refs/heads/main/source.lua')))()

-- Create the UI window
local Window = OrionLib:MakeWindow({Name = "SwebHub - Key System", HidePremium = false, SaveConfig = false})

-- Function to prompt the user for the key
local function requestKey(onSuccess)
    local isKeyValid = false

    -- Create a tab for the key input
    local Tab = Window:MakeTab({
        Name = "Key Input",
        Icon = "rbxassetid://4483345998",
        PremiumOnly = false
    })

    -- Add a textbox for the user to input the key
    Tab:AddTextbox({
        Name = "Enter Key",
        Default = "",
        TextDisappear = true,
        Callback = function(userKey)
            if userKey == requiredKey then
                isKeyValid = true
                OrionLib:MakeNotification({
                    Name = "Success",
                    Content = "Key is valid! Access granted.",
                    Image = "rbxassetid://4483345998",
                    Time = 5
                })
                OrionLib:Destroy()
                if onSuccess then
                    onSuccess()
                end
            else
                OrionLib:MakeNotification({
                    Name = "Error",
                    Content = "Invalid Key. Please try again.",
                    Image = "rbxassetid://4483345998",
                    Time = 5
                })
            end
        end
    })

    -- Add a button to copy the Discord link
    Tab:AddButton({
        Name = "Discord Link (KEY)",
        Callback = function()
            setclipboard("https://discord.gg/Q9caeDr2M8")
            OrionLib:MakeNotification({
                Name = "Copied",
                Content = "Discord link copied to clipboard!",
                Image = "rbxassetid://4483345998",
                Time = 5
            })
        end
    })

    -- Initialize the UI and wait until the key is valid
    OrionLib:Init()
    repeat wait() until isKeyValid
end

-- Execute the key request function
return requestKey
