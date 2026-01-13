local DataStoreService = game:GetService("DataStoreService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local PlayerData = require(ReplicatedStorage:WaitForChild("PlayerData"))
local Network = require(ReplicatedStorage.Framework.Network)

local DataService = {}
local PlayerDataStore = DataStoreService:GetDataStore("GameData_v1")

local sessionData = {}

function DataService.LoadData(player)
	local userId = player.UserId
	local key = "Player_" .. userId
	
	local success, data = pcall(function()
		return PlayerDataStore:GetAsync(key)
	end)
	
	if success then
		local pData = PlayerData.new(player)
		if data then
			-- Merge saved data into template
			for k, v in pairs(data) do
				pData.Data[k] = v
			end
		end
		sessionData[userId] = pData
		print("Data loaded for " .. player.Name)
		
		-- Fire to client
		Network.FireClient(player, "ProfileUpdate", {
			Username = player.Name,
			Level = pData.Data.Level,
			Currency = pData.Data.Currency
		})
		
		Network.FireClient(player, "ChallengesUpdate", {
			{Title = "Win 1 Match", Progress = 0, Goal = 1},
			{Title = "Get 5 Kills", Progress = 2, Goal = 5}
		})
		
		return pData
	else
		warn("Failed to load data for " .. player.Name)
		return nil
	end
end

function DataService.SaveData(player)
	local userId = player.UserId
	local pData = sessionData[userId]
	
	if pData then
		local key = "Player_" .. userId
		local success, err = pcall(function()
			PlayerDataStore:SetAsync(key, pData.Data)
		end)
		
		if not success then
			warn("Failed to save data for " .. player.Name .. ": " .. err)
		else
			print("Data saved for " .. player.Name)
		end
	end
end

function DataService.GetPlayerData(player)
	return sessionData[player.UserId]
end

return DataService