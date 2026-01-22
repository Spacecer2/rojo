--[[
	SettingsManager - Client-side settings management
	Handles loading, saving, and applying settings
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local SettingsData = require(ReplicatedStorage.Shared.Settings.SettingsData)

local SettingsManager = {}

-- Current settings
local currentSettings = SettingsData.GetDefaults()

-- Load settings from LocalStorage
function SettingsManager.LoadSettings(): {[string]: any}
	local success, savedSettings = pcall(function()
		-- Try to load from LocalStorage
		-- Note: In Roblox, we'd use DataStoreService or a custom storage solution
		-- For now, we'll use a simple approach with player attributes
		local player = Players.LocalPlayer
		if player then
			local settingsString = player:GetAttribute("ClientSettings")
			if settingsString then
				return game:GetService("HttpService"):JSONDecode(settingsString)
			end
		end
		return nil
	end)
	
	if success and savedSettings then
		currentSettings = SettingsData.MergeWithDefaults(savedSettings)
	else
		currentSettings = SettingsData.GetDefaults()
	end
	
	return currentSettings
end

-- Save settings to LocalStorage
function SettingsManager.SaveSettings(settings: {[string]: any}?)
	if not settings then
		settings = currentSettings
	end
	
	settings.LastModified = tick()
	currentSettings = settings
	
	-- Save to player attribute (in production, use DataStoreService)
	local success, err = pcall(function()
		local player = Players.LocalPlayer
		if player then
			local settingsString = game:GetService("HttpService"):JSONEncode(settings)
			player:SetAttribute("ClientSettings", settingsString)
		end
	end)
	
	if not success then
		warn("[SettingsManager] Failed to save settings: " .. tostring(err))
	end
end

-- Get current settings
function SettingsManager.GetSettings(): {[string]: any}
	return currentSettings
end

-- Get a specific setting value
function SettingsManager.GetSetting(category: string, key: string): any?
	if currentSettings[category] and currentSettings[category][key] ~= nil then
		return currentSettings[category][key]
	end
	return nil
end

-- Set a specific setting value
function SettingsManager.SetSetting(category: string, key: string, value: any)
	if not currentSettings[category] then
		currentSettings[category] = {}
	end
	
	currentSettings[category][key] = value
	SettingsManager.SaveSettings()
end

-- Reset settings to defaults
function SettingsManager.ResetToDefaults()
	currentSettings = SettingsData.GetDefaults()
	SettingsManager.SaveSettings()
end

-- Apply settings (e.g., update graphics, audio, etc.)
function SettingsManager.ApplySettings(settings: {[string]: any}?)
	if not settings then
		settings = currentSettings
	end
	
	-- Apply graphics settings
	if settings.Graphics then
		-- TODO: Apply graphics settings
		-- Example: Update render quality, FPS target, etc.
	end
	
	-- Apply audio settings
	if settings.Audio then
		-- TODO: Apply audio settings
		-- Example: Update volume levels
	end
	
	-- Apply input settings
	if settings.Input then
		-- TODO: Apply input settings
		-- Example: Update mouse sensitivity
	end
	
	-- Apply accessibility settings
	if settings.Accessibility then
		-- TODO: Apply accessibility settings
		-- Example: Apply colorblind mode, brightness, etc.
	end
end

-- Initialize settings manager
function SettingsManager.Init()
	SettingsManager.LoadSettings()
	SettingsManager.ApplySettings()
	print("[SettingsManager] Initialized - Settings loaded and applied")
end

return SettingsManager
