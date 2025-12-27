local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "👑 GOLD HUB | SEA 1 EDITION",
   LoadingTitle = "Carregando Módulos Sea 1...",
   LoadingSubtitle = "by Gemini AI",
   ConfigurationSaving = {
      Enabled = true,
      FolderName = "GoldHubSea1",
      FileName = "Config"
   }
})

-- [[ VARIÁVEIS ]]
local LP = game.Players.LocalPlayer
local RS = game:GetService("ReplicatedStorage")
local CommF = RS.Remotes.CommF_
_G.AutoFarm = false
_G.AutoStats = false

-- [[ ABAS ]]
local TabFarm = Window:CreateTab("Auto Farm 🚜", 4483362458)
local TabCombat = Window:CreateTab("Combate ⚔️", 4483362458)
local TabTeleport = Window:CreateTab("Teleportes 🌍", 4483362458)

-- [[ ABA AUTO FARM ]]
TabFarm:CreateSection("Farm de Nível")

TabFarm:CreateToggle({
   Name = "Auto Farm Level (Sea 1)",
   CurrentValue = false,
   Callback = function(Value)
      _G.AutoFarm = Value
      spawn(function()
         while _G.AutoFarm do
            pcall(function()
               -- Lógica simplificada de busca de Quest e NPC do Sea 1
               local enemy = workspace.Enemies:FindFirstChildOfClass("Model")
               if enemy and enemy:FindFirstChild("Humanoid") and enemy.Humanoid.Health > 0 then
                  repeat
                     wait()
                     -- Posição segura em cima do mob
                     LP.Character.HumanoidRootPart.CFrame = enemy.HumanoidRootPart.CFrame * CFrame.new(0, 20, 0)
                     game:GetService("VirtualUser"):CaptureController()
                     game:GetService("VirtualUser"):ClickButton1(Vector2.new(851, 158))
                  until not _G.AutoFarm or enemy.Humanoid.Health <= 0
               end
            end)
            wait(1)
         end
      end)
   end,
})

TabFarm:CreateToggle({
   Name = "Auto Stats (Points)",
   CurrentValue = false,
   Callback = function(Value)
      _G.AutoStats = Value
      spawn(function()
         while _G.AutoStats do
            wait(2)
            local points = LP.Data.StatsPoints.Value
            if points > 0 then
                CommF:InvokeServer("AddPoint", "Melee", points)
            end
         end
      end)
   end,
})

-- [[ ABA COMBATE ]]
TabCombat:CreateSection("Auxílios de Luta")

TabCombat:CreateToggle({
   Name = "Auto Haki de Armamento",
   CurrentValue = true,
   Callback = function(Value)
      _G.AutoHaki = Value
      spawn(function()
         while _G.AutoHaki do
            wait(5)
            if not LP.Character:FindFirstChild("HasBuso") then
               CommF:InvokeServer("Buso")
            end
         end
      end)
   end,
})

-- [[ ABA TELEPORTES ]]
TabTeleport:CreateSection("Ilhas Principais Sea 1")

local Islands = {
   ["Início (Pirates/Marines)"] = CFrame.new(1060, 16, 1420),
   ["Selva (Jungle)"] = CFrame.new(-1250, 6, 350),
   ["Deserto"] = CFrame.new(900, 6, 4400),
   ["Vila de Neve"] = CFrame.new(1200, 6, -1300),
   ["Marineford"] = CFrame.new(-4500, 20, 4200),
   ["Skypiea (Céu)"] = CFrame.new(-4800, 900, -1900)
}

for name, cf in pairs(Islands) do
   TabTeleport:CreateButton({
      Name = "Ir para: "..name,
      Callback = function()
         LP.Character.HumanoidRootPart.CFrame = cf
      end,
   })
end

Rayfield:Notify({Title = "GOLD HUB SEA 1", Content = "Script carregado com sucesso!", Duration = 5})
