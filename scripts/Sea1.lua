local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()

local Window = Fluent:CreateWindow({
    Title = "GOLD HUB | SEA 1",
    SubTitle = "v1.4 - Visual & Fruits",
    TabWidth = 160,
    Size = UDim2.fromOffset(580, 460),
    Acrylic = false,
    Theme = "Dark"
})

local Tabs = { 
    Main = Window:AddTab({ Title = "Farm", Icon = "home" }),
    Visuals = Window:AddTab({ Title = "Visual & Frutas", Icon = "apple" })
}

_G.AutoFarm = false
_G.AutoAttack = false
_G.FruitESP = false
_G.PlayerESP = false
_G.AutoCollectFruit = false

-- 1. AUTO CLIQUE (VOCÊ SELECIONA A ARMA)
spawn(function()
    while true do
        task.wait(0.5)
        if _G.AutoAttack then
            pcall(function()
                game:GetService("VirtualUser"):CaptureController()
                game:GetService("VirtualUser"):Button1Down(Vector2.new(150, 150))
                task.wait(0.01)
                game:GetService("VirtualUser"):Button1Up(Vector2.new(150, 150))
            end)
        end
    end
end)

-- 2. AUTO COLETAR E ARMAZENAR (LOOP SELECIONÁVEL)
spawn(function()
    while task.wait(1) do
        if _G.AutoCollectFruit then
            pcall(function()
                for _, v in pairs(workspace:GetChildren()) do
                    if v:IsA("Tool") and v:FindFirstChild("Handle") then
                        local root = game.Players.LocalPlayer.Character.HumanoidRootPart
                        -- Tween até a fruta
                        local tween = game:GetService("TweenService"):Create(root, TweenInfo.new((root.Position - v.Handle.Position).Magnitude/150, Enum.EasingStyle.Linear), {CFrame = v.Handle.CFrame})
                        tween:Play()
                        tween.Completed:Wait()
                        task.wait(0.5)
                        -- Armazenar automaticamente
                        game:GetService("ReplicatedStorage").Remotes.CommF_:InvokeServer("StoreFruit", v:GetAttribute("FruitName"), v)
                    end
                end
            end)
        end
    end
end)

-- 3. SISTEMA DE ESP (PLAYER E FRUTAS)
spawn(function()
    while task.wait(1) do
        -- ESP FRUTAS
        if _G.FruitESP then
            for _, v in pairs(workspace:GetChildren()) do
                if v:IsA("Tool") and v:FindFirstChild("Handle") and not v:FindFirstChild("FruitTag") then
                    local bill = Instance.new("BillboardGui", v)
                    bill.Name = "FruitTag"
                    bill.AlwaysOnTop = true
                    bill.Size = UDim2.new(0, 100, 0, 50)
                    bill.ExtentsOffset = Vector3.new(0, 3, 0)
                    local label = Instance.new("TextLabel", bill)
                    label.BackgroundTransparency = 1
                    label.Size = UDim2.new(1, 0, 1, 0)
                    label.TextColor3 = Color3.fromRGB(0, 255, 127)
                    label.TextSize = 14
                    spawn(function()
                        while v:IsDescendantOf(workspace) and _G.FruitESP do
                            local dist = math.floor((game.Players.LocalPlayer.Character.HumanoidRootPart.Position - v.Handle.Position).Magnitude)
                            label.Text = "🍎 " .. v.Name .. "\n[" .. dist .. "m]"
                            task.wait(0.5)
                        end
                        bill:Destroy()
                    end)
                end
            end
        end

        -- ESP PLAYERS
        if _G.PlayerESP then
            for _, p in pairs(game.Players:GetPlayers()) do
                if p ~= game.Players.LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") and not p.Character:FindFirstChild("PlayerTag") then
                    local bill = Instance.new("BillboardGui", p.Character.HumanoidRootPart)
                    bill.Name = "PlayerTag"
                    bill.AlwaysOnTop = true
                    bill.Size = UDim2.new(0, 100, 0, 50)
                    bill.ExtentsOffset = Vector3.new(0, 3, 0)
                    local label = Instance.new("TextLabel", bill)
                    label.BackgroundTransparency = 1
                    label.Size = UDim2.new(1, 0, 1, 0)
                    label.TextColor3 = Color3.fromRGB(255, 50, 50)
                    label.TextSize = 12
                    spawn(function()
                        while p.Character and p.Character:FindFirstChild("HumanoidRootPart") and _G.PlayerESP do
                            local dist = math.floor((game.Players.LocalPlayer.Character.HumanoidRootPart.Position - p.Character.HumanoidRootPart.Position).Magnitude)
                            label.Text = "👤 " .. p.Name .. "\n[" .. dist .. "m]"
                            task.wait(0.5)
                        end
                        bill:Destroy()
                    end)
                end
            end
        end
    end
end)

-- 4. LÓGICA DE FARM
game:GetService("RunService").Stepped:Connect(function()
    if _G.AutoFarm then
        pcall(function()
            local lp = game.Players.LocalPlayer
            local root = lp.Character.HumanoidRootPart
            for _, v in pairs(lp.Character:GetDescendants()) do
                if v:IsA("BasePart") then v.CanCollide = false end
            end
            root.Velocity = Vector3.new(0,0,0)

            if not lp.PlayerGui.Main.Quest.Visible then
                root.CFrame = CFrame.new(1059, 16, 1546)
                game:GetService("ReplicatedStorage").Remotes.CommF_:InvokeServer("StartQuest", "BanditQuest1", 1)
            else
                local monster = workspace.Enemies:FindFirstChild("Bandit")
                if monster and monster.Humanoid.Health > 0 then
                    root.CFrame = monster.HumanoidRootPart.CFrame * CFrame.new(0, 8, 0)
                else
                    root.CFrame = CFrame.new(1145, 20, 1630)
                end
            end
        end)
    end
end)

--- INTERFACE ---

-- Aba Farm
Tabs.Main:AddToggle("FarmToggle", {Title = "Auto Farm Bandits", Default = false, Callback = function(v) _G.AutoFarm = v end})
Tabs.Main:AddToggle("AttackToggle", {Title = "Auto Clique (0.5s)", Default = false, Callback = function(v) _G.AutoAttack = v end})

-- Aba Visual & Frutas
Tabs.Visuals:AddSection("Sistema de ESP")
Tabs.Visuals:AddToggle("FruitESPToggle", {Title = "Ver Frutas no Chão", Default = false, Callback = function(v) _G.FruitESP = v end})
Tabs.Visuals:AddToggle("PlayerESPToggle", {Title = "Ver Outros Jogadores", Default = false, Callback = function(v) _G.PlayerESP = v end})

Tabs.Visuals:AddSection("Frutas Automático")
Tabs.Visuals:AddToggle("CollectToggle", {Title = "Auto Coletar & Armazenar", Default = false, Callback = function(v) _G.AutoCollectFruit = v end})
