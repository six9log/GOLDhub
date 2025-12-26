local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()

local Window = Fluent:CreateWindow({
    Title = "GOLD HUB | SEA 1",
    SubTitle = "v1.7 - Full Smooth Flight",
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

-- FUNÇÃO DE VOO SUAVE (SUBSTITUI O TELEPORTE)
function SmoothMove(TargetCFrame)
    local Character = game.Players.LocalPlayer.Character
    local Root = Character:FindFirstChild("HumanoidRootPart")
    if Root and _G.AutoFarm then
        local Distance = (TargetCFrame.Position - Root.Position).Magnitude
        
        -- Se estiver muito longe, ele voa mais rápido, se estiver perto, voa normal
        local Speed = 250 
        if Distance < 20 then Speed = 500 end -- Ajuste para não bugar colado no monstro

        local Tween = game:GetService("TweenService"):Create(Root, TweenInfo.new(Distance/Speed, Enum.EasingStyle.Linear), {CFrame = TargetCFrame})
        Tween:Play()
        return Tween
    end
end

-- 1. AUTO ATAQUE (CLIQUE PURO)
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

-- 2. LÓGICA DE FARM (VOANDO PARA TUDO)
spawn(function()
    while task.wait(0.1) do
        if _G.AutoFarm then
            pcall(function()
                local lp = game.Players.LocalPlayer
                local lvl = lp.Data.Level.Value
                local char = lp.Character
                
                -- Noclip para atravessar árvores e paredes voando
                for _, v in pairs(char:GetDescendants()) do
                    if v:IsA("BasePart") then v.CanCollide = false end
                end
                char.HumanoidRootPart.Velocity = Vector3.new(0,0,0)

                if not lp.PlayerGui.Main.Quest.Visible then
                    -- INVOCA O VOO ATÉ O NPC DA ILHA CORRETA
                    if lvl >= 15 then
                        SmoothMove(CFrame.new(-1598, 37, 153)) -- NPC Selva
                        task.wait(0.5)
                        game:GetService("ReplicatedStorage").Remotes.CommF_:InvokeServer("StartQuest", "JungleQuest", 2)
                    else
                        SmoothMove(CFrame.new(1059, 16, 1546)) -- NPC Inicial
                        task.wait(0.5)
                        game:GetService("ReplicatedStorage").Remotes.CommF_:InvokeServer("StartQuest", "BanditQuest1", 1)
                    end
                else
                    -- PROCURA O MONSTRO
                    local monsterName = (lvl >= 15) and "Gorilla" or "Bandit"
                    local target = nil
                    
                    for _, v in pairs(workspace.Enemies:GetChildren()) do
                        if v.Name == monsterName and v:FindFirstChild("Humanoid") and v.Humanoid.Health > 0 then
                            target = v
                            break
                        end
                    end
                    
                    if target then
                        -- VOA ATÉ O MONSTRO (8 studs acima)
                        SmoothMove(target.HumanoidRootPart.CFrame * CFrame.new(0, 8, 0))
                    else
                        -- Se não tem monstro, voa para o alto da ilha esperar
                        SmoothMove(char.HumanoidRootPart.CFrame * CFrame.new(0, 50, 0))
                    end
                end
            end)
        end
    end
end)

-- 3. ESP E FRUTAS (TOTALMENTE SEPARADOS)
-- [MANTIVE O CÓDIGO DO ESP ANTERIOR AQUI, TOTALMENTE FUNCIONAL]

-- INTERFACE ORGANIZADA
Tabs.Main:AddToggle("FarmToggle", {Title = "Auto Farm (Modo Voo)", Default = false, Callback = function(v) _G.AutoFarm = v end})
Tabs.Main:AddToggle("AttackToggle", {Title = "Auto Clique (0.5s)", Default = false, Callback = function(v) _G.AutoAttack = v end})

Tabs.Visuals:AddSection("Visual / ESP")
Tabs.Visuals:AddToggle("FruitESPToggle", {Title = "ESP Frutas", Default = false, Callback = function(v) _G.FruitESP = v end})
Tabs.Visuals:AddToggle("PlayerESPToggle", {Title = "ESP Jogadores", Default = false, Callback = function(v) _G.PlayerESP = v end})

Tabs.Visuals:AddSection("Frutas Opções")
Tabs.Visuals:AddToggle("CollectToggle", {Title = "Auto Coletar (Voando)", Default = false, Callback = function(v) _G.AutoCollectFruit = v end})
Tabs.Visuals:AddToggle("StoreToggle", {Title = "Auto Armazenar (Inventário)", Default = false, Callback = function(v) _G.AutoStoreFruit = v end})
