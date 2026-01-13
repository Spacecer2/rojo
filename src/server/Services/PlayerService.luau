local Players = game:GetService("Players")
local ServerScriptService = game:GetService("ServerScriptService")
local DataService = require(ServerScriptService.Services.DataService)

local PlayerService = {}

function PlayerService.Init()
	Players.PlayerAdded:Connect(function(player)
		PlayerService.OnPlayerAdded(player)
	end)
	
	Players.PlayerRemoving:Connect(function(player)
		PlayerService.OnPlayerRemoving(player)
	end)
end

function PlayerService.OnPlayerAdded(player)
	print("Player joined: " .. player.Name)
	DataService.LoadData(player)
	
	-- Here we could trigger character loading or other setup
end

function PlayerService.OnPlayerRemoving(player)
	print("Player leaving: " .. player.Name)
	DataService.SaveData(player)
end

return PlayerService