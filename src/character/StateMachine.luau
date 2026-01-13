local StateMachine = {}
StateMachine.__index = StateMachine

local States = {
	Idle = "Idle",
	Walk = "Walk",
	Run = "Run",
	Sprint = "Sprint",
	Crouch = "Crouch",
	ADS = "ADS", -- Added
	Jump = "Jump",
	Freefall = "Freefall",
	Land = "Land"
}

function StateMachine.new()
	local self = setmetatable({}, StateMachine)
	self.CurrentState = States.Idle
	self.StateChanged = Instance.new("BindableEvent")
	return self
end

function StateMachine:SetState(newState)
	if self.CurrentState == newState then return end
	
	local oldState = self.CurrentState
	self.CurrentState = newState
	self.StateChanged:Fire(newState, oldState)
end

function StateMachine:GetState()
	return self.CurrentState
end

StateMachine.States = States

return StateMachine
