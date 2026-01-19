# Looting System: Ground Loot, Supply Boxes, & Rarity Tiers

## Overview
A comprehensive loot distribution system where items are scattered across the map in various containers and as ground spawns. Loot quality increases through rarity tiers, with rare items in high-risk areas, incentivizing exploration and risk-taking.

## Loot Containers

### 1. Ground Loot Spawns
**Frequency**: Most common
- Weapons, ammo, cash scattered randomly
- Visual: Small item on ground with icon
- Respawn: 30 seconds after pickup
- Density: 200-300 spawn points per map

**Pickup Mechanics**:
```lua
if DistanceTo(lootItem) < 3 then
    if Input("Use") then
        AddToInventory(lootItem)
        lootItem.Visible = false
        lootItem.RespawnTimer = 30
    end
end
```

### 2. Supply Boxes (Blue)
**Frequency**: Common, respawning
- Medium-sized wooden crate with lock
- Requires interaction (1.5 second hold)
- Contains: Armor plates, ammo, perks, cash
- Quantity: 40-50 per map
- Respawn: 60 seconds (empty state first)

**Contents**:
- Armor plates (50-70% chance)
- Ammo bundles (20-30%)
- Perks (10-15%)
- Cash ($200-$500)

### 3. Loot Crates (Orange)
**Frequency**: Rare, static spawns
- Large military-style crates
- High-value items inside
- Located at tactical/military POIs
- Quantity: 15-20 per map
- Respawn: 5 minutes

**Contents**:
- Rare weapons (blueprint M4, sniper)
- Killstreak loadouts
- Legendary armor
- High cash ($500-$1000)

### 4. Supply Drops (Airborne)
**Frequency**: Periodic, mid-match
- Plane drops random crate during match
- Audio/visual warning (horn, marker)
- Lands in contested areas (strategic)
- Quantity: 5-10 drops per match
- Timing: Drops every 3-5 minutes

**Contents**:
- Exotic weapons (limited edition)
- Maximum armor stack
- Rare attachments
- Very high cash ($1000-$2000)
- Killstreak tokens

### 5. Corpse Loot
**Frequency**: Per elimination
- Eliminated player drops their inventory
- Weapons they held, ammo, cash
- Visible for 300 seconds (5 min)
- Auto-collected if teammate picks up

**Items Dropped**:
- Primary weapon + mag
- Secondary weapon + mag
- All cash they had ($0-$500)
- Armor remaining
- Perks/consumables they held

## Item Categories

### Weapons
**Rarity Tiers**:
- Common: Stock AR, SMG, Pistol
- Uncommon: Scoped rifle, shotgun
- Rare: Experimental AR variant
- Epic: Legendary blueprint
- Exotic: Event-only weapons

### Ammunition
**Types**:
- 5.56 NATO (AR/SMG)
- .308 Magnum (sniper/LMG)
- 9mm (pistol)
- Shotgun shells
- Grenades (lethal)
- Tactical equipment (stun, smoke)

**Quantities**:
- Ground spawn: 30-60 rounds
- Box: 120-180 rounds
- Drop: 240+ rounds

### Armor Plates
**Tiers**:
- Common: 25 durability
- Uncommon: 50 durability
- Rare: 75 durability
- Epic: 100 durability (max stack = 3)

### Perks (Killstreaks)
**Types**:
- UAV ($3000 from buy station)
- Precision Airstrike ($2000)
- VTOL Jet ($2500)
- Sentry Gun ($1500)
- Loadout Drop ($6000)

### Cash
**Denominations**:
- Ground: $50-$200
- Box: $200-$500
- Drop: $500-$1000

### Attachments
**Availability**:
- Rare drop loot only
- Advanced grips, barrels, optics
- Locked to player level (some)

## Rarity System

### Color Coding
```
Common      → White/Gray
Uncommon    → Green
Rare        → Blue
Epic        → Purple
Legendary   → Gold/Orange
Exotic      → Rainbow/Animated
```

### Drop Rate Distribution
```lua
local LootDistribution = {
    Common = 0.60,      -- 60%
    Uncommon = 0.25,    -- 25%
    Rare = 0.10,        -- 10%
    Epic = 0.04,        -- 4%
    Legendary = 0.01    -- 1%
}
```

### Exotic Items
- Appear only in final supply drops
- Limited edition weapons
- Cosmetic variations
- Temporary (reset each season)

## Location-Based Loot

### Military/Industrial POIs (High-Tier)
- Rare weapons
- Epic armor
- Attachments
- High cash concentration
- More dangerous (contested)

### Civilian POIs (Low-Tier)
- Common weapons
- Basic armor
- Standard cash
- Safer to loot (less contested)

### Landmark POIs (Medium-Tier)
- Mixed rarity
- Moderate cash
- Balanced risk/reward

## Inventory System

### Inventory Slots
- Primary Weapon: 1 slot (mandatory)
- Secondary Weapon: 1 slot
- Armor Plates: Stack (max 3)
- Equipment: 3 slots (grenades, tactical, etc.)
- Cash: Stack unlimited

### Weight Limits
- Players don't have weight, but UI shows capacity
- Visual feedback if "overencumbered"
- No movement speed penalty (arcade feel)

### Pickup UI
```
┌─────────────────────────────┐
│ [E] Pick up M4A1 Carbine    │
│ [Hold for alternatives]     │
│ • Secondary: Akimbo M19     │
│ • Swap with Primary         │
└─────────────────────────────┘
```

## Loot Distribution Algorithm

### Map Coverage
```lua
function DistributeLoot(mapBounds)
    local spawnPoints = {}
    
    -- Create grid overlay
    for x = mapBounds.Min.X, mapBounds.Max.X, GRID_SIZE do
        for z = mapBounds.Min.Z, mapBounds.Max.Z, GRID_SIZE do
            local loot = GenerateRandomLoot()
            table.insert(spawnPoints, {
                Position = Vector3.new(x, HEIGHT, z),
                Item = loot,
                RespawnTime = 30
            })
        end
    end
    
    return spawnPoints
end
```

### Proximity Clustering
- Nearby items are similar rarity
- Incentivizes thorough area exploration
- Prevents lone legendary items

### Dynamic Spawning
- Early match: All spawn locations active
- Mid-match: Popular areas restock
- Late match: Concentrated drops near circle

## Corpse Loot Management

### Dropdown System
```lua
function DropCorpseLoot(player)
    local corpse = player.Character:Clone()
    corpse.Parent = workspace
    
    local loot = {
        PrimaryWeapon = player.Inventory.Primary,
        SecondaryWeapon = player.Inventory.Secondary,
        Cash = player.Cash,
        Ammo = player.Ammo,
        Armor = player.Armor
    }
    
    CreateLootBag(corpse, loot)
end
```

### Loot Bag UI
- Shows items inside bag
- Can preview stats before pickup
- Highlighting for rarity
- "Take All" button

## Supply Drop Events

### Drop Sequence
1. **Warning** (60s before): Plane horn, announcer "Supply drop incoming"
2. **Flight Path**: Animated drop pod descends with parachute
3. **Landing**: Explosion effect, loot crate appears
4. **Looting**: Open like supply box, first-come-first-served

### Supply Drop Frequency
- First drop: T=5:00 (1 crate)
- Second drop: T=10:00 (1 crate)
- Third drop: T=15:00 (2 crates)
- Final circle: (1 crate per 2 minutes)

### Strategic Placement
- Drops in contested zones (creates firefights)
- Uses intelligent pathfinding to avoid edges
- Guaranteed never on top of buildings (lands safely)

## Rarity Progression Strategy

### Early Game (0-5 min)
- Common loot dominates
- Players gather basics
- Lower risk fights

### Mid Game (5-15 min)
- Uncommon/Rare loot available
- Armor plates, attachments appear
- Supply drops increase rarity

### Late Game (15+ min)
- Epic/Legendary rarity
- Final supply drops valuable
- Every item matters

## Network Considerations

### Loot Sync
- Server authoritative on loot spawning
- Client predicts pickup locally (server validates)
- Respawn handled server-side

### Efficient Replication
- Only replicate visible loot within 200 stud radius
- LOD system for distant loot
- Batch respawn notifications

## UI Elements

### Minimap Indicators
- Red = Supply drop incoming (pings location)
- Yellow = Corpse loot (timer shows expiration)
- White = Ground loot (if in proximity)

### HUD Display
- On-screen prompt: "[E] Pick up M4 ($200)"
- Item name, rarity color, value
- Alternative actions if inventory full

### Loot List Screen
- Post-pickup: Shows what was acquired
- Rarity highlight for notable items
- Audio cue for rare drops

## Balancing

### Drop Rate Tweaks (Exposed Parameters)
- Weapon spawn frequency
- Rarity weighting
- Cash per container
- Respawn times

### Seasonal Changes
- Special cosmetic loot (seasonal)
- Event-themed weapons
- Limited-time exotic drops

## Testing Checklist

- [ ] All loot containers spawn correctly
- [ ] Rarity distribution matches expected rates
- [ ] Pickup mechanics work smoothly
- [ ] Respawn timers accurate
- [ ] Corpse loot drops on elimination
- [ ] Supply drops spawn at valid locations
- [ ] Network sync of loot instances
- [ ] Duplicate items prevented
- [ ] Inventory updates reflect picks
- [ ] Minimap indicators show loot
- [ ] Rarity color coding consistent
- [ ] Edge cases (loot in water, air) handled

## Performance Optimizations

1. **Object Pooling**: Reuse loot object instances
2. **Spatial Queries**: Frustum culling for distant loot
3. **LOD System**: Low-detail models for far loot
4. **Batch Updates**: Send all loot changes per frame

## Future Enhancements

- Loot rarity "hotspots" (high-value zones)
- Craftable loot (combine items to create better ones)
- Loot trading between squadmates
- Cosmetic loot (skins, finishers)
- Quest-related loot drops
- Time-limited exclusive loot seasons
