local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()

local Window = Fluent:CreateWindow({
    Title = "GOLD HUB | SEA 1",
    SubTitle = "v1.1 - Otimizado",
    TabWidth = 160,
    Size = UDim2.fromOffset(580, 460),
    Acrylic = false,
    Theme = "Dark"
})

local Tabs = { Main = Window:AddTab({ Title = "Farm", Icon = "home" }) }
_G.AutoFarm = false

-- 1. SISTEMA DE AUTO ATAQUE REFATORADO (FAST ATTACK)
spawn(function()
    while true do
        task.wait(0.1) -- Delay controlado para não bugar
        if _G.AutoFarm then
            pcall(function()
                local player = game.Players.LocalPlayer
                local monster = workspace.Enemies:FindFirstChild("Bandit")
                
                if monster and monster:FindFirstChild("Humanoid") and monster.Humanoid.Health > 0 then
                    -- Força Equipar
                    local tool = player.Backpack:FindFirstChild("Combat") or player.Backpack:FindFirstChild("Combate")
                    if tool and not player.Character:FindFirstChild(tool.Name) then
                        player.Character.Humanoid:EquipTool(tool)
                    end
                    
                    -- Ataque Híbrido: Remote + Clique Virtual
                    -- Isso garante que o dano conte mesmo se o servidor estiver lento
                    game:GetService("ReplicatedStorage").Remotes.CommF_:InvokeServer("Attack", monster.HumanoidRootPart, true)
                    game:GetService("VirtualUser"):CaptureController()
                    game:GetService("VirtualUser"):Button1Down(Vector2.new(50, 50))
                end
            end)
        end
    end
end)

-- 2. MOVIMENTAÇÃO RÁPIDA E ALTURA AJUSTADA
game:GetService("RunService").Stepped:Connect(function()
    if _G.AutoFarm then
        pcall(function()
            local lp = game.Players.LocalPlayer
            local root = lp.Character.HumanoidRootPart
            
            -- Noclip
            for _, v in pairs(lp.Character:GetDescendants()) do
                if v:IsA("BasePart") then v.CanCollide = false end
            end
            
            -- Lógica de Alvo Instantânea
            if not lp.PlayerGui.Main.Quest.Visible then
                -- Vai ao NPC
                root.CFrame = CFrame.new(1059, 16, 1546)
                game:GetService("ReplicatedStorage").Remotes.CommF_:InvokeServer("StartQuest", "BanditQuest1", 1)
            else
                local monster = workspace.Enemies:FindFirstChild("Bandit")
                if monster and monster:FindFirstChild("HumanoidRootPart") and monster.Humanoid.Health > 0 then
                    -- ALTURA: Aumentada para 8 studs (mais acima como pedido)
                    -- POSIÇÃO: Teleporte instantâneo para o próximo monstro assim que o atual morre
                    root.CFrame = monster.HumanoidRootPart.CFrame * CFrame.new(0, 8, 0)
                    root.Velocity = Vector3.new(0,0,0)
                else
                    -- Se o monstro morrer, o script pula para este ponto de espera IMEDIATAMENTE
                    root.CFrame = CFrame.new(1145, 22, 1630)
                end
            end
        end)
    end
end)

Tabs.Main:AddToggle("FarmToggle", {
    Title = "Ligar Auto Farm v1.1", 
    Default = false,
    Callback = function(Value) _G.AutoFarm = Value end
})
