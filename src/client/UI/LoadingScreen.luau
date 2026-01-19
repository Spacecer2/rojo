--[[
	LoadingScreen - Real progress tracking for game initialization
	Shows loading progress while controllers, services, and views load
]]
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")

local LoadingScreen = {}

local screenGui = nil
local background = nil
local container = nil
local progressBar = nil
local progressLabel = nil
local currentProgress = 0

function LoadingScreen.Create()
	local player = Players.LocalPlayer
	local playerGui = player:WaitForChild("PlayerGui")
	
	-- Create ScreenGui
	screenGui = Instance.new("ScreenGui")
	screenGui.Name = "LoadingScreen"
	screenGui.IgnoreGuiInset = true
	screenGui.ResetOnSpawn = false
	screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	screenGui.DisplayOrder = 10
	screenGui.Parent = playerGui
	
	-- Background
	background = Instance.new("Frame")
	background.Name = "Background"
	background.Size = UDim2.fromScale(1, 1)
	background.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
	background.BorderSizePixel = 0
	background.Parent = screenGui
	
	-- Container
	container = Instance.new("Frame")
	container.Name = "Container"
	container.Size = UDim2.fromOffset(600, 200)
	container.Position = UDim2.fromScale(0.5, 0.5)
	container.AnchorPoint = Vector2.new(0.5, 0.5)
	container.BackgroundTransparency = 1
	container.Parent = screenGui
	
	-- Title
	local title = Instance.new("TextLabel")
	title.Name = "Title"
	title.Text = "WARZONE"
	title.Font = Enum.Font.GothamBlack
	title.TextSize = 48
	title.TextColor3 = Color3.fromRGB(0, 162, 255)
	title.Size = UDim2.new(1, 0, 0, 60)
	title.Position = UDim2.fromOffset(0, 0)
	title.BackgroundTransparency = 1
	title.Parent = container
	
	-- Status Label
	progressLabel = Instance.new("TextLabel")
	progressLabel.Name = "StatusLabel"
	progressLabel.Text = "Initializing..."
	progressLabel.Font = Enum.Font.GothamBold
	progressLabel.TextSize = 18
	progressLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	progressLabel.Size = UDim2.new(1, 0, 0, 30)
	progressLabel.Position = UDim2.fromOffset(0, 70)
	progressLabel.BackgroundTransparency = 1
	progressLabel.Parent = container
	
	-- Progress Bar Background
	local progressBg = Instance.new("Frame")
	progressBg.Name = "ProgressBarBg"
	progressBg.Size = UDim2.new(1, 0, 0, 8)
	progressBg.Position = UDim2.fromOffset(0, 110)
	progressBg.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
	progressBg.BorderSizePixel = 0
	progressBg.Parent = container
	Instance.new("UICorner", progressBg).CornerRadius = UDim.new(0, 4)
	
	-- Progress Bar Fill
	progressBar = Instance.new("Frame")
	progressBar.Name = "ProgressBar"
	progressBar.Size = UDim2.fromScale(0, 1)
	progressBar.Position = UDim2.fromOffset(0, 0)
	progressBar.BackgroundColor3 = Color3.fromRGB(0, 162, 255)
	progressBar.BorderSizePixel = 0
	progressBar.Parent = progressBg
	Instance.new("UICorner", progressBar).CornerRadius = UDim.new(0, 4)
	
	-- Percentage Label
	local percentLabel = Instance.new("TextLabel")
	percentLabel.Name = "PercentLabel"
	percentLabel.Text = "0%"
	percentLabel.Font = Enum.Font.GothamBold
	percentLabel.TextSize = 16
	percentLabel.TextColor3 = Color3.fromRGB(180, 180, 180)
	percentLabel.Size = UDim2.new(1, 0, 0, 25)
	percentLabel.Position = UDim2.fromOffset(0, 125)
	percentLabel.BackgroundTransparency = 1
	percentLabel.Parent = container
	
	-- Store reference for updates
	LoadingScreen._percentLabel = percentLabel
	
	return screenGui
end

function LoadingScreen.SetProgress(progress, status)
	progress = math.clamp(progress, 0, 100)
	currentProgress = progress
	
	if progressBar then
		local targetSize = UDim2.fromScale(progress / 100, 1)
		TweenService:Create(progressBar, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			Size = targetSize
		}):Play()
	end
	
	if progressLabel and status then
		progressLabel.Text = status
	end
	
	if LoadingScreen._percentLabel then
		LoadingScreen._percentLabel.Text = math.floor(progress) .. "%"
	end
end

function LoadingScreen.Hide()
	if screenGui then
		-- Fade out animation
		local fadeInfo = TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
		
		if background then
			TweenService:Create(background, fadeInfo, {BackgroundTransparency = 1}):Play()
		end
		
		if container then
			-- Fade container background
			TweenService:Create(container, fadeInfo, {BackgroundTransparency = 1}):Play()
			
			-- Fade all text and descendants in container
			for _, child in ipairs(container:GetDescendants()) do
				if child:IsA("TextLabel") or child:IsA("TextButton") or child:IsA("TextBox") then
					TweenService:Create(child, fadeInfo, {TextTransparency = 1, BackgroundTransparency = 1}):Play()
				elseif child:IsA("Frame") then
					TweenService:Create(child, fadeInfo, {BackgroundTransparency = 1}):Play()
				elseif child:IsA("ImageLabel") or child:IsA("ImageButton") then
					TweenService:Create(child, fadeInfo, {ImageTransparency = 1, BackgroundTransparency = 1}):Play()
				end
			end
		end
		
		-- Wait for animation
		task.delay(0.5, function()
			if screenGui then
				screenGui:Destroy()
				screenGui = nil
				background = nil
				container = nil
				progressBar = nil
				progressLabel = nil
				LoadingScreen._percentLabel = nil
			end
		end)
	end
end

function LoadingScreen.GetProgress()
	return currentProgress
end

return LoadingScreen
