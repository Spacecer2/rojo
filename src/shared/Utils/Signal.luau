--[[
	Robust Signal Implementation
	Scalable event system for decoupled communication
]]
local Signal = {}
Signal.__index = Signal

function Signal.new()
	local self = setmetatable({}, Signal)
	self._listeners = {}
	return self
end

function Signal:Connect(fn)
	if typeof(fn) ~= "function" then
		error("Signal:Connect(fn) expects a function")
	end
	
	table.insert(self._listeners, fn)
	
	return {
		Disconnect = function()
			local idx = table.find(self._listeners, fn)
			if idx then
				table.remove(self._listeners, idx)
			end
		end
	}
end

function Signal:Fire(...)
	for _, fn in ipairs(self._listeners) do
		task.spawn(fn, ...)
	end
end

function Signal:Wait()
	local thread = coroutine.running()
	local connection
	connection = self:Connect(function(...)
		connection:Disconnect()
		task.spawn(thread, ...)
	end)
	return coroutine.yield()
end

function Signal:Destroy()
	self._listeners = {}
end

return Signal
