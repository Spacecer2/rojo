local Players = game:GetService("Players")
local BadgeService = game:GetService("BadgeService")
local RunService = game:GetService("RunService")
local ServerScriptService = game:GetService("ServerScriptService")
local DataService = require(ServerScriptService.Services.DataService)
local MarketplaceService = require(ServerScriptService.Services.MarketplaceService)

local PlayerService = {}

local BETA_TESTER_BADGE_ID = 4197950939233224

function PlayerService.Init()
	Players.PlayerAdded:Connect(function(player)
		PlayerService.OnPlayerAdded(player)
	end)
	
	Players.PlayerRemoving:Connect(function(player)
		PlayerService.OnPlayerRemoving(player)
	end)
end

function PlayerService.OnPlayerAdded(player)
	print("Player joined: " .. player.Name)
	player:SetAttribute("EquippedWeapon", "M4")
	DataService.LoadData(player)

	-- Award Beta Tester Badge
	task.spawn(function()
		if RunService:IsStudio() then
			print("[BadgeService] Skipping badge award in Studio for " .. player.Name)
			return
		end

		local success, result = pcall(function()
			return BadgeService:AwardBadge(player.UserId, BETA_TESTER_BADGE_ID)
		end)
		
		if success then
			if result then
				print("Successfully awarded Beta Tester badge to " .. player.Name)
			end
		else
			warn("Failed to award badge to " .. player.Name .. ": " .. tostring(result))
		end
	end)

	-- Check for Special Pass ownership
	task.spawn(function()
		local passId = MarketplaceService.Passes.SPECIAL_PASS
		if MarketplaceService.UserOwnsPass(player.UserId, passId) then
			print("[Marketplace] Player " .. player.Name .. " owns the Special Pass!")
		end
	end)
	
	-- Force spawn location at SpawnLocation center during load
	player.CharacterAdded:Connect(function(character)
		-- Listen for death for Gulag redirection
		local humanoid = character:WaitForChild("Humanoid")
		humanoid.Died:Connect(function()
			if not player:GetAttribute("HasBeenToGulag") then
				player:SetAttribute("HasBeenToGulag", true)
				local GulagService = require(ServerScriptService.Services.GulagService)
				task.delay(2, function()
					GulagService.QueuePlayer(player)
				end)
			end
		end)

		-- Wait for root part
		local rootPart = character:WaitForChild("HumanoidRootPart", 5)
		if rootPart then
			local spawnLocation = workspace:FindFirstChildOfClass("SpawnLocation")
			if spawnLocation then
				-- Pivot to the exact center of the SpawnLocation, slightly above the surface
				character:PivotTo(spawnLocation.CFrame * CFrame.new(0, spawnLocation.Size.Y/2 + 3.5, 0))
			else
				-- Fallback if no SpawnLocation is found
				character:PivotTo(CFrame.new(0, 1000, 0))
			end
		end
	end)
end

function PlayerService.OnPlayerRemoving(player)
	print("Player leaving: " .. player.Name)
	DataService.SaveData(player)
end

return PlayerService