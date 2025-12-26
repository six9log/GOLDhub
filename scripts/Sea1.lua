local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()

local Window = Fluent:CreateWindow({
    Title = "GOLD HUB | SEA 1",
    SubTitle = "BlueX Base + Fruit Finder",
    TabWidth = 160,
    Size = UDim2.fromOffset(580, 460),
    Acrylic = false,
    Theme = "Dark"
})

local Tabs = { 
    Main = Window:AddTab({ Title = "Farm", Icon = "home" }),
    Fruits = Window:AddTab({ Title = "Frutas", Icon = "apple" })
}

_G.AutoFarm = false
_G.AutoAttack = false
_G.FruitESP = false

-- 1. SISTEMA DE FRUTAS (ESP, COLLECT, STORE)
spawn(function()
    while task.wait(1) do
        if _G.FruitESP then
            for _, v in pairs(workspace:GetChildren()) do
                if v:IsA("Tool") and v:FindFirstChild("Handle") and not v:FindFirstChild("FruitESP") then
                    local bill = Instance.new("BillboardGui", v)
                    bill.Name = "FruitESP"
                    bill.AlwaysOnTop = true
                    bill.Size = UDim2.new(0, 100, 0, 50)
                    bill.ExtentsOffset = Vector3.new(0, 3, 0)
                    
                    local label = Instance.new("TextLabel", bill)
                    label.BackgroundTransparency = 1
                    label.Size = UDim2.new(1, 0, 1, 0)
                    label.TextColor3 = Color3.fromRGB(255, 255, 255)
                    label.TextStrokeTransparency = 0
                    label.TextSize = 14
                    
                    spawn(function()
                        while v:IsDescendantOf(workspace) do
                            local dist = math.floor((game.Players.LocalPlayer.Character.HumanoidRootPart.Position - v.Handle.Position).Magnitude)
                            label.Text = v.Name .. "\n[" .. dist .. "m]"
                            task.wait(0.5)
                        end
                    end)
                end
            end
        end
    end
end)

local function CollectFruit()
    for _, v in pairs(workspace:GetChildren()) do
        if v:IsA("Tool") and v:FindFirstChild("Handle") then
            local root = game.Players.LocalPlayer.Character.HumanoidRootPart
            local tween = game:GetService("TweenService"):Create(root, TweenInfo.new((root.Position - v.Handle.Position).Magnitude/200, Enum.EasingStyle.Linear), {CFrame = v.Handle.CFrame})
            tween:Play()
            tween.Completed:Wait()
            task.wait(0.5)
            -- Auto Storage
            game:GetService("ReplicatedStorage").Remotes.CommF_:InvokeServer("StoreFruit", v:GetAttribute("FruitName"), v)
        end
    end
end

-- 2. SISTEMA DE FARM (BASE ANTERIOR)
spawn(function()
    while task.wait() do
        if _G.AutoAttack then
            pcall(function()
                local char = game.Players.LocalPlayer.Character
                local tool = game.Players.LocalPlayer.Backpack:FindFirstChildOfClass("Tool") or char:FindFirstChildOfClass("Tool")
                if tool and not char:FindFirstChild(tool.Name) then
                    char.Humanoid:EquipTool(tool)
                end
                if char:FindFirstChildOfClass("Tool") then
                    game:GetService("VirtualUser"):CaptureController()
                    game:GetService("VirtualUser"):Button1Down(Vector2.new(100, 100))
                end
            end)
        end
    end
end)

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
                if monster and monster:FindFirstChild("Humanoid") and monster.Humanoid.Health > 0 then
                    root.CFrame = monster.HumanoidRootPart.CFrame * CFrame.new(0, 8, 0)
                else
                    root.CFrame = CFrame.new(1145, 20, 1630)
                end
            end
        end)
    end
end)

-- 3. INTERFACE
Tabs.Main:AddToggle("FarmToggle", {Title = "Auto Farm Bandits", Default = false, Callback = function(v) _G.AutoFarm = v end})
Tabs.Main:AddToggle("AttackToggle", {Title = "Fast Attack", Default = false, Callback = function(v) _G.AutoAttack = v end})

Tabs.Fruits:AddToggle("ESPToggle", {Title = "ESP Frutas (Nome/Distância)", Default = false, Callback = function(v) _G.FruitESP = v end})
Tabs.Fruits:AddButton({
    Title = "Coletar e Guardar Frutas",
    Description = "Voa até as frutas no chão e guarda no baú",
    Callback = function()
        CollectFruit()
    end
})
