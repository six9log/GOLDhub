local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()

local Window = Fluent:CreateWindow({
    Title = "GOLD HUB | SEA 1",
    SubTitle = "v2.3 - Fixed Minimize",
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

-- BOTÃO DE MINIMIZAR (USANDO FUNÇÃO INTERNA DA BILIOTECA)
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
Button.TextColor3 = Color3.fromRGB(0, 0, 0)
Button.Font = Enum.Font.SourceSansBold
Button.TextSize = 14
Button.Draggable = true
Button.Active = true
Instance.new("UICorner", Button).CornerRadius = UDim.new(1, 0)

-- Esta é a forma mais segura de alternar a visibilidade no Fluent
Button.MouseButton1Click:Connect(function()
    local FluentGui = game:GetService("CoreGui"):FindFirstChild("Fluent") or game:GetService("Players").LocalPlayer.PlayerGui:FindFirstChild("Fluent")
    if FluentGui then
        FluentGui.Enabled = not FluentGui.Enabled
    end
end)

-- FUNÇÃO DE VOO ESTABILIZADA
function SmoothMove(TargetCFrame)
    local Character = game.Players.LocalPlayer.Character
    local Root = Character and Character:FindFirstChild("HumanoidRootPart")
    local Hum = Character and Character:FindFirstChildOfClass("Humanoid")
    
    if Root and Hum and _G.AutoFarm then
        if Hum:GetState() ~= Enum.HumanoidStateType.Physics then
            Hum:ChangeState(Enum.HumanoidStateType.Physics)
        end
        Root.Velocity = Vector3.new(0,0,0)
        Root.RotVelocity = Vector3.new(0,0,0)

        local Distance = (TargetCFrame.Position - Root.Position).Magnitude
        local Speed = 250 
        
        if CurrentTween then CurrentTween:Cancel() end
        CurrentTween = game:GetService("TweenService"):Create(Root, TweenInfo.new(Distance/Speed, Enum.EasingStyle.Linear), {CFrame = TargetCFrame})
        CurrentTween:Play()
    elseif not _G.AutoFarm then
        if CurrentTween then CurrentTween:Cancel() end
        if Hum then Hum:ChangeState(Enum.HumanoidStateType.GettingUp) end
    end
end

-- TABELA DE QUESTS ATUALIZADA
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

-- 2. AUTO FARM
spawn(function()
    while task.wait(0.1) do
        if _G.AutoFarm then
            pcall(function()
                local lp = game.Players.LocalPlayer
                local char = lp.Character
                local quest = GetQuestByLevel(lp.Data.Level.Value)
                if not char or not char:FindFirstChild("HumanoidRootPart") or not quest then return end

                for _, v in pairs(char:GetDescendants()) do
                    if v:IsA("BasePart") then v.CanCollide = false end
                end

                if not lp.PlayerGui.Main.Quest.Visible then
                    SmoothMove(quest.QuestPos * CFrame.new(0, 5, 0))
                    if (char.HumanoidRootPart.Position - quest.QuestPos.Position).Magnitude < 15 then
                        task.wait(0.5)
                        game:GetService("ReplicatedStorage").Remotes.CommF_:InvokeServer("StartQuest", quest.Quest, quest.ID)
                    end
                else
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
                        -- Se o mob não existir, voa alto para o centro da área de spawn
                        SmoothMove(quest.FarmPos * CFrame.new(0, 20, 0))
                    end
                end
            end)
        end
    end
end)

-- 3. ESP E FRUTAS
spawn(function()
    while task.wait(0.5) do
        if _G.FruitESP or _G.AutoCollectFruit then
            for _, v in pairs(workspace:GetChildren()) do
                if v:IsA("Tool") and v:FindFirstChild("Handle") then
                    if _G.FruitESP and not v.Handle:FindFirstChild("FruitESP") then
                        local gui = Instance.new("BillboardGui", v.Handle)
                        gui.Name = "FruitESP"; gui.Size = UDim2.new(0,100,0,40); gui.AlwaysOnTop = true
                        local txt = Instance.new("TextLabel", gui)
                        txt.Size = UDim2.new(1,0,1,0); txt.BackgroundTransparency = 1; txt.Text = "🍎 "..v.Name; txt.TextColor3 = Color3.fromRGB(255,0,0); txt.TextScaled = true
                    end
                    if _G.AutoCollectFruit then
                        v.Handle.CFrame = game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame
                    end
                end
            end
        end
        if _G.AutoStoreFruit then
            for _, v in pairs(game.Players.LocalPlayer.Backpack:GetChildren()) do
                if v:IsA("Tool") and (v.Name:find("Fruit") or v.Name:find("Fruta")) then
                    game:GetService("ReplicatedStorage").Remotes.CommF_:InvokeServer("StoreFruit", v:GetAttribute("FruitName") or v.Name, v)
                end
            end
        end
    end
end)

-- 4. PLAYER ESP
spawn(function()
    while task.wait(1) do
        if _G.PlayerESP then
            for _, plr in pairs(game.Players:GetPlayers()) do
                if plr ~= game.Players.LocalPlayer and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
                    local hrp = plr.Character.HumanoidRootPart
                    if not hrp:FindFirstChild("PlayerESP") then
                        local gui = Instance.new("BillboardGui", hrp)
                        gui.Name = "PlayerESP"; gui.Size = UDim2.new(0,100,0,40); gui.AlwaysOnTop = true
                        local txt = Instance.new("TextLabel", gui)
                        txt.Size = UDim2.new(1,0,1,0); txt.BackgroundTransparency = 1; txt.Text = plr.Name; txt.TextColor3 = Color3.fromRGB(0,255,0); txt.TextScaled = true
                    end
                end
            end
        else
            for _, plr in pairs(game.Players:GetPlayers()) do
                if plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
                    local e = plr.Character.HumanoidRootPart:FindFirstChild("PlayerESP")
                    if e then e:Destroy() end
                end
            end
        end
    end
end)

-- INTERFACE
Tabs.Main:AddToggle("FarmToggle", {Title = "Auto Farm", Default = false, Callback = function(v) _G.AutoFarm = v end})
Tabs.Main:AddToggle("AttackToggle", {Title = "Auto Clique", Default = false, Callback = function(v) _G.AutoAttack = v end})

Tabs.Visuals:AddSection("ESP")
Tabs.Visuals:AddToggle("PlayerESPToggle", {Title = "ESP Jogadores", Default = false, Callback = function(v) _G.PlayerESP = v end})
Tabs.Visuals:AddToggle("FruitESPToggle", {Title = "ESP Frutas", Default = false, Callback = function(v) _G.FruitESP = v end})

Tabs.Visuals:AddSection("Frutas")
Tabs.Visuals:AddToggle("CollectToggle", {Title = "Auto Coletar", Default = false, Callback = function(v) _G.AutoCollectFruit = v end})
Tabs.Visuals:AddToggle("StoreToggle", {Title = "Auto Armazenar", Default = false, Callback = function(v) _G.AutoStoreFruit = v end})

Window:SelectTab(1)
