--[[
	Input Manager - Scalable input abstraction layer
	Uses ContextActionService for desktop + controller support and better abstraction
	Per documentation: ContextActionService for actions, UserInputService for axis data
]]
local UserInputService = game:GetService("UserInputService")
local ContextActionService = game:GetService("ContextActionService")

local InputController = {}
InputController.__index = InputController

-- Signals for decoupled communication
InputController.MoveVectorChanged = Instance.new("BindableEvent")
InputController.SprintToggled = Instance.new("BindableEvent")
InputController.TacticalSprintRequest = Instance.new("BindableEvent") -- New event for Tac Sprint
InputController.CrouchToggled = Instance.new("BindableEvent")
InputController.SlideRequest = Instance.new("BindableEvent") -- New event for Slide
InputController.JumpPressed = Instance.new("BindableEvent")
InputController.ADSToggled = Instance.new("BindableEvent")
InputController.FireToggled = Instance.new("BindableEvent")
InputController.ReloadRequest = Instance.new("BindableEvent")

-- Action names for ContextActionService (scalable pattern)
local ACTION_SPRINT = "Sprint"
local ACTION_CROUCH = "Crouch"
local ACTION_JUMP = "Jump"
local ACTION_ADS = "AimDownSights"
local ACTION_FIRE = "Fire"
local ACTION_RELOAD = "Reload"

local DOUBLE_TAP_THRESHOLD = 0.3 -- Max time between taps


function InputController.new()
	local self = setmetatable({}, InputController)
	self.MoveVector = Vector3.zero
	self.IsSprinting = false
	self.IsCrouching = false
	self.IsAiming = false
	self.IsFiring = false
	self._boundActions = {}
	self._lastSprintPress = 0
	
	self:Setup()
	return self
end

function InputController:Setup()
	-- Bind ContextActionService actions (supports desktop + controller, better abstraction)
	-- Sprint (Hold)
	self._boundActions[ACTION_SPRINT] = ContextActionService:BindAction(
		ACTION_SPRINT,
		function(_, state, inputObject)
			local isPressed = state == Enum.UserInputState.Begin
			
			if isPressed then
				local now = tick()
				if (now - self._lastSprintPress) < DOUBLE_TAP_THRESHOLD then
					self.TacticalSprintRequest:Fire()
				end
				self._lastSprintPress = now
			end
			
			self.IsSprinting = isPressed
			self.SprintToggled:Fire(isPressed)
			return Enum.ContextActionResult.Sink
		end,
		false,
		Enum.KeyCode.LeftShift
	)
	
	-- Crouch (Toggle or Slide)
	self._boundActions[ACTION_CROUCH] = ContextActionService:BindAction(
		ACTION_CROUCH,
		function(_, state, inputObject)
			if state == Enum.UserInputState.Begin then
				-- If sprinting, this is a Slide request
				if self.IsSprinting then
					self.SlideRequest:Fire()
				else
					self.IsCrouching = not self.IsCrouching
					self.CrouchToggled:Fire(self.IsCrouching)
				end
			end
			return Enum.ContextActionResult.Sink
		end,
		false,
		Enum.KeyCode.C
	)
	
	-- Jump (Press)
	self._boundActions[ACTION_JUMP] = ContextActionService:BindAction(
		ACTION_JUMP,
		function(_, state, inputObject)
			if state == Enum.UserInputState.Begin then
				self.JumpPressed:Fire()
			end
			return Enum.ContextActionResult.Sink
		end,
		false,
		Enum.KeyCode.Space
	)
	
	-- ADS (Hold) - MouseButton2
	self._boundActions[ACTION_ADS] = ContextActionService:BindAction(
		ACTION_ADS,
		function(_, state, inputObject)
			local isPressed = state == Enum.UserInputState.Begin
			self.IsAiming = isPressed
			self.ADSToggled:Fire(isPressed)
			return Enum.ContextActionResult.Sink
		end,
		false,
		Enum.UserInputType.MouseButton2
	)

	-- Fire (Hold) - MouseButton1
	self._boundActions[ACTION_FIRE] = ContextActionService:BindAction(
		ACTION_FIRE,
		function(_, state, inputObject)
			local isPressed = state == Enum.UserInputState.Begin
			self.IsFiring = isPressed
			self.FireToggled:Fire(isPressed)
			return Enum.ContextActionResult.Sink
		end,
		false,
		Enum.UserInputType.MouseButton1
	)

	-- Reload (Press) - R
	self._boundActions[ACTION_RELOAD] = ContextActionService:BindAction(
		ACTION_RELOAD,
		function(_, state, inputObject)
			if state == Enum.UserInputState.Begin then
				self.ReloadRequest:Fire()
			end
			return Enum.ContextActionResult.Sink
		end,
		false,
		Enum.KeyCode.R
	)
	
	-- MoveVector is computed on-demand via GetMoveVector() (called by MovementController)
	-- No background polling needed - MovementController calls GetMoveVector() directly for efficiency
end

function InputController:GetMoveVector()
	-- Basic WASD vector construction (normalized)
	local vector = Vector3.new(0, 0, 0)
	if UserInputService:IsKeyDown(Enum.KeyCode.W) then vector = vector + Vector3.new(0, 0, -1) end
	if UserInputService:IsKeyDown(Enum.KeyCode.S) then vector = vector + Vector3.new(0, 0, 1) end
	if UserInputService:IsKeyDown(Enum.KeyCode.A) then vector = vector + Vector3.new(-1, 0, 0) end
	if UserInputService:IsKeyDown(Enum.KeyCode.D) then vector = vector + Vector3.new(1, 0, 0) end
	
	-- Normalize if length > 0
	if vector.Magnitude > 0 then
		vector = vector.Unit
	end
	
	return vector
end

function InputController:Cleanup()
	-- Cleanup bound actions (scalable pattern)
	for actionName, connection in pairs(self._boundActions) do
		ContextActionService:UnbindAction(actionName)
	end
	self._boundActions = {}
end

return InputController
