# Roblox Warzone MW 2019 Recreation

A high-fidelity recreation of the **Modern Warfare 2019 / Warzone** experience within the Roblox engine. This project focuses on delivering "AAA-feel" movement, tight gunplay, and a modular architecture that pushes the boundaries of the platform.

---

## 🎯 The Vision
To bring the iconic, snappy, and weighty feel of *Call of Duty: Modern Warfare (2019)* to Roblox. This isn't just a clone; it's a technical demonstration of how modular systems, physics-driven procedural animation, and hybrid control architectures can elevate Roblox gameplay.

### Core Pillars
- **⚡ Snappy Responsiveness**: Immediate feedback to player intent. If it feels delayed, it's wrong.
- **🧠 Intelligent Systems**: Cameras and NPCs that behave with "intent" rather than just reacting to physics.
- **🎨 Visual Fidelity**: Warzone-style UI, procedural weapon sway, and fluid animation blending.
- **⚖️ Competitive Integrity**: Client-side prediction with strict server-side validation.

---

## 🏗️ System Architecture
The project is built on a "State-Driven" philosophy where logic is separated into distinct layers:

1. **Input Manager**: Normalizes `ContextActionService` and `UserInputService` into intent signals.
2. **State Machine**: The "Brain" that determines the character's status (Sprinting, Sliding, ADS, etc.) and syncs via **Instance Attributes**.
3. **Movement Controller**: Translates states into physical forces and `Humanoid` properties, utilizing `RunService.PreSimulation` for stability.
4. **Animation Manager**: Handles track playback and blending based on state changes.
5. **Procedural Animator**: Adds "juice" through springs for sway, tilt, and bobbing.

---

## 🎥 Featured Technology: Hybrid Drone Camera
*Refactored & Stabilized (Jan 2026)*

We have implemented a **Three-Layer Hybrid Architecture** for the menu/spectator camera, moving beyond simple interpolation to create a "cinematic operator" feel.

| Layer | Responsibility | Description |
| :--- | :--- | :--- |
| **1. Intent (AI)** | "What to do" | Decides on semantic framing, orbit angles, and cinematic sways. Evaluates "Framing Quality" to pick the best angles. |
| **2. Motion Plan** | "How to move" | Handles predictive filtering (velocity extrapolation), constraint satisfaction (roof/wall avoidance), and authority weighting. **Strictly separated** from semantic decisions. |
| **3. Physical Body** | "How to fly" | Pure physics simulation (Mass, Drag, Thrust) with gimbal stabilization and a **Fixed-Timestep Accumulator** for frame-rate independence. |

**Key Improvements:**
- **Fixed-Timestep Physics**: The physics layer now runs on a stable 120Hz accumulator, eliminating instability at varying frame rates.
- **Semantic Framing**: Framing quality logic extracted to a dedicated `FramingUtils` module.
- **Dampened Response**: Tuned rotation and sway parameters for a more stable, less aggressive cinematic feel.

---

## 🚀 Current Progress

### Phase 1: Foundation (COMPLETED)
- [x] **Robust Framework**: Rojo-managed, modular Service/Controller architecture with safe initialization.
- [x] **State Machine**: Attribute-based synchronization for all character states.
- [x] **Networking**: Lightweight `Network.luau` wrapper for remote events.
- [x] **Data Persistence**: `DataService` and `LoadoutService` for saving player progress and classes.

### Phase 2: Combat & Fluidity (COMPLETED)
- [x] **Advanced Movement**:
    - **Tactical Sprint**: Double-tap mechanics with "weapon up" state.
    - **Slide Canceling**: Momentum-based sliding with friction decay and interrupt logic.
    - **Procedural Sway**: Spring-based weapon sway and camera tilt.
- [x] **ADS System**: Dynamic FOV scaling and movement speed modification.
- [x] **Intelligent Camera**: The "Stalker Drone" system described above.
- [x] **Matchmaking**: Scalable lobby system and queue logic.

### Phase 3: Code Health & Polish (COMPLETED)
- [x] **Linting & Standards**: Enforced `Selene` standards across the codebase (deprecated APIs fixed, variable shadowing resolved).
- [x] **Toolchain**: Integrated `Aftman` for tool management (`Selene`, `Rojo`, `Stylua`).
- [x] **Stability**: Fixed logical redundancies in UI managers and improved error handling in character controllers.
- [x] **Documentation System**: 11 README files, 71+ markdown files, comprehensive cross-reference system.

### Phase 4: Platform Documentation (COMPLETED - Jan 2026)
- [x] **Roblox Reference Guides**: 9 comprehensive guides covering Luau, Services, Networking, Physics, UI, and Performance
- [x] **RobloxDocs Organization**: Master index, topic-based navigation, integration with project documentation
- [x] **Code Examples**: 100+ practical code samples for all major Roblox systems
- [x] **Warzone-Specific Patterns**: Optimized networking, physics, UI, and performance guidance tailored to the project

### Phase 5: Gunsmith & Arsenal (IN PROGRESS)
- [x] **Gunsmith Backend**: Server-side attachment validation and stat calculation system.
- [x] **Gunsmith UI**: Complete attachment selection interface with real-time stat comparison.
- [x] **Weapon Controller**: Client-side weapon handling (ammo, reloading, state management).
- [x] **Attachment Integration**: Full integration with WeaponService for applying attachments.
- [ ] **Weapon Framework (V3)**: Hybrid hitscan/projectile system with penetration (pending).
- [ ] **Weapon Leveling**: XP progression and unlock tracks (pending).
- [ ] **Visual Recoil**: Spring-driven camera kick and weapon feedback (pending).

---

## � Documentation Organization

All documentation is organized into logical folders for easy navigation:
**Quick Stats:**
- 🎮 **71+ markdown files** across 8 organized folders
- 📖 **40,000+ lines** of documentation and code examples
- ✅ **11 README files** with consistent naming and structure
- 🔗 **100+ cross-references** linking features, components, and design docs
- 🌐 **9 Roblox reference guides** covering development from basics to optimization
### 🎮 **[Features/](Features/)** - Complete Feature Documentation (MAIN REFERENCE)
Comprehensive design documentation for all 12 gameplay features:
- **[Combat/](Features/Combat/)** - Weapon systems & gunplay (WeaponFramework, GunsmithSystem, VisualRecoil)
- **[BattleRoyale/](Features/BattleRoyale/)** - Core BR mechanics (MatchLifecycle, GasSystem, Gulag, Contracts, Economy, LootingSystem)
- **[Progression/](Features/Progression/)** - Player retention (BattlePass, RewardSystems)
- **[Systems/](Features/Systems/)** - UI & settings (SettingsMenu)
- **Features/README.md** - Overview of all game features, including Battle Royale and Combat systems.
- **[Features/INDEX.md](Features/INDEX.md)** - Cross-references & dependency graph

### 🔧 **[Components/](Components/)** - Individual System Components
Technical documentation for specific game components:
- CameraController - Drone camera system architecture
- StateMachine - Character state management
- InputManager - Input normalization
- MovementController - Physics-driven locomotion
- ProceduralAnimator - Animation & effects
- MenuController - UI logic
- Gunsmith - Weapon customization

### 📋 **[Design/](Design/)** - High-Level Design Documents
System-level design specifications:
- Contracts - Mission objectives & rewards
- Economy & Loot - Cash system & item distribution
- GameLoop - Match flow & state progression
- Rewards & BattlePass - Seasonal progression
- Settings - Player customization

### 🎨 **[Assets/](Assets/)** - Game Content & Cosmetics
Asset inventory and cosmetic documentation:
- Weapons - All weapons & configurations
- Operators - Character cosmetics
- Equipment - Tactical & lethal items
- Killstreaks - Streak rewards
- Ranks - Player progression tiers
- Gamepasses - Cosmetic purchases

### 📖 **[Guides/](Guides/)** - Implementation & Tuning Guides
Practical guides and troubleshooting:
- Drone Tuning Guide - Camera system parameter tuning
- Drone System - System overview
- Error Handling - Common issues & solutions
- Armsdealer - Weapon dealer system

### 📦 **[Archive/](Archive/)** - Legacy Documentation
Superseded and legacy documentation (reference only):
- Old Feature_*.md files (replaced by Features/)
- Legacy system designs
- Deprecated documentation

### 🌐 **[RobloxDocs/](RobloxDocs/)** - Roblox Platform Reference (COMPLETE)
Comprehensive Roblox development guides and API documentation:
- **[RobloxDocs/README.md](RobloxDocs/README.md)** - Roblox documentation hub & quick start
- **[RobloxDocs/INDEX.md](RobloxDocs/INDEX.md)** - Master index with navigation & integration
- **[Luau_Language.md](RobloxDocs/Luau_Language.md)** - Luau scripting fundamentals & type system
- **[EngineReference.md](RobloxDocs/EngineReference.md)** - Core Roblox Engine API (638 classes)
- **[Services_Reference.md](RobloxDocs/Services_Reference.md)** - Built-in services (Players, RunService, DataStore, UI, etc.)
- **[Networking_Guide.md](RobloxDocs/Networking_Guide.md)** - Client-server communication patterns & optimization
- **[Physics_Constraints.md](RobloxDocs/Physics_Constraints.md)** - Physics simulation, constraints, raycasting
- **[UI_Systems.md](RobloxDocs/UI_Systems.md)** - GUI creation, layouts, animations, Warzone HUD patterns
- **[Performance_Guide.md](RobloxDocs/Performance_Guide.md)** - Optimization techniques & Warzone-specific patterns

---

## 📂 Code Project Structure
```text
src/
├── character/        # Movement, FSM, and Procedural Animation
├── client/
│   ├── Controllers/  # Camera, Interface, Input, Weapon, and Loot logic
│   │   ├── WeaponController.luau  # Weapon state, ammo, reloading
│   │   └── ...
│   ├── UI/           # View components and HUD systems
│   │   ├── GameplayHUD.luau       # In-game HUD (ammo, health, reload)
│   │   ├── GunsmithUI.luau        # Attachment selection interface
│   │   └── Views/                 # Menu views (Home, Loadout, Barracks, Settings)
│   ├── Settings/     # Settings management and persistence
│   └── ...
├── server/
│   ├── Services/     # Data, Player, Matchmaking, Loadout, and Gunsmith services
│   │   ├── GunsmithService.luau   # Attachment validation & stat calculation
│   │   └── ...
│   └── ...
├── shared/           # Network framework, Types, Constants, and Utils
│   ├── Settings/     # Settings data structures
│   └── ...
└── workspace/        # Map and environment configurations
```

---

## 🛠️ Technical Highlights
- **Attribute-Based Sync**: Using Roblox Attributes as a decoupled "Value Object" for state synchronization.
- **Spring Physics**: Utilizing custom `Spring` modules for smooth, organic camera and weapon motion.
- **Defensive Design**: Using `pcall` and `task.spawn` for a robust initialization sequence that prevents "infinite-yield" hangs.
- **Hybrid Control Loops**: Combining kinematic planning with dynamic physics for the camera system.

---
*Developed with a focus on performance and extensibility.*
Generated by [Rojo](https://github.com/rojo-rbx/rojo) 7.5.1.

## Getting Started
To build the place from scratch, use:

```bash
rojo build -o "Projects.rbxlx"
```

Next, open `Projects.rbxlx` in Roblox Studio and start the Rojo server:

```bash
rojo serve
```

For more help, check out [the Rojo documentation](https://rojo.space/docs).
