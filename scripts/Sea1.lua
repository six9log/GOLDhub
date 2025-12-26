-- GOLD HUB | SEA 1
local OrionLib = loadstring(game:HttpGet('https://raw.githubusercontent.com/shlexware/Orion/main/source'))()

local Window = OrionLib:MakeWindow({
    Name = "GOLD HUB | SEA 1", 
    HidePremium = false, 
    SaveConfig = true, 
    ConfigFolder = "GoldHub1"
})

local Tab = Window:MakeTab({
    Name = "Início",
    Icon = "rbxassetid://4483345998",
    PremiumOnly = false
})

Tab:AddButton({
    Name = "Script Ativado!",
    Callback = function()
        OrionLib:MakeNotification({
            Name = "GOLD HUB",
            Content = "O menu está a funcionar perfeitamente!",
            Image = "rbxassetid://4483345998",
            Time = 5
        })
    end    
})

OrionLib:Init()
