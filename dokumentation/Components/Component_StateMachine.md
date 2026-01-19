# Component: State Machine

The **State Machine** (FSM) is the central brain of the character. It ensures that the player can only be in one logical state at a time, preventing illegal movement combinations (e.g., Sprinting while Crouched).

## 🛠️ Implementation Details
- **Location**: `src/character/StateMachine.luau`
- **Synchronization**: Uses **Instance Attributes** (`Character:SetAttribute("MovementState", value)`) for replication and external observer notification.

## 📊 Supported States
- **Idle**: Stationary.
- **Walk / Run**: Standard movement.
- **Sprint**: High-speed forward movement.
- **Crouch**: Low-profile, slow movement.
- **ADS**: Aiming Down Sights (Dynamic zoom).
- **Jump / Freefall / Land**: Airbone and transition logic.

## 🔄 State Transitions
The FSM handles the "Single Source of Truth." When a state changes:
1. It fires a `StateChanged` BindableEvent locally.
2. It updates the `MovementState` attribute.
3. The `AnimationController` and `MovementController` react to this new state.

## 🚀 Warzone-Specific Logic
- **Landing Stun**: When entering the `Land` state, the FSM (via the Controller) applies a temporary speed debuff, mimicking the "heavy" landing feel of MW 2019.
- **State Priority**: ADS usually overrides Run/Walk but can be overridden by Sprint depending on configuration.

---
*Developed for high-fidelity state synchronization.*
