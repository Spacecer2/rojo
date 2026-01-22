local ServerScriptService = game:GetService("ServerScriptService")
local Services = ServerScriptService.Services

local PlayerService = require(Services.PlayerService)
local LeaderboardService = require(Services.LeaderboardService)
local MatchmakingService = require(Services.MatchmakingService)
local ChallengeService = require(Services.ChallengeService)
local DataService = require(Services.DataService)
local LoadoutService = require(Services.LoadoutService)
local WeaponService = require(Services.WeaponService)
local MarketplaceService = require(Services.MarketplaceService)

local LootService = require(Services.LootService)

-- Initialize Services in order
DataService.Init()
PlayerService.Init()
LeaderboardService.Init()
MarketplaceService.Init()
MatchmakingService.Init()
LoadoutService.Init()
WeaponService.Init()
ChallengeService.Init()
LootService.Init()

print("Server initialized with all foundational services")
