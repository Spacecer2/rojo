# Component: Input Manager

The **Input Manager** is the "intent harvester" for the player. It translates raw hardware signals into semantic gameplay actions.

## 🛠️ Implementation Details
- **Location**: `src/character/InputManager.luau`
- **APIs Used**: `UserInputService` for raw polling, `BindableEvent` for signal dispatch.

## 🕹️ Captured Inputs
| Input Key | Semantic Action | Type |
|-----------|-----------------|------|
| `WASD` | `MoveVector` | Vector3 (Normalized) |
| `LeftShift` | `Sprint` | Toggle/Hold |
| `C` | `Crouch` | Toggle |
| `Space` | `Jump` | Signal |
| `Mouse2` | `ADS` (Aim Down Sights) | Hold |

## 🧠 Design Philosophy
1. **Decoupling**: The Input Manager doesn't know about movement physics. It only knows that a key was pressed.
2. **Signal-Driven**: Other systems (like the `StateMachine`) subscribe to `BindableEvents` to react instantly.
3. **Menu Awareness**: Input is suppressed if the player is in a menu (handled via `player:GetAttribute("InMenu")` check in the controller).

## 🚀 Warzone-Specific Logic
- **ADS Integration**: Specifically tracks `MouseButton2` to trigger the `ADS` state, which is a core pillar of the MW 2019 combat loop.
- **Sprint Buffer**: Designed to handle rapid state changes required for future "Slide Canceling" implementations.

---
*Note: Currently transitioning to ContextActionService for better Mobile support.*
