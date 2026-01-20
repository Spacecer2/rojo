--[[
	DamageCalculator - Shared utility for calculating weapon damage
	Handles distance-based falloff and multipliers for hit regions.
]]

local DamageCalculator = {}

--[[
	Calculate damage based on distance and weapon configuration
	@param distance - Distance between shooter and target in studs
	@param config - Weapon base stats configuration (from WeaponData)
	@param hitRegion - "Head", "Chest", "Stomach", or "Limbs"
	@return number - Calculated damage
]]
function DamageCalculator.Calculate(distance, config, hitRegion)
	local damageStats = config.Damage
	local rangeStats = config.Range
	
	-- 1. Base Damage based on Region
	local baseDamage = damageStats[hitRegion] or damageStats.Chest
	
	-- 2. Falloff Calculation
	-- MW 2019 typically has 2-3 damage ranges. 
	-- We'll implement a simple 2-stage linear falloff for now.
	-- Min range: damage is 100% of base
	-- Max range: damage is at its minimum (usually defined as a percentage or specific value)
	
	local finalDamage = baseDamage
	
	if distance <= rangeStats.Min then
		finalDamage = baseDamage
	elseif distance >= rangeStats.Max then
		-- Apply maximum falloff (e.g., 60% damage at max range)
		finalDamage = baseDamage * 0.6
	else
		-- Linear interpolation between Min and Max range
		local ratio = (distance - rangeStats.Min) / (rangeStats.Max - rangeStats.Min)
		local minMultiplier = 1.0
		local maxMultiplier = 0.6
		
		local multiplier = minMultiplier + (maxMultiplier - minMultiplier) * ratio
		finalDamage = baseDamage * multiplier
	end
	
	return math.max(0, finalDamage)
end

return DamageCalculator
