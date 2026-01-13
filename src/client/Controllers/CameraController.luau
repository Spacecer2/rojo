local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Modules
local Spring = require(ReplicatedStorage:WaitForChild("Utils"):WaitForChild("Spring"))

local CameraController = {}

local camera = Workspace.CurrentCamera
local player = Players.LocalPlayer

-- Configuration for "Stalker Drone"
local CONFIG = {
	SwaySpeed = 0.4,
	SwayIntensity = 6.25,
	HeightOffset = 10,
	MinDistance = 15,
	MaxDistance = 35,
	LookAheadFactor = 0.8,
	MaxRotationArc = math.rad(180),
}

-- Physics Springs
local posSpring = Spring.new(Vector3.zero)
posSpring.Damper = 0.65
posSpring.Speed = 4

local lookSpring = Spring.new(Vector3.zero)
lookSpring.Damper = 0.8
lookSpring.Speed = 6

local distSpring = Spring.new(CONFIG.MaxDistance)
distSpring.Damper = 0.8
distSpring.Speed = 1 

local connection = nil

function CameraController.Init()
	player:GetAttributeChangedSignal("InMenu"):Connect(function()
		local inMenu = player:GetAttribute("InMenu")
		if inMenu then
			CameraController.EnableMenuCamera()
		else
			CameraController.DisableMenuCamera()
		end
	end)
end

function CameraController.EnableMenuCamera()
	camera.CameraType = Enum.CameraType.Scriptable
	
	if connection then connection:Disconnect() end
	
	connection = RunService.RenderStepped:Connect(function(dt)
		local character = player.Character
		if not character then return end
		local rootPart = character:FindFirstChild("HumanoidRootPart")
		if not rootPart then return end
		
		local t = tick()
		local velocity = rootPart.AssemblyLinearVelocity
		
		-- First-frame snap / Respawn reset
		if (posSpring.Position - rootPart.Position).Magnitude > 200 or posSpring.Position.Magnitude < 1 then
			posSpring.Position = rootPart.Position + Vector3.new(0, 15, 30)
			lookSpring.Position = rootPart.Position
			distSpring.Position = CONFIG.MaxDistance
		end
		
		-- 1. Dynamic Distance (Breathing)
		local distNoise = (math.sin(t * 0.2) + math.cos(t * 0.13) * 0.5) / 1.5
		local targetDist = CONFIG.MinDistance + ((distNoise + 1) / 2) * (CONFIG.MaxDistance - CONFIG.MinDistance)
		distSpring.Target = targetDist
		local currentDist = distSpring:Update(dt)
		
		-- 2. Calculate Target Position within a 180 degree arc
		local baseAngle = math.atan2(rootPart.CFrame.LookVector.X, rootPart.CFrame.LookVector.Z)
		local swayAngle = math.sin(t * CONFIG.SwaySpeed) * (CONFIG.MaxRotationArc / 2)
		local finalAngle = baseAngle + swayAngle
		
		local x = math.sin(finalAngle) * currentDist
		local z = math.cos(finalAngle) * currentDist
		local y = CONFIG.HeightOffset + math.sin(t * CONFIG.SwaySpeed * 2) * 4
		
		local targetPos = rootPart.Position + Vector3.new(x, y, z)
		
		-- 3. Stalking / Look-Ahead Logic
		local lookAhead = velocity * CONFIG.LookAheadFactor
		local stalkTarget = rootPart.Position + Vector3.new(0, 3, 0) + lookAhead
		
		-- 4. Update Springs
		posSpring.Target = targetPos
		lookSpring.Target = stalkTarget
		
		local currentPos = posSpring:Update(dt)
		local currentLook = lookSpring:Update(dt)
		
		-- 5. Apply CFrame with Drone Tilt
		local roll = math.sin(t * CONFIG.SwaySpeed * 1.5) * 0.08
		local baseCFrame = CFrame.new(currentPos, currentLook)
		camera.CFrame = baseCFrame * CFrame.Angles(0, 0, roll)
	end)
end

function CameraController.DisableMenuCamera()
	if connection then
		connection:Disconnect()
		connection = nil
	end
	camera.CameraType = Enum.CameraType.Custom
end

function CameraController.Start()
	if player:GetAttribute("InMenu") then
		CameraController.EnableMenuCamera()
	end
end

return CameraController