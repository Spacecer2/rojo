--[[
	OperatorData - Configuration for all selectable operators
	Used by OperatorsView for the UI grid and selection logic
	ID definitions now sourced from IDRegistry for centralized management
]]

local IDRegistry = require(script.Parent:WaitForChild("IDRegistry"))

local OperatorData = {
	Operators = {
		{
			Id = IDRegistry.Operators.T_800,
			Name = "T-800",
			Portrait = "rbxassetid://13165203306", -- Mock Arnold image if available, else placeholder
			Skins = 2,
			Unlocked = true,
			FinishingMove = "HOOK & SLASH",
			Rarity = "Legendary",
			Bio = "Cyberdyne Systems Model 101."
		},
		{
			Id = IDRegistry.Operators.GHOST,
			Name = "Ghost",
			Portrait = "rbxassetid://13165203306",
			Skins = 4,
			Unlocked = true,
			FinishingMove = "SILENT ENTRY",
			Rarity = "Epic",
			Bio = "Simon 'Ghost' Riley."
		},
		{
			Id = IDRegistry.Operators.SOAP,
			Name = "Soap",
			Portrait = "rbxassetid://13165203306",
			Skins = 2,
			Unlocked = false,
			FinishingMove = "CLEAN UP",
			Rarity = "Rare",
		},
		-- Mock more to fill the grid
		{ Id = IDRegistry.Operators.PRICE, Name = "Price", Portrait = "rbxassetid://13165203306", Unlocked = false },
		{ Id = IDRegistry.Operators.GAZ, Name = "Gaz", Portrait = "rbxassetid://13165203306", Unlocked = true },
		{ Id = IDRegistry.Operators.FARAH, Name = "Farah", Portrait = "rbxassetid://13165203306", Unlocked = true },
		{ Id = IDRegistry.Operators.ROZE, Name = "Roze", Portrait = "rbxassetid://13165203306", Unlocked = false },
		{ Id = IDRegistry.Operators.NIKTO, Name = "Nikto", Portrait = "rbxassetid://13165203306", Unlocked = true },
		{ Id = IDRegistry.Operators.MACE, Name = "Mace", Portrait = "rbxassetid://13165203306", Unlocked = true },
		{ Id = IDRegistry.Operators.VELIKAN, Name = "Velikan", Portrait = "rbxassetid://13165203306", Unlocked = false },
		{ Id = IDRegistry.Operators.LERCH, Name = "Lerch", Portrait = "rbxassetid://13165203306", Unlocked = true },
		{ Id = IDRegistry.Operators.WOODS, Name = "Woods", Portrait = "rbxassetid://13165203306", Unlocked = true },
		{ Id = IDRegistry.Operators.MASON, Name = "Mason", Portrait = "rbxassetid://13165203306", Unlocked = false },
	}
}

return OperatorData
