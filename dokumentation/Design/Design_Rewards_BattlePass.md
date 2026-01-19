# System Design: Battle Pass & Lottery (Supply Drops)

This document outlines the design for the player retention and monetization systems: the Seasonal Battle Pass and the "Supply Drop" Lottery system.

## 🎯 Core Philosophy
- **Fairness First**: No pay-to-win. All functional weapons are available via free paths or challenges.
- **Visual Prestige**: Rewards focus on cosmetics (skins, blueprints, operators, finishing moves).
- **Engagement Loop**: Daily login -> Match XP -> Battle Pass Tier -> Currency -> Supply Drop.

---

## 🎟️ Battle Pass System (The "Operation Pass")

A 100-Tier seasonal progression track.

### Structure
- **Seasons**: Lasts ~60 days.
- **Tiers**: 100 Tiers per season.
- **Tracks**:
    - **Free Track**: Available to everyone. Contains base weapons, basic camos, and some currency.
    - **Premium Track (Operator Pass)**: Requires purchase (e.g., 1000 CP). Contains Operator skins, Blueprints, XP Tokens, and high-value currency.

### Progression Logic
- **Battle Pass XP (BPXP)** is earned alongside Rank XP but at a fixed rate based on *Time Played* + *Match Performance*.
- **Tier Skip**: Players can purchase individual Tier Skips.

### Reward Types
1.  **Base Weapons**: Always Free (usually Tiers 15 and 30).
2.  **Blueprints**: Weapons with pre-equipped attachments and unique skins.
3.  **Operator Skins**: Thematic outfits.
4.  **COD Points (CP)**: Premium pass refunds enough CP to buy the next pass if completed.
5.  **XP Tokens**: Boosters for Rank/Weapon XP.
6.  **Cosmetics**: Emblems, Calling Cards, Charms, Watches.

### UI Layout (The Map)
Instead of a linear scroll, we use a **Sector Map** (like MW2/MW3).
- **Sectors**: The pass is divided into 20 Sectors (A0 to A20).
- **Unlock Tokens**: Leveling up grants a "Battle Token".
- **Choice**: Players spend tokens to unlock adjacent sectors, choosing their path to specific rewards.

---

## 📦 Lottery System ("Supply Drops")

A randomized reward system for acquiring legacy cosmetics and rare items not in the current Battle Pass.

### Crate Types
1.  **Standard Drop** (Purchasable with soft currency / earned via gameplay)
    - Odds: Common (60%), Rare (35%), Epic (5%).
2.  **Elite Drop** (Purchasable with premium currency / rare rewards)
    - Odds: Rare (50%), Epic (40%), Legendary (10%).

### Drop Pools
- **Blueprints**: Custom weapon variants.
- **Operator Skins**: Legacy skins from past seasons.
- **Charms & Stickers**: Weapon accessories.
- **Currency Packs**: Small amounts of CP or Credits.

### Mechanics
- **Pity System**:
    - **Epic Pity**: Guaranteed Epic item every 10 crates if none received.
    - **Legendary Pity**: Guaranteed Legendary every 30 Elite crates.
- **Duplicate Protection**:
    - If a duplicate is rolled, it is automatically converted into **Scrap** (a tertiary currency used to craft specific items).

### Opening Animation
- **3D World Interaction**: A crate is dropped from a drone onto the lobby floor.
- **Physics**: The crate lands with impact, dust kicks up.
- **Reveal**: The lid pops open, rarity colors glow (Blue, Purple, Gold), and items float up.

---

## 💰 Economy Integration

| Currency | Source | Use |
| :--- | :--- | :--- |
| **Credits (Soft)** | Match Rewards, Daily Challenges | Buy Standard Drops, Base Skins. |
| **COD Points (Hard)** | Robux, Battle Pass | Buy Battle Pass, Elite Drops, Bundles. |
| **Scrap** | Duplicates, Dismantling | Craft specific items (Bad Luck Protection). |

---

## 🛠️ Technical Implementation Plan

### Data Structure
```lua
type Reward = {
    Type: "Weapon" | "Skin" | "Currency",
    Id: string,
    Amount: number?,
    Rarity: string
}

type BattlePassSector = {
    Id: string, -- e.g., "A1"
    Rewards: {Reward}, -- 5 items per sector
    Connections: {string}, -- IDs of adjacent sectors
    IsUnlocked: boolean
}
```

### Services Needed
- **`BattlePassService`**: Handles XP tracking, token spending, and sector unlocking logic.
- **`MarketplaceService`**: Handles crate purchases and opening logic (RNG generation on server).
- **`InventoryService`**: Manages ownership of items and duplicate detection.

### Anti-Exploit
- All RNG happens on the server.
- Drop results are validated before being sent to the client.
- Purchase receipts are logged.
