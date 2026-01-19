# Component: Gunsmith System (Vision)

The **Gunsmith System** is the crown jewel of the Warzone experience. It allows for deep customization of weapons, affecting both visuals and performance.

## 🛠️ Planned Architecture
- **Location**: `src/shared/Weapons/` and `src/client/Interface/Weapons/`
- **Data-Driven**: Every weapon is a collection of "Attachment Points" (Muzzle, Barrel, Optic, Stock, Underbarrel).

## ⚙️ Mechanics
- **Weight vs. Speed**: Attachments like "Heavy Barrels" increase recoil control but decrease ADS speed and movement speed.
- **Visual Swapping**: Using `Instance:Clone()` to hot-swap models on the weapon base in real-time within the menu.
- **Attribute Modifiers**: Each attachment will add/subtract values from the weapon's base attributes (Recoil, Range, Mobility).

## 🚀 Warzone-Specific Logic
- **Blueprint System**: Support for "Blueprints" which are pre-configured attachment sets with unique skins.
- **Real-time Stats**: A radar chart or bar graph in the UI that updates live as the player toggles attachments.

---
*Building a modular foundation for endless weapon variety.*
