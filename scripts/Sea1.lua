local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()

local Window = Fluent:CreateWindow({
    Title = "GOLD HUB | ZENITH ULTIMATE v6.0",
    SubTitle = "Tudo-em-Um (Sea 1 Edition)",
    TabWidth = 160,
    Size = UDim2.fromOffset(580, 460),
    Acrylic = false,
    Theme = "Dark",
    MinimizeKey = Enum.KeyCode.Home
})

local Tabs = { 
    Main = Window:AddTab({ Title = "Farm & Stats", Icon = "home" }),
    Combat = Window:AddTab({ Title = "Combat & PvP", Icon = "swords" }),
    Boss = Window:AddTab({ Title = "Auto Boss", Icon = "skull" }),
    Puzzles = Window:AddTab({ Title = "Quests & Hakis", Icon = "star" }),
    Fruit = Window:AddTab({ Title = "Frutas & Gacha", Icon = "apple" })
}

-- CONFIGURAÇÕES GLOBAIS
_G.AutoFarm = false
_G.AutoAttack = false
_G.AutoStats = false
_G.StatSelect = "Melee"
_G.TargetBoss = ""
_G.AutoBoss = false
_G.TargetPlayer = ""
_G.TPPlayer = false
_G.Aimlock = false
_G.FruitESP = false
_G.AutoCollectPull = false
_G.AutoCollectTween = false
_G.AutoStoreFruit = false

local CurrentTween = nil

-- FUNÇÃO DE MOVIMENTAÇÃO (TWEEN)
function SmoothMove(TargetCFrame, SpeedOverride)
    local Character = game.Players.LocalPlayer.Character
    local Root = Character and Character:FindFirstChild("HumanoidRootPart")
    if Root then
        local Distance = (TargetCFrame.Position - Root.Position).Magnitude
        local Speed = SpeedOverride or 220 
        if CurrentTween then CurrentTween:Cancel() end
        CurrentTween = game:GetService("TweenService"):Create(Root, TweenInfo.new(Distance/Speed, Enum.EasingStyle.Linear), {CFrame = TargetCFrame})
        CurrentTween:Play()
    end
end

-- 1. AUTO STATS (DISTRIBUIÇÃO AUTOMÁTICA)
spawn(function()
    while task.wait(0.5) do
        if _G.AutoStats then
            local points = game.Players.LocalPlayer.Data.Points.Value
            if points > 0 then
                game:GetService("ReplicatedStorage").Remotes.CommF_:InvokeServer("AddStats", _G.StatSelect, points)
            end
        end
    end
end)

-- 2. AUTO FARM INTELIGENTE (SEA 1 COMPLETO)
local function GetQuestData()
    local level = game.Players.LocalPlayer.Data.Level.Value
    if level < 10 then return "BanditQuest1", 1, "Bandit", CFrame.new(1059,16,1546), CFrame.new(1145,25,1630)
    elseif level < 15 then return "JungleQuest", 1, "Monkey", CFrame.new(-1598,37,153), CFrame.new(-1612,36,147)
    elseif level < 30 then return "JungleQuest", 2, "Gorilla", CFrame.new(-1598,37,153), CFrame.new(-1240,15,497)
    elseif level < 60 then return "BuggyQuest1", (level < 40 and 1 or 2), (level < 40 and "Pirate" or "Brute"), CFrame.new(-1141,4,3828), CFrame.new(-1141,15,3828)
    elseif level < 90 then return "DesertQuest", (level < 75 and 1 or 2), (level < 75 and "Desert Bandit" or "Desert Officer"), CFrame.new(896,28,4391), CFrame.new(1000,28,4400)
    elseif level < 120 then return "SnowQuest", (level < 105 and 1 or 2), (level < 105 and "Snow Bandit" or "Snowman"), CFrame.new(1385,15,-1310), CFrame.new(1300,15,-1300)
    elseif level < 150 then return "MarineQuest2", 1, "Chief Petty Officer", CFrame.new(-4855,22,4330), CFrame.new(-4800,22,4400)
    elseif level < 190 then return "SkyQuest", (level < 175 and 1 or 2), (level < 175 and "Sky Bandit" or "Dark Wizard"), CFrame.new(-1240,358,15), CFrame.new(-1240,360,150)
    elseif level < 250 then return "PrisonQuest", (level < 210 and 1 or 2), (level < 210 and "Prisoner" or "Dangerous Prisoner"), CFrame.new(5307,1,475), CFrame.new(5400,1,500)
    elseif level < 350 then return "MagmaQuest", (level < 300 and 1 or 2), (level < 300 and "Military Soldier" or "Military Spy"), CFrame.new(-5315,12,8517), CFrame.new(-5300,20,8600)
    else return "FishmanQuest", 1, "Fishman Warrior", CFrame.new(61122,18,1565), CFrame.new(61000,18,1500) end
end

-- 3. SISTEMA DE COMBATE & PVP
local function GetPlayers()
    local p = {}
    for _, v in pairs(game.Players:GetPlayers()) do
        if v.Name ~= game.Players.LocalPlayer.Name then table.insert(p, v.Name) end
    end
    return p
end

local PlayerDrop = Tabs.Combat:AddDropdown("PlayerDrop", {Title = "Selecionar Alvo PvP", Values = GetPlayers(), Default = "", Callback = function(v) _G.TargetPlayer = v end})
Tabs.Combat:AddButton({Title = "Atualizar Jogadores", Callback = function() PlayerDrop:SetValues(GetPlayers()) end})
Tabs.Combat:AddToggle("TPPlayer", {Title = "TP no Jogador (Caçar)", Default = false, Callback = function(v) _G.TPPlayer = v end})
Tabs.Combat:AddToggle("Aimlock", {Title = "Aimlock (Aimbot)", Default = false, Callback = function(v) _G.Aimlock = v end})

-- 4. AUTO BOSS (LISTA COMPLETA SEA 1)
local BossList = {"Greybeard [Lv. 750]", "Saber Expert [Lv. 200]", "The Saw [Lv. 100]", "Vice Admiral", "Magma Admiral", "Fishman Lord", "Warden", "Chief Warden", "Swan"}
Tabs.Boss:AddDropdown("BossDrop", {Title = "Escolher Boss", Values = BossList, Default = "", Callback = function(v) _G.TargetBoss = v end})
Tabs.Boss:AddToggle("ABoss", {Title = "Iniciar Auto Boss", Default = false, Callback = function(v) _G.AutoBoss = v end})

-- 5. PUZZLES & HAKIS
Tabs.Puzzles:AddSection("Shanks (Saber Quest)")
Tabs.Puzzles:AddButton({Title = "Ativar 5 Botões (Selva)", Callback = function()
    local b = {CFrame.new(-1613,35,149), CFrame.new(-1540,36,210), CFrame.new(-1533,40,31), CFrame.new(-1371,35,33), CFrame.new(-1381,36,178)}
    for _, p in pairs(b) do SmoothMove(p) task.wait(1.5) end
end})
Tabs.Puzzles:AddButton({Title = "Ir Sala do Shanks", Callback = function() SmoothMove(CFrame.new(-1406, 30, -2)) end})
Tabs.Puzzles:AddSection("Hakis Remotos")
Tabs.Puzzles:AddButton({Title = "Comprar Todos Hakis", Callback = function()
    local r = game:GetService("ReplicatedStorage").Remotes.CommF_
    r:InvokeServer("BuyHaki", "Buso"); r:InvokeServer("BuyHaki", "SkyJump"); r:InvokeServer("BuyHaki", "Soru"); r:InvokeServer("BuyHaki", "Observation")
end})

-- 6. FRUTAS & ESP
Tabs.Fruit:AddButton({Title = "Girar Fruta (Remoto)", Callback = function() game:GetService("ReplicatedStorage").Remotes.CommF_:InvokeServer("Cousin","Buy") end})
Tabs.Fruit:AddToggle("FESP", {Title = "ESP Frutas + Distância", Default = false, Callback = function(v) _G.FruitESP = v end})
Tabs.Fruit:AddToggle("CTween", {Title = "Coletar Voando (Tween)", Default = false, Callback = function(v) _G.AutoCollectTween = v end})
Tabs.Fruit:AddToggle("CPull", {Title = "❗ Puxar Fruta (Agressivo)", Default = false, Callback = function(v) _G.AutoCollectPull = v end})

-- 7. LOOPS DE EXECUÇÃO
spawn(function()
    while task.wait(0.1) do
        -- AUTO FARM & ATAQUE
        if _G.AutoFarm then
            pcall(function()
                local qN, qI, mN, qP, fP = GetQuestData()
                local lp = game.Players.LocalPlayer
                if not lp.PlayerGui.Main.Quest.Visible then
                    SmoothMove(qP * CFrame.new(0, 10, 0))
                    if (lp.Character.HumanoidRootPart.Position - qP.Position).Magnitude < 15 then
                        game:GetService("ReplicatedStorage").Remotes.CommF_:InvokeServer("StartQuest", qN, qI)
                    end
                else
                    local target = workspace.Enemies:FindFirstChild(mN) or workspace.Enemies:FindFirstChild(mN.." [Lv. "..lp.Data.Level.Value.."]")
                    if target and target:FindFirstChild("Humanoid") and target.Humanoid.Health > 0 then
                        SmoothMove(target.HumanoidRootPart.CFrame * CFrame.new(0, 10, 0))
                    else
                        SmoothMove(fP * CFrame.new(0, 20, 0))
                    end
                end
            end)
        end
        
        if _G.AutoAttack then
            local char = game.Players.LocalPlayer.Character
            local tool = char and (char:FindFirstChildOfClass("Tool") or game.Players.LocalPlayer.Backpack:FindFirstChildOfClass("Tool"))
            if tool then
                if not char:FindFirstChild(tool.Name) then char.Humanoid:EquipTool(tool) end
                tool:Activate()
            end
        end

        -- AUTO BOSS
        if _G.AutoBoss and _G.TargetBoss ~= "" then
            local boss = workspace.Enemies:FindFirstChild(_G.TargetBoss)
            if boss then SmoothMove(boss.HumanoidRootPart.CFrame * CFrame.new(0, 12, 0)) end
        end

        -- PVP TP
        if _G.TPPlayer and _G.TargetPlayer ~= "" then
            local targetChar = game.Players[_G.TargetPlayer].Character
            if targetChar then SmoothMove(targetChar.HumanoidRootPart.CFrame * CFrame.new(0, 5, 0), 400) end
        end
    end
end)

-- AIMLOCK CÂMERA
game:GetService("RunService").RenderStepped:Connect(function()
    if _G.Aimlock and _G.TargetPlayer ~= "" then
        pcall(function()
            local targetChar = game.Players[_G.TargetPlayer].Character
            if targetChar then
                local cam = workspace.CurrentCamera
                cam.CFrame = CFrame.new(cam.CFrame.Position, targetChar.HumanoidRootPart.Position)
            end
        end)
    end
end)

-- INTERFACE DA ABA PRINCIPAL
Tabs.Main:AddToggle("AFarm", {Title = "Auto Farm Nível", Default = false, Callback = function(v) _G.AutoFarm = v end})
Tabs.Main:AddToggle("AClick", {Title = "Auto Clique", Default = false, Callback = function(v) _G.AutoAttack = v end})
Tabs.Main:AddSection("Auto Stats")
Tabs.Main:AddDropdown("StatS", {Title = "Subir Status:", Values = {"Melee", "Defense", "Sword", "Blox Fruit"}, Default = "Melee", Callback = function(v) _G.StatSelect = v end})
Tabs.Main:AddToggle("AStats", {Title = "Ativar Auto Stats", Default = false, Callback = function(v) _G.AutoStats = v end})

Window:SelectTab(1)
