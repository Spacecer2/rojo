--[[
	PlaylistData - Shared constants for available game modes
	ID definitions now sourced from IDRegistry for centralized management
]]

local IDRegistry = require(script.Parent:WaitForChild("IDRegistry"))

local PlaylistData = {}

PlaylistData.Modes = {
	{
		Id = IDRegistry.Playlists.BR_QUADS,
		Title = "BR QUADS",
		Desc = "Teams of Four. Loot and Kill. Last team standing wins.",
		Image = "rbxassetid://13165203306", -- Placeholder
		Active = true
	},
	{
		Id = IDRegistry.Playlists.BR_SOLOS,
		Title = "BR SOLOS",
		Desc = "Solo battle royale experience. High tension, high stakes.",
		Image = "rbxassetid://13165203306"
	},
	{
		Id = IDRegistry.Playlists.SCOPES_AND_SCATTER,
		Title = "SCOPES AND SCATTER GU",
		Desc = "Snipers and shotguns only. Limited time mode.",
		Image = "rbxassetid://13165203306"
	},
	{
		Id = IDRegistry.Playlists.PLUNDER_QUADS,
		Title = "PLUNDER QUADS",
		Desc = "Collect the most cash to win. Infinite respawns.",
		Image = "rbxassetid://13165203306"
	},
	{
		Id = IDRegistry.Playlists.PRACTICE_BOTS,
		Title = "PRACTICE MODES",
		Desc = "Hone your skills in training against bots.",
		Image = "rbxassetid://13165203306",
		IsLocal = true -- Flag for movement test/local game
	}
}

return PlaylistData
