--!strict
-- FramingUtils.luau
-- Implements semantic framing quality evaluation for the camera system.
-- Separates "what is a good shot" from "how to move there".

local FramingUtils = {}

export type FramingConfig = {
	MinDistance: number,
	MaxDistance: number,
	IdealAlignment: number, -- degrees
}

export type FramingScore = {
	distance: number,
	angle: number,
	forward: number,
	height: number,
	total: number,
}

-- Evaluates the semantic quality of a camera position for framing the player
-- Returns a structured score breakdown
function FramingUtils.EvaluateFramingQuality(cameraPos: Vector3, playerPos: Vector3, playerVel: Vector3, c: FramingConfig): FramingScore
	local directionToPlayer = playerPos - cameraPos
	local distance = directionToPlayer.Magnitude
	
	if distance < 0.1 then
		return {
			distance = 0,
			angle = 0,
			forward = 0,
			height = 0,
			total = 0
		}
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
	-- local horizontalDist = horizontalDir.Magnitude -- Unused
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
	local totalScore = 
		(distanceQuality * 0.25) +
		(angleQuality * 0.35) +
		(forwardBias * 0.25) +
		(heightQuality * 0.15)
	
	return {
		distance = distanceQuality,
		angle = angleQuality,
		forward = forwardBias,
		height = heightQuality,
		total = math.clamp(totalScore, 0, 1)
	}
end

-- Evaluate multiple orbit angles and return the best one
-- Used by impulse generator to make semantic decisions
function FramingUtils.FindBestFramingAngle(
	playerPos: Vector3, 
	playerVel: Vector3, 
	currentAngle: number, 
	distance: number, 
	height: number, 
	c: FramingConfig, 
	numSamples: number
): (number, number)
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
		
		local scoreData = FramingUtils.EvaluateFramingQuality(testPos, playerPos, playerVel, c)
		
		if scoreData.total > bestScore then
			bestScore = scoreData.total
			bestAngle = testAngle
		end
	end
	
	return bestAngle, bestScore
end

return FramingUtils
