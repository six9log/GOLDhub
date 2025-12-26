local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()

local Window = Fluent:CreateWindow({
    Title = "GOLD HUB | SEA 1",
    SubTitle = "por six9log",
    TabWidth = 160,
    Size = UDim2.fromOffset(580, 460),
    Acrylic = false,
    Theme = "Dark"
})

local Tabs = { Main = Window:AddTab({ Title = "Farm", Icon = "home" }) }
local Options = Fluent.Options
_G.AutoFarm = false

-- FUNÇÃO DE CLIQUE NO MEIO DA TELA (0.1s de delay)
spawn(function()
    while true do
        task.wait(0.1) -- Delay de 0.100 segundos solicitado
        if _G.AutoFarm then
            pcall(function()
                local char = game.Players.LocalPlayer.Character
                if char and char:FindFirstChildOfClass("Tool") then
                    -- Simula o clique no centro exato da tela
                    local VUser = game:GetService("VirtualUser")
                    VUser:CaptureController()
                    VUser:Button1Down(Vector2.new(workspace.CurrentCamera.ViewportSize.X / 2, workspace.CurrentCamera.ViewportSize.Y / 2))
                end
            end)
        end
    end
end)

-- SISTEMA ANTI-QUEDA E NOCLIP
game:GetService("RunService").Stepped:Connect(function()
    if _G.AutoFarm then
        pcall(function()
            local char = game.Players.LocalPlayer.Character
            if char and char:FindFirstChild("HumanoidRootPart") then
                if not char.HumanoidRootPart:FindFirstChild("GoldVelocity") then
                    local bv = Instance.new("BodyVelocity")
                    bv.Name = "GoldVelocity"
                    bv.Velocity = Vector3.new(0,0,0)
                    bv.MaxForce = Vector3.new(9e9, 9e9, 9e9)
                    bv.Parent = char.HumanoidRootPart
                end
                for _, v in pairs(char:GetDescendants()) do
                    if v:IsA("BasePart") then v.CanCollide = false end
                end
            end
        end)
    end
end)

-- LÓGICA DE MOVIMENTAÇÃO
spawn(function()
    while true do
        task.wait()
        if _G.AutoFarm then
            pcall(function()
                local player = game.Players.LocalPlayer
                local questGui = player.PlayerGui.Main.Quest
                
                if not questGui.Visible then
                    player.Character.HumanoidRootPart.CFrame = CFrame.new(1059, 16, 1546)
                    task.wait(0.5)
                    game:GetService("ReplicatedStorage").Remotes.CommF_:InvokeServer("StartQuest", "BanditQuest1", 1)
                else
                    local Monster = game:GetService("Workspace").Enemies:FindFirstChild("Bandit")
                    if Monster and Monster:FindFirstChild("HumanoidRootPart") and Monster.Humanoid.Health > 0 then
                        -- Fica a 7 studs de altura (ideal para o clique no centro pegar)
                        player.Character.HumanoidRootPart.CFrame = Monster.HumanoidRootPart.CFrame * CFrame.new(0, 7, 0)
                        
                        -- Equipar Arma
                        local tool = player.Backpack:FindFirstChildOfClass("Tool") or player.Character:FindFirstChildOfClass("Tool")
                        if tool then player.Character.Humanoid:EquipTool(tool) end
                    else
                        player.Character.HumanoidRootPart.CFrame = CFrame.new(1145, 20, 1630)
                    end
                end
            end)
        end
    end
end)

Tabs.Main:AddToggle("FarmToggle", {Title = "Ligar Auto Farm", Default = false})
Options.FarmToggle:OnChanged(function() _G.AutoFarm = Options.FarmToggle.Value end)
