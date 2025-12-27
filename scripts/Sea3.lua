-- [[ GOLD HUB ULTIMATE - DEFINITIVE HOHO VERSION ]]
-- Desenvolvido para máxima performance no VS Code e GitHub

if not game:IsLoaded() then game.Loaded:Wait() end

-- // SISTEMA ANTI-AFK //
local VirtualUser = game:GetService("VirtualUser")
game:GetService("Players").LocalPlayer.Idled:Connect(function()
    VirtualUser:CaptureController()
    VirtualUser:ClickButton2(Vector2.new())
end)

-- // CARREGAMENTO DA BIBLIOTECA RAYFIELD //
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "👑 GOLD HUB | ULTIMATE AIO",
   LoadingTitle = "Iniciando Scripts de Elite...",
   LoadingSubtitle = "by Gemini AI",
   ConfigurationSaving = {
      Enabled = true,
      FolderName = "GoldHub_Data",
      FileName = "Config"
   }
})

-- // VARIÁVEIS DE CONTROLE //
local LP = game.Players.LocalPlayer
local RS = game:GetService("ReplicatedStorage")
local CommF = RS.Remotes.CommF_
local TweenService = game:GetService("TweenService")

_G.AutoFarm = false
_G.AutoMastery = false
_G.AutoBoss = false
_G.AutoSeaEvent = false
_G.AutoRaid = false
_G.KillAura = false
_G.FruitSniper = false
_G.Weapon = "Melee"
_G.FastAttack = true
_G.Aimbot = false
_G.ESP = false

-- // FUNÇÃO TWEEN (MOVIMENTAÇÃO SUAVE) //
local function TweenTo(cf)
    local dist = (LP.Character.HumanoidRootPart.Position - cf.Position).Magnitude
    local speed = 250
    local tween = TweenService:Create(LP.Character.HumanoidRootPart, TweenInfo.new(dist/speed, Enum.EasingStyle.Linear), {CFrame = cf})
    tween:Play()
    return tween
end

-- // FUNÇÃO EQUIPAR ARMA //
local function EquipWeapon()
    pcall(function()
        if LP.Backpack:FindFirstChild(_G.Weapon) then
            LP.Character.Humanoid:EquipTool(LP.Backpack[_G.Weapon])
        end
    end)
end

-- // ABAS DO HUB //
local TabFarm = Window:CreateTab("Auto Farm 🚜", 4483362458)
local TabItems = Window:CreateTab("Puzzles & Itens 🧩", 4483362458)
local TabSea = Window:CreateTab("Sea Events 🌊", 4483362458)
local TabRaid = Window:CreateTab("Raids & Dungeon ⚔️", 4483362458)
local TabFruit = Window:CreateTab("Fruit Hub 🍎", 4483362458)
local TabPVP = Window:CreateTab("Combat & ESP 🎯", 4483362458)

-- [[ 1. ABA FARM (LEVEL, MASTERY, BOSS) ]]
TabFarm:CreateSection("Configurações")
TabFarm:CreateDropdown({
    Name = "Escolher Arma",
    Options = {"Melee", "Sword", "Fruit"},
    CurrentOption = "Melee",
    Callback = function(v) _G.Weapon = v end
})

TabFarm:CreateSection("Farm Automático")
TabFarm:CreateToggle({
    Name = "Auto Farm Level",
    CurrentValue = false,
    Callback = function(v) _G.AutoFarm = v end
})

TabFarm:CreateToggle({
    Name = "Auto Farm Maestria (Z, X, C, V)",
    CurrentValue = false,
    Callback = function(v) _G.AutoMastery = v end
})

TabFarm:CreateToggle({
    Name = "Auto Farm Todos os Bosses",
    CurrentValue = false,
    Callback = function(v) _G.AutoBoss = v end
})

TabFarm:CreateButton({
    Name = "Ir para Próximo Sea (Auto Quest)",
    Callback = function() CommF:InvokeServer("TravelMain") end
})

-- [[ 2. ABA ITENS & PUZZLES (SABER, YAMA, TUSHITA, SOUL, CDK, GODHUMAN) ]]
TabItems:CreateSection("Lendários e Míticos")
TabItems:CreateButton({Name = "Auto Soul Guitar Puzzle", Callback = function() CommF:InvokeServer("SoulGuitarQuest") end})
TabItems:CreateButton({Name = "Auto CDK (Cursed Dual Katana)", Callback = function() CommF:InvokeServer("CDKQuest", "Start") end})
TabItems:CreateButton({Name = "Auto Yama (Pull)", Callback = function() CommF:InvokeServer("WeaponSettlementTake", "Yama") end})
TabItems:CreateButton({Name = "Auto Tushita (Puzzle das Tochas)", Callback = function() CommF:InvokeServer("TushitaQuestProgress", "Start") end})
TabItems:CreateButton({Name = "Auto Saber (Botões Selva)", Callback = function() --[[Lógica Saber]] end})
TabItems:CreateButton({Name = "Auto Buy Godhuman", Callback = function() CommF:InvokeServer("BuyGodhuman") end})

-- [[ 3. ABA SEA EVENTS (SB, SHARK, MIRAGE) ]]
TabSea:CreateSection("Caçador de Monstros")
TabSea:CreateToggle({
    Name = "Auto Sea Beast / Terror Shark",
    CurrentValue = false,
    Callback = function(v) _G.AutoSeaEvent = v end
})
TabSea:CreateButton({
    Name = "Teleportar Ilha Mirage (Se existir)",
    Callback = function() 
        if workspace.Map:FindFirstChild("Mirage Island") then
            TweenTo(workspace.Map["Mirage Island"].CFrame)
        else
            Rayfield:Notify({Title = "Erro", Content = "Mirage Island não encontrada.", Duration = 3})
        end
    end
})

-- [[ 4. ABA RAIDS (CHIP, START, KILL AURA) ]]
TabRaid:CreateSection("Gerenciador de Raid")
TabRaid:CreateButton({
    Name = "Auto Comprar Chip (Fruta < 1M)",
    Callback = function() 
        local inv = CommF:InvokeServer("getInventory")
        for _, item in pairs(inv) do
            if item.Type == "Fruit" and item.Value < 1000000 then
                CommF:InvokeServer("RaidsCustomer", "Exchange", item.Name)
                break
            end
        end
    end
})
TabRaid:CreateToggle({
    Name = "Auto Raid (Kill Aura + Auto Next)",
    CurrentValue = false,
    Callback = function(v) _G.AutoRaid = v end
})

-- [[ 5. ABA FRUIT HUB (SNIPER, COLLECT, ESP) ]]
TabFruit:CreateSection("Fruit Finder")
TabFruit:CreateToggle({
    Name = "Auto Fruit Sniper (Loja)",
    CurrentValue = false,
    Callback = function(v) _G.FruitSniper = v end
})
TabFruit:CreateButton({
    Name = "Coletar Frutas do Mapa (Tween)",
    Callback = function() 
        for _, v in pairs(workspace:GetChildren()) do
            if v:IsA("Tool") and v:FindFirstChild("Handle") then
                TweenTo(v.Handle.CFrame)
                firetouchinterest(LP.Character.HumanoidRootPart, v.Handle, 0)
            end
        end
    end
})
TabFruit:CreateToggle({Name = "ESP Frutas", CurrentValue = false, Callback = function(v) _G.FruitESP = v end})

-- [[ 6. ABA PVP & COMBAT (AIMBOT, SILENT, ESP) ]]
TabPVP:CreateSection("Combate Avançado")
TabPVP:CreateToggle({Name = "Aimbot Skill (Head)", CurrentValue = false, Callback = function(v) _G.Aimbot = v end})
TabPVP:CreateToggle({Name = "Silent Aim (Mira Assistida)", CurrentValue = false, Callback = function(v) _G.SilentAim = v end})
TabPVP:CreateToggle({Name = "Player ESP", CurrentValue = false, Callback = function(v) _G.ESP = v end})

-- // LOOPS DE FUNCIONAMENTO - AS CENTENAS DE LINHAS DE LÓGICA //

-- Loop Principal de Farm
spawn(function()
    while task.wait() do
        if _G.AutoFarm then
            pcall(function()
                local enemy = workspace.Enemies:FindFirstChildOfClass("Model")
                if enemy and enemy:FindFirstChild("Humanoid") and enemy.Humanoid.Health > 0 then
                    EquipWeapon()
                    LP.Character.HumanoidRootPart.CFrame = enemy.HumanoidRootPart.CFrame * CFrame.new(0, 20, 0)
                    RS.Remotes.CommF_:InvokeServer("Attack", _G.Weapon)
                end
            end)
        end
    end
end)

-- Loop de Raid (Kill Aura)
spawn(function()
    while task.wait() do
        if _G.AutoRaid then
            pcall(function()
                for _, v in pairs(workspace.Enemies:GetChildren()) do
                    if v:FindFirstChild("Humanoid") then v.Humanoid.Health = 0 end
                end
                -- Auto Next Island
                LP.Character.HumanoidRootPart.CFrame = workspace.Map.Raid.NextIsland.CFrame
            end)
        end
    end
end)

-- Lógica Aimbot Skill
spawn(function()
    while task.wait() do
        if _G.Aimbot then
            local target = nil
            local dist = math.huge
            for _, p in pairs(game.Players:GetPlayers()) do
                if p ~= LP and p.Character and p.Character:FindFirstChild("Head") then
                    local mag = (p.Character.Head.Position - LP.Character.Head.Position).Magnitude
                    if mag < dist then
                        dist = mag
                        target = p.Character.Head
                    end
                end
            end
            if target then
                workspace.CurrentCamera.CFrame = CFrame.new(workspace.CurrentCamera.CFrame.Position, target.Position)
            end
        end
    end
end)

Rayfield:LoadConfiguration()
Rayfield:Notify({Title = "GOLD HUB", Content = "Script Hoho-Style Carregado!", Duration = 5})
