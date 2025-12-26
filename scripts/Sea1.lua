local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()

local Window = Fluent:CreateWindow({
    Title = "GOLD HUB | SEA 1",
    SubTitle = "Correção de Ataque",
    TabWidth = 160,
    Size = UDim2.fromOffset(580, 460),
    Acrylic = false,
    Theme = "Dark"
})

local Tabs = { Main = Window:AddTab({ Title = "Farm", Icon = "home" }) }
_G.AutoFarm = false

-- 1. SISTEMA DE ATAQUE (SIMULA CLIQUE SEM USAR O MOUSE REAL)
local VirtualUser = game:GetService("VirtualUser")
spawn(function()
    while true do
        task.wait(0.1) -- Delay que pediste
        if _G.AutoFarm then
            pcall(function()
                local player = game.Players.LocalPlayer
                local monster = workspace.Enemies:FindFirstChild("Bandit")
                
                if monster and monster:FindFirstChild("Humanoid") and monster.Humanoid.Health > 0 then
                    -- 1. Garante que o Combat está na mão
                    local tool = player.Backpack:FindFirstChild("Combat") or player.Backpack:FindFirstChild("Combate")
                    if tool and not player.Character:FindFirstChild(tool.Name) then
                        player.Character.Humanoid:EquipTool(tool)
                    end
                    
                    -- 2. Simula o clique de ataque (Isso faz o soco bater de verdade)
                    VirtualUser:CaptureController()
                    VirtualUser:ClickButton1(Vector2.new(50, 50)) -- Clica no "vazio" da tela para não abrir abas
                end
            end)
        end
    end
end)

-- 2. MOVIMENTAÇÃO E ANTI-QUEDA
game:GetService("RunService").Stepped:Connect(function()
    if _G.AutoFarm then
        pcall(function()
            local lp = game.Players.LocalPlayer
            local char = lp.Character
            local root = char.HumanoidRootPart
            
            -- Noclip total
            for _, v in pairs(char:GetDescendants()) do
                if v:IsA("BasePart") then v.CanCollide = false end
            end
            
            -- Lógica de Alvo
            local monster = workspace.Enemies:FindFirstChild("Bandit")
            if not lp.PlayerGui.Main.Quest.Visible then
                -- Vai ao NPC (Teleporte direto para ser rápido)
                root.CFrame = CFrame.new(1059, 16, 1546)
                game:GetService("ReplicatedStorage").Remotes.CommF_:InvokeServer("StartQuest", "BanditQuest1", 1)
            elseif monster and monster:FindFirstChild("HumanoidRootPart") then
                -- Fica EM CIMA do monstro (distância ideal para o soco pegar)
                root.CFrame = monster.HumanoidRootPart.CFrame * CFrame.new(0, 5, 0)
                root.Velocity = Vector3.new(0,0,0)
            else
                -- Espera os monstros nascerem
                root.CFrame = CFrame.new(1145, 18, 1630)
            end
        end)
    end
end)

Tabs.Main:AddToggle("FarmToggle", {
    Title = "Ligar Auto Farm", 
    Default = false,
    Callback = function(Value) _G.AutoFarm = Value end
})
