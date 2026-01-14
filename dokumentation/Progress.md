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

## Phase 2 – Combat & Fluidity
- [x] **ADS Scaling**: Implemented dynamic FOV zoom and movement speed multipliers with smooth interpolation.
- [x] **Landing Stun**: Added "heavy land" logic for high falls.
- [x] **Crouch System**: Basic toggle implemented with CrouchWalk state; animation blending integrated.
- [x] **Tactical Sprint**: "Weapon-up" sprint logic with double-tap activation and duration timer.
- [ ] **Slide Mechanic**: In R&D (momentum/friction focus).
- [x] **Local Movement Test**: Button to instantly test movement mechanics without matchmaking.

## Phase 3 – Gunsmith & Arsenal
- [ ] **Weapon Framework**: Foundation for modular attachments.
- [ ] **Lobby System**: 3D character preview in main menu.
- [ ] **Loadout Management UI**: Client-side integration with server persistence.

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
*Last Updated: 13.01.2026*
