# Project Roadmap: Roblox Warzone MW 2019 Recreation

This document outlines the complete development lifecycle for the project, aimed at delivering a AAA-grade Warzone experience on Roblox.

---

## 🏗️ Phase 1: Foundational Infrastructure (COMPLETED)
*Goal: Build a scalable, high-performance base.*
- [x] **Dev Environment**: Rojo, Git, and automated Luau linting.
- [x] **Networking**: Custom middleware for safe, efficient Remote communication.
- [x] **Data Architecture**: Secure `DataStore` patterns for player profiles and persistence.
- [x] **System Hub**: Modular controller/service architecture for decoupled logic.

---

## 🏃 Phase 2: Advanced Movement & Character (COMPLETED)
*Goal: Perfect the "MW 2019 Feel" (Heavy but Fluid).*
- [x] **State Machine**: Attribute-based sync for Idle, Walk, Sprint, ADS, and Air states.
- [x] **ADS Mechanics**: Responsive FOV scaling and sensitivity dampening.
- [x] **Tactical Sprint**: "Weapon-up" high-speed sprint with stamina and "Double-Tap" activation.
- [x] **Slide Mechanics**: Momentum-based sliding with friction decay and "Slide Cancel" logic.
- [x] **Stance Controls**: Fully integrated Crouch and Prone systems.
- [x] **Procedural Juice**: Physics-based head-bob, movement tilt, and weapon sway.

---

## 💎 Phase 3: Code Health & Architecture (COMPLETED)
*Goal: Ensure long-term maintainability and stability.*
- [x] **Toolchain Integration**: Aftman (Rojo, Selene, Stylua) for standardized dev tools.
- [x] **Static Analysis**: Enforced strict linting (Selene) to remove shadowing, deprecated APIs, and global pollution.
- [x] **Camera Refactor**: Implemented "Three-Layer Hybrid" architecture (Intent/Plan/Physics) with fixed-timestep accumulation.
- [x] **Performance**: Optimized physics loops using `RunService.PreSimulation`.

---

## 🔫 Phase 4: The Arsenal (Combat & Gunplay) (COMPLETED)
*Goal: Realistic ballistics and deep customization.*
- [x] **Weapon Framework (V3)**:
    - [x] Hybrid Hitscan/Projectile system (Bullet travel & drop).
    - [x] Wall penetration and material-based damage falloff.
    - [x] Real-time projectile visualization (Tracers).
- [x] **Gunsmith Backend**:
    - [x] Attachment Data Structure (Muzzle, Barrel, Optic, etc.).
    - [x] Real-time stat modification logic (Mobility, Recoil, Range).
    - [x] Weapon attachment welding and visual assembly logic.
- [x] **Loadout UI**:
    - [x] "WeaponsMenu" with slot selection and stats visualization.
    - [x] "Gunsmith UI" for visual attachment customization.
    - [x] "Squad Preview" in 3D Lobby.
- [x] **Visual Recoil**:
    - [x] Spring-driven camera kick and weapon vibration.
    - [x] Viewmodel sway and bobbing integration.
    - [x] Dynamic weapon model swapping and viewmodel support.

---

## 🚁 Phase 5: The Playable Loop & World (IN PROGRESS)
*Goal: Create a functioning, winnable Battle Royale match loop.*

- [x] **Match Lifecycle**:
    - [x] Service Coordinator (`MatchService`) for Warmup -> Infil -> Match -> End.
    - [x] Warmup & Infiltration logic (Teleportation).
    - [x] Win Condition checks (Last Team Standing).
- [x] **The Gas**: Circular hazard system with visual distortion and health drain.
- [x] **Economy & Loot**:
    - [x] Cash spawning and looting.
    - [x] Buy Stations (UI/Logic).
    - [x] Supply Boxes (Blue/Orange) and Rarity tiers.
- [~] **The Gulag**:
    - [x] 1v1 Arena Management & Matchmaking.
    - [x] Win/Loss Logic & Respawn.
    - [ ] "Capture Flag" Overtime Mechanic.
    - [ ] **Integration**: Hook into MatchService death flow (Currently TODO).
- [ ] **Map Development**:
    - [ ] Greybox Layout (POIs, Cover).
    - [ ] Verticality & Traversal testing.

---

## 🖥️ Phase 6: Core User Experience (IN PROGRESS)
*Goal: AAA-standard interface, settings, and feedback.*

- [x] **Player HUD**:
    - [x] Architecture (Three-Layer System).
    - [x] Basic implementation (Ammo, Health, State).
    - [ ] **Advanced Features**: Compass Tape, Hitmarkers, Minimap.
- [x] **Settings System**:
    - [x] Backend Data Structure (`SettingsData`).
    - [x] Client Controller (`SettingsController`) for application.
    - [x] **Settings Menu UI**: Tabbed interface (General, Graphics, Audio).
- [ ] **Audio Occlusion**: Advanced sound propagation through walls and materials.

---

## 📦 Phase 7: Meta & Content (PENDING)
*Goal: Player retention, progression, and variety.*

- [ ] **Contracts**:
    - [ ] Bounty (Kill Target).
    - [ ] Recon (Secure Area).
    - [ ] Scavenger (Loot Crates).
- [ ] **Battle Pass**: 100-Tier "Sector Map" progression system.
- [ ] **Global Progression**: Weapon XP, Player Levels, and Camo Challenges.
- [ ] **Reward Systems**: "Supply Drop" lottery with pity mechanics.

---

## 🌍 Phase 8: Social & Optimization (PENDING)
*Goal: Scale to 100+ players and community features.*

- [ ] **Social Systems**: In-game clans, global leaderboards, and party management.
- [ ] **Optimization**:
    - [ ] LOD / Streaming Enabled.
    - [ ] Network Replication Budgeting.
    - [ ] Memory Management.

---

## 💡 Guiding Principles
1. **Fidelity Over Speed**: Do it right the first time; use physics over hacks.
2. **Predictable Gameplay**: The player should never fight the controls.
3. **Warzone DNA**: Every sound, animation, and UI element must feel authentic to MW 2019.

---
*Updated: 20.01.2026*