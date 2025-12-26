-- GOLD HUB | Loader Oficial
print("Iniciando GOLD HUB...")

local PlaceId = game.PlaceId
local BaseURL = "https://raw.githubusercontent.com/SEU_USUARIO/GOLD-HUB/main/scripts/"

if PlaceId == 2753915549 then
    loadstring(game:HttpGet(BaseURL .. "Sea1.lua"))()
elseif PlaceId == 4442272183 then
    loadstring(game:HttpGet(BaseURL .. "Sea2.lua"))()
elseif PlaceId == 7449423635 then
    loadstring(game:HttpGet(BaseURL .. "Sea3.lua"))()
else
    game.Players.LocalPlayer:Kick("GOLD HUB: Mundo não suportado!")
end
