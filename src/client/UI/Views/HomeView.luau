--[[
	HomeView - Main menu/PLAY view
	Implements the full lobby/matchmaking interface per Mainmenu.md documentation
]]
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local UI = require(script.Parent.Parent)
local Controllers = script.Parent.Parent.Parent.Controllers

-- Safe require with fallbacks
local MatchmakingController = nil
local PlayerDataController = nil
local Theme = nil
local PlaylistData = nil

local constants = ReplicatedStorage:FindFirstChild("Constants") or ReplicatedStorage:WaitForChild("Constants", 5)

local success0, pd = pcall(function() return require(constants:WaitForChild("PlaylistData")) end)
if success0 then PlaylistData = pd end

local success1, mc = pcall(function()
	if Controllers then
		local module = Controllers:FindFirstChild("MatchmakingController")
		if not module then
			module = Controllers:WaitForChild("MatchmakingController", 5)
		end
		if module then
			return require(module)
		end
	end
	return nil
end)
if not success1 then warn("Failed to load MatchmakingController:", mc) end
if success1 and mc then MatchmakingController = mc end

local success2, pdc = pcall(function()
	if Controllers then
		local module = Controllers:FindFirstChild("PlayerDataController")
		if not module then
			module = Controllers:WaitForChild("PlayerDataController", 5)
		end
		if module then
			return require(module)
		end
	end
	return nil
end)
if not success2 then warn("Failed to load PlayerDataController:", pdc) end
if success2 and pdc then PlayerDataController = pdc end

local success3, theme = pcall(function()
	-- Theme is likely in ReplicatedStorage.Constants.Theme directly, or Shared.Constants
	-- Based on project structure: src/shared/Constants -> ReplicatedStorage.Constants
	local constants = ReplicatedStorage:FindFirstChild("Constants")
	if not constants then
		constants = ReplicatedStorage:WaitForChild("Constants", 5)
	end
	if constants then
		local themeModule = constants:FindFirstChild("Theme")
		if not themeModule then
			themeModule = constants:WaitForChild("Theme", 5)
		end
		if themeModule then
			return require(themeModule)
		end
	end
	return nil
end)
if not success3 then warn("Failed to load Theme:", theme) end
if success3 and theme then Theme = theme end

local PlaylistData = {Modes = {}}
local success4, playlistDataModule = pcall(function()
	if constants then
		local module = constants:FindFirstChild("PlaylistData")
		if module then
			return require(module)
		end
	end
	return nil
end)
if success4 and playlistDataModule then PlaylistData = playlistDataModule end

local HomeView = {}

-- Fallback colors if Theme fails to load
local COLORS = Theme and Theme.Colors or {
	Background = Color3.fromRGB(15, 15, 15),
	Panel = Color3.fromRGB(30, 30, 35),
	AccentBlue = Color3.fromRGB(0, 162, 255),
	AccentGold = Color3.fromRGB(255, 215, 0),
	TextMain = Color3.fromRGB(255, 255, 255),
	TextSecondary = Color3.fromRGB(180, 180, 180),
}

function HomeView.Create(parent)
	local connections = {}
	local frame = Instance.new("Frame")
	frame.Name = "HomeView"
	frame.Size = UDim2.fromScale(1, 1)
	frame.BackgroundTransparency = 1
	frame.Parent = parent
	
	local player = Players.LocalPlayer
	
	-- Get initial data with safe fallbacks
	local lobbyState = {PlayerCount = 1, MaxPlayers = 100, Status = "Searching"}
	if MatchmakingController and MatchmakingController.GetLobbyState then
		local success, state = pcall(function() return MatchmakingController.GetLobbyState() end)
		if success then lobbyState = state end
	end
	
	local profile = {
		Level = 1,
		Currency = 0,
		Username = player and player.Name or "Player",
		XP = 0,
		MaxXP = 1000
	}
	if PlayerDataController and PlayerDataController.GetProfile then
		local success, prof = pcall(function() return PlayerDataController.GetProfile() end)
		if success and prof then profile = prof end
	end
	
	-- === LEFT SIDE: Game Mode List ===
	local modeContainer = Instance.new("ScrollingFrame")
	modeContainer.Name = "ModeList"
	modeContainer.Size = UDim2.new(0, 350, 1, -120) -- Full height minus Squad Fill area
	modeContainer.Position = UDim2.fromOffset(40, 20)
	modeContainer.BackgroundTransparency = 1
	modeContainer.ScrollBarThickness = 0
	modeContainer.Parent = frame
	
	local modeLayout = Instance.new("UIListLayout")
	modeLayout.Padding = UDim.new(0, 10)
	modeLayout.Parent = modeContainer
	
	local modes = PlaylistData and PlaylistData.Modes or {
		{Title = "BATTLE ROYALE", Desc = "Standard mode.", Image = "rbxassetid://13165203306", Active = true},
	}
	
	local currentSquadFill = true
	local currentSelectedMode = "BR QUADS"

	local function startMatchmaking(data)
		if data.IsLocal then
			-- Trigger local game start
			local MenuController = require(script.Parent.Parent.Parent.Interface.MenuController)
			if MenuController and MenuController.StartLocalGame then
				MenuController.StartLocalGame()
				MenuController.SetFooterStatus("Starting Local Movement Test...")
			end
			return
		end

		if MatchmakingController and MatchmakingController.StartMatchmaking then
			MatchmakingController.StartMatchmaking({
				Mode = currentSelectedMode,
				SquadFill = currentSquadFill
			})
			
			-- Update Footer Status via MenuController
			local MenuController = require(script.Parent.Parent.Parent.Interface.MenuController)
			if MenuController and MenuController.SetFooterStatus then
				MenuController.SetFooterStatus("Searching for " .. currentSelectedMode .. " (Squad Fill: " .. (currentSquadFill and "ON" or "OFF") .. ")...")
			end
		end
	end

	local function createModeTile(data)
		local tile = Instance.new("Frame")
		tile.Size = UDim2.new(1, 0, 0, 80)
		tile.BackgroundColor3 = data.Active and COLORS.AccentBlue or Color3.new(0,0,0)
		tile.BackgroundTransparency = data.Active and 0.7 or 0.4
		tile.BorderSizePixel = 0
		
		local bgImage = Instance.new("ImageLabel")
		bgImage.Size = UDim2.fromScale(1, 1)
		bgImage.Image = data.Image
		bgImage.ImageTransparency = 0.6
		bgImage.ScaleType = Enum.ScaleType.Crop
		bgImage.BackgroundTransparency = 1
		bgImage.Parent = tile
		
		local selectionGlow = Instance.new("Frame")
		selectionGlow.Size = UDim2.new(0, 4, 1, 0)
		selectionGlow.BackgroundColor3 = COLORS.AccentBlue
		selectionGlow.BorderSizePixel = 0
		selectionGlow.Visible = data.Active or false
		selectionGlow.Parent = tile
		
		local title = Instance.new("TextLabel")
		title.Text = data.Title
		title.Font = Enum.Font.GothamBlack
		title.TextSize = 16
		title.TextColor3 = Color3.new(1, 1, 1)
		title.Size = UDim2.new(1, -20, 0, 20)
		title.Position = UDim2.fromOffset(10, 10)
		title.BackgroundTransparency = 1
		title.TextXAlignment = Enum.TextXAlignment.Left
		title.Parent = tile
		
		local desc = Instance.new("TextLabel")
		desc.Text = data.Desc
		desc.Font = Enum.Font.Gotham
		desc.TextSize = 10
		desc.TextColor3 = Color3.fromRGB(200, 200, 200)
		desc.Size = UDim2.new(1, -20, 0, 30)
		desc.Position = UDim2.fromOffset(10, 35)
		desc.BackgroundTransparency = 1
		desc.TextXAlignment = Enum.TextXAlignment.Left
		desc.TextWrapped = true
		desc.Parent = tile
		
		local btn = Instance.new("TextButton")
		btn.Size = UDim2.fromScale(1, 1)
		btn.BackgroundTransparency = 1
		btn.Text = ""
		btn.Parent = tile
		
		if UI and UI.ApplyFeedback then UI.ApplyFeedback(btn, {HoverScale = 1.02}) end
		
		btn.MouseButton1Click:Connect(function()
			currentSelectedMode = data.Title
			-- Clear others
			for _, child in ipairs(modeContainer:GetChildren()) do
				if child:IsA("Frame") then
					child.BackgroundTransparency = 0.4
					child.BackgroundColor3 = Color3.new(0,0,0)
					local glow = child:FindFirstChild("Frame")
					if glow then glow.Visible = false end
				end
			end
			-- Select this
			tile.BackgroundTransparency = 0.7
			tile.BackgroundColor3 = COLORS.AccentBlue
			selectionGlow.Visible = true
			
			startMatchmaking(data)
		end)
		
		return tile
	end
	
	for _, m in ipairs(modes) do
		createModeTile(m).Parent = modeContainer
	end
	
	-- Squad Fill Toggle
	local squadFill = Instance.new("Frame")
	squadFill.Name = "SquadFill"
	squadFill.Size = UDim2.fromOffset(350, 40)
	squadFill.Position = UDim2.new(0, 40, 1, -40)
	squadFill.AnchorPoint = Vector2.new(0, 1)
	squadFill.BackgroundTransparency = 1
	squadFill.Parent = frame
	
	local fillLabel = Instance.new("TextLabel")
	fillLabel.Text = "Squad Fill          <font color='#ffffff'>Fill</font>"
	fillLabel.RichText = true
	fillLabel.Font = Enum.Font.GothamBold
	fillLabel.TextSize = 12
	fillLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
	fillLabel.Size = UDim2.fromScale(1, 1)
	fillLabel.BackgroundTransparency = 1
	fillLabel.TextXAlignment = Enum.TextXAlignment.Left
	fillLabel.Parent = squadFill
	
	local fillBtn = Instance.new("TextButton")
	fillBtn.Size = UDim2.fromScale(1, 1)
	fillBtn.BackgroundTransparency = 1
	fillBtn.Text = ""
	fillBtn.Parent = squadFill
	
if UI and UI.ApplyFeedback then UI.ApplyFeedback(fillBtn, {HoverScale = 1.05}) end
	
	fillBtn.MouseButton1Click:Connect(function()
		currentSquadFill = not currentSquadFill
		fillLabel.Text = "Squad Fill          <font color='#ffffff'>" .. (currentSquadFill and "Fill" or "Don't Fill") .. "</font>"
	end)
	
	-- XP Boost Indicator (Center Bottom)
	local xpBoost = Instance.new("Frame")
	xpBoost.Name = "XPBoost"
	xpBoost.Size = UDim2.fromOffset(120, 30)
	xpBoost.Position = UDim2.new(0.5, -50, 1, -40)
	xpBoost.AnchorPoint = Vector2.new(0.5, 1)
	xpBoost.BackgroundColor3 = Color3.fromRGB(200, 150, 0)
	xpBoost.BackgroundTransparency = 0.2
	xpBoost.Visible = false -- Hidden by default until data arrives
	xpBoost.Parent = frame
	Instance.new("UICorner", xpBoost).CornerRadius = UDim.new(0, 4)
	
	local xpBoostLabel = Instance.new("TextLabel")
	xpBoostLabel.Text = "🔥 LOADING BOOST"
	xpBoostLabel.Font = Enum.Font.GothamBlack
	xpBoostLabel.TextSize = 10
	xpBoostLabel.TextColor3 = Color3.new(0,0,0)
	xpBoostLabel.Size = UDim2.fromScale(1, 1)
	xpBoostLabel.BackgroundTransparency = 1
	xpBoostLabel.Parent = xpBoost


	
	
	-- === RIGHT SIDE: Mission & Challenges ===
	local rightPanel = Instance.new("Frame")
	rightPanel.Name = "RightPanel"
	rightPanel.Size = UDim2.new(0, 350, 1, -40)
	rightPanel.Position = UDim2.new(1, -40, 0, 20)
	rightPanel.AnchorPoint = Vector2.new(1, 0)
	rightPanel.BackgroundTransparency = 1
	rightPanel.Parent = frame
	
	local rightLayout = Instance.new("UIListLayout")
	rightLayout.Padding = UDim.new(0, 15)
	rightLayout.Parent = rightPanel

	local function createPanel(title, subtitle)
		local p = Instance.new("Frame")
		p.Size = UDim2.new(1, 0, 0, 140)
		p.BackgroundColor3 = Color3.new(0,0,0)
		p.BackgroundTransparency = 0.5
		p.BorderSizePixel = 0
		
		local t = Instance.new("TextLabel")
		t.Name = "TitleLabel"
		t.Text = title .. " - <font color='#00a2ff'>" .. subtitle .. "</font>"
		t.RichText = true
		t.Font = Enum.Font.GothamBold
		t.TextSize = 14
		t.TextColor3 = Color3.new(1, 1, 1)
		t.Size = UDim2.new(1, -20, 0, 30)
		t.Position = UDim2.fromOffset(10, 0)
		t.BackgroundTransparency = 1
		t.TextXAlignment = Enum.TextXAlignment.Left
		t.Parent = p
		
		return p
	end

	-- 1. Mission Panel
	local missionPanel = createPanel("Mission", "Boats and Trains")
	missionPanel.Parent = rightPanel
	
	local missionObj = Instance.new("TextLabel")
	missionObj.Name = "MissionObj"
	missionObj.Text = "[1/7] - Start 1 Contract(s) at the Verdansk Port"
	missionObj.Font = Enum.Font.Gotham
	missionObj.TextSize = 10
	missionObj.TextColor3 = Color3.fromRGB(180, 180, 180)
	missionObj.Size = UDim2.new(1, -60, 0, 30)
	missionObj.Position = UDim2.fromOffset(10, 35)
	missionObj.BackgroundTransparency = 1
	missionObj.TextXAlignment = Enum.TextXAlignment.Left
	missionObj.TextWrapped = true
	missionObj.Parent = missionPanel
	
	local missionXP = Instance.new("TextLabel")
	missionXP.Text = "💎 XP"
	missionXP.Font = Enum.Font.GothamBold
	missionXP.TextSize = 10
	missionXP.TextColor3 = COLORS.AccentBlue
	missionXP.Size = UDim2.new(0, 40, 0, 40)
	missionXP.Position = UDim2.new(1, -50, 0, 35)
	missionXP.BackgroundTransparency = 0.2
	missionXP.BackgroundColor3 = Color3.new(0,0,0)
	missionXP.Parent = missionPanel

	-- 2. Daily Challenges Panel
	local dailyPanel = createPanel("Daily Challenges", "15h 41m")
	dailyPanel.Size = UDim2.new(1, 0, 0, 180)
	dailyPanel.Parent = rightPanel
	
	local function updateChallenges(challenges)
		-- Clear existing rows (if we stored them)
		for _, child in ipairs(dailyPanel:GetChildren()) do
			if child:IsA("Frame") and child.Name == "ChallengeRow" then
				child:Destroy()
			end
		end
		
		challenges = challenges or (PlayerDataController and PlayerDataController.GetChallenges()) or {}
		for i, challenge in ipairs(challenges) do
			if i > 3 then break end -- Only show top 3
			local row = Instance.new("Frame")
			row.Name = "ChallengeRow"
			row.Size = UDim2.new(1, -20, 0, 40)
			row.Position = UDim2.fromOffset(10, 35 + (i-1)*45)
			row.BackgroundTransparency = 1
			row.Parent = dailyPanel
			
			local t = Instance.new("TextLabel")
			t.Text = challenge.Title
			t.Font = Enum.Font.Gotham
			t.TextSize = 10
			t.TextColor3 = Color3.new(1,1,1)
			t.Size = UDim2.new(1, -50, 0, 15)
			t.BackgroundTransparency = 1
			t.TextXAlignment = Enum.TextXAlignment.Left
			t.Parent = row
			
			local barBg = Instance.new("Frame")
			barBg.Size = UDim2.new(1, -50, 0, 4)
			barBg.Position = UDim2.fromOffset(0, 20)
			barBg.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
			barBg.BorderSizePixel = 0
			barBg.Parent = row
			
			local barFill = Instance.new("Frame")
			barFill.Size = UDim2.fromScale(math.min(1, (challenge.Progress or 0)/(challenge.Goal or 1)), 1)
			barFill.BackgroundColor3 = COLORS.AccentBlue
			barFill.BorderSizePixel = 0
			barFill.Parent = barBg
			
			local xpReward = Instance.new("TextLabel")
			xpReward.Text = "+" .. (challenge.XP or 0) .. " XP"
			xpReward.Font = Enum.Font.GothamBold
			xpReward.TextSize = 8
			xpReward.TextColor3 = COLORS.AccentBlue
			xpReward.Size = UDim2.fromOffset(50, 15)
			xpReward.Position = UDim2.new(1, -50, 0, 0)
			xpReward.BackgroundTransparency = 1
			xpReward.TextXAlignment = Enum.TextXAlignment.Right
			xpReward.Parent = row
		end
	end

	if PlayerDataController and PlayerDataController.ChallengesChanged then
		table.insert(connections, PlayerDataController.ChallengesChanged.Event:Connect(updateChallenges))
	end
	updateChallenges()

	-- View Link
	local viewLink = Instance.new("TextButton")
	viewLink.Text = "🔘 View Missions & Challenges"
	viewLink.Font = Enum.Font.GothamBold
	viewLink.TextSize = 10
	viewLink.TextColor3 = Color3.fromRGB(150, 150, 150)
	viewLink.Size = UDim2.new(1, 0, 0, 20)
	viewLink.BackgroundTransparency = 1
	viewLink.TextXAlignment = Enum.TextXAlignment.Left
	viewLink.Parent = rightPanel
	
	UI.ApplyFeedback(viewLink, {HoverScale = 1.05})

	-- Cleanup redundant events listener setup
	if MatchmakingController and MatchmakingController.LobbyChanged then
		table.insert(connections, MatchmakingController.LobbyChanged.Event:Connect(function(newState)
			-- Logic to update mission/challenge panels if they were dynamic
		end))
	end
	
	-- Update profile when it changes (with safe checks)
	if PlayerDataController and PlayerDataController.ProfileChanged then
		table.insert(connections, PlayerDataController.ProfileChanged.Event:Connect(function(newProfile)
			-- Update Mission Panel
			local titleLabel = missionPanel:FindFirstChild("TitleLabel")
			if titleLabel and newProfile.ActiveMission then
				titleLabel.Text = "Mission - <font color='#00a2ff'>" .. newProfile.ActiveMission.Title .. "</font>"
			end
			local missionObjText = missionPanel:FindFirstChild("MissionObj")
			if missionObjText and newProfile.ActiveMission then
				missionObjText.Text = newProfile.ActiveMission.Objective
			end

			-- Update XP Boost visibility/text if we had a reference to it
			local xpBoostLabel = frame:FindFirstChild("XPBoost", true)
			if xpBoostLabel then
				local textLabel = xpBoostLabel:FindFirstChildOfClass("TextLabel")
				if textLabel and newProfile.XPBoost then
					textLabel.Text = "🔥 " .. (newProfile.XPBoost * 100) .. "% XP BOOST"
					xpBoostLabel.Visible = newProfile.XPBoost > 0
				end
			end
		end))
	end
	
	return {
		Instance = frame,
		Destroy = function()
			for _, c in ipairs(connections) do c:Disconnect() end
			frame:Destroy()
		end
	}
end

return HomeView
