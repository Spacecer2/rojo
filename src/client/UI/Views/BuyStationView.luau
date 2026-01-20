--[[
	BuyStationView - Interface for purchasing killstreaks and items
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UI = require(script.Parent.Parent)
local EconomyData = require(ReplicatedStorage.Constants.EconomyData)
local Theme = require(ReplicatedStorage.Constants.Theme)
local Network = require(ReplicatedStorage.Framework.Network)

local BuyStationView = {}

local COLORS = Theme.Colors or {
	Background = Color3.fromRGB(15, 15, 15),
	Panel = Color3.fromRGB(30, 30, 35),
	AccentGold = Color3.fromRGB(255, 215, 0),
	TextMain = Color3.fromRGB(255, 255, 255),
	TextSecondary = Color3.fromRGB(180, 180, 180),
}

function BuyStationView.Create(parent)
	local frame = Instance.new("Frame")
	frame.Name = "BuyStationView"
	frame.Size = UDim2.fromScale(0.4, 0.6)
	frame.Position = UDim2.fromScale(0.5, 0.5)
	frame.AnchorPoint = Vector2.new(0.5, 0.5)
	frame.BackgroundColor3 = COLORS.Background
	frame.BorderSizePixel = 0
	frame.Parent = parent
	
	Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 8)
	
	local header = Instance.new("TextLabel")
	header.Text = "BUY STATION"
	header.Font = Enum.Font.GothamBlack
	header.TextSize = 24
	header.TextColor3 = COLORS.AccentGold
	header.Size = UDim2.new(1, 0, 0, 50)
	header.BackgroundTransparency = 1
	header.Parent = frame
	
	local itemList = Instance.new("ScrollingFrame")
	itemList.Size = UDim2.new(1, -40, 1, -100)
	itemList.Position = UDim2.fromOffset(20, 60)
	itemList.BackgroundTransparency = 1
	itemList.ScrollBarThickness = 2
	itemList.Parent = frame
	
	local layout = Instance.new("UIListLayout")
	layout.Padding = UDim.new(0, 10)
	layout.Parent = itemList
	
	for _, item in pairs(EconomyData.BuyStationItems) do
		local itemBtn = Instance.new("TextButton")
		itemBtn.Name = item.Name
		itemBtn.Size = UDim2.new(1, 0, 0, 60)
		itemBtn.BackgroundColor3 = COLORS.Panel
		itemBtn.BorderSizePixel = 0
		itemBtn.Text = ""
		itemBtn.Parent = itemList
		
		Instance.new("UICorner", itemBtn).CornerRadius = UDim.new(0, 4)
		
		local nameLabel = Instance.new("TextLabel")
		nameLabel.Text = item.Name:upper()
		nameLabel.Font = Enum.Font.GothamBold
		nameLabel.TextSize = 14
		nameLabel.TextColor3 = COLORS.TextMain
		nameLabel.Position = UDim2.fromOffset(10, 10)
		nameLabel.Size = UDim2.new(0.7, 0, 0, 20)
		nameLabel.TextXAlignment = Enum.TextXAlignment.Left
		nameLabel.BackgroundTransparency = 1
		nameLabel.Parent = itemBtn
		
		local descLabel = Instance.new("TextLabel")
		descLabel.Text = item.Description
		descLabel.Font = Enum.Font.Gotham
		descLabel.TextSize = 10
		descLabel.TextColor3 = COLORS.TextSecondary
		descLabel.Position = UDim2.fromOffset(10, 30)
		descLabel.Size = UDim2.new(0.7, 0, 0, 20)
		descLabel.TextXAlignment = Enum.TextXAlignment.Left
		descLabel.BackgroundTransparency = 1
		descLabel.Parent = itemBtn
		
		local priceLabel = Instance.new("TextLabel")
		priceLabel.Text = "$" .. item.Price
		priceLabel.Font = Enum.Font.GothamBlack
		priceLabel.TextSize = 16
		priceLabel.TextColor3 = COLORS.AccentGold
		priceLabel.Position = UDim2.new(0.7, 0, 0, 0)
		priceLabel.Size = UDim2.new(0.3, -10, 1, 0)
		priceLabel.TextXAlignment = Enum.TextXAlignment.Right
		priceLabel.BackgroundTransparency = 1
		priceLabel.Parent = itemBtn
		
		UI.ApplyFeedback(itemBtn)
		
		itemBtn.MouseButton1Click:Connect(function()
			Network.FireServer("BuyStationPurchase", item.Name)
		end)
	end
	
	local closeBtn = Instance.new("TextButton")
	closeBtn.Text = "CLOSE"
	closeBtn.Font = Enum.Font.GothamBold
	closeBtn.TextSize = 14
	closeBtn.TextColor3 = Color3.new(1, 0, 0)
	closeBtn.Size = UDim2.new(1, -40, 0, 30)
	closeBtn.Position = UDim2.new(0, 20, 1, -10)
	closeBtn.AnchorPoint = Vector2.new(0, 1)
	closeBtn.BackgroundTransparency = 1
	closeBtn.Parent = frame
	
	closeBtn.MouseButton1Click:Connect(function()
		frame:Destroy()
	end)
	
	return frame
end

return BuyStationView
