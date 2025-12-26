local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()

local Window = Fluent:CreateWindow({
    Title = "GOLD HUB | SEA 1",
    SubTitle = "Bring Mobs Limitado",
    TabWidth = 160,
    Size = UDim2.fromOffset(580, 460),
    Acrylic = false,
    Theme = "Dark"
})

local Tabs = { Main = Window:AddTab({ Title = "Farm", Icon = "home" }) }
_G.AutoFarm = false
_G.BringMobs = true

-- 1. FUNÇÃO BRING MOBS (LIMITADA A 3)
local function ExecuteBringMobs()
    if not _G.BringMobs then return end
    
    local count = 0
    for _, v in pairs(workspace.Enemies:GetChildren()) do
        -- Verifica se é Bandit, se está vivo e se ainda não puxou 3
        if v.Name == "Bandit" and v:FindFirstChild("HumanoidRootPart") and v.Humanoid.Health > 0 and count < 3 then
            v.HumanoidRootPart.CFrame = game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame * CFrame.new(0, 0, -5)
            v.HumanoidRootPart.CanCollide = false
            v.Humanoid.WalkSpeed = 0
            count = count + 1
        end
    end
end

-- 2. FUNÇÃO DE ATAQUE (MELHORADA)
spawn(function()
    while true do
        task.wait(0.1)
        if _G.AutoFarm then
            pcall(function()
                local player = game.Players.LocalPlayer
                local monster = workspace.Enemies:FindFirstChild("Bandit")
                
                if monster and monster:FindFirstChild("Humanoid") and monster.Humanoid.Health > 0 then
                    -- Equipar Combat
                    local tool = player.Backpack:FindFirstChild("Combat") or player.Backpack:FindFirstChild("Combate")
                    if tool and not player.Character:FindFirstChild(tool.Name) then
                        player.Character.Humanoid:EquipTool(tool)
                    end
                    
                    -- Ataque sem abrir inventário
                    game:GetService("ReplicatedStorage").Remotes.CommF_:InvokeServer("Attack", monster.HumanoidRootPart, true)
                    game:GetService("VirtualUser"):CaptureController()
                    game:GetService("VirtualUser"):Button1Down(Vector2.new(100, 100))
                end
            end)
        end
    end
end)

-- 3. LOOP DE MOVIMENTO E LOGICA DE MISSÃO
game:GetService("RunService").Stepped:Connect(function()
    if _G.AutoFarm then
        pcall(function()
            local lp = game.Players.LocalPlayer
            local root = lp.Character.HumanoidRootPart
            
            -- Noclip ativo
            for _, v in pairs(lp.Character:GetDescendants()) do
                if v:IsA("BasePart") then v.CanCollide = false end
            end
            
            if not lp.PlayerGui.Main.Quest.Visible then
                -- Vai pegar a missão
                root.CFrame = CFrame.new(1059, 20, 1546)
                game:GetService("ReplicatedStorage").Remotes.CommF_:InvokeServer("StartQuest", "BanditQuest1", 1)
            else
                -- Posicionamento fixo para farmar os monstros puxados
                root.CFrame = CFrame.new(1145, 25, 1630) 
                root.Velocity = Vector3.new(0,0,0)
                
                -- Chama a função de puxar
                ExecuteBringMobs()
            end
        end)
    end
end)

-- INTERFACE
Tabs.Main:AddToggle("FarmToggle", {
    Title = "Auto Farm Bandits", 
    Default = false,
    Callback = function(Value) _G.AutoFarm = Value end
})

Tabs.Main:AddToggle("BringToggle", {
    Title = "Usar Bring Mobs (Máx 3)", 
    Default = true,
    Callback = function(Value) _G.BringMobs = Value end
})
