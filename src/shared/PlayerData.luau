local PlayerData = {}
PlayerData.__index = PlayerData

function PlayerData.new(player)
	local self = setmetatable({}, PlayerData)
	self.Player = player
	self.Data = {
		Level = 1,
		RankTitle = "PRIVATE",
		Experience = 0,
		MaxExperience = 1000,
		Currency = 0,
		XPBoost = 0,
		ActiveMission = {
			Title = "None",
			Objective = "Select a mission to begin.",
			Progress = 0,
			Goal = 1
		},
		Challenges = {
			{Id = "RECON_CONTRACTS", Title = "Complete 5 'Recon' Contract(s)", Progress = 0, Goal = 5, XP = 2500},
			{Id = "AIRPORT_CONTRACTS", Title = "Start 3 Contract(s) at Airport", Progress = 0, Goal = 3, XP = 1500},
			{Id = "OPEN_CACHES", Title = "Open 10 Caches", Progress = 0, Goal = 10, XP = 1000},
		},
		Inventory = {},
		Settings = {
			FOV = 103,
			Sensitivity = 1.2
		}
	}
	return self
end

return PlayerData