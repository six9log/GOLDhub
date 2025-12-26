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

-- NOVO SISTEMA DE ATAQUE (SEM CLIQUES NA TELA)
local function Kill()
    pcall(function()
        local player = game.Players.LocalPlayer
        local character = player.Character
        -- Tenta ativar a ferramenta que está na mão
        local tool = character:FindFirstChildOfClass("Tool")
        if tool then
            tool:Activate()
        end
    end)
end

-- ANTI-QUEDA E NOCLIP (PARA NÃO FICAR TRAVADO)
game:GetService("RunService").Stepped:Connect(function()
    if _G.AutoFarm then
        pcall(function()
            local char = game.Players.LocalPlayer.Character
            if char and char:FindFirstChild("HumanoidRootPart") then
                if not char.HumanoidRootPart:FindFirstChild("GoldVelocity") then
                    local bv = Instance.new("BodyVelocity")
                    bv.Name = "GoldVelocity"
                    bv.Velocity = Vector3.new(0,0,0)
                    bv.MaxForce = Vector3.new(9e9, 9e9, 9e9)
                    bv.Parent = char.HumanoidRootPart
                end
                for _, v in pairs(char:GetDescendants()) do
                    if v:IsA("BasePart") then v.CanCollide = false end
                end
            end
        end)
    end
end)

-- LÓGICA DE FARM MELHORADA
spawn(function()
    while true do
        task.wait()
        if _G.AutoFarm then
            pcall(function()
                local player = game.Players.LocalPlayer
                local questGui = player.PlayerGui.Main.Quest
                
                if not questGui.Visible then
                    -- Vai para o NPC da Missão
                    player.Character.HumanoidRootPart.CFrame = CFrame.new(1059, 16, 1546)
                    task.wait(0.5)
                    game:GetService("ReplicatedStorage").Remotes.CommF_:InvokeServer("StartQuest", "BanditQuest1", 1)
                else
                    -- Procura o Bandit
                    local Monster = game:GetService("Workspace").Enemies:FindFirstChild("Bandit")
                    if Monster and Monster:FindFirstChild("HumanoidRootPart") and Monster.Humanoid.Health > 0 then
                        -- Fica mais próximo (6 studs) para o combate alcançar
                        player.Character.HumanoidRootPart.CFrame = Monster.HumanoidRootPart.CFrame * CFrame.new(0, 6, 0)
                        
                        -- Equipar Combate
                        local tool = player.Backpack:FindFirstChild("Combate") or player.Backpack:FindFirstChild("Combat") or player.Character:FindFirstChildOfClass("Tool")
                        if tool and not player.Character:FindFirstChild(tool.Name) then
                            player.Character.Humanoid:EquipTool(tool)
                        end
                        
                        -- Atacar
                        Kill()
                    else
                        -- Se o Bandit morreu, espera no ponto de spawn
                        player.Character.HumanoidRootPart.CFrame = CFrame.new(1145, 20, 1630)
                    end
                end
            end)
        end
    end
end)

Tabs.Main:AddToggle("FarmToggle", {Title = "Ligar Auto Farm", Default = false})
Options.FarmToggle:OnChanged(function() _G.AutoFarm = Options.FarmToggle.Value end)
