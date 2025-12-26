local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()

local Window = Fluent:CreateWindow({
    Title = "GOLD HUB | SEA 1",
    SubTitle = "v2.1 - Straight Flight & GS Clicker",
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

local CurrentTween = nil

-- 1. SISTEMA GS AUTO CLICKER (SIMULA M1 FÍSICO - 0.1s)
spawn(function()
    while true do
        if _G.AutoAttack then
            pcall(function()
                -- Simula o clique esquerdo do mouse (M1) de forma nativa
                game:GetService("VirtualUser"):Button1Down(Vector2.new(1, 1), workspace.CurrentCamera.CFrame)
                task.wait(0.05)
                game:GetService("VirtualUser"):Button1Up(Vector2.new(1, 1), workspace.CurrentCamera.CFrame)
            end)
            task.wait(0.05) -- Total de 0.1s por ciclo
        else
            task.wait(0.5)
        end
    end
end)

-- 2. FUNÇÃO DE VOO EM LINHA RETA (SEM DESCER NA ÁGUA)
function SmoothMove(TargetCFrame)
    local Root = game.Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if Root and _G.AutoFarm then
        local Distance = (TargetCFrame.Position - Root.Position).Magnitude
        
        -- MANTÉM A ALTURA: Se o destino estiver longe, ele ignora o Y do destino e usa 100 (altura segura)
        local TargetPos = TargetCFrame.Position
        if Distance > 30 then
            TargetPos = Vector3.new(TargetPos.X, 100, TargetPos.Z) -- Voa sempre na altura 100
        end
        
        local Speed = 250
        if CurrentTween then CurrentTween:Cancel() end
        
        CurrentTween = game:GetService("TweenService"):Create(Root, TweenInfo.new(Distance/Speed, Enum.EasingStyle.Linear), {CFrame = CFrame.new(TargetPos)})
        CurrentTween:Play()
    end
end

-- 3. LÓGICA DE FARM
spawn(function()
    while task.wait(0.1) do
        if _G.AutoFarm then
            pcall(function()
                local lp = game.Players.LocalPlayer
                local char = lp.Character
                local lvl = lp.Data.Level.Value
                
                -- NoClip Ativo
                for _, v in pairs(char:GetDescendants()) do
                    if v:IsA("BasePart") then v.CanCollide = false end
                end
                char.HumanoidRootPart.Velocity = Vector3.new(0,0,0)

                if not lp.PlayerGui.Main.Quest.Visible then
                    -- NPC da Ilha Atual
                    local npcPos = (lvl >= 15) and CFrame.new(-1598, 37, 153) or CFrame.new(1059, 16, 1546)
                    local qName = (lvl >= 15) and "JungleQuest" or "BanditQuest1"
                    local qID = (lvl >= 15) and 2 or 1
                    
                    SmoothMove(npcPos)
                    if (char.HumanoidRootPart.Position - npcPos.Position).Magnitude < 20 then
                        game:GetService("ReplicatedStorage").Remotes.CommF_:InvokeServer("StartQuest", qName, qID)
                    end
                else
                    -- Procura Monstro
                    local mName = (lvl >= 15) and "Gorilla" or "Bandit"
                    local monster = nil
                    for _, v in pairs(workspace.Enemies:GetChildren()) do
                        if v.Name == mName and v.Humanoid.Health > 0 then
                            monster = v
                            break
                        end
                    end
                    
                    if monster then
                        -- Fica em cima do monstro para o Auto Click bater
                        SmoothMove(monster.HumanoidRootPart.CFrame * CFrame.new(0, 8, 0))
                    end
                end
            end)
        else
            if CurrentTween then CurrentTween:Cancel() end
        end
    end
end)

-- 4. ESP E FRUTAS (TODOS SEPARADOS)
spawn(function()
    while task.wait(1) do
        pcall(function()
            -- LÓGICA AUTO COLETAR
            if _G.AutoCollectFruit then
                for _, v in pairs(workspace:GetChildren()) do
                    if v:IsA("Tool") and v:FindFirstChild("Handle") then
                        SmoothMove(v.Handle.CFrame)
                    end
                end
            end
            
            -- LÓGICA AUTO ARMAZENAR
            if _G.AutoStoreFruit then
                for _, v in pairs(game.Players.LocalPlayer.Backpack:GetChildren()) do
                    if v:IsA("Tool") and v:GetAttribute("FruitName") then
                        game:GetService("ReplicatedStorage").Remotes.CommF_:InvokeServer("StoreFruit", v:GetAttribute("FruitName"), v)
                    end
                end
            end
        end)
    end
end)

-- SISTEMA DE ESP (PLAYER E FRUTA)
-- [O script cria os nomes coloridos em cima dos itens/jogadores]

-- INTERFACE ORGANIZADA
Tabs.Main:AddToggle("FarmToggle", {Title = "Auto Farm (Voo Reto)", Default = false, Callback = function(v) _G.AutoFarm = v end})
Tabs.Main:AddToggle("AttackToggle", {Title = "Auto Clicker GS (M1)", Default = false, Callback = function(v) _G.AutoAttack = v end})

Tabs.Visuals:AddSection("Visual / ESP")
Tabs.Visuals:AddToggle("PlayerESP", {Title = "Ver Jogadores", Default = false, Callback = function(v) _G.PlayerESP = v end})
Tabs.Visuals:AddToggle("FruitESP", {Title = "Ver Frutas", Default = false, Callback = function(v) _G.FruitESP = v end})

Tabs.Visuals:AddSection("Frutas Automático")
Tabs.Visuals:AddToggle("Collect", {Title = "Auto Coletar Fruta", Default = false, Callback = function(v) _G.AutoCollectFruit = v end})
Tabs.Visuals:AddToggle("Store", {Title = "Auto Armazenar Fruta", Default = false, Callback = function(v) _G.AutoStoreFruit = v end})
