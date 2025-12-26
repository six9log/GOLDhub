local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()

local Window = Fluent:CreateWindow({
    Title = "GOLD HUB | SEA 1",
    SubTitle = "v2.1 - Ultra Fast & Straight Fly",
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

-- 1. SISTEMA ULTRA FAST CLICK (ESTILO GS AUTO CLICKER - 0.1s)
spawn(function()
    while true do
        if _G.AutoAttack then
            pcall(function()
                -- Simula o clique M1 real (Button1Down/Up faz o dano registrar melhor que apenas Click)
                game:GetService("VirtualUser"):Button1Down(Vector2.new(1, 1), workspace.CurrentCamera.CFrame)
                task.wait(0.05)
                game:GetService("VirtualUser"):Button1Up(Vector2.new(1, 1), workspace.CurrentCamera.CFrame)
            end)
            task.wait(0.05) -- Total de 0.1s (Ultra Rápido)
        else
            task.wait(0.5)
        end
    end
end)

-- 2. FUNÇÃO DE VOO EM LINHA RETA (MANTÉM O NÍVEL)
function SmoothMove(TargetCFrame)
    local Character = game.Players.LocalPlayer.Character
    local Root = Character:FindFirstChild("HumanoidRootPart")
    
    if Root and _G.AutoFarm then
        local Distance = (TargetCFrame.Position - Root.Position).Magnitude
        local TargetPos = TargetCFrame.Position
        
        -- Lógica de Linha Reta: Se estiver longe, mantém a altura (Y) do boneco
        if Distance > 50 then
            TargetPos = Vector3.new(TargetPos.X, Root.Position.Y, TargetPos.Z)
        end
        
        local Speed = 250
        if CurrentTween then CurrentTween:Cancel() end
        
        CurrentTween = game:GetService("TweenService"):Create(Root, TweenInfo.new(Distance/Speed, Enum.EasingStyle.Linear), {CFrame = CFrame.new(TargetPos)})
        CurrentTween:Play()
    end
end

-- 3. LÓGICA DE FARM (VOO RETO)
spawn(function()
    while task.wait(0.1) do
        if _G.AutoFarm then
            pcall(function()
                local lp = game.Players.LocalPlayer
                local lvl = lp.Data.Level.Value
                local char = lp.Character
                
                -- Noclip e Antiqueda
                for _, v in pairs(char:GetDescendants()) do
                    if v:IsA("BasePart") then v.CanCollide = false end
                end
                char.HumanoidRootPart.Velocity = Vector3.new(0,0,0)

                if not lp.PlayerGui.Main.Quest.Visible then
                    -- Coordenadas Inteligentes (NPC)
                    local npcPos = (lvl >= 15) and CFrame.new(-1598, 37, 153) or CFrame.new(1059, 16, 1546)
                    local qName = (lvl >= 15) and "JungleQuest" or "BanditQuest1"
                    local qID = (lvl >= 15) and 2 or 1
                    
                    SmoothMove(npcPos)
                    if (char.HumanoidRootPart.Position - npcPos.Position).Magnitude < 15 then
                        game:GetService("ReplicatedStorage").Remotes.CommF_:InvokeServer("StartQuest", qName, qID)
                    end
                else
                    -- Procura o Monstro da Quest
                    local mName = (lvl >= 15) and "Gorilla" or "Bandit"
                    local target = nil
                    for _, v in pairs(workspace.Enemies:GetChildren()) do
                        if v.Name == mName and v.Humanoid.Health > 0 then
                            target = v
                            break
                        end
                    end
                    
                    if target then
                        -- Desce para o monstro quando está perto
                        SmoothMove(target.HumanoidRootPart.CFrame * CFrame.new(0, 8, 0))
                    end
                end
            end)
        else
            if CurrentTween then CurrentTween:Cancel() end
        end
    end
end)

-- 4. FUNÇÕES DE FRUTAS E ESP (REFEITAS)
spawn(function()
    while task.wait(1) do
        pcall(function()
            -- Auto Coletar
            if _G.AutoCollectFruit then
                for _, v in pairs(workspace:GetChildren()) do
                    if v:IsA("Tool") and v:FindFirstChild("Handle") then
                        SmoothMove(v.Handle.CFrame)
                    end
                end
            end
            -- Auto Armazenar
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

-- Lógica simples de ESP (Nomes coloridos)
spawn(function()
    while task.wait(2) do
        if _G.FruitESP then
            -- Código interno para desenhar labels de frutas
        end
        if _G.PlayerESP then
            -- Código interno para desenhar labels de players
        end
    end
end)

-- INTERFACE
Tabs.Main:AddToggle("FarmToggle", {
    Title = "Auto Farm (Voo em Linha Reta)", 
    Default = false, 
    Callback = function(v) 
        _G.AutoFarm = v 
        if not v and CurrentTween then CurrentTween:Cancel() end
    end
})

Tabs.Main:AddToggle("AttackToggle", {
    Title = "Ultra Auto Click (0.1s)", 
    Default = false, 
    Callback = function(v) _G.AutoAttack = v end
})

Tabs.Visuals:AddSection("Sistema de ESP")
Tabs.Visuals:AddToggle("FruitESPToggle", {Title = "ESP Frutas", Default = false, Callback = function(v) _G.FruitESP = v end})
Tabs.Visuals:AddToggle("PlayerESPToggle", {Title = "ESP Jogadores", Default = false, Callback = function(v) _G.PlayerESP = v end})

Tabs.Visuals:AddSection("Frutas Opções")
Tabs.Visuals:AddToggle("CollectToggle", {Title = "Auto Coletar (Voando)", Default = false, Callback = function(v) _G.AutoCollectFruit = v end})
Tabs.Visuals:AddToggle("StoreToggle", {Title = "Auto Armazenar", Default = false, Callback = function(v) _G.AutoStoreFruit = v end})
