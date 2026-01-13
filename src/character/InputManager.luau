local UserInputService = game:GetService("UserInputService")
local ContextActionService = game:GetService("ContextActionService")

local InputController = {}
InputController.__index = InputController

-- Signals
InputController.MoveVectorChanged = Instance.new("BindableEvent")
InputController.SprintToggled = Instance.new("BindableEvent")
InputController.CrouchToggled = Instance.new("BindableEvent")
InputController.JumpPressed = Instance.new("BindableEvent")
InputController.ADSToggled = Instance.new("BindableEvent") -- Added

function InputController.new()
	local self = setmetatable({}, InputController)
	self.MoveVector = Vector3.zero
	self.IsSprinting = false
	self.IsCrouching = false
	self.IsAiming = false -- Added
	
	self:Setup()
	return self
end

function InputController:Setup()
	UserInputService.InputBegan:Connect(function(input, gpe)
		if gpe then return end
		
		if input.KeyCode == Enum.KeyCode.LeftShift then
			self.IsSprinting = true
			self.SprintToggled:Fire(true)
		elseif input.KeyCode == Enum.KeyCode.C then
			self.IsCrouching = not self.IsCrouching
			self.CrouchToggled:Fire(self.IsCrouching)
		elseif input.KeyCode == Enum.KeyCode.Space then
			self.JumpPressed:Fire()
		elseif input.UserInputType == Enum.UserInputType.MouseButton2 then -- ADS
			self.IsAiming = true
			self.ADSToggled:Fire(true)
		end
	end)
	
	UserInputService.InputEnded:Connect(function(input, gpe)
		if input.KeyCode == Enum.KeyCode.LeftShift then
			self.IsSprinting = false
			self.SprintToggled:Fire(false)
		elseif input.UserInputType == Enum.UserInputType.MouseButton2 then -- ADS
			self.IsAiming = false
			self.ADSToggled:Fire(false)
		end
	end)
end

function InputController:GetMoveVector()
	-- Basic WASD vector construction
	local vector = Vector3.zero
	if UserInputService:IsKeyDown(Enum.KeyCode.W) then vector += Vector3.new(0, 0, -1) end
	if UserInputService:IsKeyDown(Enum.KeyCode.S) then vector += Vector3.new(0, 0, 1) end
	if UserInputService:IsKeyDown(Enum.KeyCode.A) then vector += Vector3.new(-1, 0, 0) end
	if UserInputService:IsKeyDown(Enum.KeyCode.D) then vector += Vector3.new(1, 0, 0) end
	
	-- Normalize if length > 0
	if vector.Magnitude > 0 then
		vector = vector.Unit
	end
	
	return vector
end

return InputController