--[[
	WeaponUtils - Utilities for weapon stat calculations and logic
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Shared = ReplicatedStorage:WaitForChild("shared")
local Constants = Shared:WaitForChild("Constants")

local WeaponData = require(Constants:WaitForChild("WeaponData"))
local AttachmentData = require(Constants:WaitForChild("AttachmentData"))

local WeaponUtils = {}

-- Calculate final stats based on base weapon and a list of attachments
function WeaponUtils.CalculateStats(weaponName, equippedAttachments)
	local baseWeapon = WeaponData.Weapons[weaponName]
	if not baseWeapon then return nil end

	-- Deep clone base stats
	local stats = {
		Damage = table.clone(baseWeapon.BaseStats.Damage),
		FireRate = baseWeapon.BaseStats.FireRate,
		Recoil = table.clone(baseWeapon.BaseStats.Recoil),
		Range = table.clone(baseWeapon.BaseStats.Range),
		Mobility = table.clone(baseWeapon.BaseStats.Mobility),
		MagazineSize = baseWeapon.BaseStats.MagazineSize,
		ReloadTime = baseWeapon.BaseStats.ReloadTime,
		
		-- Derived/Extra stats
		BulletVelocity = 1000, -- Default base velocity
		AimingStability = 1.0,
		SoundSuppressed = false,
		MuzzleFlashVisible = true,
	}

	for _, attachmentName in pairs(equippedAttachments) do
		local attachment = AttachmentData.Attachments[attachmentName]
		if not attachment then continue end

		local mods = attachment.Modifiers
		if not mods then continue end

		-- Apply Modifiers
		if mods.Range then
			stats.Range.Min *= (1 + mods.Range)
			stats.Range.Max *= (1 + mods.Range)
		end

		if mods.BulletVelocity then
			stats.BulletVelocity *= (1 + mods.BulletVelocity)
		end

		if mods.ADSSpeed then
			stats.Mobility.ADSSpeed += mods.ADSSpeed
		end

		if mods.MovementSpeed then
			stats.Mobility.MovementSpeed += mods.MovementSpeed
		end

		if mods.RecoilControl then
			stats.Recoil.Vertical *= (1 - mods.RecoilControl)
			stats.Recoil.Horizontal *= (1 - mods.RecoilControl)
		end
		
		if mods.HorizontalRecoilControl then
			stats.Recoil.Horizontal *= (1 - mods.HorizontalRecoilControl)
		end

		if mods.MagazineSize then
			stats.MagazineSize += mods.MagazineSize
		end

		if mods.ReloadTime then
			stats.ReloadTime += mods.ReloadTime
		end

		if mods.AimingStability then
			stats.AimingStability += mods.AimingStability
		end

		if mods.SoundSuppressed ~= nil then
			stats.SoundSuppressed = mods.SoundSuppressed
		end

		if mods.MuzzleFlashVisible ~= nil then
			stats.MuzzleFlashVisible = mods.MuzzleFlashVisible
		end
	end

	return stats
end

-- Normalize stats for UI display (0 to 1 range)
-- This is a simplified version; real MW uses complex curves for these.
function WeaponUtils.GetUINormalizedStats(stats)
	return {
		Damage = math.clamp(stats.Damage.Chest / 50, 0, 1),
		Range = math.clamp(stats.Range.Max / 150, 0, 1),
		FireRate = math.clamp(stats.FireRate / 1000, 0, 1),
		Accuracy = math.clamp(1 / (stats.Recoil.Vertical + stats.Recoil.Horizontal + 1), 0, 1),
		Mobility = math.clamp(stats.Mobility.MovementSpeed / 1.2, 0, 1),
		Control = math.clamp(stats.AimingStability / 2, 0, 1),
	}
end

return WeaponUtils
