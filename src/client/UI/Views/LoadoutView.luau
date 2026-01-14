--[[
	LoadoutView - Weapons/loadout management view
	Shows the loadout editor interface
]]
local WeaponsMenu = require(script.Parent.Parent.Parent.Interface.Weapons.WeaponsMenu)

local LoadoutView = {}

function LoadoutView.Create(parent)
	return WeaponsMenu.Create(parent)
end

return LoadoutView
