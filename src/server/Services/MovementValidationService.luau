--[[
	MovementValidationService - Server-side validation for movement states
	Ensures movement states are valid and prevents exploits in multiplayer
]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ServerScriptService = game:GetService("ServerScriptService")

local MovementValidationService = {}

-- Lazy load CheaterManagementService to avoid circular dependency
local CheaterManagementService = nil
local function getCheaterManagementService()
	if not CheaterManagementService then
		CheaterManagementService = require(ServerScriptService.Services.CheaterManagementService)
	end
	return CheaterManagementService
end

-- Valid movement states (from StateMachine)
local VALID_STATES = {
	"Idle",
	"Run",
	"Sprint",
	"TacticalSprint",
	"Crouch",
	"CrouchWalk",
	"ADS",
	"Jump",
	"Freefall",
	"Land",
	"Slide",
}

-- Track player movement states for validation
local playerStates: {[number]: string} = {}

-- Validate movement state
local function isValidState(state: string): boolean
	return table.find(VALID_STATES, state) ~= nil
end

-- Monitor player movement states
local function monitorPlayer(player: Player)
	if not player.Character then return end
	
	local character = player.Character
	local humanoid = character:FindFirstChild("Humanoid")
	if not humanoid then return end
	
	-- Listen for movement state changes
	character:GetAttributeChangedSignal("MovementState"):Connect(function()
		local state = character:GetAttribute("MovementState")
		
		if state then
			-- Validate state
			if not isValidState(state) then
				warn("[MovementValidationService] Invalid movement state for " .. player.Name .. ": " .. tostring(state))
				-- Report to cheater management
				getCheaterManagementService().ReportViolation(player, "INVALID_MOVEMENT_STATE", "State: " .. tostring(state))
				-- Reset to Idle if invalid
				character:SetAttribute("MovementState", "Idle")
				return
			end
			
			-- Store state for monitoring
			playerStates[player.UserId] = state
			
			-- Additional validation: Check if player can be in certain states
			-- For example, can't be sliding if not grounded
			if state == "Slide" then
				if humanoid.FloorMaterial == Enum.Material.Air then
					warn("[MovementValidationService] Player " .. player.Name .. " attempted slide while airborne")
					getCheaterManagementService().ReportViolation(player, "INVALID_MOVEMENT_STATE", "Slide while airborne")
					character:SetAttribute("MovementState", "Freefall")
				end
			end
		end
	end)
	
	-- Periodic validation check
	task.spawn(function()
		while player.Parent and character.Parent do
			task.wait(1) -- Check every second
			
			local currentState = character:GetAttribute("MovementState")
			if currentState and not isValidState(currentState) then
				warn("[MovementValidationService] Detected invalid state for " .. player.Name .. ": " .. tostring(currentState))
				character:SetAttribute("MovementState", "Idle")
			end
		end
	end)
end

function MovementValidationService.Init()
	-- Monitor existing players
	for _, player in ipairs(Players:GetPlayers()) do
		if player.Character then
			monitorPlayer(player)
		end
		player.CharacterAdded:Connect(function()
			monitorPlayer(player)
		end)
	end
	
	-- Monitor new players
	Players.PlayerAdded:Connect(function(player)
		if player.Character then
			monitorPlayer(player)
		end
		player.CharacterAdded:Connect(function()
			monitorPlayer(player)
		end)
	end)
	
	print("[MovementValidationService] Initialized - Monitoring movement states for multiplayer")
end

-- Get current movement state for a player (for other services)
function MovementValidationService.GetPlayerState(player: Player): string?
	if player.Character then
		return player.Character:GetAttribute("MovementState")
	end
	return nil
end

return MovementValidationService
