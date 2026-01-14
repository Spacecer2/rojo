local ServerScriptService = game:GetService("ServerScriptService")
local Services = ServerScriptService.Services

local PlayerService = require(Services.PlayerService)
local LeaderboardService = require(Services.LeaderboardService)
local MatchmakingService = require(Services.MatchmakingService)
local ChallengeService = require(Services.ChallengeService)
local DataService = require(Services.DataService)
local LoadoutService = require(Services.LoadoutService)

-- Initialize Services in order
DataService.Init()
PlayerService.Init()
LeaderboardService.Init()
MatchmakingService.Init()
LoadoutService.Init()
ChallengeService.Init()

print("Server initialized with all foundational services")
