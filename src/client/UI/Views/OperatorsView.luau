--[[
	OperatorsView - Character selection interface
	Inspired by the provide reference image (Warzone style)
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")

local Constants = ReplicatedStorage:WaitForChild("Constants")
local Theme = require(Constants:WaitForChild("Theme"))

local OperatorData = {Operators = {}}
local success, operatorDataModule = pcall(function() return require(Constants:WaitForChild("OperatorData")) end)
if success and operatorDataModule then OperatorData = operatorDataModule end

local Utils = ReplicatedStorage:WaitForChild("Utils")
local OperatorRanking = require(Utils:WaitForChild("OperatorRanking"))

local OperatorsView = {}

local COLORS = (Theme and Theme.Colors) or {
	Background = Color3.fromRGB(15, 15, 15),
	Panel = Color3.fromRGB(30, 30, 35),
	AccentBlue = Color3.fromRGB(0, 162, 255),
	AccentGold = Color3.fromRGB(255, 215, 0),
	TextMain = Color3.fromRGB(255, 255, 255),
	TextSecondary = Color3.fromRGB(180, 180, 180),
}

function OperatorsView.Create(parent)
	local connections = {}
	local player = Players.LocalPlayer
	local frame = Instance.new("Frame")
	frame.Name = "OperatorsView"
	frame.Size = UDim2.fromScale(1, 1)
	frame.BackgroundTransparency = 1
	frame.Parent = parent
	
	-- 1. Progress Header (Top Left)
	local header = Instance.new("Frame")
	header.Name = "Header"
	header.Size = UDim2.new(0, 400, 0, 50)
	header.Position = UDim2.fromOffset(40, 20)
	header.BackgroundTransparency = 1
	header.Parent = frame
	
	local unlockedLabel = Instance.new("TextLabel")
	unlockedLabel.Name = "UnlockedLabel"
	unlockedLabel.Text = "0/0 OPERATORS UNLOCKED"
	unlockedLabel.Font = Enum.Font.GothamBold
	unlockedLabel.TextSize = 14
	unlockedLabel.TextColor3 = COLORS.TextSecondary
	unlockedLabel.Size = UDim2.new(1, 0, 0, 20)
	unlockedLabel.BackgroundTransparency = 1
	unlockedLabel.TextXAlignment = Enum.TextXAlignment.Left
	unlockedLabel.Parent = header
	
	local progressBg = Instance.new("Frame")
	progressBg.Name = "ProgressBackground"
	progressBg.Size = UDim2.new(0, 300, 0, 4)
	progressBg.Position = UDim2.fromOffset(0, 25)
	progressBg.BackgroundColor3 = Color3.fromRGB(60, 60, 65)
	progressBg.BorderSizePixel = 0
	progressBg.Parent = header
	
	local progressFill = Instance.new("Frame")
	progressFill.Name = "Fill"
	progressFill.Size = UDim2.fromScale(0, 1)
	progressFill.BackgroundColor3 = COLORS.AccentBlue
	progressFill.BorderSizePixel = 0
	progressFill.Parent = progressBg

	-- Bind ranking UI to update dynamically
	if player then
		table.insert(connections, OperatorRanking.BindToLabel(unlockedLabel, player))
		table.insert(connections, OperatorRanking.BindToProgressBar(progressBg, player))
	end

	-- 2. Detail Section (Left Center)
	local detailPanel = Instance.new("Frame")
	detailPanel.Name = "DetailPanel"
	detailPanel.Size = UDim2.new(0, 300, 0, 200)
	detailPanel.Position = UDim2.fromOffset(40, 100)
	detailPanel.BackgroundTransparency = 1
	detailPanel.Parent = frame
	
	local opName = Instance.new("TextLabel")
	opName.Name = "OpName"
	opName.Text = "T-800"
	opName.Font = Enum.Font.GothamBlack
	opName.TextSize = 48
	opName.TextColor3 = COLORS.TextMain
	opName.Size = UDim2.new(1, 0, 0, 55)
	opName.BackgroundTransparency = 1
	opName.TextXAlignment = Enum.TextXAlignment.Left
	opName.Parent = detailPanel
	
	local skinInfo = Instance.new("Frame")
	skinInfo.Size = UDim2.new(0, 200, 0, 40)
	skinInfo.Position = UDim2.fromOffset(0, 65)
	skinInfo.BackgroundColor3 = Color3.new(0,0,0)
	skinInfo.BackgroundTransparency = 0.6
	skinInfo.Parent = detailPanel
	
	local skinLabel = Instance.new("TextLabel")
	skinLabel.Name = "SkinLabel"
	skinLabel.Text = "OPERATOR SKINS\nLOADING..."
	skinLabel.Font = Enum.Font.GothamBold
	skinLabel.TextSize = 10
	skinLabel.TextColor3 = COLORS.AccentBlue
	skinLabel.Size = UDim2.fromScale(1, 1)
	skinLabel.Position = UDim2.fromOffset(10, 0)
	skinLabel.BackgroundTransparency = 1
	skinLabel.TextXAlignment = Enum.TextXAlignment.Left
	skinLabel.Parent = skinInfo
	
	local moveInfo = Instance.new("Frame")
	moveInfo.Size = UDim2.new(0, 200, 0, 40)
	moveInfo.Position = UDim2.fromOffset(0, 110)
	moveInfo.BackgroundColor3 = Color3.new(0,0,0)
	moveInfo.BackgroundTransparency = 0.6
	moveInfo.Parent = detailPanel
	
	local moveLabel = Instance.new("TextLabel")
	moveLabel.Text = "FINISHING MOVE\nHOOK & SLASH"
	moveLabel.Font = Enum.Font.GothamBold
	moveLabel.TextSize = 10
	moveLabel.TextColor3 = COLORS.TextMain
	moveLabel.Size = UDim2.fromScale(1, 1)
	moveLabel.Position = UDim2.fromOffset(10, 0)
	moveLabel.BackgroundTransparency = 1
	moveLabel.TextXAlignment = Enum.TextXAlignment.Left
	moveLabel.Parent = moveInfo

	-- 3. Grid Section (Center Bottom)
	local scrollFrame = Instance.new("ScrollingFrame")
	scrollFrame.Name = "OperatorGrid"
	scrollFrame.Size = UDim2.new(1, -80, 0, 300)
	scrollFrame.Position = UDim2.new(0, 40, 1, -40)
	scrollFrame.AnchorPoint = Vector2.new(0, 1)
	scrollFrame.BackgroundTransparency = 1
	scrollFrame.ScrollBarThickness = 2
	scrollFrame.ScrollBarImageColor3 = COLORS.AccentBlue
	scrollFrame.Parent = frame
	
	local gridLayout = Instance.new("UIGridLayout")
	gridLayout.CellSize = UDim2.fromOffset(110, 140)
	gridLayout.CellPadding = UDim2.fromOffset(10, 10)
	gridLayout.SortOrder = Enum.SortOrder.LayoutOrder
	gridLayout.Parent = scrollFrame
	
	local function createOpTile(op)
		local tile = Instance.new("Frame")
		tile.BackgroundColor3 = COLORS.Panel
		tile.BackgroundTransparency = 0.1
		tile.BorderSizePixel = 1
		tile.BorderColor3 = Color3.fromRGB(60, 60, 65)
		
		local portrait = Instance.new("ImageLabel")
		portrait.Size = UDim2.fromScale(1, 1)
		portrait.Image = op.Portrait or ""
		portrait.BackgroundTransparency = 1
		portrait.Parent = tile
		
		if not op.Unlocked then
			local lock = Instance.new("Frame")
			lock.Size = UDim2.fromOffset(24, 24)
			lock.Position = UDim2.new(0.5, 0, 0.5, 0)
			lock.AnchorPoint = Vector2.new(0.5, 0.5)
			lock.BackgroundColor3 = Color3.fromRGB(0,0,0)
			lock.BackgroundTransparency = 0.5
			lock.Parent = tile
			portrait.ImageColor3 = Color3.fromRGB(100, 100, 100)
		end
		
		local nameTag = Instance.new("TextLabel")
		nameTag.Text = op.Name:upper()
		nameTag.Font = Enum.Font.GothamBold
		nameTag.TextSize = 10
		nameTag.TextColor3 = COLORS.TextMain
		nameTag.Size = UDim2.new(1, 0, 0, 20)
		nameTag.Position = UDim2.new(0, 0, 1, 0)
		nameTag.AnchorPoint = Vector2.new(0, 1)
		nameTag.BackgroundColor3 = Color3.new(0,0,0)
		nameTag.BackgroundTransparency = 0.5
		nameTag.Parent = tile
		
		-- Selection logic
		local btn = Instance.new("TextButton")
		btn.Size = UDim2.fromScale(1, 1)
		btn.BackgroundTransparency = 1
		btn.Text = ""
		btn.Parent = tile
		
		table.insert(connections, btn.MouseEnter:Connect(function()
			tile.BorderColor3 = COLORS.AccentBlue
			tile.BorderSizePixel = 2
		end))
		
		table.insert(connections, btn.MouseLeave:Connect(function()
			tile.BorderColor3 = Color3.fromRGB(60, 60, 65)
			tile.BorderSizePixel = 1
		end))
		
		table.insert(connections, btn.MouseButton1Click:Connect(function()
			opName.Text = op.Name
			-- Dynamically calculate unlocked skins based on player data
			local skinCount = op.Skins or 0
			local unlockedSkins = OperatorRanking.IsOperatorUnlocked(player, op.Id) and skinCount or 0
			skinLabel.Text = string.format("OPERATOR SKINS\n%d/%d UNLOCKED", unlockedSkins, skinCount)
			moveLabel.Text = string.format("FINISHING MOVE\n%s", op.FinishingMove or "UNASSIGNED")
		end))
		
		return tile
	end
	
	for _, op in ipairs(OperatorData.Operators) do
		createOpTile(op).Parent = scrollFrame
	end
	
	-- 4. Action Buttons (Bottom Bar Right-ish)
	local actions = Instance.new("Frame")
	actions.Name = "Actions"
	actions.Size = UDim2.new(0, 500, 0, 40)
	actions.Position = UDim2.new(1, -40, 1, -350)
	actions.AnchorPoint = Vector2.new(1, 1)
	actions.BackgroundTransparency = 1
	actions.Parent = frame
	
	local actionLayout = Instance.new("UIListLayout")
	actionLayout.FillDirection = Enum.FillDirection.Horizontal
	actionLayout.HorizontalAlignment = Enum.HorizontalAlignment.Right
	actionLayout.Padding = UDim.new(0, 30)
	actionLayout.Parent = actions
	
	local function createAction(text)
		local container = Instance.new("Frame")
		container.Size = UDim2.fromOffset(80, 30)
		container.BackgroundTransparency = 1
		
		local label = Instance.new("TextLabel")
		label.Text = "⚪ " .. text -- Mock icon
		label.Font = Enum.Font.GothamBold
		label.TextSize = 10
		label.TextColor3 = COLORS.TextSecondary
		label.Size = UDim2.fromScale(1, 1)
		label.BackgroundTransparency = 1
		label.Parent = container
		
		return container
	end
	
	createAction("EQUIP").Parent = actions
	createAction("CUSTOMIZE").Parent = actions
	createAction("PREVIEW").Parent = actions
	createAction("BIO").Parent = actions
	
	return {
		Instance = frame,
		Destroy = function()
			for _, c in ipairs(connections) do c:Disconnect() end
			frame:Destroy()
		end
	}
end

return OperatorsView
