--[[
	CameraController - Three-Layer Hybrid Drone Camera System
	
	ARCHITECTURE:
	This system implements a clean three-layer architecture with one-way influence:
	
Layer 1: Intent (Cinematic/AI)
	- What the camera wants to do
	- Generates desired orbit angle, distance, height, look-ahead bias
	- Generates desired focus target (intent to look at player)
	- Impulse generator modifies orbit parameters (NOT forces)
	- NO physics, NO forces, NO decisions about execution
	
	Layer 2: Motion Plan (Control/Smoothing)
		- How to achieve intent smoothly
		- Predictive filtering (replaces latency buffer)
		- Constraint satisfaction (distance leash, roof avoidance, min distance, obstacle avoidance)
		- Efficient raycast-based obstacle detection with caching
		- Manual control mode handling (bias/override/assist)
		- Error magnitude and authority weight (renamed from stress/ambition)
		- Outputs: desired position and velocity trajectories
		- NO mass, NO gravity, NO thrust
	
	Layer 3: Physical Realization (Drone Body)
		- How physics executes the plan
		- Pure physics: mass, thrust, drag, gravity, torque
		- Gimbal physics for focus point
		- NO decisions, NO randomness, NO "wants"
	
	KEY IMPROVEMENTS:
	- Predictive velocity extrapolation instead of hard latency buffer
	- Impulses modify intent (orbit parameters), not forces
	- Roof avoidance modifies target position, not forces
	- Efficient raycast-based obstacle avoidance with caching
	- Clear manual control mode separation
	- Camera look direction decoupled from body orientation
	- Renamed emotional variables (stress/ambition → errorMagnitude/authorityWeight)
	- Framing quality objective function guides semantic decisions (intent → motion plan)
	
	FRAMING QUALITY SYSTEM:
	- Evaluates camera positions for readability, angle quality, forward-facing bias, and distance appropriateness
	- Intent layer uses framing quality to make semantic orbit decisions (not random)
	- Motion plan layer refines constraint-satisfied positions for better framing
	- Error magnitude includes framing quality as a signal (unifies heuristics under one objective)
]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

local FramingUtils = require(game:GetService("ReplicatedStorage"):WaitForChild("Utils"):WaitForChild("FramingUtils"))

local CameraController = {}

local player = Players.LocalPlayer
local camera = Workspace.CurrentCamera

-- Helper for Dynamic Configuration
local function GetAttr(name, default)
	local val = player:GetAttribute(name)
	return val == nil and default or val
end

local function GetConfig()
	return {
		MinDistance = GetAttr("DroneMinDistance", 10),
		MaxDistance = GetAttr("DroneMaxDistance", 30),
		HeightOffset = GetAttr("DroneHeightOffset", 0),
		LookAheadFactor = GetAttr("DroneLookAheadFactor", 0.2),
		IdealAlignment = GetAttr("DroneIdealAlignment", 0),
		
		-- Intent Layer: Cinematic Behavior
		OrbitSwayAmplitude = GetAttr("DroneOrbitSwayAmplitude", 0.1), -- Radians
		OrbitSwayFrequency = GetAttr("DroneOrbitSwayFrequency", 0.1), -- Hz
		ImpulseIntervalMin = GetAttr("DroneFlankMin", 15),
		ImpulseIntervalMax = GetAttr("DroneFlankMax", 50),
		
		-- Motion Plan Layer: Control & Smoothing
		ErrorSmoothing = GetAttr("DroneStressSmoothing", 0.012), -- Renamed from StressSmoothing
		AuthorityScale = GetAttr("DroneAmbitionScale", 1.0), -- Renamed from AmbitionScale
		AuthorityBase = GetAttr("DroneAmbitionBase", 0.15), -- Renamed from AmbitionBase
		PredictionLeadTime = GetAttr("DroneLatencySteps", 15) * 0.016, -- Convert steps to time
		TopSpeed = GetAttr("DroneTopSpeed", 40),
		AccelerationLimit = GetAttr("DroneAccelerationLimit", 50),
		
		-- Manual Control
		ManualControlMode = GetAttr("DroneManualMode", "bias"), -- "bias", "override", "assist"
		ManualControlStrength = GetAttr("DroneManualStrength", 25),
		
		-- Constraint Satisfaction
		RoofAvoidanceRadius = GetAttr("DroneRoofAvoidanceRadius", 5),
		RoofAvoidanceMinAngle = GetAttr("DroneRoofAvoidanceMinAngle", math.rad(30)),
		
		-- Obstacle Avoidance (Raycasting)
		ObstacleAvoidanceEnabled = GetAttr("DroneObstacleAvoidanceEnabled", true),
		ObstacleRaycastRadius = GetAttr("DroneObstacleRaycastRadius", 1.5), -- Raycast thickness
		ObstacleAvoidanceStrength = GetAttr("DroneObstacleAvoidanceStrength", 0.8),
		ObstacleRaycastDistance = GetAttr("DroneObstacleRaycastDistance", 100), -- Max raycast distance
		ObstacleCheckInterval = GetAttr("DroneObstacleCheckInterval", 0.033), -- How often to raycast (seconds)
		
		-- Physical Layer: Drone Body
		MASS = 2,
		GRAVITY = Vector3.new(0, -8, 0),
		DRAG_LINEAR = 9,
		DRAG_ANGULAR = 5.0,
		MaxPhysicalRoll = math.rad(GetAttr("DroneMaxRollDeg", 50)),
		
		-- Gimbal Physics
		GIMBAL_MASS = 1.0,
		FocusSpringSpeed = GetAttr("DroneFocusSpringSpeed", 1.8),
		FocusSpringDamper = GetAttr("DroneFocusSpringDamper", 0.6),
		GIMBAL_CENTRIFUGAL = 0.8,
	}
end

-- ============================================================================
-- THREE-LAYER ARCHITECTURE
-- ============================================================================

-- Layer 1: Intent (Cinematic/AI) - What the camera wants to do
local IntentLayer = {
	-- Desired orbital parameters
	desiredOrbitAngle = 0,      -- Angle around player (radians)
	desiredDistance = 20,        -- Distance from player
	desiredHeight = 10,          -- Height offset
	lookAheadBias = Vector3.zero, -- Look-ahead offset
	desiredFocusTarget = Vector3.zero, -- Where the camera wants to look (player position with offset)
	
	-- Impulse generator (modifies intent, NOT forces)
	impulseGenerator = {
		nextPulse = 0,
		centralAngle = 0,        -- Reference angle we sway around
		targetDist = 20,          -- Stable distance we maintain
	},
}

-- Layer 2: Motion Plan (Control/Smoothing) - How to achieve intent smoothly
local MotionPlanLayer = {
	-- Predictive state (replaces latency buffer)
	lastTargetPos = Vector3.zero,
	lastTargetVel = Vector3.zero,
	lastTargetAcc = Vector3.zero,
	
	-- Control state
	errorMagnitude = 0,          -- Renamed from droneStress (0-1)
	authorityWeight = 1,          -- Renamed from droneAmbition (1-5)
	
	-- Desired trajectories (output to physics layer)
	desiredPosition = Vector3.zero,
	desiredVelocity = Vector3.zero,
}

-- Layer 3: Physical Realization (Drone Body) - How physics executes the plan
local PhysicalLayer = {
	-- Physical state
	p = Vector3.zero,            -- Position
	v = Vector3.zero,            -- Velocity
	q = CFrame.identity,         -- Body orientation
	w = Vector3.zero,            -- Angular velocity
	
	-- Gimbal state (focus point)
	f = Vector3.zero,            -- Focus position
	fv = Vector3.zero,           -- Focus velocity
	
	-- Orientation smoothing
	filteredDesiredAcc = nil,
	currentRotSpeed = nil,
	currentRoll = 0,
}

-- Connection and initialization
local connection = nil
local physicsAccumulator = 0
local PHYSICS_STEP = 1/120

-- Obstacle detection cache for efficient raycasting
local ObstacleCache = {
	lastCheckTime = 0,
	lastHit = nil,
	lastHitDistance = math.huge,
	lastHitPosition = nil,
	lastCameraPos = nil,
	lastPlayerPos = nil,
}



-- ============================================================================
-- OBSTACLE DETECTION (Efficient Raycasting)
-- ============================================================================
-- Create filter list to ignore player character and other non-obstacles
local function CreateRaycastFilter(character)
	local filter = {}
	if character then
		for _, part in ipairs(character:GetDescendants()) do
			if part:IsA("BasePart") then
				table.insert(filter, part)
			end
		end
	end
	return {
		FilterDescendantsInstances = filter,
		FilterType = Enum.RaycastFilterType.Exclude,
	}
end

-- Efficient obstacle detection with caching
local function CheckObstacleBetween(cameraPos, targetPos, rootPart, c)
	local currentTime = tick()
	
	-- Use cached result if recent and positions haven't changed much
	local cacheValid = false
	if ObstacleCache.lastCheckTime > 0 then
		local timeSinceCheck = currentTime - ObstacleCache.lastCheckTime
		local posChanged = (ObstacleCache.lastCameraPos and (cameraPos - ObstacleCache.lastCameraPos).Magnitude > 2)
			or (ObstacleCache.lastPlayerPos and (targetPos - ObstacleCache.lastPlayerPos).Magnitude > 2)
		
		if timeSinceCheck < c.ObstacleCheckInterval and not posChanged then
			cacheValid = true
		end
	end
	
	if cacheValid and ObstacleCache.lastHit then
		-- Return cached result
		return ObstacleCache.lastHit, ObstacleCache.lastHitDistance, ObstacleCache.lastHitPosition
	end
	
	-- Perform new raycast
	local direction = targetPos - cameraPos
	local distance = direction.Magnitude
	if distance < 0.1 then
		return nil, math.huge, nil
	end
	
	direction = direction.Unit
	
	-- Use spherical raycast for better obstacle detection
	local raycastParams = RaycastParams.new()
	local character = rootPart and rootPart.Parent or player.Character
	if character then
		local filterData = CreateRaycastFilter(character)
		raycastParams.FilterDescendantsInstances = filterData.FilterDescendantsInstances
		raycastParams.FilterType = Enum.RaycastFilterType.Exclude
	end
	raycastParams.IgnoreWater = true
	
	local raycastDistance = math.min(distance, c.ObstacleRaycastDistance)
	local raycastResult = Workspace:Raycast(cameraPos, direction * raycastDistance, raycastParams)
	
	-- Cache results
	ObstacleCache.lastCheckTime = currentTime
	ObstacleCache.lastCameraPos = cameraPos
	ObstacleCache.lastPlayerPos = targetPos
	
	if raycastResult then
		ObstacleCache.lastHit = raycastResult
		ObstacleCache.lastHitDistance = (raycastResult.Position - cameraPos).Magnitude
		ObstacleCache.lastHitPosition = raycastResult.Position
		return raycastResult, ObstacleCache.lastHitDistance, raycastResult.Position
	else
		ObstacleCache.lastHit = nil
		ObstacleCache.lastHitDistance = math.huge
		ObstacleCache.lastHitPosition = nil
		return nil, math.huge, nil
	end
end

-- ============================================================================
-- LAYER 1: INTENT (Cinematic/AI) - What the camera wants to do
-- ============================================================================
local function UpdateIntentLayer(rootPart, charVelocity, dt, t, c)
	local playerPos = rootPart.Position
	
	-- Impulse generator modifies orbit parameters (NOT forces)
	-- NOW: Makes semantic decisions based on framing quality instead of pure randomness
	if t > IntentLayer.impulseGenerator.nextPulse then
		-- Evaluate current framing quality
		local currentOffset = Vector3.new(
			math.sin(IntentLayer.impulseGenerator.centralAngle) * IntentLayer.impulseGenerator.targetDist,
			c.HeightOffset,
			math.cos(IntentLayer.impulseGenerator.centralAngle) * IntentLayer.impulseGenerator.targetDist
		)
		local currentCameraPos = playerPos + currentOffset
		local currentQuality = FramingUtils.EvaluateFramingQuality(currentCameraPos, playerPos, charVelocity, c).total
		
		-- If framing quality is poor, actively seek better angle
		-- If framing quality is good, make smaller adjustments (cinematic variation)
		local seekBetterFraming = currentQuality < 0.6
		
		if seekBetterFraming then
			-- Actively find better framing angle (semantic decision)
			local targetDist = IntentLayer.impulseGenerator.targetDist > 0 and IntentLayer.impulseGenerator.targetDist or (c.MinDistance + 5)
			local bestAngle, _ = FramingUtils.FindBestFramingAngle(
				playerPos, 
				charVelocity, 
				IntentLayer.impulseGenerator.centralAngle,
				targetDist,
				c.HeightOffset,
				c,
				16 -- Sample more angles when seeking better framing
			)
			
			-- Smoothly transition to better angle
			local angleDiff = (bestAngle - IntentLayer.impulseGenerator.centralAngle + math.pi) % (math.pi * 2) - math.pi
			IntentLayer.impulseGenerator.centralAngle = 
				(IntentLayer.impulseGenerator.centralAngle + angleDiff * 0.7) % (math.pi * 2)
			
			-- Adjust distance to optimal framing range
			local optimalDistance = (c.MinDistance + c.MaxDistance * 0.7) * 0.5
			local distError = targetDist - optimalDistance
			IntentLayer.impulseGenerator.targetDist = targetDist - distError * 0.3
			IntentLayer.impulseGenerator.targetDist = math.clamp(
				IntentLayer.impulseGenerator.targetDist,
				c.MinDistance,
				c.MaxDistance * 0.45
			)
			
			-- Shorter duration when actively seeking better framing
			local duration = 1.5 + math.random() * 1.5
			IntentLayer.impulseGenerator.nextPulse = t + duration
		else
			-- Current framing is good - make subtle cinematic variations
			-- Smaller, more intentional shifts (still influenced by framing, but less aggressive)
			local variationAngle = (math.random() - 0.5) * math.pi * 0.2 -- Reduced from 0.4
			
			-- Bias variation toward better framing
			local testAngle = (IntentLayer.impulseGenerator.centralAngle + variationAngle) % (math.pi * 2)
			local testOffset = Vector3.new(
				math.sin(testAngle) * IntentLayer.impulseGenerator.targetDist,
				c.HeightOffset,
				math.cos(testAngle) * IntentLayer.impulseGenerator.targetDist
			)
			local testPos = playerPos + testOffset
			local testQuality = FramingUtils.EvaluateFramingQuality(testPos, playerPos, charVelocity, c).total
			
			-- Only accept variation if it doesn't hurt framing too much
			if testQuality > currentQuality * 0.85 then
				IntentLayer.impulseGenerator.centralAngle = testAngle
			else
				-- Try opposite direction variation
				local altAngle = (IntentLayer.impulseGenerator.centralAngle - variationAngle) % (math.pi * 2)
				local altOffset = Vector3.new(
					math.sin(altAngle) * IntentLayer.impulseGenerator.targetDist,
					c.HeightOffset,
					math.cos(altAngle) * IntentLayer.impulseGenerator.targetDist
				)
				local altPos = playerPos + altOffset
				local altQuality = FramingUtils.EvaluateFramingQuality(altPos, playerPos, charVelocity, c).total
				
				if altQuality > currentQuality * 0.85 then
					IntentLayer.impulseGenerator.centralAngle = altAngle
				end
			end
			
			-- Subtle distance adjustment
			local prevDist = IntentLayer.impulseGenerator.targetDist > 0 and IntentLayer.impulseGenerator.targetDist or (c.MinDistance + 5)
			local maxTargetDist = math.max(c.MinDistance, c.MaxDistance * 0.45)
			local distVariation = (math.random() - 0.5) * 1 -- Reduced from 2
			IntentLayer.impulseGenerator.targetDist = 
				math.clamp(prevDist + distVariation, c.MinDistance, maxTargetDist)
			
			-- Longer duration when framing is good (stability)
			local duration = 2.5 + math.random() * 3.0
			IntentLayer.impulseGenerator.nextPulse = t + duration
		end
	end
	
	-- Continuous orbital sway (breathing motion)
	local sway = math.sin(t * c.OrbitSwayFrequency * 2 * math.pi) * c.OrbitSwayAmplitude
	IntentLayer.desiredOrbitAngle = IntentLayer.impulseGenerator.centralAngle + sway
	IntentLayer.desiredDistance = IntentLayer.impulseGenerator.targetDist
	IntentLayer.desiredHeight = c.HeightOffset + math.sin(t * 0.6) * 0.5 -- Reduced vertical breathing from 1.5
	
	-- Look-ahead bias based on player velocity
	IntentLayer.lookAheadBias = charVelocity * c.LookAheadFactor
	
	-- Intent to look at the player (with height offset for head/upper body focus)
	IntentLayer.desiredFocusTarget = playerPos + Vector3.new(0, 1.5, 0) + IntentLayer.lookAheadBias
end

-- ============================================================================
-- LAYER 2 HELPERS: MOTION PLAN (Control/Smoothing)
-- ============================================================================

-- 1. Manual control arbitration (mode-dependent)
local function HandleManualControl(predictedTarget, currentPos, dt, c)
	-- Use drone's current orientation for input reference
	local droneLookDir = (PhysicalLayer.f - PhysicalLayer.p)
	if droneLookDir.Magnitude < 0.1 then
		droneLookDir = PhysicalLayer.q.LookVector
	else
		droneLookDir = droneLookDir.Unit
	end
	local droneRightDir = PhysicalLayer.q.RightVector
	
	local manualInput = Vector3.zero
	if UserInputService:IsKeyDown(Enum.KeyCode.W) then manualInput = manualInput + droneLookDir end
	if UserInputService:IsKeyDown(Enum.KeyCode.S) then manualInput = manualInput - droneLookDir end
	if UserInputService:IsKeyDown(Enum.KeyCode.A) then manualInput = manualInput - droneRightDir end
	if UserInputService:IsKeyDown(Enum.KeyCode.D) then manualInput = manualInput + droneRightDir end
	
	local resultTarget = predictedTarget
	if manualInput.Magnitude > 0.1 then
		manualInput = (manualInput * Vector3.new(1, 0, 1)).Unit
		
		if c.ManualControlMode == "override" then
			-- Manual completely overrides AI
			resultTarget = currentPos + manualInput * c.ManualControlStrength * dt
		elseif c.ManualControlMode == "bias" then
			-- Manual nudges intent (modifies desired position)
			resultTarget = predictedTarget + manualInput * c.ManualControlStrength * dt * 0.1
		elseif c.ManualControlMode == "assist" then
			-- Manual sets target, AI smooths
			resultTarget = predictedTarget:Lerp(currentPos + manualInput * c.ManualControlStrength, 0.3)
		end
	end
	
	return resultTarget, manualInput
end

-- 2. Constraint satisfaction (prioritized sequence)
local function ApplyMotionConstraints(target, playerPos, currentPos, rootPart, c)
	local result = target
	local distToPlayer = (playerPos - currentPos).Magnitude
	
	-- 1. Leash (Max distance)
	if distToPlayer > c.MaxDistance * 0.4 then
		local leashFactor = math.clamp((distToPlayer - (c.MaxDistance * 0.4)) / (c.MaxDistance * 0.8), 0, 1)
		local directionToPlayer = (playerPos - currentPos)
		if directionToPlayer.Magnitude > 0.1 then
			directionToPlayer = directionToPlayer.Unit
			local safeRadius = c.MaxDistance * 0.7
			local homePos = playerPos - (directionToPlayer * safeRadius)
			result = result:Lerp(homePos, leashFactor * 0.9)
		end
	end
	
	-- 2. Roof avoidance (compositional)
	local horizontalOffset = (result - playerPos) * Vector3.new(1, 0, 1)
	local horizontalDist = horizontalOffset.Magnitude
	local heightAbovePlayer = result.Y - playerPos.Y
	
	if heightAbovePlayer > 2 and horizontalDist < c.RoofAvoidanceRadius then
		local overheadFactor = 1 - (horizontalDist / c.RoofAvoidanceRadius)
		if horizontalDist > 0.1 then
			local pushDir = horizontalOffset.Unit
			local pushDistance = overheadFactor * (c.RoofAvoidanceRadius - horizontalDist)
			result = result + pushDir * pushDistance
		else
			local randomAngle = math.random() * math.pi * 2
			local randomDir = Vector3.new(math.cos(randomAngle), 0, math.sin(randomAngle))
			result = playerPos + randomDir * c.RoofAvoidanceRadius + Vector3.new(0, result.Y - playerPos.Y, 0)
		end
	end
	
	-- 3. Obstacle avoidance (safety)
	if c.ObstacleAvoidanceEnabled then
		local playerHeadPos = playerPos + Vector3.new(0, 1.5, 0)
		local hit, hitDistance, hitPosition = CheckObstacleBetween(currentPos, playerHeadPos, rootPart, c)
		
		if hit and hitDistance < distToPlayer * 1.1 then
			local directionToPlayer = (playerHeadPos - currentPos).Unit
			local directionToHit = (hitPosition - currentPos).Unit
			local avoidanceDir = (directionToPlayer - directionToHit * directionToPlayer:Dot(directionToHit))
			
			if avoidanceDir.Magnitude > 0.1 then
				avoidanceDir = avoidanceDir.Unit
			elseif hit.Normal then
				avoidanceDir = hit.Normal
			else
				avoidanceDir = Vector3.new(1, 0, 0)
			end
			
			local remainingDistance = distToPlayer - hitDistance
			local pushDistance = math.max(remainingDistance * 0.5, c.ObstacleRaycastRadius * 2)
			result = result + avoidanceDir * pushDistance * c.ObstacleAvoidanceStrength
			
			local pullBack = (currentPos - hitPosition).Unit * (c.ObstacleRaycastRadius + 1)
			result = result:Lerp(result + pullBack, 0.3)
		end
	end
	
	-- 4. Min distance (final safety)
	local finalDistToPlayer = (result - playerPos).Magnitude
	if finalDistToPlayer < c.MinDistance then
		local pushDir = (result - playerPos)
		if pushDir.Magnitude > 0.1 then
			pushDir = pushDir.Unit
			result = playerPos + pushDir * c.MinDistance
		else
			local randomAngle = math.random() * math.pi * 2
			local randomDir = Vector3.new(math.cos(randomAngle), 0, math.sin(randomAngle))
			result = playerPos + randomDir * c.MinDistance
		end
	end
	
	return result
end

-- ============================================================================
-- LAYER 2: MOTION PLAN (Control/Smoothing) - How to achieve intent smoothly
-- ============================================================================
local function UpdateMotionPlanLayer(rootPart, charVelocity, dt, c)
	local playerPos = rootPart.Position
	
	-- 1. Compute target position from intent
	local targetOffset = Vector3.new(
		math.sin(IntentLayer.desiredOrbitAngle) * IntentLayer.desiredDistance,
		IntentLayer.desiredHeight,
		math.cos(IntentLayer.desiredOrbitAngle) * IntentLayer.desiredDistance
	)
	local targetPos = playerPos + targetOffset
	
	-- 2. Predictive filtering (replaces latency buffer)
	-- Use a stable delta time for prediction to avoid noise from frame rate jitter
	local stableDt = math.clamp(dt, 0.008, 0.033)
	
	-- Estimate target velocity and acceleration
	local targetVel = (targetPos - MotionPlanLayer.lastTargetPos) / stableDt
	local targetAcc = (targetVel - MotionPlanLayer.lastTargetVel) / stableDt
	
	-- Smooth estimates to reduce numerical noise
	local velSmoothing = math.clamp(10 * dt, 0, 1)
	MotionPlanLayer.lastTargetVel = MotionPlanLayer.lastTargetVel:Lerp(targetVel, velSmoothing)
	MotionPlanLayer.lastTargetAcc = MotionPlanLayer.lastTargetAcc:Lerp(targetAcc, velSmoothing)
	MotionPlanLayer.lastTargetPos = targetPos
	
	-- Predict future position (cinematic lag without phase issues)
	local leadTime = c.PredictionLeadTime
	local predictedTarget = targetPos 
		+ MotionPlanLayer.lastTargetVel * leadTime
		+ MotionPlanLayer.lastTargetAcc * (leadTime * leadTime * 0.5)
	
	-- 3. Manual control arbitration
	local manualTarget, manualInput = HandleManualControl(predictedTarget, PhysicalLayer.p, dt, c)
	
	-- 4. Constraint satisfaction (prioritized)
	local finalTarget = ApplyMotionConstraints(manualTarget, playerPos, PhysicalLayer.p, rootPart, c)
	
	-- 5. Error magnitude and authority weight
	local rawError = finalTarget - PhysicalLayer.p
	local distToTarget = rawError.Magnitude
	local leashFactor = math.clamp(((playerPos - PhysicalLayer.p).Magnitude - (c.MaxDistance * 0.4)) / (c.MaxDistance * 0.8), 0, 1)
	
	-- Error magnitude = tracking error difficulty
	local currentError = math.clamp(
		(distToTarget / 15) + 
		(PhysicalLayer.v.Magnitude / c.TopSpeed) + 
		(manualInput.Magnitude * 0.1),
		0, 1
	)
	MotionPlanLayer.errorMagnitude = math.lerp(MotionPlanLayer.errorMagnitude, currentError, c.ErrorSmoothing)
	
	-- Authority weight = base + error-driven scaling
	local baseAuthority = c.AuthorityBase + (MotionPlanLayer.errorMagnitude * c.AuthorityScale)
	MotionPlanLayer.authorityWeight = math.lerp(MotionPlanLayer.authorityWeight, baseAuthority, 0.1)
	-- Safety override: ramp up authority near leash limit
	MotionPlanLayer.authorityWeight = math.lerp(MotionPlanLayer.authorityWeight, 2.5, math.pow(leashFactor, 1.5))
	
	-- 6. Generate desired trajectory (position and velocity)
	-- PID-like control for smooth trajectory
	local rampedAuthority = math.pow(MotionPlanLayer.authorityWeight, 1.5)
	local stopFactor = math.clamp(1 - (distToTarget / 10), 0, 1)
	
	local kP_pos = (0.8 + (leashFactor * 0.8)) * rampedAuthority * (1 - stopFactor * 0.4)
	local kP_vel = (1.8 + (leashFactor * 0.8) + (stopFactor * 2.0)) * math.sqrt(rampedAuthority)
	
	local targetVelocity = rawError * kP_pos
	local currentTopSpeed = c.TopSpeed * (0.6 + MotionPlanLayer.errorMagnitude * 0.9)
	if targetVelocity.Magnitude > currentTopSpeed then
		targetVelocity = targetVelocity.Unit * currentTopSpeed
	end
	
	-- Clamp acceleration
	local velError = targetVelocity - PhysicalLayer.v
	local targetAcceleration = velError * kP_vel
	if targetAcceleration.Magnitude > c.AccelerationLimit then
		targetAcceleration = targetAcceleration.Unit * c.AccelerationLimit
	end
	
	-- Output to physics layer
	MotionPlanLayer.desiredPosition = finalTarget
	MotionPlanLayer.desiredVelocity = targetVelocity
end

-- ============================================================================
-- LAYER 3: PHYSICAL REALIZATION (Drone Body) - How physics executes the plan
-- ============================================================================
local function UpdatePhysicalLayer(dt, c)
	-- 1. Compute desired acceleration from motion plan
	local posError = MotionPlanLayer.desiredPosition - PhysicalLayer.p
	local velError = MotionPlanLayer.desiredVelocity - PhysicalLayer.v
	
	-- Simple PD controller for thrust (outputs acceleration)
	local kP = 0.8
	local kD = 1.8
	local desiredAcc = (posError * kP + velError * kD)
	
	-- Clamp acceleration
	if desiredAcc.Magnitude > c.AccelerationLimit then
		desiredAcc = desiredAcc.Unit * c.AccelerationLimit
	end
	
	-- 2. Orientation control (body tries to align with trajectory)
	-- This is a kinematic approximation of a high-torque attitude controller
	local filterPower = 0.05 / MotionPlanLayer.authorityWeight
	PhysicalLayer.filteredDesiredAcc = PhysicalLayer.filteredDesiredAcc and 
		PhysicalLayer.filteredDesiredAcc:Lerp(desiredAcc, filterPower) or desiredAcc
	
	local thrustMagnitude = PhysicalLayer.filteredDesiredAcc.Magnitude
	local desiredThrustDir = thrustMagnitude > 0.1 and PhysicalLayer.filteredDesiredAcc.Unit or Vector3.new(0, 1, 0)
	local desiredOrientation = CFrame.lookAt(Vector3.zero, -desiredThrustDir, Vector3.new(0, 1, 0))
	
	-- Smooth rotation speed (Dampened from 3.2 to 1.2)
	local targetRotSpeed = 1.2 * MotionPlanLayer.authorityWeight
	PhysicalLayer.currentRotSpeed = PhysicalLayer.currentRotSpeed and 
		math.lerp(PhysicalLayer.currentRotSpeed, targetRotSpeed, 0.05) or targetRotSpeed
	
	PhysicalLayer.q = PhysicalLayer.q:Lerp(desiredOrientation, math.clamp(PhysicalLayer.currentRotSpeed * dt, 0, 1))
	
	-- Extract and filter roll separately for even more smoothness
	local _, _, targetRoll = PhysicalLayer.q:ToEulerAnglesYXZ()
	PhysicalLayer.currentRoll = math.lerp(PhysicalLayer.currentRoll, targetRoll, math.clamp(5 * dt, 0, 1))
	
	-- 3. Physics integration (Pure Newton-Euler)
	local actualThrustDirection = -PhysicalLayer.q.LookVector
	local appliedThrustForce = actualThrustDirection * thrustMagnitude * c.MASS
	
	-- Forces: thrust, gravity, drag
	local gravityForce = c.GRAVITY * c.MASS
	local dragForce = -c.DRAG_LINEAR * PhysicalLayer.v
	local netForce = appliedThrustForce + gravityForce + dragForce
	
	-- Semi-implicit Euler integration
	PhysicalLayer.v = PhysicalLayer.v + (netForce / c.MASS) * dt
	PhysicalLayer.p = PhysicalLayer.p + PhysicalLayer.v * dt
	
	-- 4. Gimbal physics (focus point) - follows intent to look at player
	local focusTarget = IntentLayer.desiredFocusTarget
	
	local baseStiffness = c.FocusSpringSpeed * 4
	local baseDamping = c.FocusSpringDamper * 12
	local currentStiffness = baseStiffness * math.sqrt(MotionPlanLayer.authorityWeight)
	local currentDamping = baseDamping * math.sqrt(MotionPlanLayer.authorityWeight)
	
	-- Centrifugal compensation for focus point
	local lookDir = (PhysicalLayer.f - PhysicalLayer.p).Unit
	local lateralVel = PhysicalLayer.v - PhysicalLayer.v:Dot(lookDir) * lookDir
	local framingForce = lateralVel * c.GIMBAL_CENTRIFUGAL
	
	local focusError = focusTarget - PhysicalLayer.f
	local focusForce = (focusError * currentStiffness) - (PhysicalLayer.fv * currentDamping) + framingForce
	
	PhysicalLayer.fv = PhysicalLayer.fv + (focusForce / c.GIMBAL_MASS) * dt
	PhysicalLayer.f = PhysicalLayer.f + PhysicalLayer.fv * dt
end

-- ============================================================================
-- MAIN CAMERA CONTROL
-- ============================================================================
function CameraController.EnableMenuCamera()
	camera.CameraType = Enum.CameraType.Scriptable
	
	if connection then connection:Disconnect() end
	
	local initialized = false
	physicsAccumulator = 0
	
	connection = RunService.RenderStepped:Connect(function(dt)
		local character = player.Character
		if not character then return end
		local rootPart = character:FindFirstChild("HumanoidRootPart")
		if not rootPart then return end
		
		local c = GetConfig()
		local t = tick()
		local charVelocity = rootPart.AssemblyLinearVelocity
		
		-- Initialize state
		if not initialized then
			local _, y, _ = rootPart.CFrame:ToOrientation()
			local spawnAngle = y + math.pi -- Start in front of player
			local spawnDist = c.MinDistance + 5
			
			IntentLayer.desiredOrbitAngle = spawnAngle
			IntentLayer.impulseGenerator.centralAngle = spawnAngle
			IntentLayer.impulseGenerator.targetDist = spawnDist
			
			PhysicalLayer.p = rootPart.Position + Vector3.new(
				math.sin(spawnAngle) * spawnDist,
				c.HeightOffset,
				math.cos(spawnAngle) * spawnDist
			)
			PhysicalLayer.v = Vector3.zero
			PhysicalLayer.q = CFrame.lookAt(PhysicalLayer.p, rootPart.Position + Vector3.new(0, 1.5, 0))
			PhysicalLayer.f = rootPart.Position + Vector3.new(0, 1.5, 0)
			PhysicalLayer.fv = Vector3.zero
			
			MotionPlanLayer.lastTargetPos = PhysicalLayer.p
			MotionPlanLayer.lastTargetVel = Vector3.zero
			MotionPlanLayer.lastTargetAcc = Vector3.zero
			
			physicsAccumulator = 0
			initialized = true
		end
		
		-- Fixed timestep physics accumulator
		-- This guarantees stable physics behavior regardless of frame rate
		physicsAccumulator = physicsAccumulator + math.min(dt, 0.1) -- Cap dt to avoid spiral of death
		
		-- Execute three-layer architecture
		-- Layers 1 & 2 run per-frame (decision making)
		UpdateIntentLayer(rootPart, charVelocity, dt, t, c)      -- Layer 1: Intent
		UpdateMotionPlanLayer(rootPart, charVelocity, dt, c)     -- Layer 2: Motion Plan
		
		-- Layer 3 (Physics) runs on fixed sub-steps
		while physicsAccumulator >= PHYSICS_STEP do
			UpdatePhysicalLayer(PHYSICS_STEP, c)                 -- Layer 3: Physics
			physicsAccumulator = physicsAccumulator - PHYSICS_STEP
		end
		
		-- Final camera assembly
		-- Interpolate for smoothness if needed (optional, but good for high refresh rates)
		local finalCF = CFrame.lookAt(PhysicalLayer.p, PhysicalLayer.f)
		
		camera.CameraType = Enum.CameraType.Scriptable
		camera.CFrame = finalCF * CFrame.Angles(0, 0, PhysicalLayer.currentRoll)
	end)
end

function CameraController.DisableMenuCamera()
	if connection then
		connection:Disconnect()
		connection = nil
	end
	
	-- Reset all layer state
	IntentLayer.desiredOrbitAngle = 0
	IntentLayer.desiredDistance = 20
	IntentLayer.desiredHeight = 10
	IntentLayer.lookAheadBias = Vector3.zero
	IntentLayer.desiredFocusTarget = Vector3.zero
	IntentLayer.impulseGenerator.nextPulse = 0
	IntentLayer.impulseGenerator.centralAngle = 0
	IntentLayer.impulseGenerator.targetDist = 20
	
	MotionPlanLayer.lastTargetPos = Vector3.zero
	MotionPlanLayer.lastTargetVel = Vector3.zero
	MotionPlanLayer.lastTargetAcc = Vector3.zero
	MotionPlanLayer.errorMagnitude = 0
	MotionPlanLayer.authorityWeight = 1
	MotionPlanLayer.desiredPosition = Vector3.zero
	MotionPlanLayer.desiredVelocity = Vector3.zero
	
	PhysicalLayer.p = Vector3.zero
	PhysicalLayer.v = Vector3.zero
	PhysicalLayer.q = CFrame.identity
	PhysicalLayer.w = Vector3.zero
	PhysicalLayer.f = Vector3.zero
	PhysicalLayer.fv = Vector3.zero
	PhysicalLayer.filteredDesiredAcc = nil
	PhysicalLayer.currentRotSpeed = nil
	
	-- Reset obstacle cache
	ObstacleCache.lastCheckTime = 0
	ObstacleCache.lastHit = nil
	ObstacleCache.lastHitDistance = math.huge
	ObstacleCache.lastHitPosition = nil
	ObstacleCache.lastCameraPos = nil
	ObstacleCache.lastPlayerPos = nil
	
	camera.CameraType = Enum.CameraType.Custom
end

local initialized = false
function CameraController.Init()
	if initialized then return end
	initialized = true
	
	player:GetAttributeChangedSignal("InMenu"):Connect(function()
		local inMenu = player:GetAttribute("InMenu")
		if inMenu then
			CameraController.EnableMenuCamera()
		else
			CameraController.DisableMenuCamera()
		end
	end)
end

function CameraController.Start()
	CameraController.Init()
	if player:GetAttribute("InMenu") then
		CameraController.EnableMenuCamera()
	end
end

return CameraController