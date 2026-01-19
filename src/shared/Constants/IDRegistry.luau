--[[
	IDRegistry - Centralized ID management for the entire game
	Single source of truth for all ID definitions and validation
	Provides consistent ID schemas and lookup utilities
	
	Integration Points:
	- OperatorRanking: Tracks operator unlocks and progression
	- IDRegistryUIHelper: Generates dynamic UI from registry data
	- OperatorsView: Displays operators with dynamic metadata
	- PlaylistData: Validates and manages playlist configurations
	
	Metadata Structure:
	- Each category (Playlists, Operators, Challenges) has:
	  - IDs table: Keyed ID definitions
	  - List: Array of all IDs in that category
	  - Metadata: Rich data for each ID (UI, stats, descriptions)
]]

local IDRegistry = {
	Version = "2.0.0", -- Updated with metadata and ranking integration
	LastUpdated = "2026-01-19",
	ChangeLog = {
		["2.0.0"] = "Added comprehensive metadata, ranking integration, UI binding support",
		["1.0.0"] = "Initial release with basic ID validation"
	}
}

-- ============================================================================
-- PLAYLIST IDS
-- ============================================================================
IDRegistry.Playlists = {
	BR_QUADS = "BR_QUADS",
	BR_SOLOS = "BR_SOLOS",
	SCOPES_AND_SCATTER = "SCOPES_AND_SCATTER",
	PLUNDER_QUADS = "PLUNDER_QUADS",
	PRACTICE_BOTS = "PRACTICE_BOTS"
}

IDRegistry.PlaylistList = {
	"BR_QUADS",
	"BR_SOLOS",
	"SCOPES_AND_SCATTER",
	"PLUNDER_QUADS",
	"PRACTICE_BOTS"
}

-- Playlist Metadata for UI Generation
IDRegistry.PlaylistMetadata = {
	BR_QUADS = {
		Name = "Battle Royale Quads",
		Description = "4-player squad battle royale",
		Icon = "rbxassetid://0",
		MaxPlayers = 4,
		GameMode = "Battle Royale",
		Ranking = true
	},
	BR_SOLOS = {
		Name = "Battle Royale Solos",
		Description = "Solo battle royale competition",
		Icon = "rbxassetid://0",
		MaxPlayers = 1,
		GameMode = "Battle Royale",
		Ranking = true
	},
	SCOPES_AND_SCATTER = {
		Name = "Scopes and Scatter",
		Description = "Sniper rifle competition",
		Icon = "rbxassetid://0",
		MaxPlayers = 2,
		GameMode = "Limited",
		Ranking = false
	},
	PLUNDER_QUADS = {
		Name = "Plunder Quads",
		Description = "Collect cash and survive",
		Icon = "rbxassetid://0",
		MaxPlayers = 4,
		GameMode = "Plunder",
		Ranking = false
	},
	PRACTICE_BOTS = {
		Name = "Practice vs Bots",
		Description = "Train against AI opponents",
		Icon = "rbxassetid://0",
		MaxPlayers = 4,
		GameMode = "Practice",
		Ranking = false
	}
}

-- ============================================================================
-- OPERATOR IDS
-- ============================================================================
IDRegistry.Operators = {
	T_800 = "T-800",
	GHOST = "Ghost",
	SOAP = "Soap",
	PRICE = "Price",
	GAZ = "Gaz",
	FARAH = "Farah",
	ROZE = "Roze",
	NIKTO = "Nikto",
	MACE = "Mace",
	VELIKAN = "Velikan",
	LERCH = "Lerch",
	WOODS = "Woods",
	MASON = "Mason"
}

IDRegistry.OperatorList = {
	"T-800",
	"Ghost",
	"Soap",
	"Price",
	"Gaz",
	"Farah",
	"Roze",
	"Nikto",
	"Mace",
	"Velikan",
	"Lerch",
	"Woods",
	"Mason"
}

-- Operator Metadata for UI Generation
IDRegistry.OperatorMetadata = {
	["T-800"] = {
		Name = "T-800",
		Bio = "Cyberdyne Systems Model 101. Coming to Warzone.",
		Rarity = "Legendary",
		Skins = 2,
		Portrait = "rbxassetid://13165203306",
		FinishingMove = "HOOK & SLASH",
		Nationality = "Cyborg",
		Category = "Villain"
	},
	["Ghost"] = {
		Name = "Ghost",
		Bio = "Simon 'Ghost' Riley. Elite British SAS operative.",
		Rarity = "Epic",
		Skins = 4,
		Portrait = "rbxassetid://13165203306",
		FinishingMove = "SILENT ENTRY",
		Nationality = "British",
		Category = "Task Force 141"
	},
	["Soap"] = {
		Name = "Soap",
		Bio = "Sergeant John 'Soap' MacTavish. Veteran of multiple campaigns.",
		Rarity = "Rare",
		Skins = 2,
		Portrait = "rbxassetid://13165203306",
		FinishingMove = "CLEAN UP",
		Nationality = "Scottish",
		Category = "Task Force 141"
	},
	["Price"] = {
		Name = "Price",
		Bio = "Captain John Price. Leader of Task Force 141.",
		Rarity = "Epic",
		Skins = 3,
		Portrait = "rbxassetid://13165203306",
		FinishingMove = "BREACH & CLEAR",
		Nationality = "British",
		Category = "Task Force 141"
	},
	["Gaz"] = {
		Name = "Gaz",
		Bio = "Kyle 'Gaz' Garrick. Tactical operator with sharp instincts.",
		Rarity = "Rare",
		Skins = 2,
		Portrait = "rbxassetid://13165203306",
		FinishingMove = "CLASSIFIED",
		Nationality = "British",
		Category = "Task Force 141"
	},
	["Farah"] = {
		Name = "Farah",
		Bio = "Captain Farah Karim. Leader of the Urzikstan Liberation Army.",
		Rarity = "Epic",
		Skins = 2,
		Portrait = "rbxassetid://13165203306",
		FinishingMove = "COUNTER-ATTACK",
		Nationality = "Urzikstani",
		Category = "Allies"
	},
	["Roze"] = {
		Name = "Roze",
		Bio = "Rosa 'Roze' Mendes. Former member of the Armada cartel.",
		Rarity = "Rare",
		Skins = 3,
		Portrait = "rbxassetid://13165203306",
		FinishingMove = "PRECISION STRIKE",
		Nationality = "Colombian",
		Category = "Operators"
	},
	["Nikto"] = {
		Name = "Nikto",
		Bio = "Nikto. Mysterious operative with a dark past.",
		Rarity = "Legendary",
		Skins = 2,
		Portrait = "rbxassetid://13165203306",
		FinishingMove = "DECISIVE FORCE",
		Nationality = "Unknown",
		Category = "Shadow Company"
	},
	["Mace"] = {
		Name = "Mace",
		Bio = "Mace. Hardened operator with superior tactical skills.",
		Rarity = "Epic",
		Skins = 2,
		Portrait = "rbxassetid://13165203306",
		FinishingMove = "OVERWHELMING FORCE",
		Nationality = "American",
		Category = "Shadow Company"
	},
	["Velikan"] = {
		Name = "Velikan",
		Bio = "Velikan. Imposing force with unmatched combat prowess.",
		Rarity = "Legendary",
		Skins = 2,
		Portrait = "rbxassetid://13165203306",
		FinishingMove = "ABSOLUTE ZERO",
		Nationality = "Russian",
		Category = "Shadow Company"
	},
	["Lerch"] = {
		Name = "Lerch",
		Bio = "Lerch. Veteran of countless operations across the globe.",
		Rarity = "Rare",
		Skins = 2,
		Portrait = "rbxassetid://13165203306",
		FinishingMove = "TACTICAL STRIKE",
		Nationality = "German",
		Category = "Operators"
	},
	["Woods"] = {
		Name = "Woods",
		Bio = "Frank 'Woods' Woods. Seasoned Black Ops veteran.",
		Rarity = "Epic",
		Skins = 3,
		Portrait = "rbxassetid://13165203306",
		FinishingMove = "TACTICAL NUKE",
		Nationality = "American",
		Category = "Black Ops"
	},
	["Mason"] = {
		Name = "Mason",
		Bio = "Alex Mason. Black Ops operative with specialized training.",
		Rarity = "Rare",
		Skins = 2,
		Portrait = "rbxassetid://13165203306",
		FinishingMove = "CLASSIFIED OPS",
		Nationality = "American",
		Category = "Black Ops"
	}
}

-- ============================================================================
-- CHALLENGE IDS
-- ============================================================================
IDRegistry.Challenges = {
	RECON_CONTRACTS = "RECON_CONTRACTS",
	AIRPORT_CONTRACTS = "AIRPORT_CONTRACTS",
	OPEN_CACHES = "OPEN_CACHES"
}

IDRegistry.ChallengeList = {
	"RECON_CONTRACTS",
	"AIRPORT_CONTRACTS",
	"OPEN_CACHES"
}

-- Challenge Metadata for UI Generation
IDRegistry.ChallengeMetadata = {
	RECON_CONTRACTS = {
		Name = "Recon Contract",
		Description = "Gather intelligence at specified locations",
		Icon = "rbxassetid://0",
		Reward = 1500,
		Difficulty = "Medium",
		Duration = 180,
		Objectives = 3
	},
	AIRPORT_CONTRACTS = {
		Name = "Airport Security",
		Description = "Secure the airport perimeter",
		Icon = "rbxassetid://0",
		Reward = 2000,
		Difficulty = "Hard",
		Duration = 300,
		Objectives = 2
	},
	OPEN_CACHES = {
		Name = "Cache Retrieval",
		Description = "Find and open hidden caches",
		Icon = "rbxassetid://0",
		Reward = 1200,
		Difficulty = "Easy",
		Duration = 120,
		Objectives = 4
	}
}

-- ============================================================================
-- LOADOUT IDS
-- ============================================================================
IDRegistry.Loadouts = {
	DEFAULT = 1,
	MIN_ID = 1,
	MAX_ID = 999
}

-- Loadout Metadata for UI Generation
IDRegistry.LoadoutMetadata = {
	Default = {
		Name = "Default Loadout",
		Description = "Balanced weapon setup",
		Icon = "rbxassetid://0",
		Rarity = "Common",
		PrimaryWeapon = "M4A1",
		SecondaryWeapon = "M9",
		Equipment = "Frag Grenade",
		Tactical = "Stun Grenade"
	}
}

-- ============================================================================
-- WEAPON IDS
-- ============================================================================
IDRegistry.Weapons = {
	-- Assault Rifles
	M4A1 = "M4A1",
	SCAR = "SCAR",
	FR_FAMAS = "FR_FAMAS",
	M13 = "M13",
	
	-- SMG
	MP5 = "MP5",
	UZIE = "UZI",
	STRIKER_45 = "STRIKER_45",
	
	-- Sniper Rifles
	HDR = "HDR",
	AX50 = "AX50",
	SPR208 = "SPR208",
	
	-- Shotguns
	ORIGIN12 = "ORIGIN12",
	JAK12 = "JAK12",
	OLYMPIA = "OLYMPIA",
	
	-- LMG
	FINN_LW = "FINN_LW",
	SA87 = "SA87",
	
	-- Pistols
	M9 = "M9",
	MW11 = "MW11",
	X16 = "X16"
}

IDRegistry.WeaponList = {
	"M4A1", "SCAR", "FR_FAMAS", "M13",
	"MP5", "UZI", "STRIKER_45",
	"HDR", "AX50", "SPR208",
	"ORIGIN12", "JAK12", "OLYMPIA",
	"FINN_LW", "SA87",
	"M9", "MW11", "X16"
}

-- Weapon Metadata for UI Generation
IDRegistry.WeaponMetadata = {
	M4A1 = {
		Name = "M4A1",
		Type = "Assault Rifle",
		Description = "Balanced, reliable, and effective. The M4A1 is a solid choice for most engagements.",
		Damage = 38,
		FireRate = 13,
		Accuracy = 75,
		MagazineSize = 30,
		Rarity = "Common"
	},
	SCAR = {
		Name = "SCAR",
		Type = "Assault Rifle",
		Description = "High damage assault rifle with moderate recoil.",
		Damage = 48,
		FireRate = 10,
		Accuracy = 70,
		MagazineSize = 30,
		Rarity = "Rare"
	},
	FR_FAMAS = {
		Name = "FR FAMAS",
		Type = "Assault Rifle",
		Description = "Burst fire assault rifle with high precision.",
		Damage = 42,
		FireRate = 12,
		Accuracy = 82,
		MagazineSize = 30,
		Rarity = "Rare"
	},
	M13 = {
		Name = "M13",
		Type = "Assault Rifle",
		Description = "Fast handling assault rifle with low recoil.",
		Damage = 35,
		FireRate = 14,
		Accuracy = 78,
		MagazineSize = 30,
		Rarity = "Uncommon"
	},
	MP5 = {
		Name = "MP5",
		Type = "SMG",
		Description = "Close-quarters SMG with excellent handling.",
		Damage = 30,
		FireRate = 15,
		Accuracy = 72,
		MagazineSize = 30,
		Rarity = "Common"
	},
	UZI = {
		Name = "UZI",
		Type = "SMG",
		Description = "High fire rate SMG, excellent for hip-fire.",
		Damage = 25,
		FireRate = 17,
		Accuracy = 65,
		MagazineSize = 25,
		Rarity = "Common"
	},
	STRIKER_45 = {
		Name = "STRIKER 45",
		Type = "SMG",
		Description = "Powerful SMG with lower fire rate but high damage.",
		Damage = 35,
		FireRate = 12,
		Accuracy = 68,
		MagazineSize = 30,
		Rarity = "Uncommon"
	},
	HDR = {
		Name = "HDR",
		Type = "Sniper Rifle",
		Description = "One-shot kill potential at all ranges.",
		Damage = 95,
		FireRate = 2,
		Accuracy = 100,
		MagazineSize = 5,
		Rarity = "Epic"
	},
	AX50 = {
		Name = "AX-50",
		Type = "Sniper Rifle",
		Description = "Powerful sniper with great handling.",
		Damage = 98,
		FireRate = 2,
		Accuracy = 98,
		MagazineSize = 5,
		Rarity = "Epic"
	},
	SPR208 = {
		Name = "SPR 208",
		Type = "Sniper Rifle",
		Description = "Semi-auto sniper rifle for aggressive sniping.",
		Damage = 85,
		FireRate = 8,
		Accuracy = 95,
		MagazineSize = 5,
		Rarity = "Rare"
	},
	ORIGIN12 = {
		Name = "ORIGIN12",
		Type = "Shotgun",
		Description = "Heavy hitting shotgun, effective in close quarters.",
		Damage = 120,
		FireRate = 3,
		Accuracy = 35,
		MagazineSize = 6,
		Rarity = "Rare"
	},
	JAK12 = {
		Name = "JAK-12",
		Type = "Shotgun",
		Description = "Semi-auto shotgun with high capacity magazine.",
		Damage = 110,
		FireRate = 5,
		Accuracy = 40,
		MagazineSize = 8,
		Rarity = "Uncommon"
	},
	OLYMPIA = {
		Name = "OLYMPIA",
		Type = "Shotgun",
		Description = "Classic double-barrel shotgun.",
		Damage = 140,
		FireRate = 2,
		Accuracy = 30,
		MagazineSize = 2,
		Rarity = "Uncommon"
	},
	FINN_LW = {
		Name = "FINN LW",
		Type = "LMG",
		Description = "Light machine gun with excellent magazine capacity.",
		Damage = 38,
		FireRate = 11,
		Accuracy = 65,
		MagazineSize = 100,
		Rarity = "Rare"
	},
	SA87 = {
		Name = "SA87",
		Type = "LMG",
		Description = "Versatile LMG with balanced stats.",
		Damage = 40,
		FireRate = 10,
		Accuracy = 70,
		MagazineSize = 40,
		Rarity = "Uncommon"
	},
	M9 = {
		Name = "M9",
		Type = "Pistol",
		Description = "Standard pistol for secondary use.",
		Damage = 35,
		FireRate = 14,
		Accuracy = 65,
		MagazineSize = 15,
		Rarity = "Common"
	},
	MW11 = {
		Name = "MW11",
		Type = "Pistol",
		Description = "High fire rate machine pistol.",
		Damage = 28,
		FireRate = 18,
		Accuracy = 60,
		MagazineSize = 20,
		Rarity = "Common"
	},
	X16 = {
		Name = "X16",
		Type = "Pistol",
		Description = "Powerful semi-auto pistol.",
		Damage = 55,
		FireRate = 6,
		Accuracy = 70,
		MagazineSize = 12,
		Rarity = "Uncommon"
	}
}

-- ============================================================================
-- EQUIPMENT & TACTICAL ITEMS
-- ============================================================================
IDRegistry.Equipment = {
	FRAG_GRENADE = "FRAG_GRENADE",
	SEMTEX = "SEMTEX",
	C4 = "C4",
	THERMITE = "THERMITE"
}

IDRegistry.EquipmentList = {
	"FRAG_GRENADE",
	"SEMTEX",
	"C4",
	"THERMITE"
}

IDRegistry.EquipmentMetadata = {
	FRAG_GRENADE = {
		Name = "Frag Grenade",
		Type = "Lethal",
		Description = "Bounces before detonation. Effective against groups.",
		Damage = 100,
		Duration = 3,
		Rarity = "Common"
	},
	SEMTEX = {
		Name = "Semtex",
		Type = "Lethal",
		Description = "Sticky explosive that adheres to surfaces.",
		Damage = 100,
		Duration = 2,
		Rarity = "Common"
	},
	C4 = {
		Name = "C4",
		Type = "Lethal",
		Description = "Remote detonated explosive.",
		Damage = 120,
		Duration = 0,
		Rarity = "Rare"
	},
	THERMITE = {
		Name = "Thermite",
		Type = "Lethal",
		Description = "Incendiary grenade that burns areas.",
		Damage = 80,
		Duration = 5,
		Rarity = "Rare"
	}
}

IDRegistry.Tactical = {
	STUN_GRENADE = "STUN_GRENADE",
	FLASH_GRENADE = "FLASH_GRENADE",
	SMOKE_GRENADE = "SMOKE_GRENADE",
	GAS_DRONE = "GAS_DRONE"
}

IDRegistry.TacticalList = {
	"STUN_GRENADE",
	"FLASH_GRENADE",
	"SMOKE_GRENADE",
	"GAS_DRONE"
}

IDRegistry.TacticalMetadata = {
	STUN_GRENADE = {
		Name = "Stun Grenade",
		Type = "Tactical",
		Description = "Stuns enemies, disables vision and hearing.",
		EffectDuration = 6,
		Radius = 20,
		Rarity = "Common"
	},
	FLASH_GRENADE = {
		Name = "Flash Grenade",
		Type = "Tactical",
		Description = "Blinds enemies with bright flash.",
		EffectDuration = 4,
		Radius = 25,
		Rarity = "Common"
	},
	SMOKE_GRENADE = {
		Name = "Smoke Grenade",
		Type = "Tactical",
		Description = "Creates smoke screen for concealment.",
		EffectDuration = 10,
		Radius = 30,
		Rarity = "Common"
	},
	GAS_DRONE = {
		Name = "Gas Drone",
		Type = "Tactical",
		Description = "Releases toxic gas in an area.",
		EffectDuration = 8,
		Radius = 25,
		Rarity = "Rare"
	}
}

-- ============================================================================
-- LOOKUP & VALIDATION FUNCTIONS
-- ============================================================================

--[[
	Get metadata for a specific ID
	@param category - The category (Playlists, Operators, Challenges, Loadouts)
	@param id - The ID to get metadata for
	@return table - Metadata table for the ID, or empty table if not found
]]
function IDRegistry.GetMetadata(category, id)
	local metadataTable = IDRegistry[category .. "Metadata"]
	if metadataTable and metadataTable[id] then
		return table.clone(metadataTable[id])
	end
	return {}
end

--[[
	Get all metadata for a category for enumeration
	@param category - The category (Playlists, Operators, Challenges, Loadouts)
	@return table - Table of all metadata for that category
]]
function IDRegistry.GetAllMetadata(category)
	local metadataTable = IDRegistry[category .. "Metadata"]
	if metadataTable then
		return table.clone(metadataTable)
	end
	return {}
end
function IDRegistry.IsValidPlaylist(id)
	for _, playlistId in ipairs(IDRegistry.PlaylistList) do
		if playlistId == id then
			return true
		end
	end
	return false
end

--[[
	Validates if an operator ID exists
	@param id - The operator ID to validate
	@return boolean - True if valid
]]
function IDRegistry.IsValidOperator(id)
	for _, operatorId in ipairs(IDRegistry.OperatorList) do
		if operatorId == id then
			return true
		end
	end
	return false
end

--[[
	Validates if a challenge ID exists
	@param id - The challenge ID to validate
	@return boolean - True if valid
]]
function IDRegistry.IsValidChallenge(id)
	for _, challengeId in ipairs(IDRegistry.ChallengeList) do
		if challengeId == id then
			return true
		end
	end
	return false
end

--[[
	Validates if a loadout ID is within valid range
	@param id - The loadout ID to validate
	@return boolean - True if valid
]]
function IDRegistry.IsValidLoadout(id)
	return type(id) == "number" and id >= IDRegistry.Loadouts.MIN_ID and id <= IDRegistry.Loadouts.MAX_ID
end

--[[
	Validates if a weapon ID exists
	@param id - The weapon ID to validate
	@return boolean - True if valid
]]
function IDRegistry.IsValidWeapon(id)
	for _, weaponId in ipairs(IDRegistry.WeaponList) do
		if weaponId == id then
			return true
		end
	end
	return false
end

--[[
	Validates if an equipment ID exists
	@param id - The equipment ID to validate
	@return boolean - True if valid
]]
function IDRegistry.IsValidEquipment(id)
	for _, equipmentId in ipairs(IDRegistry.EquipmentList) do
		if equipmentId == id then
			return true
		end
	end
	return false
end

--[[
	Validates if a tactical item ID exists
	@param id - The tactical ID to validate
	@return boolean - True if valid
]]
function IDRegistry.IsValidTactical(id)
	for _, tacticalId in ipairs(IDRegistry.TacticalList) do
		if tacticalId == id then
			return true
		end
	end
	return false
end

--[[
	Generic ID validation by category
	@param category - The category (Playlists, Operators, Challenges, Loadouts, Weapons, Equipment, Tactical)
	@param id - The ID to validate
	@return boolean - True if valid
]]
function IDRegistry.ValidateID(category, id)
	if category == "Playlists" then
		return IDRegistry.IsValidPlaylist(id)
	elseif category == "Operators" then
		return IDRegistry.IsValidOperator(id)
	elseif category == "Challenges" then
		return IDRegistry.IsValidChallenge(id)
	elseif category == "Loadouts" then
		return IDRegistry.IsValidLoadout(id)
	elseif category == "Weapons" then
		return IDRegistry.IsValidWeapon(id)
	elseif category == "Equipment" then
		return IDRegistry.IsValidEquipment(id)
	elseif category == "Tactical" then
		return IDRegistry.IsValidTactical(id)
	end
	return false
end

--[[
	Get all IDs for a category for enumeration/debugging
	@param category - The category (Playlists, Operators, Challenges, Weapons, Equipment, Tactical)
	@return table - List of all IDs in that category
]]
function IDRegistry.GetAll(category)
	if category == "Playlists" then
		return table.clone(IDRegistry.PlaylistList)
	elseif category == "Operators" then
		return table.clone(IDRegistry.OperatorList)
	elseif category == "Challenges" then
		return table.clone(IDRegistry.ChallengeList)
	elseif category == "Weapons" then
		return table.clone(IDRegistry.WeaponList)
	elseif category == "Equipment" then
		return table.clone(IDRegistry.EquipmentList)
	elseif category == "Tactical" then
		return table.clone(IDRegistry.TacticalList)
	end
	return {}
end

return IDRegistry
