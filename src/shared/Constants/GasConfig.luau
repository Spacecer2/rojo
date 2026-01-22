--[[
	GasConfig - Configuration for the Battle Royale Gas System
	Defines phases, damage, and timing for the contracting circle.
]]

local GasConfig = {
	-- Initial state before game starts
	START_DELAY = 60, -- Seconds before first circle starts moving
	
	PHASES = {
		[1] = {
			Radius = 1000,
			Damage = 1, -- Per second
			WaitDuration = 120, -- Seconds to wait before contracting
			ContractDuration = 90, -- Seconds to finish contracting
		},
		[2] = {
			Radius = 600,
			Damage = 2,
			WaitDuration = 90,
			ContractDuration = 60,
		},
		[3] = {
			Radius = 300,
			Damage = 5,
			WaitDuration = 60,
			ContractDuration = 45,
		},
		[4] = {
			Radius = 100,
			Damage = 10,
			WaitDuration = 45,
			ContractDuration = 30,
		},
		[5] = {
			Radius = 20,
			Damage = 20,
			WaitDuration = 30,
			ContractDuration = 30,
		},
		[6] = {
			Radius = 0,
			Damage = 40,
			WaitDuration = 30,
			ContractDuration = 60, -- Final collapse
		}
	},
	
	-- Visuals
	VISUALS = {
		BoundaryColor = Color3.fromRGB(150, 50, 200),
		DistortionRange = 50, -- Studs from edge where effects start
		GasTransparency = 0.4,
	}
}

return GasConfig
