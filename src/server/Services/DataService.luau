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
		
		-- Sync to client and leaderboards
		DataService.UpdateClient(player)
		DataService.UpdateLeaderstats(player)
		
		Network.FireClient(player, "ChallengesUpdate", pData.Data.Challenges)
		
		return pData
	else
		warn("Failed to load data for " .. player.Name)
		return nil
	end
end

function DataService.UpdateClient(player)
	local pData = sessionData[player.UserId]
	if pData then
		Network.FireClient(player, "ProfileUpdate", {
			Username = player.Name,
			Level = pData.Data.Level,
			RankTitle = pData.Data.RankTitle,
			Currency = pData.Data.Currency,
			XPBoost = pData.Data.XPBoost,
			ActiveMission = pData.Data.ActiveMission,
			XPProgress = (pData.Data.MaxExperience > 0) and (pData.Data.Experience / pData.Data.MaxExperience) or 0
		})
	end
end

function DataService.UpdateLeaderstats(player)
	local pData = sessionData[player.UserId]
	local leaderstats = player:FindFirstChild("leaderstats")
	if pData and leaderstats then
		local lvl = leaderstats:FindFirstChild("Level")
		local cur = leaderstats:FindFirstChild("Currency")
		if lvl then lvl.Value = pData.Data.Level end
		if cur then cur.Value = pData.Data.Currency end
	end
end

function DataService.AddCurrency(player, amount)
	local pData = sessionData[player.UserId]
	if pData then
		pData.Data.Currency = pData.Data.Currency + amount
		DataService.UpdateClient(player)
		DataService.UpdateLeaderstats(player)
	end
end

function DataService.AddXP(player, amount)
	local pData = sessionData[player.UserId]
	if pData then
		pData.Data.Experience = pData.Data.Experience + amount
		-- Level up logic
		while pData.Data.Experience >= pData.Data.MaxExperience do
			pData.Data.Experience = pData.Data.Experience - pData.Data.MaxExperience
			pData.Data.Level = pData.Data.Level + 1
			pData.Data.MaxExperience = math.floor(pData.Data.MaxExperience * 1.1) -- Scale XP req
			print("[DataService] " .. player.Name .. " leveled up to " .. pData.Data.Level)
		end
		
		DataService.UpdateClient(player)
		DataService.UpdateLeaderstats(player)
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

function DataService.Init()
	Network.OnServerEvent("RequestData", function(player)
		print("[DataService] Data request from " .. player.Name)
		DataService.UpdateClient(player)
		
		local pData = sessionData[player.UserId]
		if pData then
			Network.FireClient(player, "ChallengesUpdate", pData.Data.Challenges)
		end
	end)
	print("[DataService] Initialized")
end

function DataService.GetPlayerData(player)
	return sessionData[player.UserId]
end

return DataService