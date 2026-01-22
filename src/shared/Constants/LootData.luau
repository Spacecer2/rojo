--!strict
-- This module defines constants and data structures related to the looting system.
-- It is shared between client and server to ensure consistent data interpretation.

local LootData = {}

LootData.Rarities = {
    Common = {
        DisplayName = "Common",
        Color = Color3.fromRGB(160, 160, 160), -- Grey
        Priority = 1,
    },
    Uncommon = {
        DisplayName = "Uncommon",
        Color = Color3.fromRGB(80, 200, 80),  -- Green
        Priority = 2,
    },
    Rare = {
        DisplayName = "Rare",
        Color = Color3.fromRGB(0, 112, 221),  -- Blue
        Priority = 3,
    },
    Epic = {
        DisplayName = "Epic",
        Color = Color3.fromRGB(163, 53, 238), -- Purple
        Priority = 4,
    },
    Legendary = {
        DisplayName = "Legendary",
        Color = Color3.fromRGB(255, 128, 0),  -- Orange
        Priority = 5,
    },
    Mythic = {
        DisplayName = "Mythic",
        Color = Color3.fromRGB(255, 0, 255),  -- Pink/Magenta
        Priority = 6,
    },
}

LootData.ItemTypes = {
    Weapon = "Weapon",
    Ammo = "Ammo",
    Cash = "Cash",
    ArmorPlate = "ArmorPlate",
    Lethal = "Lethal",
    Tactical = "Tactical",
    FieldUpgrade = "FieldUpgrade",
    Attachment = "Attachment",
    Killstreak = "Killstreak",
}

-- Basic structure for a loot item's data (to be stored as Attributes on a Model)
LootData.DefaultLootItemAttributes = {
    ItemType = LootData.ItemTypes.Weapon, -- What type of item it is
    ItemName = "Default Weapon",          -- Display name
    Rarity = "Common",                    -- Rarity string (key from LootData.Rarities)
    WeaponId = "AR_Default",              -- Specific ID for weapons
    AttachmentIds = {},                   -- Table of string attachment IDs for weapons
    AmmoType = "556",                     -- Type of ammo for ammo/weapons
    AmmoAmount = 30,                      -- Amount of ammo
    Value = 100,                          -- Value for Cash, or other numeric properties
    IconId = "rbxassetid://0",            -- Asset ID for UI icon
    Description = "A standard issue weapon.", -- Brief description for UI
}

-- Keybind for picking up items (to be configured in SettingsMenu)
LootData.PickupKeybind = Enum.KeyCode.F -- Default keybind

-- Interaction distances
LootData.InteractionDistance = 8
LootData.UIVisibleDistance = 15 -- How far the UI should be visible

return LootData
