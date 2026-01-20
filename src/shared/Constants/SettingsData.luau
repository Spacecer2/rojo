--[[
	SettingsData - Default configuration for player settings
]]

local SettingsData = {
	Defaults = {
		-- INPUT
		Sensitivity = 1.0,
		InvertLook = false,
		ToggleSprint = true,
		ToggleADS = false,
		
		-- AUDIO
		MasterVolume = 1.0,
		MusicVolume = 0.7,
		EffectsVolume = 1.0,
		VoiceChatVolume = 1.0,
		HitmarkerVolume = 0.8,
		
		-- GRAPHICS / ACCESSIBILITY
		FOV = 90, -- Field of View
		MotionBlur = true,
		WeaponBob = true,
		ColorblindMode = "None", -- None, Protanopia, Deuteranopia, Tritanopia
		HUDScale = 1.0,
		
		-- DRONE CAMERA
		DroneOrbitSwayAmplitude = 0.6,
		DroneOrbitSwayFrequency = 0.2,
		DroneMinDistance = 10,
		DroneMaxDistance = 30,
		DroneHeightOffset = 0,
		DroneLookAheadFactor = 0.2,
		DroneIdealAlignment = 0,
		DroneTopSpeed = 40,
		DroneAccelerationLimit = 50,
		DroneFocusSpringSpeed = 1.8,
		DroneFocusSpringDamper = 0.6,
	},
	
	-- Constraints for UI sliders
	Constraints = {
		Sensitivity = {Min = 0.1, Max = 5.0, Step = 0.1},
		MasterVolume = {Min = 0, Max = 1, Step = 0.05},
		MusicVolume = {Min = 0, Max = 1, Step = 0.05},
		EffectsVolume = {Min = 0, Max = 1, Step = 0.05},
		VoiceChatVolume = {Min = 0, Max = 1, Step = 0.05},
		HitmarkerVolume = {Min = 0, Max = 1, Step = 0.05},
		FOV = {Min = 60, Max = 120, Step = 1},
		HUDScale = {Min = 0.8, Max = 1.2, Step = 0.05},
		
		-- Drone Constraints
		DroneOrbitSwayAmplitude = {Min = 0.1, Max = 1.5, Step = 0.05},
		DroneOrbitSwayFrequency = {Min = 0.05, Max = 0.5, Step = 0.05},
		DroneMinDistance = {Min = 10, Max = 30, Step = 1},
		DroneMaxDistance = {Min = 30, Max = 80, Step = 5},
		DroneHeightOffset = {Min = -10, Max = 20, Step = 1},
		DroneLookAheadFactor = {Min = 0.0, Max = 0.5, Step = 0.05},
		DroneIdealAlignment = {Min = 0, Max = 180, Step = 5},
		DroneTopSpeed = {Min = 25, Max = 60, Step = 5},
		DroneAccelerationLimit = {Min = 30, Max = 80, Step = 5},
		DroneFocusSpringSpeed = {Min = 1.0, Max = 4.0, Step = 0.2},
		DroneFocusSpringDamper = {Min = 0.4, Max = 0.9, Step = 0.1},
	},
	
	-- Dropdown Options
	Options = {
		ColorblindMode = {"None", "Protanopia", "Deuteranopia", "Tritanopia"}
	}
}

return SettingsData
