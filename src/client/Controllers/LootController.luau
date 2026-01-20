--[[
	LootController - Client-side loot visualization and interaction
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local Network = require(ReplicatedStorage.Framework.Network)
local LootData = require(ReplicatedStorage.Constants.LootData)

local LootController = {
	VisualLoot = {}, -- [LootId] = { Model, Prompt }
	VisualBoxes = {}, -- [BoxId] = { Model, Prompt }
}

function LootController:Init()
	-- Listen for loot spawns
	Network.OnClientEvent("LootSpawned", function(data)
		self:RenderLoot(data)
	end)
	
	Network.OnClientEvent("LootCollected", function(lootId)
		self:RemoveLoot(lootId)
	end)

	Network.OnClientEvent("BoxSpawned", function(data)
		self:RenderBox(data)
	end)

	Network.OnClientEvent("BoxOpened", function(boxId)
		self:HandleBoxOpening(boxId)
	end)
end

function LootController:RenderBox(data)
	local config = LootData.Containers[data.Type]
	if not config then return end

	local boxId = data.BoxId

	local model = Instance.new("Part")
	model.Name = "SupplyBox_" .. data.Type
	model.Size = Vector3.new(4, 2, 2)
	model.Position = data.Position
	model.Anchored = true
	model.Color = data.Type == "SupplyBox" and Color3.fromRGB(0, 100, 255) or Color3.fromRGB(255, 100, 0)
	model.Material = Enum.Material.Metal
	model.Parent = workspace:FindFirstChild("Loot") or workspace

	local prompt = Instance.new("ProximityPrompt")
	prompt.ObjectText = data.Type == "SupplyBox" and "Supply Box" or "Loot Crate"
	prompt.ActionText = "Open"
	prompt.HoldDuration = config.HoldTime
	prompt.Parent = model

	prompt.Triggered:Connect(function()
		Network.FireServer("BoxInteraction", boxId)
	end)

	self.VisualBoxes[boxId] = {
		Model = model,
		Prompt = prompt
	}
end

function LootController:HandleBoxOpening(boxId)
	local info = self.VisualBoxes[boxId]
	if info then
		-- Animation: Move lid or just fade out for now
		if info.Prompt then info.Prompt:Destroy() end
		
		task.spawn(function()
			for i = 0, 1, 0.1 do
				info.Model.Transparency = i
				task.wait(0.05)
			end
			info.Model:Destroy()
			self.VisualBoxes[boxId] = nil
		end)
	end
end

function LootController:RenderLoot(data)
	local itemData = LootData.Items[data.ItemKey]
	if not itemData then return end
	
	local lootId = data.LootId
	
	-- Create visual representation
	local model = Instance.new("Part")
	model.Name = "VisualLoot_" .. data.ItemKey
	model.Size = Vector3.new(1, 1, 1)
	model.Position = data.Position
	model.Anchored = true
	model.CanCollide = false
	model.Material = Enum.Material.Neon
	
	-- Color based on rarity
	local rarity = itemData.Rarity or "Common"
	local rarityData = LootData.Rarities[rarity]
	model.Color = rarityData.Color
	model.Parent = workspace:FindFirstChild("Loot") or workspace
	
	-- Interaction Prompt
	local prompt = Instance.new("ProximityPrompt")
	prompt.ObjectText = itemData.Name
	prompt.ActionText = itemData.Type == "Currency" and ("Take $" .. itemData.Value) or "Pick Up"
	prompt.HoldDuration = 0
	prompt.MaxActivationDistance = 8
	prompt.Parent = model
	
	prompt.Triggered:Connect(function()
		Network.FireServer("LootInteraction", lootId)
	end)
	
	self.VisualLoot[lootId] = {
		Model = model,
		Prompt = prompt
	}
	
	-- Floating animation (optional)
	task.spawn(function()
		local startY = model.Position.Y
		while model.Parent do
			local t = tick()
			model.Position = Vector3.new(data.Position.X, startY + math.sin(t * 2) * 0.2, data.Position.Z)
			model.CFrame = model.CFrame * CFrame.Angles(0, 0.05, 0)
			task.wait()
		end
	end)
end

function LootController:RemoveLoot(lootId)
	local info = self.VisualLoot[lootId]
	if info then
		if info.Model then info.Model:Destroy() end
		self.VisualLoot[lootId] = nil
	end
end

return LootController
