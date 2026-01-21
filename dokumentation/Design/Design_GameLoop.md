# System Design: Game Loop & Match Flow (Battle Royale)

## System Design & Vision

The game loop is the fundamental structure that defines the player's journey through a single match of our battle royale. It is designed to create a compelling narrative arc with a clear beginning, middle, and end, and to provide a constant sense of tension and release. The core principles are:

- **A Three-Act Structure:** Each match is designed to have a distinct three-act structure, similar to a classic story.
    - **Act I: The Infiltration & Scramble.** The match begins with a high-energy infiltration sequence, followed by a tense scramble for resources in the early game.
    - **Act II: The Mid-Game Hunt.** As the circle closes and players become better equipped, the mid-game becomes a strategic game of cat and mouse, with squads vying for position and hunting each other down.
    - **Act III: The Final Showdown.** The endgame is a climactic battle for survival as the last few squads are forced into a tiny, final circle.
- **Pacing and Flow:** The game loop is carefully paced to provide a balance of high-intensity action and quieter moments of strategic planning. The gas circle, the Gulag, and the distribution of loot are all designed to work together to create a dynamic and unpredictable flow to each match.
- **Player Agency and Choice:** While the overall structure of the game loop is linear, players have a high degree of agency within each phase. They can choose where to drop, which contracts to pursue, and how to approach the final circle. This ensures that no two matches play out the same way.

## 🔄 Match Lifecycle

### 1. Pre-Game Lobby (The Warmup)
- **State**: `MatchState.Warmup`
- **Behavior**: Players spawn with random loadouts. Damage is enabled, but deaths respawn instantly in the air.
- **Goal**: Allow asset pre-loading and wait for player count (min 40, max 150).
- **Countdown**: Starts when player threshold is met.

### 2. Infiltration (The Drop)
- **State**: `MatchState.Infil`
- **Cinematic**:
    - **Cutscene**: C-130 transport plane flies over the map path.
    - **UI**: "DROP ZONE" text, altitude altimeter.
- **Mechanics**:
    - Players can eject at any point along the flight path.
    - **Parachute**: Procedural deployment physics (acceleration/deceleration). Cut/re-deploy mechanics.
    - **Flare**: Smoke trail on players to signal enemies.

### 3. Early Game (Loot & Scavenge)
- **State**: `MatchState.Active`
- **Phase**: Gas Circle 1 closes (5 minutes).
- **Activities**: Looting ground items, completing Contracts, buying Loadout Drops.

### 4. Mid Game (Loadouts & Positioning)
- **Phase**: Gas Circles 2-4.
- **Event**: "Public Loadout Drop" (Free loadouts drop randomly within the circle).
- **Gulag**: The Gulag closes at the end of Circle 4. Anyone dead after this is permanently out unless bought back.

### 5. End Game (The Squeeze)
- **Phase**: Circles 5-8 (Moving Zones).
- **Mechanic**: The circle shifts position while shrinking, forcing rotation.
- **Intensity**: Gas mask durability becomes critical.

### 6. Victory (Exfil)
- **State**: `MatchState.Victory`
- **Trigger**: One squad remains.
- **Cinematic**:
    - Helicopter arrives.
    - Camera pans to winning squad boarding.
    - "WARZONE VICTORY" banner overlay.
    - Credits roll with match stats.

---

## ☠️ The Gulag (Respawn Mechanic)

A 1v1 arena where eliminated players fight for a second chance.

### Mechanics
1.  **Queue**: Dead players enter a spectator balcony overlooking the pit. They can throw rocks (0 damage, slight stun) at fighters below.
2.  **The Fight**:
    - **Loadout**: Random symmetrical loadout (e.g., Shotguns, Pistols, or Snipers only).
    - **Timer**: 40 seconds total.
    - **Overtime**: If no one dies in 25s, a **Capture Flag** spawns in the center. Capturing it wins the round.
3.  **Outcome**:
    - **Winner**: Redeploys via parachute above their squad.
    - **Loser**: Eliminated (Spectate squad or leave).

---

## 🌫️ The Gas System (Circle Logic)

The playable area is restricted by a damaging "Gas" zone.

### Technical Implementation
- **Shape**: Cylinder (infinite height).
- **Damage**: Percentage-based ticking damage (e.g., 10% hp/sec).
- **Visibility**: Post-processing effect (green tint, blur) and coughing audio when inside.
- **Gas Mask**: Item that prevents damage for 12 seconds. Has a distinct "cracking" animation overlay when breaking.

| Circle | Duration | Close Time | Damage |
| :--- | :--- | :--- | :--- |
| 1 | 4:00 | 2:00 | Low |
| 2 | 3:00 | 1:30 | Low |
| 3 | 2:30 | 1:15 | Med |
| 4 | 2:00 | 1:00 | Med (Gulag Closes) |
| 5 | 1:30 | 0:45 | High |
| 6 | 1:00 | 0:30 | Extreme |
