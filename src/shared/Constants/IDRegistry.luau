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

-- ============================================================================
-- LOADOUT IDS
-- ============================================================================
IDRegistry.Loadouts = {
	DEFAULT = 1,
	MIN_ID = 1,
	MAX_ID = 999
}

-- ============================================================================
-- LOOKUP & VALIDATION FUNCTIONS
-- ============================================================================

--[[
	Validates if a playlist ID exists
	@param id - The playlist ID to validate
	@return boolean - True if valid
]]
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
