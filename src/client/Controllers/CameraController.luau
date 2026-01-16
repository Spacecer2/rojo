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
local UserInputService = game:GetService("UserInputService")

local Spring = require(game:GetService("ReplicatedStorage"):WaitForChild("Utils"):WaitForChild("Spring"))
local DroneSettingsUI = require(script.Parent.Parent.UI.DroneSettingsUI)

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
		OrbitSwayAmplitude = GetAttr("DroneOrbitSwayAmplitude", 0.6), -- Radians
		OrbitSwayFrequency = GetAttr("DroneOrbitSwayFrequency", 0.2), -- Hz
		ImpulseIntervalMin = GetAttr("DroneFlankMin", 15),
		ImpulseIntervalMax = GetAttr("DroneFlankMax", 50),
		
		-- Motion Plan Layer: Control & Smoothing
		ErrorSmoothing = GetAttr("DroneStressSmoothing", 0.012), -- Renamed from StressSmoothing
		AuthorityScale = GetAttr("DroneAmbitionScale", 1.8), -- Renamed from AmbitionScale
		AuthorityBase = GetAttr("DroneAmbitionBase", 0.55), -- Renamed from AmbitionBase
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
}

-- Connection and initialization
local connection = nil
local distSpring = Spring.new(12)

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
-- FRAMING QUALITY EVALUATION
-- ============================================================================
-- Evaluates the semantic quality of a camera position for framing the player
-- Returns a score from 0 (poor) to 1 (excellent)
-- This provides a unifying objective function that guides intent decisions
local function EvaluateFramingQuality(cameraPos, playerPos, playerVel, c)
	local directionToPlayer = playerPos - cameraPos
	local distance = directionToPlayer.Magnitude
	
	if distance < 0.1 then
		return 0 -- Invalid position
	end
	
	local cameraToPlayer = directionToPlayer.Unit
	
	-- 1. Distance quality (optimal range around player)
	-- Prefer distances in the sweet spot between min and max
	local optimalDistance = (c.MinDistance + c.MaxDistance * 0.7) * 0.5
	local distanceError = math.abs(distance - optimalDistance)
	local distanceQuality = 1 - math.clamp(distanceError / optimalDistance, 0, 1)
	
	-- 2. Angle quality (readability)
	-- Prefer forward-facing angles where player's silhouette is clear
	-- Bad angles: directly overhead (flattening), directly behind (occlusion)
	local horizontalDir = cameraToPlayer * Vector3.new(1, 0, 1)
	local horizontalDist = horizontalDir.Magnitude
	local verticalAngle = math.asin(math.clamp(cameraToPlayer.Y, -1, 1))
	
	-- Penalize overhead angles (too flat)
	local overheadPenalty = math.max(0, (verticalAngle - math.rad(15)) / math.rad(75))
	local overheadQuality = 1 - math.min(overheadPenalty, 1)
	
	-- Penalize too low angles (looking up at player)
	local underAnglePenalty = math.max(0, (-verticalAngle) / math.rad(45))
	local underAngleQuality = 1 - math.min(underAnglePenalty, 0.5)
	
	-- Combine angle quality
	local angleQuality = overheadQuality * (0.6 + underAngleQuality * 0.4)
	
	-- 3. Forward-facing bias (camera should prefer to face player's movement direction)
	-- This makes motion feel more intentional and readable
	local forwardBias = 0.5 -- Neutral if no movement
	if playerVel.Magnitude > 0.1 then
		local playerForward = playerVel.Unit
		local horizontalCameraToPlayer = horizontalDir.Unit
		
		-- Dot product: 1 = camera behind player (chase), -1 = camera in front (face view)
		local forwardAlignment = horizontalCameraToPlayer:Dot(playerForward)
		
		-- Target alignment based on degrees from front (0 = front, 180 = back)
		local targetDot = -math.cos(math.rad(c.IdealAlignment))
		forwardBias = 1 - math.abs(forwardAlignment - targetDot)
	end
	
	-- 4. Height quality (avoid extreme vertical angles)
	-- Prefer angles between 15-45 degrees above horizontal
	local idealVerticalAngle = math.rad(30)
	local verticalAngleError = math.abs(verticalAngle - idealVerticalAngle)
	local heightQuality = 1 - math.clamp(verticalAngleError / math.rad(45), 0, 1)
	
	-- Combine all quality metrics with weights
	local framingScore = 
		(distanceQuality * 0.25) +
		(angleQuality * 0.35) +
		(forwardBias * 0.25) +
		(heightQuality * 0.15)
	
	return math.clamp(framingScore, 0, 1)
end

-- Evaluate multiple orbit angles and return the best one
-- Used by impulse generator to make semantic decisions
local function FindBestFramingAngle(playerPos, playerVel, currentAngle, distance, height, c, numSamples)
	numSamples = numSamples or 8
	
	local bestAngle = currentAngle
	local bestScore = 0
	
	-- Sample angles around current position
	for i = 0, numSamples - 1 do
		local testAngle = currentAngle + (i / numSamples) * math.pi * 2
		local testOffset = Vector3.new(
			math.sin(testAngle) * distance,
			height,
			math.cos(testAngle) * distance
		)
		local testPos = playerPos + testOffset
		
		local score = EvaluateFramingQuality(testPos, playerPos, playerVel, c)
		
		if score > bestScore then
			bestScore = score
			bestAngle = testAngle
		end
	end
	
	return bestAngle, bestScore
end

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
		FilterType = Enum.RaycastFilterType.Blacklist,
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
		raycastParams.FilterType = Enum.RaycastFilterType.Blacklist
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
		local currentQuality = EvaluateFramingQuality(currentCameraPos, playerPos, charVelocity, c)
		
		-- If framing quality is poor, actively seek better angle
		-- If framing quality is good, make smaller adjustments (cinematic variation)
		local seekBetterFraming = currentQuality < 0.6
		
		if seekBetterFraming then
			-- Actively find better framing angle (semantic decision)
			local targetDist = IntentLayer.impulseGenerator.targetDist > 0 and IntentLayer.impulseGenerator.targetDist or (c.MinDistance + 5)
			local bestAngle, bestScore = FindBestFramingAngle(
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
			local variationAngle = (math.random() - 0.5) * math.pi * 0.4 -- Reduced from 0.7
			
			-- Bias variation toward better framing
			local testAngle = (IntentLayer.impulseGenerator.centralAngle + variationAngle) % (math.pi * 2)
			local testOffset = Vector3.new(
				math.sin(testAngle) * IntentLayer.impulseGenerator.targetDist,
				c.HeightOffset,
				math.cos(testAngle) * IntentLayer.impulseGenerator.targetDist
			)
			local testPos = playerPos + testOffset
			local testQuality = EvaluateFramingQuality(testPos, playerPos, charVelocity, c)
			
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
				local altQuality = EvaluateFramingQuality(altPos, playerPos, charVelocity, c)
				
				if altQuality > currentQuality * 0.85 then
					IntentLayer.impulseGenerator.centralAngle = altAngle
				end
			end
			
			-- Subtle distance adjustment
			local prevDist = IntentLayer.impulseGenerator.targetDist > 0 and IntentLayer.impulseGenerator.targetDist or (c.MinDistance + 5)
			local maxTargetDist = math.max(c.MinDistance, c.MaxDistance * 0.45)
			local distVariation = (math.random() - 0.5) * 2 -- Reduced from 3
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
	IntentLayer.desiredHeight = c.HeightOffset + math.sin(t * 0.6) * 1.5 -- Vertical breathing
	
	-- Look-ahead bias based on player velocity
	IntentLayer.lookAheadBias = charVelocity * c.LookAheadFactor
	
	-- Intent to look at the player (with height offset for head/upper body focus)
	local playerPos = rootPart.Position
	IntentLayer.desiredFocusTarget = playerPos + Vector3.new(0, 1.5, 0) + IntentLayer.lookAheadBias
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
	-- Estimate target velocity and acceleration
	local targetVel = (targetPos - MotionPlanLayer.lastTargetPos) / math.max(dt, 0.001)
	local targetAcc = (targetVel - MotionPlanLayer.lastTargetVel) / math.max(dt, 0.001)
	
	-- Smooth velocity and acceleration estimates
	local velSmoothing = math.clamp(5 * dt, 0, 1)
	MotionPlanLayer.lastTargetVel = MotionPlanLayer.lastTargetVel:Lerp(targetVel, velSmoothing)
	MotionPlanLayer.lastTargetAcc = MotionPlanLayer.lastTargetAcc:Lerp(targetAcc, velSmoothing)
	MotionPlanLayer.lastTargetPos = targetPos
	
	-- Predict future position (cinematic lag without phase issues)
	local leadTime = c.PredictionLeadTime
	local predictedTarget = targetPos 
		+ MotionPlanLayer.lastTargetVel * leadTime
		+ MotionPlanLayer.lastTargetAcc * (leadTime * leadTime * 0.5)
	
	-- 3. Constraint satisfaction: Distance leash
	local distToPlayer = (playerPos - PhysicalLayer.p).Magnitude
	local leashFactor = math.clamp((distToPlayer - (c.MaxDistance * 0.4)) / (c.MaxDistance * 0.8), 0, 1)
	
	if distToPlayer > c.MaxDistance * 0.4 then
		-- Pull back toward safe orbital radius
		local directionToPlayer = (playerPos - PhysicalLayer.p)
		if directionToPlayer.Magnitude > 0.1 then
			directionToPlayer = directionToPlayer.Unit
			local safeRadius = c.MaxDistance * 0.7
			local homePos = playerPos - (directionToPlayer * safeRadius)
			predictedTarget = predictedTarget:Lerp(homePos, leashFactor * 0.9)
		end
	end
	
	-- 4. Constraint satisfaction: Roof avoidance (modifies target position, not forces)
	local horizontalOffset = (predictedTarget - playerPos) * Vector3.new(1, 0, 1)
	local horizontalDist = horizontalOffset.Magnitude
	local heightAbovePlayer = predictedTarget.Y - playerPos.Y
	
	if heightAbovePlayer > 2 and horizontalDist < c.RoofAvoidanceRadius then
		-- Push target outward horizontally to avoid overhead position
		local overheadFactor = 1 - (horizontalDist / c.RoofAvoidanceRadius)
		if horizontalDist > 0.1 then
			local pushDir = horizontalOffset.Unit
			-- Push target away from center
			local pushDistance = overheadFactor * (c.RoofAvoidanceRadius - horizontalDist)
			predictedTarget = predictedTarget + pushDir * pushDistance
		else
			-- If exactly overhead, push in random horizontal direction
			local randomAngle = math.random() * math.pi * 2
			local randomDir = Vector3.new(math.cos(randomAngle), 0, math.sin(randomAngle))
			predictedTarget = playerPos + randomDir * c.RoofAvoidanceRadius + Vector3.new(0, predictedTarget.Y - playerPos.Y, 0)
		end
	end
	
	-- 5. Constraint satisfaction: Min distance (modifies orbit, not forces)
	if distToPlayer < c.MinDistance then
		-- Push desired position outward
		local pushDir = (PhysicalLayer.p - playerPos)
		if pushDir.Magnitude > 0.1 then
			pushDir = pushDir.Unit
			local minDistOffset = pushDir * (c.MinDistance - distToPlayer)
			predictedTarget = predictedTarget + minDistOffset
		else
			-- If exactly at player, push in random direction
			local randomAngle = math.random() * math.pi * 2
			local randomDir = Vector3.new(math.cos(randomAngle), 0, math.sin(randomAngle))
			predictedTarget = playerPos + randomDir * c.MinDistance
		end
	end
	
	-- 6. Constraint satisfaction: Obstacle avoidance (raycast detection)
	if c.ObstacleAvoidanceEnabled then
		local cameraPos = PhysicalLayer.p
		local playerHeadPos = playerPos + Vector3.new(0, 1.5, 0) -- Focus on player head area
		
		local hit, hitDistance, hitPosition = CheckObstacleBetween(cameraPos, playerHeadPos, rootPart, c)
		
		if hit and hitDistance < distToPlayer * 1.1 then
			-- Obstacle detected between camera and player
			-- Calculate avoidance: move target position away from obstacle
			local directionToPlayer = (playerHeadPos - cameraPos).Unit
			local directionToHit = (hitPosition - cameraPos).Unit
			
			-- Find perpendicular direction to avoid obstacle
			local avoidanceDir = (directionToPlayer - directionToHit * directionToPlayer:Dot(directionToHit))
			if avoidanceDir.Magnitude > 0.1 then
				avoidanceDir = avoidanceDir.Unit
			else
				-- If directions align, push perpendicular to the obstacle normal
				if hit.Normal then
					avoidanceDir = hit.Normal
				else
					-- Fallback: push horizontally away from obstacle
					local horizontalDir = (hitPosition - playerPos) * Vector3.new(1, 0, 1)
					if horizontalDir.Magnitude > 0.1 then
						avoidanceDir = horizontalDir.Unit
					else
						avoidanceDir = Vector3.new(1, 0, 0) -- Default fallback
					end
				end
			end
			
			-- Calculate how far we need to push to avoid obstacle
			local remainingDistance = distToPlayer - hitDistance
			local pushDistance = math.max(remainingDistance * 0.5, c.ObstacleRaycastRadius * 2)
			
			-- Adjust predicted target to avoid obstacle
			local avoidanceOffset = avoidanceDir * pushDistance * c.ObstacleAvoidanceStrength
			predictedTarget = predictedTarget + avoidanceOffset
			
			-- Also pull back slightly from the obstacle
			local pullBack = (cameraPos - hitPosition).Unit * (c.ObstacleRaycastRadius + 1)
			predictedTarget = predictedTarget:Lerp(predictedTarget + pullBack, 0.3)
		end
	end
	
	-- 7. Manual control (mode-dependent)
	-- Use drone's current orientation for input reference
	local droneLookDir = (PhysicalLayer.f - PhysicalLayer.p)
	if droneLookDir.Magnitude < 0.1 then
		droneLookDir = PhysicalLayer.q.LookVector
	else
		droneLookDir = droneLookDir.Unit
	end
	local droneRightDir = PhysicalLayer.q.RightVector
	
	local manualInput = Vector3.zero
	if UserInputService:IsKeyDown(Enum.KeyCode.W) then manualInput += droneLookDir end
	if UserInputService:IsKeyDown(Enum.KeyCode.S) then manualInput -= droneLookDir end
	if UserInputService:IsKeyDown(Enum.KeyCode.A) then manualInput -= droneRightDir end
	if UserInputService:IsKeyDown(Enum.KeyCode.D) then manualInput += droneRightDir end
	
	if manualInput.Magnitude > 0.1 then
		manualInput = (manualInput * Vector3.new(1, 0, 1)).Unit
		
		if c.ManualControlMode == "override" then
			-- Manual completely overrides AI
			predictedTarget = PhysicalLayer.p + manualInput * c.ManualControlStrength * dt
		elseif c.ManualControlMode == "bias" then
			-- Manual nudges intent (modifies desired position)
			predictedTarget = predictedTarget + manualInput * c.ManualControlStrength * dt * 0.1
		elseif c.ManualControlMode == "assist" then
			-- Manual sets target, AI smooths (handled in trajectory planning)
			predictedTarget = predictedTarget:Lerp(PhysicalLayer.p + manualInput * c.ManualControlStrength, 0.3)
		end
	end
	
	-- 7.5. Framing quality refinement (after all constraints, refine for quality)
	-- This addresses constraint shadowing by improving framing without violating hard constraints
	local currentFramingQuality = EvaluateFramingQuality(predictedTarget, playerPos, charVelocity, c)
	
	-- If framing is poor and we're not in an emergency constraint situation, refine
	local distToPlayer = (playerPos - predictedTarget).Magnitude
	local inConstraintEmergency = distToPlayer < c.MinDistance * 1.1 or distToPlayer > c.MaxDistance * 0.95
	
	if currentFramingQuality < 0.65 and not inConstraintEmergency then
		-- Try small adjustments that improve framing without violating constraints
		local horizontalOffset = (predictedTarget - playerPos) * Vector3.new(1, 0, 1)
		local horizontalDist = horizontalOffset.Magnitude
		
		if horizontalDist > 0.1 then
			local horizontalDir = horizontalOffset.Unit
			
			-- Sample small orthogonal adjustments to improve angle quality
			local bestRefined = predictedTarget
			local bestRefinedQuality = currentFramingQuality
			
			for i = 1, 4 do
				local testAngle = (i / 4) * math.pi * 2
				local perpendicular = Vector3.new(-horizontalDir.Z, 0, horizontalDir.X)
				local testOffset = perpendicular * math.cos(testAngle) + Vector3.new(0, 1, 0) * math.sin(testAngle)
				
				-- Small adjustment (don't move too far)
				local testPos = predictedTarget + testOffset * (horizontalDist * 0.15)
				
				-- Verify constraints are still satisfied
				local testDistToPlayer = (playerPos - testPos).Magnitude
				if testDistToPlayer >= c.MinDistance and testDistToPlayer <= c.MaxDistance then
					local testQuality = EvaluateFramingQuality(testPos, playerPos, charVelocity, c)
					
					if testQuality > bestRefinedQuality then
						bestRefinedQuality = testQuality
						bestRefined = testPos
					end
				end
			end
			
			-- Smoothly blend toward better framing (don't snap)
			if bestRefinedQuality > currentFramingQuality + 0.1 then
				predictedTarget = predictedTarget:Lerp(bestRefined, 0.2)
			end
		end
	end
	
	-- 8. Error magnitude and authority weight (renamed from stress/ambition)
	local rawError = predictedTarget - PhysicalLayer.p
	local distToTarget = rawError.Magnitude
	
	-- Evaluate final framing quality for error calculation
	local finalFramingQuality = EvaluateFramingQuality(predictedTarget, playerPos, charVelocity, c)
	local framingError = 1 - finalFramingQuality -- Invert: poor framing = high error
	
	-- Error magnitude = distance error + velocity error + manual input magnitude + framing quality error
	-- Framing quality is weighted less than hard constraints but influences authority
	local currentError = math.clamp(
		(distToTarget / 15) + 
		(PhysicalLayer.v.Magnitude / c.TopSpeed) + 
		(manualInput.Magnitude * 0.1) +
		(framingError * 0.15), -- Framing quality contributes to error (15% weight)
		0, 1
	)
	MotionPlanLayer.errorMagnitude = math.lerp(MotionPlanLayer.errorMagnitude, currentError, c.ErrorSmoothing)
	
	-- Authority weight = base + error-driven scaling
	local baseAuthority = c.AuthorityBase + (MotionPlanLayer.errorMagnitude * c.AuthorityScale)
	MotionPlanLayer.authorityWeight = math.lerp(MotionPlanLayer.authorityWeight, baseAuthority, 0.1)
	-- Safety override: ramp up authority near leash limit
	MotionPlanLayer.authorityWeight = math.lerp(MotionPlanLayer.authorityWeight, 2.5, math.pow(leashFactor, 1.5))
	
	-- 9. Generate desired trajectory (position and velocity)
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
	MotionPlanLayer.desiredPosition = predictedTarget
	MotionPlanLayer.desiredVelocity = targetVelocity
end

-- ============================================================================
-- LAYER 3: PHYSICAL REALIZATION (Drone Body) - How physics executes the plan
-- ============================================================================
local function UpdatePhysicalLayer(dt, dtScale, c)
	-- 1. Compute desired acceleration from motion plan
	local posError = MotionPlanLayer.desiredPosition - PhysicalLayer.p
	local velError = MotionPlanLayer.desiredVelocity - PhysicalLayer.v
	
	-- Simple PD controller for thrust
	local kP = 0.8
	local kD = 1.8
	local desiredAcc = (posError * kP + velError * kD)
	
	-- Clamp acceleration
	if desiredAcc.Magnitude > c.AccelerationLimit then
		desiredAcc = desiredAcc.Unit * c.AccelerationLimit
	end
	
	-- 2. Orientation control (body tries to align with trajectory)
	local filterPower = 0.05 / MotionPlanLayer.authorityWeight
	PhysicalLayer.filteredDesiredAcc = PhysicalLayer.filteredDesiredAcc and 
		PhysicalLayer.filteredDesiredAcc:Lerp(desiredAcc, filterPower) or desiredAcc
	
	local thrustMagnitude = PhysicalLayer.filteredDesiredAcc.Magnitude
	local desiredThrustDir = thrustMagnitude > 0.1 and PhysicalLayer.filteredDesiredAcc.Unit or Vector3.new(0, 1, 0)
	local desiredOrientation = CFrame.lookAt(Vector3.zero, -desiredThrustDir, Vector3.new(0, 1, 0))
	
	-- Smooth rotation speed
	local targetRotSpeed = 3.2 * MotionPlanLayer.authorityWeight
	PhysicalLayer.currentRotSpeed = PhysicalLayer.currentRotSpeed and 
		math.lerp(PhysicalLayer.currentRotSpeed, targetRotSpeed, 0.05) or targetRotSpeed
	
	PhysicalLayer.q = PhysicalLayer.q:Lerp(desiredOrientation, math.clamp(PhysicalLayer.currentRotSpeed * dt, 0, 1))
	
	-- 3. Physics integration (pure physics, no decisions)
	local actualThrustDirection = -PhysicalLayer.q.LookVector
	local appliedThrust = actualThrustDirection * thrustMagnitude
	
	-- Forces: thrust, gravity, drag
	-- Scale forces during frame stalls to maintain stability
	local netForce = ((appliedThrust * c.MASS) 
		+ (c.GRAVITY * c.MASS) 
		+ (-c.DRAG_LINEAR * PhysicalLayer.v)) * dtScale
	
	PhysicalLayer.v = PhysicalLayer.v + (netForce / c.MASS) * dt
	PhysicalLayer.p = PhysicalLayer.p + PhysicalLayer.v * dt
	
	-- 4. Gimbal physics (focus point) - follows intent to look at player
	local focusTarget = IntentLayer.desiredFocusTarget
	
	local baseStiffness = c.FocusSpringSpeed * 4
	local baseDamping = c.FocusSpringDamper * 12
	local currentStiffness = baseStiffness * math.sqrt(MotionPlanLayer.authorityWeight)
	local currentDamping = baseDamping * math.sqrt(MotionPlanLayer.authorityWeight)
	
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
	
	connection = RunService.RenderStepped:Connect(function(dt)
		-- Handle frame stalls properly: scale forces instead of lying to integrator
		-- Clamp dt to reasonable maximum, but track scale factor for force adjustment
		local dtScale = 1
		if dt > 0.1 then
			dtScale = 0.016 / dt -- Scale forces down proportionally
			dt = 0.016 -- Use stable timestep for integration
		end
		
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
			
			initialized = true
		end
		
		-- Execute three-layer architecture (one-way influence)
		UpdateIntentLayer(rootPart, charVelocity, dt, t, c)      -- Layer 1: Intent
		UpdateMotionPlanLayer(rootPart, charVelocity, dt, c)     -- Layer 2: Motion Plan
		UpdatePhysicalLayer(dt, dtScale, c)                      -- Layer 3: Physics (with force scaling)
		
		-- Final camera assembly
		local finalCF = CFrame.lookAt(PhysicalLayer.p, PhysicalLayer.f)
		local _, _, roll = PhysicalLayer.q:ToEulerAnglesYXZ()
		
		camera.CameraType = Enum.CameraType.Scriptable
		camera.CFrame = finalCF * CFrame.Angles(0, 0, roll)
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
	
	-- Initialize settings UI
	DroneSettingsUI.Init()
	
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