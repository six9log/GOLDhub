local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()

local Window = Fluent:CreateWindow({
    Title = "GOLD HUB | SEA 1",
    SubTitle = "por six9log",
    TabWidth = 160,
    Size = UDim2.fromOffset(580, 460),
    Acrylic = false,
    Theme = "Dark"
})

local Tabs = {
    Main = Window:AddTab({ Title = "Farm Principal", Icon = "home" })
}

local Options = Fluent.Options
_G.AutoFarm = false

-- FUNÇÃO PARA VOAR ATÉ AO MONSTRO (TWEEN)
function CheckAndTween(TargetPos)
    local Character = game.Players.LocalPlayer.Character
    if Character and Character:FindFirstChild("HumanoidRootPart") then
        local Distance = (TargetPos.Position - Character.HumanoidRootPart.Position).Magnitude
        if Distance > 5 then
            local Tween = game:GetService("TweenService"):Create(
                Character.HumanoidRootPart,
                TweenInfo.new(Distance/250, Enum.EasingStyle.Linear), -- Velocidade 250
                {CFrame = TargetPos}
            )
            Tween:Play()
        end
    end
end

-- LÓGICA DO FARM
spawn(function()
    while true do
        task.wait()
        if _G.AutoFarm then
            pcall(function()
                -- Procura o monstro "Bandit"
                local Monster = game:GetService("Workspace").Enemies:FindFirstChild("Bandit") or game:GetService("ReplicatedStorage"):FindFirstChild("Bandit")
                
                if Monster and Monster:FindFirstChild("HumanoidRootPart") and Monster.Humanoid.Health > 0 then
                    -- Voa até ao monstro e fica um pouco acima dele
                    CheckAndTween(Monster.HumanoidRootPart.CFrame * CFrame.new(0, 10, 0))
                    
                    -- Equipar Arma
                    local tool = game.Players.LocalPlayer.Backpack:FindFirstChildOfClass("Tool") or game.Players.LocalPlayer.Character:FindFirstChildOfClass("Tool")
                    if tool then game.Players.LocalPlayer.Character.Humanoid:EquipTool(tool) end
                    
                    -- Bater
                    game:GetService("VirtualUser"):CaptureController()
                    game:GetService("VirtualUser"):Button1Down(Vector2.new(1280, 672))
                end
            end)
        end
    end
end)

Tabs.Main:AddToggle("FarmToggle", {Title = "Auto Farm Bandits (Teste)", Default = false})

Options.FarmToggle:OnChanged(function()
    _G.AutoFarm = Options.FarmToggle.Value
end)

Fluent:SelectTab(1)
