--[[
	WeaponService - Handles weapon inventory and equipment
	Manages giving weapons to players based on their selected loadouts
	from the grouped weapons in StarterPack.
]]

local StarterPack = game:GetService("StarterPack")
local ServerScriptService = game:GetService("ServerScriptService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local LoadoutService = require(ServerScriptService.Services.LoadoutService)
local Network = require(ReplicatedStorage.Framework.Network)

local WeaponService = {}

-- Cache of available weapon models for quick lookup
local weaponCache = {}

-- Recursively scan StarterPack.Weapons to populate the cache
local function scanWeapons(root)
	for _, child in ipairs(root:GetChildren()) do
		if child:IsA("Tool") then
			weaponCache[child.Name] = child
		elseif child:IsA("Folder") or child:IsA("Model") then
			scanWeapons(child)
		end
	end
end

-- Find a weapon tool by name anywhere in StarterPack.Weapons
local function findWeaponTool(weaponName)
	-- Try cache first
	if weaponCache[weaponName] then
		return weaponCache[weaponName]
	end
	
	-- If not in cache, ensure we've scanned
	local weaponsFolder = StarterPack:FindFirstChild("Weapons")
	if weaponsFolder then
		scanWeapons(weaponsFolder)
	end
	
	return weaponCache[weaponName]
end

-- Give loadout weapons to a player
function WeaponService.GiveLoadoutWeapons(player)
	local character = player.Character
	if not character then return end
	
	local backpack = player:FindFirstChild("Backpack")
	if not backpack then return end
	
	-- Clear existing weapons
	for _, child in ipairs(backpack:GetChildren()) do
		if child:IsA("Tool") then child:Destroy() end
	end
	for _, child in ipairs(character:GetChildren()) do
		if child:IsA("Tool") then child:Destroy() end
	end
	
	-- Get player's active loadout
	local loadouts = LoadoutService.GetLoadouts(player)
	if #loadouts == 0 then return end
	
	-- For now, use the first loadout
	local activeLoadout = loadouts[1]
	
	-- Give Primary
	local primaryTool = findWeaponTool(activeLoadout.Primary.Name)
	if primaryTool then
		primaryTool:Clone().Parent = backpack
	else
		warn("[WeaponService] Could not find primary weapon: " .. activeLoadout.Primary.Name)
	end
	
	-- Give Secondary
	local secondaryTool = findWeaponTool(activeLoadout.Secondary.Name)
	if secondaryTool then
		secondaryTool:Clone().Parent = backpack
	else
		warn("[WeaponService] Could not find secondary weapon: " .. activeLoadout.Secondary.Name)
	end
	
	print("[WeaponService] Gave loadout weapons to " .. player.Name)
end

function WeaponService.Init()
	local Players = game:GetService("Players")
	
	-- Connect to character spawning
	Players.PlayerAdded:Connect(function(player)
		player.CharacterAdded:Connect(function(character)
			-- Small delay to ensure everything is loaded
			task.wait(0.5)
			WeaponService.GiveLoadoutWeapons(player)
		end)
	end)
	
	-- Listen for loadout updates from client
	Network.OnServerEvent("UpdateLoadout", function(player, loadoutData)
		LoadoutService.SaveLoadout(player, loadoutData)
		WeaponService.GiveLoadoutWeapons(player)
	end)
	
	-- Initial scan
	local weaponsFolder = StarterPack:FindFirstChild("Weapons")
	if weaponsFolder then
		scanWeapons(weaponsFolder)
	end
	
	print("[WeaponService] Initialized and weapons scanned")
end

return WeaponService
