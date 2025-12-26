local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()

local Window = Fluent:CreateWindow({
    Title = "GOLD HUB | SEA 1",
    SubTitle = "Versão Estável",
    TabWidth = 160,
    Size = UDim2.fromOffset(580, 460),
    Acrylic = false,
    Theme = "Dark"
})

local Tabs = { Main = Window:AddTab({ Title = "Farm", Icon = "home" }) }
_G.AutoFarm = false

-- 1. SISTEMA DE ATAQUE (SEM CLIQUES, SEM ABRIR INV)
spawn(function()
    while true do
        task.wait(0.1)
        if _G.AutoFarm then
            pcall(function()
                local monster = workspace.Enemies:FindFirstChild("Bandit")
                if monster and monster:FindFirstChild("Humanoid") and monster.Humanoid.Health > 0 then
                    -- Força equipar o Combat
                    local tool = game.Players.LocalPlayer.Backpack:FindFirstChild("Combat") or game.Players.LocalPlayer.Backpack:FindFirstChild("Combate")
                    if tool then
                        game.Players.LocalPlayer.Character.Humanoid:EquipTool(tool)
                    end
                    
                    -- Comando de ataque direto
                    game:GetService("ReplicatedStorage").Remotes.CommF_:InvokeServer("Attack", monster.HumanoidRootPart, true)
                end
            end)
        end
    end
end)

-- 2. MOVIMENTO E TRAVA ANTI-QUEDA (ANCHOR)
game:GetService("RunService").Stepped:Connect(function()
    if _G.AutoFarm then
        pcall(function()
            local char = game.Players.LocalPlayer.Character
            local root = char.HumanoidRootPart
            
            -- Noclip para não bugar
            for _, v in pairs(char:GetDescendants()) do
                if v:IsA("BasePart") then v.CanCollide = false end
            end
            
            -- Procura o alvo
            local monster = workspace.Enemies:FindFirstChild("Bandit")
            local targetPos
            
            if not game.Players.LocalPlayer.PlayerGui.Main.Quest.Visible then
                targetPos = CFrame.new(1059, 16, 1546) -- NPC
            elseif monster and monster:FindFirstChild("HumanoidRootPart") then
                targetPos = monster.HumanoidRootPart.CFrame * CFrame.new(0, 5, 0) -- 5 studs acima do monstro
            else
                targetPos = CFrame.new(1145, 18, 1630) -- Spawn
            end
            
            -- Movimento suave e trava
            if targetPos then
                root.CFrame = targetPos
                root.Velocity = Vector3.new(0,0,0) -- Para o boneco não sair voando
            end
        end)
    end
end)

Tabs.Main:AddToggle("FarmToggle", {
    Title = "Ligar Auto Farm", 
    Default = false,
    Callback = function(Value) 
        _G.AutoFarm = Value 
    end
})
