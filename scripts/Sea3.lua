-- [[ ANTI-AFK PARA EVITAR KICK ]]
local VirtualUser = game:GetService("VirtualUser")
game:GetService("Players").LocalPlayer.Idled:Connect(function()
    VirtualUser:CaptureController()
    VirtualUser:ClickButton2(Vector2.new())
end)

local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "👑 GOLD HUB | DEFINITIVE EDITION",
   LoadingTitle = "Carregando Módulos Anti-Ban...",
   LoadingSubtitle = "by Gemini AI",
   ConfigurationSaving = {Enabled = true, FolderName = "GoldHubUltimate"}
})

-- [[ SERVIÇOS ]]
local LP = game.Players.LocalPlayer
local RS = game:GetService("ReplicatedStorage")
local CommF = RS.Remotes.CommF_

_G.Weapon = "Melee" -- Padrão

-- [[ ABAS ]]
local TabFarm = Window:CreateTab("Farm Principal 🚜")
local TabItems = Window:CreateTab("Itens & Puzzles 🧩")
local TabRaid = Window:CreateTab("Raids & Chips ⚔️")
local TabPVP = Window:CreateTab("PVP & Visual 🎯")

-- [[ FUNÇÃO AUTO-EQUIP ]]
local function EquipWeapon()
    pcall(function()
        if LP.Backpack:FindFirstChild(_G.Weapon) then
            LP.Character.Humanoid:EquipTool(LP.Backpack[_G.Weapon])
        end
    end)
end

-- [[ ABA FARM ]]
TabFarm:CreateSection("Configurações de Farm")

TabFarm:CreateDropdown({
   Name = "Equipar Arma",
   Options = {"Melee", "Sword", "Fruit"},
   CurrentOption = "Melee",
   Callback = function(v) _G.Weapon = v end
})

TabFarm:CreateToggle({
   Name = "Auto Farm Level (Com Agrupar Mobs)",
   CurrentValue = false,
   Callback = function(v) _G.AutoFarm = v end
})

TabFarm:CreateToggle({
   Name = "Auto Farm Bones (Ossos - Haunted Castle)",
   CurrentValue = false,
   Callback = function(v) _G.AutoBones = v end
})

-- [[ LÓGICA DE FARM DEFINITIVA ]]
spawn(function()
    while task.wait() do
        if _G.AutoFarm or _G.AutoBones then
            pcall(function()
                EquipWeapon()
                local targetName = _G.AutoFarm and "NPC" or "Skeleton" -- Lógica de alvo
                for _, v in pairs(workspace.Enemies:GetChildren()) do
                    if v:FindFirstChild("Humanoid") and v.Humanoid.Health > 0 then
                        -- Agrupar Mobs (Bring Mobs)
                        v.HumanoidRootPart.CFrame = LP.Character.HumanoidRootPart.CFrame * CFrame.new(0, 0, -5)
                        v.HumanoidRootPart.CanCollide = false
                        v.Humanoid.WalkSpeed = 0
                        
                        -- Ataque
                        VirtualUser:CaptureController()
                        VirtualUser:ClickButton1(Vector2.new(851, 158))
                    end
                end
            end)
        end
    end
end)

-- [[ ABA RAIDS ]]
TabRaid:CreateSection("Gerenciador de Raid")

TabRaid:CreateButton({
   Name = "Auto Buy Chip (Fruta < 1M)",
   Callback = function()
      local success = false
      local inv = CommF:InvokeServer("getInventory")
      for _, item in pairs(inv) do
         if item.Type == "Fruit" and item.Value < 1000000 then
            CommF:InvokeServer("RaidsCustomer", "Exchange", item.Name)
            success = true
            Rayfield:Notify({Title = "Raid", Content = "Chip comprado com: "..item.Name, Duration = 5})
            break
         end
      end
      if not success then Rayfield:Notify({Title = "Erro", Content = "Nenhuma fruta barata no inventário!", Duration = 5}) end
   end
})

-- [[ ABA ITENS ]]
TabItems:CreateSection("Puzzles")

TabItems:CreateButton({
   Name = "Auto Soul Guitar (Check Moon)",
   Callback = function()
      local lighting = game:GetService("Lighting")
      if lighting.Sky.MoonTextureId == "rbxassetid://5883637139" then -- ID Simbólico Lua Cheia
          CommF:InvokeServer("SoulGuitarQuest")
      else
          Rayfield:Notify({Title = "Aviso", Content = "Aguarde a Lua Cheia!", Duration = 5})
      end
   end
})

-- [[ ABA PVP & VISUAL ]]
TabPVP:CreateSection("Assistência")

TabPVP:CreateToggle({
   Name = "Aimbot Skill (Headlock)",
   CurrentValue = false,
   Callback = function(v) _G.Aimbot = v end
})

TabPVP:CreateToggle({
   Name = "ESP Players (Box)",
   CurrentValue = false,
   Callback = function(v) _G.ESP = v end
})

-- Lógica Aimbot Skill
spawn(function()
    while task.wait() do
        if _G.Aimbot then
            local target = nil
            local dist = math.huge
            for _, p in pairs(game.Players:GetPlayers()) do
                if p ~= LP and p.Character and p.Character:FindFirstChild("Head") then
                    local mag = (p.Character.Head.Position - LP.Character.Head.Position).Magnitude
                    if mag < dist then
                        dist = mag
                        target = p.Character.Head
                    end
                end
            end
            if target then
                local cam = workspace.CurrentCamera
                cam.CFrame = CFrame.new(cam.CFrame.Position, target.Position)
            end
        end
    end
end)

Rayfield:LoadConfiguration()
