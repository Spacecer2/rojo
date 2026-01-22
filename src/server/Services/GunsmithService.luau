--[[
	GunsmithService - Server-side attachment validation and stat calculation
	Validates attachment compatibility and calculates modified weapon stats
	Integrates with WeaponService to apply attachment effects
]]

local ServerScriptService = game:GetService("ServerScriptService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local WeaponData = require(ReplicatedStorage.Shared.Constants.WeaponData)
local AttachmentData = require(ReplicatedStorage.Shared.Constants.AttachmentData)
local WeaponUtils = require(ReplicatedStorage.Shared.Utils.WeaponUtils)

local GunsmithService = {}

-- Validate that an attachment exists and is valid
function GunsmithService.ValidateAttachment(attachmentName: string): boolean
	if not attachmentName or attachmentName == "" then
		return false
	end
	
	local attachment = AttachmentData.Attachments[attachmentName]
	return attachment ~= nil
end

-- Validate that an attachment is compatible with a weapon's slots
function GunsmithService.ValidateAttachmentSlot(weaponName: string, attachmentName: string): boolean
	local weapon = WeaponData.Weapons[weaponName]
	if not weapon then
		return false
	end
	
	local attachment = AttachmentData.Attachments[attachmentName]
	if not attachment then
		return false
	end
	
	-- Check if weapon has the required slot for this attachment category
	local attachmentCategory = attachment.Category
	local weaponSlots = weapon.Slots
	
	-- Map attachment categories to slot names
	local categoryToSlot = {
		["Optic"] = "Optic",
		["Muzzle"] = "Muzzle",
		["Barrel"] = "Barrel",
		["Magazine"] = "Magazine",
		["Underbarrel"] = "Underbarrel",
		["Stock"] = "Stock",
		["RearGrip"] = "RearGrip",
		["Laser"] = "Laser",
		["Ammunition"] = "Ammunition",
		["TriggerAction"] = "TriggerAction",
	}
	
	local requiredSlot = categoryToSlot[attachmentCategory]
	if not requiredSlot then
		warn("[GunsmithService] Unknown attachment category: " .. tostring(attachmentCategory))
		return false
	end
	
	-- Check if weapon has this slot
	for _, slot in ipairs(weaponSlots) do
		if slot == requiredSlot then
			return true
		end
	end
	
	return false
end

-- Validate a complete attachment configuration for a weapon
function GunsmithService.ValidateAttachmentConfig(weaponName: string, attachments: {string}): (boolean, string?)
	if not weaponName or not WeaponData.Weapons[weaponName] then
		return false, "Invalid weapon name: " .. tostring(weaponName)
	end
	
	if not attachments then
		attachments = {}
	end
	
	-- Track which slots are used (prevent duplicates)
	local usedSlots = {}
	
	for _, attachmentName in ipairs(attachments) do
		-- Validate attachment exists
		if not GunsmithService.ValidateAttachment(attachmentName) then
			return false, "Invalid attachment: " .. tostring(attachmentName)
		end
		
		-- Validate attachment slot compatibility
		if not GunsmithService.ValidateAttachmentSlot(weaponName, attachmentName) then
			return false, "Attachment " .. attachmentName .. " is not compatible with weapon " .. weaponName
		end
		
		-- Check for duplicate slot usage
		local attachment = AttachmentData.Attachments[attachmentName]
		local category = attachment.Category
		local categoryToSlot = {
			["Optic"] = "Optic",
			["Muzzle"] = "Muzzle",
			["Barrel"] = "Barrel",
			["Magazine"] = "Magazine",
			["Underbarrel"] = "Underbarrel",
			["Stock"] = "Stock",
			["RearGrip"] = "RearGrip",
			["Laser"] = "Laser",
			["Ammunition"] = "Ammunition",
			["TriggerAction"] = "TriggerAction",
		}
		local slot = categoryToSlot[category]
		
		if usedSlots[slot] then
			return false, "Duplicate attachment in slot: " .. slot
		end
		
		usedSlots[slot] = true
	end
	
	return true, nil
end

-- Calculate modified weapon stats with attachments
function GunsmithService.CalculateWeaponStats(weaponName: string, attachments: {string}?): {[string]: any}?
	-- Validate configuration first
	local isValid, errorMsg = GunsmithService.ValidateAttachmentConfig(weaponName, attachments or {})
	if not isValid then
		warn("[GunsmithService] Invalid attachment config for " .. weaponName .. ": " .. tostring(errorMsg))
		return nil
	end
	
	-- Use WeaponUtils to calculate stats
	return WeaponUtils.CalculateStats(weaponName, attachments or {})
end

-- Get attachment information for a weapon
function GunsmithService.GetAvailableAttachments(weaponName: string): {[string]: {[string]: any}}
	local weapon = WeaponData.Weapons[weaponName]
	if not weapon then
		return {}
	end
	
	local available = {}
	local weaponSlots = weapon.Slots
	
	-- Map slot names to categories
	local slotToCategory = {
		["Optic"] = "Optic",
		["Muzzle"] = "Muzzle",
		["Barrel"] = "Barrel",
		["Magazine"] = "Magazine",
		["Underbarrel"] = "Underbarrel",
		["Stock"] = "Stock",
		["RearGrip"] = "RearGrip",
		["Laser"] = "Laser",
		["Ammunition"] = "Ammunition",
		["TriggerAction"] = "TriggerAction",
	}
	
	-- Find all attachments that match weapon's slots
	for attachmentName, attachment in pairs(AttachmentData.Attachments) do
		local category = attachment.Category
		for _, slot in ipairs(weaponSlots) do
			if slotToCategory[slot] == category then
				if not available[category] then
					available[category] = {}
				end
				available[category][attachmentName] = attachment
				break
			end
		end
	end
	
	return available
end

-- Apply attachment stats to a weapon tool (sets attributes for client-side use)
function GunsmithService.ApplyAttachmentsToWeapon(weaponTool: Tool, weaponName: string, attachments: {string}?)
	if not weaponTool or not weaponTool:IsA("Tool") then
		warn("[GunsmithService] Invalid weapon tool provided")
		return false
	end
	
	-- Calculate stats
	local stats = GunsmithService.CalculateWeaponStats(weaponName, attachments)
	if not stats then
		warn("[GunsmithService] Failed to calculate stats for " .. weaponName)
		return false
	end
	
	-- Store attachment IDs as attribute (comma-separated)
	if attachments and #attachments > 0 then
		weaponTool:SetAttribute("AttachmentIds", table.concat(attachments, ","))
	else
		weaponTool:SetAttribute("AttachmentIds", "")
	end
	
	-- Store calculated stats as attributes for client-side access
	weaponTool:SetAttribute("WeaponName", weaponName)
	weaponTool:SetAttribute("FireRate", stats.FireRate)
	weaponTool:SetAttribute("MagazineSize", stats.MagazineSize)
	weaponTool:SetAttribute("ReloadTime", stats.ReloadTime)
	weaponTool:SetAttribute("BulletVelocity", stats.BulletVelocity)
	weaponTool:SetAttribute("AimingStability", stats.AimingStability)
	weaponTool:SetAttribute("SoundSuppressed", stats.SoundSuppressed)
	weaponTool:SetAttribute("MuzzleFlashVisible", stats.MuzzleFlashVisible)
	
	-- Store damage values (as JSON string since attributes don't support tables directly)
	local HttpService = game:GetService("HttpService")
	weaponTool:SetAttribute("Damage", HttpService:JSONEncode(stats.Damage))
	weaponTool:SetAttribute("Recoil", HttpService:JSONEncode(stats.Recoil))
	weaponTool:SetAttribute("Range", HttpService:JSONEncode(stats.Range))
	weaponTool:SetAttribute("Mobility", HttpService:JSONEncode(stats.Mobility))
	
	print("[GunsmithService] Applied " .. #(attachments or {}) .. " attachments to " .. weaponName)
	return true
end

-- Initialize service
function GunsmithService.Init()
	print("[GunsmithService] Initialized - Ready for attachment validation and stat calculation")
end

return GunsmithService
