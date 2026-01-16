local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Network = require(ReplicatedStorage:WaitForChild("Framework"):WaitForChild("Network"))

local LoadoutData = {}

local defaultLoadouts = {
	{
		Id = 1,
		Name = "Meta M13",
		Primary = { Name = "M13B", Category = "Assault Rifle", Progress = 2200, Max = 2200 },
		Secondary = { Name = "X12", Category = "Handgun", Progress = 500, Max = 1000 },
		Perks = {"Overkill", "Ghost", "Tracker"},
		Lethal = "Semtex",
		Tactical = "Flash Grenade"
	},
	{
		Id = 2,
		Name = "Warzone SMG",
		Primary = { Name = "Lachmann Sub", Category = "Submachine Gun", Progress = 433, Max = 2200 },
		Secondary = { Name = "Knife", Category = "Melee", Progress = 100, Max = 100 },
		Perks = {"Double Time", "Fast Hands", "Birdseye"},
		Lethal = "Thermite",
		Tactical = "Stim"
	}
}

local loadouts = table.clone(defaultLoadouts)
local nextId = 3

function LoadoutData.GetLoadouts()
	return loadouts
end

function LoadoutData.CreateNew()
	local newLoadout = {
		Id = nextId,
		Name = "Custom Loadout " .. nextId,
		Primary = { Name = "M4", Category = "Assault Rifle", Progress = 0, Max = 2200 },
		Secondary = { Name = "P890", Category = "Handgun", Progress = 0, Max = 1000 },
		Perks = {"E.O.D.", "Hardline", "Ghost"},
		Lethal = "Frag",
		Tactical = "Stun"
	}
	table.insert(loadouts, newLoadout)
	nextId += 1
	return newLoadout
end

function LoadoutData.Delete(id)
	for i, loadout in ipairs(loadouts) do
		if loadout.Id == id then
			table.remove(loadouts, i)
			break
		end
	end
end

function LoadoutData.Save(loadout)
	Network.FireServer("UpdateLoadout", loadout)
end

return LoadoutData