--[[
	SettingsView - Configuration Menu
	Tabs: General, Graphics, Audio
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local UI = require(script.Parent.Parent)
local Controllers = script.Parent.Parent.Parent.Controllers
local SettingsController = require(Controllers:WaitForChild("SettingsController"))
local SettingsData = require(ReplicatedStorage.Constants.SettingsData)
local ViewManager = require(Controllers:WaitForChild("ViewManager"))

local SettingsView = {}

local COLORS = {
	Background = Color3.fromRGB(15, 15, 15),
	Panel = Color3.fromRGB(30, 30, 35),
	AccentBlue = Color3.fromRGB(0, 162, 255),
	TextMain = Color3.fromRGB(255, 255, 255),
	TextSecondary = Color3.fromRGB(180, 180, 180),
}

function SettingsView.Create(parent)
	local connections = {}
	
	local frame = Instance.new("Frame")
	frame.Name = "SettingsView"
	frame.Size = UDim2.fromScale(1, 1)
	frame.BackgroundTransparency = 1
	frame.Parent = parent
	
	-- Layout: Left Panel (Categories), Right Panel (Options)
	
	local categoryPanel = Instance.new("Frame")
	categoryPanel.Name = "Categories"
	categoryPanel.Size = UDim2.new(0, 250, 1, -80)
	categoryPanel.Position = UDim2.fromOffset(40, 20)
	categoryPanel.BackgroundColor3 = COLORS.Panel
	categoryPanel.BackgroundTransparency = 0.5
	categoryPanel.BorderSizePixel = 0
	categoryPanel.Parent = frame
	
	local catLayout = Instance.new("UIListLayout")
	catLayout.Padding = UDim.new(0, 5)
	catLayout.Parent = categoryPanel
	
	local optionsScroll = Instance.new("ScrollingFrame")
	optionsScroll.Name = "OptionsScroll"
	optionsScroll.Size = UDim2.new(1, -310, 1, -80)
	optionsScroll.Position = UDim2.fromOffset(310, 20)
	optionsScroll.BackgroundTransparency = 1
	optionsScroll.BorderSizePixel = 0
	optionsScroll.ScrollBarThickness = 4
	optionsScroll.Parent = frame
	
	local optLayout = Instance.new("UIListLayout")
	optLayout.Padding = UDim.new(0, 15)
	optLayout.SortOrder = Enum.SortOrder.LayoutOrder
	optLayout.Parent = optionsScroll
	
	-- Helper to create option widgets
	local function createSlider(key, labelText, config, order)
		local container = Instance.new("Frame")
		container.Size = UDim2.new(1, -10, 0, 60)
		container.BackgroundTransparency = 1
		container.LayoutOrder = order
		
		local label = Instance.new("TextLabel")
		label.Text = labelText
		label.Font = Enum.Font.GothamBold
		label.TextSize = 14
		label.TextColor3 = COLORS.TextMain
		label.Size = UDim2.new(1, 0, 0, 20)
		label.BackgroundTransparency = 1
		label.TextXAlignment = Enum.TextXAlignment.Left
		label.Parent = container
		
		local valLabel = Instance.new("TextLabel")
		valLabel.Text = tostring(SettingsController.CurrentSettings[key])
		valLabel.Font = Enum.Font.Gotham
		valLabel.TextSize = 14
		valLabel.TextColor3 = COLORS.AccentBlue
		valLabel.Size = UDim2.new(0, 50, 0, 20)
		valLabel.Position = UDim2.new(1, -50, 0, 0)
		valLabel.BackgroundTransparency = 1
		valLabel.TextXAlignment = Enum.TextXAlignment.Right
		valLabel.Parent = container
		
		local sliderBg = Instance.new("Frame")
		sliderBg.Size = UDim2.new(1, 0, 0, 6)
		sliderBg.Position = UDim2.new(0, 0, 0, 35)
		sliderBg.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
		sliderBg.BorderSizePixel = 0
		sliderBg.Parent = container
		Instance.new("UICorner", sliderBg).CornerRadius = UDim.new(1, 0)
		
		local fill = Instance.new("Frame")
		local current = SettingsController.CurrentSettings[key] or config.Min
		local alpha = math.clamp((current - config.Min) / (config.Max - config.Min), 0, 1)
		fill.Size = UDim2.fromScale(alpha, 1)
		fill.BackgroundColor3 = COLORS.AccentBlue
		fill.BorderSizePixel = 0
		fill.Parent = sliderBg
		Instance.new("UICorner", fill).CornerRadius = UDim.new(1, 0)
		
		local btn = Instance.new("TextButton")
		btn.Size = UDim2.fromScale(1, 1)
		btn.BackgroundTransparency = 1
		btn.Text = ""
		btn.Parent = sliderBg
		
		-- Simple Slider Logic
		local dragging = false
		btn.MouseButton1Down:Connect(function() dragging = true end)
		local inputSvc = game:GetService("UserInputService")
		table.insert(connections, inputSvc.InputEnded:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
		end))
		
		table.insert(connections, inputSvc.InputChanged:Connect(function(input)
			if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
				local mousePos = input.Position.X
				local startPos = sliderBg.AbsolutePosition.X
				local width = sliderBg.AbsoluteSize.X
				local newAlpha = math.clamp((mousePos - startPos) / width, 0, 1)
				
				local newValue = config.Min + (newAlpha * (config.Max - config.Min))
				-- Round to step
				newValue = math.round(newValue / config.Step) * config.Step
				
				-- Update UI
				fill.Size = UDim2.fromScale(newAlpha, 1)
				valLabel.Text = string.format("%.1f", newValue)
				
				-- Update Controller
				SettingsController.UpdateSetting(key, newValue)
			end
		end))
		
		return container
	end

	local function createToggle(key, labelText, order)
		local container = Instance.new("Frame")
		container.Size = UDim2.new(1, -10, 0, 40)
		container.BackgroundTransparency = 1
		container.LayoutOrder = order
		
		local label = Instance.new("TextLabel")
		label.Text = labelText
		label.Font = Enum.Font.GothamBold
		label.TextSize = 14
		label.TextColor3 = COLORS.TextMain
		label.Size = UDim2.new(1, -60, 1, 0)
		label.BackgroundTransparency = 1
		label.TextXAlignment = Enum.TextXAlignment.Left
		label.Parent = container
		
		local btn = Instance.new("TextButton")
		btn.Size = UDim2.fromOffset(50, 26)
		btn.Position = UDim2.new(1, -50, 0.5, 0)
		btn.AnchorPoint = Vector2.new(0, 0.5)
		btn.BackgroundColor3 = SettingsController.CurrentSettings[key] and COLORS.AccentBlue or Color3.fromRGB(60,60,60)
		btn.Text = SettingsController.CurrentSettings[key] and "ON" or "OFF"
		btn.Font = Enum.Font.GothamBold
		btn.TextSize = 12
		btn.TextColor3 = Color3.new(1,1,1)
		btn.Parent = container
		Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 4)
		
		btn.MouseButton1Click:Connect(function()
			local newVal = not SettingsController.CurrentSettings[key]
			btn.Text = newVal and "ON" or "OFF"
			btn.BackgroundColor3 = newVal and COLORS.AccentBlue or Color3.fromRGB(60,60,60)
			SettingsController.UpdateSetting(key, newVal)
		end)
		
		return container
	end

	-- Render Options based on Category
	local function loadCategory(cat)
		for _, c in ipairs(optionsScroll:GetChildren()) do
			if c:IsA("Frame") then c:Destroy() end
		end
		
		if cat == "General" then
			createSlider("Sensitivity", "Look Sensitivity", SettingsData.Constraints.Sensitivity, 1).Parent = optionsScroll
			createToggle("InvertLook", "Invert Look", 2).Parent = optionsScroll
			createToggle("ToggleSprint", "Toggle Sprint", 3).Parent = optionsScroll
			createToggle("ToggleADS", "Toggle ADS", 4).Parent = optionsScroll
		elseif cat == "Graphics" then
			createSlider("FOV", "Field of View", SettingsData.Constraints.FOV, 1).Parent = optionsScroll
			createToggle("MotionBlur", "Motion Blur", 2).Parent = optionsScroll
			createSlider("HUDScale", "HUD Scale", SettingsData.Constraints.HUDScale, 3).Parent = optionsScroll
			createToggle("WeaponBob", "Weapon Movement", 4).Parent = optionsScroll
		elseif cat == "Audio" then
			createSlider("MasterVolume", "Master Volume", SettingsData.Constraints.MasterVolume, 1).Parent = optionsScroll
			createSlider("MusicVolume", "Music Volume", SettingsData.Constraints.MusicVolume, 2).Parent = optionsScroll
			createSlider("EffectsVolume", "Effects Volume", SettingsData.Constraints.EffectsVolume, 3).Parent = optionsScroll
		end
		
		optionsScroll.CanvasSize = UDim2.fromOffset(0, optLayout.AbsoluteContentSize.Y + 20)
	end

	-- Category Buttons
	local categories = {"General", "Graphics", "Audio"}
	for _, cat in ipairs(categories) do
		local btn = Instance.new("TextButton")
		btn.Text = cat
		btn.Font = Enum.Font.GothamBold
		btn.TextSize = 14
		btn.TextColor3 = COLORS.TextSecondary
		btn.BackgroundColor3 = Color3.new(0,0,0)
		btn.BackgroundTransparency = 1
		btn.Size = UDim2.new(1, 0, 0, 40)
		btn.Parent = categoryPanel
		
		btn.MouseButton1Click:Connect(function()
			-- Reset styles
			for _, child in ipairs(categoryPanel:GetChildren()) do
				if child:IsA("TextButton") then child.TextColor3 = COLORS.TextSecondary end
			end
			btn.TextColor3 = COLORS.AccentBlue
			loadCategory(cat)
		end)
	end
	
	-- Back Button (Footer)
	local backBtn = Instance.new("TextButton")
	backBtn.Text = "← BACK"
	backBtn.Font = Enum.Font.GothamBold
	backBtn.TextSize = 14
	backBtn.TextColor3 = Color3.new(1, 1, 1)
	backBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
	backBtn.Size = UDim2.fromOffset(100, 40)
	backBtn.Position = UDim2.new(0, 40, 1, -50)
	backBtn.Parent = frame
	Instance.new("UICorner", backBtn).CornerRadius = UDim.new(0, 4)
	
	backBtn.MouseButton1Click:Connect(function()
		ViewManager.SwitchTo("Home")
	end)

	-- Default Load
	loadCategory("General")
	
	return {
		Instance = frame,
		Destroy = function()
			for _, c in ipairs(connections) do c:Disconnect() end
			frame:Destroy()
		end
	}
end

return SettingsView
