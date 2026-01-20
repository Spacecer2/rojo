local MarketplaceService = game:GetService("MarketplaceService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Network = require(ReplicatedStorage.Framework.Network)
local EconomyData = require(ReplicatedStorage.Constants.EconomyData)

local MarketplaceServiceWrapper = {}

-- Store gamepass IDs here for easy access
MarketplaceServiceWrapper.Passes = {
	SPECIAL_PASS = 1670695943,
	VIP = 0,
	XP_BOOST = 0,
}

function MarketplaceServiceWrapper.Init()
	MarketplaceService.PromptGamePassPurchaseFinished:Connect(function(player, passId, purchased)
		if purchased then
			print(string.format("[MarketplaceService] %s purchased gamepass %d", player.Name, passId))
			MarketplaceServiceWrapper.OnGamePassPurchased(player, passId)
		end
	end)

	-- Listen for Buy Station requests
	Network.OnServerEvent("BuyStationPurchase", function(player, itemName)
		MarketplaceServiceWrapper.ProcessPurchase(player, itemName)
	end)
end

function MarketplaceServiceWrapper.ProcessPurchase(player, itemName)
	local itemData = nil
	for _, item in pairs(EconomyData.BuyStationItems) do
		if item.Name == itemName then
			itemData = item
			break
		end
	end

	if not itemData then return end

	local PlayerDataService = require(script.Parent.PlayerDataService)
	local profile = PlayerDataService.GetProfile(player)
	if not profile then return end

	if profile.Currency >= itemData.Price then
		-- Deduct currency
		PlayerDataService.UpdateProfile(player, function(p)
			p.Currency -= itemData.Price
			return p
		end)

		-- Perform action
		MarketplaceServiceWrapper.PerformAction(player, itemData.Action, itemData.Args)
		
		print(string.format("[MarketplaceService] %s bought %s for $%d", player.Name, itemName, itemData.Price))
	else
		-- Insufficient funds
		print(string.format("[MarketplaceService] %s failed to buy %s (Insufficient funds)", player.Name, itemName))
	end
end

function MarketplaceServiceWrapper.PerformAction(player, action, args)
	if action == "GiveItem" then
		-- Logic to give item (e.g. LootService or direct inventory)
		print("Giving item to player: ", args.Item)
	elseif action == "ActivateKillstreak" then
		print("Activating killstreak: ", args.Streak)
	elseif action == "GivePerk" then
		print("Giving perk: ", args.Perk)
	end
end

function MarketplaceServiceWrapper.UserOwnsPass(userId, passId)
	local success, result = pcall(function()
		return MarketplaceService:UserOwnsGamePassAsync(userId, passId)
	end)
	
	if success then
		return result
	else
		warn(string.format("[MarketplaceService] Failed to check ownership of pass %d for user %d: %s", passId, userId, result))
		return false
	end
end

function MarketplaceServiceWrapper.OnGamePassPurchased(player, passId)
	-- Handle specific pass rewards immediately if needed
	-- Usually, systems check ownership on join or when needed, 
	-- but some rewards might need instant feedback.
end

return MarketplaceServiceWrapper