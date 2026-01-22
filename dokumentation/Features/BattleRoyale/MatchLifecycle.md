# Match Lifecycle: Pre-Game → Infiltration → Victory

## Overview
The match lifecycle is the backbone of the battle royale experience. It's a carefully orchestrated state machine that guides players through a distinct narrative arc, from the initial chaos of infiltration to the final, tense moments of a one-on-one showdown.

## System Design & Vision

The match lifecycle is designed to create a specific and compelling player experience that is distinct from a traditional deathmatch or other game modes. The core principles are:

- **A Three-Act Structure:** Each match is designed to have a clear beginning, middle, and end.
    - **Act I: The Scramble.** The infiltration and initial looting phase is all about survival and gearing up.
    - **Act II: The Hunt.** The mid-game is a strategic game of cat and mouse, as squads hunt each other, complete contracts, and vie for positional advantage.
    - **Act III: The Showdown.** The endgame is a climactic battle for survival as the final few squads are forced into a tiny, final circle.
- **Player Agency and Choice:** While the overall structure is linear, players have a high degree of agency within each phase. They can choose where to drop, which contracts to pursue, and how to approach the final circle. This ensures that no two matches play out the same way.
- **Escalating Stakes:** The stakes are constantly escalating throughout the match. The gas becomes more damaging, the circle shrinks faster, and the value of a single elimination increases exponentially. This creates a powerful sense of tension and excitement that builds to a crescendo in the final moments.
- **A Sense of Place and Journey:** The large, detailed map is more than just a backdrop for the action. It's a character in itself, with its own landmarks and secrets. The journey from the initial drop zone to the final circle is a key part of the experience.

## Match States

### 1. Lobby State (30-120 seconds)
**Duration**: Configurable, typically 30s for full lobbies
- Players spawn in the Lobby/Hangout area
- Can preview weapons, change loadouts, inspect operators
- Squad preview available (3D model display)
- Countdown timer visible
- Can cancel/leave before infiltration

**Server Actions**:
- Wait for minimum players (4-150 depending on mode)
- Allocate match ID and server instance
- Load map data
- Prepare supply boxes, loot spawns

**Client Actions**:
- Display "Ready Up" button
- Show teammate names and operators
- Preview weapon stats

### 2. Infiltration State (90-120 seconds)
**Duration**: Variable based on map size
- Plane enters map airspace from direction
- Players see plane interior (animated cutscene)
- Player can jump at any time
- Automatic deploy near end
- Parachute mechanic with steering

**Server Actions**:
- Spawn plane with all players
- Calculate flight path based on selected positions
- Monitor jump positions and parachute states
- Deploy non-jumping players at end of path

**Client Actions**:
- Render plane interior
- Show overhead map with flight path
- Parachute deployment UI
- Fall speed and altitude indicators
- Teammate position tracking

### 3. Active Match State (15-25 minutes)
**Duration**: Until only 1 team remains or circle ends
- Players loot, fight, and complete objectives
- Gas circle contracts and damages players
- Buy stations active
- Supply drops fall at intervals
- Contracts available (Bounty, Recon, Scavenger)

**Server Actions**:
- Process all player damage/healing
- Manage gas circle movement
- Spawn supply drops
- Validate contract progress
- Eliminate players with 0 HP
- Send telemetry/stats updates

**Client Actions**:
- Render HUD (health, ammo, teammates)
- Update minimap with positions
- Play ambient sounds
- Display notifications (eliminations, buyback)
- Contract progress UI

### 4. End Game State (Final 2-5 minutes)
**Duration**: Last 3 circles converge to point
- Gas moves rapidly, damage increases
- Teams converge on small area
- Intense 1v1 fights
- Clutch plays likely

**Server Actions**:
- Accelerate circle contraction
- Increase gas damage per tick
- Monitor for last team standing

**Client Actions**:
- Shake screen during gas expansion
- Zoom HUD elements closer to center
- Play tension music
- Highlight teammate callouts

### 5. Victory State
**Winner Determination**:
- Last team with any living member
- If all players eliminated simultaneously → tie (rare)

**Server Actions**:
- Lock match state (no more shooting/movement)
- Calculate stats (kills, damage, survival time)
- Award rewards (XP, currency)
- Send to leaderboards
- Initialize victory animation

**Client Actions**:
- Display victory screen with team names
- Play victory music/sounds
- Show stats breakdown
- Offer to queue again or return to lobby

## State Transition Diagram

```
Lobby (30s)
    ↓
Infiltration (90-120s, player controlled)
    ↓
Active Match (15-25 min, dynamic)
    ├→ Player Eliminated (sent to spectate or end)
    ├→ Team Wipe (survivors continue)
    ├→ Gas Circle Closes
    ↓
End Game (Final circles, 2-5 min)
    ├→ Player Eliminations accelerate
    ├→ Emergency Buy Station bonuses (x2 cash)
    ↓
Victory (1 team remains)
    ↓
Post-Match Screen (stats, rewards)
    ↓
Lobby (queue again or back to menu)
```

## Player Lifecycle Within Match

### Spawn
1. Load character with equipped loadout
2. Parachute deployment from plane
3. Land on map
4. Full HP/Armor at start
5. Starter weapon equipped

### Alive Phase
- Free roam and combat
- Loot looting
- Gas avoidance (health drain if caught outside)
- Team coordination

### Downed Phase (Warzone-specific)
- Hit 0 HP → enter "Down" state instead of instant death
- Can be revived by teammate within 30s window
- Teammate can pick up banner → redeploy at Gulag
- 60s timer to fully bleed out if not revived

### Eliminated Phase
- Cannot respawn in Solo modes
- Can spectate teammates in Squad modes
- Removed from active player list
- Can purchase "Loadout Drop" to rejoin

### Victory or Defeat
- Match ends for player
- Stats calculated and stored
- Rewards dispensed
- Return to menu or queue

## Game Loop Timing

### Server Tick Rate
- Physics: 60 Hz (RunService.Heartbeat)
- Network: 30 Hz (replication cadence)
- Checks: 1 Hz (gas damage, elimination checks)

### Client Render
- Continuous (60+ FPS)
- Input processing: Every frame
- Animation updates: Every frame

## Circle/Gas System Integration

**Gas Circles**: Managed by separate GasSystem
- Circle 1: Starts at 60s mark (shrinks to 60% of map)
- Circle 2: At 5min mark (shrinks to 30% of map)
- Circle 3: At 10min mark (shrinks to 10% of map)
- Circle 4+: Rapid mini-circles until winner

**Damage Ticks**:
- Circle 1: 1 damage/sec outside
- Circle 2: 5 damage/sec
- Circle 3: 10 damage/sec
- Circle 4+: 20 damage/sec

## Networking & Synchronization

### Critical Replication
1. **Player State** (60Hz)
   - Position, velocity, orientation
   - HP, armor level
   - Weapon equipped, ammo count

2. **Events** (On-demand)
   - Player eliminated
   - Team eliminated
   - Match ended
   - Contract completed

3. **UI Updates** (30Hz)
   - HUD refresh
   - Minimap updates
   - Teammate status

### Conflict Resolution
- Server is authoritative on all damage/elimination
- Client can predict movement but defers to server
- Position corrections smoothed over network frame

## Exemplary Match Flow

```
T=0:00  → Lobby starts, 150 players join, countdown 30s
T=0:30  → Infiltration: Players board plane
T=1:00  → First player jumps, deploys parachute
T=2:00  → Last players auto-deploy
T=2:15  → Players begin looting, initial skirmishes
T=5:00  → Circle 1 warning, ~100 players alive
T=5:30  → Circle 1 closes, gas damage begins
T=8:00  → Circle 2 warning, ~60 players alive
T=10:00 → Circle 2 closes, 40 players alive
T=12:00 → Intense mid-game: Multiple teams clash
T=15:00 → Circle 3 warning, ~15 players alive (3 teams)
T=17:00 → Circle 3 closes, 8 players alive (2 teams)
T=20:00 → End Game: Teams in tight 50m area
T=22:00 → Final fight, 3 players alive (1 team + 1 solo)
T=22:45 → Victory! Winning team gets rewards
T=23:00 → Stats screen, option to queue again
```

## Key Features

### Squad Elimination
- If all members of a squad eliminated, squad is completely out
- Leaderboard shows squad rank

### Last Stand Mechanics
- Final player(s) get dramatic music/effects
- If solo mode, music intensifies for last 3 players

### Commentary System
- Announcer calls out milestones
  - "First blood!"
  - "Multi-kill!"
  - "Victory!"

## Performance Considerations

1. **Player Culling**: Distant players update less frequently
2. **LOD Streaming**: Buildings load/unload based on proximity
3. **Cleanup**: Corpses/items removed after 300s
4. **Instance Recycling**: Match servers reused after cleanup

## Error Handling

### Player Disconnect
- Body becomes idle NPC (can still be shot)
- Revive window extended by 30s if teammate nearby
- Can rejoin same match within 60s

### Server Crash
- Match gracefully paused
- Players kept alive on last known state
- Server restarts and replays to match point

### Network Latency
- Client-side hit detection with 100ms tolerance
- Server validates all damage applicability
- Rollback if invalid

## Testing Checklist

- [ ] State transitions occur correctly
- [ ] Gas circles spawn and move predictably
- [ ] Player elimination triggers proper state changes
- [ ] Team wipes recognized correctly
- [ ] Victory determined only when valid condition met
- [ ] Stats calculated accurately
- [ ] Network replication smooth and consistent
- [ ] Disconnected players handled gracefully
- [ ] Full match 20+ min completes without issues

## Future Enhancements

- Loadout drops for respawn (like Fortnite/Apex)
- Gulag system for first elimination (1v1 fight to rejoin)
- Seasonal events with modified match rules
- Tournament modes with fixed circle timing
