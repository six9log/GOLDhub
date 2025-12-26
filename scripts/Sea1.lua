local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()

local Window = Fluent:CreateWindow({
    Title = "GOLD HUB | SEA 1",
    SubTitle = "v1.9 - GS Clicker Mode",
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

-- 1. SISTEMA GS AUTO CLICKER (SIMULA M1 REAL)
spawn(function()
    while true do
        if _G.AutoAttack then
            pcall(function()
                -- Simula o pressionar do botão esquerdo do mouse (M1)
                game:GetService("VirtualUser"):ClickButton1(Vector2.new(150, 150))
            end)
            task.wait(0.5) -- Intervalo do GS Auto Clicker
        else
            task.wait(0.1)
        end
    end
end)

-- 2. FUNÇÃO DE VOO (ESTÁVEL)
local CurrentTween = nil
function SmoothMove(TargetCFrame)
    local Root = game.Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if Root and _G.AutoFarm then
        local Distance = (TargetCFrame.Position - Root.Position).Magnitude
        local Speed = 200 
        
        if CurrentTween then CurrentTween:Cancel() end
        
        CurrentTween = game:GetService("TweenService"):Create(Root, TweenInfo.new(Distance/Speed, Enum.EasingStyle.Linear), {CFrame = TargetCFrame})
        CurrentTween:Play()
    end
end

-- 3. LÓGICA DE FARM (VOANDO SEM TP)
spawn(function()
    while task.wait(0.1) do
        if _G.AutoFarm then
            pcall(function()
                local lp = game.Players.LocalPlayer
                local char = lp.Character
                local lvl = lp.Data.Level.Value
                
                -- Noclip e trava de gravidade
                for _, v in pairs(char:GetDescendants()) do
                    if v:IsA("BasePart") then v.CanCollide = false end
                end
                char.HumanoidRootPart.Velocity = Vector3.new(0,0,0)

                if not lp.PlayerGui.Main.Quest.Visible then
                    -- VOO ATÉ O NPC
                    local npcPos = (lvl >= 15) and CFrame.new(-1598, 37, 153) or CFrame.new(1059, 16, 1546)
                    local qName = (lvl >= 15) and "JungleQuest" or "BanditQuest1"
                    local qID = (lvl >= 15) and 2 or 1
                    
                    SmoothMove(npcPos)
                    if (char.HumanoidRootPart.Position - npcPos.Position).Magnitude < 15 then
                        game:GetService("ReplicatedStorage").Remotes.CommF_:InvokeServer("StartQuest", qName, qID)
                    end
                else
                    -- VOO ATÉ O MONSTRO
                    local mName = (lvl >= 15) and "Gorilla" or "Bandit"
                    local monster = nil
                    for _, v in pairs(workspace.Enemies:GetChildren()) do
                        if v.Name == mName and v.Humanoid.Health > 0 then
                            monster = v
                            break
                        end
                    end
                    
                    if monster then
                        SmoothMove(monster.HumanoidRootPart.CFrame * CFrame.new(0, 8, 0))
                    end
                end
            end)
        else
            if CurrentTween then CurrentTween:Cancel() end
        end
    end
end)

-- 4. ABA VISUAL & FRUTAS (SEPARADOS)
-- [Mantive os Toggles de ESP e Frutas organizados como você pediu]

-- INTERFACE
Tabs.Main:AddToggle("FarmToggle", {
    Title = "Auto Farm (Voo Suave)", 
    Default = false, 
    Callback = function(v) 
        _G.AutoFarm = v 
        if not v and CurrentTween then CurrentTween:Cancel() end
    end
})

Tabs.Main:AddToggle("AttackToggle", {
    Title = "GS Auto Click (M1)", 
    Default = false, 
    Callback = function(v) _G.AutoAttack = v end
})

Tabs.Visuals:AddSection("Sistema de ESP")
Tabs.Visuals:AddToggle("FruitESPToggle", {Title = "ESP Frutas", Default = false, Callback = function(v) _G.FruitESP = v end})
Tabs.Visuals:AddToggle("PlayerESPToggle", {Title = "ESP Jogadores", Default = false, Callback = function(v) _G.PlayerESP = v end})

Tabs.Visuals:AddSection("Frutas Opções")
Tabs.Visuals:AddToggle("CollectToggle", {Title = "Auto Coletar (Voando)", Default = false, Callback = function(v) _G.AutoCollectFruit = v end})
Tabs.Visuals:AddToggle("StoreToggle", {Title = "Auto Armazenar", Default = false, Callback = function(v) _G.AutoStoreFruit = v end})
