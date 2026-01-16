local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")

local LoadoutData = require(script.Parent.LoadoutData)

local WeaponsMenu = {}

local COLORS = {
	Background = Color3.fromRGB(15, 15, 15),
	Panel = Color3.fromRGB(30, 30, 35),
	AccentBlue = Color3.fromRGB(0, 162, 255),
	AccentGold = Color3.fromRGB(255, 215, 0),
	TextMain = Color3.fromRGB(255, 255, 255),
	TextSecondary = Color3.fromRGB(180, 180, 180),
	Delete = Color3.fromRGB(255, 70, 70)
}

function WeaponsMenu.Create(parent)
	local container = Instance.new("Frame")
	container.Name = "WeaponsMenu"
	container.Size = UDim2.fromScale(1, 1)
	container.BackgroundTransparency = 1
	container.Parent = parent
	
	-- Title
	local title = Instance.new("TextLabel")
	title.Text = "EDIT LOADOUTS"
	title.Font = Enum.Font.GothamBlack
	title.TextSize = 32
	title.TextColor3 = COLORS.TextMain
	title.Position = UDim2.fromOffset(40, 20)
	title.Size = UDim2.new(0, 300, 0, 40)
	title.TextXAlignment = Enum.TextXAlignment.Left
	title.BackgroundTransparency = 1
	title.Parent = container
	
	local sidebar = Instance.new("ScrollingFrame")
	sidebar.Name = "Sidebar"
	sidebar.Position = UDim2.fromOffset(40, 80)
	sidebar.Size = UDim2.new(0, 300, 1, -180)
	sidebar.BackgroundTransparency = 1
	sidebar.ScrollBarThickness = 2
	sidebar.Parent = container
	
	local sidebarLayout = Instance.new("UIListLayout")
	sidebarLayout.Padding = UDim.new(0, 5)
	sidebarLayout.Parent = sidebar
	
	local centerPanel = Instance.new("Frame")
	centerPanel.Name = "CenterPanel"
	centerPanel.Position = UDim2.new(0, 360, 0, 80)
	centerPanel.Size = UDim2.new(0, 450, 1, -120)
	centerPanel.BackgroundTransparency = 1
	centerPanel.Parent = container

	local selectedId = 1

	-- Helper: Create Weapon Slot
	local function createWeaponSlot(parent, label, weaponData)
		local slot = Instance.new("Frame")
		slot.Size = UDim2.new(1, 0, 0, 110)
		slot.BackgroundColor3 = COLORS.Panel
		slot.BackgroundTransparency = 0.2
		slot.Parent = parent
		Instance.new("UICorner", slot)
		
		local lbl = Instance.new("TextLabel")
		lbl.Text = label:upper()
		lbl.Font = Enum.Font.GothamBold
		lbl.TextSize = 10
		lbl.TextColor3 = COLORS.TextSecondary
		lbl.Position = UDim2.fromOffset(15, 10)
		lbl.Size = UDim2.new(1, -30, 0, 15)
		lbl.TextXAlignment = Enum.TextXAlignment.Left
		lbl.BackgroundTransparency = 1
		lbl.Parent = slot
		
		local nameLbl = Instance.new("TextLabel")
		nameLbl.Text = weaponData.Name:upper()
		nameLbl.Font = Enum.Font.GothamBlack
		nameLbl.TextSize = 22
		nameLbl.TextColor3 = COLORS.TextMain
		nameLbl.Position = UDim2.fromOffset(15, 25)
		nameLbl.Size = UDim2.new(1, -30, 0, 30)
		nameLbl.TextXAlignment = Enum.TextXAlignment.Left
		nameLbl.BackgroundTransparency = 1
		nameLbl.Parent = slot
		
		local catLbl = Instance.new("TextLabel")
		catLbl.Text = weaponData.Category:upper()
		catLbl.Font = Enum.Font.Gotham
		catLbl.TextSize = 12
		catLbl.TextColor3 = COLORS.AccentGold
		catLbl.Position = UDim2.fromOffset(15, 55)
		catLbl.Size = UDim2.new(1, -30, 0, 15)
		catLbl.TextXAlignment = Enum.TextXAlignment.Left
		catLbl.BackgroundTransparency = 1
		catLbl.Parent = slot
		
		local xpBg = Instance.new("Frame")
		xpBg.Size = UDim2.new(1, -30, 0, 4)
		xpBg.Position = UDim2.new(0, 15, 1, -15)
		xpBg.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
		xpBg.BorderSizePixel = 0
		xpBg.Parent = slot
		
		local xpFill = Instance.new("Frame")
		xpFill.Size = UDim2.fromScale(weaponData.Progress/weaponData.Max, 1)
		xpFill.BackgroundColor3 = COLORS.AccentGold
		xpFill.BorderSizePixel = 0
		xpFill.Parent = xpBg
	end

	local function refreshEditor(loadout)
		centerPanel:ClearAllChildren()
		
		local layout = Instance.new("UIListLayout")
		layout.Padding = UDim.new(0, 15)
		layout.Parent = centerPanel
		
		createWeaponSlot(centerPanel, "Primary Weapon", loadout.Primary)
		createWeaponSlot(centerPanel, "Secondary Weapon", loadout.Secondary)
		
		-- Perks
		local perksFrame = Instance.new("Frame")
		perksFrame.Size = UDim2.new(1, 0, 0, 70)
		perksFrame.BackgroundTransparency = 1
		perksFrame.Parent = centerPanel
		
		local perksLayout = Instance.new("UIListLayout")
		perksLayout.FillDirection = Enum.FillDirection.Horizontal
		perksLayout.Padding = UDim.new(0, 10)
		perksLayout.Parent = perksFrame
		
		for _, perk in ipairs(loadout.Perks) do
			local p = Instance.new("Frame")
			p.Size = UDim2.new(0.31, 0, 1, 0)
			p.BackgroundColor3 = COLORS.Panel
			p.Parent = perksFrame
			Instance.new("UICorner", p).CornerRadius = UDim.new(0, 8)
			
			local l = Instance.new("TextLabel")
			l.Text = perk:upper()
			l.Font = Enum.Font.GothamBold
			l.TextSize = 12
			l.TextColor3 = COLORS.TextMain
			l.Size = UDim2.fromScale(1, 1)
			l.BackgroundTransparency = 1
			l.Parent = p
		end
		
		-- Equipment
		local eqFrame = Instance.new("Frame")
		eqFrame.Size = UDim2.new(1, 0, 0, 70)
		eqFrame.BackgroundTransparency = 1
		eqFrame.Parent = centerPanel
		
		local function addEq(name, label)
			local f = Instance.new("Frame")
			f.Size = UDim2.new(0.48, 0, 1, 0)
			f.BackgroundColor3 = COLORS.Panel
			f.Parent = eqFrame
			Instance.new("UICorner", f)
			
			local tl = Instance.new("TextLabel")
			tl.Text = label:upper()
			tl.Font = Enum.Font.GothamBold
			tl.TextSize = 9
			tl.TextColor3 = COLORS.TextSecondary
			tl.Position = UDim2.fromOffset(10, 10)
			tl.Size = UDim2.new(1, -20, 0, 10)
			tl.TextXAlignment = Enum.TextXAlignment.Left
			tl.BackgroundTransparency = 1
			tl.Parent = f
			
			local nl = Instance.new("TextLabel")
			nl.Text = name:upper()
			nl.Font = Enum.Font.GothamBold
			nl.TextSize = 14
			nl.TextColor3 = COLORS.TextMain
			nl.Position = UDim2.fromOffset(10, 25)
			nl.Size = UDim2.new(1, -20, 0, 20)
			nl.TextXAlignment = Enum.TextXAlignment.Left
			nl.BackgroundTransparency = 1
			nl.Parent = f
		end
		
		addEq(loadout.Lethal, "Lethal")
		addEq(loadout.Tactical, "Tactical")
		
		local uiList = Instance.new("UIListLayout")
		uiList.FillDirection = Enum.FillDirection.Horizontal
		uiList.Padding = UDim.new(0, 10)
		uiList.Parent = eqFrame
	end

	local function refreshSidebar()
		for _, child in ipairs(sidebar:GetChildren()) do
			if child:IsA("Frame") then child:Destroy() end
		end
		
		local currentLoadouts = LoadoutData.GetLoadouts()
		for _, loadout in ipairs(currentLoadouts) do
			local item = Instance.new("Frame")
			item.Size = UDim2.new(1, -10, 0, 50)
			item.BackgroundTransparency = 1
			item.Parent = sidebar
			
			local btn = Instance.new("TextButton")
			btn.Size = UDim2.new(1, -40, 1, 0)
			btn.BackgroundColor3 = (loadout.Id == selectedId) and Color3.fromRGB(40, 40, 45) or COLORS.Panel
			btn.BackgroundTransparency = (loadout.Id == selectedId) and 0.2 or 0.6
			btn.Text = loadout.Name:upper()
			btn.Font = Enum.Font.GothamBold
			btn.TextSize = 14
			btn.TextColor3 = (loadout.Id == selectedId) and COLORS.AccentBlue or COLORS.TextSecondary
			btn.TextXAlignment = Enum.TextXAlignment.Left
			btn.Parent = item
			Instance.new("UICorner", btn)
			Instance.new("UIPadding", btn).PaddingLeft = UDim.new(0, 15)
			
			btn.MouseButton1Click:Connect(function()
				selectedId = loadout.Id
				refreshSidebar()
				refreshEditor(loadout)
				LoadoutData.Save(loadout)
			end)
			
			-- Delete Button
			local del = Instance.new("TextButton")
			del.Size = UDim2.fromOffset(30, 30)
			del.Position = UDim2.new(1, -35, 0.5, -15)
			del.BackgroundColor3 = COLORS.Delete
			del.Text = "X"
			del.Font = Enum.Font.GothamBold
			del.TextColor3 = COLORS.TextMain
			del.Parent = item
			Instance.new("UICorner", del).CornerRadius = UDim.new(1, 0)
			
			del.MouseButton1Click:Connect(function()
				LoadoutData.Delete(loadout.Id)
				if selectedId == loadout.Id then
					local remaining = LoadoutData.GetLoadouts()
					if #remaining > 0 then
						selectedId = remaining[1].Id
						refreshEditor(remaining[1])
					end
				end
				refreshSidebar()
			end)
		end
	end

	-- Add Button
	local addBtn = Instance.new("TextButton")
	addBtn.Name = "AddButton"
	addBtn.Text = "+ CREATE NEW LOADOUT"
	addBtn.Font = Enum.Font.GothamBold
	addBtn.TextSize = 14
	addBtn.TextColor3 = Color3.new(0,0,0)
	addBtn.BackgroundColor3 = COLORS.AccentGold
	addBtn.Size = UDim2.new(0, 300, 0, 40)
	addBtn.Position = UDim2.new(0, 40, 1, -80)
	addBtn.Parent = container
	Instance.new("UICorner", addBtn)
	
	addBtn.MouseButton1Click:Connect(function()
		local newLoadout = LoadoutData.CreateNew()
		selectedId = newLoadout.Id
		refreshSidebar()
		refreshEditor(newLoadout)
		LoadoutData.Save(newLoadout)
	end)

	-- Init
	local initial = LoadoutData.GetLoadouts()
	if #initial > 0 then
		refreshEditor(initial[1])
		refreshSidebar()
	end
	
	return container
end

return WeaponsMenu