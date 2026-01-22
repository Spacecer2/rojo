--[[
	SharedState - A central repository for sharing live instances/references between client systems.
	This is used as an idiomatic replacement for _G.
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Signal = require(ReplicatedStorage:WaitForChild("Utils"):WaitForChild("Signal"))

local SharedState = {
	References = {},
	ReferenceAdded = Signal.new()
}

function SharedState.Set(name, instance)
	SharedState.References[name] = instance
	SharedState.ReferenceAdded:Fire(name, instance)
end

function SharedState.Get(name)
	return SharedState.References[name]
end

-- Wait for a reference to be set if it doesn't exist yet
function SharedState.WaitFor(name, timeout)
	if SharedState.References[name] then
		return SharedState.References[name]
	end
	
	local startTime = tick()
	timeout = timeout or 10
	
	while not SharedState.References[name] do
		if (tick() - startTime) > timeout then
			warn("[SharedState] Timeout waiting for reference: " .. name)
			return nil
		end
		task.wait()
	end
	
	return SharedState.References[name]
end

return SharedState
