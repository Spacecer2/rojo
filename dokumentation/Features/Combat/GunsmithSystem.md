# Gunsmith System: Real-Time Stat Modification

## Overview
A deep weapon customization system where attachments (barrel, muzzle, optic, grip, stock) dynamically modify weapon statistics in real-time. Players can craft unique loadouts with visible stat tradeoffs.

## Architecture

### Core Components
1. **GunsmiththService.luau** (Server)
   - Validates attachment compatibility
   - Calculates modified stats
   - Persists loadout configurations

2. **AttachmentData.luau** (Shared)
   - Defines all available attachments
   - Specifies stat modifiers
   - Lists rarity and unlock conditions

3. **GunsmiththUI.luau** (Client)
   - Attachment selection grid
   - Real-time stat preview
   - Comparison with default weapon

4. **LoadoutManager.luau** (Server/Shared)
   - Applies stat modifications when weapon equipped
   - Validates attachment slots
   - Handles loadout persistence

## Attachment Categories

### Barrels
Modify: Range, Velocity, Recoil

```lua
Barrels = {
    STOCK = {
        Id = "M4_BARREL_STOCK",
        Name = "Stock Barrel",
        Rarity = "Common",
        Stats = {
            RangeModifier = 1.0,
            VelocityModifier = 1.0,
            RecoilModifier = 1.0,
            MobilityModifier = 1.0
        }
    },
    MONOLITHIC = {
        Id = "M4_BARREL_MONOLITHIC",
        Name = "Monolithic Suppressor",
        Rarity = "Rare",
        Stats = {
            RangeModifier = 1.2,
            VelocityModifier = 1.15,
            RecoilModifier = 0.85,
            MobilityModifier = 0.9
        },
        Effects = {Sound = "Suppressed"}
    }
}
```

### Muzzles
Modify: Recoil Control, Sound Profile, Velocity

- Muzzle Brakes (↑ Recoil, ↑ Velocity, Loud)
- Suppressors (↓ Recoil, ↓ Velocity, Silent)
- Flash Hiders (→ Recoil, → Velocity, ↓ Flash)

### Optics
Modify: Aim Speed, Visual Clarity, Handling

- Iron Sights (Fast, No zoom)
- Reflex Sight (Balanced)
- Thermal Scope (Slow, Heat detection)
- ACOG (Long range, Slow)

### Grips
Modify: Recoil, Accuracy, Hip-Fire

- Standard Grip (Baseline)
- Angled Grip (↓ Recoil, ↓ Hip-fire)
- Vertical Grip (↑ Stability, Slower ADS)
- Lightweight Grip (↑ Mobility, Baseline stats)

### Stocks
Modify: Stability, Handling, ADS Speed

- Collapsed Stock (↓ Stability, ↑ Mobility)
- Extended Stock (↑ Stability, ↓ Mobility)
- Tactical Stock (Balanced)

## Stat System

### Base Weapon Stats
```lua
local WeaponStats = {
    Damage = 28,
    Range = 40,
    FireRate = 750,
    Accuracy = 0.8,
    Handling = 0.7,
    Mobility = 0.65,
    RecoilControl = 0.6
}
```

### Modifier Application
```lua
function ApplyAttachmentModifiers(baseStats, attachments)
    local modifiedStats = {}
    
    for statName, baseValue in pairs(baseStats) do
        local totalModifier = 1.0
        
        -- Sum all attachment modifiers for this stat
        for _, attachment in ipairs(attachments) do
            if attachment.Stats[statName .. "Modifier"] then
                totalModifier *= attachment.Stats[statName .. "Modifier"]
            end
        end
        
        modifiedStats[statName] = baseValue * totalModifier
    end
    
    return modifiedStats
end
```

### Stat Display
Each stat shows:
- Base value (white)
- Modified value (green/red based on change)
- Percentage change (-15%, +20%, etc.)
- Visual bar graph (0-100)

## Compatibility System

### Slot Validation
- Each weapon has fixed attachment slots (5 max)
- Attachments must match weapon platform (AR, SMG, etc.)
- Some attachments are mutually exclusive

```lua
local M4_Slots = {
    Barrel = true,
    Muzzle = true,
    Optic = true,
    Grip = true,
    Stock = true
}

-- Incompatibility rules
local Incompatibilities = {
    {"Iron Sights", "Reflex Sight"}, -- Can't have two optics
    {"Monolithic Barrel", "Stock Barrel"} -- Mutually exclusive
}
```

## Loadout Persistence

### Save Structure
```lua
local Loadout = {
    Id = 1,
    Name = "Close Quarters",
    Weapon = "M4",
    Attachments = {
        Barrel = "M4_BARREL_MONOLITHIC",
        Muzzle = "MUZZLE_SUPPRESSOR",
        Optic = "IRON_SIGHTS",
        Grip = "ANGLED_GRIP",
        Stock = "COLLAPSED_STOCK"
    },
    Stats = {
        -- Calculated and stored for quick reference
        Damage = 33.6,
        Range = 48,
        Handling = 0.75
    }
}
```

## UI/UX Flow

### Gunsmith Menu
1. **Weapon Selection** - Grid of available weapons
2. **Attachment Carousel** - Scroll through each slot
3. **Stat Comparison** - Before/after preview
4. **Loadout Save** - Name and save configuration
5. **Apply** - Equip the loadout

### Real-Time Preview
- Stats update as attachments are selected
- Visual indicators for positive/negative changes
- Comparison with default weapon setup

## Server-Side Validation

### When Player Equips Weapon
1. Validate all attachments exist in AttachmentData
2. Check compatibility rules
3. Verify unlocked status (level/rarity requirements)
4. Calculate final stats
5. Apply to weapon instance
6. Replicate to all clients

```lua
function EquipLoadout(player, loadoutId)
    local loadout = LoadoutService.GetLoadout(player, loadoutId)
    
    -- Validate
    if not ValidateLoadout(loadout) then
        return false, "Invalid loadout configuration"
    end
    
    -- Calculate stats
    local stats = CalculateModifiedStats(
        WEAPON_CONFIGS[loadout.Weapon],
        loadout.Attachments
    )
    
    -- Apply to character
    ApplyWeaponStats(player.Character, loadout.Weapon, stats)
    
    return true
end
```

## Cosmetic Attachments

Some attachments have visual models that appear on the weapon:
- Different barrel lengths
- Optic mounted on rail
- Grip visible on handguard
- Stock type visible

## Progression System

### Attachment Unlock
- Attachments unlock at specific player levels
- Weapon-specific challenges (get 20 kills with barrel X)
- Rarity tiers (Common → Uncommon → Rare → Epic → Legendary)

### Recommended Loadouts
- System suggests optimized attachments for playstyle
- Aggressive (↑ Mobility, ↓ Range)
- Balanced (Mixed)
- Long-range (↑ Range, ↓ Mobility)

## Integration Points

### With Weapon Framework V3
- Ballistic type determined by attachments
- Muzzle type affects sound properties
- Barrel length modifies projectile speed

### With HUD
- Display equipped loadout name
- Show active attachment configuration
- Quick-swap between loadouts

### With Economy
- Attachments purchasable with in-game currency
- Limited-time bundle attachments

## Performance Considerations

1. **Stat Caching**: Store calculated stats instead of recalculating each frame
2. **Lazy Loading**: Load attachment models only when visible
3. **Batch Updates**: Send all stat changes in single network packet

## Testing Checklist

- [ ] Attachment modifiers apply correctly
- [ ] Incompatible attachments blocked
- [ ] Loadout persistence across sessions
- [ ] Stat UI updates in real-time
- [ ] Visual models attach correctly to weapons
- [ ] Network replication of loadout changes
- [ ] Unlock conditions validated server-side

## Future Enhancements

- Attachment blueprint system (craft new attachments)
- Weapon mastery tree unlocking exclusive attachments
- Cosmetic skins for attachments
- Smart loadout recommendations based on playstyle
- Attachment trading economy
