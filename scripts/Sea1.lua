local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()

local Window = Fluent:CreateWindow({
    Title = "GOLD HUB | SEA 1",
    SubTitle = "por six9log",
    TabWidth = 160,
    Size = UDim2.fromOffset(580, 460),
    Acrylic = false,
    Theme = "Dark"
})

local Tabs = { Main = Window:AddTab({ Title = "Farm Principal", Icon = "home" }) }
local Options = Fluent.Options
_G.AutoFarm = false

-- FUNÇÃO PARA PEGAR MISSÃO AUTOMÁTICA
function GetQuest()
    local Level = game.Players.LocalPlayer.Data.Level.Value
    if Level >= 0 then
        game:GetService("ReplicatedStorage").Remotes.CommF_:InvokeServer("StartQuest", "BanditQuest1", 1)
    end
end

-- FUNÇÃO DE MOVIMENTO SEGURO (TWEEN)
function StableTween(TargetCFrame)
    local Character = game.Players.LocalPlayer.Character
    local Root = Character:FindFirstChild("HumanoidRootPart")
    if Root then
        -- Ativa Noclip e Anti-Queda
        if not Root:FindFirstChild("GoldHubBodyVelocity") then
            local bv = Instance.new("BodyVelocity")
            bv.Name = "GoldHubBodyVelocity"
            bv.Velocity = Vector3.new(0,0,0)
            bv.MaxForce = Vector3.new(9e9, 9e9, 9e9)
            bv.Parent = Root
        end
        
        for _, v in pairs(Character:GetDescendants()) do
            if v:IsA("BasePart") then v.CanCollide = false end
        end
        
        Root.CFrame = TargetCFrame
    end
end

-- LÓGICA PRINCIPAL
spawn(function()
    while true do
        task.wait()
        if _G.AutoFarm then
            pcall(function()
                -- Se não tiver missão, vai pegar
                if not game.Players.LocalPlayer.PlayerGui.Main.Quest.Visible then
                    StableTween(CFrame.new(1059, 16, 1546)) -- Posição do NPC da Quest
                    task.wait(0.5)
                    GetQuest()
                else
                    -- Procura o Monstro
                    local Monster = game:GetService("Workspace").Enemies:FindFirstChild("Bandit")
                    if Monster and Monster:FindFirstChild("HumanoidRootPart") and Monster.Humanoid.Health > 0 then
                        -- Fica EM CIMA do monstro (distância segura)
                        StableTween(Monster.HumanoidRootPart.CFrame * CFrame.new(0, 12, 0))
                        
                        -- Equipar Arma
                        local tool = game.Players.LocalPlayer.Backpack:FindFirstChildOfClass("Tool") or game.Players.LocalPlayer.Character:FindFirstChildOfClass("Tool")
                        if tool then game.Players.LocalPlayer.Character.Humanoid:EquipTool(tool) end
                        
                        -- Ataque
                        game:GetService("VirtualUser"):CaptureController()
                        game:GetService("VirtualUser"):Button1Down(Vector2.new(1280, 672))
                    else
                        -- Se o monstro não nasceu, espera no local de spawn
                        StableTween(CFrame.new(1145, 25, 1630))
                    end
                end
            end)
        else
            -- Remove Anti-Queda se desligar o farm
            pcall(function()
                if game.Players.LocalPlayer.Character.HumanoidRootPart:FindFirstChild("GoldHubBodyVelocity") then
                    game.Players.LocalPlayer.Character.HumanoidRootPart.GoldHubBodyVelocity:Destroy()
                end
            end)
        end
    end
end)

Tabs.Main:AddToggle("FarmToggle", {Title = "Auto Farm Level (Bandits)", Default = false})
Options.FarmToggle:OnChanged(function() _G.AutoFarm = Options.FarmToggle.Value end)
