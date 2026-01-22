# 🎯 Battle Royale Mechanics

Core battle royale loop, survival, and progression systems.

## 📄 Features

| Feature | Description |
|---------|-------------|
| [MatchLifecycle.md](MatchLifecycle.md) | Match state orchestration from lobby to victory |
| [GasSystem.md](GasSystem.md) | Circular hazard with escalating damage and pacing |
| [Gulag.md](Gulag.md) | Second-chance 1v1 arena system |
| [LootingSystem.md](LootingSystem.md) | Ground loot, supply drops, and item distribution |
| [Contracts.md](Contracts.md) | Secondary objectives (Bounty, Recon, Scavenger) |
| [Economy.md](Economy.md) | In-game cash system and buy stations |

## 🎮 Overview

Battle Royale in our game is a high-stakes, large-scale fight for survival. The core gameplay loop is designed to be intense and dynamic:

- **Infiltration:** Each match begins with all squads dropping from a plane onto the map. The initial moments are a frantic scramble for weapons and resources.
- **Looting & Contracts:** Players must explore the environment to find better weapons, armor plates, and other equipment. Completing contracts provides cash and other advantages.
- **The Gulag:** Upon their first elimination, players are sent to the Gulag for a 1v1 fight to earn a second chance and redeploy.
- **The Gas & Final Circle:** A deadly gas cloud continuously shrinks the playable area, forcing intense encounters as squads are pushed closer together, culminating in a final showdown.
- **Economy:** Cash earned through looting and contracts can be spent at Buy Stations to purchase powerful items like killstreaks, loadout drops, and teammate redeployments.

This loop ensures that every match is a unique and unpredictable experience.

## 🔗 Related Documentation

- [Features/INDEX.md](../INDEX.md) - Cross-references and dependency graph
- [Features/README.md](../README.md) - All features overview
- [Combat/](../Combat/) - Weapon systems used in BR
- [Progression/](../Progression/) - Cosmetic rewards from BR wins
- [Design/Design_GameLoop.md](../../Design/Design_GameLoop.md) - Design specifications

---

**Start with [MatchLifecycle.md](MatchLifecycle.md) to understand the match flow.**
