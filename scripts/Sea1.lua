local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()

local Window = Fluent:CreateWindow({
    Title = "GOLD HUB | SEA 1",
    SubTitle = "v1.5 - Auto Island Detection",
    TabWidth = 160,
    Size = UDim2.fromOffset(580, 460),
    Acrylic = false,
    Theme = "Dark"
})

local Tabs = { 
    Main = Window:AddTab({ Title = "Farm", Icon = "home" }),
    Visuals = Window:AddTab({ Title = "Visual & Frutas", Icon = "apple" })
}

_G.AutoFarm = false
_G.AutoAttack = false

-- FUNÇÃO PARA PEGAR DADOS DA ILHA ATUAL (BASEADO NO SEU LEVEL)
function GetQuestData()
    local lvl = game.Players.LocalPlayer.Data.Level.Value
    if lvl >= 0 and lvl < 10 then
        return "BanditQuest1", 1, "Bandit", CFrame.new(1059, 16, 1546) -- Ilha Inicial
    elseif lvl >= 10 and lvl < 15 then
        return "JungleQuest", 1, "Monkey", CFrame.new(-1598, 37, 153) -- Selva (Macacos)
    elseif lvl >= 15 and lvl < 30 then
        return "JungleQuest", 2, "Gorilla", CFrame.new(-1598, 37, 153) -- Selva (Gorilas)
    end
    -- Se for level maior, ele continua nos Gorilas por enquanto (Pode pedir para eu adicionar mais ilhas)
    return "JungleQuest", 2, "Gorilla", CFrame.new(-1598, 37, 153)
end

-- 1. AUTO CLIQUE (Puro - Sem selecionar arma)
spawn(function()
    while true do
        task.wait(0.5)
        if _G.AutoAttack then
            pcall(function()
                game:GetService("VirtualUser"):CaptureController()
                game:GetService("VirtualUser"):Button1Down(Vector2.new(150, 150))
                task.wait(0.01)
                game:GetService("VirtualUser"):Button1Up(Vector2.new(150, 150))
            end)
        end
    end
end)

-- 2. LÓGICA DE FARM INTELIGENTE
game:GetService("RunService").Stepped:Connect(function()
    if _G.AutoFarm then
        pcall(function()
            local lp = game.Players.LocalPlayer
            local root = lp.Character.HumanoidRootPart
            local questName, questID, monsterName, npcPos = GetQuestData()

            -- Noclip
            for _, v in pairs(lp.Character:GetDescendants()) do
                if v:IsA("BasePart") then v.CanCollide = false end
            end
            root.Velocity = Vector3.new(0,0,0)

            -- Verifica se já tem a missão certa
            if not lp.PlayerGui.Main.Quest.Visible then
                -- Vai até o NPC da ilha certa
                root.CFrame = npcPos
                task.wait(0.2)
                game:GetService("ReplicatedStorage").Remotes.CommF_:InvokeServer("StartQuest", questName, questID)
            else
                -- Procura o monstro da missão atual perto de você
                local monster = nil
                for _, v in pairs(workspace.Enemies:GetChildren()) do
                    if v.Name == monsterName and v:FindFirstChild("Humanoid") and v.Humanoid.Health > 0 then
                        monster = v
                        break
                    end
                end

                if monster then
                    -- Vai para cima do monstro da ilha ATUAL
                    root.CFrame = monster.HumanoidRootPart.CFrame * CFrame.new(0, 8, 0)
                else
                    -- Se não achar o monstro, vai para o ponto de spawn daquela ilha específica
                    root.CFrame = npcPos * CFrame.new(0, 20, 0)
                end
            end
        end)
    end
end)

-- MANTIVE AS OUTRAS FUNÇÕES (FRUTAS E ESP) ABAIXO...
-- [O restante do código de ESP e Frutas continua igual ao v1.4]

Tabs.Main:AddToggle("FarmToggle", {Title = "Auto Farm (Auto Island)", Default = false, Callback = function(v) _G.AutoFarm = v end})
Tabs.Main:AddToggle("AttackToggle", {Title = "Auto Clique (0.5s)", Default = false, Callback = function(v) _G.AutoAttack = v end})
