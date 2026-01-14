--[[
	PlaylistData - Shared constants for available game modes
]]

local PlaylistData = {}

PlaylistData.Modes = {
	{
		Id = "BR_QUADS",
		Title = "BR QUADS",
		Desc = "Teams of Four. Loot and Kill. Last team standing wins.",
		Image = "rbxassetid://13165203306", -- Placeholder
		Active = true
	},
	{
		Id = "BR_SOLOS",
		Title = "BR SOLOS",
		Desc = "Solo battle royale experience. High tension, high stakes.",
		Image = "rbxassetid://13165203306"
	},
	{
		Id = "SCOPES_AND_SCATTER",
		Title = "SCOPES AND SCATTER GU",
		Desc = "Snipers and shotguns only. Limited time mode.",
		Image = "rbxassetid://13165203306"
	},
	{
		Id = "PLUNDER_QUADS",
		Title = "PLUNDER QUADS",
		Desc = "Collect the most cash to win. Infinite respawns.",
		Image = "rbxassetid://13165203306"
	},
	{
		Id = "PRACTICE_BOTS",
		Title = "PRACTICE MODES",
		Desc = "Hone your skills in training against bots.",
		Image = "rbxassetid://13165203306",
		IsLocal = true -- Flag for movement test/local game
	}
}

return PlaylistData
