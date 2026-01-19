```markdown
# Advanced Movement System (Roblox)
### Warzone-Inspired Modular Character Movement & Animation Architecture

This document describes the **design, architecture, and implementation roadmap** for a modern, responsive, Warzone-inspired movement system built on **Roblox’s Humanoid framework**.

The goal is to achieve:
- Tight, predictable movement
- Animation-driven feel with code-controlled logic
- Competitive responsiveness
- Extensible architecture for future mechanics (slide, vault, lean, etc.)

---

## 1. Design Goals

### Core Pillars
- **Responsiveness** – Immediate feedback to player input
- **Readability** – Movement states are clear to the player and observers
- **Consistency** – Same input produces the same result
- **Modularity** – Each system can be swapped or extended
- **Network Safety** – Client-side responsiveness with server authority

### Non-Goals
- Full root-motion locomotion (not natively supported by Roblox)
- Physics-driven ragdoll movement
- Animation-locked controls

---

## 2. High-Level Architecture

```

Player Input
↓
Input Controller
↓
Movement State Machine
↓
Movement Controller (Humanoid)
↕
Animation State Manager
↓
Animation Tracks (Priority + Blend)

```

Each layer has **one responsibility** and communicates via clean state data.

---

## 3. Folder Structure

```

StarterPlayer
└── StarterCharacterScripts
├── MovementController.client.lua
├── AnimationController.client.lua
├── StateMachine.lua
├── InputController.client.lua
└── Config.lua

```

Optional:
```

ReplicatedStorage
└── Shared
├── MovementEnums.lua
└── AnimationData.lua

```

---

## 4. Core Systems

---

### 4.1 Input Controller

**Responsibility:**  
Capture raw player intent and normalize it into actions.

**Roblox Tools:**
- UserInputService
- ContextActionService (optional)

**Outputs:**
- MoveVector
- SprintHeld
- CrouchToggle
- JumpPressed
- AimHeld

**Notes:**
- Input logic lives **only on the client**
- Input is *intent*, not movement

---

### 4.2 Movement State Machine

**Responsibility:**  
Decide *what the character is doing*, not *how it moves*.

**Primary States:**
- Idle
- Walk
- Run
- Sprint
- Crouch
- Jump
- Freefall
- Land
- Slide (future)
- Vault (future)

**Inputs:**
- Input Controller
- Humanoid:GetState()
- Velocity / MoveDirection

**Outputs:**
- CurrentMovementState
- SpeedMultiplier
- AnimationState

---

### 4.3 Movement Controller

**Responsibility:**  
Translate state → physical movement.

**Roblox Tools:**
- Humanoid:Move()
- Humanoid.WalkSpeed
- Humanoid.JumpPower

**Key Concepts:**
- Speed is controlled via multipliers
- Acceleration and deceleration are simulated in code
- Humanoid remains authoritative for physics

**Example Speed Model:**

| State   | WalkSpeed |
|--------|-----------|
| Walk   | 12        |
| Run    | 16        |
| Sprint | 22        |
| Crouch | 8         |

---

### 4.4 Animation Controller

**Responsibility:**  
Play, blend, and stop animations based on state.

**Roblox Tools:**
- Animation
- AnimationTrack
- Animation Priority
- Animation Events

**Animation Layers:**
- Base Locomotion (Idle / Walk / Run)
- Movement Modifiers (Sprint / Crouch)
- Actions (Jump / Land / Reload / Fire)

**Rules:**
- Never spam `LoadAnimation`
- Cache AnimationTracks
- Fade between animations (0.1–0.25s)

---

### 4.5 Animation Priority System

**Priority Order (Low → High):**
1. Idle
2. Movement
3. Action
4. Override (Vaults, Slides)

Higher priority animations override lower ones without stopping them.

---

## 5. Animation Philosophy (Warzone-Style)

- **In-place locomotion** for movement
- **Script-controlled velocity**
- **Animation-assisted transitions**
- **Event markers** for:
  - Footsteps
  - Land timing
  - Slide exit windows

This avoids root-motion limitations while preserving animation feel.

---

## 6. Networking Model

### Client
- Handles input
- Predicts animation
- Feels instant

### Server
- Owns character physics
- Validates movement
- Replicates position

**Rule:**  
Animations = client-side  
Movement = server-authoritative  

---

## 7. Extensibility Hooks

Designed to easily support:

- Sliding
- Vaulting
- Leaning
- Stamina system
- Weapon-dependent movement
- Animation motion matching (advanced)

---

## 8. Roadmap

### Phase 1 – Foundation
- [ ] Custom Input Controller
- [ ] Movement State Machine
- [ ] Walk / Run / Sprint
- [ ] Idle / Walk / Run animations
- [ ] Replace default Animate script

---

### Phase 2 – Combat Readiness
- [ ] ADS movement scaling
- [ ] Jump / Fall / Land states
- [ ] Animation priorities
- [ ] Footstep animation events

---

### Phase 3 – Advanced Movement
- [ ] Crouch system
- [ ] Sprint-to-slide prototype
- [ ] Momentum preservation
- [ ] Camera-relative movement tuning

---

### Phase 4 – Polish & Performance
- [ ] Animation blending improvements
- [ ] State transition smoothing
- [ ] Network jitter reduction
- [ ] Debug visualizers (states, speed)

---

### Phase 5 – Experimental
- [ ] Motion matching prototype
- [ ] Procedural leaning
- [ ] IK foot placement (if feasible)
- [ ] Parkour / vault system

---

## 9. Guiding Principles

- **State drives animation, not input**
- **Movement logic > animation logic**
- **Predictability beats realism**
- **Every mechanic must be interruptible**
- **If it feels delayed, it’s wrong**

---

## 10. Final Notes

This system intentionally avoids Roblox’s default animation controller to achieve:
- Cleaner state control
- Higher skill ceiling
- Competitive-grade responsiveness

Treat this movement system as **core engine code**, not gameplay logic.

---

### Author Intent
Built for FPS / TPS experiences that demand **tight movement**, **clear animation readability**, and **long-term extensibility**.

