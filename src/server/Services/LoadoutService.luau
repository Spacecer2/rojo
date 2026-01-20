--[[
	LoadoutService - Scalable loadout persistence system
	Handles server-side storage and retrieval of player weapon loadouts
	Designed for integration with DataService for persistence
	Uses centralized ID management from IDRegistry
]]
local ServerScriptService = game:GetService("ServerScriptService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local _DataService = require(ServerScriptService.Services.DataService)
local IDRegistry = require(ReplicatedStorage.Constants.IDRegistry)

local LoadoutService = {}

-- In-memory cache (will be integrated with DataService for persistence)
local playerLoadouts = {}

-- Default loadout structure (abstracted for scalability)
local function createDefaultLoadout()
	return {
		Id = IDRegistry.Loadouts.DEFAULT,
		Name = "Default Loadout",
		Primary = {
			Name = "M4",
			Category = "Assault Rifle",
			Attachments = {}, -- For future gunsmith integration
			Progress = 0,
			Max = 2200
		},
		Secondary = {
			Name = "P890",
			Category = "Handgun",
			Attachments = {},
			Progress = 0,
			Max = 1000
		},
		Perks = {"E.O.D.", "Hardline", "Ghost"},
		Lethal = "Frag",
		Tactical = "Stun"
	}
end

-- Get loadouts for player
function LoadoutService.GetLoadouts(player)
	if not playerLoadouts[player.UserId] then
		-- Initialize with default loadout
		playerLoadouts[player.UserId] = {
			createDefaultLoadout()
		}
	end
	return playerLoadouts[player.UserId]
end

-- Save loadout for player
function LoadoutService.SaveLoadout(player, loadoutData)
	-- Validate loadout ID
	if not IDRegistry.IsValidLoadout(loadoutData.Id) then
		warn("[LoadoutService] Invalid loadout ID: " .. tostring(loadoutData.Id))
		return false
	end
	
	if not playerLoadouts[player.UserId] then
		playerLoadouts[player.UserId] = {}
	end
	
	local loadouts = playerLoadouts[player.UserId]
	
	-- Update existing or add new
	local found = false
	for i, loadout in ipairs(loadouts) do
		if loadout.Id == loadoutData.Id then
			loadouts[i] = loadoutData
			found = true
			break
		end
	end
	
	if not found then
		table.insert(loadouts, loadoutData)
	end
	
	-- TODO: Integrate with DataService for persistence
	-- DataService.UpdatePlayerLoadouts(player, loadouts)
	
	print("[LoadoutService] Loadout saved for " .. player.Name)
	return true
end

-- Delete loadout
function LoadoutService.DeleteLoadout(player, loadoutId)
	local loadouts = playerLoadouts[player.UserId]
	if loadouts then
		for i, loadout in ipairs(loadouts) do
			if loadout.Id == loadoutId then
				table.remove(loadouts, i)
				print("[LoadoutService] Loadout " .. loadoutId .. " deleted for " .. player.Name)
				return true
			end
		end
	end
	return false
end

-- Initialize service
function LoadoutService.Init()
	-- Cleanup on player leaving (save to DataService)
	local Players = game:GetService("Players")
	Players.PlayerRemoving:Connect(function(player)
		-- TODO: Save loadouts to DataService
		playerLoadouts[player.UserId] = nil
	end)
	
	print("[LoadoutService] Initialized")
end

return LoadoutService
