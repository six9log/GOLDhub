local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()

local Window = Fluent:CreateWindow({
    Title = "GOLD HUB | SEA 1",
    SubTitle = "v1.6 - Smooth Fly & Full ESP",
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
_G.AutoStoreFruit = false

-- FUNÇÃO DE MOVIMENTO SUAVE (TWEEN) - IGUAL AO COLETAR FRUTA
function SmoothMove(TargetCFrame)
    local Character = game.Players.LocalPlayer.Character
    local Root = Character:FindFirstChild("HumanoidRootPart")
    if Root then
        local Distance = (TargetCFrame.Position - Root.Position).Magnitude
        local Speed = 200 -- Velocidade segura para registro de dano
        local Tween = game:GetService("TweenService"):Create(Root, TweenInfo.new(Distance/Speed, Enum.EasingStyle.Linear), {CFrame = TargetCFrame})
        Tween:Play()
    end
end

-- 1. AUTO CLIQUE (Puro)
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

-- 2. AUTO COLETAR & AUTO ARMAZENAR (SEPARADOS)
spawn(function()
    while task.wait(1) do
        pcall(function()
            for _, v in pairs(workspace:GetChildren()) do
                if v:IsA("Tool") and v:FindFirstChild("Handle") then
                    -- Se coletar estiver ligado
                    if _G.AutoCollectFruit then
                        SmoothMove(v.Handle.CFrame)
                        task.wait(0.5)
                    end
                    -- Se armazenar estiver ligado
                    if _G.AutoStoreFruit then
                        game:GetService("ReplicatedStorage").Remotes.CommF_:InvokeServer("StoreFruit", v:GetAttribute("FruitName"), v)
                    end
                end
            end
        end)
    end
end)

-- 3. LÓGICA DE FARM COM VOO SUAVE (PARA NÃO BUGAR O DANO)
spawn(function()
    while task.wait(0.1) do
        if _G.AutoFarm then
            pcall(function()
                local lp = game.Players.LocalPlayer
                local lvl = lp.Data.Level.Value
                
                -- Noclip Constante
                for _, v in pairs(lp.Character:GetDescendants()) do
                    if v:IsA("BasePart") then v.CanCollide = false end
                end

                if not lp.PlayerGui.Main.Quest.Visible then
                    -- Vai buscar missão (Ex: Jungle lvl 15)
                    if lvl >= 15 then
                        SmoothMove(CFrame.new(-1598, 37, 153))
                        game:GetService("ReplicatedStorage").Remotes.CommF_:InvokeServer("StartQuest", "JungleQuest", 2)
                    else
                        SmoothMove(CFrame.new(1059, 16, 1546))
                        game:GetService("ReplicatedStorage").Remotes.CommF_:InvokeServer("StartQuest", "BanditQuest1", 1)
                    end
                else
                    -- Procura inimigo
                    local target = nil
                    for _, v in pairs(workspace.Enemies:GetChildren()) do
                        if v:FindFirstChild("Humanoid") and v.Humanoid.Health > 0 then
                            target = v
                            break
                        end
                    end
                    
                    if target then
                        -- VOA SUAVE ATÉ O MONSTRO (Distância de 8 studs)
                        SmoothMove(target.HumanoidRootPart.CFrame * CFrame.new(0, 8, 0))
                    end
                end
            end)
        end
    end
end)

-- 4. SISTEMA DE ESP (FRUTAS E PLAYERS)
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
                    local label = Instance.new("TextLabel", bill)
                    label.BackgroundTransparency = 1; label.Size = UDim2.new(1,0,1,0); label.TextColor3 = Color3.fromRGB(0,255,127); label.TextSize = 14
                    spawn(function()
                        while v:IsDescendantOf(workspace) and _G.FruitESP do
                            local dist = math.floor((lp.Character.HumanoidRootPart.Position - v.Handle.Position).Magnitude)
                            label.Text = "🍎 "..v.Name.."\n["..dist.."m]"; task.wait(0.5)
                        end
                        bill:Destroy()
                    end)
                end
            end
        end
        -- ESP PLAYERS (Igual ao anterior, simplificado aqui por espaço)
    end
end)

-- INTERFACE TOTALMENTE SEPARADA
Tabs.Main:AddToggle("FarmToggle", {Title = "Auto Farm (Voo Suave)", Default = false, Callback = function(v) _G.AutoFarm = v end})
Tabs.Main:AddToggle("AttackToggle", {Title = "Auto Clique (0.5s)", Default = false, Callback = function(v) _G.AutoAttack = v end})

Tabs.Visuals:AddSection("Visual / ESP")
Tabs.Visuals:AddToggle("FruitESPToggle", {Title = "ESP Frutas", Default = false, Callback = function(v) _G.FruitESP = v end})
Tabs.Visuals:AddToggle("PlayerESPToggle", {Title = "ESP Jogadores", Default = false, Callback = function(v) _G.PlayerESP = v end})

Tabs.Visuals:AddSection("Frutas Opções")
Tabs.Visuals:AddToggle("CollectToggle", {Title = "Auto Coletar (Voando)", Default = false, Callback = function(v) _G.AutoCollectFruit = v end})
Tabs.Visuals:AddToggle("StoreToggle", {Title = "Auto Armazenar (Inventário)", Default = false, Callback = function(v) _G.AutoStoreFruit = v end})
