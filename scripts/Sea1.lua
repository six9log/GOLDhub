local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()

local Window = Fluent:CreateWindow({
    Title = "GOLD HUB | SEA 1",
    SubTitle = "v2.1 - Anti-Stuck Edition",
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

local CurrentTween = nil

-- BOTÃO DE MINIMIZAR
local FloatGui = Instance.new("ScreenGui")
FloatGui.Name = "FloatToggleGui"
FloatGui.Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui")
FloatGui.ResetOnSpawn = false
local Button = Instance.new("TextButton")
Button.Parent = FloatGui
Button.Size = UDim2.new(0, 50, 0, 50)
Button.Position = UDim2.new(0, 10, 0.5, -25)
Button.Text = "GOLD"
Button.BackgroundColor3 = Color3.fromRGB(255, 200, 0)
Instance.new("UICorner", Button).CornerRadius = UDim.new(1, 0)
Button.MouseButton1Click:Connect(function()
    if game:GetService("CoreGui"):FindFirstChild("Fluent") then
        game:GetService("CoreGui").Fluent.Enabled = not game:GetService("CoreGui").Fluent.Enabled
    end
end)

-- VOO COM ANTI-QUEDA E ESTABILIDADE
function SmoothMove(TargetCFrame)
    local Character = game.Players.LocalPlayer.Character
    local Root = Character and Character:FindFirstChild("HumanoidRootPart")
    local Hum = Character and Character:FindFirstChildOfClass("Humanoid")
    
    if Root and Hum and _G.AutoFarm then
        -- Força o estado de física para não bugar na água
        if Hum:GetState() ~= Enum.HumanoidStateType.Physics then
            Hum:ChangeState(Enum.HumanoidStateType.Physics)
        end
        
        -- Zera forças para evitar o "balanço" que aparece na sua imagem
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

-- TABELA DE QUESTS (SEA 1)
local QuestTable = {
    {Min = 0, Max = 9, Quest = "BanditQuest1", ID = 1, Mob = "Bandit", QuestPos = CFrame.new(1059,16,1546), FarmPos = CFrame.new(1145,25,1630)},
    {Min = 10, Max = 14, Quest = "JungleQuest", ID = 1, Mob = "Monkey", QuestPos = CFrame.new(-1598,37,153), FarmPos = CFrame.new(-1612,36,147)},
    {Min = 15, Max = 29, Quest = "JungleQuest", ID = 2, Mob = "Gorilla", QuestPos = CFrame.new(-1598,37,153), FarmPos = CFrame.new(-1240,15,497)},
}

local function GetQuestByLevel(level)
    for _, q in pairs(QuestTable) do
        if level >= q.Min and level <= q.Max then return q end
    end
end

-- LOOP PRINCIPAL DE FARM
spawn(function()
    while task.wait(0.1) do
        if _G.AutoFarm then
            pcall(function()
                local lp = game.Players.LocalPlayer
                local char = lp.Character
                local quest = GetQuestByLevel(lp.Data.Level.Value)
                
                if not char or not char:FindFirstChild("HumanoidRootPart") or not quest then return end

                -- NOCLIP ATIVO (Para atravessar a borda da ilha se necessário)
                for _, v in pairs(char:GetDescendants()) do
                    if v:IsA("BasePart") then v.CanCollide = false end
                end

                if not lp.PlayerGui.Main.Quest.Visible then
                    -- FASE 1: PEGAR MISSÃO
                    -- Voa um pouco acima do NPC para não bugar na cabeça dele
                    SmoothMove(quest.QuestPos * CFrame.new(0, 5, 0))
                    if (char.HumanoidRootPart.Position - quest.QuestPos.Position).Magnitude < 15 then
                        task.wait(0.3)
                        game:GetService("ReplicatedStorage").Remotes.CommF_:InvokeServer("StartQuest", quest.Quest, quest.ID)
                    end
                else
                    -- FASE 2: MATAR MOBS
                    local target = nil
                    for _, v in pairs(workspace.Enemies:GetChildren()) do
                        if v.Name == quest.Mob and v:FindFirstChild("Humanoid") and v.Humanoid.Health > 0 then
                            target = v
                            break
                        end
                    end

                    if target then
                        -- Voa em cima do monstro (8 studs acima)
                        SmoothMove(target.HumanoidRootPart.CFrame * CFrame.new(0, 8, 0))
                    else
                        -- Se não achou o monstro, vai para o meio da área de farm
                        -- Adicionado um leve offset para cima para sair da água
                        SmoothMove(quest.FarmPos * CFrame.new(0, 10, 0))
                    end
                end
            end)
        end
    end
end)

-- AUTO ATAQUE
spawn(function()
    while task.wait(0.1) do
        if _G.AutoAttack then
            pcall(function()
                local char = game.Players.LocalPlayer.Character
                local tool = char:FindFirstChildOfClass("Tool") or game.Players.LocalPlayer.Backpack:FindFirstChildOfClass("Tool")
                if tool then
                    if not char:FindFirstChild(tool.Name) then char.Humanoid:EquipTool(tool) end
                    tool:Activate()
                end
            end)
        end
    end
end)

-- INTERFACE
Tabs.Main:AddToggle("FarmToggle", {Title = "Auto Farm (Quest Inteligente)", Default = false, Callback = function(v) _G.AutoFarm = v end})
Tabs.Main:AddToggle("AttackToggle", {Title = "Auto Clique", Default = false, Callback = function(v) _G.AutoAttack = v end})

Window:SelectTab(1)
