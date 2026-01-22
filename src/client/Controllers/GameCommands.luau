--[[
	GameCommands - Game-related console commands
	Commands for game state, ammo, weapons, items, and player data modification
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local Network = require(ReplicatedStorage.Framework.Network)

local DeveloperConsole = require(script.Parent.DeveloperConsole)
local WeaponController = require(script.Parent.WeaponController)

local GameCommands = {}

local player = Players.LocalPlayer

-- Helper: Get number from args
local function getNumber(args, index, default)
	if args[index] then
		local num = tonumber(args[index])
		if num then return num end
	end
	return default
end

-- Helper: Get string from args
local function getString(args, index, default)
	return args[index] or default
end

-- Register all game commands
function GameCommands.RegisterAll()
	-- === GAME STATE COMMANDS ===
	
	DeveloperConsole.RegisterCommand("gamestate", function(args)
		local state = getString(args, 1, "current")
		
		if state == "current" or state == "get" then
			local inMenu = player:GetAttribute("InMenu") or false
			local movementState = player.Character and player.Character:GetAttribute("MovementState") or "None"
			
			DeveloperConsole.Log("INFO", "=== GAME STATE ===")
			DeveloperConsole.Log("INFO", "In Menu: " .. tostring(inMenu))
			DeveloperConsole.Log("INFO", "Movement State: " .. tostring(movementState))
			DeveloperConsole.Log("INFO", "Character: " .. (player.Character and "Present" or "None"))
		elseif state == "menu" then
			player:SetAttribute("InMenu", true)
			DeveloperConsole.Log("SUCCESS", "Set game state to MENU")
		elseif state == "game" then
			player:SetAttribute("InMenu", false)
			DeveloperConsole.Log("SUCCESS", "Set game state to GAME")
		else
			DeveloperConsole.Log("ERROR", "Invalid state. Use: current, menu, game")
		end
	end, "Get or set game state", "gamestate [current|menu|game]", {
		"gamestate current",
		"gamestate menu",
		"gamestate game"
	})
	
	-- === AMMO COMMANDS ===
	
	DeveloperConsole.RegisterCommand("ammo", function(args)
		local action = getString(args, 1, "get")
		
		if action == "get" or action == "current" then
			local weaponState = WeaponController.GetWeaponState()
			DeveloperConsole.Log("INFO", "=== AMMO STATUS ===")
			DeveloperConsole.Log("INFO", "Current Ammo: " .. weaponState.Ammo)
			DeveloperConsole.Log("INFO", "Reserve: " .. weaponState.Reserve)
			DeveloperConsole.Log("INFO", "Max Ammo: " .. weaponState.MaxAmmo)
			DeveloperConsole.Log("INFO", "Max Reserve: " .. weaponState.MaxReserve)
			DeveloperConsole.Log("INFO", "Is Reloading: " .. tostring(weaponState.IsReloading))
		elseif action == "set" then
			local current = getNumber(args, 2, -1)
			local reserve = getNumber(args, 3, -1)
			
			if current >= 0 or reserve >= 0 then
				-- Send command to server to modify ammo
				Network.FireServer("DevCommand", "ammo", {Current = current, Reserve = reserve})
				DeveloperConsole.Log("SUCCESS", "Ammo modification request sent to server")
			else
				DeveloperConsole.Log("ERROR", "Usage: ammo set [current] [reserve]")
			end
		elseif action == "max" then
			Network.FireServer("DevCommand", "ammo", {Max = true})
			DeveloperConsole.Log("SUCCESS", "Set ammo to maximum")
		elseif action == "reload" then
			WeaponController.Reload()
			DeveloperConsole.Log("SUCCESS", "Started reload")
		else
			DeveloperConsole.Log("ERROR", "Usage: ammo [get|set|max|reload]")
		end
	end, "Manage weapon ammo", "ammo [get|set|max|reload] [current] [reserve]", {
		"ammo get",
		"ammo set 30 90",
		"ammo max",
		"ammo reload"
	})
	
	-- === WEAPON COMMANDS ===
	
	DeveloperConsole.RegisterCommand("weapon", function(args)
		local action = getString(args, 1, "info")
		
		if action == "info" or action == "get" then
			local weaponState = WeaponController.GetWeaponState()
			DeveloperConsole.Log("INFO", "=== WEAPON INFO ===")
			DeveloperConsole.Log("INFO", "Weapon: " .. (weaponState.Weapon or "None"))
			DeveloperConsole.Log("INFO", "Ammo: " .. weaponState.Ammo .. "/" .. weaponState.MaxAmmo)
			DeveloperConsole.Log("INFO", "Reserve: " .. weaponState.Reserve)
			DeveloperConsole.Log("INFO", "Reloading: " .. tostring(weaponState.IsReloading))
		elseif action == "give" then
			local weaponName = getString(args, 2, "")
			if weaponName == "" then
				DeveloperConsole.Log("ERROR", "Usage: weapon give <weaponName>")
				return
			end
			
			Network.FireServer("DevCommand", "weapon_give", {WeaponName = weaponName})
			DeveloperConsole.Log("SUCCESS", "Requested weapon: " .. weaponName)
		elseif action == "list" then
			DeveloperConsole.Log("INFO", "=== AVAILABLE WEAPONS ===")
			DeveloperConsole.Log("INFO", "M4, Lachmann Sub, P890, M13B, X12, Knife")
		else
			DeveloperConsole.Log("ERROR", "Usage: weapon [info|give|list]")
		end
	end, "Manage weapons", "weapon [info|give|list] [weaponName]", {
		"weapon info",
		"weapon give M4",
		"weapon list"
	})
	
	-- === DROP ITEM COMMANDS ===
	
	DeveloperConsole.RegisterCommand("drop", function(args)
		local itemType = getString(args, 1, "")
		local itemName = getString(args, 2, "")
		local amount = getNumber(args, 3, 1)
		
		if itemType == "" then
			DeveloperConsole.Log("ERROR", "Usage: drop <type> [name] [amount]")
			DeveloperConsole.Log("INFO", "Types: weapon, cash, ammo, armor")
			return
		end
		
		local dropData = {
			Type = itemType,
			Name = itemName,
			Amount = amount
		}
		
		Network.FireServer("DevCommand", "drop_item", dropData)
		DeveloperConsole.Log("SUCCESS", "Dropped " .. amount .. "x " .. itemType .. (itemName ~= "" and (" (" .. itemName .. ")") or ""))
	end, "Drop items at player position", "drop <type> [name] [amount]", {
		"drop weapon M4",
		"drop cash 500",
		"drop ammo 60",
		"drop armor 3"
	})
	
	-- === PLAYER DATA COMMANDS ===
	
	DeveloperConsole.RegisterCommand("level", function(args)
		local action = getString(args, 1, "get")
		
		if action == "get" then
			Network.FireServer("DevCommand", "playerdata_get", {Field = "Level"})
			DeveloperConsole.Log("INFO", "Requesting player level from server...")
		elseif action == "set" then
			local level = getNumber(args, 2, -1)
			if level < 1 then
				DeveloperConsole.Log("ERROR", "Usage: level set <number>")
				return
			end
			
			Network.FireServer("DevCommand", "playerdata_set", {Field = "Level", Value = level})
			DeveloperConsole.Log("SUCCESS", "Set level to " .. level)
		elseif action == "add" then
			local amount = getNumber(args, 2, 1)
			Network.FireServer("DevCommand", "playerdata_add", {Field = "Level", Value = amount})
			DeveloperConsole.Log("SUCCESS", "Added " .. amount .. " level(s)")
		else
			DeveloperConsole.Log("ERROR", "Usage: level [get|set|add] [value]")
		end
	end, "Manage player level", "level [get|set|add] [value]", {
		"level get",
		"level set 50",
		"level add 5"
	})
	
	DeveloperConsole.RegisterCommand("xp", function(args)
		local action = getString(args, 1, "get")
		
		if action == "get" then
			Network.FireServer("DevCommand", "playerdata_get", {Field = "Experience"})
			DeveloperConsole.Log("INFO", "Requesting XP from server...")
		elseif action == "add" then
			local amount = getNumber(args, 2, 100)
			Network.FireServer("DevCommand", "playerdata_add", {Field = "Experience", Value = amount})
			DeveloperConsole.Log("SUCCESS", "Added " .. amount .. " XP")
		elseif action == "set" then
			local amount = getNumber(args, 2, 0)
			Network.FireServer("DevCommand", "playerdata_set", {Field = "Experience", Value = amount})
			DeveloperConsole.Log("SUCCESS", "Set XP to " .. amount)
		else
			DeveloperConsole.Log("ERROR", "Usage: xp [get|add|set] [amount]")
		end
	end, "Manage player XP", "xp [get|add|set] [amount]", {
		"xp get",
		"xp add 1000",
		"xp set 5000"
	})
	
	DeveloperConsole.RegisterCommand("cash", function(args)
		local action = getString(args, 1, "get")
		
		if action == "get" then
			Network.FireServer("DevCommand", "playerdata_get", {Field = "Currency"})
			DeveloperConsole.Log("INFO", "Requesting cash from server...")
		elseif action == "add" then
			local amount = getNumber(args, 2, 100)
			Network.FireServer("DevCommand", "playerdata_add", {Field = "Currency", Value = amount})
			DeveloperConsole.Log("SUCCESS", "Added $" .. amount)
		elseif action == "set" then
			local amount = getNumber(args, 2, 0)
			Network.FireServer("DevCommand", "playerdata_set", {Field = "Currency", Value = amount})
			DeveloperConsole.Log("SUCCESS", "Set cash to $" .. amount)
		else
			DeveloperConsole.Log("ERROR", "Usage: cash [get|add|set] [amount]")
		end
	end, "Manage player cash", "cash [get|add|set] [amount]", {
		"cash get",
		"cash add 5000",
		"cash set 10000"
	})
	
	DeveloperConsole.RegisterCommand("playerdata", function(args)
		local action = getString(args, 1, "get")
		
		if action == "get" then
			local field = getString(args, 2, "all")
			Network.FireServer("DevCommand", "playerdata_get", {Field = field})
			DeveloperConsole.Log("INFO", "Requesting player data from server...")
		elseif action == "set" then
			local field = getString(args, 2, "")
			local value = getString(args, 3, "")
			
			if field == "" then
				DeveloperConsole.Log("ERROR", "Usage: playerdata set <field> <value>")
				DeveloperConsole.Log("INFO", "Fields: Level, Currency, Experience, XPBoost")
				return
			end
			
			-- Try to parse as number
			local numValue = tonumber(value)
			Network.FireServer("DevCommand", "playerdata_set", {
				Field = field,
				Value = numValue or value
			})
			DeveloperConsole.Log("SUCCESS", "Set " .. field .. " to " .. value)
		elseif action == "reset" then
			Network.FireServer("DevCommand", "playerdata_reset", {})
			DeveloperConsole.Log("SUCCESS", "Reset player data to defaults")
		else
			DeveloperConsole.Log("ERROR", "Usage: playerdata [get|set|reset] [field] [value]")
		end
	end, "Manage player data", "playerdata [get|set|reset] [field] [value]", {
		"playerdata get",
		"playerdata set Level 50",
		"playerdata set Currency 10000",
		"playerdata reset"
	})
	
	-- === HEALTH COMMANDS ===
	
	DeveloperConsole.RegisterCommand("health", function(args)
		local action = getString(args, 1, "get")
		
		if not player.Character then
			DeveloperConsole.Log("ERROR", "No character found")
			return
		end
		
		local humanoid = player.Character:FindFirstChild("Humanoid")
		if not humanoid then
			DeveloperConsole.Log("ERROR", "No humanoid found")
			return
		end
		
		if action == "get" then
			DeveloperConsole.Log("INFO", "=== HEALTH STATUS ===")
			DeveloperConsole.Log("INFO", "Health: " .. math.ceil(humanoid.Health) .. "/" .. math.ceil(humanoid.MaxHealth))
		elseif action == "set" then
			local health = getNumber(args, 2, 100)
			humanoid.Health = math.clamp(health, 0, humanoid.MaxHealth)
			DeveloperConsole.Log("SUCCESS", "Set health to " .. health)
		elseif action == "heal" or action == "max" then
			humanoid.Health = humanoid.MaxHealth
			DeveloperConsole.Log("SUCCESS", "Healed to full health")
		else
			DeveloperConsole.Log("ERROR", "Usage: health [get|set|heal] [value]")
		end
	end, "Manage player health", "health [get|set|heal] [value]", {
		"health get",
		"health set 50",
		"health heal"
	})
	
	-- === HELP COMMAND ===
	
	DeveloperConsole.RegisterCommand("help", function(args)
		local commandName = getString(args, 1, "")
		
		if commandName == "" then
			DeveloperConsole.Log("INFO", "=== AVAILABLE COMMANDS ===")
			DeveloperConsole.Log("INFO", "")
			DeveloperConsole.Log("INFO", "GAME STATE:")
			DeveloperConsole.Log("INFO", "  gamestate [current|menu|game] - Get or set game state")
			DeveloperConsole.Log("INFO", "")
			DeveloperConsole.Log("INFO", "AMMO & WEAPONS:")
			DeveloperConsole.Log("INFO", "  ammo [get|set|max|reload] [current] [reserve] - Manage ammo")
			DeveloperConsole.Log("INFO", "  weapon [info|give|list] [weaponName] - Manage weapons")
			DeveloperConsole.Log("INFO", "")
			DeveloperConsole.Log("INFO", "ITEMS:")
			DeveloperConsole.Log("INFO", "  drop <type> [name] [amount] - Drop items (weapon, cash, ammo, armor)")
			DeveloperConsole.Log("INFO", "")
			DeveloperConsole.Log("INFO", "PLAYER DATA:")
			DeveloperConsole.Log("INFO", "  level [get|set|add] [value] - Manage player level")
			DeveloperConsole.Log("INFO", "  xp [get|add|set] [amount] - Manage XP")
			DeveloperConsole.Log("INFO", "  cash [get|add|set] [amount] - Manage cash")
			DeveloperConsole.Log("INFO", "  playerdata [get|set|reset] [field] [value] - Manage player data")
			DeveloperConsole.Log("INFO", "  health [get|set|heal] [value] - Manage health")
			DeveloperConsole.Log("INFO", "")
			DeveloperConsole.Log("INFO", "Type 'help <command>' for detailed help")
		else
			local help = DeveloperConsole.GetCommandHelp(commandName)
			if help then
				DeveloperConsole.Log("INFO", "=== " .. help.Name:upper() .. " ===")
				DeveloperConsole.Log("INFO", help.Description)
				DeveloperConsole.Log("INFO", "Syntax: " .. help.Syntax)
				if #help.Examples > 0 then
					DeveloperConsole.Log("INFO", "Examples:")
					for _, example in ipairs(help.Examples) do
						DeveloperConsole.Log("INFO", "  " .. example)
					end
				end
			else
				DeveloperConsole.Log("ERROR", "Command not found: " .. commandName)
			end
		end
	end, "Show command help", "help [command]", {
		"help",
		"help ammo",
		"help weapon"
	})
	
	-- === CLEAR COMMAND ===
	
	DeveloperConsole.RegisterCommand("clear", function(args)
		DeveloperConsole.Clear()
		DeveloperConsole.Log("SUCCESS", "Console cleared")
	end, "Clear console output", "clear", {
		"clear"
	})
	
	-- === POSITION COMMAND ===
	
	DeveloperConsole.RegisterCommand("pos", function(args)
		local character = player.Character
		if not character or not character:FindFirstChild("HumanoidRootPart") then
			DeveloperConsole.Log("ERROR", "No character found")
			return
		end
		
		local position = character.HumanoidRootPart.Position
		DeveloperConsole.Log("INFO", "Position: " .. tostring(position))
		DeveloperConsole.Log("INFO", "X: " .. math.floor(position.X) .. ", Y: " .. math.floor(position.Y) .. ", Z: " .. math.floor(position.Z))
	end, "Get player position", "pos", {
		"pos"
	})
	
	-- === TELEPORT COMMAND ===
	
	DeveloperConsole.RegisterCommand("tp", function(args)
		local x = getNumber(args, 1, nil)
		local y = getNumber(args, 2, nil)
		local z = getNumber(args, 3, nil)
		
		if not x or not y or not z then
			DeveloperConsole.Log("ERROR", "Usage: tp <x> <y> <z>")
			return
		end
		
		local character = player.Character
		if not character or not character:FindFirstChild("HumanoidRootPart") then
			DeveloperConsole.Log("ERROR", "No character found")
			return
		end
		
		character.HumanoidRootPart.CFrame = CFrame.new(x, y, z)
		DeveloperConsole.Log("SUCCESS", "Teleported to (" .. x .. ", " .. y .. ", " .. z .. ")")
	end, "Teleport player", "tp <x> <y> <z>", {
		"tp 0 10 0",
		"tp 100 50 100"
	})
	
	print("[GameCommands] Registered all game commands")
end

return GameCommands
