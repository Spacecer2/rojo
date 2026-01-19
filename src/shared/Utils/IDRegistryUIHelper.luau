--[[
	IDRegistryUIHelper - Dynamic UI generation from IDRegistry metadata
	Provides reusable components for generating UI elements from registry data
	Enables UI to stay in sync with IDRegistry changes automatically
]]

local IDRegistryUIHelper = {}

--[[
	Create a simple ID list frame with metadata display
	@param parent - Parent frame
	@param category - Category name (Playlists, Operators, Challenges)
	@param onSelect - Callback function when item is selected
	@param size - Optional custom size (default: UDim2.fromScale(1, 1))
	@return frame - Created frame
]]
function IDRegistryUIHelper.CreateIDListFrame(parent, category, onSelect, size)
	size = size or UDim2.fromScale(1, 1)
	
	local frame = Instance.new("Frame")
	frame.Name = category .. "List"
	frame.Size = size
	frame.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
	frame.BorderSizePixel = 0
	frame.Parent = parent
	
	-- List layout
	local listLayout = Instance.new("UIListLayout")
	listLayout.Padding = UDim.new(0, 5)
	listLayout.Parent = frame
	
	return frame
end

--[[
	Create an ID item button with metadata display
	@param parent - Parent container
	@param itemName - Name of the item
	@param metadata - Metadata table for the item
	@param onSelect - Callback function when clicked
	@return button - Created button frame
]]
function IDRegistryUIHelper.CreateIDItemButton(parent, itemName, metadata, onSelect)
	local itemFrame = Instance.new("Frame")
	itemFrame.Name = itemName
	itemFrame.Size = UDim2.new(1, -10, 0, 60)
	itemFrame.BackgroundColor3 = Color3.fromRGB(45, 45, 50)
	itemFrame.BorderSizePixel = 0
	itemFrame.Parent = parent
	
	-- Corner radius
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 4)
	corner.Parent = itemFrame
	
	-- Item name
	local nameLabel = Instance.new("TextLabel")
	nameLabel.Text = metadata.Name or itemName
	nameLabel.Font = Enum.Font.GothamBold
	nameLabel.TextSize = 14
	nameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	nameLabel.Size = UDim2.new(0.5, 0, 1, 0)
	nameLabel.Position = UDim2.fromOffset(10, 0)
	nameLabel.BackgroundTransparency = 1
	nameLabel.TextXAlignment = Enum.TextXAlignment.Left
	nameLabel.Parent = itemFrame
	
	-- Description
	local descLabel = Instance.new("TextLabel")
	descLabel.Text = metadata.Description or metadata.Bio or ""
	descLabel.Font = Enum.Font.Gotham
	descLabel.TextSize = 12
	descLabel.TextColor3 = Color3.fromRGB(180, 180, 180)
	descLabel.Size = UDim2.new(0.5, -20, 1, 0)
	descLabel.Position = UDim2.new(0.5, 10, 0, 0)
	descLabel.BackgroundTransparency = 1
	descLabel.TextXAlignment = Enum.TextXAlignment.Left
	descLabel.TextTruncate = Enum.TextTruncate.AtEnd
	descLabel.Parent = itemFrame
	
	-- Click detection
	local clickRegion = Instance.new("TextButton")
	clickRegion.Text = ""
	clickRegion.Size = UDim2.fromScale(1, 1)
	clickRegion.BackgroundTransparency = 1
	clickRegion.Parent = itemFrame
	
	clickRegion.MouseButton1Click:Connect(function()
		if onSelect then
			onSelect(itemName, metadata)
		end
	end)
	
	-- Hover effect
	clickRegion.MouseEnter:Connect(function()
		itemFrame.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
	end)
	
	clickRegion.MouseLeave:Connect(function()
		itemFrame.BackgroundColor3 = Color3.fromRGB(45, 45, 50)
	end)
	
	return itemFrame
end

--[[
	Create a grid of ID items (for operators, etc.)
	@param parent - Parent container
	@param category - Category name
	@param idRegistry - The IDRegistry module
	@param onSelect - Callback function when item is selected
	@param itemsPerRow - Number of items per row
	@return scrollFrame - Created scroll frame
]]
function IDRegistryUIHelper.CreateIDGridFrame(parent, category, idRegistry, onSelect, itemsPerRow)
	itemsPerRow = itemsPerRow or 4
	
	local scrollFrame = Instance.new("ScrollingFrame")
	scrollFrame.Name = category .. "Grid"
	scrollFrame.Size = UDim2.fromScale(1, 1)
	scrollFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
	scrollFrame.BorderSizePixel = 0
	scrollFrame.ScrollBarThickness = 8
	scrollFrame.CanvasSize = UDim2.fromScale(1, 0)
	scrollFrame.Parent = parent
	
	-- Grid layout
	local gridLayout = Instance.new("UIGridLayout")
	gridLayout.CellSize = UDim2.new(1 / itemsPerRow, -5, 0, 120)
	gridLayout.CellPadding = UDim2.fromOffset(5, 5)
	gridLayout.Parent = scrollFrame
	
	-- Get all IDs for the category
	local allIds = idRegistry.GetAll(category)
	local allMetadata = idRegistry.GetAllMetadata(category)
	
	-- Create items
	for _, id in ipairs(allIds) do
		local metadata = allMetadata[id] or {}
		local itemFrame = Instance.new("Frame")
		itemFrame.Name = id
		itemFrame.Size = UDim2.fromScale(1, 1)
		itemFrame.BackgroundColor3 = Color3.fromRGB(45, 45, 50)
		itemFrame.BorderSizePixel = 0
		itemFrame.Parent = scrollFrame
		
		-- Corner
		local corner = Instance.new("UICorner")
		corner.CornerRadius = UDim.new(0, 6)
		corner.Parent = itemFrame
		
		-- Icon/Portrait
		if metadata.Portrait or metadata.Icon then
			local portrait = Instance.new("ImageLabel")
			portrait.Image = metadata.Portrait or metadata.Icon
			portrait.Size = UDim2.new(1, 0, 0.7, 0)
			portrait.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
			portrait.BorderSizePixel = 0
			portrait.Parent = itemFrame
		end
		
		-- Name
		local nameLabel = Instance.new("TextLabel")
		nameLabel.Text = metadata.Name or id
		nameLabel.Font = Enum.Font.GothamBold
		nameLabel.TextSize = 12
		nameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
		nameLabel.Size = UDim2.new(1, 0, 0.3, 0)
		nameLabel.Position = UDim2.new(0, 0, 0.7, 0)
		nameLabel.BackgroundTransparency = 1
		nameLabel.TextTruncate = Enum.TextTruncate.AtEnd
		nameLabel.Parent = itemFrame
		
		-- Click detection
		local clickButton = Instance.new("TextButton")
		clickButton.Text = ""
		clickButton.Size = UDim2.fromScale(1, 1)
		clickButton.BackgroundTransparency = 1
		clickButton.Parent = itemFrame
		
		clickButton.MouseButton1Click:Connect(function()
			if onSelect then
				onSelect(id, metadata)
			end
		end)
		
		-- Hover effect
		clickButton.MouseEnter:Connect(function()
			itemFrame.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
		end)
		
		clickButton.MouseLeave:Connect(function()
			itemFrame.BackgroundColor3 = Color3.fromRGB(45, 45, 50)
		end)
	end
	
	return scrollFrame
end

--[[
	Create a metadata display panel for an item
	@param parent - Parent container
	@param metadata - Metadata table to display
	@param size - Optional custom size
	@return panel - Created panel frame
]]
function IDRegistryUIHelper.CreateMetadataPanel(parent, metadata, size)
	size = size or UDim2.fromScale(0.3, 1)
	
	local panel = Instance.new("Frame")
	panel.Name = "MetadataPanel"
	panel.Size = size
	panel.Position = UDim2.fromScale(0.7, 0)
	panel.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
	panel.BorderSizePixel = 0
	panel.Parent = parent
	
	-- List layout
	local listLayout = Instance.new("UIListLayout")
	listLayout.Padding = UDim.new(0, 10)
	listLayout.Parent = panel
	
	-- Add metadata fields
	for key, value in pairs(metadata) do
		if key ~= "Name" and key ~= "Portrait" and key ~= "Icon" then
			local fieldFrame = Instance.new("Frame")
			fieldFrame.Name = key
			fieldFrame.Size = UDim2.new(1, -20, 0, 40)
			fieldFrame.BackgroundTransparency = 1
			fieldFrame.Parent = panel
			
			local keyLabel = Instance.new("TextLabel")
			keyLabel.Text = key .. ":"
			keyLabel.Font = Enum.Font.GothamBold
			keyLabel.TextSize = 11
			keyLabel.TextColor3 = Color3.fromRGB(100, 200, 255)
			keyLabel.Size = UDim2.new(1, 0, 0.4, 0)
			keyLabel.BackgroundTransparency = 1
			keyLabel.TextXAlignment = Enum.TextXAlignment.Left
			keyLabel.Parent = fieldFrame
			
			local valueLabel = Instance.new("TextLabel")
			valueLabel.Text = tostring(value)
			valueLabel.Font = Enum.Font.Gotham
			valueLabel.TextSize = 12
			valueLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
			valueLabel.Size = UDim2.new(1, 0, 0.6, 0)
			valueLabel.Position = UDim2.fromOffset(0, 20)
			valueLabel.BackgroundTransparency = 1
			valueLabel.TextXAlignment = Enum.TextXAlignment.Left
			valueLabel.TextWrapped = true
			valueLabel.Parent = fieldFrame
		end
	end
	
	return panel
end

--[[
	Update a list with current registry data (for live updates)
	@param listFrame - The list frame to update
	@param category - Category name
	@param idRegistry - The IDRegistry module
	@param onSelect - Callback function
]]
function IDRegistryUIHelper.UpdateList(listFrame, category, idRegistry, onSelect)
	-- Clear existing items
	for _, child in ipairs(listFrame:GetChildren()) do
		if child:IsA("Frame") or child:IsA("TextButton") then
			child:Destroy()
		end
	end
	
	-- Get all IDs
	local allIds = idRegistry.GetAll(category)
	local allMetadata = idRegistry.GetAllMetadata(category)
	
	-- Recreate items
	for _, id in ipairs(allIds) do
		local metadata = allMetadata[id] or {}
		IDRegistryUIHelper.CreateIDItemButton(listFrame, id, metadata, onSelect)
	end
end

return IDRegistryUIHelper
