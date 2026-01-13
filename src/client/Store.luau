local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SimpleSignal = {} -- Simple signal implementation for state changes
SimpleSignal.__index = SimpleSignal

function SimpleSignal.new()
	local self = setmetatable({}, SimpleSignal)
	self._listeners = {}
	return self
end

function SimpleSignal:Connect(fn)
	table.insert(self._listeners, fn)
	return {
		Disconnect = function()
			local idx = table.find(self._listeners, fn)
			if idx then table.remove(self._listeners, idx) end
		end
	}
end

function SimpleSignal:Fire(...)
	for _, fn in ipairs(self._listeners) do
		task.spawn(fn, ...)
	end
end

-- The Store
local Store = {
	State = {
		CurrentMenu = "PLAY", -- PLAY, WEAPONS, OPERATORS, etc.
		SelectedLoadoutId = 1,
		IsMatchmaking = false,
		PlayerProfile = nil
	},
	
	Changed = SimpleSignal.new()
}

function Store.Set(key, value)
	if Store.State[key] == value then return end
	local oldValue = Store.State[key]
	Store.State[key] = value
	Store.Changed:Fire(key, value, oldValue)
end

function Store.Get(key)
	return Store.State[key]
end

return Store