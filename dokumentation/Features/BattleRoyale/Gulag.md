# The Gulag: 1v1 Arena & Capture-The-Flag Overtime

## Overview
The Gulag is a high-stakes, second-chance mechanic that fundamentally alters the traditional battle royale formula. Instead of permanent elimination on first death, players are given a chance to fight their way back into the match through a 1v1 duel.

## System Design & Vision

The Gulag is a cornerstone of the Warzone experience, designed to solve several key problems with the battle royale genre:

- **Mitigating Early-Game RNG:** In a typical BR, an unlucky early-game encounter can lead to a frustratingly short match. The Gulag gives players a second chance, making the early game more forgiving and encouraging more aggressive plays.
- **Maintaining Squad Integrity:** The Gulag keeps squads in the game longer. Even if a player is eliminated, their squad can still play with the hope of their teammate winning their Gulag and returning. This reduces the "lame duck" phase where a squad is at a disadvantage for the rest of the match.
- **A Test of Pure Skill:** The Gulag is a 1v1 duel on a symmetrical map with a limited weapon pool. This strips away the variables of the main battle royale and boils it down to a pure test of gun skill. This creates a compelling and fair "redemption arc" for the player.
- **Narrative & Tension:** The Gulag is a moment of high drama. A player's entire squad is spectating, their hopes riding on the outcome of a single duel. This creates a powerful narrative moment that is unique to each match.

## Gulag Mechanics

### Entry Conditions
1. **First Death Only**: Players are sent to Gulag only on their first elimination
   - Subsequent eliminations = permanent death
   - Downed state → Gulag if not revived within 30s
   - Respawned from Gulag → no second Gulag

2. **Timing**: Gulag match starts immediately after player elimination
   - Load-in time: 3 seconds
   - Preparation phase: 15 seconds (customize loadout)
   - Fight phase: 3-5 minutes (best of 3 possible outcomes)

3. **Matchmaking**: 
   - Next eliminated enemy enters as opponent
   - Queue system if no opponent available
   - Timeout: 30 seconds → automatic loss

### Gulag Arena

#### Map Design
- Small, symmetrical arena (100x100 studs)
- Multiple cover points (boxes, pillars, walls)
- Ceiling: 50 studs (prevents helicopter escapes)
- No gas, no environmental hazards
- Neutral lighting, balanced for both players

#### Layout
```
        ┌─────────────────┐
        │   CENTER ZONE   │
        │   (Open Arena)  │
    ┌───┤   50x50 studs   ├───┐
    │   └─────────────────┘   │
    │   ┌─────────────────┐   │
    │   │ SPAWN POINT A   │   │
┌───┴───┤ Cover Scattered │───┴───┐
│ SIDE  │   Both Sides    │ SIDE  │
│ COVER │   Symmetrical   │ COVER │
└───┬───┤ Ammo Crates:    │───┬───┘
    │   │ 2 AR Ammo      │   │
    │   │ 2 Shotgun      │   │
    │   │ 1 Sniper Ammo  │   │
    │   └─────────────────┘   │
    │                         │
    │   ┌─────────────────┐   │
    └───┤ SPAWN POINT B   ├───┘
        │ (Opposite Side) │
        └─────────────────┘
```

#### Weapon Pool
- M4A1 (2x, one at each spawn)
- Glock 18 (2x secondary)
- Shotgun (1x center, high risk to grab)
- Ammo scattered throughout
- No grenades/lethals (fair melee combat too)

### Loadout Selection

#### Preparation Phase (15 seconds)
Player must choose:
1. **Primary Weapon** from available options
   - M4 (Default, balanced)
   - SMG (Close range, movement)
   - Sniper (Long range, one-shot)
   - Shotgun (One-hit at close range, slow reload)

2. **Perks** (Choose 2 of 4)
   - Double Time (↑ Sprint duration)
   - Ghost (Invisible to killcam)
   - Cold Blooded (Unseen by thermal)
   - High Alert (Ping when tracked)

3. **Lethal** (Choose 1 or none)
   - Frag Grenade
   - Semtex
   - None (conserves cooldown)

#### Loadout Balance
- All combos viable (no hard counters)
- Pro loadouts still vary by playstyle
- Random opponent prevents perfect counter-picking

### Fight Phase

#### Victory Conditions (First to happen)
1. **Elimination**: Opponent reaches 0 HP
   - Only outcome counts as "win"
   - Downed opponent bled out after 30s

2. **Time Limit**: 5 minutes elapsed
   - Both players still alive = TIE
   - Sudden Death: 1v1 mutual damage mode (no healing)
   - First to die loses

#### Scoring System
```lua
local GulagStats = {
    Eliminations = 0,
    Losses = 0,
    WinStreak = 0,
    BestStreak = 0,
    TotalKills = 0,
    TotalDeaths = 0,
    AverageMatchTime = 0
}
```

#### Player HUD During Gulag
- Opponent name visible
- Remaining HP bars (both players)
- Ammo counter
- Timer (5:00 counting down)
- Kill streak counter

### Sudden Death (If Time Expires)

#### Rules
- Both players take constant 5 HP/sec damage
- No healing items spawn
- Forces engagement
- First to reach 0 HP loses
- Typical duration: 30-90 seconds

#### Arena Changes
- Lighting intensifies (red emergency lights)
- Music tempo increases
- Screen edges vignette (claustrophobic feel)

## Gulag Progression & Ranking

### Gulag Tier System
```lua
local GulagRanks = {
    {Name = "Recruit", WinsRequired = 0},
    {Name = "Soldier", WinsRequired = 5},
    {Name = "Veteran", WinsRequired = 15},
    {Name = "Elite", WinsRequired = 30},
    {Name = "Legend", WinsRequired = 50},
    {Name = "Unstoppable", WinsRequired = 100}
}
```

### Rank Rewards
- Visual badge in lobby
- Special intro animation
- Cosmetic weapon skins
- XP boosters
- Prestige cosmetics at high ranks

### Matchmaking Quality
- Rank-based lobbies after first season
- New players matched with other new players
- Prevents smurfing (account level check)

## Network & Synchronization

### Gulag Instance
- Separate isolated map instance (reduced network traffic)
- Local server handles all physics
- Results replicated back to main match

### Data Replication
1. Player enters Gulag → Sent to isolated server
2. Opponent selection → Matched or queued
3. Fight happens → Server records outcome
4. Winner: Teleported back to squad position
5. Loser: Spectate mode or return to lobby

### Anti-Cheat
- All damage validated server-side
- No client-side damage calculation
- All position updates validated
- Hit detection server-authoritative

## Spectating

### After Gulag Loss
- Spectate your Gulag opponent's match
- Watch their team try to avenge you
- See if they win the match
- Cash reward if team wins (+$100)

### Spectate Features
- Free camera (watch from any angle)
- Teammate squad vision (see their view)
- Minimap of main match
- Timer of main match circle

## Gulag Chat & Banter

### Pre-Match Dialogue
- Random quips from announcer
- Squad encouragement: "Go get them!"
- Sound of crowd (audio ambience)

### Post-Match
- Winner: Celebration animation + sound
- Loser: Respectful "good fight" message
- Both: Stat summary (damage, accuracy, etc.)

## Return to Match

### Winner Resurrection
```lua
function ReturnFromGulag(winner, squad)
    -- Respawn at squad position if safe
    if IsSafeToSpawn(squad.Position) then
        winner.Character:MoveTo(squad.Position)
    else
        -- Spawn at nearest safe location
        winner.Character:MoveTo(FindNearestSafeSpawn(squad.Position))
    end
    
    -- Restore loadout
    winner:EquipLoadout(winner.CurrentLoadout)
    
    -- Notify squad
    Network.FireTeam("GulagWinner", winner.Name)
end
```

### Rejoin Sequence
- 2 second fade-in animation
- Squad members see respawn notification
- Position marked on minimap
- Audio cue for teammates

## Gulag Settings & Customization

### Toggle Options
- Solo queue (1v1 only)
- Squad Gulag (3v3 matches) - separate mode
- Practice Gulag (vs AI, no consequences)

### Difficulty Scaling
- Beginner: Opponent accuracy 60%
- Normal: Opponent accuracy 80%
- Hard: Opponent accuracy 95%
- Legendary: Opponent accuracy 100% + AI reads your moves

## Balance Considerations

### Weapon Balance
- M4: Mid-range, balanced
- SMG: Close-range domination
- Sniper: One-shot kills (high skill)
- Shotgun: Lethal up-close (risky)

### Map Symmetry
- Identical cover on both sides
- Spawn points equidistant from center
- No advantage areas
- Encourages skillful play

### Luck Mitigation
- Best-of-3 possible
- Loadout selection mitigates variance
- Streaks reward consistent skill

## Testing Checklist

- [ ] Gulag arena spawns correctly
- [ ] Loadout selection UI functional
- [ ] Fight mechanics work (damage, elimination)
- [ ] Timer countdown accurate
- [ ] Sudden Death triggers after 5:00
- [ ] Winner returns to main match
- [ ] Loser goes to spectate mode
- [ ] Stats properly recorded
- [ ] Network sync smooth
- [ ] Rank progression calculates correctly
- [ ] No exploits (hiding, terrain glitches)
- [ ] Audio cues play appropriately

## Performance Optimization

1. **Instance Isolation**: Gulag runs on separate server thread
2. **LOD Disabled**: No culling needed (small map)
3. **Physics Simplification**: Fewer objects in arena
4. **Batch Updates**: Send position/health every 100ms only

## Future Enhancements

- Gulag tournaments (brackets)
- Squad Gulag (3v3 team duels)
- Gulag cosmetics (weapon skins exclusive to Gulag winners)
- Gulag achievements (flawless runs, revenge matches)
- Community voting on Gulag maps
- Seasonal Gulag map rotations
- Champion titles (current win streak displays)
- Gulag MVP rewards (best performer in weekly leaderboard)
