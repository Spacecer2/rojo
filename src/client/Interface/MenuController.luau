local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")

local Controllers = script.Parent.Parent.Controllers
local ViewManager = require(Controllers:WaitForChild("ViewManager"))
local HomeView = require(script.Parent.Parent.UI.Views.HomeView)
local LoadoutView = require(script.Parent.Parent.UI.Views.LoadoutView)

local MenuController = {}

-- Theme Colors
local COLORS = {
	Background = Color3.fromRGB(15, 15, 15),
	Panel = Color3.fromRGB(30, 30, 35),
	AccentBlue = Color3.fromRGB(0, 162, 255),
	TextMain = Color3.fromRGB(255, 255, 255),
	TextSecondary = Color3.fromRGB(180, 180, 180),
}

function MenuController.Start()
	local player = Players.LocalPlayer
	local playerGui = player:WaitForChild("PlayerGui")

	-- Global State
	player:SetAttribute("InMenu", true)
	player.CameraMode = Enum.CameraMode.Classic
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
	topBar.Size = UDim2.new(1, 0, 0, 60)
	topBar.BackgroundColor3 = Color3.new(0,0,0)
	topBar.BackgroundTransparency = 0.4
	topBar.Parent = mainFrame

	local tabContainer = Instance.new("Frame")
	tabContainer.Name = "Tabs"
	tabContainer.Size = UDim2.new(0, 600, 1, 0)
	tabContainer.Position = UDim2.fromScale(0.5, 0)
	tabContainer.AnchorPoint = Vector2.new(0.5, 0)
	tabContainer.BackgroundTransparency = 1
	tabContainer.Parent = topBar

	local tabLayout = Instance.new("UIListLayout")
	tabLayout.FillDirection = Enum.FillDirection.Horizontal
	tabLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
	tabLayout.Padding = UDim.new(0, 30)
	tabLayout.Parent = tabContainer
	
	-- 3. Content Container
	local contentContainer = Instance.new("Frame")
	contentContainer.Name = "ContentContainer"
	contentContainer.Size = UDim2.new(1, 0, 1, -60)
	contentContainer.Position = UDim2.fromOffset(0, 60)
	contentContainer.BackgroundTransparency = 1
	contentContainer.Parent = mainFrame

	-- 4. Initialize ViewManager
	ViewManager.SetContainer(contentContainer)
	ViewManager.RegisterView("PLAY", HomeView)
	ViewManager.RegisterView("WEAPONS", LoadoutView)

	-- 5. Create Tabs
	local tabs = {"PLAY", "WEAPONS", "OPERATORS", "STORE"}
	for _, tabName in ipairs(tabs) do
		local btn = Instance.new("TextButton")
		btn.Text = tabName
		btn.Font = Enum.Font.GothamBold
		btn.TextSize = 14
		btn.TextColor3 = COLORS.TextSecondary
		btn.BackgroundTransparency = 1
		btn.Size = UDim2.new(0, 100, 1, 0)
		btn.Parent = tabContainer
		
		btn.MouseButton1Click:Connect(function()
			ViewManager.SwitchTo(tabName)
			
			-- Update visual
			for _, child in ipairs(tabContainer:GetChildren()) do
				if child:IsA("TextButton") then
					child.TextColor3 = COLORS.TextSecondary
				end
			end
			btn.TextColor3 = COLORS.AccentBlue
		end)
	end

	-- Default View
	ViewManager.SwitchTo("PLAY")
	
	print("MenuController Refactored and Started")
end

return MenuController
