local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()

local Window = Fluent:CreateWindow({
    Title = "GOLD HUB | SEA 1",
    SubTitle = "por six9log",
    TabWidth = 160,
    Size = UDim2.fromOffset(580, 460),
    Acrylic = true,
    Theme = "Dark",
    MinimizeKey = Enum.KeyCode.LeftControl
})

local Tabs = {
    Main = Window:AddTab({ Title = "Farm Principal", Icon = "home" }),
    Settings = Window:AddTab({ Title = "Configurações", Icon = "settings" })
}

Tabs.Main:AddParagraph({
    Title = "Bem-vindo!",
    Content = "O GOLD HUB está agora usando a Fluent Interface."
})

Tabs.Main:AddButton({
    Title = "Testar Script",
    Description = "Verifica se o HUB está respondendo",
    Callback = function()
        Window:Dialog({
            Title = "Sucesso",
            Content = "A interface Fluent carregou perfeitamente!",
            Buttons = {
                { Title = "Legal!", Default = true }
            }
        })
    end
})

Fluent:SelectTab(1)
