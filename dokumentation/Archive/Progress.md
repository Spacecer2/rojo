# Project Progress

## Overview
Tracking the implementation of the Advanced Movement System and Foundational Infrastructure.

## Roadmap

### Phase 1 – Foundation
- [x] **Project Setup**: Rojo configured, folder structure created.
- [x] **Folder Structure**: `StarterCharacterScripts` mapped to `src/character`.
- [x] **Custom Input Controller**: `InputManager.luau` implemented with ContextActionService for desktop + controller support.
- [x] **Movement State Machine**: `StateMachine.luau` implemented with attribute-based sync (includes CrouchWalk state).
- [x] **Movement Controller**: `MovementController.client.luau` implemented with PreSimulation updates, smooth speed interpolation, and FOV transitions.
- [x] **Animation Controller**: `AnimationController.client.luau` implemented with layered animation system (Base/Action/Override priorities) and attribute sync.
- [x] **Procedural Animator**: `ProceduralAnimator.client.luau` using PreRender for visual updates.
- [x] **Foundational Layers**:
    - [x] **Database Service**: `DataService.luau` with DataStore integration.
    - [x] **User Handling**: `PlayerService.luau` for join/leave logic.
    - [x] **Player Data**: `PlayerData.luau` shared template.
    - [x] **Network Framework**: `Network.luau` for easy Remote communication.
    - [x] **Leaderboard**: `LeaderboardService.luau` for visible player stats.
    - [x] **Robust Initialization**: Controllers now use `task.spawn` and `pcall` to ensure the game starts even if one service is slow.
    - [x] **Main Menu Integration**: Menu now locks movement and appears correctly on join.
    - [x] **UI Framework**: `ViewManager` and modular Views (Home, Loadout) - *Note: Files referenced but may need verification*
    - [x] **Matchmaking Service**: `MatchmakingService.luau` with scalable lobby system.
    - [x] **Loadout Service**: `LoadoutService.luau` for server-side weapon loadout persistence.
    - [x] **Signal & Spring**: `Signal.luau` and `Spring.luau` in `src/shared/Utils` for scalable communication and physics.

## Phase 2 – Combat & Fluidity (COMPLETED)
- [x] **ADS Scaling**: Implemented dynamic FOV zoom and movement speed multipliers with smooth interpolation.
- [x] **Landing Stun**: Added "heavy land" logic for high falls.
- [x] **Crouch System**: Basic toggle implemented with CrouchWalk state; animation blending integrated.
- [x] **Tactical Sprint**: "Weapon-up" sprint logic with double-tap activation and duration timer.
- [x] **Slide Mechanic**: Implemented momentum-based sliding with friction decay and "Slide Canceling" support.
- [x] **Intelligent Drone Camera**: 3-Layer Hybrid Architecture (Intent → Motion Plan → Physics) for cinematic menu/spectating.
- [x] **Local Movement Test**: Button to instantly test movement mechanics without matchmaking.

## Phase 3 – Gunsmith & Arsenal (IN PROGRESS)
**Goal:** Implement the core weapon customization and leveling systems.

#### Tasks:
- [ ] **Data Foundations**
    - [ ] Weapon Data Constants (Base stats, categories)
    - [ ] Attachment Data Constants (Modifiers, models, categories)
- [ ] **Weapon Attachment System**
    - [ ] Backend logic to apply modifiers to base stats
    - [ ] Real-time model swapping on weapon instances
- [ ] **Global Progression**
    - [ ] Weapon Leveling System (XP calculation & ranks)
    - [ ] Unlockable Content (Mapping level → attachment)
- [ ] **Loadout Integration**
    - [ ] Extend `LoadoutService` for attachment persistence
    - [ ] Save/Load custom weapon builds
- [ ] **Gunsmith UI**
    - [ ] Attachment Selection Grid
    - [ ] Real-time Stat Comparison (Radar/Bar graphs)
    - [ ] Weapon 3D Preview Camera

#### Dependencies:
- **Core Systems:** `PlayerDataService` for XP storage.
- **UI Framework:** `ViewManager` for screen transitions.
- **Assets:** Weapon and attachment models (using placeholders for now).

#### Success Metrics:
1. Players can equip an optic and see it visually on the weapon.
2. Equipping a "Heavy Barrel" increases recoil control but decreases ADS speed.
3. Weapon XP increases after simulated kills/actions and persists across sessions.
4. Gunsmith UI correctly displays "Locked" state for items above weapon level.

## Recent Improvements (15.01.2026)
- ✅ **Drone Camera Refactor**:
    - Implemented **3-Layer Hybrid Architecture** (Intent / Motion Plan / Physics).
    - Added **Semantic Framing**: Camera evaluates angles for best visibility.
    - Added **Predictive Filtering**: Zero-lag velocity extrapolation.
    - Added `DroneSettingsUI` for real-time parameter tuning.
- ✅ **Documentation Update**:
    - Updated `README.md` with high-level architecture overview.
    - Added `DRONE_TUNING_GUIDE.md` for camera configuration.

## Recent Improvements (13.01.2026)
- ✅ **Movement System Enhancements**:
    - Migrated to `RunService.PreSimulation` for physics updates (per documentation)
    - Added smooth speed interpolation for natural movement feel
    - Improved FOV transitions with configurable lerp factors
    - Enhanced AnimationController with layered animation priority system
- ✅ **Input System Refactoring**:
    - Migrated to ContextActionService for desktop + controller support
    - Improved abstraction and scalability
- ✅ **Server Services**:
    - Created MatchmakingService with extensible lobby system
    - Created LoadoutService for weapon persistence
- ✅ **Framework Refactor**:
    - Standardized `Signal` and `Spring` utilities in `src/shared/Utils`
    - Decoupled `Store` and `CameraController` from internal implementations
    - Improved Client Loader robustness
- ✅ **Bug Fixes**:
    - Fixed workspace JSON model error (SpawnLocation TeamColor)
    - Fixed missing server services (prevented server crashes)

---
*Last Updated: 15.01.2026*