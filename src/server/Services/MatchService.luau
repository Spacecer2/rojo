--[[
	MatchService - Core Game Loop Manager
	Coordinated Warmup -> Infiltration -> BR Loop -> Victory
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local Network = require(ReplicatedStorage.Framework.Network)
local GasService = nil -- Delayed require
local GulagService = nil

local MatchService = {
	State = "Warmup", -- Warmup, Infil, Match, Ended
	StartTime = 0,
	AlivePlayers = {},
}

-- Config
local WARMUP_TIME = 20 -- Seconds
local MIN_PLAYERS = 1 -- Set to 1 for testing

function MatchService.Init()
	GasService = require(script.Parent.GasService)
	GulagService = require(script.Parent.GulagService)
	
	-- Start Warmup
	task.spawn(MatchService.StartWarmup)
	
	-- Listen for deaths to check win condition
	Players.PlayerAdded:Connect(function(player)
		player.CharacterAdded:Connect(function(char)
			local hum = char:WaitForChild("Humanoid")
			hum.Died:Connect(function()
				MatchService.OnPlayerDied(player)
			end)
		end)
	end)
end

function MatchService.StartWarmup()
	MatchService.State = "Warmup"
	-- Warmup timer disabled for now
	MatchService.StartMatch()
end

function MatchService.StartMatch()
	MatchService.State = "Match"
	print("[MatchService] MATCH STARTED!")
	
	-- 1. Lock Lobby (not implemented yet)
	
	-- 2. Teleport Players (Infiltration)
	-- For now, just respawn them at random points
	MatchService.AlivePlayers = {}
	for _, player in ipairs(Players:GetPlayers()) do
		table.insert(MatchService.AlivePlayers, player)
		player:LoadCharacter() 
		-- Teleport logic would go here
	end
	
	-- 3. Start Gas
	GasService.StartMatch()
	
	Network.FireAllClients("MatchStatus", { State = "Match" })
end

function MatchService.OnPlayerDied(player)
	if MatchService.State ~= "Match" then return end
	
	-- Remove from alive list
	local index = table.find(MatchService.AlivePlayers, player)
	if index then
		table.remove(MatchService.AlivePlayers, index)
	end
	
	-- Check Win Condition
	if #MatchService.AlivePlayers <= 1 and #Players:GetPlayers() > 1 then
		local winner = MatchService.AlivePlayers[1]
		MatchService.EndMatch(winner)
	end
	
	-- Gulag Logic (if first death)
	-- GulagService.QueuePlayer(player) -- TODO: Integrate Gulag flow
end

function MatchService.EndMatch(winner)
	MatchService.State = "Ended"
	print("[MatchService] MATCH ENDED!")
	
	if winner then
		print("Winner: " .. winner.Name)
		Network.FireAllClients("MatchStatus", { State = "Victory", Winner = winner.Name })
	else
		Network.FireAllClients("MatchStatus", { State = "Draw" })
	end
	
	-- Reset server after delay
	task.delay(10, function()
		-- Soft restart logic
		MatchService.StartWarmup()
	end)
end

return MatchService
