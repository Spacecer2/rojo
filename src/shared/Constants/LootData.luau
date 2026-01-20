--[[
	LootData - Configuration for items, rarities, and containers
]]

local LootData = {
	Rarities = {
		Common = { Color = Color3.fromRGB(200, 200, 200), Weight = 0.60 },
		Uncommon = { Color = Color3.fromRGB(50, 200, 50), Weight = 0.25 },
		Rare = { Color = Color3.fromRGB(50, 150, 255), Weight = 0.10 },
		Epic = { Color = Color3.fromRGB(180, 50, 255), Weight = 0.04 },
		Legendary = { Color = Color3.fromRGB(255, 200, 50), Weight = 0.01 },
	},
	
	Items = {
		-- CASH
		["Cash_Small"] = { Name = "Cash", Type = "Currency", Value = 100, Model = "CashPile" },
		["Cash_Medium"] = { Name = "Cash", Type = "Currency", Value = 500, Model = "CashStack" },
		["Cash_Large"] = { Name = "Cash Bundle", Type = "Currency", Value = 1000, Model = "CashBundle" },
		
		-- WEAPONS (Referencing WeaponData)
		["M4_Loot"] = { Name = "M4", Type = "Weapon", WeaponName = "M4", Rarity = "Common" },
		["Intervention_Loot"] = { Name = "Intervention", Type = "Weapon", WeaponName = "Intervention", Rarity = "Rare" },
		
		-- CONSUMABLES
		["ArmorPlate"] = { Name = "Armor Plate", Type = "Consumable", MaxStack = 3 },
	},
	
	Containers = {
		SupplyBox = {
			Model = "SupplyBox_Blue",
			HoldTime = 1.5,
			LootCount = {2, 4},
			LootTable = {
				{ Item = "Cash_Small", Weight = 50 },
				{ Item = "Cash_Medium", Weight = 20 },
				{ Item = "M4_Loot", Weight = 15 },
				{ Item = "ArmorPlate", Weight = 15 },
			}
		},
		LootCrate = {
			Model = "LootCrate_Orange",
			HoldTime = 2.0,
			LootCount = {4, 6},
			LootTable = {
				{ Item = "Cash_Medium", Weight = 40 },
				{ Item = "Cash_Large", Weight = 20 },
				{ Item = "Intervention_Loot", Weight = 20 },
				{ Item = "ArmorPlate", Weight = 20 },
			}
		}
	}
}

return LootData
