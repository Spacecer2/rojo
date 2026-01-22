--[[
	GulagConfig - Configuration for the Gulag 1v1 arena
]]

local GulagConfig = {
	MAX_QUEUE_TIME = 60, -- Seconds to wait for opponent before auto-win (test only) or loss
	PREP_TIME = 15, -- Preparation phase duration
	MATCH_DURATION = 300, -- 5 minutes
	OVERTIME_DAMAGE = 5, -- Per second during sudden death
	
	WEAPONS = {
		Primary = {"M4", "Intervention"},
		Secondary = {"Glock"},
	},
	
	ARENA = {
		Center = Vector3.new(0, 1000, 0), -- Far away from main map
		Size = Vector2.new(100, 100),
		SpawnA = Vector3.new(0, 1000, 40),
		SpawnB = Vector3.new(0, 1000, -40),
	}
}

return GulagConfig
