# Battle Pass System: 100-Tier Sector Map Progression

## Overview
A seasonal progression system featuring 100 tiers of rewards organized as a "Sector Map" visual metaphor. Players earn tiers through gameplay, complete challenges, and unlock cosmetics, XP boosters, and in-game currency. Both free and premium tiers available.

## Battle Pass Structure

### Tier System
```
Tier 1-25    │ Early Access (Free & Premium tracks)
Tier 26-50   │ Mid Season (Premium advantage begins)
Tier 51-75   │ Push Phase (Grind intensive)
Tier 76-100  │ Endgame (Prestigious rewards, exclusive cosmetics)
```

### Free vs Premium
- **Free Track**: 50% of rewards, cosmetics, 200 COD Points
- **Premium Track**: All rewards, exclusive cosmetics, 1500 COD Points
- **Premium+ (Tier Skip)**: Start at Tier 10, immediate unlock
- **Cost**: $9.99 USD (or equivalent in-game currency at season start)

## Progression Mechanics

### Earning XP
```lua
local XPSources = {
    {Activity = "Kill", XP = 100},
    {Activity = "Headshot", XP = 150},
    {Activity = "Assist", XP = 50},
    {Activity = "Objective Captured", XP = 200},
    {Activity = "Contract Completed", XP = 300},
    {Activity = "Match Survived (per min)", XP = 10},
    {Activity = "Victory", XP = 1000},
    {Activity = "Weekly Challenge", XP = 500}
}
```

### Battle Pass XP vs Player XP
- **Battle Pass XP**: Separate pool, only progresses tiers (not weapon levels)
- **Player XP**: Separate pool, increases account level
- **Conversion**: Both earned simultaneously from actions

### Tier Thresholds
```
Tier 1:     0 XP
Tier 2:     1,000 XP
Tier 3:     2,500 XP
Tier 4:     4,000 XP
...
Tier 50:    100,000 XP (cumulative)
Tier 75:    187,500 XP (cumulative)
Tier 100:   500,000 XP total (grind heavy)
```

### Tier Skip Tokens
- Earn through gameplay (rare)
- Purchase with premium currency
- Skip single tier (not full pass)
- "Double XP Weekends" accelerate progression

## Seasonal Structure

### Season Calendar
```
Season 1: Modern Warfare (90 days)
├─ Week 1-4: Base content release
├─ Week 5-8: Mid-season update (new guns, challenges)
├─ Week 9-12: Endgame content push
└─ Final Week: Exclusive cosmetics, final challenges

Season 2: New Ops & Arsenal (90 days)
├─ Resets all progression (cosmetics remain)
├─ New cosmetic themes
└─ New weapon balancing
```

### Seasonal Themes
- **Theme**: War, Espionage, Sci-Fi, Horror, etc.
- **Cosmetics**: All skins/items themed
- **Weapons**: Seasonal cosmetic options
- **Music**: Themed Battle Pass menu soundtrack

## Reward Structure

### Cosmetic Rewards (Primary)
```
Tier 1     │ Operator Skin: "Shadow"
Tier 5     │ Weapon Blueprint: M4 "Crimson"
Tier 10    │ Finishing Move: "Clean Sweep"
Tier 15    │ Weapon Camo: Digital Camo
Tier 20    │ Operator Skin: "Ghost"
Tier 25    │ Weapon Blueprint: AK-47 "Behemoth"
Tier 30    │ Emblem/Calling Card
Tier 35    │ Execution Animation
Tier 40    │ Reactive Weapon Camo (changes on kills)
Tier 50    │ Ultra Rarity: Operator "Price" + Execution
...
Tier 100   │ ULTIMATE REWARD: Mythic Operator Skin
```

### Currency Rewards
```
Tier 2     │ +200 COD Points
Tier 7     │ +300 COD Points
Tier 15    │ +500 COD Points
Tier 30    │ +1000 COD Points
Tier 60    │ +1500 COD Points
Tier 100   │ +2400 COD Points (covers next pass)
```

### XP Boosters
```
Tier 12    │ 2-Hour 50% Battle Pass XP Boost
Tier 25    │ 2-Hour 100% Battle Pass XP Boost
Tier 45    │ 24-Hour 25% Player XP Boost
Tier 75    │ 7-Day 50% Battle Pass XP Boost
```

### Weapon Blueprints
- 8-10 blueprints per season
- 5-7 common (early tiers)
- 2-3 epic/legendary (mid-late tiers)
- Unique attachment combos
- Themed cosmetics per season

### Execution Animations
- Unique finishing move per tier (50+)
- Squad can watch (1.5 second animation)
- Audio cue for teammates
- Cosmetic only (no gameplay advantage)

## Visual Presentation: Sector Map

### Map UI
```
┌─────────────────────────────────┐
│   BATTLE PASS - SECTOR MAP      │
├─────────────────────────────────┤
│                                 │
│  [TIR 1]─[TIER 2]──[TIER 3]     │
│   Operator        +XP            │
│                                 │
│      ↓                          │
│  [TIER 4]──[TIER 5]──[TIER 6]   │
│    Weapon     Camo     +Cash    │
│   Blueprint                     │
│      ↓                          │
│  [TIER 7]──[TIER 8]──[TIER 9]   │
│    Emote      Skin     +COD$    │
│                                 │
│  Progress: 23 / 100             │
│  XP: 45,230 / 250,000           │
│  Tier Progress: ███████░░ 70%   │
│                                 │
│  [View Free Track] [View Premium]
└─────────────────────────────────┘
```

### Tile Details (On Hover)
```
TIER 23
├─ Name: Operator Skin "Reaper"
├─ Rarity: Epic (Purple)
├─ Unlock: 3,500 XP Remaining
├─ Preview: [3D Character Model]
└─ Description: "Dark warrior outfit"

FREE TIER: Yes
PREMIUM TRACK: Yes (duplicate not shown)
```

### Progression Line
- Connected line shows tier progression path
- Green = Completed tier
- Yellow = Current tier (showing progress bar)
- Gray = Locked tiers
- Branching paths show free vs premium rewards

## Challenges & Accelerated Progression

### Weekly Challenges
```
Week 1
├─ Get 15 kills with AR rifles → 500 BP XP
├─ Complete 5 contracts → 300 BP XP
├─ Win 3 matches → 750 BP XP
├─ Revive 10 teammates → 400 BP XP
└─ Open 20 supply boxes → 250 BP XP

Total Weekly: 2,200 BP XP
(Roughly 2 full tiers)
```

### Daily Challenges
```
Daily (Pick 3 of 5)
├─ Eliminate 5 players → 150 BP XP
├─ Land at 3 different POIs → 100 BP XP
├─ Deal 500 damage → 150 BP XP
├─ Complete 1 contract → 100 BP XP
└─ Use 5 killstreaks → 200 BP XP

Daily Max: 300 BP XP + best 3 choices
(Roughly 0.3 tier per day)
```

### Seasonal Challenges (Mega-Challenges)
```
Tier 1-25 Lock:
└─ Complete "Shadow's Journey" (multi-step quest)
   • Kill 100 players
   • Scan 10 recon contracts
   • Complete "The Gauntlet" bounty
   → Unlock TIER 25 Operator Skin early

Tier 76-100 Locks:
└─ "Become Unstoppable"
   • Get 200 elimination kills
   • Win 5 squad matches
   • Find all hidden collectibles
   → Unlock TIER 100 Mythic Skin showcase
```

## Cosmetic Themes by Tier

### Early Tiers (1-25): "Infiltration"
- Dark, tactical operator skins
- Military-grade weapon blueprints
- Camouflage and utility cosmetics

### Mid Tiers (26-75): "Arsenal Expansion"
- Character variety (new operators)
- Exotic weapon variations
- Stylish cosmetics (not tactical)

### Endgame Tiers (76-100): "Legend Status"
- Ultra-rare operators
- Mythic weapon blueprints (animated, reactive)
- Prestige cosmetics (visible in lobby)

## Premium Pass Benefits

### Exclusive Perks
- 2x Battle Pass XP on Weekends
- Exclusive cosmetics (not in free track)
- Early access to cosmetics (1 week early)
- Premium-only challenges (+250 XP each)
- Monthly bonus COD Points (+200 COD$)

### Exclusive Cosmetics (Premium Only)
- 5-10 operator skins unique to premium
- Mythic weapon blueprints
- Ultra-rare executions
- Calling cards (prestige designs)

### Premium Track Vs Free Track
```
Tier 50 Free Track:    Operator Skin "Steel"
Tier 50 Premium Track: Operator Skin "Phantom" + Execution

Tier 75 Free Track:    Weapon Blueprint "Standard"
Tier 75 Premium Track: Weapon Blueprint "Animated" + Camo
```

## Tier Skip Mechanics

### Tier Skip Token Earn Rate
- Earn 1 token every 50 tiers completed
- Tokens can stack (max 5)
- Don't expire with season reset
- Purchasable: 300 COD$ per token

### Using Skip Tokens
- Click "Skip Tier" button on locked tier
- 1 token = advance 1 tier instantly
- XP not refunded (use tokens wisely)

## Battle Pass Expiration

### Active Period
- Seasons last 90 days typically
- 7-day grace period (can still earn XP)
- Cosmetics remain in inventory after expiration

### Carry-Over
- Incomplete Battle Pass cosmetics → Lost (incentive to complete)
- Purchase premium track anytime during season
- Retroactively unlock cosmetics if purchased

### New Season Reset
- All progress resets to Tier 0
- Cosmetics earned stay in inventory
- Premium pass renewed if purchased for new season
- Exclusive cosmetics from past seasons retired

## Network & Persistence

### Server Storage
```lua
local BattlePassData = {
    PlayerId = player.UserId,
    Season = 1,
    CurrentTier = 23,
    XPProgress = 45230,
    BattlePassType = "Premium", -- or "Free"
    CompletedChallenges = {
        "Challenge_Kills_AR",
        "Challenge_Contracts"
    },
    ClaimedRewards = {23, 22, 21, 20, ...}
}
```

### Sync Frequency
- Tier completion: Immediate (real-time)
- XP updates: Every 5 minutes
- Challenge completion: On-demand
- Cosmetic unlock: Immediate

## Leaderboards

### Seasonal Leaderboards
- Rank players by Battle Pass tier
- Secondary sort by XP progress
- Top 100 display "Legendary" rank
- Weekly rankings

### Challenge Leaderboards
- Speed runs (who completes season fastest)
- Challenge completion rate
- Prestige rankings (completed multiple seasons)

## Monetization Strategy

### Pass Purchase Options
- **Standard**: $9.99 (100 tiers, full cosmetics)
- **Premium+ Tier 10**: $14.99 (starts at tier 10)
- **Cosmetics Only**: $4.99 (cosmetics, no XP rewards)

### Pricing Tiers by Region
- Adjusted for currency
- Price consistency: ~2-3% season cost

### Free Alternative
- All cosmetics available through gameplay (slow grind)
- Premium Track accelerates progression
- No gameplay advantage (cosmetic only)

## Testing Checklist

- [ ] Tier progression calculates correctly
- [ ] XP accumulation accurate across all activities
- [ ] Challenge completion validated
- [ ] Cosmetics unlock at correct tiers
- [ ] Free vs Premium tracks distinct
- [ ] Tier skip tokens function properly
- [ ] Seasonal reset clears progress only
- [ ] Leaderboards update in real-time
- [ ] Network sync of tier data
- [ ] Cosmetics persist after season end
- [ ] Premium pass perks apply correctly
- [ ] No exploit paths to skip tiers

## Performance Optimizations

1. **XP Batching**: Send accumulated XP every 30s
2. **Cosmetic Caching**: Load cosmetics on-demand
3. **UI Rendering**: Render only visible tiers (virtualization)

## Future Enhancements

- Cosmetics can be "fused" for unique variants
- Seasonal cosmetic re-releases with twists
- Crossover cosmetics (with other games/brands)
- Player prestige tokens (replay past season tracks)
- Community voting on cosmetic designs
- Limited-time battle pass variants (extended seasons)
