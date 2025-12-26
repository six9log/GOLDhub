local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()

local Window = Fluent:CreateWindow({
    Title = "GOLD HUB | SEA 1",
    SubTitle = "Bring Mobs Edition",
    TabWidth = 160,
    Size = UDim2.fromOffset(580, 460),
    Acrylic = false,
    Theme = "Dark"
})

local Tabs = { Main = Window:AddTab({ Title = "Farm", Icon = "home" }) }
_G.AutoFarm = false

-- 1. FUNÇÃO DE TRAZER OS MONSTROS (BRING MOBS)
local function BringMobs()
    for _, v in pairs(workspace.Enemies:GetChildren()) do
        if v.Name == "Bandit" and v:FindFirstChild("HumanoidRootPart") and v.Humanoid.Health > 0 then
            v.HumanoidRootPart.CFrame = game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame * CFrame.new(0, 0, -5)
            v.HumanoidRootPart.CanCollide = false
            v.Humanoid.WalkSpeed = 0
        end
    end
end

-- 2. SISTEMA DE ATAQUE (FAST ATTACK)
spawn(function()
    while true do
        task.wait(0.05) -- Ataque mais rápido
        if _G.AutoFarm then
            pcall(function()
                local player = game.Players.LocalPlayer
                local character = player.Character
                
                -- Verifica o monstro mais próximo
                local monster = workspace.Enemies:FindFirstChild("Bandit")
                if monster and monster:FindFirstChild("Humanoid") and monster.Humanoid.Health > 0 then
                    -- Força Equipar
                    local tool = player.Backpack:FindFirstChild("Combat") or player.Backpack:FindFirstChild("Combate")
                    if tool and not character:FindFirstChild(tool.Name) then
                        character.Humanoid:EquipTool(tool)
                    end
                    
                    -- Ataque sem falhas
                    local toolName = character:FindFirstChildOfClass("Tool")
                    if toolName then
                        game:GetService("ReplicatedStorage").Remotes.CommF_:InvokeServer("Attack", monster.HumanoidRootPart, true)
                        -- Clique virtual no centro para garantir o registro
                        game:GetService("VirtualUser"):CaptureController()
                        game:GetService("VirtualUser"):Button1Down(Vector2.new(100, 100))
                    end
                end
            end)
        end
    end
end)

-- 3. MOVIMENTAÇÃO E POSICIONAMENTO
game:GetService("RunService").Stepped:Connect(function()
    if _G.AutoFarm then
        pcall(function()
            local lp = game.Players.LocalPlayer
            local root = lp.Character.HumanoidRootPart
            
            -- Noclip para não bugar com os monstros puxados
            for _, v in pairs(lp.Character:GetDescendants()) do
                if v:IsA("BasePart") then v.CanCollide = false end
            end
            
            if not lp.PlayerGui.Main.Quest.Visible then
                -- Vai pegar a missão
                root.CFrame = CFrame.new(1059, 20, 1546)
                game:GetService("ReplicatedStorage").Remotes.CommF_:InvokeServer("StartQuest", "BanditQuest1", 1)
            else
                -- Fica em uma posição centralizada na ilha, um pouco alto
                -- Isso evita que você fique "viajando" de um lado para o outro
                root.CFrame = CFrame.new(1145, 25, 1630) 
                root.Velocity = Vector3.new(0,0,0)
                
                -- Puxa os monstros para você
                BringMobs()
            end
        end)
    end
end)

Tabs.Main:AddToggle("FarmToggle", {
    Title = "Auto Farm + Bring Mobs", 
    Default = false,
    Callback = function(Value) _G.AutoFarm = Value end
})
