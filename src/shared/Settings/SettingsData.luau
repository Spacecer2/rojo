--[[
	SettingsData - Default settings structure and management
	Handles both client-side and server-side settings
]]

local SettingsData = {}

-- Default settings structure
SettingsData.Defaults = {
	Version = 1,
	LastModified = 0,
	
	-- Input Settings
	Input = {
		MouseSensitivity = 1.0,
		ADSSensitivity = 0.8,
		VerticalMultiplier = 1.0,
		ControllerSensitivity = 2.5,
		RawInput = true,
		MouseSmoothing = true,
	},
	
	-- Audio Settings
	Audio = {
		MasterVolume = 1.0,
		EffectsVolume = 1.0,
		MusicVolume = 0.6,
		VoiceVolume = 1.0,
		UIVolume = 0.8,
		VoiceChatEnabled = true,
		PushToTalk = true,
	},
	
	-- Graphics Settings
	Graphics = {
		Quality = "High", -- Low, Medium, High, Ultra
		Resolution = "1920x1080",
		TargetFPS = 60,
		VSync = true,
		DrawDistance = 500,
		ShadowQuality = "Medium",
		ParticleEffects = "High",
		Bloom = true,
		ShowFPS = true,
		ShowPing = true,
	},
	
	-- Gameplay Settings
	Gameplay = {
		DamageNumbers = true,
		KillCallouts = true,
		Killcam = true,
		KillcamDuration = 5,
		BloodEffects = true,
		ShowMinimap = true,
		ShowHUD = true,
	},
	
	-- Accessibility Settings
	Accessibility = {
		ColorblindMode = "None", -- None, Deuteranopia, Protanopia, Tritanopia
		Brightness = 1.0,
		Contrast = 1.0,
		HighContrast = false,
		ReduceMotion = false,
		FontSize = "Medium", -- Small, Medium, Large
		HUDScale = 1.0,
		Subtitles = false,
		MonoAudio = false,
	},
	
	-- Anti-Cheat & Privacy Settings
	AntiCheat = {
		ReportCheaters = true, -- Allow reporting other players
		AutoReportSuspicious = false, -- Automatically report suspicious activity
		ShowViolationWarnings = true, -- Show warnings when violations detected
		PrivacyMode = "Standard", -- Standard, Private, Anonymous
		ShareTelemetry = true, -- Share gameplay data for anti-cheat
		AllowDataCollection = true, -- Allow collection of performance data
	},
	
	-- Network Settings
	Network = {
		NetworkBuffer = "Medium", -- Low, Medium, High
		UpdateRate = 30, -- Hz
		InterpolateUpdates = true,
		ShowPacketLoss = false,
	},
}

-- Server-side only settings (stored per player)
SettingsData.ServerDefaults = {
	HUDScale = 1.0,
	ColorblindMode = "None",
	Brightness = 1.0,
	AntiCheatSettings = {
		ReportCheaters = true,
		PrivacyMode = "Standard",
		ShareTelemetry = true,
	},
}

-- Settings validation
function SettingsData.Validate(settings: {[string]: any}): {[string]: any}
	local validated = {}
	
	-- Validate each category
	for category, defaultValues in pairs(SettingsData.Defaults) do
		if category == "Version" or category == "LastModified" then
			validated[category] = settings[category] or defaultValues
		elseif type(defaultValues) == "table" then
			validated[category] = {}
			for key, defaultValue in pairs(defaultValues) do
				local value = settings[category] and settings[category][key]
				if value ~= nil then
					-- Type check
					if type(value) == type(defaultValue) then
						validated[category][key] = value
					else
						validated[category][key] = defaultValue
					end
				else
					validated[category][key] = defaultValue
				end
			end
		end
	end
	
	validated.Version = SettingsData.Defaults.Version
	validated.LastModified = tick()
	
	return validated
end

-- Get default settings
function SettingsData.GetDefaults(): {[string]: any}
	return SettingsData.Defaults
end

-- Merge settings with defaults
function SettingsData.MergeWithDefaults(userSettings: {[string]: any}?): {[string]: any}
	if not userSettings then
		return SettingsData.Validate({})
	end
	
	return SettingsData.Validate(userSettings)
end

return SettingsData
