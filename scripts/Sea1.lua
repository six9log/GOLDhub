local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()

local Window = Fluent:CreateWindow({
    Title = "GOLD HUB | SEA 1",
    SubTitle = "por six9log",
    TabWidth = 160,
    Size = UDim2.fromOffset(580, 460),
    Acrylic = false,
    Theme = "Dark"
})

local Tabs = { Main = Window:AddTab({ Title = "Farm", Icon = "home" }) }
local Options = Fluent.Options
_G.AutoFarm = false

-- SISTEMA DE ATAQUE POR MAGNITUDE (SEM CLIQUES NO MOUSE)
spawn(function()
    while true do
        task.wait(0.1) -- Delay de 0.1s como pediste
        if _G.AutoFarm then
            pcall(function()
                local player = game.Players.LocalPlayer
                local character = player.Character
                
                -- Verifica se tens uma ferramenta na mão
                local tool = character:FindFirstChildOfClass("Tool")
                if tool then
                    -- Envia o sinal de ataque sem precisar clicar na tela
                    tool:Activate()
                    
                    -- Dano em área (Magnitude)
                    for _, enemy in pairs(workspace.Enemies:GetChildren()) do
                        if enemy:FindFirstChild("Humanoid") and enemy.Humanoid.Health > 0 then
                            local dist = (character.HumanoidRootPart.Position - enemy.HumanoidRootPart.Position).Magnitude
                            if dist < 20 then
                                -- Este comando ajuda o jogo a registar o soco no monstro
                                game:GetService("ReplicatedStorage").Remotes.Validator:FireServer(math.huge)
                            end
                        end
                    end
                end
            end)
        end
    end
end)

-- ANTI-QUEDA E NOCLIP MELHORADO
game:GetService("RunService").Stepped:Connect(function()
    if _G.AutoFarm then
        pcall(function()
            local char = game.Players.LocalPlayer.Character
            if char and char:FindFirstChild("HumanoidRootPart") then
                -- Congela o boneco no ar para não cair nem tremer
                if not char.HumanoidRootPart:FindFirstChild("GoldVelocity") then
                    local bv = Instance.new("BodyVelocity")
                    bv.Name = "GoldVelocity"
                    bv.Velocity = Vector3.new(0,0,0)
                    bv.MaxForce = Vector3.new(9e9, 9e9, 9e9)
                    bv.Parent = char.HumanoidRootPart
                end
                -- Noclip para não bater em nada
                for _, v in pairs(char:GetDescendants()) do
                    if v:IsA("BasePart") then v.CanCollide = false end
                end
            end
        end)
    end
end)

-- LÓGICA DE MOVIMENTO E QUESTS
spawn(function()
    while true do
        task.wait()
        if _G.AutoFarm then
            pcall(function()
                local player = game.Players.LocalPlayer
                local questGui = player.PlayerGui.Main.Quest
                
                if not questGui.Visible then
                    -- Vai buscar a missão
                    player.Character.HumanoidRootPart.CFrame = CFrame.new(1059, 16, 1546)
                    task.wait(0.5)
                    game:GetService("ReplicatedStorage").Remotes.CommF_:InvokeServer("StartQuest", "BanditQuest1", 1)
                else
                    -- Procura o Bandit
                    local Monster = workspace.Enemies:FindFirstChild("Bandit")
                    if Monster and Monster:FindFirstChild("HumanoidRootPart") and Monster.Humanoid.Health > 0 then
                        -- Fica a 6 studs de altura (perfeito para o soco)
                        player.Character.HumanoidRootPart.CFrame = Monster.HumanoidRootPart.CFrame * CFrame.new(0, 6, 0)
                        
                        -- Equipar Arma automaticamente
                        local tool = player.Backpack:FindFirstChildOfClass("Tool") or player.Character:FindFirstChildOfClass("Tool")
                        if tool and not player.Character:FindFirstChild(tool.Name) then
                            player.Character.Humanoid:EquipTool(tool)
                        end
                    else
                        -- Espera os monstros nascerem
                        player.Character.HumanoidRootPart.CFrame = CFrame.new(1145, 20, 1630)
                    end
                end
            end)
        end
    end
end)

Tabs.Main:AddToggle("FarmToggle", {Title = "Ligar Auto Farm", Default = false})
Options.FarmToggle:OnChanged(function() _G.AutoFarm = Options.FarmToggle.Value end)
