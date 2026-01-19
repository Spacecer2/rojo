--[[
	OperatorRanking - Dynamic operator unlock tracking and ranking system
	Manages operator progression and displays real-time unlock statistics
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local Constants = ReplicatedStorage:WaitForChild("Constants")
local IDRegistry = require(Constants:WaitForChild("IDRegistry"))

local OperatorRanking = {}
OperatorRanking._cache = {}
OperatorRanking._listeners = {}

--[[
	Get the player's unlocked operators
	@param player - The player instance
	@return table - List of unlocked operator IDs
]]
function OperatorRanking.GetUnlockedOperators(player)
	if not player or not player:FindFirstChild("PlayerData") then
		return {}
	end
	
	local playerData = player:FindFirstChild("PlayerData")
	local unlockedValue = playerData:FindFirstChild("UnlockedOperators")
	
	if unlockedValue and unlockedValue:IsA("ValueBase") then
		local unlockedStr = unlockedValue.Value
		if type(unlockedStr) == "string" and unlockedStr ~= "" then
			local unlocked = {}
			for id in unlockedStr:gmatch("[^,]+") do
				table.insert(unlocked, id:match("^%s*(.-)%s*$")) -- trim
			end
			return unlocked
		end
	end
	
	return {}
end

--[[
	Count total unlocked operators for a player
	@param player - The player instance
	@return number - Count of unlocked operators
]]
function OperatorRanking.GetUnlockedCount(player)
	local unlocked = OperatorRanking.GetUnlockedOperators(player)
	return #unlocked
end

--[[
	Get total operators available
	@return number - Total operator count
]]
function OperatorRanking.GetTotalCount()
	return #IDRegistry.OperatorList
end

--[[
	Get unlock percentage for a player
	@param player - The player instance
	@return number - Percentage (0-100)
]]
function OperatorRanking.GetUnlockPercentage(player)
	local unlocked = OperatorRanking.GetUnlockedCount(player)
	local total = OperatorRanking.GetTotalCount()
	return total > 0 and (unlocked / total * 100) or 0
end

--[[
	Check if a specific operator is unlocked
	@param player - The player instance
	@param operatorId - The operator ID
	@return boolean - True if unlocked
]]
function OperatorRanking.IsOperatorUnlocked(player, operatorId)
	local unlocked = OperatorRanking.GetUnlockedOperators(player)
	for _, id in ipairs(unlocked) do
		if id == operatorId then
			return true
		end
	end
	return false
end

--[[
	Unlock an operator for a player
	@param player - The player instance
	@param operatorId - The operator ID
	@return boolean - True if successfully unlocked
]]
function OperatorRanking.UnlockOperator(player, operatorId)
	if not IDRegistry.IsValidOperator(operatorId) then
		warn("Invalid operator ID:", operatorId)
		return false
	end
	
	if OperatorRanking.IsOperatorUnlocked(player, operatorId) then
		return false -- Already unlocked
	end
	
	if not player:FindFirstChild("PlayerData") then
		return false
	end
	
	local playerData = player:FindFirstChild("PlayerData")
	local unlockedValue = playerData:FindFirstChild("UnlockedOperators")
	
	if not unlockedValue then
		unlockedValue = Instance.new("StringValue")
		unlockedValue.Name = "UnlockedOperators"
		unlockedValue.Parent = playerData
	end
	
	local currentUnlocked = unlockedValue.Value
	if currentUnlocked == "" then
		unlockedValue.Value = operatorId
	else
		unlockedValue.Value = currentUnlocked .. "," .. operatorId
	end
	
	-- Notify listeners
	OperatorRanking._notifyListeners(player)
	return true
end

--[[
	Get ranking tier based on unlock percentage
	@param percentage - Unlock percentage (0-100)
	@return table - { Tier = string, Name = string, Color = Color3 }
]]
function OperatorRanking.GetRankingTier(percentage)
	if percentage >= 100 then
		return { Tier = "LEGEND", Name = "All Operators Unlocked", Color = Color3.fromRGB(255, 215, 0) }
	elseif percentage >= 80 then
		return { Tier = "ELITE", Name = "Veteran", Color = Color3.fromRGB(200, 100, 255) }
	elseif percentage >= 60 then
		return { Tier = "EXPERT", Name = "Advanced", Color = Color3.fromRGB(100, 200, 255) }
	elseif percentage >= 40 then
		return { Tier = "VETERAN", Name = "Intermediate", Color = Color3.fromRGB(100, 255, 100) }
	elseif percentage >= 20 then
		return { Tier = "RECRUIT", Name = "Beginner", Color = Color3.fromRGB(255, 200, 100) }
	else
		return { Tier = "NOVICE", Name = "New Player", Color = Color3.fromRGB(150, 150, 150) }
	end
end

--[[
	Format ranking info for display
	@param player - The player instance
	@return table - { UnlockedCount, TotalCount, Percentage, Tier, TierName, Color }
]]
function OperatorRanking.GetRankingInfo(player)
	local unlockedCount = OperatorRanking.GetUnlockedCount(player)
	local totalCount = OperatorRanking.GetTotalCount()
	local percentage = OperatorRanking.GetUnlockPercentage(player)
	local tier = OperatorRanking.GetRankingTier(percentage)
	
	return {
		UnlockedCount = unlockedCount,
		TotalCount = totalCount,
		Percentage = percentage,
		Tier = tier.Tier,
		TierName = tier.Name,
		Color = tier.Color,
		FormattedText = string.format("%d/%d OPERATORS UNLOCKED", unlockedCount, totalCount),
		ProgressRatio = unlockedCount / totalCount
	}
end

--[[
	Listen for ranking changes
	@param callback - Function called when ranking changes: callback(player, rankingInfo)
	@return function - Disconnect function
]]
function OperatorRanking.OnRankingChanged(callback)
	table.insert(OperatorRanking._listeners, callback)
	
	return function()
		for i, listener in ipairs(OperatorRanking._listeners) do
			if listener == callback then
				table.remove(OperatorRanking._listeners, i)
				break
			end
		end
	end
end

--[[
	Internal: Notify all listeners of ranking change
	@param player - The player instance
]]
function OperatorRanking._notifyListeners(player)
	local rankingInfo = OperatorRanking.GetRankingInfo(player)
	for _, listener in ipairs(OperatorRanking._listeners) do
		task.spawn(function()
			listener(player, rankingInfo)
		end)
	end
end

--[[
	Update a UI label with dynamic ranking info
	@param label - TextLabel to update
	@param player - The player instance
	@return function - Disconnect function for cleanup
]]
function OperatorRanking.BindToLabel(label, player)
	local function updateLabel()
		local info = OperatorRanking.GetRankingInfo(player)
		label.Text = info.FormattedText
	end
	
	updateLabel()
	
	local disconnect = OperatorRanking.OnRankingChanged(function(changedPlayer)
		if changedPlayer == player then
			updateLabel()
		end
	end)
	
	return disconnect
end

--[[
	Update a progress bar with dynamic ranking info
	@param progressBar - Frame with a Fill child to update
	@param player - The player instance
	@return function - Disconnect function for cleanup
]]
function OperatorRanking.BindToProgressBar(progressBar, player)
	local fillFrame = progressBar:FindFirstChild("Fill") or progressBar
	
	local function updateProgress()
		local info = OperatorRanking.GetRankingInfo(player)
		fillFrame.Size = UDim2.fromScale(info.ProgressRatio, 1)
		fillFrame.BackgroundColor3 = info.Color
	end
	
	updateProgress()
	
	local disconnect = OperatorRanking.OnRankingChanged(function(changedPlayer)
		if changedPlayer == player then
			updateProgress()
		end
	end)
	
	return disconnect
end

return OperatorRanking
