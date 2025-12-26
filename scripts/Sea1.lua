-- ===============================
-- FLUENT UI
-- ===============================
local Fluent = loadstring(game:HttpGet(
    "https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"
))()

local Window = Fluent:CreateWindow({
    Title = "GOLD HUB | SEA 1 (SUAVE)",
    SubTitle = "por six9log",
    TabWidth = 160,
    Size = UDim2.fromOffset(580, 460),
    Acrylic = false,
    Theme = "Dark"
})

local Tabs = { Main = Window:AddTab({ Title = "Farm", Icon = "home" }) }
local Options = Fluent.Options
_G.AutoFarm = false

-- ===============================
-- SERVIÇOS
-- ===============================
local Players = game:GetService("Players")
local StarterGui = game:GetService("StarterGui")
local ContextActionService = game:GetService("ContextActionService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer

-- ===============================
-- DESATIVA HOTBAR / INVENTÁRIO
-- ===============================
pcall(function()
    StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Backpack, false)
end)

-- ===============================
-- BLOQUEIA INPUT PADRÃO (clique + hotbar)
-- ===============================
local function BlockInput()
    return Enum.ContextActionResult.Sink
end

ContextActionService:BindAction(
    "BlockHotbarAndClick",
    BlockInput,
    false,
    Enum.UserInputType.MouseButton1,
    Enum.KeyCode.One,
    Enum.KeyCode.Two,
    Enum.KeyCode.Three,
    Enum.KeyCode.Four,
    Enum.KeyCode.Five
)

-- ===============================
-- FUNÇÃO DE MOVIMENTO SUAVE (TWEEN)
-- ===============================
function SmoothTween(TargetCFrame)
    local Character = player.Character
    if not Character then return end

    local Root = Character:FindFirstChild("HumanoidRootPart")
    if Root then
        local Distance = (TargetCFrame.Position - Root.Position).Magnitude
        local Speed = 250
        local Tween = TweenService:Create(
            Root,
            TweenInfo.new(Distance / Speed, Enum.EasingStyle.Linear),
            { CFrame = TargetCFrame }
        )
        Tween:Play()
    end
end

-- ===============================
-- FUNÇÃO: FORÇAR COMBAT
-- ===============================
local function EquipCombat()
    local character = player.Character
    if not character then return end

    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if not humanoid then return end

    local tool =
        player.Backpack:FindFirstChild("Combat")
        or player.Backpack:FindFirstChild("Combate")

    if tool and not character:FindFirstChild(tool.Name) then
        humanoid:EquipTool(tool)
    end

    -- Remove qualquer outra tool equipada
    for _, v in ipairs(character:GetChildren()) do
        if v:IsA("Tool") and v.Name ~= "Combat" and v.Name ~= "Combate" then
            v.Parent = player.Backpack
        end
    end
end

-- ===============================
-- LÓGICA DE FARM
-- ===============================
task.spawn(function()
    while true do
        task.wait(0.1)

        if not _G.AutoFarm then
            continue
        end

        pcall(function()
            local character = player.Character
            if not character then return end

            EquipCombat()

            local enemies = workspace:FindFirstChild("Enemies")
            if not enemies then return end

            local Monster = enemies:FindFirstChild("Bandit")
            if Monster
                and Monster:FindFirstChild("Humanoid")
                and Monster:FindFirstChild("HumanoidRootPart")
                and Monster.Humanoid.Health > 0
            then
                -- Fica acima do monstro
                SmoothTween(Monster.HumanoidRootPart.CFrame * CFrame.new(0, 9, 0))

                -- ATAQUE (mantido exatamente como você usa)
                game:GetService("ReplicatedStorage").Remotes.CommF_:InvokeServer(
                    "Attack",
                    Monster.HumanoidRootPart,
                    true
                )
            else
                -- Vai para o spawn
                SmoothTween(CFrame.new(1145, 20, 1630))
            end
        end)
    end
end)

-- ===============================
-- ANTI-QUEDA / NOCLIP
-- ===============================
RunService.Stepped:Connect(function()
    if _G.AutoFarm then
        pcall(function()
            local char = player.Character
            if not char then return end

            for _, v in ipairs(char:GetDescendants()) do
                if v:IsA("BasePart") then
                    v.CanCollide = false
                end
            end
        end)
    end
end)

-- ===============================
-- TOGGLE UI
-- ===============================
Tabs.Main:AddToggle("FarmToggle", {
    Title = "Ligar Auto Farm Suave",
    Default = false
})

Options.FarmToggle:OnChanged(function()
    _G.AutoFarm = Options.FarmToggle.Value
end)
