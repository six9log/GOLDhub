-- TESTE DE ABERTURA GOLD HUB
local OrionLib = loadstring(game:HttpGet(('https://raw.githubusercontent.com/shlexware/Orion/main/source')))()

local Window = OrionLib:MakeWindow({
    Name = "GOLD HUB | TESTE", 
    HidePremium = false, 
    SaveConfig = true, 
    ConfigFolder = "GoldTest"
})

local Tab = Window:MakeTab({
    Name = "Sucesso",
    Icon = "rbxassetid://4483345998",
    PremiumOnly = false
})

Tab:AddButton({
    Name = "O Script Funcionou!",
    Callback = function()
        print("Botão apertado")
    end    
})

OrionLib:Init()
