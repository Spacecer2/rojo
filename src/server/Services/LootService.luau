--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local ServerScriptService = game:GetService("ServerScriptService")

local LootData = require(ReplicatedStorage.Shared.Constants.LootData)
local DataService = require(ServerScriptService.Services.DataService)
local WeaponService = require(ServerScriptService.Services.WeaponService)

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
        
        -- Handle table values (like AttachmentIds) by serializing to comma-separated string
        if type(value) == "table" then
            value = table.concat(value, ",")
        end
        
        lootModel:SetAttribute(key, value)
    end
    
    -- Ensure Rarity is a valid string
    local rarityAttr = lootModel:GetAttribute("Rarity")
    if not LootData.Rarities[rarityAttr] then
        warn("[LootService] Invalid rarity provided for loot item, defaulting to Common: " .. tostring(rarityAttr))
        lootModel:SetAttribute("Rarity", "Common")
    end

    print("[LootService] Spawned loot item: " .. lootModel:GetAttribute("ItemName") .. " (" .. lootModel:GetAttribute("Rarity") .. ") at " .. tostring(position))
    return lootModel
end

-- Function to handle client pickup requests
local function onRequestPickup(player: Player, lootModelInstance: Model)
    -- Server-side validation
    if not lootModelInstance or not lootModelInstance:IsA("Model") or lootModelInstance.Parent ~= ServerLootFolder then
        warn("[LootService] " .. player.Name .. " attempted to pick up invalid or non-existent loot.")
        return
    end

    local playerCharacter = player.Character
    if not playerCharacter or not playerCharacter:FindFirstChild("HumanoidRootPart") then
        warn("[LootService] " .. player.Name .. " character not found for pickup.")
        return
    end

    local distance = (playerCharacter.HumanoidRootPart.Position - lootModelInstance.PrimaryPart.Position).Magnitude
    if distance > LootData.InteractionDistance + 2 then -- Allow some leeway for interaction
        warn("[LootService] " .. player.Name .. " too far from loot item for pickup (distance: " .. math.floor(distance) .. ").")
        return
    end

    -- Get item attributes
    local itemType = lootModelInstance:GetAttribute("ItemType")
    local itemName = lootModelInstance:GetAttribute("ItemName")
    local rarity = lootModelInstance:GetAttribute("Rarity")
    
    -- Process pickup based on item type
    local pickupSuccess = false
    
    if itemType == LootData.ItemTypes.Weapon then
        -- Give weapon to player
        local weaponId = lootModelInstance:GetAttribute("WeaponId")
        local attachmentIdsString = lootModelInstance:GetAttribute("AttachmentIds")
        local attachmentIds: {string} = {}
        
        -- Parse comma-separated attachment IDs string back into table
        if attachmentIdsString and type(attachmentIdsString) == "string" and #attachmentIdsString > 0 then
            for attachmentId in string.gmatch(attachmentIdsString, "([^,]+)") do
                table.insert(attachmentIds, attachmentId:match("^%s*(.-)%s*$")) -- Trim whitespace
            end
        end
        
        if weaponId then
            pickupSuccess = WeaponService.GiveWeapon(player, weaponId, attachmentIds)
            if pickupSuccess then
                print("[LootService] " .. player.Name .. " picked up weapon: " .. itemName .. " (" .. rarity .. ")")
            else
                warn("[LootService] Failed to give weapon " .. weaponId .. " to " .. player.Name)
            end
        else
            warn("[LootService] Weapon loot item missing WeaponId attribute")
        end
        
    elseif itemType == LootData.ItemTypes.Cash then
        -- Add cash to player
        local cashValue = lootModelInstance:GetAttribute("Value") or 0
        if cashValue > 0 then
            DataService.AddCurrency(player, cashValue)
            pickupSuccess = true
            print("[LootService] " .. player.Name .. " picked up cash: $" .. cashValue)
        else
            warn("[LootService] Cash loot item has invalid value: " .. tostring(cashValue))
        end
        
    elseif itemType == LootData.ItemTypes.Ammo then
        -- Add ammo to player's current weapon (simplified - could be expanded)
        local ammoType = lootModelInstance:GetAttribute("AmmoType")
        local ammoAmount = lootModelInstance:GetAttribute("AmmoAmount") or 0
        
        if ammoAmount > 0 then
            -- TODO: Integrate with weapon ammo system when available
            pickupSuccess = true
            print("[LootService] " .. player.Name .. " picked up ammo: " .. ammoAmount .. "x " .. (ammoType or "Unknown"))
        else
            warn("[LootService] Ammo loot item has invalid amount")
        end
        
    elseif itemType == LootData.ItemTypes.ArmorPlate then
        -- Add armor plate to player (simplified - could be expanded)
        local plateValue = lootModelInstance:GetAttribute("Value") or 1
        
        if plateValue > 0 then
            -- TODO: Integrate with armor system when available
            pickupSuccess = true
            print("[LootService] " .. player.Name .. " picked up armor plate(s): " .. plateValue)
        else
            warn("[LootService] Armor plate loot item has invalid value")
        end
        
    elseif itemType == LootData.ItemTypes.Lethal or itemType == LootData.ItemTypes.Tactical then
        -- Add utility item to player (simplified - could be expanded)
        local utilityName = lootModelInstance:GetAttribute("ItemName")
        
        -- TODO: Integrate with utility inventory system when available
        pickupSuccess = true
        print("[LootService] " .. player.Name .. " picked up utility: " .. utilityName)
        
    elseif itemType == LootData.ItemTypes.Attachment then
        -- Add attachment to player inventory (simplified - could be expanded)
        local attachmentId = lootModelInstance:GetAttribute("WeaponId") or lootModelInstance:GetAttribute("ItemName")
        
        -- TODO: Integrate with attachment inventory system when available
        pickupSuccess = true
        print("[LootService] " .. player.Name .. " picked up attachment: " .. attachmentId)
        
    else
        warn("[LootService] Unknown item type: " .. tostring(itemType))
    end

    -- Only destroy and notify if pickup was successful
    if pickupSuccess then
        ServerToClientEvents:WaitForChild("LootPickedUp"):FireClient(player, lootModelInstance)
        lootModelInstance:Destroy() -- Remove from world
    else
        warn("[LootService] Pickup failed for " .. player.Name .. " - item: " .. tostring(itemName))
    end
end

function LootService.Init()
    requestPickupRemote.OnServerEvent:Connect(onRequestPickup)
    print("[LootService] Initialized - Ready to handle loot pickups")

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
