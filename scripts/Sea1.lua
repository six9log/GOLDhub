local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()

local Window = Fluent:CreateWindow({
    Title = "GOLD HUB | SEA 1",
    SubTitle = "v1.9 - Auto Quest System",
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

local CurrentTween = nil

-- FUNÇÃO DE VOO ESTABILIZADA
function SmoothMove(TargetCFrame)
    local Character = game.Players.LocalPlayer.Character
    local Root = Character:FindFirstChild("HumanoidRootPart")
    local Hum = Character:FindFirstChildOfClass("Humanoid")
    
    if Root and Hum and _G.AutoFarm then
        if Hum:GetState() ~= Enum.HumanoidStateType.Physics then
            Hum:ChangeState(Enum.HumanoidStateType.Physics)
        end
        Root.Velocity = Vector3.new(0,0,0)
        Root.RotVelocity = Vector3.new(0,0,0)

        local Distance = (TargetCFrame.Position - Root.Position).Magnitude
        local Speed = 250 
        
        if CurrentTween then CurrentTween:Cancel() end
        
        CurrentTween = game:GetService("TweenService"):Create(
            Root,
            TweenInfo.new(Distance/Speed, Enum.EasingStyle.Linear),
            {CFrame = TargetCFrame}
        )
        CurrentTween:Play()
    elseif not _G.AutoFarm then
        if CurrentTween then CurrentTween:Cancel() end
        if Hum then Hum:ChangeState(Enum.HumanoidStateType.GettingUp) end
    end
end

-- 1. AUTO ATAQUE
spawn(function()
    while task.wait(0.1) do
        if _G.AutoAttack then
            pcall(function()
                local player = game.Players.LocalPlayer
                local char = player.Character
                local tool = char:FindFirstChildOfClass("Tool") or player.Backpack:FindFirstChildOfClass("Tool")
                if tool and not char:FindFirstChild(tool.Name) then
                    char.Humanoid:EquipTool(tool)
                end
                if tool then tool:Activate() end
            end)
        end
    end
end)

-- 2. AUTO FARM DINÂMICO (CORRIGIDO PARA SELVA)
spawn(function()
    while task.wait(0.1) do
        if _G.AutoFarm then
            pcall(function()
                local lp = game.Players.LocalPlayer
                local lvl = lp.Data.Level.Value
                local char = lp.Character
                if not char or not char:FindFirstChild("HumanoidRootPart") then return end
                
                -- Noclip
                for _, v in pairs(char:GetChildren()) do
                    if v:IsA("BasePart") then v.CanCollide = false end
                end

                if not lp.PlayerGui.Main.Quest.Visible then
                    -- LÓGICA DE SELEÇÃO DE MISSÃO POR NÍVEL
                    local qName, qID, qNPCPos
                    
                    if lvl >= 0 and lvl < 10 then
                        qName, qID = "BanditQuest1", 1
                        qNPCPos = CFrame.new(1059, 16, 1546) -- NPC Bandidos
                    elseif lvl >= 10 and lvl < 15 then
                        qName, qID = "JungleQuest", 1
                        qNPCPos = CFrame.new(-1598, 37, 153) -- NPC Selva (Macacos)
                    elseif lvl >= 15 and lvl < 30 then
                        qName, qID = "JungleQuest", 2
                        qNPCPos = CFrame.new(-1598, 37, 153) -- NPC Selva (Gorilas)
                    end

                    if qNPCPos then
                        SmoothMove(qNPCPos)
                        if (char.HumanoidRootPart.Position - qNPCPos.Position).Magnitude < 10 then
                            task.wait(0.5)
                            game:GetService("ReplicatedStorage").Remotes.CommF_:InvokeServer("StartQuest", qName, qID)
                        end
                    end
                else
                    -- LÓGICA DE ALVO POR NÍVEL
                    local monsterName = ""
                    if lvl < 10 then monsterName = "Bandit"
                    elseif lvl >= 10 and lvl < 15 then monsterName = "Monkey"
                    elseif lvl >= 15 then monsterName = "Gorilla" end
                    
                    local target = nil
                    for _, v in pairs(workspace.Enemies:GetChildren()) do
                        if v.Name == monsterName and v:FindFirstChild("Humanoid") and v.Humanoid.Health > 0 then
                            target = v
                            break
                        end
                    end
                    
                    if target then
                        SmoothMove(target.HumanoidRootPart.CFrame * CFrame.new(0, 8, 0))
                    else
                        -- Se não achar o monstro, vai para o spawn dele
                        local spawnPos = (monsterName == "Monkey") and CFrame.new(-1612, 36, 147) or CFrame.new(-1240, 6, 497)
                        SmoothMove(spawnPos)
                    end
                end
            end)
        end
    end
end)

-- ESP DE FRUTAS (SIMPLIFICADO)
spawn(function()
    while task.wait(1) do
        if _G.FruitESP then
            for _, v in pairs(workspace:GetChildren()) do
                if v:IsA("Tool") and v:FindFirstChild("Handle") and not v.Handle:FindFirstChild("FruitESP") then
                    local gui = Instance.new("BillboardGui", v.Handle)
                    gui.Name = "FruitESP"
                    gui.Size = UDim2.new(0, 100, 0, 40)
                    gui.AlwaysOnTop = true
                    local txt = Instance.new("TextLabel", gui)
                    txt.Size = UDim2.new(1,0,1,0)
                    txt.BackgroundTransparency = 1
                    txt.Text = "🍎 " .. v.Name
                    txt.TextColor3 = Color3.fromRGB(255,0,0)
                    txt.TextScaled = true
                end
            end
        end
    end
end)

-- INTERFACE
Tabs.Main:AddToggle("FarmToggle", {
    Title = "Auto Farm (Quest Inteligente)",
    Default = false,
    Callback = function(v) _G.AutoFarm = v end
})

Tabs.Main:AddToggle("AttackToggle", {
    Title = "Auto Clique",
    Default = false,
    Callback = function(v) _G.AutoAttack = v end
})

Tabs.Visuals:AddToggle("FruitESPToggle", {
    Title = "ESP de Frutas",
    Default = false,
    Callback = function(v) _G.FruitESP = v end
})

Window:SelectTab(1)
