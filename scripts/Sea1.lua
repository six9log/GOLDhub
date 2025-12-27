local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()

local Window = Fluent:CreateWindow({
    Title = "GOLD HUB | ZENITH FINAL v6.2",
    SubTitle = "Sea 1 Complete - Fixed Fruit System",
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
_G.AutoFarm = false; _G.AutoAttack = false; _G.AutoStats = false; _G.StatSelect = "Melee"
_G.TargetBoss = ""; _G.AutoBoss = false; _G.TargetPlayer = ""; _G.TPPlayer = false
_G.Aimlock = false; _G.FruitESP = false; _G.AutoCollectPull = false; _G.AutoCollectTween = false
_G.FruitLock = false

local CurrentTween = nil
function SmoothMove(TargetCFrame, SpeedOverride)
    local Root = game.Players.LocalPlayer.Character and game.Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if Root then
        local Distance = (TargetCFrame.Position - Root.Position).Magnitude
        if CurrentTween then CurrentTween:Cancel() end
        CurrentTween = game:GetService("TweenService"):Create(Root, TweenInfo.new(Distance/(SpeedOverride or 225), Enum.EasingStyle.Linear), {CFrame = TargetCFrame})
        CurrentTween:Play()
    end
end

-- SISTEMA DE FRUTAS (ESP + DISTÂNCIA + COLETA)
spawn(function()
    while task.wait(0.3) do
        local fruitFound = false
        for _, v in pairs(workspace:GetChildren()) do
            if v:IsA("Tool") and v:FindFirstChild("Handle") then
                local dist = math.floor((game.Players.LocalPlayer.Character.HumanoidRootPart.Position - v.Handle.Position).Magnitude)
                
                -- ESP COM DISTÂNCIA
                if _G.FruitESP then
                    local gui = v.Handle:FindFirstChild("FruitESP")
                    if not gui then
                        gui = Instance.new("BillboardGui", v.Handle)
                        gui.Name = "FruitESP"; gui.Size = UDim2.new(0,150,0,50); gui.AlwaysOnTop = true
                        local txt = Instance.new("TextLabel", gui)
                        txt.Name = "Label"; txt.Size = UDim2.new(1,0,1,0); txt.BackgroundTransparency = 1; txt.TextColor3 = Color3.fromRGB(255,0,0); txt.TextScaled = true; txt.Font = "SourceSansBold"
                    end
                    gui.Label.Text = "🍎 " .. v.Name .. "\n[" .. dist .. "m]"
                else
                    if v.Handle:FindFirstChild("FruitESP") then v.Handle.FruitESP:Destroy() end
                end

                -- COLETA AGRESSIVA (PULL)
                if _G.AutoCollectPull then
                    v.Handle.CFrame = game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame
                
                -- COLETA SUAVE (TWEEN)
                elseif _G.AutoCollectTween then
                    _G.FruitLock = true
                    fruitFound = true
                    SmoothMove(v.Handle.CFrame, 300)
                end
            end
        end
        if not fruitFound then _G.FruitLock = false end
    end
end)

-- AUTO STATS
spawn(function()
    while task.wait(1) do
        if _G.AutoStats then
            local p = game.Players.LocalPlayer.Data.Points.Value
            if p > 0 then game:GetService("ReplicatedStorage").Remotes.CommF_:InvokeServer("AddStats", _G.StatSelect, p) end
        end
    end
end)

-- LÓGICA DE FARM (SEA 1 COMPLETO)
function GetQuest()
    local lv = game.Players.LocalPlayer.Data.Level.Value
    if lv < 10 then return "BanditQuest1", 1, "Bandit", CFrame.new(1059,16,1546), CFrame.new(1145,25,1630)
    elseif lv < 30 then return "JungleQuest", 2, "Gorilla", CFrame.new(-1598,37,153), CFrame.new(-1240,15,497)
    elseif lv < 60 then return "BuggyQuest1", 2, "Brute", CFrame.new(-1141,4,3828), CFrame.new(-1340,15,4120)
    elseif lv < 90 then return "DesertQuest", 2, "Desert Officer", CFrame.new(896,28,4391), CFrame.new(1530,28,4380)
    elseif lv < 120 then return "SnowQuest", 2, "Snowman", CFrame.new(1385,15,-1310), CFrame.new(1300,25,-1500)
    elseif lv < 150 then return "MarineQuest2", 1, "Chief Petty Officer", CFrame.new(-4855,22,4330), CFrame.new(-4800,22,4400)
    elseif lv < 250 then return "PrisonQuest", 2, "Dangerous Prisoner", CFrame.new(5307,1,475), CFrame.new(5400,1,500)
    else return "MagmaQuest", 1, "Military Soldier", CFrame.new(-5315,12,8517), CFrame.new(-5300,20,8600) end
end

-- PVP
local PlayerDrop = Tabs.Combat:AddDropdown("PDrop", {Title = "Selecionar Jogador", Values = {}, Callback = function(v) _G.TargetPlayer = v end})
Tabs.Combat:AddButton({Title = "Atualizar Jogadores", Callback = function() 
    local plrs = {} for _,v in pairs(game.Players:GetPlayers()) do if v ~= game.Players.LocalPlayer then table.insert(plrs, v.Name) end end
    PlayerDrop:SetValues(plrs)
end})
Tabs.Combat:AddToggle("TPPlr", {Title = "Perseguir Jogador (TP)", Default = false, Callback = function(v) _G.TPPlayer = v end})
Tabs.Combat:AddToggle("Aim", {Title = "Aimlock (Aimbot)", Default = false, Callback = function(v) _G.Aimlock = v end})

-- BOSS & PUZZLES
Tabs.Boss:AddDropdown("BDrop", {Title = "Lista de Bosses", Values = {"Greybeard [Lv. 750]", "Saber Expert [Lv. 200]", "The Saw [Lv. 100]", "Vice Admiral", "Magma Admiral", "Fishman Lord"}, Callback = function(v) _G.TargetBoss = v end})
Tabs.Boss:AddToggle("ABoss", {Title = "Matar Boss Selecionado", Default = false, Callback = function(v) _G.AutoBoss = v end})

Tabs.Puzzles:AddButton({Title = "Puzzle Shanks (5 Botões)", Callback = function()
    local b = {CFrame.new(-1613,35,149), CFrame.new(-1540,36,210), CFrame.new(-1533,40,31), CFrame.new(-1371,35,33), CFrame.new(-1381,36,178)}
    for _,p in pairs(b) do SmoothMove(p) task.wait(1.5) end
end})
Tabs.Puzzles:AddButton({Title = "Comprar Hakis & Geppo", Callback = function() 
    local r = game:GetService("ReplicatedStorage").Remotes.CommF_
    r:InvokeServer("BuyHaki","Buso"); r:InvokeServer("BuyHaki","SkyJump"); r:InvokeServer("BuyHaki","Soru"); r:InvokeServer("BuyHaki","Observation")
end})

-- FRUIT INTERFACE
Tabs.Fruit:AddButton({Title = "Girar Fruta (Remoto)", Callback = function() game:GetService("ReplicatedStorage").Remotes.CommF_:InvokeServer("Cousin","Buy") end})
Tabs.Fruit:AddToggle("FESPT", {Title = "ESP Frutas + Distância", Default = false, Callback = function(v) _G.FruitESP = v end})
Tabs.Fruit:AddToggle("CTweenT", {Title = "Coletar Voando (Seguro)", Default = false, Callback = function(v) _G.AutoCollectTween = v end})
Tabs.Fruit:AddToggle("CPullT", {Title = "❗ Puxar Fruta (Agressivo/Ban)", Default = false, Callback = function(v) _G.AutoCollectPull = v end})

-- LOOPS PRINCIPAIS
spawn(function()
    while task.wait(0.1) do
        if _G.AutoFarm and not _G.FruitLock then
            pcall(function()
                local qN, qI, mN, qP, fP = GetQuest()
                local lp = game.Players.LocalPlayer
                if not lp.PlayerGui.Main.Quest.Visible then
                    SmoothMove(qP * CFrame.new(0,10,0))
                    if (lp.Character.HumanoidRootPart.Position - qP.Position).Magnitude < 15 then game:GetService("ReplicatedStorage").Remotes.CommF_:InvokeServer("StartQuest", qN, qI) end
                else
                    local t = workspace.Enemies:FindFirstChild(mN) or workspace.Enemies:FindFirstChild(mN.." [Lv. "..lp.Data.Level.Value.."]")
                    if t and t:FindFirstChild("Humanoid") and t.Humanoid.Health > 0 then SmoothMove(t.HumanoidRootPart.CFrame * CFrame.new(0,12,0)) else SmoothMove(fP * CFrame.new(0,20,0)) end
                end
            end)
        end
        if _G.AutoAttack then
            local c = game.Players.LocalPlayer.Character
            local t = c and (c:FindFirstChildOfClass("Tool") or game.Players.LocalPlayer.Backpack:FindFirstChildOfClass("Tool"))
            if t then if not c:FindFirstChild(t.Name) then c.Humanoid:EquipTool(t) end; t:Activate() end
        end
        if _G.TPPlayer and _G.TargetPlayer ~= "" then
            local tc = game.Players[_G.TargetPlayer].Character
            if tc then SmoothMove(tc.HumanoidRootPart.CFrame * CFrame.new(0,5,0), 400) end
        end
        if _G.AutoBoss and _G.TargetBoss ~= "" then
            local b = workspace.Enemies:FindFirstChild(_G.TargetBoss)
            if b then SmoothMove(b.HumanoidRootPart.CFrame * CFrame.new(0,12,0)) end
        end
    end
end)

game:GetService("RunService").RenderStepped:Connect(function()
    if _G.Aimlock and _G.TargetPlayer ~= "" then
        local tc = game.Players[_G.TargetPlayer].Character
        if tc then workspace.CurrentCamera.CFrame = CFrame.new(workspace.CurrentCamera.CFrame.Position, tc.HumanoidRootPart.Position) end
    end
end)

-- ABA FARM & STATS
Tabs.Main:AddToggle("AF_T", {Title = "Auto Farm Nível", Default = false, Callback = function(v) _G.AutoFarm = v end})
Tabs.Main:AddToggle("AT_T", {Title = "Auto Clique", Default = false, Callback = function(v) _G.AutoAttack = v end})
Tabs.Main:AddDropdown("SS_D", {Title = "Focar Status em:", Values = {"Melee", "Defense", "Sword", "Blox Fruit"}, Default = "Melee", Callback = function(v) _G.StatSelect = v end})
Tabs.Main:AddToggle("AS_T", {Title = "Ativar Auto Stats", Default = false, Callback = function(v) _G.AutoStats = v end})

Window:SelectTab(1)
