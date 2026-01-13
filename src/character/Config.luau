local Config = {
	-- System Settings
	RigType = Enum.HumanoidRigType.R15, -- Enforcing R15 for modern mechanics
	
	-- Movement Speeds
	WalkSpeed = 12,
	RunSpeed = 16,
	SprintSpeed = 22,
	CrouchSpeed = 8,
	ADSSpeedMultiplier = 0.5, -- Movement is 50% slower when aiming
	
	-- Jump & Land
	JumpPower = 50,
	LandStunDuration = 0.2, -- Brief slowdown after high fall
	
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