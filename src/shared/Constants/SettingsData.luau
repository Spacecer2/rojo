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
	},
	
	-- Dropdown Options
	Options = {
		ColorblindMode = {"None", "Protanopia", "Deuteranopia", "Tritanopia"}
	}
}

return SettingsData
