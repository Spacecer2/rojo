# Project Progress

## Overview
Tracking the implementation of the Advanced Movement System and Foundational Infrastructure.

## Roadmap

### Phase 1 – Foundation
- [x] **Project Setup**: Rojo configured, folder structure created.
- [x] **Folder Structure**: `StarterCharacterScripts` mapped to `src/character`.
- [x] **Custom Input Controller**: `InputManager.luau` implemented.
- [x] **Movement State Machine**: `StateMachine.luau` implemented.
- [x] **Movement Controller**: `MovementController.client.luau` fixed with defensive requiring.
- [x] **Animation Controller**: `AnimationController.client.luau` implemented and syncing via Attributes.
- [x] **Foundational Layers**:
    - [x] **Database Service**: `DataService.luau` with DataStore integration.
    - [x] **User Handling**: `PlayerService.luau` for join/leave logic.
    - [x] **Player Data**: `PlayerData.luau` shared template.
    - [x] **Network Framework**: `Network.luau` for easy Remote communication.
    - [x] **Leaderboard**: `LeaderboardService.luau` for visible player stats.
    - [x] **Robust Initialization**: Controllers now use `task.spawn` and `pcall` to ensure the game starts even if one service is slow.
    - [x] **Main Menu Integration**: Menu now locks movement and appears correctly on join.
    - [x] **UI Framework**: `ViewManager` and modular Views (Home, Loadout) implemented.
    - [x] **Matchmaking & Loadout Services**: Server-side infrastructure for lobbies and weapon persistence.
    - [x] **Signal Module**: Professional `Signal` class for decoupled communication.

### Phase 2 – Combat Readiness
- [x] **ADS movement scaling**: Implemented with FOV zoom and speed multipliers.
- [x] **Jump / Fall / Land states refinement**: Added landing stun logic and state transitions.
- [ ] Animation priorities
- [ ] Footstep animation events

### Phase 3 – Advanced Movement
- [ ] Crouch system (Basic toggle implemented, needs anims/physics tweaks)
- [ ] Sprint-to-slide prototype
- [ ] Momentum preservation

---
*Last Updated: 13.01.2026*