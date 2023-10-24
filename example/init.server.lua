local playersService = game:GetService("Players")

local greedyDataService = require(script.Parent.GreedyDataService)

local function playerAdded(player : Player)
    print("playerAdded")
    greedyDataService:loadPlayer(player)
end

for _, player in playersService:GetPlayers() do
    playerAdded(player)
end

playersService.PlayerAdded:Connect(playerAdded)