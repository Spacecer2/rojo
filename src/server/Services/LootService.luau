--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")

local LootData = require(ReplicatedStorage.src.shared.Constants.LootData)
-- Assume we have a PlayerDataService and WeaponService available for inventory management
-- For now, we'll just print and destroy the item.

local LootService = {}
local ServerLootFolder = Instance.new("Folder")
ServerLootFolder.Name = "ServerLoot"
ServerLootFolder.Parent = Workspace

local ServerToClientEvents = ReplicatedStorage:WaitForChild("Events"):WaitForChild("ServerToClient")
local ClientToServerEvents = ReplicatedStorage:WaitForChild("Events"):WaitForChild("ClientToServer")

local requestPickupRemote = ClientToServerEvents:WaitForChild("RequestPickup")

function LootService.SpawnLootItem(itemData: { [string]: any }, position: Vector3): Model
    -- Create a simple representation for now
    local lootModel = Instance.new("Model")
    lootModel.Name = itemData.ItemName or "LootItem"
    lootModel.Parent = ServerLootFolder
    lootModel.Archivable = true -- Allow cloning if needed

    local primaryPart = Instance.new("Part")
    primaryPart.Size = Vector3.new(2, 2, 2)
    primaryPart.Position = position
    primaryPart.Anchored = false
    primaryPart.CanCollide = true
    primaryPart.Transparency = 0.5 -- Make it visible for testing
    primaryPart.BrickColor = BrickColor.new("Bright green")
    primaryPart.Name = "PrimaryPart"
    primaryPart.Parent = lootModel
    lootModel.PrimaryPart = primaryPart

    -- Set attributes based on LootData.DefaultLootItemAttributes and provided itemData
    for key, defaultValue in pairs(LootData.DefaultLootItemAttributes) do
        local value = itemData[key] ~= nil and itemData[key] or defaultValue
        lootModel:SetAttribute(key, value)
    end
    
    -- Ensure Rarity is a valid string
    local rarityAttr = lootModel:GetAttribute("Rarity")
    if not LootData.Rarities[rarityAttr] then
        warn("Invalid rarity provided for loot item, defaulting to Common:", rarityAttr)
        lootModel:SetAttribute("Rarity", "Common")
    end

    print("Spawned loot item:", lootModel:GetAttribute("ItemName"), "of rarity:", lootModel:GetAttribute("Rarity"), "at", position)
    return lootModel
end

-- Function to handle client pickup requests
local function onRequestPickup(player: Player, lootModelInstance: Model)
    -- Server-side validation
    if not lootModelInstance or not lootModelInstance:IsA("Model") or lootModelInstance.Parent ~= ServerLootFolder then
        warn(player.Name, "attempted to pick up invalid or non-existent loot.")
        return
    end

    local playerCharacter = player.Character
    if not playerCharacter or not playerCharacter:FindFirstChild("HumanoidRootPart") then
        warn(player.Name, "character not found for pickup.")
        return
    end

    local distance = (playerCharacter.HumanoidRootPart.Position - lootModelInstance.PrimaryPart.Position).Magnitude
    if distance > LootData.InteractionDistance + 2 then -- Allow some leeway for interaction
        warn(player.Name, "too far from loot item for pickup.")
        return
    end

    -- Process pickup (simplified for now)
    local itemName = lootModelInstance:GetAttribute("ItemName")
    print(player.Name, "picked up", itemName)
    -- TODO: Integrate with actual player inventory/equip logic (e.g., call WeaponService or PlayerDataService)
    -- Example:
    -- if lootModelInstance:GetAttribute("ItemType") == LootData.ItemTypes.Weapon then
    --     WeaponService.GiveWeapon(player, lootModelInstance:GetAttribute("WeaponId"), lootModelInstance:GetAttribute("AttachmentIds"))
    -- elseif lootModelInstance:GetAttribute("ItemType") == LootData.ItemTypes.Cash then
    --     PlayerDataService.AddCash(player, lootModelInstance:GetAttribute("Value"))
    -- end

    ServerToClientEvents:WaitForChild("LootPickedUp"):FireClient(player, lootModelInstance) -- Notify the client that it was picked up

    lootModelInstance:Destroy() -- Remove from world
end

function LootService.Init()
    requestPickupRemote.OnServerEvent:Connect(onRequestPickup)
    print("LootService Initialized.")

    -- For testing purposes, spawn some loot
    -- task.wait(5) -- Give game some time to load
    -- LootService.SpawnLootItem({
    --     ItemType = LootData.ItemTypes.Weapon,
    --     ItemName = "M4A1",
    --     Rarity = "Rare",
    --     WeaponId = "M4A1",
    --     AttachmentIds = {"Optic_RedDot", "Stock_M4"},
    --     Description = "A versatile assault rifle.",
    -- }, Vector3.new(0, 5, 0))

    -- LootService.SpawnLootItem({
    --     ItemType = LootData.ItemTypes.Cash,
    --     ItemName = "Cash Pile",
    --     Rarity = "Uncommon",
    --     Value = 500,
    --     Description = "A small pile of cash.",
    -- }, Vector3.new(5, 5, 0))

    -- LootService.SpawnLootItem({
    --     ItemType = LootData.ItemTypes.Ammo,
    --     ItemName = "5.56 Ammo Box",
    --     Rarity = "Common",
    --     AmmoType = "556",
    --     AmmoAmount = 60,
    --     Description = "An ammo box for 5.56mm weapons.",
    -- }, Vector3.new(-5, 5, 0))
end

return LootService
