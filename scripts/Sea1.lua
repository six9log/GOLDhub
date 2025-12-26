-- GOLD HUB | Sea 1 Test
local OrionLib = loadstring(game:HttpGet(('https://raw.githubusercontent.com/shlexware/Orion/main/source')))()

local Window = OrionLib:MakeWindow({
    Name = "GOLD HUB | SEA 1", 
    HidePremium = false, 
    SaveConfig = true, 
    ConfigFolder = "GoldHub1"
})

local Tab = Window:MakeTab({
    Name = "Main",
    Icon = "rbxassetid://4483345998",
    PremiumOnly = false
})

Tab:AddButton({
    Name = "Script Ativado com Sucesso!",
    Callback = function()
        print("GOLD HUB está a funcionar!")
    end    
})

OrionLib:Init()
