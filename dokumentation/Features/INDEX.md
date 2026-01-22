# Cross-Reference Index

Quick-reference guide for feature dependencies, interactions, and terminology standards.

**Navigation:** [Main README](README.md) | [Dependencies](#dependencies) | [Interactions](#interactions) | [Terminology](#terminology)

---

## Dependencies

This section outlines the critical dependencies between the core systems. Understanding these relationships is essential for maintaining the stability and integrity of the overall game architecture.

### Core Orchestrator: MatchLifecycle
The `MatchLifecycle` is the master state machine that governs the entire flow of a match. It is the central nervous system of the game, and all other systems are subservient to it.

- **Owns:** The master state of the match (Lobby → Infiltration → Active → Victory).
- **Controls:** All major state transitions, including the gas circle timing, player spawning, and elimination events.
- **Depends on:** Nothing. It is the top-level system.

### The Economic Engine: Economy
The `Economy` system is the engine that drives player motivation and strategic decision-making. It is not just a currency system, but a tool for creating conflict and rewarding skill.

- **Sources:** All player actions that generate value, including kills ([WeaponFramework](Combat/WeaponFramework.md)), looting ([LootingSystem](BattleRoyale/LootingSystem.md)), and contracts ([Contracts](BattleRoyale/Contracts.md)).
- **Sinks:** All items and actions that provide a strategic advantage, such as killstreaks, revives, and loadout drops.
- **Affected by:** The `GasSystem`, which can trigger emergency "fire sales" to accelerate the late-game economy.

### The Combat Loop: WeaponFramework → GunsmithSystem → VisualRecoil
This is the core combat loop, a tightly integrated pipeline that delivers a responsive and skill-based gunplay experience.

- **`WeaponFramework` (Authority):** The foundation of the combat loop, responsible for all ballistics calculations and damage application. It reads data from the `GunsmithSystem` to determine the properties of each weapon.
- **`GunsmithSystem` (Configuration):** The heart of player expression in combat. It allows players to modify the stats and behavior of their weapons, which are then fed back into the `WeaponFramework`.
- **`VisualRecoil` (Feedback):** The final layer of the combat loop, providing visceral feedback to the player. It is driven by events from the `WeaponFramework` and modifiers from the `GunsmithSystem`.

### The Pacing Mechanism: GasSystem & Gulag
These two systems work in tandem to control the pacing of the match and to create a fair and engaging experience.

- **`GasSystem`:** The primary mechanism for forcing player engagement and creating a sense of urgency. It is driven by the `MatchLifecycle` and affects all other systems, from looting to contracts.
- **`Gulag`:** The second-chance mechanic that mitigates early-game frustration and keeps squads in the game longer. It is a self-contained system that is triggered by the `MatchLifecycle`.

### The Content Pipeline: LootingSystem & RewardSystems
These systems are responsible for populating the game world with content and for rewarding players for their time and investment.

- **`LootingSystem`:** The system that distributes all in-game items, from weapons and ammo to armor plates and cash. It is driven by the `MatchLifecycle` and the `GasSystem`.
- **`RewardSystems`:** The long-term progression and monetization engine. It is responsible for all cosmetic rewards, including the Battle Pass and supply drops.

### The Player's Lens: SettingsMenu
The `SettingsMenu` is the player's window into the game. It allows them to customize their experience, from the sensitivity of their mouse to the color of their crosshair. It is a critical component of player agency and accessibility.

---

## Interactions

This section illustrates the data flow and chain of events for key gameplay scenarios, providing a clear, high-level understanding of how the core systems interact.

### Scenario: Player Earns a Killstreak
This scenario demonstrates the flow of the economy and loot systems.

`Player Interaction` → `Buy Station UI` → `Economy` (validates and deducts cash) → `MatchLifecycle` (initiates killstreak) → `LootingSystem` (spawns loadout drop) → `Player` (receives killstreak).

### Scenario: Player Accepts a Bounty Contract
This scenario shows the interplay between the contract system, the economy, and player progression.

`Player Interaction` → `Contracts` (activates bounty) → `MatchLifecycle` (broadcasts bounty to target) → `WeaponFramework` (registers kill) → `Contracts` (validates completion) → `Economy` (awards cash) → `BattlePass` (awards XP).

### Scenario: Player is Eliminated and Enters the Gulag
This scenario highlights the second-chance mechanic and its integration with the match lifecycle.

`Player Health` ≤ 0 → `MatchLifecycle` (triggers Gulag) → `Gulag` (transports player to arena) → `LootingSystem` (provides balanced weapon) → `Gulag` (resolves duel) → `MatchLifecycle` (re-deploys or permanently eliminates player).

### Scenario: The Gas Circle Closes
This scenario illustrates the core pacing mechanism of the battle royale.

`MatchLifecycle` (triggers new gas phase) → `GasSystem` (updates circle parameters and damage) → `Contracts` (updates zone-based objectives) → `LootingSystem` (despawns loot in gas) → `Player` (forced to move).

---

## Terminology

**For consistency across all documentation, use these terms:**

| Concept | Standard Term | ❌ Avoid |
|---------|---------------|---------|
| In-game earned currency | **Cash** | Money, coins, credits |
| Real-money currency | **COD Points** (CP) | Premium currency, Tokens |
| Currency from duplicates | **Cosmetic Bucks** | Shards, dust |
| Airborne item event | **Supply Drop** | Airdrop, crate drop |
| Ground item container | **Supply Container** | Supply box, loot crate, chest |
| Character cosmetic | **Operator Skin** | Character skin, outfit |
| Weapon cosmetic | **Weapon Blueprint** | Weapon skin, cosmetic |
| Weapon modification | **Attachment** | Module, mod, component |
| Damage reduction item | **Armor Plate** | Shield, plate |
| Battle Pass level | **Tier** | Level, rank (in BP context) |
| Weapon configuration | **Loadout** | Setup, build, class |
| Gas expansion level | **Circle Phase** or **Gas Phase** | Round, wave, stage |
| Player death | **Eliminated** | Killed, knocked |
| Gulag respawn | **Returned** | Respawned, revived |

---

## Statistics

| Metric | Value |
|--------|-------|
| **Total Features** | 12 |
| **Documentation Files** | 13 (12 + INDEX) |
| **Total Lines** | ~3,500 |
| **Code Examples** | 50+ |
| **Testing Checklists** | ✅ 12/12 Complete |
| **Cross-References** | 40+ links |
| **Consistency Status** | ✅ Verified |

---

## Navigation

- **[Back to Main README](README.md)** - Feature directory and overview
- **[Combat Systems](Combat/)** - Weapon & gunplay
- **[BattleRoyale Systems](BattleRoyale/)** - Core BR loop
- **[Progression Systems](Progression/)** - Player retention
- **[System Features](Systems/)** - UI & settings
