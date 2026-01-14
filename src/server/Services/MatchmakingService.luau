--[[
	MatchmakingService - Scalable matchmaking system
	Handles lobby creation, player matching, and queue management
	Designed for extensibility (supports different game modes, skill-based matching, etc.)
]]
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Network = require(ReplicatedStorage.Framework.Network)

local MatchmakingService = {}

-- Lobby state management (scalable for different game modes)
local lobbies = {}
local queue = {} -- Players waiting for matches

-- Lobby configuration (abstracted for easy extension)
local LOBBY_CONFIG = {
	MaxPlayers = 100, -- Battle Royale default
	MinPlayers = 10, -- Minimum to start
	GameMode = "BattleRoyale" -- Extensible enum
}

-- Create a new lobby
local function createLobby()
	local lobbyId = #lobbies + 1
	local lobby = {
		Id = lobbyId,
		Players = {},
		MaxPlayers = LOBBY_CONFIG.MaxPlayers,
		MinPlayers = LOBBY_CONFIG.MinPlayers,
		GameMode = LOBBY_CONFIG.GameMode,
		Status = "Waiting", -- Waiting, Starting, InProgress
		CreatedAt = tick()
	}
	lobbies[lobbyId] = lobby
	return lobby
end

-- Add player to queue
function MatchmakingService.QueuePlayer(player)
	if not table.find(queue, player) then
		table.insert(queue, player)
		print("[MatchmakingService] " .. player.Name .. " queued")
		
		-- Try to find or create lobby
		MatchmakingService.ProcessQueue()
	end
end

-- Remove player from queue
function MatchmakingService.DequeuePlayer(player)
	local index = table.find(queue, player)
	if index then
		table.remove(queue, index)
	end
end

-- Broadcast lobby state to all players in that lobby
local function broadcastLobbyUpdate(lobby)
	local playerData = {}
	for _, p in ipairs(lobby.Players) do
		table.insert(playerData, {
			Name = p.Name,
			UserId = p.UserId
		})
	end
	
	local state = {
		Id = lobby.Id,
		PlayerCount = #lobby.Players,
		MaxPlayers = lobby.MaxPlayers,
		Status = lobby.Status,
		Players = playerData
	}
	
	for _, p in ipairs(lobby.Players) do
		Network.FireClient(p, "LobbyUpdate", state)
	end
end

-- Process queue and assign players to lobbies
function MatchmakingService.ProcessQueue()
	-- Find available lobby or create new one
	local availableLobby = nil
	for _, lobby in pairs(lobbies) do
		if lobby.Status == "Waiting" and #lobby.Players < lobby.MaxPlayers then
			availableLobby = lobby
			break
		end
	end
	
	if not availableLobby then
		availableLobby = createLobby()
	end
	
	-- Add players from queue to lobby
	local changed = false
	while #queue > 0 and #availableLobby.Players < availableLobby.MaxPlayers do
		local player = table.remove(queue, 1)
		if player and player.Parent then
			table.insert(availableLobby.Players, player)
			print("[MatchmakingService] " .. player.Name .. " added to lobby " .. availableLobby.Id)
			changed = true
		end
	end
	
	if changed then
		broadcastLobbyUpdate(availableLobby)
	end
end

-- Initialize service
function MatchmakingService.Init()
	-- Cleanup on player leaving
	Players.PlayerRemoving:Connect(function(player)
		MatchmakingService.DequeuePlayer(player)
		-- Remove from any lobbies (extensible cleanup)
		for _, lobby in pairs(lobbies) do
			local index = table.find(lobby.Players, player)
			if index then
				table.remove(lobby.Players, index)
				broadcastLobbyUpdate(lobby)
			end
		end
	end)
	
	print("[MatchmakingService] Initialized")
	
	-- Listen for client requests
	Network.OnServerEvent("MatchmakingRequest", function(player)
		MatchmakingService.QueuePlayer(player)
	end)
end

-- Get lobby for player (for future use)
function MatchmakingService.GetPlayerLobby(player)
	for _, lobby in pairs(lobbies) do
		if table.find(lobby.Players, player) then
			return lobby
		end
	end
	return nil
end

return MatchmakingService
