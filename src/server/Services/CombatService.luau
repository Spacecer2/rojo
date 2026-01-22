--[[
	CombatService - Server-side combat management
	Handles weapon firing requests, hit validation, and damage application.
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local Network = require(ReplicatedStorage.Framework.Network)
local HitscanHandler = require(ServerScriptService.Modules.HitscanHandler)
local ProjectileManager = require(ServerScriptService.Modules.ProjectileManager)
local WeaponData = require(ReplicatedStorage.Constants.WeaponData)

local CombatService = {}

function CombatService.Init()
	-- Listen for fire requests
	Network.OnServerEvent("FireWeapon", function(player, data)
		-- data: { WeaponName, Origin, Direction }
		if not data or not data.WeaponName or not data.Origin or not data.Direction then return end
		
		local weaponConfig = WeaponData.Weapons[data.WeaponName]
		if not weaponConfig then return end
		
		-- TODO: Validate fire rate, ammo, and distance from origin to character
		
		if weaponConfig.BallisticType == "Projectile" then
			ProjectileManager.Fire(player, data.Origin, data.Direction, data.WeaponName)
			
			-- Replicate muzzle effect to other clients (travel effects handled separately if needed)
			for _, otherPlayer in ipairs(game:GetService("Players"):GetPlayers()) do
				if otherPlayer ~= player then
					Network.FireClient(otherPlayer, "WeaponFireEffect", {
						Player = player,
						WeaponName = data.WeaponName,
						Origin = data.Origin,
						Direction = data.Direction,
						IsProjectile = true
					})
				end
			end
		else
			-- Default to hitscan
			local hits = HitscanHandler.PerformRaycast(player, data.Origin, data.Direction, data.WeaponName)
			if hits then
				HitscanHandler.ProcessHits(player, hits, data.WeaponName)
				
				-- Replicate effects to other clients
				for _, otherPlayer in ipairs(game:GetService("Players"):GetPlayers()) do
					if otherPlayer ~= player then
						Network.FireClient(otherPlayer, "WeaponFireEffect", {
							Player = player,
							WeaponName = data.WeaponName,
							Origin = data.Origin,
							Direction = data.Direction,
							Hits = hits,
							IsProjectile = false
						})
					end
				end
			end
		end
	end)
	
	print("[CombatService] Initialized")
end

return CombatService
