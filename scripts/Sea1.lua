local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()

local Window = Fluent:CreateWindow({
    Title = "GOLD HUB | SEA 1 (SUAVE)",
    SubTitle = "por six9log",
    TabWidth = 160,
    Size = UDim2.fromOffset(580, 460),
    Acrylic = false,
    Theme = "Dark"
})

local Tabs = { Main = Window:AddTab({ Title = "Farm", Icon = "home" }) }
local Options = Fluent.Options
_G.AutoFarm = false

-- FUNÇÃO DE MOVIMENTO SUAVE (TWEEN)
function SmoothTween(TargetCFrame)
    local Character = game.Players.LocalPlayer.Character
    local Root = Character:FindFirstChild("HumanoidRootPart")
    if Root then
        local Distance = (TargetCFrame.Position - Root.Position).Magnitude
        local Speed = 250 -- Velocidade segura para evitar ban
        local Tween = game:GetService("TweenService"):Create(Root, TweenInfo.new(Distance/Speed, Enum.EasingStyle.Linear), {CFrame = TargetCFrame})
        Tween:Play()
    end
end

-- LÓGICA DE FARM E EQUIPAR SOCO
spawn(function()
    while true do
        task.wait(0.1) -- Delay solicitado de 0.1s
        if _G.AutoFarm then
            pcall(function()
                local player = game.Players.LocalPlayer
                local character = player.Character
                
                -- FORÇA SELECIONAR O SOCO (COMBATE)
                local tool = player.Backpack:FindFirstChild("Combat") or player.Backpack:FindFirstChild("Combate")
                if tool and not character:FindFirstChild(tool.Name) then
                    character.Humanoid:EquipTool(tool)
                end

                local Monster = workspace.Enemies:FindFirstChild("Bandit")
                if Monster and Monster:FindFirstChild("Humanoid") and Monster.Humanoid.Health > 0 then
                    -- Movimento suave até o monstro (fica 6 blocos acima)
                    SmoothTween(Monster.HumanoidRootPart.CFrame * CFrame.new(0, 6, 0))
                    
                    -- ATAQUE VIA REMOTE (Não clica na tela, não abre abas)
                    game:GetService("ReplicatedStorage").Remotes.CommF_:InvokeServer("Attack", Monster.HumanoidRootPart, true)
                else
                    -- Se não tem monstro, vai para o spawn suavemente
                    SmoothTween(CFrame.new(1145, 20, 1630))
                end
            end)
        end
    end
end)

-- SISTEMA ANTI-QUEDA (NOCLIP)
game:GetService("RunService").Stepped:Connect(function()
    if _G.AutoFarm then
        pcall(function()
            for _, v in pairs(game.Players.LocalPlayer.Character:GetDescendants()) do
                if v:IsA("BasePart") then v.CanCollide = false end
            end
        end)
    end
end)

Tabs.Main:AddToggle("FarmToggle", {Title = "Ligar Auto Farm Suave", Default = false})
Options.FarmToggle:OnChanged(function() _G.AutoFarm = Options.FarmToggle.Value end)
