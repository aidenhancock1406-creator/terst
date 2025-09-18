-- Load and execute the key.lua script
local keyScript = loadstring(game:HttpGet("https://raw.githubusercontent.com/adminabuser/terst/refs/heads/main/key.lua"))()

-- Validate the key
keyScript(function()
    -- Load and execute the hm.lua script after key validation
    local mainScript = loadstring(game:HttpGet("https://raw.githubusercontent.com/adminabuser-creator/terst/main/mainn.lua"))()
    mainScript()
end)
