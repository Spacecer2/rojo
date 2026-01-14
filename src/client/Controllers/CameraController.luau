local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

local Spring = require(game:GetService("ReplicatedStorage"):WaitForChild("Utils"):WaitForChild("Spring"))

local CameraController = {}

local player = Players.LocalPlayer
local camera = Workspace.CurrentCamera

-- 1. Configuration Constants
local CONFIG = {
	MinDistance = 12,
	MaxDistance = 40,
	HeightOffset = 10,
	SwaySpeed = 0.5,
	LookAheadFactor = 0.2,
	MaxRotationArc = math.rad(45),
}

-- 2. Local State
local connection = nil
local isFirstFrame = true
local lastPos = Vector3.zero

-- Physics Springs
local posSpring = Spring.new(Vector3.zero)
posSpring.Speed = 12
posSpring.Damper = 0.9

local focusSpring = Spring.new(Vector3.zero)
focusSpring.Speed = 4
focusSpring.Damper = 0.8

local distSpring = Spring.new(CONFIG.MaxDistance)
distSpring.Speed = 2
distSpring.Damper = 0.8

-- 3. Drone Behavioral Control
function CameraController.EnableMenuCamera()
	camera.CameraType = Enum.CameraType.Scriptable
	
	if connection then connection:Disconnect() end
	
	local baselineAngle = nil
	local baselineSpring = Spring.new(0)
	baselineSpring.Speed = 0.8
	baselineSpring.Damper = 0.85
	
	local dronePhase = "Idle" -- Idle, Anticipation, Execution, Settle
	local phaseData = {}
	local flankTimer = tick() + math.random(15, 25)
	
	connection = RunService.RenderStepped:Connect(function(dt)
		-- Safety catch for lag spikes
		if dt > 0.1 then dt = 0.016 end
		
		local character = player.Character
		if not character then return end
		local rootPart = character:FindFirstChild("HumanoidRootPart")
		if not rootPart then return end
		
		local t = tick()
		local velocity = rootPart.AssemblyLinearVelocity
		
		-- A. Initialize Baseline
		if not baselineAngle then
			local _, y, _ = rootPart.CFrame:ToOrientation()
			baselineAngle = y
			baselineSpring.Position = y
			baselineSpring.Target = y
			posSpring.Position = rootPart.Position + Vector3.new(0, 10, 20)
			focusSpring.Position = rootPart.Position
			lastPos = posSpring.Position
		end
		
		-- B. Phase Transitions & Kinematic Calculations
		local function getSign(val) return val > 0 and 1 or (val < 0 and -1 or 0) end
		
		if t > flankTimer and dronePhase == "Idle" then
			-- Start Anticipation (The "Wind-Up")
			dronePhase = "Anticipation"
			phaseData.StartTime = t
			phaseData.StartAngle = baselineSpring.Position
			
			local _, pY, _ = rootPart.CFrame:ToOrientation()
			local shift = (math.random() > 0.5 and 1 or -1) * (math.pi * (0.8 + math.random() * 0.4))
			phaseData.Shift = shift
			phaseData.TargetAngle = pY + shift
			
			player:SetAttribute("TurnToAngle", math.deg(phaseData.TargetAngle + math.pi))
			player:SetAttribute("TurnRequestTime", t + 1.2)
		end
		
		local currentBaselineAngle = baselineSpring.Position
		local settleAlpha = (dronePhase == "Idle") and 1 or 0
		
		if dronePhase == "Anticipation" then
			local p = math.clamp((t - phaseData.StartTime) / 1.5, 0, 1)
			local curve = p * p * (3 - 2 * p)
			local windUp = math.sin(curve * math.pi) * 0.15 * -getSign(phaseData.Shift)
			currentBaselineAngle = phaseData.StartAngle + windUp
			
			if p >= 1 then
				dronePhase = "Execution"
				phaseData.StartTime = t
				phaseData.StartAngle = currentBaselineAngle
			end
		elseif dronePhase == "Execution" then
			local p = math.clamp((t - phaseData.StartTime) / 1.5, 0, 1)
			local curve = p * p * (3 - 2 * p)
			
			local diff = (phaseData.TargetAngle - phaseData.StartAngle + math.pi) % (math.pi * 2) - math.pi
			currentBaselineAngle = phaseData.StartAngle + (diff * curve)
			
			if p >= 1 then
				dronePhase = "Settle"
				phaseData.StartTime = t
				baselineSpring.Position = currentBaselineAngle
				baselineSpring.Target = currentBaselineAngle
				baselineSpring.Velocity = 0
			end
		elseif dronePhase == "Settle" then
			settleAlpha = math.clamp((t - phaseData.StartTime) / 3.0, 0, 1)
			currentBaselineAngle = baselineSpring:Update(dt)
			
			if settleAlpha >= 1 then
				dronePhase = "Idle"
				flankTimer = t + math.random(25, 45)
			end
		else
			currentBaselineAngle = baselineSpring:Update(dt)
		end
		
		-- C. The "Stalking" Targets (Position & Focus)
		local isKinematic = (dronePhase == "Anticipation" or dronePhase == "Execution")
		
		-- 1. Distance & Orbital Path
		local noise = ((math.sin(t * 0.2) * 0.5) + (math.cos(t * 0.11) * 0.3)) * settleAlpha
		local targetDist = CONFIG.MinDistance + ((noise + 1) / 2) * (CONFIG.MaxDistance - CONFIG.MinDistance)
		
		if dronePhase == "Execution" then
			local p = (t - phaseData.StartTime) / 1.5
			targetDist = targetDist + math.sin(p * math.pi) * 15 -- Safety Arch
		end
		
		-- Cinematic Swoop (Dive)
		local diveMult = 1 - (math.clamp((math.sin(t * 0.1) * math.cos(t * 0.06) - 0.75) / 0.15, 0, 1) * 0.6 * settleAlpha)
		targetDist = math.clamp(targetDist * diveMult, 10, CONFIG.MaxDistance)
		distSpring.Target = targetDist
		local currentDist = distSpring:Update(dt)
		
		-- 2. Rotation & Height
		local l1 = math.sin(t * CONFIG.SwaySpeed)
		local l2 = math.cos(t * CONFIG.SwaySpeed * 0.73) * 0.5
		local rawSway = (l1 + l2) * 0.6 * settleAlpha
		
		local finalAngle = currentBaselineAngle + (rawSway * (CONFIG.MaxRotationArc / 2))
		local x = math.sin(finalAngle) * currentDist
		local z = math.cos(finalAngle) * currentDist
		local y = CONFIG.HeightOffset + (math.sin(t * 0.45) * 1.5 + math.cos(t * 0.19) * 0.8) * settleAlpha
		local targetPos = rootPart.Position + Vector3.new(x, y, z)
		
		-- 3. Camera Look-at (Stalk Target)
		local stalkTarget
		if isKinematic and phaseData.TargetAngle then
			local fX = math.sin(phaseData.TargetAngle + math.pi) * 20
			local fZ = math.cos(phaseData.TargetAngle + math.pi) * 20
			stalkTarget = rootPart.Position + Vector3.new(fX, 1.5, fZ)
		else
			local lead = velocity * CONFIG.LookAheadFactor * settleAlpha
			local sX = math.sin(t * 0.4) * 6 * settleAlpha
			local sY = math.cos(t * 0.35) * 3 * settleAlpha
			stalkTarget = rootPart.Position + Vector3.new(sX, 1.5 + sY, sX * 0.3) + lead
		end
		
		-- D. Coordinate Dynamic vs Kinematic Brains
		local currentPos, currentLook
		posSpring.Target = targetPos
		focusSpring.Target = stalkTarget
		
		if isKinematic then
			-- Hard Kinematic Override: Zero-latency dash
			currentPos = targetPos
			currentLook = stalkTarget
			
			-- Resync Springs for soft handover
			posSpring.Position = targetPos
			posSpring.Velocity = Vector3.zero
			focusSpring.Position = stalkTarget
			focusSpring.Velocity = Vector3.zero
		else
			-- Dynamic Spring Motion
			posSpring.Speed = (dronePhase == "Settle") and 15 or 12
			focusSpring.Speed = (dronePhase == "Settle") and 10 or 4
			currentPos = posSpring:Update(dt)
			currentLook = focusSpring:Update(dt)
		end
		
		-- Distance Clamp Tracking
		local diff = currentPos - targetPos
		if diff.Magnitude > 12 then currentPos = targetPos + (diff.Unit * 12) end
		
		-- E. Physical Derived Effectors
		local actualVel = (currentPos - lastPos) / dt
		lastPos = currentPos
		
		local flatVel = Vector3.new(actualVel.X, 0, actualVel.Z)
		local speedScale = math.clamp(flatVel.Magnitude / 40, 0, 1)
		
		local lookDir = (currentLook - currentPos).Unit
		local right = lookDir:Cross(Vector3.new(0,1,0))
		local lateralSpeed = flatVel:Dot(right)
		
		local roll = -math.clamp(lateralSpeed * 0.05, -math.rad(50), math.rad(50))
		local yawLead = -math.clamp(lateralSpeed * 0.04, -math.rad(50), math.rad(50))
		
		-- Suppression & Decorative Fade-in
		local manAlpha = (dronePhase == "Execution") and 0 or settleAlpha
		local idleRoll = math.sin(t * CONFIG.SwaySpeed * 1.5) * 0.03 * (1 - speedScale) * manAlpha
		
		-- F. Final Assembly
		camera.CameraType = Enum.CameraType.Scriptable
		local baseCF = CFrame.new(currentPos, currentLook)
		camera.CFrame = baseCF * CFrame.Angles(0, yawLead, roll + idleRoll)
	end)
end

function CameraController.DisableMenuCamera()
	if connection then
		connection:Disconnect()
		connection = nil
	end
	camera.CameraType = Enum.CameraType.Custom
end

function CameraController.Start()
	if player:GetAttribute("InMenu") then
		CameraController.EnableMenuCamera()
	end
end

return CameraController