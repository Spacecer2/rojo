local ServerScriptService = game:GetService("ServerScriptService")
local Services = ServerScriptService.Services

local PlayerService = require(Services.PlayerService)
local LeaderboardService = require(Services.LeaderboardService)
local MatchmakingService = require(Services.MatchmakingService)
local ChallengeService = require(Services.ChallengeService)
local DataService = require(Services.DataService)
local LoadoutService = require(Services.LoadoutService)
local WeaponService = require(Services.WeaponService)
local GunsmithService = require(Services.GunsmithService)
local MarketplaceService = require(Services.MarketplaceService)
local MovementValidationService = require(Services.MovementValidationService)
local CheaterManagementService = require(Services.CheaterManagementService)
local DevCommandService = require(Services.DevCommandService)

local LootService = require(Services.LootService)

-- Initialize Services in order
DataService.Init()
PlayerService.Init()
LeaderboardService.Init()
MarketplaceService.Init()
MatchmakingService.Init()
LoadoutService.Init()
GunsmithService.Init() -- Initialize before WeaponService (WeaponService depends on it)
WeaponService.Init()
ChallengeService.Init()
CheaterManagementService.Init() -- Initialize before MovementValidationService
MovementValidationService.Init()
LootService.Init()
DevCommandService.Init() -- Developer console commands

print("Server initialized with all foundational services")
