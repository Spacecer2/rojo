--[[
	GunsmithUI - Attachment selection and stat preview interface
	Integrates with GunsmithService for attachment validation and stat calculation
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local WeaponData = require(ReplicatedStorage.Shared.Constants.WeaponData)
local AttachmentData = require(ReplicatedStorage.Shared.Constants.AttachmentData)
local WeaponUtils = require(ReplicatedStorage.Shared.Utils.WeaponUtils)

local GunsmithUI = {}

-- Theme colors
local COLORS = {
	Background = Color3.fromRGB(15, 15, 15),
	Panel = Color3.fromRGB(30, 30, 35),
	AccentBlue = Color3.fromRGB(0, 162, 255),
	AccentGold = Color3.fromRGB(255, 215, 0),
	TextMain = Color3.fromRGB(255, 255, 255),
	TextSecondary = Color3.fromRGB(180, 180, 180),
	Positive = Color3.fromRGB(0, 255, 0),
	Negative = Color3.fromRGB(255, 0, 0),
}

-- Create stat bar for comparison
local function createStatBar(parent, statName, baseValue, modifiedValue, maxValue, yOffset)
	local container = Instance.new("Frame")
	container.Size = UDim2.new(1, -40, 0, 30)
	container.Position = UDim2.new(0, 20, 0, yOffset)
	container.BackgroundTransparency = 1
	container.Parent = parent
	
	-- Stat name
	local nameLabel = Instance.new("TextLabel")
	nameLabel.Size = UDim2.new(0, 120, 1, 0)
	nameLabel.Position = UDim2.new(0, 0, 0, 0)
	nameLabel.BackgroundTransparency = 1
	nameLabel.Text = statName
	nameLabel.TextColor3 = COLORS.TextSecondary
	nameLabel.Font = Enum.Font.GothamMedium
	nameLabel.TextSize = 12
	nameLabel.TextXAlignment = Enum.TextXAlignment.Left
	nameLabel.Parent = container
	
	-- Base value bar
	local baseBarBg = Instance.new("Frame")
	baseBarBg.Size = UDim2.new(0, 150, 0, 8)
	baseBarBg.Position = UDim2.new(0, 130, 0, 11)
	baseBarBg.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
	baseBarBg.BorderSizePixel = 0
	baseBarBg.Parent = container
	Instance.new("UICorner", baseBarBg).CornerRadius = UDim.new(0, 2)
	
	local baseBarFill = Instance.new("Frame")
	baseBarFill.Size = UDim2.new(math.clamp(baseValue / maxValue, 0, 1), 0, 1, 0)
	baseBarFill.BackgroundColor3 = COLORS.TextSecondary
	baseBarFill.BorderSizePixel = 0
	baseBarFill.Parent = baseBarBg
	Instance.new("UICorner", baseBarFill).CornerRadius = UDim.new(0, 2)
	
	-- Modified value bar
	local modBarBg = Instance.new("Frame")
	modBarBg.Size = UDim2.new(0, 150, 0, 8)
	modBarBg.Position = UDim2.new(0, 290, 0, 11)
	modBarBg.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
	modBarBg.BorderSizePixel = 0
	modBarBg.Parent = container
	Instance.new("UICorner", modBarBg).CornerRadius = UDim.new(0, 2)
	
	local modBarFill = Instance.new("Frame")
	local modPercent = math.clamp(modifiedValue / maxValue, 0, 1)
	modBarFill.Size = UDim2.new(modPercent, 0, 1, 0)
	modBarFill.BackgroundColor3 = modifiedValue > baseValue and COLORS.Positive or (modifiedValue < baseValue and COLORS.Negative or COLORS.AccentBlue)
	modBarFill.BorderSizePixel = 0
	modBarFill.Parent = modBarBg
	Instance.new("UICorner", modBarFill).CornerRadius = UDim.new(0, 2)
	
	-- Change indicator
	local changeLabel = Instance.new("TextLabel")
	changeLabel.Size = UDim2.new(0, 60, 1, 0)
	changeLabel.Position = UDim2.new(1, -60, 0, 0)
	changeLabel.BackgroundTransparency = 1
	local change = modifiedValue - baseValue
	local changePercent = (change / baseValue) * 100
	if change > 0 then
		changeLabel.Text = "+" .. string.format("%.1f%%", changePercent)
		changeLabel.TextColor3 = COLORS.Positive
	elseif change < 0 then
		changeLabel.Text = string.format("%.1f%%", changePercent)
		changeLabel.TextColor3 = COLORS.Negative
	else
		changeLabel.Text = "0%"
		changeLabel.TextColor3 = COLORS.TextSecondary
	end
	changeLabel.Font = Enum.Font.GothamBold
	changeLabel.TextSize = 11
	changeLabel.TextXAlignment = Enum.TextXAlignment.Right
	changeLabel.Parent = container
	
	return container
end

-- Create attachment slot UI
local function createAttachmentSlot(parent, slotName, weaponName, currentAttachment, yOffset, onSelect)
	local container = Instance.new("Frame")
	container.Size = UDim2.new(1, -40, 0, 60)
	container.Position = UDim2.new(0, 20, 0, yOffset)
	container.BackgroundColor3 = COLORS.Panel
	container.BackgroundTransparency = 0.3
	container.BorderSizePixel = 0
	container.Parent = parent
	Instance.new("UICorner", container).CornerRadius = UDim.new(0, 4)
	
	-- Slot name
	local slotLabel = Instance.new("TextLabel")
	slotLabel.Size = UDim2.new(0, 150, 0, 20)
	slotLabel.Position = UDim2.new(0, 10, 0, 5)
	slotLabel.BackgroundTransparency = 1
	slotLabel.Text = slotName:upper()
	slotLabel.TextColor3 = COLORS.TextSecondary
	slotLabel.Font = Enum.Font.GothamBold
	slotLabel.TextSize = 12
	slotLabel.TextXAlignment = Enum.TextXAlignment.Left
	slotLabel.Parent = container
	
	-- Current attachment name
	local currentLabel = Instance.new("TextLabel")
	currentLabel.Size = UDim2.new(1, -20, 0, 20)
	currentLabel.Position = UDim2.new(0, 10, 0, 25)
	currentLabel.BackgroundTransparency = 1
	currentLabel.Text = currentAttachment or "None"
	currentLabel.TextColor3 = currentAttachment and COLORS.TextMain or COLORS.TextSecondary
	currentLabel.Font = Enum.Font.Gotham
	currentLabel.TextSize = 14
	currentLabel.TextXAlignment = Enum.TextXAlignment.Left
	currentLabel.Parent = container
	
	-- Select button
	local selectButton = Instance.new("TextButton")
	selectButton.Size = UDim2.new(0, 100, 0, 30)
	selectButton.Position = UDim2.new(1, -110, 0, 15)
	selectButton.BackgroundColor3 = COLORS.AccentBlue
	selectButton.BorderSizePixel = 0
	selectButton.Text = "SELECT"
	selectButton.TextColor3 = COLORS.TextMain
	selectButton.Font = Enum.Font.GothamBold
	selectButton.TextSize = 12
	selectButton.Parent = container
	Instance.new("UICorner", selectButton).CornerRadius = UDim.new(0, 4)
	
	selectButton.MouseButton1Click:Connect(function()
		if onSelect then
			onSelect(slotName)
		end
	end)
	
	return container, currentLabel
end

-- Create attachment selection modal
local function createAttachmentModal(parent, slotName, weaponName, availableAttachments, currentAttachment, onSelect)
	local modal = Instance.new("Frame")
	modal.Size = UDim2.fromScale(1, 1)
	modal.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
	modal.BackgroundTransparency = 0.3
	modal.Parent = parent
	
	local modalContent = Instance.new("Frame")
	modalContent.Size = UDim2.new(0, 600, 0, 500)
	modalContent.Position = UDim2.new(0.5, 0, 0.5, 0)
	modalContent.AnchorPoint = Vector2.new(0.5, 0.5)
	modalContent.BackgroundColor3 = COLORS.Background
	modalContent.BorderSizePixel = 0
	modalContent.Parent = modal
	Instance.new("UICorner", modalContent).CornerRadius = UDim.new(0, 8)
	
	-- Title
	local title = Instance.new("TextLabel")
	title.Size = UDim2.new(1, -40, 0, 40)
	title.Position = UDim2.new(0, 20, 0, 10)
	title.BackgroundTransparency = 1
	title.Text = "SELECT " .. slotName:upper()
	title.TextColor3 = COLORS.TextMain
	title.Font = Enum.Font.GothamBlack
	title.TextSize = 20
	title.TextXAlignment = Enum.TextXAlignment.Left
	title.Parent = modalContent
	
	-- Scroll frame for attachments
	local scrollFrame = Instance.new("ScrollingFrame")
	scrollFrame.Size = UDim2.new(1, -40, 1, -100)
	scrollFrame.Position = UDim2.new(0, 20, 0, 60)
	scrollFrame.BackgroundTransparency = 1
	scrollFrame.ScrollBarThickness = 4
	scrollFrame.Parent = modalContent
	
	local layout = Instance.new("UIListLayout")
	layout.Padding = UDim.new(0, 5)
	layout.Parent = scrollFrame
	
	-- Close button
	local closeButton = Instance.new("TextButton")
	closeButton.Size = UDim2.new(0, 100, 0, 35)
	closeButton.Position = UDim2.new(1, -120, 1, -45)
	closeButton.BackgroundColor3 = COLORS.Panel
	closeButton.BorderSizePixel = 0
	closeButton.Text = "CLOSE"
	closeButton.TextColor3 = COLORS.TextMain
	closeButton.Font = Enum.Font.GothamBold
	closeButton.TextSize = 14
	closeButton.Parent = modalContent
	Instance.new("UICorner", closeButton).CornerRadius = UDim.new(0, 4)
	
	closeButton.MouseButton1Click:Connect(function()
		modal:Destroy()
	end)
	
	-- Create attachment buttons
	local attachments = availableAttachments[slotName] or {}
	local yOffset = 0
	for attachmentName, attachmentData in pairs(attachments) do
		local attachmentButton = Instance.new("TextButton")
		attachmentButton.Size = UDim2.new(1, -10, 0, 50)
		attachmentButton.Position = UDim2.new(0, 5, 0, yOffset)
		attachmentButton.BackgroundColor3 = attachmentName == currentAttachment and COLORS.AccentBlue or COLORS.Panel
		attachmentButton.BackgroundTransparency = attachmentName == currentAttachment and 0.5 or 0.3
		attachmentButton.BorderSizePixel = 0
		attachmentButton.Text = ""
		attachmentButton.Parent = scrollFrame
		Instance.new("UICorner", attachmentButton).CornerRadius = UDim.new(0, 4)
		
		local nameLabel = Instance.new("TextLabel")
		nameLabel.Size = UDim2.new(1, -20, 0, 25)
		nameLabel.Position = UDim2.new(0, 10, 0, 5)
		nameLabel.BackgroundTransparency = 1
		nameLabel.Text = attachmentName
		nameLabel.TextColor3 = COLORS.TextMain
		nameLabel.Font = Enum.Font.GothamBold
		nameLabel.TextSize = 14
		nameLabel.TextXAlignment = Enum.TextXAlignment.Left
		nameLabel.Parent = attachmentButton
		
		local descLabel = Instance.new("TextLabel")
		descLabel.Size = UDim2.new(1, -20, 0, 20)
		descLabel.Position = UDim2.new(0, 10, 0, 30)
		descLabel.BackgroundTransparency = 1
		descLabel.Text = attachmentData.Description or ""
		descLabel.TextColor3 = COLORS.TextSecondary
		descLabel.Font = Enum.Font.Gotham
		descLabel.TextSize = 11
		descLabel.TextXAlignment = Enum.TextXAlignment.Left
		descLabel.TextWrapped = true
		descLabel.Parent = attachmentButton
		
		attachmentButton.MouseButton1Click:Connect(function()
			if onSelect then
				onSelect(attachmentName)
			end
			modal:Destroy()
		end)
		
		yOffset = yOffset + 55
	end
	
	layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
		scrollFrame.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + 10)
	end)
	
	return modal
end

-- Create Gunsmith UI
function GunsmithUI.Create(parent, weaponName, currentAttachments, onAttachmentChange)
	local container = Instance.new("Frame")
	container.Name = "GunsmithUI"
	container.Size = UDim2.fromScale(1, 1)
	container.BackgroundTransparency = 1
	container.Parent = parent
	
	-- Left panel: Attachment slots
	local leftPanel = Instance.new("ScrollingFrame")
	leftPanel.Name = "AttachmentSlots"
	leftPanel.Size = UDim2.new(0, 400, 1, -40)
	leftPanel.Position = UDim2.new(0, 20, 0, 20)
	leftPanel.BackgroundTransparency = 1
	leftPanel.ScrollBarThickness = 4
	leftPanel.Parent = container
	
	local slotLayout = Instance.new("UIListLayout")
	slotLayout.Padding = UDim.new(0, 10)
	slotLayout.Parent = leftPanel
	
	-- Right panel: Stat comparison
	local rightPanel = Instance.new("Frame")
	rightPanel.Name = "StatComparison"
	rightPanel.Size = UDim2.new(0, 400, 1, -40)
	rightPanel.Position = UDim2.new(1, -420, 0, 20)
	rightPanel.AnchorPoint = Vector2.new(1, 0)
	rightPanel.BackgroundColor3 = COLORS.Panel
	rightPanel.BackgroundTransparency = 0.3
	rightPanel.Parent = container
	Instance.new("UICorner", rightPanel).CornerRadius = UDim.new(0, 8)
	
	local statTitle = Instance.new("TextLabel")
	statTitle.Size = UDim2.new(1, -40, 0, 40)
	statTitle.Position = UDim2.new(0, 20, 0, 10)
	statTitle.BackgroundTransparency = 1
	statTitle.Text = "STAT COMPARISON"
	statTitle.TextColor3 = COLORS.TextMain
	statTitle.Font = Enum.Font.GothamBlack
	statTitle.TextSize = 18
	statTitle.TextXAlignment = Enum.TextXAlignment.Left
	statTitle.Parent = rightPanel
	
	local statContainer = Instance.new("ScrollingFrame")
	statContainer.Size = UDim2.new(1, -40, 1, -60)
	statContainer.Position = UDim2.new(0, 20, 0, 50)
	statContainer.BackgroundTransparency = 1
	statContainer.ScrollBarThickness = 4
	statContainer.Parent = rightPanel
	
	local statLayout = Instance.new("UIListLayout")
	statLayout.Padding = UDim.new(0, 5)
	statLayout.Parent = statContainer
	
	-- Get weapon data
	local weaponData = WeaponData.Weapons[weaponName]
	if not weaponData then
		warn("[GunsmithUI] Weapon not found: " .. weaponName)
		return container
	end
	
	-- Get available attachments by slot
	local availableAttachments = {}
	for _, slot in ipairs(weaponData.Slots) do
		availableAttachments[slot] = {}
		for attachmentName, attachmentData in pairs(AttachmentData.Attachments) do
			if attachmentData.Category == slot then
				availableAttachments[slot][attachmentName] = attachmentData
			end
		end
	end
	
	-- Update stats display
	local function updateStats()
		-- Clear existing stats
		for _, child in ipairs(statContainer:GetChildren()) do
			if child:IsA("Frame") then
				child:Destroy()
			end
		end
		
		-- Calculate base and modified stats
		local baseStats = WeaponUtils.CalculateStats(weaponName, {})
		local modifiedStats = WeaponUtils.CalculateStats(weaponName, currentAttachments or {})
		
		if baseStats and modifiedStats then
			local yOffset = 0
			
			-- Damage (chest)
			createStatBar(statContainer, "Damage", baseStats.Damage.Chest, modifiedStats.Damage.Chest, 50, yOffset)
			yOffset = yOffset + 35
			
			-- Range
			createStatBar(statContainer, "Range", baseStats.Range.Max, modifiedStats.Range.Max, 150, yOffset)
			yOffset = yOffset + 35
			
			-- Fire Rate
			createStatBar(statContainer, "Fire Rate", baseStats.FireRate, modifiedStats.FireRate, 1000, yOffset)
			yOffset = yOffset + 35
			
			-- Mobility (movement speed)
			createStatBar(statContainer, "Mobility", baseStats.Mobility.MovementSpeed, modifiedStats.Mobility.MovementSpeed, 1.5, yOffset)
			yOffset = yOffset + 35
			
			-- Recoil Control (inverse of recoil)
			local baseRecoil = baseStats.Recoil.Vertical + baseStats.Recoil.Horizontal
			local modRecoil = modifiedStats.Recoil.Vertical + modifiedStats.Recoil.Horizontal
			createStatBar(statContainer, "Control", 1 / (baseRecoil + 0.1), 1 / (modRecoil + 0.1), 2, yOffset)
			yOffset = yOffset + 35
			
			-- ADS Speed (inverse)
			createStatBar(statContainer, "ADS Speed", 1 / (baseStats.Mobility.ADSSpeed + 0.1), 1 / (modifiedStats.Mobility.ADSSpeed + 0.1), 10, yOffset)
		end
		
		statLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
			statContainer.CanvasSize = UDim2.new(0, 0, 0, statLayout.AbsoluteContentSize.Y + 10)
		end)
	end
	
	-- Create attachment slots
	local slotLabels = {}
	local yOffset = 0
	for _, slot in ipairs(weaponData.Slots) do
		local currentAttachment = nil
		if currentAttachments then
			for _, attName in ipairs(currentAttachments) do
				local attData = AttachmentData.Attachments[attName]
				if attData and attData.Category == slot then
					currentAttachment = attName
					break
				end
			end
		end
		
		local slotFrame, labelRef = createAttachmentSlot(
			leftPanel,
			slot,
			weaponName,
			currentAttachment,
			yOffset,
			function()
				-- Open attachment selection modal
				createAttachmentModal(
					container,
					slot,
					weaponName,
					availableAttachments,
					currentAttachment,
					function(selectedAttachment)
						-- Update current attachment
						if currentAttachments then
							-- Remove old attachment in this slot
							for i = #currentAttachments, 1, -1 do
								local attData = AttachmentData.Attachments[currentAttachments[i]]
								if attData and attData.Category == slot then
									table.remove(currentAttachments, i)
								end
							end
							-- Add new attachment
							table.insert(currentAttachments, selectedAttachment)
						else
							currentAttachments = {selectedAttachment}
						end
						
						-- Update UI
						labelRef.Text = selectedAttachment
						labelRef.TextColor3 = COLORS.TextMain
						updateStats()
						
						-- Notify parent
						if onAttachmentChange then
							onAttachmentChange(currentAttachments)
						end
					end
				)
			end
		)
		
		slotLabels[slot] = labelRef
		yOffset = yOffset + 70
	end
	
	slotLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
		leftPanel.CanvasSize = UDim2.new(0, 0, 0, slotLayout.AbsoluteContentSize.Y + 10)
	end)
	
	-- Initial stats update
	updateStats()
	
	return container
end

return GunsmithUI
