# Advanced Movement System Roadmap (Refined)

## 1. Core Systems Architecture

### 1.1 Input Controller
**Responsibility:** Capture raw player intent and normalize it into actions.
**API Choice:** 
- **`ContextActionService`**: Primary tool for Actions (Sprint, Crouch, Jump, Interact).
    - *Why?* Built-in support for mobile touch buttons, priority handling (e.g., UI overriding game input), and easy unbinding.
- **`UserInputService`**: Secondary tool for raw axis data (WASD Vector, MouseDelta).
    - *Why?* Better for continuous analog input.

**Outputs:**
- `MoveVector` (Vector3)
- Signals: `SprintToggled`, `CrouchToggled`, `JumpPressed`

### 1.2 Movement State Machine
**Responsibility:** Determine the *Single Source of Truth* for the character's behavior.
**Synchronization:** **Instance Attributes**
- The State Machine writes to `Character:SetAttribute("MovementState", "Run")`.
- Other systems (Animation, UI) listen via `Character:GetAttributeChangedSignal("MovementState")`.
- *Benefit:* Decoupled architecture; systems don't need to require each other, they just observe the Character.

**States:**
- `Idle`, `Walk`, `Run`, `Sprint`
- `Crouch`, `CrouchWalk`
- `Jump`, `Freefall`, `Land`
- `Slide` (Future)

### 1.3 Movement Controller
**Responsibility:** Translate State → Physics.
**Execution Context:** **`RunService.PreSimulation`** (formerly Stepped)
- *Why?* Physics forces and velocity changes should be applied *before* the physics engine solves the frame to prevent jitter.

**Mechanics:**
- **Speed:** Managed via `Humanoid.WalkSpeed` (interpolated for smooth transitions).
- **Forces:** `VectorForce` or `LinearVelocity` may be used later for Sliding/Dashing to override default friction.

### 1.4 Animation Controller
**Responsibility:** Visual representation of State.
**API Choice:** `Humanoid:LoadAnimation()` (via Animator)
**Logic:**
- Listens to `MovementState` attribute.
- Uses `TweenService` or `AdjustSpeed()` to blend between animations (e.g., Walk -> Run).
- **Priority:**
    - `Action` (Jump/Land) > `Movement` (Run/Slide) > `Idle`.

### 1.5 Procedural Animator (New)
**Responsibility:** Dynamic, physics-based secondary motion (Sway, Tilt, Bobbing).
**Execution Context:** **`RunService.PreRender`** (formerly RenderStepped)
- *Why?* Visual updates must run every screen frame for maximum smoothness (high refresh rate monitors).

**Features:**
- **Movement Tilt:** Rotates `RootJoint` based on `AssemblyLinearVelocity` (local space).
- **Sway:** Springs applied to Camera or Torso based on MouseDelta.
- **Foot IK:** `IKControl` (Future) for planting feet on uneven ground.

---

# Project Roadmap: Warzone MW 2019 Recreation

This document outlines the complete development lifecycle for the project, aimed at delivering a AAA-grade Warzone experience on Roblox.

---

## 🏗️ Phase 1: Foundational Infrastructure (COMPLETED)
*Goal: Build a scalable, high-performance base.*
- [x] **Dev Environment**: Rojo, Git, and automated Luau linting.
- [x] **Networking**: Custom middleware for safe, efficient Remote communication.
- [x] **Data Architecture**: Secure `DataStore` patterns for player profiles and persistence.
- [x] **System Hub**: Modular controller/service architecture for decoupled logic.

---

## 🏃 Phase 2: Advanced Movement & Character (IN PROGRESS)
*Goal: Perfect the "MW 2019 Feel" (Heavy but Fluid).*
- [x] **State Machine**: Attribute-based sync for Idle, Walk, Sprint, ADS, and Air states.
- [x] **ADS Mechanics**: Responsive FOV scaling and sensitivity dampening.
- [x] **Tactical Sprint**: "Weapon-up" high-speed sprint with stamina and "Double-Tap" activation.
- [ ] **The "Slide" Suite**:
    - Momentum-based sliding with custom friction.
    - **Slide Canceling** tech for high-level movement.
- [x] **Stance Controls**: Fully integrated Crouch and Prone systems (Crouch implemented).
- [x] **Procedural Juice**: Physics-based head-bob, movement tilt, and weapon sway (Initial pass).
- [x] **Local Movement Test**: Integrated "TEST MOVEMENT" button for instant bypass of matchmaking.

---

## 🔫 Phase 3: The Arsenal (Combat & Gunplay)
*Goal: Realistic ballistics and deep customization.*
- [ ] **Weapon Framework (V3)**:
    - Hybrid Hitscan/Projectile system (Bullet travel & drop).
    - Wall penetration and material-based damage falloff.
- [ ] **Gunsmith System**:
    - Modular 5-attachment system with visual model swapping.
    - Real-time stat modification (Mobility, Recoil, Range).
- [ ] **Visual Recoil**: Spring-driven camera kick and weapon vibration.
- [ ] **Reload Systems**: Support for Tactical (partial) and Dry (empty) reloads.

---

## 🚁 Phase 4: The Warzone Loop (Battle Royale)
*Goal: Implement the core mechanics of the BR experience.*
- [ ] **The Gas**: Circular hazard system with visual distortion and health drain.
- [ ] **Buy Stations**: Interactive kiosks for Killstreaks, Loadouts, and Revives.
- [ ] **Armor Plating**: Iconic 3-plate system with manual plating animations.
- [ ] **The Gulag**: 1v1 arena for eliminated players to earn a redeploy.
- [ ] **Contracts**: Scavenger, Recon, and Bounty missions for in-match rewards.

---

## 🖥️ Phase 5: UI/UX & Meta-Progression
*Goal: AAA-standard interface and player retention.*
- [ ] **Warzone Lobby**: Interactive 3D squad preview with dynamic lighting.
- [ ] **Loadout Editor**: High-fidelity "Armory Table" for weapon customization.
- [ ] **Global Progression**: Weapon XP, Player Levels, and Camo Challenges.
- [ ] **HUD**: Minimap (square/circle toggle), Compass, and dynamic Kill-feed.

---

## 🌍 Phase 6: Environment & Social
*Goal: Large-scale world-building and community features.*
- [ ] **Map Development**: Modular "Points of Interest" (POIs) with tactical verticality.
- [ ] **Audio Occlusion**: Advanced sound propagation through walls and materials.
- [ ] **Social Systems**: In-game clans, global leaderboards, and party management.

---

## 💎 Phase 7: Final Polish & Tech
*Goal: Optimization and visual excellence.*
- [ ] **Parallel Processing**: Moving physics/procedural logic to Actors (Parallel Luau).
- [ ] **Lighting & VFX**: Leveraging "Future" lighting for realistic metallic reflections.
- [ ] **Optimization Pass**: Aggressive LOD management for large-scale maps.

---

## 💡 Guiding Principles
1. **Fidelity Over Speed**: Do it right the first time; use physics over hacks.
2. **Predictable Gameplay**: The player should never fight the controls.
3. **Warzone DNA**: Every sound, animation, and UI element must feel authentic to MW 2019.

---
*Refined based on Roblox Engine API documentation: 13.01.2026*