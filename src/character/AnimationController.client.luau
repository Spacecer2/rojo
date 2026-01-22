
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

-- State - Support for layered animations (per documentation priority system)
local loadedAnimations = {}
local activeTracks = {
	Base = nil,      -- Idle, Walk, Run (Movement priority)
	Action = nil,    -- Jump, Land, Fall (Action priority)
	Override = nil   -- Future: Slide, Vault (Override priority)
}

-- Utility to load animation
local function getAnimation(id)
	if id == "" or id == nil or id == "rbxassetid://" then return nil end
	local anim = Instance.new("Animation")
	anim.AnimationId = id
	return anim
end

-- Priority mapping per documentation (Low -> High: Idle < Movement < Action < Override)
local function getAnimationPriority(animName)
	if animName == "Idle" then
		return Enum.AnimationPriority.Idle
	elseif animName == "Jump" or animName == "Fall" or animName == "Land" then
		return Enum.AnimationPriority.Action
	elseif animName == "Slide" then
		return Enum.AnimationPriority.Action4 -- Higher priority for override animations
	else
		return Enum.AnimationPriority.Movement
	end
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
				track.Priority = getAnimationPriority(name)
			end
		end
	end
end

-- Function to play animation with proper layering and priority handling
local function playAnimation(animName, fadeTime, speed, layer)
	fadeTime = fadeTime or 0.2
	speed = speed or 1
	layer = layer or "Base" -- Default to base layer
	
	local track = loadedAnimations[animName]
	if not track then return end
	
	-- Determine layer based on priority if not specified
	if not layer then
		local priority = getAnimationPriority(animName)
		if priority == Enum.AnimationPriority.Action or priority == Enum.AnimationPriority.Action4 then
			layer = "Action"
		else
			layer = "Base"
		end
	end
	
	local currentLayerTrack = activeTracks[layer]
	
	-- Don't restart if it's the same track
	if currentLayerTrack == track then
		return
	end
	
	-- Stop previous track on this layer
	if currentLayerTrack then
		currentLayerTrack:Stop(fadeTime)
	end
	
	-- Play new track
	track:Play(fadeTime)
	track:AdjustSpeed(speed)
	activeTracks[layer] = track
end

-- Listen for State Changes via Attribute (set by MovementController)
char:GetAttributeChangedSignal("MovementState"):Connect(function()
	local newState = char:GetAttribute("MovementState")
	
	-- Clear action layer if we're leaving an action state
	if newState ~= "Jump" and newState ~= "Freefall" and newState ~= "Land" and newState ~= "Slide" then
		if activeTracks.Action then
			activeTracks.Action:Stop(0.2)
			activeTracks.Action = nil
		end
		if activeTracks.Override then
			activeTracks.Override:Stop(0.2)
			activeTracks.Override = nil
		end
	end
	
	-- Play animations based on state (per documentation animation layers)
	if newState == "Idle" then
		playAnimation("Idle", 0.3)
	elseif newState == "Walk" then
		playAnimation("Walk", 0.2)
	elseif newState == "Run" then
		playAnimation("Run", 0.2)
	elseif newState == "Sprint" then
		playAnimation("Sprint", 0.3, 1.2)
	elseif newState == "TacticalSprint" then
		playAnimation("TacticalSprint", 0.3, 1.2)
	elseif newState == "Crouch" then
		playAnimation("Crouch", 0.3)
	elseif newState == "CrouchWalk" then
		playAnimation("CrouchWalk", 0.2)
	elseif newState == "Jump" then
		playAnimation("Jump", 0.1, 1, "Action")
	elseif newState == "Freefall" then
		playAnimation("Fall", 0.3, 1, "Action")
	elseif newState == "Land" then
		playAnimation("Land", 0.1, 1, "Action")
	elseif newState == "Slide" then
		playAnimation("Slide", 0.1, 1, "Action") -- Using Action layer for Slide for now
	end
end)

-- Initial check
local initialState = char:GetAttribute("MovementState") or "Idle"
playAnimation(initialState)

print("Animation Controller Initialized")