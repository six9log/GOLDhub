local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()

local Window = Fluent:CreateWindow({
    Title = "GOLD HUB | SEA 1",
    SubTitle = "Refatorado",
    TabWidth = 160,
    Size = UDim2.fromOffset(580, 460),
    Acrylic = false,
    Theme = "Dark"
})

local Tabs = { Main = Window:AddTab({ Title = "Farm", Icon = "home" }) }
local Options = Fluent.Options
_G.AutoFarm = false

-- 1. FUNÇÃO DE ATAQUE REFATORADA (SEM CLIQUE NA TELA)
local function ExecuteAttack(target)
    pcall(function()
        local player = game.Players.LocalPlayer
        -- Procura o Soco (Combat) ou qualquer ferramenta
        local tool = player.Character:FindFirstChildOfClass("Tool") or player.Backpack:FindFirstChild("Combat") or player.Backpack:FindFirstChild("Combate")
        
        if tool then
            -- Garante que está na mão
            if tool.Parent == player.Backpack then
                player.Character.Humanoid:EquipTool(tool)
            end
            -- Ataque direto via Remote (Não abre inventário)
            game:GetService("ReplicatedStorage").Remotes.CommF_:InvokeServer("Attack", target.HumanoidRootPart, true)
        end
    end)
end

-- 2. MOVIMENTAÇÃO SUAVE (ANTI-BAN)
function SmoothMove(targetCFrame)
    local root = game.Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if root then
        local distance = (targetCFrame.Position - root.Position).Magnitude
        local tween = game:GetService("TweenService"):Create(root, TweenInfo.new(distance/250, Enum.EasingStyle.Linear), {CFrame = targetCFrame})
        tween:Play()
    end
end

-- 3. LOOP PRINCIPAL DE FARM
spawn(function()
    while true do
        task.wait(0.1) -- Seu delay de 0.1s
        if _G.AutoFarm then
            pcall(function()
                local player = game.Players.LocalPlayer
                
                -- Checagem de Missão
                if not player.PlayerGui.Main.Quest.Visible then
                    SmoothMove(CFrame.new(1059, 16, 1546))
                    task.wait(0.5)
                    game:GetService("ReplicatedStorage").Remotes.CommF_:InvokeServer("StartQuest", "BanditQuest1", 1)
                else
                    -- Localiza o Bandit
                    local monster = workspace.Enemies:FindFirstChild("Bandit")
                    if monster and monster:FindFirstChild("Humanoid") and monster.Humanoid.Health > 0 then
                        -- Posiciona suavemente 6 studs acima
                        SmoothMove(monster.HumanoidRootPart.CFrame * CFrame.new(0, 6, 0))
                        -- Chama a nova função de bater
                        ExecuteAttack(monster)
                    else
                        -- Espera no spawn
                        SmoothMove(CFrame.new(1145, 20, 1630))
                    end
                end
            end)
        end
    end
end)

-- 4. NOCLIP CONSTANTE
game:GetService("RunService").Stepped:Connect(function()
    if _G.AutoFarm then
        pcall(function()
            for _, v in pairs(game.Players.LocalPlayer.Character:GetDescendants()) do
                if v:IsA("BasePart") then v.CanCollide = false end
            end
        end)
    end
end)

Tabs.Main:AddToggle("FarmToggle", {Title = "Ligar Auto Farm", Default = false})
Options.FarmToggle:OnChanged(function() _G.AutoFarm = Options.FarmToggle.Value end)
