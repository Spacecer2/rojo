# System Design: Game Loop & Match Flow (Battle Royale)

This document details the lifecycle of a single Battle Royale match, from the pre-game lobby to the final extraction.

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
