# Reward Systems: Supply Drops, Loot Lottery & Pity Mechanics

## Overview
A player retention system providing cosmetic and functional rewards through probabilistic "supply drops" (loot boxes) with guaranteed pity mechanics. Players earn supply drops through gameplay, with purchasable options for speed. All rewards cosmetic/convenience (no pay-to-win).

## Supply Drop System

### Earning Supply Drops
Players earn 1 supply drop every:
- 2 hours of gameplay (play timer)
- 10 wins accumulated
- 50 challenges completed in season
- Battle Pass tiers reached (every 5 tiers = 1 drop)
- Special events (limited-time)

### Supply Drop Tiers
```
Tier 1: Standard (60%)
├─ Operator cosmetics (common skins)
├─ Weapon blueprints (standard)
└─ Calling cards (basic designs)

Tier 2: Rare (30%)
├─ Operator cosmetics (unique skins)
├─ Weapon blueprints (decorated)
├─ Finishing moves
└─ Cosmetic weapon camos

Tier 3: Epic (8%)
├─ Legendary operator skins
├─ Exotic weapon blueprints
├─ Execution animations
└─ Prestige cosmetics

Tier 4: Mythic (2%)
├─ Ultra-rare limited cosmetics
├─ Animated weapon blueprints
├─ Special operator bundles
└─ Exclusive rank badges
```

### Rarity Colors
- Standard: White
- Rare: Blue
- Epic: Purple
- Mythic: Gold/Rainbow glow

## Loot Box Mechanics

### Opening Sequence
```
1. User clicks "Open Supply Drop"
2. Animation: Box lid slowly opens
3. Confetti explosion effect
4. Item reveal (zooms into center)
5. Rarity glow appears (color-coded)
6. Text shows: "You've unlocked: [Item Name]"
7. 3-second hold to proceed to next
```

### Item Types

#### Operator Skins
- Full character cosmetics
- Themed by season
- 50+ unique options
- Rarity varies (common to mythic)

#### Weapon Blueprints
- Pre-configured weapon setups
- Unique visual skins
- Different attachments per tier
- Animated camos (rare+)

#### Finishers / Executions
- 1.5 second elimination animations
- Unique per operator sometimes
- All finishers functional (cosmetic)
- Rare finishers only in high tiers

#### Cosmetic Camos
- Weapon coatings
- 10+ patterns per rarity
- Animated versions (epic+)
- Seasonal exclusives

#### Calling Cards
- Account-wide profile displays
- 20x20 icon + background
- Ranked tiers have special cards
- Event exclusives

#### Emotes & Sprays
- Standing emotes (taunts, celebrations)
- Wall sprays (painted on objects)
- 5-15 seconds duration
- Cosmetic for self-expression

#### Audio Packs
- Voice line alternatives
- Operator-specific callouts
- Victory theme variations
- Weapon fire sound options (if available)

## Pity Mechanics (Guaranteed Rewards)

### Spark System
```lua
local PitySystem = {
    Standard = {
        TierName = "Standard",
        RequiredOpens = 10,  -- Guaranteed rare every 10 opens
        Progression = 0
    },
    Rare = {
        TierName = "Rare",
        RequiredOpens = 25,  -- Guaranteed epic every 25 opens
        Progression = 0
    },
    Epic = {
        TierName = "Epic",
        RequiredOpens = 50,  -- Guaranteed mythic every 50 opens
        Progression = 0
    }
}
```

### How It Works
- Track "opens since last [tier] reward"
- Every 10 standard drops → Guaranteed 1 rare
- Every 25 rare drops → Guaranteed 1 epic
- Every 50 epic drops → Guaranteed 1 mythic
- Counters reset when threshold met

### Soft Pity
- At 80% of threshold → Increased drop chance
  - Opens 1-8: Normal rates
  - Opens 9: 50% rare chance
  - Opens 10: 100% rare guaranteed

### Display in UI
```
Pity Counter: 8/10 (you'll get rare next!)
└─ Progress bar showing distance to pity
   ████████░░ 80% progress
```

## Acquisition & Purchasing

### Free Supply Drops
- Earned through gameplay (every 2 hours)
- No purchase needed
- Limited quantity per month (~60 free)

### Purchased Supply Drops
```
1 Drop:      $2.99
5 Drops:     $12.99 (save $2)
10 Drops:    $22.99 (save $5)
20 Drops:    $39.99 (save $20)
50 Drops:    $79.99 (save $70)

Monthly Pass:
├─ 15 drops/month
├─ All duplicates → Convert to currency
└─ $9.99/month (recurring)
```

### Cosmetic Bundles
- 3-5 themed cosmetics (operator skin + weapons + finisher)
- $14.99-$24.99 per bundle
- Guaranteed (no RNG)
- Seasonal releases

### Battle Pass
- $9.99/season
- 100 tiers of rewards
- Mixed: Supply drops + Battle Pass cosmetics
- No RNG (all guaranteed)

## Duplicate Handling

### Duplicate Cosmetics
When opening a cosmetic already owned:
- Display: "Duplicate! +100 Currency"
- Converted to in-game currency (cosmetic bucks)
- 1 common duplicate = 50 bucks
- 1 rare duplicate = 150 bucks
- 1 epic duplicate = 500 bucks
- 1 mythic duplicate = 2000 bucks

### Currency Usage
- Cosmetic Bucks → Purchase specific cosmetics
- Skip loot box (buy items directly)
- Budget: Usually 2-4 cosmetics per month of drops

## Event-Based Rewards

### Holiday Events (Limited-Time)
- Special supply drop variants
- Themed cosmetics (holiday skins)
- Increased drop rates (+50%)
- Time-limited (~2 weeks)

### Seasonal Cosmetics
- New cosmetics each season
- Only available in supply drops
- Previous season cosmetics added to pool

### Tournament/Competitive
- Pro cosmetics (team skins)
- Chat badges for supporters
- Cosmetic weapon blueprints (team colors)

## Progression Tracking

### Reward History
```
Last 10 Supply Drop Opens:
├─ Common: "Operator Skin - Assault"
├─ Common: "Weapon Blueprint - M4 Blue"
├─ Rare: "Execution - Takedown"
├─ Common: "+100 Currency"
├─ Common: "Calling Card - Prestige"
├─ Rare: "Operator Skin - Night Guard"
├─ Common: "Camo - Digital"
├─ Common: "+50 Currency"
├─ Common: "Emote - Victory"
└─ Epic: "Operator Skin - Legendary"
```

### Statistics
- Total drops opened
- Average rarity
- Duplicate count
- Currency accumulated
- Cosmetics collected (percentage of total)

## Monetization Balance

### F2P vs P2P
- F2P players: 60 free drops/month (~$180 value)
- Can get mythic cosmetics (slow)
- P2P players: Accelerated progression
- No gameplay advantages

### Cosmetic Economy
- 3-4 new cosmetics weekly
- Rotation prevents "fear of missing out" (FOMO)
- Cosmetics return every season
- Exclusive cosmetics (limited release)

### Revenue Model
- 30% of monthly revenue from supply drops
- 40% from Battle Pass
- 20% from cosmetic bundles
- 10% from events

## Quality Assurance

### Cosmetic Requirements
- All cosmetics tested for:
  - Visual clarity (easy to see in-game)
  - Performance (no excessive particles)
  - Hitbox accuracy (can't obstruct hitbox)
  - Audio quality (sounds crisp)

### Rarity Balance
- Common tier: 60% chance (1 guaranteed per drop minimum)
- Rare tier: 30% chance
- Epic tier: 8% chance
- Mythic tier: 2% chance (pity every 50 opens)

## Anti-Cheat & Security

### Account Protection
- Supply drop items tied to account
- No trading (prevents account selling)
- Account recovery includes cosmetics
- 2FA recommended for high-value accounts

### Fraud Prevention
- Failed purchase attempts blocked
- Chargeback protection
- Regional pricing adjustments
- VPN detection (prevents arbitrage)

## Testing Checklist

- [ ] Drop rates match intended percentages
- [ ] Pity system counts correctly
- [ ] Soft pity increases drop rate
- [ ] Duplicates convert to currency
- [ ] Cosmetics unlock in-game
- [ ] Purchase system processes correctly
- [ ] Limited-time cosmetics expire
- [ ] Bundle purchases grant all items
- [ ] Leaderboard cosmetics display
- [ ] Cosmetic preview renders correctly
- [ ] No exploits (resetting drops, duplication)
- [ ] Cloud sync of cosmetics

## Performance Considerations

1. **Cosmetic Loading**: Load on-demand (not at start)
2. **Animation Caching**: Preload animation templates
3. **Texture Streaming**: LOD system for cosmetics
4. **Network**: Batch cosmetic unlocks

## Seasonal Rotation Strategy

### Season 1: Foundation
- 50 cosmetics released
- 10 per rarity tier

### Season 2: Expansion
- 20 new cosmetics
- 30 returning from Season 1
- 5 exclusive "pass-only" cosmetics

### Season 3+: Sustainable
- 10-15 new per season
- Rotating pool (prevent stale)
- Exclusive cosmetics encourage purchases

## Future Enhancements

- Cosmetic crafting (combine duplicates)
- Transmog system (combine cosmetics)
- Cosmetic marketplace (player trading)
- Subscription cosmetics (monthly-only)
- Live-service cosmetics (battle pass only)
- Cosmetic trading up (lower rarity → higher)
- Birthday cosmetics (free cosmetics on player birthday)
- Charity cosmetics (proceeds to charity)
