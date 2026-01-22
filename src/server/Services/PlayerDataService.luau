local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Network = require(ReplicatedStorage.Framework.Network)
local SettingsData = require(ReplicatedStorage.Constants.SettingsData)

local PlayerDataService = {}

-- Store player data in memory for now
local playerProfiles = {}
local playerChallenges = {}

-- Setup Remotes
local Remotes = ReplicatedStorage:FindFirstChild("Remotes")
if not Remotes then
	Remotes = Instance.new("Folder")
	Remotes.Name = "Remotes"
	Remotes.Parent = ReplicatedStorage
end

local ProfileUpdateEvent = Instance.new("RemoteEvent")
ProfileUpdateEvent.Name = "ProfileUpdate"
ProfileUpdateEvent.Parent = Remotes

local ChallengesUpdateEvent = Instance.new("RemoteEvent")
ChallengesUpdateEvent.Name = "ChallengesUpdate"
ChallengesUpdateEvent.Parent = Remotes

function PlayerDataService.Init()
	-- Listen for settings updates
	Network.OnServerEvent("UpdateSettings", function(player, key, value)
		PlayerDataService.UpdateProfile(player, function(profile)
			if not profile.Settings then profile.Settings = {} end
			profile.Settings[key] = value
			print(string.format("[PlayerDataService] Saved setting '%s' for %s", key, player.Name))
			return profile
		end)
	end)

	Players.PlayerAdded:Connect(function(player)
		-- Load Mock Data
		playerProfiles[player.UserId] = {
			Level = 350,
			XP = 15400,
			MaxXP = 20000,
			Currency = 2000,
			Username = player.Name,
			Settings = table.clone(SettingsData.Defaults)
		}
		
		playerChallenges[player.UserId] = {
			{Id = "1", Title = "Win 1 Ranked Match", Progress = 1, Goal = 1, RewardXP = 500},
			{Id = "2", Title = "Kill 6 Enemies in BR", Progress = 2, Goal = 6, RewardXP = 150},
			{Id = "3", Title = "Win 3 BR Matches", Progress = 0, Goal = 3, RewardXP = 1000}
		}
		
		-- Send initial data
		task.wait(1) -- Wait for client to load
		PlayerDataService.UpdateClient(player)
	end)
end

function PlayerDataService.UpdateProfile(player, updateFunc)
	local profile = playerProfiles[player.UserId]
	if profile then
		local newProfile = updateFunc(profile)
		playerProfiles[player.UserId] = newProfile
		PlayerDataService.UpdateClient(player)
	end
end

function PlayerDataService.UpdateClient(player)
	local profile = playerProfiles[player.UserId]
	local challenges = playerChallenges[player.UserId]
	
	if profile then
		ProfileUpdateEvent:FireClient(player, profile)
	end
	if challenges then
		ChallengesUpdateEvent:FireClient(player, challenges)
	end
end

function PlayerDataService.Start()
	print("[PlayerDataService] Started")
end

return PlayerDataService