--[[
	ProjectileManager - Server-side projectile physics and collision
	Handles physical bullet travel, gravity drop, and realistic travel time.
]]

local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local WeaponData = require(ReplicatedStorage.Constants.WeaponData)
local HitscanHandler = require(ServerScriptService.Modules.HitscanHandler)

local ProjectileManager = {}
local activeProjectiles = {}

-- Constant
local GRAVITY = Vector3.new(0, -workspace.Gravity, 0)
local BULLET_LIFE_TIME = 5 -- Max seconds a bullet can exist

function ProjectileManager.Fire(player, origin, direction, weaponName)
	local weaponConfig = WeaponData.Weapons[weaponName]
	if not weaponConfig then return end
	
	local projectileStats = weaponConfig.ProjectileStats or {
		Velocity = 1500, -- Studs per second
		GravityMultiplier = 1.0,
		Mass = 1
	}
	
	local projectile = {
		Player = player,
		WeaponName = weaponName,
		Position = origin,
		Velocity = direction.Unit * projectileStats.Velocity,
		Gravity = GRAVITY * (projectileStats.GravityMultiplier or 1),
		StartTime = tick(),
		RaycastParams = RaycastParams.new()
	}
	
	projectile.RaycastParams.FilterType = Enum.RaycastFilterType.Exclude
	projectile.RaycastParams.FilterDescendantsInstances = {player.Character}
	projectile.RaycastParams.IgnoreWater = true
	
	table.insert(activeProjectiles, projectile)
end

local function updateProjectiles(dt)
	local now = tick()
	
	for i = #activeProjectiles, 1, -1 do
		local proj = activeProjectiles[i]
		
		-- Check expiry
		if (now - proj.StartTime) > BULLET_LIFE_TIME then
			table.remove(activeProjectiles, i)
			continue
		end
		
		-- Calculate next position
		-- P = P0 + V0*t + 0.5*a*t^2
		local displacement = (proj.Velocity * dt) + (0.5 * proj.Gravity * dt * dt)
		local nextPosition = proj.Position + displacement
		
		-- Check for collisions between current and next position
		local direction = nextPosition - proj.Position
		local result = workspace:Raycast(proj.Position, direction, proj.RaycastParams)
		
		if result then
			-- Process Hit
			-- We reuse HitscanHandler's logic for processing hits on players
			HitscanHandler.ProcessHits(proj.Player, {{
				Instance = result.Instance,
				Position = result.Position,
				Material = result.Material,
				Distance = (result.Position - proj.Position).Magnitude, -- This distance is from start of frame
				PenetrationLevel = 0 -- For now projectiles don't penetrate (could be added)
			}}, proj.WeaponName)
			
			-- Remove projectile on hit
			table.remove(activeProjectiles, i)
		else
			-- Update velocity and position
			proj.Position = nextPosition
			proj.Velocity = proj.Velocity + (proj.Gravity * dt)
		end
	end
end

-- Hook into RunService
RunService.Heartbeat:Connect(updateProjectiles)

return ProjectileManager
