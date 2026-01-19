--[[
	IDRegistry - Centralized ID management for the entire game
	Single source of truth for all ID definitions and validation
	Provides consistent ID schemas and lookup utilities
]]

local IDRegistry = {
	Version = "1.0.0",
	LastUpdated = "2026-01-19"
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
	Generic ID validation by category
	@param category - The category (Playlists, Operators, Challenges, Loadouts)
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
	end
	return false
end

--[[
	Get all IDs for a category for enumeration/debugging
	@param category - The category (Playlists, Operators, Challenges)
	@return table - List of all IDs in that category
]]
function IDRegistry.GetAll(category)
	if category == "Playlists" then
		return table.clone(IDRegistry.PlaylistList)
	elseif category == "Operators" then
		return table.clone(IDRegistry.OperatorList)
	elseif category == "Challenges" then
		return table.clone(IDRegistry.ChallengeList)
	end
	return {}
end

return IDRegistry
