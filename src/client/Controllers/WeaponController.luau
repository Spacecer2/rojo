--[[
	WeaponController - Client-side weapon handling
	Manages weapon state, ammo, shooting, and reloading
	Integrates with HUD for ammo display and reload progress
]]

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer
local character = nil
local backpack = nil

-- Initialize character reference
local function initializeCharacter()
	character = player.Character
	if character then
		backpack = player:WaitForChild("Backpack", 5)
	end
end

-- Wait for character
if player.Character then
	initializeCharacter()
end
player.CharacterAdded:Connect(initializeCharacter)

local WeaponController = {}

-- Weapon state
local currentWeapon = nil
local currentAmmo = 0
local currentReserve = 0
local maxAmmo = 30
local maxReserve = 90
local isReloading = false
local reloadStartTime = 0
local reloadDuration = 2.0

-- Events
local WeaponStateChanged = Instance.new("BindableEvent")
WeaponController.WeaponStateChanged = WeaponStateChanged.Event

-- Get current equipped weapon
local function getEquippedWeapon()
	if not character then return nil end
	
	-- Check if weapon is equipped (in character)
	for _, tool in ipairs(character:GetChildren()) do
		if tool:IsA("Tool") then
			return tool
		end
	end
	
	-- Check backpack for first weapon
	if backpack then
		for _, tool in ipairs(backpack:GetChildren()) do
			if tool:IsA("Tool") then
				return tool
			end
		end
	end
	
	return nil
end

-- Update weapon stats from tool attributes
local function updateWeaponStats(tool)
	if not tool then
		currentWeapon = nil
		currentAmmo = 0
		currentReserve = 0
		maxAmmo = 30
		return
	end
	
	currentWeapon = tool
	local weaponName = tool:GetAttribute("WeaponName") or tool.Name
	local magazineSize = tool:GetAttribute("MagazineSize") or 30
	local reloadTime = tool:GetAttribute("ReloadTime") or 2.0
	
	maxAmmo = magazineSize
	reloadDuration = reloadTime
	
	-- Read ammo from attributes if set (for dev commands)
	local attrAmmo = tool:GetAttribute("CurrentAmmo")
	local attrReserve = tool:GetAttribute("ReserveAmmo")
	
	if attrAmmo ~= nil then
		currentAmmo = attrAmmo
		tool:SetAttribute("CurrentAmmo", nil) -- Clear after reading
	end
	if attrReserve ~= nil then
		currentReserve = attrReserve
		tool:SetAttribute("ReserveAmmo", nil) -- Clear after reading
	end
	
	-- Initialize ammo if not set
	if currentAmmo == 0 and attrAmmo == nil then
		currentAmmo = maxAmmo
		currentReserve = maxReserve
	end
	
	WeaponStateChanged:Fire({
		Weapon = weaponName,
		Ammo = currentAmmo,
		Reserve = currentReserve,
		MaxAmmo = maxAmmo,
		MaxReserve = maxReserve,
		IsReloading = isReloading
	})
end

-- Fire weapon
function WeaponController.Fire()
	if not currentWeapon or isReloading then return false end
	if currentAmmo <= 0 then
		-- Auto-reload if empty
		WeaponController.Reload()
		return false
	end
	
	currentAmmo = currentAmmo - 1
	
	WeaponStateChanged:Fire({
		Weapon = currentWeapon:GetAttribute("WeaponName") or currentWeapon.Name,
		Ammo = currentAmmo,
		Reserve = currentReserve,
		MaxAmmo = maxAmmo,
		MaxReserve = maxReserve,
		IsReloading = isReloading
	})
	
	return true
end

-- Reload weapon
function WeaponController.Reload()
	if not currentWeapon or isReloading then return false end
	if currentReserve <= 0 or currentAmmo >= maxAmmo then return false end
	
	isReloading = true
	reloadStartTime = tick()
	
	WeaponStateChanged:Fire({
		Weapon = currentWeapon:GetAttribute("WeaponName") or currentWeapon.Name,
		Ammo = currentAmmo,
		Reserve = currentReserve,
		MaxAmmo = maxAmmo,
		MaxReserve = maxReserve,
		IsReloading = isReloading,
		ReloadProgress = 0
	})
	
	-- Simulate reload
	task.spawn(function()
		task.wait(reloadDuration)
		
		if currentWeapon then
			local ammoNeeded = maxAmmo - currentAmmo
			local ammoToAdd = math.min(ammoNeeded, currentReserve)
			
			currentAmmo = currentAmmo + ammoToAdd
			currentReserve = currentReserve - ammoToAdd
			
			isReloading = false
			
			WeaponStateChanged:Fire({
				Weapon = currentWeapon:GetAttribute("WeaponName") or currentWeapon.Name,
				Ammo = currentAmmo,
				Reserve = currentReserve,
				MaxAmmo = maxAmmo,
				MaxReserve = maxReserve,
				IsReloading = isReloading
			})
		end
	end)
	
	return true
end

-- Get current weapon state
function WeaponController.GetWeaponState()
	return {
		Weapon = currentWeapon and (currentWeapon:GetAttribute("WeaponName") or currentWeapon.Name) or nil,
		Ammo = currentAmmo,
		Reserve = currentReserve,
		MaxAmmo = maxAmmo,
		MaxReserve = maxReserve,
		IsReloading = isReloading,
		ReloadProgress = isReloading and math.min(1, (tick() - reloadStartTime) / reloadDuration) or 0
	}
end

-- Initialize
function WeaponController.Init()
	-- Monitor weapon changes
	local function setupWeaponMonitoring()
		if not character then return end
		
		character.ChildAdded:Connect(function(child)
			if child:IsA("Tool") then
				updateWeaponStats(child)
			end
		end)
		
		character.ChildRemoved:Connect(function(child)
			if child:IsA("Tool") and child == currentWeapon then
				updateWeaponStats(nil)
			end
		end)
		
		if backpack then
			backpack.ChildAdded:Connect(function(child)
				if child:IsA("Tool") and not currentWeapon then
					updateWeaponStats(child)
				end
			end)
		end
		
		-- Initial weapon check
		task.spawn(function()
			task.wait(1) -- Wait for character to fully load
			local weapon = getEquippedWeapon()
			if weapon then
				updateWeaponStats(weapon)
			end
		end)
	end
	
	-- Setup for existing character or wait for spawn
	if character then
		setupWeaponMonitoring()
	end
	player.CharacterAdded:Connect(function()
		initializeCharacter()
		setupWeaponMonitoring()
	end)
	
	-- Update reload progress and check for attribute changes
	RunService.Heartbeat:Connect(function()
		-- Check for attribute changes (from dev commands)
		if currentWeapon then
			local attrAmmo = currentWeapon:GetAttribute("CurrentAmmo")
			local attrReserve = currentWeapon:GetAttribute("ReserveAmmo")
			
			if attrAmmo ~= nil then
				currentAmmo = attrAmmo
				currentWeapon:SetAttribute("CurrentAmmo", nil)
			end
			if attrReserve ~= nil then
				currentReserve = attrReserve
				currentWeapon:SetAttribute("ReserveAmmo", nil)
			end
		end
		
		if isReloading and currentWeapon then
			local progress = math.min(1, (tick() - reloadStartTime) / reloadDuration)
			WeaponStateChanged:Fire({
				Weapon = currentWeapon:GetAttribute("WeaponName") or currentWeapon.Name,
				Ammo = currentAmmo,
				Reserve = currentReserve,
				MaxAmmo = maxAmmo,
				MaxReserve = maxReserve,
				IsReloading = isReloading,
				ReloadProgress = progress
			})
		end
	end)
	
	print("[WeaponController] Initialized")
end

return WeaponController
