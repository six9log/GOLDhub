local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()

local Window = Fluent:CreateWindow({
    Title = "GOLD HUB | SEA 1",
    SubTitle = "v1.8 - Real Smooth Flight",
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
_G.FruitESP = false
_G.PlayerESP = false
_G.AutoCollectFruit = false
_G.AutoStoreFruit = false

local CurrentTween = nil

-- FUNÇÃO DE VOO REAL (PARA ONDE ESTIVER AO DESLIGAR)
function SmoothMove(TargetCFrame)
    local Character = game.Players.LocalPlayer.Character
    local Root = Character:FindFirstChild("HumanoidRootPart")
    
    if Root and _G.AutoFarm then
        local Distance = (TargetCFrame.Position - Root.Position).Magnitude
        local Speed = 250 -- Velocidade de voo estável
        
        -- Cancela o voo anterior se existir para não dar "chicote"
        if CurrentTween then CurrentTween:Cancel() end
        
        CurrentTween = game:GetService("TweenService"):Create(Root, TweenInfo.new(Distance/Speed, Enum.EasingStyle.Linear), {CFrame = TargetCFrame})
        CurrentTween:Play()
    elseif CurrentTween and not _G.AutoFarm then
        CurrentTween:Cancel() -- Para o boneco na hora se desligar o farm
    end
end

-- 1. AUTO CLIQUE (PURO - VOCÊ SELECIONA A ARMA)
spawn(function()
    while task.wait(0.15) do
        if _G.AutoAttack then
            pcall(function()
                local player = game.Players.LocalPlayer
                local char = player.Character
                if not char then return end

                -- Procura ferramenta equipada
                local tool = char:FindFirstChildOfClass("Tool")
                if tool then
                    tool:Activate()
                end
            end)
        end
    end
end)


-- 2. LÓGICA DE FARM COM VOO (SEM TP)
spawn(function()
    while task.wait(0.1) do
        if _G.AutoFarm then
            pcall(function()
                local lp = game.Players.LocalPlayer
                local lvl = lp.Data.Level.Value
                local char = lp.Character
                
                -- Noclip para atravessar as nuvens e ilhas voando
                for _, v in pairs(char:GetDescendants()) do
                    if v:IsA("BasePart") then v.CanCollide = false end
                end
                char.HumanoidRootPart.Velocity = Vector3.new(0,0,0)

                if not lp.PlayerGui.Main.Quest.Visible then
                    -- VOO ATÉ O NPC (DETERMINA ILHA PELO LEVEL)
                    local targetPos = CFrame.new(1059, 16, 1546) -- Default: Bandit
                    local qName, qID = "BanditQuest1", 1
                    
                    if lvl >= 15 then 
                        targetPos = CFrame.new(-1598, 37, 153) -- Jungle
                        qName, qID = "JungleQuest", 2
                    end
                    -- Adicionar mais ilhas aqui conforme subir de level
                    
                    SmoothMove(targetPos)
                    if (char.HumanoidRootPart.Position - targetPos.Position).Magnitude < 10 then
                        game:GetService("ReplicatedStorage").Remotes.CommF_:InvokeServer("StartQuest", qName, qID)
                    end
                else
                    -- PROCURA O MONSTRO DA MISSÃO
                    local monsterName = (lvl >= 15) and "Gorilla" or "Bandit"
                    local target = nil
                    for _, v in pairs(workspace.Enemies:GetChildren()) do
                        if v.Name == monsterName and v:FindFirstChild("Humanoid") and v.Humanoid.Health > 0 then
                            target = v
                            break
                        end
                    end
                    
                    if target then
                        -- VOA ATÉ O MONSTRO E FICA EM CIMA
                        SmoothMove(target.HumanoidRootPart.CFrame * CFrame.new(0, 8, 0))
                    end
                end
            end)
        else
            -- Se desligar, para o movimento
            if CurrentTween then CurrentTween:Cancel() end
        end
    end
end)

-- 3. ABA VISUAL & FRUTAS (TOTALMENTE SEPARADO)
-- Aqui ficam os códigos de ESP Frutas, ESP Jogadores e Auto Collect que já fizemos.
-- Eles usam a mesma lógica de SmoothMove para as frutas.

-- INTERFACE
Tabs.Main:AddToggle("FarmToggle", {
    Title = "Auto Farm (Modo Voo)", 
    Default = false, 
    Callback = function(v) 
        _G.AutoFarm = v 
        if not v and CurrentTween then CurrentTween:Cancel() end
    end
})

Tabs.Main:AddToggle("AttackToggle", {Title = "Auto Clique (0.5s)", Default = false, Callback = function(v) _G.AutoAttack = v end})

Tabs.Visuals:AddSection("Sistema de ESP")
Tabs.Visuals:AddToggle("FruitESPToggle", {Title = "ESP de Frutas", Default = false, Callback = function(v) _G.FruitESP = v end})
Tabs.Visuals:AddToggle("PlayerESPToggle", {Title = "ESP de Jogadores", Default = false, Callback = function(v) _G.PlayerESP = v end})

Tabs.Visuals:AddSection("Opções de Fruta")
Tabs.Visuals:AddToggle("CollectToggle", {Title = "Auto Coletar (Voando)", Default = false, Callback = function(v) _G.AutoCollectFruit = v end})
Tabs.Visuals:AddToggle("StoreToggle", {Title = "Auto Armazenar", Default = false, Callback = function(v) _G.AutoStoreFruit = v end})
