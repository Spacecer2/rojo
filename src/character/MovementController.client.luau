local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

-- Character setup
local char = script.Parent
local humanoid = char:WaitForChild("Humanoid")
local rootPart = char:WaitForChild("HumanoidRootPart")

-- Wait for modules safely
local function safeRequire(name)
	local module = char:WaitForChild(name, 10)
	if module then
		return require(module)
	else
		warn("Could not find module: " .. name)
		return nil
	end
end

local Config = safeRequire("Config")
local StateMachine = safeRequire("StateMachine")
local InputManager = safeRequire("InputManager")

if not (Config and StateMachine and InputManager) then
	warn("MovementController failed to load dependencies.")
	return
end

local player = Players.LocalPlayer
local camera = Workspace.CurrentCamera

-- Initialize Systems
local stateMachine = StateMachine.new()
local inputController = InputManager.new()

-- Tac Sprint State
local lastTacSprintTime = 0
local isTacSprinting = false
local tacSprintTimer = nil

-- Slide State
local lastSlideTime = 0
local slideVelocity = nil -- LinearVelocity instance
local slideAttachment = nil
local slideDirection = Vector3.zero

-- Initialize Slide Physics
local function setupSlidePhysics()
	slideAttachment = Instance.new("Attachment")
	slideAttachment.Name = "SlideAttachment"
	slideAttachment.Parent = rootPart
	
	slideVelocity = Instance.new("LinearVelocity")
	slideVelocity.Name = "SlideVelocity"
	slideVelocity.Attachment0 = slideAttachment
	slideVelocity.MaxForce = 0 -- Initially disabled
	slideVelocity.VelocityConstraintMode = Enum.VelocityConstraintMode.Vector
	slideVelocity.VectorVelocity = Vector3.zero
	slideVelocity.RelativeTo = Enum.ActuatorRelativeTo.World
	slideVelocity.Parent = rootPart
end
setupSlidePhysics()

-- Bind State Changes
stateMachine.StateChanged.Event:Connect(function(newState, oldState)
	char:SetAttribute("MovementState", newState)
	
	-- Cleanup Slide if leaving state
	if oldState == "Slide" then
		slideVelocity.MaxForce = 0
		humanoid.AutoRotate = true
	end
	
	-- Handle Landing
	if newState == "Land" then
		task.delay(Config.LandStunDuration, function()
			if stateMachine:GetState() == "Land" then
				stateMachine:SetState("Idle")
			end
		end)
	end
end)

-- Logic
local function updateState()
	if player:GetAttribute("InMenu") then
		stateMachine:SetState("Idle")
		return
	end

	local moveVector = inputController:GetMoveVector()
	local isMoving = moveVector.Magnitude > 0
	local isSprinting = inputController.IsSprinting
	local isCrouching = inputController.IsCrouching
	local isAiming = inputController.IsAiming
	
	-- Grounded check
	local isGrounded = humanoid.FloorMaterial ~= Enum.Material.Air
	
	if not isGrounded then
		if humanoid.Jump then
			stateMachine:SetState("Jump")
		else
			stateMachine:SetState("Freefall")
		end
		return
	end

	-- Handling Landing transition
	if stateMachine:GetState() == "Freefall" and isGrounded then
		stateMachine:SetState("Land")
		return
	end
	
	-- Don't interrupt Landing state early unless moving fast
	if currentState == "Land" and not isMoving then
		return
	end

	-- Don't update state while Sliding (Slide governs its own exit)
	if currentState == "Slide" then
		return
	end

	if isMoving then
		if isAiming then
			stateMachine:SetState("ADS")
			isTacSprinting = false -- ADS cancels tac sprint
		elseif stateMachine:GetState() == "TacticalSprint" then
			-- Keep Tax Sprint state
		elseif isSprinting then
			stateMachine:SetState("Sprint")
		elseif isCrouching then
			stateMachine:SetState("CrouchWalk") -- Use CrouchWalk when moving while crouched
		else
			stateMachine:SetState("Run")
		end
	else
		if isAiming then
			stateMachine:SetState("ADS")
		elseif isCrouching then
			stateMachine:SetState("Crouch")
		else
			stateMachine:SetState("Idle")
		end
	end
end

-- Speed interpolation state
local currentSpeed = Config.WalkSpeed

	local function applyMovement(dt)
	local inMenu = player:GetAttribute("InMenu")
	if inMenu then
		humanoid.WalkSpeed = 0
		currentSpeed = 0
		if rootPart then rootPart.Anchored = true end
		return
	else
		if rootPart and rootPart.Anchored then rootPart.Anchored = false end
	end

	local currentState = stateMachine:GetState()
	local targetSpeed = Config.WalkSpeed
	
	-- Handle Slide Physics separately
	if currentState == "Slide" then
		-- Smoothly decay slide velocity
		local currentVel = slideVelocity.VectorVelocity
		local decay = 1 - (Config.SlideFriction * dt)
		local newVel = currentVel * math.clamp(decay, 0, 1)
		
		slideVelocity.VectorVelocity = newVel
		
		-- Termination checks
		local speed = newVel.Magnitude
		if speed < Config.RunSpeed * 0.8 then
			stateMachine:SetState(inputController.IsCrouching and "Crouch" or "Idle")
		end
		
		-- FOV for slide
		local targetFOV = Config.DefaultFOV + 5
		local fovLerpFactor = math.min(1, (dt * 60) * Config.FOVTransitionSpeed)
		camera.FieldOfView = camera.FieldOfView + (targetFOV - camera.FieldOfView) * fovLerpFactor
		
		return -- Skip normal movement logic
	end
	
	if currentState == "Run" then
		targetSpeed = Config.RunSpeed
	elseif currentState == "Sprint" then
		targetSpeed = Config.SprintSpeed
	elseif currentState == "TacticalSprint" then
		targetSpeed = Config.TacticalSprintSpeed
	elseif currentState == "Crouch" or currentState == "CrouchWalk" then
		targetSpeed = Config.CrouchSpeed
	elseif currentState == "ADS" then
		targetSpeed = Config.WalkSpeed * Config.ADSSpeedMultiplier
	elseif currentState == "Idle" or currentState == "Land" then
		targetSpeed = (currentState == "Land") and (Config.WalkSpeed * 0.5) or 0
	end
	
	-- Smooth speed interpolation (per documentation - smooth transitions)
	local lerpFactor = math.min(1, (dt * 60) / Config.AccelerationTime) -- Normalize to 60fps
	currentSpeed = currentSpeed + (targetSpeed - currentSpeed) * lerpFactor
	humanoid.WalkSpeed = currentSpeed
	
	-- FOV Change
	local targetFOV = Config.DefaultFOV
	if inputController.IsAiming then
		targetFOV = Config.ADSFOV
	elseif currentState == "TacticalSprint" then
		targetFOV = Config.DefaultFOV + 10 -- Dynamic FOV boost
	end
	
	local fovLerpFactor = math.min(1, (dt * 60) * Config.FOVTransitionSpeed)
	camera.FieldOfView = camera.FieldOfView + (targetFOV - camera.FieldOfView) * fovLerpFactor
end

-- Function to start Tactical Sprint
local function startTacticalSprint()
	local now = tick()
	if (now - lastTacSprintTime) < Config.TacticalSprintCooldown then return end
	
	local currentState = stateMachine:GetState()
	-- Can only enter from moving forward states
	if currentState == "Sprint" or currentState == "Run" then
		stateMachine:SetState("TacticalSprint")
		isTacSprinting = true
		
		-- Duration Timer
		if tacSprintTimer then task.cancel(tacSprintTimer) end
		tacSprintTimer = task.delay(Config.TacticalSprintDuration, function()
			if stateMachine:GetState() == "TacticalSprint" then
				stateMachine:SetState("Sprint") -- Downgrade to normal sprint
				isTacSprinting = false
				lastTacSprintTime = tick()
			end
		end)
	end
end

-- Function to start Sliding
local function startSlide()
	local currentState = stateMachine:GetState()
	
	-- Slide Cancellation (Slide Cancel)
	if currentState == "Slide" then
		stateMachine:SetState("Crouch")
		return
	end

	local now = tick()
	if (now - lastSlideTime) < Config.SlideCooldown then return end
	
	-- Check if we are grounded and moving fast enough
	local isGrounded = humanoid.FloorMaterial ~= Enum.Material.Air
	if not isGrounded then return end
	
	local moveVector = inputController:GetMoveVector()
	if currentSpeed < Config.MinSlideSpeed then return end

	-- Calculate slide direction (based on current velocity or move vector)
	local velocity = rootPart.AssemblyLinearVelocity
	if velocity.Magnitude > 1 then
		slideDirection = velocity.Unit
	else
		slideDirection = rootPart.CFrame.LookVector
	end
	
	stateMachine:SetState("Slide")
	lastSlideTime = now
	
	-- Apply Initial Physics
	slideVelocity.MaxForce = 100000 -- Strong push
	slideVelocity.VectorVelocity = slideDirection * Config.SlideSpeed
	humanoid.AutoRotate = false -- Lock rotation during slide
	
	-- Cancel other sprinting states
	isTacSprinting = false
end

-- Bind Input Signals
inputController.TacticalSprintRequest.Event:Connect(startTacticalSprint)
inputController.SlideRequest.Event:Connect(startSlide)
inputController.JumpPressed.Event:Connect(function()
	if stateMachine:GetState() == "Slide" then
		stateMachine:SetState("Idle") -- Standard "Slide Cancel into Jump"
	end
	
	-- Grounded check for jump
	if humanoid.FloorMaterial ~= Enum.Material.Air then
		humanoid.Jump = true
	end
end)

-- Loop - Using PreSimulation for physics updates (per documentation recommendations)
RunService.PreSimulation:Connect(function(dt)
	updateState()
	applyMovement(dt)
end)

print("[MovementController] Initialized Phase 2")