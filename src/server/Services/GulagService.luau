--[[
	GulagService - Server-side 1v1 management
	Handles queuing, matchmaking, and match logic.
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Network = require(ReplicatedStorage.Framework.Network)
local GulagConfig = require(ReplicatedStorage.Constants.GulagConfig)

local GulagService = {
	Queue = {}, -- List of players waiting for an opponent
	ActiveMatches = {}, -- [MatchId] = { P1, P2, StartTime, State }
}

function GulagService.Init()
	-- Periodic Matchmaking check
	task.spawn(function()
		while true do
			task.wait(2)
			GulagService.Matchmake()
		end
	end)
end

function GulagService.QueuePlayer(player)
	if table.find(GulagService.Queue, player) then return end
	table.insert(GulagService.Queue, player)
	
	print(string.format("[GulagService] %s entered the queue", player.Name))
	Network.FireClient(player, "GulagStatus", { State = "InQueue" })
end

function GulagService.Matchmake()
	while #GulagService.Queue >= 2 do
		local p1 = table.remove(GulagService.Queue, 1)
		local p2 = table.remove(GulagService.Queue, 1)
		
		if p1 and p2 then
			GulagService.StartMatch(p1, p2)
		end
	end
end

function GulagService.StartMatch(p1, p2)
	local matchId = game:GetService("HttpService"):GenerateGUID(false)
	
	local matchData = {
		Id = matchId,
		Players = {p1, p2},
		StartTime = tick(),
		State = "Fight"
	}
	
	GulagService.ActiveMatches[matchId] = matchData
	
	-- Setup Players
	for i, p in ipairs({p1, p2}) do
		local spawnPos = (i == 1) and GulagConfig.ARENA.SpawnA or GulagConfig.ARENA.SpawnB
		local char = p.Character
		if char and char:FindFirstChild("HumanoidRootPart") then
			char.HumanoidRootPart.CFrame = CFrame.new(spawnPos)
		end
		
		-- Give Weapons
		local WeaponService = require(script.Parent.WeaponService)
		WeaponService.EquipWeapon(p, "M4") -- Default for now
		
		Network.FireClient(p, "GulagStatus", { 
			State = "MatchStarted", 
			Opponent = (i == 1 and p2.Name or p1.Name),
			MatchId = matchId
		})
		
		-- Listen for death
		local hum = char:FindFirstChild("Humanoid")
		if hum then
			local conn
			conn = hum.Died:Connect(function()
				conn:Disconnect()
				GulagService.OnPlayerDiedInMatch(matchId, p)
			end)
		end
	end
	
	print(string.format("[GulagService] Match %s started: %s vs %s", matchId, p1.Name, p2.Name))
end

function GulagService.OnPlayerDiedInMatch(matchId, deadPlayer)
	local match = GulagService.ActiveMatches[matchId]
	if not match then return end
	
	local winner = nil
	for _, p in pairs(match.Players) do
		if p ~= deadPlayer then
			winner = p
			break
		end
	end
	
	GulagService.EndMatch(matchId, winner, deadPlayer)
end

function GulagService.EndMatch(matchId, winner, loser)
	local match = GulagService.ActiveMatches[matchId]
	if not match then return end
	
	GulagService.ActiveMatches[matchId] = nil
	
	if winner then
		print(string.format("[GulagService] %s won the Gulag!", winner.Name))
		Network.FireClient(winner, "GulagStatus", { State = "Winner" })
		
		-- Return winner to match
		task.delay(3, function()
			GulagService.RespawnWinner(winner)
		end)
	end
	
	if loser then
		print(string.format("[GulagService] %s lost the Gulag.", loser.Name))
		Network.FireClient(loser, "GulagStatus", { State = "Loser" })
		-- Loser stays dead or goes to spectate
	end
end

function GulagService.RespawnWinner(player)
	-- Logic to find a safe spawn or teammate
	local char = player.Character
	if char and char:FindFirstChild("Humanoid") then
		player:LoadCharacter() -- Full respawn back into match
	end
end

return GulagService
