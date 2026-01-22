--[[
	SettingsView - Comprehensive settings menu with Input, Audio, Graphics, and Accessibility tabs
	Follows the ViewManager pattern with Create function returning Instance and Destroy
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

-- SettingsManager is in client/Settings, access via relative path
local SettingsManager = require(script.Parent.Parent.Parent.Settings.SettingsManager)
local SettingsData = require(ReplicatedStorage.Shared.Settings.SettingsData)

local SettingsView = {}

-- Theme colors (fallback if Theme not available)
local COLORS = {
	Background = Color3.fromRGB(15, 15, 15),
	Panel = Color3.fromRGB(30, 30, 35),
	AccentBlue = Color3.fromRGB(0, 162, 255),
	TextMain = Color3.fromRGB(255, 255, 255),
	TextSecondary = Color3.fromRGB(180, 180, 180),
	SliderBg = Color3.fromRGB(40, 40, 45),
	SliderFill = Color3.fromRGB(100, 200, 255),
}

-- Create a slider control
local function createSlider(parent, label, min, max, step, defaultValue, category, key, yOffset)
	local container = Instance.new("Frame")
	container.Size = UDim2.new(1, -40, 0, 50)
	container.Position = UDim2.new(0, 20, 0, yOffset)
	container.BackgroundTransparency = 1
	container.Parent = parent
	
	-- Label
	local labelText = Instance.new("TextLabel")
	labelText.Size = UDim2.new(0.5, 0, 0, 20)
	labelText.Position = UDim2.new(0, 0, 0, 0)
	labelText.BackgroundTransparency = 1
	labelText.Text = label
	labelText.TextColor3 = COLORS.TextSecondary
	labelText.TextXAlignment = Enum.TextXAlignment.Left
	labelText.Font = Enum.Font.GothamMedium
	labelText.TextSize = 14
	labelText.Parent = container
	
	-- Value label
	local valueLabel = Instance.new("TextLabel")
	valueLabel.Size = UDim2.new(0.5, 0, 0, 20)
	valueLabel.Position = UDim2.new(0.5, 0, 0, 0)
	valueLabel.BackgroundTransparency = 1
	valueLabel.TextColor3 = COLORS.AccentBlue
	valueLabel.TextXAlignment = Enum.TextXAlignment.Right
	valueLabel.Font = Enum.Font.GothamBold
	valueLabel.TextSize = 14
	valueLabel.Parent = container
	
	-- Slider background
	local sliderBg = Instance.new("Frame")
	sliderBg.Size = UDim2.new(1, 0, 0, 6)
	sliderBg.Position = UDim2.new(0, 0, 0, 30)
	sliderBg.BackgroundColor3 = COLORS.SliderBg
	sliderBg.BorderSizePixel = 0
	sliderBg.Parent = container
	Instance.new("UICorner", sliderBg).CornerRadius = UDim.new(0, 3)
	
	-- Slider fill
	local sliderFill = Instance.new("Frame")
	sliderFill.Size = UDim2.new(0, 0, 1, 0)
	sliderFill.BackgroundColor3 = COLORS.SliderFill
	sliderFill.BorderSizePixel = 0
	sliderFill.Parent = sliderBg
	Instance.new("UICorner", sliderFill).CornerRadius = UDim.new(0, 3)
	
	-- Interactive button
	local sliderButton = Instance.new("TextButton")
	sliderButton.Size = UDim2.new(1, 0, 0, 30)
	sliderButton.Position = UDim2.new(0, 0, 0, 25)
	sliderButton.BackgroundTransparency = 1
	sliderButton.Text = ""
	sliderButton.Parent = container
	
	-- Get current value
	local currentValue = SettingsManager.GetSetting(category, key) or defaultValue
	local function updateValue(ratio)
		local value = min + (max - min) * ratio
		value = math.floor(value / step + 0.5) * step
		value = math.clamp(value, min, max)
		
		SettingsManager.SetSetting(category, key, value)
		
		-- Update display
		if step >= 1 then
			valueLabel.Text = string.format("%.0f", value)
		elseif step >= 0.1 then
			valueLabel.Text = string.format("%.1f", value)
		else
			valueLabel.Text = string.format("%.2f", value)
		end
		
		-- Update fill
		local fillRatio = (value - min) / (max - min)
		sliderFill.Size = UDim2.new(fillRatio, 0, 1, 0)
	end
	
	-- Initialize
	local initialRatio = (currentValue - min) / (max - min)
	updateValue(initialRatio)
	
	-- Drag handling
	local dragging = false
	local dragConnection
	
	sliderButton.MouseButton1Down:Connect(function()
		dragging = true
		local mousePos = UserInputService:GetMouseLocation()
		local sliderPos = sliderBg.AbsolutePosition
		local sliderSize = sliderBg.AbsoluteSize
		local relativeX = mousePos.X - sliderPos.X
		local ratio = math.clamp(relativeX / sliderSize.X, 0, 1)
		updateValue(ratio)
		
		-- Connect to InputChanged for smooth dragging
		if dragConnection then dragConnection:Disconnect() end
		dragConnection = UserInputService.InputChanged:Connect(function(input)
			if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
				local mousePos = UserInputService:GetMouseLocation()
				local sliderPos = sliderBg.AbsolutePosition
				local sliderSize = sliderBg.AbsoluteSize
				local relativeX = mousePos.X - sliderPos.X
				local ratio = math.clamp(relativeX / sliderSize.X, 0, 1)
				updateValue(ratio)
			end
		end)
	end)
	
	UserInputService.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			dragging = false
			if dragConnection then
				dragConnection:Disconnect()
				dragConnection = nil
			end
		end
	end)
	
	return container
end

-- Create a checkbox control
local function createCheckbox(parent, label, category, key, defaultValue, yOffset)
	local container = Instance.new("Frame")
	container.Size = UDim2.new(1, -40, 0, 30)
	container.Position = UDim2.new(0, 20, 0, yOffset)
	container.BackgroundTransparency = 1
	container.Parent = parent
	
	-- Label
	local labelText = Instance.new("TextLabel")
	labelText.Size = UDim2.new(1, -50, 1, 0)
	labelText.Position = UDim2.new(0, 0, 0, 0)
	labelText.BackgroundTransparency = 1
	labelText.Text = label
	labelText.TextColor3 = COLORS.TextSecondary
	labelText.TextXAlignment = Enum.TextXAlignment.Left
	labelText.Font = Enum.Font.GothamMedium
	labelText.TextSize = 14
	labelText.Parent = container
	
	-- Checkbox
	local checkbox = Instance.new("Frame")
	checkbox.Size = UDim2.new(0, 20, 0, 20)
	checkbox.Position = UDim2.new(1, -20, 0, 5)
	checkbox.BackgroundColor3 = COLORS.SliderBg
	checkbox.BorderSizePixel = 0
	checkbox.Parent = container
	Instance.new("UICorner", checkbox).CornerRadius = UDim.new(0, 3)
	
	local checkmark = Instance.new("TextLabel")
	checkmark.Size = UDim2.fromScale(1, 1)
	checkmark.BackgroundTransparency = 1
	checkmark.Text = "✓"
	checkmark.TextColor3 = COLORS.AccentBlue
	checkmark.Font = Enum.Font.GothamBold
	checkmark.TextSize = 16
	checkmark.Parent = checkbox
	
	local button = Instance.new("TextButton")
	button.Size = UDim2.fromScale(1, 1)
	button.BackgroundTransparency = 1
	button.Text = ""
	button.Parent = container
	
	local function updateCheckbox(value)
		SettingsManager.SetSetting(category, key, value)
		checkmark.Visible = value
		if value then
			checkbox.BackgroundColor3 = COLORS.AccentBlue
		else
			checkbox.BackgroundColor3 = COLORS.SliderBg
		end
	end
	
	-- Initialize
	local currentValue = SettingsManager.GetSetting(category, key)
	if currentValue == nil then
		currentValue = defaultValue
	end
	updateCheckbox(currentValue)
	
	button.MouseButton1Click:Connect(function()
		local newValue = not (SettingsManager.GetSetting(category, key) or false)
		updateCheckbox(newValue)
	end)
	
	return container
end

-- Create a dropdown control
local function createDropdown(parent, label, options, category, key, defaultValue, yOffset)
	local container = Instance.new("Frame")
	container.Size = UDim2.new(1, -40, 0, 40)
	container.Position = UDim2.new(0, 20, 0, yOffset)
	container.BackgroundTransparency = 1
	container.Parent = parent
	
	-- Label
	local labelText = Instance.new("TextLabel")
	labelText.Size = UDim2.new(0.5, 0, 0, 20)
	labelText.Position = UDim2.new(0, 0, 0, 0)
	labelText.BackgroundTransparency = 1
	labelText.Text = label
	labelText.TextColor3 = COLORS.TextSecondary
	labelText.TextXAlignment = Enum.TextXAlignment.Left
	labelText.Font = Enum.Font.GothamMedium
	labelText.TextSize = 14
	labelText.Parent = container
	
	-- Dropdown button
	local dropdown = Instance.new("TextButton")
	dropdown.Size = UDim2.new(0.5, 0, 0, 30)
	dropdown.Position = UDim2.new(0.5, 0, 0, 0)
	dropdown.BackgroundColor3 = COLORS.SliderBg
	dropdown.BorderSizePixel = 0
	dropdown.Text = ""
	dropdown.Parent = container
	Instance.new("UICorner", dropdown).CornerRadius = UDim.new(0, 3)
	
	local dropdownText = Instance.new("TextLabel")
	dropdownText.Size = UDim2.new(1, -30, 1, 0)
	dropdownText.Position = UDim2.new(0, 10, 0, 0)
	dropdownText.BackgroundTransparency = 1
	dropdownText.TextColor3 = COLORS.TextMain
	dropdownText.TextXAlignment = Enum.TextXAlignment.Left
	dropdownText.Font = Enum.Font.Gotham
	dropdownText.TextSize = 12
	dropdownText.Parent = dropdown
	
	local arrow = Instance.new("TextLabel")
	arrow.Size = UDim2.new(0, 20, 1, 0)
	arrow.Position = UDim2.new(1, -20, 0, 0)
	arrow.BackgroundTransparency = 1
	arrow.Text = "▼"
	arrow.TextColor3 = COLORS.TextSecondary
	arrow.Font = Enum.Font.Gotham
	arrow.TextSize = 10
	arrow.Parent = dropdown
	
	local currentValue = SettingsManager.GetSetting(category, key) or defaultValue
	dropdownText.Text = currentValue
	
	-- Dropdown menu (hidden by default)
	local menu = Instance.new("Frame")
	menu.Size = UDim2.new(1, 0, 0, #options * 30)
	menu.Position = UDim2.new(0, 0, 1, 5)
	menu.BackgroundColor3 = COLORS.Panel
	menu.BorderSizePixel = 0
	menu.Visible = false
	menu.Parent = dropdown
	Instance.new("UICorner", menu).CornerRadius = UDim.new(0, 3)
	Instance.new("UIListLayout", menu).Padding = UDim.new(0, 2)
	
	for _, option in ipairs(options) do
		local optionButton = Instance.new("TextButton")
		optionButton.Size = UDim2.new(1, -10, 0, 28)
		optionButton.BackgroundColor3 = COLORS.SliderBg
		optionButton.BorderSizePixel = 0
		optionButton.Text = option
		optionButton.TextColor3 = COLORS.TextMain
		optionButton.Font = Enum.Font.Gotham
		optionButton.TextSize = 12
		optionButton.Parent = menu
		Instance.new("UICorner", optionButton).CornerRadius = UDim.new(0, 2)
		
		optionButton.MouseButton1Click:Connect(function()
			SettingsManager.SetSetting(category, key, option)
			dropdownText.Text = option
			menu.Visible = false
		end)
		
		optionButton.MouseEnter:Connect(function()
			optionButton.BackgroundColor3 = COLORS.AccentBlue
		end)
		optionButton.MouseLeave:Connect(function()
			optionButton.BackgroundColor3 = COLORS.SliderBg
		end)
	end
	
	dropdown.MouseButton1Click:Connect(function()
		menu.Visible = not menu.Visible
	end)
	
	return container
end

-- Create a tab content panel
local function createTabContent(parent, tabName)
	local scrollFrame = Instance.new("ScrollingFrame")
	scrollFrame.Name = tabName .. "Content"
	scrollFrame.Size = UDim2.fromScale(1, 1)
	scrollFrame.BackgroundTransparency = 1
	scrollFrame.ScrollBarThickness = 4
	scrollFrame.ScrollBarImageColor3 = COLORS.AccentBlue
	scrollFrame.Parent = parent
	
	local layout = Instance.new("UIListLayout")
	layout.Padding = UDim.new(0, 10)
	layout.Parent = scrollFrame
	
	-- Update canvas size when content changes
	layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
		scrollFrame.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + 20)
	end)
	
	return scrollFrame
end

function SettingsView.Create(parent)
	local connections = {}
	local frame = Instance.new("Frame")
	frame.Name = "SettingsView"
	frame.Size = UDim2.fromScale(1, 1)
	frame.BackgroundTransparency = 1
	frame.Parent = parent
	
	-- Title
	local title = Instance.new("TextLabel")
	title.Size = UDim2.new(1, 0, 0, 60)
	title.Position = UDim2.fromOffset(0, 0)
	title.BackgroundTransparency = 1
	title.Text = "SETTINGS"
	title.TextColor3 = COLORS.TextMain
	title.Font = Enum.Font.GothamBlack
	title.TextSize = 32
	title.TextXAlignment = Enum.TextXAlignment.Left
	title.Parent = frame
	
	-- Tab buttons container
	local tabContainer = Instance.new("Frame")
	tabContainer.Size = UDim2.new(1, 0, 0, 40)
	tabContainer.Position = UDim2.fromOffset(0, 60)
	tabContainer.BackgroundTransparency = 1
	tabContainer.Parent = frame
	
	local tabLayout = Instance.new("UIListLayout")
	tabLayout.FillDirection = Enum.FillDirection.Horizontal
	tabLayout.Padding = UDim.new(0, 10)
	tabLayout.Parent = tabContainer
	
	-- Content area
	local contentArea = Instance.new("Frame")
	contentArea.Size = UDim2.new(1, 0, 1, -100)
	contentArea.Position = UDim2.fromOffset(0, 100)
	contentArea.BackgroundTransparency = 1
	contentArea.Parent = frame
	
	local tabs = {"Input", "Audio", "Graphics", "Accessibility"}
	local currentTab = "Input"
	local tabContents = {}
	
	-- Create tab buttons and content
	for _, tabName in ipairs(tabs) do
		-- Tab button
		local tabButton = Instance.new("TextButton")
		tabButton.Size = UDim2.new(0, 150, 1, 0)
		tabButton.BackgroundColor3 = COLORS.Panel
		tabButton.BorderSizePixel = 0
		tabButton.Text = tabName
		tabButton.TextColor3 = COLORS.TextSecondary
		tabButton.Font = Enum.Font.GothamBold
		tabButton.TextSize = 14
		tabButton.Parent = tabContainer
		Instance.new("UICorner", tabButton).CornerRadius = UDim.new(0, 4)
		
		-- Tab content
		local tabContent = createTabContent(contentArea, tabName)
		tabContent.Visible = (tabName == currentTab)
		tabContents[tabName] = tabContent
		
		-- Tab switching
		tabButton.MouseButton1Click:Connect(function()
			currentTab = tabName
			for name, content in pairs(tabContents) do
				content.Visible = (name == tabName)
			end
			-- Update button colors
			for _, btn in ipairs(tabContainer:GetChildren()) do
				if btn:IsA("TextButton") then
					if btn.Text == tabName then
						btn.BackgroundColor3 = COLORS.AccentBlue
						btn.TextColor3 = COLORS.TextMain
					else
						btn.BackgroundColor3 = COLORS.Panel
						btn.TextColor3 = COLORS.TextSecondary
					end
				end
			end
		end)
		
		-- Set initial active tab
		if tabName == currentTab then
			tabButton.BackgroundColor3 = COLORS.AccentBlue
			tabButton.TextColor3 = COLORS.TextMain
		end
	end
	
	-- === INPUT TAB ===
	local inputContent = tabContents["Input"]
	local inputY = 20
	
	createSlider(inputContent, "Mouse Sensitivity", 0.1, 5.0, 0.1, 1.0, "Input", "MouseSensitivity", inputY)
	inputY = inputY + 60
	createSlider(inputContent, "ADS Sensitivity", 0.1, 2.0, 0.1, 0.8, "Input", "ADSSensitivity", inputY)
	inputY = inputY + 60
	createSlider(inputContent, "Vertical Multiplier", 0.5, 2.0, 0.1, 1.0, "Input", "VerticalMultiplier", inputY)
	inputY = inputY + 60
	createCheckbox(inputContent, "Raw Input", "Input", "RawInput", true, inputY)
	inputY = inputY + 40
	createCheckbox(inputContent, "Mouse Smoothing", "Input", "MouseSmoothing", true, inputY)
	
	-- === AUDIO TAB ===
	local audioContent = tabContents["Audio"]
	local audioY = 20
	
	createSlider(audioContent, "Master Volume", 0.0, 1.0, 0.01, 1.0, "Audio", "MasterVolume", audioY)
	audioY = audioY + 60
	createSlider(audioContent, "Effects Volume", 0.0, 1.0, 0.01, 1.0, "Audio", "EffectsVolume", audioY)
	audioY = audioY + 60
	createSlider(audioContent, "Music Volume", 0.0, 1.0, 0.01, 0.6, "Audio", "MusicVolume", audioY)
	audioY = audioY + 60
	createSlider(audioContent, "Voice Volume", 0.0, 1.0, 0.01, 1.0, "Audio", "VoiceVolume", audioY)
	audioY = audioY + 60
	createCheckbox(audioContent, "Voice Chat Enabled", "Audio", "VoiceChatEnabled", true, audioY)
	audioY = audioY + 40
	createCheckbox(audioContent, "Push to Talk", "Audio", "PushToTalk", true, audioY)
	
	-- === GRAPHICS TAB ===
	local graphicsContent = tabContents["Graphics"]
	local graphicsY = 20
	
	createDropdown(graphicsContent, "Quality", {"Low", "Medium", "High", "Ultra"}, "Graphics", "Quality", "High", graphicsY)
	graphicsY = graphicsY + 50
	createSlider(graphicsContent, "Draw Distance", 100, 1000, 50, 500, "Graphics", "DrawDistance", graphicsY)
	graphicsY = graphicsY + 60
	createDropdown(graphicsContent, "Shadow Quality", {"Off", "Low", "Medium", "High"}, "Graphics", "ShadowQuality", "Medium", graphicsY)
	graphicsY = graphicsY + 50
	createDropdown(graphicsContent, "Particle Effects", {"Low", "Medium", "High"}, "Graphics", "ParticleEffects", "High", graphicsY)
	graphicsY = graphicsY + 50
	createCheckbox(graphicsContent, "VSync", "Graphics", "VSync", true, graphicsY)
	graphicsY = graphicsY + 40
	createCheckbox(graphicsContent, "Show FPS", "Graphics", "ShowFPS", true, graphicsY)
	graphicsY = graphicsY + 40
	createCheckbox(graphicsContent, "Show Ping", "Graphics", "ShowPing", true, graphicsY)
	
	-- === ACCESSIBILITY TAB ===
	local accessibilityContent = tabContents["Accessibility"]
	local accessibilityY = 20
	
	createDropdown(accessibilityContent, "Colorblind Mode", {"None", "Deuteranopia", "Protanopia", "Tritanopia"}, "Accessibility", "ColorblindMode", "None", accessibilityY)
	accessibilityY = accessibilityY + 50
	createSlider(accessibilityContent, "Brightness", 0.5, 1.5, 0.05, 1.0, "Accessibility", "Brightness", accessibilityY)
	accessibilityY = accessibilityY + 60
	createSlider(accessibilityContent, "Contrast", 0.5, 1.5, 0.05, 1.0, "Accessibility", "Contrast", accessibilityY)
	accessibilityY = accessibilityY + 60
	createSlider(accessibilityContent, "HUD Scale", 0.5, 1.5, 0.05, 1.0, "Accessibility", "HUDScale", accessibilityY)
	accessibilityY = accessibilityY + 60
	createDropdown(accessibilityContent, "Font Size", {"Small", "Medium", "Large"}, "Accessibility", "FontSize", "Medium", accessibilityY)
	accessibilityY = accessibilityY + 50
	createCheckbox(accessibilityContent, "Subtitles", "Accessibility", "Subtitles", false, accessibilityY)
	accessibilityY = accessibilityY + 40
	createCheckbox(accessibilityContent, "Mono Audio", "Accessibility", "MonoAudio", false, accessibilityY)
	accessibilityY = accessibilityY + 40
	createCheckbox(accessibilityContent, "High Contrast", "Accessibility", "HighContrast", false, accessibilityY)
	accessibilityY = accessibilityY + 40
	createCheckbox(accessibilityContent, "Reduce Motion", "Accessibility", "ReduceMotion", false, accessibilityY)
	
	-- Reset to defaults button
	local resetButton = Instance.new("TextButton")
	resetButton.Size = UDim2.new(0, 200, 0, 40)
	resetButton.Position = UDim2.new(1, -220, 1, -50)
	resetButton.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
	resetButton.BorderSizePixel = 0
	resetButton.Text = "Reset to Defaults"
	resetButton.TextColor3 = COLORS.TextMain
	resetButton.Font = Enum.Font.GothamBold
	resetButton.TextSize = 14
	resetButton.Parent = frame
	Instance.new("UICorner", resetButton).CornerRadius = UDim.new(0, 4)
	
	resetButton.MouseButton1Click:Connect(function()
		SettingsManager.ResetToDefaults()
		-- Reload the view
		frame:Destroy()
		SettingsView.Create(parent)
	end)
	
	return {
		Instance = frame,
		Destroy = function()
			for _, c in ipairs(connections) do
				if c.Disconnect then c:Disconnect() end
			end
			frame:Destroy()
		end
	}
end

return SettingsView
