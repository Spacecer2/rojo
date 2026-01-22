--[[
	GasService - Server-side circle management
	Handles phase timing, contraction logic, and player damage.
]]

local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Network = require(ReplicatedStorage.Framework.Network)
local GasConfig = require(ReplicatedStorage.Constants.GasConfig)

local GasService = {
	CurrentPhase = 0,
	State = "Waiting", -- "Waiting", "Contracting", "Finished"
	
	CurrentCenter = Vector3.new(0, 0, 0),
	TargetCenter = Vector3.new(0, 0, 0),
	
	CurrentRadius = 2000, -- Start huge
	TargetRadius = 2000,
	StartRadius = 2000,
	
	TimeRemaining = 0,
	PhaseStartTime = 0,
}

function GasService.Init()
	-- Initialization logic
	GasService.CurrentRadius = GasConfig.PHASES[1].Radius * 2
	GasService.TargetRadius = GasConfig.PHASES[1].Radius * 2
	
	-- Damage Loop
	task.spawn(function()
		while true do
			task.wait(1) -- Damage ticks every second
			GasService.ApplyGasDamage()
		end
	end)
	
	-- Sync Loop
	RunService.Heartbeat:Connect(function(dt)
		GasService.Update(dt)
	end)
end

function GasService.StartMatch()
	print("[GasService] Starting Gas Sequence...")
	task.spawn(function()
		task.wait(GasConfig.START_DELAY)
		GasService.StartNextPhase()
	end)
end

function GasService.Update(dt)
	local now = tick()
	
	if GasService.State == "Contracting" then
		local elapsed = now - GasService.PhaseStartTime
		local duration = GasConfig.PHASES[GasService.CurrentPhase].ContractDuration
		local alpha = math.clamp(elapsed / duration, 0, 1)
		
		-- Smooth lerp for radius and center
		GasService.CurrentRadius = GasService.StartRadius + (GasService.TargetRadius - GasService.StartRadius) * alpha
		GasService.CurrentCenter = GasService.StartCenter:Lerp(GasService.TargetCenter, alpha)
		
		GasService.TimeRemaining = math.max(0, duration - elapsed)
		
		if alpha >= 1 then
			GasService.State = "Waiting"
			GasService.PhaseStartTime = tick()
			GasService.TimeRemaining = GasConfig.PHASES[GasService.CurrentPhase].WaitDuration
		end
	elseif GasService.State == "Waiting" then
		local elapsed = now - GasService.PhaseStartTime
		local duration = GasConfig.PHASES[GasService.CurrentPhase] and GasConfig.PHASES[GasService.CurrentPhase].WaitDuration or 0
		
		GasService.TimeRemaining = math.max(0, duration - elapsed)
		
		if GasService.CurrentPhase > 0 and elapsed >= duration then
			GasService.StartNextPhase()
		end
	end
	
	-- Broadcast state to clients
	Network.FireAllClients("GasUpdate", {
		Center = GasService.CurrentCenter,
		Radius = GasService.CurrentRadius,
		Phase = GasService.CurrentPhase,
		State = GasService.State,
		TimeRemaining = GasService.TimeRemaining
	})
end

function GasService.StartNextPhase()
	GasService.CurrentPhase += 1
	local phaseData = GasConfig.PHASES[GasService.CurrentPhase]
	
	if not phaseData then
		GasService.State = "Finished"
		return
	end
	
	GasService.State = "Contracting"
	GasService.PhaseStartTime = tick()
	
	GasService.StartRadius = GasService.CurrentRadius
	GasService.TargetRadius = phaseData.Radius
	
	GasService.StartCenter = GasService.CurrentCenter
	-- Pick a random point within the current radius for the next center
	local angle = math.random() * math.pi * 2
	local r = math.random() * (GasService.CurrentRadius - phaseData.Radius)
	GasService.TargetCenter = GasService.CurrentCenter + Vector3.new(math.cos(angle) * r, 0, math.sin(angle) * r)
	
	print(string.format("[GasService] Phase %d started. Target Radius: %d", GasService.CurrentPhase, phaseData.Radius))
end

function GasService.ApplyGasDamage()
	local phaseData = GasConfig.PHASES[GasService.CurrentPhase]
	local damage = phaseData and phaseData.Damage or 0
	if damage <= 0 then return end
	
	for _, player in ipairs(Players:GetPlayers()) do
		local char = player.Character
		if not char then continue end
		
		local root = char:FindFirstChild("HumanoidRootPart")
		local humanoid = char:FindFirstChild("Humanoid")
		if not root or not humanoid or humanoid.Health <= 0 then continue end
		
		local dist = (Vector3.new(root.Position.X, 0, root.Position.Z) - Vector3.new(GasService.CurrentCenter.X, 0, GasService.CurrentCenter.Z)).Magnitude
		
		if dist > GasService.CurrentRadius then
			humanoid:TakeDamage(damage)
		end
	end
end

return GasService
