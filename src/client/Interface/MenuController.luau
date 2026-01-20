local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")

local Controllers = script.Parent.Parent.Controllers
local ViewManager = require(Controllers:WaitForChild("ViewManager"))

-- Safe view loading
local function safeRequireView(name)
	local views = script.Parent.Parent:WaitForChild("UI"):WaitForChild("Views")
	local module = views:WaitForChild(name, 5)
	if module then
		local success, result = pcall(require, module)
		if success then
			return result
		else
			warn("[MenuController] Failed to require view: " .. name .. " - " .. tostring(result))
		end
	else
		warn("[MenuController] View module not found: " .. name)
	end
	return nil
end

local HomeView = safeRequireView("HomeView")
local LoadoutView = safeRequireView("LoadoutView")
local OperatorsView = safeRequireView("OperatorsView")
local BarracksView = safeRequireView("BarracksView")
local PlayerDataController = nil

local success_pdc, pdc = pcall(function() return require(Controllers:WaitForChild("PlayerDataController")) end)
if success_pdc then PlayerDataController = pdc end

local MenuController = {}

-- Theme Colors
local COLORS = {
	Background = Color3.fromRGB(15, 15, 15),
	Panel = Color3.fromRGB(30, 30, 35),
	AccentBlue = Color3.fromRGB(0, 162, 255),
	AccentGold = Color3.fromRGB(255, 215, 0),
	AccentYellow = Color3.fromRGB(255, 215, 0),
	TextMain = Color3.fromRGB(255, 255, 255),
	TextSecondary = Color3.fromRGB(180, 180, 180),
}

function MenuController.StartLocalGame()
	print("[MenuController] Starting Local Movement Test...")
	
	local player = Players.LocalPlayer
	local playerGui = player:WaitForChild("PlayerGui")
	
	-- 1. Hide Menu
	local screenGui = playerGui:FindFirstChild("WarzoneMenu")
	if screenGui then
		screenGui.Enabled = false
	end
	
	-- 2. Release Camera/Mouse
	player.CameraMode = Enum.CameraMode.LockFirstPerson
	UserInputService.MouseBehavior = Enum.MouseBehavior.LockCenter
	
	-- 3. Update State (Trigger MovementController)
	player:SetAttribute("InMenu", false)
	
	print("[MenuController] Local Game Started")
end

function MenuController.Start()
	local success, err = pcall(function()
		local player = Players.LocalPlayer
		local playerGui = player:WaitForChild("PlayerGui")

		-- Global State
		player:SetAttribute("InMenu", true)
		player.CameraMode = Enum.CameraMode.Classic
		player.ReplicationFocus = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
		UserInputService.MouseBehavior = Enum.MouseBehavior.Default

		-- 1. Setup ScreenGui
		local screenGui = Instance.new("ScreenGui")
		screenGui.Name = "WarzoneMenu"
		screenGui.IgnoreGuiInset = true
		screenGui.ResetOnSpawn = false
		screenGui.Parent = playerGui

		local mainFrame = Instance.new("Frame")
		mainFrame.Name = "MainFrame"
		mainFrame.Size = UDim2.fromScale(1, 1)
		mainFrame.BackgroundTransparency = 1
		mainFrame.Parent = screenGui

		-- 2. Top Bar
		local topBar = Instance.new("Frame")
		topBar.Name = "TopBar"
		topBar.Size = UDim2.new(1, 0, 0, 100)
		topBar.BackgroundColor3 = Color3.new(0,0,0)
		topBar.BackgroundTransparency = 0.4
		topBar.Parent = mainFrame
		
		-- WARZONE Branding
		local branding = Instance.new("TextLabel")
		branding.Name = "Branding"
		branding.Text = "WARZONE"
		branding.Font = Enum.Font.GothamBlack
		branding.TextSize = 28
		branding.TextColor3 = Color3.new(1, 1, 1)
		branding.Size = UDim2.fromOffset(200, 40)
		branding.Position = UDim2.fromOffset(40, 10)
		branding.BackgroundTransparency = 1
		branding.TextXAlignment = Enum.TextXAlignment.Left
		branding.Parent = topBar

		-- Resource Bar (Top Right)
		local resources = Instance.new("Frame")
		resources.Name = "ResourceBar"
		resources.Size = UDim2.fromOffset(400, 40)
		resources.Position = UDim2.new(1, -40, 0, 10)
		resources.AnchorPoint = Vector2.new(1, 0)
		resources.BackgroundTransparency = 1
		resources.Parent = topBar
		
		local resLayout = Instance.new("UIListLayout")
		resLayout.FillDirection = Enum.FillDirection.Horizontal
		resLayout.HorizontalAlignment = Enum.HorizontalAlignment.Right
		resLayout.Padding = UDim.new(0, 20)
		resLayout.Parent = resources

		local rankItem = Instance.new("TextLabel")
		rankItem.Name = "RankItem"
		rankItem.TextSize = 14
		rankItem.Font = Enum.Font.GothamBold
		rankItem.TextColor3 = Color3.new(1, 1, 1)
		rankItem.BackgroundTransparency = 1
		rankItem.Size = UDim2.new(0, 120, 1, 0)
		rankItem.Parent = resources

		local cpItem = Instance.new("TextLabel")
		cpItem.Name = "CPItem"
		cpItem.TextSize = 14
		cpItem.Font = Enum.Font.GothamBold
		cpItem.TextColor3 = COLORS.AccentGold
		cpItem.BackgroundTransparency = 1
		cpItem.Size = UDim2.new(0, 80, 1, 0)
		cpItem.Parent = resources

		local socialItem = Instance.new("TextLabel")
		socialItem.Name = "SocialItem"
		socialItem.Text = "👥 Social"
		socialItem.TextSize = 14
		socialItem.Font = Enum.Font.GothamBold
		socialItem.TextColor3 = Color3.new(1, 1, 1)
		socialItem.BackgroundTransparency = 1
		socialItem.Size = UDim2.new(0, 80, 1, 0)
		socialItem.Parent = resources

		local function updateTopBar(profile)
			profile = profile or (PlayerDataController and PlayerDataController.GetProfile()) or {}
			rankItem.Text = "🎖️ Rank " .. (profile.Level or 77)
			cpItem.Text = "🪙 " .. (profile.Currency or 500)
		end

		if PlayerDataController and PlayerDataController.ProfileChanged then
			PlayerDataController.ProfileChanged.Event:Connect(updateTopBar)
		end
		updateTopBar()

		-- Tab Navigation
		local tabContainer = Instance.new("Frame")
		tabContainer.Name = "TabContainer"
		tabContainer.Size = UDim2.new(1, -80, 0, 40)
		tabContainer.Position = UDim2.fromOffset(40, 50)
		tabContainer.BackgroundTransparency = 1
		tabContainer.Parent = topBar
		
		local tabLayout = Instance.new("UIListLayout")
		tabLayout.FillDirection = Enum.FillDirection.Horizontal
		tabLayout.Padding = UDim.new(0, 20)
		tabLayout.Parent = tabContainer

		-- 3. Content Container
		local contentContainer = Instance.new("Frame")
		contentContainer.Name = "ContentContainer"
		contentContainer.Size = UDim2.new(1, 0, 1, -140)
		contentContainer.Position = UDim2.fromOffset(0, 100)
		contentContainer.BackgroundTransparency = 1
		contentContainer.Parent = mainFrame
		
		-- 4. Footer
		local footer = Instance.new("Frame")
		footer.Name = "Footer"
		footer.Size = UDim2.new(1, 0, 0, 40)
		footer.Position = UDim2.fromScale(0, 1)
		footer.AnchorPoint = Vector2.new(0, 1)
		footer.BackgroundColor3 = Color3.new(0,0,0)
		footer.BackgroundTransparency = 0.6
		footer.Parent = mainFrame

		local prompts = Instance.new("TextLabel")
		prompts.Text = "🔘 Back  🅧 Select  🔘 Options"
		prompts.Font = Enum.Font.Gotham
		prompts.TextSize = 12
		prompts.TextColor3 = Color3.fromRGB(180, 180, 180)
		prompts.Size = UDim2.new(0, 400, 1, 0)
		prompts.Position = UDim2.fromOffset(40, 0)
		prompts.BackgroundTransparency = 1
		prompts.TextXAlignment = Enum.TextXAlignment.Left
		prompts.Parent = footer
		
		local statusMsg = Instance.new("TextLabel")
		statusMsg.Name = "StatusMsg"
		statusMsg.Text = "Welcome to Modern Warfare. Have fun, stay frosty."
		statusMsg.Font = Enum.Font.Gotham
		statusMsg.TextSize = 12
		statusMsg.TextColor3 = Color3.fromRGB(150, 150, 150)
		statusMsg.Size = UDim2.new(0, 400, 1, 0)
		statusMsg.Position = UDim2.new(1, -40, 0, 0)
		statusMsg.AnchorPoint = Vector2.new(1, 0)
		statusMsg.BackgroundTransparency = 1
		statusMsg.TextXAlignment = Enum.TextXAlignment.Right
		statusMsg.Parent = footer

		function MenuController.SetFooterStatus(text)
			if statusMsg then statusMsg.Text = text end
		end

		-- TextChatService setup... (rest remains similar)
		task.spawn(function()
			local TextChatService = game:GetService("TextChatService")
			
			-- Configure Chat Window (Warzone-style)
			local chatWindowConfig = TextChatService:FindFirstChildOfClass("ChatWindowConfiguration")
			if chatWindowConfig then
				chatWindowConfig.Enabled = true
				chatWindowConfig.HorizontalAlignment = Enum.HorizontalAlignment.Right
				chatWindowConfig.VerticalAlignment = Enum.VerticalAlignment.Bottom
				chatWindowConfig.BackgroundTransparency = 1 -- Fully transparent background
				-- Use FontFrontface for modern TextChatService properties
				chatWindowConfig.FontFace = Font.fromEnum(Enum.Font.Gotham)
				chatWindowConfig.TextSize = 14
				chatWindowConfig.TextColor3 = COLORS.TextMain
			end

			local chatInputConfig = TextChatService:FindFirstChildOfClass("ChatInputBarConfiguration")
			if chatInputConfig then
				chatInputConfig.Enabled = true
				chatInputConfig.FontFace = Font.fromEnum(Enum.Font.GothamBold)
				chatInputConfig.TextSize = 14
				chatInputConfig.BackgroundTransparency = 0.5 -- Semi-transparent input bar
			end
		end)
		-- 5. Initialize ViewManager
		ViewManager.SetContainer(contentContainer)
		if HomeView then ViewManager.RegisterView("Home", HomeView) end
		if LoadoutView then ViewManager.RegisterView("Weapons", LoadoutView) end
		if OperatorsView then ViewManager.RegisterView("Operators", OperatorsView) end
		if BarracksView then ViewManager.RegisterView("Barracks", BarracksView) end

		-- 6. Create Tabs
		local function createTab(tabName, viewName)
			local btn = Instance.new("TextButton")
			btn.Text = tabName
			btn.Font = Enum.Font.GothamBold
			btn.TextSize = 14
			btn.TextColor3 = COLORS.TextSecondary
			btn.BackgroundTransparency = 1
			btn.Size = UDim2.new(0, 100, 1, 0)
			btn.Parent = tabContainer
			
			btn.MouseButton1Click:Connect(function()
				ViewManager.SwitchTo(viewName)
				for _, child in ipairs(tabContainer:GetChildren()) do
					if child:IsA("TextButton") then
						child.TextColor3 = COLORS.TextSecondary
					end
				end
				btn.TextColor3 = COLORS.AccentBlue
			end)
		end

				createTab("PLAY", "Home")
				createTab("WEAPONS", "Weapons")
				createTab("OPERATORS", "Operators")
				createTab("BARRACKS", "Barracks")
				createTab("BATTLE PASS", "Home")
				createTab("STORE", "Home")

				-- Default View
				ViewManager.SwitchTo("Home")
		
		print("MenuController Refactored and Started")
	end)
	
	if not success then
		warn("[MenuController] Failed to start: " .. tostring(err))
	end
end

return MenuController
