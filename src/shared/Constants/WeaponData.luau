--[[
	WeaponData - Configuration for all base weapons
	Defines default stats and available attachment slots.
]]

local WeaponData = {
	Weapons = {
		["M4"] = {
			Name = "M4",
			Category = "Assault Rifle",
			Description = "A versatile, reliable assault rifle with a high rate of fire.",
			BaseStats = {
				Damage = { Head = 35, Chest = 28, Stomach = 28, Limbs = 24 },
				FireRate = 800, -- RPM
				Recoil = { Vertical = 1.0, Horizontal = 0.2 },
				Range = { Min = 30, Max = 100 }, -- Studs
				Mobility = { MovementSpeed = 1.0, ADSSpeed = 0.25 }, -- Multiplier and Seconds
				MagazineSize = 30,
				ReloadTime = 2.2,
			},
			Slots = {
				"Muzzle",
				"Barrel",
				"Laser",
				"Optic",
				"Stock",
				"RearGrip",
				"Magazine",
				"Underbarrel",
				"Ammunition"
			}
		},
		["Lachmann Sub"] = {
			Name = "Lachmann Sub",
			Category = "Submachine Gun",
			Description = "A compact SMG with excellent mobility and close-quarters dominance.",
			BaseStats = {
				Damage = { Head = 40, Chest = 25, Stomach = 25, Limbs = 20 },
				FireRate = 850,
				Recoil = { Vertical = 0.8, Horizontal = 0.4 },
				Range = { Min = 15, Max = 50 },
				Mobility = { MovementSpeed = 1.05, ADSSpeed = 0.18 },
				MagazineSize = 30,
				ReloadTime = 1.8,
			},
			Slots = {
				"Muzzle",
				"Barrel",
				"Laser",
				"Optic",
				"Stock",
				"RearGrip",
				"Magazine",
				"Underbarrel",
				"Ammunition"
			}
		},
		["P890"] = {
			Name = "P890",
			Category = "Handgun",
			Description = "A semi-automatic pistol chambered in .45 Auto, offering stopping power and reliability.",
			BaseStats = {
				Damage = { Head = 50, Chest = 34, Stomach = 34, Limbs = 30 },
				FireRate = 350,
				Recoil = { Vertical = 1.2, Horizontal = 0.1 },
				Range = { Min = 10, Max = 30 },
				Mobility = { MovementSpeed = 1.1, ADSSpeed = 0.12 },
				MagazineSize = 8,
				ReloadTime = 1.5,
			},
			Slots = {
				"Muzzle",
				"Laser",
				"Optic",
				"TriggerAction",
				"Magazine",
				"Ammunition"
			}
		},
		["M13B"] = {
			Name = "M13B",
			Category = "Assault Rifle",
			Description = "Featuring a short-stroke piston system that allows for a high rate of fire and low recoil.",
			BaseStats = {
				Damage = { Head = 30, Chest = 24, Stomach = 24, Limbs = 20 },
				FireRate = 900,
				Recoil = { Vertical = 0.7, Horizontal = 0.1 },
				Range = { Min = 25, Max = 80 },
				Mobility = { MovementSpeed = 1.02, ADSSpeed = 0.22 },
				MagazineSize = 30,
				ReloadTime = 2.0,
			},
			Slots = {
				"Muzzle", "Barrel", "Laser", "Optic", "Stock", "RearGrip", "Magazine", "Underbarrel", "Ammunition"
			}
		},
		["X12"] = {
			Name = "X12",
			Category = "Handgun",
			Description = "A lightweight semi-auto 9mm pistol with specialized trigger for fast firing.",
			BaseStats = {
				Damage = { Head = 40, Chest = 28, Stomach = 28, Limbs = 24 },
				FireRate = 450,
				Recoil = { Vertical = 0.9, Horizontal = 0.1 },
				Range = { Min = 12, Max = 35 },
				Mobility = { MovementSpeed = 1.1, ADSSpeed = 0.1 },
				MagazineSize = 17,
				ReloadTime = 1.4,
			},
			Slots = {
				"Muzzle", "Laser", "Optic", "TriggerAction", "Magazine", "Ammunition"
			}
		},
		["Knife"] = {
			Name = "Knife",
			Category = "Melee",
			Description = "Tactical combat knife for quick and silent eliminations.",
			BaseStats = {
				Damage = { Head = 135, Chest = 135, Stomach = 135, Limbs = 135 },
				FireRate = 120,
				Recoil = { Vertical = 0, Horizontal = 0 },
				Range = { Min = 5, Max = 5 },
				Mobility = { MovementSpeed = 1.2, ADSSpeed = 0 },
				MagazineSize = 1,
				ReloadTime = 0,
			},
			Slots = {}
		}
	}
}

return WeaponData
