local Players = game:GetService("Players")
local ServerScriptService = game:GetService("ServerScriptService")
local DataService = require(ServerScriptService.Services.DataService)

local LeaderboardService = {}

function LeaderboardService.Init()
	Players.PlayerAdded:Connect(function(player)
		LeaderboardService.CreateLeaderboard(player)
	end)
end

function LeaderboardService.CreateLeaderboard(player)
	local leaderstats = Instance.new("Folder")
	leaderstats.Name = "leaderstats"
	leaderstats.Parent = player
	
	local level = Instance.new("IntValue")
	level.Name = "Level"
	level.Parent = leaderstats
	
	local currency = Instance.new("IntValue")
	currency.Name = "Currency"
	currency.Parent = leaderstats
	
	-- Update values when data loads
	task.spawn(function()
		local pData = nil
		repeat
			task.wait(0.5)
			pData = DataService.GetPlayerData(player)
		until pData or not player.Parent
		
		if pData then
			level.Value = pData.Data.Level
			currency.Value = pData.Data.Currency
			
			-- Optional: Listen for data changes if we add signals to PlayerData
		end
	end)
end

return LeaderboardService