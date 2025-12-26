local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()

local Window = Fluent:CreateWindow({
    Title = "GOLD HUB | SEA 1",
    SubTitle = "Simples e Rápido",
    TabWidth = 160,
    Size = UDim2.fromOffset(580, 460),
    Acrylic = false,
    Theme = "Dark"
})

local Tabs = { Main = Window:AddTab({ Title = "Farm", Icon = "home" }) }
_G.AutoFarm = false
_G.AutoClick = false

-- 1. FUNÇÃO DE AUTO CLIQUE (BOTÃO SEPARADO)
spawn(function()
    while true do
        task.wait(0.1) -- Delay de 0.1s como você pediu
        if _G.AutoClick then
            pcall(function()
                local player = game.Players.LocalPlayer
                -- Verifica se tem arma na mão
                if player.Character:FindFirstChildOfClass("Tool") then
                    game:GetService("VirtualUser"):CaptureController()
                    game:GetService("VirtualUser"):Button1Down(Vector2.new(100, 100))
                end
            end)
        end
    end
end)

-- 2. LÓGICA DE FARM E TRANSIÇÃO INSTANTÂNEA
game:GetService("RunService").Stepped:Connect(function()
    if _G.AutoFarm then
        pcall(function()
            local lp = game.Players.LocalPlayer
            local root = lp.Character.HumanoidRootPart
            
            -- Noclip
            for _, v in pairs(lp.Character:GetDescendants()) do
                if v:IsA("BasePart") then v.CanCollide = false end
            end

            if not lp.PlayerGui.Main.Quest.Visible then
                -- Vai ao NPC buscar missão
                root.CFrame = CFrame.new(1059, 16, 1546)
                game:GetService("ReplicatedStorage").Remotes.CommF_:InvokeServer("StartQuest", "BanditQuest1", 1)
            else
                -- Procura o monstro vivo mais próximo
                local monster = workspace.Enemies:FindFirstChild("Bandit")
                if monster and monster:FindFirstChild("Humanoid") and monster.Humanoid.Health > 0 then
                    -- Teleporte instantâneo para cima do monstro
                    root.CFrame = monster.HumanoidRootPart.CFrame * CFrame.new(0, 8, 0)
                    root.Velocity = Vector3.new(0,0,0)
                    
                    -- Ataque via servidor (complementar ao auto click)
                    game:GetService("ReplicatedStorage").Remotes.CommF_:InvokeServer("Attack", monster.HumanoidRootPart, true)
                else
                    -- Se o monstro morreu, vai para o spawn sem delay
                    root.CFrame = CFrame.new(1145, 20, 1630)
                end
            end
        end)
    end
end)

-- 3. INTERFACE SIMPLIFICADA
Tabs.Main:AddToggle("FarmToggle", {
    Title = "Ligar Auto Farm", 
    Default = false,
    Callback = function(Value) _G.AutoFarm = Value end
})

Tabs.Main:AddToggle("ClickToggle", {
    Title = "Auto Clique (Atacar)", 
    Default = false,
    Callback = function(Value) _G.AutoClick = Value end
})
