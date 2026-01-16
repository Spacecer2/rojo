--[[
	MusicController
	Handles background music playback, looping, and volume control.
]]

local SoundService = game:GetService("SoundService")
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")

local MusicController = {}

-- Configuration
local MUSIC_ID = "rbxassetid://1839843632" -- Replace with your desired audio ID
local DEFAULT_VOLUME = 0.5
local FADE_TIME = 2.0

local bgMusic = nil

function MusicController.Init()
	-- Check if the sound already exists in SoundService
	bgMusic = SoundService:FindFirstChild("BackgroundMusic")
	
	if not bgMusic then
		bgMusic = Instance.new("Sound")
		bgMusic.Name = "BackgroundMusic"
		bgMusic.SoundId = MUSIC_ID
		bgMusic.Looped = true
		bgMusic.Volume = 0 -- Start at 0 for fade in
		bgMusic.Parent = SoundService
	end
end

function MusicController.Start()
	if bgMusic then
		if not bgMusic.IsPlaying then
			bgMusic:Play()
		end
		
		-- Fade in
		local tweenInfo = TweenInfo.new(FADE_TIME, Enum.EasingStyle.Linear)
		local tween = TweenService:Create(bgMusic, tweenInfo, {Volume = DEFAULT_VOLUME})
		tween:Play()
		
		print("[MusicController] Background music started")
	end
end

-- Function to change track smoothly
function MusicController.PlayTrack(soundId, volume)
	volume = volume or DEFAULT_VOLUME
	
	if bgMusic.SoundId == soundId and bgMusic.IsPlaying then
		return -- Already playing this track
	end
	
	-- Fade out current
	local fadeOut = TweenService:Create(bgMusic, TweenInfo.new(1.0), {Volume = 0})
	fadeOut:Play()
	fadeOut.Completed:Wait()
	
	-- Switch and fade in
	bgMusic.SoundId = soundId
	bgMusic:Play()
	local fadeIn = TweenService:Create(bgMusic, TweenInfo.new(1.0), {Volume = volume})
	fadeIn:Play()
end

return MusicController
