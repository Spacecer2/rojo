local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local char = script.Parent
local player = Players.LocalPlayer

-- Wait for joints safely
local humanoid = char:WaitForChild("Humanoid")
local head = char:WaitForChild("Head")
local neck = head:WaitForChild("Neck")
local upperTorso = char:WaitForChild("UpperTorso")

local originalNeckC0 = neck.C0

-- Utils
local Spring = require(ReplicatedStorage:WaitForChild("Utils"):WaitForChild("Spring"))

-- Springs
local headSpring = Spring.new(Vector3.zero)
headSpring.Damper = 0.8
headSpring.Speed = 8

local ProceduralAnimator = {}

function ProceduralAnimator.Start()
	RunService.RenderStepped:Connect(function(dt)
		local inMenu = player:GetAttribute("InMenu")
		
		-- 1. Head Look-At (Drone Tracking)
		if inMenu then
			local camPos = Workspace.CurrentCamera.CFrame.Position
			
			-- Calculate local goal for neck relative to UpperTorso
			local relativePos = upperTorso.CFrame:PointToObjectSpace(camPos)
			
			-- Standard look-at math
			local targetAngleY = math.atan2(-relativePos.X, -relativePos.Z)
			local targetAngleX = math.atan2(relativePos.Y, math.sqrt(relativePos.X^2 + relativePos.Z^2))
			
			-- Clamp angles to prevent exorcist head turns (70 degrees max)
			targetAngleY = math.clamp(targetAngleY, -math.rad(70), math.rad(70))
			targetAngleX = math.clamp(targetAngleX, -math.rad(40), math.rad(40))
			
			headSpring.Target = Vector3.new(targetAngleX, targetAngleY, 0)
		else
			headSpring.Target = Vector3.zero
		end
		
		local currentHeadRotation = headSpring:Update(dt)
		neck.C0 = originalNeckC0 * CFrame.Angles(currentHeadRotation.X, currentHeadRotation.Y, 0)
	end)
end

task.spawn(ProceduralAnimator.Start)

print("[ProceduralAnimator] Initialized for " .. char.Name)
return ProceduralAnimator
