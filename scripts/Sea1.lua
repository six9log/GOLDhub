local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()

local Window = Fluent:CreateWindow({
    Title = "GOLD HUB | SEA 1 (ULTRA STABLE)",
    SubTitle = "por six9log",
    TabWidth = 160,
    Size = UDim2.fromOffset(580, 460),
    Acrylic = false,
    Theme = "Dark"
})

local Tabs = { Main = Window:AddTab({ Title = "Farm", Icon = "home" }) }
local Options = Fluent.Options
_G.AutoFarm = false

-- SISTEMA ANTI-QUEDA DEFINITIVO
spawn(function()
    game:GetService("RunService").Stepped:Connect(function()
        if _G.AutoFarm then
            pcall(function()
                local char = game.Players.LocalPlayer.Character
                if char and char:FindFirstChild("HumanoidRootPart") then
                    -- Isso impede que você caia ou seja empurrado
                    if not char.HumanoidRootPart:FindFirstChild("VelocityHandler") then
                        local bv = Instance.new("BodyVelocity")
                        bv.Name = "VelocityHandler"
                        bv.Velocity = Vector3.new(0,0,0)
                        bv.MaxForce = Vector3.new(9e9, 9e9, 9e9)
                        bv.Parent = char.HumanoidRootPart
                    end
                    -- Noclip: Atravessa tudo para não bugar
                    for _, v in pairs(char:GetDescendants()) do
                        if v:IsA("BasePart") then v.CanCollide = false end
                    end
                end
            end)
        end
    end)
end)

-- LÓGICA DE FARM E ATAQUE
spawn(function()
    while true do
        task.wait()
        if _G.AutoFarm then
            pcall(function()
                local player = game.Players.LocalPlayer
                local questGui = player.PlayerGui.Main.Quest
                
                -- Se não tem missão, voa pro NPC
                if not questGui.Visible then
                    player.Character.HumanoidRootPart.CFrame = CFrame.new(1059, 16, 1546)
                    task.wait(0.5)
                    game:GetService("ReplicatedStorage").Remotes.CommF_:InvokeServer("StartQuest", "BanditQuest1", 1)
                else
                    -- Procura o Monstro Bandit
                    local Monster = game:GetService("Workspace").Enemies:FindFirstChild("Bandit")
                    if Monster and Monster:FindFirstChild("HumanoidRootPart") and Monster.Humanoid.Health > 0 then
                        -- Fica PARADO exatamente 10 blocos acima do monstro
                        player.Character.HumanoidRootPart.CFrame = Monster.HumanoidRootPart.CFrame * CFrame.new(0, 10, 0)
                        
                        -- Equipar Arma
                        local tool = player.Backpack:FindFirstChildOfClass("Tool") or player.Character:FindFirstChildOfClass("Tool")
                        if tool then player.Character.Humanoid:EquipTool(tool) end
                        
                        -- ATAQUE ULTRA RÁPIDO (PC)
                        game:GetService("VirtualUser"):Button1Down(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
                    else
                        -- Se o monstro morreu, espera no spawn dele
                        player.Character.HumanoidRootPart.CFrame = CFrame.new(1145, 25, 1630)
                    end
                end
            end)
        end
    end
end)

Tabs.Main:AddToggle("FarmToggle", {Title = "Ligar Auto Farm", Default = false})
Options.FarmToggle:OnChanged(function() _G.AutoFarm = Options.FarmToggle.Value end)
