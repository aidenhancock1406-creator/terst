-- Load and execute the key.lua script
local keyScript = loadstring(game:HttpGet("https://raw.githubusercontent.com/aidenhancock1406-creator/terst/main/key.lua"))()

-- Validate the key
keyScript(function()
    -- Load and execute the hm.lua script after key validation
    local mainScript = loadstring(game:HttpGet("https://raw.githubusercontent.com/aidenhancock1406-creator/terst/main/yumad.lua"))()
    mainScript()
end)
