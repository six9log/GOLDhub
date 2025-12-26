--[[
    GOLD HUB - SEA 1 (Mundo 1)
    Lógica de Threads Separadas (Hoho Hub Style)
]]

--// 1. INTERFACE
local OrionLib = loadstring(game:HttpGet(('https://raw.githubusercontent.com/shlexware/Orion/main/source')))()
local Window = OrionLib:MakeWindow({
    Name = "GOLD HUB | SEA 1", 
    HidePremium = false, 
    SaveConfig = true, 
    ConfigFolder = "GoldSea1"
})

--// 2. VARIÁVEIS GLOBAIS
_G.AutoFarm = false
_G.FastAttack = true
_G.SelectWeapon = "Melee"

local Player = game.Players.LocalPlayer

--// 3. TABELA DE MISSÕES (Extraída do seu arquivo original)
local QuestTable = {
    {Level = 1, Name = "BanditQuest1", Mon = "Bandit", QPos = CFrame.new(1059, 15, 1550), MPos = CFrame.new(1045, 27, 1560)},
    {Level = 10, Name = "JungleQuest", Mon = "Monkey", QPos = CFrame.new(-1598, 35, 153), MPos = CFrame.new(-1448, 67, 11)},
    {Level = 15, Name = "JungleQuest", Mon = "Gorilla", QPos = CFrame.new(-1598, 35, 153), MPos = CFrame.new(-1200, 50, -500)},
    {Level = 30, Name = "PirateVillageQuest", Mon = "Pirate", QPos = CFrame.new(-1923, 5, 3906), MPos = CFrame.new(-1184, 4, 3851)},
    {Level = 60, Name = "DesertQuest", Mon = "Desert Bandit", QPos = CFrame.new(894, 6, 4388), MPos = CFrame.new(996, 6, 4425)}
}

--// 4. FUNÇÕES DE SUPORTE
function GetBestQuest()
    local lvl = Player.Data.Level.Value
    local best = QuestTable[1]
    for _, v in pairs(QuestTable) do
        if lvl >= v.Level then best = v end
    end
    return best
end

function EquipWeapon()
    local tool = Player.Backpack:FindFirstChild(_G.SelectWeapon) or Player.Character:FindFirstChild(_G.SelectWeapon)
    if tool and not Player.Character:FindFirstChild(_G.SelectWeapon) then
        Player.Character.Humanoid:EquipTool(tool)
    end
end

--// 5. THREAD DE ATAQUE (Roda independente para não travar)
task.spawn(function()
    while task.wait() do
        if _G.AutoFarm and _G.FastAttack then
            pcall(function()
                local Combat = require(Player.PlayerScripts.CombatFramework)
                local Active = debug.getupvalues(Combat)[2].activeController
                if Active then
                    Active.hitboxMagnitude = 60
                    Active.attack()
                end
            end)
        end
    end
end)

--// 6. ABA PRINCIPAL (UI)
local MainTab = Window:MakeTab({Name = "Auto Farm", Icon = "rbxassetid://4483345998"})

MainTab:AddToggle({
    Name = "Auto Farm Level",
    Default = false,
    Callback = function(v) _G.AutoFarm = v end    
})

MainTab:AddDropdown({
    Name = "Arma",
    Default = "Melee",
    Options = {"Melee", "Sword", "Fruit"},
    Callback = function(v) _G.SelectWeapon = v end    
})

--// 7. LOOP DE MOVIMENTAÇÃO (O "Motor" do Farm)
task.spawn(function()
    while task.wait() do
        if _G.AutoFarm then
            pcall(function()
                local data = GetBestQuest()
                
                -- Se não tem quest, vai pegar
                if not Player.PlayerGui.Main.Quest.Visible then
                    Player.Character.HumanoidRootPart.CFrame = data.QPos
                    task.wait(0.5)
                    game:GetService("ReplicatedStorage").Remotes.CommF_:InvokeServer("StartQuest", data.Name, 1)
                else
                    -- Se tem quest, foca no inimigo
                    local enemy = workspace.Enemies:FindFirstChild(data.Mon)
                    if enemy and enemy:FindFirstChild("Humanoid") and enemy.Humanoid.Health > 0 then
                        EquipWeapon()
                        -- Magnet: Trava 20 studs acima do NPC
                        Player.Character.HumanoidRootPart.CFrame = enemy.HumanoidRootPart.CFrame * CFrame.new(0, 20, 0)
                    else
                        -- NPC ainda não deu spawn
                        Player.Character.HumanoidRootPart.CFrame = data.MPos
                    end
                end
            end)
        end
    end
end)

OrionLib:Init()
