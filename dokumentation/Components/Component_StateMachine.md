# Component: State Machine

## System Design & Vision

The `StateMachine` (Finite State Machine) is the central brain of the character. Its design is rooted in the philosophy of providing a single, authoritative source of truth for the player's current logical state. This is crucial for preventing illegal or contradictory actions (e.g., sprinting while prone) and ensuring consistent, predictable behavior across all game systems. The vision is to create a robust and flexible state management system that can gracefully handle complex player actions and interactions, while also providing clear and predictable transitions between different states. This underpins the "snappy responsiveness" and "tight controls" that are hallmarks of the Warzone experience.

## 🛠️ Implementation Details
- **Location**: `src/character/StateMachine.luau`
- **Synchronization**: Leverages **Instance Attributes** (`Character:SetAttribute("MovementState", value)`) for efficient replication to the server and for allowing other client-side components to react to state changes without direct coupling.

## 📊 Supported States
The `StateMachine` defines and manages a comprehensive set of character states, each with distinct behaviors and permissible transitions:

-   **Idle**: The character is stationary and not performing any active movement.
-   **Walk / Run**: Standard ground-based locomotion.
-   **Sprint**: High-speed forward movement, often with unique animation and weapon handling characteristics.
-   **Crouch**: A low-profile movement state, reducing visibility and increasing accuracy but decreasing speed.
-   **Prone**: The lowest-profile movement state, offering maximum concealment but minimal mobility.
-   **ADS (Aim Down Sights)**: A combat-focused state where the player is aiming their weapon precisely, typically involving a zoomed-in camera and reduced movement speed.
-   **Jump / Freefall / Land**: States governing airborne movement and the transitions associated with leaving and returning to the ground.
-   **Slide**: A dynamic movement state initiated from a sprint, allowing for rapid horizontal traversal while maintaining a low profile (planned for future implementation).

## 🔄 State Transitions
The FSM strictly enforces rules for how the character can move between states. This ensures logical consistency and prevents unexpected behavior.

1.  **Event-Driven Transitions**: State changes are primarily triggered by player input (via the `InputManager`) or by game events (e.g., taking damage, falling).
2.  **Centralized Control**: The `StateMachine` acts as the "Single Source of Truth." When a state changes:
    *   It fires a `StateChanged` `BindableEvent` locally, allowing for internal component reactions.
    *   It updates the `MovementState` attribute on the character, enabling server-side systems and other client-side components (like `AnimationController` and `MovementController`) to react to this new state.
3.  **Prioritization Logic**: Each state has a defined priority, ensuring that higher-priority actions (e.g., ADS) can override lower-priority actions (e.g., running) when appropriate.

## 🚀 Warzone-Specific Logic
- **Landing Mechanics**: When transitioning to the `Land` state, the FSM (via the `MovementController`) applies a temporary speed debuff and visual effects (e.g., camera shake), mimicking the "heavy" and impactful landing feel of *Call of Duty: Modern Warfare (2019)*.
- **Advanced Movement State Chains**: The system is built to support complex movement chains crucial to Warzone, such as seamlessly transitioning from sprint to slide, and slide to ADS, while maintaining responsiveness and fluid animation.
- **State Priority Balancing**: Careful tuning of state priorities ensures that player actions like ADS immediately take precedence over other movement states, providing the "snappy" control expected in a competitive FPS.

---
*Developed for high-fidelity state synchronization and responsive character control.*
