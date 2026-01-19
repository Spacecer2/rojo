# System Design: Economy & Loot

This document outlines the in-match economy (Cash) and the item distribution system.

## 💰 Economy (Cash)

Cash is a session-persistent currency found in the world or earned from contracts. It is lost upon death.

### Sources
- **Ground Loot**: Stacks of $100, $500, $2000 (legendary).
- **Loot Crates**: Varying amounts based on crate tier.
- **Contracts**: Large payouts for completion ($2000 - $6000).
- **Looting Enemies**: Dropped players drop a percentage of their cash (30-50%).

### Uses (Buy Stations)
Buy Stations are interactable kiosks scattered across the map.

| Item | Cost | Description |
| :--- | :--- | :--- |
| **Armor Plate Bundle** | $1,500 | Restores 5 armor plates. |
| **Gas Mask** | $3,000 | Protection against the circle. |
| **Cluster Strike** | $3,000 | Killstreak. |
| **Precision Airstrike** | $3,500 | Killstreak. |
| **UAV** | $4,000 | Reveals enemies nearby. |
| **Self-Revive Kit** | $4,000 | Allow reviving self when downed. |
| **Loadout Drop Marker** | $10,000 | Calls in a custom loadout crate. |
| **Squad Buyback** | $4,500 | Redeploy a dead teammate. |

---

## 📦 Looting System

Items spawn dynamically at the start of the match using a "Loot Table" system.

### Containers
1.  **Ground Loot**: Visible 3D models of guns/ammo on floors.
    - *Hover UI*: Shows name, rarity color, and stats comparison.
2.  **Supply Box (Blue)**:
    - Contains: Ammo, Cash, 1 Weapon (Common/Rare), 1 Equipment.
    - Sound: Hum sound when nearby.
3.  **Legendary Supply Box (Orange)**:
    - Contains: High Cash, 1 Weapon (Epic/Legendary), Killstreak or Field Upgrade.
    - Rarity: Rare spawn.

### Rarity Tiers
Color-coded tiers indicating attachment count on weapons.

- **Common (White)**: Base weapon, no attachments.
- **Uncommon (Green)**: 1 Attachment.
- **Rare (Blue)**: 3 Attachments.
- **Epic (Purple)**: 4 Attachments.
- **Legendary (Orange)**: 5 Attachments (Blueprint variant).
- **Custom (Red)**: Player's Loadout weapon.

### Inventory Management
- **Backpack System**:
    - **Ammo**: Dedicated pool (AR, SMG, Sniper, Shotgun, Rocket). Max caps apply.
    - **Plates**: Max 3 equipped + 5 in reserve.
    - **Killstreak**: 1 Slot (holding a second replaces the first).
    - **Field Upgrade**: 1 Slot (Dead Silence, Trophy System, etc.).
    - **Gas Mask**: 1 Slot (auto-equip).

---

## 🛠️ Technical Architecture

### `LootService`
- **Spatial Hashing**: Loot is registered in a spatial grid to only replicate items near players (Optimization).
- **Interaction**: Server validates distance and line-of-sight for pickup requests.
- **Generation**: Seeded RNG based on match ID so loot is deterministic for debugging but random for players.

### `EconomyService`
- Tracks cash per player.
- Handles atomic transactions (Buy Station purchases).
- Manages death drops (calculating how much cash drops vs disappears).
