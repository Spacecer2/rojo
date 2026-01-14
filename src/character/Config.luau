local Config = {
	-- System Settings
	RigType = Enum.HumanoidRigType.R15, -- Enforcing R15 for modern mechanics
	
	-- Movement Speeds
	WalkSpeed = 12,
	RunSpeed = 16,
	SprintSpeed = 22,
	TacticalSprintSpeed = 28, -- Super sprint speed
	CrouchSpeed = 8,
	ADSSpeedMultiplier = 0.5, -- Movement is 50% slower when aiming
	
	-- Camera Settings
	DefaultFOV = 70,
	ADSFOV = 50,
	FOVTransitionSpeed = 8, -- Higher = faster transition
	
	-- Jump & Land
	JumpPower = 50,
	LandStunDuration = 0.2, -- Brief slowdown after high fall
	TacticalSprintDuration = 4.0, -- Max duration for tac sprint
	TacticalSprintCooldown = 2.0, -- Cooldown before using again
	
	-- Slide Settings
	SlideSpeed = 35, -- Initial slide boost
	SlideFriction = 3.5, -- Deceleration during slide (higher = shorter/stronger friction)
	SlideDuration = 1.0, -- Max time a slide can last
	SlideCooldown = 0.8,
	MinSlideSpeed = 16, -- Min speed needed to start a slide
	
	
	-- Transition Times
	AccelerationTime = 0.2,
	DecelerationTime = 0.2,
	
	-- Animation IDs (R15)
	-- Replace with your asset IDs (e.g., "rbxassetid://123456789")
	Animations = {
		Idle = "rbxassetid://507766666",
		Walk = "rbxassetid://507777826",
		Run = "rbxassetid://913376220",
		Sprint = "rbxassetid://913376220",
		TacticalSprint = "rbxassetid://913376220", -- Placeholder (needs gun-up anim)
		Crouch = "rbxassetid://507766666",
		CrouchWalk = "rbxassetid://507766666",
		ADS = "rbxassetid://507766666", -- Needs ADS ID
		Slide = "",
		Jump = "rbxassetid://507765000",
		Fall = "rbxassetid://507767968",
		Land = "rbxassetid://507765000"
	}
}

return Config