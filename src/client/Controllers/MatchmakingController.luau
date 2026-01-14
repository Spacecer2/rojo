local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Network = require(ReplicatedStorage:WaitForChild("Framework"):WaitForChild("Network"))

local MatchmakingController = {}

-- Events
MatchmakingController.LobbyChanged = Instance.new("BindableEvent")

local currentLobbyState = {
	PlayerCount = 1,
	MaxPlayers = 10,
	Status = "Searching"
}

function MatchmakingController.Init()
	Network.OnClientEvent("LobbyUpdate", function(state)
		currentLobbyState = state
		MatchmakingController.LobbyChanged:Fire(state)
	end)
end

function MatchmakingController.GetLobbyState()
	return currentLobbyState
end

function MatchmakingController.Start()
	print("[MatchmakingController] Started")
end

function MatchmakingController.StartMatchmaking(settings)
	settings = settings or {}
	print("[MatchmakingController] Requesting matchmaking with settings:", settings)
	Network.FireServer("MatchmakingRequest", settings)
end

return MatchmakingController