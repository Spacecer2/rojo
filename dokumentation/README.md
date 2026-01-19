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

### Phase 3: Code Health & Polish (RECENT)
- [x] **Linting & Standards**: Enforced `Selene` standards across the codebase (deprecated APIs fixed, variable shadowing resolved).
- [x] **Toolchain**: Integrated `Aftman` for tool management (`Selene`, `Rojo`, `Stylua`).
- [x] **Stability**: Fixed logical redundancies in UI managers and improved error handling in character controllers.

### Phase 4: Gunsmith & Arsenal (IN PROGRESS)
- [ ] **Attachment System**: Modular data structure for weapon modifications.
- [ ] **Gunsmith UI**: Real-time stat visualization (Radar/Bar graphs).
- [ ] **Weapon Leveling**: XP progression and unlock tracks.

---

## 📂 Project Structure
```text
src/
├── character/        # Movement, FSM, and Procedural Animation
├── client/
│   ├── Controllers/  # Camera, Interface, and Input logic
│   ├── UI/           # Roact/Fusion-style View components
│   └── ...
├── server/
│   ├── Services/     # Data, Player, Matchmaking, and Loadout services
│   └── ...
├── shared/           # Network framework, Types, Constants, and Utils (Spring, Signal)
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
