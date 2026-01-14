--[[
	OperatorData - Configuration for all selectable operators
	Used by OperatorsView for the UI grid and selection logic
]]

local OperatorData = {
	Operators = {
		{
			Id = "T-800",
			Name = "T-800",
			Portrait = "rbxassetid://13165203306", -- Mock Arnold image if available, else placeholder
			Skins = 2,
			Unlocked = true,
			FinishingMove = "HOOK & SLASH",
			Rarity = "Legendary",
			Bio = "Cyberdyne Systems Model 101."
		},
		{
			Id = "Ghost",
			Name = "Ghost",
			Portrait = "rbxassetid://13165203306",
			Skins = 4,
			Unlocked = true,
			FinishingMove = "SILENT ENTRY",
			Rarity = "Epic",
			Bio = "Simon 'Ghost' Riley."
		},
		{
			Id = "Soap",
			Name = "Soap",
			Portrait = "rbxassetid://13165203306",
			Skins = 2,
			Unlocked = false,
			FinishingMove = "CLEAN UP",
			Rarity = "Rare",
		},
		-- Mock more to fill the grid
		{ Id = "Price", Name = "Price", Portrait = "rbxassetid://13165203306", Unlocked = false },
		{ Id = "Gaz", Name = "Gaz", Portrait = "rbxassetid://13165203306", Unlocked = true },
		{ Id = "Farah", Name = "Farah", Portrait = "rbxassetid://13165203306", Unlocked = true },
		{ Id = "Roze", Name = "Roze", Portrait = "rbxassetid://13165203306", Unlocked = false },
		{ Id = "Nikto", Name = "Nikto", Portrait = "rbxassetid://13165203306", Unlocked = true },
		{ Id = "Mace", Name = "Mace", Portrait = "rbxassetid://13165203306", Unlocked = true },
		{ Id = "Velikan", Name = "Velikan", Portrait = "rbxassetid://13165203306", Unlocked = false },
		{ Id = "Lerch", Name = "Lerch", Portrait = "rbxassetid://13165203306", Unlocked = true },
		{ Id = "Woods", Name = "Woods", Portrait = "rbxassetid://13165203306", Unlocked = true },
		{ Id = "Mason", Name = "Mason", Portrait = "rbxassetid://13165203306", Unlocked = false },
	}
}

return OperatorData
