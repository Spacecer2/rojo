--[[
	HitscanHandler - Server-side raycasting with penetration support
	Handles weapon firing validation and hit detection for hitscan weapons.
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Constants = ReplicatedStorage:WaitForChild("Constants")
local WeaponData = require(Constants:WaitForChild("WeaponData"))
local DamageCalculator = require(ReplicatedStorage.Utils.DamageCalculator)

local HitscanHandler = {}

local MAX_PENETRATION_DEPTH = 3
local PENETRATION_LOSS_PERCENT = 0.3 -- 30% damage loss per surface

-- Materials that can be penetrated
local PENETRABLE_MATERIALS = {
	[Enum.Material.Wood] = true,
	[Enum.Material.Plaster] = true,
	[Enum.Material.Plastic] = true, -- For thin props
	[Enum.Material.Fabric] = true,
	[Enum.Material.Glass] = true,
}

function HitscanHandler.PerformRaycast(player, origin, direction, weaponName)
	local weaponConfig = WeaponData.Weapons[weaponName]
	if not weaponConfig then return nil end
	
	local raycastParams = RaycastParams.new()
	raycastParams.FilterType = Enum.RaycastFilterType.Exclude
	raycastParams.FilterDescendantsInstances = {player.Character, workspace:FindFirstChild("Bullets")}
	raycastParams.IgnoreWater = true
	
	local currentOrigin = origin
	local currentDirection = direction * (weaponConfig.BaseStats.Range.Max or 500)
	local hits = {}
	local surfacesPenetrated = 0
	
	while surfacesPenetrated <= MAX_PENETRATION_DEPTH do
		local result = workspace:Raycast(currentOrigin, currentDirection, raycastParams)
		if not result then break end
		
		local hitInstance = result.Instance
		local hitPosition = result.Position
		local hitMaterial = result.Material
		
		-- Record hit
		table.insert(hits, {
			Instance = hitInstance,
			Position = hitPosition,
			Material = hitMaterial,
			Distance = (hitPosition - origin).Magnitude,
			PenetrationLevel = surfacesPenetrated
		})
		
		-- Check if we should stop or penetrate
		local isPlayer = hitInstance.Parent:FindFirstChild("Humanoid") or hitInstance.Parent.Parent:FindFirstChild("Humanoid")
		
		if isPlayer then
			-- Stop at players (one player per bullet for balance, or until they die)
			break
		end
		
		if PENETRABLE_MATERIALS[hitMaterial] then
			surfacesPenetrated += 1
			-- Move origin slightly forward to avoid hitting the same surface again
			currentOrigin = hitPosition + (direction * 0.1)
			-- Reduce remaining distance (not strictly necessary but good for precision)
			-- currentDirection = ...
		else
			break -- Stopped by hard surface
		end
	end
	
	return hits
end

function HitscanHandler.ProcessHits(player, hits, weaponName)
	local weaponConfig = WeaponData.Weapons[weaponName]
	if not weaponConfig then return end
	
	for _, hit in ipairs(hits) do
		local character = hit.Instance.Parent
		local humanoid = character:FindFirstChild("Humanoid")
		if not humanoid then
			character = character.Parent
			humanoid = character:FindFirstChild("Humanoid")
		end
		
		if humanoid and humanoid.Health > 0 then
			-- Calculate region
			local region = "Chest"
			if hit.Instance.Name == "Head" then
				region = "Head"
			elseif hit.Instance.Name:find("Leg") or hit.Instance.Name:find("Arm") then
				region = "Limbs"
			end
			
			-- Base damage with falloff
			local damage = DamageCalculator.Calculate(hit.Distance, weaponConfig.BaseStats, region)
			
			-- Apply penetration penalty
			if hit.PenetrationLevel > 0 then
				damage = damage * math.pow(1 - PENETRATION_LOSS_PERCENT, hit.PenetrationLevel)
			end
			
			humanoid:TakeDamage(damage)
			
			-- Only damage the first person hit (or implement pierce logic)
			break 
		end
	end
end

return HitscanHandler
