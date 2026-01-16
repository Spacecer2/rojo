--[[
	DroneSettingsUI - Settings Interface for Three-Layer Camera System
	
	Organized by the three-layer architecture:
	- Layer 1: Intent (Cinematic/AI behavior)
	- Layer 2: Motion Plan (Control & smoothing)
	- Layer 3: Physical (Drone body physics)
]]

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local DroneSettingsUI = {}

local screenGui
local settingsPanel
local isVisible = false

-- Parameter definitions organized by layer
local parameters = {
	-- Layer 1: Intent (Cinematic/AI) - What the camera wants to do
	{section = "🎬 Intent Layer (Cinematic Behavior)", params = {
		{name = "DroneOrbitSwayAmplitude", label = "Orbit Sway Amplitude", min = 0.1, max = 1.5, default = 0.6, step = 0.05, 
		 tooltip = "How much the camera sways around the orbit (radians)"},
		{name = "DroneOrbitSwayFrequency", label = "Orbit Sway Frequency", min = 0.05, max = 0.5, default = 0.2, step = 0.05,
		 tooltip = "Speed of orbital sway motion (Hz)"},
		{name = "DroneMinDistance", label = "Min Distance", min = 10, max = 30, default = 10, step = 1,
		 tooltip = "Minimum distance from player"},
		{name = "DroneMaxDistance", label = "Max Distance", min = 30, max = 80, default = 30, step = 5,
		 tooltip = "Maximum distance from player"},
		{name = "DroneHeightOffset", label = "Height Offset", min = -10, max = 20, default = 0, step = 1,
		 tooltip = "Vertical offset above player"},
		{name = "DroneLookAheadFactor", label = "Look Ahead Factor", min = 0.0, max = 0.5, default = 0.2, step = 0.05,
		 tooltip = "How far ahead the camera looks (velocity-based)"},
		{name = "DroneIdealAlignment", label = "Preferred Angle (Deg)", min = 0, max = 180, default = 0, step = 5,
		 tooltip = "Target angle from the front: 0° is direct front, 180° is direct behind"},
	}},
	
	-- Layer 2: Motion Plan (Control/Smoothing) - How to achieve intent smoothly
	{section = "🎯 Motion Plan Layer (Control & Smoothing)", params = {
		{name = "DroneAmbitionBase", label = "Authority Base", min = 0.2, max = 1.0, default = 0.55, step = 0.05,
		 tooltip = "Base authority weight (maps to AuthorityBase internally)"},
		{name = "DroneAmbitionScale", label = "Authority Scale", min = 1.0, max = 3.0, default = 1.8, step = 0.1,
		 tooltip = "How much error increases authority (maps to AuthorityScale internally)"},
		{name = "DroneStressSmoothing", label = "Error Smoothing", min = 0.005, max = 0.05, default = 0.012, step = 0.001,
		 tooltip = "Smoothing rate for error magnitude (maps to ErrorSmoothing internally)"},
		{name = "DroneLatencySteps", label = "Prediction Lead (Steps)", min = 5, max = 30, default = 15, step = 1,
		 tooltip = "Steps ahead for predictive filtering (replaces latency buffer)"},
		{name = "DroneTopSpeed", label = "Top Speed", min = 25, max = 60, default = 40, step = 5,
		 tooltip = "Maximum camera movement speed"},
		{name = "DroneAccelerationLimit", label = "Acceleration Limit", min = 30, max = 80, default = 50, step = 5,
		 tooltip = "Maximum acceleration for smooth motion"},
		{name = "DroneManualStrength", label = "Manual Control Strength", min = 15, max = 40, default = 25, step = 5,
		 tooltip = "Strength of WASD manual control"},
		{name = "DroneManualMode", label = "Manual Mode", default = "bias", isEnum = true,
		 enumValues = {"bias", "override", "assist"},
		 tooltip = "Manual control mode: bias (nudge), override (full control), assist (AI smooths)"},
		{name = "DroneRoofAvoidanceRadius", label = "Roof Avoidance Radius", min = 3, max = 10, default = 5, step = 1,
		 tooltip = "Radius for overhead position avoidance"},
	}},
	
	-- Layer 3: Physical (Drone Body) - How physics executes the plan
	{section = "⚙️ Physical Layer (Drone Body Physics)", params = {
		{name = "DroneFocusSpringSpeed", label = "Gimbal Spring Speed", min = 1.0, max = 4.0, default = 1.8, step = 0.2,
		 tooltip = "Focus point (gimbal) spring stiffness"},
		{name = "DroneFocusSpringDamper", label = "Gimbal Spring Damper", min = 0.4, max = 0.9, default = 0.6, step = 0.1,
		 tooltip = "Focus point (gimbal) damping"},
		{name = "DroneMaxRollDeg", label = "Max Body Roll (Deg)", min = 20, max = 70, default = 50, step = 5,
		 tooltip = "Maximum roll angle for drone body"},
	}},
}

local function createSlider(parent, param, yOffset)
	local container = Instance.new("Frame")
	container.Size = UDim2.new(1, -20, 0, param.tooltip and 60 or 50)
	container.Position = UDim2.new(0, 10, 0, yOffset)
	container.BackgroundTransparency = 1
	container.Parent = parent
	
	local label = Instance.new("TextLabel")
	label.Size = UDim2.new(0.5, 0, 0, 20)
	label.Position = UDim2.new(0, 0, 0, 0)
	label.BackgroundTransparency = 1
	label.Text = param.label
	label.TextColor3 = Color3.fromRGB(220, 220, 220)
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.Font = Enum.Font.GothamMedium
	label.TextSize = 14
	label.Parent = container
	
	local valueLabel = Instance.new("TextLabel")
	valueLabel.Size = UDim2.new(0.5, 0, 0, 20)
	valueLabel.Position = UDim2.new(0.5, 0, 0, 0)
	valueLabel.BackgroundTransparency = 1
	valueLabel.TextColor3 = Color3.fromRGB(100, 200, 255)
	valueLabel.TextXAlignment = Enum.TextXAlignment.Right
	valueLabel.Font = Enum.Font.GothamBold
	valueLabel.TextSize = 14
	valueLabel.Parent = container
	
	-- Tooltip label
	if param.tooltip then
		local tooltipLabel = Instance.new("TextLabel")
		tooltipLabel.Size = UDim2.new(1, 0, 0, 15)
		tooltipLabel.Position = UDim2.new(0, 0, 0, 20)
		tooltipLabel.BackgroundTransparency = 1
		tooltipLabel.Text = param.tooltip
		tooltipLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
		tooltipLabel.TextXAlignment = Enum.TextXAlignment.Left
		tooltipLabel.Font = Enum.Font.Gotham
		tooltipLabel.TextSize = 11
		tooltipLabel.TextWrapped = true
		tooltipLabel.Parent = container
	end
	
	local sliderBg = Instance.new("Frame")
	sliderBg.Size = UDim2.new(1, 0, 0, 6)
	sliderBg.Position = UDim2.new(0, 0, 0, param.tooltip and 40 or 30)
	sliderBg.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
	sliderBg.BorderSizePixel = 0
	sliderBg.Parent = container
	
	local sliderFill = Instance.new("Frame")
	sliderFill.Size = UDim2.new(0, 0, 1, 0)
	sliderFill.BackgroundColor3 = Color3.fromRGB(100, 200, 255)
	sliderFill.BorderSizePixel = 0
	sliderFill.Parent = sliderBg
	
	local sliderButton = Instance.new("TextButton")
	sliderButton.Size = UDim2.new(1, 0, 0, 30)
	sliderButton.Position = UDim2.new(0, 0, 0, param.tooltip and 32 or 22)
	sliderButton.BackgroundTransparency = 1
	sliderButton.Text = ""
	sliderButton.Parent = container
	
	local function updateValue(ratio)
		local value
		local fillRatio = ratio
		
		if param.isEnum then
			-- Enum mode: select from enumValues array
			local index = math.floor(ratio * (#param.enumValues - 1) + 0.5) + 1
			index = math.clamp(index, 1, #param.enumValues)
			value = param.enumValues[index]
			player:SetAttribute(param.name, value)
			valueLabel.Text = value
			-- Update fill for enum (ratio already calculated)
		else
			-- Numeric mode
			value = param.min + (param.max - param.min) * ratio
			value = math.floor(value / param.step + 0.5) * param.step
			value = math.clamp(value, param.min, param.max)
			
			player:SetAttribute(param.name, value)
			
			-- Format based on step size
			if param.step >= 1 then
				valueLabel.Text = string.format("%.0f", value)
			elseif param.step >= 0.1 then
				valueLabel.Text = string.format("%.1f", value)
			else
				valueLabel.Text = string.format("%.3f", value)
			end
			
			-- Calculate fill ratio for numeric
			fillRatio = (value - param.min) / (param.max - param.min)
		end
		
		-- Update slider fill
		sliderFill.Size = UDim2.new(fillRatio, 0, 1, 0)
	end
	
	-- Get current value
	local currentValue = player:GetAttribute(param.name)
	if currentValue == nil then
		currentValue = param.default
	end
	
	local initialRatio
	if param.isEnum then
		-- Find index of current value in enumValues
		local index = 1
		for i, v in ipairs(param.enumValues) do
			if v == currentValue then
				index = i
				break
			end
		end
		initialRatio = (index - 1) / (#param.enumValues - 1)
	else
		initialRatio = (currentValue - param.min) / (param.max - param.min)
	end
	
	updateValue(initialRatio)
	
	local dragging = false
	sliderButton.MouseButton1Down:Connect(function()
		dragging = true
	end)
	
	UserInputService.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			dragging = false
		end
	end)
	
	UserInputService.InputChanged:Connect(function(input)
		if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
			local relativeX = input.Position.X - sliderBg.AbsolutePosition.X
			local ratio = math.clamp(relativeX / sliderBg.AbsoluteSize.X, 0, 1)
			updateValue(ratio)
		end
	end)
	
	return container
end

local function createPresetButton(parent, name, values, xPos)
	local button = Instance.new("TextButton")
	button.Size = UDim2.new(0.3, -5, 0, 35)
	button.Position = UDim2.new(xPos, 0, 0, 0)
	button.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
	button.BorderSizePixel = 0
	button.Text = name
	button.TextColor3 = Color3.fromRGB(255, 255, 255)
	button.Font = Enum.Font.GothamBold
	button.TextSize = 14
	button.Parent = parent
	
	button.MouseButton1Click:Connect(function()
		for attrName, value in pairs(values) do
			player:SetAttribute(attrName, value)
		end
	end)
	
	return button
end

function DroneSettingsUI.Init()
	screenGui = Instance.new("ScreenGui")
	screenGui.Name = "DroneSettings"
	screenGui.ResetOnSpawn = false
	screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	screenGui.Parent = playerGui
	
	settingsPanel = Instance.new("Frame")
	settingsPanel.Size = UDim2.new(0, 500, 0, 600)
	settingsPanel.Position = UDim2.new(0.5, -250, 0.5, -300)
	settingsPanel.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
	settingsPanel.BorderSizePixel = 0
	settingsPanel.Visible = false
	settingsPanel.Parent = screenGui
	
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 12)
	corner.Parent = settingsPanel
	
	local title = Instance.new("TextLabel")
	title.Size = UDim2.new(1, 0, 0, 50)
	title.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
	title.BorderSizePixel = 0
	title.Text = "Drone Camera Settings"
	title.TextColor3 = Color3.fromRGB(255, 255, 255)
	title.Font = Enum.Font.GothamBold
	title.TextSize = 20
	title.Parent = settingsPanel
	
	-- Subtitle
	local subtitle = Instance.new("TextLabel")
	subtitle.Size = UDim2.new(1, -20, 0, 20)
	subtitle.Position = UDim2.new(0, 10, 0, 50)
	subtitle.BackgroundTransparency = 1
	subtitle.Text = "Three-Layer Architecture: Intent → Motion Plan → Physical"
	subtitle.TextColor3 = Color3.fromRGB(150, 150, 150)
	subtitle.TextXAlignment = Enum.TextXAlignment.Left
	subtitle.Font = Enum.Font.Gotham
	subtitle.TextSize = 11
	subtitle.Parent = settingsPanel
	
	local titleCorner = Instance.new("UICorner")
	titleCorner.CornerRadius = UDim.new(0, 12)
	titleCorner.Parent = title
	
	local scrollFrame = Instance.new("ScrollingFrame")
	scrollFrame.Size = UDim2.new(1, -20, 1, -140)
	scrollFrame.Position = UDim2.new(0, 10, 0, 75)
	scrollFrame.BackgroundTransparency = 1
	scrollFrame.BorderSizePixel = 0
	scrollFrame.ScrollBarThickness = 6
	scrollFrame.Parent = settingsPanel
	
	local yOffset = 0
	for _, section in ipairs(parameters) do
		-- Section header with background
		local sectionContainer = Instance.new("Frame")
		sectionContainer.Size = UDim2.new(1, -20, 0, 35)
		sectionContainer.Position = UDim2.new(0, 10, 0, yOffset)
		sectionContainer.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
		sectionContainer.BorderSizePixel = 0
		sectionContainer.Parent = scrollFrame
		
		local sectionCorner = Instance.new("UICorner")
		sectionCorner.CornerRadius = UDim.new(0, 6)
		sectionCorner.Parent = sectionContainer
		
		local sectionLabel = Instance.new("TextLabel")
		sectionLabel.Size = UDim2.new(1, -20, 1, 0)
		sectionLabel.Position = UDim2.new(0, 10, 0, 0)
		sectionLabel.BackgroundTransparency = 1
		sectionLabel.Text = section.section
		sectionLabel.TextColor3 = Color3.fromRGB(100, 200, 255)
		sectionLabel.TextXAlignment = Enum.TextXAlignment.Left
		sectionLabel.Font = Enum.Font.GothamBold
		sectionLabel.TextSize = 15
		sectionLabel.Parent = sectionContainer
		
		yOffset = yOffset + 40
		
		for _, param in ipairs(section.params) do
			createSlider(scrollFrame, param, yOffset)
			yOffset = yOffset + 55
		end
		
		yOffset = yOffset + 10
	end
	
	scrollFrame.CanvasSize = UDim2.new(0, 0, 0, yOffset)
	
	local presetContainer = Instance.new("Frame")
	presetContainer.Size = UDim2.new(1, -20, 0, 40)
	presetContainer.Position = UDim2.new(0, 10, 1, -50)
	presetContainer.BackgroundTransparency = 1
	presetContainer.Parent = settingsPanel
	
	-- Preset label
	local presetLabel = Instance.new("TextLabel")
	presetLabel.Size = UDim2.new(1, 0, 0, 20)
	presetLabel.Position = UDim2.new(0, 0, 0, -25)
	presetLabel.BackgroundTransparency = 1
	presetLabel.Text = "Presets:"
	presetLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
	presetLabel.TextXAlignment = Enum.TextXAlignment.Left
	presetLabel.Font = Enum.Font.GothamMedium
	presetLabel.TextSize = 13
	presetLabel.Parent = presetContainer
	
	-- Presets organized by layer architecture
	createPresetButton(presetContainer, "Cinematic", {
		-- Intent Layer
		DroneOrbitSwayAmplitude = 0.8,
		DroneOrbitSwayFrequency = 0.15,
		DroneLookAheadFactor = 0.3,
		DroneIdealAlignment = 0,
		-- Motion Plan Layer
		DroneAmbitionBase = 0.4,
		DroneStressSmoothing = 0.008,
		DroneLatencySteps = 20,
		DroneTopSpeed = 30,
		DroneAccelerationLimit = 40,
		DroneManualMode = "bias",
		-- Physical Layer
		DroneFocusSpringSpeed = 1.5,
		DroneFocusSpringDamper = 0.5,
	}, 0)
	
	createPresetButton(presetContainer, "Responsive", {
		-- Intent Layer
		DroneOrbitSwayAmplitude = 0.4,
		DroneOrbitSwayFrequency = 0.3,
		DroneLookAheadFactor = 0.15,
		DroneIdealAlignment = 135,
		-- Motion Plan Layer
		DroneAmbitionBase = 0.7,
		DroneAmbitionScale = 2.0,
		DroneStressSmoothing = 0.03,
		DroneLatencySteps = 8,
		DroneTopSpeed = 50,
		DroneAccelerationLimit = 60,
		DroneManualMode = "override",
		-- Physical Layer
		DroneFocusSpringSpeed = 2.5,
		DroneFocusSpringDamper = 0.7,
	}, 0.33)
	
	createPresetButton(presetContainer, "Lazy Drift", {
		-- Intent Layer
		DroneOrbitSwayAmplitude = 1.0,
		DroneOrbitSwayFrequency = 0.1,
		DroneLookAheadFactor = 0.25,
		DroneIdealAlignment = 0,
		-- Motion Plan Layer
		DroneAmbitionBase = 0.35,
		DroneAmbitionScale = 1.5,
		DroneStressSmoothing = 0.005,
		DroneLatencySteps = 25,
		DroneTopSpeed = 25,
		DroneAccelerationLimit = 35,
		DroneManualMode = "assist",
		-- Physical Layer
		DroneFocusSpringSpeed = 1.2,
		DroneFocusSpringDamper = 0.4,
	}, 0.66)
	
	-- F key toggle
	UserInputService.InputBegan:Connect(function(input, gameProcessed)
		if not gameProcessed and input.KeyCode == Enum.KeyCode.F then
			isVisible = not isVisible
			settingsPanel.Visible = isVisible
		end
	end)
end

function DroneSettingsUI.Toggle()
	isVisible = not isVisible
	if settingsPanel then
		settingsPanel.Visible = isVisible
	end
end

return DroneSettingsUI
