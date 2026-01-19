# Contracts System: Bounty, Recon & Scavenger Missions

## Overview
In-match contracts provide secondary objectives that reward cash, XP, and strategic advantages. Three contract types offer varying risk-reward profiles and playstyles: Bounty (aggressive hunting), Recon (tactical intelligence), and Scavenger (exploration).

## Contract Mechanics

### General System
- **Activation**: Pick up contract card at random locations or from eliminated enemies
- **Duration**: 2-5 minutes (visible timer)
- **Difficulty**: Scales with current circle (harder = more reward)
- **Visibility**: Enemy teams can see you've accepted contract (threat indicator)
- **Rewards**: Cash ($150-$500) + XP + Bonus perks

### Contract UI
```
┌─────────────────────────────┐
│    CONTRACT ACCEPTED        │
├─────────────────────────────┤
│ BOUNTY - Hunt Target        │
│ Target: Enemy Squad         │
│ Location: Shown on Map      │
│ Time Remaining: 3:45        │
│ Reward: $300                │
│ Progress: 0/1 Elimination   │
└─────────────────────────────┘
```

## Contract Types

### 1. Bounty Contract
**Objective**: Eliminate a specific enemy player or squad

#### How It Works
1. Accept bounty → Target squad revealed on minimap
2. Hunt them down before timer expires
3. Complete if target is eliminated
4. Bonus cash if completed quickly (under 2 min)

#### Rewards
- Base: $300
- Quick completion: +$100 (under 1:30)
- Squad wipe: +$50 per member (up to $400 total)
- Headshot kill: +$50

#### Target Mechanics
```lua
function AcceptBountyContract()
    local targetSquad = FindRandomActiveSquad()
    
    -- Reveal position every 30 seconds
    local updateFrequency = 30
    
    -- Position accuracy degrades over distance
    -- Close (< 100 studs): Exact position
    -- Medium (100-300): Approximate location
    -- Far (> 300): General area only
    
    return {
        Type = "Bounty",
        TargetSquad = targetSquad,
        Reward = 300,
        TimeLimit = 180 -- 3 minutes
    }
end
```

#### Gameplay Impact
- Creates immediate conflict
- Targets warned they're hunted (sound cue)
- Other squads can see bounty marker (opportunity to ambush)
- Risk: Bounty hunters may be ambushed themselves

#### Completion Conditions
- Target squad completely eliminated, OR
- Bounty timer expires (failed)
- Bounty can be transferred if hunter is eliminated

### 2. Recon Contract
**Objective**: Capture and hold objective locations for total time

#### How It Works
1. Accept recon → 3 locations marked on map (buildings or landmarks)
2. Visit each location and "secure" it (2 second interaction)
3. Hold position for 10 seconds while scanning
4. Location revealed to team on minimap
5. Complete if all 3 scanned

#### Rewards
- Base: $200 per location ($600 total)
- Speed bonus: +$100 if completed under 2:00
- Extra points: +$50 per teammate nearby during scan

#### Mechanics
```lua
function ScanReconLocation(location)
    -- Start scan animation
    ShowScanEffect(location)
    
    -- 10 second duration (can be interrupted by damage)
    local scanTime = 0
    while scanTime < 10 and not player.IsDamaged do
        scanTime += deltaTime
        ShowProgressBar(scanTime / 10)
    end
    
    -- If interrupted, must restart from beginning
    if player.IsDamaged then
        ResetScan()
        return
    end
    
    -- Successful scan
    MarkLocationOnTeamMap(location)
    return true
end
```

#### Strategic Value
- Information gathering (map control)
- Teamwork incentive (squadmates nearby = bonus)
- Safe contract (less combat-focused)
- Rewards: UAV equivalent effect for team

#### Gameplay Impact
- Team gets intel advantage
- Enemy teams can contest locations
- Encourages map exploration
- Promotes squad cohesion

### 3. Scavenger Contract
**Objective**: Collect and loot specific items scattered around map

#### How It Works
1. Accept scavenger → 3 items to collect shown on map
2. Loot items appear as glowing markers
3. Collect all 3 items within time limit
4. Return to extraction point to complete

#### Possible Items
- Armor plates (Uncommon/Rare rarity)
- Exotic weapons (one-time use)
- High-value cash bundles ($500+)
- Killstreak tokens
- Attachment blueprints

#### Rewards
- Base: $250 per item collected ($750 total)
- Items kept regardless of contract completion
- Bonus: +$200 if extraction completed
- XP: +500 XP per item

#### Mechanics
```lua
function StartScavengerContract()
    local items = GenerateRandomScavengerLoot(3)
    local extractionPoint = PickRandomExtraction()
    
    return {
        Type = "Scavenger",
        Items = items,      -- List of 3 items to collect
        ExtractionPoint = extractionPoint,
        TimeLimit = 300,    -- 5 minutes
        ItemsCollected = 0,
        Reward = 750
    }
end
```

#### Completion Conditions
- Collect all 3 items AND reach extraction point, OR
- Time expires (partial credit for items collected)

#### Strategic Depth
- Balances direct combat vs. resource gathering
- Item spawns in contested areas (risk/reward)
- Extraction point can be camped by other teams
- Items are valuable regardless of contract success

#### Gameplay Impact
- Incentivizes exploration
- Valuable loot drop (worth the risk)
- Encourages team spread (different items at different locations)
- Extraction mechanic creates vulnerability window

## Contract Distribution

### Map Spawning
- **Contract Cards**: 15-20 spawn locations per map
  - Usually near POIs
  - Respawn after pickup (60 second delay)
  - Can be found on ground as loot

- **Difficulty Multiplier**:
  - Early game (0-5 min): 1.0x reward
  - Mid game (5-12 min): 1.3x reward (harder competition)
  - Late game (12+ min): 2.0x reward (final contracts valuable)

### Contract Variety
- Rotating contract types (prevents repetition)
- Seasonal contract additions
- Event-specific contracts (holiday themes)

## Contract Interaction

### Accepting Contracts
```lua
-- Player finds contract card
if DistanceTo(contractCard) < 3 then
    ShowPrompt("[E] Accept " .. contractType .. " Contract")
    
    if Input("Use") then
        ActivateContract(player, contractCard)
        contractCard:Remove()
    end
end
```

### Canceling Contracts
- Can abandon contract anytime (no penalty)
- Contract reward forfeited
- Cooldown: 30 seconds before picking another

### Transferring Contracts
- If player eliminated, contract passes to squad
- Contract timer continues
- Reward pool unchanged

## Team Coordination

### Squad Communication
- Contract objective shared with squad
- Markers visible to all teammates
- Waypoint system for navigation
- Progress notifications ("2/3 locations scanned")

### Competitive Advantage
- Completed contracts boost team cash pool
- XP shared among squad
- Bounty kills count toward eliminations stat

## Risk-Reward Analysis

### Bounty Risks
- Hunted status makes you target
- Time pressure forces engagement
- Ambush vulnerability

### Recon Risks
- Location lockout (can't leave area during scan)
- Enemy interference (take damage = restart)
- Map exposure (enemies know your general area)

### Scavenger Risks
- Spread team thin (different item locations)
- Extraction point vulnerability
- Items in contested zones

## Rewards Scaling

### Cash Progression
```lua
local ContractRewards = {
    Early = {Bounty = 200, Recon = 150, Scavenger = 200},
    Mid = {Bounty = 300, Recon = 200, Scavenger = 250},
    Late = {Bounty = 500, Recon = 400, Scavenger = 500}
}
```

### Bonus Conditions
- Speed completion: +25% bonus
- Stealth elimination (Bounty): +15% bonus
- Squad participation (Recon): +50% bonus
- Risky extractions (Scavenger): +75% bonus

## Seasonal Contract Variations

### Season 1: Standard
- Classic 3 types

### Season 2: Tactical
- Assassination contracts (eliminate specific NPC targets)
- Defend contracts (hold position against waves)

### Season 3: Heist
- Safe-cracking contracts (puzzle-based rewards)
- Escort contracts (guide NPC to extraction)

## Stats & Tracking

### Contract Statistics
```lua
local PlayerContractStats = {
    BountiesCompleted = 0,
    BountiesFailed = 0,
    ReconLocationsScanned = 0,
    ScavengerItemsCollected = 0,
    TotalContractCash = 0,
    ContractWinStreak = 0,
    FavoriteContractType = "Bounty"
}
```

### Leaderboards
- Weekly: Most contracts completed
- Global: Highest contract cash earned
- Monthly: Best contract completion rate

## Network Synchronization

### Server Authority
- Contract completion validated server-side
- All players see active contracts (map markers)
- Results replicated to all squads
- Anti-cheat checks on contract markers

### Efficient Replication
- Contract state sent every 5 seconds
- Markers updated when objectives change
- Notification only sent on state change

## Testing Checklist

- [ ] All 3 contract types spawn correctly
- [ ] Contract objectives update in real-time
- [ ] Timers countdown accurately
- [ ] Completion conditions validate properly
- [ ] Rewards calculate with bonuses
- [ ] Cancellation works without penalties
- [ ] Transfer system works on elimination
- [ ] Team visibility synced correctly
- [ ] Minimap markers accurate
- [ ] Network replication smooth
- [ ] No exploits (instant completion, camping)
- [ ] Performance with multiple active contracts

## Balancing Parameters

Exposed settings for tuning:
- Contract reward amounts
- Time limits per type
- Difficulty scaling factors
- Bonus multipliers
- Spawn frequency

## Future Enhancements

- Daily contracts with reset timer
- Personal contracts (squad-specific objectives)
- Challenge contracts (extreme difficulty, exotic rewards)
- Revenge contracts (target that killed you)
- Cooperative contracts (multiple squads team up)
- Contract leaderboards with cosmetic rewards
- Limited-time event contracts
