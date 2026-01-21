# System Design: Contracts

## System Design & Vision

Contracts are a core gameplay mechanic designed to create dynamic, player-driven scenarios and objectives within a single match. They are not simply side-quests, but a fundamental part of the strategic layer of the game. The design is guided by the following principles:

- **Player-Driven Narrative:** Contracts generate micro-narratives within each match. A "Bounty" contract creates a tense hunter-hunted scenario, while a "Recon" contract tells a story of tactical positioning and foresight. This makes each match feel unique and less predictable.
- **Risk vs. Reward:** Each contract type is designed with a clear risk-reward profile. Bounties are high-risk, high-reward, pushing squads into direct conflict. Recons are lower risk, offering a strategic advantage. This allows squads to choose their level of engagement.
- **Economic & Strategic Integration:** Contracts are deeply integrated with the in-game economy. They are a primary source of cash, which can then be used at Buy Stations to gain a significant advantage. This creates a feedback loop where completing contracts directly translates to increased power.
- **A Tool for Pacing and Flow:** Contracts are used to influence the pacing and flow of the match. For example, Recon contracts can be used to encourage players to move to new areas of the map, while Most Wanted contracts can create a "king of the hill" scenario in the mid-game.

## 📜 Contract Types

### 1. 🎯 Bounty
**Objective**: Eliminate a specific target player.
- **Mechanics**:
    - A random player within a radius is marked.
    - **Hunter**: Sees a yellow circle on the map estimating target location. Circle shrinks as they get closer.
    - **Hunted**: Receives a "THREAT LEVEL" UI (Low/Med/High) based on proximity of hunters.
- **Outcome**:
    - **Success**: Cash reward for the hunting squad.
    - **Poached**: If someone else kills the target, partial reward.
    - **Survival**: If time runs out, the *Target* gets the reward.

### 2. 👁️ Recon (Secure Area)
**Objective**: Capture a specific point to reveal the next circle.
- **Mechanics**:
    - Spawns a flare at a random location.
    - Squad must stand near the device to "upload data" (Capture bar).
    - Launching the flare alerts nearby enemies.
- **Reward**: High loot, Cash, and **reveals the next Safe Zone circle** (Yellow circle on map).

### 3. 📦 Scavenger
**Objective**: Open 3 specific supply boxes sequentially.
- **Mechanics**:
    - Marks the first crate. Opening it marks the second, then the third.
    - Each crate drops better loot than standard boxes.
- **Reward**: The final crate guarantees a **Satchel** (Armor or Munitions) and high Cash.

### 4. 👑 Most Wanted
**Objective**: Survive for 3 minutes while marked for *everyone*.
- **Mechanics**:
    - Picking up this contract marks the player (Crown Icon) on the map for ALL players in the lobby.
    - Timer: 3:00.
    - Reducing Timer: Opening crates or getting kills reduces the timer.
- **Reward**: High Cash + **Instantly revives all dead squadmates** (free buyback).

---

## ⚙️ Spawning & logic

- **Distribution**: Contracts spawn randomly at the start of the match.
- **Limit**: Only one contract can be active per squad at a time.
- **Overtime**: New contracts stop spawning after Circle 4 closes.

## 🛠️ Technical Implementation

### `ContractService`
- **State Management**: Tracks active contracts per squad.
- **Target Selection**: Efficiently queries spatial data to find valid Bounty targets (not too close, not too far).
- **UI Replication**: Sends HUD updates (Timers, Threat Levels) only to relevant clients.
