local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()

local Window = Fluent:CreateWindow({
    Title = "GOLD HUB | SEA 1",
    SubTitle = "v1.8 - Real Smooth Flight",
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

-- FUNÇÃO DE VOO REAL
function SmoothMove(TargetCFrame)
    local Character = game.Players.LocalPlayer.Character
    local Root = Character:FindFirstChild("HumanoidRootPart")
    
    if Root and _G.AutoFarm then
        local Distance = (TargetCFrame.Position - Root.Position).Magnitude
        local Speed = 250
        
        if CurrentTween then CurrentTween:Cancel() end
        
        CurrentTween = game:GetService("TweenService"):Create(
            Root,
            TweenInfo.new(Distance/Speed, Enum.EasingStyle.Linear),
            {CFrame = TargetCFrame}
        )
        CurrentTween:Play()
    elseif CurrentTween and not _G.AutoFarm then
        CurrentTween:Cancel()
    end
end

-- 1. AUTO ATAQUE (CORRIGIDO)
spawn(function()
    while task.wait(0.15) do
        if _G.AutoAttack then
            pcall(function()
                local player = game.Players.LocalPlayer
                local char = player.Character
                if not char then return end

                local tool = char:FindFirstChildOfClass("Tool")

                if not tool then
                    local bp = player:FindFirstChild("Backpack")
                    if bp then
                        local bpTool = bp:FindFirstChildOfClass("Tool")
                        if bpTool then
                            char.Humanoid:EquipTool(bpTool)
                            tool = bpTool
                        end
                    end
                end

                if tool then
                    tool:Activate()
                end
            end)
        end
    end
end)

-- 2. AUTO FARM (INALTERADO)
spawn(function()
    while task.wait(0.1) do
        if _G.AutoFarm then
            pcall(function()
                local lp = game.Players.LocalPlayer
                local lvl = lp.Data.Level.Value
                local char = lp.Character
                
                for _, v in pairs(char:GetDescendants()) do
                    if v:IsA("BasePart") then
                        v.CanCollide = false
                    end
                end

                char.HumanoidRootPart.Velocity = Vector3.new(0,0,0)

                if not lp.PlayerGui.Main.Quest.Visible then
                    local targetPos = CFrame.new(1059, 16, 1546)
                    local qName, qID = "BanditQuest1", 1
                    
                    if lvl >= 15 then 
                        targetPos = CFrame.new(-1598, 37, 153)
                        qName, qID = "JungleQuest", 2
                    end
                    
                    SmoothMove(targetPos)
                    if (char.HumanoidRootPart.Position - targetPos.Position).Magnitude < 10 then
                        game:GetService("ReplicatedStorage").Remotes.CommF_:InvokeServer(
                            "StartQuest", qName, qID
                        )
                    end
                else
                    local monsterName = (lvl >= 15) and "Gorilla" or "Bandit"
                    local target
                    
                    for _, v in pairs(workspace.Enemies:GetChildren()) do
                        if v.Name == monsterName
                        and v:FindFirstChild("Humanoid")
                        and v.Humanoid.Health > 0 then
                            target = v
                            break
                        end
                    end
                    
                    if target then
                        SmoothMove(target.HumanoidRootPart.CFrame * CFrame.new(0, 8, 0))
                    end
                end
            end)
        else
            if CurrentTween then CurrentTween:Cancel() end
        end
    end
end)

-- 3. ESP DE FRUTAS
spawn(function()
    while task.wait(1) do
        if _G.FruitESP then
            for _, v in pairs(workspace:GetChildren()) do
                if v:IsA("Tool") and v:FindFirstChild("Handle") then
                    if not v.Handle:FindFirstChild("FruitESP") then
                        local gui = Instance.new("BillboardGui", v.Handle)
                        gui.Name = "FruitESP"
                        gui.Size = UDim2.new(0, 100, 0, 40)
                        gui.AlwaysOnTop = true

                        local txt = Instance.new("TextLabel", gui)
                        txt.Size = UDim2.new(1,0,1,0)
                        txt.BackgroundTransparency = 1
                        txt.Text = "🍎 FRUTA"
                        txt.TextColor3 = Color3.fromRGB(255,0,0)
                        txt.TextScaled = true
                        txt.Font = Enum.Font.SourceSansBold
                    end
                end
            end
        else
            for _, v in pairs(workspace:GetDescendants()) do
                if v.Name == "FruitESP" then
                    v:Destroy()
                end
            end
        end
    end
end)

-- 4. ESP DE PLAYERS
spawn(function()
    while task.wait(1) do
        if _G.PlayerESP then
            for _, plr in pairs(game.Players:GetPlayers()) do
                if plr ~= game.Players.LocalPlayer and plr.Character then
                    local head = plr.Character:FindFirstChild("Head")
                    if head and not head:FindFirstChild("PlayerESP") then
                        local gui = Instance.new("BillboardGui", head)
                        gui.Name = "PlayerESP"
                        gui.Size = UDim2.new(0, 100, 0, 40)
                        gui.AlwaysOnTop = true

                        local txt = Instance.new("TextLabel", gui)
                        txt.Size = UDim2.new(1,0,1,0)
                        txt.BackgroundTransparency = 1
                        txt.Text = plr.Name
                        txt.TextColor3 = Color3.fromRGB(0,255,0)
                        txt.TextScaled = true
                        txt.Font = Enum.Font.SourceSansBold
                    end
                end
            end
        else
            for _, v in pairs(workspace:GetDescendants()) do
                if v.Name == "PlayerESP" then
                    v:Destroy()
                end
            end
        end
    end
end)

-- INTERFACE (INALTERADA)
Tabs.Main:AddToggle("FarmToggle", {
    Title = "Auto Farm (Modo Voo)",
    Default = false,
    Callback = function(v)
        _G.AutoFarm = v
        if not v and CurrentTween then CurrentTween:Cancel() end
    end
})

Tabs.Main:AddToggle("AttackToggle", {
    Title = "Auto Clique",
    Default = false,
    Callback = function(v) _G.AutoAttack = v end
})

Tabs.Visuals:AddSection("Sistema de ESP")
Tabs.Visuals:AddToggle("FruitESPToggle", {
    Title = "ESP de Frutas",
    Default = false,
    Callback = function(v) _G.FruitESP = v end
})

Tabs.Visuals:AddToggle("PlayerESPToggle", {
    Title = "ESP de Jogadores",
    Default = false,
    Callback = function(v) _G.PlayerESP = v end
})

Tabs.Visuals:AddSection("Opções de Fruta")
Tabs.Visuals:AddToggle("CollectToggle", {Title = "Auto Coletar", Default = false, Callback = function(v) _G.AutoCollectFruit = v end})
Tabs.Visuals:AddToggle("StoreToggle", {Title = "Auto Armazenar", Default = false, Callback = function(v) _G.AutoStoreFruit = v end})
