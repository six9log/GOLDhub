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

-- BOTÃO FLUTUANTE REDONDO PARA MINIMIZAR/ABRIR MENU
local UIS = game:GetService("UserInputService")
local PlayerGui = game.Players.LocalPlayer:WaitForChild("PlayerGui")

local FloatGui = Instance.new("ScreenGui")
FloatGui.Name = "FloatToggleGui"
FloatGui.Parent = PlayerGui
FloatGui.ResetOnSpawn = false

local Button = Instance.new("TextButton")
Button.Parent = FloatGui
Button.Size = UDim2.new(0, 55, 0, 55)
Button.Position = UDim2.new(0, 20, 0.5, -25)
Button.Text = "☰"
Button.TextSize = 28
Button.BackgroundColor3 = Color3.fromRGB(255, 200, 0)
Button.TextColor3 = Color3.fromRGB(0, 0, 0)
Button.BorderSizePixel = 0
Button.AutoButtonColor = true
Button.Draggable = true
Button.Active = true

local Corner = Instance.new("UICorner", Button)
Corner.CornerRadius = UDim.new(1, 0)

local Stroke = Instance.new("UIStroke", Button)
Stroke.Thickness = 2
Stroke.Color = Color3.fromRGB(0, 0, 0)

local MenuVisible = true
Button.MouseButton1Click:Connect(function()
    MenuVisible = not MenuVisible
    Window:SetVisible(MenuVisible)
end)

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

-- TABELA DE QUEST POR NÍVEL (SEA 1)
local QuestTable = {
    {Min = 0, Max = 9, Quest = "BanditQuest1", ID = 1, Mob = "Bandit", QuestPos = CFrame.new(1059,16,1546), FarmPos = CFrame.new(1145,16,1630)},
    {Min = 10, Max = 14, Quest = "JungleQuest", ID = 1, Mob = "Monkey", QuestPos = CFrame.new(-1598,37,153), FarmPos = CFrame.new(-1612,36,147)},
    {Min = 15, Max = 29, Quest = "JungleQuest", ID = 2, Mob = "Gorilla", QuestPos = CFrame.new(-1598,37,153), FarmPos = CFrame.new(-1240,6,497)},
    {Min = 30, Max = 39, Quest = "BuggyQuest1", ID = 1, Mob = "Pirate", QuestPos = CFrame.new(-1141,4,3828), FarmPos = CFrame.new(-1210,5,3900)},
    {Min = 40, Max = 59, Quest = "BuggyQuest1", ID = 2, Mob = "Brute", QuestPos = CFrame.new(-1141,4,3828), FarmPos = CFrame.new(-1340,5,4120)},
    -- Adicione mais níveis conforme a progressão do jogo
}

local function GetQuestByLevel(level)
    for _, q in pairs(QuestTable) do
        if level >= q.Min and level <= q.Max then
            return q
        end
    end
end

-- 2. AUTO FARM DINÂMICO (TODAS AS ILHAS SEA 1)
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

                local quest = GetQuestByLevel(lvl)
                if not quest then return end

                if not lp.PlayerGui.Main.Quest.Visible then
                    SmoothMove(quest.QuestPos)
                    if (char.HumanoidRootPart.Position - quest.QuestPos.Position).Magnitude < 10 then
                        task.wait(0.5)
                        game:GetService("ReplicatedStorage").Remotes.CommF_:InvokeServer(quest.Quest, quest.ID)
                    end
                else
                    -- LÓGICA DE ALVO POR NÍVEL
                    local target = nil
                    for _, v in pairs(workspace.Enemies:GetChildren()) do
                        if v.Name == quest.Mob and v:FindFirstChild("Humanoid") and v.Humanoid.Health > 0 then
                            target = v
                            break
                        end
                    end

                    if target then
                        SmoothMove(target.HumanoidRootPart.CFrame * CFrame.new(0, 8, 0))
                    else
                        SmoothMove(quest.FarmPos)
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
