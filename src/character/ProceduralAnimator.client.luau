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
local rootPart = char:WaitForChild("HumanoidRootPart")

local originalNeckC0 = neck.C0

-- Utils
local Spring = require(ReplicatedStorage:WaitForChild("Utils"):WaitForChild("Spring"))

-- Springs
local headSpring = Spring.new(Vector3.zero)
headSpring.Damper = 0.8
headSpring.Speed = 8

local ProceduralAnimator = {}

function ProceduralAnimator.Start()
	-- Using PreRender instead of deprecated RenderStepped (per documentation)
	local isFirstFrame = true
	
	local lastStepTime = 0
	
	RunService.PreRender:Connect(function(dt)
		-- Safety / Lag Protection
		if dt > 0.1 then dt = 0.016 end
		
		local inMenu = player:GetAttribute("InMenu")
		
		-- 1. Stepped Rotation (Flank Tracking)
		if inMenu then
			local targetAngle = player:GetAttribute("TurnToAngle")
			local requestTime = player:GetAttribute("TurnRequestTime") or 0
			
			-- Natural Latency: Wait 0.7 seconds before reacting
			if targetAngle and (tick() - requestTime > 0.7) then
				local _, pY, _ = rootPart.CFrame:ToOrientation()
				local currentRot = math.deg(pY)
				
				local diff = targetAngle - currentRot
				diff = (diff + 180) % 360 - 180
				
				if math.abs(diff) > 2 then
					-- Slower mechanical steps (0.18s interval)
					if tick() - lastStepTime > 0.18 then
						lastStepTime = tick()
						
						local stepSize = math.min(45, math.abs(diff))
						local direction = math.sign(diff)
						local newRot = currentRot + (stepSize * direction)
						
						-- Apply strictly on Y
						rootPart.CFrame = CFrame.new(rootPart.Position) * CFrame.fromOrientation(0, math.rad(newRot), 0)
					end
				end
			end
		end

		-- 2. Head Look-At (Drone Tracking)
		if inMenu and Workspace.CurrentCamera then
			local camPos = Workspace.CurrentCamera.CFrame.Position
			
			-- Calculate local goal for neck relative to UpperTorso
			local relativePos = upperTorso.CFrame:PointToObjectSpace(camPos)
			
			-- Standard look-at math
			local targetAngleY = math.atan2(-relativePos.X, -relativePos.Z)
			local targetAngleX = math.atan2(relativePos.Y, math.sqrt(relativePos.X^2 + relativePos.Z^2))
			
			-- Clamp angles to prevent exorcist head turns (70 degrees max)
			targetAngleY = math.clamp(targetAngleY, -math.rad(70), math.rad(70))
			targetAngleX = math.clamp(targetAngleX, -math.rad(40), math.rad(40))
			
			-- NaN Check
			if targetAngleY ~= targetAngleY or targetAngleX ~= targetAngleX then
				return 
			end
			
			local targetVec = Vector3.new(targetAngleX, targetAngleY, 0)
			
			-- Snap on first frame to prevent rubberbanding
			if isFirstFrame or (headSpring.Position - targetVec).Magnitude > 2 then
				headSpring.Position = targetVec
				headSpring.Velocity = Vector3.zero
				isFirstFrame = false
			end
			
			headSpring.Target = targetVec
		else
			headSpring.Target = Vector3.zero
		end
		
		local currentHeadRotation = headSpring:Update(dt)
		if currentHeadRotation.X == currentHeadRotation.X then -- NaN check result
			neck.C0 = originalNeckC0 * CFrame.Angles(currentHeadRotation.X, currentHeadRotation.Y, 0)
		end
	end)
end

task.spawn(ProceduralAnimator.Start)

print("[ProceduralAnimator] Initialized for " .. char.Name)
return ProceduralAnimator
