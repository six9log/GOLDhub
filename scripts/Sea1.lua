local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
local VIM = game:GetService("VirtualInputManager") -- Serviço mais preciso para cliques

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

-- FUNÇÃO DE CLIQUE COM VIRTUAL INPUT MANAGER (0.1s delay)
spawn(function()
    while true do
        task.wait(0.1)
        if _G.AutoFarm then
            pcall(function()
                local char = game.Players.LocalPlayer.Character
                if char and char:FindFirstChildOfClass("Tool") then
                    -- Pega o centro da tela
                    local x = workspace.CurrentCamera.ViewportSize.X / 2
                    local y = workspace.CurrentCamera.ViewportSize.Y / 2
                    
                    -- Simula o clique do mouse (MB1) no centro
                    VIM:SendMouseButtonEvent(x, y, 0, true, game, 0) -- Botão pressionado
                    task.wait(0.01)
                    VIM:SendMouseButtonEvent(x, y, 0, false, game, 0) -- Botão solto
                end
            end)
        end
    end
end)

-- SISTEMA ANTI-QUEDA E NOCLIP (MANTIDO)
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

-- LÓGICA DE MOVIMENTAÇÃO E QUEST
spawn(function()
    while true do
        task.wait()
        if _G.AutoFarm then
            pcall(function()
                local player = game.Players.LocalPlayer
                local questGui = player.PlayerGui.Main.Quest
                
                if not questGui.Visible then
                    player.Character.HumanoidRootPart.CFrame = CFrame.new(1059, 16, 1546)
                    task.wait(0.5)
                    game:GetService("ReplicatedStorage").Remotes.CommF_:InvokeServer("StartQuest", "BanditQuest1", 1)
                else
                    local Monster = game:GetService("Workspace").Enemies:FindFirstChild("Bandit")
                    if Monster and Monster:FindFirstChild("HumanoidRootPart") and Monster.Humanoid.Health > 0 then
                        -- Fica a 7 studs de altura
                        player.Character.HumanoidRootPart.CFrame = Monster.HumanoidRootPart.CFrame * CFrame.new(0, 7, 0)
                        
                        -- Equipar Arma
                        local tool = player.Backpack:FindFirstChildOfClass("Tool") or player.Character:FindFirstChildOfClass("Tool")
                        if tool then player.Character.Humanoid:EquipTool(tool) end
                    else
                        -- Espera no spawn dos monstros
                        player.Character.HumanoidRootPart.CFrame = CFrame.new(1145, 20, 1630)
                    end
                end
            end)
        end
    end
end)

Tabs.Main:AddToggle("FarmToggle", {Title = "Ligar Auto Farm", Default = false})
Options.FarmToggle:OnChanged(function() _G.AutoFarm = Options.FarmToggle.Value end)
