# Cross-Reference Index

Quick-reference guide for feature dependencies, interactions, and terminology standards.

**Navigation:** [Main README](README.md) | [Dependencies](#dependencies) | [Interactions](#interactions) | [Terminology](#terminology)

---

## Dependencies

### Core Orchestrators
**MatchLifecycle** - Master state machine (highest dependency priority)
- **Owns**: Match flow state (Lobby → Active → Victory)
- **Controls**: Timer phases, player spawning, elimination handling
- **Depends on**:
  - [GasSystem](BattleRoyale/GasSystem.md) (respects circle phases)
  - [Gulag](BattleRoyale/Gulag.md) (respawn decisions)
  - [Contracts](BattleRoyale/Contracts.md) (activation timing)
  - [LootingSystem](BattleRoyale/LootingSystem.md) (spawn waves)
  - [BattlePass](Progression/BattlePass.md) (season timing)

### Money/Resources Hub
**Economy** - Cash management
- **Sources**: Kills ([WeaponFramework](Combat/WeaponFramework.md)), Looting ([LootingSystem](BattleRoyale/LootingSystem.md)), [Contracts](BattleRoyale/Contracts.md), [MatchLifecycle](BattleRoyale/MatchLifecycle.md)
- **Sinks**: Killstreaks ([WeaponFramework](Combat/WeaponFramework.md)), Revives ([Gulag](BattleRoyale/Gulag.md)), Cosmetics ([SettingsMenu](Systems/SettingsMenu.md))
- **Affected by**: [GasSystem](BattleRoyale/GasSystem.md) (emergency discounts), [MatchLifecycle](BattleRoyale/MatchLifecycle.md) (round timing)

### Combat Pipeline
**[WeaponFramework](Combat/WeaponFramework.md)** (Authority) → **[GunsmithSystem](Combat/GunsmithSystem.md)** (Config) → **[VisualRecoil](Combat/VisualRecoil.md)** (Feedback)
- **WeaponFramework** reads: [GunsmithSystem](Combat/GunsmithSystem.md) (attachment modifiers), [SettingsMenu](Systems/SettingsMenu.md) (sensitivity)
- **GunsmithSystem** modifies: Weapon stats (range, recoil, handling per attachment)
- **VisualRecoil** driven by: [WeaponFramework](Combat/WeaponFramework.md) (events), [GunsmithSystem](Combat/GunsmithSystem.md) (modifiers), [SettingsMenu](Systems/SettingsMenu.md) (haptic)

### Hazard Systems
**[GasSystem](BattleRoyale/GasSystem.md)** - Circle mechanics
- **Driven by**: [MatchLifecycle](BattleRoyale/MatchLifecycle.md) (phase timing)
- **Affects**: Player damage, movement urgency, [Contracts](BattleRoyale/Contracts.md) completion (zone reveals)
- **Related to**: [Gulag](BattleRoyale/Gulag.md) (safe zone guaranteed), [LootingSystem](BattleRoyale/LootingSystem.md) (container vulnerability)

**[Gulag](BattleRoyale/Gulag.md)** - Respawn arena
- **Gated by**: First elimination only (checked by [MatchLifecycle](BattleRoyale/MatchLifecycle.md))
- **Interacts with**: [Economy](BattleRoyale/Economy.md) (revive costs), [LootingSystem](BattleRoyale/LootingSystem.md) (weapon sourcing)
- **Returns to**: [MatchLifecycle](BattleRoyale/MatchLifecycle.md) with respawn decision

### Item Distribution
**[LootingSystem](BattleRoyale/LootingSystem.md)** (Ground loot) + **[RewardSystems](Progression/RewardSystems.md)** (Cosmetics)
- **LootingSystem** spawned by: [MatchLifecycle](BattleRoyale/MatchLifecycle.md) (timing), [GasSystem](BattleRoyale/GasSystem.md) (zone removal)
- **LootingSystem** uses: Rarity scheme (matching [RewardSystems](Progression/RewardSystems.md))
- **RewardSystems** sources: [BattlePass](Progression/BattlePass.md) (seasonal), Events, Achievements
- **Both** reference: [Economy](BattleRoyale/Economy.md) (value assignments)

### Long-term Engagement
**[BattlePass](Progression/BattlePass.md)** → **[RewardSystems](Progression/RewardSystems.md)** → **[SettingsMenu](Systems/SettingsMenu.md)**
- **BattlePass** tracks: Player progression, challenge completion
- **RewardSystems** rewards: Cosmetics via cosmetic currency / COD Points
- **SettingsMenu** manages: Cosmetic equipping, visual customization

---

## Interactions

### Scenario: Player Earns Killstreak ($3000)

```
Player confirms purchase at Buy Station
  ↓
Economy: Squad cash -$3000 (checked against squad pool)
  ↓
MatchLifecycle: Award UAV to squad (sends loadout drop)
  ↓
LootingSystem: Spawn supply container at location
  ↓
Player collects supply drop
  ↓
WeaponFramework: UAV becomes active
  ↓
VisualRecoil: UAV recoil patterns apply
```

**Related docs:** [Economy](BattleRoyale/Economy.md), [LootingSystem](BattleRoyale/LootingSystem.md), [WeaponFramework](Combat/WeaponFramework.md)

### Scenario: Player Contracts Bounty Hunt

```
Contracts system: Activate bounty on squad (~$300-$500 range)
  ↓
MatchLifecycle: Notify all squads of bounty
  ↓
Hunters eliminate target squad
  ↓
Economy: Award cash to hunters
  ↓
Bounty objective complete
  ↓
BattlePass: Award XP to participants
```

**Related docs:** [Contracts](BattleRoyale/Contracts.md), [Economy](BattleRoyale/Economy.md), [BattlePass](Progression/BattlePass.md)

### Scenario: Player Downed, Enters Gulag

```
Player eliminated (health ≤ 0)
  ↓
MatchLifecycle: Check elimination count (first only)
  ↓
Gulag: Port to arena with random weapon
  ↓
LootingSystem: Provide weapon pool (restricted, balanced)
  ↓
Player wins/loses duel
  ↓
Gulag: Return winner to squad respawn OR eliminate
  ↓
MatchLifecycle: Update player state
```

**Related docs:** [Gulag](BattleRoyale/Gulag.md), [LootingSystem](BattleRoyale/LootingSystem.md), [MatchLifecycle](BattleRoyale/MatchLifecycle.md)

### Scenario: Gas Closing (Circle Phase Escalation)

```
MatchLifecycle: Timer triggers new gas phase
  ↓
GasSystem: Damage escalation (1→5→10→20 HP/sec)
  ↓
GasSystem: Visual distortion increases
  ↓
Contracts: Zone-based objectives may auto-complete
  ↓
LootingSystem: Remove containers from old zone
  ↓
Players forced toward new safe zone
```

**Related docs:** [GasSystem](BattleRoyale/GasSystem.md), [MatchLifecycle](BattleRoyale/MatchLifecycle.md), [Contracts](BattleRoyale/Contracts.md)

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
