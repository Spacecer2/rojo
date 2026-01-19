local MarketplaceService = game:GetService("MarketplaceService")
local Players = game:GetService("Players")

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