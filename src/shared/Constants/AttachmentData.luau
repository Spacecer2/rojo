--[[ 
	AttachmentData - Configuration for all weapon attachments
	Defines stat modifiers and visual attributes.
]]

local AttachmentData = {
	Attachments = {
		-- OPTICS
		["Slimline Pro"] = {
			Name = "Slimline Pro",
			Category = "Optic",
			Description = "A compact red dot sight for quick target acquisition.",
			Modifiers = {
				ADSSpeed = 0.01, -- Slight penalty (in seconds)
				ZoomMultiplier = 1.25,
			},
			AssetId = "rbxassetid://0", -- Placeholder
		},
		["VLK 4.0 Optic"] = {
			Name = "VLK 4.0 Optic",
			Category = "Optic",
			Description = "A 4.0x magnification optic for medium-range engagements.",
			Modifiers = {
				ADSSpeed = 0.04,
				ZoomMultiplier = 4.0,
				RecoilControl = 0.1, -- 10% reduction in vertical recoil
			},
			AssetId = "rbxassetid://0",
		},

		-- MUZZLES
		["Monolithic Suppressor"] = {
			Name = "Monolithic Suppressor",
			Category = "Muzzle",
			Description = "Provides sound suppression and increased range.",
			Modifiers = {
				SoundSuppressed = true,
				Range = 0.1, -- 10% increase
				ADSSpeed = 0.02,
				RecoilControl = 0.05,
			},
			AssetId = "rbxassetid://0",
		},
		["Flash Guard"] = {
			Name = "Flash Guard",
			Category = "Muzzle",
			Description = "Reduces muzzle flash and provides slight recoil control.",
			Modifiers = {
				MuzzleFlashVisible = false,
				RecoilControl = 0.02,
			},
			AssetId = "rbxassetid://0",
		},

		-- BARRELS
		["Tempus Hightower 20\" Barrel"] = {
			Name = "Tempus Hightower 20\" Barrel",
			Category = "Barrel",
			Description = "A long barrel that increases bullet velocity and range.",
			Modifiers = {
				Range = 0.2,
				BulletVelocity = 0.2,
				ADSSpeed = 0.05,
				MovementSpeed = -0.05,
				RecoilControl = 0.15,
			},
			AssetId = "rbxassetid://0",
		},

		-- MAGAZINES
		["45 Round Mag"] = {
			Name = "45 Round Mag",
			Category = "Magazine",
			Description = "Extended magazine increasing ammo capacity.",
			Modifiers = {
				MagazineSize = 15, -- Adds 15 rounds
				MovementSpeed = -0.03,
				ADSSpeed = 0.02,
				ReloadTime = 0.2,
			},
			AssetId = "rbxassetid://0",
		},
		
		-- UNDERBARRELS
		["Commando Foregrip"] = {
			Name = "Commando Foregrip",
			Category = "Underbarrel",
			Description = "Angled grip for improved recoil stabilization and aiming stability.",
			Modifiers = {
				HorizontalRecoilControl = 0.1,
				AimingStability = 0.15,
				MovementSpeed = -0.02,
			},
			AssetId = "rbxassetid://0",
		}
	}
}

return AttachmentData
