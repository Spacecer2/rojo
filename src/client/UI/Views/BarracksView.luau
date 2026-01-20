--[[
	BarracksView - Player statistics, missions, and customization
	Matches the Warzone "BARRACKS" reference image
]]
local Controllers = script.Parent.Parent.Parent.Controllers
local PlayerDataController = nil

local success_pdc, pdc = pcall(function() return require(Controllers:WaitForChild("PlayerDataController")) end)
if success_pdc then PlayerDataController = pdc end

local COLORS = {
	Background = Color3.fromRGB(15, 15, 15),
	Panel = Color3.fromRGB(30, 30, 35),
	AccentBlue = Color3.fromRGB(0, 162, 255),
	TextMain = Color3.fromRGB(255, 255, 255),
	TextSecondary = Color3.fromRGB(180, 180, 180),
	Border = Color3.fromRGB(60, 60, 60),
}

local BarracksView = {}

function BarracksView.Create(parent)
	local connections = {}
	local frame = Instance.new("Frame")
	frame.Name = "BarracksView"
	frame.Size = UDim2.fromScale(1, 1)
	frame.BackgroundTransparency = 1
	frame.Parent = parent

	-- 1. Left Sidebar (Categories)
	local sidebar = Instance.new("Frame")
	sidebar.Name = "Sidebar"
	sidebar.Size = UDim2.new(0, 240, 1, -100)
	sidebar.Position = UDim2.fromOffset(40, 40)
	sidebar.BackgroundTransparency = 1
	sidebar.Parent = frame

	local sidebarLayout = Instance.new("UIListLayout")
	sidebarLayout.Padding = UDim.new(0, 20)
	sidebarLayout.Parent = sidebar

	local function createCategory(name, items)
		local catFrame = Instance.new("Frame")
		catFrame.Name = name
		catFrame.Size = UDim2.new(1, 0, 0, 30 + (#items * 35))
		catFrame.BackgroundTransparency = 1
		catFrame.Parent = sidebar

		local title = Instance.new("TextLabel")
		title.Text = name:upper()
		title.Font = Enum.Font.GothamBold
		title.TextSize = 10
		title.TextColor3 = COLORS.TextSecondary
		title.Size = UDim2.new(1, 0, 0, 20)
		title.TextXAlignment = Enum.TextXAlignment.Left
		title.BackgroundTransparency = 1
		title.Parent = catFrame

		local itemContainer = Instance.new("Frame")
		itemContainer.Size = UDim2.new(1, 0, 1, -25)
		itemContainer.Position = UDim2.fromOffset(0, 25)
		itemContainer.BackgroundTransparency = 1
		itemContainer.Parent = catFrame
		
		local itemLayout = Instance.new("UIListLayout")
		itemLayout.Padding = UDim.new(0, 2)
		itemLayout.Parent = itemContainer

		for i, itemName in ipairs(items) do
			local btn = Instance.new("TextButton")
			btn.Name = itemName
			btn.Text = "     " .. itemName -- Padding
			btn.Font = Enum.Font.GothamBold
			btn.TextSize = 13
			btn.TextColor3 = COLORS.TextMain
			btn.Size = UDim2.new(1, 0, 0, 32)
			btn.BackgroundColor3 = Color3.new(1,1,1)
			btn.BackgroundTransparency = 0.95
			btn.BorderSizePixel = 0
			btn.TextXAlignment = Enum.TextXAlignment.Left
			btn.AutoButtonColor = false
			btn.Parent = itemContainer

			if itemName == "MISSIONS & CHALLENGES" then
				btn.BackgroundTransparency = 0.8
				btn.BackgroundColor3 = COLORS.AccentBlue
				-- Add blue bar indicator
				local bar = Instance.new("Frame")
				bar.Size = UDim2.new(0, 2, 1, 0)
				bar.BackgroundColor3 = COLORS.AccentBlue
				bar.BorderSizePixel = 0
				bar.Parent = btn
			end
		end
	end

	createCategory("Missions & Challenges", {"MISSIONS & CHALLENGES"})
	createCategory("Customization", {"IDENTITY"})
	createCategory("Stats", {"RANK PROGRESSION", "RECORDS", "ACHIEVEMENTS"})

	-- 2. Main Content Area
	local content = Instance.new("Frame")
	content.Name = "MainArea"
	content.Size = UDim2.new(1, -340, 1, -100)
	content.Position = UDim2.fromOffset(300, 40)
	content.BackgroundTransparency = 1
	content.Parent = frame

	local contentLayout = Instance.new("UIListLayout")
	contentLayout.FillDirection = Enum.FillDirection.Horizontal
	contentLayout.Padding = UDim.new(0, 30)
	contentLayout.Parent = content

	local function createPanel(titleText, timeText)
		local panel = Instance.new("Frame")
		panel.Size = UDim2.fromScale(0.45, 1)
		panel.BackgroundColor3 = COLORS.Panel
		panel.BackgroundTransparency = 0.4
		panel.BorderSizePixel = 0
		panel.Parent = content

		local title = Instance.new("TextLabel")
		title.Name = "TitleLabel"
		title.RichText = true
		title.Text = titleText
		title.Font = Enum.Font.GothamBold
		title.TextSize = 16
		title.TextColor3 = COLORS.TextMain
		title.Size = UDim2.new(1, -40, 0, 40)
		title.Position = UDim2.fromOffset(20, 10)
		title.TextXAlignment = Enum.TextXAlignment.Left
		title.BackgroundTransparency = 1
		title.Parent = panel

		if timeText then
			local t = Instance.new("TextLabel")
			t.Text = "🕒 " .. timeText
			t.Font = Enum.Font.Gotham
			t.TextSize = 12
			t.TextColor3 = COLORS.AccentBlue
			t.Size = UDim2.fromOffset(100, 40)
			t.Position = UDim2.new(1, -110, 0, 10)
			t.TextXAlignment = Enum.TextXAlignment.Right
			t.BackgroundTransparency = 1
			t.Parent = panel
		end

		return panel
	end

	-- 2.1 Mission Panel
	local missionPanel = createPanel("Mission - <font color='#00a2ff'>Boot Camp!</font>")
	
	local missionObj = Instance.new("TextLabel")
	missionObj.Text = "Ping an Enemy"
	missionObj.Font = Enum.Font.Gotham
	missionObj.TextSize = 12
	missionObj.TextColor3 = COLORS.TextSecondary
	missionObj.Size = UDim2.new(1, -40, 0, 20)
	missionObj.Position = UDim2.fromOffset(20, 60)
	missionObj.TextXAlignment = Enum.TextXAlignment.Left
	missionObj.BackgroundTransparency = 1
	missionObj.Parent = missionPanel

	local progressBg = Instance.new("Frame")
	progressBg.Size = UDim2.new(1, -40, 0, 4)
	progressBg.Position = UDim2.fromOffset(20, 85)
	progressBg.BackgroundColor3 = COLORS.Border
	progressBg.BorderSizePixel = 0
	progressBg.Parent = missionPanel

	local progressFill = Instance.new("Frame")
	progressFill.Size = UDim2.fromScale(0, 1)
	progressFill.BackgroundColor3 = COLORS.AccentBlue
	progressFill.BorderSizePixel = 0
	progressFill.Parent = progressBg

	local progressText = Instance.new("TextLabel")
	progressText.Text = "0/1"
	progressText.Font = Enum.Font.Gotham
	progressText.TextSize = 10
	progressText.TextColor3 = COLORS.TextSecondary
	progressText.Size = UDim2.fromOffset(40, 20)
	progressText.Position = UDim2.fromScale(0, 1)
	progressText.TextXAlignment = Enum.TextXAlignment.Left
	progressText.BackgroundTransparency = 1
	progressText.Parent = progressBg

	local rewardTitle = Instance.new("TextLabel")
	rewardTitle.Text = "Reward"
	rewardTitle.Font = Enum.Font.GothamBold
	rewardTitle.TextSize = 14
	rewardTitle.TextColor3 = COLORS.TextMain
	rewardTitle.Size = UDim2.new(1, -40, 0, 30)
	rewardTitle.Position = UDim2.fromOffset(20, 120)
	rewardTitle.TextXAlignment = Enum.TextXAlignment.Left
	rewardTitle.BackgroundTransparency = 1
	rewardTitle.Parent = missionPanel

	local function createRewardCard(name, value, isLoot)
		local card = Instance.new("Frame")
		card.Size = UDim2.fromOffset(110, 130)
		card.BackgroundColor3 = Color3.new(0,0,0)
		card.BackgroundTransparency = 0.5
		card.BorderSizePixel = 1
		card.BorderColor3 = isLoot and COLORS.AccentBlue or COLORS.Border
		card.Parent = nil -- Manual positioning

		local header = Instance.new("TextLabel")
		header.Text = isLoot and "Loot" or "XP"
		header.Font = Enum.Font.Gotham
		header.TextSize = 9
		header.TextColor3 = COLORS.TextSecondary
		header.Size = UDim2.new(1, 0, 0, 20)
		header.BackgroundTransparency = 1
		header.Parent = card

		local icon = Instance.new("Frame")
		icon.Size = UDim2.fromOffset(60, 60)
		icon.Position = UDim2.new(0.5, -30, 0, 25)
		icon.BackgroundColor3 = isLoot and COLORS.AccentBlue or COLORS.TextSecondary
		icon.BackgroundTransparency = 0.9
		icon.BorderSizePixel = 0
		icon.Parent = card
		Instance.new("UICorner", icon).CornerRadius = UDim.new(0, 4)

		local iconLabel = Instance.new("TextLabel")
		iconLabel.Text = isLoot and "⚔️" or "💎"
		iconLabel.TextSize = 24
		iconLabel.Size = UDim2.fromScale(1, 1)
		iconLabel.BackgroundTransparency = 1
		iconLabel.Parent = icon

		local info = Instance.new("TextLabel")
		info.Text = name
		info.Font = Enum.Font.GothamBold
		info.TextSize = 10
		info.TextColor3 = COLORS.TextMain
		info.Size = UDim2.new(1, -10, 0, 20)
		info.Position = UDim2.new(0, 5, 1, -40)
		info.BackgroundTransparency = 1
		info.Parent = card

		local subText = Instance.new("TextLabel")
		subText.Text = isLoot and "Calling Card" or value .. " XP"
		subText.Font = Enum.Font.Gotham
		subText.TextSize = 9
		subText.TextColor3 = COLORS.AccentBlue
		subText.Size = UDim2.new(1, -10, 0, 15)
		subText.Position = UDim2.new(0, 5, 1, -20)
		subText.BackgroundTransparency = 1
		subText.Parent = card

		return card
	end

	local rewardList = Instance.new("Frame")
	rewardList.Size = UDim2.new(1, -40, 0, 140)
	rewardList.Position = UDim2.fromOffset(20, 160)
	rewardList.BackgroundTransparency = 1
	rewardList.Parent = missionPanel

	local rlLayout = Instance.new("UIListLayout")
	rlLayout.FillDirection = Enum.FillDirection.Horizontal
	rlLayout.Padding = UDim.new(0, 10)
	rlLayout.Parent = rewardList

	createRewardCard("XP", "750", false).Parent = rewardList
	createRewardCard("Clashing Blades", "", true).Parent = rewardList

	-- 2.2 Challenges Panel
	local challengesPanel = createPanel("Warzone Daily Challenges", "17h 50m")
	
	local challengeObj = Instance.new("TextLabel")
	challengeObj.Text = "Earn top 15 placement with your team 1 time(s)"
	challengeObj.Font = Enum.Font.Gotham
	challengeObj.TextSize = 12
	challengeObj.TextColor3 = COLORS.TextSecondary
	challengeObj.Size = UDim2.new(1, -40, 0, 30)
	challengeObj.Position = UDim2.fromOffset(20, 60)
	challengeObj.TextXAlignment = Enum.TextXAlignment.Left
	challengeObj.TextWrapped = true
	challengeObj.BackgroundTransparency = 1
	challengeObj.Parent = challengesPanel

	local chalProgressBg = progressBg:Clone()
	chalProgressBg.Position = UDim2.fromOffset(20, 100)
	chalProgressBg.Parent = challengesPanel
	
	local chalRewardTitle = rewardTitle:Clone()
	chalRewardTitle.Position = UDim2.fromOffset(20, 135)
	chalRewardTitle.Parent = challengesPanel

	local chalRewardList = rewardList:Clone()
	chalRewardList.Position = UDim2.fromOffset(20, 175)
	chalRewardList.Parent = challengesPanel
	-- Clear cloned children
	for _, c in ipairs(chalRewardList:GetChildren()) do if c:IsA("Frame") then c:Destroy() end end
	
	-- 3. Data Sync
	local function updateProfile(profile)
		if not profile.ActiveMission then return end
		local mission = profile.ActiveMission
		missionPanel.TitleLabel.Text = "Mission - <font color='#00a2ff'>" .. mission.Title .. "</font>"
		missionObj.Text = mission.Objective
		
		local prog = (mission.Progress or 0) / (mission.Goal or 1)
		progressFill.Size = UDim2.fromScale(prog, 1)
		progressText.Text = (mission.Progress or 0) .. "/" .. (mission.Goal or 1)
		
		-- Update Rewards (Simple XP for now)
		for _, child in ipairs(rewardList:GetChildren()) do if child:IsA("Frame") then child:Destroy() end end
		createRewardCard("XP", "750", false).Parent = rewardList
		if mission.Title == "Boot Camp!" then
			createRewardCard("Clashing Blades", "", true).Parent = rewardList
		end
	end

	local function updateChallenges(challenges)
		if #challenges == 0 then return end
		-- Show the first challenge in the detailed panel for now
		local challenge = challenges[1]
		challengeObj.Text = challenge.Title
		
		local prog = (challenge.Progress or 0) / (challenge.Goal or 1)
		chalProgressBg:FindFirstChildOfClass("Frame").Size = UDim2.fromScale(prog, 1)
		chalProgressBg:FindFirstChildOfClass("TextLabel").Text = (challenge.Progress or 0) .. "/" .. (challenge.Goal or 1)
		
		for _, child in ipairs(chalRewardList:GetChildren()) do if child:IsA("Frame") then child:Destroy() end end
		createRewardCard("XP", tostring(challenge.XP or 2000), false).Parent = chalRewardList
	end

	if PlayerDataController then
		table.insert(connections, PlayerDataController.ProfileChanged.Event:Connect(updateProfile))
		table.insert(connections, PlayerDataController.ChallengesChanged.Event:Connect(updateChallenges))
		
		local p = PlayerDataController.GetProfile()
		if p then updateProfile(p) end
		
		local c = PlayerDataController.GetChallenges()
		if c then updateChallenges(c) end
	end

	return {
		Instance = frame,
		Destroy = function()
			for _, c in ipairs(connections) do c:Disconnect() end
			frame:Destroy()
		end
	}
end

return BarracksView
