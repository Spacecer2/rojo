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

-- Bind State Changes
stateMachine.StateChanged.Event:Connect(function(newState, oldState)
	char:SetAttribute("MovementState", newState)
	
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
	if stateMachine:GetState() == "Land" and not isMoving then
		return
	end

	if isMoving then
		if isAiming then
			stateMachine:SetState("ADS")
		elseif isSprinting then
			stateMachine:SetState("Sprint")
		elseif isCrouching then
			stateMachine:SetState("Crouch")
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

local function applyMovement()
	local inMenu = player:GetAttribute("InMenu")
	if inMenu then
		humanoid.WalkSpeed = 0
		return
	end

	local currentState = stateMachine:GetState()
	local targetSpeed = Config.WalkSpeed
	
	if currentState == "Run" then
		targetSpeed = Config.RunSpeed
	elseif currentState == "Sprint" then
		targetSpeed = Config.SprintSpeed
	elseif currentState == "Crouch" then
		targetSpeed = Config.CrouchSpeed
	elseif currentState == "ADS" then
		targetSpeed = Config.WalkSpeed * Config.ADSSpeedMultiplier
	elseif currentState == "Idle" or currentState == "Land" then
		targetSpeed = (currentState == "Land") and (Config.WalkSpeed * 0.5) or 0
	end
	
	humanoid.WalkSpeed = targetSpeed
	
	-- FOV Change for ADS
	local targetFOV = inputController.IsAiming and 50 or 70
	camera.FieldOfView = camera.FieldOfView + (targetFOV - camera.FieldOfView) * 0.1
end

-- Loop
RunService.Heartbeat:Connect(function()
	updateState()
	applyMovement()
end)

print("[MovementController] Initialized Phase 2")