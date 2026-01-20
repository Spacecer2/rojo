local run = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local cam = game.Workspace.CurrentCamera
local plr = game:GetService("Players").LocalPlayer

-- Dependencies
local SharedState = require(plr.PlayerScripts:WaitForChild("SharedState"))
local Spring = require(ReplicatedStorage:WaitForChild("Utils"):WaitForChild("Spring"))

-- State
local arms = nil
local currentWeapon = nil
local renderConnection = nil
local attributeConnection = nil
local weaponAttributeConnection = nil

-- Procedural Animation State
local swaySpring = Spring.new(Vector3.zero)
swaySpring.Speed = 12
swaySpring.Damper = 0.5

local bobSpring = Spring.new(Vector3.zero)
bobSpring.Speed = 8
bobSpring.Damper = 0.5

local lastCamCFrame = cam.CFrame

local function cleanupWeapon()
	if currentWeapon then
		currentWeapon:Destroy()
		currentWeapon = nil
	end
end

local function cleanupArms()
	if renderConnection then
		renderConnection:Disconnect()
		renderConnection = nil
	end
	
	if attributeConnection then
		attributeConnection:Disconnect()
		attributeConnection = nil
	end
	
	if weaponAttributeConnection then
		weaponAttributeConnection:Disconnect()
		weaponAttributeConnection = nil
	end
	
	cleanupWeapon()
	
	if arms then
		arms:Destroy()
		arms = nil
	end
	
	local existing = cam:FindFirstChild("Arms")
	if existing then
		existing:Destroy()
	end
	
	print("[FPS Arms] Cleaned up")
end

local function equipWeapon(weaponName)
	cleanupWeapon()
	if not arms then return end
	
	local weaponsFolder = ReplicatedStorage:WaitForChild("Assets"):WaitForChild("Weapons")
	local weaponTemplate = weaponsFolder:FindFirstChild(weaponName)
	
	if not weaponTemplate then
		warn("[FPS Arms] Missing weapon model for: " .. weaponName)
		return
	end
	
	currentWeapon = weaponTemplate:Clone()
	currentWeapon.Parent = arms
	
	-- Weld to Right Arm
	local rightArm = arms:FindFirstChild("Right Arm") or arms:FindFirstChild("RightHand")
	if rightArm then
		local handle = currentWeapon:FindFirstChild("Handle") or currentWeapon.PrimaryPart
		if handle then
			local weld = Instance.new("Motor6D")
			weld.Name = "WeaponWeld"
			weld.Part0 = rightArm
			weld.Part1 = handle
			-- Standard offset (adjust per model)
			weld.C0 = CFrame.new(0, -1, -0.5) * CFrame.Angles(math.rad(-90), 0, 0)
			weld.Parent = handle
		end
	end
	
	print("[FPS Arms] Equipped: " .. weaponName)
end

local function updateViewmodel(dt)
	if not arms or not cam then return end
	
	-- 1. Calculate Camera Delta for Sway
	local camRot = cam.CFrame:ToOrientation()
	local lastRot = lastCamCFrame:ToOrientation()
	local delta = Vector3.new(camRot - lastRot) -- Pitch, Yaw, Roll deltas
	lastCamCFrame = cam.CFrame
	
	-- Shove sway spring
	swaySpring:Shove(Vector3.new(delta.Y * 20, delta.X * 20, 0))
	local sway = swaySpring:Update(dt)
	
	-- 2. Calculate Bobbing based on Movement State
	local moveState = plr.Character and plr.Character:GetAttribute("MovementState") or "Idle"
	local bobTarget = Vector3.zero
	
	if moveState ~= "Idle" and moveState ~= "ADS" then
		local speedMult = (moveState == "Sprint" or moveState == "TacticalSprint") and 1.5 or 1.0
		local t = tick() * 10 * speedMult
		bobTarget = Vector3.new(
			math.cos(t * 0.5) * 0.05,
			math.abs(math.sin(t)) * 0.05,
			0
		)
	end
	bobSpring.Target = bobTarget
	local bob = bobSpring:Update(dt)
	
	-- 3. Apply final CFrame
	-- Position viewmodel slightly in front and down from camera
	local baseOffset = CFrame.new(0.2, -1.2, -0.5)
	local swayCF = CFrame.Angles(math.rad(sway.Y), math.rad(sway.X), math.rad(sway.X * 0.5))
	local bobCF = CFrame.new(bob.X, bob.Y, 0)
	
	arms:SetPrimaryPartCFrame(cam.CFrame * baseOffset * swayCF * bobCF)
end

local function startArms()
	if arms then
		print("[FPS Arms] Already active")
		return
	end
	
	local function ensurePrimaryPart(model)
		if model.PrimaryPart then
			return true
		end
		local part = model:FindFirstChildWhichIsA("BasePart", true)
		if part then
			model.PrimaryPart = part
			return true
		end
		return false
	end
	
	-- Clone and setup arms
	local assetsFolder = ReplicatedStorage:WaitForChild("Assets", 5)
	local armsTemplate = assetsFolder and assetsFolder:FindFirstChild("Arms")
	
	if not armsTemplate then
		warn("[FPS Arms] Missing Arms model.")
		return
	end

	arms = armsTemplate:Clone()
	if not ensurePrimaryPart(arms) then
		warn("[FPS Arms] Arms model has no BasePart.")
		arms:Destroy()
		arms = nil
		return
	end
	arms.Parent = cam
	
	-- Initial weapon
	local weapon = plr:GetAttribute("EquippedWeapon") or "M4"
	equipWeapon(weapon)
	
	-- Set camera mode
	plr.CameraMode = Enum.CameraMode.LockFirstPerson
	
	-- Start render loop
	renderConnection = run.RenderStepped:Connect(updateViewmodel)
	
	-- Listen for weapon changes
	weaponAttributeConnection = plr:GetAttributeChangedSignal("EquippedWeapon"):Connect(function()
		equipWeapon(plr:GetAttribute("EquippedWeapon"))
	end)
	
	print("[FPS Arms] Activated with Weapon Support")
end

-- Listen for InMenu attribute changes
attributeConnection = plr:GetAttributeChangedSignal("InMenu"):Connect(function()
	if plr:GetAttribute("InMenu") == false then
		startArms()
	else
		cleanupArms()
	end
end)

print("[FPS Arms] Controller initialized")