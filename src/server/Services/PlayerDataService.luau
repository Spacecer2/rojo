local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

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
	Players.PlayerAdded:Connect(function(player)
		-- Load Mock Data
		playerProfiles[player.UserId] = {
			Level = 350,
			XP = 15400,
			MaxXP = 20000,
			Currency = 2000,
			Username = player.Name
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