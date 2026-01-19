local run = game:GetService("RunService")
local cam = game.Workspace.CurrentCamera
local plr = game.Players.LocalPlayer

local arms = nil
local renderConnection = nil
local attributeConnection = nil

local function cleanupArms()
	if renderConnection then
		renderConnection:Disconnect()
		renderConnection = nil
	end
	
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
	local replicatedStorage = game:GetService("ReplicatedStorage")
	local assetsFolder = replicatedStorage:WaitForChild("Assets", 5)
	local armsTemplate = assetsFolder and assetsFolder:FindFirstChild("Arms")
		or replicatedStorage:FindFirstChild("Arms")
	
	if not armsTemplate then
		warn("[FPS Arms] Missing Arms model. Import Arms.rbxm into src/shared/Assets.")
		return
	end

	arms = armsTemplate:Clone()
	if not ensurePrimaryPart(arms) then
		warn("[FPS Arms] Arms model has no BasePart. Add a MeshPart or Part and set PrimaryPart.")
		arms:Destroy()
		arms = nil
		return
	end
	arms.Parent = cam
	
	-- Set camera mode to first person
	plr.CameraMode = Enum.CameraMode.LockFirstPerson
	
	-- Start render loop
	renderConnection = run.RenderStepped:Connect(function()
		if arms and cam then
			arms:SetPrimaryPartCFrame(cam.CFrame * CFrame.new(0, 1, 0))
		end
	end)
	
	print("[FPS Arms] Activated")
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