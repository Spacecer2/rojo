--[[
	EconomyData - Buy Station items and prices
]]

local EconomyData = {
	BuyStationItems = {
		{
			Name = "Armor Plate Bundle",
			Price = 1500,
			Description = "A bundle of 3 armor plates.",
			Action = "GiveItem",
			Args = { Item = "ArmorPlate", Count = 3 }
		},
		{
			Name = "UAV",
			Price = 4000,
			Description = "Deploys a UAV to reveal enemy positions on the minimap.",
			Action = "ActivateKillstreak",
			Args = { Streak = "UAV" }
		},
		{
			Name = "Precision Airstrike",
			Price = 3500,
			Description = "Call in twin A-10 Warthogs for a strafing run.",
			Action = "ActivateKillstreak",
			Args = { Streak = "PrecisionAirstrike" }
		},
		{
			Name = "Self-Revive Kit",
			Price = 4000,
			Description = "Allows you to revive yourself when downed.",
			Action = "GivePerk",
			Args = { Perk = "SelfRevive" }
		},
		{
			Name = "Loadout Drop Marker",
			Price = 10000,
			Description = "Call in a personal loadout drop.",
			Action = "GiveItem",
			Args = { Item = "LoadoutMarker" }
		}
	}
}

return EconomyData
