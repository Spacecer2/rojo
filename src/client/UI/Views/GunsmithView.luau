--[[
	GunsmithView - Weapon customization interface
	Allows players to equip attachments and visualize stat changes.
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local UI = require(script.Parent.Parent)
local Constants = ReplicatedStorage:WaitForChild("Constants")
local WeaponData = require(Constants:WaitForChild("WeaponData"))
local AttachmentData = require(Constants:WaitForChild("AttachmentData"))
local WeaponUtils = require(ReplicatedStorage:WaitForChild("Utils"):WaitForChild("WeaponUtils"))
local Theme = require(Constants:WaitForChild("Theme"))

local Controllers = script.Parent.Parent.Parent.Controllers
local PlayerDataController = require(Controllers:WaitForChild("PlayerDataController"))

local GunsmithView = {}

local COLORS = Theme.Colors or {
	Background = Color3.fromRGB(15, 15, 15),
	Panel = Color3.fromRGB(30, 30, 35),
	AccentBlue = Color3.fromRGB(0, 162, 255),
	TextMain = Color3.fromRGB(255, 255, 255),
	TextSecondary = Color3.fromRGB(180, 180, 180),
}

function GunsmithView.Create(parent, weaponName)
	local connections = {}
	local frame = Instance.new("Frame")
	frame.Name = "GunsmithView"
	frame.Size = UDim2.fromScale(1, 1)
	frame.BackgroundTransparency = 1
	frame.Parent = parent

	-- State
	local currentWeaponName = weaponName or "M4"
	local profile = PlayerDataController.GetProfile()
	local equippedAttachments = profile.Loadouts[profile.SelectedLoadoutId or "DEFAULT"].Attachments[currentWeaponName] or {}

	-- === TOP BAR: Weapon Info ===
	local header = Instance.new("Frame")
	header.Size = UDim2.new(1, -80, 0, 60)
	header.Position = UDim2.fromOffset(40, 20)
	header.BackgroundTransparency = 1
	header.Parent = frame

	local weaponTitle = Instance.new("TextLabel")
	weaponTitle.Text = currentWeaponName:upper()
	weaponTitle.Font = Enum.Font.GothamBlack
	weaponTitle.TextSize = 32
	weaponTitle.TextColor3 = COLORS.TextMain
	weaponTitle.Size = UDim2.new(1, 0, 0, 35)
	weaponTitle.TextXAlignment = Enum.TextXAlignment.Left
	weaponTitle.BackgroundTransparency = 1
	weaponTitle.Parent = header

	local weaponCat = Instance.new("TextLabel")
	weaponCat.Text = WeaponData.Weapons[currentWeaponName].Category:upper()
	weaponCat.Font = Enum.Font.GothamBold
	weaponCat.TextSize = 14
	weaponCat.TextColor3 = COLORS.AccentBlue
	weaponCat.Position = UDim2.fromOffset(0, 35)
	weaponCat.Size = UDim2.new(1, 0, 0, 20)
	weaponCat.TextXAlignment = Enum.TextXAlignment.Left
	weaponCat.BackgroundTransparency = 1
	weaponCat.Parent = header

	-- === CENTER: 3D Viewport ===
	local viewport = Instance.new("ViewportFrame")
	viewport.Size = UDim2.new(1, -400, 1, -250)
	viewport.Position = UDim2.fromOffset(40, 100)
	viewport.BackgroundTransparency = 1
	viewport.Parent = frame

	local cam = Instance.new("Camera")
	cam.FieldOfView = 35
	viewport.CurrentCamera = cam
	cam.Parent = viewport

	local worldModel = Instance.new("WorldModel")
	worldModel.Parent = viewport

	local weaponModel = nil
	
	local function refreshWeaponModel()
		if weaponModel then weaponModel:Destroy() end
		
		local weaponTemplate = ReplicatedStorage.Assets.Weapons:FindFirstChild(currentWeaponName)
		if weaponTemplate then
			weaponModel = weaponTemplate:Clone()
			weaponModel.Parent = worldModel
			
			-- Apply Visual Attachments
			WeaponUtils.AssembleWeapon(weaponModel, equippedAttachments)
			
			-- Position camera
			local cf, size = weaponModel:GetBoundingBox()
			cam.CFrame = CFrame.new(cf.Position + cf.LookVector * 5 + cf.RightVector * 1, cf.Position)
		end
	end
	refreshWeaponModel()

	-- Rotating animation
	table.insert(connections, RunService.RenderStepped:Connect(function(dt)
		if weaponModel then
			weaponModel:PivotTo(weaponModel:GetPivot() * CFrame.Angles(0, dt * 0.2, 0))
		end
	end))

	-- === BOTTOM: Stat Bars ===
	local statPanel = Instance.new("Frame")
	statPanel.Size = UDim2.new(0, 300, 0, 150)
	statPanel.Position = UDim2.new(0, 40, 1, -40)
	statPanel.AnchorPoint = Vector2.new(0, 1)
	statPanel.BackgroundTransparency = 1
	statPanel.Parent = frame

	local function createStatBar(name, index)
		local row = Instance.new("Frame")
		row.Size = UDim2.new(1, 0, 0, 25)
		row.Position = UDim2.fromOffset(0, (index-1) * 25)
		row.BackgroundTransparency = 1
		row.Parent = statPanel

		local label = Instance.new("TextLabel")
		label.Text = name:upper()
		label.Font = Enum.Font.GothamBold
		label.TextSize = 10
		label.TextColor3 = COLORS.TextSecondary
		label.Size = UDim2.new(0.3, 0, 1, 0)
		label.TextXAlignment = Enum.TextXAlignment.Left
		label.BackgroundTransparency = 1
		label.Parent = row

		local barBg = Instance.new("Frame")
		barBg.Size = UDim2.new(0.7, -10, 0, 4)
		barBg.Position = UDim2.new(0.3, 0, 0.5, -2)
		barBg.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
		barBg.BorderSizePixel = 0
		barBg.Parent = row

		local barFill = Instance.new("Frame")
		barFill.Name = "Fill"
		barFill.Size = UDim2.fromScale(0.5, 1)
		barFill.BackgroundColor3 = COLORS.TextMain
		barFill.BorderSizePixel = 0
		barFill.Parent = barBg

		return barFill
	end

	local bars = {
		Accuracy = createStatBar("Accuracy", 1),
		Damage = createStatBar("Damage", 2),
		Range = createStatBar("Range", 3),
		FireRate = createStatBar("Fire Rate", 4),
		Mobility = createStatBar("Mobility", 5),
		Control = createStatBar("Control", 6),
	}

	local function updateStats()
		local stats = WeaponUtils.CalculateStats(currentWeaponName, equippedAttachments)
		local uiStats = WeaponUtils.GetUINormalizedStats(stats)
		
		for name, bar in pairs(bars) do
			if uiStats[name] then
				bar:TweenSize(UDim2.fromScale(uiStats[name], 1), "Out", "Quad", 0.3, true)
			end
		end
	end
	updateStats()

	-- === RIGHT: Attachment Slots ===
	local slotPanel = Instance.new("ScrollingFrame")
	slotPanel.Size = UDim2.new(0, 320, 1, -120)
	slotPanel.Position = UDim2.new(1, -40, 0, 100)
	slotPanel.AnchorPoint = Vector2.new(1, 0)
	slotPanel.BackgroundTransparency = 1
	slotPanel.ScrollBarThickness = 2
	slotPanel.Parent = frame

	local slotLayout = Instance.new("UIListLayout")
	slotLayout.Padding = UDim.new(0, 10)
	slotLayout.Parent = slotPanel

	local weaponConfig = WeaponData.Weapons[currentWeaponName]
	for _, slot in ipairs(weaponConfig.Slots) do
		local slotBtn = Instance.new("Frame")
		slotBtn.Size = UDim2.new(1, 0, 0, 50)
		slotBtn.BackgroundColor3 = COLORS.Panel
		slotBtn.BackgroundTransparency = 0.5
		slotBtn.BorderSizePixel = 0
		slotBtn.Parent = slotPanel

		local slotLabel = Instance.new("TextLabel")
		slotLabel.Text = slot:upper()
		slotLabel.Font = Enum.Font.GothamBold
		slotLabel.TextSize = 10
		slotLabel.TextColor3 = COLORS.TextSecondary
		slotLabel.Position = UDim2.fromOffset(10, 10)
		slotLabel.Size = UDim2.new(1, -20, 0, 10)
		slotLabel.TextXAlignment = Enum.TextXAlignment.Left
		slotLabel.BackgroundTransparency = 1
		slotLabel.Parent = slotBtn

		local currentEquipped = "NONE"
		for _, attName in pairs(equippedAttachments) do
			local attData = AttachmentData.Attachments[attName]
			if attData and attData.Category == slot then
				currentEquipped = attName
				break
			end
		end

		local equippedLabel = Instance.new("TextLabel")
		equippedLabel.Text = currentEquipped
		equippedLabel.Font = Enum.Font.GothamBlack
		equippedLabel.TextSize = 14
		equippedLabel.TextColor3 = currentEquipped == "NONE" and Color3.fromRGB(100, 100, 100) or COLORS.AccentBlue
		equippedLabel.Position = UDim2.fromOffset(10, 25)
		equippedLabel.Size = UDim2.new(1, -20, 0, 20)
		equippedLabel.TextXAlignment = Enum.TextXAlignment.Left
		equippedLabel.BackgroundTransparency = 1
		equippedLabel.Parent = slotBtn

		local btn = Instance.new("TextButton")
		btn.Size = UDim2.fromScale(1, 1)
		btn.BackgroundTransparency = 1
		btn.Text = ""
		btn.Parent = slotBtn
		UI.ApplyFeedback(btn)

		btn.MouseButton1Click:Connect(function()
			-- TODO: Open Attachment Selection Sub-Menu
			print("Opening selection for slot: " .. slot)
		end)
	end

	return {
		Instance = frame,
		Destroy = function()
			for _, c in ipairs(connections) do c:Disconnect() end
			frame:Destroy()
		end
	}
end

return GunsmithView
