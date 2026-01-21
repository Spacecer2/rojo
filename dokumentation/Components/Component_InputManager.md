# Component: Input Manager

## System Design & Vision

The Input Manager is the foundation of our player control system. It's designed to be a clean, decoupled "intent harvester" that translates raw hardware signals into semantic gameplay actions. The vision is to create a single source of truth for all player input, a system that is easy to maintain, extend, and adapt to different platforms (keyboard/mouse, controller, touch). This decoupling is critical for a clean and scalable architecture, as it allows other systems to react to player intent without having to worry about the complexities of input hardware.

## 🛠️ Implementation Details
- **Location**: `src/character/InputManager.luau`
- **APIs Used**: `UserInputService` for raw polling, `ContextActionService` for action binding, and `BindableEvent` for signal dispatch.

## 🕹️ Captured Inputs
| Input Key | Semantic Action | Type |
|-----------|-----------------|------|
| `WASD` | `MoveVector` | Vector3 (Normalized) |
| `LeftShift` | `Sprint` | Toggle/Hold |
| `C` | `Crouch` | Toggle |
| `Space` | `Jump` | Signal |
| `Mouse2` | `ADS` (Aim Down Sights) | Hold |

## 🧠 Design Philosophy
1. **Decoupling**: The Input Manager's sole responsibility is to translate raw input into semantic actions. It has no knowledge of the systems that consume these actions, such as movement or combat.
2. **Signal-Driven Architecture**: The Input Manager uses `BindableEvents` to broadcast player intent to the rest of the game. This creates a highly modular and event-driven architecture, where other systems can simply subscribe to the events they are interested in.
3. **Context-Awareness**: The Input Manager is aware of the game's context, such as whether the player is in a menu or in active gameplay. This allows it to suppress input when necessary, preventing unwanted actions.

## 🚀 Warzone-Specific Logic
- **ADS Integration**: The Input Manager is designed to robustly handle the `Aim Down Sights` (ADS) action, a core pillar of the MW 2019 combat loop. It correctly manages the "hold" and "toggle" behaviors for ADS, which is a common point of failure in many FPS games.
- **Advanced Movement Support**: The system is designed to handle the rapid state changes required for advanced movement techniques like "slide canceling," which will be a key feature of our game.

---
*Note: The transition to `ContextActionService` is a key part of our strategy to support multiple platforms with a single codebase.*
