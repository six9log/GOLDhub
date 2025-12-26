local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()

local Window = Fluent:CreateWindow({
    Title = "GOLD HUB | SEA 1 (ULTRA)",
    SubTitle = "por six9log",
    TabWidth = 160,
    Size = UDim2.fromOffset(580, 460),
    Acrylic = false,
    Theme = "Dark"
})

local Tabs = { Main = Window:AddTab({ Title = "Farm", Icon = "home" }) }
local Options = Fluent.Options
_G.AutoFarm = false

-- ATAQUE REMOTO (DIRETO NO SERVIDOR)
spawn(function()
    while true do
        task.wait(0.1) -- Seu delay de 0.1s
        if _G.AutoFarm then
            pcall(function()
                local Monster = workspace.Enemies:FindFirstChild("Bandit")
                if Monster and Monster:FindFirstChild("Humanoid") and Monster.Humanoid.Health > 0 then
                    -- Isso aqui envia o dano direto pro monstro, sem clique!
                    game:GetService("ReplicatedStorage").Remotes.CommF_:InvokeServer("Attack", Monster.HumanoidRootPart, true)
                end
            end)
        end
    end
end)

-- SISTEMA DE MOVIMENTO E QUEST (SIMPLIFICADO)
spawn(function()
    while true do
        task.wait()
        if _G.AutoFarm then
            pcall(function()
                local player = game.Players.LocalPlayer
                local root = player.Character.HumanoidRootPart
                
                -- Se não tem missão
                if not player.PlayerGui.Main.Quest.Visible then
                    root.CFrame = CFrame.new(1059, 16, 1546)
                    task.wait(0.5)
                    game:GetService("ReplicatedStorage").Remotes.CommF_:InvokeServer("StartQuest", "BanditQuest1", 1)
                else
                    -- Procura o Bandit
                    local Monster = workspace.Enemies:FindFirstChild("Bandit")
                    if Monster and Monster:FindFirstChild("HumanoidRootPart") then
                        -- Fica colado no monstro para o dano entrar
                        root.CFrame = Monster.HumanoidRootPart.CFrame * CFrame.new(0, 5, 0)
                        
                        -- Noclip e Anti-Queda
                        root.Velocity = Vector3.new(0,0,0)
                        for _, v in pairs(player.Character:GetDescendants()) do
                            if v:IsA("BasePart") then v.CanCollide = false end
                        end
                    end
                end
            end)
        end
    end
end)

Tabs.Main:AddToggle("FarmToggle", {Title = "Ligar Auto Farm", Default = false})
Options.FarmToggle:OnChanged(function() _G.AutoFarm = Options.FarmToggle.Value end)
