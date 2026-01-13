--[[
	Robust Physics Spring
	Handles both Scalars and Vector3
]]
local Spring = {}
Spring.__index = Spring

function Spring.new(position)
	local self = setmetatable({}, Spring)
	
	self.Target = position or Vector3.zero
	self.Position = position or Vector3.zero
	self.Velocity = (typeof(self.Target) == "Vector3") and Vector3.zero or 0
	
	self.Mass = 1
	self.Force = 50
	self.Damper = 1 -- 1 = Critical Damping
	self.Speed = 4
	
	return self
end

function Spring:Update(dt)
	-- Clamp dt to prevent explosions on lag spikes
	dt = math.min(dt, 0.05) * self.Speed
	
	local displacement = self.Position - self.Target
	local springForce = -self.Force * displacement
	local dampingForce = self.Damper * self.Velocity
	
	local acceleration = (springForce - dampingForce) / self.Mass
	
	self.Velocity = self.Velocity + acceleration * dt
	self.Position = self.Position + self.Velocity * dt
	
	-- NaN check
	if typeof(self.Position) == "number" then
		if self.Position ~= self.Position then self.Position = self.Target end
	elseif self.Position.X ~= self.Position.X then
		self.Position = self.Target
	end
	
	return self.Position
end

function Spring:Shove(force)
	self.Velocity = self.Velocity + force
end

return Spring