--[[
	ProceduralAnimator - Physics-Driven Character Animation System
	Inspired by the "Three-Layer" Drone Camera architecture.
	
	LAYER 1: INTENT (Input/State)
	- Reads MovementState (Sprint, Run, Idle)
	- Reads Velocity/Acceleration
	
	LAYER 2: MOTION PLAN (Procedural Generators)
	- Step Cycle (Bobbing)
	- Breathing (Idle Sway)
	- Look-At Targets
	
	LAYER 3: PHYSICAL REALIZATION (Springs/Physics)
	- Tilt/Bank Springs (Acceleration-based)
	- Impact Springs (Landing)
	- Joint Manipulation (CFrame application)
]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local char = script.Parent
local player = Players.LocalPlayer

-- Joints & Parts
local humanoid = char:WaitForChild("Humanoid")
local rootPart = char:WaitForChild("HumanoidRootPart")
local lowerTorso = char:WaitForChild("LowerTorso")
local rootJoint = lowerTorso:WaitForChild("Root") -- Motor6D connecting RootPart to LowerTorso
local head = char:WaitForChild("Head")
local neck = head:WaitForChild("Neck")
local upperTorso = char:WaitForChild("UpperTorso")
local waist = upperTorso:WaitForChild("Waist")

local originalRootC0 = rootJoint.C0
local originalNeckC0 = neck.C0
local originalWaistC0 = waist.C0

-- Dependencies
local Spring = require(ReplicatedStorage:WaitForChild("Utils"):WaitForChild("Spring"))

-- ============================================================================
-- PHYSICAL CONFIGURATION
-- ============================================================================
local CONFIG = {
	-- Tilt (Banking into turns)
	TiltAmount = 0.08, -- Radians per velocity unit
	TiltSpeed = 8,
	TiltDamper = 0.6,
	
	-- Bobbing (Step Cycle)
	BobAmplitude = 0.15, -- Studs
	BobFrequency = 12,   -- Base Hz
	
	-- Breathing (Idle)
	BreathSpeed = 1,
	BreathAmp = 0.02,
	
	-- Look At
	HeadTrackingSpeed = 10,
	HeadTrackingDamper = 0.7,
	MaxHeadYaw = math.rad(70),
	MaxHeadPitch = math.rad(45),
}

-- ============================================================================
-- SYSTEM STATE (The "Layers")
-- ============================================================================

local MotionState = {
	Velocity = Vector3.zero,
	LocalVelocity = Vector3.zero,
	Acceleration = Vector3.zero,
	Speed = 0,
	IsGrounded = true,
	StepCycle = 0,
}

local Springs = {
	Tilt = Spring.new(Vector3.zero),    -- X=Pitch, Z=Roll
	Bob = Spring.new(Vector3.zero),     -- Y=Vertical Offset
	Sway = Spring.new(Vector3.zero),    -- Rotational Noise
	Head = Spring.new(Vector3.zero),    -- Look Direction
}

-- Initialize Spring Params
Springs.Tilt.Speed = CONFIG.TiltSpeed
Springs.Tilt.Damper = CONFIG.TiltDamper

Springs.Bob.Speed = 15
Springs.Bob.Damper = 0.5

Springs.Head.Speed = CONFIG.HeadTrackingSpeed
Springs.Head.Damper = CONFIG.HeadTrackingDamper

-- ============================================================================
-- HELPERS
-- ============================================================================

local function GetMovementState()
	return char:GetAttribute("MovementState") or "Idle"
end

-- ============================================================================
-- LAYER 1: INTENT & STATE UPDATES
-- ============================================================================
local lastVelocity = Vector3.zero

local function UpdateState(dt)
	local currentVel = rootPart.AssemblyLinearVelocity
	local horizontalVel = currentVel * Vector3.new(1, 0, 1)
	
	-- Calculate Acceleration (Finite Difference)
	local accel = (horizontalVel - lastVelocity) / math.max(dt, 0.001)
	lastVelocity = horizontalVel
	
	MotionState.Velocity = horizontalVel
	MotionState.Speed = horizontalVel.Magnitude
	MotionState.Acceleration = accel
	MotionState.IsGrounded = humanoid.FloorMaterial ~= Enum.Material.Air
	
	-- Local Velocity (Relative to facing)
	local lookCFrame = rootPart.CFrame
	MotionState.LocalVelocity = lookCFrame:VectorToObjectSpace(horizontalVel)
end

-- ============================================================================
-- LAYER 2: MOTION PLANNING (Procedural Generators)
-- ============================================================================
local function UpdateMotionPlan(dt, time)
	local state = GetMovementState()
	
	-- 1. Tilt Intent (Bank into turns, lean into acceleration)
	-- Invert X acceleration for pitch (lean forward when accelerating)
	-- Invert Z velocity/accel for roll (bank into turns)
	local targetTilt = Vector3.new(
		MotionState.LocalVelocity.Z * CONFIG.TiltAmount * 0.5 + MotionState.Acceleration.Z * 0.005, -- Pitch
		0,
		-MotionState.LocalVelocity.X * CONFIG.TiltAmount * 0.8 -- Roll
	)
	
	-- Dampen tilt when stopped
	if MotionState.Speed < 0.1 then
		targetTilt = Vector3.zero
	end
	
	-- 2. Step Cycle (Bobbing)
	local bobTarget = Vector3.zero
	if MotionState.Speed > 0.5 and MotionState.IsGrounded then
		-- Frequency scales with speed (sprint = faster steps)
		local freqMult = (state == "Sprint" or state == "TacticalSprint") and 1.4 or 1.0
		local wave = math.sin(time * CONFIG.BobFrequency * freqMult)
		
		-- Bob Up/Down
		local yOffset = math.abs(wave) * CONFIG.BobAmplitude * (MotionState.Speed / 16)
		bobTarget = Vector3.new(0, -yOffset, 0) -- Dip down
	else
		-- Breathing (Idle)
		local breath = math.sin(time * CONFIG.BreathSpeed) * CONFIG.BreathAmp
		bobTarget = Vector3.new(0, breath, 0)
	end
	
	-- 3. Head Tracking Intent
	local headTarget = Vector3.zero
	local inMenu = player:GetAttribute("InMenu")
	
	if inMenu and Workspace.CurrentCamera then
		local camPos = Workspace.CurrentCamera.CFrame.Position
		local relativePos = upperTorso.CFrame:PointToObjectSpace(camPos)
		
		local yaw = math.atan2(-relativePos.X, -relativePos.Z)
		local pitch = math.atan2(relativePos.Y, math.sqrt(relativePos.X^2 + relativePos.Z^2))
		
		yaw = math.clamp(yaw, -CONFIG.MaxHeadYaw, CONFIG.MaxHeadYaw)
		pitch = math.clamp(pitch, -CONFIG.MaxHeadPitch, CONFIG.MaxHeadPitch)
		
		if yaw == yaw and pitch == pitch then -- NaN check
			headTarget = Vector3.new(pitch, yaw, 0)
		end
	end
	
	-- Set Spring Targets
	Springs.Tilt.Target = targetTilt
	Springs.Bob.Target = bobTarget
	Springs.Head.Target = headTarget
end

-- ============================================================================
-- LAYER 3: PHYSICAL REALIZATION (Apply to Joints)
-- ============================================================================
local function UpdatePhysics(dt)
	-- Update Springs
	local currentTilt = Springs.Tilt:Update(dt)
	local currentBob = Springs.Bob:Update(dt)
	local currentHead = Springs.Head:Update(dt)
	
	-- 1. Apply Tilt & Bob to RootJoint (LowerTorso -> RootPart)
	-- Tilt rotates the whole body, Bob moves it vertically
	local tiltCF = CFrame.Angles(currentTilt.X, 0, currentTilt.Z)
	local bobCF = CFrame.new(currentBob)
	
	-- Apply to RootJoint (Modify C0)
	-- We apply inverse tilt to root to make the body lean, but keep root flat
	rootJoint.C0 = originalRootC0 * bobCF * tiltCF
	
	-- 2. Counter-rotate Upper Body (Waist) for stability
	-- This keeps the head relatively level even when banking
	local counterTilt = CFrame.Angles(-currentTilt.X * 0.5, 0, -currentTilt.Z * 0.5)
	waist.C0 = originalWaistC0 * counterTilt
	
	-- 3. Apply Head Tracking
	neck.C0 = originalNeckC0 * CFrame.Angles(currentHead.X, currentHead.Y, 0)
end

-- ============================================================================
-- MAIN LOOP
-- ============================================================================
local ProceduralAnimator = {}

function ProceduralAnimator.Start()
	local _connection = RunService.PreRender:Connect(function(dt)
		-- Time Accumulator
		local time = tick()
		
		-- Lag protection
		if dt > 0.1 then dt = 0.016 end
		
		-- Execute Layers
		UpdateState(dt)
		UpdateMotionPlan(dt, time)
		UpdatePhysics(dt)
		
		-- Handle Menu Turn Steps (Legacy Logic - Kept for compatibility)
		local inMenu = player:GetAttribute("InMenu")
		if inMenu then
			local targetAngle = player:GetAttribute("TurnToAngle")
			local requestTime = player:GetAttribute("TurnRequestTime") or 0
			
			if targetAngle and (time - requestTime > 0.7) then
				local _, pY, _ = rootPart.CFrame:ToOrientation()
				local currentRot = math.deg(pY)
				local diff = (targetAngle - currentRot + 180) % 360 - 180
				
				if math.abs(diff) > 2 then
					local stepSize = math.min(45, math.abs(diff)) * 0.1 -- Smooth lerp-like step
					rootPart.CFrame = rootPart.CFrame * CFrame.Angles(0, math.rad(stepSize * math.sign(diff)), 0)
				end
			end
		end
	end)
end

-- ============================================================================
-- EVENT BINDINGS
-- ============================================================================
-- Impact Reaction (Landing)
char:GetAttributeChangedSignal("MovementState"):Connect(function()
	local state = char:GetAttribute("MovementState")
	if state == "Land" then
		-- Apply heavy downwards impulse
		Springs.Bob.Velocity = Vector3.new(0, -12, 0)
		Springs.Tilt.Velocity = Vector3.new(0.5, 0, 0) -- Pitch forward slightly
	elseif state == "Jump" then
		Springs.Bob.Velocity = Vector3.new(0, 5, 0) -- Spring up
	end
end)

-- Start
task.spawn(ProceduralAnimator.Start)
print("[ProceduralAnimator] Initialized with Physics Layers")

return ProceduralAnimator