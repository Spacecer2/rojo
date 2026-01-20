--[[
	WeaponController - Client-side weapon management
	Handles input, local fire logic, effects, and communication with CombatService.
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

local Network = require(ReplicatedStorage.Framework.Network)
local WeaponData = require(ReplicatedStorage.Constants.WeaponData)
local SharedState = require(script.Parent.Parent.SharedState)
local TracerManager = require(script.Parent.Parent.Modules.TracerManager)

local WeaponController = {}

local player = Players.LocalPlayer
local camera = Workspace.CurrentCamera

-- Local State
local currentWeaponName = "M4" -- Default for now
local currentAmmo = 0
local isReloading = false
local lastFireTime = 0
local inputController = nil

local currentRecoil = Vector3.zero
local recoilVelocity = Vector3.zero
local recoilStiffness = 15
local recoilDamping = 5

function WeaponController:Init()
	-- Wait for character and input controller
	player.CharacterAdded:Connect(function(char)
		self:SetupCharacter(char)
	end)
	
	if player.Character then
		self:SetupCharacter(player.Character)
	end
	
	-- Listen for effects from server
	Network.OnClientEvent("WeaponFireEffect", function(data)
		self:PlayFireEffect(data)
	end)

	RunService.RenderStepped:Connect(function(dt)
		self:UpdateRecoil(dt)
	end)
end

function WeaponController:UpdateRecoil(dt)
	local force = -recoilStiffness * currentRecoil - recoilDamping * recoilVelocity
	recoilVelocity = recoilVelocity + force * dt
	currentRecoil = currentRecoil + recoilVelocity * dt
	
	if not player:GetAttribute("InMenu") and camera.CameraType == Enum.CameraType.Custom then
		camera.CFrame = camera.CFrame * CFrame.Angles(math.rad(currentRecoil.X), math.rad(currentRecoil.Y), 0)
	end
end

function WeaponController:Start()
	-- Initial state setup
	local config = WeaponData.Weapons[currentWeaponName]
	if config then
		currentAmmo = config.BaseStats.MagazineSize
	end

	-- Connect to InputController from SharedState
	task.spawn(function()
		local controller = SharedState.WaitFor("InputController")
		if controller then
			self:SetInputController(controller)
		end
	end)
end

function WeaponController:SetupCharacter(char)
	-- Try to get InputManager from character (MovementController creates it)
	task.spawn(function()
		local inputManagerModule = char:WaitForChild("InputManager", 10)
		if inputManagerModule then
			-- In this architecture, InputManager is a module that is required by MovementController
			-- We need to wait for MovementController to initialize it or get the instance
			-- For now, let's assume we can access it via a signal or global
			print("[WeaponController] InputManager module found")
		end
		
		-- Alternative: WeaponController creates its own input listeners or we use a central InputController
		-- Let's check MovementController again to see how it exposes InputManager
	end)
end

function WeaponController:SetInputController(controller)
	inputController = controller
	
	inputController.FireToggled.Event:Connect(function(isPressed)
		if isPressed then
			self:StartFiring()
		else
			self:StopFiring()
		end
	end)
	
	inputController.ReloadRequest.Event:Connect(function()
		self:Reload()
	end)
end

function WeaponController:StartFiring()
	if isReloading then return end
	
	self.IsFiring = true
	
	-- Rapid fire loop
	task.spawn(function()
		while self.IsFiring do
			self:Fire()
			
			local config = WeaponData.Weapons[currentWeaponName]
			if not config then break end
			
			local fireDelay = 60 / config.BaseStats.FireRate
			task.wait(fireDelay)
			
			-- Semi-auto check (if we implement it)
		end
	end)
end

function WeaponController:StopFiring()
	self.IsFiring = false
end

function WeaponController:Fire()
	if currentAmmo <= 0 then
		self:Reload()
		return
	end
	
	local now = tick()
	local config = WeaponData.Weapons[currentWeaponName]
	local fireDelay = 60 / config.BaseStats.FireRate
	
	if (now - lastFireTime) < fireDelay then return end
	lastFireTime = now
	currentAmmo -= 1
	
	-- Calculate origin and direction
	local origin = camera.CFrame.Position
	local direction = camera.CFrame.LookVector
	
	-- Send to server
	Network.FireServer("FireWeapon", {
		WeaponName = currentWeaponName,
		Origin = origin,
		Direction = direction
	})
	
	-- Local Effects (Recoil, Sound, Muzzle Flash, Tracers)
	self:ApplyLocalRecoil(config)
	self:PlayLocalFireSound(config)
	
	self:PlayFireEffect({
		Player = player,
		WeaponName = currentWeaponName,
		Origin = origin,
		Direction = direction,
		IsProjectile = (config.BallisticType == "Projectile")
	})
end

function WeaponController:Reload()
	if isReloading then return end
	local config = WeaponData.Weapons[currentWeaponName]
	if not config or currentAmmo >= config.BaseStats.MagazineSize then return end
	
	isReloading = true
	print("Reloading...")
	
	task.wait(config.BaseStats.ReloadTime)
	
	currentAmmo = config.BaseStats.MagazineSize
	isReloading = false
	print("Reloaded!")
end

function WeaponController:ApplyLocalRecoil(config)
	local recoilConfig = config.BaseStats.Recoil
	local vRecoil = recoilConfig.Vertical
	local hRecoil = (math.random() - 0.5) * 2 * recoilConfig.Horizontal
	
	recoilVelocity = recoilVelocity + Vector3.new(vRecoil, hRecoil, 0)
end

function WeaponController:PlayLocalFireSound(config)
	-- TODO: Play sound
end

function WeaponController:PlayFireEffect(data)
	-- data: { Player, WeaponName, Origin, Direction, Hits, IsProjectile }
	local config = WeaponData.Weapons[data.WeaponName]
	if not config then return end

	if data.IsProjectile then
		local projStats = config.ProjectileStats or { Velocity = 1000, GravityMultiplier = 1 }
		local velocity = data.Direction.Unit * projStats.Velocity
		local gravity = Vector3.new(0, -workspace.Gravity, 0) * (projStats.GravityMultiplier or 1)
		
		TracerManager.CreateProjectileTracer(data.Origin, velocity, gravity, config)
	else
		-- For hitscan, if hits are provided, use the first hit position, otherwise use max range
		local hitPos = data.Origin + (data.Direction.Unit * (config.BaseStats.Range.Max or 500))
		if data.Hits and #data.Hits > 0 then
			hitPos = data.Hits[1].Position
			TracerManager.CreateImpact(hitPos, Vector3.new(0, 1, 0), data.Hits[1].Material)
		end
		
		TracerManager.CreateHitscanTracer(data.Origin, hitPos)
	end
end

return WeaponController
