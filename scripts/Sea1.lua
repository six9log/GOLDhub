local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()

local Window = Fluent:CreateWindow({
    Title = "GOLD HUB | SEA 1",
    SubTitle = "por six9log",
    TabWidth = 160,
    Size = UDim2.fromOffset(580, 460),
    Acrylic = false,
    Theme = "Dark"
})

local Tabs = {
    Main = Window:AddTab({ Title = "Farm", Icon = "rbxassetid://4483362458" })
}

local Options = Fluent.Options

-- VARIÁVEIS DE CONTROLE
_G.AutoFarm = false

-- FUNÇÃO DE ATAQUE
spawn(function()
    while wait() do
        if _G.AutoFarm then
            pcall(function()
                -- Aqui entra a lógica de clique/ataque
                game:GetService("VirtualUser"):CaptureController()
                game:GetService("VirtualUser"):Button1Down(Vector2.new(1280, 672))
            end)
        end
    end
end)

-- INTERFACE
Tabs.Main:AddToggle("AutoFarm", {Title = "Auto Farm Level", Default = false})

Options.AutoFarm:OnChanged(function()
    _G.AutoFarm = Options.AutoFarm.Value
end)

Fluent:SelectTab(1)
