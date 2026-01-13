local PlayerData = {}
PlayerData.__index = PlayerData

function PlayerData.new(player)
	local self = setmetatable({}, PlayerData)
	self.Player = player
	self.Data = {
		Level = 1,
		Experience = 0,
		Currency = 100,
		Inventory = {},
		Settings = {
			FOV = 70,
			Sensitivity = 1
		}
	}
	return self
end

return PlayerData