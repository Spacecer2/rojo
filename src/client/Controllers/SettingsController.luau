--[[
	SettingsController - Client-side settings management
	Handles loading, saving (local), and applying settings.
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local SoundService = game:GetService("SoundService")
local Lighting = game:GetService("Lighting")

local SettingsData = require(ReplicatedStorage.Constants.SettingsData)
local Network = require(ReplicatedStorage.Framework.Network)

local SettingsController = {
	CurrentSettings = table.clone(SettingsData.Defaults)
}

-- Events
SettingsController.SettingsChanged = Instance.new("BindableEvent")

function SettingsController.Init()
	print("[SettingsController] Initialized")
end

function SettingsController.Start()
	-- Connect to Player Data
	local PlayerDataController = require(script.Parent.PlayerDataController)
	
	local function loadFromProfile(profile)
		if profile and profile.Settings then
			for k, v in pairs(profile.Settings) do
				SettingsController.CurrentSettings[k] = v
			end
			SettingsController.ApplyAll()
			print("[SettingsController] Settings synced from profile")
		end
	end
	
	-- Load initial if available
	local profile = PlayerDataController.GetProfile()
	if profile then loadFromProfile(profile) end
	
	-- Listen for updates
	PlayerDataController.ProfileChanged.Event:Connect(loadFromProfile)
	
	-- Apply initial settings
	SettingsController.ApplyAll()
end

function SettingsController.GetSettings()
	return SettingsController.CurrentSettings
end

function SettingsController.UpdateSetting(key, value)
	if SettingsController.CurrentSettings[key] == nil then
		warn("Invalid setting key:", key)
		return
	end
	
	SettingsController.CurrentSettings[key] = value
	SettingsController.ApplySetting(key, value)
	SettingsController.SettingsChanged:Fire(key, value)
	
	-- Save to server
	Network.FireServer("UpdateSettings", key, value)
end

function SettingsController.ApplyAll()
	for k, v in pairs(SettingsController.CurrentSettings) do
		SettingsController.ApplySetting(k, v)
	end
end

function SettingsController.ApplySetting(key, value)
	if key == "FOV" then
		local cam = workspace.CurrentCamera
		if cam then cam.FieldOfView = value end
		
	elseif key == "MasterVolume" then
		-- Simple global volume scaling (could be more complex with SoundGroups)
		-- SoundService.RespectFilteringEnabled = true -- Default
		
	elseif key == "MotionBlur" then
		local cam = workspace.CurrentCamera
		if not cam then return end
		
		local blur = cam:FindFirstChild("MotionBlur")
		if not blur then
			blur = Instance.new("BlurEffect")
			blur.Name = "MotionBlur"
			blur.Parent = cam
		end
		blur.Enabled = value
		blur.Size = value and 4 or 0 -- Simple toggle
		
	elseif key == "Sensitivity" then
		-- Used by InputManager, not applied globally
		
	end
	-- Add more application logic here
end

return SettingsController
