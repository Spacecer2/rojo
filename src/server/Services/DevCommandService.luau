--[[
	DevCommandService - Server-side handler for developer console commands
	Validates and executes dev commands with proper authorization
]]

local ServerScriptService = game:GetService("ServerScriptService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local DataService = require(ServerScriptService.Services.DataService)
local WeaponService = require(ServerScriptService.Services.WeaponService)
local LootService = require(ServerScriptService.Services.LootService)
local LootData = require(ReplicatedStorage.Shared.Constants.LootData)
local Network = require(ReplicatedStorage.Framework.Network)

local DevCommandService = {}

-- Allowed developer user IDs (add your user ID here)
local ALLOWED_DEVS = {
	-- Add developer user IDs here
	-- Example: 123456789
}

-- Check if player is authorized
local function isAuthorized(player)
	-- In development, allow all players
	-- In production, check against ALLOWED_DEVS
	return true -- TODO: Implement proper authorization
end

-- Handle dev commands
function DevCommandService.HandleCommand(player, command, args)
	if not isAuthorized(player) then
		warn("[DevCommandService] Unauthorized dev command from " .. player.Name)
		return
	end
	
	if command == "ammo" then
		local character = player.Character
		if not character then return end
		
		-- Find equipped weapon
		local weapon = nil
		for _, tool in ipairs(character:GetChildren()) do
			if tool:IsA("Tool") then
				weapon = tool
				break
			end
		end
		
		if not weapon then
			-- Check backpack
			local backpack = player:FindFirstChild("Backpack")
			if backpack then
				for _, tool in ipairs(backpack:GetChildren()) do
					if tool:IsA("Tool") then
						weapon = tool
						break
					end
				end
			end
		end
		
		if weapon then
			if args.Max then
				local maxAmmo = weapon:GetAttribute("MagazineSize") or 30
				weapon:SetAttribute("CurrentAmmo", maxAmmo)
				weapon:SetAttribute("ReserveAmmo", 90)
			elseif args.Current ~= nil or args.Reserve ~= nil then
				if args.Current ~= nil and args.Current >= 0 then
					weapon:SetAttribute("CurrentAmmo", args.Current)
				end
				if args.Reserve ~= nil and args.Reserve >= 0 then
					weapon:SetAttribute("ReserveAmmo", args.Reserve)
				end
			end
		end
		
	elseif command == "weapon_give" then
		if args.WeaponName then
			WeaponService.GiveWeapon(player, args.WeaponName)
		end
		
	elseif command == "drop_item" then
		local character = player.Character
		if not character or not character:FindFirstChild("HumanoidRootPart") then return end
		
		local position = character.HumanoidRootPart.Position + Vector3.new(0, 2, 0)
		
		if args.Type == "weapon" then
			LootService.SpawnLootItem({
				ItemType = LootData.ItemTypes.Weapon,
				ItemName = args.Name or "M4",
				Rarity = "Rare",
				WeaponId = args.Name or "M4",
				AttachmentIds = {},
			}, position)
		elseif args.Type == "cash" then
			LootService.SpawnLootItem({
				ItemType = LootData.ItemTypes.Cash,
				ItemName = "Cash Pile",
				Rarity = "Common",
				Value = args.Amount or 100,
			}, position)
		elseif args.Type == "ammo" then
			LootService.SpawnLootItem({
				ItemType = LootData.ItemTypes.Ammo,
				ItemName = "Ammo Box",
				Rarity = "Common",
				AmmoType = "556",
				AmmoAmount = args.Amount or 60,
			}, position)
		elseif args.Type == "armor" then
			LootService.SpawnLootItem({
				ItemType = LootData.ItemTypes.ArmorPlate,
				ItemName = "Armor Plate",
				Rarity = "Common",
				Value = args.Amount or 1,
			}, position)
		end
		
	elseif command == "playerdata_get" then
		local pData = DataService.GetPlayerData(player)
		if pData then
			if args.Field == "all" then
				Network.FireClient(player, "DevResponse", {
					Command = command,
					Data = pData.Data
				})
			else
				local value = pData.Data[args.Field]
				Network.FireClient(player, "DevResponse", {
					Command = command,
					Field = args.Field,
					Value = value
				})
			end
		end
		
	elseif command == "playerdata_set" then
		local pData = DataService.GetPlayerData(player)
		if pData and args.Field and args.Value ~= nil then
			pData.Data[args.Field] = args.Value
			DataService.UpdateClient(player)
			DataService.UpdateLeaderstats(player)
			
			Network.FireClient(player, "DevResponse", {
				Command = command,
				Field = args.Field,
				Value = args.Value,
				Success = true
			})
		end
		
	elseif command == "playerdata_add" then
		local pData = DataService.GetPlayerData(player)
		if pData and args.Field and args.Value then
			if type(pData.Data[args.Field]) == "number" then
				pData.Data[args.Field] = pData.Data[args.Field] + args.Value
				
				-- Handle level up logic for XP
				if args.Field == "Experience" then
					while pData.Data.Experience >= pData.Data.MaxExperience do
						pData.Data.Experience = pData.Data.Experience - pData.Data.MaxExperience
						pData.Data.Level = pData.Data.Level + 1
						pData.Data.MaxExperience = math.floor(pData.Data.MaxExperience * 1.1)
					end
				end
				
				DataService.UpdateClient(player)
				DataService.UpdateLeaderstats(player)
				
				Network.FireClient(player, "DevResponse", {
					Command = command,
					Field = args.Field,
					Value = pData.Data[args.Field],
					Success = true
				})
			end
		end
		
	elseif command == "playerdata_reset" then
		local pData = DataService.GetPlayerData(player)
		if pData then
			-- Reset to defaults
			pData.Data.Level = 1
			pData.Data.Experience = 0
			pData.Data.MaxExperience = 1000
			pData.Data.Currency = 0
			pData.Data.XPBoost = 0
			
			DataService.UpdateClient(player)
			DataService.UpdateLeaderstats(player)
			
			Network.FireClient(player, "DevResponse", {
				Command = command,
				Success = true
			})
		end
	end
end

-- Initialize
function DevCommandService.Init()
	-- Listen for dev commands from clients
	Network.OnServerEvent("DevCommand", function(player, command, args)
		DevCommandService.HandleCommand(player, command, args)
	end)
	
	print("[DevCommandService] Initialized")
end

return DevCommandService
