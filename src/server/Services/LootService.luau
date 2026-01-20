--[[
	LootService - Server-side loot management
	Handles spawning, interaction, and rewarding items.
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Network = require(ReplicatedStorage.Framework.Network)
local LootData = require(ReplicatedStorage.Constants.LootData)
local PlayerDataService = nil -- Will require in Init to avoid circular deps

local LootService = {
	ActiveLoot = {}, -- [LootId] = Data
	ActiveBoxes = {}, -- [BoxId] = Data
}

function LootService.SpawnLoot(position, itemId)
	local itemData = LootData.Items[itemId]
	if not itemData then warn("[LootService] Invalid loot item:", itemId) return end

	local lootId = game:GetService("HttpService"):GenerateGUID(false)
	
	-- Create Visuals
	local part = Instance.new("Part")
	part.Name = "Loot_" .. itemId
	part.Size = Vector3.new(1, 1, 1)
	part.Position = position + Vector3.new(0, 1, 0)
	part.Anchored = false
	part.CanCollide = true
	part.Parent = workspace
	part:SetAttribute("LootId", lootId)
	
	-- Visuals
	if itemData.Rarity then
		local rarityInfo = LootData.Rarities[itemData.Rarity]
		if rarityInfo then part.Color = rarityInfo.Color end
	else
		part.Color = Color3.fromRGB(200, 200, 200)
	end
	
	local bb = Instance.new("BillboardGui")
	bb.Size = UDim2.fromScale(4, 1)
	bb.StudsOffset = Vector3.new(0, 2, 0)
	bb.AlwaysOnTop = true
	bb.Parent = part
	
	local txt = Instance.new("TextLabel")
	txt.Text = itemData.Name
	txt.Size = UDim2.fromScale(1, 1)
	txt.BackgroundTransparency = 1
	txt.TextColor3 = Color3.new(1,1,1)
	txt.TextScaled = true
	txt.Parent = bb
	
	-- Interaction
	local prompt = Instance.new("ProximityPrompt")
	prompt.ActionText = "Pick Up"
	prompt.ObjectText = itemData.Name
	prompt.RequiresLineOfSight = false
	prompt.HoldDuration = 0.5
	prompt.Parent = part
	
	prompt.Triggered:Connect(function(player)
		LootService.ProcessInteraction(player, lootId)
	end)

	LootService.ActiveLoot[lootId] = {
		Part = part,
		Data = itemData
	}
end

function LootService.Init()
	PlayerDataService = require(script.Parent.PlayerDataService)
	
	-- Listen for interaction
	Network.OnServerEvent("LootInteraction", function(player, lootId)
		LootService.ProcessInteraction(player, lootId)
	end)

	Network.OnServerEvent("BoxInteraction", function(player, boxId)
		LootService.ProcessBoxOpening(player, boxId)
	end)
	
	-- Initial spawn (Example)
	task.spawn(function()
		task.wait(5)
		LootService.SpawnLoot(Vector3.new(0, 5, 10), "Cash_Small")
		LootService.SpawnLoot(Vector3.new(10, 5, 0), "M4_Loot")
		LootService.SpawnSupplyBox(Vector3.new(-10, 5, -10), "SupplyBox")
	end)
end

function LootService.SpawnSupplyBox(position, boxType)
	local config = LootData.Containers[boxType]
	if not config then return end
	
	local boxId = game:GetService("HttpService"):GenerateGUID(false)
	
	-- Server-side tracker
	LootService.ActiveBoxes[boxId] = {
		Position = position,
		Type = boxType,
		Opened = false
	}
	
	-- Tell clients to render the box
	Network.FireAllClients("BoxSpawned", {
		BoxId = boxId,
		Position = position,
		Type = boxType
	})
end

function LootService.ProcessBoxOpening(player, boxId)
	local box = LootService.ActiveBoxes[boxId]
	if not box or box.Opened then return end
	
	-- Distance Check
	local char = player.Character
	if not char or not char:FindFirstChild("HumanoidRootPart") then return end
	if (char.HumanoidRootPart.Position - box.Position).Magnitude > 12 then return end
	
	box.Opened = true
	local config = LootData.Containers[box.Type]
	
	-- Generate Loot
	local count = math.random(config.LootCount[1], config.LootCount[2])
	local table = config.LootTable
	
	for i = 1, count do
		-- Weighted Random Selection
		local totalWeight = 0
		for _, entry in pairs(table) do totalWeight += entry.Weight end
		local rnd = math.random() * totalWeight
		
		local selectedItem = nil
		local currentWeight = 0
		for _, entry in pairs(table) do
			currentWeight += entry.Weight
			if rnd <= currentWeight then
				selectedItem = entry.Item
				break
			end
		end
		
		if selectedItem then
			-- Spawn loot with slight offset
			local offset = Vector3.new(math.random(-2, 2), 2, math.random(-2, 2))
			LootService.SpawnLoot(box.Position + offset, selectedItem)
		end
	end
	
	Network.FireAllClients("BoxOpened", boxId)
end

function LootService.ProcessInteraction(player, lootId)
	local lootInfo = LootService.ActiveLoot[lootId]
	if not lootInfo then return end
	
	-- Verify distance
	local char = player.Character
	if not char or not char:FindFirstChild("HumanoidRootPart") then return end
	
	local dist = (char.HumanoidRootPart.Position - lootInfo.Part.Position).Magnitude
	if dist > 10 then return end -- Basic anti-cheat
	
	local itemData = lootInfo.Data
	
	-- Reward player
	if itemData.Type == "Currency" then
		PlayerDataService.UpdateProfile(player, function(profile)
			profile.Currency += itemData.Value
			return profile
		end)
		print(string.format("[LootService] %s picked up $%d", player.Name, itemData.Value))
	elseif itemData.Type == "Weapon" then
		-- Logic to give weapon (e.g., call WeaponService)
		local WeaponService = require(script.Parent.WeaponService)
		WeaponService.EquipWeapon(player, itemData.WeaponName)
	end
	
	-- Cleanup
	lootInfo.Part:Destroy()
	LootService.ActiveLoot[lootId] = nil
	Network.FireAllClients("LootCollected", lootId)
end

return LootService
