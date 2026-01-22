--[[
	DeveloperConsole - In-game developer console with command registry
	Provides commands for game state, ammo, weapons, items, and player data modification
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Network = require(ReplicatedStorage.Framework.Network)

local DeveloperConsole = {}

-- Console state
DeveloperConsole.Enabled = true
DeveloperConsole.History = {}
DeveloperConsole.Commands = {}
DeveloperConsole.Output = {}
DeveloperConsole.IsOpen = false
DeveloperConsole.MaxHistory = 100
DeveloperConsole.MaxOutput = 500

-- Output levels
DeveloperConsole.Levels = {
	INFO = Color3.fromRGB(200, 200, 200),
	WARNING = Color3.fromRGB(255, 200, 0),
	ERROR = Color3.fromRGB(255, 100, 100),
	SUCCESS = Color3.fromRGB(100, 255, 100),
	DEBUG = Color3.fromRGB(100, 200, 255),
}

-- Log output
function DeveloperConsole.Log(level, message, data)
	local entry = {
		Level = level,
		Message = message,
		Data = data,
		Timestamp = os.date("%H:%M:%S")
	}
	
	table.insert(DeveloperConsole.Output, entry)
	
	-- Limit output size
	if #DeveloperConsole.Output > DeveloperConsole.MaxOutput then
		table.remove(DeveloperConsole.Output, 1)
	end
	
	-- Fire output event for UI
	if DeveloperConsole.OutputChanged then
		DeveloperConsole.OutputChanged:Fire(entry)
	end
end

-- Register command
function DeveloperConsole.RegisterCommand(name, callback, description, syntax, examples)
	DeveloperConsole.Commands[name:lower()] = {
		Name = name,
		Callback = callback,
		Description = description or "",
		Syntax = syntax or "",
		Examples = examples or {}
	}
end

-- Parse command input
local function parseCommand(input)
	input = input:gsub("^%s+", ""):gsub("%s+$", "") -- Trim
	if input == "" then return nil, {} end
	
	local parts = {}
	for part in string.gmatch(input, "%S+") do
		table.insert(parts, part)
	end
	
	if #parts == 0 then return nil, {} end
	
	local command = parts[1]:lower()
	table.remove(parts, 1)
	
	return command, parts
end

-- Execute command
function DeveloperConsole.ExecuteCommand(input)
	if not DeveloperConsole.Enabled then
		DeveloperConsole.Log("ERROR", "Console is disabled")
		return
	end
	
	-- Add to history
	table.insert(DeveloperConsole.History, input)
	if #DeveloperConsole.History > DeveloperConsole.MaxHistory then
		table.remove(DeveloperConsole.History, 1)
	end
	
	-- Log input
	DeveloperConsole.Log("INFO", "> " .. input)
	
	-- Parse and execute
	local command, args = parseCommand(input)
	if not command then return end
	
	local cmd = DeveloperConsole.Commands[command]
	if not cmd then
		DeveloperConsole.Log("ERROR", "Unknown command: " .. command .. " (type 'help' for commands)")
		return
	end
	
	-- Execute with error handling
	local success, result = pcall(function()
		return cmd.Callback(args)
	end)
	
	if not success then
		DeveloperConsole.Log("ERROR", "Command failed: " .. tostring(result))
	end
end

-- Get autocomplete suggestions
function DeveloperConsole.GetAutocompleteSuggestions(input)
	local suggestions = {}
	local inputLower = input:lower()
	
	for name, cmd in pairs(DeveloperConsole.Commands) do
		if name:sub(1, #inputLower) == inputLower then
			table.insert(suggestions, cmd.Name)
		end
	end
	
	return suggestions
end

-- Get command help
function DeveloperConsole.GetCommandHelp(commandName)
	local cmd = DeveloperConsole.Commands[commandName:lower()]
	if not cmd then return nil end
	
	return {
		Name = cmd.Name,
		Description = cmd.Description,
		Syntax = cmd.Syntax,
		Examples = cmd.Examples
	}
end

-- Get all commands
function DeveloperConsole.GetAllCommands()
	local commands = {}
	for _, cmd in pairs(DeveloperConsole.Commands) do
		table.insert(commands, cmd)
	end
	table.sort(commands, function(a, b) return a.Name < b.Name end)
	return commands
end

-- Clear output
function DeveloperConsole.Clear()
	DeveloperConsole.Output = {}
	if DeveloperConsole.OutputCleared then
		DeveloperConsole.OutputCleared:Fire()
	end
end

-- Events
DeveloperConsole.OutputChanged = Instance.new("BindableEvent")
DeveloperConsole.OutputCleared = Instance.new("BindableEvent")

-- Initialize with welcome message
DeveloperConsole.Log("INFO", "=== DEVELOPER CONSOLE ===")
DeveloperConsole.Log("INFO", "Type 'help' for available commands")
DeveloperConsole.Log("INFO", "Press F9 to toggle console")

return DeveloperConsole
