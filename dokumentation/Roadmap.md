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

## 2. Updated Roadmap

### Phase 1 – Foundation (Current Status)
- [x] **Project Setup**: Rojo & Folder Structure (`src/character`).
- [x] **Input Manager**: `ContextActionService` / `UserInputService` implementation.
- [x] **State Machine**: Finite State Machine (FSM) with Attribute Sync.
- [x] **Movement Controller**: Basic Walk/Run/Sprint logic.
- [x] **Animation Controller**: Basic R15 Animation playback (Idle/Walk/Run/Jump).
- [x] **Procedural Sway**: Basic Tilt/Sway on `RootJoint` using Springs.

### Phase 2 – Combat & Fluidity
- [ ] **Transition Smoothing**: Use `TweenService` or Springs for `WalkSpeed` changes (prevent instant snaps).
- [ ] **Crouch System**: Fully implement Crouch logic (Hitbox reduction, speed dampening).
- [ ] **Slide Mechanic**:
    - Impulse force (`VectorForce`).
    - Friction reduction (`CustomPhysicalProperties`).
    - Camera FOV Tween.
- [ ] **Camera System**: Custom `CameraOffset` handling for Crouch/Slide.

### Phase 3 – Polish & Advanced Tech
- [ ] **Inverse Kinematics (IK)**: Use `IKControl` for foot placement on slopes.
- [ ] **Motion Matching**: Select start-frames of animations based on velocity (prevent foot sliding).
- [ ] **Network Replication**: Ensure Attributes replicate correctly to server for anti-cheat validation.
- [ ] **Sound Integration**: Footstep sounds triggered by `AnimationEvents`.

---

## 3. Guiding Principles
1.  **Server Authoritative, Client Predictive**: Input is immediate on client; Server validates via Attributes/Position checks.
2.  **Decoupled Systems**: Components communicate via Attributes and Signals, never direct requires where possible.
3.  **Physics First**: Movement should look good even without animations (via Procedural Tilt/Sway).

---
*Refined based on Roblox Engine API documentation: 13.01.2026*