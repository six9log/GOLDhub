local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()

local Window = Fluent:CreateWindow({
    Title = "GOLD HUB | SEA 1",
    SubTitle = "v1.0 - Estável",
    TabWidth = 160,
    Size = UDim2.fromOffset(580, 460),
    Acrylic = false,
    Theme = "Dark"
})

local Tabs = { Main = Window:AddTab({ Title = "Farm", Icon = "home" }) }
_G.AutoFarm = false

-- FUNÇÃO DE ATAQUE TOTALMENTE AUTOMÁTICO
spawn(function()
    while true do
        task.wait(0.1)
        if _G.AutoFarm then
            pcall(function()
                local monster = workspace.Enemies:FindFirstChild("Bandit")
                if monster and monster:FindFirstChild("Humanoid") and monster.Humanoid.Health > 0 then
                    -- Envia sinal de ataque para o servidor sem animação (evita bugs de aba)
                    game:GetService("ReplicatedStorage").Remotes.CommF_:InvokeServer("Attack", monster.HumanoidRootPart, true)
                end
            end)
        end
    end
end)

-- LÓGICA DE MOVIMENTO RÍGIDO (TRAVA O PERSONAGEM)
game:GetService("RunService").Heartbeat:Connect(function()
    if _G.AutoFarm then
        pcall(function()
            local lp = game.Players.LocalPlayer
            local char = lp.Character
            local root = char.HumanoidRootPart
            
            -- Noclip e trava de queda
            for _, v in pairs(char:GetDescendants()) do
                if v:IsA("BasePart") then v.CanCollide = false end
            end
            root.Velocity = Vector3.new(0,0,0)

            if not lp.PlayerGui.Main.Quest.Visible then
                -- Teleporte instantâneo para o NPC
                root.CFrame = CFrame.new(1059, 16, 1546)
                game:GetService("ReplicatedStorage").Remotes.CommF_:InvokeServer("StartQuest", "BanditQuest1", 1)
            else
                local target = workspace.Enemies:FindFirstChild("Bandit")
                if target and target:FindFirstChild("HumanoidRootPart") then
                    -- Fica colado NA FRENTE do monstro (distância curta de 4 studs)
                    root.CFrame = target.HumanoidRootPart.CFrame * CFrame.new(0, 4, 0)
                else
                    -- Vai para onde os monstros nascem se não houver nenhum
                    root.CFrame = CFrame.new(1145, 18, 1630)
                end
            end
        end)
    end
end)

Tabs.Main:AddToggle("FarmToggle", {Title = "Auto Farm Bandits", Default = false, Callback = function(Value) _G.AutoFarm = Value end})
