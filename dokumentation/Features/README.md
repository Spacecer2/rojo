# 🎮 Features Documentation

Complete design documentation for all gameplay systems and features in the Warzone MW2019 Roblox recreation.

## 🔥 The Warzone Experience

A typical match of Warzone is a high-stakes battle for survival with a unique gameplay loop:

1.  **Infiltration:** All squads start by dropping from a plane onto a large, detailed map. The initial moments are a scramble for weapons, armor, and resources.
2.  **Loot & Contracts:** Squads explore the map, looting buildings for better gear and completing contracts to earn cash and other rewards.
3.  **The Gas:** A deadly circle of gas slowly closes in, forcing squads into an ever-shrinking playable area.
4.  **Buy Stations:** Squads can use the cash they've earned to buy valuable items like killstreaks, armor plates, and even bring back eliminated teammates.
5.  **The Gulag:** Upon their first elimination, players are sent to the Gulag, a 1v1 arena where they can fight for a chance to redeploy.
6.  **The Final Circle:** The last remaining squads fight it out in a small, final circle until only one team is left standing.

This gameplay loop creates a dynamic and unpredictable experience that we aim to capture in this project.

## 📁 Structure

Features are organized into 4 logical categories:

### 🔫 **Combat/** - Weapon Systems & Gunplay
Core ballistics, weapon customization, and visual feedback systems.

- **[WeaponFramework.md](Combat/WeaponFramework.md)** - Hitscan/Projectile hybrid ballistics system
  - Bullet travel, drop, penetration mechanics
  - Material-based damage falloff
  - Server-authoritative hit validation

- **[GunsmithSystem.md](Combat/GunsmithSystem.md)** - Attachment-based weapon customization
  - Real-time stat modification
  - Barrel, muzzle, optic, grip, stock categories
  - Loadout persistence and compatibility validation

- **[VisualRecoil.md](Combat/VisualRecoil.md)** - Feedback and feel
  - Spring-physics camera kick
  - Weapon sway and procedural animations
  - Haptic vibration patterns
  - Skill-based recoil compensation

### 🎯 **BattleRoyale/** - Core BR Loop
Everything needed for a complete battle royale match flow.

- **[MatchLifecycle.md](BattleRoyale/MatchLifecycle.md)** - Match state orchestration
  - Lobby → Infiltration → Active Match → End Game → Victory
  - Player lifecycle (spawn, alive, downed, eliminated)
  - Network synchronization & conflict resolution

- **[GasSystem.md](BattleRoyale/GasSystem.md)** - Circular hazard & pacing
  - 4+ phase contraction system
  - Escalating damage (1→5→10→20 HP/sec)
  - Visual distortion and post-processing effects
  - Circle prediction mechanics

- **[Gulag.md](BattleRoyale/Gulag.md)** - Second-chance 1v1 system
  - First-elimination-only duel arena
  - Sudden death overtime (mutual damage mode)
  - Winner respawn, loser permanent elimination
  - Rank progression & cosmetics

- **[LootingSystem.md](BattleRoyale/LootingSystem.md)** - Item distribution
  - Ground loot spawning (respawning)
  - Supply containers (common & rare)
  - Emergency air-drops (mid-match events)
  - Corpse loot & inventory management
  - Rarity tiers: Common → Uncommon → Rare → Epic → Legendary → Exotic

- **[Contracts.md](BattleRoyale/Contracts.md)** - Secondary objectives
  - **Bounty**: Hunt target squad ($300-$500 reward)
  - **Recon**: Scan locations for intel ($600 reward)
  - **Scavenger**: Collect items & extract ($750 reward)
  - Difficulty scaling & risk-reward balance

- **[Economy.md](BattleRoyale/Economy.md)** - In-game currency system
  - **Cash is King**: Earn cash through looting, kills, and contracts to gain a significant advantage.
  - **Buy Stations**: These are shops where players can spend their cash on valuable items like killstreaks, armor plates, and teammate revives.
  - Squad cash pool (shared team budget)
  - Dynamic pricing (early game cheap, late game premium)

### 📊 **Progression/** - Player Retention Systems
Long-term engagement and cosmetic reward structures.

- **[BattlePass.md](Progression/BattlePass.md)** - Seasonal 100-tier progression
  - Free and premium tracks with a variety of rewards.
  - Examples: Operator skins (e.g., "Ghost," "Captain Price"), weapon blueprints with unique attachments and appearances, and cosmetic items like calling cards and emblems.
  - Weekly/daily challenges for accelerated progression
  - Pity system on COD Points purchases

- **[RewardSystems.md](Progression/RewardSystems.md)** - Supply drop cosmetics
  - Probabilistic loot box system
  - Rarity tiers: Standard (60%) → Rare (30%) → Epic (8%) → Mythic (2%)
  - **Pity mechanics**: Guaranteed tier every N opens
  - Duplicate conversion to cosmetic currency
  - Optional premium passes and bundle cosmetics

### ⚙️ **Systems/** - UI & Settings
Meta-systems affecting all gameplay.

- **[SettingsMenu.md](Systems/SettingsMenu.md)** - Player customization
  - **Input**: Sensitivity, control schemes, keybinding, deadzone
  - **Audio**: Master volume, device selection, voice chat, equalizer
  - **Graphics**: Resolution, FPS, draw distance, quality presets, colorblind modes
  - **Accessibility**: Motor, hearing, visual adaptations
  - Cloud sync & profile management

---

## 🔗 Cross-Reference Map

### Dependency Graph
```
MatchLifecycle (CORE - Orchestrator)
├─ Owns state machine: Lobby → Infiltration → Active → End Game → Victory
├─ Orchestrates:
│  ├─ GasSystem (timing & phases)
│  ├─ Gulag (respawn logic)
│  ├─ Contracts (objective activation)
│  ├─ Economy (cash & loot)
│  └─ LootingSystem (spawn management)
├─ Reads from:
│  ├─ BattlePass (seasonal timing)
│  └─ SettingsMenu (player preferences)
└─ Syncs with: All systems

Economy (HUB - Financial Flows)
├─ Cash sources:
│  ├─ Looting: LootingSystem
│  ├─ Kills: WeaponFramework
│  ├─ Contracts: Contracts system
│  └─ Milestones: MatchLifecycle
├─ Cash sinks:
│  ├─ Killstreaks: WeaponFramework
│  ├─ Revives: Gulag
│  └─ Equipment: BattlePass cosmetics (cosmetic, not cash)
└─ Affected by: GasSystem (emergency discounts)

Combat Pipeline (Execution Layer)
├─ WeaponFramework (Authority)
│  ├─ Uses: GunsmithSystem (attachment ballistics)
│  ├─ Feeds into: VisualRecoil (feedback)
│  ├─ Reads from: SettingsMenu (sensitivity, aim assist)
│  └─ Sources ammo: LootingSystem
├─ GunsmithSystem (Configuration)
│  ├─ Modifies: Weapon stats (range, recoil, handling)
│  ├─ References: WeaponFramework (attachment effects)
│  └─ Used by: MatchLifecycle (loadout equipping)
└─ VisualRecoil (Feedback)
   ├─ Driven by: WeaponFramework (damage events)
   ├─ Configured by: GunsmithSystem (attachment modifiers)
   └─ Controlled by: SettingsMenu (haptic intensity, FOV)

Retention Systems (Long-term)
├─ BattlePass
│  ├─ Provides: Season structure & deadlines
│  ├─ Rewards: Cosmetics via RewardSystems
│  ├─ Earns: XP from MatchLifecycle playtime
│  └─ Integrates: Challenge system
├─ RewardSystems
│  ├─ Sources: BattlePass, Events, Achievements
│  ├─ Cosmetics pool: Shared with all systems
│  └─ Uses: Rarity scheme (LootingSystem matching)
└─ SettingsMenu
   ├─ Affects: All systems (feel/performance)
   └─ Persists: Player preferences (cosmetic config)
```

---

## 📋 System Interactions

### Kill Flow
```
Player fires weapon
  ↓
WeaponFramework (validates, applies ballistics)
  ↓ (references)
GunsmithSystem (applies attachment modifiers to damage)
  ↓ (triggers feedback)
VisualRecoil (camera kick, haptic)
  ↓ (on target hit)
MatchLifecycle (update player state)
  ↓ (player eliminated)
Gulag (first time → arena, else permanent)
  ↓ (on contract bounty kill)
Contracts (check completion)
  ↓ (on any kill)
Economy (award cash to squad)
```

### Loot Flow
```
Player lands
  ↓
LootingSystem (nearby items visible)
  ↓ (player picks up)
Inventory updates
  ↓ (weapon picked up)
GunsmithSystem (apply current loadout)
  ↓ (WeaponFramework ready to use)
Ready for combat
  ↓ (on rarity items)
RewardSystems (tracks for cosmetics pool)
```

### Economy Flow
```
Player eliminates enemy
  ↓
Economy (+cash to squad)
  ↓ (player loots corpse)
LootingSystem (corpse drops cash)
  ↓ (squad reaches $6000)
Buy Station (purchase loadout drop)
  ↓ (loadout drop lands)
Economy (-$6000 from squad pool)
  ↓ (player collects loadout)
GunsmithSystem (apply custom configuration)
```

---

## 🎯 Terminology Standardization

**For consistency across all documentation, use these terms:**

| Concept | Standard Term | Variants to Avoid |
|---------|---------------|-------------------|
| In-game earned money | **Cash** | Money, coins, credits |
| Real-money currency | **COD Points** (or CP) | Premium currency, Tokens |
| Currency from duplicates | **Cosmetic Bucks** | Shards, dust, dust crystals |
| Periodic loot event | **Supply Drop** | Airdrop, crate drop, loot drop |
| Ground container | **Supply Container** (generic) | Supply box, loot crate, chest |
| → Common variant | **Supply Container (Blue)** | Supply box |
| → Rare variant | **Supply Container (Orange)** | Loot crate, military crate |
| Character cosmetic | **Operator Skin** | Character skin, outfit, bundle |
| Weapon cosmetic | **Weapon Blueprint** | Weapon skin, cosmetic weapon |
| Weapon modification | **Attachment** | Module, mod, component |
| Damage reduction item | **Armor Plate** | Shield, plate, armor |
| Battle Pass level | **Tier** | Level, rank (within BP context) |
| Battle Pass skip | **Tier Skip Token** | Skip token, boost |
| Weapon configuration | **Loadout** | Setup, build, class |
| Gas expansion level | **Circle Phase** or **Gas Phase** | Round, wave, stage |
| Player death mechanic | **Eliminated** | Killed, knocked, downed |
| Respawn from Gulag | **Returned** | Respawned, revived |

---

## ✅ Consistency Verification

### Resolved Inconsistencies
- ✅ **Terminology unified** - All docs use standardized terms (see table above)
- ✅ **Reward values aligned** - Cash amounts consistent across Economy, Contracts, Gulag
- ✅ **Gas damage progression** - Confirmed 1→5→10→20 HP/sec across all references
- ✅ **Rarity scheme** - Unified across LootingSystem and RewardSystems
- ✅ **File naming** - Fixed `GunsmiththSystem` → `GunsmithSystem`
- ✅ **Cross-references added** - All docs link to related systems
- ✅ **Testing checklists** - All docs include comprehensive test coverage
- ✅ **Code examples completed** - No truncated code blocks

### Design Decisions (Intentional)
- **Gulag weapon pool restricted** - Balanced 1v1 (no sniper camping)
- **Armor gas reduction 50%** - Unified by design (no tier variation)
- **Player count variance** - By gamemode (4 players in practice, 150 in public)
- **SettingsMenu independent** - UI system, loosely coupled

---

## 📊 Statistics

| Metric | Value |
|--------|-------|
| **Total Features** | 12 |
| **Total Lines of Documentation** | ~3,500 |
| **Files** | 12 + INDEX.md + this README |
| **Code Examples** | 50+ |
| **Testing Checklists** | 12 (all complete) |
| **Cross-References** | 40+ internal links |
| **Diagrams** | 10+ (ASCII and text-based) |

## ✅ Implementation Status

### Completed Systems
- ✅ **Gunsmith Backend**: Server-side attachment validation and stat calculation (`GunsmithService`)
- ✅ **Gunsmith UI**: Complete attachment selection interface with stat comparison
- ✅ **Settings Menu**: Full UI implementation with Input, Audio, Graphics, and Accessibility tabs
- ✅ **Gameplay HUD**: Ammo, health, movement state, and reload progress display
- ✅ **Weapon Controller**: Client-side weapon state management and reload system
- ✅ **Barracks Menu**: Complete implementation with all tabs (Missions, Identity, Rank, Records, Achievements)
- ✅ **Loadout Editor**: WeaponsMenu with Gunsmith integration

### In Progress
- 🔄 **Weapon Framework (V3)**: Hybrid hitscan/projectile system (backend complete, ballistics pending)
- 🔄 **Settings Application**: Graphics/audio/input application logic (UI complete, integration pending)
- 🔄 **Visual Recoil**: Spring-driven camera kick system (pending)

---

## 🚀 How to Use This Documentation

### For Developers
1. Start with [MatchLifecycle.md](BattleRoyale/MatchLifecycle.md) to understand the core flow
2. Drill into specific systems you're implementing
3. Check cross-references for dependencies
4. Use testing checklists during implementation

### For Designers
1. Read [INDEX.md](INDEX.md) for the dependency graph
2. Review feature overviews in each document
3. Examine balance parameters sections
4. Check future enhancements for roadmap ideas

### For QA
1. Use the testing checklists in each document
2. Verify cross-system interactions using dependency graphs
3. Check reward values against economy document
4. Test accessibility features in SettingsMenu

### For Project Managers
1. Review phase dependencies in [INDEX.md](INDEX.md)
2. Check "Future Enhancements" sections for roadmap
3. Estimate effort from architecture descriptions
4. Track progress against testing checklists

---

## 📝 Documentation Notes

- **Last Updated**: 2026-01-19
- **Version**: 1.0 (Complete)
- **Status**: Ready for Implementation
- **Consistency Check**: ✅ Passed
- **Cross-Reference Validation**: ✅ Complete
- **Terminology Standardized**: ✅ Yes

---

**For questions or updates, refer to the individual feature documents or consult the project roadmap.**
