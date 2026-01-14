local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Utils = ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Utils")
local Signal = require(Utils:WaitForChild("Signal"))

-- The Store
local Store = {
	State = {
		CurrentMenu = "PLAY", -- PLAY, WEAPONS, OPERATORS, etc.
		SelectedLoadoutId = 1,
		IsMatchmaking = false,
		PlayerProfile = nil
	},
	
	Changed = Signal.new()
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