local ServerScriptService = game:GetService("ServerScriptService")
local Services = ServerScriptService.Services

local PlayerService = require(Services.PlayerService)
local LeaderboardService = require(Services.LeaderboardService)
local MatchmakingService = require(Services.MatchmakingService)
local LoadoutService = require(Services.LoadoutService)

-- Initialize Services in order
PlayerService.Init()
LeaderboardService.Init()
MatchmakingService.Init()
LoadoutService.Init()

print("Server initialized with all foundational services")
