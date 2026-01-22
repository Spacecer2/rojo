--[[
	GasController - Client-side gas visualization and effects
	Renders the gas dome and applies screen distortion.
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")
local Players = game:GetService("Players")

local Network = require(ReplicatedStorage.Framework.Network)
local GasConfig = require(ReplicatedStorage.Constants.GasConfig)

local GasController = {
	TargetCenter = Vector3.new(0, 0, 0),
	CurrentCenter = Vector3.new(0, 0, 0),
	TargetRadius = 2000,
	CurrentRadius = 2000,
	
	GasDome = nil,
	Blur = nil,
	ColorCorrection = nil,
}

function GasController:Init()
	-- Create Gas Dome
	local dome = Instance.new("Part")
	dome.Name = "GasDome"
	dome.Shape = Enum.PartType.Ball
	dome.Anchored = true
	dome.CanCollide = false
	dome.CanQuery = false
	dome.CastShadow = false
	dome.Color = GasConfig.VISUALS.BoundaryColor
	dome.Transparency = GasConfig.VISUALS.GasTransparency
	dome.Material = Enum.Material.ForceField
	dome.Size = Vector3.new(GasController.CurrentRadius * 2, GasController.CurrentRadius * 2, GasController.CurrentRadius * 2)
	dome.CFrame = CFrame.new(GasController.CurrentCenter)
	dome.Parent = workspace
	GasController.GasDome = dome
	
	-- Post-processing
	local blur = Instance.new("BlurEffect")
	blur.Size = 0
	blur.Parent = Lighting
	GasController.Blur = blur
	
	local cc = Instance.new("ColorCorrectionEffect")
	cc.TintColor = Color3.new(1, 1, 1)
	cc.Parent = Lighting
	GasController.ColorCorrection = cc
	
	-- Listen for server updates
	Network.OnClientEvent("GasUpdate", function(data)
		GasController.TargetCenter = data.Center
		GasController.TargetRadius = data.Radius
		-- We can also use data.TimeRemaining and data.State for HUD updates
	end)
	
	-- Render Loop
	RunService.Heartbeat:Connect(function(dt)
		self:Update(dt)
	end)
end

function GasController:Update(dt)
	-- Smooth Lerp
	GasController.CurrentCenter = GasController.CurrentCenter:Lerp(GasController.TargetCenter, dt * 5)
	GasController.CurrentRadius = GasController.CurrentRadius + (GasController.TargetRadius - GasController.CurrentRadius) * dt * 5
	
	if GasController.GasDome then
		GasController.GasDome.CFrame = CFrame.new(GasController.CurrentCenter)
		GasController.GasDome.Size = Vector3.new(GasController.CurrentRadius * 2, GasController.CurrentRadius * 2, GasController.CurrentRadius * 2)
	end
	
	-- Distance-based effects
	local player = Players.LocalPlayer
	local char = player.Character
	if char and char:FindFirstChild("HumanoidRootPart") then
		local pos = char.HumanoidRootPart.Position
		local distToCenter = (Vector3.new(pos.X, 0, pos.Z) - Vector3.new(GasController.CurrentCenter.X, 0, GasController.CurrentCenter.Z)).Magnitude
		
		local distFromEdge = distToCenter - GasController.CurrentRadius
		
		if distFromEdge > 0 then
			-- Inside Gas (or rather, outside circle)
			local intensity = math.clamp(distFromEdge / GasConfig.VISUALS.DistortionRange, 0, 1)
			GasController.Blur.Size = 2 + (intensity * 10)
			GasController.ColorCorrection.TintColor = Color3.new(1, 1 - (intensity * 0.5), 1)
			GasController.ColorCorrection.Saturation = -intensity * 0.5
		else
			-- Outside Gas (safe zone)
			local intensity = math.clamp((GasConfig.VISUALS.DistortionRange + distFromEdge) / GasConfig.VISUALS.DistortionRange, 0, 1)
			if distFromEdge > -GasConfig.VISUALS.DistortionRange then
				-- Near the edge
				GasController.Blur.Size = intensity * 2
				GasController.ColorCorrection.TintColor = Color3.new(1, 1, 1)
			else
				GasController.Blur.Size = 0
				GasController.ColorCorrection.Saturation = 0
			end
		end
	end
end

return GasController
