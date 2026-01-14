local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Network = require(ReplicatedStorage:WaitForChild("Framework"):WaitForChild("Network"))

local PlayerDataController = {}

-- Events for UI to listen to
PlayerDataController.ProfileChanged = Instance.new("BindableEvent")
PlayerDataController.ChallengesChanged = Instance.new("BindableEvent")

local currentProfile = nil
local currentChallenges = {}

function PlayerDataController.Init()
	Network.OnClientEvent("ProfileUpdate", function(profile)
		currentProfile = profile
		PlayerDataController.ProfileChanged:Fire(profile)
	end)
	
	Network.OnClientEvent("ChallengesUpdate", function(challenges)
		currentChallenges = challenges
		PlayerDataController.ChallengesChanged:Fire(challenges)
	end)
end

function PlayerDataController.GetProfile()
	return currentProfile
end

function PlayerDataController.GetChallenges()
	return currentChallenges
end

function PlayerDataController.Start()
	print("[PlayerDataController] Started")
	Network.FireServer("RequestData")
end

return PlayerDataController