--[[
	ChallengeService - Server-side manager for daily challenges
	Handles progress tracking, goal completion, and rewards
]]
local ServerScriptService = game:GetService("ServerScriptService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Network = require(ReplicatedStorage.Framework.Network)

local ChallengeService = {}

-- Update progress for a specific challenge
function ChallengeService.UpdateProgress(player, challengeId, increment)
	local DataService = require(ServerScriptService.Services.DataService)
	local pData = DataService.GetPlayerData(player)
	
	if pData and pData.Data.Challenges then
		for _, challenge in ipairs(pData.Data.Challenges) do
			if challenge.Id == challengeId then
				challenge.Progress = math.min(challenge.Goal, challenge.Progress + (increment or 1))
				
				-- Sync to client
				Network.FireClient(player, "ChallengesUpdate", pData.Data.Challenges)
				
				if challenge.Progress >= challenge.Goal then
					print("[ChallengeService] Challenge completed for " .. player.Name .. ": " .. challenge.Title)
					-- Reward logic could go here (e.g., DataService.AddXP)
				end
				return true
			end
		end
	end
	return false
end

function ChallengeService.Init()
	print("[ChallengeService] Initialized")
end

return ChallengeService
