--[[
	BarracksView - Complete player statistics, missions, and customization interface
	Features: Missions & Challenges, Identity (Operators/Calling Cards/Emblems), 
	Rank Progression, Records, and Achievements
]]
local Controllers = script.Parent.Parent.Parent.Controllers
local PlayerDataController = nil
local success_pdc, pdc = pcall(function() return require(Controllers:WaitForChild("PlayerDataController")) end)
if success_pdc then PlayerDataController = pdc end

local OperatorData = require(ReplicatedStorage.Shared.Constants.OperatorData)

local COLORS = {
	Background = Color3.fromRGB(15, 15, 15),
	Panel = Color3.fromRGB(30, 30, 35),
	AccentBlue = Color3.fromRGB(0, 162, 255),
	AccentGold = Color3.fromRGB(255, 215, 0),
	TextMain = Color3.fromRGB(255, 255, 255),
	TextSecondary = Color3.fromRGB(180, 180, 180),
	Border = Color3.fromRGB(60, 60, 60),
	Positive = Color3.fromRGB(0, 255, 0),
	Negative = Color3.fromRGB(255, 0, 0),
}

local BarracksView = {}

-- Create reward card helper
local function createRewardCard(parent, name, value, isLoot, xPos, yPos)
	local card = Instance.new("Frame")
	card.Size = UDim2.new(0, 110, 0, 130)
	card.Position = UDim2.new(0, xPos, 0, yPos)
	card.BackgroundColor3 = Color3.new(0,0,0)
	card.BackgroundTransparency = 0.5
	card.BorderSizePixel = 1
	card.BorderColor3 = isLoot and COLORS.AccentBlue or COLORS.Border
	card.Parent = parent
	Instance.new("UICorner", card).CornerRadius = UDim.new(0, 4)

	local header = Instance.new("TextLabel")
	header.Text = isLoot and "Loot" or "XP"
	header.Font = Enum.Font.Gotham
	header.TextSize = 9
	header.TextColor3 = COLORS.TextSecondary
	header.Size = UDim2.new(1, 0, 0, 20)
	header.BackgroundTransparency = 1
	header.Parent = card

	local icon = Instance.new("Frame")
	icon.Size = UDim2.new(0, 60, 0, 60)
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
	info.TextWrapped = true
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

-- Create content panel helper
local function createContentPanel(parent, titleText, timeText)
	local panel = Instance.new("Frame")
	panel.Size = UDim2.new(0.45, 0, 1, 0)
	panel.BackgroundColor3 = COLORS.Panel
	panel.BackgroundTransparency = 0.4
	panel.BorderSizePixel = 0
	panel.Parent = parent
	Instance.new("UICorner", panel).CornerRadius = UDim.new(0, 8)

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
		t.Size = UDim2.new(0, 100, 0, 40)
		t.Position = UDim2.new(1, -110, 0, 10)
		t.TextXAlignment = Enum.TextXAlignment.Right
		t.BackgroundTransparency = 1
		t.Parent = panel
	end

	return panel
end

function BarracksView.Create(parent)
	local connections = {}
	local frame = Instance.new("Frame")
	frame.Name = "BarracksView"
	frame.Size = UDim2.fromScale(1, 1)
	frame.BackgroundTransparency = 1
	frame.Parent = parent

	-- 1. Left Sidebar (Categories)
	local sidebar = Instance.new("ScrollingFrame")
	sidebar.Name = "Sidebar"
	sidebar.Size = UDim2.new(0, 240, 1, -100)
	sidebar.Position = UDim2.fromOffset(40, 40)
	sidebar.BackgroundTransparency = 1
	sidebar.ScrollBarThickness = 4
	sidebar.Parent = frame

	local sidebarLayout = Instance.new("UIListLayout")
	sidebarLayout.Padding = UDim.new(0, 20)
	sidebarLayout.Parent = sidebar

	-- 2. Main Content Area
	local content = Instance.new("Frame")
	content.Name = "MainArea"
	content.Size = UDim2.new(1, -340, 1, -100)
	content.Position = UDim2.fromOffset(300, 40)
	content.BackgroundTransparency = 1
	content.Parent = frame

	-- Current selected tab
	local currentTab = "MISSIONS & CHALLENGES"
	local contentViews = {}

	-- Create sidebar category button
	local function createCategoryButton(categoryName, itemName, isSelected)
		local btn = Instance.new("TextButton")
		btn.Name = itemName
		btn.Text = "     " .. itemName
		btn.Font = Enum.Font.GothamBold
		btn.TextSize = 13
		btn.TextColor3 = isSelected and COLORS.TextMain or COLORS.TextSecondary
		btn.Size = UDim2.new(1, 0, 0, 32)
		btn.BackgroundColor3 = isSelected and COLORS.AccentBlue or Color3.new(1,1,1)
		btn.BackgroundTransparency = isSelected and 0.7 or 0.95
		btn.BorderSizePixel = 0
		btn.TextXAlignment = Enum.TextXAlignment.Left
		btn.AutoButtonColor = false
		
		if isSelected then
			local bar = Instance.new("Frame")
			bar.Size = UDim2.new(0, 2, 1, 0)
			bar.BackgroundColor3 = COLORS.AccentBlue
			bar.BorderSizePixel = 0
			bar.Parent = btn
		end
		
		btn.MouseButton1Click:Connect(function()
			currentTab = itemName
			-- Update all buttons
			for _, child in ipairs(sidebar:GetDescendants()) do
				if child:IsA("TextButton") then
					local isNowSelected = child.Name == itemName
					child.TextColor3 = isNowSelected and COLORS.TextMain or COLORS.TextSecondary
					child.BackgroundColor3 = isNowSelected and COLORS.AccentBlue or Color3.new(1,1,1)
					child.BackgroundTransparency = isNowSelected and 0.7 or 0.95
					-- Update bar
					local bar = child:FindFirstChildOfClass("Frame")
					if isNowSelected and not bar then
						bar = Instance.new("Frame")
						bar.Size = UDim2.new(0, 2, 1, 0)
						bar.BackgroundColor3 = COLORS.AccentBlue
						bar.BorderSizePixel = 0
						bar.Parent = child
					elseif not isNowSelected and bar then
						bar:Destroy()
					end
				end
			end
			-- Show selected content
			for name, view in pairs(contentViews) do
				view.Visible = (name == itemName)
			end
		end)
		
		return btn
	end

	-- Create category section
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
			createCategoryButton(name, itemName, itemName == currentTab).Parent = itemContainer
		end
	end

	createCategory("Missions & Challenges", {"MISSIONS & CHALLENGES"})
	createCategory("Customization", {"IDENTITY", "OPERATORS", "CALLING CARDS", "EMBLEMS"})
	createCategory("Stats", {"RANK PROGRESSION", "RECORDS", "ACHIEVEMENTS"})

	sidebarLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
		sidebar.CanvasSize = UDim2.new(0, 0, 0, sidebarLayout.AbsoluteContentSize.Y + 20)
	end)

	-- === MISSIONS & CHALLENGES VIEW ===
	local missionsView = Instance.new("Frame")
	missionsView.Name = "MISSIONS & CHALLENGES"
	missionsView.Size = UDim2.fromScale(1, 1)
	missionsView.BackgroundTransparency = 1
	missionsView.Visible = true
	missionsView.Parent = content

	local missionsLayout = Instance.new("UIListLayout")
	missionsLayout.FillDirection = Enum.FillDirection.Horizontal
	missionsLayout.Padding = UDim.new(0, 30)
	missionsLayout.Parent = missionsView

	-- Mission Panel
	local missionPanel = createContentPanel(missionsView, "Mission - <font color='#00a2ff'>Boot Camp!</font>")
	
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

	local rewardList = Instance.new("Frame")
	rewardList.Size = UDim2.new(1, -40, 0, 140)
	rewardList.Position = UDim2.fromOffset(20, 160)
	rewardList.BackgroundTransparency = 1
	rewardList.Parent = missionPanel

	createRewardCard(rewardList, "XP", "750", false, 0, 0)
	createRewardCard(rewardList, "Clashing Blades", "", true, 120, 0)

	-- Challenges Panel
	local challengesPanel = createContentPanel(missionsView, "Warzone Daily Challenges", "17h 50m")
	
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
	
	local chalRewardList = Instance.new("Frame")
	chalRewardList.Size = UDim2.new(1, -40, 0, 140)
	chalRewardList.Position = UDim2.fromOffset(20, 175)
	chalRewardList.BackgroundTransparency = 1
	chalRewardList.Parent = challengesPanel

	contentViews["MISSIONS & CHALLENGES"] = missionsView

	-- === IDENTITY VIEW ===
	local identityView = Instance.new("ScrollingFrame")
	identityView.Name = "IDENTITY"
	identityView.Size = UDim2.fromScale(1, 1)
	identityView.BackgroundTransparency = 1
	identityView.Visible = false
	identityView.ScrollBarThickness = 4
	identityView.Parent = content

	local identityLayout = Instance.new("UIListLayout")
	identityLayout.Padding = UDim.new(0, 20)
	identityLayout.Parent = identityView

	-- Operator Selection
	local operatorSection = Instance.new("Frame")
	operatorSection.Size = UDim2.new(1, 0, 0, 200)
	operatorSection.BackgroundColor3 = COLORS.Panel
	operatorSection.BackgroundTransparency = 0.4
	operatorSection.Parent = identityView
	Instance.new("UICorner", operatorSection).CornerRadius = UDim.new(0, 8)

	local operatorTitle = Instance.new("TextLabel")
	operatorTitle.Text = "ACTIVE OPERATOR"
	operatorTitle.Font = Enum.Font.GothamBlack
	operatorTitle.TextSize = 18
	operatorTitle.TextColor3 = COLORS.TextMain
	operatorTitle.Size = UDim2.new(1, -40, 0, 40)
	operatorTitle.Position = UDim2.fromOffset(20, 10)
	operatorTitle.TextXAlignment = Enum.TextXAlignment.Left
	operatorTitle.BackgroundTransparency = 1
	operatorTitle.Parent = operatorSection

	-- Operator grid
	local operatorGrid = Instance.new("Frame")
	operatorGrid.Size = UDim2.new(1, -40, 0, 140)
	operatorGrid.Position = UDim2.fromOffset(20, 60)
	operatorGrid.BackgroundTransparency = 1
	operatorGrid.Parent = operatorSection

	local gridLayout = Instance.new("UIGridLayout")
	gridLayout.CellSize = UDim2.new(0, 120, 0, 130)
	gridLayout.CellPadding = UDim2.new(0, 10, 0, 10)
	gridLayout.HorizontalAlignment = Enum.HorizontalAlignment.Left
	gridLayout.Parent = operatorGrid

	for _, operator in ipairs(OperatorData.Operators) do
		local opCard = Instance.new("TextButton")
		opCard.Size = UDim2.new(0, 120, 0, 130)
		opCard.BackgroundColor3 = operator.Unlocked and COLORS.Panel or Color3.fromRGB(20, 20, 20)
		opCard.BackgroundTransparency = operator.Unlocked and 0.3 or 0.7
		opCard.BorderSizePixel = 1
		opCard.BorderColor3 = operator.Unlocked and COLORS.AccentBlue or COLORS.Border
		opCard.Text = ""
		opCard.Parent = operatorGrid
		Instance.new("UICorner", opCard).CornerRadius = UDim.new(0, 4)

		local opName = Instance.new("TextLabel")
		opName.Text = operator.Name
		opName.Font = Enum.Font.GothamBold
		opName.TextSize = 12
		opName.TextColor3 = operator.Unlocked and COLORS.TextMain or COLORS.TextSecondary
		opName.Size = UDim2.new(1, -10, 0, 20)
		opName.Position = UDim2.fromOffset(5, 5)
		opName.BackgroundTransparency = 1
		opName.Parent = opCard

		if not operator.Unlocked then
			local lockIcon = Instance.new("TextLabel")
			lockIcon.Text = "🔒"
			lockIcon.Font = Enum.Font.Gotham
			lockIcon.TextSize = 32
			lockIcon.Size = UDim2.fromScale(1, 1)
			lockIcon.Position = UDim2.fromOffset(0, 20)
			lockIcon.BackgroundTransparency = 1
			lockIcon.Parent = opCard
		end
	end

	-- Calling Cards Section
	local callingCardsSection = operatorSection:Clone()
	callingCardsSection.Name = "CallingCardsSection"
	callingCardsSection.Position = UDim2.new(0, 0, 0, 220)
	callingCardsSection.Parent = identityView

	local ccTitle = callingCardsSection:FindFirstChild("TextLabel")
	if ccTitle then ccTitle.Text = "CALLING CARDS" end

	-- Emblems Section
	local emblemsSection = operatorSection:Clone()
	emblemsSection.Name = "EmblemsSection"
	emblemsSection.Position = UDim2.new(0, 0, 0, 440)
	emblemsSection.Parent = identityView

	local emTitle = emblemsSection:FindFirstChild("TextLabel")
	if emTitle then emTitle.Text = "EMBLEMS" end

	identityLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
		identityView.CanvasSize = UDim2.new(0, 0, 0, identityLayout.AbsoluteContentSize.Y + 20)
	end)

	contentViews["IDENTITY"] = identityView
	contentViews["OPERATORS"] = identityView
	contentViews["CALLING CARDS"] = identityView
	contentViews["EMBLEMS"] = identityView

	-- === RANK PROGRESSION VIEW ===
	local rankView = Instance.new("Frame")
	rankView.Name = "RANK PROGRESSION"
	rankView.Size = UDim2.fromScale(1, 1)
	rankView.BackgroundTransparency = 1
	rankView.Visible = false
	rankView.Parent = content

	local rankPanel = createContentPanel(rankView, "Player Rank", nil)
	rankPanel.Size = UDim2.new(1, 0, 0, 300)

	local profile = PlayerDataController and PlayerDataController.GetProfile() or {}
	local playerLevel = profile.Level or 1
	local playerXP = profile.XP or 0
	local maxXP = profile.MaxXP or 1000

	local rankLabel = Instance.new("TextLabel")
	rankLabel.Text = "RANK " .. playerLevel
	rankLabel.Font = Enum.Font.GothamBlack
	rankLabel.TextSize = 32
	rankLabel.TextColor3 = COLORS.AccentGold
	rankLabel.Size = UDim2.new(1, -40, 0, 50)
	rankLabel.Position = UDim2.fromOffset(20, 60)
	rankLabel.TextXAlignment = Enum.TextXAlignment.Left
	rankLabel.BackgroundTransparency = 1
	rankLabel.Parent = rankPanel

	local xpBarBg = Instance.new("Frame")
	xpBarBg.Size = UDim2.new(1, -40, 0, 20)
	xpBarBg.Position = UDim2.fromOffset(20, 120)
	xpBarBg.BackgroundColor3 = COLORS.Border
	xpBarBg.BorderSizePixel = 0
	xpBarBg.Parent = rankPanel
	Instance.new("UICorner", xpBarBg).CornerRadius = UDim.new(0, 4)

	local xpBarFill = Instance.new("Frame")
	xpBarFill.Size = UDim2.new(playerXP / maxXP, 0, 1, 0)
	xpBarFill.BackgroundColor3 = COLORS.AccentGold
	xpBarFill.BorderSizePixel = 0
	xpBarFill.Parent = xpBarBg
	Instance.new("UICorner", xpBarFill).CornerRadius = UDim.new(0, 4)

	local xpText = Instance.new("TextLabel")
	xpText.Text = playerXP .. " / " .. maxXP .. " XP"
	xpText.Font = Enum.Font.GothamBold
	xpText.TextSize = 14
	xpText.TextColor3 = COLORS.TextMain
	xpText.Size = UDim2.new(1, -40, 1, 0)
	xpText.Position = UDim2.fromOffset(20, 0)
	xpText.BackgroundTransparency = 1
	xpText.Parent = xpBarBg

	contentViews["RANK PROGRESSION"] = rankView

	-- === RECORDS VIEW ===
	local recordsView = Instance.new("ScrollingFrame")
	recordsView.Name = "RECORDS"
	recordsView.Size = UDim2.fromScale(1, 1)
	recordsView.BackgroundTransparency = 1
	recordsView.Visible = false
	recordsView.ScrollBarThickness = 4
	recordsView.Parent = content

	local recordsLayout = Instance.new("UIListLayout")
	recordsLayout.Padding = UDim.new(0, 20)
	recordsLayout.Parent = recordsView

	local function createStatCard(title, value, subtitle)
		local card = Instance.new("Frame")
		card.Size = UDim2.new(0, 300, 0, 100)
		card.BackgroundColor3 = COLORS.Panel
		card.BackgroundTransparency = 0.4
		card.Parent = recordsView
		Instance.new("UICorner", card).CornerRadius = UDim.new(0, 8)

		local titleLabel = Instance.new("TextLabel")
		titleLabel.Text = title
		titleLabel.Font = Enum.Font.GothamBold
		titleLabel.TextSize = 12
		titleLabel.TextColor3 = COLORS.TextSecondary
		titleLabel.Size = UDim2.new(1, -40, 0, 20)
		titleLabel.Position = UDim2.fromOffset(20, 10)
		titleLabel.TextXAlignment = Enum.TextXAlignment.Left
		titleLabel.BackgroundTransparency = 1
		titleLabel.Parent = card

		local valueLabel = Instance.new("TextLabel")
		valueLabel.Text = tostring(value)
		valueLabel.Font = Enum.Font.GothamBlack
		valueLabel.TextSize = 28
		valueLabel.TextColor3 = COLORS.TextMain
		valueLabel.Size = UDim2.new(1, -40, 0, 40)
		valueLabel.Position = UDim2.fromOffset(20, 30)
		valueLabel.TextXAlignment = Enum.TextXAlignment.Left
		valueLabel.BackgroundTransparency = 1
		valueLabel.Parent = card

		if subtitle then
			local subLabel = Instance.new("TextLabel")
			subLabel.Text = subtitle
			subLabel.Font = Enum.Font.Gotham
			subLabel.TextSize = 10
			subLabel.TextColor3 = COLORS.TextSecondary
			subLabel.Size = UDim2.new(1, -40, 0, 20)
			subLabel.Position = UDim2.fromOffset(20, 70)
			subLabel.TextXAlignment = Enum.TextXAlignment.Left
			subLabel.BackgroundTransparency = 1
			subLabel.Parent = card
		end

		return card
	end

	createStatCard("WINS", "0", "Total Victories")
	createStatCard("KILLS", "0", "Total Eliminations")
	createStatCard("DEATHS", "0", "Total Deaths")
	createStatCard("K/D RATIO", "0.00", "Kills per Death")
	createStatCard("MATCHES PLAYED", "0", "Total Matches")
	createStatCard("AVG PLACEMENT", "N/A", "Average Finish Position")

	recordsLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
		recordsView.CanvasSize = UDim2.new(0, 0, 0, recordsLayout.AbsoluteContentSize.Y + 20)
	end)

	contentViews["RECORDS"] = recordsView

	-- === ACHIEVEMENTS VIEW ===
	local achievementsView = Instance.new("ScrollingFrame")
	achievementsView.Name = "ACHIEVEMENTS"
	achievementsView.Size = UDim2.fromScale(1, 1)
	achievementsView.BackgroundTransparency = 1
	achievementsView.Visible = false
	achievementsView.ScrollBarThickness = 4
	achievementsView.Parent = content

	local achievementsLayout = Instance.new("UIGridLayout")
	achievementsLayout.CellSize = UDim2.new(0, 200, 0, 150)
	achievementsLayout.CellPadding = UDim2.new(0, 20, 0, 20)
	achievementsLayout.HorizontalAlignment = Enum.HorizontalAlignment.Left
	achievementsLayout.Parent = achievementsView

	local achievements = {
		{Name = "First Blood", Desc = "Get your first kill", Unlocked = true},
		{Name = "Victory Royale", Desc = "Win a match", Unlocked = false},
		{Name = "Kill Master", Desc = "Get 10 kills in a match", Unlocked = false},
		{Name = "Survivor", Desc = "Reach top 10", Unlocked = true},
		{Name = "Weapon Master", Desc = "Unlock all attachments", Unlocked = false},
		{Name = "Elite", Desc = "Reach Rank 50", Unlocked = false},
	}

	for _, achievement in ipairs(achievements) do
		local achCard = Instance.new("Frame")
		achCard.Size = UDim2.new(0, 200, 0, 150)
		achCard.BackgroundColor3 = achievement.Unlocked and COLORS.Panel or Color3.fromRGB(20, 20, 20)
		achCard.BackgroundTransparency = achievement.Unlocked and 0.3 or 0.7
		achCard.BorderSizePixel = 1
		achCard.BorderColor3 = achievement.Unlocked and COLORS.AccentGold or COLORS.Border
		achCard.Parent = achievementsView
		Instance.new("UICorner", achCard).CornerRadius = UDim.new(0, 8)

		local icon = Instance.new("TextLabel")
		icon.Text = achievement.Unlocked and "🏆" or "🔒"
		icon.Font = Enum.Font.Gotham
		icon.TextSize = 48
		icon.Size = UDim2.new(1, 0, 0, 60)
		icon.Position = UDim2.fromOffset(0, 10)
		icon.BackgroundTransparency = 1
		icon.Parent = achCard

		local nameLabel = Instance.new("TextLabel")
		nameLabel.Text = achievement.Name
		nameLabel.Font = Enum.Font.GothamBold
		nameLabel.TextSize = 14
		nameLabel.TextColor3 = achievement.Unlocked and COLORS.TextMain or COLORS.TextSecondary
		nameLabel.Size = UDim2.new(1, -20, 0, 30)
		nameLabel.Position = UDim2.fromOffset(10, 70)
		nameLabel.BackgroundTransparency = 1
		nameLabel.TextWrapped = true
		nameLabel.Parent = achCard

		local descLabel = Instance.new("TextLabel")
		descLabel.Text = achievement.Desc
		descLabel.Font = Enum.Font.Gotham
		descLabel.TextSize = 10
		descLabel.TextColor3 = COLORS.TextSecondary
		descLabel.Size = UDim2.new(1, -20, 0, 40)
		descLabel.Position = UDim2.fromOffset(10, 100)
		descLabel.BackgroundTransparency = 1
		descLabel.TextWrapped = true
		descLabel.Parent = achCard
	end

	achievementsLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
		achievementsView.CanvasSize = UDim2.new(0, 0, 0, achievementsLayout.AbsoluteContentSize.Y + 20)
	end)

	contentViews["ACHIEVEMENTS"] = achievementsView

	-- Data sync
	local function updateProfile(profile)
		profile = profile or {}
		if profile.ActiveMission then
			local mission = profile.ActiveMission
			missionPanel.TitleLabel.Text = "Mission - <font color='#00a2ff'>" .. mission.Title .. "</font>"
			missionObj.Text = mission.Objective
			local prog = (mission.Progress or 0) / (mission.Goal or 1)
			progressFill.Size = UDim2.fromScale(prog, 1)
			progressText.Text = (mission.Progress or 0) .. "/" .. (mission.Goal or 1)
		end
		
		-- Update rank
		if rankView.Visible then
			local level = profile.Level or 1
			local xp = profile.XP or 0
			local maxXP = profile.MaxXP or 1000
			rankLabel.Text = "RANK " .. level
			xpBarFill.Size = UDim2.new(xp / maxXP, 0, 1, 0)
			xpText.Text = xp .. " / " .. maxXP .. " XP"
		end
	end

	local function updateChallenges(challenges)
		if #challenges == 0 then return end
		local challenge = challenges[1]
		challengeObj.Text = challenge.Title
		local prog = (challenge.Progress or 0) / (challenge.Goal or 1)
		chalProgressBg:FindFirstChildOfClass("Frame").Size = UDim2.fromScale(prog, 1)
	end

	if PlayerDataController then
		table.insert(connections, PlayerDataController.ProfileChanged.Event:Connect(updateProfile))
		table.insert(connections, PlayerDataController.ChallengesChanged.Event:Connect(updateChallenges))
		updateProfile(PlayerDataController.GetProfile())
		updateChallenges(PlayerDataController.GetChallenges())
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
