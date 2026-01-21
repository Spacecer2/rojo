# Components Documentation

This section details the individual game components that form the building blocks of our game systems. Our project follows a **Component-Based Architecture (CBA)**, a design pattern that promotes reusability, flexibility, and a clean separation of concerns.

## 🏛️ Component-Based Architecture

Instead of creating monolithic game objects with complex inheritance chains, we compose entities from smaller, independent components. Each component is responsible for a specific piece of functionality.

### Benefits of CBA
- **Reusability:** Components like `MovementController` can be attached to any entity that needs to move, whether it's a player, an AI, or a dynamic object.
- **Flexibility:** We can easily add, remove, or swap components to change an entity's behavior without rewriting large amounts of code.
- **Maintainability:** Smaller, focused components are easier to debug, test, and maintain.
- **Collaboration:** Different developers can work on different components simultaneously with minimal friction.

## 🧩 Core Components

Below are the core components that drive the main gameplay systems.

| Component | Purpose |
|-----------|---------|
| [CameraController](Component_CameraController.md) | Third-person camera system with hybrid drone architecture. Manages camera positioning, rotation, and effects. |
| [StateMachine](Component_StateMachine.md) | The "brain" of an entity. Manages character states (e.g., sprinting, sliding, aiming) and transitions between them. |
| [InputManager](Component_InputManager.md) | Normalizes player input from various sources and translates it into game-specific intents (e.g., "move forward," "fire weapon"). |
| [MovementController](Component_MovementController.md) | Applies forces and physics to an entity based on the current state from the `StateMachine`. Handles locomotion. |
| [ProceduralAnimator](Component_ProceduralAnimator.md) | Creates dynamic, procedural animations for weapon sway, camera bob, and other effects, adding a layer of realism. |
| [MenuController](Component_MenuController.md) | Manages the UI and navigation logic for the main menu and other interfaces. |
| [Gunsmith](Component_Gunsmith.md) | Handles the weapon customization system, allowing players to modify attachments and see real-time stat changes. |
| [CameraController_Critique](Component_CameraController_Critique.md) | An analysis and critique of our camera implementation, a key component for the game's feel. |


---

**For feature-level documentation, see [Features/](../Features/README.md)**
