--[[
	TracerManager - Client-side bullet visualization
	Handles tracers, impact effects, and muzzle flashes.
]]

local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local TracerManager = {}

-- Constants
local TRACER_WIDTH = 0.05
local TRACER_LIFETIME = 0.1
local TRACER_COLOR = ColorSequence.new(Color3.fromRGB(255, 255, 200))

function TracerManager.CreateHitscanTracer(origin, hitPosition)
	local distance = (hitPosition - origin).Magnitude
	local tracer = Instance.new("Part")
	tracer.Name = "Tracer"
	tracer.Anchored = true
	tracer.CanCollide = false
	tracer.CanQuery = false
	tracer.CastShadow = false
	tracer.Color = Color3.fromRGB(255, 255, 150)
	tracer.Transparency = 0.5
	tracer.Material = Enum.Material.Neon
	
	-- Position and Rotate
	tracer.Size = Vector3.new(TRACER_WIDTH, TRACER_WIDTH, distance)
	tracer.CFrame = CFrame.lookAt(origin, hitPosition) * CFrame.new(0, 0, -distance/2)
	tracer.Parent = workspace:FindFirstChild("Bullets") or workspace
	
	-- Fade out
	local tweenInfo = TweenInfo.new(TRACER_LIFETIME, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
	local tween = TweenService:Create(tracer, tweenInfo, {
		Transparency = 1,
		Size = Vector3.new(0, 0, distance)
	})
	
	tween.Completed:Connect(function()
		tracer:Destroy()
	end)
	tween:Play()
end

function TracerManager.CreateProjectileTracer(origin, velocity, gravity, weaponConfig)
	-- For projectiles, we simulate a visual part that follows the same path
	local tracer = Instance.new("Part")
	tracer.Name = "ProjectileTracer"
	tracer.Size = Vector3.new(0.1, 0.1, 1)
	tracer.CanCollide = false
	tracer.CanQuery = false
	tracer.CastShadow = false
	tracer.Color = Color3.fromRGB(255, 255, 100)
	tracer.Material = Enum.Material.Neon
	tracer.Parent = workspace:FindFirstChild("Bullets") or workspace
	
	local trail = Instance.new("Trail")
	trail.Color = TRACER_COLOR
	trail.WidthScale = NumberSequence.new(1, 0)
	trail.Lifetime = 0.1
	
	local att0 = Instance.new("Attachment", tracer)
	att0.Position = Vector3.new(0, 0.05, 0)
	local att1 = Instance.new("Attachment", tracer)
	att1.Position = Vector3.new(0, -0.05, 0)
	
	trail.Attachment0 = att0
	trail.Attachment1 = att1
	trail.Parent = tracer

	-- Simulating visual movement
	local currentPos = origin
	local currentVel = velocity
	local startTime = tick()
	
	local connection
	connection = game:GetService("RunService").Heartbeat:Connect(function(dt)
		if (tick() - startTime) > 5 or tracer.Parent == nil then
			connection:Disconnect()
			if tracer.Parent then tracer:Destroy() end
			return
		end
		
		local displacement = (currentVel * dt) + (0.5 * gravity * dt * dt)
		local nextPos = currentPos + displacement
		
		-- Collision check for VISUAL removal (server handles actual damage)
		local result = workspace:Raycast(currentPos, displacement * 1.1)
		if result then
			TracerManager.CreateImpact(result.Position, result.Normal, result.Material)
			tracer:Destroy()
			connection:Disconnect()
			return
		end
		
		tracer.CFrame = CFrame.lookAt(currentPos, nextPos)
		currentPos = nextPos
		currentVel = currentVel + (gravity * dt)
	end)
end

function TracerManager.CreateImpact(position, normal, material)
	-- Simple impact effect
	local impact = Instance.new("Part")
	impact.Size = Vector3.new(0.2, 0.2, 0.2)
	impact.CFrame = CFrame.new(position, position + normal)
	impact.Anchored = true
	impact.CanCollide = false
	impact.Transparency = 1
	impact.Parent = workspace:FindFirstChild("Bullets") or workspace
	
	local attachment = Instance.new("Attachment", impact)
	
	local particles = Instance.new("ParticleEmitter")
	particles.Texture = "rbxassetid://13442183214" -- Smoke texture placeholder
	particles.Rate = 0
	particles.Lifetime = NumberRange.new(0.2, 0.5)
	particles.Speed = NumberRange.new(5, 10)
	particles.SpreadAngle = Vector2.new(45, 45)
	particles.Size = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0.1),
		NumberSequenceKeypoint.new(1, 0)
	})
	particles.Parent = attachment
	
	particles:Emit(5)
	
	task.delay(1, function()
		impact:Destroy()
	end)
end

return TracerManager
