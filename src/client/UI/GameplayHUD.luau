--[[
	GameplayHUD - Main in-game HUD
	Displays ammo, health, movement state, reload progress, and weapon info
	Integrates with WeaponController and MovementController
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local GameplayHUD = {}

-- Theme colors
local COLORS = {
	Background = Color3.fromRGB(15, 15, 15),
	AccentBlue = Color3.fromRGB(0, 162, 255),
	AccentGold = Color3.fromRGB(255, 215, 0),
	TextMain = Color3.fromRGB(255, 255, 255),
	TextSecondary = Color3.fromRGB(180, 180, 180),
	Health = Color3.fromRGB(0, 255, 0),
	HealthLow = Color3.fromRGB(255, 0, 0),
	Armor = Color3.fromRGB(0, 150, 255),
}

local screenGui = nil
local ammoFrame = nil
local healthFrame = nil
local movementStateLabel = nil
local reloadProgressBar = nil

-- Create HUD elements
local function createHUD()
	if screenGui then screenGui:Destroy() end
	
	screenGui = Instance.new("ScreenGui")
	screenGui.Name = "GameplayHUD"
	screenGui.ResetOnSpawn = false
	screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	screenGui.Parent = playerGui
	
	-- === AMMO COUNTER (Bottom Right) ===
	ammoFrame = Instance.new("Frame")
	ammoFrame.Name = "AmmoCounter"
	ammoFrame.Size = UDim2.new(0, 200, 0, 80)
	ammoFrame.Position = UDim2.new(1, -220, 1, -100)
	ammoFrame.BackgroundTransparency = 1
	ammoFrame.Parent = screenGui
	
	local currentAmmoLabel = Instance.new("TextLabel")
	currentAmmoLabel.Name = "CurrentAmmo"
	currentAmmoLabel.Size = UDim2.new(0, 120, 0, 50)
	currentAmmoLabel.Position = UDim2.new(0, 0, 0, 0)
	currentAmmoLabel.BackgroundTransparency = 1
	currentAmmoLabel.Text = "30"
	currentAmmoLabel.TextColor3 = COLORS.TextMain
	currentAmmoLabel.Font = Enum.Font.GothamBlack
	currentAmmoLabel.TextSize = 48
	currentAmmoLabel.TextXAlignment = Enum.TextXAlignment.Right
	currentAmmoLabel.Parent = ammoFrame
	
	local reserveAmmoLabel = Instance.new("TextLabel")
	reserveAmmoLabel.Name = "ReserveAmmo"
	reserveAmmoLabel.Size = UDim2.new(0, 80, 0, 30)
	reserveAmmoLabel.Position = UDim2.new(0, 130, 0, 50)
	reserveAmmoLabel.BackgroundTransparency = 1
	reserveAmmoLabel.Text = "90"
	reserveAmmoLabel.TextColor3 = COLORS.TextSecondary
	reserveAmmoLabel.Font = Enum.Font.GothamBold
	reserveAmmoLabel.TextSize = 20
	reserveAmmoLabel.TextXAlignment = Enum.TextXAlignment.Left
	reserveAmmoLabel.Parent = ammoFrame
	
	local weaponNameLabel = Instance.new("TextLabel")
	weaponNameLabel.Name = "WeaponName"
	weaponNameLabel.Size = UDim2.new(1, 0, 0, 20)
	weaponNameLabel.Position = UDim2.new(0, 0, 1, 5)
	weaponNameLabel.BackgroundTransparency = 1
	weaponNameLabel.Text = "M4"
	weaponNameLabel.TextColor3 = COLORS.TextSecondary
	weaponNameLabel.Font = Enum.Font.Gotham
	weaponNameLabel.TextSize = 14
	weaponNameLabel.TextXAlignment = Enum.TextXAlignment.Right
	weaponNameLabel.Parent = ammoFrame
	
	-- === HEALTH & ARMOR (Bottom Left) ===
	healthFrame = Instance.new("Frame")
	healthFrame.Name = "HealthBar"
	healthFrame.Size = UDim2.new(0, 300, 0, 60)
	healthFrame.Position = UDim2.new(0, 20, 1, -100)
	healthFrame.BackgroundTransparency = 1
	healthFrame.Parent = screenGui
	
	local healthBarBg = Instance.new("Frame")
	healthBarBg.Name = "HealthBarBg"
	healthBarBg.Size = UDim2.new(1, 0, 0, 25)
	healthBarBg.Position = UDim2.new(0, 0, 0, 0)
	healthBarBg.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
	healthBarBg.BorderSizePixel = 0
	healthBarBg.Parent = healthFrame
	Instance.new("UICorner", healthBarBg).CornerRadius = UDim.new(0, 4)
	
	local healthBarFill = Instance.new("Frame")
	healthBarFill.Name = "HealthBarFill"
	healthBarFill.Size = UDim2.new(1, 0, 1, 0)
	healthBarFill.BackgroundColor3 = COLORS.Health
	healthBarFill.BorderSizePixel = 0
	healthBarFill.Parent = healthBarBg
	Instance.new("UICorner", healthBarFill).CornerRadius = UDim.new(0, 4)
	
	local healthLabel = Instance.new("TextLabel")
	healthLabel.Name = "HealthLabel"
	healthLabel.Size = UDim2.new(1, 0, 1, 0)
	healthLabel.BackgroundTransparency = 1
	healthLabel.Text = "100"
	healthLabel.TextColor3 = COLORS.TextMain
	healthLabel.Font = Enum.Font.GothamBold
	healthLabel.TextSize = 16
	healthLabel.Parent = healthBarBg
	
	local armorBarBg = Instance.new("Frame")
	armorBarBg.Name = "ArmorBarBg"
	armorBarBg.Size = UDim2.new(1, 0, 0, 20)
	armorBarBg.Position = UDim2.new(0, 0, 1, -20)
	armorBarBg.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
	armorBarBg.BorderSizePixel = 0
	armorBarBg.Parent = healthFrame
	Instance.new("UICorner", armorBarBg).CornerRadius = UDim.new(0, 4)
	
	local armorBarFill = Instance.new("Frame")
	armorBarFill.Name = "ArmorBarFill"
	armorBarFill.Size = UDim2.new(0, 0, 1, 0)
	armorBarFill.BackgroundColor3 = COLORS.Armor
	armorBarFill.BorderSizePixel = 0
	armorBarFill.Parent = armorBarBg
	Instance.new("UICorner", armorBarFill).CornerRadius = UDim.new(0, 4)
	
	-- === MOVEMENT STATE (Top Center) ===
	movementStateLabel = Instance.new("TextLabel")
	movementStateLabel.Name = "MovementState"
	movementStateLabel.Size = UDim2.new(0, 200, 0, 30)
	movementStateLabel.Position = UDim2.new(0.5, -100, 0, 20)
	movementStateLabel.BackgroundTransparency = 1
	movementStateLabel.Text = ""
	movementStateLabel.TextColor3 = COLORS.TextSecondary
	movementStateLabel.Font = Enum.Font.Gotham
	movementStateLabel.TextSize = 12
	movementStateLabel.Visible = false
	movementStateLabel.Parent = screenGui
	
	-- === RELOAD PROGRESS (Center) ===
	local reloadFrame = Instance.new("Frame")
	reloadFrame.Name = "ReloadProgress"
	reloadFrame.Size = UDim2.new(0, 300, 0, 40)
	reloadFrame.Position = UDim2.new(0.5, -150, 0.5, 0)
	reloadFrame.BackgroundTransparency = 1
	reloadFrame.Visible = false
	reloadFrame.Parent = screenGui
	
	local reloadBarBg = Instance.new("Frame")
	reloadBarBg.Name = "ReloadBarBg"
	reloadBarBg.Size = UDim2.new(1, 0, 0, 6)
	reloadBarBg.Position = UDim2.new(0, 0, 0.5, 0)
	reloadBarBg.AnchorPoint = Vector2.new(0, 0.5)
	reloadBarBg.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
	reloadBarBg.BorderSizePixel = 0
	reloadBarBg.Parent = reloadFrame
	Instance.new("UICorner", reloadBarBg).CornerRadius = UDim.new(0, 3)
	
	reloadProgressBar = Instance.new("Frame")
	reloadProgressBar.Name = "ReloadBarFill"
	reloadProgressBar.Size = UDim2.new(0, 0, 1, 0)
	reloadProgressBar.BackgroundColor3 = COLORS.AccentBlue
	reloadProgressBar.BorderSizePixel = 0
	reloadProgressBar.Parent = reloadBarBg
	Instance.new("UICorner", reloadProgressBar).CornerRadius = UDim.new(0, 3)
	
	local reloadLabel = Instance.new("TextLabel")
	reloadLabel.Name = "ReloadLabel"
	reloadLabel.Size = UDim2.new(1, 0, 1, 0)
	reloadLabel.BackgroundTransparency = 1
	reloadLabel.Text = "RELOADING"
	reloadLabel.TextColor3 = COLORS.TextMain
	reloadLabel.Font = Enum.Font.GothamBold
	reloadLabel.TextSize = 14
	reloadLabel.Parent = reloadFrame
end

-- Update ammo display
function GameplayHUD.UpdateAmmo(ammo, reserve, maxAmmo, maxReserve)
	if not ammoFrame then return end
	
	local currentAmmoLabel = ammoFrame:FindFirstChild("CurrentAmmo")
	local reserveAmmoLabel = ammoFrame:FindFirstChild("ReserveAmmo")
	
	if currentAmmoLabel then
		currentAmmoLabel.Text = tostring(ammo)
		-- Change color if low ammo
		if ammo <= maxAmmo * 0.3 then
			currentAmmoLabel.TextColor3 = COLORS.HealthLow
		else
			currentAmmoLabel.TextColor3 = COLORS.TextMain
		end
	end
	
	if reserveAmmoLabel then
		reserveAmmoLabel.Text = tostring(reserve)
	end
end

-- Update weapon name
function GameplayHUD.UpdateWeaponName(weaponName)
	if not ammoFrame then return end
	
	local weaponNameLabel = ammoFrame:FindFirstChild("WeaponName")
	if weaponNameLabel then
		weaponNameLabel.Text = weaponName or ""
	end
end

-- Update health display
function GameplayHUD.UpdateHealth(health, maxHealth)
	if not healthFrame then return end
	
	local healthBarFill = healthFrame:FindFirstChild("HealthBarBg"):FindFirstChild("HealthBarFill")
	local healthLabel = healthFrame:FindFirstChild("HealthBarBg"):FindFirstChild("HealthLabel")
	
	if healthBarFill then
		local healthPercent = math.clamp(health / maxHealth, 0, 1)
		healthBarFill.Size = UDim2.new(healthPercent, 0, 1, 0)
		
		-- Change color based on health
		if healthPercent <= 0.3 then
			healthBarFill.BackgroundColor3 = COLORS.HealthLow
		elseif healthPercent <= 0.6 then
			healthBarFill.BackgroundColor3 = Color3.fromRGB(255, 200, 0)
		else
			healthBarFill.BackgroundColor3 = COLORS.Health
		end
	end
	
	if healthLabel then
		healthLabel.Text = tostring(math.ceil(health))
	end
end

-- Update armor display
function GameplayHUD.UpdateArmor(armor, maxArmor)
	if not healthFrame then return end
	
	local armorBarFill = healthFrame:FindFirstChild("ArmorBarBg"):FindFirstChild("ArmorBarFill")
	
	if armorBarFill then
		local armorPercent = math.clamp(armor / maxArmor, 0, 1)
		armorBarFill.Size = UDim2.new(armorPercent, 0, 1, 0)
	end
end

-- Update movement state
function GameplayHUD.UpdateMovementState(state)
	if not movementStateLabel then return end
	
	if state and state ~= "Idle" and state ~= "Walk" then
		movementStateLabel.Text = state:upper()
		movementStateLabel.Visible = true
	else
		movementStateLabel.Visible = false
	end
end

-- Update reload progress
function GameplayHUD.UpdateReloadProgress(progress, isReloading)
	if not screenGui then return end
	
	local reloadFrame = screenGui:FindFirstChild("ReloadProgress")
	if not reloadFrame then return end
	
	if isReloading and progress > 0 then
		reloadFrame.Visible = true
		local reloadBarFill = reloadFrame:FindFirstChild("ReloadBarBg"):FindFirstChild("ReloadBarFill")
		if reloadBarFill then
			reloadBarFill.Size = UDim2.new(progress, 0, 1, 0)
		end
	else
		reloadFrame.Visible = false
	end
end

-- Show/Hide HUD
function GameplayHUD.SetVisible(visible)
	if screenGui then
		screenGui.Enabled = visible
	end
end

-- Initialize
function GameplayHUD.Init()
	createHUD()
	
	-- Monitor menu state
	player:GetAttributeChangedSignal("InMenu"):Connect(function()
		local inMenu = player:GetAttribute("InMenu") or false
		GameplayHUD.SetVisible(not inMenu)
	end)
	
	-- Initial visibility
	local inMenu = player:GetAttribute("InMenu") or false
	GameplayHUD.SetVisible(not inMenu)
	
	print("[GameplayHUD] Initialized")
end

return GameplayHUD
