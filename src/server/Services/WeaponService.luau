--[[
	WeaponService - Handles weapon inventory and equipment
	Manages giving weapons to players based on their selected loadouts
	from the grouped weapons in StarterPack.
]]

local StarterPack = game:GetService("StarterPack")
local ServerScriptService = game:GetService("ServerScriptService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local LoadoutService = require(ServerScriptService.Services.LoadoutService)
local GunsmithService = require(ServerScriptService.Services.GunsmithService)
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

-- Give a single weapon to a player (used for loot pickup)
function WeaponService.GiveWeapon(player: Player, weaponName: string, attachmentIds: {string}?): boolean
	local character = player.Character
	if not character then 
		warn("[WeaponService] Cannot give weapon to " .. player.Name .. " - character not found")
		return false
	end
	
	local backpack = player:FindFirstChild("Backpack")
	if not backpack then 
		warn("[WeaponService] Cannot give weapon to " .. player.Name .. " - backpack not found")
		return false
	end
	
	-- Find the weapon tool
	local weaponTool = findWeaponTool(weaponName)
	if not weaponTool then
		warn("[WeaponService] Could not find weapon: " .. weaponName)
		return false
	end
	
	-- Clone and give the weapon
	local clonedWeapon = weaponTool:Clone()
	clonedWeapon.Parent = backpack
	
	-- Apply attachments using GunsmithService
	if attachmentIds and #attachmentIds > 0 then
		GunsmithService.ApplyAttachmentsToWeapon(clonedWeapon, weaponName, attachmentIds)
	else
		-- Even without attachments, set base weapon name
		clonedWeapon:SetAttribute("WeaponName", weaponName)
		clonedWeapon:SetAttribute("AttachmentIds", "")
	end
	
	print("[WeaponService] Gave weapon " .. weaponName .. " to " .. player.Name)
	return true
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
	
	-- Give Primary with attachments
	local primaryTool = findWeaponTool(activeLoadout.Primary.Name)
	if primaryTool then
		local clonedPrimary = primaryTool:Clone()
		clonedPrimary.Parent = backpack
		
		-- Apply attachments from loadout
		local primaryAttachments = activeLoadout.Primary.Attachments or {}
		if #primaryAttachments > 0 then
			GunsmithService.ApplyAttachmentsToWeapon(clonedPrimary, activeLoadout.Primary.Name, primaryAttachments)
		else
			clonedPrimary:SetAttribute("WeaponName", activeLoadout.Primary.Name)
			clonedPrimary:SetAttribute("AttachmentIds", "")
		end
	else
		warn("[WeaponService] Could not find primary weapon: " .. activeLoadout.Primary.Name)
	end
	
	-- Give Secondary with attachments
	local secondaryTool = findWeaponTool(activeLoadout.Secondary.Name)
	if secondaryTool then
		local clonedSecondary = secondaryTool:Clone()
		clonedSecondary.Parent = backpack
		
		-- Apply attachments from loadout
		local secondaryAttachments = activeLoadout.Secondary.Attachments or {}
		if #secondaryAttachments > 0 then
			GunsmithService.ApplyAttachmentsToWeapon(clonedSecondary, activeLoadout.Secondary.Name, secondaryAttachments)
		else
			clonedSecondary:SetAttribute("WeaponName", activeLoadout.Secondary.Name)
			clonedSecondary:SetAttribute("AttachmentIds", "")
		end
	else
		warn("[WeaponService] Could not find secondary weapon: " .. activeLoadout.Secondary.Name)
	end
	
	print("[WeaponService] Gave loadout weapons to " .. player.Name)
end

function WeaponService.Init()
	local Players = game:GetService("Players")
	
	-- Initial scan - do this first to ensure cache is ready for all players
	local weaponsFolder = StarterPack:FindFirstChild("Weapons")
	if weaponsFolder then
		scanWeapons(weaponsFolder)
		local weaponCount = 0
		for _ in pairs(weaponCache) do
			weaponCount = weaponCount + 1
		end
		print("[WeaponService] Weapon cache populated with " .. weaponCount .. " weapons")
	else
		warn("[WeaponService] No Weapons folder found in StarterPack")
	end
	
	-- Connect to character spawning (handles both new players and respawns)
	Players.PlayerAdded:Connect(function(player)
		-- Handle initial spawn
		if player.Character then
			task.spawn(function()
				-- Wait for character to fully load
				local character = player.Character
				local humanoid = character:WaitForChild("Humanoid", 5)
				local backpack = player:WaitForChild("Backpack", 5)
				if humanoid and backpack then
					task.wait(0.5) -- Small delay to ensure everything is loaded
					WeaponService.GiveLoadoutWeapons(player)
				end
			end)
		end
		
		-- Handle respawns
		player.CharacterAdded:Connect(function(character)
			task.spawn(function()
				-- Wait for character to fully load
				local humanoid = character:WaitForChild("Humanoid", 5)
				local backpack = player:WaitForChild("Backpack", 5)
				if humanoid and backpack then
					task.wait(0.5) -- Small delay to ensure everything is loaded
					WeaponService.GiveLoadoutWeapons(player)
				else
					warn("[WeaponService] Character or Backpack not found for " .. player.Name)
				end
			end)
		end)
		
		-- Cleanup weapons when character is removed (prevents memory leaks)
		player.CharacterRemoving:Connect(function(character)
			-- Weapons will be automatically cleaned up when character is destroyed
			-- But we can log it for debugging
			print("[WeaponService] Character removed for " .. player.Name .. ", weapons cleaned up")
		end)
	end)
	
	-- Listen for loadout updates from client
	Network.OnServerEvent("UpdateLoadout", function(player, loadoutData)
		-- Validate player has character before updating loadout
		if not player.Character then
			warn("[WeaponService] Cannot update loadout for " .. player.Name .. " - no character")
			return
		end
		
		LoadoutService.SaveLoadout(player, loadoutData)
		WeaponService.GiveLoadoutWeapons(player)
	end)
	
	print("[WeaponService] Initialized - Ready for multiplayer")
end

return WeaponService
