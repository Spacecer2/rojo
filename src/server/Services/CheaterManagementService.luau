--[[
	CheaterManagementService - Unified anti-cheat and violation management system
	Detects, tracks, and punishes cheaters with a comprehensive violation system
]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")
local ServerScriptService = game:GetService("ServerScriptService")

local MovementValidationService = require(ServerScriptService.Services.MovementValidationService)

local CheaterManagementService = {}

-- Violation types and their severity scores
local ViolationTypes = {
	-- Movement violations
	SPEED_HACK = { Score = 50, Name = "Speed Hack" },
	TELEPORT = { Score = 100, Name = "Teleportation" },
	FLY_HACK = { Score = 75, Name = "Fly Hack" },
	NO_CLIP = { Score = 80, Name = "No-Clip" },
	INVALID_MOVEMENT_STATE = { Score = 10, Name = "Invalid Movement State" },
	
	-- Combat violations
	AIMBOT = { Score = 150, Name = "Aimbot" },
	WALLHACK = { Score = 120, Name = "Wallhack" },
	RAPID_FIRE = { Score = 60, Name = "Rapid Fire" },
	NO_RECOIL = { Score = 40, Name = "No Recoil" },
	
	-- Inventory violations
	ITEM_DUPLICATION = { Score = 90, Name = "Item Duplication" },
	INVALID_ITEM = { Score = 30, Name = "Invalid Item" },
	
	-- Network violations
	PACKET_SPAM = { Score = 20, Name = "Packet Spam" },
	INVALID_REQUEST = { Score = 15, Name = "Invalid Request" },
	
	-- General violations
	SCRIPT_INJECTION = { Score = 200, Name = "Script Injection" },
	EXPLOIT_ATTEMPT = { Score = 25, Name = "Exploit Attempt" },
}

-- Punishment thresholds
local PunishmentThresholds = {
	WARNING = 30,      -- First warning
	KICK = 100,        -- Auto-kick
	BAN_SHORT = 200,   -- 1 hour ban
	BAN_MEDIUM = 300,  -- 24 hour ban
	BAN_LONG = 500,    -- 7 day ban
	BAN_PERMANENT = 1000, -- Permanent ban
}

-- Player violation tracking
local playerViolations: {[number]: {
	TotalScore: number,
	Violations: {[string]: number}, -- Violation type -> count
	FirstViolation: number,
	LastViolation: number,
	Warnings: number,
	Kicks: number,
	Bans: number,
	IsBanned: boolean,
	BanUntil: number?,
}} = {}

-- Position tracking for speed/teleport detection
local playerPositions: {[number]: {
	LastPosition: Vector3,
	LastTime: number,
	VelocityHistory: {number},
}} = {}

-- Configuration
local CONFIG = {
	-- Speed detection
	MAX_SPEED = 50, -- Studs per second (normal max is ~30)
	SPEED_CHECK_INTERVAL = 0.1, -- Check every 100ms
	TELEPORT_THRESHOLD = 100, -- Studs (if moved more than this instantly, it's teleport)
	
	-- Position validation
	POSITION_CHECK_INTERVAL = 0.2, -- Check every 200ms
	
	-- Violation decay
	VIOLATION_DECAY_TIME = 300, -- 5 minutes (violations decay after this)
	VIOLATION_DECAY_RATE = 0.1, -- 10% decay per interval
	
	-- Logging
	LOG_TO_CONSOLE = true,
	LOG_TO_FILE = false, -- Future: implement file logging
}

-- Logging system
local function logViolation(player: Player, violationType: string, details: string?)
	local violation = ViolationTypes[violationType]
	if not violation then return end
	
	local userId = player.UserId
	local playerData = playerViolations[userId]
	
	if not playerData then
		playerData = {
			TotalScore = 0,
			Violations = {},
			FirstViolation = tick(),
			LastViolation = tick(),
			Warnings = 0,
			Kicks = 0,
			Bans = 0,
			IsBanned = false,
			BanUntil = nil,
		}
		playerViolations[userId] = playerData
	end
	
	-- Update violation data
	playerData.TotalScore = playerData.TotalScore + violation.Score
	playerData.Violations[violationType] = (playerData.Violations[violationType] or 0) + 1
	playerData.LastViolation = tick()
	
	-- Log to console
	if CONFIG.LOG_TO_CONSOLE then
		local logMessage = string.format(
			"[CheaterManagement] %s (%d) - %s (Score: +%d, Total: %d)%s",
			player.Name,
			userId,
			violation.Name,
			violation.Score,
			playerData.TotalScore,
			details and (" - " .. details) or ""
		)
		warn(logMessage)
	end
	
	-- Check for punishment
	checkPunishment(player, playerData)
end

-- Check if player should be punished
local function checkPunishment(player: Player, playerData: {[string]: any})
	local score = playerData.TotalScore
	
	-- Already banned
	if playerData.IsBanned and playerData.BanUntil and tick() < playerData.BanUntil then
		-- Ban still active, kick if they somehow got back in
		player:Kick("You are banned. Reason: Multiple violations detected.")
		return
	elseif playerData.IsBanned then
		-- Ban expired
		playerData.IsBanned = false
		playerData.BanUntil = nil
	end
	
	-- Check thresholds
	if score >= PunishmentThresholds.BAN_PERMANENT then
		banPlayer(player, playerData, -1, "Permanent ban: Excessive violations")
	elseif score >= PunishmentThresholds.BAN_LONG then
		banPlayer(player, playerData, 7 * 24 * 3600, "7 day ban: Multiple serious violations")
	elseif score >= PunishmentThresholds.BAN_MEDIUM then
		banPlayer(player, playerData, 24 * 3600, "24 hour ban: Serious violations detected")
	elseif score >= PunishmentThresholds.BAN_SHORT then
		banPlayer(player, playerData, 3600, "1 hour ban: Violations detected")
	elseif score >= PunishmentThresholds.KICK then
		kickPlayer(player, playerData, "Kicked: Multiple violations detected")
	elseif score >= PunishmentThresholds.WARNING and playerData.Warnings == 0 then
		warnPlayer(player, playerData, "Warning: Suspicious activity detected")
	end
end

-- Warn player
local function warnPlayer(player: Player, playerData: {[string]: any}, message: string)
	playerData.Warnings = playerData.Warnings + 1
	
	-- Send warning message to player (don't kick on first warning)
	-- TODO: Create warning UI notification that shows on screen
	-- For now, just log it
	if CONFIG.LOG_TO_CONSOLE then
		print(string.format("[CheaterManagement] Warned %s (%d) - %s (Warning #%d)", 
			player.Name, player.UserId, message, playerData.Warnings))
	end
	
	-- Only kick if multiple warnings
	if playerData.Warnings >= 3 then
		player:Kick("Multiple warnings: " .. message)
	end
end

-- Kick player
local function kickPlayer(player: Player, playerData: {[string]: any}, reason: string)
	playerData.Kicks = playerData.Kicks + 1
	player:Kick(reason)
	
	if CONFIG.LOG_TO_CONSOLE then
		print(string.format("[CheaterManagement] Kicked %s (%d) - %s", player.Name, player.UserId, reason))
	end
end

-- Ban player
local function banPlayer(player: Player, playerData: {[string]: any}, duration: number, reason: string)
	playerData.Bans = playerData.Bans + 1
	playerData.IsBanned = true
	
	if duration > 0 then
		playerData.BanUntil = tick() + duration
	else
		playerData.BanUntil = -1 -- Permanent
	end
	
	-- TODO: Save ban to DataStore for persistence across servers
	-- For now, just kick
	local banMessage = reason
	if duration > 0 then
		local hours = math.floor(duration / 3600)
		banMessage = banMessage .. string.format(" (Banned for %d hour%s)", hours, hours ~= 1 and "s" or "")
	else
		banMessage = banMessage .. " (Permanent ban)"
	end
	
	player:Kick(banMessage)
	
	if CONFIG.LOG_TO_CONSOLE then
		print(string.format("[CheaterManagement] Banned %s (%d) - %s", player.Name, player.UserId, banMessage))
	end
end

-- Speed hack detection
local function detectSpeedHack(player: Player)
	local character = player.Character
	if not character then return end
	
	local rootPart = character:FindFirstChild("HumanoidRootPart")
	local humanoid = character:FindFirstChild("Humanoid")
	if not rootPart or not humanoid then return end
	
	local userId = player.UserId
	local positionData = playerPositions[userId]
	
	if not positionData then
		positionData = {
			LastPosition = rootPart.Position,
			LastTime = tick(),
			VelocityHistory = {},
		}
		playerPositions[userId] = positionData
		return
	end
	
	local currentTime = tick()
	local timeDelta = currentTime - positionData.LastTime
	
	if timeDelta < CONFIG.SPEED_CHECK_INTERVAL then return end
	
	local currentPosition = rootPart.Position
	local distance = (currentPosition - positionData.LastPosition).Magnitude
	local speed = distance / timeDelta
	
	-- Track velocity history
	table.insert(positionData.VelocityHistory, speed)
	if #positionData.VelocityHistory > 10 then
		table.remove(positionData.VelocityHistory, 1)
	end
	
	-- Check for speed hack
	if speed > CONFIG.MAX_SPEED then
		-- Check if it's a teleport (instant movement)
		if speed > CONFIG.TELEPORT_THRESHOLD / timeDelta then
			logViolation(player, "TELEPORT", string.format("Speed: %.2f studs/s", speed))
		else
			logViolation(player, "SPEED_HACK", string.format("Speed: %.2f studs/s (Max: %.2f)", speed, CONFIG.MAX_SPEED))
		end
	end
	
	-- Update position tracking
	positionData.LastPosition = currentPosition
	positionData.LastTime = currentTime
end

-- Fly hack detection
local function detectFlyHack(player: Player)
	local character = player.Character
	if not character then return end
	
	local humanoid = character:FindFirstChild("Humanoid")
	local rootPart = character:FindFirstChild("HumanoidRootPart")
	if not humanoid or not rootPart then return end
	
	-- Check if player is in air for too long without falling
	if humanoid.FloorMaterial == Enum.Material.Air then
		local velocity = rootPart.AssemblyLinearVelocity
		
		-- If player is moving upward or hovering (not falling)
		if velocity.Y > 0 or (velocity.Y > -5 and velocity.Magnitude < 5) then
			-- Check how long they've been in air
			-- This is a simplified check - could be improved
			local state = MovementValidationService.GetPlayerState(player)
			if state ~= "Jump" and state ~= "Freefall" then
				-- Suspicious: in air but not in jump/fall state
				logViolation(player, "FLY_HACK", "Hovering or flying detected")
			end
		end
	end
end

-- No-clip detection (simplified)
local function detectNoClip(player: Player)
	local character = player.Character
	if not character then return end
	
	local rootPart = character:FindFirstChild("HumanoidRootPart")
	if not rootPart then return end
	
	-- Raycast downward to check if player is inside geometry
	local raycastParams = RaycastParams.new()
	raycastParams.FilterDescendantsInstances = {character}
	raycastParams.FilterType = Enum.RaycastFilterType.Blacklist
	
	local raycast = workspace:Raycast(rootPart.Position, Vector3.new(0, -10, 0), raycastParams)
	
	-- If no ground hit and player is "on ground", might be no-clipping
	-- This is a basic check - could be improved with more sophisticated detection
end

-- Violation decay system (reduce scores over time for minor violations)
local function decayViolations()
	for userId, playerData in pairs(playerViolations) do
		local timeSinceLastViolation = tick() - playerData.LastViolation
		
		if timeSinceLastViolation > CONFIG.VIOLATION_DECAY_TIME then
			-- Decay violations
			playerData.TotalScore = math.max(0, playerData.TotalScore * (1 - CONFIG.VIOLATION_DECAY_RATE))
			
			-- Reset if score is very low
			if playerData.TotalScore < 5 then
				playerData.TotalScore = 0
			end
		end
	end
end

-- Public API: Report violation from other services
function CheaterManagementService.ReportViolation(player: Player, violationType: string, details: string?)
	if not player or not player.Parent then return end
	
	local violation = ViolationTypes[violationType]
	if not violation then
		warn("[CheaterManagementService] Unknown violation type: " .. tostring(violationType))
		return
	end
	
	logViolation(player, violationType, details)
end

-- Public API: Get player violation data
function CheaterManagementService.GetPlayerData(player: Player): {[string]: any}?
	return playerViolations[player.UserId]
end

-- Public API: Check if player is banned
function CheaterManagementService.IsPlayerBanned(player: Player): boolean
	local playerData = playerViolations[player.UserId]
	if not playerData then return false end
	
	if playerData.IsBanned then
		if playerData.BanUntil == -1 then
			return true -- Permanent ban
		elseif playerData.BanUntil and tick() < playerData.BanUntil then
			return true -- Temporary ban still active
		else
			-- Ban expired
			playerData.IsBanned = false
			playerData.BanUntil = nil
			return false
		end
	end
	
	return false
end

-- Public API: Manually ban a player (for admins)
function CheaterManagementService.BanPlayer(player: Player, duration: number, reason: string)
	local userId = player.UserId
	local playerData = playerViolations[userId]
	
	if not playerData then
		playerData = {
			TotalScore = 0,
			Violations = {},
			FirstViolation = tick(),
			LastViolation = tick(),
			Warnings = 0,
			Kicks = 0,
			Bans = 0,
			IsBanned = false,
			BanUntil = nil,
		}
		playerViolations[userId] = playerData
	end
	
	banPlayer(player, playerData, duration, reason)
end

-- Start monitoring a player
local function startMonitoring(player: Player)
	task.spawn(function()
		while player.Parent and player.Character do
			detectSpeedHack(player)
			detectFlyHack(player)
			detectNoClip(player)
			
			task.wait(CONFIG.POSITION_CHECK_INTERVAL)
		end
	end)
end

-- Initialize service
function CheaterManagementService.Init()
	local Players = game:GetService("Players")
	
	-- Check existing players for bans
	for _, player in ipairs(Players:GetPlayers()) do
		if CheaterManagementService.IsPlayerBanned(player) then
			player:Kick("You are banned from this game.")
		else
			-- Start monitoring existing players
			if player.Character then
				startMonitoring(player)
			end
			player.CharacterAdded:Connect(function()
				startMonitoring(player)
			end)
		end
	end
	
	-- Monitor new players
	Players.PlayerAdded:Connect(function(player)
		-- Check if banned
		if CheaterManagementService.IsPlayerBanned(player) then
			player:Kick("You are banned from this game.")
			return
		end
		
		-- Start monitoring
		if player.Character then
			startMonitoring(player)
		end
		player.CharacterAdded:Connect(function()
			startMonitoring(player)
		end)
	end)
	
	-- Start violation decay loop
	RunService.Heartbeat:Connect(function()
		decayViolations()
	end)
	
	print("[CheaterManagementService] Initialized - Anti-cheat system active")
end

return CheaterManagementService
