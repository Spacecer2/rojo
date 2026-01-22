# Economy & Buy Stations: In-Game Currency & Purchasing

## Overview
The in-game economy is a core system designed to drive strategic decision-making, reward proactive gameplay, and create dynamic shifts in power throughout a match. It's not merely a currency system, but a tool for pacing and balancing the battle royale experience.

## System Design & Vision

The economic model is built on a few key principles:

- **Cash as a Catalyst for Conflict:** The pursuit of cash, whether through looting or hunting other players, is a primary driver of engagement. The most valuable items are expensive, forcing squads to take risks to build their finances.
- **Shared Squad Economy:** By pooling cash at the squad level, we encourage communication and team-based strategic planning. The decision to spend a large amount of cash on a loadout drop versus saving it for revives becomes a critical team decision. This moves the focus from individual performance to squad-based success.
- **Buy Stations as Strategic Hotspots:** Buy Stations are intentionally placed in high-traffic areas to create focal points for conflict. Their limited number and public visibility make them high-risk, high-reward locations where squads are forced to expose themselves to gain a significant advantage.
- **Dynamic Pricing as a Balancing Mechanism:** The economy is designed to be dynamic, with prices adjusting based on the state of the match. This allows us to control the pacing of the game, making powerful items more accessible in the early game to accelerate the action, and more expensive in the late game to increase the stakes.

## Currency System

### Cash (Primary Currency)
- Earned through gameplay
- Shared per squad (team pool)
- Used at Buy Stations
- Non-tradeable between teams

### Where Cash Comes From
1. **Looting** (Primary source)
   - Cash spawns on ground in small stacks ($50-$200)
   - Open cash registers: $100-$500
   - Supply boxes: $500-$1000

2. **Eliminations**
   - Kill enemy: $100-$300 (based on distance/difficulty)
   - Assist: $50 (if teammate gets kill within 5s)
   - Headshot: +50% bonus

3. **Contracts** (Secondary source)
   - Bounty completed: $200-$500
   - Recon contract: $150-$300
   - Scavenger contract: $100-$200

4. **First kills per circle**
   - First blood bonus: $500
   - First team elimination: $1000 (squad bonus)

5. **Milestones**
   - 10 kills in match: +$500
   - 1000 total damage: +$300

### Cash Management
The shared squad pool is a fundamental aspect of the economic design. It elevates the gameplay from a collection of individual efforts to a coordinated squad-based strategy.

```lua
-- Squad cash pool
local Squad = {
    TeamId = 1,
    Members = {player1, player2, player3},
    CashPool = 0,
    CashHistory = {} -- Track earned cash
}

function AddCash(squad, amount, source)
    squad.CashPool += amount
    table.insert(squad.CashHistory, {
        Amount = amount,
        Source = source, -- "Loot", "Kill", "Contract"
        Time = tick()
    })
    
    -- Broadcast to team
    Network.FireTeam("CashUpdate", squad.CashPool)
end
```

## Buy Station System

### Station Placement
- 5-8 Buy Stations per map
- Located at high-traffic areas
- GPS markers visible on minimap
- Auto-labeled on HUD when nearby

### Station Appearance
- Large neon-lit kiosk
- Blue glowing screens
- "BUY" text prominent
- Interaction radius: 50 studs

### Interaction Mechanics
```lua
-- Player approaches buy station
if Vector3.Distance(player.Pos, station.Pos) < 50 then
    -- Show "Hold [E] to open" prompt
    if player:Input("Use") then
        OpenBuyMenu(station)
    end
end
```

## Item Categories

### 1. Tactical Items
**Purpose**: Gameplay advantage items
- **Armor Plate Bundle** ($100)
  - Grants +100 armor (can stack up to 3 plates = 300 armor)
  - Effective vs. direct damage
  
- **Ammo Restock** ($150)
  - Refills all weapons to max
  - Cannot exceed max capacity
  
- **Killstreak Loadout** ($400-$600)
  - Unlock powerful killstreaks for duration
  - Radius: 30min respawn (can be used by whole squad)
  
- **Gas Mask** ($200)
  - Immunity to gas damage for 90 seconds
  - One-time use only

### 2. Loadout Drops
**Purpose**: Get preferred weapon setup mid-game

- **Custom Loadout Drop** ($6000)
  - Drop custom loadout package (primary weapon, perks, lethals)
  - Lands near buy station in marked crate
  - 30s timer to collect
  
- **Weapon Swap Drop** ($3000)
  - Swap primary weapon to stored loadout
  - Used for mid-game pivots

### 3. Revivals & Support
**Purpose**: Team support mechanics

- **Squad Revive** ($4500)
  - Instant revive of all downed squad members within 100 studs
  - Brings them back at 50% HP
  - Must be inside station radius
  
- **Teammate Revive Token** ($2500)
  - Single teammate revive, can be used anywhere on map
  - 60 second duration (must use or expires)
  - Deployed as drop package

### 4. Reconnaissance
**Purpose**: Information gathering

- **UAV Scan** ($3000)
  - Reveals enemy positions on minimap for 90 seconds
  - All squad members can see it
  - Ping system adds markers

- **Snapshot Grenade** ($1500)
  - Throwable device
  - Shows all enemies in 50 stud radius for 10 seconds
  - Can mark through walls

## Buy Station UI

### Menu Layout
```
═══════════════════════════════════════
         BUY STATION - MAIN MENU
═══════════════════════════════════════
Squad Cash: $2,450

[TACTICAL ITEMS]
├─ Armor Bundle (x3)           $100 ea
├─ Ammo Restock                $150
├─ Killstreak Loadout          $600
└─ Gas Mask                     $200

[LOADOUTS]
├─ Custom Loadout Drop         $6000
└─ Weapon Swap                  $3000

[SUPPORT]
├─ Squad Revive                $4500
└─ Revive Token                $2500

[RECON]
├─ UAV Scan                     $3000
└─ Snapshot Grenade            $1500

[EXIT]

BALANCE: $2,450 / Spent: $0
═══════════════════════════════════════
```

### Selection & Purchase
- Tab between categories
- Arrow keys to scroll items
- [E] to purchase highlighted item
- Purchase confirmation dialog
- Deduct from squad cash

## Pricing Strategy

### Cost Factors
- Early game items: Cheap ($100-$500)
- Mid-game items: Medium ($1500-$3000)
- Late game items: Expensive ($4500-$6000)

### Dynamic Pricing
- Later in match = higher prices
- Rare items: 50% markup
- Emergency discounts during final circles (x0.5 multiplier)

## Squad Economy Decisions

### Strategic Choices
1. **Save for Loadout Drop** (~$6000)
   - Pros: Best weapon setup, team coordination
   - Cons: Expensive, must wait/find looting locations

2. **Buy Early Armor** (~$300)
   - Pros: Immediate survivability
   - Cons: Less cash for later purchases

3. **Invest in Revivals** (~$4500)
   - Pros: Team sustainability
   - Cons: High cost, only useful if someone goes down

4. **Buy UAV** (~$3000)
   - Pros: Information advantage
   - Cons: Doesn't help in direct fight

### Economic Strategies
- **Hoarders**: Save all cash, buy massive loadout late
- **Spenders**: Spend frequently for consistent advantage
- **Balanced**: Mix purchases throughout match

## Cash Display

### On-Screen Indicators
- Squad cash shown in top-right HUD
- Individual contribution shown on score screen
- Cash earned notifications ("Earned $150 from kill")
- Total squad earnings visible

### Post-Match
- Final squad balance shown
- Cash ranking vs other squads
- Breakdown: Looting vs Kills vs Contracts

## Limitations & Safeguards

### Cash Maximums
- Squad max: $10,000
- Player pickup limit: $500 at once
- Loot respawn delay: 5 minutes

### Anti-Farming
- Killing AFK players: -50 cash penalty
- Excessive revives in one spot: Marks as abuse
- Stationary players for 5min: Auto-eliminated

### Losing Cash on Death
- Squad loses cash only if all members eliminated
- Individual cash visible to enemy team (incentive)

## Buy Station Interactions

### Multiple Players at Station
- First person in interacts (queue system)
- "Waiting for player X..." notification
- 30 second timeout to complete transaction

### During Combat
- Station provides cover (solid collision)
- Enemy can see you using station (vulnerable)
- Cannot shoot while in menu

### Network Replication
- All purchases replicated to squad
- Killstreak UAV visible to team
- Loadout drops announced in chat

## Seasonal Economy Changes

### Season 1: Standard
- 5 Buy Stations
- Base prices

### Season 2: Inflation
- Prices increase 20%
- Cash earnings +30%
- New premium items added

### Event: Holiday Sale
- All items 50% off
- Limited time (7 days)
- Creates urgency

## Testing Checklist

- [ ] Cash calculations correct for all sources
- [ ] Squad pool properly shared
- [ ] Buy Station menu displays correctly
- [ ] Purchases deduct correct amounts
- [ ] Items grant intended effects
- [ ] Multiple players at station handled
- [ ] Maximum cash caps enforced
- [ ] Killstreak spawns correctly
- [ ] Loadout drops land at correct location
- [ ] Revival mechanics function properly
- [ ] UAV scan reveals enemy positions
- [ ] Economy balance incentivizes gameplay

## Performance Considerations

1. **Cash Sync**: Send updates every 5 seconds max
2. **Menu Rendering**: Cache item lists, update only on changes
3. **Killstreak Spawns**: Limit to 1 per squad at a time
4. **Cleanup**: Remove expired drops after 2 minutes

## Future Enhancements

- Advanced perks purchasable ($2000)
- Consumables (healing items, stimulants)
- Secret cash caches requiring puzzles
- Bounties (pay to mark enemy location)
- Insurance system (pay to retain loadout if squad wipes)
- Squad contracts (high-risk, high-reward cash opportunities)
- Seasonal cosmetics for purchase
