local Players = game:GetService("Players")

-- Character setup
local char = script.Parent
local humanoid = char:WaitForChild("Humanoid")
local animator = humanoid:WaitForChild("Animator")

-- Wait for modules
local function safeRequire(name)
	local module = char:WaitForChild(name, 5)
	if module then
		return require(module)
	else
		warn("Could not find module: " .. name)
		return nil
	end
end

local Config = safeRequire("Config")

if not Config then
	warn("AnimationController failed to load Config.")
	return
end

-- State
local loadedAnimations = {}
local currentTrack = nil

-- Utility to load animation
local function getAnimation(id)
	if id == "" or id == nil or id == "rbxassetid://" then return nil end
	local anim = Instance.new("Animation")
	anim.AnimationId = id
	return anim
end

-- Initialize Animations
if Config.Animations then
	for name, id in pairs(Config.Animations) do
		local animInstance = getAnimation(id)
		if animInstance then
			local success, track = pcall(function()
				return animator:LoadAnimation(animInstance)
			end)
			
			if success then
				loadedAnimations[name] = track
				-- Set Priorities
				if name == "Idle" then
					track.Priority = Enum.AnimationPriority.Idle
				elseif name == "Action" or name == "Jump" or name == "Fall" then
					track.Priority = Enum.AnimationPriority.Action
				else
					track.Priority = Enum.AnimationPriority.Movement
				end
			end
		end
	end
end

-- Function to play animation based on state
local function playAnimation(animName, fadeTime, speed)
	fadeTime = fadeTime or 0.2
	speed = speed or 1
	
	local track = loadedAnimations[animName]
	if not track then return end
	
	if currentTrack == track then
		return 
	end
	
	if currentTrack then
		currentTrack:Stop(fadeTime)
	end
	
	track:Play(fadeTime)
	track:AdjustSpeed(speed)
	currentTrack = track
end

-- Listen for State Changes via Attribute (set by MovementController)
char:GetAttributeChangedSignal("MovementState"):Connect(function()
	local newState = char:GetAttribute("MovementState")
	
	if newState == "Idle" then
		playAnimation("Idle", 0.3)
	elseif newState == "Walk" then
		playAnimation("Walk", 0.2)
	elseif newState == "Run" then
		playAnimation("Run", 0.2)
	elseif newState == "Sprint" then
		playAnimation("Sprint", 0.3, 1.2)
	elseif newState == "Crouch" then
		playAnimation("Crouch", 0.3)
	elseif newState == "Jump" then
		playAnimation("Jump", 0.1)
	elseif newState == "Freefall" then
		playAnimation("Fall", 0.3)
	end
end)

-- Initial check
local initialState = char:GetAttribute("MovementState") or "Idle"
playAnimation(initialState)

print("Animation Controller Initialized")