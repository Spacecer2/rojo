--[[
	SquadPreviewController - Handles 3D character previews in the menu
	Displays squadmates at designated "Squad Spots" in the lobby
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local SquadPreviewController = {}

local lobbyBasePosition = Vector3.new(0, 1000, 0)
local squadOffsets = {
	Vector3.new(6, 0, 4),   -- Left Behind
	Vector3.new(-6, 0, 4),  -- Right Behind
	Vector3.new(3, 0, 7),   -- Further Left
	Vector3.new(-3, 0, 7),  -- Further Right
}

local activeSquadModels = {}

function SquadPreviewController:Init()
	local Controllers = script.Parent
	local MatchmakingController = require(Controllers:WaitForChild("MatchmakingController"))
	
	MatchmakingController.LobbyChanged.Event:Connect(function(state)
		self:UpdateSquad(state.Players or {})
	end)
end

function SquadPreviewController:UpdateSquad(players)
	local localPlayer = Players.LocalPlayer
	local otherSquadmates = {}
	
	-- Filter for squadmates (everyone except local player)
	for _, pData in ipairs(players) do
		if pData.UserId ~= localPlayer.UserId then
			table.insert(otherSquadmates, pData)
		end
	end
	
	-- 1. Identify models to remove
	for userId, model in pairs(activeSquadModels) do
		local stillInSquad = false
		for _, pData in ipairs(otherSquadmates) do
			if pData.UserId == userId then
				stillInSquad = true
				break
			end
		end
		
		if not stillInSquad then
			model:Destroy()
			activeSquadModels[userId] = nil
		end
	end
	
	-- 2. Add or Update models
	for i, pData in ipairs(otherSquadmates) do
		if i > #squadOffsets then break end -- Max squad display limit
		
		if not activeSquadModels[pData.UserId] then
			task.spawn(function()
				local success, model = pcall(function()
					return Players:CreateHumanoidModelFromUserId(pData.UserId)
				end)
				
				if success and model then
					model.Name = "Squadmate_" .. pData.Name
					model.Parent = workspace
					
					-- Position
					local offset = squadOffsets[i]
					local targetPos = lobbyBasePosition + offset
					model:PivotTo(CFrame.new(targetPos, lobbyBasePosition))
					
					-- Anchor components to prevent physics issues in menu
					for _, part in ipairs(model:GetDescendants()) do
						if part:IsA("BasePart") then
							part.Anchored = true
							part.CanCollide = false
						end
					end
					
					-- Play idle animation if available
					local humanoid = model:FindFirstChildOfClass("Humanoid")
					if humanoid then
						local animator = humanoid:FindFirstChildOfClass("Animator") or Instance.new("Animator", humanoid)
						-- Hardcoded idle for now, ideally pull from local config
						local idleAnim = Instance.new("Animation")
						idleAnim.AnimationId = "rbxassetid://507766666" -- Default R15 Idle
						local track = animator:LoadAnimation(idleAnim)
						track:Play()
					end
					
					activeSquadModels[pData.UserId] = model
				end
			end)
		end
	end
end

function SquadPreviewController:Start()
	print("[SquadPreviewController] Started")
end

return SquadPreviewController
